"""Top-level views for the site."""

from typing import Any

from django.http import HttpRequest, HttpResponse
from django.views.generic import TemplateView


def debug_shell(request: HttpRequest) -> None:
    """Just `assert False`, to force an exception and get to the Werkzeug debug console."""
    assert False  # noqa: B011, PT015, S101


class LandingPageView(TemplateView):
    """View for the landing page."""

    template_name = "landing/landing_page.html"

    def get(self, request: HttpRequest, *args: Any, **kwargs: Any) -> HttpResponse:
        """Entry-point for the 'get' method."""
        return super().get(request, *args, **kwargs)
