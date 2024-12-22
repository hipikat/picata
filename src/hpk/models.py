"""Django models; mostly subclassed Wagtail classes."""

from typing import ClassVar

from django.db import models
from django.db.models.functions import Coalesce
from django.http import HttpRequest
from django.urls import reverse
from django.utils.html import format_html
from modelcluster.contrib.taggit import ClusterTaggableManager
from modelcluster.fields import ParentalKey
from taggit.models import TagBase, TaggedItemBase
from wagtail.admin.panels import FieldPanel, Panel
from wagtail.blocks import RichTextBlock
from wagtail.fields import RichTextField, StreamField
from wagtail.images.blocks import ImageChooserBlock
from wagtail.models import Page
from wagtail.snippets.models import register_snippet
from wagtail_modeladmin.options import ModelAdmin

from hpk.typing import Args, Context, Kwargs

from .blocks import CodeBlock, SectionBlock


class BasicPage(Page):
    """A basic page model for static content."""

    template = "basic_page.html"

    content = StreamField(
        [
            ("rich_text", RichTextBlock()),
            ("code", CodeBlock()),
            ("image", ImageChooserBlock()),
        ],
        use_json_field=True,
        blank=True,
        help_text="Main content for the page.",
    )

    content_panels: ClassVar[list[FieldPanel]] = [
        *Page.content_panels,
        FieldPanel("content"),
    ]

    class Meta:
        """Meta-info for the class."""

        verbose_name = "Basic Page"
        verbose_name_plural = "Basic Pages"


@register_snippet
class ArticleTag(TagBase):
    """Custom tag model for articles."""

    class Meta:
        """Meta-info for the class."""

        verbose_name = "Article Tag"
        verbose_name_plural = "Article Tags"

    def __str__(self) -> str:
        """String representation of the tag."""
        return self.name


class ArticleTagItem(TaggedItemBase):
    """Associates an ArticleTag with Article."""

    content_object = ParentalKey(
        "Article",
        on_delete=models.CASCADE,
        related_name="tagged_items",
    )


class ArticleType(models.Model):
    """Defines a type of article, like Blog Post, Review, or Guide."""

    name = models.CharField(max_length=100, unique=True, help_text="Name of the article type.")
    name_plural = models.CharField(
        max_length=100,
        blank=True,
        help_text="Plural form of the article type name (optional). Defaults to appending 's'.",
    )
    slug = models.SlugField(unique=True, max_length=100)
    description = models.TextField(blank=True, help_text="Optional description of this type.")

    def __str__(self) -> str:
        """Return the name of the ArticleType."""
        return self.name

    def get_name_plural(self) -> str:
        """Return the plural name of the article type."""
        return self.name_plural or f"{self.name}s"


class ArticleTypeAdmin(ModelAdmin):
    """Wagtail admin integration for managing article types."""

    model = ArticleType
    menu_label = "Article Types"  # Label for the menu item
    menu_icon = "tag"  # Icon for the menu item (from Wagtail icon set)
    add_to_settings_menu = True  # Whether to add to the "Settings" menu
    list_display = ("name", "slug")  # Fields to display in the listing
    search_fields = ("name", "slug")  # Fields to include in the search bar


class Article(Page):
    """Class for article-like pages."""

    summary = RichTextField(blank=True, help_text="A short summary, or tagline for the article.")

    content = StreamField(
        [
            ("section", SectionBlock()),
            ("code", CodeBlock()),
            ("image", ImageChooserBlock()),
        ],
        use_json_field=True,
        blank=True,
        help_text="Main content for the article.",
    )

    tags = ClusterTaggableManager(
        through=ArticleTagItem,
        blank=True,
        help_text="Tags for the article.",
    )

    article_type = models.ForeignKey(
        "ArticleType",
        null=True,
        blank=True,
        on_delete=models.SET_NULL,
        related_name="articles",
        help_text="Select the type of article.",
    )

    content_panels: ClassVar[list[Panel]] = [
        *Page.content_panels,
        FieldPanel("summary"),
        FieldPanel("content"),
        FieldPanel("article_type"),
        FieldPanel("tags"),
    ]

    def render_preview(self) -> str:
        """Return HTML to display a preview of this page."""
        return format_html(
            '<a href="{}"><strong>{}</strong></a><br>{}<br><em>Read more...</em>',
            self.url,
            self.title,
            self.summary,
        )

    class Meta:
        """Meta-info for the class."""

        verbose_name = "Article"
        verbose_name_plural = "Articles"


class PostGroupPage(Page):
    """A top-level page for grouping various types of posts or articles."""

    template = "post_group.html"
    subpage_types: ClassVar[list[str]] = ["hpk.Article"]

    intro = RichTextField(blank=True, help_text="An optional introduction to this group.")

    content_panels: ClassVar[list[Panel]] = [*Page.content_panels, FieldPanel("intro")]

    def get_context(self, request: HttpRequest, *args: Args, **kwargs: Kwargs) -> Context:
        """Add a list of 'posts' from children of this page to the context dict."""
        # Get child pages, including drafts if the user is authenticated, with an effective_date
        children = self.get_children().specific()  # type: ignore[reportAttributeAccessIssue]

        if not request.user.is_authenticated:
            children = children.live()
        children = children.annotate(
            effective_date=Coalesce("first_published_at", "latest_revision_created_at")
        )

        # Create a list of posts, with formatted dates, in reverse chronological order
        posts = []
        for child in children.order_by("-effective_date"):
            post = {
                "object": child,
                "published": f"{child.first_published_at:%Y-%m-%d @ %H:%M %Z}"
                if child.first_published_at
                else False,
                "updated": f"{child.last_published_at:%Y-%m-%d @ %H:%M %Z}"
                if child.last_published_at
                else False,
            }
            last_draft_created_at = child.latest_revision.created_at
            if request.user.is_authenticated and (
                not child.last_published_at or last_draft_created_at > child.last_published_at
            ):
                post["latest_draft"] = f"{last_draft_created_at:%Y-%m-%d @ %H:%M %Z}"
                post["draft_url"] = reverse("wagtailadmin_pages:preview_on_edit", args=[child.id])
            posts.append(post)

        context = super().get_context(request, args, kwargs)
        context["posts"] = posts
        return context

    class Meta:
        """Meta-info for the class."""

        verbose_name: str = "Post Group"
        verbose_name_plural: str = "Post Groups"
