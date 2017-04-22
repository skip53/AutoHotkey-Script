;-------------------------------------------------------------------------------
;~ 软件快速启动器a
;-------------------------------------------------------------------------------
#SingleInstance FORCE	;决定当脚本已经运行时是否允许它再次运行,记得用force，这样主脚本reload时，子脚本也自动reload了
SetTitleMatchMode Regex	;更改进程匹配模式为正则
#Persistent				;持续运行不退出
#NoTrayIcon				;隐藏托盘图标
SendMode Input			;所有Send命令，统一采用最快的SendInput

#Include %A_LineFile%\..\..\Functions\appStarter 快速启动器\appStarter.ahk

appStarter("#c", "cmd")
appStarter("!#c", "cmd")
appStarter("#f", "d:\TechnicalSupport\ProgramFiles\Firefox-pcxFirefox\firefox\firefox.exe")
appStarter("#g", "D:\TechnicalSupport\ProgramFiles\CentBrowser\chrome.exe")
appStarter("#n", "notepad")
appStarter("#z", "d:\TechnicalSupport\ProgramFiles\AutoHotkey\SciTE\SciTE.exe")
appStarter("#e", "D:\TechnicalSupport\ProgramFiles\Evernote\Evernote\Evernote.exe")
appStarter(">!m", "D:\TechnicalSupport\Sandbox\LL\1LongAndTrust\drive\D\TechnicalSupport\Users\LL\AppData\Roaming\Spotify\Spotify.exe")
appStarter("#y", "D:\Dropbox\Technical_Backup\ProgramFiles.Untrust\YodaoDict\YodaoDict.exe")
appStarter("#s", "整理pdg")
appStarter("#t", "启动TotalCommander")
appStarter("#k", "shell:::{ED7BA470-8E54-465E-825C-99712043E01C}", "控制面板任务")
appStarter("#h", "shell:::{645FF040-5081-101B-9F08-00AA002F954E}", "回收站")
appStarter("#g", "录制gif")
appStarter("#s", "d:\Dropbox\Technical_Backup\ProgramFiles.Untrust\ColorPic 4.1  屏幕取色小插件 颜色 色彩 配色\#ColorPic.exe")
appStarter("#j", "D:\Dropbox\Technical_Backup\ProgramFiles.Untrust\HourglassPortable 倒计时小工具 计时器 时钟\HourglassPortable 计时器 倒计时.exe")
appStarter("#u", "D:\Dropbox\Technical_Backup\ProgramFiles.Trust\UltraEdit v22.20.0.49(x32)\ultraedit.lnk")

return

整理pdg:
	Run, "d:\Dropbox\Technical_Backup\ProgramFiles.Trust\#Book Tools\Sx_Renamer\Sx_Renamer.exe"
	Run, "d:\Dropbox\Technical_Backup\ProgramFiles.Trust\#Book Tools\Pdg2Pic\Pdg2Pic.exe"
	return
启动TotalCommander:
	if WinExist("ahk_class TTOTAL_CMD") {
		WinClose
	}
	WinWaitClose, ahk_class TTOTAL_CMD, , 2
	Sleep, 500
	Run, "d:\TechnicalSupport\ProgramFiles\Total Commander 8.51a\TOTALCMD.EXE"
	WinWait, ahk_class TNASTYNAGSCREEN				;自动点123
	WinGetText, Content, ahk_class TNASTYNAGSCREEN	;获取未注册提示窗口文本信息
	StringMid, Num, Content, 10, 1					;获取随机数字
	ControlSend,, %Num%, ahk_class TNASTYNAGSCREEN	;将随机数字发送到未注册提示窗口
	WinActivate, ahk_class TTOTAL_CMD
	return
录制gif:
	Run "D:\Dropbox\Technical_Backup\ProgramFiles.Untrust\keycastow 显示击键按键，录制屏幕时很有用\keycastow.exe"
	Run "d:\Dropbox\Technical_Backup\ProgramFiles.Untrust\#Repository\ScreenToGif 1.4.1 屏幕录制gif\$$ScreenToGif 2.5.exe"
	return
