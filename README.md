# Living Word 📖

A beautiful, feature-rich Bible reading app built with Flutter and Riverpod. Read, search, and study the Bible with an intuitive interface designed for both Android and iOS.

![Flutter](https://img.shields.io/badge/Flutter-3.0+-blue.svg)
![License](https://img.shields.io/badge/License-MIT-green.svg)
![Platform](https://img.shields.io/badge/Platform-Android%20%7C%20iOS-lightgrey.svg)

## ✨ Features

### Core Reading Experience

- **44 Bible Translations** - Access multiple translations including HCSB, KJV, NIV, ESV, NLT, and more
- **Swipe Navigation** - Swipe left/right to navigate between chapters
- **Pinch to Zoom** - Adjust font size with intuitive pinch gestures
- **Smart Search** - Search for verses, phrases, or Bible references
- **Beautiful UI** - Modern Material Design 3 with Light/Dark theme support

### Customization

- **Theme Options** - Light, Dark, or System default
- **Font Settings** - Adjust size, style, and line spacing
- **Reading Preferences** - Toggle verse numbers, chapter headings, footnotes
- **Reading Mode** - Distraction-free reading experience

### Notifications & Reminders (Coming Soon)

- Daily verse notifications
- Reading plan reminders
- Prayer reminders
- Customizable notification schedules

### Smart UI/UX

- **Adaptive Safe Areas** - Automatically detects Android navigation bar type
- **Floating Chapter Navigation** - Quick access to previous/next chapters
- **Responsive Design** - Optimized for phones and tablets

## 🚀 Getting Started

### Prerequisites

- Flutter SDK (3.0.0 or higher)
- Dart SDK (2.17.0 or higher)
- Android Studio / Xcode (for mobile development)

### Installation

1. **Clone the repository**

   ```bash
   git clone https://github.com/yourusername/living_word.git
   cd living_word
   ```

2. **Install dependencies**

   ```bash
   flutter pub get
   ```

3. **Run code generation** (for Freezed models)

   ```bash
   flutter pub run build_runner build --delete-conflicting-outputs
   ```

4. **Run the app**

   ```bash
   # For Android
   flutter run

   # For iOS
   flutter run -d ios

   # For macOS
   flutter run -d macos
   ```

## 🏗️ Project Structure

```
lib/
├── main.dart                      # App entry point
└── src/
    ├── data/                      # Static data
    │   └── bible_books.dart       # Bible books metadata
    ├── models/                    # Data models
    │   ├── bible_reference.dart
    │   ├── verse.dart
    │   ├── search_result.dart
    │   └── app_settings.dart
    ├── providers/                 # Riverpod providers
    │   ├── bible_providers.dart
    │   └── settings_providers.dart
    ├── repositories/              # Data repositories
    │   └── bible_repository.dart
    ├── services/                  # Business logic
    │   └── search_service.dart
    ├── screens/                   # UI screens
    │   ├── bible_home_screen.dart
    │   └── settings_screen.dart
    ├── widgets/                   # Reusable widgets
    │   ├── verse_list_widget.dart
    │   ├── bible_selector_dialog.dart
    │   ├── translation_selector_dialog.dart
    │   ├── navigation_controls.dart
    │   └── bible_search_bar.dart
    └── utils/                     # Utility classes
        └── navigation_utils.dart
```

## 🛠️ Built With

- **[Flutter](https://flutter.dev/)** - UI framework
- **[Riverpod](https://riverpod.dev/)** - State management
- **[Freezed](https://pub.dev/packages/freezed)** - Code generation for immutable models
- **[Shared Preferences](https://pub.dev/packages/shared_preferences)** - Local data persistence
- **[Android Nav Setting](https://pub.dev/packages/android_nav_setting)** - Navigation bar detection

## 🤝 Contributing

We welcome contributions from the community! Here's how you can help:

### Reporting Bugs

- Use the [issue tracker](https://github.com/yourusername/living_word/issues)
- Describe the bug and steps to reproduce
- Include screenshots if applicable

### Suggesting Features

- Open an issue with the "enhancement" label
- Describe the feature and its benefits
- Discuss implementation approaches

### Pull Requests

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/AmazingFeature`)
3. Make your changes
4. Run tests: `flutter test`
5. Ensure code follows Flutter style guide
6. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
7. Push to the branch (`git push origin feature/AmazingFeature`)
8. Open a Pull Request

### Code Style

- Follow [Effective Dart](https://dart.dev/guides/language/effective-dart) guidelines
- Use meaningful variable and function names
- Add comments for complex logic
- Write tests for new features

## 📝 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

```
MIT License

Copyright (c) 2025 Living Word Contributors

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
```

## 💝 Support the Project

If you find Living Word helpful, consider supporting its development:

- ⭐ Star this repository
- 🐛 Report bugs and suggest features
- 🔀 Submit pull requests
- 📢 Share with others

### Donations

Support ongoing development and hosting costs:

- **Buy Me a Coffee**: [buymeacoffee.com/livingword](https://buymeacoffee.com/livingword)
- **PayPal**: [paypal.me/livingword](https://paypal.me/livingword)
- **GitHub Sponsors**: Sponsor this project on GitHub

Every contribution helps maintain and improve Living Word!

## 👥 Contributors

Thanks to all the amazing people who have contributed to this project!

<!-- This section will be auto-generated -->
<a href="https://github.com/yourusername/living_word/graphs/contributors">
  <img src="https://contrib.rocks/image?repo=yourusername/living_word" />
</a>

## 📱 Screenshots

<!-- Add screenshots here -->

Coming soon!

## 🗺️ Roadmap

- [x] Core Bible reading functionality
- [x] Multiple translations
- [x] Search functionality
- [x] Theme customization
- [x] Pinch-to-zoom font control
- [ ] Reading plans
- [ ] Verse bookmarks and highlights
- [ ] Notes and annotations
- [ ] Audio Bible integration
- [ ] Cross-references
- [ ] Study tools (concordance, dictionary)
- [ ] Share verses
- [ ] Cloud sync

## 📞 Contact

- **Issues**: [GitHub Issues](https://github.com/yourusername/living_word/issues)
- **Email**: support@livingwordapp.com
- **Twitter**: [@LivingWordApp](https://twitter.com/livingwordapp)

## 🙏 Acknowledgments

- Bible translations provided by [Bible.org](https://bible.org/)
- Icons from [Material Design Icons](https://materialdesignicons.com/)
- Built with ❤️ by the Living Word community

---

**Made with Flutter 💙**
