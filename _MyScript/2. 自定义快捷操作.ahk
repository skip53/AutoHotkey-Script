;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; 声明：
;;; 1、用KeyTweak改键盘映射，capslock改为Numpad0了，否则做快捷键总是激活大小写
;;; 切换，很烦
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;-------------------------------------------------------------------------------
;~ 脚本配置 #Include等
;-------------------------------------------------------------------------------
{
	;提升性能相关的配置
	#NoEnv						;不检查空变量是否为环境变量
	;#KeyHistory 0				;不记录击键log
	;ListLines Off				;不记录击键log
	SetBatchLines, -1			;行之间运行不留时间空隙,默认是有10ms的间隔
	SetKeyDelay, -1, -1			;发送按键不留时间空隙
	SetMouseDelay, -1			;每次鼠标移动或点击后自动的延时=0   
	SetDefaultMouseSpeed, 0		;设置在 Click 和 MouseMove/Click/Drag 中没有指定鼠标速度时使用的速度 = 瞬间移动.
	;如果以前录制的脚本,因延时变短,出问题,命令 MouseClick, MouseMove 和 MouseClickDrag 都提供了一个用来设置鼠标速度代替默认速度的参数.用它们自己的参数,设定移动速度
	SetWinDelay, 0
	SetControlDelay, 0
	SendMode Input				;据说SendInput is the fastest send method.
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	#Include %A_LineFile%\..\..\Functions\WinClip\WinClipAPI.ahk
	#Include %A_LineFile%\..\..\Functions\WinClip\WinClip.ahk
	;#Include %A_LineFile%\..\..\Functions\url_encode_decode.ahk	;该脚本必须以ANSI运行
	#Include %A_LineFile%\..\..\Functions\TrayIcon by FanaticGuru.ahk
	#Include %A_LineFile%\..\..\Functions\WinHttpRequest 网络函数 HTTP get post\WinHttpRequest.ahk
	#Include %A_LineFile%\..\..\Functions\GetActiveBrowserURL 获取浏览器窗口的地址 等信息\GetActiveBrowserURL.ahk
	#Include %A_LineFile%\..\..\辅助工具\快捷抓取、查找屏幕文字／图像字符串\函数部分 v5.6.ahk

	#InstallKeybdHook		;安装键盘和鼠标钩子 像Input和A_PriorKey，都需要钩子
	#InstallMouseHook
	SetTitleMatchMode Regex	;更改进程匹配模式为正则
	#SingleInstance ignore	;决定当脚本已经运行时是否允许它再次运行。
	#Persistent				;持续运行不退出
	#MaxThreadsPerHotkey 5
	CoordMode, Mouse, Client	;鼠标坐标采用Client模式
	;SetCapsLockState,AlwaysOff
	CountStp := 0	;一键多用的计时器
	
	#Hotstring EndChars  `n				;编辑热字串的终止符

	Menu, Tray, Icon, %A_LineFile%\..\Icon\自定义快捷操作.ico, , 1
	Menu, tray, tip, 自定义快捷键、自动保存 by LL
	TrayTip, 提示, 脚本已启动, , 1
	Sleep, 1000
	TrayTip
	;return		;注：这里不能加return  原因搜索帮助文件的「自动执行段」

	;最近不怎么用snagit了，先去掉这行
	;Run, d:\BaiduYun\@\Software\AHKScript\_MyScript\非快捷键类 全局运行脚本（由开机脚本自动调用）.ahk
	Run, %A_LineFile%\..\3. 快捷输入.ahk

	;注意：menu菜单的定义，必须在“自动执行段”
	Menu, LangRenMenu, Add, 大厅中找房, 找狂欢版语音
	Menu, LangRenMenu, Add, 占座#9, 占座#9
	Menu, LangRenMenu, Add, 占座#10, 占座#10
	Menu, LangRenMenu, Add, 占座#18, 占座#18
	Menu, LangRenMenu, Add			; 添加分隔线
	Menu, LangRenMenu, Add, &F：快速第一个投票, 快速第一个投票
	Menu, LangRenMenu, Add, &B：全场标记村民, 全场标记村民
	Menu, LangRenMenu, Add			; 添加分隔线
	Menu, LangRenMenu, Add, &1：【踩人】, 找狼不积极
	Menu, LangRenMenu, Add, &2：【踩错不担责】, 踩错声明
	Menu, LangRenMenu, Add, &3：【先知y熊n】, 问先知熊
	Menu, LangRenMenu, Add, &4：【问归】, 问归
	Menu, LangRenMenu, Add, &5：【没时间思考】, 第一个发言没时间
	Menu, LangRenMenu, Add, &6：【不归票】, 局势焦灼
	Menu, WholeOSMenu, Add, 注册表-定位路径, 注册表-定位路径
}

;-------------------------------------------------------------------------------
;~ 函数部分
;-------------------------------------------------------------------------------
{
	;Get memory usage of Process 获取一个进程的内存占用 → 用于监控Firefox内存
	MemUsage(ProcName, Units="K") {
		Process, Exist, %ProcName%
		pid := Errorlevel

		; get process handle
		hProcess := DllCall( "OpenProcess", UInt, 0x10|0x400, Int, false, UInt, pid )

		; get memory info
		PROCESS_MEMORY_COUNTERS_EX := VarSetCapacity(memCounters, 44, 0)
		DllCall( "psapi.dll\GetProcessMemoryInfo", UInt, hProcess, UInt, &memCounters, UInt, PROCESS_MEMORY_COUNTERS_EX )
		DllCall( "CloseHandle", UInt, hProcess )

		SetFormat, Float, 0.0 ; round up K

		PrivateBytes := NumGet(memCounters, 40, "UInt")
		if (Units == "B")
			return PrivateBytes
		if (Units == "K")
			Return PrivateBytes / 1024
		if (Units == "M")
			Return PrivateBytes / 1024 / 1024
	}

	/*
	判断输入法状态，目前网上提到的方法有4种。没有万金油方法，具体情况具体使用：
	1. 用日本网友封装的如下函数。相关贴：http://ahk8.com/archive/index.php/thread-3751-1.html 和 https://www6.atwiki.jp/eamat/pages/18.html
	当然这个库，不止能判断输入状态，还有其它功能
	这个函数，对MyLifeOrganized窗口无效
	2. 用A_CaretX，对于浏览器等非标准窗口，无效
	3. 用ControlGetFocus 获取焦点控件，通过文件名是否含edit等字样，判断是否为编辑控件
	相关贴：http://ahk8.com/archive/index.php/thread-4338.html
	4. Sendmessage发送消息给窗口，通过返回值判断
	相关贴：http://tieba.baidu.com/p/2543294240	
	*/
	;判断当前是否为输入状态，比A_CaretX可靠性更好   =1 在输入状态   =0 不在
	IME_GET(WinTitle="A")  {
		ControlGet,hwnd,HWND,,,%WinTitle%
		if  (WinActive(WinTitle))   {
			ptrSize := !A_PtrSize ? 4 : A_PtrSize
			VarSetCapacity(stGTI, cbSize:=4+4+(PtrSize*6)+16, 0)
			NumPut(cbSize, stGTI,  0, "UInt")   ;   DWORD   cbSize;
			hwnd := DllCall("GetGUIThreadInfo", Uint,0, Uint,&stGTI)
					 ? NumGet(stGTI,8+PtrSize,"UInt") : hwnd
		}
		return DllCall("SendMessage"
			, UInt, DllCall("imm32\ImmGetDefaultIMEWnd", Uint,hwnd)
			, UInt, 0x0283  ;Message : WM_IME_CONTROL
			,  Int, 0x0005  ;wParam  : IMC_GETOPENSTATUS
			,  Int, 0)      ;lParam  : 0
	}	
	
	;打开超链接
	openLink(before, after) {
		clipboard = 
		Send, ^c
		ClipWait, 1  ; 等待剪贴板中出现文本.
		backup := clipboard	; 注意变量的两种赋值方法，或者加冒号不加百分号。或者如下面所示，加百分号不加冒号
		clipboard = %before%%clipboard%%after%
		/*WinActivate, ahk_class MozillaWindowClass
		SendInput, ^t
		Sleep, 1
		SendInput, ^v{Enter}
		*/
		Run, %clipboard%
		Sleep, 500	;这里必须加个延迟，否则下一行太快执行
		clipboard = %backup%
		return
	}
	
	;打开伪链接
	openFakeLink(before, after) {
		clipboard = 
		Send, ^c
		ClipWait, 1  ; 等待剪贴板中出现文本.
		backup := clipboard	; 注意变量的两种赋值方法，或者加冒号不加百分号。或者如下面所示，加百分号不加冒号
		clipboard = %before%%clipboard%%after%
		WinActivate, ahk_class MozillaWindowClass
		SendInput, ^t
		Sleep, 1
		SendInput, ^v{Enter}
		Sleep, 500	;这里必须加个延迟，否则下一行太快执行
		clipboard = %backup%
		return
	}
	
	;Unicode发送函数,避免触发输入法,也不受全角影响  from [辅助Send 发送ASCII字符 V1.7.2](http://ahk8.com/thread-5385.html)
	SendL(ByRef string) {
		static Ord:=("Asc","Ord")
		inputString:=("string",string)
		Loop, Parse, %inputString%
			ascString.=(_:=%Ord%(A_LoopField))<0x100?"{ASC " _ "}":A_LoopField
		SendInput, % ascString
	}
	
	;evernote编辑器增强函数
	evernoteEdit(eFoward, eEnd) {
		;BlockInput On
		clipboard =
		Send ^c
		ClipWait, 1
		t := WinClip.GetHtml3()
		;MsgBox, % t
		;t := WinClip.GetText()
		;RegExMatch(t, "s)(?<=StartFragment-->)(.*?)(?=<!--EndFragment)", t)
		;MsgBox, % WinClip.GetHtml2()
		;MsgBox, % WinClip.GetHtml3()
		html = %eFoward%%t%%eEnd%
		;MsgBox, % html
		WinClip.Clear()
		;MsgBox, % html
		WinClip.SetHTML(html)
		Sleep, 300
		;SendInput, {Space}{backspace}
		;Sleep,2000
		Send ^v
		;BlockInput Off
		Return
	}
	
	;evernote不保留原格式，增强函数
	evernoteEditText(eFoward, eEnd) {
		clipboard =
		Send ^c
		ClipWait, 1
		t := WinClip.GetText()
		html = %eFoward%%t%%eEnd%
		WinClip.Clear()
		WinClip.SetHTML(html)
		Sleep, 300
		Send ^v
		Return
	}
	
	;evernote无原文本的插入html增强函数
	evernoteInsertHTML(html) {
		clipboard =
		WinClip.SetHTML(html)
		Sleep, 300
		Send ^v
		Return
	}
	
	WinClip.GetHtml2 := Func("GetHtml2")		; 也可以直接覆盖原来的函数 -> WinClip.GetHtml := Func("GetHtml2")
	WinClip.GetHtml3 := Func("GetHtml_DOM")
	
	;操作HTML DOM，比GetHTML函数更实用
	GetHtml_DOM(this, Encoding := "UTF-8") {
		html := this.GetHtml2(Encoding)
		static doc := ComObjCreate("htmlFile")
		doc.Write(html), doc.Close()
		return doc.all.tags("span")[0].InnerHtml
	}

	;WinClip中Get的UTF-8改写，支持中文
	GetHtml2(this, Encoding := "UTF-8")	{
	  if !( clipSize := this._fromclipboard( clipData ) )
		return ""
	  if !( out_size := this._getFormatData( out_data, clipData, clipSize, "HTML Format" ) )
		return ""
	  return strget( &out_data, out_size, Encoding )
	}

	;返回当前资源管理器中，所在的路径
	ActiveFolderPath(WinTitle="A") {
		;Returns the path of the specified Explorer window, or the path of the active Explorer window if
		;a title is not specified. Works with Explorer windows, desktop and some open/save dialogues.
		;Returns empty path if no path is retrieved.
		WinGetClass Class, %WinTitle%
		If (Class ~= "Progman|WorkerW") ;desktop
			WinPath := A_Desktop
		;Else If (Class ~= "(Cabinet|Explore)WClass") ;all other Explorer windows
		Else ;all other windows
		{
			WinGetText, WinPath, A
			RegExMatch(WinPath, "地址:.*", WinPath)
			WinPath := RegExReplace(WinPath, "地址: ") ;remove "Address: " part
		}

		WinPath := RegExReplace(WinPath, "\\+$") ;remove single or double  trailing backslash
		If WinPath ;if path not empty, append single backslash
			WinPath .= "\"
		Return WinPath
	}
	
	;=============================================================================================================
	; Func: GetProcessMemory_Private
	; Get the number of private bytes used by a specified process.  Result is in K by default, but can also be in
	; bytes or MB.
	;
	; Params:
	;   ProcName    - Name of Process (e.g. Firefox.exe)
	;   Units       - Optional Unit of Measure B | K | M.  Defaults to K (Kilobytes)
	;
	; Returns:
	;   Private bytes used by the process
	;-------------------------------------------------------------------------------------------------------------
	GetProcessMemory_Private(ProcName, Units="K") {
		Process, Exist, %ProcName%
		pid := Errorlevel

		; get process handle
		hProcess := DllCall( "OpenProcess", UInt, 0x10|0x400, Int, false, UInt, pid )

		; get memory info
		PROCESS_MEMORY_COUNTERS_EX := VarSetCapacity(memCounters, 44, 0)
		DllCall( "psapi.dll\GetProcessMemoryInfo", UInt, hProcess, UInt, &memCounters, UInt, PROCESS_MEMORY_COUNTERS_EX )
		DllCall( "CloseHandle", UInt, hProcess )

		SetFormat, Float, 0.0 ; round up K

		PrivateBytes := NumGet(memCounters, 40, "UInt")
		if (Units == "B")
			return PrivateBytes
		if (Units == "K")
			Return PrivateBytes / 1024
		if (Units == "M")
			Return PrivateBytes / 1024 / 1024
	}


	;=============================================================================================================
	; Func: GetProcessMemory_All
	; Get all Process Memory Usage Counters.  Mimics what's shown in Task Manager.
	;
	; Params:
	;   ProcName    - Name of Process (e.g. Firefox.exe)
	;
	; Returns:
	;   String with all values in KB as one big string.  Use a Regular Expression to parse out the value you want.
	;-------------------------------------------------------------------------------------------------------------
	GetProcessMemory_All(ProcName) {
		Process, Exist, %ProcName%
		pid := Errorlevel

		; get process handle
		hProcess := DllCall( "OpenProcess", UInt, 0x10|0x400, Int, false, UInt, pid )

		; get memory info
		PROCESS_MEMORY_COUNTERS_EX := VarSetCapacity(memCounters, 44, 0)
		DllCall( "psapi.dll\GetProcessMemoryInfo", UInt, hProcess, UInt, &memCounters, UInt, PROCESS_MEMORY_COUNTERS_EX )
		DllCall( "CloseHandle", UInt, hProcess )

		list := "cb,PageFaultCount,PeakWorkingSetSize,WorkingSetSize,QuotaPeakPagedPoolUsage"
			  . ",QuotaPagedPoolUsage,QuotaPeakNonPagedPoolUsage,QuotaNonPagedPoolUsage"
			  . ",PagefileUsage,PeakPagefileUsage,PrivateUsage"

		n := 0
		Loop, Parse, list, `,
		{
			n += 4
			SetFormat, Float, 0.0 ; round up K
			this := A_Loopfield
			this := NumGet( memCounters, (A_Index = 1 ? 0 : n-4), "UInt") / 1024

			; omit cb
			If A_Index != 1
				info .= A_Loopfield . ": " . this . " K" . ( A_Loopfield != "" ? "`n" : "" )
		}

		Return "[" . pid . "] " . pname . "`n`n" . info ; for everything
	}
}

