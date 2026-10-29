# Data safety form (draft for Play Console)

Answers describe the 0.9.1 binary and `deploy/worker.js`. Do not submit this until `SUPPORT_EMAIL` in `store/privacy-policy.md` is real and you will delete rows when asked. Do not upload this file to Play; type the answers into the form.

If you later add AdMob or any other SDK, stop and rewrite this form. This draft says there is no ad SDK.

## Security practices

| Question | Answer |
| --- | --- |
| Does the app collect or share any of the required user data types? | Yes |
| Is all of the user data collected by your app encrypted in transit? | Yes. Daily board traffic is HTTPS to `riftrush-demo.aytekinsugar1903.workers.dev`. Offline play sends nothing. |
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

## Do not declare

- Location, financial info, health, messages, photos, audio, files, calendar, contacts, web history
- Advertising ID or app-instance ID
- Crash logs, diagnostics, or analytics SDKs (none are in the project)
- Name, email, phone, or a user account (the nickname is user-generated content, not a legal name)
- Purchases (there are none)

## Device permissions to mention in the listing

- `android.permission.INTERNET` — daily leaderboard only
- `android.permission.VIBRATE` — optional, off in settings

## Ads and families

Play will ask whether the app contains ads. **This build does not.** `ads.gd` is a stub: the reward buttons grant the reward locally and do not load an ad. Declare **No ads**.

Do not opt into Designed for Families. Nicknames are public.

## Local-only data (not sent)

`user://save.cfg` holds coins, unlocks, stars, cards, fire rate, nickname, daily best, and settings. Release export sets `user_data_backup/allow=false`. You do not need to declare on-device-only preferences as collected data.
