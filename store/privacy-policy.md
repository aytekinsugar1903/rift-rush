# Rift Rush privacy policy

**Effective date:** 29 October 2026
**App:** Rift Rush, Android package `io.github.aytekinsugar1903.riftrush`
**Version this text describes:** 0.9.1 (versionCode 19)

Replace `SUPPORT_EMAIL` with a monitored address before you host this page. The hosted URL is what you paste into Play Console. This file is the text; it is not published by the repository itself.

**Contact:** SUPPORT_EMAIL

## English

Rift Rush is an offline cartoon crowd-runner with an optional daily leaderboard.

### Data that stays on the device

A local save stores coins, level unlocks, stars, card ownership and levels, cannon fire-rate level, the nickname you typed, your best daily shot count, and settings (sound, music, vibration, shadows). It is not sent anywhere by itself. Uninstalling the app removes it. Android backup of this save is turned off in the release export.

### Daily leaderboard

If you open the daily challenge, the app loads the public board from:

`https://riftrush-demo.aytekinsugar1903.workers.dev`

If your nickname is at least two characters and you finish the daily castle, the app sends:

- the nickname
- the day (Europe/Istanbul calendar date)
- the shot count

The server stores nickname, shot count, and the time of the score. A better (lower) shot count replaces an older one for the same nickname and day. Nicknames are visible to anyone who opens that day's board.

The server also stores a daily rate-limit counter under a key that is the first 12 bytes of SHA-256 of your connection IP, the day, and a fixed suffix. The raw IP address is not written into the game database. The key exists so one network cannot flood the board. It is not used for advertising.

The app does not send your score when the nickname is shorter than two characters, and test runs inside the development build do not send scores.

### What this version does not do

This build does not include an advertising SDK, does not read the advertising ID, and does not offer in-app purchases. Buttons labeled as watching an ad grant the reward on the device; they do not contact an ad network. If a later version adds a real ad network, this policy and the Play Data safety form must be updated before that version ships.

There is no account system, no precise location, no contacts, photos, or microphone access. The release app requests Internet (for the daily board) and vibration (if you leave vibration on).

### Children

The game is cartoon fantasy violence. It is not directed at children under 13, and it should not be enrolled in Google Play Families while nicknames are public. Do not post a nickname you would not want other players to see.

### Deletion

To delete a daily score, email SUPPORT_EMAIL with the nickname and the day. The developer deletes that nickname's row for that day from the score table. Local data is removed by clearing the app's storage or uninstalling it. There is no in-app delete button in 0.9.1.

### Changes

A new policy will be posted at the same URL with a new effective date. Continued use of the daily board after that date means you accept the new text.

## Türkçe

Rift Rush, isteğe bağlı günlük sıralaması olan, çevrimdışı oynanabilen bir çizgi film kalabalık koşusudur.

### Cihazda kalan veriler

Yerel kayıt; coin, açılan bölümler, yıldızlar, kart sahipliği ve seviyeleri, atış hızı, yazdığın takma ad, günlük en iyi atış sayın ve ayarları (ses, müzik, titreşim, gölge) tutar. Bu kayıt kendiliğinden gönderilmez. Uygulamayı silmek onu siler. Yayın dışa aktarımında Android yedeklemesi kapalıdır.

### Günlük sıralama

Günlük meydan okumayı açarsan uygulama sıralamayı şu adresten yükler:

`https://riftrush-demo.aytekinsugar1903.workers.dev`

Takma adın en az iki karakterse ve günlük kaleyi bitirirsen uygulama şunları gönderir:

- takma ad
- gün (Europe/Istanbul tarihi)
- atış sayısı

Sunucu takma adı, atış sayısını ve skor zamanını saklar. Aynı takma ad ve günde daha düşük atış, eskisinin yerine geçer. Takma adlar o günün sıralamasını açan herkese görünür.

Sunucu ayrıca bağlantı IP adresinin, günün ve sabit bir son ekin SHA-256 özetinin ilk 12 baytını hız sınırı anahtarı olarak tutar. Ham IP, oyun veritabanına yazılmaz. Anahtar, bir ağın sıralamayı doldurmasını engellemek içindir. Reklam için kullanılmaz.

Takma ad iki karakterden kısaysa skor gönderilmez. Geliştirme içindeki test koşuları da skor göndermez.

### Bu sürümün yapmadıkları

Bu sürümde reklam SDK'sı yoktur, reklam kimliği okunmaz ve uygulama içi satın alma yoktur. Reklam izle diye etiketlenmiş düğmeler ödülü cihazda verir; bir reklam ağına bağlanmaz. İleride gerçek bir reklam ağı eklenirse bu metin ve Play Veri güvenliği formu, o sürüm çıkmadan güncellenmelidir.

Hesap sistemi, kesin konum, kişiler, fotoğraf veya mikrofon yoktur. Yayın uygulaması İnternet (günlük sıralama) ve titreşim (ayarı açıksa) iznini ister.

### Çocuklar

Oyun çizgi film tarzında fantastik şiddet içerir. 13 yaş altındaki çocuklara yönelik değildir. Takma adlar herkese açıkken Google Play Families programına alınmamalıdır. Başkalarının görmesini istemediğin bir takma ad yazma.

### Silme

Günlük skoru silmek için SUPPORT_EMAIL adresine takma adı ve günü yaz. Geliştirici o günkü skor satırını siler. Yerel veri, uygulama depolamasını temizlemekle veya uygulamayı kaldırmakla silinir. 0.9.1 sürümünde uygulama içi silme düğmesi yoktur.

### Değişiklikler

Yeni metin aynı adreste, yeni yürürlük tarihiyle yayınlanır. O tarihten sonra günlük sıralamayı kullanmaya devam etmek yeni metni kabul etmek anlamına gelir.