;-------------------------------------------------------------------------------
;~ 全局程序: 注意全局程序，必须写在#IfWinActive *前面* ，函数后面， 才能正确执行！
;-------------------------------------------------------------------------------
{
	;-------------------------------------------------------------------------------
	;~ 控制当前运行是Unicode64版,若不是则切换 (U64比U32运行更快，尽量用U64)
	;-------------------------------------------------------------------------------
	SplitPath A_AhkPath,, AhkDir
	If ( !(A_PtrSize = 4 && A_IsUnicode ) ) {
		U64 := AhkDir . "\AutoHotkeyU32.exe"
		If (FileExist(U64)) {
			Run %U64% "%A_LineFile%"
			ExitApp
		} Else {
			MsgBox 0x2010, AutoGUI, AutoHotkey 64-bit Unicode not found.
			ExitApp
		}
	}
	
	;-------------------------------------------------------------------------------
	;~ 自动结束 垃圾进程
	;-------------------------------------------------------------------------------
	trashProcess := ["DownloadSDKServer.exe", "SogouCloud.exe", "SpotifyWebHelper.exe"]			;目标进程名称 = 
	Loop {
		For index, value in trashProcess {
			Process, Exist, %value%				;查找进程是否存在
			if ( ErrorLevel != 0 ) {
				Process, Close, %ErrorLevel%		;终止进程
				if ( ErrorLevel = 0 )
					MsgBox, 检测到垃圾进程，但我没有成功的结束它！
			}
			Sleep, 10000
		}
	}
	
	;-------------------------------------------------------------------------------
	;~ 自动保存pdf等
	;-------------------------------------------------------------------------------
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
}

;-------------------------------------------------------------------------------
;~ test部分: 检测某函数的作用，临时代码段
;-------------------------------------------------------------------------------
{
	
}

;-------------------------------------------------------------------------------
;~ 全局键位
;-------------------------------------------------------------------------------
{
	;临时
	Tab & o::
	;q::SendInput, p

	;常用软件快速启动
	{
		;配合Listary快速启动
		#r::SendInput, ^!+r
		;#c::Run "d:\TechnicalSupport\ProgramFiles\babun-1.2.0\.babun\babun.bat"
		#c::Run cmd
		!#c::Run, "C:\Windows\System32\cmd.exe"
		;注意主profile不要加--no-remote，否则evernote等打开链接时，会报错「已经运行，没有响应」云云。这里不必装安装版
		#f::Run "d:\TechnicalSupport\ProgramFiles\Firefox-pcxFirefox\firefox\firefox.exe"
		;!#f::Run "D:\TechnicalSupport\ProgramFiles\GreenpcxFirefox\UseFirefox\firefox\firefox.exe" --no-remote
		;#d::Run "D:\TechnicalSupport\ProgramFiles\GreenpcxFirefox\DevFirefox\pcxfirefox\firefox.exe" --no-remote
		;#g::Run "d:\TechnicalSupport\ProgramFiles\GoogleChrome 便携版\MyChrome for Use\MyChrome.exe"
		#g::Run "D:\TechnicalSupport\ProgramFiles\CentBrowser\chrome.exe"
		#n::Run notepad
		#z::Run "d:\TechnicalSupport\ProgramFiles\AutoHotkey\SciTE\SciTE.exe"
		;#z::Run "d:\TechnicalSupport\ProgramFiles\Total Commander 8.51a\plugins\wlx\Syn2\Syn.exe" "d:\BaiduYun\@\Software\AHKScript\_MyScript\自定义快捷操作.ahk"
		#x::Run "C:\Program Files (x86)\Microsoft Office\root\Office16\EXCEL.EXE"
		;#e::Run "D:\TechnicalSupport\ProgramFiles\Evernote\Evernote\Evernote.exe"
		#e::Run "D:\TechnicalSupport\ProgramFiles\Evernote\Evernote\Evernote.exe
		#y::Run "d:\TechnicalSupport\ProgramFiles\YodaoDict\YodaoDict.exe"
		#m::Run resmon
		;^#c::Run, "d:\BaiduYun\Technical Backup\ProgramFiles\ColorPic 4.1  屏幕取色小插件 颜色 色彩 配色\#ColorPic.exe"
		;^#s::Run, "d:\BaiduYun\Technical Backup\ProgramFiles\#Fast Run\st.lnk"
		>!m::Run, "C:\Users\LL\AppData\Roaming\Spotify\Spotify.exe"
		~LButton & F2::SendInput, ^+!#m
		#s::
			Run sx
			Run pp
			;Run ABBYY Screenshot Reader
			return
		;录制gif
		/*#!s::
			Run "d:\BaiduYun\Technical Backup\ProgramFiles\keycastow 显示击键按键，录制屏幕时很有用\keycastow.exe"
			Run "d:\BaiduYun\Technical Backup\ProgramFiles\#Repository\ScreenToGif 1.4.1 屏幕录制gif\$$ScreenToGif - Preview 11 屏幕录制gif.exe"
			return
			*/
		#t::
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
		;Numpad0 & q::Run "shell:::{ED7BA470-8E54-465E-825C-99712043E01C}"
	}

	;快捷输入
	{
		Tab & s:: Send, ▶{Space}			;	右三角
		Tab & d:: Send, •{Space}			;	圆点
		;Tab & f:: Send, ■{Space}			;	方点
		Tab & f:: Send, ●{Space}			;	大圆点
		Tab & 1:: Send, ①{Space}
		Tab & 2:: Send, ②{Space}
		Tab & 3:: Send, ③{Space}
		Tab & 4:: Send, ④{Space}
		Tab & 5:: Send, ⑤{Space}
		Tab & 6:: Send, ⑥{Space}
		Tab & 7:: Send, ⑦{Space}
		Tab & 8:: Send, ⑧{Space}
		Numpad0 & 1:: Send, ❶{Space}
		Numpad0 & 2:: Send, ❷{Space}
		Numpad0 & 3:: Send, ❸{Space}
		Numpad0 & 4:: Send, ❹{Space}
		Numpad0 & 5:: Send, ❺{Space}
		Numpad0 & 6:: Send, ❻{Space}
		Numpad0 & 7:: Send, ❼{Space}
		Numpad0 & 8:: Send, ❽{Space}
		
		;Tab & g:: Send, √{Space}
		;多数时候，回车紧接句号，说明前面输入的是英文，那句号应该是英文的点，所以自动修改下
		
		
		;鼠标移动到任务栏，滚动中键，则调节音量。但效果不理想，和搜狗输入法冲突，会输入'b'和'c'，且有难听的声音提示。换用独立工具Volumouse了
		/*#If MouseIsOver("ahk_class Shell_TrayWnd")
		
		WheelUp::
		Send {Volume_Up}
		SoundPlay *-1
		return

		WheelDown::
		Send {Volume_Down}
		SoundPlay *-1
		return

		MButton::
		Send {Volume_Mute}
		SoundPlay *-1
		return

		MouseIsOver(WinTitle) {
			MouseGetPos,,, Win
			return WinExist(WinTitle . " ahk_id " . Win)
		}
		
		#If
		*/
}
	
	;简单映射型 快捷键
	{
		~LButton & r::Reload
		~LButton & s::			;禁用脚本
			Suspend, On			;注意suspend必须在第一行 否则当suspend状态下，这个开关键，本身也会被禁用
			TrayTip, 提示, 已 [禁用] 脚本, , 1
			Sleep, 1000
			TrayTip
			Pause, On
			return
		~LButton & a::
			Suspend, Off
			TrayTip, 提示, 已 [启用] 脚本, , 1
			Sleep, 1000
			TrayTip
			Pause, Off
			return
		
		;Ditto自动分组(快捷输入)
		!Space::^!+l
		
		;配合Actual Window Manager做虚拟桌面切换
		#F1::SendInput, !#{F1}
		#F2::SendInput, !#{F2}

		;输入 不可见&宽度0 的字符
		Tab & Space:: SendInput, {U+2067}{U+2068}{U+2069}{U+206A}{U+206B}{U+206C}
		
		;还有些字符也不可见且宽度0，但是由于被列入network.IDN.blacklist_chars，所以经常被过滤掉，例如 {U+115F}{U+1160}{U+200B}{U+1160}{U+115F}{U+2001}{U+2002}{U+2003}{U+2004}{U+2005}{U+2006}{U+2007}{U+2008}{U+2009}{U+200A}{U+200B}{U+2028}{U+2029}{U+202F}{U+205F}{U+3000}{U+3164}{U+FEFF}
		;输入 不可见&宽度非0 的字符
		Numpad0 & Space:: SendInput, {U+115A}{U+115B}{U+115C}{U+115D}{U+115E}{U+11A3}{U+11A4}{U+11A5}{U+11A6}{U+11A7}
		;输入 几乎不可见 的字符
		Tab & p:: SendInput, {U+06E4}{U+115B}{U+115C}{U+115D}{U+115E}
		
		;在farbox web editor中快捷输入meta信息
		Tab & b:: SendInput, {Shift}Title{U+003A}{Space}{Enter}Tags{U+003A}{Space}标签1{U+002C}{Space}标签2{Enter}Status{U+003A}{Space}draft{U+002F}public{Enter}URL{U+003A} this-is-my-first-post
	}
	
	;复杂型 快捷键
	{
		注册表-定位路径:
			; 注册表的HKEY_CURRENT_USER/Software/Microsoft/Windows/CurrentVersion/Applets/Regedit
			; 下的LastKey项保存了上一次浏览的注册表项位置，所以在打开注册表编辑器前修改它就行了
			InputBox, NewLastKey, 注册表自动定位工具, 请输入要定位到的路径, , 800, 130
			IfWinExist, 注册表编辑器 ahk_class RegEdit_RegEdit	
			{
				WinClose
				WinWaitClose
			}
			RegWrite, REG_SZ, HKEY_CURRENT_USER, Software\Microsoft\Windows\CurrentVersion\Applets\Regedit, LastKey, %NewLastKey%
			If(ErrorLevel = 1)
				MsgBox failed
			Run, regedit.exe
			return

		;cow edit
		!x::Run "d:\TechnicalSupport\ProgramFiles\cow-win64-0.9.6 不要用0.9.8版本，有连接reset的bug\rc.txt"
		!z::Run "d:\TechnicalSupport\ProgramFiles\cow-win64-0.9.6 不要用0.9.8版本，有连接reset的bug\blocked.txt"
		;cow reload
		!c::
			MouseGetPos, xpos, ypos 				;记忆鼠标位置
			TrayIcon_Button("cow-taskbar.exe", "R")
			MouseMove, 20, 50,, R
			Sleep, 500
			MouseClick, left
			TrayIcon_Button("cow-taskbar.exe", "R")
			Sleep, 1000
			MouseMove, 20, 40,, R
			MouseClick, left
			MouseMove, xpos, ypos					;恢复鼠标位置
			return
		
		
		/*Tab & o::
			Loop, 39
			{
				SendInput, {Tab}{Space}
				Sleep, 1500
				SendInput, {Tab}{Tab}{Space}
				Sleep, 1500
				SendInput, {Tab}{Tab}{Space}
				Sleep, 1500
				SendInput, {Tab}{Space}
				Sleep, 1500
			}	
			return
		*/
		
		;豆瓣book搜索
		Numpad0 & d::openLink("http://book.douban.com/subject_search?search_text=", "&cat=1001")
		;豆瓣movie搜索
		Numpad0 & s::openLink("http://movie.douban.com/subject_search?search_text=", "&cat=1002")
		;谷歌搜索
		Numpad0 & g::openLink("https://www.google.com/search?newwindow=1&site=&source=hp&q=", "&=&=&oq=&gs_l=")
		;快速查词典
		Numpad0 & c::openLink("http://dict.youdao.com/search?q=", "")
		
		;双击esc退出焦点程序
		~Esc::
			if (A_ThisHotKey = A_PriorHotKey and A_TimeSincePriorHotkey < 500) 
				Send, !{F4}
			return

		;恢复Tab键原本功能
		{
			$Tab::Send, {Tab}
			LAlt & Tab::AltTab
			^Tab::Send, ^{Tab}
			^+Tab::Send, ^+{Tab}
			+Tab::SendInput, +{Tab}
		}
		
		;配合有道词典取词
		~LWin:: Send, {LControl}{LControl}
		
		;配合anki收集
		/*Numpad0 & s::
		{
			WinActivate, ahk_exe anki.exe
			SendInput, a
			return
		}
		*/
		
		;evernote新建笔记
		Numpad0 & a::SendInput, ^!n
		
		$F4::
			CountStp := ++CountStp
			SetTimer, tkds, 500
			Return
			tkds:
				if CountStp > 1 ;大于1时关闭计时器
					SetTimer, TimerPrtSc, Off
				if CountStp = 1 ;只按一次时执行
				{
					SendInput, {F4}
					WinWaitActive, ahk_class ENMainFrame, , 2
					sendL("notebook:""1  Cabinet"" ")		;注意字符中的双引号要转义，不是\"，而是两个引号""
				}
				if CountStp = 2 ;按两次时...
					SendInput ^+!#m    ;显示MyLifeOrganized
				if CountStp = 3 ;按3次时...
					SendInput, ^+m
				CountStp := 0 ;最后把记录的变量设置为0,于下次记录.
				Return
	}
}
	
