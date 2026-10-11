#!/usr/bin/env python3
"""Download hero icons and map images, write Content/maps.json. Run from the repo root."""
import html
import json
import re
import subprocess
import sys
import tempfile
import unicodedata
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
CATALOG = ROOT / "App" / "Assets.xcassets"
HEROES_URL = "https://overwatch.blizzard.com/en-us/heroes/"
MAPS_API = "https://overwatch.fandom.com/api.php?action=parse&page=Maps&prop=text&format=json"
MODES = ["Control", "Escort", "Flashpoint", "Hybrid", "Push"]
UA = "Mozilla/5.0 (OWCoach asset script)"


def get(url: str) -> bytes:
    # Fandom's Cloudflare rejects Python's urllib TLS fingerprint, and its image CDN wants a fandom Referer.
    command = ["curl", "-sfL", "--max-time", "30", "-A", UA, "-e", "https://overwatch.fandom.com/", url]
    return subprocess.run(command, check=True, capture_output=True).stdout


def slug(name: str) -> str:
    ascii_name = unicodedata.normalize("NFKD", name).encode("ascii", "ignore").decode()
    ascii_name = ascii_name.replace("'", "")
    return re.sub(r"[^a-z0-9]+", "-", ascii_name.lower()).strip("-")


def as_jpeg(data: bytes) -> bytes:
    # Fandom's CDN serves WebP to some clients; asset catalogs need PNG or JPEG.
    with tempfile.TemporaryDirectory() as tmp:
        source, target = Path(tmp) / "in", Path(tmp) / "out.jpg"
        source.write_bytes(data)
        subprocess.run(["sips", "-s", "format", "jpeg", str(source), "--out", str(target)], check=True, capture_output=True)
        return target.read_bytes()


def write_imageset(folder: Path, name: str, data: bytes, ext: str) -> None:
    group = CATALOG / folder
    group.mkdir(parents=True, exist_ok=True)
    (group / "Contents.json").write_text(json.dumps({"info": {"author": "xcode", "version": 1}}, indent=2))
    imageset = group / f"{name}.imageset"
    imageset.mkdir(exist_ok=True)
    filename = f"{name}.{ext}"
    (imageset / filename).write_bytes(data)
    contents = {"images": [{"filename": filename, "idiom": "universal"}], "info": {"author": "xcode", "version": 1}}
    (imageset / "Contents.json").write_text(json.dumps(contents, indent=2))


def fetch_heroes() -> None:
    page = get(HEROES_URL).decode("utf-8")
    urls = dict(re.findall(r'alt="([^"]+)" slot="media" src="([^"]+\.png)"', page))
    for path in sorted((ROOT / "Content" / "heroes").glob("*.json")):
        hero_id = json.loads(path.read_text())["id"]
        if hero_id not in urls:
            sys.exit(f"hero icon not found on Blizzard page: {hero_id}")
        write_imageset(Path("Heroes"), f"hero-{hero_id}", get(urls[hero_id]), "png")
        print("hero", hero_id)


def fetch_maps() -> None:
    text = json.loads(get(MAPS_API))["parse"]["text"]["*"]
    section = text[text.index('id="Standard_Play"'):text.index('id="Standard_Play_map_statistics"')]
    maps = []
    for mode in MODES:
        match = re.search(rf'id="{mode}">{mode}</span>.*?<ul class="gallery[^"]*">(.*?)</ul>', section, re.S)
        if not match:
            sys.exit(f"mode section not found: {mode}")
        for box in re.findall(r'<li class="gallerybox".*?</li>', match.group(1), re.S):
            image = re.search(r'<img alt="([^"]+)"[^>]*data-src="([^"]+)"', box)
            if not image:
                continue
            name = html.unescape(image.group(1))
            url = re.sub(r"/scale-to-width-down/\d+", "/scale-to-width-down/480", html.unescape(image.group(2)))
            map_id = slug(name)
            write_imageset(Path("Maps"), f"map-{map_id}", as_jpeg(get(url)), "jpg")
            maps.append({"id": map_id, "name": name, "mode": mode.lower()})
            print("map", map_id)
    maps.sort(key=lambda m: (MODES.index(m["mode"].capitalize()), m["name"]))
    (ROOT / "Content" / "maps.json").write_text(json.dumps(maps, ensure_ascii=False, indent=2) + "\n")


if __name__ == "__main__":
    fetch_heroes()
    fetch_maps()
