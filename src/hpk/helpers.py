"""Generic helper-functions."""

from ipaddress import AddressValueError, IPv4Address

from lxml.etree import _Element


def get_public_ip() -> IPv4Address | None:
    """Fetch the public-facing IP of the current host."""
    import socket

    import psutil

    for addrs in psutil.net_if_addrs().values():
        for addr in addrs:
            if addr.family == socket.AF_INET:
                ip = addr.address
                if not ip.startswith(("10.", "192.168.", "172.", "127.")):
                    try:
                        return IPv4Address(ip)
                    except AddressValueError:
                        pass
    return None


def get_full_text(element: _Element) -> str:
    """Extract text from an element and its descendants, concatenate it, and trim whitespace."""
    return "".join(element.xpath(".//text()")).strip()
