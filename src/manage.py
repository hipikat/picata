#!/usr/bin/env python
"""Entry-point for Django management commands."""

from os import environ
from sys import argv

if __name__ == "__main__":
    environ.setdefault("DJANGO_SETTINGS_MODULE", "picata.settings.dev")

    if len(argv) >= 2:  # noqa: PLR2004
        environ.setdefault("DJANGO_MANAGEMENT_COMMAND", argv[1])

    from django.core.management import execute_from_command_line

    execute_from_command_line(argv)
