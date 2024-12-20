"""Reusable types for the hpk project."""

from collections.abc import Mapping
from typing import Any, TypedDict

from django.http import HttpRequest


class TemplateContext(TypedDict):
    """Used by template tags marked with `@register.inclusion_tag`."""

    request: HttpRequest


# Arguments for Views
ViewArg = tuple[Any, ...]
ViewKwarg = Mapping[str, str | None]

# Arguments for StructBlock (et al?) 'render' functions
RenderValue = Mapping[str, Any]
RenderContext = Mapping[str, Any] | None

# Log arguments for structured logging
LogArg = str | int | float | bool
