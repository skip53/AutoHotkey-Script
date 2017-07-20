;-------------------------------------------------------------------------------
;~ 检测窗口，自动切换输入法的中/英文状态
;~ 
;~ 网上搜到的输入法自动切换
;~ • Autohotkey 中文论坛 - 修正版根据程序设置输入法: http://ahk8.com/archive/index.php/thread-5306.html
;~ • Autohotkey 中文论坛 - 输入法自动切换，IME 开关比切换输入法慢？: http://ahk8.com/archive/index.php/thread-5832.html
;~ • Autohotkey 中文论坛 - 根据不同窗口自动设置输入法 V1.0.2: http://ahk8.com/archive/index.php/thread-2469.html
;~ • lspcieee_ahk/IME.ahk at master · lspcieee/lspcieee_ahk: https://github.com/lspcieee/lspcieee_ahk/blob/master/IME.ahk
;~ 没有一个特满意的，尤其第4个，基于消息而非窗口，因此在Anki进入主窗口时触发英文，再进入编辑窗口触发中文后，回到主窗口时，此时不能再次触发英文，因为无新消息
;-------------------------------------------------------------------------------

#SingleInstance FORCE	;决定当脚本已经运行时是否允许它再次运行,记得用force，这样主脚本reload时，子脚本也自动reload了
SetTitleMatchMode Regex	;更改进程匹配模式为正则
#Persistent				;持续运行不退出
#NoTrayIcon				;隐藏托盘图标
SendMode Input			;所有Send命令，统一采用最快的SendInput

{
	; Checks if a value exists in an array (similar to HasKey)
	; FoundPos := HasVal(Haystack, Needle) 
	; from: https://autohotkey.com/boards/viewtopic.php?p=109617#p109617
	HasVal(haystack, needle) {
		for index, value in haystack
			if (value = needle)
				return index
		if !(IsObject(haystack))
			throw Exception("Bad haystack!", -1, haystack)
		return 0
	}
	
	;检测两个数组A和B是否有相同的item，如果没，返回0，如果有，返回arr2的位置
	hasSameItem(arr1, arr2) {
		for key, value in arr1
		{
			index := HasVal(arr2, value)
			if ( index != 0 )
				return index
		}
		return 0
	}
}

WindowEN := ["Anki - User 1", "ahk_class testtesttest"]
WindowZH := ["Edit Current"]
LastCurrentTitle := 
LastCurrentClass :=
LastCurrentEXE :=
	
Loop
{
	;获取当前窗口
	WinGetTitle, CurrentTitle, A
	WinGetClass, CurrentClass, A
	WinGet, CurrentEXE, ProcessName, A
	
	;检查是否切换了窗口（基于title class exe综合判断）
	if ( CurrentTitle != LastCurrentTitle || CurrentClass != LastCurrentClass || CurrentEXE != LastCurrentEXE ) {
		LastCurrentTitle := CurrentTitle
		LastCurrentClass := CurrentClass
		LastCurrentEXE := CurrentEXE
		
		;检查当前窗口是否在todo列表内，如果在，执行切换操作
		CurrentWindow := []
		CurrentWindow.Push(CurrentTitle, "ahk_class " . CurrentClass, "ahk_exe " . CurrentEXE)
		if ( hasSameItem(CurrentWindow, WindowEN) != 0 ) 
			SendInput, ^,{Shift}
		else if ( hasSameItem(CurrentWindow, WindowZH) != 0 )	
			SendInput, ^,
	}
	Sleep, 100	;休息100ms 防止不停循环
}
return
