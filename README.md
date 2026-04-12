# PersonaPulse

Behavioral signals and profile intelligence for Reddit accounts, built with Flutter.

`PersonaPulse` is a cross-platform Reddit profile analysis app with a premium dashboard UI, profile history views, cached research logs, and a branded landing page. The repo package slug is still `reddit_profile_viewer`, but the current product identity in the app and website is `PersonaPulse`.

## What It Does

- Search a Reddit username and generate a profile dashboard
- Pull recent posts and comments from multiple data sources
- Calculate lightweight profile signals such as toxicity and controversial activity
- Save profile history locally with Hive
- Show a global Community Pulse with trending keywords and subreddits
- Export profile dossiers as PDF
- Run across Android, iOS, Windows, Linux, macOS, and web

## Project Structure

- `lib/`: Flutter application code
- `lib/screens/`: splash, home, scanning, dashboard, history, signals, and settings screens
- `lib/services/`: Reddit fetching, cache, and dossier generation services
- `website/`: standalone marketing landing page for PersonaPulse
- `test/`: Flutter tests

## Tech Stack

- Flutter
- Dart
- Dio
- Hive / Hive Flutter
- Flutter Animate
- Google Fonts
- PDF / Printing
- Font Awesome Flutter

## Branding

- Product name: `PersonaPulse`
- App window title: `PersonaPulse Insights`
- Website title/tagline: `PersonaPulse | Behavioral Signals for Reddit Profiles`
- Internal package slug: `reddit_profile_viewer`

If you plan to publish this app, the next cleanup step should be renaming package identifiers consistently across Android, iOS, web manifest, and desktop targets.

## Getting Started

### 1. Install dependencies

```bash
flutter pub get
```

### 2. Configure environment variables

Create a `.env` file in the project root. You can start from `.env.template`.

Expected variables:

```env
REDDIT_CLIENT_ID=your_client_id_here
REDDIT_CLIENT_SECRET=your_client_secret_here
REDDIT_USER_AGENT=android:reddit_scope:v1.0.0 (by /u/your_username)
```

### 3. Run the app

```bash
flutter run
```

Examples:

```bash
flutter run -d windows
flutter run -d chrome
flutter run -d android
```

## Data Sources

The app currently supports multiple service modes behind `RedditService.create()`:

- public Reddit endpoints
- OAuth-based Reddit access
- archive/proxy-assisted mode

The default service configuration lives in `lib/services/reddit_service.dart`.

## Website Assets

The landing page lives in `website/index.html`.

Current brand assets:

- `website/assets/personapulse-mark.svg`
- `website/assets/personapulse-logo.svg`

## Development Notes

- Local cache is initialized through `CacheService`
- The app theme is defined in `AppTheme`
- Some repo files still contain older names such as `RedIntel` or `RedditScope`
- This README reflects the latest public-facing branding, not every legacy internal string

## Compliance

Use the app responsibly and review Reddit's API, data use, and trademark policies before distributing or commercializing it. Avoid implying affiliation with Reddit.

## Status

PersonaPulse is still in active development, so expect ongoing branding cleanup, service refinements, and package identifier changes.
