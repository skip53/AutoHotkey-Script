;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; 声明：
;;; 1、用KeyTweak改键盘映射，capslock改为Numpad0了，否则做快捷键总是激活大小写
;;; 切换，很烦
;;; 2、原生AutoHotkey不支持真正多线程(多个程序不能并行跑)，用AutoHotkey_H又嫌麻
;;; 烦，所以改成多进程：全局程序另写脚本，再调用
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;-------------------------------------------------------------------------------
;~ 脚本配置 #Include等
;-------------------------------------------------------------------------------
{
	;提升性能相关的配置
	#NoEnv						;不检查空变量是否为环境变量
	SetBatchLines, -1			;行之间运行不留时间空隙,默认是有10ms的间隔
	SetKeyDelay, -1, -1			;发送按键不留时间空隙
	SetMouseDelay, -1			;每次鼠标移动或点击后自动的延时=0   
	SetDefaultMouseSpeed, 0		;设置在 Click 和 MouseMove/Click/Drag 中没有指定鼠标速度时使用的速度 = 瞬间移动.
	;如果以前录制的脚本,因延时变短,出问题,命令 MouseClick, MouseMove 和 MouseClickDrag 都提供了一个用来设置鼠标速度代替默认速度的参数.用它们自己的参数,设定移动速度
	SetWinDelay, 0
	SetControlDelay, 0
	SendMode Input				;;所有Send命令，统一采用最快的SendInput

	;include外部函数
	#Include %A_LineFile%\..\..\Functions\WinClip\WinClipAPI.ahk
	#Include %A_LineFile%\..\..\Functions\WinClip\WinClip.ahk
	;#Include %A_LineFile%\..\..\Functions\url编码解码库 url_encode_decode\url_encode_decode.ahk	;该脚本必须以ANSI运行
	#Include %A_LineFile%\..\..\Functions\TrayIcon library 操纵右下角 系统托盘区 的图标，可右键点击调出菜单\TrayIcon by FanaticGuru.ahk
	#Include %A_LineFile%\..\..\Functions\WinHttpRequest 网络函数 HTTP get post\WinHttpRequest.ahk
	#Include %A_LineFile%\..\..\Functions\GetActiveBrowserURL 获取浏览器窗口的地址 等信息\GetActiveBrowserURL.ahk
	#Include %A_LineFile%\..\..\辅助工具\快捷抓取、查找屏幕文字／图像字符串\函数部分 v5.6.ahk

	;性能以外的脚本配置
	#InstallKeybdHook			;安装键盘和鼠标钩子 像Input和A_PriorKey，都需要钩子
	#InstallMouseHook
	SetTitleMatchMode Regex		;更改进程匹配模式为正则
	#SingleInstance FORCE		;决定当脚本已经运行时是否允许它再次运行。
	#Persistent					;持续运行不退出
	#MaxThreadsPerHotkey 5
	CoordMode, Mouse, Client	;鼠标坐标采用Client模式
	;SetCapsLockState,AlwaysOff
	CountStp := 0				;一键多用的计时器
	mloflag := 0				;MyLifeOrganized的状态标识  1 = widget模式   0 = 正常模式
	#Hotstring EndChars  `n		;编辑热字串的终止符

	Menu, Tray, Icon, %A_LineFile%\..\Icon\自定义快捷操作.ico, , 1
	Menu, tray, tip, 自定义快捷键、自动保存 by LL
	TrayTip, 提示, 脚本已启动, , 1
	Sleep, 1000
	TrayTip
	;return		;注：这里不能加return  原因搜索帮助文件的「自动执行段」：程序执行到return，就会停止，后面的行，不会再执行
}

;-------------------------------------------------------------------------------
;~ 多进程 和 @菜单
;-------------------------------------------------------------------------------
{
	Run, %A_LineFile%\..\3. 快捷输入.ahk
	Run, %A_LineFile%\..\4. 结束垃圾进程.ahk
	Run, %A_LineFile%\..\5. 自动保存文件.ahk
	Run, %A_LineFile%\..\6. 图片上传七牛云.ahk
	Run, %A_LineFile%\..\7. 快速启动器.ahk
	Run, %A_LineFile%\..\8. 表情包.ahk
	Run, %A_LineFile%\..\9. 基于窗口切换输入法.ahk
	
	;注意：menu菜单的定义，必须在“自动执行段”
	Menu, WholeOSMenu, Add, 注册表-定位路径			;如果省略 Label-or-Submenu, 那么将使用 MenuItemName 同时作为标签和菜单项的名称.
}

