# Rift Rush (MVP)

Godot 4.7.1, portrait 1080x1920. Web demo: https://riftrush-demo.aytekinsugar1903.workers.dev

- Web: godot --headless --export-release Web build/web/index.html, sonra deploy/ (wasm gzip + worker)
- APK: --export-debug Android build/riftrush-debug.apk
- Bench: xvfb-run godot --path . -- bench 16 out.png
- Reklamlar: ads.gd (stub)
- Test modlari (hicbiri skor gondermez): autoplay N (AP_MODE=smart|casual|human|hold, AP_TS; human botu AP_HB ile ayarlanir), inputcheck, helpcheck, settingsshot, holdcheck mouse|space, steercheck, uitiming (AP_HELP=1.3 yardimli mermi denemesi), flowtest, bench, hintshot/winshot/popshot
- Zorluk denemesi (insana kalibre): AP_LOADOUT=start ./tools_trials.sh human 1 40 4  (hedef kayip yardimsiz: L1 ~%5-8, L2 ~%30, L3 ~%40)