;-------------------------------------------------------------------------------
;~ @Evernote快捷键
;-------------------------------------------------------------------------------
#IfWinActive ahk_class (ENSingleNoteView|ENMainFrame)
{
	;快捷键: 非编辑器部分
	{
		
		;en的搜索不支持特殊字符，特快捷输入这些国际字母，以变相支持特殊字符
		` & 1::SendInput, {U+0069}{U+006E}{U+0074}{U+0069}{U+0074}{U+006C}{U+0065}{U+003A}		;输入intitle:，为了避免输入法影响，用unicode输入
		` & 2::SendInput, Δ{Space}
		` & 3::SendInput, Ø{Space}
		` & d::SendInput, ^;			;快速插入日期时间
		;Tab & q::evernoteInsertHTML("<span style='color: #e97d23'>[]</span>")			;之前颜色#355986
		Tab & q::SendInput, {U+005B}{U+005D}
		Tab & w::SendInput, √
		Tab & e::SendInput, ×
		;Tab & r::SendInput, ●
		Tab & t::SendInput, ○
		$`::SendInput, ``
		+`::SendInput, ~{Shift}
		~^`::SendInput, ^`
		
		^Space::controlsend, , ^{Space}, A   	;简化格式
		F1::Menu, LangRenMenu, Show
		F3::SendInput, ^!t				;批量打标签
		Numpad0 & r::SendInput !vpb		;显示回收站
		~LButton & a::SendInput, ^!a	;切换账户
		
		;复制到当前笔记本
		F5::
		{
			SendInput, {AppsKey}c
			WinWait, 复制笔记到笔记本
			Sleep, 100
			SendInput, {Enter}
			return
		}
		
		;导出笔记
		F6::
		{
			SendInput, {AppsKey}x{Enter}
			WinWait, ahk_class #32770
			SendInput, {Enter}
			return
		}
		
		;加括号
		Tab & a::
		{
			Send, ^x
			Send, (%Clipboard%)
			return
		}
		
		;双击右键，高亮，和Firefox习惯一样
		{
			$RButton::
				CountStp := ++CountStp
				SetTimer, TimerPrtSc, 500
				Return
			TimerPrtSc:
				if CountStp > 1 ;大于1时关闭计时器
					SetTimer, TimerPrtSc, Off
				if CountStp = 1 ;只按一次时执行
					SendInput, {RButton}
				if CountStp = 2 ;按两次时...
					SendInput, ^+h
				CountStp := 0 ;最后把记录的变量设置为0,于下次记录.
				Return
		}
	}
	
	;颜色 字体格式等
	{
		;方框环绕
		!f::evernoteEdit("<div style='margin-top: 5px; margin-bottom: 9px; word-wrap: break-word; padding: 8.5px; border-top-left-radius: 4px; border-top-right-radius: 4px; border-bottom-right-radius: 4px; border-bottom-left-radius: 4px; background-color: rgb(245, 245, 245); border: 1px solid rgba(0, 0, 0, 0.148438)'>", "</div></br>")
		;超级标题
		!s::evernoteEditText("<div style='margin:1px 0px; color:rgb(255, 255, 255); background-color:#8BAAD0; border-top-left-radius:5px; border-top-right-radius:5px; border-bottom-right-radius:5px; border-bottom-left-radius:5px; text-align:center;'><b>", "</b></div></br>")
		;贯穿线
		^+=::
			evernoteInsertHTML("<div style='margin: 3px 0px; border-top-width: 2px; border-top-style: solid; border-top-color: rgb(116, 98, 67); font-size: 3px'>　</div><span style='font-size: 12px'>&nbsp;</span>")
			SendInput, {Left}
			return
		;底色标题
		;!t::evernoteEditText("<div><div style='padding:0px 5px; margin:3px 0px; display:inline-block; color:rgb(255, 255, 255); text-align:center; border-top-left-radius:5px; border-top-right-radius:5px; border-bottom-right-radius:5px; border-bottom-left-radius:5px; background-color:#E2A55C;'>", "<br/></div><br/></div><br/>")
		;引用
		!y::evernoteEdit("<div style='margin:0.8em 0px; line-height:1.5em; border-left-width:5px; border-left-style:solid; border-left-color:rgb(127, 192, 66); padding-left:1.5em; '>", "</div>")
		/* 需要其它样式，在这里增加 
		*/	
		
		;字体白色（选中可见）
		Numpad0 & w::evernoteEditText("反白可见【<span style='color: white;'>", "</span>】")
		
		;v6版本，鼠标点击方式，实现修改文字颜色
		evernoteMouseChangeColor(r, g, b) {
			CoordMode, Mouse, Screen	;鼠标坐标，临时采用全屏幕模式，否则鼠标不能回归原位
			MouseGetPos, xpos, ypos 
			CoordMode, Mouse, Client	;鼠标坐标，返回Client模式
			IfWinActive, ahk_class ENMainFrame 
			{
				Click 890, 159		;点击颜色按钮
				Click 935, 341		;点击更多颜色
				;严重依赖窗口视图相对位置，编辑区域中界限，设定为表格刚刚消失不见时的位置，接近于屏幕竖直中线
			}
			IfWinActive, ahk_class ENSingleNoteView
			{
				Click 231, 121		;点击颜色按钮
				Click 262, 304		;点击更多颜色
			}
			;SendL("M")			;进入更多颜色		
			Sleep, 50
			Click, 116, 333		;进入自定义颜色
			SendInput, {Tab}{Tab}{Tab}
			SendInput %r%{Tab}%g%{Tab}%b%{Tab}{Space}
			Click, 21, 259		;点击设定好自定义颜色
			SendInput, {Tab}{Space}
			CoordMode, Mouse, Screen	;鼠标坐标，继续改回全屏幕模式，方便移动鼠标
			MouseMove, %xpos%, %ypos%, 0
			CoordMode, Mouse, Client	;鼠标坐标，继续返回Client模式
			return
		}
		
		{
			;字体红色
			#1::
				evernoteMouseChangeColor(240, 46, 55)
				SendInput, ^b
				return
			;字体蓝色
			#2::
				evernoteMouseChangeColor(55, 64, 230)
				SendInput, ^b
				return
			;字体灰色
			#3::
				evernoteMouseChangeColor(214, 214, 214)
				return
			;字体绿色
			#4::
				evernoteMouseChangeColor(15, 130, 15)
				SendInput, ^b
				return
			;字体白色
			#5::
				evernoteMouseChangeColor(255, 255, 255)
				return
		
			;周计划专用配色
			;字体橙色
			#F1::evernoteMouseChangeColor(233, 125, 35)
			;字体绿色
			#F2::evernoteMouseChangeColor(55, 64, 230)
			;字体蓝色
			#F3::evernoteMouseChangeColor(91, 133, 170)
			;字体土黄色
			#F4::evernoteMouseChangeColor(255, 188, 41)
			;字体紫色
			#F5::evernoteMouseChangeColor(194, 0, 251)
		}
	}
	
	;每日Todo的连续操作
	Tab & r::
	{
		Click, 1131, 500
		SendInput, ^a
		Sleep, 20
		SendInput, ^+v
		Sleep, 20
		SendInput, ^h
		Sleep, 20
		SendInput, ^a
		sendL("[]")
		Click, 982, 686
		Sleep, 400
		Click, 1181, 272
		SendInput, ^a
		SendInput, ^+c
		return
	}
}

;-------------------------------------------------------------------------------
;~ @Explorer快捷键
;-------------------------------------------------------------------------------
#IfWinActive, ahk_class (Progman|WorkerW|CabinetWClass|ExploreWClass|#32770|Clover_WidgetWin_0)
{
	;复制路径
	^1::	clipboard := ActiveFolderPath("")

	;复制文件名
	^2::	
	{
		send ^c
		sleep,200
		clipboard = %clipboard%
		SplitPath, clipboard, name
		clipboard = %name%
		return
	}

	;复制含文件名的完整路径
	^3::	
	{
		send ^c
		sleep,200
		clipboard = %clipboard%
		return
	}
	
	;tc中打开同路径目录
	^t::
	{
		clipboard =
		clipboard := ActiveFolderPath("")
		ClipWait, 1
		Run, "d:\TechnicalSupport\ProgramFiles\Total Commander 8.51a\TOTALCMD.EXE" /O /T /L="%Clipboard%"
		return
	}
	
	;tc中打开沙盘中的同路径
	^s::
	{
		clipboard =
		clipboard := ActiveFolderPath("")
		ClipWait, 1
		StringReplace, clipboard, clipboard, :
		Run, "d:\TechnicalSupport\ProgramFiles\Total Commander 8.51a\TOTALCMD.EXE" /O /T /L="d:\TechnicalSupport\Sandbox\LL"
		;Run, "d:\TechnicalSupport\ProgramFiles\Total Commander 8.51a\TOTALCMD.EXE" /O /T /L="d:\TechnicalSupport\Sandbox\LiLong\UnstableSoftware\drive\%Clipboard%"
		return
	}
}

;-------------------------------------------------------------------------------
;~ @Anki快捷键
;-------------------------------------------------------------------------------
#IfWinActive, ahk_exe anki.exe
{
	;新建cloze
	F1::
		Send, ^+c
		return
	
	;新建cloze，序号不增加
	F2::
		Send, ^+!c
		return
	
	;增量阅读，把透析的快捷键，改变成`
	`::
		Send, ^+!q
		return
		
	;增量阅读，添加为析取qa后，自动关闭，方便下一次析取
	^Enter::
		Send, ^{Enter}
		sleep, 300
		Send, {Esc}
		return
		
	;快速格式化笔记
	F3::
		SendInput, {F7}
		SendInput, ^b
		return
		
	F4::SendInput {F8}
	
	` & 1::	SendInput, ^+!c{Left}{Left}{U+003A}{U+003A}简要复述
	
	;Brower中预览卡片
	Numpad0 & q::SendInput, ^+p
}

;-------------------------------------------------------------------------------
;~ @cmd快捷键
;-------------------------------------------------------------------------------
#IfWinActive ahk_class ConsoleWindowClass
{
	~Esc::
	{
		if (A_ThisHotKey = A_PriorHotKey and A_TimeSincePriorHotkey < 500)
		{
			WinClose A ;这里的大写字母A已经表示了当前激活的窗口,不必更改!
		}
		return
	}
}

;-------------------------------------------------------------------------------
;~ M$ @Word快捷键
;-------------------------------------------------------------------------------
#IfWinActive ahk_class OpusApp
{
	;导航窗格的开关，需要先在word里将导航窗格的快捷键指定为^!+p
	F1::
	{
		Send, ^!+p
		return
	}
	
	`::
		Send, ^!m
		return
}

