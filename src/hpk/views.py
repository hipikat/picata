"""Top-level views for the site."""

import logging

from django.http import HttpRequest, HttpResponse
from django.views.generic import TemplateView

from hpk.typing import ViewArg, ViewKwarg

logger = logging.getLogger(__name__)


def debug_shell(request: HttpRequest) -> None:
    """Just `assert False`, to force an exception and get to the Werkzeug debug console."""
    logger.info("Raising `assert False` in the `debug_shell` view...")
    assert False  # noqa: B011, PT015, S101


class LandingPageView(TemplateView):
    """View for the landing page."""

    template_name = "landing/landing_page.html"

    def get(self, request: HttpRequest, *args: ViewArg, **kwargs: ViewKwarg) -> HttpResponse:
        """Entry-point for the 'get' method."""
        return super().get(request, *args, **kwargs)
