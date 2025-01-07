"""Functions to transform the response."""

from lxml import etree

from hpk.helpers import get_full_text


def add_heading_ids(tree: etree._Element) -> None:
    """Add a unique id to any heading in <main> missing one, derived from its inner text."""
    seen_ids = set()
    main = tree.xpath("/html/body/main")
    if not main:
        return

    for heading in main[0].xpath(".//h1|//h2|//h3|//h4|//h5|//h6"):
        if heading.get("id"):
            continue
        heading_text = get_full_text(heading)
        slug = heading_text.lower().replace(" ", "-")
        unique_id = slug
        count = 1
        while unique_id in seen_ids:
            unique_id = f"{slug}-{count}"
            count += 1
        seen_ids.add(unique_id)
        heading.set("id", unique_id)
