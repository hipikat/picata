# ruff: noqa: F405
"""Django settings for development environments."""

from .base import *  # noqa: F403

# SECURITY WARNING: don't run with debug turned on in production!
DEBUG = False

# SECURITY WARNING: keep the secret key used in production secret!
SECRET_KEY = "django-insecure-9yz$rw8%)1wm-l)j6q-r&$bu_n52sv=4q6)c5u8n10+5w+anec"  # noqa: S105

# SECURITY WARNING: define the correct hosts in production!
ALLOWED_HOSTS = ["127.0.0.1", "localhost"]

EMAIL_BACKEND = "django.core.mail.backends.console.EmailBackend"

INSTALLED_APPS += [
    "debug_toolbar",
    "django_extensions",
]

DEBUG_PROPAGATE_EXCEPTIONS = True

LOGGING["handlers"]["console"]["formatter"] = "verbose"
LOGGING["handlers"]["console"]["level"] = "DEBUG"  # Debug level for console output

LOGGING["root"]["level"] = "DEBUG"
LOGGING["loggers"]["django"]["level"] = "DEBUG"
LOGGING["loggers"]["django.request"]["level"] = "DEBUG"
LOGGING["loggers"]["django.security"] = {
    "handlers": ["console"],
    "level": "WARNING",
    "propagate": True,
}
