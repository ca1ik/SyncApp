<p align="center">
  <img src="https://img.shields.io/badge/Flutter-3.3+-02569B?style=for-the-badge&logo=flutter&logoColor=white" alt="Flutter"/>
  <img src="https://img.shields.io/badge/Dart-3.3+-0175C2?style=for-the-badge&logo=dart&logoColor=white" alt="Dart"/>
  <img src="https://img.shields.io/badge/BLoC-8.1-blueviolet?style=for-the-badge" alt="BLoC"/>
  <img src="https://img.shields.io/badge/Platform-Android%20%7C%20iOS%20%7C%20Web%20%7C%20Windows%20%7C%20macOS%20%7C%20Linux-blue?style=for-the-badge" alt="Platform"/>
  <img src="https://img.shields.io/badge/License-Private-red?style=for-the-badge" alt="License"/>
</p>

# 💕 Sync — Neuro-Linguistic Crisis Management

> **A real-time emotion synchronization platform for couples.**
>
> Sync is a comprehensive Flutter application designed to strengthen emotional communication between partners, provide instant support during crisis moments, and improve relationship quality through AI-powered insights.

---

## 📋 Table of Contents

- [Overview](#-overview)
- [Key Features](#-key-features)
- [Architecture & Tech Stack](#️-architecture--tech-stack)
- [Project Structure](#-project-structure)
- [Feature Details](#-feature-details)
- [Data Models](#-data-models)
- [Theme System](#-theme-system)
- [Freemium Model](#-freemium-model-free-vs-pro)
- [Packages Used](#-packages-used)
- [Setup & Running](#-setup--running)

---

## 🌟 Overview

**Sync** is a mobile application that lets couples share their emotional states with a single tap, measures and analyzes relationship quality with AI, and strengthens their bond through fun interactive games.

### Core Philosophy

| Problem | Sync's Solution |
|---------|----------------|
| Unable to express feelings during crisis | **8 emotional signals** — one-tap communication |
| Not knowing how your partner feels | **Real-time mood streams** — instant synchronization |
| Recurring relationship problems | **AI trigger reports** — pattern detection |
| Emotional burnout | **Breathing exercises** — stress management |
| Monotony in relationship | **10 couple games** — playful bonding |

---

## 🚀 Key Features

### 🎯 Mood Sync Engine
- **8 Emotional Signals**: 🤗 Need Hug · 🤫 Need Silence · 🌙 Need Space · 💬 Need Talk · 🔋 Exhausted · ✨ Happy · 🫂 Anxious · 😊 Neutral
- **Energy Level** (0–100): Physical and mental energy measurement
- **Tolerance Level** (0–100): Emotional patience threshold
- **Real-time streams** for partner mood updates
- **Privacy control**: Each mood entry can be shared or kept private

### 🤖 AI Assistant
- **Micro-Advice Engine**: Instant, actionable suggestions based on current mood state
- **Trigger Report**: Weekly relationship analysis, conflict risk score (0.0–1.0), 3 recommendations
- **Relationship Coach** 💕: Guidance on communication, trust, conflict resolution, and romance
- **Astrology Assistant** 🔮: Zodiac compatibility, planetary transits, birth chart interpretations
- **Offline Mode**: All AI features have local fallbacks — works without internet

### 🧘 Breathing Exercises
- **Box Breathing** 📦: 4-4-4-4 second cycle — for crisis moments
- **4-7-8 Calming** 🌙: Pre-sleep relaxation
- **Energizing** ⚡: 2-2 quick breathing cycle
- **Couple Sync** 💞: 5-3-5-2 breathing together exercise
- Visual breathing circle animation, haptic feedback, phase transition vibration

### 🎮 Games Hub (10 Couple Games)
| Game | Type | Access |
|------|------|--------|
| 🔢 Count Trap | Number guessing | Free |
| 🎭 Truth or Dare | Classic party game | Free |
| ⚖️ Would You Rather | Dilemma discussion | Free |
| 🧠 Know Me Quiz | Knowledge quiz | PRO |
| 😤 Trip Meter | Patience challenge | PRO |
| ✍️ Finish the Sentence | Romantic completion | PRO |
| 🎯 Emoji Guess | Emotional communication | PRO |
| 🗺️ Love Map | Relationship memories | PRO |
| 🔐 Secret Message | Encrypted love letters | PRO |
| 💞 Compatibility Test | Match percentage | PRO |

### 📊 Dashboard & Analytics
- **Relationship Score**: Overall relationship health via 0–100 algorithm
- **Mood Distribution Chart**: Pie chart of signal usage ratios
- **Energy & Tolerance Trend**: Time-series line charts (PRO)
- **Mood History**: Detailed list of last 50 entries

### 🏆 Achievement System
**14 unique achievements** for gamification:
- 🔥 Streak achievements: 3, 7, 14, 30 consecutive days
- 📊 Milestones: First mood, 10th mood, 50th mood
- 🤝 Social: Partner linked
- 🧠 Analysis: First report, mood variety
- 🌙 Patterns: Night owl, early bird, weekend warrior, consistent couple

### ❓ Q&A System
- **Ask**: Write custom questions for your partner (10 suggestions for inspiration)
- **Answer**: Respond to incoming questions, earn points
- **History**: View all Q&A conversations
- Star rating (1–5) with multiplier point system

---

## 🏗️ Architecture & Tech Stack

### Design Pattern: Clean Architecture

```
┌─────────────────────────────────────────────┐
│              PRESENTATION LAYER              │
│     Pages · Widgets · BLoC · CUBIT           │
├─────────────────────────────────────────────┤
│                DATA LAYER                    │
│   Repositories · Services · Models           │
├─────────────────────────────────────────────┤
│              CORE LAYER                      │
│  DI · Router · Theme · Constants · Widgets   │
├─────────────────────────────────────────────┤
│           LOCAL PERSISTENCE                  │
│         SharedPreferences (JSON)             │
└─────────────────────────────────────────────┘
```

### State Management Strategy

| Approach | Use Case | Classes |
|----------|----------|---------|
| **BLoC** | Complex business logic | `AuthBloc`, `SyncEngineBloc` |
| **CUBIT** | Simple state management | `PartnerMoodCubit`, `SubscriptionCubit` |
| **Provider** | Theme switching | `AppThemeProvider` |
| **GetX** | Routing & navigation | `GetMaterialApp`, `GetPages` |

### Data Flow

```
UI (Widget) ──reads/listens──▶ BLoC / CUBIT
                                    │
                                 calls
                                    ▼
                              Repository
                                    │
                             persists/reads
                                    ▼
                         SharedPreferences (JSON)
```

### Dependency Injection (DI)
- **GetIt** service locator pattern
- All services, repositories, BLoCs, and CUBITs registered at app startup
- Stateful objects (BLoCs) → Factory
- Singleton services (Notification, Logger) → Singleton

---

## 📁 Project Structure

```
lib/
├── main.dart                          # Application entry point
├── core/
│   ├── constants/
│   │   └── app_constants.dart         # SharedPreferences keys, constants
│   ├── di/
│   │   └── injection.dart             # GetIt dependency injection setup
│   ├── router/
│   │   └── app_router.dart            # GetX route definitions (12 pages)
│   ├── services/
│   │   └── native_bridge_service.dart  # Android/iOS native channel bridge
│   ├── theme/
│   │   ├── app_theme.dart             # 9 theme definitions & gradient system
│   │   └── theme_provider.dart        # ChangeNotifier theme manager
│   └── widgets/
│       └── romantic_background.dart    # Animated couple silhouette & hearts
├── data/
│   ├── models/
│   │   ├── user_model.dart            # User profile
│   │   ├── mood_log_model.dart        # Mood entry & MoodSignal enum
│   │   ├── game_model.dart            # Game types, scores, couple points
│   │   ├── achievement_model.dart     # 14 achievement definitions
│   │   ├── streak_model.dart          # Streak tracking
│   │   └── trigger_report_model.dart  # AI trigger report
│   ├── repositories/
│   │   ├── auth_repository.dart       # Authentication & partner linking
│   │   ├── mood_repository.dart       # Mood CRUD & streams
│   │   ├── games_repository.dart      # Game scores, question bank, points
│   │   └── gamification_repository.dart # Achievement & streak management
│   └── services/
│       ├── ai_api_client.dart         # AI micro-advice & trigger reports
│       ├── ai_assistant_service.dart  # Local chatbot (Relationship Coach & Astrology)
│       └── notification_service.dart  # Local notification management
└── features/
    ├── auth/                          # Login, registration, partner linking
    ├── sync_engine/                   # Mood synchronization engine
    ├── home/                          # Home page — mood submission
    ├── dashboard/                     # Analytics & charts
    ├── breathing/                     # 4 breathing exercises
    ├── games/                         # 10 games + Q&A system
    ├── ai_assistant/                  # Dual AI chatbot
    ├── achievements/                  # Achievements & streak page
    ├── settings/                      # Theme, account, plan management
    ├── subscription/                  # PRO subscription system
    └── onboarding/                    # 5-screen introduction
```

---

## 🔮 Feature Details

### 🏠 Home Page
The heart of the app — mood submission happens here:
- **Dual Sliders**: Adjust energy and tolerance levels (0–100)
- **8-Signal Selector**: One-tap mood broadcasting
- **Share Toggle**: Share with partner / keep private
- **Optional Note**: Additional context field
- **Relationship Score**: Real-time percentage calculated from historical data
- **Daily Quote**: Rotating display from 10 motivational quotes
- **Streak Indicator**: 🔥 + consecutive day count
- **AI Micro-Advice**: Instant suggestion after mood submission
- **Success Animation**: 2-second confirmation with haptic feedback
- **Partner Mood Display**: Shows linked partner's latest signal
- **Premium Limit**: Free users limited to 5 moods per day

### 🔐 Authentication
- **Email registration & login** (local, no Firebase)
- **Partner linking**: Email-based matching, automatic `coupleId` generation
- **Session management**: Persistent sessions via SharedPreferences
- **Smart routing**: Onboarding → Login → Partner Link → Home

### 📱 Onboarding (5 Screens)
1. **Sync Brand** 💕 — Emotional coordination introduction
2. **One-Touch Bridge** 🤝 — 8-signal system explanation
3. **Micro Advice** 💡 — AI-powered real-time suggestions
4. **Breathing & Calm** 🧘 — Stress management techniques
5. **Predict & Prevent** 📊 — Pattern recognition and trigger alerts

Animated page transitions, gradient backgrounds, skip button

### ⚙️ Settings Page
- **Account & streak summary** welcome banner
- **Quick action buttons**: Breathing, Achievements, PRO
- **Theme selector**: Horizontal scroll picker across 9 themes
- **Plan status**: Free/PRO comparison table
- **Logout** button

---

## 📦 Data Models

### UserModel
```dart
uid          : String     // Unique user identifier
email        : String     // Email address
displayName  : String?    // Display name
photoUrl     : String?    // Profile photo URL
partnerUid   : String?    // Linked partner identifier
coupleId     : String?    // Shared couple identifier
isPro        : bool       // PRO subscription status
fcmToken     : String     // Notification token
createdAt    : DateTime?  // Registration date
lastActiveAt : DateTime?  // Last activity timestamp
```

### MoodLogModel
```dart
signal              : MoodSignal   // 8 emotional signal enum
energyLevel         : int          // 0–100 energy level
toleranceLevel      : int          // 0–100 tolerance level
note                : String?      // Optional description
isSharedWithPartner : bool         // Partner sharing status
timestamp           : DateTime     // Entry timestamp
```

### TriggerReportModel (AI Report)
```dart
summaryText       : String             // Overall summary
patterns          : List<TriggerPattern> // Detected patterns
recommendations   : List<String>        // 3 main recommendations
conflictRiskScore : double             // 0.0–1.0 conflict risk
periodStart/End   : DateTime            // Analysis period
```

### StreakModel
```dart
currentStreak : int                // Current consecutive day streak
longestStreak : int                // All-time longest streak
totalEntries  : int                // Total entry count
weeklyEntries : Map<String, int>   // Weekly distribution
isActiveToday : bool               // Active today (computed)
```

---

## 🎨 Theme System

**9 carefully crafted color palettes**, each tailored to relationship moods:

| Theme | Character | Color Tone |
|-------|-----------|------------|
| 🌅 **Calm Sunset** | Default, warm | Orange / Pink gradient |
| 🌊 **Ocean Breeze** | Calming | Blue / Teal |
| 🌙 **Midnight Soft** | Night mode | Purple / Dark |
| 🌿 **Morning Dew** | Fresh, energizing | Green / Yellow |
| 🌹 **Rose Petal** | Romantic | Pink tones |
| 💜 **Lavender Dream** | Peaceful | Lavender / Purple |
| 🌸 **Cherry Blossom** | Elegant, delicate | Light pink |
| ☀️ **Golden Hour** | Warm, nostalgic | Gold / Amber |
| ❄️ **Arctic Aurora** | Cool, modern | Northern lights palette |

- **Gradient system** custom-defined for each theme
- **Instant switching** with smooth transition animations
- **Persistent storage**: Selected theme saved to SharedPreferences

---

## 💎 Freemium Model (Free vs PRO)

| Feature | 🆓 Free | 👑 PRO |
|---------|---------|--------|
| Mood submissions | 5 / day | ♾️ Unlimited |
| Partner linking | ✅ | ✅ |
| Breathing exercises | 1 technique (Box) | All 4 techniques |
| Games | 3 games | 10 games |
| Q&A System | ✅ | ✅ |
| AI advice | Basic | Advanced |
| Dashboard | Basic | Full analytics |
| Mood history | Last 10 | Unlimited |
| Achievements | 8 basic | 14 (all) |
| Trigger reports | ❌ | ✅ |
| Couple breath sync | ❌ | ✅ |
| Theme selection | 9 themes | 9 themes |

**Subscription management**: `SubscriptionCubit` with daily limit tracking, automatic midnight reset, SharedPreferences persistence.

---

## 📚 Packages Used

### State Management
| Package | Version | Purpose |
|---------|---------|---------|
| `flutter_bloc` | ^8.1.6 | BLoC & CUBIT pattern |
| `get` | ^4.6.6 | Routing, navigation |
| `provider` | ^6.1.2 | Theme state management |
| `equatable` | ^2.0.5 | Value equality comparison |

### Networking & AI
| Package | Version | Purpose |
|---------|---------|---------|
| `dio` | ^5.7.0 | HTTP client (AI API) |
| `pretty_dio_logger` | ^1.4.0 | API request/response logging |

### Local Storage
| Package | Version | Purpose |
|---------|---------|---------|
| `shared_preferences` | ^2.3.3 | All data persistence (JSON) |

### UI & Theming
| Package | Version | Purpose |
|---------|---------|---------|
| `flutter_animate` | ^4.5.0 | Micro-interaction animations |
| `fl_chart` | ^0.69.0 | Pie & line charts |
| `google_fonts` | ^6.2.1 | Typography management |
| `gap` | ^3.0.1 | Consistent spacing |

### Utilities & Infrastructure
| Package | Version | Purpose |
|---------|---------|---------|
| `get_it` | ^8.0.2 | Dependency injection (service locator) |
| `json_annotation` | ^4.9.0 | JSON serialization |
| `intl` | ^0.19.0 | Date/time formatting |
| `logger` | ^2.4.0 | Structured logging |
| `uuid` | ^4.5.1 | Unique ID generation |
| `flutter_local_notifications` | ^18.0.1 | Local notifications |

### Development & Testing
| Package | Version | Purpose |
|---------|---------|---------|
| `mockito` | ^5.4.4 | Mock objects |
| `bloc_test` | ^9.1.7 | BLoC unit tests |
| `build_runner` | ^2.4.13 | Code generation |
| `flutter_lints` | ^6.0.0 | Static analysis rules |

---

## 🔌 Native Integrations

### Platform Channels (MethodChannel)
```
com.example.sync_app/native_bridge
  ├── updateWidgetSignal(signal, emoji)  → Android home widget update
  └── triggerCalmMode()                  → Launch native meditation mode

com.example.sync_app/home_widget
  └── Display latest mood signal on Android home screen
```

### Notification Channels
| Channel | Purpose |
|---------|---------|
| `partner_mood_channel` | Partner signal notifications |
| `sync_general_channel` | General app notifications |
| `micro_advice_channel` | AI advice notifications (big-text) |

---

## 💾 Local Data Persistence

All data is stored as JSON in **SharedPreferences** — no backend required:

```
sync_current_user        → Active user profile
sync_users_db            → All registered users
sync_mood_logs           → Mood entry list
sync_couple_points       → Couple points & bond level
sync_game_scores         → Game scores (last 100)
sync_couple_questions    → Q&A history
sync_streak_data         → Streak tracking data
sync_achievements        → Unlocked achievements
selected_theme           → Selected theme
sync_is_pro              → Subscription status
sync_daily_mood_count    → Daily mood counter
sync_last_reset_date     → Last reset date
```

---

## 🛠️ Setup & Running

### Requirements
- Flutter SDK `>=3.3.0`
- Dart SDK `>=3.3.0`
- Android Studio or VS Code
- Android emulator / iOS simulator / physical device

### Steps

```bash
# 1. Clone the repo
git clone https://github.com/user/SyncApp.git
cd SyncApp/sync_app

# 2. Install dependencies
flutter pub get

# 3. Analyze code
flutter analyze

# 4. Run the app
flutter run
```

### Opening in Android Studio
1. Open Android Studio → select `Open`
2. Choose the `sync_app` root folder (**do not open the android subfolder alone**)
3. Install Flutter and Dart plugins if not already installed
4. Wait for Gradle synchronization to complete
5. Select emulator or physical device → `Run` (Shift+F10)

### Running via Windows PowerShell

```powershell
$env:PATH = 'C:\Users\user\flutter_sdk\bin;' + $env:PATH
flutter pub get
flutter analyze
flutter run
```

---

## 🧪 Testing

```bash
# Run all tests
flutter test

# Run a specific test file
flutter test test/sync_engine_bloc_test.dart
flutter test test/stress_prediction_test.dart
```

Available test files:
- `sync_engine_bloc_test.dart` — Sync engine BLoC tests
- `stress_prediction_test.dart` — AI/pattern prediction tests
- `widget_test.dart` — Widget unit tests

---

## 🎯 Technical Highlights

- **🔒 Offline-First**: All features work without internet — no backend required
- **💾 Persistent State**: All data survives app restart
- **⚡ Real-Time Sync**: Mood streams update instantly
- **🤖 Fallback AI**: All AI features have offline local implementations
- **🏆 Gamification**: 14-achievement system + bond level progression
- **💕 Couple-Centric**: All content designed for paired thinking and interaction
- **🎨 9 Theme Palettes**: Romantic, calming, and modern color options
- **📱 6 Platforms**: Android, iOS, Web, Windows, macOS, Linux support
- **🔗 Native Bridge**: Android home widget and native meditation mode integration
- **🇹🇷 Turkish UI**: Fully localized Turkish interface and content

---

<p align="center">
  <b>Sync</b> — Where emotions synchronize. 💕
</p>
