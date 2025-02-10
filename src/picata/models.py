"""Django models; mostly subclassed Wagtail classes."""

# NB: Django's meta-class shenanigans over-complicate type hinting when QuerySets get involved.
# pyright: reportAttributeAccessIssue=false

from collections import OrderedDict
from datetime import datetime, timedelta
from typing import Any, ClassVar, TypedDict, cast

from django.contrib.auth.models import AbstractUser
from django.db.models import (
    CASCADE,
    SET_NULL,
    CharField,
    ForeignKey,
    Model,
    SlugField,
    TextField,
)
from django.db.models.functions import Coalesce
from django.http import HttpRequest
from django.urls import reverse
from django.utils.timezone import now
from modelcluster.contrib.taggit import ClusterTaggableManager
from modelcluster.fields import ParentalKey
from taggit.models import TagBase, TaggedItemBase
from wagtail.admin.panels import FieldPanel, Panel
from wagtail.blocks import RichTextBlock
from wagtail.contrib.settings.models import BaseSiteSetting, register_setting
from wagtail.fields import RichTextField, StreamField
from wagtail.images.blocks import ImageChooserBlock
from wagtail.images.models import Image
from wagtail.models import Page, PageManager
from wagtail.query import PageQuerySet
from wagtail.search import index
from wagtail_modeladmin.options import ModelAdmin

from picata.typing import Args, Kwargs, UserOrNot
from picata.typing.wagtail import PageContext

from .blocks import (
    CodeBlock,
    StaticIconLinkListsBlock,
    WrappedImageChooserBlock,
)


class ChronoPageQuerySet(PageQuerySet):
    """QuerySet for pages that can be ordered based on dates."""

    def with_effective_date(self) -> "ChronoPageQuerySet":
        """Annotate pages with 'effective_date' to allow date-based ordering."""
        return self.annotate(
            effective_date=Coalesce("last_published_at", "latest_revision_created_at", now())
        )

    def by_date(self) -> "ChronoPageQuerySet":
        """Return all pages ordered by descending 'effective_date'."""
        return self.with_effective_date().order_by("-effective_date")

    def live_for_user(self, user: UserOrNot = None) -> "ChronoPageQuerySet":
        """Filter out non-live pages for non-authenticated users."""
        return self if user and user.is_authenticated else self.live()

    def descendants_of_page(self, page: Page) -> "ChronoPageQuerySet":
        """Return all Article and PostSeries pages under a given page."""
        from picata.models import Article, PostSeries  # Avoid circular imports

        qs = Page.objects.descendant_of(page).type(Article, PostSeries)  # ✅ Correct approach!
        return qs.specific()  # Ensures the QuerySet remains correctly typed.


class ChronoPageManager(PageManager.from_queryset(ChronoPageQuerySet)):  # type: ignore[misc]
    """Custom manager to ensure QuerySet methods are always available."""


class CorePublicationData(TypedDict):
    """Guaranteed keys for publication data on a page derived from `BasePage`."""

    live: bool
    url: str | None
    published: str | None
    updated: str | None
    year: int
    list_date: datetime


class BasePublicationData(CorePublicationData, total=False):
    """Publication data that may be included on pages derived from `BasePage`."""

    latest_draft: str
    draft_url: str


class BasePageContext(PageContext, total=False):
    """Return-type for an `Article`'s context dictionary."""

    url: str
    published: bool | str
    updated: bool | str
    latest_draft: str
    draft_url: str
    title: str


