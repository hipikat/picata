"""Simple template tag to produce absolute URLs from static file requests."""  # noqa: INP001

from django.templatetags.static import static

from picata.typing import Context


def absolute_static(context: Context, file: str) -> str:
    """Return the absolute path to a static file."""
    request = context["request"]
    return request.build_absolute_uri(static(file))
