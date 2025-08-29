# 🅰 Sayf Text Fixer (All-in-One)

[![AutoHotkey v2](https://img.shields.io/badge/AutoHotkey-v2.0%2B-blue.svg)](https://www.autohotkey.com/)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Version](https://img.shields.io/badge/Version-1.0-green.svg)](https://github.com/zSayf/SayfAiTextFixer/releases)
[![Platform](https://img.shields.io/badge/Platform-Windows-lightgrey.svg)](https://www.microsoft.com/windows)
[![GitHub release](https://img.shields.io/github/release/zSayf/SayfAiTextFixer.svg)](https://github.com/zSayf/SayfAiTextFixer/releases)
[![GitHub stars](https://img.shields.io/github/stars/zSayf/SayfAiTextFixer.svg)](https://github.com/zSayf/SayfAiTextFixer/stargazers)

> **🌟 Smart bilingual proofreading tool powered by Google Gemini AI**  
> ✨ Corrects spelling & grammar in **English** and **Arabic** with a single hotkey ✨

## 🚀 What is Sayf Text Fixer?

**Sayf Text Fixer** is a lightweight desktop utility that brings AI-powered text correction to **any Windows application**. Select text anywhere and press a hotkey to instantly fix spelling and grammar errors using Google's Gemini AI.

### ✨ Key Features
- **📝 One Hotkey Fix** → Select text and press `Ctrl+Alt+S` to instantly correct it
- **🌍 Bilingual Support** → Works with **English** & **Arabic**, or auto-detects language
- **🎨 Dynamic Tray Icon** → Shows real-time status (Ready/Processing/Error)
- **⚙️ Simple Settings** → Easy API key and language configuration
- **📄 Processing Log** → Track your corrections with detailed history
- **☁️ Gemini AI Powered** → Uses Google's fast `gemini-2.5-flash` model

---

## ⚡ Features

### 📝 Text Correction
- **Grammar Fixing**: Corrects spelling and grammar errors while preserving meaning
- **Smart Detection**: Automatically detects English or Arabic text
- **Universal Support**: Works in any Windows application (Word, Notepad, browsers, etc.)

### 🌍 Language Support
- **English**: Full grammar and spelling correction
- **Arabic**: Native Arabic text processing
- **Auto-Detect**: Automatically identifies language

### 🖥️ System Integration
- **One Hotkey**: Single `Ctrl+Alt+S` for instant correction
- **Tray Icon**: Real-time status indicator
- **Smart Clipboard**: Automatic text replacement

---

## 📦 Installation

### What You Need
1. **Windows 10/11**
2. **[AutoHotkey v2.0+](https://www.autohotkey.com/)** - Download and install first
3. **Google Gemini API Key** - [Get yours free here](https://makersuite.google.com/app/apikey)

### Quick Setup
1. Download `Sayf Text Fixer (All-in-One).ahk`
2. Right-click and select "Run"
3. Enter your API key when prompted
4. Start using with `Ctrl+Alt+S`!

### Getting Your API Key
1. Go to [Google AI Studio](https://makersuite.google.com/app/apikey)
2. Sign in with Google account
3. Click "Create API Key"
4. Copy and paste into Sayf Text Fixer

---

## 🎯 How to Use

### Basic Operation
1. **Select text** in any app (Word, browser, etc.)
2. **Press `Ctrl+Alt+S`**
3. **Wait for processing** (yellow tray icon)
4. **See corrected text** replace your selection automatically

### Hotkeys
| Key | Action |
|-----|---------|
| `Ctrl+Alt+S` | Fix selected text |
| `Ctrl+Alt+D` | View correction log |
| `Ctrl+Alt+M` | Open settings |
| `Esc` | Hide tooltip |

### Tray Icon Guide
| Icon | Meaning |
|------|---------|
| ![Gray](https://raw.githubusercontent.com/zSayf/SayfAiTextFixer/main/ICONS/A-gray.ico) | Ready to use |
| ![Green](https://raw.githubusercontent.com/zSayf/SayfAiTextFixer/main/ICONS/A-green.ico) | API key is valid |
| ![Red](https://raw.githubusercontent.com/zSayf/SayfAiTextFixer/main/ICONS/A-red.ico) | API key missing/invalid |
| ![Yellow](https://raw.githubusercontent.com/zSayf/SayfAiTextFixer/main/ICONS/A-yellow.ico) | Processing text |

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
