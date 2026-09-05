# 🎴 iSueca

> The classic Portuguese trick-taking card game Sueca, natively reimagined for iOS with SwiftUI.

[Report Bug](https://github.com/VidiPT89/iSueca/issues) · [Request Feature](https://github.com/VidiPT89/iSueca/issues)

## ✨ Features

- ✅ Full official Sueca rules — 40-card deck, 4 players in 2 partnerships, follow-suit and mandatory-cut logic
- ✅ 1 human player + 3 bot opponents, with 3 selectable AI difficulty levels (Easy, Medium, Hard)
- ✅ Card-counting bot on Hard difficulty — tracks played cards to spot master cards and safe cuts
- ✅ Smooth, native SwiftUI animations — dealing, card play, trick collection and score count-up
- ✅ Haptic feedback on card play and illegal-move attempts
- ✅ Live scoreboard with visible trump card and turn indicator
- ✅ Runtime language switch — Português (PT-PT) and English, independent of system locale
- ✅ Dark mode, Light mode, and System mode
- ✅ Custom color identity inspired by [ividi.dev](https://ividi.dev/) — burnt orange, amber and near-black
- ✅ In-app rules reference and match statistics

## 🛠️ Tech Stack

| Category    | Technology            |
|-------------|------------------------|
| Language    | Swift 5.9+              |
| UI          | SwiftUI (iOS 16+)        |
| Architecture| MVVM                     |
| Project     | XcodeGen                 |

## 🚀 Quick Start

**Prerequisites**
- Xcode 15+
- iOS 16+ simulator or device

**Steps**

```bash
git clone https://github.com/VidiPT89/iSueca.git
cd iSueca
open iSueca.xcodeproj
```

Select the `iSueca` scheme and run on a simulator or device.

## 📖 Usage

Launch the app, tap Play, and take on 3 bot opponents in a full hand of Sueca. Your partner sits opposite
you; win tricks together to pass 60 of the 120 points in play. Adjust bot difficulty and speed, switch
language and appearance, and review the rules at any time from Settings and the main menu.

## 🧪 Testing

Build and run the `iSueca` scheme in Xcode (`⌘R`), or verify the project compiles via:

```bash
xcodebuild -project iSueca.xcodeproj -scheme iSueca -destination 'generic/platform=iOS Simulator' build
```

## 📄 License

Distributed under the MIT License. See [LICENSE](LICENSE) for details.

## 👨‍💻 Author

**David Arsénio Martins**

🌐 Website: [ividi.dev](https://ividi.dev/)
🐙 GitHub: [@VidiPT89](https://github.com/VidiPT89/)

## 🤝 Contributing

Contributions, issues and feature requests are welcome. Feel free to check the [issues page](https://github.com/VidiPT89/iSueca/issues).

---

<p align="center">Developed by <a href="https://ividi.dev">David Arsénio Martins</a></p>
<p align="center">If you like this project, consider giving it a ⭐</p>
