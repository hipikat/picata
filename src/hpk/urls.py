"""Top-level URL configuration for the site."""

from debug_toolbar.toolbar import debug_toolbar_urls
from django.conf import settings
from django.contrib import admin
from django.urls import include, path
from wagtail import urls as wagtail_urls
from wagtail.admin import urls as wagtailadmin_urls
from wagtail.documents import urls as wagtaildocs_urls

urlpatterns = [
    path("django-admin/", admin.site.urls),  # Django Admin
    path("admin/", include(wagtailadmin_urls)),  # Wagtail Admin
    path("documents/", include(wagtaildocs_urls)),  # Wagtail documents
]

# Debug-mode-only URLs
if settings.DEBUG:
    from django.conf.urls.static import static
    from django.contrib.staticfiles.urls import staticfiles_urlpatterns
    from django.views.generic import RedirectView

    from .views import debug_shell, theme_gallery

    # Serve static and media files from development server
    urlpatterns += staticfiles_urlpatterns()
    urlpatterns += static(settings.MEDIA_URL, document_root=settings.MEDIA_ROOT)

    # Enable Django Debug Toolbar
    urlpatterns += debug_toolbar_urls()

    urlpatterns += [
        path("favicon.ico", RedirectView.as_view(url=settings.STATIC_URL + "favicon.ico")),
        path("shell/", debug_shell),  # Just raises an exception (to invoke Werkzeug shell access)
        path("gallery/", theme_gallery),  # "Theme gallery", for reference while tweaking the theme
    ]

# Let Wagtail take care of the rest
urlpatterns += [path("", include(wagtail_urls))]
