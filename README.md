<h1 align="center">
  🌍 Travel Hub
</h1>

<p align="center">
  <b>Your smart travel companion for Egypt</b><br/>
  A Flutter mobile application that helps travelers discover hotels, landmarks, and navigate Egypt with the power of AI.
</p>

<p align="center">
  <img src="https://img.shields.io/badge/Flutter-3.x-blue?logo=flutter" />
  <img src="https://img.shields.io/badge/Dart-3.9-blue?logo=dart" />
  <img src="https://img.shields.io/badge/Firebase-Backend-orange?logo=firebase" />
  <img src="https://img.shields.io/badge/State%20Management-BLoC-purple" />
  <img src="https://img.shields.io/badge/Platform-Android%20%7C%20iOS-green" />
</p>

---

## 📱 About the App

**Travel Hub** is a full-featured travel assistant mobile app built with Flutter. It is designed to help users explore Egypt's hotels and famous landmarks, book hotel rooms, navigate via an interactive map, and identify places using an AI-powered camera feature.

The app supports both **English** and **Arabic** languages and includes **Light / Dark mode** theming.

---

## ✨ Features

| Feature | Description |
|---|---|
| 🔐 **Authentication** | Email/password sign-up & login, Google Sign-In, Forgot password & reset via email |
| 🏨 **Hotels** | Browse Egyptian hotels, view details (description, facilities, price/night, stars), add to favorites, and book |
| 🗿 **Landmarks** | Explore famous Egyptian landmarks with rich details, image carousels, and favorites support |
| 🗺️ **Interactive Map** | Full-screen Google Maps integration with geocoding & geolocator support |
| 🤖 **AI Camera** | Take or pick a photo of a landmark — the AI identifies it and returns a Wikipedia summary in English & Arabic, with text-to-speech playback |
| ❤️ **Favorites** | Save favorite hotels and landmarks, synced to Firestore per user |
| 🌐 **Localization** | Full Arabic and English support (easy_localization) |
| 🌙 **Dark Mode** | System-wide theme toggle powered by ThemeCubit, persisted across sessions |
| 👤 **Profile** | User profile with a customizable profile picture (saved locally as Base64) |
| ⚙️ **Settings** | Theme toggle, language switch, Help, Privacy Policy, and About screens |

---

## 🏗️ Project Architecture

The project follows a **Feature-First Clean Architecture** pattern:

```
lib/
├── core/                        # Shared utilities, theme, routing, services
│   ├── cubit/                   # ThemeCubit (global dark mode state)
│   ├── services/                # AuthService
│   └── utils/                   # AppRouter (go_router), AppTheme, DeepLinkListener
│
├── features/                    # Standalone features (no bottom nav)
│   ├── auth/
│   │   ├── login/               # Login screen, form, custom fields, Google Sign-In
│   │   ├── register/            # Register screen and form
│   │   ├── forget_password/     # Forgot password flow
│   │   └── reset/               # Reset password (deep link handler)
│   ├── ai_camera/               # AI landmark recognition (image → API → Wikipedia summary + TTS)
│   ├── splash/                  # Splash screen
│   └── welcome/                 # Onboarding welcome screen
│
├── navigation/                  # Bottom nav features (inside MainScreen)
│   ├── home/                    # Home screen with quick-access buttons & attractions
│   ├── hotels/                  # Hotels list, details, booking
│   ├── land_mark/               # Landmarks list, details, image carousel
│   ├── maps/                    # Full-screen Google Map
│   ├── favorites/               # Hotels & Landmarks favorites (Firestore-synced)
│   └── setting/                 # Settings, Help, Privacy, About
│
├── main.dart                    # App entry point (Firebase init, localization)
├── my_app.dart                  # Root widget (Auth state listener, BLoC providers)
└── constant.dart                # App-wide color constants & gradients
```

---

## 🛠️ Tech Stack

| Layer | Technology |
|---|---|
| **Framework** | Flutter (Dart 3.9+) |
| **State Management** | flutter_bloc (BLoC / Cubit) |
| **Navigation** | go_router |
| **Backend** | Firebase (Auth, Firestore, Storage, Functions) |
| **Maps** | google_maps_flutter, geolocator, geocoding |
| **AI Camera** | Custom Python REST API + Wikipedia API |
| **Text-to-Speech** | flutter_tts |
| **Localization** | easy_localization (EN / AR) |
| **Image** | image_picker, cached_network_image |
| **Deep Links** | app_links |
| **UI Utilities** | flutter_screenutil, flutter_svg, carousel_slider |
| **Local Storage** | shared_preferences |

