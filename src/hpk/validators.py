"""Custom validators for Django fields."""

from django.core.exceptions import ValidationError
from django.core.validators import URLValidator


class HREFValidator:
    """Custom validator for href attributes in HTML anchor tags.

    Basically it's `URLValidator` but with 'mailto:', 'tel:' and 'file:' added.
    (Doesn't actually validate email addresses, telephone numbers, or file paths.)
    """

    def __init__(
        self, extra_schemes: list[str] | None = None, url_schemes: list[str] | None = None
    ) -> None:
        """Store schemes we check for and initialise a basic `URLValidator`."""
        self.schemes: list[str] = extra_schemes or ["mailto", "tel", "file", "sms"]
        self.base_validator = URLValidator(schemes=url_schemes)

    def __call__(self, value: str) -> None:
        """Try validating a custom scheme (e.g. "mailto:…") if the `URLValidator` fails."""
        try:
            self.base_validator(value)
        except ValidationError as err:
            if ":" in value:
                if not any(value.startswith(f"{scheme}:") for scheme in self.schemes):
                    raise ValidationError(
                        f"'{value}' is not a valid href.", code="invalid_href"
                    ) from err
            elif not value.startswith(("/", "#")):  # Allow relative links or fragments
                raise ValidationError(
                    f"'{value}' is not a valid href.", code="invalid_href"
                ) from err
        else:
            return
