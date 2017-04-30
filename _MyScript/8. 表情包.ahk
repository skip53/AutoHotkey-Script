;-------------------------------------------------------------------------------
;~ 软件快速启动器a
;-------------------------------------------------------------------------------
#NoEnv
#SingleInstance force
#NoTrayIcon				;隐藏托盘图标
SetWorkingDir, %A_ScriptDir%
SetBatchLines, -1
CoordMode, Mouse, Screen

gui_title := "表情包"



; —————————————————————— 设置 ——————————————————————

; 表情根目录
RootDir := A_ScriptDir . "\表情"

; 显示标题和边框
ShowGuiTitle := False

; 界面失去焦点则关闭界面
LossFocus_CloseGui := True

; 隐藏滚动条（滚动条显示时，ActiveX 的高度为 215。隐藏时高度自动调整。）
; HideScrollbar := True

; 高亮鼠标下的图片(如果比较卡，可以禁用此选项)
HighlightImage := True

; 图片对应的图床地址
global imageAddrInOnline := {  "小黄脸开心-1": "https://ooo.0o0.ooo/2017/04/16/58f32b46f2b08.png"
    ,"小黄脸开心-2": "https://ooo.0o0.ooo/2017/04/16/58f32b46f2957.png"
    ,"小黄脸酷": "https://ooo.0o0.ooo/2017/04/16/58f32b470aa74.png"
    ,"小黄脸哭": "https://ooo.0o0.ooo/2017/04/16/58f32b470cd46.png"
    ,"小黄脸迷茫": "https://ooo.0o0.ooo/2017/04/16/58f32b4719aac.png"
    ,"小黄脸懵B": "https://ooo.0o0.ooo/2017/04/16/58f32b471b38e.png"
    ,"小黄脸酷-1": "https://ooo.0o0.ooo/2017/04/16/58f32b471b7a7.png"
    ,"小黄脸热恋": "https://ooo.0o0.ooo/2017/04/16/58f32b4724eae.png"
    ,"小黄脸亲吻-2": "https://ooo.0o0.ooo/2017/04/16/58f32b47258fd.png"
    ,"小黄脸思考": "https://ooo.0o0.ooo/2017/04/16/58f32b5d9f8cc.png"
    ,"小黄脸天使": "https://ooo.0o0.ooo/2017/04/16/58f32b5da1f24.png"
    ,"小黄脸头晕": "https://ooo.0o0.ooo/2017/04/16/58f32b5dacdc0.png"
    ,"小黄脸吐舌": "https://ooo.0o0.ooo/2017/04/16/58f32b5daf873.png"
    ,"小黄脸笑哭": "https://ooo.0o0.ooo/2017/04/16/58f32b5db27b9.png"
    ,"小黄脸微笑-1": "https://ooo.0o0.ooo/2017/04/16/58f32b5db5020.png"
    ,"小黄脸眼红": "https://ooo.0o0.ooo/2017/04/16/58f32b5dbc891.png"
    ,"file_86877": "https://ooo.0o0.ooo/2017/04/22/58fb7bf7c3ede.png"
    ,"file_86878": "https://ooo.0o0.ooo/2017/04/22/58fb7bf7d5c71.png"
    ,"file_86879": "https://ooo.0o0.ooo/2017/04/22/58fb7bf7dcd53.png"
    ,"file_86881": "https://ooo.0o0.ooo/2017/04/22/58fb7bf7e862b.png"
    ,"file_86882": "https://ooo.0o0.ooo/2017/04/22/58fb7bf7f4237.png"
    ,"file_86883": "https://ooo.0o0.ooo/2017/04/22/58fb7bf80b806.png"
    ,"file_86884": "https://ooo.0o0.ooo/2017/04/22/58fb7bf80dd4c.png"
    ,"file_86885": "https://ooo.0o0.ooo/2017/04/22/58fb7bf81c895.png"
    ,"file_86886": "https://ooo.0o0.ooo/2017/04/22/58fb7bf82670c.png"
    ,"file_86887": "https://ooo.0o0.ooo/2017/04/22/58fb7bf83497f.png"
    ,"file_86888": "https://ooo.0o0.ooo/2017/04/22/58fb7c01d05ef.png"    }

; —————————————————————— /设置 ——————————————————————


; html head
html_head =
(LTrim
    <!DOCTYPE html>
    <html>
        <head>
            <script>
                 function copyImage(ID)
                          {
                              var HeaderImage = document.getElementById(ID);
                              var controlRange;
                              if (document.body.createControlRange) 
                              {
                                  controlRange = document.body.createControlRange();
                                  controlRange.addElement(HeaderImage);
                                  controlRange.execCommand('Copy');
                              }
                              return false;
                          }
             </script>
      </head>
)

; 隐藏滚动条的 html 代码
if HideScrollbar
    style_HideScrollbar := "html { overflow: hidden }"

