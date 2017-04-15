;-------------------------------------------------------------------------------
;~ 软件快速启动器a
;-------------------------------------------------------------------------------
#SingleInstance FORCE	;决定当脚本已经运行时是否允许它再次运行,记得用force，这样主脚本reload时，子脚本也自动reload了
SetTitleMatchMode Regex	;更改进程匹配模式为正则
#Persistent				;持续运行不退出
#NoTrayIcon				;隐藏托盘图标
SendMode Input			;所有Send命令，统一采用最快的SendInput

#Include d:\Dropbox\Technical_Backup\AHKScript\Functions\Menu - some functions related to AHK menus  关于menu菜单的库\Menu.ahk

class MenuClass {
	static wholeMenuList := {}		;里面存储的是对象，不是字符串
	indexOfWholeMenuList :=	
	
	__New(hotkeyOfMenu) {		
		MenuClass.wholeMenuList[hotkeyOfMenu] := this
		this.indexOfWholeMenuList := hotkeyOfMenu
	}
	
	checkMenuExist(hotkeyAndNameOfMenu) {				;函数不太区分 类函数 还是 实例函数，都能用
		if ( MenuClass.wholeMenuList[hotkeyAndNameOfMenu] != "" )
			return MenuClass.wholeMenuList[hotkeyAndNameOfMenu]
		else
		{
			newMenu := new MenuClass(hotkeyAndNameOfMenu)
			return newMenu
		}
	}
	
	afterPressHotkeyDoWhat() {
		return new this.popOutMenuORRunSoloDirectly(this)
	}
	
	Class ItemClass {
		whatItemNameShows :=
		calledBeforeConvert :=	
		calledFuncORLabelString :=	
		parent :=	
		
		__New(myParent) {
			this.parent := myParent
			return this
		}
		
		convertCalled() {
			if ( IsFunc(this.calledBeforeConvert) )
			{
				this.calledFuncORLabelString := Func(this.calledBeforeConvert)
			}
			else if ( IsLabel(this.calledBeforeConvert) ) 
			{
				this.calledFuncORLabelString := this.calledBeforeConvert
			}
			else
			{
				this.calledFuncORLabelString := new this.FuncClassConvertFromString(this)  			;不能存储到没写this的called。为什么？？？？？？？？？？？？
			}
			return this.calledFuncORLabelString
		}
		
		generateItemNameIfNotGiven() {
			if ( this.whatItemNameShows != "" )
				return this.whatItemNameShows
			else
			{
				;~ MsgBox, % this.calledBeforeConvert
				;~ tempArray := StrSplit(this.calledBeforeConvert, "\", A_Space)
				;~ tempMaxIndex := tempArray.MaxIndex()
				;~ this.whatItemNameShows := Array[tempMaxIndex]
				;~ MsgBox, % Array[tempMaxIndex]
				filename := RegExReplace(this.calledBeforeConvert, ".*?\\?([^\\]+)$", "$1")
				;MsgBox, % filename
				return filename
			}
		}
		
		class FuncClassConvertFromString {
			__New(myParent) {
				this.parent := myParent
				return this
			}
			Call() {
				Run, % this.parent.calledBeforeConvert
			}
			__Call(method, args*) {
				if (method = "")  ;对%fn%()或fn.()
					return this.Call(args*)
				if (IsObject(method))  ; 如果此函数对象作为方法被使用.
					return this.Call(method, args*)
			}

		}
	}

	Class popOutMenuORRunSoloDirectly {
		__New(myParent) {
			this.parent := myParent
		}
		Call() {
			if ( this.parent.Length() = 1 )					;不能写作.Length，这是一个方法，不是属性
			{	if ( IsLabel(this.parent[1].calledBeforeConvert) )
				{
					destination := this.parent[1].calledFuncORLabelString
					gosub %destination%
				}
				else
					this.parent[1].calledFuncORLabelString.call()
			}
			else		;menu里有多个item
			{
				menuName := this.parent.indexOfWholeMenuList
				CoordMode, Menu, Screen
				this.setMenuPosition()
				x := this.x
				y := this.y
				Menu, %menuName%, Show, %x%, %y%
			}
		}
		__Call(method, args*) {
			if (method = "")  								;对%fn%()或fn.()
				return this.Call(args*)
			if (IsObject(method))  							;如果此函数对象作为方法被使用.
				return this.Call(method, args*)
		}
		setMenuPosition() {									;设定menu显示的位置，存储在this.x  this.y中
			this.x := (A_ScreenWidth / 2)
			this.y := (A_ScreenHeight / 2)
		}
		
	}
}

;calledString只支持接受字符串，可以是单程序路径、函数名、标签名
appStarter(hotkeys, calledString, itemName := "") {
	menu := MenuClass.checkMenuExist(hotkeys)			;检查menu实例是否存在。若无，则创建，如有，则读取存储地址。返回menu instance
	
	itemInstance := new menu.ItemClass(menu)
	itemInstance.whatItemNameShows := itemName
	itemInstance.calledBeforeConvert := calledString
	calledOBJorSTR := itemInstance.convertCalled()
	itemName := itemInstance.generateItemNameIfNotGiven()
	menu.Push(itemInstance)
	
	Menu, %hotkeys%, Add, %itemName%, %calledOBJorSTR%
	
	popOutMenuORRunSoloDirectly := menu.afterPressHotkeyDoWhat()		;创建热键，调用afterPressHotkeyDoWhat()函数
	Hotkey, %hotkeys%, %popOutMenuORRunSoloDirectly%, On
}

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
appStarter("#h", "shell:::{ED7BA470-8E54-465E-825C-99712043E01C}", "回收站")
appStarter("#g", "录制gif")
appStarter("#s", "d:\BaiduYun\Technical_Backup\ProgramFiles\ColorPic 4.1  屏幕取色小插件 颜色 色彩 配色\#ColorPic.exe")

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
