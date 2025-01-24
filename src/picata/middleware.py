"""HTML-processing middlware; should be placed last in (at the heart of) MIDDLEWARE."""

import logging
import re
from collections.abc import Callable
from typing import ClassVar

from django.http import HttpRequest, HttpResponse
from lxml import etree

from picata.helpers import make_response

logger = logging.getLogger(__name__)


class HTMLProcessingMiddleware:
    """Middleware register for text/html document transformers."""

    transformers: ClassVar[list[Callable[[etree._Element], None]]] = []

    def __init__(self, get_response: Callable) -> None:
        """Standard middleware initialisation; get the get_response method."""
        self.get_response = get_response

    def __call__(self, request: HttpRequest) -> HttpResponse:
        """Filter the response through every registered transformer function."""
        response = self.get_response(request)

        if "text/html" in response.get("Content-Type", ""):
            doctype = self.extract_doctype(response.content.decode())
            tree = etree.fromstring(response.content, etree.HTMLParser())  # noqa: S320
            if tree is not None:
                for transformer in self.transformers:
                    transformer(tree)
                processed_html = etree.tostring(
                    tree,
                    pretty_print=True,  # type: ignore [reportCallIssue]
                    method="html",  # type: ignore [reportCallIssue]
                    encoding=str,  # type: ignore [reportCallIssue]
                )
                return make_response(response, f"{doctype}\n{processed_html}")

        return response

    @staticmethod
    def extract_doctype(html: str) -> str:
        """Extract the DOCTYPE declaration from the HTML."""
        match = re.match(r"^(<!DOCTYPE [^>]+>)", html, re.IGNORECASE)
        return match.group(1) if match else ""

    @classmethod
    def add_transformer(cls, func: Callable[[etree._Element], None]) -> None:
        """Add a transformation function to the global pipeline."""
        cls.transformers.append(func)
