# Picata

**_This project is very much pre-alpha_**

Picata is a CMS & blog application I forked off from my personal website. At the
moment it's effectively a ton of pre-made [Wagtail](https://wagtail.org) "stuff"
(models, views, templatetags, middleware, hooks, etc.), made generic enough that
you can `pip install` the package, add it to your `INSTALLED_APPS`, and have a
CMS/blog up-and-running without having to spend weeks or months tailoring Wagtail
to your needs.

It's still under heavy development, with most documentation and a project
template pending but - if you're already working with Wagtail - the source
provides many working solutions to common problems. The repo for the aforementioned
personal website [lives on GitHub](https://github.com/hipikat/hpk.io), and
demonstrates a working implementation of this package (requiring, in fact, only
this package as a dependency).

## What's in the box?

- [Wagtail](https://wagtail.org) (on [Django](https://www.djangoproject.com)) as the CMS & web frameworks
- Runs on [PostgreSQL](https://www.postgresql.org); loaded with scripts for managing the
  database lifecycle and snapshots
- [Tailwind CSS](https://tailwindcss.com) in [Sass](https://sass-lang.com) for front-end styling
- [lxml](https://lxml.de) is used for fast HTML processing in a middleware layer

### Development features & workflows

Everything's written in very modern Python (circa 2025), with agressive linting and type-checking
thanks to [mypy](https://mypy-lang.org),
[Pydantic](https://docs.pydantic.dev/latest/)/[Pyright](https://github.com/microsoft/pyright),
and [Ruff](https://docs.astral.sh/ruff/). Picata uses [Django Debug Toolbar](https://django-debug-toolbar.readthedocs.io),
[runserver_plus](https://django-extensions.readthedocs.io/en/latest/runserver_plus.html), and
[iPython](https://www.google.com/search?client=safari&rls=en&q=ipython&ie=UTF-8&oe=UTF-8) for
development workflows. The project itself uses [pre-commit](https://pre-commit.com) extensively,
with 16 hooks to keep everything neat and tidy.

All front-end code is written in [TypeScript](https://typescript-eslint.io), with
[React](https://react.dev) set up and ready-to-go in the [Webpack](https://webpack.js.org) pipeline,
if you're into that kind of thing.

### Holding things together

- Uses [UV](https://github.com/astral-sh/uv) and
  [pyproject.toml](https://packaging.python.org/en/latest/specifications/pyproject-toml/)
  exclusively for Python project management
- [Just](https://just.systems) as a task runner, with over 60 recipes (at last count)
- [OpenTofu](https://opentofu.org) (a fork of [Terraform](https://www.terraform.io)) and
  [cloud-init](https://cloud-init.io) for all DevOps & rapid deployment
- [Docker](https://www.docker.com) and [Docker Compose](https://docs.docker.com/compose/) for local
  development
