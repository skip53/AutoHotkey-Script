;提升性能相关的配置
#NoEnv						;不检查空变量是否为环境变量
SetBatchLines, -1			;行之间运行不留时间空隙,默认是有10ms的间隔
SetKeyDelay, -1, -1			;发送按键不留时间空隙
SetMouseDelay, -1			;每次鼠标移动或点击后自动的延时=0   
SetDefaultMouseSpeed, 0		;设置在 Click 和 MouseMove/Click/Drag 中没有指定鼠标速度时使用的速度 = 瞬间移动.
SetWinDelay, 0
SetControlDelay, 0
SendMode Input				;据说SendInput is the fastest send method.

;-------------------------------------------------------------------------------
;~ 开机自启程序
;-------------------------------------------------------------------------------
{
	Run, "D:\TechnicalSupport\ProgramFiles\cow-win64-0.9.6 不要用0.9.8版本，有连接reset的bug\cow-taskbar.exe"
	Run, "D:\Dropbox\Technical_Backup\shadowsocks-qt5 因为cow只提供http，无socks5和https接口，故专开一下客户端。不用了，可以用privoxy模拟socks5\ss-qt5.exe"
	Run, "D:\TechnicalSupport\ProgramFiles\AutoHotkey\AutoHotkeyU32.exe" "%A_LineFile%\..\2. 自定义快捷操作.ahk"
	Run, "D:\TechnicalSupport\ProgramFiles\MyLifeOrganized.net\MLO\mlo.exe"
	Run, "D:\TechnicalSupport\ProgramFiles\Sandboxie\Start.exe" /box:1LongAndTrust "d:\Dropbox\Technical_Backup\ProgramFiles.Trust\douban\firefox\firefox.exe"
	Run % "d:\Dropbox\Technical_Backup\ProgramFiles.Trust\RecycleBinHelper 自动删除回收站N天前的文件\RecycleBinHelper.exe 7 -s"    ;删除7天前的文件
	
}

;-------------------------------------------------------------------------------
;~ 定期备份
;-------------------------------------------------------------------------------
{
	;压缩包方式备份
	packbackup(backupdir, backupname, targetdir, interval, archive := true) {
		7zdir := "d:\Dropbox\Technical_Backup\ProgramFiles.Trust\7z1604-extra  7zip的单独命令行版本\7za.exe"
		SetWorkingDir, %backupdir%
		FileGetTime, timestamp, %backupname%, M
		FormatTime, date, %timestamp%, yyyyMMdd
		xData := A_YYYY * 10000 + A_MM * 100 + A_DD
		xData -= date, days
		if ( xData > interval ) 			;注意这里不能写成xData > %interval%   AutoHotkey的语法确实太魔幻了无力吐槽
		{
			if ( archive = true )
				FileMove, %backupname%, %date%.zip
			else
				FileDelete, %backupname%
			RunWait, %7zdir% a -tzip "%backupname%" "%targetdir%"
		}
	}
	
	packbackup("d:\Storage\Software\Firefox Backup", "Firefox_Backup_7days.zip", "d:\TechnicalSupport\ProgramFiles\Firefox-pcxFirefox\Profiles\", "7")
	packbackup("d:\Storage\Software\CentBrowser Backup", "Chrome&CentBrowser_Backup_30days.zip", "d:\TechnicalSupport\ProgramFiles\CentBrowser\User Data\", "25")
	packbackup("d:\Storage\Software\Totalcmd Backup", "Total Commander newest backup.zip", "d:\TechnicalSupport\ProgramFiles\Total Commander 8.51a\", "30")
	packbackup("d:\Dropbox\Technical_Backup", "Sandboxie.ini.zip", "D:\TechnicalSupport\ProgramFiles\Sandboxie\Sandboxie.ini", 7, false)
	;备份操作不要间隔太小，如每次开机备份，这样坏配置可能会覆盖先前备份，导致真要恢复时也找不到有价值备份了
}

ExitApp


