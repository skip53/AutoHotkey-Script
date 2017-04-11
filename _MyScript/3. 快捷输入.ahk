;-------------------------------------------------------------------------------
;~ 1. 快捷输入部分，总是莫名其妙、间歇性的失效，所以从主脚本，独立出来试试，方便看日志排错
;~ 2. ahk8 的 InputMagician库，有两个不足：
;~ 		1是会接管所有键盘输入，导致同一脚本的其它热键失效
;~ 		2是函数的参数传递不清晰
;~    所以换成现在这个hotstring版本。下载地址：https://autohotkey.com/boards/viewtopic.php?f=6&t=3329
;-------------------------------------------------------------------------------

#SingleInstance FORCE	;决定当脚本已经运行时是否允许它再次运行,记得用force，这样主脚本reload时，子脚本也自动reload了
SetTitleMatchMode Regex	;更改进程匹配模式为正则
#Persistent				;持续运行不退出
;~ #NoTrayIcon				;隐藏托盘图标
SendMode Input			;所有Send命令，统一采用最快的SendInput
#Hotstring EndChars  `n		;编辑热字串的终止符
#MaxHotkeysPerInterval 200

#Include d:\Dropbox\Technical_Backup\AHKScript\Functions\regexHotString库，类似InputMagician\Hotstring.ahk

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
	
	;移动光标
	CaretMove(match, step)
	{
		length := strlen(match)	;取得捕获的字符串长度
		length += step					; 加上 < / > 三个符号的长度
		Send, {Left %length%}			;将光标左移
	}
}	

;-------------------------------------------------------------------------------
;~ 正则/动态部分    库写的不好，不能用{}框起来，否则报错
;-------------------------------------------------------------------------------
Hotstring("<(\w+)>", "htmltag", 3)
Hotstring("(img|url)\\", "bbcode", 3)
return				;注意：只能调用语句写上面 函数写下面 中间return分开 否则会报错

htmltag($) {
	;SendInput, % $.Value(1) . $.Value(2) . $.Value(3) . $.Value(1) . "/" . $.Value(2) . $.Value(3)
	SendInput, % "<" . $.Value(1) . "></" . $.Value(1) . ">"
	CaretMove($.Value(1), 3)
	return
}

bbcode($) {
	Send, % "[" . $.Value(1) . "][/" . $.Value(1) . "]"
	CaretMove($.Value(1), 3)
	return
}


;-------------------------------------------------------------------------------
;~ 静态部分
;-------------------------------------------------------------------------------
{
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
}
