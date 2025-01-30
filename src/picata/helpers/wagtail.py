"""Generic helper-functions."""
# NB: Django's meta-class shenanigans over-complicate type hinting when QuerySets get involved.
# pyright: reportAttributeAccessIssue=false

from typing import cast

from django.http import HttpRequest
from wagtail.models import Page
from wagtail.query import PageQuerySet

from picata.models import TaggedPage

from . import get_models_of_type

TAGGED_PAGE_TYPES = get_models_of_type(TaggedPage)


def visible_pages_qs(request: HttpRequest) -> PageQuerySet:
    """Return a QuerySet of all pages derived from `Page` visible to the user."""
    pages = cast(PageQuerySet, Page.objects.all())
    if not request.user.is_authenticated:
        pages = pages.live()
    return pages


def filter_pages_by_tags(pages: list[Page], tags: set[str]) -> list[TaggedPage]:
    """Filter a list of pages to those containing all of a list of tags."""
    filtered_pages = []
    for page in pages:
        try:
            if isinstance(page, tuple(TAGGED_PAGE_TYPES)):
                page_tags = {tag.name for tag in page.tags.all()}
                if set(tags).issubset(page_tags):
                    filtered_pages.append(page)
        except AttributeError:
            continue
    return filtered_pages


def filter_pages_by_type(pages: list[Page], page_type_slugs: set[str]) -> list[Page]:
    """Filter a list of pages to those with a `page_type` matching any of the given slugs."""
    filtered_pages = []
    for page in pages:
        try:
            if (
                hasattr(page, "page_type")
                and page.page_type
                and page.page_type.slug in page_type_slugs
            ):
                filtered_pages.append(page)
        except AttributeError:
            continue
    return filtered_pages


def page_preview_data(page: Page, request: HttpRequest | None) -> dict[str, str]:
    """Return a dictionary of available publication and preview data for a page."""
    page_data = getattr(page, "preview_data", {}).copy()
    if hasattr(page, "get_publication_data"):
        page_data.update(page.get_publication_data(request))
    return page_data
