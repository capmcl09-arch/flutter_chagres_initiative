#!/usr/bin/env python3
"""Fetch Panama Canal headlines from Google News RSS and write news.json.

Runs daily in CI. On any failure (network, parse, empty result) it leaves
the existing news.json untouched — the site keeps showing the last-known-good
headlines — and exits 0 so the workflow does not fail noisily.

Output path is controlled by NEWS_OUT (default docs/news.json). Pass extra
paths as CLI args to write the same payload to multiple locations
(e.g. build/web/news.json for local testing).
"""
import json
import os
import sys
from datetime import datetime, timezone
from email.utils import parsedate_to_datetime
from urllib.request import Request, urlopen
from xml.etree import ElementTree as ET

FEED = (
    "https://news.google.com/rss/search?"
    "q=%22panama+canal%22+when:30d&hl=en-US&gl=US&ceid=US:en"
)
MAX_ITEMS = 12
TIMEOUT = 30
USER_AGENT = "Mozilla/5.0 (ChagresInitiative canal-news ticker)"


def short_date(pub: str) -> str:
    """RFC-822 pubDate -> 'M/D/YY' (e.g. '5/20/26'); '' if unparseable."""
    if not pub:
        return ""
    try:
        dt = parsedate_to_datetime(pub)
        return f"{dt.month}/{dt.day}/{dt:%y}"
    except (TypeError, ValueError):
        return ""


def fetch(url: str) -> bytes:
    req = Request(url, headers={"User-Agent": USER_AGENT})
    with urlopen(req, timeout=TIMEOUT) as resp:
        return resp.read()


def parse(xml_bytes: bytes) -> list[dict]:
    root = ET.fromstring(xml_bytes)
    items: list[dict] = []
    for item in root.iter("item"):
        title = (item.findtext("title") or "").strip()
        link = (item.findtext("link") or "").strip()
        pub = (item.findtext("pubDate") or "").strip()
        source_el = item.find("source")
        source = (
            source_el.text.strip()
            if source_el is not None and source_el.text
            else ""
        )
        if not title or not link:
            continue
        # Google titles read "Headline - Source"; strip the trailing source.
        clean = title
        if source and clean.endswith(" - " + source):
            clean = clean[: -(len(source) + 3)].strip()
        items.append(
            {
                "title": clean,
                "url": link,
                "source": source,
                "published": pub,
                "date": short_date(pub),
            }
        )
    return items


def main() -> int:
    out_paths = [os.environ.get("NEWS_OUT", "docs/news.json")]
    out_paths.extend(sys.argv[1:])

    try:
        items = parse(fetch(FEED))
    except Exception as exc:  # noqa: BLE001 - keep CI green, preserve old file
        print(f"warn: fetch/parse failed: {exc}", file=sys.stderr)
        return 0

    # De-dupe by lowercase title, keep feed order, cap the count.
    seen: set[str] = set()
    deduped: list[dict] = []
    for it in items:
        key = it["title"].lower()
        if key in seen:
            continue
        seen.add(key)
        deduped.append(it)
    deduped = deduped[:MAX_ITEMS]

    if not deduped:
        print(
            "warn: no items parsed; leaving existing news.json untouched",
            file=sys.stderr,
        )
        return 0

    payload = {
        "updated": datetime.now(timezone.utc).isoformat(),
        "items": deduped,
    }
    for path in out_paths:
        directory = os.path.dirname(path)
        if directory:
            os.makedirs(directory, exist_ok=True)
        with open(path, "w", encoding="utf-8") as fh:
            json.dump(payload, fh, ensure_ascii=False, indent=2)
        print(f"wrote {len(deduped)} items to {path}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
