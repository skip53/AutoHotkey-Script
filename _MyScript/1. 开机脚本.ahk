;提升性能相关的配置
#NoEnv						;不检查空变量是否为环境变量
SetBatchLines, -1			;行之间运行不留时间空隙,默认是有10ms的间隔
SetKeyDelay, -1, -1			;发送按键不留时间空隙
SetMouseDelay, -1			;每次鼠标移动或点击后自动的延时=0   
SetDefaultMouseSpeed, 0		;设置在 Click 和 MouseMove/Click/Drag 中没有指定鼠标速度时使用的速度 = 瞬间移动.
SetWinDelay, 0
SetControlDelay, 0
SendMode Input				;据说SendInput is the fastest send method.
SetTitleMatchMode Regex		;更改进程匹配模式为正则
#Persistent					;持续运行不退出
#NoTrayIcon					;隐藏托盘图标
SendMode Input				;所有Send命令，统一采用最快的SendInput
#Hotstring EndChars  `n		;编辑热字串的终止符
#MaxHotkeysPerInterval 200

;-------------------------------------------------------------------------------
;~ 开机自启程序
;-------------------------------------------------------------------------------
{
	;翻墙工具
	Run, "d:\Dropbox\Technical_Backup\ProgramFiles.Trust\MEOW-x64 cow的替代品 白名单fork\MEOW.exe"
	;~ Run, "D:\Dropbox\Technical_Backup\shadowsocks-qt5 因为cow只提供http，无socks5和https接口，故专开一下客户端。不用了，可以用privoxy模拟socks5\ss-qt5.exe"
	;~ Run, "d:\Dropbox\Technical_Backup\ProgramFiles.Trust\ShadowsocksR-win\ShadowsocksR-dotnet4.0.exe"
	
	Run, "D:\TechnicalSupport\ProgramFiles\AutoHotkey\AutoHotkeyU32.exe" "%A_LineFile%\..\2. 自定义快捷操作.ahk"
	Run, "D:\TechnicalSupport\ProgramFiles\MyLifeOrganized.net\MLO\mlo.exe"
	;~ Run, "D:\TechnicalSupport\ProgramFiles\Sandboxie\Start.exe" /box:1LongAndTrust "d:\Dropbox\Technical_Backup\ProgramFiles.Trust\douban\firefox\firefox.exe"
	Run % "d:\Dropbox\Technical_Backup\ProgramFiles.Trust\RecycleBinHelper 自动删除回收站N天前的文件\RecycleBinHelper.exe 7 -s"    ;删除7天前的文件
} 

;-------------------------------------------------------------------------------
;~ 定期备份
;-------------------------------------------------------------------------------
{
	;压缩包方式备份
	packBackup(destinationDir, destinationFileName, sourceDir, intervalDays, keepOldZip := true) {
		7zdir := "d:\Dropbox\Technical_Backup\ProgramFiles.Trust\7z1604-extra  7zip的单独命令行版本\7za.exe"
		SetWorkingDir, %destinationDir%
		FileGetTime, timestamp, %destinationFileName%, M
		if ( timestamp = "" )
		{
			RunWait, %7zdir% a -tzip "%destinationFileName%" "%sourceDir%"
		} else
		{
			FormatTime, date, %timestamp%, yyyyMMdd
			xData := A_YYYY * 10000 + A_MM * 100 + A_DD
			xData -= date, days
			if ( xData > intervalDays ) 			;注意这里不能写成xData > %intervalDays%   AutoHotkey的语法确实太魔幻了无力吐槽
			{
				if ( keepOldZip = true )
					FileMove, %destinationFileName%, %date%.zip
				else
					FileDelete, %destinationFileName%
				RunWait, %7zdir% a -tzip "%destinationFileName%" "%sourceDir%"
			}
		}
	}
	
	packBackup("d:\Storage\Software\Firefox Backup", "Firefox_Backup_7days.zip", "d:\TechnicalSupport\ProgramFiles\Firefox-pcxFirefox\Profiles\", "7")
	packBackup("d:\Storage\Software\CentBrowser Backup", "Chrome&CentBrowser_Backup_30days.zip", "d:\TechnicalSupport\ProgramFiles\CentBrowser\User Data\", "25")
	packBackup("d:\Storage\Software\Totalcmd Backup", "Total Commander newest backup.zip", "d:\TechnicalSupport\ProgramFiles\Total Commander 8.51a\", "30")
	packBackup("d:\Dropbox\Technical_Backup", "Sandboxie.ini.zip", "D:\TechnicalSupport\ProgramFiles\Sandboxie\Sandboxie.ini", 7, false)
	packBackup("d:\Dropbox\Technical_Backup", "hosts.zip", "C:\Windows\System32\drivers\etc\hosts", 7, false)
	;calibre的配置（不用便携版，是因为无法记忆上次仓库地址）
	packBackup("d:\Dropbox\Technical_Backup", "CalibreSettings.zip", "d:\TechnicalSupport\Users\LL\AppData\Roaming\calibre\", 7, false)
	packBackup("d:\Dropbox\Technical_Backup", "SnagItSettings.zip", "d:\TechnicalSupport\Sandbox\LL\1LongAndTrust\drive\D\TechnicalSupport\Users\LL\AppData\Local\TechSmith\SnagIt\", 7, false)
	packBackup("d:\Dropbox\Technical_Backup", "Anki配置备份.zip", "c:\Users\LL\AppData\Roaming\Anki2\", 7, false)
	;备份操作不要间隔太小，如每次开机备份，这样坏配置可能会覆盖先前备份，导致真要恢复时也找不到有价值备份了
	;备份注册表，可以用计划任务的方法
	
	;普通复制备份
	copyBackupForFile(destinationFile, sourceFile, intervalDays) {
		FileGetTime, timestamp, %destinationFile%, M
		FormatTime, date, %timestamp%, yyyyMMdd
		xData := A_YYYY * 10000 + A_MM * 100 + A_DD
		xData -= date, days
		if ( xData > intervalDays || timestamp = "" ) 			;注意这里不能写成xData > %intervalDays%   AutoHotkey的语法确实太魔幻了无力吐槽
		{
			FileCopy, %sourceFile%, %destinationFile%, 1
		}
	}
	
	;不能简单的复制备份！复制期间写入数据库时，会因为只读状态，而导致印象丢笔记却不提醒，印象这点设计的超级不合理。改用Macrium Reflect备份(VSS机制)
	;~ copyBackupForFile("d:\TechnicalSupport\SysBackup\EvernoteBackup\bootislands#app.yinxiang.com.exb", "d:\TechnicalSupport\Users\LL\Evernote\Databases\bootislands#app.yinxiang.com.exb", 7)
}

;-------------------------------------------------------------------------------
;~ 开机自启 - 延时
;-------------------------------------------------------------------------------
{
	Sleep, 5*60*1000
	loop
	{
		if ( A_TimeIdlePhysical > 7*60*1000 )
		{
			Run, D:\TechnicalSupport\ProgramFiles\Sandboxie\Start.exe /box:5Dropbox "C:\ProgramData\Microsoft\Windows\Start Menu\程序\Dropbox\Dropbox.lnk"
			break
		}
		Sleep, 30*1000
	}
}

ExitApp