; 高亮图片
if HighlightImage
    html_MouseMove =
    (LTrim
        onmouseover="this.className='borderOn'"
        onmouseOut="this.className='borderOff'"
        class="borderOff"
    )

; style
html_style =
(LTrim
   <style>
        html,body {
          width: 100`%;
          height: 100`%;
          padding: 0px;
          margin: 0px;
        }

        table {
        }

        td {
            position: fixed;
            width: 24pt;
            height: 24pt;
            text-align:center;
        }

        img {
            max-width:100`%;
            max-height:100`%;
        }

        .borderOn { /* ----------------------------------- 鼠标悬停 */
            border: solid 1px #4CA0D9;  /* 边框颜色 */
            background-color: #D0F0FF;  /* 背景颜色 */
        }


        %style_HideScrollbar%

   </style>
)

td_attrib =
(LTrim Join%A_Space%
    %html_MouseMove%
    onclick="document.all._cp.src=this.innerHTML"
)



; #################################
;        生成 html
; #################################
;

; 建立 .html 文件夹
IfNotExist, .html
    FileCreateDir, .html

MaxCount := 0       ; 分类文件夹图片最多的数量

Loop, %RootDir%\*, 2                ; 搜索【分类文件夹】
{
    if A_LoopFileName = .html
        Continue

    ; 删除 html 文件，然后重新创建
    htmlFile = .html\%A_LoopFileName%.html
    FileDelete, %htmlFile%

    ; html 头部代码
    FileAppend, %html_head%%html_style%<table border="1" cellspacing="0px" bgcolor="#F6FBFE" bordercolor="#D3E4F0">`r`n, %htmlFile%

    ; 生成 html
    _count := "", tr_start := "", tr_end := "", TotalImages := 0
    Loop, %A_LoopFileLongPath%\*    ; 搜索【分类文件夹】中的图片
    {
        ; 排除非图片
        if A_LoopFileExt not in bmp,jpg,jpeg,gif,png,ico
            Continue

        ; 判断什么时候换行
        _count += 1
        tr_start := (_count=1) ? "<tr>" : ""
        tr_end   := (_count=14) ? "</tr>" : ""

        ; 鼠标悬停在图片上的提示（无后缀文件名）
        SplitPath, A_LoopFileName,,,, alt

        FileAppend,
            (LTrim Join
                %tr_start%<td %td_attrib%>
                <img src="%A_LoopFileLongPath%" alt="%alt%" id="%alt%"></td>%tr_end%`r`n
            )
            , %htmlFile%

        _count := (_count=14) ? 0 : _count

        TotalImages += 1
    }

    if !TotalImages
    {
        FileDelete, %htmlFile%
        Continue
    }

    if !HideScrollbar
    {
        ; 如果图片数量小于 70，则补上空的表格
        Loop, % 70 - TotalImages
        {
            ; 判断什么时候换行
            _count += 1
            tr_start := (_count=1) ? "<tr>" : ""
            tr_end   := (_count=14) ? "</tr>" : ""

            FileAppend,
                (LTrim Join
                    %tr_start%<td>&nbsp;</td>%tr_end%`r`n
                )
                , %htmlFile%

            _count := (_count=14) ? 0 : _count

            TotalImages ++
        }

        MaxCount := (TotalImages > MaxCount) ? TotalImages : MaxCount

        ; 是否隐藏滚动条
        html_HideScrollbar := ( Ceil(TotalImages/14) <=5 ) ? "<style>html { overflow: hidden }</style>" : ""
    }
    else
        MaxCount := (TotalImages > MaxCount) ? TotalImages : MaxCount

    ; html 尾部代码
    FileAppend,
        (LTrim Join
            </table>
            <iframe name="_cp" src="about:blank" style="display:none;"></iframe>
            %html_HideScrollbar%
        )
        , %htmlFile%

    ; 保存分类列表
    if _count !=
        CategoryList := CategoryList "|" A_LoopFileName
    else
        FileDelete, %htmlFile%
}


if !CategoryList
{
    MsgBox, 48,, 没有找到图片。程序将退出。
    ExitApp
}

CategoryList := LTrim(CategoryList, "|")

; 自动调整 ActiveX 高度
ActiveXHeight := ( HideScrollbar ? ( Ceil(MaxCount / 14) * 36.4 ) : 182 )



; #################################
;        GUI
; #################################
;

; 无标题
if !ShowGuiTitle
{
    Gui, Color, EEAA99
    Gui +LastFound +Owner
    WinSet, Transparent, 200
    WinSet, TransColor, EEAA99
    Gui -Caption
}

; -----------
StringSplit, c, CategoryList, |

Gui, Font, s12
Gui, Color, White
Gui, Margin, 10, 10
Gui, +LastFound +AlwaysOnTop
GroupAdd MyGui, % "ahk_id " . WinExist()

