"""Types for Wagtail.

NB: This module split the picata.typing module into a package in order to avoid
circular imports during program initialisation, with the `from wagtail` imports.
"""

from typing import Any

from wagtail.blocks import StructBlock
from wagtail.models import Page

from . import Context


# StructBlock types
class BlockRenderContextDict(Context):
    """Context dicts passed to render functions for Blocks."""

    self: StructBlock
    page: Page


BlockRenderContext = BlockRenderContextDict | None
BlockRenderValue = dict[str, Any]


class PageContext(Context):
    """Base class for Wagtail Page classes."""

    self: Page
    page: Page
