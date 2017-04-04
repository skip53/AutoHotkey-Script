;MsgBox, 11123333
#SingleInstance force

;Run % comspec . A_Space . "Python" . A_Space .  """d:\test test\1.py"""
;Run % comspec . A_Space . "Python" . A_Space . Chr(34) . "d:\test test\1.bat" . Chr(34)

;MsgBox, %comspec% " Python ""d:\Program Files\1.py"""
;MsgBox % comspec . " Python ""d:\Program Files\1.py"""

;Run % "Python" . A_Space .  """d:\Program Files\1.py"""
;Run % """d:\test test\1.bat"""

#Include d:\Dropbox\Technical_Backup\AHKScript\Functions\regexHotString库，类似InputMagician\Hotstring.ahk

Hotstring("(\d+)\/(\d+)%", "percent",3)
return

percent:
; now $ is a match object.
sendInput, % Round(($.Value(1)/$.Value(2))*100)
; 2/2% -> 100
; 70/100 -> 70%
return

::tc::TotalCommander
::ahk::AutoHotkey