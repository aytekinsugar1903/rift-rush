#!/usr/bin/env python3
"""Check store listing limits and the Android release preset. No network, no secrets."""
import re
import struct
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]

def png_size(path: Path):
    data = path.read_bytes()[:24]
    if data[:8] != b"\x89PNG\r\n\x1a\n":
        raise SystemExit(f"{path} is not a PNG")
    w, h = struct.unpack(">II", data[16:24])
    return w, h

def section(text: str, heading: str) -> str:
    m = re.search(rf"^## {re.escape(heading)}\n(.+?)(?=^## |\Z)", text, re.M | re.S)
    if not m:
        raise SystemExit(f"missing section: {heading}")
    return m.group(1).strip()

def main() -> None:
    errors = []
    en = (ROOT / "store/listing-en.md").read_text()
    tr = (ROOT / "store/listing-tr.md").read_text()
    for label, body, limit in (
        ("en title", section(en, "Title"), 30),
        ("tr title", section(tr, "Title"), 30),
        ("en short", section(en, "Short description"), 80),
        ("tr short", section(tr, "Short description"), 80),
        ("en full", section(en, "Full description"), 4000),
        ("tr full", section(tr, "Full description"), 4000),
    ):
        n = len(body)
        print(f"{label}: {n}/{limit}")
        if n == 0 or n > limit:
            errors.append(f"{label} length {n} not in 1..{limit}")

    shots = sorted((ROOT / "store/phone").glob("*.png"))
    if len(shots) < 2:
        errors.append("need at least 2 phone screenshots")
    for p in shots:
        w, h = png_size(p)
        print(f"{p.name}: {w}x{h}")
        if (w, h) != (1080, 1920):
            errors.append(f"{p.name} is {w}x{h}, expected 1080x1920")
        if b"tRNS" in p.read_bytes()[:64]:
            pass
        # 24-bit RGB: color type 2. IHDR color type is byte 25 of the file (offset 9+16+1? )
        # PNG IHDR: width 4, height 4, bit depth 1, color type 1 at file offset 24
        color_type = p.read_bytes()[25]
        if color_type != 2:
            errors.append(f"{p.name} color type {color_type}, Play phone screenshots should be RGB (2)")

    fw, fh = png_size(ROOT / "store/feature-graphic.png")
    print(f"feature: {fw}x{fh}")
    if (fw, fh) != (1024, 500):
        errors.append("feature graphic must be 1024x500")
    if (ROOT / "store/feature-graphic.png").read_bytes()[25] != 2:
        errors.append("feature graphic must be RGB without alpha")

    iw, ih = png_size(ROOT / "store/icon-512.png")
    print(f"icon: {iw}x{ih} mode-byte {(ROOT / 'store/icon-512.png').read_bytes()[25]}")
    if (iw, ih) != (512, 512):
        errors.append("icon must be 512x512")
    if (ROOT / "store/icon-512.png").stat().st_size > 1024 * 1024:
        errors.append("icon exceeds 1024 KB")

    cfg = (ROOT / "export_presets.cfg").read_text()
    if 'name="Android Release"' not in cfg or "[preset.2.options]" not in cfg:
        errors.append("Android Release preset missing")
    else:
        opt = cfg.split("[preset.2.options]", 1)[1]
        for needle in (
            "gradle_build/use_gradle_build=true",
            "gradle_build/export_format=1",
            'gradle_build/target_sdk="36"',
            'gradle_build/min_sdk="24"',
            "permissions/internet=true",
            'keystore/release=""',
            'keystore/release_user=""',
            'keystore/release_password=""',
            'version/name="0.9.1"',
            "version/code=19",
        ):
            if needle not in opt:
                errors.append(f"release preset missing {needle}")
        if 'export_path="build/riftrush-release.aab"' not in cfg:
            errors.append("release export path is not the AAB")
        if re.search(r'keystore/(debug|release)(_user|_password)?="[^"]+', cfg):
            errors.append("non-empty keystore field in export_presets.cfg")

    if errors:
        print("FAIL")
        for e in errors:
            print(" -", e)
        sys.exit(1)
    print("store listing ok")

if __name__ == "__main__":
    main()
