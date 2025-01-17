"""Generic helper-functions."""
# NB: Django's meta-class shenanigans over-complicate type hinting when QuerySets get involved.
# pyright: reportAttributeAccessIssue=false

from django.db.models import QuerySet
from django.http import HttpRequest

from hpk.models import BasePage, TaggedPage

from . import get_models_of_type

TAGGED_PAGE_TYPES = get_models_of_type(TaggedPage)


def visible_pages_qs(request: HttpRequest) -> QuerySet[BasePage]:
    """Return a QuerySet of all pages derived from `BasePage` visible to the user."""
    pages = BasePage.objects.all()
    if not request.user.is_authenticated:
        pages = pages.live()  # type: ignore [reportAttributeAccessIssue]
    return pages


def filter_pages_by_tags(pages: list[BasePage], tags: list[str]) -> list[TaggedPage]:
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


def page_preview_data(request: HttpRequest, page: BasePage) -> dict[str, str]:
    """Return a dictionary of available publication and preview data for a page."""
    page_data = getattr(page, "preview_data", {}).copy()
    if hasattr(page, "get_publication_data"):
        page_data.update(page.get_publication_data(request))
    return page_data
