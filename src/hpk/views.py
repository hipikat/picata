"""Top-level views for the site."""

# NB: Django's meta-class shenanigans over-complicate type hinting when QuerySets get involved.
# pyright: reportAttributeAccessIssue=false, reportArgumentType=false

import logging
from typing import TYPE_CHECKING, NoReturn

from django.http import HttpRequest, HttpResponse
from django.shortcuts import render

from hpk.helpers.wagtail import (
    filter_pages_by_tags,
    page_preview_data,
    visible_pages_qs,
)

if TYPE_CHECKING:
    from wagtail.query import PageQuerySet

logger = logging.getLogger(__name__)


def debug_shell(request: HttpRequest) -> NoReturn:
    """Just `assert False`, to force an exception and get to the Werkzeug debug console."""
    logger.info(
        "Raising `assert False` in the `debug_shell` view. "
        "Request details: method=%s, path=%s, user=%s",
        request.method,
        request.path,
        request.user if request.user.is_authenticated else "Anonymous",
    )
    assert False  # noqa: B011, PT015, S101


def preview(request: HttpRequest, file: str) -> HttpResponse:
    """Render a named template from the "templates/previews/" directory."""
    return render(request, f"previews/{file}.html")


def search(request: HttpRequest) -> HttpResponse:
    """Render search results from the `query` and `tags` GET parameters."""
    results: dict[str, str | list[str]] = {}

    # Base QuerySet for all pages
    pages: PageQuerySet = visible_pages_qs(request)

    # Perform search by query
    query_string = request.GET.get("query")
    if query_string:
        pages = pages.search(query_string)
        results["query"] = query_string

    # Resolve specific pages post-search
    specific_pages = [page.specific for page in pages]

    # Filter by tags
    tags_string = request.GET.get("tags")
    if tags_string:
        tags = [tag.strip() for tag in tags_string.split(",") if tag.strip()]
        specific_pages = filter_pages_by_tags(specific_pages, tags)
        results["tags"] = tags

    # Handle empty cases
    if not query_string and not tags_string:
        specific_pages = []

    # Enhance pages with preview and publication data
    page_previews = [page_preview_data(request, page) for page in specific_pages]

    return render(request, "search_results.html", {**results, "pages": page_previews})
