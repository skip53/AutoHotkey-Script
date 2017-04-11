;-------------------------------------------------------------------------------
;~ 软件快速启动器
;-------------------------------------------------------------------------------


class _Menu {
	;类变量
	static wholeMenuList := {}
	
	;实例变量
	nameIndex :=			;在wholeMenuList中的key     _Menu.wholeMenuList[nameIndex]即是menu实例的对象引用
	child := []				;子item的引用数组
	
	;方法
	__New(chars) {
		_Menu.wholeMenuList[chars] := this
		this.nameIndex := chars
	}
	;~ 按下热键时，执行的判断函数，如果只有一个，则直接执行；如果有多个，则显示菜单
	checkMenuExist(chars) {							;函数不太区分 类函数 还是 实例函数，都能用
		if ( _Menu.wholeMenuList[chars] != "" )
			return _Menu.wholeMenuList[chars]		;返回的是menu实例对象
		else
		{
			newMenu := new _Menu(chars)
			return newMenu
		}
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
	
	;创建热键，调用hotkeyTriger()函数
	F1:: Menu, %chars%, show
	;Hotkey, %chars%, menuName.hotkeyTriger()
		
}

appStarter("F9", "test1", "C:\Windows\System32\calc.exe")
;appStarter("F9", "test2", "C:\Windows\System32\calc.exe")
	
hahaha:
	return