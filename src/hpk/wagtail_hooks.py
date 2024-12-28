"""Wagtail hooks, used to customise view-level behaviour of the Wagtail admin and front-end.

See: https://docs.wagtail.org/en/stable/reference/hooks.html
"""

from wagtail.hooks import register as register_hook
# from wagtail.models import Page


@register_hook("construct_explorer_page_queryset")
def order_admin_menu_by_date(parent_page, pages, request):
    # Check if the parent page is the 'blog' page by slug
    if parent_page.slug == "blog":
        # Reorder children by most recent first
        return pages.order_by("-first_published_at")
    # Return default queryset for all other cases
    return pages
