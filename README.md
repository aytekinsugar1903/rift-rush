# Rift Rush (MVP)

Godot 4.7.1, portrait 1080x1920. Web demo: https://riftrush-demo.aytekinsugar1903.workers.dev

- Web: godot --headless --export-release Web build/web/index.html, sonra deploy/ (wasm gzip + worker)
- APK: --export-debug Android build/riftrush-debug.apk
- Bench: xvfb-run godot --path . -- bench 16 out.png
- Reklamlar: ads.gd (stub)