;-------------------------------------------------------------------------------
;~ 函数部分
;-------------------------------------------------------------------------------
{
	;TotalCommander和资源管理器，跳转到沙盘同路径时，询问哪个沙盘
	getWhichSBIE() {
		allSBIEName := []
		promptMsgNeedToShow := "请直接输入序号:`n`n"
		loop, Files, d:\TechnicalSupport\Sandbox\LL\*, D
		{
			allSBIEName.Push(A_LoopFileName)
			promptMsgNeedToShow := promptMsgNeedToShow . A_Index . ".  " . A_LoopFileName . "`n"
		}
		InputBox, whichSBIE, , %promptMsgNeedToShow%,,, 400, ,,,, 1
		SBIEName := allSBIEName[whichSBIE]
		return SBIEName
	}
	
	;kill进程的方式, 来关闭窗口，因为WinKill有时还是不管用，比如针对notepad2
	Processkill(WinTitle="A") {
		WinGet, prid, PID, %WinTitle%
		Process, Close, %prid%
	}
				
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
	判断当前输入状态，目前网上提到的方法有4种。没有万金油方法，具体情况具体使用：
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
;~ 控制当前运行是Unicode32版,若不是则切换 (U64虽然比U32运行更快，但这个脚本用U64总莫名故障)
;-------------------------------------------------------------------------------
{
	SplitPath A_AhkPath,, AhkDir
	If ( !(A_PtrSize = 4 && A_IsUnicode ) ) {
		U32 := AhkDir . "\AutoHotkeyU32.exe"
		If (FileExist(U32)) {
			Run %U32% "%A_LineFile%"
			ExitApp
		} Else {
			MsgBox 0x2010, AutoGUI, AutoHotkey 32-bit Unicode not found.
			ExitApp
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
	;快捷输入
	{
		Tab & s:: Send, ▶{Space}			;	右三角
		Tab & d:: Send, •{Space}			;	圆点
		;Tab & f:: Send, ■{Space}			;	方点
		;Tab & g:: Send, √{Space}
		Tab & f:: Send, ●{Space}			;	大圆点
		Tab & 1:: Send, ①{Space}
		Tab & 2:: Send, ②{Space}
		Tab & 3:: Send, ③{Space}
		Tab & 4:: Send, ④{Space}
		Tab & 5:: Send, ⑤{Space}
		Tab & 6:: Send, ⑥{Space}
		Tab & 7:: Send, ⑦{Space}
		Tab & 8:: Send, ⑧{Space}
		Tab & a:: sendL("( ส็็็็็็็็็็็็็็็็็็็็็็็็็็็็็็็็็็็็็็็็็็็็็็็็็็็็็็็็็ 　不了ส้้้้้้้้้้้้้้้้้้้้้้้้้้้้้้้้้้้้้้้้้้้้้้้้้้้้้้้้้) ")   ;喷射字符
		Numpad0 & 1:: Send, ❶{Space}
		Numpad0 & 2:: Send, ❷{Space}
		Numpad0 & 3:: Send, ❸{Space}
		Numpad0 & 4:: Send, ❹{Space}
		Numpad0 & 5:: Send, ❺{Space}
		Numpad0 & 6:: Send, ❻{Space}
		Numpad0 & 7:: Send, ❼{Space}
		Numpad0 & 8:: Send, ❽{Space}
		LButton & Space::Run, %A_LineFile%\..\..\其它语言函数or库\nircmd-x64\nircmd.exe standby		;系统睡眠
		$`:: sendL("``")
		
		` & d::
			FormatTime, nowTime, , yyyyMMdd
			SendL(nowTime)
			return
		
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
		~LButton & r::Reload    ;子脚本已添加#SingleInstance FORCE 所以会自动跟随reload
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
		
		;配合Listary快速启动
		#r::SendInput, ^!+r
		
		;配合Actual Window Manager做虚拟桌面切换
		#F1::SendInput, !#{F1}
		#F2::SendInput, !#{F2}

		;输入 不可见&宽度0 的字符
		;~ Tab & Space:: SendInput, {U+2067}{U+2068}{U+2069}{U+206A}{U+206B}{U+206C}
		Tab & Space:: SendInput, {U+200B}      ;输入零宽度空格
		
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
			InputBox, NewLastKey, 请输入欲定位的注册表路径(!!末尾不能含斜杠!!), , 800, 130
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
		!x::Run "d:\Dropbox\Technical_Backup\ProgramFiles.Trust\MEOW-x64 cow的替代品 白名单fork\rc.txt"
		!z::Run "d:\Dropbox\Technical_Backup\ProgramFiles.Trust\MEOW-x64 cow的替代品 白名单fork\proxy.txt"
		;cow reload
		!c::
			MouseGetPos, xpos, ypos 				;记忆鼠标位置
			TrayIcon_Button("MEOW.exe", "R")
			Sleep, 500
			MouseMove, 20, 80,, R
			MouseClick, left
			TrayIcon_Button("MEOW.exe", "R")
			Sleep, 1000
			MouseMove, 20, 35,, R
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
				Processkill()
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
			SetTimer, tkds, -500    ;负数，表示只运行一次
			Return
			tkds:
				if CountStp = 1 ;只按一次时执行
				{
					SendInput, #+f
					WinWaitActive, ahk_class ENMainFrame, , 2
					Sleep, 200
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
	;快捷输入
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
	}
	
	;操作类快捷键
	{
		^Space::controlsend, , ^{Space}, A   	;简化格式
		;F1::Menu, LangRenMenu, Show
		F1::MsgBox % "Ctrl + Alt + A 	切换用户`nF10 	显示/隐藏左侧边栏`nF11 	显示/隐藏笔记列表`nCtrl + Q 	快捷搜索`nShift + Alt + T 	跳转到标签??`nAlt + Shift + D 	插入日期和时间`nAlt + F2 	搜索标签`nCtrl-Shift-E 	搜狗输入法的英文模式`n`n用UltraEdit+RTF粘贴 来做代码高亮"
		Numpad0 & r::SendInput !vpb		;显示回收站
		~LButton & a::SendInput, ^!a	;切换账户
		^+z::SendInput, ^y
		
		F5::		;复制到当前笔记本
		{
			SendInput, {AppsKey}c
			;~ WinWait, 复制笔记到笔记本
			WinWait, Copy Note to Notebook
			Sleep, 100
			SendInput, {Enter}
			return
		}
		
		F6::		;导出笔记
		{
			SendInput, {AppsKey}x{Enter}
			WinWait, ahk_class #32770
			SendInput, {Enter}
			return
		}
		
		Tab & a::	;加括号
		{
			Send, ^x
			Send, (%Clipboard%)
			return
		}
		
		$F3::		;打标签
		{
			CountStp := ++CountStp
			SetTimer, dktc, -500    ;负数，表示只运行一次
			Return
			dktc:
				if CountStp = 1 ;只按一次时执行
					SendInput, !{F2}				;批量打标签（搜索标签，支持拖拽）
				if CountStp = 2 ;按两次时...
					SendInput, ^!t				;批量打标签  Assign界面不支持筛选标签，不要用了
				CountStp := 0 ;最后把记录的变量设置为0,于下次记录.
				Return
		}		
		
		$RButton::	;双击右键，高亮，和Firefox习惯一样
		{
			CountStp := ++CountStp
			SetTimer, TimerPrtSc, -500
			Return
			TimerPrtSc:
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
			CoordMode, Mouse, Screen	;鼠标坐标全屏幕模式，方便鼠标回归原位
			MouseGetPos, xpos, ypos 
			文字:=""
			文字.="|<>52.0000300000000200000000401zzU007k03tw000V0073U002400840008k0000000R0008"
			if 查找文字(929,181,150000,150000,文字,"*147",X,Y,OCR,0.2,0.2)
			{
				CoordMode, Mouse
				Click, %X%, %Y%		;点击颜色按钮
				Y1 := Y + 180
				Click, %X%, %Y1%	;点击更多颜色
			}
			else
			{
				MsgBox, 没有找到颜色选择框,找字模块失败!
			}
			;SendL("M")			;进入更多颜色		
			WinWait, 颜色
			WinMove, 10, 10
			CoordMode, Mouse, Client	;鼠标坐标Client模式
			Click, 116, 333		;进入自定义颜色
			SendInput, {Tab}{Tab}{Tab}
			SendInput %r%{Tab}%g%{Tab}%b%{Tab}{Space}
			Click, 21, 259		;点击设定好自定义颜色
			SendInput, {Tab}{Space}
			CoordMode, Mouse, Screen	;鼠标坐标全屏幕模式
			MouseMove, %xpos%, %ypos%, 0
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
			
			;v6下用evernoteEditText()回帖，前面都会多一个空格，无解。但删除一下也不麻烦，聊胜于无吧
			;背景色黄色
			!1::evernoteEditText("<span style='background: #FFFAA5;'>", "</span>")
			;背景色蓝色
			!2::evernoteEditText("<span style='background: #ADD8E6;'>", "</span>")		;不要蓝色#ADD8E6
			;背景色灰色
			!3::evernoteEditText("<span style='background: #D3D3D3;'>", "</span>")
			;背景色绿色
			!4::evernoteEditText("<span style='background: #90EE90;'>", "</span>")		;原颜色#FFD796
			
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
		clipboard =
		send ^c
		ClipWait, 1
		clipboard = %clipboard%
		SplitPath, clipboard, name
		clipboard = %name%
		return
	}

	;复制含文件名的完整路径
	^3::	
	{
		clipboard =
		send ^c
		ClipWait, 1
		clipboard = %clipboard%
		return
	}
	
	;tc中打开同路径目录
	^t::
	{
		clipboard =
		clipboard := ActiveFolderPath("")
		ClipWait, 1
		SendInput, !{F4}							;关闭explorer窗口
		Run, "d:\TechnicalSupport\ProgramFiles\Total Commander 8.51a\TOTALCMD.EXE" /O /T /L="%Clipboard%"
		return
	}
	
	;tc中打开沙盘中的同路径
	^s::
	{
		clipboard =
		clipboard := ActiveFolderPath("")
		ClipWait, 1
		StringReplace, clipboard, clipboard, :		;删除冒号
		SendInput, !{F4}							;关闭explorer窗口
		SBIEname := getWhichSBIE()
		Run, "d:\TechnicalSupport\ProgramFiles\Total Commander 8.51a\TOTALCMD.EXE" /O /T /S /R="d:\TechnicalSupport\Sandbox\LL\%SBIEname%\drive\%Clipboard%"
		return
	}
}

;-------------------------------------------------------------------------------
;~ @Anki快捷键
;-------------------------------------------------------------------------------
#IfWinActive, ahk_exe anki.exe
{
	F1::Send, ^+c		;新建cloze
	F2::Send, ^+!c		;新建cloze，序号不增加
	F3::SendInput, {F7}^b	;快速加颜色加粗
	$`:: sendL("‧")		;用于不需要复现的伴随cloze的提示，不是1左边的点，是更淡的unicode
	
	#If WinActive("Anki - User 1")
	1::sendL("@")	;suspend card
	2::sendL("!")	;suspend note
	3::sendL("-")	;bury card
	4::sendL("=")	;bury note
	c::SendInput, ^!c	;查看statics
	#If
	
	/*;增量阅读，把透析的快捷键，改变成`
	`::
		Send, ^+!q
		return
		
	;增量阅读，添加为析取qa后，自动关闭，方便下一次析取
	^Enter::
		Send, ^{Enter}
		sleep, 300
		Send, {Esc}
		return
	
	;~ ` & 1::	SendInput, ^+!c{Left}{Left}{U+003A}{U+003A}简要复述
	
	;Brower中预览卡片
	;~ Numpad0 & q::SendInput, ^+p
	*/
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
	
	;切换伪•桌面widget模式
	^Home::
	{
		if ( mloflag == 1 )
		{
			WinSet, AlwaysOnTop, Off, A
			WinMove, A,, 163, 32, 1056, 650
			Send {F12}			;从小变大，要后!{F2}，否则边栏宽度出问题
			mloflag := 0
		}
		else
		{
			Send {F12}
			WinSet, AlwaysOnTop, On, A
			WinMove, A,, 1128, 28, 50, 10
			CoordMode, Mouse, Screen
			MouseGetPos, mousepoX, mousepoY
			CoordMode, Mouse, Relative
			Click, 179, 243
			Click, 179, 243
			MouseMove, 123, 97
			Sleep 100
			Click, down
			MouseMove, 196, 96, 10
			Click, Up
			CoordMode, Mouse, Screen
			MouseMove, %mousepoX%, %mousepoY%
			mloflag := 1
		}
		return
	}
	
	
	;简化本来已有的快捷键
	{
		#If ( WinActive("ahk_class TfrmMyLifeMain") && A_CaretX = "")
		m:: SendInput, ^m
		c:: SendInput, ^c
		s:: 
		{
			CountStp := ++CountStp
			SetTimer, dcxyh, -500
			Return
			dcxyh:
				if CountStp = 1 ;只按一次时执行
				{
					SendInput, ^+!s
					WinWait, Skip occurrence, , 2
					SendInput, {Enter}
				}
				if CountStp = 2 ;按两次时...
				{
					SendInput, ^+!s
					WinWait, Skip occurrence, , 2
					SendInput, {Down}{Enter}
				}
			CountStp := 0 ;最后把记录的变量设置为0,于下次记录.
			Return
		}
		v:: 
		{
			CountStp := ++CountStp
			SetTimer, jkdfs, -500
			Return
			jkdfs:
				if CountStp = 1 ;只按一次时执行
				{
					Send, ^v
					WinWait, ahk_class TRadioChoice, , 2
					SendInput, {Down}{Enter}
				}
				if CountStp = 2 ;按两次时...
				{
					Send, ^v
					WinWait, ahk_class TRadioChoice, , 2
					SendInput, {Enter}
				}
			CountStp := 0 ;最后把记录的变量设置为0,于下次记录.
			Return
		}
		F1:: SendInput, ^+!x	;Inbox view
		F3:: SendInput, ^+!{F3}	;todo view
		delete::  ;删除到垃圾桶
		{
			SendInput, ^m
			WinWait, ahk_class TfrmSelectTaskNode
			SendInput, {Down}{End}{Enter}
			return
		}
		$Insert::
		{
			CountStp := ++CountStp
			SetTimer, kdlst, -500
			Return
			kdlst:
				if CountStp = 1 ;只按一次时执行
					Send, {Insert}
				if CountStp = 2 ;按两次时...
					Send, !{Insert}
				CountStp := 0 ;最后把记录的变量设置为0,于下次记录.
				Return
		}
			
		
		#If WinActive("ahk_class TfrmMyLifeMain")	;;;;;;;;;;;;注意AutoHotkey不支持#IfWinActive 和 #If 的嵌套，务必记得#if完，恢复之前的上下文
	}
	
}

;-------------------------------------------------------------------------------
;~ @TotalCommander快捷键
;-------------------------------------------------------------------------------
#IfWinActive ahk_class TTOTAL_CMD
{
	;关闭当前标签
	`::Send, ^w

	;在win7自带资源管理器中打开同路径
	^e::
		clipboard =
		Send, ^1
		ClipWait, 1
		Run, %Clipboard%
		return
	
	;在对侧窗口打开沙盘中同路径
	^s::
		clipboard =
		Send, ^1
		ClipWait, 1
		StringReplace, clipboard, clipboard, :		;删除冒号
		SBIEname := getWhichSBIE()
		Run, "d:\TechnicalSupport\ProgramFiles\Total Commander 8.51a\TOTALCMD.EXE" /O /T /S /R="d:\TechnicalSupport\Sandbox\LL\%SBIEname%\drive\%Clipboard%"
		return
		
	;压缩多文件为uvz：自动重命名和勾选选项
	#F5::
		SendInput, !{F5}{Right}{BS}{BS}{BS}
		sendL("uvz")
		Sleep, 500
		Control, Check, , TCheckBox2, ahk_class TDLGZIP
		Control, Uncheck, , TCheckBox1, ahk_class TDLGZIP
		ControlClick, TButton5, ahk_class TDLGZIP
		;SendInput, !n{Tab}{Tab}{Tab}{Space}
		return
	
	;文件夹被占用，无法删除时，查看是被谁占用的
	^Del::
		Clipboard := 
		SendInput, ^1
		ClipWait, 1
		commands = ("d:\Dropbox\Technical_Backup\ProgramFiles.Trust\Handle 查看文件夹或文件 被哪个程序占用 而无法删除\handle64.exe" %Clipboard% & echo "直接taskkill /PID来结束进程")
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
		SetTimer, T0, -500 
		Return

		T0:
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
		
		;Diigo快捷键
		F3::
		{
			Send, ^!b		;配合diigo的侧边栏
			设定时间 := A_Now
			设定时间 += 3,Seconds
			文字:=""
			文字.="|<>53.0000Y0001XU1V80003bW32SIMeDTY64yttqSxMA9hVn5rPkMGO7YDir0kaoP8RBa1tD8SEM0A000000k1k0000078"
			Loop
			{
				if 查找文字(33,113,50,50,文字,"*143",X,Y,OCR,0.4,0.4)
				{
					Sleep, 500
					ControlClick, x170 y168, A  			;Click, 152, 170 但不移动鼠标
					SendInput, +{Home}{BackSpace}
					;~ MsgBox, 找到了
					break
				} 
				If ( A_Now > 设定时间)
				{
					MsgBox, 没找到啊
					break
				}
			}			
			return
		}
		
		;用AutoHotkey绑定`和关闭标签，容易写代码时误关闭，改为用ff脚本KeyChanger做。
		;但KeyChanger在空白tab和Google上又自动进入输入焦点，还是回到ahk。判断下当前是否输入状态吧
		$`::
			if not IME_GET()
				Send, ^w		;关闭当前标签
			Else
				sendL("``")
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
		;~ Numpad0 & q::openLink("http://book.szdnet.org.cn/search?Field=all&channel=search&sw=", "")
		Numpad0 & q::openLink("http://books.gdlink.net.cn/search?Field=all&channel=search&sw=", "")
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
	;~ 基于网址的自定义   ;是无效的，因为if里的快捷键，执行不了，要#if方可
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
;~ @豆瓣 桌面客户端快捷键 （伪Firefox）
;-------------------------------------------------------------------------------
#IfWinActive Mozilla Firefox \[#\]
{
	MButton:: SendInput, {LButton}
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
		;~ $Enter::SendInput, +{Enter}
		;~ $^Enter::SendInput, {Enter}
		
		;tab
		;Tab::SendInput, {Space}{Space}{Space}{Space}
		
		!F1::SendInput, !s
	}
	
	~LButton & q::MsgBox % GetProcessMemory_All("chrome.exe")
}

;-------------------------------------------------------------------------------
;~ SciTE4AutoHotkey 快捷键
;-------------------------------------------------------------------------------
#IfWinActive ahk_exe SciTE.exe
{
	^/::ControlSend,, ^q, A 			;行首注释
	^+c::  								;RTF复制
		KeyWait Control					;keywait的用法！不加是不行的
		KeyWait Shift
		Send {Alt}ef
		return
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
				Run, %A_LineFile%\..\..\其它语言函数or库\nircmd-x64\nircmd.exe mutesysvolume 1
				;用外部程序来执行静音，避免{Volume_Mute}和搜狗输入法的冲突，参见：http://ahk8.com/thread-2650.html
				Run, "D:\Dropbox\Technical_Backup\ProgramFiles.Trust\Shutdown8  定时关机\Shutdown8 关机.exe"
				;关闭盖子，不睡眠不关机  参见 https://superuser.com/questions/874849/change-what-closing-the-lid-does-from-the-commandline
				commands = (powercfg -SETACVALUEINDEX 381b4222-f694-41f0-9685-ff5bb260df2e 4f971e89-eebd-4455-a8de-9e59040e7347 5ca83367-6e45-459f-a27b-476b1d01c936 0 & powercfg -SETDCVALUEINDEX 381b4222-f694-41f0-9685-ff5bb260df2e 4f971e89-eebd-4455-a8de-9e59040e7347 5ca83367-6e45-459f-a27b-476b1d01c936 0)
				RunWait, %comspec% /c %commands%
				Sleep, 5000			;防止后面的程序，遮盖窗口
				;~ Run, "D:\TechnicalSupport\ProgramFiles.Untrust\Thunder Network\Thunder\Program\Thunder.exe"
				;~ Run, "C:\Users\LL\AppData\Roaming\Resilio Sync\Resilio Sync.exe"
				Run, "D:\TechnicalSupport\ProgramFiles\Sandboxie\Start.exe" /box:5Dropbox "C:\ProgramData\Microsoft\Windows\Start Menu\程序\Dropbox\Dropbox.lnk"
			}
		}
		return
}

;-------------------------------------------------------------------------------
;~ @记事本@Notepad/Notepad2.exe
;-------------------------------------------------------------------------------
/*#IfWinActive ahk_exe (notepad.exe|Notepad2.exe)
{
	~Esc::
		if (A_ThisHotKey = A_PriorHotKey and A_TimeSincePriorHotkey < 500) 
		{
			SendInput, !{F4}
			SendInput, n
			;WinKill, A       ;不管用
		}
		return
	
}
*/

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
;~ 浏览器 全屏@Flash 看视频时
;-------------------------------------------------------------------------------
#IfWinActive ahk_exe plugin-container.exe
{
	;~ Space:: SendInput, {LButton}
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

