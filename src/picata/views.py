"""Top-level views for the site."""

# NB: Django's meta-class shenanigans over-complicate type hinting when QuerySets get involved.
# pyright: reportAttributeAccessIssue=false, reportArgumentType=false

import logging
from typing import TYPE_CHECKING, NoReturn

from django.http import HttpRequest, HttpResponse
from django.shortcuts import render

from picata.helpers.wagtail import (
    filter_pages_by_tags,
    filter_pages_by_type,
    page_preview_data,
    visible_pages_qs,
)
from picata.models import ArticleType

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
    return render(request, f"picata/previews/{file}.html")


def search(request: HttpRequest) -> HttpResponse:
    """Render search results from the `query` and `tags` GET parameters."""
    results: dict[str, str | list[str] | set[str]] = {}

    # Base QuerySet for all pages
    pages: PageQuerySet = visible_pages_qs(request)

    # Perform search by query
    query_string = request.GET.get("query")
    if query_string:
        pages = pages.search(query_string)
        results["query"] = query_string

    # Resolve specific pages post-search
    specific_pages = [page.specific for page in pages]

    # Filter by page types
    page_types_string = request.GET.get("page_types")
    if page_types_string:
        page_type_slugs = {slug.strip() for slug in page_types_string.split(",") if slug.strip()}
        matching_page_types = ArticleType.objects.filter(slug__in=page_type_slugs)
        specific_pages = filter_pages_by_type(specific_pages, page_type_slugs)
        results["page_types"] = [page_type.name for page_type in matching_page_types]

    # Filter by tags
    tags_string = request.GET.get("tags")
    if tags_string:
        tags = {tag.strip() for tag in tags_string.split(",") if tag.strip()}
        specific_pages = filter_pages_by_tags(specific_pages, tags)
        results["tags"] = tags

    # Handle empty cases
    if not (query_string or tags_string or page_types_string):
        specific_pages = []

    # Enhance pages with preview and publication data
    page_previews = [page_preview_data(request, page) for page in specific_pages]

    return render(request, "picata/search_results.html", {**results, "pages": page_previews})
