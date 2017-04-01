;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; 
;;; 快捷输入部分，总是莫名其妙、间歇性的失效，所以从主脚本，独立出来试试
;;; 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

#SingleInstance FORCE	;决定当脚本已经运行时是否允许它再次运行,记得用force，这样主脚本reload时，子脚本也自动reload了
SetTitleMatchMode Regex	;更改进程匹配模式为正则
#Hotstring EndChars  `n				;编辑热字串的终止符
Menu, Tray, Icon, %A_LineFile%\..\Icon\keyboard_128px.ico, , 1

#Include %A_LineFile%\..\..\Functions\InputMagician库，动态正则热字串替换\InputMagician.ahk
#Include %A_LineFile%\..\..\Functions\InputMagician库，动态正则热字串替换\Eval.ahk

;-------------------------------------------------------------------------------
;~ 函数部分
;-------------------------------------------------------------------------------
{
	;Unicode发送函数,避免触发输入法,也不受全角影响
	;from [辅助Send 发送ASCII字符 V1.7.2](http://ahk8.com/thread-5385.html)
	SendL(ByRef string) {
		static Ord:=("Asc","Ord")
		inputString:=("string",string)
		Loop, Parse, %inputString%
			ascString.=(_:=%Ord%(A_LoopField))<0x100?"{ASC " _ "}":A_LoopField
		SendInput, % ascString
	}
}	

::tc::TotalCommander
::sof::stackoverflow
:*:b\::
:*:bo\::
	sendL("bootislands")		;放弃unicode难读的方式，用sendL()，来避免触发输入法
	return
:*:b@\::
	sendL("bootislands@163.com")
	return
:*:bg\::
	sendL("bootislands@gmail.com")
	return
:*:vg\::
	sendL("VeryNginx@gmail.com")
	return
:*:rg\::
	sendL("riverno@gmail.com")
	return
:*:q@\::
	sendL("1755381995@qq.com")
	return
:*:js\::
	sendL("JavaScript")
	return
::ahk::AutoHotkey
::mlo::MyLifeOrganized

#If a_priorkey="Enter"
.::  sendL(".")			;回车+句号  自动变点号 避免AutoHotkey。com这种输入错误问题
#If


