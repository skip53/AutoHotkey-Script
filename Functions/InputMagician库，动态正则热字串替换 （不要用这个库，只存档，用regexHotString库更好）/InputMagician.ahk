; 2014.9.14 Nigh
; Beta 0
; jiyucheng007#gmail.com

; Git: https://github.com/Nigh/InputMagician

; TODO:
; AddReg 警告非法设置
; 一个包含inputMagi全部功能的小应用

; 原型
; inputMagi.AddReg(正则捕获,正则替换,正则设置(不了解置空即可),预处理函数,后处理函数)
; 其中，预处理函数与后处理函数的输入均为正则的捕获对象
; 不了解正则捕获对象的用户，请参阅帮助手册的RegExMatch()项下的Match Object条目

/*
识别的优先级按照Add的顺序，先Add的先识别
inputMagi.AddReg("(\d+)\*(\d+)","$1*$2","",Func(fEval))
inputMagi.AddReg(src,des,regSetting,FuncBefore,FuncAfter)
src:要检测的输入
des:转换的输出
regSetting:正则设置如 "i)"
FuncBefore:使用自定义函数来处理输出，格式为Output:=FuncBefore(Input)，输入为正则捕获对象，输出为处理结果
FuncAfter:在替换结束后执行的自定义函数，输入为正则捕获对象
AddReg(src,des,regSetting="",FuncBefore="",FuncAfter="")
*/
class inputMagi
{
	static keys
	static indexMax:=0
	static indexRegMax:=0
	Grimoire:=Object()
	Majutsu:=Object()
	
	Add(src,des)
	{
		this.indexMax++
		this.Grimoire[this.indexMax,"src"]:=src
		this.Grimoire[this.indexMax,"des"]:=des
		this.Grimoire.MaxIndex:=this.indexMax
	}
	
	AddReg(src,des,regSetting="",Fun1="",Fun2="")
	{
		if(Fun1!="" and !IsFunc(Fun1)){
			Msgbox, 错误的FuncBefore设置。(%src% In [Function]AddReg)
			Return
		}
		if(Fun2!="" and !IsFunc(Fun2)){
			Msgbox, 错误的FuncAfter设置。(%src% In [Function]AddReg)
			Return
		}
		this.indexRegMax++
		this.Majutsu[this.indexRegMax,"src"]:=regSetting ")" src "$"
		this.Majutsu[this.indexRegMax,"des"]:=des
		this.Majutsu[this.indexRegMax,"FuncBefore"]:=Fun1
		this.Majutsu[this.indexRegMax,"FuncAfter"]:=Fun2
		this.Majutsu.MaxIndex:=this.indexRegMax
	}
	
	Delete(src)
	{
		Loop, % this.indexMax
		{
			If(this.Grimoire[A_Index,"src"]=src)
			{
				this.Grimoire.Remove(A_Index)
				this.indexMax-=1
				this.Grimoire.MaxIndex:=this.indexMax
				Break
			}
		}
	}
	
	DeleteReg(src)
	{
		Loop, % this.indexRegMax
		{
			If(this.Majutsu[A_Index,"src"]=src)
			{
				this.Majutsu.Remove(A_Index)
				this.indexRegMax-=1
				this.Majutsu.MaxIndex:=this.indexRegMax
				Break
			}
		}
	}
	
	Start()
	{
		this.exit:=0

		if(this.outputKey="")
		{
			Msgbox, % "未设置输出触发按键" this.outputKey "，未能启动"
			Return
		}
		Hotkey, ~BS, __backSpace, On
		Loop
		{
			If(this.exit)
			Break
			Input, key, I V L1, 
			if(key=this.outputKey){
				this.Output()
			}else{
				this.keys:=SubStr(this.keys . key,-19)
			}
		}
		Return

		__backSpace:
		inputMagi.keys:=SubStr(inputMagi.keys,1,StrLen(inputMagi.keys)-1)
		Return
	}

	Stop()
	{
		this.exit:=1
	}
	
	SetOutputKey(key)
	{
		this.outputKey:=key
	}

	Output()
	{
		keys:=this.keys
		spell_1:=SubStr(keys,-1)
		temp_Index:=0
		Loop, % this.Grimoire.MaxIndex
		{
			temp_Index:=A_Index
			IfInString, spell_1, % this.Grimoire[temp_Index,"src"]
			{
;~ 				Loop, % StrLen(this.Grimoire[temp_Index,"src"])
				SendInput, % "{BS " StrLen(this.Grimoire[temp_Index,"src"])+1 "}" this.Grimoire[temp_Index,"des"]
				this.keys:=""
				Break
			}
			temp_Index:=0
		}
		
		If(!temp_Index And this.Majutsu.MaxIndex)
		Loop, % this.Majutsu.MaxIndex
		{
			temp_Index:=A_Index
			If(FoundPos:=RegExMatch(keys,"O" this.Majutsu[temp_Index,"src"],match))
			{
				NewStr:=RegExReplace(match.Value(),this.Majutsu[temp_Index,"src"],this.Majutsu[temp_Index,"des"])
				If(isFunc(this.Majutsu[temp_Index,"FuncBefore"])){
					NewStr:=(this.Majutsu[temp_Index,"FuncBefore"]).(match)
				}
				SendInput, % "{BS " match.Len()+1 "}" NewStr
				If(isFunc(this.Majutsu[temp_Index,"FuncAfter"])){
					this.Majutsu[temp_Index,"FuncAfter"].(match)
				}
				this.keys:=""
				Break
			}
			temp_Index:=0
		}
		
		If(!temp_Index)
			SendEvent, {`}
	}

	Version()
	{
		Return, "beta 0"
	}

	_pushClip()
	{
		this.tmp:=ClipboardAll
	}
	_popClip()
	{
		Clipboard:=this.tmp
	}
}
