####
# This is the Dockerfile for hpk.io development.
#
# Based on debian:buster-slim (Debian 10; official support till July 2022)
#
# Build targets:
#
# hpk-app-base – Installs the production Python virtual environment for the app
#   app, on a Python slim-buster image, as well as the `picata` executable.
#   The virtualenv is installed local to the project (at /app/.venv/).
#
# hpk-node-base – Installs the node environment on top of a Node slim-buster
#   image, including development packages (i.e. /app/node_modules/).
#
# hpk-app-bundler – Extends hpk-node-base, copies all source files that get
#   consumed by Webpack, and runs Webpack builds (for both dev and production),
#   resulting in a build directory at /app/var/build-webpack/.
#
# hpk-app-dev – Sets up the system environment for running the application,
#   installs Python development packages, copies the "bundled" code produced
#   by webpack in hpk-app-bundler, calls Django's `collectstatic` (which
#   creates /app/static/), and runs the development server (runserver_plus).
#
# hpk-nginx – Installs config on an Nginx image for a "staging" web server.
#
####


#######################################
# Base image for web containers
FROM python:3.12-slim-bookworm AS hpk-app-base
LABEL version="0.0.1"
LABEL Description="Base image for hpk app-enabled containers"
LABEL maintainer="Ada Wright <ada@hpk.io>"

ENV LANG en_AU.UTF-8
ENV PYTHONUNBUFFERED=TRUE
ENV DJANGO_SETTINGS_MODULE=hpk.settings.dev

# Install system packages (necessary ones, then useful-for-development ones)
RUN apt-get update
RUN apt-get install -y --no-install-recommends \
    curl wait-for-it libpq5 libpq-dev
RUN apt-get install -y --no-install-recommends \
    neovim sudo tree zsh
# RUN apt-get clean && rm -rf /var/lib/apt/lists/*

# Add the 'wagtail' user and give it the /app directory
RUN groupadd -g 1500 wagtail
RUN useradd -u 1500 -g wagtail -s /usr/bin/zsh wagtail
RUN echo "wagtail ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers
RUN mkdir -p /app && chown wagtail:wagtail /app

# Set up caches in a local, persistent volume
VOLUME /mnt/hpk-caches
RUN mkdir -p /mnt/hpk-caches/uv && chown -R wagtail:wagtail /mnt/hpk-caches/uv
RUN mkdir -p /mnt/hpk-caches/apt && \
    echo 'Dir::Cache::Archives "/mnt/hpk-caches/apt/";' > /etc/apt/apt.conf.d/02cache-dir

# Install Just
RUN curl --proto '=https' --tlsv1.2 -sSf https://just.systems/install.sh | \
    bash -s -- --to /usr/local/bin

# Install UV and set the cache directory
RUN curl -LsSf https://astral.sh/uv/install.sh | \
    UV_UNMANAGED_INSTALL="/usr/local/bin" HOME="/root" sh
ENV UV_CACHE_DIR=/mnt/hpk-caches/uv

# Switch to the 'wagtail' user and /app directory, from herein on
WORKDIR /app
USER wagtail

# Install the project's Python environment
COPY --chown=wagtail:wagtail pyproject.toml uv.lock /app/
RUN uv sync --all-groups --directory /app --no-progress --locked


#######################################
# Base image for Node-enabled containers
FROM node:20.17-bookworm-slim AS hpk-node-base
LABEL version="0.0.1"
LABEL Description="Base image for Node-enabled containers"
LABEL maintainer="Ada Wright <ada@hpk.io>"

# Add 'wagtail' user
RUN groupadd -g 1500 wagtail
RUN useradd -u 1500 -g wagtail wagtail
RUN echo "wagtail ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoer

# Set up caches in a local, persistent volume
VOLUME /mnt/hpk-caches
RUN mkdir -p /mnt/hpk-caches/npm && chown -R wagtail:wagtail /mnt/hpk-caches/npm
ENV npm_config_cache=/mnt/hpk-caches/npm

# Switch to the 'wagtail' user and /app directory, from herein on
RUN mkdir -p /app && chown wagtail:wagtail /app
WORKDIR /app
USER wagtail
ENV PATH /app/node_modules/.bin:$PATH

# Install the project's Node dependencies
COPY --chown=wagtail:wagtail package.json package-lock.json /app/
RUN npm ci


#######################################
# Webpack bundler
FROM hpk-node-base AS hpk-bundler
LABEL Description="Webpack bundler image"

ENV SHELL=/bin/bash

# COPY --from=hpk-app-base /app/bin /app/bin/
# COPY --from=hpk-app-base /app/cli /app/cli/

# Import only the things that get consumed by Webpack
COPY config/webpack.config.mjs config/webpack.config.mjs
COPY src/entrypoint.tsx src/entrypoint.tsx
COPY src/components src/components
COPY src/styles.sass src/styles.sass
COPY tailwind.config.mjs tailwind.config.mjs
COPY src/static src/static

# # Ensure the build directory is declared a volume, and writable by 'wagtail'
# USER root
# VOLUME /app/build
# RUN mkdir -p /app/build && chown wagtail:wagtail /app/build
# USER wagtail

# TODO: see if we can just ditch this command, since the
# bundler service takes care of it in the form of volumes
# (but i think that needs to run before the server can start?)
RUN npm run webpack


#######################################
# Development image for the web app
FROM hpk-app-base AS hpk-app-dev
LABEL Description="Development image for the picata app"

ENV SECRET_KEY=Static_SECRET_KEY_for_Development_Hashing_Goodness

COPY --from=hpk-bundler /app/build /app/build
COPY src/ /app/src/
COPY Justfile /app/Justfile

RUN mkdir -p /app/media /app/logs
RUN just dj collectstatic

EXPOSE 8050/tcp
EXPOSE 8060/tcp
# CMD ["just", "dj", "runserver_plus", "0.0.0.0:8060"]
