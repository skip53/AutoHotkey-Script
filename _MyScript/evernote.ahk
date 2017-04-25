{
	#NoEnv						;不检查空变量是否为环境变量
	SetBatchLines, -1			;行之间运行不留时间空隙,默认是有10ms的间隔
	SetKeyDelay, -1, -1			;发送按键不留时间空隙
	SetMouseDelay, -1			;每次鼠标移动或点击后自动的延时=0   
	SetDefaultMouseSpeed, 0		;设置在 Click 和 MouseMove/Click/Drag 中没有指定鼠标速度时使用的速度 = 瞬间移动.
	SetWinDelay, 0
	SetControlDelay, 0
	SendMode Input

	#Include %A_LineFile%\..\..\Functions\WinClip\WinClipAPI.ahk
	#Include %A_LineFile%\..\..\Functions\WinClip\WinClip.ahk
	#Include %A_LineFile%\..\..\辅助工具\快捷抓取、查找屏幕文字／图像字符串\函数部分 v5.6.ahk

	#InstallKeybdHook		;安装键盘和鼠标钩子 像Input和A_PriorKey，都需要钩子
	#InstallMouseHook
	SetTitleMatchMode Regex	;更改进程匹配模式为正则
	#SingleInstance ignore	;决定当脚本已经运行时是否允许它再次运行。
	#Persistent				;持续运行不退出
	#MaxThreadsPerHotkey 5

	;evernote编辑器增强函数
	evernoteEdit(eFoward, eEnd)
	{
		clipboard =
		Send ^c
		ClipWait, 1
		t := WinClip.GetHtml3()
		html = %eFoward%%t%%eEnd%
		WinClip.Clear()
		WinClip.SetHTML(html)
		Sleep, 300
		Send ^v
		Return
	}
	
	;evernote不保留原格式，增强函数
	evernoteEditText(eFoward, eEnd)
	{
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
	evernoteInsertHTML(html)
	{
		clipboard =
		WinClip.SetHTML(html)
		Sleep, 300
		Send ^v
		Return
	}
	
	WinClip.GetHtml2 := Func("GetHtml2")		; 也可以直接覆盖原来的函数 -> WinClip.GetHtml := Func("GetHtml2")
	WinClip.GetHtml3 := Func("GetHtml_DOM")
	
	;操作HTML DOM，比GetHTML函数更实用
	GetHtml_DOM(this, Encoding := "UTF-8")
	{
		html := this.GetHtml2(Encoding)
		static doc := ComObjCreate("htmlFile")
		doc.Write(html), doc.Close()
		return doc.all.tags("span")[0].InnerHtml
	}

	;WinClip中Get的UTF-8改写，支持中文
	GetHtml2(this, Encoding := "UTF-8")
	{
	  if !( clipSize := this._fromclipboard( clipData ) )
		return ""
	  if !( out_size := this._getFormatData( out_data, clipData, clipSize, "HTML Format" ) )
		return ""
	  return strget( &out_data, out_size, Encoding )
	}

}

#IfWinActive ahk_class (ENSingleNoteView|ENMainFrame)
{		
	;快捷键: 非编辑器部分
	{
		^Space::controlsend, , ^{Space}, A   	;简化格式
		F1::
	}
	
	;颜色 字体格式等
	{
		;方框环绕
		!f::evernoteEdit("<div style='margin-top: 5px; margin-bottom: 9px; word-wrap: break-word; padding: 8.5px; border-top-left-radius: 4px; border-top-right-radius: 4px; border-bottom-right-radius: 4px; border-bottom-left-radius: 4px; background-color: rgb(245, 245, 245); border: 1px solid rgba(0, 0, 0, 0.148438)'>", "</div></br>")
		;超级标题
		!s::evernoteEditText("<div style='margin:1px 0px; color:rgb(255, 255, 255); background-color:#8BAAD0; border-top-left-radius:5px; border-top-right-radius:5px; border-bottom-right-radius:5px; border-bottom-left-radius:5px; text-align:center;'><b>", "</b></div></br>")
		;引用
		!y::evernoteEdit("<div style='margin:0.8em 0px; line-height:1.5em; border-left-width:5px; border-left-style:solid; border-left-color:rgb(127, 192, 66); padding-left:1.5em; '>", "</div>")
		
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
			!1::
				evernoteMouseChangeColor(240, 46, 55)
				SendInput, ^b
				return
			;字体蓝色
			!2::
				evernoteMouseChangeColor(55, 64, 230)
				SendInput, ^b
				return
			;字体灰色
			!3::
				evernoteMouseChangeColor(214, 214, 214)
				return
			;字体绿色
			!4::
				evernoteMouseChangeColor(15, 130, 15)
				SendInput, ^b
				return
			;字体白色
			!5::
				evernoteMouseChangeColor(255, 255, 255)
				return
		}
	}
}
