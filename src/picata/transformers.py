"""Callables to transform the response."""

from lxml import etree

from picata.helpers import ALPHANUMERIC_REGEX, get_full_text


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


class AnchorInserter:
    """Transformer to insert anchored pilcrows into targeted elements in the document."""

    def __init__(self, root: str, targets: str) -> None:
        """Remember the root paths we're to operate on."""
        self.root_xpath = root
        self.targets_xpath = targets

    def __call__(self, tree: etree._Element) -> None:
        """Inserts anchors into targets within the specified roots."""
        for root_element in tree.xpath(self.root_xpath):
            self._process_targets(root_element, self.targets_xpath)

    def _process_targets(self, root: etree._Element, targets: str) -> None:
        """Processes targets within a given root element, inserting anchors."""
        for target in root.xpath(targets):
            target_id = target.get("id")
            if not target_id or target.xpath(".//a"):
                continue

            sanitized_id = self._sanitize_id(target_id)
            if sanitized_id != target_id:
                target.set("id", sanitized_id)

            # Append an anchored pilcrow to the target element
            anchor = etree.Element("a", href=f"#{target_id}", **{"class": "target-link"})
            anchor.text = "¶"
            target.append(anchor)

    def _sanitize_id(self, id_value: str) -> str:
        """Sanitize the ID by removing non-alphanumeric characters."""
        return ALPHANUMERIC_REGEX.sub("", id_value)