---

## 🤖 AI Camera — How It Works

1. User takes a photo (camera or gallery) from the **Home** screen.
2. The image is sent via `multipart/form-data` POST to a Python backend hosted on `ngrok`.
3. The backend runs an image classification model, then fetches a **Wikipedia** summary for the identified landmark in both English and Arabic.
4. The result is displayed to the user with an option to **listen** via Text-to-Speech.

> **Note:** The AI backend URL is configured in `lib/features/ai_camera/service/api_service.dart`.  
> You need to run your own backend or update the URL to point to an active server.

---

## 🚀 Getting Started

### Prerequisites

- Flutter SDK `^3.9.0`
- Dart SDK `^3.9.0`
- Android Studio / VS Code
- A Firebase project configured for Android & iOS
- Google Maps API Key

### Installation

1. **Clone the repository:**
   ```bash
   git clone https://github.com/YOUR_USERNAME/travel-hub.git
   cd travel-hub
   ```

2. **Install dependencies:**
   ```bash
   flutter pub get
   ```

3. **Firebase Setup:**
   - Create a Firebase project at [console.firebase.google.com](https://console.firebase.google.com)
   - Enable **Authentication** (Email/Password + Google)
   - Enable **Cloud Firestore**
   - Enable **Firebase Storage**
   - Download `google-services.json` → place it in `android/app/`
   - Run `flutterfire configure` to regenerate `lib/firebase_options.dart`

4. **Google Maps API Key:**
   - Obtain an API key from [Google Cloud Console](https://console.cloud.google.com)
   - Add it to `android/app/src/main/AndroidManifest.xml`:
     ```xml
     <meta-data
       android:name="com.google.android.geo.API_KEY"
       android:value="YOUR_GOOGLE_MAPS_API_KEY"/>
     ```

5. **AI Backend:**
   - Update `baseUrl` in `lib/features/ai_camera/service/api_service.dart` with your active backend URL.

6. **Run the app:**
   ```bash
   flutter run
   ```

---

## 🔒 Security & Configuration

> **⚠️ Important:** The following sensitive files are **excluded from version control** via `.gitignore` and must be set up manually:

| File | Reason |
|---|---|
| `android/app/google-services.json` | Firebase Android config (contains API keys) |
| `ios/Runner/GoogleService-Info.plist` | Firebase iOS config |
| `lib/firebase_options.dart` | Generated Firebase options — regenerate with `flutterfire configure` |

Never commit these files to a public repository.

---

## 📦 Key Dependencies

```yaml
flutter_bloc: ^9.1.1        # State management
go_router: ^14.2.8          # Declarative navigation
firebase_core: ^3.13.1      # Firebase core
firebase_auth: ^5.5.4       # Authentication
cloud_firestore: ^5.6.8     # Database
google_maps_flutter: ^2.14.0 # Maps
geolocator: ^14.0.2         # GPS location
geocoding: ^4.0.0           # Address from coordinates
easy_localization: ^3.0.8   # AR/EN localization
flutter_tts: ^4.2.3         # Text-to-speech
image_picker: ^1.1.2        # Camera & gallery
carousel_slider: ^5.1.1     # Image carousels
cached_network_image: ^3.4.1 # Cached images
flutter_screenutil: ^5.9.3  # Responsive UI
app_links: ^6.3.0           # Deep link handling
```

---

## 🗺️ App Navigation Flow

```
Splash Screen
    └── Welcome Screen
            ├── Login Screen
            │       ├── Forgot Password → Reset Password
            │       └── Register Screen
            └── Main Screen (Bottom Navigation)
                    ├── 🏠 Home  →  AI Camera View
                    ├── 🏨 Hotels → Hotel Details → Booking
                    ├── 🗿 Landmarks → Landmark Details
                    ├── 🗺️ Map
                    └── ⚙️ Settings → Help / Privacy / About
```

---

## 👥 Team

This project was developed as a **Final Year College Project**.

---

## 📄 License

This project is for educational purposes. All rights reserved © 2025 Travel Hub Team.
