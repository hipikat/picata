"""Django models; mostly subclassed Wagtail classes."""

# NB: Django's meta-class shenanigans over-complicate type hinting when QuerySets get involved.
# pyright: reportAttributeAccessIssue=false

from collections import OrderedDict
from datetime import timedelta
from typing import Any, ClassVar, cast

from django.db.models import (
    CASCADE,
    SET_NULL,
    CharField,
    ForeignKey,
    Model,
    SlugField,
    TextField,
)
from django.db.models.functions import Coalesce, ExtractYear
from django.http import HttpRequest
from django.urls import reverse
from modelcluster.contrib.taggit import ClusterTaggableManager
from modelcluster.fields import ParentalKey
from taggit.models import TagBase, TaggedItemBase
from wagtail.admin.panels import FieldPanel, Panel
from wagtail.blocks import RichTextBlock
from wagtail.contrib.routable_page.models import RoutablePageMixin
from wagtail.contrib.settings.models import BaseSiteSetting, register_setting
from wagtail.fields import RichTextField, StreamField
from wagtail.images.blocks import ImageChooserBlock
from wagtail.images.models import Image
from wagtail.models import Page
from wagtail.search import index
from wagtail_modeladmin.options import ModelAdmin

from hpk.typing import Args, Kwargs
from hpk.typing.wagtail import PageContext

from .blocks import (
    CodeBlock,
    StaticIconLinkListsBlock,
    WrappedImageChooserBlock,
)


class BasePage(Page):
    """Mixin for `Page`-types offering previews of themselves on other `Page`s."""

    @property
    def preview_data(self) -> dict[str, Any]:
        """Return a dictionary of data used in previewing this page type."""
        return {"title": self.seo_title or self.title, "summary": self.search_description}

    def get_publication_data(self, request: HttpRequest | None = None) -> dict[str, str]:
        """Helper method to calculate and format relevant dates for previews."""
        site = self.get_site()
        last_edited = self.latest_revision.created_at
        year = self.first_published_at.year if self.first_published_at else last_edited.year
        published, updated = self.first_published_at, self.last_published_at

        # Convert datetime objects to strings like "3 Jan, '25", or False, and
        # give a grace-period of one week for edits before marking the post as "updated"
        published_str = f"{published.day} {published:%b '%y}" if published else False
        updated_str = (
            f"{updated.day} {updated:%b '%y}"
            if published and updated and (updated >= published + timedelta(weeks=1))
            else False
        )

        data = {
            "year": year,
            "url": self.relative_url(site),
            "published": published_str,
            "updated": updated_str,
        }

        # Add last draft date & preview URL if there's an unpublished draft, for logged-in users
        if (
            (request and request.user.is_authenticated)
            and (not published or (updated and last_edited > updated))
            and hasattr(self, "id")
        ):
            data.update(
                {
                    "latest_draft": f"{last_edited.day} {last_edited:%b '%y}",
                    "draft_url": reverse("wagtailadmin_pages:preview_on_edit", args=[self.id]),
                }
            )

        return data

    class Meta:
        """Declare `BasePage` as an abstract `Page` class."""

        abstract = True


# @register_snippet
class PageTag(TagBase):
    """Custom tag model for articles."""

    def __str__(self) -> str:
        """String representation of the tag."""
        return self.name


class PageTagRelation(TaggedItemBase):
    """Associates an PageTag with an Page."""

    tag: ForeignKey[PageTag] = ForeignKey(
        PageTag,
        related_name="tagged_items",
        on_delete=CASCADE,
    )
    content_object = ParentalKey(
        "Article",
        on_delete=CASCADE,
        related_name="tagged_items",
    )


class TaggedPage(BasePage):
    """Abstract base for a `Page` type supporting tags."""

    tags = ClusterTaggableManager(
        through=PageTagRelation,
        blank=True,
        help_text="Tags for the article.",
    )

    content_panels: ClassVar[list[Panel]] = [
        *BasePage.content_panels,
        FieldPanel("tags"),
    ]

    class Meta:
        """Declare `BasePage` as an abstract `Page` class."""

        abstract = True


class BasicPage(BasePage):
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
        *BasePage.content_panels,
        FieldPanel("content"),
    ]

    search_fields: ClassVar[list[index.SearchField]] = [
        *Page.search_fields,
        index.SearchField("content"),
    ]


class SplitViewPage(BasePage):
    """A page with 50%-width divs, split down the middle."""

    template = "split_view.html"

    content = StreamField(
        [
            ("rich_text", RichTextBlock()),
            ("code", CodeBlock()),
            ("image", WrappedImageChooserBlock()),
            ("icon_link_lists", StaticIconLinkListsBlock()),
        ],
        use_json_field=True,
        blank=True,
        help_text="Main content for the split-view page.",
    )

    content_panels: ClassVar[list[FieldPanel]] = [
        *BasePage.content_panels,
        FieldPanel("content"),
    ]

    search_fields: ClassVar[list[index.SearchField]] = [
        *Page.search_fields,
        index.SearchField("content"),
    ]

    class Meta:
        """Declare explicit human-readable names for the page type."""

        verbose_name = "split-view page"
        verbose_name_plural = "split-view pages"


