"""Django settings for the project.

Generated by 'django-admin startproject' using Django 5.1.

For more information on this file, see
https://docs.djangoproject.com/en/5.1/topics/settings/

For the full list of settings and their values, see
https://docs.djangoproject.com/en/5.1/ref/settings/
"""

import contextlib
from os import getenv
from pathlib import Path

from hpk.helpers import get_public_ip
from hpk.log_utils import FormatterWithEverything

SRC_DIR = Path(__file__).resolve().parent.parent.parent
BASE_DIR = Path(SRC_DIR).parent
LOG_DIR = BASE_DIR / "logs"

INTERNAL_IPS = ["*"]

ALLOWED_HOSTS = [*getenv("FQDN", "").split(), "localhost", "127.0.0.1"]
with contextlib.suppress(Exception):
    public_ip = get_public_ip()
    if public_ip:
        ALLOWED_HOSTS.append(str(public_ip))

SECRET_KEY = getenv("SECRET_KEY")


# Application definition

INSTALLED_APPS = [
    # Local apps
    "hpk.apps.Config",
    # Wagtail
    "wagtail.contrib.forms",
    "wagtail.contrib.redirects",
    "wagtail.contrib.routable_page",
    "wagtail.contrib.settings",
    "wagtail.embeds",
    "wagtail.sites",
    "wagtail.users",
    "wagtail.snippets",
    "wagtail.documents",
    "wagtail.images",
    "wagtail.search",
    "wagtail.admin",
    "wagtail_modeladmin",
    "wagtail",
    "modelcluster",
    "taggit",
    # Django apps
    "django.contrib.admin",
    "django.contrib.auth",
    "django.contrib.contenttypes",
    "django.contrib.sessions",
    "django.contrib.sitemaps",
    "django.contrib.messages",
    "django.contrib.staticfiles",
]

MIDDLEWARE = [
    "django.contrib.sessions.middleware.SessionMiddleware",
    "django.middleware.common.CommonMiddleware",
    "django.middleware.csrf.CsrfViewMiddleware",
    "django.contrib.auth.middleware.AuthenticationMiddleware",
    "django.contrib.messages.middleware.MessageMiddleware",
    "django.middleware.clickjacking.XFrameOptionsMiddleware",
    "django.middleware.security.SecurityMiddleware",
    "wagtail.contrib.redirects.middleware.RedirectMiddleware",
    "hpk.middleware.HTMLProcessingMiddleware",
]

ROOT_URLCONF = "hpk.urls"

TEMPLATES = [
    {
        "BACKEND": "django.template.backends.django.DjangoTemplates",
        "DIRS": [SRC_DIR / "templates"],
        "APP_DIRS": True,
        "OPTIONS": {
            "context_processors": [
                "django.template.context_processors.debug",
                "django.template.context_processors.request",
                "django.contrib.auth.context_processors.auth",
                "django.contrib.messages.context_processors.messages",
                "wagtail.contrib.settings.context_processors.settings",
            ],
        },
    },
]

WSGI_APPLICATION = "hpk.wsgi.application"


# Database
# https://docs.djangoproject.com/en/5.1/ref/settings/#databases

DATABASES = {
    "default": {
        "ENGINE": "django.db.backends.postgresql",
        "NAME": getenv("DB_NAME"),
        "USER": getenv("DB_USER"),
        "PASSWORD": getenv("DB_PASSWORD"),
        "HOST": getenv("DB_HOST", "localhost"),
        "PORT": "5432",
    },
}


# Password validation
# https://docs.djangoproject.com/en/5.1/ref/settings/#auth-password-validators

AUTH_PASSWORD_VALIDATORS = [
    {
        "NAME": "django.contrib.auth.password_validation.UserAttributeSimilarityValidator",
    },
    {
        "NAME": "django.contrib.auth.password_validation.MinimumLengthValidator",
    },
    {
        "NAME": "django.contrib.auth.password_validation.CommonPasswordValidator",
    },
    {
        "NAME": "django.contrib.auth.password_validation.NumericPasswordValidator",
    },
]


# Logging
# https://docs.djangoproject.com/en/5.1/topics/logging/

