"""Wagtail hooks, used to customise view-level behaviour of the Wagtail admin and front-end.

See: https://docs.wagtail.org/en/stable/reference/hooks.html
"""

import logging
from typing import ClassVar

from django.db.models import QuerySet, Value
from django.db.models.functions import Coalesce
from django.http import HttpRequest
from wagtail import hooks
from wagtail.models import Page
from wagtail.snippets.views.snippets import SnippetViewSet

from picata.models import PageTag

logger = logging.getLogger(__name__)


@hooks.register("construct_explorer_page_queryset")  # type: ignore[reportOptionalCall]
def order_admin_menu_by_date(parent_page: Page, pages: QuerySet, request: HttpRequest) -> QuerySet:  # noqa: ARG001
    """Order admin menus latest-at-top for pages with lots of children (like 'blog')."""
    if parent_page.slug == "blog":
        # Sort directly in order_by with Coalesce
        return pages.order_by(
            Coalesce("first_published_at", "latest_revision_created_at", Value("1970-01-01")).desc()
        )
    return pages


class PageTagViewSet(SnippetViewSet):
    """Viewset for managing `PageTag`s."""

    icon: str = "tag"
    list_display: ClassVar[list[str]] = ["name"]
    search_fields: ClassVar[list[str]] = ["name"]


@hooks.register("register_admin_viewset")  # type: ignore[reportOptionalCall]
def register_article_tag_viewset() -> SnippetViewSet:
    """Make `PageTag`s editable via the Wagtail admin."""
    return PageTagViewSet(model=PageTag)
