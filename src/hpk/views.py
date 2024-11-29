"""Top-level views for the site."""

from django.views.generic import TemplateView


def debug_shell(request):
    assert False


class LandingPageView(TemplateView):
    """View for the landing page."""

    template_name = "landing/landing_page.html"
