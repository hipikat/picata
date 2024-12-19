"""App configuration for the hpk Django app."""

from django.apps import AppConfig


class Config(AppConfig):
    """Configuration class for the hpk Django app."""

    default_auto_field = "django.db.models.BigAutoField"
    name = "hpk"

    def ready(self) -> None:
        """Register custom ModelAdmin classes with the Wagtail admin."""
        from wagtail_modeladmin.options import modeladmin_register

        from .models import ArticleTypeAdmin

        modeladmin_register(ArticleTypeAdmin)
