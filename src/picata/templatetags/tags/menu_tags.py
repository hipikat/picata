"""Template tags for rendering menus."""  # noqa: INP001

# NB: Django's meta-class shenanigans over-complicate type hinting when QuerySets get involved.
# pyright: reportAttributeAccessIssue=false

from typing import TYPE_CHECKING, TypedDict

from django import template
from wagtail.models import Page, Site

from picata.typing import Context

if TYPE_CHECKING:
    from django.http import HttpRequest

register = template.Library()


class SiteMenuContext(TypedDict):
    """Context returned from `render_site_menu` for `site_menu.html`."""

    menu_pages: list[Page]
    current_section: Page | None


@register.inclusion_tag("picata/tags/site_menu.html", takes_context=True)
def render_site_menu(context: Context) -> SiteMenuContext:
    """Fetch the site root and its child pages for the site menu."""
    current_page: Page | None = context.get("self")
    active_section = None

    request: HttpRequest = context["request"]
    current_site = Site.find_for_request(request)
    if not current_site:
        raise ValueError("No Wagtail Site found for the current request.")

    # Get menu pages as a list of pages starting with the root, followed by its children
    root_page = current_site.root_page.specific

    top_pages = root_page.get_children().in_menu()
    if not request.user.is_authenticated:
        top_pages = top_pages.live()
    top_pages = top_pages.specific()

    menu_pages = [root_page, *top_pages]

    # Find which page in the set of menu pages that the current page is a descendant of
    if current_page == root_page:
        active_section = root_page
    else:
        for page in top_pages:
            if current_page and (current_page == page or current_page.is_descendant_of(page)):
                active_section = page
                break

    return {"menu_pages": menu_pages, "current_section": active_section}
