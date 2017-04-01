;-------------------------------------------------------------------------------
;~ 自动保存文件（pdf等）
;-------------------------------------------------------------------------------

#SingleInstance FORCE	;决定当脚本已经运行时是否允许它再次运行,记得用force，这样主脚本reload时，子脚本也自动reload了
SetTitleMatchMode Regex	;更改进程匹配模式为正则
#Persistent				;持续运行不退出
#NoTrayIcon				;隐藏托盘图标

窗口1上次保存时间:=A_TickCount-30*1000    ;使下面立即开始检测

SetTimer, 自动保存, 5000  ;5秒钟检测一次，刚好可检测5秒内有没有键盘和鼠标操作
Return

; 自动保存函数
自动保存:
当前时间:=A_TickCount
; 如果存在该窗口，且距离上次保存已有5min
if WinExist("ahk_exe Acrobat.exe") and (当前时间-窗口1上次保存时间>120*1000)
{
	; 窗口没有激活；或激活了但距离上次用户操作已有5s
	if !WinActive() or ( WinActive() and (A_TimeIdlePhysical>5000) )
	{
		ControlSend, ahk_parent, {Control Down}s{Control Up}, ahk_exe Acrobat.exe
		窗口1上次保存时间:=当前时间
	}
}
return