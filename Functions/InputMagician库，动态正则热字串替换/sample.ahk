#NoEnv
#SingleInstance force
#include InputMagician.ahk
#include Eval.ahk
#MaxThreads 10	; 如果设置为1，则inputMagi会阻塞当前线程
SetKeyDelay, -1
SendMode, Input

; Git: https://github.com/Nigh/InputMagician

; 由于AddReg功能已经涵盖Add功能
; 如果没有特别需要必须使用到Add，可能会在以后版本中删除
; inputMagi.Add(".l",".lcomm`t" )	; 配置定长替换对
; inputMagi.Add(".o",".org`t")


; 原型
; inputMagi.AddReg(正则捕获,正则替换,正则设置(不了解置空即可),预处理函数,后处理函数)
; 其中，预处理函数与后处理函数的输入均为正则的捕获对象
; 不了解正则捕获对象的用户，请参阅帮助手册的RegExMatch()项下的Match Object条目
; 预处理函数在捕获发生之后执行
; 后处理函数在替换结束之后执行

; AddReg为注册热字符串
inputMagi.AddReg("btw","by the way")
; 试试输入btw`

inputMagi.AddReg("<(\w+)>","<$1></$1>","","",Func("CaretMove"))
; 试试输入<div>`

inputMagi.AddReg("(\d+)\*(\d+)","$1*$2","",Func("UserEval"))
; 试试输入123*456`

; inputMagi.AddReg("(1|0)(1|0)(1|0)(1|0)(1|0)","$x '000$1$2$3$4$5","",Func("UserEval"))
; 试试输入10010`
; 由于Eval库的兼容性，此例已失效

; 设置输出触发字符(1左边的那个键)
inputMagi.SetOutputKey("``")

SetTimer, inputMagiLabel, -1	; inputMagician需要占用一个线程，使用timer可以使得下面的代码继续执行
; inputMagi.Start()				; 如果注释掉上面那行，使用这行，则下面的代码不会执行

Msgbox, just test
Return

inputMagiLabel:
inputMagi.Start()
Return

CaretMove(match)
{
	length:=strlen(match.Value(1))	;取得捕获的字符串长度
	length+=3	; 加上 < / > 三个符号的长度
	Send, {Left %length%}	;将光标左移
}

UserEval(match)
{
	Return, Eval(match.value())	;对整个捕获进行Eval转换，需要Eval库的支持
}


F6::Suspend
