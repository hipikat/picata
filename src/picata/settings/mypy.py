"""Django settings for the mypy type-checking daemon."""

import django_stubs_ext

from .dev import *  # noqa: F403

django_stubs_ext.monkeypatch()
