"""Filter to wrap the last two words of text in a span which prevents word-wrapping."""  # noqa: INP001

from html.parser import HTMLParser

from django.utils.html import escape
from django.utils.safestring import mark_safe


class KillOrphansParser(HTMLParser):
    """Parser that wraps the last two words of visible text in a span tag."""

    result: list[str]
    text_chunks: list[str]

    def __init__(self) -> None:
        """Initialize the parser and result containers."""
        super().__init__()
        self.result = []
        self.text_chunks = []

    def handle_starttag(self, tag: str, attrs: list[tuple[str, str | None]]) -> None:
        """Handle start tags and store them."""
        start_tag_text = self.get_starttag_text()
        if start_tag_text is not None:
            self.result.append(start_tag_text)

    def handle_endtag(self, tag: str) -> None:
        """Handle end tags and store them."""
        self.result.append(f"</{tag}>")

    def handle_data(self, data: str) -> None:
        """Handle text data and store it."""
        self.text_chunks.append(data)
        self.result.append(data)

    def get_wrapped_html(self) -> str:
        """Return HTML with the last two words wrapped in a span."""
        full_text = "".join(self.text_chunks)
        words = full_text.split()

        if len(words) < 2:  # noqa: PLR2004
            return "".join(self.result)

        wrapped_words = (
            " ".join(words[:-2])
            + f' <span class="whitespace-nowrap">{escape(" ".join(words[-2:]))}</span>'
        )

        return mark_safe(  # noqa: S308
            "".join(wrapped_words if chunk in full_text else chunk for chunk in self.result)
        )


def killorphans(value: str) -> str:
    """Wrap the last two words of visible text in a span tag."""
    parser = KillOrphansParser()
    parser.feed(value)
    return parser.get_wrapped_html()