class BasePage(Page):
    """Mixin for `Page`-types offering previews of themselves on other `Page`s."""

    objects = ChronoPageManager()

    def get_preview_fields(self, user: UserOrNot) -> dict[str, Any]:
        """Return a dictionary of data used in previewing this page type."""
        return {
            "title": self.seo_title or self.title,
            "summary": f"<p>{self.search_description}</p>",
        }

    def get_publication_data(self, request: HttpRequest | None = None) -> dict[str, str]:
        """Helper method to calculate and format relevant dates for previews."""
        site = self.get_site()
        last_edited = (
            self.latest_revision.created_at if self.latest_revision else self.last_published_at
        )
        published, updated = self.first_published_at, self.last_published_at
        year = (
            self.first_published_at.year
            if self.first_published_at
            else (last_edited.year if last_edited else now().year)
        )

        # Convert datetime objects to strings like "3 Jan, '25", or False, and
        # give a grace-period of one week for edits before marking the post as "updated"
        published_str = f"{published.day} {published:%b '%y}" if published else False
        updated_str = (
            f"{updated.day} {updated:%b '%y}"
            if published and updated and (updated >= published + timedelta(weeks=1))
            else False
        )

        data = {
            "live": self.live,
            "url": self.relative_url(site, request),
            "published": published_str,
            "updated": updated_str,
            "year": year,
            "list_date": published if published else last_edited if last_edited else now(),
        }

        # Add last draft date & preview URL if there's an unpublished draft, for logged-in users
        if (
            (request and request.user.is_authenticated)
            and (not published or (updated and last_edited > updated))
            and last_edited
            and hasattr(self, "id")
        ):
            data.update(
                {
                    "latest_draft": f"{last_edited.day} {last_edited:%b '%y}",
                    "draft_url": reverse("wagtailadmin_pages:preview_on_edit", args=[self.id]),
                }
            )

        return data

    def get_context(self, request: HttpRequest, *args: Args, **kwargs: Kwargs) -> BasePageContext:
        """Gather any publication and preview data available for the page into the context."""
        from picata.helpers.wagtail import page_preview_data

        context = super().get_context(request, *args, **kwargs)
        context.update(page_preview_data(self, request))
        return cast(BasePageContext, {**context})

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

    promote_panels: ClassVar[list[Panel]] = [
        FieldPanel("tags"),
        *BasePage.promote_panels,
    ]

    class Meta:
        """Declare `BasePage` as an abstract `Page` class."""

        abstract = True


class BasicPage(BasePage):
    """A basic page model for static content."""

    template = "picata/basic_page.html"

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

    template = "picata/split_view.html"

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


class ArticleContext(BasePageContext):
    """Return-type for an `Article`'s context dictionary."""

    content: str


class SeriesPostMixin:
    """Mixin for articles that belong to a PostSeries."""


class Article(SeriesPostMixin, TaggedPage):
    """Class for article-like pages."""

    template = "picata/article.html"

    tagline: CharField = CharField(
        blank=True, help_text="A short tagline for the article.", max_length=255
    )
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

    promote_panels: ClassVar[list[Panel]] = [
        FieldPanel("summary"),
        FieldPanel("page_type"),
        *TaggedPage.promote_panels,
    ]

    content_panels: ClassVar[list[Panel]] = [
        *TaggedPage.content_panels,
        FieldPanel("tagline"),
        FieldPanel("content"),
    ]

    search_fields: ClassVar[list[index.SearchField]] = [
        *TaggedPage.search_fields,
        index.SearchField("tagline"),
        index.SearchField("summary"),
        index.SearchField("content"),
        index.SearchField("tags"),
        index.SearchField("page_type"),
    ]

    def get_preview_fields(self, user: UserOrNot = None) -> dict[str, Any]:
        """Return data required to render a preview of this article."""
        return {
            **super().get_preview_fields(user),
            "tagline": self.tagline,
            "summary": self.summary,
            "page_type": self.page_type,
            "tags": list(self.tags.all()),
        }

    def get_context(self, request: HttpRequest, *args: Args, **kwargs: Kwargs) -> ArticleContext:
        """Provide extra context needed for the `Article` to render itself."""
        context = dict(super().get_context(request, *args, **kwargs))
        context.update({"content": self.content})
        return cast(ArticleContext, context)


class PostGroupPageContext(BasePageContext):
    """Return-type for a `PostGroupPage`'s context dictionary."""

    posts_by_year: OrderedDict[int, list[dict[str, str]]]


