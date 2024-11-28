"""Middleware for the project."""

from collections.abc import Callable

from django.http import HttpRequest, HttpResponse


class SetRemoteAddrMiddleware:
    """Set REMOTE_ADDR based on HTTP_X_REAL_IP, if it exists.

    This is required due to a known but when proxying between Nginx and Gunicorn
    over a Unix domain socket.

    See: https://github.com/python-web-sig/wsgi-ng/issues/11
    """

    def __init__(self, get_response: Callable[[HttpRequest], HttpResponse]) -> None:
        """Required; only called once during initialisation."""
        self.get_response = get_response

    def __call__(self, request: HttpRequest) -> HttpResponse:
        """Update REMOTE_ADDR based on the available, forwarded headers."""
        if "HTTP_X_REAL_IP" in request.META:
            request.META["REMOTE_ADDR"] = request.META["HTTP_X_REAL_IP"]
        elif "HTTP_X_FORWARDED_FOR" in request.META:
            request.META["REMOTE_ADDR"] = request.META["HTTP_X_FORWARDED_FOR"].split(",")[0]
        return self.get_response(request)
