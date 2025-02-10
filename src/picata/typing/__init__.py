"""Reusable types for the Picata project."""

from typing import Any, TypedDict

from django.contrib.auth.models import AbstractUser, AnonymousUser, User
from django.http import HttpRequest

# Generic arguments and keyword arguments
Args = tuple[Any, ...]
Kwargs = dict[str, Any]


UserOrNot = User | AnonymousUser | AbstractUser | None


class Context(TypedDict):
    """Base class for context dicts passed all around the system."""

    request: HttpRequest


# Log arguments for structured logging
LogArg = str | int | float | bool