class ArticleType(Model):  # type: ignore[django-manager-missing]
    """Defines a type of article, like Blog Post, Review, or Guide."""

    name = CharField(max_length=100, unique=True, help_text="Name of the article type.")
    _Pluralised_name = CharField(
        max_length=100,
        blank=True,
        help_text="Plural form of the article type name (optional). Defaults to appending 's'.",
    )
    slug = SlugField(unique=True, max_length=100)
    description = TextField(blank=True, help_text="Optional description of this type.")

    def __str__(self) -> str:
        """Return the name of the ArticleType."""
        return self.name

    @property
    def name_plural(self) -> str:
        """Return the plural name of the article type."""
        return self._Pluralised_name or f"{self.name}s"

    @property
    def indefinite_article(self) -> str:
        """Return a string like 'a guide' or 'an article'."""
        name_lower = self.name.lower()
        return f"{'an' if name_lower[0] in 'aeiou' else 'a'} {name_lower}"


class ArticleTypeAdmin(ModelAdmin):
    """Wagtail admin integration for managing article types."""

    model = ArticleType
    menu_label = "Article Types"  # Label for the menu item
    menu_icon = "tag"  # Icon for the menu item (from Wagtail icon set)
    add_to_settings_menu = True  # Whether to add to the "Settings" menu
    list_display = ("name", "slug")  # Fields to display in the listing
    search_fields = ("name", "slug")  # Fields to include in the search bar


class ArticleContext(PageContext):
    """Return-type for an `Article`'s context dictionary."""

    content: str


class Article(TaggedPage):
    """Class for article-like pages."""

    template = "article.html"

    tagline: CharField = CharField(blank=True, help_text="A short tagline for the article.")
    summary = RichTextField(blank=True, help_text="A summary to be displayed in previews.")
    content = StreamField(
        [
            ("rich_text", RichTextBlock()),
            ("code", CodeBlock()),
            ("image", ImageChooserBlock()),
        ],
        use_json_field=True,
        blank=True,
        help_text="Main content for the article.",
    )

    page_type: ForeignKey[ArticleType | None] = ForeignKey(
        ArticleType,
        null=True,
        blank=True,
        on_delete=SET_NULL,
        related_name="articles",
        help_text="Select the type of article.",
    )

    content_panels: ClassVar[list[Panel]] = [
        *TaggedPage.content_panels,
        FieldPanel("tagline"),
        FieldPanel("summary"),
        FieldPanel("content"),
        FieldPanel("page_type"),
    ]

    search_fields: ClassVar[list[index.SearchField]] = [
        *TaggedPage.search_fields,
        index.SearchField("tagline"),
        index.SearchField("summary"),
        index.SearchField("content"),
        index.SearchField("tags"),
        index.SearchField("page_type"),
    ]

    @property
    def preview_data(self) -> dict[str, Any]:
        """Return data required to render a preview of this article."""
        return {
            **super().preview_data,
            "tagline": self.tagline,
            "summary": self.summary,
            "page_type": self.page_type,
            "tags": list(self.tags.all()),
        }

    def get_context(self, request: HttpRequest, *args: Args, **kwargs: Kwargs) -> ArticleContext:
        """Provide extra context needed for the `Article` to render itself."""
        context = super().get_context(request, *args, **kwargs)
        context.update(self.preview_data)
        context.update(self.get_publication_data())
        context["content"] = self.content
        return cast(ArticleContext, {**context})


class PostGroupePageContext(PageContext):
    """Return-type for a `PostGroupPage`'s context dictionary."""

    posts: OrderedDict[int, list[dict[str, str]]]


class PostGroupPage(RoutablePageMixin, Page):
    """A top-level page for grouping various types of posts or articles."""

    template = "post_listing.html"
    subpage_types: ClassVar[list[str]] = ["hpk.Article"]

    intro = RichTextField(blank=True, help_text="An optional introduction to this group.")

    content_panels: ClassVar[list[Panel]] = [*BasePage.content_panels, FieldPanel("intro")]

    def get_context(
        self, request: HttpRequest, *args: Args, **kwargs: Kwargs
    ) -> PostGroupePageContext:
        """Add a dictionary of posts grouped by year to the context dict."""
        children = self.get_children()
        if not request.user.is_authenticated:
            children = children.live()
        children = children.specific()
        children = children.annotate(
            effective_date=Coalesce("first_published_at", "latest_revision_created_at"),
            year_published=ExtractYear("first_published_at"),
        )

        # Create an OrderedDict grouping posts by year in reverse chronological order
        posts_by_year: OrderedDict = OrderedDict()
        for child in children.order_by("-effective_date"):
            post_data = getattr(child, "preview_data", {}).copy()
            post_data.update(**child.get_publication_data(request))

            # Group posts by year, defaulting to last-draft year if unpublished
            if post_data["year"] not in posts_by_year:
                posts_by_year[post_data["year"]] = []
            posts_by_year[post_data["year"]].append(post_data)

        return cast(
            PostGroupePageContext,
            {**super().get_context(request, *args, **kwargs), "posts_by_year": posts_by_year},
        )

    class Meta:
        """Declare more human-friendly names for the page type."""

        verbose_name: str = "post listing"
        verbose_name_plural: str = "post listings"


@register_setting
class SocialSettings(BaseSiteSetting):
    """Site-wide social media configuration."""

    default_social_image: ForeignKey[Image] = ForeignKey(
        Image,
        null=True,
        blank=True,
        on_delete=SET_NULL,
        help_text="Default image for social media previews.",
        related_name="+",
    )

    panels: ClassVar[list[Panel]] = [
        FieldPanel("default_social_image"),
    ]