class PostGroupPage(BasePage):
    """A top-level page for grouping various types of posts or articles."""

    template = "picata/post_listing.html"
    subpage_types: ClassVar[list[str]] = ["picata.Article", "picata.PostSeries"]

    intro = RichTextField(blank=True, help_text="An optional introduction to this group.")

    content_panels: ClassVar[list[Panel]] = [*BasePage.content_panels, FieldPanel("intro")]

    def get_context(
        self, request: HttpRequest, *args: Args, **kwargs: Kwargs
    ) -> PostGroupPageContext:
        """Add a dictionary of posts grouped by year to the context dict."""
        from picata.helpers.wagtail import page_preview_data, visible_pages_qs

        children = visible_pages_qs(
            cast(AbstractUser, request.user), cast(PageQuerySet, self.get_children())
        ).specific()

        child_data = sorted(
            [page_preview_data(child, request) for child in children],
            key=lambda p: p["list_date"],
            reverse=True,
        )

        # Create an OrderedDict grouping posts by year in reverse chronological order
        posts_by_year: OrderedDict = OrderedDict()
        for child in child_data:
            # Group posts by year, defaulting to last-draft year if unpublished
            if child["year"] not in posts_by_year:
                posts_by_year[child["year"]] = []
            posts_by_year[child["year"]].append(child)

        return cast(
            PostGroupPageContext,
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


class HomePageContext(BasePageContext):
    """Return-type for the `HomePage`'s context dictionary."""

    top_content: str
    bottom_content: str
    recent_posts: list[BasePage]


class HomePage(BasePage):
    """Single-use specialised page for the root of the site."""

    template = "picata/home_page.html"

    top_content = StreamField(
        [
            ("rich_text", RichTextBlock()),
            ("image", WrappedImageChooserBlock()),
            ("icon_link_lists", StaticIconLinkListsBlock()),
        ],
        use_json_field=True,
        blank=True,
        help_text="Content stream above 'Recent posts'",
    )

    bottom_content = StreamField(
        [
            ("rich_text", RichTextBlock()),
            ("image", WrappedImageChooserBlock()),
            ("icon_link_lists", StaticIconLinkListsBlock()),
        ],
        use_json_field=True,
        blank=True,
        help_text="Content stream rendered under 'Recent posts'",
    )

    content_panels: ClassVar[list[FieldPanel]] = [
        *BasePage.content_panels,
        FieldPanel("top_content"),
        FieldPanel("bottom_content"),
    ]

    search_fields: ClassVar[list[index.SearchField]] = [
        *Page.search_fields,
        index.SearchField("top_content"),
        index.SearchField("bottom_content"),
    ]

    def get_context(self, request: HttpRequest, *args: Args, **kwargs: Kwargs) -> HomePageContext:
        """Add content streams and a recent posts list to the context."""
        from picata.helpers.wagtail import page_preview_data

        recent_posts = Article.objects.live_for_user(request.user).by_date()
        recent_posts = [page_preview_data(post, request) for post in recent_posts]

        return cast(
            HomePageContext,
            {
                **dict(super().get_context(request, *args, **kwargs)),
                "top_content": self.top_content,
                "bottom_content": self.bottom_content,
                "recent_posts": recent_posts,
            },
        )

    class Meta:
        """Declare explicit human-readable names for the page type."""

        verbose_name = "home page"


class PostSeries(BasePage):
    """A container for a series of related articles."""

    introduction = StreamField(
        [("rich_text", RichTextBlock()), ("image", WrappedImageChooserBlock())],
        blank=True,
        use_json_field=True,
    )

    content_panels: ClassVar[list[FieldPanel]] = [
        *BasePage.content_panels,
        FieldPanel("introduction"),
    ]

    parent_page_types: ClassVar[list[str]] = ["PostGroupPage"]
    subpage_types: ClassVar[list[str]] = ["Article"]

    def get_publication_data(self, request: HttpRequest | None = None) -> dict[str, Any]:
        """Return publication data, using the most recent child article's data for sorting."""
        data = super().get_publication_data(request)
        children = (
            Article.objects.child_of(self)
            .by_date()
            .live_for_user(request.user if request else None)
        )
        child_publication_data = [child.get_publication_data(request) for child in children]

        if child_publication_data:
            latest_child = max(child_publication_data, key=lambda p: p["list_date"])
            data["published"] = latest_child["published"]
            data["updated"] = latest_child["updated"]
            data["list_date"] = latest_child["list_date"]

        return data

    def get_preview_fields(self, user: UserOrNot = None) -> dict[str, Any]:
        """Return preview data, including a sorted list of child articles as 'parts'."""
        data = super().get_preview_fields(user)
        children = Article.objects.child_of(self).by_date().live_for_user(user)
        part_previews = [child.get_preview_fields() for child in children]
        data["parts"] = part_previews
        return data
