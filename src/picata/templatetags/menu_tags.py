"""Template tags for rendering menus."""

# NB: Django's meta-class shenanigans over-complicate type hinting when QuerySets get involved.
# pyright: reportAttributeAccessIssue=false

from typing import TypedDict

from django import template
from django.http import HttpRequest
from wagtail.models import Page, Site

from picata.typing import Context

register = template.Library()


class SiteMenuContext(TypedDict):
    """Context returned from `render_site_menu` for `site_menu.html`."""

    root_page: Page
    menu_pages: list[Page]
    request: HttpRequest


@register.inclusion_tag("picata/tags/site_menu.html", takes_context=True)
def render_site_menu(context: Context) -> SiteMenuContext:
    """Fetch the site root and its child pages for the site menu."""
    request: HttpRequest = context["request"]
    current_site = Site.find_for_request(request)
    if not current_site:
        raise ValueError("No Wagtail Site found for the current request.")

    root_page = current_site.root_page.specific

    menu_pages = root_page.get_children().in_menu()
    if not request.user.is_authenticated:
        menu_pages = menu_pages.live()

    return {
        "root_page": root_page,
        "menu_pages": menu_pages.specific(),
        "request": request,
    }
