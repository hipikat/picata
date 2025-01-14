"""Top-level views for the site."""

import logging
from typing import NoReturn

from django.http import HttpRequest, HttpResponse
from django.shortcuts import render
from wagtail.models import Page
from wagtail.search.utils import parse_query_string

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
    """Render search results from the `q` GET parameter."""
    results = {}

    # Narrow down searchable page set if user isn't authenticated, and get specific items
    pages = Page.objects.all().specific(defer=True)  # type: ignore[reportAttributeAccessIssue]
    if not request.user.is_authenticated:
        pages = pages.live()

    # Parse filters and query from the search string and (just, for now) search based on query
    query_string = request.GET.get("query")
    if query_string:
        filters, query = parse_query_string(query_string, operator="and")
        pages = pages.search(query)
        results["query"] = query

    # Fitler based on tags (if a comma-separated set of 'tags' was provided as a GET variable)
    tags_string = request.GET.get("tags")
    if tags_string:
        tags = [tag.strip() for tag in tags_string.split(",")]
        pages = pages.filter(tags__name__in=tags).distinct()
        results["tags"] = tags

    if not query_string and not tags_string:
        pages = []

    return render(request, "search_results.html", {**results, "pages": pages})
