"""Top-level URL configuration for the site."""

from debug_toolbar.toolbar import debug_toolbar_urls
from django.conf import settings
from django.contrib import admin
from django.urls import include, path
from wagtail import urls as wagtail_urls
from wagtail.admin import urls as wagtailadmin_urls
from wagtail.documents import urls as wagtaildocs_urls

from .views import LandingPageView

urlpatterns = [
    path("django-admin/", admin.site.urls),
    path("admin/", include(wagtailadmin_urls)),
    path("documents/", include(wagtaildocs_urls)),
    path("", LandingPageView.as_view(), name="landing-page"),
]


if settings.DEBUG:
    from django.conf.urls.static import static
    from django.contrib.staticfiles.urls import staticfiles_urlpatterns

    # Serve static and media files from development server
    urlpatterns += staticfiles_urlpatterns()
    urlpatterns += static(settings.MEDIA_URL, document_root=settings.MEDIA_ROOT)

    # Enable Django Debug Toolbar
    urlpatterns += debug_toolbar_urls()

    from .views import debug_shell, theme_gallery

    urlpatterns += [
        path("shell/", debug_shell),
        path("gallery/", theme_gallery),
    ]

urlpatterns += [
    path("", include(wagtail_urls)),
]
