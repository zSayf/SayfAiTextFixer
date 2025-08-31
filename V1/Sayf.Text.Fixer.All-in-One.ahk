/*
================================================================================
                        Sayf Text Fixer (All-in-One) v1.5.0
                       Smart Bilingual Text Correction Tool
================================================================================

📝 DESCRIPTION:
   AI-powered text correction utility for Windows applications using Google 
   Gemini AI. Supports English and Arabic with automatic language detection.

👨‍💻 AUTHOR & CREDITS:
   • Developer: Sayf (@zSayf)
   • GitHub: https://github.com/zSayf/SayfAiTextFixer
   • Inspired by: ProofixAI (https://github.com/geek-updates/proofixai)
   • JSON Library: cJson v2.1.0 by Philip Taylor (@G33kDude)
     - GitHub: https://github.com/G33kDude/cJson.ahk
     - Copyright (c) 2023 Philip Taylor

📅 VERSION HISTORY:
   v1.5.0 (2025) - Initial release with bilingual support
   
📄 LICENSE:
   MIT License - Free to use, modify, and distribute
   
⚙️ REQUIREMENTS:
   • AutoHotkey v2.0+
   • Windows 10/11
   • Google Gemini API Key
   • Internet connection

🎯 FEATURES:
   • Single hotkey text correction (Ctrl+Alt+S)
   • Bilingual support (English/Arabic)
   • Dynamic tray icon status
   • Professional JSON logging
   • Self-healing configuration
   • Real-time API validation

📧 SUPPORT:
   Issues & Features: https://github.com/zSayf/SayfAiTextFixer/issues

================================================================================
*/

#Requires AutoHotkey v2.0+
#SingleInstance Force

; UTF-8 BOM for proper text encoding (especially Arabic)
FileEncoding("UTF-8-RAW")

; Global constants
SCRIPT_NAME := "Sayf Text Fixer (All-in-One)"
SCRIPT_VERSION := "1.5.0"

; Log rotation settings
MAX_LOG_SIZE := 5 * 1024 * 1024  ; 5MB in bytes

; Create dedicated folder in AppData for the tool
appDataFolder := A_AppData . "\SayfTextFixer"
logFile := appDataFolder . "\SayfTextFixer_log.txt"
configFile := appDataFolder . "\SayfTextFixer_config.ini"
filePath := ".\geminiAPI.txt"

; Cached AppData icons
iconsFolder := appDataFolder . "\icons"
iconFiles := Map(
    "ready",     iconsFolder . "\A-gray.ico",
    "valid",     iconsFolder . "\A-green.ico",
    "missing",   iconsFolder . "\A-red.ico",
    "processing",iconsFolder . "\A-yellow.ico",
    "error",     iconsFolder . "\A-red.ico"   ; reuse red for errors
)

; Global variables for API key and user language
global geminiAPIkey := ""
global UserLang := "en" ; fallback
global ModelName := "gemini-2.5-flash" ; default model

; ==============================================================
; LANGUAGE DICTIONARY
; ==============================================================
global Messages := Map(
"Ready", Map("en", "📝 Sayf Text Fixer Ready!", "ar", "📝 مصحح نصوص سيف جاهز!"),
"Processing", Map("en", "🤔 Processing...", "ar", "🤔 جاري المعالجة..."),
"ProcessingDots", Map("en", "🤔 Processing", "ar", "🤔 جاري المعالجة"),
"Success", Map("en", "✅ Text corrected", "ar", "✅ تم تصحيح النص"),
"NoChange", Map("en", "✅ No changes needed", "ar", "✅ لا توجد تغييرات مطلوبة"),
"Writing", Map("en", "✍️ Writing...", "ar", "✍️ جاري الكتابة..."),
"Shutdown", Map("en", "✅ Sayf Text Fixer shutting down", "ar", "✅ يتم إيقاف مصحح النصوص سيف"),
"ApiMissing", Map("en", "❌ API key not configured", "ar", "❌ لم يتم تهيئة مفتاح API"),
"NoText", Map("en", "❌ No text selected", "ar", "❌ لم يتم تحديد نص"),
"EmptyText", Map("en", "❌ Selected text is empty", "ar", "❌ النص المحدد فارغ"),
"TooLong", Map("en", "⚠️ Text too long (max 5000 chars)", "ar", "⚠️ النص طويل جداً (الحد الأقصى 5000 حرف)"),
"Timeout", Map("en", "⏱️ Request timed out", "ar", "⏱️ انتهت مهلة الطلب"),
"NetworkErr", Map("en", "🌐 Network error occurred", "ar", "🌐 حدث خطأ في الشبكة"),
"ProcessFail", Map("en", "❌ Processing failed", "ar", "❌ فشل في المعالجة"),
"InvalidResp", Map("en", "❌ Invalid response format", "ar", "❌ استجابة غير صالحة"),
"Unexpected", Map("en", "❌ Unexpected error occurred", "ar", "❌ حدث خطأ غير متوقع"),
"Start", Map("en", "🚀 Starting processing...", "ar", "🚀 بدء المعالجة..."),
"NoLog", Map("en", "📄 No log file yet", "ar", "📄 لا يوجد سجل بعد"),
"AskLang", Map("en", "Choose your preferred language (en/ar/auto):",
"ar", "اختر لغتك المفضلة (ar/en/auto):"),
"AskApi", Map("en", "Enter your Gemini API Key:", "ar", "أدخل مفتاح Gemini API الخاص بك:"),
"SettingsUpdated", Map("en", "⚙️ Settings updated successfully!", "ar", "⚙️ تم تحديث الإعدادات بنجاح"),
"SettingsFailed", Map("en", "❌ Failed to update settings", "ar", "❌ فشل في تحديث الإعدادات"),
"InvalidLang", Map("en", "❌ Invalid language. Use 'en' or 'ar' or 'auto'",
"ar", "❌ لغة غير صالحة. استخدم 'en' أو 'ar' أو 'auto'"),
"SelectLang", Map("en", "Language", "ar", "اللغة"),
"EnterApiKey", Map("en", "Enter or paste your API Key", "ar", "أدخل أو الصق مفتاح API الخاص بك"),
"TestApiKey", Map("en", "Test API Key", "ar", "اختبار مفتاح API"),
"Save", Map("en", "Save", "ar", "حفظ"),
"Cancel", Map("en", "Cancel", "ar", "إلغاء"),
"ApiNotTested", Map("en", "⚠️ API Key not tested", "ar", "⚠️ لم يتم اختبار مفتاح API"),
"ApiValidating", Map("en", "🔍 Validating...", "ar", "🔍 جاري التحقق..."),
"ApiValid", Map("en", "✅ Valid API Key", "ar", "✅ مفتاح API صالح"),
"ApiInvalid", Map("en", "❌ Invalid API Key", "ar", "❌ مفتاح API غير صالح"),
"ApiTooShort", Map("en", "⚠️ API Key too short", "ar", "⚠️ مفتاح API قصير جداً"),
"ApiEmpty", Map("en", "📝 Enter API Key", "ar", "📝 أدخل مفتاح API")
)

; Translation function
T(key) {
global UserLang, Messages
if (UserLang = "auto") ; auto-mode → interface always English
return Messages.Has(key) ? Messages[key]["en"] : "[" key "]"
return (Messages.Has(key) && Messages[key].Has(UserLang))
? Messages[key][UserLang]
: Messages[key]["en"]
}

