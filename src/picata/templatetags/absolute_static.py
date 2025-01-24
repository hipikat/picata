"""Simple template tag to produce absolute URLs from static file requests."""

from django import template
from django.templatetags.static import static

from picata.typing import Context

register = template.Library()


@register.simple_tag(takes_context=True)
def absolute_static(context: Context, file: str) -> str:
    """Return the absolute path to a static file."""
    request = context["request"]
    return request.build_absolute_uri(static(file))
