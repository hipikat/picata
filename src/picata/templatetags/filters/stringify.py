"""Filter to transform Python types into human-readable strings."""  # noqa: INP001


def stringify(value: list, quote_style: str | None = None) -> str:
    """Convert a list of strings into a human-readable string with optional quoting."""
    if not value:
        return ""

    if not (isinstance(value, list | set | tuple)):
        raise TypeError("The 'stringify' filter currently only supports lists.")

    quote = "'" if quote_style == "single" else '"' if quote_style == "double" else ""
    quoted_items = [f"{quote}{item!s}{quote}" for item in value]

    if len(quoted_items) == 0:
        return ""
    if len(quoted_items) == 1:
        return quoted_items[0]
    if len(quoted_items) == 2:  # noqa: PLR2004
        return " and ".join(quoted_items)
    return f"{', '.join(quoted_items[:-1])}, and {quoted_items[-1]}"
