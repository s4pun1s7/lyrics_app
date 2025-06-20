# Lyrics App 🎶
A cross-platform Flutter app to search, view, and manage song lyrics with a beautiful, responsive UI.

---

## 🚀 Features
- Search for lyrics and album art by artist and song (with suggestions)
- Responsive, scrollable UI for all platforms (Web, Android, iOS, Desktop)
- Save, view, and delete your favorite lyrics
- Live settings: font, size, line height, text alignment, and text area width
- Real-time preview of style settings
- Dark mode toggle
- Source code and about section in-app
- Firebase authentication and cloud sync (if enabled)
- Modular, maintainable codebase
- Open-source and lightweight
- CORS proxy for lyrics API (web support)
- Error handling and user feedback (snackbars, dialogs)
- Modern, accessible design

## 🖼️ Screenshots
<!-- Add your screenshots here -->
| Search                                 | Lyrics                                 | Saved                                | Settings                                   |
| -------------------------------------- | -------------------------------------- | ------------------------------------ | ------------------------------------------ |
| ![Search](docs/screenshots/search.png) | ![Lyrics](docs/screenshots/lyrics.png) | ![Saved](docs/screenshots/saved.png) | ![Settings](docs/screenshots/settings.png) |

## 📦 Getting Started

To run this project locally:

```bash
# Clone the repo
git clone https://github.com/s4pun1s7/lyrics_app.git

# Navigate into the project
cd lyrics_app

# Get dependencies
flutter pub get

# Run the app (replace with your desired platform)
flutter run -d chrome
```

## 🖥️ Main Screens
- **Search:** Find lyrics by artist and song, with suggestions
- **Lyrics:** View lyrics with album art, save/unsave, and open source links
- **Saved:** Manage your saved lyrics
- **Settings:** Customize font, size, line height, alignment, and text area width with live preview

## ⚙️ Project Structure
```
├── android/        # Android native files
├── ios/            # iOS native files
├── lib/            # Main Flutter source code
│   ├── api/        # Lyrics, album art, and suggestions APIs
│   ├── models/     # Data models
│   ├── pages/      # App pages (search, lyrics, saved, settings, home)
│   ├── services/   # Firebase and other services
│   └── widgets/    # Modular UI widgets
├── linux/          # Linux support
├── macos/          # macOS support
├── web/            # Web support
├── windows/        # Windows support
├── test/           # Unit and widget tests
```

## 🛠 Tech Stack
- **Frontend:** Flutter (Dart)
- **Backend/Logic:** Dart, Firebase (optional)
- **Other Technologies:**
  - C++, CMake (native integrations)
  - Swift (iOS support)
  - HTML (for web deployment)

## 📝 Usage
- **Search:** Enter artist and song, get instant suggestions, and tap to search.
- **Lyrics:** View lyrics, album art, and save/unsave songs. Open source/Spotify links.
- **Saved:** Access and manage your saved lyrics.
- **Settings:** Adjust font, size, line height, alignment, and text area width. See live preview.
- **Dark Mode:** Toggle in settings.
- **Reset:** Restore all settings to defaults.

## 🤝 Contributing
Contributions are welcome! Please open issues or pull requests for bugs, features, or improvements.

1. Fork the repo
2. Create your feature branch (`git checkout -b feature/YourFeature`)
3. Commit your changes (`git commit -am 'Add new feature'`)
4. Push to the branch (`git push origin feature/YourFeature`)
5. Open a pull request

## 🙏 Credits & Acknowledgments
- Lyrics APIs: [lyrics.ovh](https://lyrics.ovh), [iTunes Search API](https://affiliate.itunes.apple.com/resources/documentation/itunes-store-web-service-search-api/)
- Flutter & Dart teams
- Open source contributors

## 📫 Contact & Support
- GitHub Issues: [github.com/s4pun1s7/lyrics_app/issues](https://github.com/s4pun1s7/lyrics_app/issues)
- Email: [martin.k4lchev@gmail.com](mailto:martin.k4lchev@gmail.com)

## 📄 License
This project is open source. See the [LICENSE](LICENSE) file for details.
