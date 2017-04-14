;-------------------------------------------------------------------------------
;~ 软件快速启动器
;-------------------------------------------------------------------------------
#SingleInstance FORCE	;决定当脚本已经运行时是否允许它再次运行,记得用force，这样主脚本reload时，子脚本也自动reload了
SetTitleMatchMode Regex	;更改进程匹配模式为正则
#Persistent				;持续运行不退出
;~ #NoTrayIcon				;隐藏托盘图标
SendMode Input			;所有Send命令，统一采用最快的SendInput

#Include d:\Dropbox\Technical_Backup\AHKScript\Functions\Menu - some functions related to AHK menus  关于menu菜单的库\Menu.ahk

class _Menu {
	static wholeMenuList := {}
	nameIndex :=			;在wholeMenuList中的key     _Menu.wholeMenuList[nameIndex]即是menu实例的对象引用
	child := []				;子item的引用数组
	
	;实例变量
	
	;方法
	__New(chars) {		
		_Menu.wholeMenuList[chars] := this			;todo 不用数组了，直接存储进对象？
		this.nameIndex := chars
	}
	
	;检查菜单是否存在，否则新建
	checkMenuExist(chars) {							;函数不太区分 类函数 还是 实例函数，都能用
		if ( _Menu.wholeMenuList[chars] != "" )
			return _Menu.wholeMenuList[chars]		;返回的是menu实例对象
		else
		{
			newMenu := new _Menu(chars)
			return newMenu
		}
	}
	
	;返回函数对象，行为是弹出menu
	afterPressHotkey() {
		return new this.popOutMenu(this)
	}
	
	Class _Item {
		;实例变量
		name :=				;显示的名称
		called :=			;exe路径字符串
		calledObj :=		;call字符串转成的函数对象
		parent :=			;父menu实例
		
		
		;方法
		__New(myParent) {
			this.parent := myParent
			return this
		}
		
		transferCalled() {
			if ( !IsFunc(called) && !IsLabel(called) )
			{
				this.calledObj := new this.str2Func(this)  					;存储函数对象到this.called   注意不能存储到没写this的called。为什么？？？？？？？？？？？？
				;~ calledObj.Call("C:\Windows\System32\calc.exe")
			}
			;~ return this.calledObj
		}
		
		class str2Func {					;函数对象写法，具体参见https://autohotkey.com/docs/objects/Functor.htm
			__New(myParent) {
				this.parent := myParent
				return this
			}
			Call() {		;注意函数对象，传参数的方法
				;MsgBox % this.parent.called
				Run, % this.parent.called
			}
			__Call(method, args*) {
				if (method = "")  ;对%fn%()或fn.()
					return this.Call(args*)
				if (IsObject(method))  ; 如果此函数对象作为方法被使用.
					return this.Call(method, args*)
			}

		}
	}

	Class popOutMenu {
		__New(myParent) {
			this.parent := myParent
		}
		Call() {
			menuName := this.parent.nameIndex
			CoordMode, Menu, Screen
			this.setMenuPosition()
			x := this.x
			y := this.y
			Menu, %menuName%, Show, %x%, %y%
			;~ Menu, %menuName%, Show, 127, Center
		}
		__Call(method, args*) {
			if (method = "")  ;对%fn%()或fn.()
				return this.Call(args*)
			if (IsObject(method))  ; 如果此函数对象作为方法被使用.
				return this.Call(method, args*)
		}
		setMenuPosition() {					;设定menu显示的位置，存储在this.x  this.y中
			this.x := (A_ScreenWidth / 2)
			this.y := (A_ScreenHeight / 2)
		}
		
	}
}

;called支持单个程序、多个程序、函数
appStarter(chars, itemName, called) {
	;检查menu实例是否存在。若无，则创建，如有，则读取存储地址。返回menu instance
	menu := _Menu.checkMenuExist(chars)
	
	;创建called函数，有则直接添加，无则新建
	item := new menu._Item(menu)
	item.name := itemName
	item.called := called
	item.transferCalled()
	menu.Push(item)		;关联两个instance
	
	;菜单里加上menuName和called的名字
	;Menu, %menu.name%, Add, %item%.name, item.called
	called := item.calledObj
	Menu, %chars%, Add, %itemName%, %called%
	;~ called.call()
	
	popoutMenu := menu.afterPressHotkey()
	;创建热键，调用afterPressHotkey()函数
	Hotkey, %chars%, %popoutMenu%, On

}

appStarter("Numpad0 & q", "test2test2test2test2test2test2test2test2test2test2", "C:\Windows\System32\cmd.exe")
appStarter("Numpad0 & q", "test1", "C:\Windows\System32\calc.exe")
appStarter("^+z", "test2", "C:\Windows\System32\cmd.exe")