Gui, Add, ActiveX, xm w505 h%ActiveXHeight% vWB, Shell.Explorer
WB.Silent := True
WB.Navigate(A_ScriptDir "\.html\" c1 ".html")
ComObjConnect(WB, WB_events)

; 分类
Gui, Add, Tab2, xm w505 h25 Buttons AltSubmit -Wrap -Background BackgroundFFFFFF vTabNumber gChangeCategory, %CategoryList%

;Gui, Show,, %gui_title%

if LossFocus_CloseGui
    SetTimer, CloseGui, 200

TrayTip, %gui_title%, 按 Ctrl+1 显示界面`n   Esc 关闭界面
Sleep, 1000
TrayTip

WinGetPos, x, y, w, h
Return



; #################################
;        显示界面快捷键
; #################################
;
!b::
MouseGetPos, x, y, winID
y := (y + h > A_ScreenHeight) ? (y - h) : y
x := (x + w > A_ScreenWidth) ? (x - w) : x
Gui, Show, x%x% y%y%

if LossFocus_CloseGui
    SetTimer, CloseGui, 200
return



; #################################
;        界面失去焦点时自动关闭
; #################################
;
CloseGui:
IfWinNotActive, ahk_group MyGui
{
    Gui, Cancel
    SetTimer, CloseGui, Off
}
return




; #################################
;        切换分类
; #################################
;
ChangeCategory:
GuiControlGet, TabNumber
htmlFile := A_ScriptDir "\.html\" c%TabNumber% ".html"
WB.Navigate(htmlFile)
return



#IfWinActive ahk_group MyGui
~WheelUp::
~WheelDown::
MouseGetPos,,,, CurrCtrl

; 滚动图片表格
if (CurrCtrl = "Internet Explorer_Server1")
{
    if (A_ThisHotkey = "~WheelDown")
        ControlSend, Internet Explorer_Server1, {PgDn}
    else
        ControlSend, Internet Explorer_Server1, {PgUp}

    return
}

if (CurrCtrl != "SysTabControl321")
    return

GuiControlGet, TabNumber
TabNumber_new := (A_ThisHotkey = "~WheelDown") ? (TabNumber + 1) : (TabNumber - 1)
if (TabNumber_new > c0)
    TabNumber_new := 1
else if (TabNumber_new <= 0)
    TabNumber_new := c0

GuiControl, Choose, TabNumber, |%TabNumber_new%

htmlFile := A_ScriptDir "\.html\" c%TabNumber_new% ".html"
WB.Navigate(htmlFile)
return

; 界面显示后，不管界面有没有激活，按 ESC 都关闭界面
;#IfWinExist, ahk_group MyGui
;Esc::Gui, Cancel

#IfWinActive



; #################################
;        关闭界面
; #################################
;
GuiEscape:
GuiClose:
Gui, Cancel

class WB_events  
{  
    ; 处理方法, 当然也可以监听其他事件  
    ; 参考: http://msdn.microsoft.com/en-us/library/aa768334  
    NavigateComplete2(wb, url)
    {
        if ( url = "about:blank" || SubStr(url, -4) = ".html" )
            return

        Gui, Cancel                         ; 关闭界面
        WinWaitClose

        Clipboard_bak := ClipboardAll       ; 备份剪贴板
        Clipboard :=
        img_id := RegExReplace(url, "^.*\\([^>]+)\.[^.]+>$", "$1")   ;获取文件名 同时也是html内的id
        
        ;MsgBox, % url
        ShiftIsDown := GetKeyState("Shift", "P")        ;insert markdown
        CtrlIsDown := GetKeyState("Ctrl", "P")          ;insert file
        AltIsDown := GetKeyState("Alt", "P")            ;insert html
        
        if ( ShiftIsDown )
        {
            Clipboard := "![](" . imageAddrInOnline[img_id] . ")"
        } else if ( CtrlIsDown )
        {
            __CopyImg(img_id)               ; 复制图片文件到剪贴板
        } else if ( AltIsDown )
        {
            Clipboard := "<img src=""" . imageAddrInOnline[img_id] . """>" 
        } else
        {
            Clipboard := "[img]" . imageAddrInOnline[img_id] . "[/img]"
        }
        
        ClipWait, 5

        SendInput, ^v                       ; 粘贴
        Sleep, 200
        KeyWait, v

        Clipboard := Clipboard_bak          ; 恢复剪贴板
        Clipboard_bak =                     ; 清空剪贴板备份
    }
}

__CopyImg(img_id)
{
    global
    WB.document.parentWindow.execScript("Javascript:copyImage('" img_id "')")   ;本质上是通过JS，把该img_id对应的图片，复制进剪贴板，相比于GDip胜在能处理gif动图
}