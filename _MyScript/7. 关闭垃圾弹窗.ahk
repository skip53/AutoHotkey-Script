;-------------------------------------------------------------------------------
;~ 自动关闭QQ、迅雷、搜狗等，托盘区右下角 的弹窗 (补充adkiller)
;-------------------------------------------------------------------------------

#SingleInstance FORCE	;决定当脚本已经运行时是否允许它再次运行,记得用force，这样主脚本reload时，子脚本也自动reload了
SetTitleMatchMode Regex	;更改进程匹配模式为正则
#Persistent				;持续运行不退出
#NoTrayIcon				;隐藏托盘图标
SendMode Input			;所有Send命令，统一采用SendInput

trashWindow := ["About Snagit", "ahk_class testtesttest"]

Loop
{
	for i in trashWindow
	{
		if ( WinExist( trashWindow[i] ) )
			WinClose
	}
	Sleep, 100	;休息100ms 防止不停循环
}
return
