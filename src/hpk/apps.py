"""Application configuration for the hpk Django app."""

from django.apps import AppConfig


class Config(AppConfig):
    """Configuration class for the hpk Django application."""

    default_auto_field = "django.db.models.BigAutoField"
    name = "hpk"

    def ready(self) -> None:
        """Configure Wagtail admin with custom models, and register document transformers."""
        #
        # Register the 'custom article type' model with the Wagtail admin
        from wagtail_modeladmin.options import modeladmin_register

        from hpk.models import ArticleTypeAdmin

        modeladmin_register(ArticleTypeAdmin)

        # Add document transformers to the HTMLProcessingMiddleware
        from hpk.middleware import HTMLProcessingMiddleware
        from hpk.transformers import add_heading_ids

        HTMLProcessingMiddleware.add_transformer(add_heading_ids)
