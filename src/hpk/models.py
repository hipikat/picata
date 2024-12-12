"""Django models; mostly subclassed Wagtail classes."""

from typing import ClassVar

from django.db import models
from django.utils import timezone
from wagtail.admin.panels import FieldPanel
from wagtail.fields import RichTextField, StreamField
from wagtail.images.blocks import ImageChooserBlock
from wagtail.models import Page

from .blocks import SectionBlock


class Article(Page):
    """Class for article-like pages."""

    summary = RichTextField(blank=True, help_text="A short summary, or tagline for the article.")
    content = StreamField(
        [
            ("section", SectionBlock()),
            ("image", ImageChooserBlock()),
        ],
        use_json_field=True,
        blank=True,
    )

    date_created = models.DateTimeField(
        default=timezone.now, help_text="When the article was first created."
    )
    date_modified = models.DateTimeField(
        default=timezone.now, help_text="When the article was last mutilated."
    )

    # content_panels: ClassVar[list] = [
    content_panels: ClassVar[list] = [
        *Page.content_panels,
        FieldPanel("summary"),
        FieldPanel("content"),
        FieldPanel("date_created"),
        FieldPanel("date_modified"),
    ]

    class Meta:
        """Meta-info for the class."""

        verbose_name = "Article"
        verbose_name_plural = "Articles"
