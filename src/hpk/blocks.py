"""Wagtail "blocks"."""

from wagtail.blocks import CharBlock, IntegerBlock, RichTextBlock, StreamBlock, StructBlock
from wagtail.images.blocks import ImageChooserBlock


class SectionBlock(StructBlock):
    """A page section, with a heading rendered at a defined level."""

    heading = CharBlock(required=True, help_text="Heading for this section.")
    level = IntegerBlock(required=True, min_value=1, max_value=6, help_text="Heading level")
    content = StreamBlock(
        [
            (
                "rich_text",
                RichTextBlock(features=["bold", "italic", "link", "ul", "ol", "document-link"]),
            ),
            ("image", ImageChooserBlock()),
        ],
        required=False,
        help_text="Content blocks for this section.",
    )

    class Meta:
        """Meta-info for the block."""

        icon = "folder"
        label = "Section"
