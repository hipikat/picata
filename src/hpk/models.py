"""Django models; mostly subclassed Wagtail classes."""

# from django.db import models
# from wagtail.admin.panels import FieldPanel, StreamFieldPanel
# from wagtail.blocks import CharBlock, TextBlock
# from wagtail.fields import RichTextField, StreamField
# from wagtail.images.blocks import ImageChooserBlock
# from wagtail.models import Page


# class Article(Page):
#     """Class for article-like pages."""

#     summary = RichTextField(blank=True, help_text="A short summary, or tagline for the article.")
#     content = StreamField(
#         [
#             ("heading", CharBlock(classname="full title")),
#             ("paragraph", TextBlock()),
#             ("image", ImageChooserBlock()),
#         ],
#         use_json_field=True,
#         blank=True,
#     )

#     date_created = models.DateTimeField(
#         auto_now_add=True, help_text="When the article was first created."
#     )
#     date_modified = models.DateTimeField(
#         auto_now=True, help_text="When the article was last updated."
#     )

#     content_panels = [
#         *Page.content_panels,
#         FieldPanel("subtitle"),
#         StreamFieldPanel("body"),
#         FieldPanel("date_created"),
#         FieldPanel("date_modified"),
#     ]

#     class Meta:
#         """Meta-info for the class."""

#         verbose_name = "Article"
#         verbose_name_plural = "Articles"
