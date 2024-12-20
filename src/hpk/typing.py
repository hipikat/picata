"""Reusable types for the hpk project."""

from collections.abc import Mapping
from typing import Any

# Arguments for Views
ViewArg = tuple[Any, ...]
ViewKwarg = Mapping[str, str | None]

# Arguments for StructBlock (et al?) 'render' functions
RenderValue = Mapping[str, Any]
RenderContext = Mapping[str, Any] | None


# Log arguments for structured logging
LogArg = str | int | float | bool
