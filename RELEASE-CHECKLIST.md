# Rift Rush Play Console checklist

Version in this branch: **0.9.1**, versionCode **19**, package `io.github.aytekinsugar1903.riftrush`.

Nothing in this repository publishes the app. You upload the AAB, artwork, and forms yourself in Play Console. Do not commit the upload keystore or its passwords.

## 1. Secrets

Create the Play **upload** key once (Play App Signing will hold the app signing key). Keep the file outside the repo.

| Variable | Where it comes from |
| --- | --- |
| `GODOT_ANDROID_KEYSTORE_RELEASE_PATH` | Path to the `.keystore` or `.jks` file, **not** inside the git tree |
| `GODOT_ANDROID_KEYSTORE_RELEASE_USER` | Key alias |
| `GODOT_ANDROID_KEYSTORE_RELEASE_PASSWORD` | Store password. Godot also uses this as the key password. If those two differ, make them the same before export. |
| `GODOT_ANDROID_KEYSTORE_RELEASE_BASE64` | Optional CI substitute for `PATH`. Base64 of the keystore file. |

GitHub Actions names can match those variables. Decode `BASE64` to a temp file in the job, export `PATH` to that file, and do not print the password. `tools/export_aab.sh` already does the decode and deletes the temp file. It refuses a keystore path inside the repo and refuses a non-empty keystore field in `export_presets.cfg`.

Check the wiring without building:

```bash
./tools/export_aab.sh --check
```

## 2. Build the AAB

Requires Godot 4.7.1, the Android export templates (`android_source.zip` installed from the Godot project menu), a JDK, and the Android SDK with build-tools that can sign for targetSdk 36.

```bash
./tools/export_aab.sh
```

Preset **Android Release** writes `build/riftrush-release.aab`. That preset is Gradle, export format AAB, `minSdk` 24, `targetSdk` 36, arm64-v8a only, Internet and vibration, signing on, backup off. Keystore lines in the preset are empty on purpose so Godot reads the environment variables above.

`build/` is gitignored. Do not attach the AAB to a commit.

Confirm the listing files before you upload artwork:

```bash
python3 tools/check_store_listing.py
```

## 3. Play Console app

Create the app only when you are ready. Suggested answers:

- App name: Rift Rush
- Default language: Turkish or English (listings for both are in `store/`)
- App or game: Game
- Free
- Declarations: not a news app, not a government app, not COVID-19 related
- Package name must stay `io.github.aytekinsugar1903.riftrush`

Enroll in **Play App Signing**. The keystore from step 1 is the upload key, not Google's app signing key. Losing the upload key means you cannot ship updates until Play support resets it.

## 4. Store listing (manual upload)

| Play field | File |
| --- | --- |
| English title, short description, full description | `store/listing-en.md` |
| Turkish title, short description, full description | `store/listing-tr.md` |
| App icon 512×512 | `store/icon-512.png` |
| Feature graphic 1024×500 | `store/feature-graphic.png` |
| Phone screenshots (1080×1920) | `store/phone/01-menu.png` through `05-victory.png` |

Use the same icon and feature graphic for both languages unless you make a Turkish graphic later. Limits: title 30, short description 80, full description 4000.

Add a real support email on the listing. The privacy policy still says `SUPPORT_EMAIL` until you replace it.

## 5. Privacy policy

1. Replace every `SUPPORT_EMAIL` in `store/privacy-policy.md`.
2. Host that page at a public HTTPS URL you control. This repo does not host it.
3. Paste that URL into Play Console. The daily-board host (`riftrush-demo...workers.dev`) is the API, not the policy, unless you deliberately publish the policy there yourself.

## 6. Data safety

Transcribe `store/data-safety.md`. Short version:

- Collect nickname, daily shot count, and a truncated daily hash of the connection IP for rate limiting.
- Do not mark data as sold or shared.
- Encrypted in transit: yes.
- Deletion: answer **Yes** only after the email in the policy is monitored and you will delete the `scores` row. Otherwise answer **No**.
- Ads: **No** for 0.9.1. There is no ad SDK.
- Do not enroll in Designed for Families.

## 7. Content rating

Fill the IARC questionnaire from `store/content-rating.md`. Cartoon fantasy violence, public nicknames, no sex, gambling, substances, or purchases, no ads in this build. Save the certificate Play generates. Do not invent the age rating in the listing text.

## 8. Other policy forms

- Ads declaration: **Yes**. Rewarded ads are opt-in. Interstitials are between levels only (see `store/data-safety.md`). The Android build uses Google's test ad ids from `ads_config.gd` until you paste the real app id and two ad unit ids there and rebuild. Do not ship test ids to production.
- Target audience: not children. 13+ is the honest fit while nicknames are public.
- News: No. COVID-19: No. Government: No.
- Data deletion URL: the hosted privacy policy, once the email works.
- Advertising ID: the app does not use it.

## 9. Ads before review

`ads_config.gd` is the only id source. It currently holds Google's official test ids because the AdMob account is pending. Create the app and two units (rewarded, interstitial) in AdMob, put those three ids in that file, rebuild the AAB, and create the UMP GDPR message (and a KVKK / Turkey message if AdMob offers it) before production. Until then, test ads are what the release build requests.

In the EEA, UMP shows Google's form before ads load. Elsewhere, including Turkey, the game asks a local allow / not-now question (Settings can change it). Refusing ads, or a failed load, must leave the level playable: rewarded buttons grant nothing, and the next level still opens.

Do not add another ad network without editing the privacy policy and the Data safety draft again.

The daily API has no delete endpoint. Deletion is a manual SQL change when someone emails you.

Old rows in D1 tables `scores` and `rl` are not purged. Delete them yourself if you promised a retention period.

## 10. Ship it yourself

1. Upload `build/riftrush-release.aab` to an **internal testing** track first.
2. Install that build on a phone. Open a level offline, then open the daily board and confirm a nickname posts only when it is at least two characters.
3. Promote to production only after internal testing looks right.

Do not run a Play upload action from CI unless you add that step yourself later. `tools/export_aab.sh` stops when the AAB file exists.
