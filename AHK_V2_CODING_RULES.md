# AutoHotkey v2 Coding Rules for IDE - Sayf AI Text Fix Standards

## MANDATORY SCRIPT HEADER
```autohotkey
#Requires AutoHotkey v2.0+
#SingleInstance Force
; UTF-8 BOM for proper text encoding (especially Arabic)
FileEncoding("UTF-8-RAW")

; Include required libraries
#include JSON.ahk

; Global constants
SCRIPT_NAME := "YourScriptName"
SCRIPT_VERSION := "1.0.0"
```

## CRITICAL ERROR HANDLING RULES

### 1. ALWAYS implement global error handler
```autohotkey
OnError(GlobalErrorHandler)

GlobalErrorHandler(exception, mode) {
    errorMsg := Format("[{1}] Error: {2}\nFile: {3}\nLine: {4}\nWhat: {5}\nStack: {6}",
        FormatTime(, "yyyy-MM-dd HH:mm:ss"), exception.Message, exception.File, 
        exception.Line, exception.What, exception.Stack)
    
    ; Write to log file
    try {
        FileAppend(errorMsg . "`n", logFile, "UTF-8")
    }
    
    ; Show user-friendly message
    MouseGetPos(&mouseX, &mouseY)
    ToolTip("❌ Unexpected error occurred", mouseX + 10, mouseY + 10)
    SetTimer(() => ToolTip(), -3000)
    
    ; Return 1 to suppress default error dialog
    return 1
}
```

### 2. MANDATORY parameter validation pattern
```autohotkey
YourFunction(param1, param2, param3?) {
    ; Check if required parameters are set
    if (!IsSet(param1) || !IsSet(param2)) {
        throw ValueError("Required parameters missing", A_ThisFunc)
    }
    
    ; Validate parameter types
    if (Type(param1) != "String") {
        throw TypeError("param1 must be a string", A_ThisFunc, param1)
    }
    
    if (Type(param2) != "Integer") {
        throw TypeError("param2 must be an integer", A_ThisFunc, param2)
    }
    
    ; Validate parameter values
    if (StrLen(Trim(param1)) < 1) {
        throw ValueError("param1 cannot be empty", A_ThisFunc)
    }
    
    ; Handle optional parameters
    if (!IsSet(param3)) {
        param3 := "default_value"
    }
    
    ; Function logic here
}
```

### 3. MANDATORY try-catch-finally for risky operations
```autohotkey
SafeOperation() {
    resource := ""
    try {
        ; Risky operations
        resource := AcquireResource()
        result := ProcessResource(resource)
        return result
        
    } catch ValueError as e {
        ; Handle specific errors first
        LogError("Value error: " . e.Message)
        return ""
    } catch TypeError as e {
        LogError("Type error: " . e.Message)
        return ""
    } catch Error as e {
        ; Handle general errors last
        LogError("General error: " . e.Message)
        return ""
    } finally {
        ; ALWAYS cleanup resources
        if (resource) {
            try {
                ReleaseResource(resource)
            } catch {
                ; Ignore cleanup errors
            }
        }
    }
}
```

## FILE AND RESOURCE HANDLING RULES

### 1. ALWAYS validate file existence
```autohotkey
SafeFileOperation(filePath) {
    ; Validate parameter
    if (!IsSet(filePath) || Type(filePath) != "String") {
        throw TypeError("filePath must be a string", A_ThisFunc)
    }
    
    ; Check file exists
    if (!FileExist(filePath)) {
        throw TargetError("File not found: " . filePath, A_ThisFunc)
    }
    
    ; Check if it's actually a file (not directory)
    attributes := FileExist(filePath)
    if (InStr(attributes, "D")) {
        throw ValueError("Expected file but found directory: " . filePath, A_ThisFunc)
    }
    
    return true
}
```

### 2. MANDATORY file handle cleanup
```autohotkey
SafeFileRead(filePath) {
    fileHandle := ""
    try {
        SafeFileOperation(filePath)  ; Validate first
        
        fileHandle := FileOpen(filePath, "r", "UTF-8")
        if (!fileHandle) {
            throw OSError("Cannot open file: " . filePath, A_ThisFunc)
        }
        
        content := fileHandle.Read()
        return content
        
    } catch Error as e {
        throw e  ; Re-throw to caller
    } finally {
        ; ALWAYS close file handle
        if (fileHandle && fileHandle.Handle != -1) {
            fileHandle.Close()
        }
    }
}
```

## COM OBJECT HANDLING RULES

### 1. MANDATORY COM cleanup pattern
```autohotkey
SafeCOMOperation() {
    comObj := ""
    try {
        comObj := ComObject("MSXML2.XMLHTTP")
        if (!comObj) {
            throw OSError("Failed to create COM object", A_ThisFunc)
        }
        
        ; Configure and use COM object
        comObj.Open("GET", url, false)
        comObj.Send()
        
        return comObj.ResponseText
        
    } catch Error as e {
        throw e
    } finally {
        ; ALWAYS cleanup COM object
        if (comObj) {
            try {
                comObj := ""
            } catch {
                ; Ignore cleanup errors
            }
        }
    }
}
```

## TIMEOUT AND PERFORMANCE RULES

### 1. MANDATORY timeout for loops
```autohotkey
SafeWaitOperation(condition, timeout := 5000) {
    startTime := A_TickCount
    
    while (condition.Call()) {
        if (A_TickCount - startTime > timeout) {
            throw TimeoutError("Operation timeout exceeded", A_ThisFunc)
        }
        Sleep(10)  ; Prevent tight loop - MANDATORY
    }
}
```

### 2. MANDATORY clipboard handling with timeout
```autohotkey
SafeClipboardGet(timeout := 1000) {
    oldClipboard := A_Clipboard
    A_Clipboard := ""
    Send("^c")
    
    ; Custom timeout loop (faster than ClipWait)
    startTime := A_TickCount
    while (!A_Clipboard && (A_TickCount - startTime < timeout)) {
        Sleep(10)  ; Fast polling
    }
    
    if (!A_Clipboard) {
        A_Clipboard := oldClipboard
        throw TimeoutError("Clipboard operation timeout", A_ThisFunc)
    }
    
    selectedText := A_Clipboard
    A_Clipboard := oldClipboard
    return selectedText
}
```

## LANGUAGE DETECTION AND BILINGUAL SUPPORT

### 1. MANDATORY Arabic text detection
```autohotkey
IsArabicText(text) {
    try {
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
```

### 2. MANDATORY bilingual user feedback
```autohotkey
ShowBilingualMessage(englishMsg, arabicMsg, x?, y?) {
    if (!IsSet(x) || !IsSet(y)) {
        MouseGetPos(&x, &y)
        x += 10
        y += 10
    }
    
    ; Always provide both languages or detect context
    message := englishMsg . " | " . arabicMsg
    ToolTip(message, x, y)
}
```

## LOGGING RULES

### 1. MANDATORY logging functions
```autohotkey
LogInfo(message) => LogMessage("INFO", message)
LogWarn(message) => LogMessage("WARN", message)
LogError(message) => LogMessage("ERROR", message)

LogMessage(level, message) {
    try {
        timestamp := FormatTime(, "yyyy-MM-dd HH:mm:ss")
        logEntry := Format("[{1}] {2}: {3}`n", timestamp, level, message)
        FileAppend(logEntry, logFile, "UTF-8")
    } catch {
        ; Silently fail if logging unavailable
    }
}
```

## INITIALIZATION RULES

### 1. MANDATORY initialization pattern
```autohotkey
InitializeScript() {
    try {
        ; Validate critical dependencies
        ValidateDependencies()
        
        ; Initialize logging
        InitializeLogging()
        
        ; Load configuration
        LoadConfiguration()
        
        ; Setup error handling
        SetupErrorHandling()
        
        LogInfo("Script initialized successfully")
        return true
        
    } catch Error as e {
        ; Critical initialization error
        MsgBox("Failed to initialize: " . e.Message, "Critical Error", "IconX")
        ExitApp(1)
    }
}
```

### 2. MANDATORY graceful shutdown
```autohotkey
OnExit(CleanupAndExit)

CleanupAndExit(ExitReason, ExitCode) {
    try {
        LogInfo("Script shutting down: " . ExitReason)
        
        ; Clear any active tooltips
        ToolTip()
        
        ; Close open resources
        CleanupResources()
        
        LogInfo("Shutdown completed successfully")
        
    } catch Error as e {
        try {
            LogError("Shutdown error: " . e.Message)
        }
    }
}
```

## PERFORMANCE OPTIMIZATION RULES

### 1. MANDATORY static variable caching
```autohotkey
GetCachedValue(key, factory) {
    static cache := Map()
    
    if (cache.Has(key)) {
        return cache[key]
    }
    
    value := factory.Call()
    cache[key] := value
    return value
}
```

### 2. MANDATORY efficient string building
```autohotkey
BuildLargeString(items) {
    if (Type(items) != "Array") {
        throw TypeError("Expected Array", A_ThisFunc, items)
    }
    
    ; Use array for efficient building
    parts := []
    for item in items {
        parts.Push(String(item))
    }
    
    ; Join all at once - more efficient
    return parts.Join("`n")
}
```

## FORBIDDEN PATTERNS

### ❌ NEVER DO THESE:
1. **Don't use variables without IsSet() check**
2. **Don't create loops without Sleep() and timeout**
3. **Don't use COM objects without try-finally cleanup**
4. **Don't use file operations without existence check**
5. **Don't ignore error types - always catch specific first**
6. **Don't use tight polling loops - always include delays**
7. **Don't forget UTF-8 encoding for international text**
8. **Don't use ClipWait - implement custom timeout logic**
9. **Don't show tooltips without mouse position**
10. **Don't skip parameter validation in functions**

## HOTKEY IMPLEMENTATION RULES

### 1. MANDATORY hotkey error handling
```autohotkey
^!s:: {
    try {
        ; Validate preconditions
        ValidatePreconditions()
        
        ; Get selected text safely
        selectedText := SafeClipboardGet()
        
        ; Validate input
        trimmedText := Trim(selectedText)
        if (!trimmedText || StrLen(trimmedText) < 1) {
            MouseGetPos(&mouseX, &mouseY)
            ToolTip("❌ No text selected | لم يتم تحديد نص", mouseX + 10, mouseY + 10)
            SetTimer(() => ToolTip(), -2000)
            return
        }
        
        ; Process text with error handling
        result := ProcessText(trimmedText)
        
    } catch Error as e {
        MouseGetPos(&mouseX, &mouseY)
        ToolTip("❌ Error: " . e.Message, mouseX + 10, mouseY + 10)
        SetTimer(() => ToolTip(), -3000)
        LogError("Hotkey error: " . e.Message)
    }
}
```

## VALIDATION CHECKLIST FOR IDE

Before generating any AutoHotkey v2 code, verify:

✅ **Script Header**: Includes #Requires AutoHotkey v2.0+, #SingleInstance Force, UTF-8 encoding
✅ **Global Error Handler**: OnError() implemented with return 1
✅ **Parameter Validation**: All functions validate parameters with IsSet() and Type()
✅ **Error Handling**: Try-catch-finally for all risky operations
✅ **Resource Cleanup**: Finally blocks clean up all resources
✅ **Timeout Mechanisms**: All loops and waits have timeout protection
✅ **File Operations**: Always check FileExist() before file operations
✅ **COM Objects**: Always cleaned up in finally blocks
✅ **Logging**: All errors and important events logged
✅ **Bilingual Support**: UI messages support both English and Arabic
✅ **Performance**: Static caching and efficient string operations used
✅ **Sleep in Loops**: All loops include Sleep() to prevent tight loops

## EXAMPLE TEMPLATE FOR NEW FUNCTIONS

```autohotkey
/**
 * Template for new function - ALWAYS follow this pattern
 */
YourNewFunction(requiredParam, optionalParam?) {
    ; 1. Parameter validation
    if (!IsSet(requiredParam)) {
        throw ValueError("requiredParam is required", A_ThisFunc)
    }
    
    if (Type(requiredParam) != "String") {
        throw TypeError("requiredParam must be string", A_ThisFunc, requiredParam)
    }
    
    ; 2. Handle optional parameters
    if (!IsSet(optionalParam)) {
        optionalParam := "default_value"
    }
    
    ; 3. Initialize resources
    resource := ""
    
    try {
        ; 4. Main logic with error handling
        resource := AcquireResource()
        result := ProcessWithResource(resource, requiredParam, optionalParam)
        
        ; 5. Log success
        LogInfo("Function completed successfully")
        return result
        
    } catch ValueError as e {
        LogError("Value error in " . A_ThisFunc . ": " . e.Message)
        throw e
    } catch TypeError as e {
        LogError("Type error in " . A_ThisFunc . ": " . e.Message)
        throw e
    } catch Error as e {
        LogError("General error in " . A_ThisFunc . ": " . e.Message)
        throw e
    } finally {
        ; 6. Always cleanup
        if (resource) {
            try {
                ReleaseResource(resource)
            } catch {
                ; Ignore cleanup errors
            }
        }
    }
}
```

---

**REMEMBER: Every AutoHotkey v2 script must follow ALL these rules. No exceptions. This ensures robust, maintainable, and error-free code that matches the Sayf AI Text Fix project standards.**