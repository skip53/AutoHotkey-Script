;-------------------------------------------------------------------------------
;~ 上传*剪贴板*中的图片，到七牛云，完成后，设置剪贴板为图片url
;~ 
;~ 该python脚本调用的win32clipboard，是pywin32的一个包，安装方式：
;~ https://sourceforge.net/projects/pywin32/files/
;~ 注意对应版本
;~ 另，需安装七牛库：pip install qiniu
;-------------------------------------------------------------------------------

#SingleInstance FORCE	;决定当脚本已经运行时是否允许它再次运行,记得用force，这样主脚本reload时，子脚本也自动reload了
SetTitleMatchMode Regex	;更改进程匹配模式为正则
#Persistent				;持续运行不退出
;~ #NoTrayIcon				;隐藏托盘图标
SendMode Input			;所有Send命令，统一采用最快的SendInput

#Include d:\Dropbox\Technical_Backup\AHKScript\Functions\GDI+ standard library\Gdip_All 支持unicode u64等各种版本，最好用这个.ahk

saveImagetoFile(pathwithoutSlash, ext := "png", open := false) {
	If !pToken := Gdip_Startup()
	{
		MsgBox, 48, gdiplus Error!, Gdiplus failed to start. Please ensure you have gdiplus on your system
		ExitApp
	}
	pBitmap:=Gdip_CreateBitmapFromClipboard()
	FilePath := pathwithoutSlash "." ext		;构造存储路径
	Gdip_SaveBitmapToFile(pBitmap, FilePath)	;注意该函数会根据设置的扩展名，来判断输出格式，支持png.jpg等，具体看源码
	Gdip_DisposeImage(pBitmap)
	Gdip_Shutdown(pToken)
	if ( open = true )
		Run, %FilePath%
	return FilePath
}

#u::
	;保存剪贴板图片 -> 临时文件
	path := A_Temp "\" A_Now
	path := saveImagetoFile(path, "png")
	
	;上传
	Run %comspec%  /c "Python d:\Dropbox\Technical_Backup\AHKScript\其它语言函数or库\图片上传七牛\upload_qiniu.py %path%" /p
	;Run, % "python ""d:\test test\upload_qiniu.py""" . A_Space . path     ;如果路径有空格，就这样写
	;“/k” 表示命令执行完成之后，cmd窗口不消失，这样可以方便调试，如果出错了可以看到错误信息；如果希望窗口自动关闭，可以将这个参数设置为“/c”。
	return

#o::
	Clipboard := 
	send, ^c
	clipwait
	Run %comspec%  /k "Python d:\Dropbox\Technical_Backup\AHKScript\其它语言函数or库\图片上传七牛\upload_qiniu.py %Clipboard%" /p
	return
