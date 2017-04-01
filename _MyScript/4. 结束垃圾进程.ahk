;-------------------------------------------------------------------------------
;~ 自动结束 垃圾进程 （由于会不断生成日志，导致调试时过滤不方便，所以单独执行）
;-------------------------------------------------------------------------------

#SingleInstance FORCE	;决定当脚本已经运行时是否允许它再次运行,记得用force，这样主脚本reload时，子脚本也自动reload了
SetTitleMatchMode Regex	;更改进程匹配模式为正则
#NoTrayIcon				;隐藏托盘图标

trashProcess := ["DownloadSDKServer.exe", "SogouCloud.exe", "SpotifyWebHelper.exe"]			;目标进程名称 = 
Loop {
	For index, value in trashProcess {
		Process, Exist, %value%				;查找进程是否存在
		if ( ErrorLevel != 0 ) {
			Process, Close, %ErrorLevel%		;终止进程
			if ( ErrorLevel = 0 )
				MsgBox, 检测到垃圾进程，但我没有成功的结束它！
		}
		Sleep, 5000
	}
}