"""Test the landing page response as expected, to an actual test client."""

from http import HTTPStatus

import pytest
from django.test import Client


@pytest.mark.django_db
def test_homepage_contains_welcome() -> None:
    """Test that the homepage contains the expected welcome message."""
    client = Client()
    response = client.get("/")
    assert response.status_code == HTTPStatus.OK
    assert "Welcome to your new Wagtail site!" in response.content.decode()
