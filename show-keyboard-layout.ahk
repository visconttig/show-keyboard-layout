#NoEnv
#Persistent
#SingleInstance force
SetBatchLines, -1

GroupAdd, programs, ahk_exe Code.exe
GroupAdd, programs, ahk_exe idea64.exe


; Change to auto-start the Gui 
;   {{{
global GuiIsOpen := false
;CreateGui() 
;   }}}

;================================================
; COPY SCRIPT TO StartUp FOLDER FOR AUTORUNNING
;put this line near the top of your script: 
    FileCreateShortcut, %A_ScriptFullPath%, %A_Startup%\%A_ScriptName%.lnk, %A_ScriptDir% 
;=============================================

CreateGui(){
    global
    ; Create a small GUI to show layout name
Gui, +AlwaysOnTop +ToolWindow -SysMenu -Caption
Gui, Font, s18 Bold, Arial
Gui, Color, Black
Gui, Add, Text, vLayoutText cWhite, Loading...
Gui, Show, x1425 y295 NoActivate, Keyboard Layout
}


; Update layout name every half-second
SetTimer, UpdateLayoutName, 500
return


    UpdateLayoutName:
    layoutHex := GetKeyboardLayoutHex()

    ; Map known layout codes to friendly names and styles
    layoutMap := {}
    layoutMap["F0010409"] := {name: "US_Int", textColor: "White", bgColor: "Black"}
    layoutMap["F0D30409"] := {name: "US_Clmk", textColor: "White", bgColor: "Red"}
    layoutMap["080A580A"] := {name: "Spa_LA", textColor: "White", bgColor: "Gray"}
    layoutMap["08040804"] := {name: "Chn_Simpl", textColor: "Gray", bgColor: "Black"}

    if (layoutMap.HasKey(layoutHex)) {
        layout := layoutMap[layoutHex]
        layoutName := layout.name
        textColor := layout.textColor
        bgColor := layout.bgColor

        Gui, Color, %bgColor%
        GuiControl, +c%textColor%, LayoutText
    } else {
        ; Fallback: get layout name from registry
        regKey := "HKLM\SYSTEM\CurrentControlSet\Control\Keyboard Layouts\" . layoutHex
        RegRead, layoutName, %regKey%, Layout Text
        if (ErrorLevel || layoutName = "")
            layoutName := layoutHex

        ; Set default colors
        Gui, Color, Black
        GuiControl, +cWhite, LayoutText
    }

    GuiControl,, LayoutText, %layoutName%
return



GetKeyboardLayoutHex()
{
    ; Get foreground window and thread ID
    WinGet, hwnd, ID, A
    threadID := DllCall("GetWindowThreadProcessId", "UInt", hwnd, "UInt*", 0)
    hkl := DllCall("GetKeyboardLayout", "UInt", threadID)
    
    ; Convert HKL to an 8-digit hex string
    layoutHex := Format("{:08X}", hkl & 0xFFFFFFFF)
    return layoutHex
}

GuiClose:
ExitApp



ToggleGui(){
    if (GuiIsOpen) {
        GuiIsOpen := false
        Gui, Destroy
    } else {
        GuiIsOpen := true
        CreateGui()
    }
}



; Hotkey to show or hide view:
#IfWinNotActive ahk_group programs
F8::ToggleGui()

