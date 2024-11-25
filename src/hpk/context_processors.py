"""Context processors used across the project."""

from django.http import HttpRequest
from django.template.context_processors import debug as django_debug


def debug(request: HttpRequest) -> dict[str, object]:
    """Ensure 'debug' is always set in template contexts.

    The built-in `django.template.context_processors.debug` only sets 'debug' when
    `django.conf.settings.DEBUG` is `True` and the request's `REMOTE_ADDR is in
    settings.INTERNAL_IPS. This context processor ensures `DEBUG` is set to `False`
    whenever it hasn't been set by Django's built-in processor.
    """
    context_extras = {"debug": False}

    context_extras.update(django_debug(request))
    return context_extras
