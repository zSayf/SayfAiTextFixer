# 🅰 Sayf Text Fixer (All-in-One)  
> **Smart bilingual proofreading tool powered by Google Gemini AI**  
> ✨ Corrects spelling & grammar in **English** and **Arabic** with a single hotkey ✨  

---

## ⚡ Features
- 📝 **One Hotkey Fix** → Select any text and press `Ctrl+Alt+S` to instantly proofread.  
- 🌍 **Bilingual Support** → Works with **English** & **Arabic**, or auto-detects.  
- 🎨 **Dynamic Tray Icon** → Status is reflected:
  - ✅ Valid API Key  
  - ❌ Missing/Invalid API Key  
  - ⏳ Processing  
  - ⚠️ Error  
  - 📝 Ready  
- ⚙️ **Settings Panel** → Easily update:
  - API Key  
  - Language preference (en / ar / auto)  
- 📄 **Log Viewer** → Quick history of all corrections (`Ctrl+Alt+D`).  
- ☁️ **Gemini API Integration** → Uses the fastest `gemini-2.5-flash` model.  
- 📦 **Auto-Caches Custom Tray Icons** from GitHub → loads instantly, refreshes weekly.  

---

## 🎯 Hotkeys
| Shortcut | Action |
|----------|--------|
| `Ctrl+Alt+S` | Fix selected text |
| `Ctrl+Alt+D` | Open correction log |
| `Ctrl+Alt+M` | Open Settings dialog |
| `Esc` | Hide tooltip |

---

## 📥 Installation
1. **Install [AutoHotkey v2](https://www.autohotkey.com/)** (required).  
2. Download and Run `SayfTextFixer.ahk`. (Soon)
---

## 🖼️ Tray Icon Status
Your system tray shows the current status dynamically:

- ![Ready](https://raw.githubusercontent.com/zSayf/SayfAiTextFixer/main/ICONS/A-gray.ico) **Ready**  
- ![Valid](https://raw.githubusercontent.com/zSayf/SayfAiTextFixer/main/ICONS/A-green.ico) **API OK**  
- ![Missing](https://raw.githubusercontent.com/zSayf/SayfAiTextFixer/main/ICONS/A-red.ico) **API Missing/Invalid**  
- ![Processing](https://raw.githubusercontent.com/zSayf/SayfAiTextFixer/main/ICONS/A-yellow.ico) **Processing**  

(icons are cached automatically into your AppData folder)

---

## ⚙️ Settings Dialog
- 🌍 Choose **language** (Arabic / English / Auto).  
- 🔑 Enter or update your **Gemini API key**.  
- ✅ Validate API key instantly.  
- 💾 Save directly to config (`SayfTextFixer_config.ini` in AppData).

---

## 📂 File Locations
- Logs:  
  ```
  %AppData%\SayfTextFixer\SayfTextFixer_log.txt
  ```  
- Config:  
  ```
  %AppData%\SayfTextFixer\SayfTextFixer_config.ini
  ```
- Cached Icons:  
  ```
  %AppData%\SayfTextFixer\icons\A-*.ico
  ```

---

## 💡 Example Workflow
1. Select text anywhere (Word, Notepad, Browser, etc).  
2. Press **`Ctrl+Alt+S`**.  
3. Tray icon turns yellow (`⏳ Processing`).  
4. Corrected text **replaces your selection automatically**.  
5. Log is updated with **before/after analysis**.  

---

## 🤝 Contribution
Pull requests are welcome!  
If you’d like to add more features/languages, fork and PR.  

---

## 📜 License
MIT License © 2024 [@zSayf](https://github.com/zSayf)  

---

⭐ **Don’t forget to star the repo if you like it!**
```
