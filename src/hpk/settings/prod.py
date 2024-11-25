"""Django settings for production environments."""
# ruff: noqa: F405

from .base import *  # noqa: F403

# ManifestStaticFilesStorage is recommended in production, to prevent
# outdated JavaScript / CSS assets being served from cache
# (e.g. after a Wagtail upgrade).
# See https://docs.djangoproject.com/en/5.1/ref/contrib/staticfiles/#manifeststaticfilesstorage
STORAGES["staticfiles"] = {
    "BACKEND": "django.contrib.staticfiles.storage.ManifestStaticFilesStorage"
}
