# 🅰 Sayf Text Fixer

[![AutoHotkey v2](https://img.shields.io/badge/AutoHotkey-v2.0%2B-blue.svg)](https://www.autohotkey.com/)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![GitHub release](https://img.shields.io/github/release/zSayf/SayfAiTextFixer.svg)](https://github.com/zSayf/SayfAiTextFixer/releases)
[![Platform](https://img.shields.io/badge/Platform-Windows-lightgrey.svg)](https://www.microsoft.com/windows)
[![GitHub stars](https://img.shields.io/github/stars/zSayf/SayfAiTextFixer.svg)](https://github.com/zSayf/SayfAiTextFixer/stargazers)

> **🌟 Smart bilingual proofreading tool powered by Google Gemini AI**  
> ✨ Corrects spelling & grammar in **English** and **Arabic** with a single hotkey ✨
## 🎥 See It In Action

### English & Arabic Text Correction
![Demo GIF](https://i.giphy.com/bG7bCw1k1wJUY9OtDY.webp)

### Individual Demos
![English Demo 1](https://i.giphy.com/REeVvRkVDFezA8r0Rr.webp)
![English Demo 2](https://i.giphy.com/gI1fhmSdiaQvymHnfI.webp)
![Arabic Demo](https://i.giphy.com/DjuPvo1hxQLuUI1TMo.webp)


## 🚀 What is Sayf Text Fixer?

**Sayf Text Fixer** is a lightweight desktop utility that brings AI-powered text correction to **any Windows application**. Select text anywhere and press a hotkey to instantly fix spelling and grammar errors using Google's Gemini AI.

### ✨ Core Features
- **📝 Universal Text Correction** → Works across all Windows applications
- **🌍 Bilingual AI Processing** → Native support for English & Arabic with auto-detection
- **⚡ One-Click Operation** → Single hotkey for instant text correction
- **🎨 Smart Status System** → Real-time feedback through dynamic tray icons
- **⚙️ Easy Configuration** → Simple setup and management interface
- **📄 Activity Tracking** → Comprehensive correction history and analytics

---

## 📦 Installation

### Prerequisites
1. **Windows 10/11** - Any modern Windows version
2. **[AutoHotkey v2.0+](https://www.autohotkey.com/download/ahk-v2.exe)** - Free scripting platform
3. **Google Gemini API Key** - [Get yours free](https://makersuite.google.com/app/apikey)
4. **Internet Connection** - Required for AI processing

### Quick Setup
1. **Download** the latest release from [Releases](https://github.com/zSayf/SayfAiTextFixer/releases) [Click Here For Direct Download](https://github.com/zSayf/SayfAiTextFixer/releases/download/v1.5.0/Sayf.Text.Fixer.All-in-One.ahk)
2. **Install** AutoHotkey v2.0+ if not already installed
3. **Run** the script file
4. **Configure** your API key when prompted
5. **Start using** with the configured hotkeys!

### Getting Your API Key
1. Visit [Google AI Studio](https://makersuite.google.com/app/apikey)
2. Sign in with your Google account
3. Create a new API key
4. Copy and paste into Sayf Text Fixer settings

---

## 🎯 How to Use

### Basic Operation
1. **Select text** in any app (Word, browser, etc.)
2. **Press `Ctrl+Alt+S`**
3. **Wait for processing** (yellow tray icon)
4. **See corrected text** replace your selection automatically

### Hotkeys
| Key | Action |
|-----|----------|
| `Ctrl+Alt+S` | Fix selected text |
| `Ctrl+Alt+D` | View correction log |
| `Ctrl+Alt+M` | Open settings |
| `Esc` | Hide tooltip |

### Tray Icon Guide
| Icon | Meaning |
|------|----------|
| <img src="https://raw.githubusercontent.com/zSayf/SayfAiTextFixer/main/ICONS/A-gray.ico" width="64"> | Ready to use |
| <img src="https://raw.githubusercontent.com/zSayf/SayfAiTextFixer/main/ICONS/A-green.ico" width="64"> | API key is valid |
| <img src="https://raw.githubusercontent.com/zSayf/SayfAiTextFixer/main/ICONS/A-red.ico" width="64"> | API key missing/invalid |
| <img src="https://raw.githubusercontent.com/zSayf/SayfAiTextFixer/main/ICONS/A-yellow.ico" width="64"> | Processing text |

---

## 📁 File Locations

All files are stored in your AppData folder:
```
%AppData%\SayfTextFixer\
├── SayfTextFixer_config.ini    # Your settings
├── SayfTextFixer_log.txt       # Correction history  
└── icons\                      # Tray icons
```

---

## 🔧 Support & Troubleshooting

## 🔧 Common Issues

### "API key not configured"
- **Fix**: Press `Ctrl+Alt+M` and enter your Gemini API key
- **Get key**: [Google AI Studio](https://makersuite.google.com/app/apikey)

### "No text selected"
- **Fix**: Make sure text is highlighted before pressing `Ctrl+Alt+S`

### Red tray icon (Invalid API)
- **Check**: API key is at least 10 characters
- **Test**: Use "Test API Key" button in settings

### Text not replacing
- **Try**: Different application (Notepad, Word)
- **Check**: Clipboard permissions

### Get Help
- **Documentation** - Check release notes for version-specific details
- **Report Issues** - [GitHub Issues](https://github.com/zSayf/SayfAiTextFixer/issues)
- **Feature Requests** - Open an issue with "Enhancement" label
- **Community** - Star the repository to show support!

---

## 🤝 Contributing

Want to help improve Sayf Text Fixer?

- 🐛 **Report bugs**: [GitHub Issues](https://github.com/zSayf/SayfAiTextFixer/issues)
- ✨ **Suggest features**: Open an issue with "Feature Request" label
- 💻 **Submit code**: Fork and create pull requests
- 🌍 **Add languages**: Help expand language support

### For Developers
- Uses **AutoHotkey v2.0+**
- Follows zero-error development patterns
- JSON-based logging system
- Self-healing configuration

---

## 📄 License

**MIT License** © 2024 [@zSayf](https://github.com/zSayf)

Free to use, modify, and distribute. See LICENSE file for details.

---

## 🙏 Acknowledgments

This project was inspired by and builds upon the excellent work of:

- **[ProofixAI](https://github.com/geek-updates/proofixai)** - Original concept and inspiration for AI-powered text correction
- **Google Gemini AI** - Advanced language processing capabilities
- **AutoHotkey Community** - Robust scripting platform and community support
- **Microsoft Windows** - Primary deployment platform

---

## 🙏 Support

- 🐛 **Issues**: [GitHub Issues](https://github.com/zSayf/SayfAiTextFixer/issues)
- 📧 **Contact**: [GitHub Profile](https://github.com/zSayf)

---

⭐ **If this tool helps you write better, please star the repository!** ⭐