;-------------------------------------------------------------------------------
;~ @MyLifeOrganized快捷键
;-------------------------------------------------------------------------------
#IfWinActive ahk_class TfrmMyLifeMain
{
	;mlo的备注不支持中文路径的超链接，因此加这个脚本
	/*F1::
	{
		Send ^c
		Run %clipboard%
		Return
	}
	*/
	
	;覆盖搜狗输入法的全局快捷键干扰
	^+z::ControlSend,, ^+z, A
	
	;简化本来已有的快捷键
	{
		#If ( WinActive("ahk_class TfrmMyLifeMain") && A_CaretX = "")
		m:: SendInput, ^m
		c:: SendInput, ^c
		v:: 
		{
			CountStp := ++CountStp
			SetTimer, jkdfs, 500
			Return
			jkdfs:
				if CountStp > 1 ;大于1时关闭计时器
					SetTimer, TimerPrtSc, Off
				if CountStp = 1 ;只按一次时执行
				{
					Send, ^v
					Sleep, 50
					SendInput, {Down}{Enter}
				}
				if CountStp = 2 ;按两次时...
					Send, ^v{Enter}
				CountStp := 0 ;最后把记录的变量设置为0,于下次记录.
				Return
		}
		F1:: SendInput, ^+!x	;Inbox view
		delete::  ;删除到垃圾桶
		{
			SendInput, ^m
			WinWait, ahk_class TfrmSelectTaskNode
			SendInput, {Down}{End}{Enter}
			return
		}
		
		#If WinActive("ahk_class TfrmMyLifeMain")	;;;;;;;;;;;;注意AutoHotkey不支持#IfWinActive 和 #If 的嵌套，务必记得#if完，恢复之前的上下文
	}
	
}

;-------------------------------------------------------------------------------
;~ @TotalCommander快捷键
;-------------------------------------------------------------------------------
#IfWinActive ahk_class TTOTAL_CMD
{
	/*;为熟悉vim 屏蔽方向键
	{
		Up::
		Down::
		Left::
		Right:: return
	}
	*/
	
	;关闭当前标签
	`::Send, ^w

	;在win7自带资源管理器中打开同路径
	^e::
		Send, ^1
		Sleep, 50
		Run, %Clipboard%
		return
	
	;在对侧窗口打开沙盘中同路径
	^s::
		Send, ^1
		Sleep, 50
		StringReplace, clipboard, clipboard, :
		Run, "d:\TechnicalSupport\ProgramFiles\Total Commander 8.51a\TOTALCMD.EXE" /O /T /S /R="d:\TechnicalSupport\Sandbox\LL\"
		return
		
	;压缩多文件为uvz：自动重命名和勾选选项
	#F5::
		SendInput, !{F5}{Right}{Left}{BS}{BS}{BS}
		sendL("uvz")
		SendInput, !n{Tab}{Tab}{Tab}{Space}
		return
	
	;文件夹被占用，无法删除时，查看是被谁占用的
	^Del::
		Clipboard := 
		SendInput, ^1
		ClipWait
		commands = ("d:\Dropbox\Technical Backup\ProgramFiles.Trust\Handle 查看文件夹或文件 被哪个程序占用 而无法删除\handle64.exe" %Clipboard% & echo "直接taskkill /PID来结束进程")
		runwait, %comspec% /k %commands%
		return
}

;-------------------------------------------------------------------------------
;~ @farbox editor快捷键
;-------------------------------------------------------------------------------
#IfWinActive ahk_class QWidget
{
	;^m::
	;send, Tags: 1, 2{Enter}Status: draft
;status: draft
;title: 
;tags: 
}

;-------------------------------------------------------------------------------
;~ @acrobat dc快捷键
;-------------------------------------------------------------------------------
#IfWinActive ahk_class AcrobatSDIWindow
{
	;acrobat dc中划词取词失效，改用剪贴板取词
	~LWin:: 
	{
		Send, ^c
		timeNow:=A_TickCount
		while(A_TickCount - timeNow < 500) 				;等1秒钟，
		{
			IfWinExist, ahk_class #32770				;期间出现ahk_class #32770的弹窗
			{
				;WinActivate  ; 自动使用上面找到的窗口.
				Send, {Space}
				return
			}
		}
		return
	}
	
	;修改批注颜色 公用代码函数
	changebg(r, g, b)
	{
		SendInput {RButton}H{RButton}P{Enter}{Down}{Down}{Down}{Down}{Down}{Down}{Enter}
		Sleep, 600
		SendInput {Tab}{Tab}{Tab}{Tab}{Tab}{Tab}{Tab}%r%{Tab}%g%{Tab}%b%{Enter}{Tab}{Tab}{Tab}{Tab}{Tab}{Enter}
		return
	}
	;批注颜色list
	!1::changebg(157, 205, 120)				;绿		#9DCD78，重点
	!2::changebg(135, 201, 217)				;蓝		#87C9D9，
	!3::changebg(241, 202, 93)				;橙		#F1CA5D，
	!4::changebg(255, 138, 128)				;暖红	#FF8A80，
	!5::changebg(185, 192, 199)				;灰		#B9C0C7，最不重要，说明
	;!`::changebg(255, 255, 115)			;黄		#FFFF73，普通批注，acrobat默认，不必设快捷键
	;备用色
	;!1::changebg(205, 164, 133)				;驼色#CDA485，
	
	;统一高亮firefox、evernote和pdf的快捷键，都是双击右键高亮
	RButton::
	{
		++CountStp
		;循环计时器，每500秒执行一次T0子程序。首次运行时，会先等待指定时间，就靠这个特性来一键多用
		SetTimer,T0,400 
		Return

		T0:
			SetTimer,T0,Off
			if CountStp = 1 ;只按一次时执行
				SendInput, {RButton}
			if CountStp = 2 ;按两次时...
				SendInput, {AppsKey}H
			if (CountStp = 3) {
				SendInput, {RButton}P
				;等待窗口出现 高亮属性
				WinWait, 高亮属性, , 5
				WinActivate
				IfWinActive, 高亮属性
					SendInput, {Enter}{Down}{Down}{Down}{Down}{Right}{Right}{Right}{Right}{Right}{Enter}{Tab}{Tab}{Tab}{Tab}{Tab}{Enter}
			}
			
			CountStp := 0 ;最后把记录的变量设置为0,于下次记录.
		Return
	}
	
	;中键，配合有道取词
	MButton::
	{
		SendInput, ^c
		Sleep, 200
		Send {BackSpace}
		;为了处理acrobat可能弹出的报错框
		timeNow:=A_TickCount
		while(A_TickCount - timeNow < 500) 			;等1秒钟，
		{
			IfWinExist, ahk_class #32770				;期间出现ahk_class #32770的弹窗
			{
				Send, {Space}
				return
			}
		}
		return
	}
}

