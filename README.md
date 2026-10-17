# Rift Rush (MVP)

Godot 4.7.1, portrait 1080x1920. Web demo: https://riftrush-demo.aytekinsugar1903.workers.dev

- Web: godot --headless --export-release Web build/web/index.html, sonra deploy/ (wasm gzip + worker)
- APK: --export-debug Android build/riftrush-debug.apk
- Bench: xvfb-run godot --path . -- bench 16 out.png
- Reklamlar: ads.gd (stub)
- Test modlari (hicbiri skor gondermez): clickcheck (tum ekran gecislerinde ilk tik; 3 desen: hareket+bas, isinlan+ayni karede bas, hareketsiz bas; oyun tutmasi birakmasi), holdsteer (bas-tut nisan, fare+dokunma), AP_FPS=4 (dusuk FPS yavas cihaz), autoplay N (AP_MODE=smart|casual|human|weak|hold, AP_TS; human/weak botu AP_HB ile ayarlanir; AP_LOSS=1|2 gercek yardim yolunu dener), inputcheck, helpcheck, settingsshot, holdcheck mouse|space, steercheck, uitiming (AP_HELP=1.3 yardimli mermi denemesi), flowtest, bench, hintshot/winshot/popshot
- Zorluk denemesi (insana kalibre): AP_LOADOUT=start ./tools_trials.sh human 1 40 4  (hedef kayip yardimsiz: L1 ~%5-8, L2 ~%30, L3 ~%40)
- Zayif insan (yarim isabet, gec tepki): AP_LOSS=2 AP_LOADOUT=start ./tools_trials.sh weak 1 48 8 (hedef: L2 <%35 yardimsiz / <%5 +%30 yardimla, L3 <%45 / <%10)
