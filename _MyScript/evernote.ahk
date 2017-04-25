{
#NoEnv						;不检查空变量是否为环境变量
#KeyHistory 0				;不记录击键log
ListLines Off				;不记录击键log
SetBatchLines, -1			;行之间运行不留时间空隙,默认是有10ms的间隔
SetKeyDelay, -1, -1			;发送按键不留时间空隙
SetMouseDelay, -1			;每次鼠标移动或点击后自动的延时=0   
SetDefaultMouseSpeed, 0		;设置在 Click 和 MouseMove/Click/Drag 中没有指定鼠标速度时使用的速度 = 瞬间移动.
SetWinDelay, 0
SetControlDelay, 0
SendMode Input				;据说SendInput is the fastest send method.

	#NoEnv						;不检查空变量是否为环境变量
	SetBatchLines, -1			;行之间运行不留时间空隙,默认是有10ms的间隔
	SetKeyDelay, -1, -1			;发送按键不留时间空隙
	SetMouseDelay, -1			;每次鼠标移动或点击后自动的延时=0   
	SetDefaultMouseSpeed, 0		;设置在 Click 和 MouseMove/Click/Drag 中没有指定鼠标速度时使用的速度 = 瞬间移动.
	SetWinDelay, 0
	SetControlDelay, 0
	SendMode Input				;据说SendInput is the fastest send method.
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	#Include %A_LineFile%\..\..\Functions\WinClip\WinClipAPI.ahk
	#Include %A_LineFile%\..\..\Functions\WinClip\WinClip.ahk
	;#Include %A_LineFile%\..\..\Functions\url_encode_decode.ahk	;该脚本必须以ANSI运行
	#Include %A_LineFile%\..\..\Functions\TrayIcon by FanaticGuru.ahk
	#Include %A_LineFile%\..\..\Functions\WinHttpRequest 网络函数 HTTP get post\WinHttpRequest.ahk
	#Include %A_LineFile%\..\..\Functions\GetActiveBrowserURL 获取浏览器窗口的地址 等信息\GetActiveBrowserURL.ahk

	#InstallKeybdHook		;安装键盘和鼠标钩子 像Input和A_PriorKey，都需要钩子
	#InstallMouseHook
	SetTitleMatchMode Regex	;更改进程匹配模式为正则
	#SingleInstance ignore	;决定当脚本已经运行时是否允许它再次运行。
	#Persistent				;持续运行不退出
	#MaxThreadsPerHotkey 5
	CoordMode, Mouse, Client	;鼠标坐标采用Client模式
	
	
	

;evernote编辑器增强函数
	evernoteEdit(eFoward, eEnd)
	{
		;BlockInput On
		clipboard =
		Send ^c
		ClipWait, 1
		t := WinClip.GetHtml3()
		;MsgBox, % t
		;t := WinClip.GetText()
		;RegExMatch(t, "s)(?<=StartFragment-->)(.*?)(?=<!--EndFragment)", t)
		;MsgBox, % WinClip.GetHtml2()
		;MsgBox, % WinClip.GetHtml3()
		html = %eFoward%%t%%eEnd%
		;MsgBox, % html
		WinClip.Clear()
		;MsgBox, % html
		WinClip.SetHTML(html)
		Sleep, 300
		;SendInput, {Space}{backspace}
		;Sleep,2000
		Send ^v
		;BlockInput Off
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
		
		;双击右键高亮
		{
			$RButton::
				CountStp := ++CountStp
				SetTimer, TimerPrtSc, 500
				Return
			TimerPrtSc:
				if CountStp > 1 ;大于1时关闭计时器
					SetTimer, TimerPrtSc, Off
				if CountStp = 1 ;只按一次时执行
					SendInput, {RButton}
				if CountStp = 2 ;按两次时...
					SendInput, ^+h
				CountStp := 0 ;最后把记录的变量设置为0,于下次记录.
				Return
		}
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
			CoordMode, Mouse, Screen	;鼠标坐标，临时采用全屏幕模式，否则鼠标不能回归原位
			MouseGetPos, xpos, ypos 
			CoordMode, Mouse, Client	;鼠标坐标，返回Client模式
			IfWinActive, ahk_class ENMainFrame 
			{
				Click 890, 159		;点击颜色按钮
				Click 935, 341		;点击更多颜色
				;严重依赖窗口视图相对位置，编辑区域中界限，设定为表格刚刚消失不见时的位置，接近于屏幕竖直中线
			}
			IfWinActive, ahk_class ENSingleNoteView
			{
				Click 231, 121		;点击颜色按钮
				Click 262, 304		;点击更多颜色
			}
			;SendL("M")			;进入更多颜色		
			Sleep, 50
			Click, 116, 333		;进入自定义颜色
			SendInput, {Tab}{Tab}{Tab}
			SendInput %r%{Tab}%g%{Tab}%b%{Tab}{Space}
			Click, 21, 259		;点击设定好自定义颜色
			SendInput, {Tab}{Space}
			CoordMode, Mouse, Screen	;鼠标坐标，继续改回全屏幕模式，方便移动鼠标
			MouseMove, %xpos%, %ypos%, 0
			CoordMode, Mouse, Client	;鼠标坐标，继续返回Client模式
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
