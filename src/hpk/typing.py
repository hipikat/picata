"""Reusable types for the hpk project."""

from collections.abc import Mapping
from typing import Any

# Arguments for Views
ViewArg = tuple[Any, ...]
ViewKwarg = Mapping[str, str | None]

# Log arguments for structured logging
LogArg = str | int | float | bool
