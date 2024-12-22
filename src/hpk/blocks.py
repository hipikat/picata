"""Wagtail "blocks"."""

import pygments
from django.utils.html import format_html
from pygments import formatters, lexers
from pygments.util import ClassNotFound
from wagtail.blocks import (
    CharBlock,
    ChoiceBlock,
    IntegerBlock,
    RichTextBlock,
    StreamBlock,
    StructBlock,
    TextBlock,
)
from wagtail.images.blocks import ImageChooserBlock

from hpk.typing.wagtail import BlockRenderContext, BlockRenderValue


class CodeBlock(StructBlock):
    """A block for displaying code with optional syntax highlighting."""

    code = TextBlock(required=True, help_text=None)
    language = ChoiceBlock(
        required=False,
        choices=[
            ("python", "Python"),
            ("javascript", "JavaScript"),
            ("html", "HTML"),
            ("css", "CSS"),
            ("bash", "Bash"),
            ("plaintext", "Plain Text"),
        ],
        help_text=None,
    )

    def render_basic(self, value: BlockRenderValue, context: BlockRenderContext = None) -> str:
        """Render the code block with syntax highlighting."""
        code = value.get("code", "")
        language = value.get("language", "plaintext")
        try:
            lexer = lexers.get_lexer_by_name(language)
            formatter = formatters.HtmlFormatter(cssclass="pygments")
            highlighted_code = pygments.highlight(code, lexer, formatter)
        except ClassNotFound:
            highlighted_code = f"<pre><code>{code}</code></pre>"

        return format_html(highlighted_code)

    class Meta:
        """Meta information."""

        icon = "code"
        label = "Code Block"


class SectionBlock(StructBlock):
    """A page section, with a heading rendered at a defined level."""

    heading = CharBlock(
        required=True, help_text='Heading for this section, included in "page contents".'
    )
    level = IntegerBlock(required=True, min_value=1, max_value=6, help_text="Heading level")
    content = StreamBlock(
        [
            ("rich_text", RichTextBlock()),
            ("image", ImageChooserBlock()),
        ],
        required=False,
        help_text=None,
    )

    class Meta:
        """Meta-info for the block."""

        icon = "folder"
        label = "Section"
