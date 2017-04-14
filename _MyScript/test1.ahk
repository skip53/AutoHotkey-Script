#SingleInstance FORCE	;决定当脚本已经运行时是否允许它再次运行,记得用force，这样主脚本reload时，子脚本也自动reload了
SetTitleMatchMode Regex	;更改进程匹配模式为正则
SendMode Input			;所有Send命令，统一采用最快的SendInput


#Include d:\Dropbox\Technical_Backup\AHKScript\Functions\Menu - some functions related to AHK menus  关于menu菜单的库\Menu.ahk

;~ #singleinstance force
;~ #warn

;~ Coordmode Tooltip, Screen

;~ Tooltip % "Hello World!`nMultiline", 0, 0
;~ WinGet hwnd, ID, ahk_class tooltips_class32
;~ ;DllCall("ShowWindow", "Ptr", hwnd, "Uint", 0) ; SW_HIDE
;~ VarSetCapacity(rec,4*A_PtrSize)
;~ res := DllCall("GetWindowRect", "Ptr", hwnd, "Ptr", &rec)
;~ posX := NumGet(rec, 0, "UInt")
;~ posY := NumGet(rec, 4, "UInt")
;~ width := NumGet(rec, 8, "UInt") - posX
;~ height := NumGet(rec, 12, "UInt") - posY
;~ msgbox % "Width -> " . width . "`nHeight -> " . height

;~ Return

;~ F1::reload

;~ Esc::
;~ ExitApp

sServer := "abcdefg"
sServer := SubStr(sServer, 1, -1*(4))
MsgBox, % sServer