LOGGING = {
    "version": 1,
    "disable_existing_loggers": False,
    "formatters": {
        "complete": {
            "()": FormatterWithEverything,
        },
        "verbose": {
            "format": "----\n{levelname} {asctime} {name}:{module}\n{message}",
            "style": "{",
        },
        "simple": {
            "format": "{levelname} {module}: {message}",
            "style": "{",
        },
    },
    "handlers": {
        "console": {
            "class": "logging.StreamHandler",
            "formatter": "verbose",
            "level": "INFO",
        },
        "django_log": {
            "level": "INFO",
            "class": "hpk.log_utils.RotatingDailyFileHandler",
            "filename": LOG_DIR / "django.log",
            "formatter": "verbose",
        },
        "hpk_log": {
            "level": "INFO",
            "class": "hpk.log_utils.RotatingDailyFileHandler",
            "filename": LOG_DIR / "hpk.log",
            "formatter": "verbose",
        },
        "warnings_log": {
            "level": "WARNING",
            "class": "logging.handlers.RotatingFileHandler",
            "filename": LOG_DIR / "warnings.log",
            "maxBytes": 1024 * 1024 * 5,
            "backupCount": 5,
            "formatter": "verbose",
        },
    },
    "loggers": {
        "hpk": {
            "handlers": ["hpk_log"],
            "level": "INFO",
            "propagate": True,
        },
        "django": {
            "handlers": ["django_log", "warnings_log"],
            "level": "INFO",
            "propagate": True,
        },
        "django.request": {
            "handlers": ["django_log", "warnings_log"],
            "level": "WARNING",
            "propagate": False,
        },
        "django.template": {
            "handlers": ["django_log", "warnings_log"],
            "level": "WARNING",
            "propagate": False,
        },
        "wagtail": {
            "handlers": ["django_log", "warnings_log"],
            "level": "WARNING",
            "propagate": True,
        },
        "gunicorn.error": {
            "handlers": ["console"],
            "level": "ERROR",
            "propagate": False,
        },
        "watchdog.observers.inotify_buffer": {
            "handlers": ["console"],
            "level": "WARNING",
            "propagate": False,
        },
    },
    "root": {
        "handlers": ["console"],
        "level": "INFO",
    },
}


# Internationalization
# See https://docs.djangoproject.com/en/5.1/topics/i18n/

LANGUAGE_CODE = "en-us"

TIME_ZONE = getenv("TIMEZONE", "UTC")

USE_I18N = True

USE_TZ = True


# Static files (CSS, JavaScript, Images)
# https://docs.djangoproject.com/en/5.1/howto/static-files/

STATICFILES_FINDERS = [
    "django.contrib.staticfiles.finders.FileSystemFinder",
    "django.contrib.staticfiles.finders.AppDirectoriesFinder",
]

STATICFILES_DIRS = [
    SRC_DIR / "static",
    BASE_DIR / "build/webpack",
]

STATIC_ROOT = BASE_DIR / "static"
STATIC_URL = "/static/"

MEDIA_ROOT = BASE_DIR / "media"
MEDIA_URL = "/media/"

# Default storage settings, with the staticfiles storage updated.
# See https://docs.djangoproject.com/en/5.1/ref/settings/#std-setting-STORAGES
STORAGES = {
    "default": {
        "BACKEND": "django.core.files.storage.FileSystemStorage",
    },
    "staticfiles": {
        "BACKEND": "django.contrib.staticfiles.storage.StaticFilesStorage",
    },
}


# Email
# See https://docs.djangoproject.com/en/5.1/topics/email/

EMAIL_BACKEND = "django.core.mail.backends.smtp.EmailBackend"
EMAIL_HOST = "smtp.gmail.com"
EMAIL_PORT = 587
EMAIL_USE_TLS = True
EMAIL_HOST_USER = getenv("ADMIN_EMAIL")
EMAIL_HOST_PASSWORD = getenv("GMAIL_PASSWORD")
DEFAULT_FROM_EMAIL = getenv("ADMIN_EMAIL")


# Wagtail
# See https://docs.wagtail.org/en/stable/

WAGTAIL_SITE_NAME = "Hpk.io"

# Image serving
WAGTAILIMAGES_IMAGE_MODEL = "wagtailimages.Image"
WAGTAILIMAGES_SERVE_METHOD = "wagtail.images.views.serve.ServeView.as_view"

# Search - https://docs.wagtail.org/en/stable/topics/search/backends.html
WAGTAILSEARCH_BACKENDS = {
    "default": {
        "BACKEND": "wagtail.search.backends.database",
    },
}

# Base URL to use when referring to full URLs within the Wagtail admin backend -
# e.g. in notification emails. Don't include '/admin' or a trailing slash
WAGTAILADMIN_BASE_URL = "https://" + getenv("FQDN", "hpk.io")

# https://docs.wagtail.org/en/stable/reference/settings.html#general-editing
WAGTAILADMIN_RICH_TEXT_EDITORS = {
    "default": {
        "WIDGET": "wagtail.admin.rich_text.DraftailRichTextArea",
        "OPTIONS": {
            "features": [
                "h1",
                "h2",
                "h3",
                "h4",
                "h5",
                "h6",
                "bold",
                "italic",
                "ol",
                "ul",
                "code",
                "blockquote",
                "hr",
                "link",
                "document-link",
                "image",
                "embed",
                "superscript",
                "subscript",
                "strikethrough",
            ]
        },
    },
}

# Allowed file extensions for documents in the document library.
# This can be omitted to allow all files, but note that this may present a security risk
# if untrusted users are allowed to upload files -
# see https://docs.wagtail.org/en/stable/advanced_topics/deploying.html#user-uploaded-files
WAGTAILDOCS_EXTENSIONS = [
    "csv",
    "docx",
    "key",
    "odt",
    "pdf",
    "pptx",
    "rtf",
    "txt",
    "xlsx",
    "zip",
]
