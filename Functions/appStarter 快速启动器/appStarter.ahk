
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
				if (method = "") 
					return this.Call(args*)
				if (IsObject(method))
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
			if (method = "")  
				return this.Call(args*)
			if (IsObject(method))  	
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
