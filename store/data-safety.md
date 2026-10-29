# Data safety form (draft for Play Console)

Answers describe the 0.9.1 Android release: the game, `deploy/worker.js`, and the Google Mobile Ads SDK (AdMob) plus UMP. Do not submit this until `SUPPORT_EMAIL` in `store/privacy-policy.md` is real and you will delete leaderboard rows when asked. Do not upload this file to Play; type the answers into the form.

Ad unit ids in `ads_config.gd` are Google's test ids until the AdMob account is approved. Test ads still talk to Google. Replace the three constants with real ids before production, then rebuild the AAB. The data types below stay the same.

## Security practices

| Question | Answer |
| --- | --- |
| Does the app collect or share any of the required user data types? | Yes |
| Is all of the user data collected by your app encrypted in transit? | Yes. Daily board traffic is HTTPS to `riftrush-demo.aytekinsugar1903.workers.dev`. AdMob and UMP use Google's HTTPS endpoints. Offline play with ads refused sends neither. |
| Do you provide a way for users to request that their data is deleted? | Yes, only after the privacy-policy contact address is live and you delete the `scores` row for that nickname and day on request. Until that process exists, answer **No**. |

Data is not sold. Data is not shared with third parties. The Cloudflare Worker is your own backend, not a data broker.

## Data types to declare

### App activity → Other user-generated content

The nickname the player types (2–16 letters, numbers, space, `_`, `.`, `-`).

| Field | Answer |
| --- | --- |
| Collected | Yes |
| Shared | No |
| Processed ephemerally | No. Stored in D1 table `scores`. |
| Required or optional | Optional. Under two characters, no score is sent. The campaign is playable with no nickname. |
| Purposes | App functionality (daily leaderboard) |

### App activity → Other actions

The daily shot count, the Istanbul calendar day, and the score timestamp.

| Field | Answer |
| --- | --- |
| Collected | Yes, only when a valid nickname posts a daily result |
| Shared | No |
| Processed ephemerally | No |
| Required or optional | Optional (same gate as the nickname) |
| Purposes | App functionality |

### Device or other IDs

Not the advertising ID. When the device calls the daily API, the server stores a rate-limit key: the first 12 bytes of SHA-256 of `IP|day|rr`, plus a counter. The raw IP is not stored in D1.

| Field | Answer |
| --- | --- |
| Collected | Yes, when the daily board is opened or a score is posted |
| Shared | No |
| Processed ephemerally | No. Rows stay in table `rl` until you delete them. |
| Required or optional | Required for that network call. Not collected during offline levels. |
| Purposes | Fraud prevention, security, and compliance |

## AdMob SDK (shared with Google)

Declare these because the Mobile Ads SDK and UMP run when the player allows ads. Google's own disclosure is the source of truth if it changes: developers.google.com/admob/android/privacy/play-data-disclosure.

| Data type | Collected | Shared | Optional? | Purposes |
| --- | --- | --- | --- | --- |
| Device or other IDs (including Advertising ID) | Yes | Yes, with Google | Optional. Not used if the player refuses ads. | Advertising or marketing; Fraud prevention, security, and compliance |
| App activity → App interactions | Yes | Yes, with Google | Optional, same as above | Advertising or marketing |
| App info and performance → Crash logs | Yes | Yes, with Google | Optional, same as above | Analytics |
| App info and performance → Diagnostics | Yes | Yes, with Google | Optional, same as above | Analytics |

Approximate location is not requested by Rift Rush. Leave it off unless a future AdMob feature starts using it.

UMP stores the GDPR consent decision through Google's SDK. The local KVKK choice (`allow` / `deny`) stays on the device and is not uploaded by Rift Rush.

## Ads declaration

Play Console "Ads" question: **Yes**. Rewarded ads are player-initiated. Interstitials are between levels only, after level 3, at most every 3 wins and every 3 minutes. None during a run.

## Do not declare

- Precise or approximate location, financial info, health, messages, photos, audio, files, calendar, contacts, web history
- Name, email, phone, or a user account (the nickname is user-generated content, not a legal name)
- Purchases (there are none)

Advertising ID, crash logs, and diagnostics are declared above because AdMob collects them. Rift Rush does not add a separate analytics SDK.

## Device permissions to mention in the listing

- `android.permission.INTERNET` — daily leaderboard and ads
- `android.permission.VIBRATE` — optional, off in settings
- Advertising ID — merged in by the Google Mobile Ads SDK when ads are allowed

## Families

Do not opt into Designed for Families. Nicknames are public and the app shows ads.

## Local-only data (not sent)

`user://save.cfg` holds coins, unlocks, stars, cards, fire rate, nickname, daily best, and settings. Release export sets `user_data_backup/allow=false`. You do not need to declare on-device-only preferences as collected data.
