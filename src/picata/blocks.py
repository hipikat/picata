"""Wagtail "blocks"."""

import pygments
from django.forms import CharField
from django.utils.safestring import mark_safe
from pygments import formatters, lexers
from pygments.util import ClassNotFound
from wagtail.blocks import (
    CharBlock,
    ChoiceBlock,
    IntegerBlock,
    ListBlock,
    RichTextBlock,
    StreamBlock,
    StructBlock,
    TextBlock,
    URLBlock,
)
from wagtail.images.blocks import ImageChooserBlock

from picata.typing.wagtail import BlockRenderContext, BlockRenderValue
from picata.validators import HREFValidator


class HREFField(CharField):
    """Custom field for href attributes (i.e. URLs but also schemes like 'mailto:')."""

    def __init__(self, *args, **kwargs) -> None:  # noqa: ANN002, ANN003
        """Initialise a CharField with `HREFValidator` as the only validator."""
        kwargs["validators"] = [HREFValidator()]
        super().__init__(*args, **kwargs)


class HREFBlock(URLBlock):
    """Custom block for href attributes (i.e. a `URLBlock` using the extended `HREFField`)."""

    def __init__(self, *args, **kwargs) -> None:  # noqa: ANN002, ANN003
        """Initialise the `URLBlock` superclass and replace our field with a `HREFField`."""
        super().__init__(*args, **kwargs)
        self.field = HREFField()


class StaticIconLinkItemBlock(StructBlock):
    """A single list item with an optional icon and surrounding anchor."""

    href = HREFBlock(
        required=False,
        help_text="An optional link field",
        max_length=255,
    )
    label = CharBlock(required=True, max_length=50, help_text="The title for the list item.")
    icon = CharBlock(
        required=False,
        max_length=255,
        help_text="Id of the icon in the static/icons.svg file.",
    )

    class Meta:
        """Meta information."""

        template = "picata/blocks/icon_link_item.html"


class StaticIconLinkListBlock(StructBlock):
    """A list of optionally-linked list items with an optional heading."""

    heading = CharBlock(
        required=False,
        help_text="Optional heading for this list (e.g., Social Links).",
    )
    heading_level = IntegerBlock(
        required=False,
        min_value=1,
        max_value=6,
        default=2,
        help_text="Heading level for the list (1-6).",
    )
    items = ListBlock(
        StaticIconLinkItemBlock(),
        help_text="The list of items.",
    )

    class Meta:
        """Meta information."""

        template = "picata/blocks/icon_link_list.html"


class StaticIconLinkListsBlock(StructBlock):
    """A wrapper for multiple heading-and-link-list blocks."""

    lists = StreamBlock(
        [
            ("link_list", StaticIconLinkListBlock()),
        ],
        required=False,
        help_text="Add one or more heading-and-link-list blocks.",
    )

    class Meta:
        """Meta information."""

        template = "picata/blocks/icon_link_list_stream.html"


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

        return mark_safe(highlighted_code)  # noqa: S308

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


class WrappedImageChooserBlock(ImageChooserBlock):
    """An ImageChooserBlock that wraps the output in a div."""

    def render_basic(self, value: BlockRenderValue, context: BlockRenderContext = None) -> str:
        """Render the image wrapped in a div with a custom class."""
        if not value:  # If no image is selected, return an empty string
            return ""

        # Use Wagtail's default rendering for the image, wrapped in a <div>
        image_tag = super().render_basic(value, context)
        return f'<div class="image-wrapper">{image_tag}</div>'