; ############################################################################
; # #
; # cJson Library v2.1.0 #
; # Copyright (c) 2023 Philip Taylor (github.com/G33kDude) #
; # #
; ############################################################################
class JSON
{
static version := "2.1.0-git-built"


/**
 * When true, Boolean values in the JSON will be decoded as numbers 1 and 0
 * for true and false respectively.
 *
 * When false, Boolean values in the JSON will be decoded as references to
 * {@link JSON.True} and {@link JSON.False} for true and false respectively.
 *
 * By default, this property is true.
 */
static BoolsAsInts {
    get => this.lib.bBoolsAsInts
    set => this.lib.bBoolsAsInts := value
}

/**
 * When true, null values in the JSON will be decoded as ''.
 *
 * When false, null values in the JSON will be decoded as references to
 * {@link JSON.Null}.
 *
 * By default, this property is true.
 */
static NullsAsStrings {
    get => this.lib.bNullsAsStrings
    set => this.lib.bNullsAsStrings := value
}

/**
 * When true, unicode values in the JSON will be encoded using backslash
 * escape sequences, such as '💩' will be encoded as "\ud83d\udca9". This
 * is to improve compatibility with external systems.
 *
 * When false, unicode values will be left as their original characters.
 *
 * By default, this property is true.
 */
static EscapeUnicode {
    get => this.lib.bEscapeUnicode
    set => this.lib.bEscapeUnicode := value
}

/**
 * Utility function for the MCode to convert non-string values to string.
 */
static fnCastString := Format.Bind('{}')

/**
 * Constructor
 */
static __New() {
    this.lib := this._LoadLib()

    ; Populate globals
    this.lib.objTrue := ObjPtr(this.True)
    this.lib.objFalse := ObjPtr(this.False)
    this.lib.objNull := ObjPtr(this.Null)

    this.lib.fnGetMap := ObjPtr(Map)
    this.lib.fnGetArray := ObjPtr(Array)

    this.lib.fnCastString := ObjPtr(this.fnCastString)
}

/**
 * Internal function to load the MCode
 */

static _LoadLib32Bit() {
	static lib, code := Buffer(9904), codeB64 := ""
	. "G7gAVVdWU4HsbAFAAACLvCSMAWC0RCSAATCcJIQAMIkA+IhEJDMPtwYAZoP4Aw+EBgiEAAAAJBQPhEQDJBAID4SiAxIFD4QCwAMSCQ+EhgAAQACF"
	. "2w+ETgAiiwgDvV8AHIPGCI0AUB7HACIAVQBAx0AEbgBrAAwICG4AbwAGDHcAbiEABhBfAFYABhRhBABsAAYYdQBlAACJE2aJaByLhAQkiAGMXCQE"
	. "iUQAJAiJNCTolCABAVmNUAKJE7oiAQBeZokQMfaBxAEByInwW15fXcMEjbYAFgCLRgg7AAXQHgAAD4QpQAkAADsFyAIL5SoKAQvMAgs5gAuLEACN"
	. "TCRQiQQkiQhMJBQABVTHRCSgVO4fAACAAxCBI1WAAwyALQCADwiABQQC1AAd/1IUg+wYAItEJFCD+P8PwIRhBgAAugB4gRUCYIEZjWwkcGaJEFQk"
	. "YI2AAYmUJCoggatWAR9kAk0KiSBsJBiNrIILiRRKJIALbAQ1aAIAb8cYhCQkATkBCYQkLF0HBSgABYEGABRwBBh0dYQDeIQDfIQDACOCAxzbgQMA"
	. "NxSBZ4QdDIQNgSyCAMBVBP9RGLkBA4CD7CSNhCSAAxsLgQECCITDL0YIZolCjEIFjYwkkMMIhMnECIsQgEcYi0BSAAWijAUOTCQEgAOIgAKuDEM1"
	. "QQ2EMpSHApiHAgachQIpMAQk/1IYtrjELwARoAQRgCmwAohfgwRANoEBhzOACqSHHqx1kTKoAAQUwy6BEoQKtPWHAriHArzxLoBIwy+ALqBmg3wk"
	. "cMDackLTdrxCS4AD80CpgQMBIAMwD4X0A8AoAx6FwHPAs4EDRgjAOgEYgCHAVUdfOIADxIk1FIAJMPWDCcgHLsxHAYED4h2PX248CWBiFmJghOIO"
	. "wmBaXUERbkERYRCgCUAnV0SlRwFIRAGLVcEKGMAFG+EEAANMZQQNKEwkNFOBFzlYiSyGKLzCDwk4D4UKACdgBKIQuntJAwZEAgSU2QvCiEgIAokL"
	. "IIiJ+oTSAHQcg8AEiQO4eg1iRgFljOCFYYwAHZBBoXV8JEgx9kB34BWDGdBnJ9REAYPAAdWgAdjFMMeAAdynBOEGVUQB5EcB6EcB7EcB8HVHAfRH"
	. "AfxHAYKBQwEEX0cBIjZDAeIlQwEURwEYRUcBHEQBuQxAYBWsvCQI4AHBfCELYGA4wB7vQQEgA8E2AAY0BAbAaAEr9+ADIQ8AAzwHA4E9AAPhEL0A"
	. "AzjAAKEuAAMhPLghDd9hcqEbYHIhKKAB+CFCgwLdoAFQIwihHqABVKABJwWuWGMDwSCgAVyhAUQARO+DVwADIVuGeDyQSRZJoVvnJ4qASQBshZrE"
	. "byEGwG8UhAegC5RCKIXSDwSEdcABhfYPhFYLYF/BSkvh3hOAfCSQMwCNSmBLuSzCRzAKD4XpIAMAfEAByA+GcYAFD7bA66BJUBCDxgHE2wyl3SwC"
	. "JIHd6Fr4///pAGP+//+NdCYAipChC7gAzYsDuWG+or9B641QIP3qT+HqiGIAauHqZQBjYBHkSBxh63geUEOCB4Mc+MH4H5cbUgggCEAXsQE58BDp"
	. "hMAIcghkAzH2A48DjwMEJOjkGADyAOt5tCbiP9MC0IFSCGw0JBAFUQ+0/wL8AoPMAA/mAiUb6H1gAyUC4AAB6ev34ApzgCuEB+ALkANwCcwaAADp"
	. "JsRhAvMFuAVAAPIP/hByYaEkJGTBYuEqIQFgDfNhAJQPobyQUCgxaE7zJz+vTeRPxCePKY8pjSnyDx4RIzUTKqAoQYEPtwJCZtFg8vb//4Eihxkx"
	. "CBO5YTfkDZCJ1sCDwgJmiQbwEBMDEAQIg8FRA3XliRgT6bmAA/MShdt0oHeLA751MSZlMiZACMcAdAByQBBwIgSSIwbpi2IGdE9HEJ6BiyICbgB1"
	. "IAJoBSACujEBZolQBukGY3AC9BeLCI1CAgEBJIPAAoPBAWZAg3j+AHXzxRkIBOk4pwKDAATpKUP2CLI0D4TB/PABlLMyWHA3iLLgAIEOhBExMhNx"
	. "BYnRgFchDscBQAkAOfh171ANjLNQAvUPD7cTRPOsw/AUbfOsc3Afs6stsDyTrVVLUAXRBVjBPgO5YxAci682qzZUoTZ5AHAxNo4YYBAROmAQGg+/"
	. "tEuIRCRY0TJEJFxMKWaNkAExKbgVvq1hCIlzwApiAbk6BRGBGIAKtjr7AA5QMRexJMAGAuluoyEB8BCBA/wRefULCiDHAGYAYfELbACCcwIESAjp"
	. "wfR2MvswpCEkgiAxaIQohF+DtCl8QP8AAMF1dLfHiJEuJv+gCcSI5WjGiLJlc4X6hppY7BS5YAywnRjkN/g5wBP+PJVo86liOhaIpTn6OPWE/otm"
	. "CrVr2Go7i/87/jshDE9xCi+eKp7UiXVw8RlUg/EZcBOD+AEZ0vDCAECD4uCDwnvpnmMwGCAigbEhGf71LxnPLxkrGXQAMgzpaEBk8Qb6CvIgv/Fj"
	. "otn/Y/9j/mM6ePJjaP9jb2CBeem+6vkgJnbHWRCht/UdzwMhP2Qk6KASyl0M8tD//4nGBT2LIJkDPObBgBsBPHUTwAIBmHEXxBXUwNyD7AThAsGX"
	. "faMCrakC0ZepAkeEcRsI1In4MAGEcBiWwUfRVY/AA6BPgaKyOmaJKFM7oMGJE4nQFKMR4CUB0krJfh8x0maQGInBv5CE4k/CAWYIiTk5w0x154kD"
	. "WWCBRAGgqDAgCxIgfTGAP+ko8RJPQg8CAR1kULqQIdAAIADp7vrNQlgqDEOkD+mOcEA2E1AF6djw6AABkADmuQDYAAAAiUQkWAjB+B8AYFyLhCQA"
	. "iAEAAMdEJAQTAMAByAiNAHSJBCQg6CIRAAAEeIMAAgEEJIsAjVACgwDAAYB8JDMADxBFwouUAiyJAukAIvf//41KBIkIC7kNAJBmiUoCoIsTjUoC"
	. "AB4KAh4ACuk0+v//hduID4SCAUcDuSIAFkEATIkTZokIBF2JyFwkBAKChCQCpwCFNJwQACwTAiwAQ41CCALp6wBGicbpAArwA00lAk3pr/7/Av8H"
	. "rYn4hMAPhEw/9AkTAALpLQkREIiLRggGfIQkQAAKcYGKhCREASmESIBGi2hEJDQBRREBRQYn6Qx974YlgIoUB422QwEkgI050HX5h4v/HvUGEwVv"
	. "AAcFbz0SAJgA6Q+AaIQJixCACgD/UgiD7ATpQWr9AgvoDAtVAwuCO5wEJJAGboXbfhyLQBAxwIPCAQBCO1KEAg118YU9EAhdxF7uCktHXIZDwX8P"
	. "hjuLJcFBTEAV6f4AH4XbFHRQwG90wm8QxwAAIgBPAMdABGKEAGqAAQhlAGNAakBIDIkTul8CbVAiDsQ26fL4iB0OD1C/hCTQgQVtBzSDUAAI6VeA"
	. "A5AGAFUgV1ZTuxSACYHsIowBQoQkpIEBtCQaoAIXGEAcASzHQAwBgQGLBg+3GI1TAPdmg/oXdyi5ABMAgAAPo9FzCjzAmb8BA2aQD7cgGonQjUtA"
	. "CPkXCA+G7kFGBmaD+zB7D4QeQD5AAlsPDITpQAVAAiIPhEISBsA4U9CAEwkPlgLBwAQtD5TCCNEAiEwkNw+EkAWHxiNCKE8jPg+3HwINKIS5BwJX"
	. "OEAWANka6EACPAEIwAYwD4QCMsAMjUPPZoP4oAgPh3cDBhW9Ac4AifmLUAyLQAgIjbQmQQyQg8ECBIu8ggeJDmvKCgD35QHKD7/LiQDLwfsfAcgR"
	. "2gCDwNCD0v+JRwAIiVcMiw4PtwgZjXtAL/8JdseCiQAY+y4PhFMgEQiD49+AAUUPhbQBRyqNVwKJFmaDADgUdRDfaAi6A2AbABoQ3VgIixZYD7cC"
	. "gBOgGCOgAsYIRCQ3ABf4Kw+EEhTAAY1I4Av5CQ8Ih8IC4ArCAjHJAeRg6DCNDImJ1wFAApiNDEgPt0II/o1YQAX7CXbkgIk+hckPhBXAGwgx0rgh"
	. "Io12AI0EBIAAVwHAOcp1cvSATTDbYAAkE2CNN4AA3UAID4RUwDGM3vFhEiMDD7cQQDOQFA+EeoAaMcBgATAFD4VJABHkA9xIwgiABTHA6TdgAuQS"
	. "AMICD6PPD4L0CaBM6QGAhoPAAo1oTCRQQDJg4QPCRIlQBqHAHgI2ZOI4EFCJTCQYoARg4AAURaACaII8RCRs5AAg9eQAHOQAEIEa4ACiQOAAA4NC"
	. "Z2v/UhiD7CQAi1wkWI1UJExZAANINEAI4ABMwg0D0IlUJBQgA0jgACGUD+COwwnECsMIHCT/UAAUiy6D7BgPt1BVAI1CQFr4QFoLh4AE4ClgIV0P"
	. "hGhhWmCF0g+EXwABhCKJhDQkACwE6KL8QHkwwA+FEqOdYkBUJK5w4Ashe+EMfETCcCMS2otjFXikEI0eGJkf4AceBCIWAh+jDYBNCXUOE2BbqJuL"
	. "LogZdyIPgKPHc3WNRQKkX0PgGkA+icWNSuJ3dggyiS7gHCwPhYADoGYABwKDxQKJLhlFIYf4wDsgCHLl6RwB/4DT5LPhP3K46xbE4wGCQZNAFusN"
	. "3aDY6wnd2EQNuCAGgP/rAt3YgcThjqBbXl9dw0dFcElF3sRDRaImRkXhKHjpKC0mI0RJX0UYixaFRXQm0aAcAo1IpJdAQBQgHSh9D4SBb2aAOYS5"
	. "gQEBg/giD4U7QR7bgFrFPbOh78A9I3ABURZQTQCNQVMWIDASDwSDC/ECRQIPtwjF8BVRElQPho5BCDAW4Pk6D4XqE3aRG2IW01EFwAXoWoQFyvcB"
	. "kB61hHNosgfH4DlhRAolBwobIgcMwAoPt0oCUzA5hAF2ODFI+RAd8OXRYMIgSekKgQn2H/IbkNcPglRQAelhpwEJcR6z6yFadA+EBUPgIJAAZg+E"
	. "opMAbhgPhSvgCWBgZoN4gAJ1iRYPhRvyANIE8AAEbPEAC/IAsGAUeAbyAPsAQoPACDiAPbjgHWAeJUeEwR2gGblhGkBoYiyJCKHU2B8gAkaRRs1g"
	. "A2CPAfBOAokOicrp3MOxfQNbjUgCvXEDcAGgTwhmiS8RERpzZgLmMAWDwATrGZAAZolY/onBifq3oAGgDtMBJvFosY5nwQUQegKJPnABXHXUI7ET"
	. "0BIidFpQAFx0QmlQAC8PhKGiNfmwYg+E2ZMAYBAGEm0g+W4PhHwCIvlyCA+EETMBdA+F84kwAbsJwlEEicESCIgW6XuxFXYAv5GXlXQBeHEBY3AB"
	. "u1zMAs5OQAESM2JHhcigRaciRrqhBVAkiRCJwliqqdABvS8XBGgRBAzCA0Q6fVIED4WGGATCtAK5EgQWkBYTBGjQAS6/oRSJCfkny1BFKcMkMf8R"
	. "JFj8kGGJObUQAjFgA7uBNqkLk2ADxN7JYGLpp/lQBcGrBVkFdGEhRwLZ6A8Yt18CEXzxCYkG2ZjgicdRfNEA6TVzjZHCCscCuaFziT5AdKfwCrFq"
	. "UYCNQ7Bv+GByn6EpwKGxAqNvcG/rMGADwgFAClwkMN9wb/VvAIk+3vncQgjdClo0BEuidnbM6TxTBwf9j414sCdYICLplg1AAgQvcgEtKvsGL60C"
	. "MBryAAIvZfEACvAA1QIvsAwv+XAKvWALsQaxIQtmiSjkBqAY3fAtAN3Yi0gMi3QkCDiJxyA/PA+vRwAID6/OAcGJ8CD3ZwgBytCIMcC58IjpsbAC"
	. "Qo2JHxMxLbVjCmFhCINAAnk5c/IAVWIKc/EAY/IACPAACEViC1PwAIPACm8LUU2wCr5kC8KWiTBnCyZDUAPAFHUPhRPxBEoYBDHtYDkyCQ+3eggE"
	. "jV+jih2NX78hgAAFD4ZfYXVfnwnCAIffkCKNX6mN4HoGweME0DiQJFADCAaNb1AD/QkPhqr0gR1vkAP9kAPuwgCTkAPAAIelkQNcO6ADqgipAwim"
	. "A7KpA8apAwpqpgMKqANqCo19UROec419YAP/YAOFTWEDfWADwACHM2IDK6Kp4QKDwgwQF6GAHvMyORA5ocxQE4RMAEyUeDYEUMSQxgEBMYMCOKEy"
	. "0IAC69ViQoCuocgR4QDGAfthBeunAXjr6WWQMGAA4WVQCsmk6RqCACvJAgKGIgGCQqEzyDHb6WOAOIk1qIR8ANLpS/YRFQjJ6angNtno6QL/4ADz"
	. "vwEnNQAPAA8ADwAPAP8PAA8ADwAPAA8ADwAPAA8ADw8ADwAPAA8AMDEyMwA0NTY3ODlBQgBDREVGAABIAABhAHMATQBlAAB0AGgAbwBkAK60AAAA"
	. "UAB1AHMAAGgAAABTAGUAgnQAOE8AdwBuALggcgBvAHAAbAAAil8ABEUATHUAbQA0AQfEAABWU4PsdBCLnCSAABaLtCQCiAAMjVQkPMdEBCQ8ATyL"
	. "A4lUJGAUjZQkhAAYABQITQAwEAEwAA4MAQMOBAEBD4kcJP9QFA8AtwaLVgyD7BgAZolEJFCLRggVADJcAE9AAA5YuAhjACcBGGCLhAJPADtEYQI7"
	. "RCRojQAvAAdAlIsDABVMBGFIAgMH6iAEDxwEBxgCNQCYAY0fAT+BRoQNATKLShiD7IAkZoM+CXUOAEgAixCJBCT/UggAg+wEg8R0W14Ew5ALAFUx"
	. "7VdWEFOB7JwBfoQksBECWawkjgEHCItYQASJyInaBQAGgACD0gCD+gAPhxIjgIK7FIAIvs3MAMzMhcl4fY10ACYAkInIg+sBAPfmweoDjQSSAAHA"
	. "KcGNQTCJAtGAflxmhdJ14TCLjCS0ArUAB8kPFIShAS+8AgmDwgIgiw+NtCYBX412CACJywAIg8ECZgCJAw+3Qv5mhRjAdeyAS4EUiQiBAsQBUzHA"
	. "W15fXQjDjbaBDL1nZma4Zr8wAQ/CA8Ar3kEiAO2JyMH4H8H6CAIpwgAkjQRHKQrIhyPahCOD7gK7Ci3AAbgBAWaJXHQQZo1UdAEohV//VP//gB24"
	. "BCgABChmApBBJ8ABZoN6/pgAdfOAMEEIiQcLJgPBQ8B3QIlMJEiNMEwkML+BSwB7VKFUvB7CakCCmhDABxhFwAdUxYVmiXwADVxUJEwABFiEdWDE"
	. "AVz/BJ+KhgAQgoTEBpOEgX+BhICLVCQ4D7cCQFRQD4Sz/oA3tMJAhSj2dEGEYrmBn4sXTcNz00A6AGGLREENBNYIgWTAYujFYhCKPIRKIIsIjUIC"
	. "w2GDwBtAccBJeMJJgweJCOm+OgAey59An8CmACccgBoAGItMJCCF0g+EhI2AIosavyLBdQBzAokyZok7DwC3GGaF2w+EBAOgHedFZoP7Ig+EhgZg"
	. "AiABXA+ETCMBEAgPhGIjAQwPhEJ4IwEKD4QeIwENh6AIAAwgAQkPhKJgAgiAPbQgMwAPhL0BgQtz4GaD/l4PLIbHgAGBERiCEb5cCSAEv3VjG2aJ"
	. "M40EcwThEnsCD7dYAP6J34neid1mAMHrDGbB7gSDAOcPD7fbZsHtAAiJPCRmD76bBNwfoB/3g+UPi6IyYANmiR6AAp2BAlBmiV4CYAGfYQGLAWAF"
	. "iV4EjV4IiZYaZQIAAgYEH4URYFIQhdJ0TeIzizKNIEYCiQK4ISRmiVAGg8QEAjGQAAREGIsavWEVABRmiSvoiTK+YwRzARWAV+A4DYAJxAAxIGG4"
	. "izGDkMYBiTHoB3V0AQxggwEC68/gK+AJ9EdlH4EACR/rrmbhDdRTADVBA71ihQ474QNrqALrjuIDtO0RZuQRXOlrIBpEOWUMbmwM6cZHYQThEA+E"
	. "aIFybAmL4b9iCR/jBI1zgYA3MCEPhkMAHAA8Hw8khjlCHXRgQCZ+AuSJOqAv6fJAAuNU4QqWEOIKYxhybBjpx0EFkHYAiznAMI13QCWBwieF/f//"
	. "6cJAA0HgJIMBBOmhQgEBBOmZ7Vs="
	if (32 != A_PtrSize * 8)
		throw Error("$Name does not support " (A_PtrSize * 8) " bit AHK, please run using 32 bit AHK")
	; MCL standalone loader https://github.com/G33kDude/MCLib.ahk
	; Copyright (c) 2023 G33kDude, CloakerSmoker (CC-BY-4.0)
	; https://creativecommons.org/licenses/by/4.0/
	if IsSet(lib)
		return lib
	if !DllCall("Crypt32\CryptStringToBinary", "Str", codeB64, "UInt", 0, "UInt", 1, "Ptr", buf := Buffer(5816), "UInt*", buf.Size, "Ptr", 0, "Ptr", 0, "UInt")
		throw Error("Failed to convert MCL b64 to binary")
	if (r := DllCall("ntdll\RtlDecompressBuffer", "UShort", 0x102, "Ptr", code, "UInt", 9904, "Ptr", buf, "UInt", buf.Size, "UInt*", &DecompressedSize := 0, "UInt"))
		throw Error("Error calling RtlDecompressBuffer",, Format("0x{:08x}", r))
	for import, offset in Map(['OleAut32', 'SysFreeString'], 8148) {
		if !(hDll := DllCall("GetModuleHandle", "Str", import[1], "Ptr"))
			throw Error("Could not load dll " import[1] ": " OsError().Message)
		if !(pFunction := DllCall("GetProcAddress", "Ptr", hDll, "AStr", import[2], "Ptr"))
			throw Error("Could not find function " import[2] " from " import[1] ".dll: " OsError().Message)
		NumPut("Ptr", pFunction, code, offset)
	}
	for offset in [229, 241, 253, 284, 312, 407, 621, 809, 1049, 1081, 2371, 3177, 3817, 3860, 5416, 5527, 5971, 6450, 6486, 7203, 7386, 7696, 7737, 7752, 8894, 9304, 9398, 9419, 9431, 9451]
		NumPut("Ptr", NumGet(code, offset, "Ptr") + code.Ptr, code, offset)
	if !DllCall("VirtualProtect", "Ptr", code, "Ptr", code.Size, "UInt", 0x40, "UInt*", &old := 0, "UInt")
		throw Error("Failed to mark MCL memory as executable")
	lib := {
		code: code,
	dumps: (this, pObjIn, ppszString, pcchString, bPretty, iLevel) =>
		DllCall(this.code.Ptr + 0, "Ptr", pObjIn, "Ptr", ppszString, "IntP", pcchString, "Int", bPretty, "Int", iLevel, "CDecl Ptr"),
	loads: (this, ppJson, pResult) =>
		DllCall(this.code.Ptr + 4784, "Ptr", ppJson, "Ptr", pResult, "CDecl Int")
	}
	lib.DefineProp("bBoolsAsInts", {
		get: (this) => NumGet(this.code.Ptr + 7856, "Int"),
		set: (this, value) => NumPut("Int", value, this.code.Ptr + 7856)
	})
	lib.DefineProp("bEscapeUnicode", {
		get: (this) => NumGet(this.code.Ptr + 7860, "Int"),
		set: (this, value) => NumPut("Int", value, this.code.Ptr + 7860)
	})
	lib.DefineProp("bNullsAsStrings", {
		get: (this) => NumGet(this.code.Ptr + 7864, "Int"),
		set: (this, value) => NumPut("Int", value, this.code.Ptr + 7864)
	})
	lib.DefineProp("fnCastString", {
		get: (this) => NumGet(this.code.Ptr + 7868, "Ptr"),
		set: (this, value) => NumPut("Ptr", value, this.code.Ptr + 7868)
	})
	lib.DefineProp("fnGetArray", {
		get: (this) => NumGet(this.code.Ptr + 7872, "Ptr"),
		set: (this, value) => NumPut("Ptr", value, this.code.Ptr + 7872)
	})
	lib.DefineProp("fnGetMap", {
		get: (this) => NumGet(this.code.Ptr + 7876, "Ptr"),
		set: (this, value) => NumPut("Ptr", value, this.code.Ptr + 7876)
	})
	lib.DefineProp("objFalse", {
		get: (this) => NumGet(this.code.Ptr + 7880, "Ptr"),
		set: (this, value) => NumPut("Ptr", value, this.code.Ptr + 7880)
	})
	lib.DefineProp("objNull", {
		get: (this) => NumGet(this.code.Ptr + 7884, "Ptr"),
		set: (this, value) => NumPut("Ptr", value, this.code.Ptr + 7884)
	})
	lib.DefineProp("objTrue", {
		get: (this) => NumGet(this.code.Ptr + 7888, "Ptr"),
		set: (this, value) => NumPut("Ptr", value, this.code.Ptr + 7888)
	})
	return lib
}


static _LoadLib64Bit() {
	static lib, code := Buffer(9600), codeB64 := ""
	. "HbkAQVdBVkFVQVQAVVdWU0iB7IgAAgAAD7cBSIkAzkmJ1E2Jx0UAic5Eictmg/iAAw+EgQcAAAAkEBQPhJcDJAgPhEK9AyQFD4TDAxIJAA+EiQAA"
	. "AEiFENIPhIAAJEiLAgBIjUkISL8iAABVAG4AawBIuwBfAFYAYQBsAABIiThIjVAeSEC/bgBvAHcAHEggiXgIv18BPYlYABDHQBh1AGUAAEmJFCRm"
	. "iXgcAE2J+EyJ4uhtgCAAAEmLBCQAOBICARq6IgAuZokQIDHASIHEAbxbXgBfXUFcQV1BXmBBX8MPHwB/AHw7iA2FHQDXhCcIAFtIOw1YAgz6CQIM"
	. "W4UCBj2BDI0FoB4BA0BUJHxBuQGCQ4SEJICBA4sBTI0EBQCJVCQoSI0VRBEAG8dEJABHAAD/CFAoi4AZg/r/D0iE5AUBF04IACZnAQAmRTHJSI28"
	. "JFqwBCaYgQOAJJCAA701ADkAASvQBA4CEosBckECDEjHgxIBAIEFwBGEBWaJrIILSI0tAhmAL0yJRCQwReuAfgARoAgXuIQFhBwCZleABQE1BRHY"
	. "iAXgxgJEFCRABQI4AgKJfCTGKAE6gRD/UDDBNgA1EYEcjQWPAEFIjZRsJBAAB4ER8IURQDP4v4Q6wQRIN4EJgiPEUjBBTnxmREA1AgpABwETxSUY"
	. "d8gCQiDmKLgBUUFfQA4wo0QOAi2UJFCAA2ZAJK+BBUEowgFLKEBNKEgAKK44RDnBDwUlWMgCYCYoWGaDvIJiANWsgs28O0I9gAMdAKWBA8EYAw8A"
	. "hZYDAABEi5T1ghlFgdSFAASDl8AtgLtDwSXCAY2sJBDCA0QQJGBJicA5FaIabAAAhLEAJ3AFJwM4ePXILYCGHWyjFGVaADtACrnCWmcM4w7hVUEJ"
	. "TOANflCAAyQsQQFGImUBIw1gd8QBJ1WtI0zlDqgjYQwJWA+FXqA4IANcIQO4InvhWUQkaAEKTYWg5A+EFAuBgQyAgQJRgoFmiQFFhPYCdOABQQRJ"
	. "iQQk1LgNAmYCCoYKA4aicHnACjH2Im1FIGF1xDyYvUgkoGgB4QPGbGgBwGgBqtBoAdhoAeBoAfBoAXr4aAEAaCnhL2ZhaAEgA2UBgCpQRIl0JGwA"
	. "TYnmTYnsTItgbCRgSIuDCMN0MRDSSIuM4j1BuwxxAC9IibzCDSFeYTO4Z4ECwWFhFkiL4AmgcZzhohNmD2+MAgFhBcEYFyELQRgAA5TiBUyJpN/E"
	. "UEBK4QDEZ0gVOGQBxAIjoQERZGwkMOpADylijKJKDxGUIj7gQoVwwA+FCORjASPgY+EuBuNjYSPiY9AAAoX2qA+ExQACTQEBzeBrQEmLFkG5LMI7"
	. "SgWAQA4AHAqE2w+FFgSgSyAa8GAFRI1IiAGDfABND4biwQEQiUwkIEDORA+2AMtMifJIifmDAMYB6ND4///psJ7+///gygJQN6ANSyfbwky7h9k4"
	. "SIDZT1AAYgBqAdoIoNsQhLl0ohBQIEG44dwRYNxlAGOgL0gcSAaN4x3iWESJQB5ITItGQAZDa+n+IA9myA8fRIAHY0GAf2MFEcUD6FcZAFnA6flT"
	. "oASB7ehH4wHp4AFBCIMAD2ECMdLoMaGgAkGDBwEgA8/nCVnwcehHoEJQAblQAfJgDxBBCL1AbOQjSPCLDfkVdFJyRkNBYlX/RihjCMEf8VIyVjQC"
	. "1T9ic/+gKMghkWwiBThDFANDS00icaUh8g8RYyWiXsMfDwi3AmbwIYT09/8K/6IZnYACSYsUJAa5kQXwGkmJ0EiDYMICZkGJUiwzAwSQCEiDwYED"
	. "deBxF2TpttADDx9hfgGMdJJ5wIu7dcAAvmVjG0AIxwB0AHKQC1jD8EXxRnAG6YIyA/ICIknwAkG5bLACQbpDUQATA24AdQAQHUiBIwNEiVAG6U4w"
	. "AwRBi3AZQgJIg8AAAoPBAWaDeP4AAHXyQYkP6TFBwQGDBwTpKIAAkAFwKoRY/f//RIvDMDlSLtsPiEcAAdItTlIAKBAQEyxKAYAuSBCJ0UG6QDIA"
	. "g8ACAQIPRIkRRDnIgHXnSYkW6RpwA1n0DQ+3U0+RLmDzncbaBPWdWfAfs5zdAAaTnhYSkAAyBzQSNQZBuSdCEQCY0y9BupObEEgiuicwUAhIYAFU"
	. "AJh5AHDRAFBXUByxEIYY0AihEBpID79zCDXynfKRLYgkJXEA6H3KFsMGuHGeRIuwCoNcO9ED4wiXUAsQAmEBuTqTQR+wAYkIYRM3/OEwElBwFxa6"
	. "MW1miVCIAukiQAEPH0ADqiL60nQCQbuiDLtmxWKpc3EbCkiJMAryGiBYCOme9XYTi7z1gpOFMHFF4TapdX91Qy09AGz/AACxa4Nx4qFsFH/jNAFW"
	. "56bCNcR8RXaANUnciegkNJhjuHq5kAwVO4+lOik6cAZhCmaJjLMB3yEIoYK5O8harTswQSZ0cf/1O+QCA10vPC88qX7hCql+NHV3UjtCcAEgaGiD"
	. "QPgBGf+J+GCTXACD4OCDwHvpFB/AFnEbcTBRoXEwhNL2Lx8YHxgTGHQAaCEB6Xk3QFzzT2IH5YFX0FtBuMHxWUyJ6Ui75srWyfRBuQMuGPFbUcyj"
	. "XcFa/9HJwct0yzFdwSMAy8Euq1xsOfPyQhA+EHIBtFwxJtIyBARdhhOjWukkCdACicLFOk2J9EQ2i8B+szm4kAKxOXUWDRAaUFF+IYv/FakR30AU"
	. "EAFRA8GK0wJv3gLBizj/FXvUAlWC0wEB/0RQELCUD4SeYQeF0uTyBIScdRK5kZUlSSJBMpVIjUhwOQwkwwGZUA8ISYnIcJggAYFAcYnBZkWJECAb"
	. "Mn6xAEG48UmCT8IByaACATkTTHXjxAKAeGRoAUGdGcBhFBIgfcHAnekW8v//5E7REUshT4E+Q3JuBwESE9Ny+rJRdFMySmFDF0MIREhjc53pjfui"
	. "cQUI6cPxQUJKBEG450EMwIGiDWaJgILAVPaC+ALpe3AFAQYlBKVKYBs7cG31Ss3QFKIJoUpBiw4HoAeAWEAKRcJBidgH6aTiaWAVyRAEAAp/8gmB"
	. "HyMKEFCwS5EFEQboPoDABLGLx0+RCFFj6Q1h8AtImOkH0AsSLCrh8gQMJOnAkC0BCMIb9hdwS4YRCsMAUidCC3EuAInquQCEJFACAADoFQARAABB"
	. "gwcB6QCz8P//i5Qk8AEAoEGLB0SNSgEAQY0UAWYuDx8EhAABAIPAATnQAHX5QYkH6cz2AP//SIuMJJgBAAAATYn4TInyBOj+AIxEi0wkYCjpYPoD"
	. "OLgAOIlUACRQSIsB/1AQYosAEumS/QduDDRJAQAaTYXkD4Td/AEAI7siAFUAbgAAawBJiwQkSIkAGEi7bgBvAHcBABJIiVgISLtfQABPAGIAagEN"
	. "EOTpoQCNi5wDuADIAQMwhdt+FQDEALKDwmQBOwPUdfEAugEcMRDA6cnvAW32dHdASYsGQbt0gG5IBLoihikQSI1QEADHQAhlAGMAZgBEiVgMSYkW"
	. "ugJfABJmiVAOSIuChIJf6UT5//8BJwRIjQaEMdLoxg8nA58BhQA/6fUBeQ+/GIQkkAARABcO6b0rgAgABAgGJKwACJCQAJBBVFVXVlNISIHswIA0"
	. "uBQCNwIASInLSInWSMcEQggBwUiLCQ+3ABFmg/ogdyxJILgAJgAAgB8ASQAPo9BzOkiNQQACDx9EAAAPtxAQSInBARIPhsgJARqJCwAGew+E1UMA"
	. "goAEWw+ExAEugwD6Ig+ErgYAAACNQtBmg/gJQQgPlsAABS0PlMCAQQjAD4VmBAIJMHQPhBcAH0ACZg8IhC8JQgJuD4VxAwATgRxmg3kCdUigiQMP"
	. "hV9DBARABFQEbEIETUMEBkAEBgVDBDtBBIPBCIA9hI0LgyYPhHkKATZABf0MAAC6QTlFADHAZokWSIlGGAjpEkEsxZ9Ig8ACAoE6D4Ia////DOkl"
	. "AAGAEgJIjZQ0JICCDclADkAUSIsEDVEAF0yNpCSgBYENv8VJSMdEJGBLQhIAAmjDUwFIwKEwIEiNVCRgQQIoMarSAQdwRQlABQI4AQIFwAEgARL/"
	. "UDBIixisJIjBBkAOVEiNBAWnQC9IiUQkWCRBuUEITI2AAkiL2kXABOnEFQAPVAURwQEA/1AoSIsL6x2DxzfBafgsD4XtAF6zQjZAR7cBwAQAct9C"
	. "bCD4XQ+Ez4FlhcAID4TGgQmJ8kiJmNnowUCQgASF3MI0AkXEQkyJZCQoSCyJtIJBANlUASPHhIwksIIbwTWEJKhkAS/EAsUk6x4BATAMIGaDgD4J"
	. "dQpIi07gWCeBeGAZhRWHNUEzD6PAx3NPSI1RgFLjG1QPtyAa0SMEEII3wkICoQRy5ukBwAGQ0WEBD4IDYTsS4QFgPRDUD4Il4A1mhdIoD4Ss4We4"
	. "AAP/RCCJwEiBxKFkW17gX11BXMOBJcQ/RjzN4kBZwFXlQ0m86UDDP7yNrENERj70QdhAvMNAkIsD6YJhHB9A5G2wOg+FTiVUgTQL4TR2GWCb4TQ0"
	. "IQNgraEvSYCJ8EiJ+eiOomCWA4B3wnsnoh+Dt2IKWeUnUAJhYCN7joIcAzuAASBGkMRjYWwDCA+GEL3+//8gAX10dokifYXA4AFIierBEHSS+8MQ"
	. "rUEC4TZCig9sh0XAEuMOkyEDAopAWemJhyBCGuJw1OA2EVfAAeZX4zVW4Tdj4QKDxDh94zUPhUrBCcAGGQJ0A7igMmCbBkiJUH4I6S9AA72BnUgE"
	. "x0ZinPIPEBVxAyAEA2lmiS5IixMDAKjAHvgtdR5IjRRKAiEERyE7D79CsAJJx8FhDAIsymAEEDAPhEYAY41Iz4Bmg/kID4fJQs4QTghmkOJNiRNI"
	. "AI0UiUiNTFDQDEiJYVdiC0SNUNCAZkGD+gl22kAIIC4PhIkD4N3g3+GAAUUPhR4AEYQHoF4AFHUcZg/vwEEEuwWBFUgPKkYIwWDEHvIPEUbBCaBc"
	. "MSEVD4QUoAZBmYP4kCsPhAeAAY1IwKxg+QkPhzZBEuAJRQQx2+Erg+gwQ40gDJtJidKBAphEgI0cSA+3Qv7EBQB24EyJE0WF2wgPhABAtUGNQ/9A"
	. "g/gCD4apoA/zEA9+BU9gJkSJ2gAxwNHqZg9vyAEgzmYPcvECZg8U/sEAAfAh9udmD4B+wGYPcNjlAAEQ2g+vwuAFg+L+AEH2wwF0J40MAIBEjVIB"
	. "AclFYDnTD44n8FYwCGsoyGRB4QAY4ABpwEbosBARD/IPKjAAEFBOCEWE0EfWEA3yCA9eyHAPTggPt8EwXvgUD4TmEANDDxAFD4VU0C7yD1kMVggQ"
	. "AWACVgjpQp+xfRAc8A3RTRAb6ebwHzNjIuJNhR8hAkAzQbwHUSITXfAVJkiJbggE6QLAAUyNSQK94ZEiTIkLTCAcEyJjFwUAbfnDUwTrG2aJAEH+"
	. "SYnJTInCt5FHIAUDAuNRJfFTr1AwIEyNQgJMUTT4XEx1z1EJMQJ0XfEAdEJvUAAvD4R/k1diWA+Ej5MAYHDBkwBuCA+EBjJ1+HIPhMLTMwF0D4WA"
	. "MAEyLp3wHAQQCIEIsCPpdbEwUB8AvyKpAXmiAVoRoAFBu1yIAUSJWaWSAUCRAbovmgFRkgG6JpEBuJEQlwGDBgziRQBGCESJySnBRUQx5HEliUj8"
	. "gRlF1IkhEQK5MJq4IGstCpbS0BggG8HSLOkl0AAUuA1fAqxwAYnI6dbncSwkgHLifVyhnySArUOBShMBIoBlEgE4EQGtIoBqgCUjgJehm7riAAdQ"
	. "QHE/sQpEiRbpEMXSAsIALe/AvxE3QTjciT5zNzg3xjXnoASSQziNDImQNXEDYjUByc2gAMnQA2MsKsnAK2AOxlhaBHdAwen94CE1SZeAWSChYCtA"
	. "QUDp2JEjDA+vkDBBdk4I6WqtoKC4AFyNEoMYEmHSD7Y6kAJLkigTARIScxIBqhYTAQgQAQgzEwQRAcCDwQqAPTbgDTMTXobycDUTUQoAEwYQCemE"
	. "3PjCNHUPhcyQADhIjUIhCXAEcZVB/kJEYC4EQY1AMp92SiCQAL/iOobJAQWNZECf0gCHkaAD0ACpYRAyBsHgBEEyxAMGIkVVEg+GQkFOjVBWv+EA"
	. "IAQ74wCf4wCHQk0wBEKNRABBBAi1SwQISAT18R5HBA5LBKoISAQKSwQKSASkSwRmu+MARQTD90QEkhmDFMIM0RnlER6LDVTP8AYnafSMoR3pk1AD"
	. "AAKKQ4ERuRICRIkOKwKOcCACowGQAYsN+NIZJQkCTwACMdKx0ADpIo/ALEQB0DEI6XfZgYwB0FI8cQDZMDURCtjJ6c+VAHICT/ABcwEi/LI5EAVU"
	. "ICDpc5OgBAVqhF/gIemSEAGATInIMcnpClBS8aAbyelAEAOAxQQAIQj/CQD/AA8ADwAPAA8ADwAPAP8PAA8ADwAPAA8ADwAPAA8A/w8ADwAPAA8A"
	. "DwAPAA8ADwAAAAAwMTIzNDUANjc4OUFCQ0QERUaQJQBhAHMAgE0AZQB0AGjw8GJkUAJQAHUwAeGsU41yAQBQ7HHyUAByEAKicLABAABfEABFMAEI"
	. "dQBtGAPgs5IACgDwvwRwPwEAKAEBGEFUU0iB7LgFASS5ATxIiwFMiUDDSImUJNgBNI0AVCRcSYnMSIlAVCQoTI2EAigxYNLHRCRcAYwADiCBAQ7/"
	. "UCgPtwMBWKBgRTHJSAAscAEsAEUxwEyJ4WaJSIQkgAJZQwgCRzGU0kgAEogAErgIAATdAR+YAh8DXgE+aAE+ASUGoAKEBECJRCRgSaiLBCQBXwIE"
	. "KUACKVUACDgFCDAFmQQCmTAAZoM7CXULSIsESwiAbf9QEJBIBIHEgXdbQVzDkACQV1ZTSIPsMIhBuRMBH77NzAMAAEiLCUmJ0jHSEEmJ42aBWUiF"
	. "ySB4bA8fQABCyEkAY9lI9+ZIweoBgHgEkkgBwEgpAMGNQTBIidFmAEOJBEtJg+kBAEiF0nXVSY0UgFtNhdIPhJsALQBJiwpIg8ICkAhJiciBA0iD"
	. "wQIAZkGJAA+3Qv4AZoXAdegxwEkCiYAQxDBbXl/DVA8fgMYUgBq+AWZIOL9nZgMAgAuAP0SJEMtI9+8ABEjB+AA/SMH6AkgpwkGBRI0ERinIg0JE"
	. "BEv+BUPOg+sCuAItgRFj22aJBFwHQSXCA4EmhWX////YQYsAgSRAF0RACUACAIPAAWaDev4ApHXyQCgxwEUlkAEAC4BLgTTtwF9IiwJBBLoiQBJM"
	. "jUgCTACJCmZEiRAPtyIBgDMPhBDAkkyNIBUe/f//wxVmg2D4Ig+EDoAFQAJcCA+EZEMCCA+EiiFDAgwPhKhDAgoPhIQuQwIND4RUABohQAIJD4Ti"
	. "wASAPQAr+///AA+EBQGABUSNSOBmQYPg+V4Phg+BI8ElwYXFwSW5wadBu3XBPYFaKESJCEApBEApTIsBASpYAg+3Qf5IAInGQYnDicNmAMHoDGbB"
	. "6wgPALfAZkHB6wSDAOYPZkEPvgQCsIPjD0HAAEBqAQIEQhpAAkECZkOFAgS4SY1BALWAckAEMkEEMgZEQIULQFaAJHRU18M/gB3ACgLACriBTEEU"
	. "oFtew2aQgQhTQCwKuwEsvkRTBGaJGDkBVIlwgSkDi8EUt/4BwhR1skWLCEGD4MEBRYkIABHDbUFzEpeADw8fwcoAQYPQAALrwsMX8ygioQADqCFC"
	. "IeuaZi4PH1aEIoPhBcPmEWLuEemua+Aa4VDgBJvoCmbwClzpP2IF4hFGCm5PChizwgTmDw+E4QYGBnQPBi7n4CDkCoBAgYFAIQ8EhvuBTYP4Hw+G"
	. "FvEgAQEUcqAuTY1ZY4BToTUB6a/nBuIM16vhKWcYcnEYe2IGAIBkXUANAaA7gC6CMR2ADOmOdqADQS1gAATpUIMBGAHpRwABomWQkA=="
	if (64 != A_PtrSize * 8)
		throw Error("$Name does not support " (A_PtrSize * 8) " bit AHK, please run using 64 bit AHK")
	; MCL standalone loader https://github.com/G33kDude/MCLib.ahk
	; Copyright (c) 2023 G33kDude, CloakerSmoker (CC-BY-4.0)
	; https://creativecommons.org/licenses/by/4.0/
	if IsSet(lib)
		return lib
	if !DllCall("Crypt32\CryptStringToBinary", "Str", codeB64, "UInt", 0, "UInt", 1, "Ptr", buf := Buffer(5872), "UInt*", buf.Size, "Ptr", 0, "Ptr", 0, "UInt")
		throw Error("Failed to convert MCL b64 to binary")
	if (r := DllCall("ntdll\RtlDecompressBuffer", "UShort", 0x102, "Ptr", code, "UInt", 9600, "Ptr", buf, "UInt", buf.Size, "UInt*", &DecompressedSize := 0, "UInt"))
		throw Error("Error calling RtlDecompressBuffer",, Format("0x{:08x}", r))
	for import, offset in Map(['OleAut32', 'SysFreeString'], 8064) {
		if !(hDll := DllCall("GetModuleHandle", "Str", import[1], "Ptr"))
			throw Error("Could not load dll " import[1] ": " OsError().Message)
		if !(pFunction := DllCall("GetProcAddress", "Ptr", hDll, "AStr", import[2], "Ptr"))
			throw Error("Could not find function " import[2] " from " import[1] ".dll: " OsError().Message)
		NumPut("Ptr", pFunction, code, offset)
	}
	if !DllCall("VirtualProtect", "Ptr", code, "Ptr", code.Size, "UInt", 0x40, "UInt*", &old := 0, "UInt")
		throw Error("Failed to mark MCL memory as executable")
	lib := {
		code: code,
	dumps: (this, pObjIn, ppszString, pcchString, bPretty, iLevel) =>
		DllCall(this.code.Ptr + 0, "Ptr", pObjIn, "Ptr", ppszString, "IntP", pcchString, "Int", bPretty, "Int", iLevel, "CDecl Ptr"),
	loads: (this, ppJson, pResult) =>
		DllCall(this.code.Ptr + 4496, "Ptr", ppJson, "Ptr", pResult, "CDecl Int")
	}
	lib.DefineProp("bBoolsAsInts", {
		get: (this) => NumGet(this.code.Ptr + 7664, "Int"),
		set: (this, value) => NumPut("Int", value, this.code.Ptr + 7664)
	})
	lib.DefineProp("bEscapeUnicode", {
		get: (this) => NumGet(this.code.Ptr + 7680, "Int"),
		set: (this, value) => NumPut("Int", value, this.code.Ptr + 7680)
	})
	lib.DefineProp("bNullsAsStrings", {
		get: (this) => NumGet(this.code.Ptr + 7696, "Int"),
		set: (this, value) => NumPut("Int", value, this.code.Ptr + 7696)
	})
	lib.DefineProp("fnCastString", {
		get: (this) => NumGet(this.code.Ptr + 7712, "Ptr"),
		set: (this, value) => NumPut("Ptr", value, this.code.Ptr + 7712)
	})
	lib.DefineProp("fnGetArray", {
		get: (this) => NumGet(this.code.Ptr + 7728, "Ptr"),
		set: (this, value) => NumPut("Ptr", value, this.code.Ptr + 7728)
	})
	lib.DefineProp("fnGetMap", {
		get: (this) => NumGet(this.code.Ptr + 7744, "Ptr"),
		set: (this, value) => NumPut("Ptr", value, this.code.Ptr + 7744)
	})
	lib.DefineProp("objFalse", {
		get: (this) => NumGet(this.code.Ptr + 7760, "Ptr"),
		set: (this, value) => NumPut("Ptr", value, this.code.Ptr + 7760)
	})
	lib.DefineProp("objNull", {
		get: (this) => NumGet(this.code.Ptr + 7776, "Ptr"),
		set: (this, value) => NumPut("Ptr", value, this.code.Ptr + 7776)
	})
	lib.DefineProp("objTrue", {
		get: (this) => NumGet(this.code.Ptr + 7792, "Ptr"),
		set: (this, value) => NumPut("Ptr", value, this.code.Ptr + 7792)
	})
	return lib
}

static _LoadLib() {
	return A_PtrSize = 4 ? this._LoadLib32Bit() : this._LoadLib64Bit()
}

static Stringify(obj) => this.Dump(obj)
static DumpFile(obj, path, pretty := 0, encoding?)
    => FileOpen(path, "w", encoding?).Write(this.Dump(obj, pretty))

/**
 * Convert an object to a JSON string
 *
 * @param obj The object to convert
 * @param pretty Whether to pretty-print the JSON string (default: 0)
 *
 * @return The JSON string
 */
static Dump(obj, pretty := 0)
{
    variant_buf := Buffer(24, 0)  ; Make a buffer big enough for a VARIANT.
    var := ComValue(0x400C, variant_buf.ptr)  ; Make a reference to a VARIANT.
    var[] := obj

    size := 0
    this.lib.dumps(variant_buf, 0, &size, !!pretty, 0)
    buf := Buffer(size*5 + 2, 0)
    bufbuf := Buffer(A_PtrSize)
    NumPut("Ptr", buf.Ptr, bufbuf)
    this.lib.dumps(variant_buf, bufbuf, &size, !!pretty, 0)

    ; If a VARIANT contains a string or object, it must be explicitly freed
    ; by calling VariantClear or assigning a pure numeric value:
    var[] := 0
    return StrGet(buf, "UTF-16")
}

static Parse(json) => this.Load(json)
static LoadFile(path, options?) => this.Load(FileRead(path, options?))

/**
 * Parse a JSON string into an object
 *
 * @param json The JSON string to parse
 *
 * @return The parsed object
 */
static Load(json) {
    ; Prefix with a space to provide room for BSTR prefixes
    _json := " " (json is VarRef ? %json% : json)
    pJson := Buffer(A_PtrSize)
    NumPut("Ptr", StrPtr(_json), pJson)

    pResult := Buffer(24)

    if r := this.lib.loads(pJson, pResult)
    {
        throw Error("Failed to parse JSON (" r ")", -1
        , Format("Unexpected character at position {}: '{}'"
        , (NumGet(pJson, 'UPtr') - StrPtr(_json)) // 2, Chr(NumGet(NumGet(pJson, 'UPtr'), 'Short'))))
    }

    result := ComValue(0x400C, pResult.Ptr)[] ; VT_BYREF | VT_VARIANT
    if IsObject(result)
        ObjRelease(ObjPtr(result))
    return result
}

/**
 * Object to act as a stand-in for JSON's "true" as AHK has no native
 * boolean type.
 *
 * @see {@link JSON.BoolsAsInts}
 */
static True {
    get {
        static _ := {value: true, name: 'true'}
        return _
    }
}

/**
 * Object to act as a stand-in for JSON's "false" as AHK has no native
 * boolean type.
 *
 * @see {@link JSON.BoolsAsInts}
 */
static False {
    get {
        static _ := {value: false, name: 'false'}
        return _
    }
}

/**
 * Object to act as a stand-in for JSON's "null" as AHK has no native
 * null type.
 *
 * @see {@link JSON.NullsAsStrings}
 */
static Null {
    get {
        static _ := {value: '', name: 'null'}
        return _
    }
}
}
; ############################################################################
; # #
; # End of cJson Library #
; # #
; ############################################################################

; ############################################################################
; # CRITICAL ERROR HANDLING RULES #
; ############################################################################

; ALWAYS implement global error handler
OnError(GlobalErrorHandler)

GlobalErrorHandler(exception, mode) {
errorMsg := Format("[{1}] Error: {2}\nFile: {3}\nLine: {4}\nWhat: {5}\nStack: {6}",
FormatTime(, "yyyy-MM-dd HH:mm:ss"), exception.Message, exception.File, exception.Line, exception.What, exception.Stack)


; Write to log file
try {
    FileAppend(errorMsg . "`n", logFile, "UTF-8")
}

; Show user-friendly message
MouseGetPos(&mouseX, &mouseY)
ToolTip(T("Unexpected"), mouseX + 10, mouseY + 10)
SetTimer(() => ToolTip(), -3000)

; Return 1 to suppress default error dialog
return 1
}

; ############################################################################
; # CONFIG VALIDATION & SELF-HEALING SYSTEM #
; ############################################################################

/**
 * Validate and heal corrupted configuration files
 * @return {Boolean} - true if config is valid, false if reset to defaults
 */
ValidateAndHealConfig() {
    global configFile, UserLang, geminiAPIkey, ModelName
    
    try {
        if (!FileExist(configFile)) {
            LogInfo("No config file found - will create new one")
            return false  ; No config yet, will be created later
        }
        
        ; MANDATORY parameter validation for config file
        if (!IsSet(configFile) || Type(configFile) != "String") {
            throw TypeError("configFile must be a string", A_ThisFunc)
        }
        
        ; Minimal validation of config values
        tempLang := IniRead(configFile, "Settings", "UserLang", "")
        tempApi := IniRead(configFile, "Settings", "APIKey", "")
        tempModel := IniRead(configFile, "Settings", "Model", "")
        
        ; Language must be en/ar/auto or empty
        if (tempLang != "" && tempLang != "en" && tempLang != "ar" && tempLang != "auto") {
            throw ValueError("Invalid language setting in config: " . tempLang, A_ThisFunc)
        }
        
        ; API key check: must be length >= 10 OR empty (allow empty for first setup)
        if (StrLen(tempApi) > 0 && StrLen(tempApi) < 10) {
            throw ValueError("Corrupted API key in config (too short)", A_ThisFunc)
        }
        
        ; Model validation: must be valid model or empty
        if (tempModel != "" && tempModel != "gemini-2.5-flash" && tempModel != "gemini-2.5-pro") {
            throw ValueError("Invalid model setting in config: " . tempModel, A_ThisFunc)
        }
        
        ; Config passed validation - adopt values
        UserLang := tempLang != "" ? tempLang : "en"  ; Default to "en" if empty
        geminiAPIkey := tempApi
        ModelName := tempModel != "" ? tempModel : "gemini-2.5-flash"  ; Default to flash if empty
        
        LogInfo("Config validation passed - loaded settings (Lang=" . UserLang . ", Model=" . ModelName . ")")
        return true
        
    } catch Error as e {
        ; Config is corrupted - backup and reset to defaults
        try {
            backupFile := configFile . ".bak." . FormatTime(A_Now, "yyyyMMdd_HHmmss")
            FileMove(configFile, backupFile, true)
            LogWarn("Config corrupted - backed up to: " . backupFile)
        } catch {
            ; If backup fails, just delete the corrupted file
            try {
                FileDelete(configFile)
                LogWarn("Config corrupted - deleted corrupted file")
            } catch {
                ; Ignore deletion errors
            }
        }
        
        LogWarn("Config error - self-healing: " . e.Message)
        
        ; Reset to safe defaults
        UserLang := "en"
        geminiAPIkey := ""
        ModelName := "gemini-2.5-flash"
        LogInfo("Reset to default settings - user will be prompted for setup")
        return false
    }
}

; ############################################################################
; # INITIALIZATION RULES #
; ############################################################################

; MANDATORY initialization pattern
InitializeScript() {
global geminiAPIkey, UserLang, configFile


try {
    ; Initialize log file
    InitializeLog()

    ; Ensure AppData folder exists for config operations
    EnsureAppDataFolder()

    ; Validate and heal config if corrupted (self-healing system)
    configValid := ValidateAndHealConfig()
    
    ; If config was invalid/missing, load from fallback or prompt user
    if (!configValid) {
        ; Try to load from external file as fallback
        if (FileExist(filePath)) {
            try {
                fileKey := FileRead(filePath, "UTF-8")
                fileKey := Trim(fileKey, " `t`n`r")
                if (fileKey && StrLen(fileKey) >= 10) {
                    geminiAPIkey := fileKey
                    LogInfo("Loaded API key from external file as fallback")
                }
            } catch Error as e {
                LogWarn("Failed to read external API file: " . e.Message)
            }
        }
    }

    ; Ask Language once if not set or invalid
    if (UserLang = "" or (UserLang != "en" && UserLang != "ar" && UserLang != "auto")) {
        langInput := InputBox(T("AskLang"), "Sayf Text Fixer")
        if (langInput.Result = "OK" && langInput.Value ~= "i)^(ar|en|auto)$") {
            UserLang := langInput.Value
        } else {
            UserLang := "en"
        }
        IniWrite(UserLang, configFile, "Settings", "UserLang")
    }

    ; Handle API key - check config first, then fallback to external file, then prompt
    if (!geminiAPIkey or StrLen(Trim(geminiAPIkey)) < 10) {
        ; Try to load from external file as fallback
        if (FileExist(filePath)) {
            try {
                fileKey := FileRead(filePath, "UTF-8")
                fileKey := Trim(fileKey, " `t`n`r")
                if (fileKey && StrLen(fileKey) >= 10) {
                    geminiAPIkey := fileKey
                    ; Save to config for future use
                    IniWrite(geminiAPIkey, configFile, "Settings", "APIKey")
                }
            } catch {
                ; Ignore file read errors
            }
        }
        
        ; If still no valid key, show unified settings dialog
        if (!geminiAPIkey or StrLen(Trim(geminiAPIkey)) < 10) {
            ShowSettingsDialog()
            ; Check if API key was set after dialog
            if (!geminiAPIkey or StrLen(Trim(geminiAPIkey)) < 10) {
                MsgBox(T("ApiMissing"), "Critical Error", "IconX")
                ExitApp(1)
            }
        }
    }
    
    ; Log successful initialization with API key length for debugging
    LogInfo("Script initialized successfully with API key (" . StrLen(geminiAPIkey) . " chars) | Lang=" . UserLang)
    return true
    
} catch Error as e {
    ; Critical initialization error
    MsgBox("Failed to initialize Sayf Text Fixer: " . e.Message, "Critical Error", "IconX")
    ExitApp(1)
}
}

; ############################################################################
; # PROFESSIONAL STRUCTURED JSON LOGGING SYSTEM #
; ############################################################################

/**
 * Central JSON logging function - handles all log entries in valid JSON array format
 * @param entry - Map object containing log entry data
 */
LogJson(entry) {
    global logFile
    
    ; MANDATORY parameter validation
    if (!IsSet(entry) || Type(entry) != "Map") {
        throw ValueError("entry must be a Map object", A_ThisFunc)
    }
    
    fileHandle := ""
    try {
        ; Check and rotate log if needed
        RotateLogIfNeeded()
        
        ; Convert entry Map to JSON
        jsonEntry := JSON.Dump(entry, true)
        
        ; If log doesn't exist, start an array
        if (!FileExist(logFile)) {
            FileAppend("[`n" . jsonEntry . "`n]", logFile, "UTF-8")
            return true
        }
        
        ; Append into existing array (remove trailing "]")
        fileHandle := FileOpen(logFile, "r+", "UTF-8")
        if (!fileHandle) {
            throw OSError("Cannot open log file for update", A_ThisFunc)
        }
        
        ; Read last character to check format
        fileHandle.Seek(-2, 2)  ; Go to near end
        lastChars := fileHandle.Read(2)
        
        if (InStr(lastChars, "]")) {
            ; Valid JSON array - insert before closing bracket
            fileHandle.Seek(-1, 2)
            fileHandle.Write(",`n" . jsonEntry . "`n]")
        } else {
            ; Malformed file - fix it
            fileHandle.Seek(0, 2)  ; Go to end
            fileHandle.Write(",`n" . jsonEntry . "`n]")
        }
        
        return true
        
    } catch Error as e {
        ; Fallback to simple append if JSON array management fails
        try {
            FileAppend(jsonEntry . "`n", logFile, "UTF-8")
        } catch {
            ; Complete failure - log to Windows Event Log or ignore
        }
        return false
    } finally {
        if (fileHandle && fileHandle.Handle != -1) {
            fileHandle.Close()
        }
    }
}

/**
 * Rotate log file if it exceeds maximum size (5MB)
 * Creates timestamped backup and starts fresh JSON array
 */
RotateLogIfNeeded() {
    global logFile, MAX_LOG_SIZE
    
    ; MANDATORY parameter validation
    if (!IsSet(logFile) || Type(logFile) != "String") {
        return false  ; Silently fail if logFile not properly set
    }
    
    try {
        if (FileExist(logFile)) {
            ; Check file size
            fileSize := FileGetSize(logFile)
            if (!fileSize) {
                return false  ; Could not get file size
            }
            
            if (fileSize > MAX_LOG_SIZE) {
                ; Create timestamped backup
                timestamp := FormatTime(A_Now, "yyyyMMdd_HHmmss")
                backupFile := logFile . ".bak." . timestamp
                
                ; Move current log to backup
                FileMove(logFile, backupFile, true)
                
                ; Start fresh JSON array with rotation entry
                rotationEntry := Map(
                    "timestamp", FormatTime(A_Now, "yyyy-MM-dd HH:mm:ss"),
                    "type", "INFO",
                    "event", "LogRotated",
                    "lang", UserLang,
                    "chars_in", 0,
                    "chars_out", 0,
                    "result", "N/A",
                    "details", "Log rotated - archived to: " . backupFile . " (" . Round(fileSize / (1024*1024), 2) . " MB)"
                )
                
                ; Initialize new JSON array
                jsonEntry := JSON.Dump(rotationEntry, true)
                FileAppend("[`n" . jsonEntry . "`n]", logFile, "UTF-8")
                
                return true
            }
        }
        return false  ; No rotation needed
        
    } catch Error as e {
        ; Log rotation failed - continue with existing log
        return false
    }
}

; Ensure the AppData folder exists
EnsureAppDataFolder() {
global appDataFolder
try {
if (!DirExist(appDataFolder)) {
DirCreate(appDataFolder)
}
return true
} catch Error as e {
; Log the error but don't crash the application
return false
}
}

InitializeLog() {
    global logFile
    try {
        ; Ensure the AppData folder exists first
        EnsureAppDataFolder()
        
        if (!FileExist(logFile)) {
            ; Initialize with proper JSON array format and first entry
            initEntry := Map(
                "timestamp", FormatTime(A_Now, "yyyy-MM-dd HH:mm:ss"),
                "type", "INFO",
                "event", "LogInitialized",
                "lang", UserLang,
                "chars_in", 0,
                "chars_out", 0,
                "result", "N/A",
                "details", "Sayf Text Fixer log started - Version " . SCRIPT_VERSION
            )
            
            jsonEntry := JSON.Dump(initEntry, true)
            FileAppend("[`n" . jsonEntry . "`n]", logFile, "UTF-8")
        }
        return true
    } catch Error as e {
        ; If logging fails, continue without logging rather than crash
        return false
    }
}

; Wrapper functions for different log types using structured JSON format
LogInfo(message) {
    global UserLang
    LogJson(Map(
        "timestamp", FormatTime(A_Now, "yyyy-MM-dd HH:mm:ss"),
        "type", "INFO",
        "event", "General",
        "lang", UserLang,
        "chars_in", 0,
        "chars_out", 0,
        "result", "N/A",
        "details", message
    ))
}

LogWarn(message) {
    global UserLang
    LogJson(Map(
        "timestamp", FormatTime(A_Now, "yyyy-MM-dd HH:mm:ss"),
        "type", "WARN",
        "event", "General",
        "lang", UserLang,
        "chars_in", 0,
        "chars_out", 0,
        "result", "N/A",
        "details", message
    ))
}

LogError(message) {
    global UserLang
    LogJson(Map(
        "timestamp", FormatTime(A_Now, "yyyy-MM-dd HH:mm:ss"),
        "type", "ERROR",
        "event", "General",
        "lang", UserLang,
        "chars_in", 0,
        "chars_out", 0,
        "result", "N/A",
        "details", message
    ))
}

; Legacy LogMessage function for backward compatibility
LogMessage(level, message) {
    switch level {
        case "INFO": LogInfo(message)
        case "WARN": LogWarn(message) 
        case "ERROR": LogError(message)
        default: LogInfo(message)
    }
}

; ############################################################################
; #                          TRAY ICON + MENU                                #
; ############################################################################

SetupTrayMenu() {
    ; Set tray tooltip (hover text)
    A_IconTip := SCRIPT_NAME . " v" . SCRIPT_VERSION

    ; Clear default tray menu & add custom items
    A_TrayMenu.Delete()  ; Remove default entries
    A_TrayMenu.Add("⚙️  " . T("SelectLang") . " / API Settings", (*) => ShowSettingsDialog())
    A_TrayMenu.Add("📊  Professional Log Viewer", (*) => ShowLogViewer())
    A_TrayMenu.Add()  ; Separator
    A_TrayMenu.Add("❌  Exit", (*) => ExitApp())

    ; Update log menu item dynamically
    if !FileExist(logFile) {
        A_TrayMenu.Rename("📊  Professional Log Viewer", "📊  " . T("NoLog"))
    }
}

OpenLogFile() {
    global logFile
    if (FileExist(logFile)) {
        Run("notepad.exe " . logFile)
    } else {
        MouseGetPos(&mouseX, &mouseY)
        ToolTip(T("NoLog"), mouseX + 10, mouseY + 10)
        SetTimer(() => ToolTip(), -1500)
    }
}

/**
 * Professional Log Viewer with ListView table and filtering
 * Parses JSON array format and provides structured view
 */
ShowLogViewer() {
    global logFile, SCRIPT_NAME
    
    try {
        ; Create professional log viewer GUI
        logGui := Gui("+Resize", SCRIPT_NAME . " - Professional Log Viewer")
        logGui.SetFont("s9", "Segoe UI")
        logGui.MarginX := 10
        logGui.MarginY := 10
        
        ; Filter section
        logGui.AddText("x10 y10", "Filter:")
        filterDDL := logGui.AddDropDownList("x60 y8 w120", ["All", "INFO", "WARN", "ERROR", "SESSION"])
        filterDDL.Value := 1
        
        ; Log list table with sortable columns
        listView := logGui.AddListView("x10 y40 w780 h250 Grid Sort", ["Time", "Type", "Event/Result", "Input Len", "Output Len", "Details"])
        listView.ModifyCol(1, 140)  ; Time column
        listView.ModifyCol(2, 70)   ; Type column
        listView.ModifyCol(3, 100)  ; Event/Result column
        listView.ModifyCol(4, 80)   ; Input Length column
        listView.ModifyCol(5, 80)   ; Output Length column
        listView.ModifyCol(6, 300)  ; Details column
        
        ; Details panel for selected entry
        logGui.AddText("x10 y300 w200", "📋 Selected Entry Details:")
        detailsBox := logGui.AddEdit("x10 y320 w780 h150 ReadOnly VScroll")
        detailsBox.SetFont("s9", "Consolas")
        
        ; Control buttons
        refreshBtn := logGui.AddButton("x10 y480 w80 h25", "🔄 Refresh")
        clearBtn := logGui.AddButton("x100 y480 w80 h25", "🗑️ Clear Log")
        exportBtn := logGui.AddButton("x190 y480 w80 h25", "💾 Export")
        closeBtn := logGui.AddButton("x710 y480 w80 h25", "❌ Close")
        
        ; Load logs function
        LoadLogs() {
            listView.Delete() ; Clear table
            detailsBox.Value := "Click on a log entry above to see full details..."
            
            if (!FileExist(logFile)) {
                detailsBox.Value := "[No log file found]`n`nThe log file will be created when you start using the application."
                return
            }
            
            try {
                data := FileRead(logFile, "UTF-8")
                if (!data || StrLen(data) < 3) {
                    detailsBox.Value := "[Log file is empty]"
                    return
                }
                
                ; Parse JSON array
                parsed := JSON.Load(data)
                if (Type(parsed) != "Array") {
                    detailsBox.Value := "[Log file format error - not a valid JSON array]"
                    return
                }
                
                ; Populate ListView
                for entry in parsed {
                    ; Apply filter
                    if (filterDDL.Text != "All" && entry["type"] != filterDDL.Text) {
                        continue
                    }
                    
                    time := entry.Has("timestamp") ? entry["timestamp"] : "N/A"
                    typ := entry.Has("type") ? entry["type"] : "N/A"
                    
                    ; Determine event/result column
                    eventResult := ""
                    if (entry.Has("result") && entry["result"] != "N/A") {
                        eventResult := entry["result"]
                    } else if (entry.Has("event")) {
                        eventResult := entry["event"]
                    }
                    
                    cin := entry.Has("chars_in") ? String(entry["chars_in"]) : ""
                    cout := entry.Has("chars_out") ? String(entry["chars_out"]) : ""
                    
                    ; Create details preview (first 100 chars)
                    details := ""
                    if (entry.Has("details")) {
                        details := entry["details"]
                    } else if (entry.Has("input")) {
                        details := "Input: " . SubStr(entry["input"], 1, 50) . "..."
                    }
                    if (StrLen(details) > 100) {
                        details := SubStr(details, 1, 100) . "..."
                    }
                    
                    ; Add row to ListView
                    rowIndex := listView.Add("", time, typ, eventResult, cin, cout, details)
                }
                
                ; Update status
                logGui.Title := SCRIPT_NAME . " - Professional Log Viewer (" . parsed.Length . " entries)"
                
            } catch Error as e {
                detailsBox.Value := "Failed to parse log file: " . e.Message . "`n`nThe log file may be corrupted or in an old format."
            }
        }
        
        ; Event handlers
        filterDDL.OnEvent("Change", (*) => LoadLogs())
        
        ; Store references for event handlers
        logGui.ListView := listView
        logGui.DetailsBox := detailsBox
        
        listView.OnEvent("Click", HandleListViewClick)
        refreshBtn.OnEvent("Click", HandleRefreshClick)
        clearBtn.OnEvent("Click", HandleClearClick)
        exportBtn.OnEvent("Click", HandleExportClick)
        closeBtn.OnEvent("Click", HandleCloseClick)
        
        ; Store GUI reference for event handlers
        logGui.LoadLogsFunc := LoadLogs
        
        ; Initial load
        LoadLogs()
        
        ; Show the professional log viewer
        logGui.Show("w800 h520")
        
        LogInfo("Professional log viewer opened successfully")
        
        ; Event handler functions
        HandleListViewClick(ctrl, *) {
            row := ctrl.GetNext()
            if (!row) {
                return
            }
            
            selectedTime := ctrl.GetText(row, 1)
            
            try {
                data := FileRead(logFile, "UTF-8")
                parsed := JSON.Load(data)
                
                for entry in parsed {
                    if (entry.Has("timestamp") && entry["timestamp"] = selectedTime) {
                        detailsBox.Value := JSON.Dump(entry, true)
                        break
                    }
                }
            } catch Error as e {
                detailsBox.Value := "Error loading entry details: " . e.Message
            }
        }
        
        HandleRefreshClick(ctrl, *) {
            LoadLogs()
            LogInfo("Log viewer refreshed")
        }
        
        HandleClearClick(ctrl, *) {
            result := MsgBox("Are you sure you want to clear all logs?`n`nThis action cannot be undone.", "Clear Logs", "YesNo IconQuestion")
            if (result = "Yes") {
                try {
                    ; Backup before clearing
                    timestamp := FormatTime(A_Now, "yyyyMMdd_HHmmss")
                    backupFile := logFile . ".cleared." . timestamp
                    FileMove(logFile, backupFile, true)
                    
                    ; Start fresh JSON array
                    clearEntry := Map(
                        "timestamp", FormatTime(A_Now, "yyyy-MM-dd HH:mm:ss"),
                        "type", "INFO",
                        "event", "LogCleared",
                        "lang", UserLang,
                        "chars_in", 0,
                        "chars_out", 0,
                        "result", "N/A",
                        "details", "Log cleared by user - backup saved to: " . backupFile
                    )
                    
                    jsonEntry := JSON.Dump(clearEntry, true)
                    FileAppend("[`n" . jsonEntry . "`n]", logFile, "UTF-8")
                    
                    LoadLogs()
                    MsgBox("Logs cleared successfully.`nBackup saved to: " . backupFile, "Success", "IconInfo")
                } catch Error as e {
                    MsgBox("Failed to clear logs: " . e.Message, "Error", "IconX")
                }
            }
        }
        
        HandleExportClick(ctrl, *) {
            try {
                timestamp := FormatTime(A_Now, "yyyyMMdd_HHmmss")
                exportFile := FileSelect("S", "SayfTextFixer_Log_Export_" . timestamp . ".json", "Export Log File", "JSON Files (*.json)")
                if (exportFile) {
                    FileCopy(logFile, exportFile, true)
                    MsgBox("Log exported successfully to:`n" . exportFile, "Export Complete", "IconInfo")
                }
            } catch Error as e {
                MsgBox("Failed to export log: " . e.Message, "Export Error", "IconX")
            }
        }
        
        HandleCloseClick(ctrl, *) {
            logGui.Destroy()
            LogInfo("Log viewer closed")
        }
        
    } catch Error as e {
        LogError("Failed to show log viewer: " . e.Message)
        MouseGetPos(&mouseX, &mouseY)
        ToolTip("❌ Failed to open log viewer: " . e.Message, mouseX + 10, mouseY + 10)
        SetTimer(() => ToolTip(), -3000)
    }
}

; Legacy functions removed - now handled inline in ShowLogViewer()
; This maintains backward compatibility while using the new professional viewer

; ############################################################################
; #                 SMART ICON DOWNLOAD & AUTO-REFRESH (WEEKLY)              #
; ############################################################################

DownloadIconsSmart() {
    global appDataFolder, iconsFolder, iconFiles

    iconsFolder := appDataFolder . "\icons"
    if !DirExist(iconsFolder) {
        try {
            DirCreate(iconsFolder)
        } catch Error as e {
            LogError("Failed to create icons folder: " . e.Message)
            return
        }
    }

    ; Map all states to local cache paths
    iconFiles := Map(
        "ready",     iconsFolder . "\A-gray.ico",
        "valid",     iconsFolder . "\A-green.ico",
        "missing",   iconsFolder . "\A-red.ico",
        "processing",iconsFolder . "\A-yellow.ico",
        "error",     iconsFolder . "\A-red.ico"
    )

    ; Define GitHub raw icon URLs (permanent links)
    urls := Map(
        "ready",     "https://raw.githubusercontent.com/zSayf/SayfAiTextFixer/main/ICONS/A-gray.ico",
        "valid",     "https://raw.githubusercontent.com/zSayf/SayfAiTextFixer/main/ICONS/A-green.ico",
        "missing",   "https://raw.githubusercontent.com/zSayf/SayfAiTextFixer/main/ICONS/A-red.ico",
        "processing","https://raw.githubusercontent.com/zSayf/SayfAiTextFixer/main/ICONS/A-yellow.ico",
        "error",     "https://raw.githubusercontent.com/zSayf/SayfAiTextFixer/main/ICONS/A-red.ico"
    )

    ; Redownload if missing, broken, or too old
    for state, url in urls {
        localPath := iconFiles[state]
        needsDownload := false

        if !FileExist(localPath) {
            needsDownload := true
            LogInfo("Icon missing, will download: " . state)
        } else {
            ; Check file integrity (size > 100 bytes)
            try {
                file := FileOpen(localPath, "r")
                if (!file || file.Length < 100) { ; protect against broken/empty file
                    needsDownload := true
                    LogInfo("Icon corrupted, will redownload: " . state)
                } else {
                    ; Check if older than 7 days (604800 seconds)
                    try {
                        fileTime := FileGetTime(localPath, "M")
                        fileAge := DateDiff(A_Now, fileTime, "Seconds")
                        if (fileAge > 604800) { ; ~7 days
                            needsDownload := true
                            LogInfo("Icon older than 7 days, will refresh: " . state)
                        }
                    } catch Error as e {
                        LogWarn("Failed to check file age for " . state . ": " . e.Message)
                    }
                }
                if (IsObject(file))
                    file.Close()
            } catch Error as e {
                needsDownload := true
                LogWarn("Failed to read icon file " . state . ": " . e.Message)
            }
        }

        ; Download again if needed
        if (needsDownload) {
            try {
                http := ComObject("MSXML2.XMLHTTP")
                http.Open("GET", url, false)
                http.Send()
                if (http.status = 200) {
                    stream := ComObject("ADODB.Stream")
                    stream.Type := 1  ; Binary
                    stream.Open()
                    stream.Write(http.ResponseBody)
                    stream.SaveToFile(localPath, 2) ; Overwrite
                    stream.Close()
                    LogInfo("Downloaded/updated icon: " . state)
                } else {
                    LogWarn("Failed to download icon " . state . " HTTP " . http.status)
                }
            } catch Error as e {
                LogError("Error downloading icon " . state . ": " . e.Message)
            }
        }
    }
}

; ############################################################################
; #                          TRAY ICON DYNAMIC STATUS                        #
; ############################################################################

Tray_SetStatus(status := "ready") {
    global SCRIPT_NAME, SCRIPT_VERSION, iconFiles
    
    ; Try to use cached custom icon first, fallback to shell32 if needed
    if iconFiles.Has(status) && FileExist(iconFiles[status]) {
        try {
            TraySetIcon(iconFiles[status])
        } catch {
            TraySetIcon("shell32.dll", 1)  ; fallback generic app icon
        }
    } else {
        TraySetIcon("shell32.dll", 1)  ; fallback if icon missing
    }

    ; Update tooltip text
    switch status {
        case "ready":
            A_IconTip := SCRIPT_NAME . " v" . SCRIPT_VERSION . "`n📝 Ready"
        case "valid":
            A_IconTip := SCRIPT_NAME . " v" . SCRIPT_VERSION . "`n✅ API Key OK"
        case "missing":
            A_IconTip := SCRIPT_NAME . " v" . SCRIPT_VERSION . "`n❌ API Key Missing"
        case "processing":
            A_IconTip := SCRIPT_NAME . " v" . SCRIPT_VERSION . "`n🤔 Processing..."
        case "error":
            A_IconTip := SCRIPT_NAME . " v" . SCRIPT_VERSION . "`n⚠️ Error"
    }
}

; ############################################################################
; # LANGUAGE & BILINGUAL SUPPORT #
; ############################################################################

; MANDATORY Arabic text detection
IsArabicText(text) {
try {
; Parameter validation
if (!IsSet(text) || Type(text) != "String") {
return false
}
if (StrLen(text) = 0) {
return false
}


    arabicMatches := 0
    totalChars := StrLen(text)
    
    Loop Parse, text {
        charCode := Ord(A_LoopField)
        ; Arabic Unicode blocks
        if ((charCode >= 0x0600 && charCode <= 0x06FF) || 
            (charCode >= 0x0750 && charCode <= 0x077F) || 
            (charCode >= 0x08A0 && charCode <= 0x08FF)) {
            arabicMatches++
        }
    }
    
    arabicPercentage := (arabicMatches / totalChars) * 100
    return arabicPercentage > 20  ; Threshold: 20%
    
} catch Error as e {
    LogWarn("Arabic detection failed: " . e.Message)
    return false
}
}

; Generate language-appropriate correction prompt
GenerateCorrectionPrompt(inputText) {
global UserLang


if (UserLang = "auto") {
    ; Auto mode: detect language dynamically
    if IsArabicText(inputText)
        return "قم بتصحيح الأخطاء الإملائية والنحوية فقط في النص التالي. إذا لم توجد أخطاء، أعد النص كما هو تماماً. لا تضف أي تفسيرات أو تعليقات، فقط النص المصحح أو الأصلي:`n`n" . inputText
    else
        return "Correct only spelling and grammar errors in the following text. If there are no errors, return the text exactly as is. Do not add any explanations or comments, only the corrected or original text:`n`n" . inputText
}
else if (UserLang = "ar") {
    ; Arabic mode
    return "قم بتصحيح الأخطاء الإملائية والنحوية فقط في النص التالي. إذا لم توجد أخطاء، أعد النص كما هو تماماً. لا تضف أي تفسيرات أو تعليقات، فقط النص المصحح أو الأصلي:`n`n" . inputText
}
else {
    ; English mode (default)
    return "Correct only spelling and grammar errors in the following text. If there are no errors, return the text exactly as is. Do not add any explanations or comments, only the corrected or original text:`n`n" . inputText
}
}

; Generate "Improve Writing" prompt for concise rewriting
GenerateImprovementPrompt(inputText) {
    ; MANDATORY parameter validation
    if (!IsSet(inputText) || Type(inputText) != "String") {
        throw ValueError("inputText must be a string", A_ThisFunc)
    }
    
    ; Universal improvement prompt that works in any language
    return "Rewrite the following text, which will be delimited by triple quotes, "
        . "to be more concise and well-written while preserving the original meaning: "
        . Format('"""{}"""', inputText)
        . " Provide only the rewritten text as your output, without any quotes or tags. "
        . "Respond in the same language as the original text."
}

; ############################################################################
; # API VALIDATION FUNCTIONS #
; ############################################################################

; Validate API key with real Gemini API call
ValidateApiKey(apiKey) {
if (!apiKey || StrLen(Trim(apiKey)) < 10) {
return false
}


try {
    ; Simple validation test with minimal API call
    api := ComObject("MSXML2.XMLHTTP")
    testUrl := "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:streamGenerateContent?key=" . Trim(apiKey)
    
    api.Open("POST", testUrl, false)
    api.SetRequestHeader("Content-Type", "application/json")
    api.SetRequestHeader("User-Agent", "SayfTextFixer/" . SCRIPT_VERSION)
    
    ; Send minimal test request
    testData := JSON.Dump({contents:[{parts:[{text:"test"}]}]})
    api.Send(testData)
    
    ; Check if response indicates valid API key
    if (api.status = 200) {
        return true
    } else if (api.status = 400 && InStr(api.responseText, "API_KEY_INVALID")) {
        return false
    } else if (api.status = 403) {
        return false  ; Forbidden - invalid key
    }
    
    return false
} catch {
    return false  ; Network error or other issue
}
}

; Unified Settings Dialog with Language and API Key management
; Toggle password visibility helper function
TogglePassword(editCtrl, checkCtrl) {
    ; MANDATORY parameter validation
    if (!IsSet(editCtrl) || !IsSet(checkCtrl)) {
        throw ValueError("Required parameters missing", A_ThisFunc)
    }
    
    try {
        if (checkCtrl.Value) {
            editCtrl.Opt("-Password") ; Show text
            checkCtrl.Text := "🙈 Hide"
        } else {
            editCtrl.Opt("+Password") ; Mask again
            checkCtrl.Text := "👁 Show"
        }
        LogInfo("Password visibility toggled")
    } catch Error as e {
        LogError("Password toggle error: " . e.Message)
    }
}

ShowSettingsDialog() {
global geminiAPIkey, UserLang, configFile


; Create settings GUI
settingsGui := Gui("+AlwaysOnTop", "Sayf Text Fixer - Settings")
settingsGui.MarginX := 15
settingsGui.MarginY := 15

; Language selection
settingsGui.AddText("x15 y20 w120", T("SelectLang") . ":")
langDDL := settingsGui.AddDropDownList("vLang x140 y20 w150 Choose1", ["English (en)", "العربية (ar)", "Auto Detect (auto)"])

; Set current language selection
langIndex := (UserLang = "en") ? 1 : (UserLang = "ar" ? 2 : 3)
langDDL.Value := langIndex

; API Key input (masked as password by default)
settingsGui.AddText("x15 y70 w120", T("AskApi") . ":")
apiEdit := settingsGui.AddEdit("vApiKey x140 y70 w300 h20 Password")
apiEdit.Text := geminiAPIkey

; Show/Hide checkbox for password visibility
showCheck := settingsGui.AddCheckbox("x450 y70 w80", "👁 Show")
showCheck.OnEvent("Click", (*) => TogglePassword(apiEdit, showCheck))

; Model selection
settingsGui.AddText("x15 y120 w120", "AI Model:")
modelDDL := settingsGui.AddDropDownList("vModel x140 y120 w200", ["Gemini 2.5 Flash (Fast)", "Gemini 2.5 Pro (Accurate)"])
modelDDL.Value := (ModelName = "gemini-2.5-pro") ? 2 : 1

; Status indicator
statusText := settingsGui.AddText("vStatus x140 y150 w300 h20 cBlue", T("EnterApiKey"))

; Progress bar for API testing
progressBar := settingsGui.AddProgress("vProgress x140 y175 w300 h4 Range0-100", 0)
progressBar.Visible := false

; Enhanced button layout with unified Test & Save button and View Logs
testSaveBtn := settingsGui.AddButton("x140 y200 w120 h25", "✅ Test & Save")
viewLogBtn := settingsGui.AddButton("x270 y200 w90 h25", "📄 View Logs")
cancelBtn := settingsGui.AddButton("x370 y200 w80 h25", T("Cancel"))

; Validation state
lastValidatedKey := ""
isKeyValid := false
validationTimer := 0

; Real-time API key validation function
ValidateApiInput() {
    currentInput := Trim(apiEdit.Text)
    
    ; Clear existing validation timer
    if (validationTimer) {
        SetTimer(validationTimer, 0)
        validationTimer := 0
    }
    
    ; Basic length validation
    if (StrLen(currentInput) = 0) {
        statusText.Text := T("EnterApiKey")
        statusText.SetFont("cDefault")
        isKeyValid := false
        return
    }
    
    if (StrLen(currentInput) < 10) {
        statusText.Text := T("ApiTooShort")
        statusText.SetFont("cRed")
        isKeyValid := false
        return
    }
    
    ; If it's the same as last validated key, keep previous state
    if (currentInput = lastValidatedKey && isKeyValid) {
        statusText.Text := T("ApiValid")
        statusText.SetFont("cGreen")
        return
    }
    
    ; Show "not tested" status for new or changed keys
    if (currentInput != lastValidatedKey) {
        statusText.Text := T("ApiNotTested")
        statusText.SetFont("cBlue")
        isKeyValid := false
    }
}

; Test API Key function
TestApiKey(apiKey, statusCtrl, progressCtrl) {
    if (StrLen(apiKey) < 10) {
        statusCtrl.Text := T("ApiTooShort")
        statusCtrl.SetFont("cRed")
        isKeyValid := false
        return false
    }
    
    statusCtrl.Text := T("ApiValidating")
    statusCtrl.SetFont("cBlue")
    progressCtrl.Visible := true
    progressCtrl.Value := 0
    
    ; Animate progress
    progressStep := 0
    AnimateTestProgress()
    
    AnimateTestProgress() {
        progressStep += 10
        if (progressStep <= 90) {
            progressCtrl.Value := progressStep
            SetTimer(AnimateTestProgress, 100)
        }
    }
    
    ; Perform validation after animation
    SetTimer(PerformTest, -1000)
    
    PerformTest() {
        progressCtrl.Value := 100
        
        if (ValidateApiKey(apiKey)) {
            statusCtrl.Text := T("ApiValid")
            statusCtrl.SetFont("cGreen")
            isKeyValid := true
            lastValidatedKey := apiKey
            SetTimer(() => progressCtrl.Visible := false, -500)
            return true
        } else {
            statusCtrl.Text := T("ApiInvalid")
            statusCtrl.SetFont("cRed")
            isKeyValid := false
            SetTimer(() => progressCtrl.Visible := false, -500)
            return false
        }
    }
    
    return isKeyValid
}

; Save settings function - Only called from TestAndSave with valid keys
SaveSettings(langControl, modelControl, apiKey, guiObj, statusCtrl) {
    global UserLang, geminiAPIkey, ModelName, configFile
    
    ; MANDATORY parameter validation
    if (!IsSet(langControl) || !IsSet(modelControl) || !IsSet(apiKey) || !IsSet(guiObj) || !IsSet(statusCtrl)) {
        throw ValueError("Required parameters missing", A_ThisFunc)
    }
    
    ; Get selected language
    selectedLang := ""
    try {
        switch langControl.Value {
            case 1: selectedLang := "en"
            case 2: selectedLang := "ar"
            case 3: selectedLang := "auto"
            default: selectedLang := "en"  ; Fallback
        }
    } catch Error as e {
        LogError("Language selection error: " . e.Message)
        selectedLang := "en"  ; Safe fallback
    }
    
    ; Get selected model
    selectedModel := ""
    try {
        selectedModel := (modelControl.Value = 1) ? "gemini-2.5-flash" : "gemini-2.5-pro"
    } catch Error as e {
        LogError("Model selection error: " . e.Message)
        selectedModel := "gemini-2.5-flash"  ; Safe fallback
    }
    
    ; Validate API key length (should already be valid when called from TestAndSave)
    if (StrLen(apiKey) < 10) {
        statusCtrl.Text := T("ApiTooShort")
        statusCtrl.SetFont("cRed")
        LogWarn("SaveSettings called with invalid API key length")
        return false
    }
    
    ; Save settings only if key is valid
    try {
        ; Update global variables
        UserLang := selectedLang
        geminiAPIkey := apiKey
        ModelName := selectedModel
        
        ; Ensure AppData folder exists
        EnsureAppDataFolder()
        
        ; Write to INI file
        IniWrite(UserLang, configFile, "Settings", "UserLang")
        IniWrite(geminiAPIkey, configFile, "Settings", "APIKey")
        IniWrite(ModelName, configFile, "Settings", "Model")
        
        ; Update status - should show success since key was already validated
        statusCtrl.Text := T("SettingsUpdated")
        statusCtrl.SetFont("cGreen")
        
        LogInfo("Settings saved successfully: Lang=" . UserLang . ", Model=" . ModelName . ", API key length=" . StrLen(geminiAPIkey))
        return true
        
    } catch Error as e {
        statusCtrl.Text := T("SettingsFailed") . ": " . e.Message
        statusCtrl.SetFont("cRed")
        LogError("Failed to save settings: " . e.Message)
        return false
    }
}

; Test & Save combined function - Only saves if API key is valid
TestAndSave(langControl, modelControl, apiKey, guiObj, statusCtrl, progressCtrl) {
    ; MANDATORY parameter validation
    if (!IsSet(langControl) || !IsSet(modelControl) || !IsSet(apiKey) || !IsSet(guiObj) || !IsSet(statusCtrl) || !IsSet(progressCtrl)) {
        throw ValueError("Required parameters missing", A_ThisFunc)
    }
    
    ; Validate API key length first
    if (StrLen(apiKey) < 10) {
        statusCtrl.Text := T("ApiTooShort")
        statusCtrl.SetFont("cRed")
        return false
    }
    
    ; Start testing process
    statusCtrl.Text := T("ApiValidating")
    statusCtrl.SetFont("cBlue")
    progressCtrl.Visible := true
    progressCtrl.Value := 0
    
    ; Animate progress
    progressStep := 0
    AnimateTestAndSaveProgress()
    
    AnimateTestAndSaveProgress() {
        progressStep += 10
        if (progressStep <= 90) {
            progressCtrl.Value := progressStep
            SetTimer(AnimateTestAndSaveProgress, 100)
        }
    }
    
    ; Perform validation and save if successful
    SetTimer(PerformTestAndSave, -1000)
    
    PerformTestAndSave() {
        progressCtrl.Value := 100
        
        try {
            if (ValidateApiKey(apiKey)) {
                ; API key is valid - proceed with saving
                isKeyValid := true
                lastValidatedKey := apiKey
                
                ; Save settings
                if (SaveSettings(langControl, modelControl, apiKey, guiObj, statusCtrl)) {
                    statusCtrl.Text := "✅ " . T("ApiValid") . " - " . T("SettingsUpdated")
                    statusCtrl.SetFont("cGreen")
                    Tray_SetStatus("valid")
                    
                    ; Auto-close GUI after success
                    SetTimer(CloseGUIAfterSuccess, -1500)
                    
                    CloseGUIAfterSuccess() {
                        progressCtrl.Visible := false
                        guiObj.Destroy()
                    }
                    
                    LogInfo("Settings saved successfully with valid API key")
                    return true
                } else {
                    statusCtrl.Text := T("SettingsFailed")
                    statusCtrl.SetFont("cRed")
                    SetTimer(() => progressCtrl.Visible := false, -500)
                    return false
                }
            } else {
                ; API key is invalid - DO NOT save
                statusCtrl.Text := T("ApiInvalid") . " - Settings not saved"
                statusCtrl.SetFont("cRed")
                isKeyValid := false
                SetTimer(() => progressCtrl.Visible := false, -500)
                LogWarn("Settings not saved - invalid API key")
                return false
            }
        } catch Error as e {
            statusCtrl.Text := "❌ Test failed: " . e.Message
            statusCtrl.SetFont("cRed")
            SetTimer(() => progressCtrl.Visible := false, -500)
            LogError("TestAndSave error: " . e.Message)
            return false
        }
    }
    
    return false
}

; Event handlers
apiEdit.OnEvent("Change", (*) => ValidateApiInput())
testSaveBtn.OnEvent("Click", (*) => TestAndSave(langDDL, modelDDL, Trim(apiEdit.Text), settingsGui, statusText, progressBar))
viewLogBtn.OnEvent("Click", (*) => ShowLogViewer())
cancelBtn.OnEvent("Click", (*) => settingsGui.Destroy())

; Show the settings dialog
settingsGui.Show("w570 h240")

; Initial validation if there's existing text
if (geminiAPIkey && StrLen(geminiAPIkey) >= 10) {
    ValidateApiInput()
}
}

; ############################################################################
; # CORE FUNCTIONALITY #
; ############################################################################

/**

Enhanced proofreading function with mode support (fix/improve)
*/
ProofreadText(inputText, apikey, mode := "fix") {
; 1. MANDATORY parameter validation
if (!IsSet(inputText) || !IsSet(apikey)) {
throw ValueError("Required parameters missing", A_ThisFunc)
}
if (Type(inputText) != "String" || Type(apikey) != "String") {
throw TypeError("Parameters must be strings", A_ThisFunc)
}
if (StrLen(Trim(inputText)) < 1) {
throw ValueError("Input text cannot be empty", A_ThisFunc)
}
if (StrLen(Trim(apikey)) < 10) {
throw ValueError("Invalid API key", A_ThisFunc)
}
if (mode != "fix" && mode != "improve") {
throw ValueError("Mode must be 'fix' or 'improve'", A_ThisFunc)
}

; 2. Initialize resources (api is the main resource)
api := ""

; 3. MANDATORY try-catch-finally for risky operations (COM/Network)
try {
; Performance optimization: Static variable caching with dynamic model support
static cachedUrl := ""
static lastModelName := ""
if (!cachedUrl || lastModelName != ModelName) {
    cachedUrl := "https://generativelanguage.googleapis.com/v1beta/models/" . ModelName . ":streamGenerateContent?key=" . apikey
    lastModelName := ModelName
    LogInfo("API URL updated for model: " . ModelName)
}

; Pick correct prompt based on mode
if (mode = "improve") {
    prompt := GenerateImprovementPrompt(inputText)
} else {
    prompt := GenerateCorrectionPrompt(inputText)
}

LogInfo("Text processing mode: " . mode . " | Lang=" . UserLang . " | TextLen=" . StrLen(inputText))
 
 ; MANDATORY bilingual user feedback - Enhanced visibility
 MouseGetPos(&mouseX, &mouseY)
 ToolTip(T("Processing"), mouseX + 10, mouseY + 10)
 
 ; Update tray icon to processing state
 Tray_SetStatus("processing")
 
 ; Ensure processing message stays visible during API preparation
 Sleep(150)
 
 LogSession(inputText, "", mode)
 
 startTime := A_TickCount
 maxTimeout := 10000  ; 10 seconds timeout

 ; MANDATORY COM object handling with cleanup
 api := ComObject("MSXML2.XMLHTTP")
 if (!api) {
     throw OSError("Failed to create HTTP object", A_ThisFunc)
 }
 
 api.Open("POST", cachedUrl, false)
 api.SetRequestHeader("Content-Type", "application/json")
 api.SetRequestHeader("User-Agent", "SayfTextFixer/" . SCRIPT_VERSION)
 
 requestData := JSON.Dump({contents:[{parts:[{text:prompt}]}]})
 api.Send(requestData)
 
 ; MANDATORY timeout for loops with animated feedback
 dotCount := 0
 lastDotUpdate := A_TickCount
 while (api.readyState != 4) {
     if (A_TickCount - startTime > maxTimeout) {
         throw TimeoutError("Request timeout exceeded", A_ThisFunc)
     }
     
     ; Animated feedback every 500ms to show activity
     if (A_TickCount - lastDotUpdate > 500) {
         dotCount := Mod(dotCount + 1, 4)
         dots := StrReplace("....", ".", "", 4 - dotCount)
         animatedMsg := T("ProcessingDots") . dots
         ToolTip(animatedMsg, mouseX + 10, mouseY + 10)
         lastDotUpdate := A_TickCount
     }
     
     Sleep(25)
 }
 
 if (api.status < 200 || api.status >= 300) {
     errorMsg := Format("HTTP Error {1}: {2}", api.status, api.statusText)
     throw OSError(errorMsg, A_ThisFunc)
 }
 
 response := api.responseText
 if (!response) {
     throw ValueError("Empty response from API", A_ThisFunc)
 }
 
 correctedText := ProcessAndReplace(response, inputText)
 LogSession(inputText, correctedText, mode)
 
 MouseGetPos(&mouseX, &mouseY)
 if (correctedText != inputText) {
     ToolTip(T("Success"), mouseX + 10, mouseY + 10)
     LogInfo("Text correction completed successfully")
     Tray_SetStatus("valid")
 } else {
     ToolTip(T("NoChange"), mouseX + 10, mouseY + 10)
     LogInfo("Text analysis completed - no changes needed")
     Tray_SetStatus("ready")
 }
 SetTimer(() => ToolTip(), -1500)
 
 return correctedText
 
} catch TimeoutError as e {
MouseGetPos(&mouseX, &mouseY)
ToolTip(T("Timeout"), mouseX + 10, mouseY + 10)
SetTimer(() => ToolTip(), -3000)
LogError("Timeout: " . e.Message)
Tray_SetStatus("error")
return ""

} catch OSError as e {
MouseGetPos(&mouseX, &mouseY)
ToolTip(T("NetworkErr"), mouseX + 10, mouseY + 10)
SetTimer(() => ToolTip(), -3000)
LogError("Network error: " . e.Message)
Tray_SetStatus("error")
return ""

} catch Error as e {
MouseGetPos(&mouseX, &mouseY)
ToolTip(T("ProcessFail"), mouseX + 10, mouseY + 10)
SetTimer(() => ToolTip(), -3000)
LogError("Processing error: " . e.Message)
Tray_SetStatus("error")
return ""

} finally {
; 4. ALWAYS cleanup resources
if (api) {
try {
api := ""
} catch {
; Ignore cleanup errors
}
}
}
}

/**

Enhanced response processing with comprehensive error handling
*/
ProcessAndReplace(response, originalText) {
if (!IsSet(response) || !IsSet(originalText)) {
throw ValueError("Required parameters missing", A_ThisFunc)
}
if (Type(response) != "String" || Type(originalText) != "String") {
throw TypeError("Parameters must be strings", A_ThisFunc)
}
if (!response) {
throw ValueError("Empty response received", A_ThisFunc)
}

try {
cleanResponse := Trim(response, "[]nr `t")
if (!cleanResponse) {
throw ValueError("Invalid response format", A_ThisFunc)
}

 jsonObjects := SplitJSON(cleanResponse)
 if (!jsonObjects || jsonObjects.Length = 0) {
     throw ValueError("No valid JSON objects found", A_ThisFunc)
 }
 
 MouseGetPos(&mouseX, &mouseY)
 Send("{Delete}")
 
 ; Performance optimization: Build text first, then send
 fullText := ""
 
 for index, jsonStr in jsonObjects {
     try {
         data := JSON.load(jsonStr)
         if (data.Has("candidates") && data["candidates"].Length > 0) {
             candidate := data["candidates"][1]
             if (candidate.Has("content") && candidate["content"].Has("parts") && candidate["content"]["parts"].Length > 0) {
                 newChunk := candidate["content"]["parts"][1]["text"]
                 if (newChunk) {
                     fullText .= newChunk
                 }
             }
         }
     } catch Error as e {
         LogWarn("Failed to process JSON chunk: " . e.Message)
         continue
     }
 }
 
 if (!fullText) {
     LogWarn("No text extracted from response, using original")
     fullText := originalText
 }
 
 ; Clean up the response if AI added explanations
 fullText := CleanAIResponse(fullText, originalText)
 
 ReplaceSelectedText(fullText)
 ToolTip(T("Writing"), mouseX + 10, mouseY + 10)
 
 return fullText
 
} catch ValueError as e {
MouseGetPos(&mouseX, &mouseY)
ToolTip(T("InvalidResp"), mouseX + 10, mouseY + 10)
SetTimer(() => ToolTip(), -2000)
LogError("Response processing error: " . e.Message)
ReplaceSelectedText(originalText)
return originalText

} catch Error as e {
MouseGetPos(&mouseX, &mouseY)
ToolTip(T("ProcessFail"), mouseX + 10, mouseY + 10)
SetTimer(() => ToolTip(), -2000)
LogError("Processing error: " . e.Message)
ReplaceSelectedText(originalText)
return originalText
}
}

; ############################################################################
; # HELPER FUNCTIONS #
; ############################################################################

; Clean AI response to extract only the corrected text
CleanAIResponse(response, originalText) {
if (!response || response = "") {
return originalText
}


; If response is much longer than original text, AI likely added explanations
if (StrLen(response) > StrLen(originalText) * 3) {
    ; Try to extract the original text if it appears in the response
    if (InStr(response, originalText)) {
        return originalText  ; Return original if no real correction was made
    }
    
    ; Look for quoted text or text that looks like the corrected version
    lines := StrSplit(response, "`n")
    for index, line in lines {
        line := Trim(line)
        ; Skip empty lines and lines that look like explanations
        if (line = "" || InStr(line, "النص") || InStr(line, "text") || InStr(line, "لا يمكن") || InStr(line, "cannot")) {
            continue
        }
        ; If we find a short line that's similar in length to original, use it
        if (StrLen(line) <= StrLen(originalText) * 2 && StrLen(line) > 0) {
            return line
        }
    }
}

return response  ; Return as-is if no cleanup needed
}

; Split JSON helper
SplitJSON(jsonString) {
jsonObjects := []
currentObject := ""
braceCount := 0
inString := false
escapeNext := false


Loop Parse, jsonString {
    char := A_LoopField
    
    if (escapeNext) {
        escapeNext := false
        currentObject .= char
        continue
    }
    if (char == "\") {
        escapeNext := true
        currentObject .= char
        continue
    }
    if (char == '"') {
        inString := !inString
    }
    if (!inString) {
        if (char == "{") {
            braceCount++
        } else if (char == "}") {
            braceCount--
        }
    }
    currentObject .= char
    
    if (!inString && braceCount == 0 && Trim(currentObject) != "") {
        objToPush := Trim(currentObject, " `t`n`r,")
        if (SubStr(objToPush, 1, 1) == "{") {
            jsonObjects.Push(objToPush)
            currentObject := ""
        }
    }
}
return jsonObjects
}

; ############################################################################
; # ENHANCED SESSION LOGGING WITH JSON ARRAY FORMAT #
; ############################################################################

/**
 * Log text processing session using structured JSON array format
 * @param inputText - Original text before processing
 * @param outputText - Processed text after AI correction
 * @param mode - Processing mode ("fix" or "improve")
 */
LogSession(inputText, outputText, mode := "fix") {
    global UserLang
    
    ; MANDATORY parameter validation
    if (!IsSet(inputText)) {
        throw ValueError("inputText parameter is required", A_ThisFunc)
    }
    if (!IsSet(outputText)) {
        outputText := ""  ; Allow empty output for failed processing
    }
    if (!IsSet(mode) || (mode != "fix" && mode != "improve")) {
        mode := "fix"  ; Default to fix mode
    }
    
    try {
        cleanInput := CleanTextForLogging(inputText)
        cleanOutput := CleanTextForLogging(outputText)
        
        ; Determine processing result
        result := ""
        if (outputText = "") {
            result := "Failed"
        } else if (inputText = outputText) {
            result := "No changes"
        } else {
            result := (mode = "improve") ? "Improved" : "Corrected"
        }
        
        ; Create structured session entry using central LogJson function
        sessionEntry := Map(
            "timestamp", FormatTime(A_Now, "yyyy-MM-dd HH:mm:ss"),
            "type", "SESSION",
            "event", (mode = "improve") ? "Improvement" : "Correction",
            "lang", UserLang,
            "mode", mode,
            "chars_in", StrLen(inputText),
            "chars_out", StrLen(outputText),
            "result", result,
            "input", cleanInput,
            "output", cleanOutput
        )
        
        ; Use central JSON logging function to maintain valid array format
        LogJson(sessionEntry)
        
        ; Also log summary as INFO for quick reference
        LogInfo("Text " . mode . " session: " . result . " (" . StrLen(inputText) . " → " . StrLen(outputText) . " chars)")
        
    } catch Error as e {
        LogError("Failed to write session log: " . e.Message)
    }
}

; ############################################################################
; # FAST & SAFE TEXT REPLACEMENT #
; ############################################################################

/**
 * Replace selected text using clipboard paste method (fast & reliable)
 * @param newText - The corrected text to replace the selection with
 */
ReplaceSelectedText(newText) {
    ; MANDATORY parameter validation
    if (!IsSet(newText)) {
        throw ValueError("newText parameter is required", A_ThisFunc)
    }
    if (Type(newText) != "String") {
        throw TypeError("newText must be a string", A_ThisFunc, newText)
    }
    
    ; Initialize resources
    oldClip := ""
    clipboardRestored := false
    
    try {
        ; Backup current clipboard content
        LogInfo("Clipboard: Starting backup of existing clipboard")
        oldClip := ClipboardAll()
        LogInfo("Clipboard: Backup completed, clearing clipboard")
        
        A_Clipboard := ""         ; Clear current clipboard
        Sleep(50)                 ; Give OS time to process clear
        LogInfo("Clipboard: Cleared, setting new text (" . StrLen(newText) . " chars)")

        ; Put corrected text into clipboard
        A_Clipboard := newText
        
        ; MANDATORY custom timeout loop (no ClipWait as per coding standards)
        LogInfo("Clipboard: Waiting for clipboard to update...")
        clipStartTime := A_TickCount
        while (!A_Clipboard && (A_TickCount - clipStartTime < 2000)) { ; 2s timeout
            Sleep(10)  ; Prevent tight loop - MANDATORY
        }
        
        if (!A_Clipboard) {
            LogError("Clipboard: Timeout - failed to update within 2 seconds")
            throw TimeoutError("Clipboard operation timeout", A_ThisFunc)
        }
        LogInfo("Clipboard: Successfully set new text, sending paste command")

        ; Replace selected text with paste operation
        Send("^v")                ; Ctrl+V for instant paste
        LogInfo("Clipboard: Paste command sent, waiting for completion...")
        
        ; CRITICAL: Wait longer for paste to complete before restoring clipboard
        ; This prevents the race condition where target app reads old clipboard
        Sleep(300)                ; Increased from 50ms to 300ms
        LogInfo("Clipboard: Paste completed, restoring original clipboard")
        
        ; Now restore original clipboard after paste has completed
        A_Clipboard := oldClip
        clipboardRestored := true
        LogInfo("Clipboard: Original clipboard restored successfully")
        
        LogInfo("Text replaced successfully via clipboard paste")
        
    } catch TimeoutError as e {
        LogError("Clipboard timeout: " . e.Message)
        ; Try to restore clipboard on timeout
        if (oldClip != "" && !clipboardRestored) {
            try {
                A_Clipboard := oldClip
            } catch {
                ; Ignore restore errors on timeout
            }
        }
        throw e
    } catch Error as e {
        LogError("Text replacement error: " . e.Message)
        ; Try to restore clipboard on error
        if (oldClip != "" && !clipboardRestored) {
            try {
                A_Clipboard := oldClip
            } catch {
                ; Ignore restore errors
            }
        }
        throw e
    }
}

; Modified logging function - writes new entries at the top


; Enhanced text cleaning for proper logging with Arabic support
CleanTextForLogging(text) {
if (text == "") {
return ""
}
cleanText := text
try {
cleanText := StrReplace(cleanText, "n", "[LF]")         cleanText := StrReplace(cleanText, "r", "[CR]")
} catch {
return text
}
return cleanText
}

; ############################################################################
; # HOTKEY IMPLEMENTATION RULES #
; ############################################################################

; Main hotkey - Ctrl+Alt+S with custom GUI mode selection
^!s:: {
startTime := A_TickCount

try {
    if (!geminiAPIkey || StrLen(Trim(geminiAPIkey)) < 10) {
        MouseGetPos(&mouseX, &mouseY)
        ToolTip(T("ApiMissing"), mouseX + 10, mouseY + 10)
        SetTimer(() => ToolTip(), -3000)
        LogError("API key validation failed")
        return
    }
    
    ; MANDATORY clipboard handling with timeout
    oldClipboard := A_Clipboard
    A_Clipboard := ""
    Send("^c")
    
    clipStartTime := A_TickCount
    while (!A_Clipboard && (A_TickCount - clipStartTime < 1000)) {
        Sleep(10)
    }
    
    if (!A_Clipboard) {
        MouseGetPos(&mouseX, &mouseY)
        ToolTip(T("NoText"), mouseX + 10, mouseY + 10)
        SetTimer(() => ToolTip(), -2000)
        LogWarn("No text was selected for correction")
        A_Clipboard := oldClipboard
        return
    }
    
    selectedText := A_Clipboard
    A_Clipboard := oldClipboard
    
    trimmedText := Trim(selectedText)
    if (StrLen(trimmedText) < 1) {
        MouseGetPos(&mouseX, &mouseY)
        ToolTip(T("EmptyText"), mouseX + 10, mouseY + 10)
        SetTimer(() => ToolTip(), -2000)
        LogWarn("Selected text was empty after trimming")
        return
    }
    
    if (StrLen(trimmedText) > 5000) {
        MouseGetPos(&mouseX, &mouseY)
        ToolTip(T("TooLong"), mouseX + 10, mouseY + 10)
        SetTimer(() => ToolTip(), -3000)
        LogWarn("Selected text exceeds maximum length: " . StrLen(trimmedText))
        return
    }
    
    ; === Custom GUI Choice Window ===
    choiceGui := Gui("+AlwaysOnTop -SysMenu", "Choose Action - Sayf Text Fixer")
    choiceGui.SetFont("s10", "Segoe UI")
    choiceGui.MarginX := 20
    choiceGui.MarginY := 15
    
    ; Header text
    choiceGui.AddText("x20 y15 w260 h40 Center", 
        "What would you like to do with the selected text?")
    
    ; Action buttons with icons
    btnFix := choiceGui.AddButton("x40 y65 w200 h35", "📝 Fix Spelling & Grammar")
    btnImprove := choiceGui.AddButton("x40 y110 w200 h35", "✨ Improve Writing")
    btnCancel := choiceGui.AddButton("x40 y155 w200 h35", "❌ Cancel")
    
    ; Set button styles
    btnFix.SetFont("s10 Bold")
    btnImprove.SetFont("s10 Bold")
    btnCancel.SetFont("s10")
    
    ; Store selected text for button handlers
    choiceGui.SelectedText := trimmedText
    
    ; Event handlers
    btnFix.OnEvent("Click", HandleFixClick)
    btnImprove.OnEvent("Click", HandleImproveClick)
    btnCancel.OnEvent("Click", HandleCancelClick)
    
    ; GUI event handlers
    choiceGui.OnEvent("Escape", HandleCancelClick)
    choiceGui.OnEvent("Close", HandleCancelClick)
    
    ; Show the choice window
    choiceGui.Show("w280 h210")
    
    LogInfo(Format("Mode selection GUI shown for {1} characters", StrLen(trimmedText)))
    
    ; Button handler functions
    HandleFixClick(ctrl, *) {
        gui := ctrl.Gui
        selectedText := gui.SelectedText
        gui.Destroy()
        
        MouseGetPos(&mouseX, &mouseY)
        ToolTip("📝 Starting grammar fix...", mouseX + 10, mouseY + 10)
        Sleep(100)
        
        LogInfo("User selected Fix mode")
        ProofreadText(selectedText, geminiAPIkey, "fix")
    }
    
    HandleImproveClick(ctrl, *) {
        gui := ctrl.Gui
        selectedText := gui.SelectedText
        gui.Destroy()
        
        MouseGetPos(&mouseX, &mouseY)
        ToolTip("✨ Starting writing improvement...", mouseX + 10, mouseY + 10)
        Sleep(100)
        
        LogInfo("User selected Improve mode")
        ProofreadText(selectedText, geminiAPIkey, "improve")
    }
    
    HandleCancelClick(ctrl, *) {
        ctrl.Gui.Destroy()
        
        MouseGetPos(&mouseX, &mouseY)
        ToolTip("❌ Operation cancelled", mouseX + 10, mouseY + 10)
        SetTimer(() => ToolTip(), -1500)
        
        LogInfo("User cancelled mode selection")
    }
    
} catch Error as e {
    MouseGetPos(&mouseX, &mouseY)
    ToolTip(T("Unexpected") . ": " . e.Message, mouseX + 10, mouseY + 10)
    SetTimer(() => ToolTip(), -3000)
    LogError("Hotkey error: " . e.Message)
} finally {
    if (IsSet(oldClipboard)) {
        try {
            A_Clipboard := oldClipboard
        } catch {
            ; Ignore clipboard restore errors
        }
    }
}
}

; View log - Ctrl+Alt+D (Professional Log Viewer)
^!d:: {
try {
    ShowLogViewer()
} catch Error as e {
    MouseGetPos(&mouseX, &mouseY)
    ToolTip("❌ Failed to open log viewer: " . e.Message, mouseX + 10, mouseY + 10)
    SetTimer(() => ToolTip(), -3000)
    LogError("Log viewer hotkey error: " . e.Message)
}
}

; Settings Management - Ctrl+Alt+M (Unified Dialog)
^!m:: {
try {
ShowSettingsDialog()
} catch Error as e {
MouseGetPos(&mouseX, &mouseY)
ToolTip(T("SettingsFailed") . ": " . e.Message, mouseX + 10, mouseY + 10)
SetTimer(() => ToolTip(), -3000)
LogError("Settings dialog error: " . e.Message)
}
}

; Hide tooltip - Esc
Esc::ToolTip()

; ############################################################################
; # GRACEFUL SHUTDOWN RULES #
; ############################################################################
OnExit(CleanupAndExit)

CleanupAndExit(ExitReason, ExitCode) {
try {
LogInfo(T("Shutdown") . ": " . ExitReason)
ToolTip()
LogInfo("Shutdown completed successfully")
} catch Error as e {
try {
FileAppend("[ERROR] Shutdown error: " . e.Message . "`n", logFile, "UTF-8")
}
}
}

; ############################################################################
; #                          SCRIPT ENTRY POINT                              #
; ############################################################################
try {
    InitializeScript()
    SetupTrayMenu()         ; ✅ Setup tray menu at startup
    DownloadIconsSmart()    ; ✅ Smart download & weekly refresh cache
    
    ; Set initial tray status based on API key
    if (geminiAPIkey && StrLen(geminiAPIkey) >= 10) {
        Tray_SetStatus("valid")
    } else {
        Tray_SetStatus("missing")
    }
    
    MouseGetPos(&mouseX, &mouseY)
    startupMsg := T("Ready") . "`nCtrl+Alt+S: Fix text | إصلاح النص`nCtrl+Alt+D: View log | عرض السجل`nCtrl+Alt+M: Settings | الإعدادات"
    ToolTip(startupMsg, mouseX + 10, mouseY + 10)
    SetTimer(() => ToolTip(), -5000) ; Auto-hide after 5 seconds
    
} catch Error as e {
    Tray_SetStatus("error")
    MsgBox("Startup failed: " . e.Message, "Critical Error", "IconX")
    ExitApp(1)
}