;-------------------------------------------------------------------------------
;~ @Firefox快捷键
;-------------------------------------------------------------------------------
#IfWinActive ahk_class MozillaWindowClass
{
	;-------------------------------------------------------------------------------
	;~ 加快操作的快捷键
	;-------------------------------------------------------------------------------
	{
		F1::Send, ^+{Tab}	;切换到前一标签
		F2::Send, ^{Tab}	;切换到后一标签
		
		#if (not IME_GET() && WinActive("ahk_class MozillaWindowClass") )
		h:: SendInput, ^h
		#If WinActive("ahk_class MozillaWindowClass")
		
		;Diigo快捷键
		F3::
		{
			Send, ^!b		;配合diigo的侧边栏
			设定时间=%A_Now%
			设定时间 += 5,Seconds
			文字:=""
			文字.="|<>69.w6M001lUM0k7sn000TA3060naMwQ31XMsy6AnDbkMAzDbtlaPAn3laNan6AnDiM7BnTqNlaNsn0NaNUnTsnD7szAzAbvy6NwS3lbswy800Mk0000000003g0000000000D00000000U"
			Loop
			{
				if 查找文字(41,85,150000,150000,文字,"*135",X,Y,OCR,0,0)
				{
					Sleep, 100
					ControlClick, x170 y168, A  			;Click, 152, 170 但不移动鼠标
					SendInput, +{Home}{BackSpace}
					break
				}
				If A_Now > %设定时间%
					break
			}			
			return
		}
		
		;用AutoHotkey绑定`和关闭标签，容易写代码时误关闭，改为用ff脚本KeyChanger做。
		;但KeyChanger在空白tab和Google上又自动进入输入焦点，还是回到ahk。判断下当前是否输入状态吧
		$`::
			if not IME_GET()
				Send, ^w		;关闭当前标签
			Else
				SendInput, ``
			return
		~^`::Send, ^`		;恢复Ditto本来功能
		!`::Send, ``		;恢复本来的`功能
		^b::Send, ^t^v{Enter}		;快捷打开复制的网址
		
		` & 1::
			sendL("console.log();")
			SendInput, {Left}{Left}
			return
			
		;某些网页，单击win造成的双击ctrl，会触发js，导致win+a印象笔记摘录失效，所以这里屏蔽一下，改成单击ctrl
		~LWin:: SendInput, {LControl}
	}
	
	;-------------------------------------------------------------------------------
	;~ 打开一些网址的快捷键
	;-------------------------------------------------------------------------------
	{
		Numpad0 & w::openLink("http://zh.wikipedia.org/w/index.php?search=", "")
		Numpad0 & q::openLink("http://book.szdnet.org.cn/search?Field=all&channel=search&sw=", "")
		Numpad0 & e::openFakeLink("es ", "")		;配合Firefox，E书园搜索
		Numpad0 & r::		;E书园求书时用，文献港链接 替换成 读秀链
		{
			clipboard = 
			SendInput, ^a
			Sleep, 100
			SendInput, ^c
			ClipWait, 1	; 等待剪贴板中出现文本.
			backup := clipboard	; 注意变量的两种赋值方法，或者加冒号不加百分号。或者如下面所示，加百分号不加冒号
			clipboard := RegExReplace(clipboard, "szdnet.org.cn/views/specific/2929", "duxiu.com")  
			SendInput, ^v{Enter}
			Sleep, 500	;这里必须加个延迟，否则下一行太快执行
			clipboard = %backup%
			return
		}
	}
	
	;-------------------------------------------------------------------------------
	;~ 双击右键，调用diigo高亮，同时不干扰鼠标手势
	;-------------------------------------------------------------------------------
	{
		;在Up时判断：和上次Up间隔短则高亮，和上次Down间隔短则弹出右键，都不是说明是鼠标手势则忽略
		;菜单在Up时弹出，手势在down且超时时启用
		UpStartTime := A_TickCount	;初始化
		~RButton::			;在按下时触发
			DownStartTime := A_TickCount
			return
			 
		$RButton up::		;在弹起时触发
			DownTime := A_TickCount - DownStartTime
			UpTime := A_TickCount - UpStartTime
			UpStartTime := A_TickCount
			if (UpTime < 1000 && UpTime > 100)
			{
				SendInput, h
			} 
			else if (DownTime < 300)
			{
				SendInput, {RButton}
			}
			return
	}
	
	
	;还没想好怎么做
	;自动判断是否选中文本，否的话，替换复制为全选+复制
	;^c::
	;	ControlGet,text,selected,,edit1 ;获取选中的文本
	;	if text=
	;		
	;	return 
	
	~LButton & q::MsgBox % GetProcessMemory_All("firefox.exe")
	;~LButton & q::MsgBox % MemUsage("firefox.exe", "M")
	
	;-------------------------------------------------------------------------------
	;~ 基于网址的自定义
	;-------------------------------------------------------------------------------
	{
		;-------------------------------------------------------------------------------
		;~ Inoreader网站
		;-------------------------------------------------------------------------------
		{
			iURL := GetActiveBrowserURL()
			if ( RegExMatch(iURL, "^https?://www.inoreader.com.*") != 0)
			{
				;g & RButton:: SendInput, o
			}
		}
		
		;-------------------------------------------------------------------------------
		;~ 网易云音乐 快捷键  (因为用了#if，必须放在最后)
		;-------------------------------------------------------------------------------
		/*		
		;把方向键作修饰符的话，副作用较多，例如长按Left、按住shift再按Left……都要另处理，麻烦
		Left & Right:: 
		Right & Left:: SendInput, ^+{Left}
		$Left::SendInput {Left}
		$Right::SendInput {Right}
		
		;用AuhoHotkey论坛其他人的建议，用Input，也没试验成功
		~Left::
			Input, UserInput, V T3 L1, , {Right}
			if ErrorLevel = Match
				SendInput, ^+{Right}
			return
		;至于通过if，定义快捷键上下文，也不可行，必须用#if
		if ( a_priorkey = "left" && A_TimeSincePriorHotkey < 1000) 
			Right:: SendInput, ^+{right}
		if ( a_priorkey = "right" && A_TimeSincePriorHotkey < 1000) 
			Left:: SendInput, ^+{left}
		*/
	}
	
	
}

;-------------------------------------------------------------------------------
;~ google @chrome快捷键
;-------------------------------------------------------------------------------
#IfWinActive ahk_class Chrome_WidgetWin_1
{
	F1::Send, ^+{Tab}	;切换到前一标签
	F2::Send, ^{Tab}	;切换到后一标签
	F3::Send, ^!b		;配合diigo的侧边栏
	$`::Send, ^w		;关闭当前标签
	~^`::Send, ^`
	!`::Send, ``		;恢复本来的`功能
	^b::				;快捷打开复制的网址
		Send, ^t
		Send, ^v
		Send, {Enter}
		return	
	
	;以下都是针对 fe开发 的快捷键
	{
		;快捷输入console.log();
		` & 1::
			sendL("console.log();")
			SendInput, {Left}{Left}
			return
		
		;增加console多行模式的支持
		$Enter::SendInput, +{Enter}
		$^Enter::SendInput, {Enter}
		
		;tab
		;Tab::SendInput, {Space}{Space}{Space}{Space}
		
		!F1::SendInput, !s
	}
	
	~LButton & q::MsgBox % GetProcessMemory_All("chrome.exe")
}

;-------------------------------------------------------------------------------
;~ @sublime text 3 快捷键
;-------------------------------------------------------------------------------
#IfWinActive ahk_exe sublime_text.exe
{	
	;屏蔽全局快捷键 双击esc退出
	~Esc::Send, {Esc}
	
	;用Capslock键 替代 Esc键，配合vim
	Numpad0::Send, {ESC}
	
	Numpad0 & q::SendInput ^!v
	
	F1::Send, ^+{Tab}	;切换到前一标签
	F2::Send, ^{Tab}	;切换到后一标签

	;添加笔记型 注释
	!F1::SendL("@note: ")
	;添加疑问型 注释
	!F2::SendL("@problem: ")
	;添加todo型 注释
	;!F3::SendL("@todo: ")
	;Go To Matching Pair
	Numpad0 & j::SendInput ^!+j
	
	;更新evernote笔记
	F9::
		SendInput, ^+p
		sendL("evernote update")
		SendInput, {Enter}
		return
}

;-------------------------------------------------------------------------------
;~ @OneNote 快捷键
;-------------------------------------------------------------------------------
#IfWinActive ahk_exe ONENOTE.EXE
{
	;浏览模式
	F2::
		SendInput, !d
		Sleep, 100
		SendInput, h{F11}
		return
	;编辑模式
	F1::
		SendInput, !d
		Sleep, 100
		SendInput, t{F11}
		return
	
	;给container加背景色：先转成表格，再给单元格加背景色
	Tab & q::
		SendInput, !n
		;Sleep, 50
		SendInput, t{Enter}
		Sleep, 200
		SendInput, {Alt}
		;Sleep, 50
		SendInput, jlh
		;Sleep, 50
		SendInput, {Alt}jlg
		return
}

;-------------------------------------------------------------------------------
;~ @pdg2pic: pdg批量转换pdf
;-------------------------------------------------------------------------------
#IfWinActive ahk_exe Pdg2Pic.exe
{
	F1::
		SetControlDelay -1
		
		WinGet, dir, ProcessPath, A
		;MsgBox %OutputVar%
		SplitPath, dir, , outdir
		;MsgBox %outdir%
		FileDelete, Pdg2Pic_log.txt
		
		
		静止状态:		;等待按 开始转换
		Loop {
			ControlClick, &4、开始转换, Pdg2Pic, , , , NA		;点击开始转换
			Sleep 1000
			ControlGet, ifenable, Enabled, , 转换完毕, Pdg2Pic	;如果没出错，转换成功
			if ifenable = 1
				goto 点击完成									;则点击
		}
			
		点击完成:
			ControlClick, 确定, Pdg2Pic, , , , NA		;点击转换完成的确定
			ControlGet, ifenable2, Enabled, , 否, Pdg2Pic
			if ifenable2 = 1
			{
				ControlSend, Button1, n, Pdg2Pic
			}
			
		检查日志:
			;检查是否有日志，如果有则copy
			ilog = %outdir%\Pdg2Pic_log.txt
			FileRead, OutputVar, %ilog%
			if NOT ErrorLevel
			{
				;如果文件不存在，则为1，如果成功读取到了，则为0
				FileAppend, %OutputVar%, Pdg2Pic_log.txt
			}
		
			goto 选择下一本书
			
		选择下一本书:
			Sleep 1000
			ControlClick, Button2, Pdg2Pic, , , , NA	;点击选书
			Sleep, 1500
			ControlSend, SysTreeView321, {Down}, 选择存放PDG文件的文件夹
			Sleep, 1500
			ControlClick, 确定, 选择存放PDG文件的文件夹	;点击确定，完成选书
			Sleep, 500
			goto 检查是否完成
			
		检查是否完成:
			ControlGet, ifenable3, Visible, , 文件夹里没有, Pdg2Pic
			if (ifenable3 = 1)
			{
				ControlSend, Button1, {Space}, Pdg2Pic
				;最前端弹窗
				MsgBox, 262144, PDG->PDF, 全部PDG文件，转换完成！`n`n如果转换中有错误，请参见脚本同目录下的Pdg2Pic_log.txt`n（若没有该文件，则说明一切正常）

			}
			else
			{
				goto 静止状态
			}
		return
	
}

;-------------------------------------------------------------------------------
;~ @potplayer 快捷键
;-------------------------------------------------------------------------------
#IfWinActive ahk_exe PotPlayerMini.exe
{
	F1::
	+/:: MsgBox, 【字幕同步】点号逗号/0.5s，ctrl点号逗号/5s`n【截屏】P		
}

;-------------------------------------------------------------------------------
;~ @ultraEdit
;-------------------------------------------------------------------------------
#IfWinActive ahk_exe uedit32.exe
{
	F1::
		SendInput, ^v
		;Sleep, 500
		SendInput, {Alt}
		;Sleep, 300
		SendInput, {Shift}
		SendInput, vvv{Right}{Down}{Down}{Down}{Down}{Down}{Enter}
		SendInput, ^a
		SendInput, ^!{PgDn}
		return
}

;-------------------------------------------------------------------------------
;~ @桌面在最前端时，快捷键
;-------------------------------------------------------------------------------
#IfWinActive ahk_class (WorkerW|Progman)   ;不要用ahk_exe explorer.exe，会和资源管理器冲突
{
	;显示全局菜单
	F1::Menu, WholeOSMenu, Show
	
	;双击esc，启用一系列夜间：启动迅雷、局域网同步、公网同步、定时关机
	~Esc::
		if (A_ThisHotKey = A_PriorHotKey && A_TimeSincePriorHotkey < 500) {
			;询问是否执行，防止失误导致的触发
			MsgBox 0x21, 睡前命令, 确认执行？
			IfMsgBox Cancel, {
				return
			} Else IfMsgBox OK, {
				Run, %A_LineFile%\..\..\Functions\nircmd-x64\nircmd.exe mutesysvolume 1
				;用外部程序来执行静音，避免{Volume_Mute}和搜狗输入法的冲突，参见：http://ahk8.com/thread-2650.html
				Run, "D:\TechnicalSupport\ProgramFiles.Untrust\Thunder Network\Thunder\Program\Thunder.exe"
				Run, "C:\Users\LL\AppData\Roaming\Resilio Sync\Resilio Sync.exe"
				Run, "D:\Dropbox\Technical Backup\ProgramFiles.Trust\Shutdown8  定时关机\Shutdown8 关机.exe"
			}
		}
		return
}

;-------------------------------------------------------------------------------
;~ @记事本@Notepad/Notepad2.exe
;-------------------------------------------------------------------------------
#IfWinActive ahk_exe (notepad.exe|Notepad2.exe)
{
	~Esc::
		if (A_ThisHotKey = A_PriorHotKey and A_TimeSincePriorHotkey < 500) 
		{
			SendInput, !{F4}
			Sleep, 200
			SendInput, n
			;WinKill, A       ;不管用
		}
		return
}

;-------------------------------------------------------------------------------
;~ 千牛，阿里旺旺卖家版
;-------------------------------------------------------------------------------
#IfWinActive ahk_exe AliWorkbench.exe
{
	F1:: SendInput, /{U+003A}087{Right}
	F2:: SendInput, /{U+003A}012{Right}
	F3:: SendInput, /{U+003A}074{Right}
	F4:: SendInput, /{U+003A}Q{Right}
	F5:: SendInput, /{U+003A}806{Right}
	
}


;-------------------------------------------------------------------------------
;~ @Everything
;-------------------------------------------------------------------------------
#IfWinActive ahk_exe Everything.exe
{
	^1::
		SendInput, {AppsKey}
		Sleep, 400
		SendInput, f
		return
}

;-------------------------------------------------------------------------------
;~ 游戏The Escapists快捷键
;-------------------------------------------------------------------------------
#IfWinActive ahk_class Mf2MainClassTh
{
  ;运动健身：跑步机
  F12::
    Loop {
      /*
      前面几关
      
			Send, {q down}
      Sleep, 10
	    Send, {e down}
      Sleep, 10
      Send, {q up}
      Sleep, 10
      Send, {e up}
      Sleep, 10
      */
      
      /* 
      丛林关卡 
      
      Send, {q down}
      Send, {q up}
      Sleep, 10
      Send, {e down}
      Send, {e up}
      Sleep, 10
      */
      
      /*
      cho关卡 内置的困难关
      
      Send, {q down}
      Sleep, 450
      Send, {q up}
      Sleep, 10
      */
      
      /*
      very hard 难度  引体向上
      */
      Send, {q down}
      Sleep, 10
      Send, {q up}
      Sleep, 10
      Send, {e down}
      Sleep, 10
      Send, {e up}
      Sleep, 10
		}
    return
  
  Insert::Reload
  
  F11::
    while(1)
    {
      Send, {LButton Down}
      Sleep, 2
      Send, {LButton up}
      Sleep, 2
    }
    return
  
  /*
  hard那一章，锻炼速度的
  */
  ^F12::
    Loop {
      Send, {q Down}
      Sleep, 20
      Send, {q Up}
      Sleep, 933
    }
    
}

;-------------------------------------------------------------------------------
;~ 游戏 狼人杀 快捷键         ;注意里面的找字相关代码，已经失效了，以后要用的话，重新写一下
;-------------------------------------------------------------------------------
#IfWinActive 狼人游戏
{
	;快捷键
	;$LShift::SendInput {LShift}{LShift}
	
	F1::Menu, LangRenMenu, Show
	F2::
		KeepLoopRunning := false
		return
	
	快速第一个投票:
		KeepLoopRunning := true
		WinGet, active_id, ID, A
		CoordMode, Mouse, Relative
		MouseGetPos, VarX, VarY
		Loop {
			SetControlDelay -1
			ControlClick, X%VarX% Y%VarY%, ahk_id %active_id%,,,, NA
			Sleep, 300
			if KeepLoopRunning = 0		;不知道为什么，这里改成false就调试不通过
				break
		}
		MsgBox, , , 快速投票已完成, 1
		return

	;后台抢座位
	pullseat(xposi, yposi) {
		global KeepLoopRunning := true
		WinGet, active_id, ID, A
		Loop {
			SetControlDelay -1
			ControlClick, X650 Y416, ahk_id %active_id%,,,, NA	;点同意开车
			Sleep, 50
			ControlClick, X%xposi% Y%yposi%, ahk_id %active_id%,,,, NA	;抢18号位
			Sleep, 50
			if KeepLoopRunning = 0
				break
		}
		MsgBox, , , 抢座位已完成, 1
		return
	}
		
	占座#18:
		pullseat(82, 607)		;18号位
		return
	占座#9:
		pullseat(1283, 124)		;9号位
		return
	占座#10:
		pullseat(1283, 609)		;10号位
		return
	
	;活跃窗口自动找房间
	seekseat(文字) {
		global KeepLoopRunning := true
		WinGet, active_id, ID, A
		Loop {
			SetControlDelay -1
			CoordMode, Mouse, Relative
			ControlClick, X473 Y193, ahk_id %active_id%,,,, NA			;点活跃窗口
			Sleep, 1000
			;if 查找文字(498,221,文字,"*114",150000,150000,X,Y,OCR,0,0,active_id) 
			{
				WinActivate, ahk_id %active_id%
				Sleep, 1000
				CoordMode, Mouse
				MouseMove, X, Y
				Sleep, 1000
				Click, X, Y
				return
			}
			Sleep, 500
			if KeepLoopRunning = 0
				break
		}
		MsgBox, , , 已找到房间, 1
		return
	}
	
	找狂欢版语音:
		文字=
		文字=%文字%|<  >
(
_0_00000000000000_000000_0_0000____0_00_______000000__0000000000__00000
______________________00_0_0_______0__0_______00__________00__________0
__0000__0000___________0_0_0__0000000_0______0000________000__0000000_0
___000__000__0______0__0__________00000_______0000______0000__________0
0__000__0000_____0__0_00______________00__00__0____________0__000__00_0
0__________0___000__0000_000___00_00___________00________000___________
___000__00000__000__0000___0___0__00__00000000000_________00__0__000000
_0_000__00000___00___000_0_0______00__0_______000_000000__00__0_______0
00_000__0000____0____000_0_0_00__000__0__0000_00__________00_00__000__0
0__000__000__00___00__0__0___0____00_____0000_000_000000__00_00_0000__0
_____________00__0000____0_____0___0__0_______00__________0_____00___00
000000000000000_0000000000__0_000000000_00000_000_000000_00000_000__000
)
		seekseat(文字)
		return
	
	问先知熊:
		sendL("退水吃毒/对刚到死的 先知y 熊n")
		return
	找狼不积极:
		sendL("找狼不积极，身份较「低」的是")
		return
	问归:
		sendL("抓紧时间问归，明天再分析 //如果被归的人有身份，给n反抗 //当多个坐定神（如女巫 天使），归票意见不一致时，听谁的，大家自己看")
		return
	踩错声明:
		sendL("当然，以上仅基于发言的、逻辑推测，不承诺100%正确。踩错人很正常。欢迎理性反驳，不欢迎发脾气和骂人")
		return
	第一个发言没时间:
		sendL("第一个发言，没时间思考和看票型，仓促发言，可能漏洞百出，反被狼队抗推。所以等这里理清思路、看票型、找狼后，明天再分析")
		return
	局势焦灼:
		sendL("现在局势焦灼，选错满盘皆输。这里新手，不能带队/不能归票。大家用自己的大脑，独自判断形势，投自己的票。以下只代表个人观点。如果有人无脑、不经判断的采纳，自行背锅，这里不担责")
		return
	
	;录制的一段代码，太脏
	全场标记村民:  
		mousedelay = A_MouseDelay
		SetMouseDelay -1
		CoordMode, Mouse, Screen
		{
			Sleep, 333
			Sleep, 499
			Click, 127, 422, 0
			Sleep, 15
			Click, 127, 419, 0
			Sleep, 16
			Click, 124, 408, 0
			Sleep, 16
			Click, 120, 390, 0
			Click, 118, 379, 0
			Sleep, 15
			Click, 114, 367, 0
			Sleep, 16
			Click, 110, 344, 0
			Sleep, 15
			Click, 105, 323, 0
			Sleep, 16
			Click, 101, 305, 0
			Sleep, 16
			Click, 96, 281, 0
			Sleep, 15
			Click, 94, 272, 0
			Click, 93, 264, 0
			Sleep, 16
			Click, 93, 256, 0
			Click, 92, 246, 0
			Sleep, 15
			Click, 91, 239, 0
			Sleep, 16
			Click, 90, 226, 0
			Click, 90, 220, 0
			Sleep, 16
			Click, 89, 214, 0
			Click, 89, 210, 0
			Sleep, 15
			Click, 89, 205, 0
			Sleep, 16
			Click, 89, 200, 0
			Click, 89, 191, 0
			Sleep, 15
			Click, 89, 186, 0
			Click, 89, 182, 0
			Sleep, 16
			Click, 89, 175, 0
			Click, 89, 170, 0
			Sleep, 16
			Click, 89, 166, 0
			Sleep, 15
			Click, 89, 159, 0
			Click, 89, 157, 0
			Sleep, 16
			Click, 88, 154, 0
			Click, 88, 151, 0
			Sleep, 31
			Click, 86, 146, 0
			Sleep, 16
			Click, 86, 144, 0
			Sleep, 15
			Click, 86, 142, 0
			Click, 86, 140, 0
			Sleep, 16
			Click, 86, 139, 0
			Sleep, 15
			Click, 86, 137, 0
			Sleep, 32
			Click, 85, 134, 0
			Sleep, 31
			Click, 85, 133, 0
			Sleep, 140
			Click, 85, 132, 0
			Sleep, 63
			Click, 85, 132 Left, Down
			Sleep, 156
			Click, 85, 132 Left, Up
			Sleep, 156
			Click, 86, 138, 0
			Sleep, 15
			Click, 92, 145, 0
			Click, 96, 150, 0
			Sleep, 16
			Click, 100, 156, 0
			Sleep, 15
			Click, 109, 172, 0
			Click, 115, 180, 0
			Sleep, 16
			Click, 119, 188, 0
			Click, 125, 197, 0
			Sleep, 16
			Click, 130, 206, 0
			Sleep, 15
			Click, 145, 225, 0
			Sleep, 16
			Click, 160, 243, 0
			Sleep, 15
			Click, 177, 260, 0
			Sleep, 16
			Click, 184, 267, 0
			Click, 194, 278, 0
			Sleep, 16
			Click, 198, 282, 0
			Sleep, 15
			Click, 205, 290, 0
			Sleep, 16
			Click, 213, 298, 0
			Sleep, 15
			Click, 219, 306, 0
			Sleep, 16
			Click, 222, 308, 0
			Sleep, 16
			Click, 226, 313, 0
			Click, 228, 316, 0
			Sleep, 15
			Click, 233, 323, 0
			Sleep, 16
			Click, 234, 325, 0
			Click, 236, 328, 0
			Sleep, 31
			Click, 238, 333, 0
			Sleep, 16
			Click, 242, 341, 0
			Sleep, 15
			Click, 245, 345, 0
			Sleep, 16
			Click, 247, 350, 0
			Sleep, 15
			Click, 249, 354, 0
			Sleep, 16
			Click, 251, 358, 0
			Sleep, 31
			Click, 254, 364, 0
			Sleep, 16
			Click, 255, 366, 0
			Sleep, 15
			Click, 256, 367, 0
			Sleep, 16
			Click, 256, 368, 0
			Sleep, 16
			Click, 257, 369, 0
			Sleep, 31
			Click, 258, 369, 0
			Sleep, 109
			Click, 258, 369 Left, Down
			Sleep, 62
			Click, 258, 369 Left, Up
			Sleep, 266
			Click, 257, 369, 0
			Sleep, 15
			Click, 253, 363, 0
			Sleep, 16
			Click, 247, 354, 0
			Sleep, 15
			Click, 239, 343, 0
			Sleep, 16
			Click, 225, 325, 0
			Sleep, 31
			Click, 217, 313, 0
			Sleep, 16
			Click, 207, 302, 0
			Sleep, 15
			Click, 201, 297, 0
			Sleep, 16
			Click, 193, 293, 0
			Sleep, 31
			Click, 184, 287, 0
			Sleep, 16
			Click, 172, 280, 0
			Sleep, 31
			Click, 164, 273, 0
			Sleep, 16
			Click, 157, 267, 0
			Sleep, 15
			Click, 154, 263, 0
			Click, 151, 262, 0
			Sleep, 31
			Click, 147, 258, 0
			Sleep, 16
			Click, 144, 255, 0
			Sleep, 31
			Click, 142, 254, 0
			Sleep, 16
			Click, 141, 252, 0
			Sleep, 15
			Click, 141, 251, 0
			Sleep, 156
			Click, 141, 251 Left, Down
			Sleep, 110
			Click, 141, 251 Left, Up
			Sleep, 109
			Click, 141, 250, 0
			Sleep, 15
			Click, 148, 245, 0
			Sleep, 32
			Click, 164, 235, 0
			Sleep, 15
			Click, 189, 216, 0
			Sleep, 31
			Click, 209, 198, 0
			Sleep, 16
			Click, 221, 186, 0
			Sleep, 31
			Click, 234, 167, 0
			Sleep, 16
			Click, 243, 151, 0
			Sleep, 31
			Click, 246, 143, 0
			Click, 247, 142, 0
			Sleep, 47
			Click, 247, 138, 0
			Sleep, 15
			Click, 247, 137, 0
			Sleep, 63
			Click, 247, 136, 0
			Sleep, 31
			Click, 247, 136 Left, Down
			Sleep, 140
			Click, 247, 136 Left, Up
			Sleep, 110
			Click, 249, 144, 0
			Sleep, 15
			Click, 258, 169, 0
			Sleep, 31
			Click, 285, 222, 0
			Sleep, 32
			Click, 307, 252, 0
			Sleep, 31
			Click, 335, 278, 0
			Click, 343, 285, 0
			Sleep, 31
			Click, 366, 307, 0
			Sleep, 31
			Click, 379, 320, 0
			Sleep, 31
			Click, 387, 326, 0
			Sleep, 32
			Click, 396, 335, 0
			Sleep, 31
			Click, 400, 340, 0
			Sleep, 15
			Click, 404, 343, 0
			Sleep, 32
			Click, 405, 346, 0
			Sleep, 15
			Click, 407, 347, 0
			Sleep, 31
			Click, 409, 351, 0
			Sleep, 32
			Click, 415, 361, 0
			Sleep, 31
			Click, 418, 367, 0
			Sleep, 31
			Click, 419, 369, 0
			Sleep, 94
			Click, 419, 369 Left, Down
			Sleep, 109
			Click, 419, 369 Left, Up
			Sleep, 218
			Click, 418, 368, 0
			Sleep, 31
			Click, 413, 364, 0
			Sleep, 32
			Click, 404, 351, 0
			Sleep, 31
			Click, 389, 332, 0
			Sleep, 31
			Click, 376, 317, 0
			Sleep, 16
			Click, 363, 300, 0
			Sleep, 46
			Click, 351, 286, 0
			Sleep, 16
			Click, 341, 275, 0
			Sleep, 31
			Click, 334, 268, 0
			Sleep, 31
			Click, 327, 261, 0
			Sleep, 32
			Click, 324, 261, 0
			Sleep, 46
			Click, 319, 261, 0
			Sleep, 16
			Click, 316, 261, 0
			Sleep, 31
			Click, 313, 259, 0
			Sleep, 31
			Click, 309, 257, 0
			Sleep, 32
			Click, 306, 255, 0
			Sleep, 46
			Click, 303, 253, 0
			Sleep, 32
			Click, 300, 251, 0
			Sleep, 31
			Click, 300, 250, 0
			Sleep, 78
			Click, 300, 250 Left, Down
			Sleep, 125
			Click, 300, 250 Left, Up
			Sleep, 187
			Click, 300, 248, 0
			Sleep, 31
			Click, 317, 234, 0
			Sleep, 31
			Click, 340, 210, 0
			Sleep, 31
			Click, 361, 182, 0
			Sleep, 16
			Click, 370, 167, 0
			Sleep, 94
			Click, 395, 131, 0
			Sleep, 31
			Click, 396, 129, 0
			Sleep, 31
			Click, 396, 128, 0
			Sleep, 47
			Click, 396, 128 Left, Down
			Sleep, 125
			Click, 396, 128 Left, Up
			Sleep, 171
			Click, 398, 130, 0
			Sleep, 31
			Click, 426, 174, 0
			Sleep, 32
			Click, 456, 217, 0
			Sleep, 31
			Click, 500, 273, 0
			Sleep, 47
			Click, 544, 320, 0
			Sleep, 31
			Click, 567, 343, 0
			Sleep, 47
			Click, 573, 351, 0
			Sleep, 31
			Click, 579, 360, 0
			Sleep, 31
			Click, 581, 365, 0
			Sleep, 47
			Click, 582, 370, 0
			Sleep, 31
			Click, 582, 373, 0
			Sleep, 31
			Click, 582, 374, 0
			Sleep, 141
			Click, 582, 374 Left, Down
			Sleep, 93
			Click, 582, 374 Left, Up
			Sleep, 125
			Click, 581, 373, 0
			Sleep, 47
			Click, 573, 366, 0
			Sleep, 31
			Click, 545, 341, 0
			Sleep, 31
			Click, 521, 311, 0
			Sleep, 47
			Click, 499, 288, 0
			Sleep, 47
			Click, 487, 274, 0
			Sleep, 31
			Click, 481, 270, 0
			Sleep, 47
			Click, 479, 267, 0
			Sleep, 31
			Click, 477, 265, 0
			Sleep, 47
			Click, 473, 260, 0
			Sleep, 31
			Click, 468, 257, 0
			Sleep, 47
			Click, 464, 255, 0
			Sleep, 31
			Click, 462, 254, 0
			Sleep, 47
			Click, 462, 253, 0
			Sleep, 93
			Click, 462, 253 Left, Down
			Sleep, 110
			Click, 462, 253 Left, Up
			Sleep, 93
			Click, 462, 252, 0
			Sleep, 47
			Click, 466, 237, 0
			Sleep, 31
			Click, 496, 179, 0
			Sleep, 47
			Click, 515, 134, 0
			Sleep, 47
			Click, 515, 130, 0
			Sleep, 47
			Click, 515, 129, 0
			Sleep, 46
			Click, 515, 129 Left, Down
			Sleep, 78
			Click, 515, 129 Left, Up
			Sleep, 110
			Click, 517, 130, 0
			Sleep, 46
			Click, 547, 165, 0
			Sleep, 47
			Click, 591, 215, 0
			Sleep, 47
			Click, 657, 288, 0
			Sleep, 31
			Click, 702, 336, 0
			Sleep, 47
			Click, 718, 351, 0
			Sleep, 47
			Click, 722, 356, 0
			Sleep, 47
			Click, 724, 359, 0
			Sleep, 109
			Click, 727, 363, 0
			Click, 730, 364, 0
			Sleep, 62
			Click, 731, 367, 0
			Sleep, 47
			Click, 731, 367 Left, Down
			Sleep, 109
			Click, 731, 367 Left, Up
			Sleep, 141
			Click, 730, 366, 0
			Sleep, 46
			Click, 711, 350, 0
			Click, 704, 344, 0
			Sleep, 63
			Click, 647, 294, 0
			Sleep, 47
			Click, 632, 281, 0
			Sleep, 31
			Click, 626, 276, 0
			Sleep, 78
			Click, 610, 260, 0
			Sleep, 47
			Click, 604, 251, 0
			Sleep, 46
			Click, 601, 247, 0
			Sleep, 110
			Click, 601, 247 Left, Down
			Sleep, 93
			Click, 601, 247 Left, Up
			Sleep, 47
			Click, 601, 247 Left, Down
			Sleep, 62
			Click, 601, 247 Left, Up
			Sleep, 94
			Click, 601, 246, 0
			Sleep, 47
			Click, 614, 233, 0
			Sleep, 47
			Click, 632, 213, 0
			Sleep, 46
			Click, 644, 200, 0
			Sleep, 47
			Click, 646, 197, 0
			Sleep, 47
			Click, 663, 173, 0
			Sleep, 47
			Click, 683, 140, 0
			Sleep, 62
			Click, 692, 127, 0
			Sleep, 109
			Click, 692, 127 Left, Down
			Sleep, 125
			Click, 692, 127 Left, Up
			Sleep, 109
			Click, 695, 128, 0
			Sleep, 47
			Click, 729, 178, 0
			Sleep, 63
			Click, 809, 278, 0
			Sleep, 46
			Click, 861, 333, 0
			Click, 865, 338, 0
			Sleep, 78
			Click, 877, 354, 0
			Sleep, 63
			Click, 878, 363, 0
			Sleep, 47
			Click, 879, 366, 0
			Sleep, 46
			Click, 879, 369, 0
			Sleep, 63
			Click, 879, 369 Left, Down
			Sleep, 93
			Click, 879, 369 Left, Up
			Sleep, 110
			Click, 878, 368, 0
			Sleep, 46
			Click, 866, 357, 0
			Sleep, 47
			Click, 833, 322, 0
			Sleep, 63
			Click, 800, 296, 0
			Sleep, 46
			Click, 783, 285, 0
			Sleep, 63
			Click, 775, 277, 0
			Sleep, 47
			Click, 767, 266, 0
			Sleep, 62
			Click, 760, 255, 0
			Sleep, 62
			Click, 758, 252, 0
			Sleep, 125
			Click, 758, 252 Left, Down
			Sleep, 94
			Click, 758, 252 Left, Up
			Sleep, 78
			Click, 758, 251, 0
			Click, 759, 250, 0
			Sleep, 78
			Click, 806, 202, 0
			Sleep, 62
			Click, 836, 157, 0
			Sleep, 63
			Click, 838, 145, 0
			Sleep, 62
			Click, 838, 144, 0
			Sleep, 47
			Click, 838, 144 Left, Down
			Sleep, 62
			Click, 838, 144 Left, Up
			Sleep, 109
			Click, 842, 149, 0
			Click, 847, 156, 0
			Sleep, 94
			Click, 935, 271, 0
			Click, 944, 277, 0
			Sleep, 78
			Click, 990, 316, 0
			Sleep, 62
			Click, 1002, 330, 0
			Sleep, 63
			Click, 1010, 341, 0
			Sleep, 47
			Click, 1018, 353, 0
			Sleep, 62
			Click, 1026, 366, 0
			Sleep, 62
			Click, 1030, 373, 0
			Sleep, 47
			Click, 1031, 373, 0
			Sleep, 47
			Click, 1031, 373 Left, Down
			Sleep, 62
			Click, 1031, 373 Left, Up
			Sleep, 110
			Click, 1030, 372, 0
			Sleep, 62
			Click, 1015, 354, 0
			Sleep, 62
			Click, 961, 297, 0
			Click, 955, 291, 0
			Sleep, 94
			Click, 918, 259, 0
			Sleep, 47
			Click, 905, 256, 0
			Sleep, 62
			Click, 900, 254, 0
			Sleep, 141
			Click, 900, 254 Left, Down
			Sleep, 109
			Click, 900, 254 Left, Up
			Sleep, 93
			Click, 900, 253, 0
			Sleep, 47
			Click, 926, 230, 0
			Sleep, 63
			Click, 962, 185, 0
			Sleep, 78
			Click, 974, 150, 0
			Sleep, 62
			Click, 978, 142, 0
			Sleep, 62
			Click, 978, 142 Left, Down
			Sleep, 63
			Click, 978, 142 Left, Up
			Sleep, 93
			Click, 979, 142, 0
			Sleep, 63
			Click, 1032, 234, 0
			Sleep, 62
			Click, 1104, 329, 0
			Sleep, 63
			Click, 1127, 351, 0
			Sleep, 62
			Click, 1132, 356, 0
			Sleep, 62
			Click, 1139, 362, 0
			Sleep, 63
			Click, 1154, 368, 0
			Sleep, 78
			Click, 1168, 368, 0
			Sleep, 62
			Click, 1177, 368, 0
			Sleep, 63
			Click, 1177, 368 Left, Down
			Sleep, 93
			Click, 1177, 368 Left, Up
			Sleep, 94
			Click, 1177, 366, 0
			Sleep, 78
			Click, 1150, 338, 0
			Sleep, 62
			Click, 1112, 292, 0
			Click, 1109, 288, 0
			Sleep, 109
			Click, 1088, 264, 0
			Click, 1085, 263, 0
			Sleep, 94
			Click, 1070, 256, 0
			Sleep, 62
			Click, 1068, 255, 0
			Sleep, 63
			Click, 1066, 253, 0
			Sleep, 62
			Click, 1065, 252, 0
			Sleep, 63
			Click, 1065, 252 Left, Down
			Sleep, 78
			Click, 1065, 252 Left, Up
			Sleep, 62
			Click, 1065, 250, 0
			Sleep, 62
			Click, 1094, 218, 0
			Sleep, 78
			Click, 1164, 118, 0
			Sleep, 78
			Click, 1166, 110, 0
			Sleep, 78
			Click, 1166, 110 Left, Down
			Sleep, 63
			Click, 1166, 110 Left, Up
			Sleep, 125
			Click, 1166, 111, 0
			Sleep, 46
			Click, 1172, 172, 0
			Sleep, 78
			Click, 1190, 283, 0
			Sleep, 63
			Click, 1185, 336, 0
			Sleep, 62
			Click, 1157, 378, 0
			Sleep, 78
			Click, 1142, 396, 0
			Sleep, 78
			Click, 1142, 397, 0
			Sleep, 63
			Click, 1138, 389, 0
			Sleep, 78
			Click, 1134, 364, 0
			Sleep, 140
			Click, 1134, 364 Left, Down
			Sleep, 125
			Click, 1134, 364 Left, Up
			Sleep, 187
			Click, 1133, 364, 0
			Sleep, 62
			Click, 1095, 299, 0
			Sleep, 78
			Click, 1067, 258, 0
			Sleep, 63
			Click, 1057, 248, 0
			Sleep, 78
			Click, 1053, 248, 0
			Sleep, 62
			Click, 1050, 249, 0
			Sleep, 63
			Click, 1047, 250, 0
			Sleep, 78
			Click, 1038, 250, 0
			Sleep, 62
			Click, 1030, 251, 0
			Sleep, 62
			Click, 1029, 251, 0
			Sleep, 78
			Click, 1029, 251 Left, Down
			Sleep, 78
			Click, 1029, 251 Left, Up
			Sleep, 468
			Click, 1031, 251, 0
			Sleep, 63
			Click, 1089, 230, 0
			Sleep, 78
			Click, 1192, 175, 0
			Sleep, 78
			Click, 1234, 148, 0
			Sleep, 93
			Click, 1252, 135, 0
			Click, 1253, 134, 0
			Sleep, 110
			Click, 1284, 124, 0
			Sleep, 78
			Click, 1287, 123, 0
			Sleep, 62
			Click, 1287, 123 Left, Down
			Sleep, 78
			Click, 1287, 123 Left, Up
			Sleep, 78
			Click, 1290, 140, 0
			Sleep, 78
			Click, 1293, 233, 0
			Sleep, 78
			Click, 1296, 310, 0
			Sleep, 78
			Click, 1298, 328, 0
			Sleep, 78
			Click, 1300, 342, 0
			Sleep, 16
			Click, 1300, 345, 0
			Sleep, 78
			Click, 1302, 354, 0
			Sleep, 78
			Click, 1302, 362, 0
			Sleep, 62
			Click, 1302, 362 Left, Down
			Sleep, 109
			Click, 1302, 362 Left, Up
			Sleep, 125
			Click, 1297, 361, 0
			Sleep, 78
			Click, 1257, 313, 0
			Sleep, 63
			Click, 1238, 290, 0
			Sleep, 78
			Click, 1228, 282, 0
			Sleep, 78
			Click, 1213, 275, 0
			Sleep, 78
			Click, 1202, 269, 0
			Sleep, 78
			Click, 1194, 263, 0
			Sleep, 62
			Click, 1193, 262, 0
			Sleep, 78
			Click, 1187, 257, 0
			Sleep, 78
			Click, 1182, 253, 0
			Sleep, 109
			Click, 1182, 253 Left, Down
			Sleep, 94
			Click, 1182, 253 Left, Up
			Sleep, 156
			Click, 1189, 262, 0
			Sleep, 78
			Click, 1265, 374, 0
			Sleep, 78
			Click, 1284, 460, 0
			Sleep, 93
			Click, 1290, 542, 0
			Sleep, 78
			Click, 1291, 595, 0
			Sleep, 78
			Click, 1285, 609, 0
			Sleep, 234
			Click, 1285, 609 Left, Down
			Sleep, 94
			Click, 1285, 609 Left, Up
			Sleep, 78
			Click, 1282, 589, 0
			Sleep, 94
			Click, 1279, 518, 0
			Sleep, 62
			Click, 1287, 469, 0
			Sleep, 78
			Click, 1288, 460, 0
			Sleep, 78
			Click, 1289, 459, 0
			Sleep, 156
			Click, 1289, 459 Left, Down
			Sleep, 94
			Click, 1289, 459 Left, Up
			Sleep, 140
			Click, 1289, 458, 0
			Sleep, 78
			Click, 1251, 410, 0
			Sleep, 94
			Click, 1212, 376, 0
			Sleep, 78
			Click, 1207, 369, 0
			Sleep, 93
			Click, 1196, 355, 0
			Sleep, 78
			Click, 1188, 344, 0
			Sleep, 78
			Click, 1187, 342, 0
			Sleep, 78
			Click, 1187, 342 Left, Down
			Sleep, 109
			Click, 1187, 342 Left, Up
			Sleep, 78
			Click, 1186, 358, 0
			Sleep, 78
			Click, 1175, 492, 0
			Sleep, 94
			Click, 1151, 567, 0
			Sleep, 94
			Click, 1146, 581, 0
			Sleep, 62
			Click, 1146, 581 Left, Down
			Sleep, 94
			Click, 1146, 581 Left, Up
			Sleep, 109
			Click, 1146, 576, 0
			Sleep, 93
			Click, 1153, 474, 0
			Sleep, 78
			Click, 1156, 446, 0
			Sleep, 78
			Click, 1156, 443, 0
			Sleep, 188
			Click, 1156, 443 Left, Down
			Sleep, 93
			Click, 1156, 443 Left, Up
			Sleep, 172
			Click, 1156, 441, 0
			Sleep, 78
			Click, 1096, 395, 0
			Sleep, 93
			Click, 1077, 363, 0
			Sleep, 78
			Click, 1068, 350, 0
			Sleep, 94
			Click, 1054, 344, 0
			Sleep, 94
			Click, 1045, 344, 0
			Sleep, 78
			Click, 1041, 343, 0
			Sleep, 93
			Click, 1031, 338, 0
			Sleep, 94
			Click, 1028, 337, 0
			Sleep, 78
			Click, 1028, 337 Left, Down
			Sleep, 78
			Click, 1028, 337 Left, Up
			Sleep, 93
			Click, 1022, 486, 0
			Sleep, 94
			Click, 1005, 564, 0
			Sleep, 94
			Click, 990, 591, 0
			Sleep, 93
			Click, 984, 598, 0
			Sleep, 94
			Click, 975, 613, 0
			Sleep, 93
			Click, 975, 613 Left, Down
			Sleep, 94
			Click, 975, 613 Left, Up
			Sleep, 78
			Click, 996, 589, 0
			Sleep, 78
			Click, 1101, 498, 0
			Sleep, 94
			Click, 1138, 476, 0
			Sleep, 93
			Click, 1149, 471, 0
			Sleep, 78
			Click, 1170, 464, 0
			Sleep, 78
			Click, 1173, 460, 0
			Sleep, 94
			Click, 1175, 458, 0
			Sleep, 93
			Click, 1175, 458 Left, Down
			Click, 1175, 458 Left, Up
			Sleep, 141
			Click, 1175, 457, 0
			Sleep, 78
			Click, 1157, 433, 0
			Sleep, 109
			Click, 1094, 368, 0
			Sleep, 94
			Click, 1070, 352, 0
			Sleep, 78
			Click, 1058, 344, 0
			Sleep, 93
			Click, 1055, 339, 0
			Sleep, 94
			Click, 1055, 339 Left, Down
			Sleep, 78
			Click, 1055, 339 Left, Up
			Sleep, 93
			Click, 1049, 349, 0
			Sleep, 78
			Click, 949, 460, 0
			Sleep, 110
			Click, 871, 552, 0
			Sleep, 109
			Click, 856, 586, 0
			Sleep, 93
			Click, 845, 600, 0
			Sleep, 94
			Click, 838, 606, 0
			Sleep, 78
			Click, 838, 606 Left, Down
			Sleep, 94
			Click, 838, 606 Left, Up
			Sleep, 93
			Click, 887, 550, 0
			Sleep, 94
			Click, 958, 484, 0
			Sleep, 62
			Click, 971, 478, 0
			Sleep, 141
			Click, 1002, 460, 0
			Sleep, 93
			Click, 1009, 456, 0
			Sleep, 94
			Click, 1009, 455, 0
			Sleep, 93
			Click, 1009, 455 Left, Down
			Click, 1009, 455 Left, Up
			Sleep, 156
			Click, 1009, 452, 0
			Sleep, 94
			Click, 962, 389, 0
			Sleep, 94
			Click, 945, 366, 0
			Sleep, 93
			Click, 933, 350, 0
			Sleep, 94
			Click, 918, 342, 0
			Sleep, 93
			Click, 916, 342, 0
			Sleep, 94
			Click, 915, 342, 0
			Sleep, 94
			Click, 914, 342 Left, Down
			Sleep, 78
			Click, 914, 342 Left, Up
			Sleep, 93
			Click, 888, 370, 0
			Click, 881, 378, 0
			Sleep, 141
			Click, 719, 600, 0
			Sleep, 109
			Click, 700, 630, 0
			Sleep, 93
			Click, 696, 634, 0
			Sleep, 78
			Click, 696, 634 Left, Down
			Sleep, 94
			Click, 696, 634 Left, Up
			Sleep, 94
			Click, 738, 570, 0
			Sleep, 109
			Click, 817, 498, 0
			Sleep, 93
			Click, 855, 476, 0
			Sleep, 94
			Click, 873, 465, 0
			Sleep, 94
			Click, 877, 460, 0
			Sleep, 124
			Click, 876, 460, 0
			Sleep, 94
			Click, 838, 471, 0
			Sleep, 94
			Click, 772, 524, 0
			Sleep, 109
			Click, 711, 595, 0
			Sleep, 93
			Click, 700, 607, 0
			Sleep, 94
			Click, 698, 609, 0
			Sleep, 94
			Click, 698, 609 Left, Down
			Sleep, 93
			Click, 698, 609 Left, Up
			Sleep, 94
			Click, 728, 560, 0
			Sleep, 109
			Click, 803, 485, 0
			Sleep, 94
			Click, 845, 465, 0
			Sleep, 109
			Click, 879, 452, 0
			Sleep, 109
			Click, 882, 451, 0
			Sleep, 94
			Click, 882, 450 Left, Down
			Sleep, 109
			Click, 882, 450 Left, Up
			Sleep, 109
			Click, 868, 434, 0
			Sleep, 94
			Click, 791, 367, 0
			Sleep, 109
			Click, 773, 359, 0
			Sleep, 93
			Click, 751, 349, 0
			Sleep, 94
			Click, 750, 348, 0
			Sleep, 109
			Click, 748, 343, 0
			Sleep, 94
			Click, 748, 341 Left, Down
			Sleep, 93
			Click, 748, 341 Left, Up
			Sleep, 125
			Click, 747, 342, 0
			Sleep, 109
			Click, 634, 495, 0
			Sleep, 110
			Click, 587, 560, 0
			Sleep, 109
			Click, 551, 603, 0
			Sleep, 109
			Click, 545, 609, 0
			Sleep, 109
			Click, 545, 609 Left, Down
			Sleep, 94
			Click, 545, 609 Left, Up
			Sleep, 93
			Click, 549, 582, 0
			Sleep, 125
			Click, 632, 485, 0
			Sleep, 109
			Click, 672, 462, 0
			Sleep, 94
			Click, 704, 454, 0
			Sleep, 109
			Click, 724, 454, 0
			Sleep, 109
			Click, 725, 454 Left, Down
			Sleep, 110
			Click, 725, 454 Left, Up
			Sleep, 93
			Click, 718, 450, 0
			Sleep, 109
			Click, 608, 380, 0
			Sleep, 110
			Click, 593, 360, 0
			Sleep, 109
			Click, 591, 353, 0
			Sleep, 93
			Click, 591, 343, 0
			Sleep, 110
			Click, 592, 342, 0
			Sleep, 93
			Click, 592, 341 Left, Down
			Sleep, 125
			Click, 592, 341 Left, Up
			Sleep, 312
			Click, 583, 347, 0
			Sleep, 109
			Click, 530, 439, 0
			Click, 526, 449, 0
			Sleep, 172
			Click, 467, 572, 0
			Sleep, 93
			Click, 407, 616, 0
			Sleep, 125
			Click, 404, 616, 0
			Sleep, 94
			Click, 404, 616 Left, Down
			Sleep, 109
			Click, 404, 615 Left, Up
			Sleep, 109
			Click, 452, 523, 0
			Sleep, 125
			Click, 507, 478, 0
			Sleep, 109
			Click, 549, 466, 0
			Sleep, 125
			Click, 572, 455, 0
			Sleep, 109
			Click, 572, 455 Left, Down
			Sleep, 109
			Click, 572, 455 Left, Up
			Sleep, 110
			Click, 522, 395, 0
			Sleep, 124
			Click, 489, 360, 0
			Sleep, 110
			Click, 474, 349, 0
			Sleep, 109
			Click, 463, 342, 0
			Sleep, 93
			Click, 463, 341, 0
			Sleep, 94
			Click, 463, 341 Left, Down
			Sleep, 109
			Click, 459, 343 Left, Up
			Sleep, 109
			Click, 379, 444, 0
			Sleep, 110
			Click, 273, 546, 0
			Sleep, 124
			Click, 253, 573, 0
			Sleep, 110
			Click, 243, 584, 0
			Sleep, 109
			Click, 243, 584 Left, Down
			Sleep, 93
			Click, 243, 584 Left, Up
			Sleep, 125
			Click, 303, 522, 0
			Sleep, 109
			Click, 373, 471, 0
			Sleep, 125
			Click, 402, 451, 0
			Sleep, 109
			Click, 405, 450, 0
			Sleep, 94
			Click, 405, 450 Left, Down
			Sleep, 109
			Click, 405, 450 Left, Up
			Sleep, 109
			Click, 339, 376, 0
			Sleep, 125
			Click, 303, 338, 0
			Sleep, 109
			Click, 300, 335, 0
			Sleep, 94
			Click, 300, 335 Left, Down
			Sleep, 109
			Click, 300, 335 Left, Up
			Sleep, 109
			Click, 287, 352, 0
			Sleep, 110
			Click, 160, 500, 0
			Sleep, 109
			Click, 75, 589, 0
			Sleep, 15
			Click, 73, 591, 0
			Sleep, 234
			Click, 64, 609, 0
			Sleep, 110
			Click, 64, 609 Left, Down
			Sleep, 15
			Click, 64, 609 Left, Up
			Sleep, 219
			Click, 203, 468, 0
			Sleep, 109
			Click, 257, 446, 0
			Sleep, 125
			Click, 259, 446, 0
			Sleep, 109
			Click, 259, 446 Left, Down
			Sleep, 109
			Click, 259, 446 Left, Up
			Sleep, 109
			Click, 254, 448, 0
			Sleep, 125
			Click, 216, 432, 0
			Sleep, 125
			Click, 169, 358, 0
			Sleep, 109
			Click, 157, 347, 0
			Sleep, 109
			Click, 155, 345, 0
			Sleep, 109
			Click, 154, 344, 0
			Sleep, 125
			Click, 151, 342, 0
			Sleep, 94
			Click, 151, 342 Left, Down
			Sleep, 109
			Click, 151, 342 Left, Up
			Sleep, 390
			Click, 150, 343, 0
			Sleep, 109
			Click, 138, 403, 0
			Sleep, 125
			Click, 110, 609, 0
			Sleep, 125
			Click, 108, 695, 0
			Sleep, 109
			Click, 100, 706, 0
			Sleep, 125
			Click, 77, 708, 0
			Sleep, 125
			Click, 58, 704, 0
			Sleep, 93
			Click, 54, 704, 0
			Sleep, 125
			Click, 50, 703, 0
			Sleep, 109
			Click, 49, 702, 0
		}
		CoordMode, Mouse, Client
		SetMouseDelay, %mousedelay%
		Return
	

	;刷分用 结束发言
	F12::
		global Loop1Num = 0
		global Loop2Num = 0
		GroupAdd, test, ahk_exe 狼人游戏.exe
		Loop {
			/**
			S1：全部坐下
			S2：开始游戏
			S3：平安夜阶段
			S4：收尾杀人阶段
			*/
			Loop, 6
			{
				SetControlDelay -1
				ControlClick, X1245 Y239, ahk_group test,,,, NA	;点击加入游戏
				Sleep, 800
				GroupActivate, test
				Sleep, 800
			}
			Loop, 12
			{
				SetControlDelay -1
				ControlClick, X1354 Y337, ahk_group test,,,, NA	;点击 开始游戏 或 右侧空白
				SendInput {Enter}
				Sleep, 500
				ControlClick, X1280 Y330, ahk_group test,,,, NA	;点击 中间位置的开始游戏
				Sleep, 500
				ControlClick, X616 Y418, ahk_group test,,,, NA	;点击 yes 禁用yn
				Sleep, 500
				GroupActivate, test
				Sleep, 500
			}
			;Loop, 12 {
			Loop, 702 {
				SetControlDelay -1
				SendInput, {Enter}
				Sleep, 100
				ControlClick, X693 Y432, ahk_group test,,,, NA	;刷新
				Sleep, 100
				ControlClick, X1280 Y330, ahk_group test,,,, NA	;点击 结束发言
				Sleep, 100
				ControlClick, X1223 Y341, ahk_group test,,,, NA	;刷新
				Sleep, 800
				SendInput, {Enter}
				Sleep, 200
				SendInput, {Enter}
				GroupActivate, test
				Sleep, 100
				Loop1Num = %A_Index%
			}
			Loop, 240 {
				SetControlDelay -1
				SendInput, {Enter}
				Sleep, 100
				ControlClick, X693 Y432, ahk_group test,,,, NA	;刷新
				Sleep, 100
				ControlClick, X1280 Y330, ahk_group test,,,, NA	;点击 结束发言
				Sleep, 100
				ControlClick, X841 Y124, ahk_group test,,,, NA	;点击6号
				Sleep, 100
				ControlClick, X692 Y124, ahk_group test,,,, NA	;点击5号
				Sleep, 100
				ControlClick, X542 Y124, ahk_group test,,,, NA	;点击4号
				Sleep, 100
				ControlClick, X391 Y124, ahk_group test,,,, NA	;点击3号
				Sleep, 100
				ControlClick, X244 Y124, ahk_group test,,,, NA	;点击2号
				Sleep, 100
				;ControlClick, X1223 Y341, ahk_group test,,,, NA	;刷新
				;Sleep, 700
				;SendInput, {Enter}
				;Sleep, 200
				;SendInput, {Enter}		;杀人阶段不要刷新，否则会触发同一IP检测，离开房间
				GroupActivate, test
				Sleep, 100
				Loop2Num = %A_Index%
			}
			/*Loop, 6
			{
				ControlClick, X1223 Y341, ahk_group test,,,, NA	;刷新
				Sleep, 1000
				SendInput, {Enter}
				Sleep, 200
				SendInput, {Enter}
			}
			*/
		}
		return
	
	
	CoordMode, Mouse, Client
}

;-------------------------------------------------------------------------------
;~ 浏览器 全屏@Flash 看视频时
;-------------------------------------------------------------------------------
#IfWinActive ahk_exe plugin-container.exe
{
	Space:: SendInput, {LButton}
}

;-------------------------------------------------------------------------------
;~ 游戏 @疯石
;-------------------------------------------------------------------------------
#IfWinActive ahk_exe CrazyStoneDeepLearning.exe
{
	F1::
		WinMove, A, , 665, 0
		WinSet, AlwaysOnTop, Toggle, A
		return
	1::ControlClick, X700 Y210, ahk_exe CrazyStoneDeepLearning.exe
	2::ControlClick, X663 Y174, ahk_exe CrazyStoneDeepLearning.exe
	3::ControlClick, X720 Y253, ahk_exe CrazyStoneDeepLearning.exe
	
	
}

;关闭上下文相关性，以下命令，全部针对全局
#IfWinActive
;注意以下只能写快捷键。如果写全局命令，不会被执行的。运行的命令，要写在脚本开头

