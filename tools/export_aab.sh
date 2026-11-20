#!/usr/bin/env bash
# Build the Play upload bundle (AAB). Does not upload anywhere.
#
# The upload keystore is read only from the environment (local shell or CI secrets).
# Godot 4.7 uses these names when the matching export-preset fields are empty:
#   GODOT_ANDROID_KEYSTORE_RELEASE_PATH
#   GODOT_ANDROID_KEYSTORE_RELEASE_USER
#   GODOT_ANDROID_KEYSTORE_RELEASE_PASSWORD   (store password and key password; Godot has one field)
#
# CI alternative: set GODOT_ANDROID_KEYSTORE_RELEASE_BASE64 instead of PATH.
# The script decodes it to a temp file outside the repo and deletes it on exit.
#
# Usage:
#   ./tools/export_aab.sh           # export build/riftrush-release.aab
#   ./tools/export_aab.sh --check   # validate secrets and preset, do not export
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

CHECK_ONLY=0
if [[ "${1:-}" == "--check" ]]; then
  CHECK_ONLY=1
elif [[ $# -gt 0 ]]; then
  echo "usage: ./tools/export_aab.sh [--check]" >&2
  exit 2
fi

# Refuse a committed keystore value. Empty quotes are the only allowed form.
if grep -E 'keystore/(debug|release)(_user|_password)?="[^"]+' export_presets.cfg >/dev/null; then
  echo "refusing: export_presets.cfg has a non-empty keystore field" >&2
  exit 1
fi

if [[ -z "${GODOT_ANDROID_KEYSTORE_RELEASE_USER:-}" || -z "${GODOT_ANDROID_KEYSTORE_RELEASE_PASSWORD:-}" ]]; then
  echo "refusing: set GODOT_ANDROID_KEYSTORE_RELEASE_USER and GODOT_ANDROID_KEYSTORE_RELEASE_PASSWORD" >&2
  exit 1
fi

TMP_KS=""
cleanup() {
  if [[ -n "$TMP_KS" && -f "$TMP_KS" ]]; then
    rm -f "$TMP_KS"
  fi
}
trap cleanup EXIT

if [[ -z "${GODOT_ANDROID_KEYSTORE_RELEASE_PATH:-}" ]]; then
  if [[ -z "${GODOT_ANDROID_KEYSTORE_RELEASE_BASE64:-}" ]]; then
    echo "refusing: set GODOT_ANDROID_KEYSTORE_RELEASE_PATH or GODOT_ANDROID_KEYSTORE_RELEASE_BASE64" >&2
    exit 1
  fi
  TMP_KS="$(mktemp "${TMPDIR:-/tmp}/riftrush-upload.XXXXXX.keystore")"
  chmod 600 "$TMP_KS"
  if ! printf '%s' "$GODOT_ANDROID_KEYSTORE_RELEASE_BASE64" | base64 -d >"$TMP_KS"; then
    echo "refusing: keystore base64 could not be decoded" >&2
    exit 1
  fi
  export GODOT_ANDROID_KEYSTORE_RELEASE_PATH="$TMP_KS"
fi

KS="$(readlink -f "$GODOT_ANDROID_KEYSTORE_RELEASE_PATH")"
case "$KS" in
  "$ROOT"|"$ROOT"/*)
    echo "refusing: upload keystore must live outside the git repo" >&2
    exit 1
    ;;
esac
if [[ ! -f "$KS" || ! -s "$KS" ]]; then
  echo "refusing: upload keystore file is missing or empty" >&2
  exit 1
fi
if git -C "$ROOT" ls-files --error-unmatch -- "$KS" >/dev/null 2>&1; then
  echo "refusing: upload keystore is tracked by git" >&2
  exit 1
fi

echo "upload keystore: outside repo, $(wc -c <"$KS" | tr -d ' ') bytes, alias length ${#GODOT_ANDROID_KEYSTORE_RELEASE_USER}"

if [[ "$CHECK_ONLY" == "1" ]]; then
  echo "check ok (no export, no upload)"
  exit 0
fi

GODOT="${GODOT:-godot}"
mkdir -p "$ROOT/build"
"$GODOT" --headless --path "$ROOT" --export-release "Android Release" "$ROOT/build/riftrush-release.aab"
if [[ ! -s "$ROOT/build/riftrush-release.aab" ]]; then
  echo "export failed: build/riftrush-release.aab was not written" >&2
  exit 1
fi
echo "wrote build/riftrush-release.aab ($(wc -c <"$ROOT/build/riftrush-release.aab" | tr -d ' ') bytes). Not uploaded."
