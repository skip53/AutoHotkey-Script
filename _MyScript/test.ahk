;MsgBox, 11123333

^1::
Tick := 600
SetTimer, Timer1, 1000
Return
Timer1:
if Tick--
Tooltip, % Format("{:02d}:{:02d}", Tick/60 , Mod(Tick,60)), 50, 10
else
{
SetTimer, Timer1, Off
SoundBeep, 4000, 2000
Tooltip
}
Return





ProcessList=
(
BESTplayer.exe|1800
TimeOff.exe|3600
taskmgr.exe|10
)

SetTimer, GameCheck, 1000	; 1-second timer  每秒运行一次
return

GameCheck:
IniRead, today, cfg.ini, LastDay, Day		;读取日期
if (today <> SubStr(A_now,1,8))				;和当前日期不符
{
	today := SubStr(A_now,1,8)				;更新today为今天
	loop, parse, ProcessList, `n, `r
		IniWrite, 0, cfg.ini, Counter, % StrSplit(A_LoopField,"|").1
	IniWrite, % SubStr(A_now,1,8), cfg.ini, LastDay, Day
}

loop, parse, ProcessList, `n, `r
{
	i := A_Index
	thisProcess := StrSplit(A_LoopField,"|").1
	ProcessLimit%i% := StrSplit(A_LoopField,"|").2
	IniRead, SecCounter%i%, cfg.ini, Counter, % thisProcess
	Process, Exist, % thisProcess
	if ErrorLevel
	{
		SecCounter%i% := SecCounter%i% ? SecCounter%i%+1 : 1
		IniWrite, % SecCounter%i%, cfg.ini, Counter, % thisProcess
		if (SecCounter%i% >= ProcessLimit%i%)	; if more than 30 minutes
			Process, Close, % thisProcess
	}
}
return