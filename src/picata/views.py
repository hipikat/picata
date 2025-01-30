"""Top-level views for the site."""

# NB: Django's meta-class shenanigans over-complicate type hinting when QuerySets get involved.
# pyright: reportAttributeAccessIssue=false, reportArgumentType=false

import logging
from datetime import datetime
from typing import TYPE_CHECKING, NoReturn

from django.contrib.syndication.views import Feed
from django.http import HttpRequest, HttpResponse
from django.shortcuts import render
from django.utils.feedgenerator import Atom1Feed, Rss201rev2Feed

from picata.helpers.wagtail import (
    filter_pages_by_tags,
    filter_pages_by_type,
    page_preview_data,
    visible_pages_qs,
)
from picata.models import Article, ArticleType

if TYPE_CHECKING:
    from wagtail.query import PageQuerySet

logger = logging.getLogger(__name__)


class PostsFeed(Feed):
    """Base class for RSS and Atom article feeds."""

    title = "hpk.io Articles"
    link = "https://hpk.io/blog/"
    description = "Latest posts on hpk.io"

    def items(self) -> list[Article]:
        """Return the latest 10 published articles."""
        return list(Article.objects.live().order_by("-first_published_at"))

    def item_title(self, item: Article) -> str:
        """Return the article title."""
        return item.title

    def item_link(self, item: Article) -> str:
        """Return the absolute URL for the article."""
        return item.full_url

    def item_description(self, item: Article) -> str:
        """Return the article body as HTML with absolute URLs."""
        return item.content

    def item_pubdate(self, item: Article) -> datetime:
        """Return the article creation date."""
        return item.first_published_at


class RSSArticleFeed(PostsFeed):
    """RSS feed for articles."""

    feed_type = Rss201rev2Feed


class AtomArticleFeed(PostsFeed):
    """Atom feed for articles."""

    feed_type = Atom1Feed


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
    page_previews = [page_preview_data(page, request) for page in specific_pages]

    return render(request, "picata/search_results.html", {**results, "pages": page_previews})
