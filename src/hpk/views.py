"""Top-level views for the site."""

import logging
from typing import NoReturn

from django.http import HttpRequest, HttpResponse
from django.shortcuts import render
from wagtail.models import Page

from hpk.helpers import get_models_of_type
from hpk.models import TaggedPage

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
    results = {}

    # Base QuerySet for all pages
    pages = Page.objects.all()
    if not request.user.is_authenticated:
        pages = pages.live()

    # Perform search by query
    query_string = request.GET.get("query")
    if query_string:
        pages = pages.search(query_string)
        results["query"] = query_string

    # Convert QuerySet to a list to preserve relevance ordering
    pages = list(pages)

    # Filter by tags
    tags_string = request.GET.get("tags")
    if tags_string:
        tags = [tag.strip() for tag in tags_string.split(",") if tag.strip()]
        tagged_page_types = get_models_of_type(TaggedPage)

        # Inline filtering for taggable pages
        filtered_pages = []
        for page in pages:
            try:
                specific_page = page.specific
                # Check if the page is taggable and contains all required tags
                if isinstance(specific_page, tuple(tagged_page_types)):
                    page_tags = {tag.name for tag in specific_page.tags.all()}
                    if set(tags).issubset(page_tags):
                        filtered_pages.append(page)
            except AttributeError:
                # Page lacks `specific` or `tags` attributes
                continue

        pages = filtered_pages
        results["tags"] = tags

    # Handle empty cases
    if not query_string and not tags_string:
        pages = []

    return render(request, "search_results.html", {**results, "pages": pages})
