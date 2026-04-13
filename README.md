# SubVetter

**Discover & Qualify Reddit Leads Instantly.**

SubVetter is a professional Audience Intelligence and Lead Qualification platform built with Flutter. It helps B2B founders, sales teams, and researchers sift through the noise of Reddit to identify high-intent leads and verify community trust.

The repo package slug is `reddit_profile_viewer`, but the current product identity in the app and website is `SubVetter`.

## What It Does

- **Audience Vetting**: Scan entire subreddits (r/SaaS, r/Crypto) to identify the most active and qualified members.
- **Lead Discovery**: Automatically extract a shortlist of high-intent "veteran" leads from community activity.
- **Deep Profile Scanning**: Snapshot a Reddit username and generate a full lead report dashboard.
- **Lead Watchlist**: Monitor high-value potential customers or competitors over time with dedicated tracking.
- **Communication Tone & Intent**: Analyze a user's communication style and "community fit" to inform outreach strategies.
- **Shareable Lead Reports**: Export profile summaries as professional PDFs.
- **Local Intelligence Cache**: All research is stored locally using Hive for instant offline access.

## Project Structure

```
lib/
├── main.dart
├── models/
│   └── reddit_models.dart      # Unified data models for Profiles & Audience Intel
├── screens/
│   ├── splash_page.dart        # Premium entry splash
│   ├── home_page.dart          # Search Entry & System Telemetry
│   ├── audience_page.dart      # [NEW] Subreddit Research & Lead Discovery
│   ├── watchlist_page.dart     # [NEW] Monitored Leads & High-Value Targets
│   ├── dashboard_page.dart     # Full Lead Qualification Report
│   ├── history_page.dart       # Local Intelligence History
│   └── settings_page.dart      # App Preferences
├── services/
│   ├── reddit_service.dart     # Parallel Multi-Source Data Engine
│   ├── cache_service.dart      # Persistent Hive storage & Telemetry
│   └── report_service.dart     # [NEW] Professional PDF PDF Generation
├── widgets/
│   └── navigation_shell.dart   # Dashboard Navigation Shell
└── theme/
    └── app_theme.dart          # Cyber-Dark B2B Theme
website/
├── index.html                  # Convering Landing Page (subvetter.online)
└── assets/                     # Branding assets and screenshots
```

## Tech Stack

- **Flutter** - High-performance cross-platform UI
- **Dart** - Fast programming language for intelligence gathering
- **Dio** - Resilient HTTP client with parallel request handling
- **Hive / Hive Flutter** - Ultra-fast local NoSQL database
- **Flutter Animate** - Micro-animations for a premium feel
- **Google Fonts (Inter & Space Grotesk)** - Modern B2B typography
- **PDF / Printing** - Professional report generation
- **Font Awesome Flutter** - Extensive iconography

## Branding & Identity

- **Product Name**: `SubVetter`
- **Domain**: `subvetter.online`
- **Tagline**: `Reddit Lead Qualification`
- **Package Slug**: `reddit_profile_viewer`

## Getting Started

### 1. Install dependencies

```bash
flutter pub get
```

### 2. Configure environment variables

Create a `.env` file in the project root.

Expected variables:

```env
REDDIT_CLIENT_ID=your_client_id_here
REDDIT_CLIENT_SECRET=your_client_secret_here
REDDIT_USER_AGENT=android:subvetter:v1.0.5 (by /u/Harshit1404005)
```

### 3. Run the app

```bash
flutter run -d windows  # Recommended for development
flutter run -d chrome   # For web testing
```

## Intelligence Data Engine

SubVetter uses a parallel fetch strategy to bypass standard profile limitations:
1. **Public Reddit API**: Real-time signals for visible profiles.
2. **Reddit Archive Proxy**: Deep archive retrieval for hidden or "ghost" profiles.
3. **Old Reddit Layer**: Bypasses certain UI-based rate limits and visual restrictions.

## Compliance

Use SubVetter responsibly. This tool is designed for **Market Research and Lead Qualification**. Always respect Reddit's Developer Terms and the privacy of individual community members.

## Status

**SubVetter v1.0.5** is in active development. Current focus is on **Deep Audience Intelligence** and **Automated Intent Detection**.
