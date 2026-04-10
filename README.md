# RedIntel Insights 📊
### Deep Reddit Analytics & Audience Intelligence

**RedIntel** is a professional-grade Audience Intelligence platform designed to transform fragmented Reddit data into structured, actionable behavioral dossiers. Built for analysts, researchers, and community managers who require deep-profile visibility, demographic scoring, and high-fidelity reporting, all within a stunning, fluid UI experience.

---

## ⚡ Core Analytical Capabilities

### 1. Unified Sourcing Engine (Multi-Node Extraction)
RedIntel aggregates complex user history by utilizing a parallel data-fetch pipeline:
- **Proxy Intelligence**: Custom Cloudflare Worker infrastructure that dynamically aggregates and load-balances data nodes.
- **Archive Deep-Scan**: Direct integration with legacy historical archives to provide a complete picture of a user's historical engagement.
- **Dynamic Synthesizers**: Graceful fallback strategies that synthesize data from official API gateways when necessary.

### 2. Live Behavioral Synthesis
The engine performs real-time analytics without writing to disk (unless persistent history is requested):
- **Activity Intensity Mapping**: A dynamic histogram instantly calculates activity commitment and time-based engagement patterns over the past 30 days.
- **Sector Engagement**: Real-time percentage breakdowns of the communities and subreddits a user interacts with the most, clustered by interest.
- **Tone & Interaction Radar**: Automated analysis of sentiment, controversial engagement, and interaction tone to categorize community participation style.

### 3. Community Pulse Engine
A real-time macro-view of the platform's ecosystem:
- Automatically tracks **Trending Topics** and **Active Subreddits** globally.
- Interfaces directly with the Cloudflare Proxy to pool live network intelligence and trending research vectors.
- Live-updating global sentiment indices for market research.

### 4. Intelligence Dashboard (Premium UI)
Built with fluid animations and a modern Crystalline Glassmorphism aesthetic:
- **Reactive Data Timelines**: Instantly filter hundreds of posts and comments using the built-in audience research search engine.
- **Seamless Navigation**: Context-jump instantly between your global Research Logs to an in-depth profile Dashboard.
- **Persistent Preferences**: Localized Hive storage ensures UI and privacy toggles (like turning off local logging) survive app restarts.
- **Export Engine**: Generate agency-standard PDF analysis reports at the touch of a button.

---

## 🛠 Technical Stack
- **Framework**: Flutter (Cross-platform pure Dart implementation)
- **State & Persistence**: Hive (Lightning-fast NoSQL Binary Storage)
- **Networking**: Dio (Advanced HTTP Interceptors) & Custom Cloudflare Worker Proxies
- **Reporting**: PDF & Printing (Agency-grade research reporting)
- **Design System**: Flutter Animate (Fluid Dashboard HUD)

---

## 🚀 Getting Started

1. **Infrastructure Prep**: Deploy the RedIntel Cloudflare Worker proxy (`hg140400.workers.dev` pattern) for deep data processing and Community Pulse signals.
2. **Execution**:
   ```bash
   flutter pub get
   flutter run -d windows
   ```

---

## 🔒 Legal & Compliance
RedIntel is designed as a **Data Synthesis and Research Viewer** for public and archived information. It adheres to platform policies by providing an analytical view of publicly available open-source data. Use responsibly in accordance with digital research ethics.

---
**REDINTEL v1.0.4** | *Data-Driven Audience Research*
