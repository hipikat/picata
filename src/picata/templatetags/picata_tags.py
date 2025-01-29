"""Package for custom Django template tags."""

from django import template

from .filters.kill_orphans import killorphans
from .filters.stringify import stringify
from .tags.absolute_static import absolute_static
from .tags.menu_tags import render_site_menu

register = template.Library()

register.filter()(killorphans)
register.filter()(stringify)

register.simple_tag(takes_context=True)(absolute_static)
register.inclusion_tag(filename="picata/tags/site_menu.html", takes_context=True)(render_site_menu)

__all__ = ["absolute_static", "killorphans", "render_site_menu", "stringify"]
