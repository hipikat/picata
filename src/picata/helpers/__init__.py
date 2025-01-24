"""Generic helper-functions."""
# NB: Django's meta-class shenanigans over-complicate type hinting when QuerySets get involved.
# pyright: reportAttributeAccessIssue=false

import re
from ipaddress import AddressValueError, IPv4Address

from django.apps import apps
from django.db.models import Model
from django.http import HttpResponse, StreamingHttpResponse
from lxml.etree import _Element

# Pre-compile commonly used regular expressions
ALPHANUMERIC_REGEX = re.compile(r"[^a-zA-Z0-9]")


def get_models_of_type(base_type: type[Model]) -> list[type[Model]]:
    """Retrieve all concrete subclasses of the given base Model type."""
    all_models = apps.get_models()

    return [
        model
        for model in all_models
        if issubclass(model, base_type) and not model._meta.abstract  # noqa: SLF001
    ]


def get_public_ip() -> IPv4Address | None:
    """Fetch the public-facing IP of the current host."""
    import socket

    import psutil

    for addrs in psutil.net_if_addrs().values():
        for addr in addrs:
            if addr.family == socket.AF_INET:
                ip = addr.address
                if not ip.startswith(("10.", "192.168.", "172.", "127.")):
                    try:
                        return IPv4Address(ip)
                    except AddressValueError:
                        pass
    return None


def get_full_text(element: _Element) -> str:
    """Extract text from an element and its descendants, concatenate it, and trim whitespace."""
    return "".join(element.xpath(".//text()")).strip()


def make_response(
    original_response: HttpResponse,
    new_content: str | bytes,
) -> HttpResponse:
    """Create a new HttpResponse while preserving attributes from the original response."""
    if isinstance(original_response, StreamingHttpResponse):
        raise TypeError("StreamingHttpResponse objects are not supported.")
    new_response = HttpResponse(
        content=new_content,
        content_type=original_response.get("Content-Type", None),
        status=original_response.status_code,
    )
    for key, value in original_response.headers.items():
        new_response[key] = value
    new_response.cookies = original_response.cookies
    for attr in dir(original_response):
        if not attr.startswith("_") and not hasattr(HttpResponse, attr):
            setattr(new_response, attr, getattr(original_response, attr))

    return new_response
