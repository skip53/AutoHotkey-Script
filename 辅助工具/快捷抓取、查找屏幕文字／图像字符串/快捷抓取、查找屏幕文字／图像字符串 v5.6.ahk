/*
===========================================
  【屏幕抓字生成字库工具与找字函数】v5.6  By FeiYue
===========================================

  更新历史：

  v5.6 改进：颜色模式增加了对偏色的支持，方便高手在游戏中使用。

  v5.5 改变：取消了后台查找，因为Win7以上系统不太适用。
       改进：直接生成单行的字库，用其他控件来显示字库对应的图像。

  v5.3 改进：容差增加为两个，分别是 0_字符 的容许误差百分比。
       采用新的算法，提高了带容差参数时的查找速度。
       容差为默认值0时，找不到会自动使用 5% 的容差再找一次。

  v5.2 改进：新增后台查找，相当于把指定ID的窗口搬到前台再查找。
       因此用于前台操作的找字找图代码不用修改就可以转到后台模式。
       注：Win7以上系统因PrintWindow不太好用，因此许多窗口不支持。

  v5.0 改进：新增了第三种查找模式：边缘灰差模式。

  v4.6 改进：增加对多显示器扩展显示的支持。

  v4.5 改进：修正了Win10-64位系统的一些兼容性问题。
       提高了抓字窗口中二值化、删除操作的反应速度。

  v4.3 改进：文字参数中，每个字库文字可以添加用中括号括起来
       的容差值，没有中括号才用“查找文字”函数中的容差参数。

  v4.2 改进：新增了64位系统的机器码，可用于AHK 64位版。

  v4.1 改进：不再使用GDI+获取屏幕图像，直接用GDI实现。

  v4.0 改进：文字参数增加竖线分隔的字库形式，可以进行
       OCR识别。这种形式也可用于同时查找多幅文字或图片。

  v3.5 改进：采用自写的机器码实现图内找字，极大的提高了速度。

===========  屏幕抓字生成字库工具 使用说明  ===========

  1、先点击主界面的【抓取文字图像】，然后【移动鼠标】到你要
     抓取的文字或图像，然后【点击鼠标左键】，再【移开鼠标】
     100像素以上，会弹出“抓字生成字库”界面。

  2、抓字界面会显示抓取图像的彩色放大图像，先要将它二值化为
     黑白图像。目前提供了三种二值化方式，任意选一种就行。

     （1）颜色二值化：如果文字是单色的，最好采取这种方式。
     在放大的图像中【点击某种颜色】，然后点击【颜色二值化】。
     如果不是单色的，则选定主要颜色后，手动输入偏色，也能够
     以颜色加减偏色来二值化（如：红色+/-红色偏色都视为同色）。

     （2）灰差二值化：手动输入灰差后（或直接采用默认的50），
     点击【灰差二值化】。这种方式容易统一阀值，但黑点偏少。

     （3）直接点击【灰度二值化】就会自动计算出一个灰度阀值，
     并以这个阀值二值化。自动计算是针对整个图像的所有点的，
     所以最好先【手动裁剪】图像边缘，留下中心的图像后再二值化。
     当然如果对自动计算的阀值不满意，可以手动输入阀值，慢慢
     调整看哪个效果好。另外要统一阀值添加字库时也要手动输入。

  3、图像二值化后，可以点击【智删】或【左删】等来裁剪边缘，再
     点击【确定】，即可在主窗口生成调用“查找文字()”的代码。

  4、如果要进行OCR文字识别，那么可以在“识别结果文字”输入框中
     输入这幅图像或文字的识别结果（随便写），之后如果点击
     【字库分割添加】，那么结果文字的每个字都对应图像中以空列
     分割的一部分，而如果点击【字库整体添加】则结果文字整体
     对应于这幅图像的整体。这两种添加都不会改变主窗口的代码。
     提示：可以用【修改】清除一些点生成空列来分开连在一起的字。
           也可以添加一些点让左右结构的字不要被空列分割开。
           这样修改了原始图像后，代码中的两个容差最好都大于0。
           另外逗号等自动分割会裁边，建议手动裁剪保留空白边缘。
     注意：字库应统一阀值。一般先在第3步点击确定生成代码，然后
           再抓字添加字库，这时要统一采用上一次的阀值来二值化。

  5、回到主窗口，点击【全屏查找测试】，测试成功后，点击
     【复制代码】，并粘贴到你自己的脚本中，这时还运行不了，
     因为你的代码中没有“查找文字()”函数。请在我的源代码的
     最后面找到“查找文字()”函数，将它及后面的函数都复制到
     你自己的脚本中就行了（保存成库文件然后 #Include 也行）。

  6、由于许多因素会影响屏幕图像，所以换一台电脑一般就要重新
     抓字/抓图。设置一样的屏幕分辨率、浏览器放大倍数、（取消）
     平滑屏幕字体边缘，可能通用性高一些。单色文字也通用一些。

===========  找字函数 使用说明  ===========

  是否成功 := 查找文字( 中心点X, 中心点Y, 左右偏移W, 上下偏移H
              , 文字, 颜色, 返回X, 返回Y, 返回OCR结果
              , 0字符容许误差百分比, _字符容许误差百分比 )

  1、屏幕查找范围为(X-W, Y-H)—>(X+W, Y+H)，返回找到文字的中心坐标。

  2、颜色带*号的为灰度阀值（或灰差）模式，对于非单色的文字比较好用。

  3、颜色不带*号为“RRGGBB-偏色RR偏色GG偏色BB”格式，同大漠一样。

  4、末尾的容差参数允许有一些点不同，取值范围 0~1（即 0%~100%）。

  5、如果颜色模式的偏色不为0，则末尾两个容差参数也最好大于0。

  6、对于游戏中搜图常用的背景透明图，把“_字符”容差取1即可。

  7、注意抓字时是鼠标移开后再抓的，如果查找文字时鼠标刚好在
     目标位置并造成了变色、凹凸等影响，可能要移开后再查找。

===========================================
*/

#NoEnv
#SingleInstance Force
SetBatchLines, -1
CoordMode, Mouse
CoordMode, Pixel
CoordMode, ToolTip
SetTitleMatchMode, 2
SetWorkingDir, %A_ScriptDir%
;----------------------------
Menu, Tray, Icon, Shell32.dll, 23
Menu, Tray, Add
Menu, Tray, Add, 显示主窗口
Menu, Tray, Default, 显示主窗口
Menu, Tray, Click, 1
;----------------------------
  ww:=35, hh:=12    ; 左右上下抓字抓图的范围
  nW:=2*ww+1, nH:=2*hh+1
;----------------------------
Gosub, 生成抓字窗口
Gosub, 生成主窗口
OnExit, savescr
Gosub, readscr
Return

F12::    ; 按【F12】保存修改并重启脚本
SetTitleMatchMode, 2
SplitPath, A_ScriptName,,,, name
IfWinExist, %name%
{
  ControlSend, ahk_parent, {Ctrl Down}s{Ctrl Up}
  Sleep, 500
}
Reload
Return

readscr:
f=%A_Temp%\~scr1.tmp
FileRead, s, %f%
GuiControl, Main:, scr, %s%
s=
Return

savescr:
f=%A_Temp%\~scr1.tmp
GuiControlGet, s, Main:, scr
FileDelete, %f%
FileAppend, %s%, %f%
ExitApp

显示主窗口:
Gui, Main:Show, Center
Return

生成主窗口:
Gui, Main:Default
Gui, +AlwaysOnTop +HwndMain_ID
Gui, Margin, 15, 15
Gui, Color, DDEEFF
Gui, Font, s6 bold, Verdana
Gui, Add, Edit, xm w660 r25 vMyEdit -Wrap -VScroll
Gui, Font, s12 norm, Verdana
Gui, Add, Button, xm w220 gMainRun, 抓取文字图像
Gui, Add, Button, x+0 wp gMainRun, 全屏查找测试
Gui, Add, Button, x+0 wp gMainRun, 复制代码
Gui, Font, s12 cBlue, Verdana
Gui, Add, Edit, xm w660 h350 vscr Hwndhscr -Wrap HScroll
Gui, Show, NA, 文字/图像字库生成工具
;---------------------------------------
OnMessage(0x100, "EditEvents1")  ; WM_KEYDOWN
OnMessage(0x201, "EditEvents2")  ; WM_LBUTTONDOWN
Return

EditEvents1() {
  ListLines, Off
  if (A_Gui="Main") and (A_GuiControl="scr")
    SetTimer, 显示文字, -100
}

EditEvents2() {
  ListLines, Off
  if (A_Gui="Catch")
    WM_LBUTTONDOWN()
  else
    EditEvents1()
}

显示文字:
ListLines, Off
Critical
ControlGet, i, CurrentLine,,, ahk_id %hscr%
ControlGet, s, Line, %i%,, ahk_id %hscr%
if RegExMatch(s,"(\d+)\.([\w+/]+)",r)
{
  s:=RegExReplace(base64tobit(r2),".{" r1 "}","$0`n")
  s:=StrReplace(StrReplace(s,"0","_"),"1","0")
}
else s=
GuiControl, Main:, MyEdit, % Trim(s,"`n")
Return

MainRun:
k:=A_GuiControl
WinMinimize
Gui, Hide
DetectHiddenWindows, Off
WinWaitClose, ahk_id %Main_ID%
if IsLabel(k)
  Gosub, %k%
Gui, Main:Show
GuiControl, Main:Focus, scr
Return

复制代码:
GuiControlGet, s,, scr
Clipboard:=StrReplace(s,"`n","`r`n")
s=
Return

抓取文字图像:
;------------------------------
; 先用一个微型GUI提示抓字范围
Gui, Mini:Default
Gui, +LastFound +AlwaysOnTop -Caption +ToolWindow
  +E0x08000000 -DPIScale
WinSet, Transparent, 100
Gui, Color, Red
Gui, Show, Hide w%nW% h%nH%
;------------------------------
ListLines, Off
Loop {
  MouseGetPos, px, py
  if GetKeyState("LButton","P")
    Break
  Gui, Show, % "NA x" (px-ww) " y" (py-hh)
  ToolTip, % "当前鼠标位置：" px "," py
    . "`n请移到目标位置后点击左键"
  Sleep, 20
}
KeyWait, LButton
Gui, Color, White
Loop {
  MouseGetPos, x, y
  if Abs(px-x)+Abs(py-y)>100
    Break
  Gui, Show, % "NA x" (x-ww) " y" (y-hh)
  ToolTip, 请把鼠标移开100像素以上
  Sleep, 20
}
ToolTip
ListLines, On
Gui, Destroy
WinWaitClose
cors:=getc(px,py,ww,hh)
Gui, Catch:Default
Loop, 6
  GuiControl,, Edit%A_Index%
GuiControl,, huicha, 50
GuiControl,, xiugai, 0
xiugai:=0
Gosub, 重读
Gui, Show, Center
DetectHiddenWindows, Off
WinWaitClose, ahk_id %Catch_ID%
Return

WM_LBUTTONDOWN() {
  global
  ListLines, Off
  MouseGetPos,,,, mclass
  if !InStr(mclass,"progress")
    Return
  MouseGetPos,,,, mid, 2
  For k,v in C_
    if (v=mid)
    {
      if (xiugai and bg!="")
      {
        c:=cc[k], cc[k]:=c="0" ? "_" : c="_" ? "0" : c
        c:=c="0" ? "White" : c="_" ? "Black" : "0xCCDDEE"
        Gosub, SetColor
      }
      else
      {
        c:=cors[k]
        GuiControl, Catch:, yanse, % StrReplace(c,"0x")
        c:=((c>>16&0xFF)*38+(c>>8&0xFF)*75+(c&0xFF)*15)>>7
        GuiControl, Catch:, huidu, %c%
      }
      Return
    }
}

getc(px,py,ww,hh) {
  xywh2xywh(px-ww,py-hh,2*ww+1,2*hh+1,x,y,w,h)
  if (w<1 or h<1)
    Return, 0
  bch:=A_BatchLines
  SetBatchLines, -1
  ;--------------------------------------
  GetBitsFromScreen(x,y,w,h,Scan0,Stride,bits)
  ;--------------------------------------
  cors:=[], k:=0, nW:=2*ww+1, nH:=2*hh+1
  ListLines, Off
  fmt:=A_FormatInteger
  SetFormat, IntegerFast, H
  Loop, %nH% {
    j:=py-hh-y+A_Index-1
    Loop, %nW% {
      i:=px-ww-x+A_Index-1, k++
      if (i>=0 and i<w and j>=0 and j<h)
        c:=NumGet(Scan0+0,i*4+j*Stride,"uint")
          , cors[k]:="0x" . SubStr(0x1000000|c,-5)
      else
        cors[k]:="0xFFFFFF"
    }
  }
  SetFormat, IntegerFast, %fmt%
  ListLines, On
  ; 左右上下超出屏幕边界的值
  cors.left:=Abs(px-ww-x)
  cors.right:=Abs(px+ww-(x+w-1))
  cors.up:=Abs(py-hh-y)
  cors.down:=Abs(py+hh-(y+h-1))
  SetBatchLines, %bch%
  Return, cors
}

全屏查找测试:
GuiControlGet, s, Main:, scr
wenzi=
While RegExMatch(s,"文字[.:]=""([^""]+)""",r)
  wenzi.=r1, s:=StrReplace(s,r,"","",1)
if !RegExMatch(s,"查找文字\(([^)]+)\)",r)
  Return
StringSplit, r, r1, `,, ""
if r0<6
  Return
t1:=A_TickCount
ok:=查找文字(r1,r2,r3,r4,wenzi,r6,X,Y,OCR,r10,r11)
t1:=A_TickCount-t1
MsgBox, 4096,, % "查找结果：" (ok ? "成功":"失败")
  . "`n`n文字识别结果：" OCR
  . "`n`n耗时：" t1 " 毫秒，找到的位置：" (ok ? X "," Y:"")
if ok
{
  MouseMove, X, Y
  Sleep, 1000
}
Return


生成抓字窗口:
Gui, Catch:Default
Gui, +LastFound +AlwaysOnTop +ToolWindow +HwndCatch_ID
Gui, Margin, 15, 15
Gui, Color, CCDDEE
Gui, Font, s16, Verdana
ListLines, Off
w:=(2*35+1)*14//nW+1, h:=(2*12+1)*14//nH+1
Loop, % nH*nW {
  j:=A_Index=1 ? "" : Mod(A_Index,nW)=1 ? "xm y+-1" : "x+-1"
  Gui, Add, Progress, w%w% h%h% %j% -Theme
}
ListLines, On
Gui, Add, Button, xm        w80 gRun, 重读
Gui, Add, Button, x+25      w80 gRun, 左删
Gui, Add, Button, x+0       w90 gRun, 左3删
Gui, Add, Button, x+30      w80 gRun, 右删
Gui, Add, Button, x+0       w90 gRun, 右3删
Gui, Add, Button, x+30      w80 gRun, 上删
Gui, Add, Button, x+0       w90 gRun, 上3删
Gui, Add, Button, x+30      w80 gRun, 下删
Gui, Add, Button, x+0       w90 gRun, 下3删
Gui, Add, Button, x+30      w90 gRun, 智删
;-------------------------
Gui, Add, Text,   xm y+20   w50, 颜色
Gui, Add, Edit,   x+2       w120 vyanse ReadOnly
Gui, Add, Text,   x+2       w60 Center, 偏色
Gui, Add, Edit,   x+2       w120 vpianse Limit6
Gui, Add, Button, x+2 yp-6  w140 gRun, 颜色二值化
Gui, Add, Checkbox
  , x+22 yp+6 w265 vxiugai r1 gRun, 修改(以空列分割文字)
Gui, Add, Button, x+30 yp-6 w90 gCancel, 关闭
Gui, Add, Button, x+0       w90 gRun, 确定
;-------------------------
Gui, Add, Text,   xm y+20   w50, 灰度
Gui, Add, Edit,   x+2       w120 vhuidu ReadOnly
Gui, Add, Text,   x+2       w60 Center, 灰差
Gui, Add, Edit,   x+2       w120 vhuicha
Gui, Add, Button, x+2 yp-6  w140 gRun, 灰差二值化
Gui, Add, Text,   x+22 yp+6 w255 r1,  识别结果文字(用于字库)
Gui, Add, Edit,   x+0       w220 vziku
;-------------------------
Gui, Add, Text,   xm y+20   w236 r1, 阀值(为空则自动计算)
Gui, Add, Edit,   x+0       w120 vfazhi
Gui, Add, Button, x+2 yp-6  w140 gRun Default, 灰度二值化
Gui, Add, Button, x+22      w230 gRun, 字库分割添加
Gui, Add, Button, x+15      w230 gRun, 字库整体添加
;-------------------------
Gui, Show, Hide, 抓字生成字库
WinGet, s, ControlListHwnd
C_:=StrSplit(s,"`n"), s:=""
Return

Run:
Critical
k:=A_GuiControl
if IsLabel(k)
  Goto, %k%
Return

xiugai:
GuiControlGet, xiugai
Return

SetColor:
c:=c="White" ? 0xFFFFFF : c="Black" ? 0x000000
  : ((c&0xFF)<<16)|(c&0xFF00)|((c&0xFF0000)>>16)
SendMessage, 0x2001, 0, c,, % "ahk_id " . C_[k]
Return

重读:
if !IsObject(cc)
  cc:=[], gg:=[], pp:=[]
left:=right:=up:=down:=k:=0, bg:=""
Loop, % nH*nW {
  cc[++k]:=1, c:=cors[k]
  gg[k]:=((c>>16&0xFF)*38+(c>>8&0xFF)*75+(c&0xFF)*15)>>7
  Gosub, SetColor
}
; 裁剪抓字范围超过屏幕边界的部分
Loop, % cors.left
  Gosub, 左删
Loop, % cors.right
  Gosub, 右删
Loop, % cors.up
  Gosub, 上删
Loop, % cors.down
  Gosub, 下删
Return

颜色二值化:
GuiControlGet, c,, yanse
GuiControlGet, dc,, pianse
if c=
{
  MsgBox, 4096,, `n    请先进行选色！    `n, 1
  Return
}
dc:=dc="" ? "000000" : StrReplace(dc,"0x")
color:=c "-" dc, k:=i:=0
c:=Round("0x" c), dc:=Round("0x" dc)
R:=(c>>16)&0xFF, G:=(c>>8)&0xFF, B:=c&0xFF
dR:=(dc>>16)&0xFF, dG:=(dc>>8)&0xFF, dB:=dc&0xFF
R1:=R-dR, G1:=G-dG, B1:=B-dB
R2:=R+dR, G2:=G+dG, B2:=B+dB
Loop, % nH*nW {
  if (cc[++k]="")
    Continue
  c:=cors[k], R:=(c>>16)&0xFF, G:=(c>>8)&0xFF, B:=c&0xFF
  if (R>=R1 && R<=R2 && G>=G1 && G<=G2 && B>=B1 && B<=B2)
    cc[k]:="0", c:="Black", i++
  else
    cc[k]:="_", c:="White", i--
  Gosub, SetColor
}
bg:=i>0 ? "0":"_"  ; 背景色
Return

灰度二值化:  ; 可以多次手动输入阀值或清空阀值再次二值化
GuiControl, Focus, fazhi
GuiControlGet, fazhi
if fazhi=
{
  Loop, 256    ; 统计灰度直方图
    pp[A_Index-1]:=0
  Loop, % nH*nW
    if (cc[A_Index]!="")
      pp[gg[A_Index]]++
  ; 迭代法求二值化阈值，最多迭代20次，这个算法非常快速
  IP:=IS:=0
  Loop, 256
    k:=A_Index-1, IP+=k*pp[k], IS+=pp[k]
  Newfazhi:=Floor(IP/IS)
  Loop, 20 {
    fazhi:=Newfazhi
    IP1:=IS1:=0
    Loop, % fazhi+1
      k:=A_Index-1, IP1+=k*pp[k], IS1+=pp[k]
    IP2:=IP-IP1, IS2:=IS-IS1
    if (IS1!=0 and IS2!=0)
      Newfazhi:=Floor((IP1/IS1+IP2/IS2)/2)
    if (Newfazhi=fazhi)
      Break
  }
  GuiControl,, fazhi, %fazhi%
}
color:="*" fazhi, k:=i:=0
Loop, % nH*nW {
  if (cc[++k]="")
    Continue
  if (gg[k]<fazhi+1)
    cc[k]:="0", c:="Black", i++
  else
    cc[k]:="_", c:="White", i--
  Gosub, SetColor
}
bg:=i>0 ? "0":"_"  ; 背景色
Return

灰差二值化:
GuiControlGet, huicha
if huicha=
{
  MsgBox, 4096,, `n  请先设置边缘灰度差（比如50）！  `n, 1
  Return
}
huicha:=Round(huicha)
if (left=cors.left)
  Gosub, 左删
if (right=cors.right)
  Gosub, 右删
if (up=cors.up)
  Gosub, 上删
if (down=cors.down)
  Gosub, 下删
color:="**" huicha, k:=i:=0
Loop, % nH*nW {
  if (cc[++k]="")
    Continue
  c:=gg[k]+huicha
  if (gg[k-1]>c or gg[k+1]>c or gg[k-nW]>c or gg[k+nW]>c)
    cc[k]:="0", c:="Black", i++
  else
    cc[k]:="_", c:="White", i--
  Gosub, SetColor
}
bg:=i>0 ? "0":"_"  ; 背景色
Return

gui_del:
cc[k]:="", c:="0xCCDDEE"
Gosub, SetColor
Return

左3删:
Loop, 3
  Gosub, 左删
Return

左删:
if (left+right>=nW)
  Return
left++, k:=left
Loop, %nH% {
  Gosub, gui_del
  k+=nW
}
Return

右3删:
Loop, 3
  Gosub, 右删
Return

右删:
if (left+right>=nW)
  Return
right++, k:=nW+1-right
Loop, %nH% {
  Gosub, gui_del
  k+=nW
}
Return

上3删:
Loop, 3
  Gosub, 上删
Return

上删:
if (up+down>=nH)
  Return
up++, k:=(up-1)*nW
Loop, %nW% {
  k++
  Gosub, gui_del
}
Return

下3删:
Loop, 3
  Gosub, 下删
Return

下删:
if (up+down>=nH)
  Return
down++, k:=(nH-down)*nW
Loop, %nW% {
  k++
  Gosub, gui_del
}
Return

getwz:
wz=
if bg=
  Return
ListLines, Off
k:=0
Loop, %nH% {
  v=
  Loop, %nW%
    v.=cc[++k]
  wz.=v="" ? "" : v "`n"
}
ListLines, On
Return

智删:
Gosub, getwz
if wz=
{
  MsgBox, 4096, 提示, `n请先进行一种二值化！, 1
  Return
}
While InStr(wz,bg) {
  if (wz~="^" bg "+\n")
  {
    wz:=RegExReplace(wz,"^" bg "+\n")
    Gosub, 上删
  }
  else if !(wz~="m`n)[^\n" bg "]$")
  {
    wz:=RegExReplace(wz,"m`n)" bg "$")
    Gosub, 右删
  }
  else if (wz~="\n" bg "+\n$")
  {
    wz:=RegExReplace(wz,"\n\K" bg "+\n$")
    Gosub, 下删
  }
  else if !(wz~="m`n)^[^\n" bg "]")
  {
    wz:=RegExReplace(wz,"m`n)^" bg)
    Gosub, 左删
  }
  else Break
}
wz=
Return

确定:
字库分割添加:
字库整体添加:
Gosub, getwz
if wz=
{
  MsgBox, 4096, 提示, `n请先进行一种二值化！, 1
  Return
}
Gui, Hide
GuiControlGet, ziku
ziku:=Trim(ziku)
IfInString, A_ThisLabel, 分割
{
  SetFormat, IntegerFast, d  ; 正则表达式中数字需要十进制
  s:="", bg:=StrLen(StrReplace(wz,"_"))
    > StrLen(StrReplace(wz,"0")) ? "0":"_"
  Loop {
    While InStr(wz,bg) and !(wz~="m`n)^[^\n" bg "]")
      wz:=RegExReplace(wz,"m`n)^.")
    Loop, % InStr(wz,"`n")-1 {
      i:=A_Index
      if !(wz~="m`n)^.{" i "}[^\n" bg "]")
      {
        ; 自动分割会裁边，小数点等的字库要手动制作
        v:=RegExReplace(wz,"m`n)^(.{" i "}).*","$1")
        v:=RegExReplace(v,"^(" bg "+\n)+")
        v:=RegExReplace(v,"\n\K(" bg "+\n)+$")
        s.=towz(SubStr(ziku,1,1),v)
        ziku:=SubStr(ziku,2)
        wz:=RegExReplace(wz,"m`n)^.{" i "}")
        Continue, 2
      }
    }
    Break
  }
  add(s)
  Return
}
IfInString, A_ThisLabel, 整体
{
  add(towz(ziku,wz))
  Return
}
; 生成代码中的坐标为裁剪后整体文字的中心位置
px1:=px-ww+left+(nW-left-right)//2
py1:=py-hh+up+(nH-up-down)//2
s:="`n文字:=""""`n" . towz(ziku,wz) . "`nif 查找文字("
  . px1 "," py1 ",150000,150000,文字,"""
  . color . """,X,Y,OCR,0,0)`n"
  . "{`n  CoordMode, Mouse`n  MouseMove, X, Y`n}`n"
GuiControl, Main:, scr, %s%
s:=wz:=""
Return

towz(ziku,wz) {
  SetFormat, IntegerFast, d
  wz:=StrReplace(StrReplace(wz,"0","1"),"_","0")
  wz:=InStr(wz,"`n")-1 . "." . bit2base64(wz)
  Return, "`n文字.=""|<" ziku ">" wz """`n"
}

add(s) {
  global hscr
  s:=RegExReplace("`n" s "`n","\R","`r`n")
  ControlGet, i, CurrentCol,,, ahk_id %hscr%
  if i>1
    ControlSend,, {Home}{Down}, ahk_id %hscr%
  Control, EditPaste, %s%,, ahk_id %hscr%
}


;---- 将后面的函数附加到自己的脚本中 ----


;-----------------------------------------
; 查找屏幕文字/图像字库及OCR识别
; 注意：参数中的x、y为中心点坐标，w、h为左右上下偏移
; cha1、cha0分别为0、_字符的容许误差百分比
;-----------------------------------------
查找文字(x,y,w,h,wz,c,ByRef rx="",ByRef ry="",ByRef ocr=""
  , cha1=0, cha0=0)
{
  xywh2xywh(x-w,y-h,2*w+1,2*h+1,x,y,w,h)
  if (w<1 or h<1)
    Return, 0
  bch:=A_BatchLines
  SetBatchLines, -1
  ;--------------------------------------
  GetBitsFromScreen(x,y,w,h,Scan0,Stride,bits)
  ;--------------------------------------
  ; 设定图内查找范围，注意不要越界
  sx:=0, sy:=0, sw:=w, sh:=h
  if PicOCR(Scan0,Stride,sx,sy,sw,sh,wz,c
    ,rx,ry,ocr,cha1,cha0)
  {
    rx+=x, ry+=y
    SetBatchLines, %bch%
    Return, 1
  }
  ; 容差为0的若失败则使用 5% 的容差再找一次
  if (cha1=0 and cha0=0)
    and PicOCR(Scan0,Stride,sx,sy,sw,sh,wz,c
      ,rx,ry,ocr,0.05,0.05)
  {
    rx+=x, ry+=y
    SetBatchLines, %bch%
    Return, 1
  }
  SetBatchLines, %bch%
  Return, 0
}

;-- 规范输入范围在屏幕范围内
xywh2xywh(x1,y1,w1,h1,ByRef x,ByRef y,ByRef w,ByRef h)
{
  ; 获取包含所有显示器的虚拟屏幕范围
  SysGet, zx, 76
  SysGet, zy, 77
  SysGet, zw, 78
  SysGet, zh, 79
  left:=x1, right:=x1+w1-1, up:=y1, down:=y1+h1-1
  left:=left<zx ? zx:left, right:=right>zx+zw-1 ? zx+zw-1:right
  up:=up<zy ? zy:up, down:=down>zy+zh-1 ? zy+zh-1:down
  x:=left, y:=up, w:=right-left+1, h:=down-up+1
}

;-- 获取屏幕图像的内存数据，图像包括透明窗口
GetBitsFromScreen(x,y,w,h,ByRef Scan0,ByRef Stride,ByRef bits)
{
  VarSetCapacity(bits, w*h*4, 0)
  Ptr:=A_PtrSize ? "Ptr" : "UInt"
  ; 桌面窗口对应包含所有显示器的虚拟屏幕
  win:=DllCall("GetDesktopWindow", Ptr)
  hDC:=DllCall("GetWindowDC", Ptr,win, Ptr)
  mDC:=DllCall("CreateCompatibleDC", Ptr,hDC, Ptr)
  hBM:=DllCall("CreateCompatibleBitmap", Ptr,hDC
    , "int",w, "int",h, Ptr)
  oBM:=DllCall("SelectObject", Ptr,mDC, Ptr,hBM, Ptr)
  DllCall("BitBlt", Ptr,mDC, "int",0, "int",0, "int",w, "int",h
    , Ptr,hDC, "int",x, "int",y, "uint",0x00CC0020|0x40000000)
  ;--------------------------
  VarSetCapacity(bi, 40, 0)
  NumPut(40, bi, 0, "int"), NumPut(w, bi, 4, "int")
  NumPut(-h, bi, 8, "int"), NumPut(1, bi, 12, "short")
  NumPut(bpp:=32, bi, 14, "short"), NumPut(0, bi, 16, "int")
  ;--------------------------
  DllCall("GetDIBits", Ptr,mDC, Ptr,hBM
    , "int",0, "int",h, Ptr,&bits, Ptr,&bi, "int",0)
  DllCall("SelectObject", Ptr,mDC, Ptr,oBM)
  DllCall("DeleteObject", Ptr,hBM)
  DllCall("DeleteDC", Ptr,mDC)
  DllCall("ReleaseDC", Ptr,win, Ptr,hDC)
  Scan0:=&bits, Stride:=((w*bpp+31)//32)*4
}

;-----------------------------------------
; 图像内查找文字/图像字符串及OCR函数
;-----------------------------------------
PicOCR(Scan0, Stride, sx, sy, sw, sh, wenzi, c
  , ByRef rx, ByRef ry, ByRef ocr, cha1, cha0)
{
  static MyFunc
  if !MyFunc
  {
    x32:="5589E55383C4808B45240FAF451C8B5520C1E20201D0894"
    . "5F08B5528B80000000029D0C1E00289C28B451C01D08945ECC"
    . "745E800000000C745D400000000C745D0000000008B4528894"
    . "5CC8B452C8945C8C745C400000000837D08000F85660100008"
    . "B450CC1E81025FF0000008945C08B450CC1E80825FF0000008"
    . "945BC8B450C25FF0000008945B88B4510C1E81025FF0000008"
    . "945B48B4510C1E80825FF0000008945B08B451025FF0000008"
    . "945AC8B45C02B45B48945A88B45BC2B45B08945A48B45B82B4"
    . "5AC8945A08B55C08B45B401D089459C8B55BC8B45B001D0894"
    . "5988B55B88B45AC01D0894594C745F400000000E9BF000000C"
    . "745F800000000E99D0000008B45F083C00289C28B451801D00"
    . "FB6000FB6C03B45A87C798B45F083C00289C28B451801D00FB"
    . "6000FB6C03B459C7F618B45F083C00189C28B451801D00FB60"
    . "00FB6C03B45A47C498B45F083C00189C28B451801D00FB6000"
    . "FB6C03B45987F318B55F08B451801D00FB6000FB6C03B45A07"
    . "C1E8B55F08B451801D00FB6000FB6C03B45947F0B8B55E88B4"
    . "53401D0C600318345F8018345F0048345E8018B45F83B45280"
    . "F8C57FFFFFF8345F4018B45EC0145F08B45F43B452C0F8C35F"
    . "FFFFFE917020000837D08010F85A30000008B450C83C001C1E"
    . "00789450CC745F400000000EB7DC745F800000000EB628B45F"
    . "083C00289C28B451801D00FB6000FB6C06BD0268B45F083C00"
    . "189C18B451801C80FB6000FB6C06BC04B8D0C028B55F08B451"
    . "801D00FB6000FB6D089D0C1E00429D001C83B450C730B8B55E"
    . "88B453401D0C600318345F8018345F0048345E8018B45F83B4"
    . "5287C968345F4018B45EC0145F08B45F43B452C0F8C77FFFFF"
    . "FE96A010000C745F400000000EB7BC745F800000000EB608B5"
    . "5E88B45308D0C028B45F083C00289C28B451801D00FB6000FB"
    . "6C06BD0268B45F083C00189C38B451801D80FB6000FB6C06BC"
    . "04B8D1C028B55F08B451801D00FB6000FB6D089D0C1E00429D"
    . "001D8C1F80788018345F8018345F0048345E8018B45F83B452"
    . "87C988345F4018B45EC0145F08B45F43B452C0F8C79FFFFFF8"
    . "B452883E8018945908B452C83E80189458CC745F401000000E"
    . "9B0000000C745F801000000E9940000008B45F40FAF452889C"
    . "28B45F801D08945E88B55E88B453001D00FB6000FB6D08B450"
    . "C01D08945EC8B45E88D50FF8B453001D00FB6000FB6C03B45E"
    . "C7F488B45E88D50018B453001D00FB6000FB6C03B45EC7F328"
    . "B45E82B452889C28B453001D00FB6000FB6C03B45EC7F1A8B5"
    . "5E88B452801D089C28B453001D00FB6000FB6C03B45EC7E0B8"
    . "B55E88B453401D0C600318345F8018B45F83B45900F8C60FFF"
    . "FFF8345F4018B45F43B458C0F8C44FFFFFFC745E800000000E"
    . "9E30000008B45E88D1485000000008B454401D08B008945E08"
    . "B45E08945E48B45E48945F08B45E883C0018D1485000000008"
    . "B454401D08B008945908B45E883C0028D1485000000008B454"
    . "401D08B0089458CC745F400000000EB7CC745F800000000EB6"
    . "78B45F08D50018955F089C28B453801D00FB6003C3175278B4"
    . "5E48D50018955E48D1485000000008B453C01C28B45F40FAF4"
    . "52889C18B45F801C88902EB258B45E08D50018955E08D14850"
    . "00000008B454001C28B45F40FAF452889C18B45F801C889028"
    . "345F8018B45F83B45907C918345F4018B45F43B458C0F8C78F"
    . "FFFFF8345E8078B45E83B45480F8C11FFFFFF8B45D00FAF452"
    . "889C28B45D401D08945E4C745F800000000E909030000C745F"
    . "400000000E9ED0200008B45F40FAF452889C28B45F801C28B4"
    . "5E401D08945F0C745E800000000E9BB0200008B45E883C0018"
    . "D1485000000008B454401D08B008945908B45E883C0028D148"
    . "5000000008B454401D08B0089458C8B55F88B459001D03B45C"
    . "C0F8F770200008B55F48B458C01D03B45C80F8F660200008B4"
    . "5E88D1485000000008B454401D08B008945E08B45E883C0038"
    . "D1485000000008B454401D08B008945888B45E883C0048D148"
    . "5000000008B454401D08B008945848B45E883C0058D1485000"
    . "000008B454401D08B008945DC8B45E883C0068D14850000000"
    . "08B454401D08B008945D88B45883945840F4D4584894580C74"
    . "5EC00000000E9820000008B45EC3B45887D378B55E08B45EC0"
    . "1D08D1485000000008B453C01D08B108B45F001D089C28B453"
    . "401D00FB6003C31740E836DDC01837DDC000F88980100008B4"
    . "5EC3B45847D378B55E08B45EC01D08D1485000000008B45400"
    . "1D08B108B45F001D089C28B453401D00FB6003C30740E836DD"
    . "801837DD8000F885C0100008345EC018B45EC3B45800F8C72F"
    . "FFFFF837DC4000F85840000008B55208B45F801C28B454C891"
    . "08B454C83C0048B4D248B55F401CA89108B454C8D50088B459"
    . "089028B454C8D500C8B458C8902C745C4040000008B45F42B4"
    . "58C8945D08B558C89D001C001D08945C88B558C89D0C1E0020"
    . "1D001C083C0648945CC837DD0007907C745D0000000008B452"
    . "C2B45D03B45C87D338B452C2B45D08945C8EB288B55088B451"
    . "401D03B45F87D1B8B45C48D50018955C48D1485000000008B4"
    . "54C01D0C700FFFFFFFF8B459083E8018945088B45C48D50018"
    . "955C48D1485000000008B454C01D08B55E883C2078910817DC"
    . "4FD0300000F8FA4000000C745EC00000000EB298B55E08B45E"
    . "C01D08D1485000000008B453C01D08B108B45F001D089C28B4"
    . "53401D0C600308345EC018B45EC3B45887CCF8B45F883C0010"
    . "145D48B45282B45D43B45CC0F8D13FDFFFF8B45282B45D4894"
    . "5CCE905FDFFFF90EB0490EB01908345E8078B45E83B45480F8"
    . "C39FDFFFF8345F4018B45F43B45C80F8C07FDFFFF8345F8018"
    . "B45F83B45CC0F8CEBFCFFFF837DC4007508B800000000EB1B9"
    . "08B45C48D1485000000008B454C01D0C70000000000B801000"
    . "00083EC805B5DC24800"
    x64:="554889E54883C480894D108955184489452044894D288B4"
    . "5480FAF45388B5540C1E20201D08945F48B5550B8000000002"
    . "9D0C1E00289C28B453801D08945F0C745EC00000000C745D80"
    . "0000000C745D4000000008B45508945D08B45588945CCC745C"
    . "800000000837D10000F85850100008B4518C1E81025FF00000"
    . "08945C48B4518C1E80825FF0000008945C08B451825FF00000"
    . "08945BC8B4520C1E81025FF0000008945B88B4520C1E80825F"
    . "F0000008945B48B452025FF0000008945B08B45C42B45B8894"
    . "5AC8B45C02B45B48945A88B45BC2B45B08945A48B55C48B45B"
    . "801D08945A08B55C08B45B401D089459C8B55BC8B45B001D08"
    . "94598C745F800000000E9DE000000C745FC00000000E9BC000"
    . "0008B45F483C0024863D0488B45304801D00FB6000FB6C03B4"
    . "5AC0F8C910000008B45F483C0024863D0488B45304801D00FB"
    . "6000FB6C03B45A07F768B45F483C0014863D0488B45304801D"
    . "00FB6000FB6C03B45A87C5B8B45F483C0014863D0488B45304"
    . "801D00FB6000FB6C03B459C7F408B45F44863D0488B4530480"
    . "1D00FB6000FB6C03B45A47C288B45F44863D0488B45304801D"
    . "00FB6000FB6C03B45987F108B45EC4863D0488B45684801D0C"
    . "600318345FC018345F4048345EC018B45FC3B45500F8C38FFF"
    . "FFF8345F8018B45F00145F48B45F83B45580F8C16FFFFFFE95"
    . "9020000837D10010F85B60000008B451883C001C1E00789451"
    . "8C745F800000000E98D000000C745FC00000000EB728B45F48"
    . "3C0024863D0488B45304801D00FB6000FB6C06BD0268B45F48"
    . "3C0014863C8488B45304801C80FB6000FB6C06BC04B8D0C028"
    . "B45F44863D0488B45304801D00FB6000FB6D089D0C1E00429D"
    . "001C83B451873108B45EC4863D0488B45684801D0C60031834"
    . "5FC018345F4048345EC018B45FC3B45507C868345F8018B45F"
    . "00145F48B45F83B45580F8C67FFFFFFE999010000C745F8000"
    . "00000E98D000000C745FC00000000EB728B45EC4863D0488B4"
    . "560488D0C028B45F483C0024863D0488B45304801D00FB6000"
    . "FB6C06BD0268B45F483C0014C63C0488B45304C01C00FB6000"
    . "FB6C06BC04B448D04028B45F44863D0488B45304801D00FB60"
    . "00FB6D089D0C1E00429D04401C0C1F80788018345FC018345F"
    . "4048345EC018B45FC3B45507C868345F8018B45F00145F48B4"
    . "5F83B45580F8C67FFFFFF8B455083E8018945948B455883E80"
    . "1894590C745F801000000E9CA000000C745FC01000000E9AE0"
    . "000008B45F80FAF455089C28B45FC01D08945EC8B45EC4863D"
    . "0488B45604801D00FB6000FB6D08B451801D08945F08B45EC4"
    . "898488D50FF488B45604801D00FB6000FB6C03B45F07F538B4"
    . "5EC4898488D5001488B45604801D00FB6000FB6C03B45F07F3"
    . "88B45EC2B45504863D0488B45604801D00FB6000FB6C03B45F"
    . "07F1D8B55EC8B455001D04863D0488B45604801D00FB6000FB"
    . "6C03B45F07E108B45EC4863D0488B45684801D0C600318345F"
    . "C018B45FC3B45940F8C46FFFFFF8345F8018B45F83B45900F8"
    . "C2AFFFFFFC745EC00000000E9100100008B45EC4898488D148"
    . "500000000488B85880000004801D08B008945E48B45E48945E"
    . "88B45E88945F48B45EC48984883C001488D148500000000488"
    . "B85880000004801D08B008945948B45EC48984883C002488D1"
    . "48500000000488B85880000004801D08B00894590C745F8000"
    . "00000E98C000000C745FC00000000EB778B45F48D50018955F"
    . "44863D0488B45704801D00FB6003C31752C8B45E88D5001895"
    . "5E84898488D148500000000488B45784801C28B45F80FAF455"
    . "089C18B45FC01C88902EB2D8B45E48D50018955E44898488D1"
    . "48500000000488B85800000004801C28B45F80FAF455089C18"
    . "B45FC01C889028345FC018B45FC3B45947C818345F8018B45F"
    . "83B45900F8C68FFFFFF8345EC078B45EC3B85900000000F8CE"
    . "1FEFFFF8B45D40FAF455089C28B45D801D08945E8C745FC000"
    . "00000E988030000C745F800000000E96C0300008B45F80FAF4"
    . "55089C28B45FC01C28B45E801D08945F4C745EC00000000E93"
    . "70300008B45EC48984883C001488D148500000000488B85880"
    . "000004801D08B008945948B45EC48984883C002488D1485000"
    . "00000488B85880000004801D08B008945908B55FC8B459401D"
    . "03B45D00F8FE10200008B55F88B459001D03B45CC0F8FD0020"
    . "0008B45EC4898488D148500000000488B85880000004801D08"
    . "B008945E48B45EC48984883C003488D148500000000488B858"
    . "80000004801D08B0089458C8B45EC48984883C004488D14850"
    . "0000000488B85880000004801D08B008945888B45EC4898488"
    . "3C005488D148500000000488B85880000004801D08B008945E"
    . "08B45EC48984883C006488D148500000000488B85880000004"
    . "801D08B008945DC8B458C3945880F4D4588894584C745F0000"
    . "00000E9950000008B45F03B458C7D3F8B55E48B45F001D0489"
    . "8488D148500000000488B45784801D08B108B45F401D04863D"
    . "0488B45684801D00FB6003C31740E836DE001837DE0000F88C"
    . "E0100008B45F03B45887D428B55E48B45F001D04898488D148"
    . "500000000488B85800000004801D08B108B45F401D04863D04"
    . "88B45684801D00FB6003C30740E836DDC01837DDC000F88870"
    . "100008345F0018B45F03B45840F8C5FFFFFFF837DC8000F859"
    . "70000008B55408B45FC01C2488B85980000008910488B85980"
    . "000004883C0048B4D488B55F801CA8910488B8598000000488"
    . "D50088B45948902488B8598000000488D500C8B45908902C74"
    . "5C8040000008B45F82B45908945D48B559089D001C001D0894"
    . "5CC8B559089D0C1E00201D001C083C0648945D0837DD400790"
    . "7C745D4000000008B45582B45D43B45CC7D3B8B45582B45D48"
    . "945CCEB308B55108B452801D03B45FC7D238B45C88D5001895"
    . "5C84898488D148500000000488B85980000004801D0C700FFF"
    . "FFFFF8B459483E8018945108B45C88D50018955C84898488D1"
    . "48500000000488B85980000004801D08B55EC83C2078910817"
    . "DC8FD0300000F8FAF000000C745F000000000EB318B55E48B4"
    . "5F001D04898488D148500000000488B45784801D08B108B45F"
    . "401D04863D0488B45684801D0C600308345F0018B45F03B458"
    . "C7CC78B45FC83C0010145D88B45502B45D83B45D00F8D97FCF"
    . "FFF8B45502B45D88945D0E989FCFFFF90EB0490EB01908345E"
    . "C078B45EC3B85900000000F8CBAFCFFFF8345F8018B45F83B4"
    . "5CC0F8C88FCFFFF8345FC018B45FC3B45D00F8C6CFCFFFF837"
    . "DC8007508B800000000EB23908B45C84898488D14850000000"
    . "0488B85980000004801D0C70000000000B8010000004883EC8"
    . "05DC3909090909090909090909090909090"
    MCode(MyFunc, A_PtrSize=8 ? x64:x32)
  }
  ;--------------------------------------
  ; 统计字库文字的个数和宽高，将解释文字存入数组并删除<>
  ;--------------------------------------
  wenzitab:=[], num:=0, wz:="", j:=""
  Loop, Parse, wenzi, |
  {
    v:=A_LoopField, txt:="", e1:=cha1, e0:=cha0
    ; 用角括号输入每个字库字符串的识别结果文字
    if RegExMatch(v,"<([^>]*)>",r)
      v:=StrReplace(v,r), txt:=r1
    ; 可以用中括号输入每个文字的两个容差，以逗号分隔
    if RegExMatch(v,"\[([^\]]*)]",r)
    {
      v:=StrReplace(v,r), r2:=""
      StringSplit, r, r1, `,
      e1:=r1, e0:=r2
    }
    ; 记录每个文字的起始位置、宽、高、10字符的数量和容差
    StringSplit, r, v, .
    w:=r1, v:=base64tobit(r2), h:=StrLen(v)//w
    if (r0<2 or w>sw or h>sh or StrLen(v)!=w*h)
      Continue
    len1:=StrLen(StrReplace(v,"0"))
    len0:=StrLen(StrReplace(v,"1"))
    e1:=Round(len1*e1), e0:=Round(len0*e0)
    j.=StrLen(wz) "|" w "|" h
      . "|" len1 "|" len0 "|" e1 "|" e0 "|"
    wz.=v, wenzitab[++num]:=Trim(txt)
  }
  IfEqual, wz,, Return, 0
  ;--------------------------------------
  ; wz 使用Astr参数类型可以自动转为ANSI版字符串
  ; in 输入各文字的起始位置等信息，out 返回结果
  ; ss 等为临时内存，jiange 超过间隔就会加入*号
  ;--------------------------------------
  mode:=InStr(c,"**") ? 2 : InStr(c,"*") ? 1 : 0
  c:=StrReplace(c,"*"), jiange:=5, num*=7
  if mode=0
  {
    c:=StrReplace(c,"0x") . "-0"
    StringSplit, r, c, -
    c:=Round("0x" r1), dc:=Round("0x" r2)
  }
  VarSetCapacity(in,num*4,0), i:=-4
  Loop, Parse, j, |
    if (A_Index<=num)
      NumPut(A_LoopField, in, i+=4, "int")
  VarSetCapacity(gs, sw*sh)
  VarSetCapacity(ss, sw*sh, Asc("0"))
  k:=StrLen(wz)*4
  VarSetCapacity(s1, k, 0), VarSetCapacity(s0, k, 0)
  VarSetCapacity(out, 1024*4, 0)
  if DllCall(&MyFunc, "int",mode, "uint",c, "uint",dc
    , "int",jiange, "ptr",Scan0, "int",Stride
    , "int",sx, "int",sy, "int",sw, "int",sh
    , "ptr",&gs, "ptr",&ss
    , "Astr",wz, "ptr",&s1, "ptr",&s0
    , "ptr",&in, "int",num, "ptr",&out)
  {
    ocr:="", i:=-4  ; 返回第一个文字的中心位置
    x:=NumGet(out,i+=4,"int"), y:=NumGet(out,i+=4,"int")
    w:=NumGet(out,i+=4,"int"), h:=NumGet(out,i+=4,"int")
    rx:=x+w//2, ry:=y+h//2
    While (k:=NumGet(out,i+=4,"int"))
      v:=wenzitab[k//7], ocr.=v="" ? "*" : v
    Return, 1
  }
  Return, 0
}

MCode(ByRef code, hex)
{
  ListLines, Off
  bch:=A_BatchLines
  SetBatchLines, -1
  VarSetCapacity(code, StrLen(hex)//2)
  Loop, % StrLen(hex)//2
    NumPut("0x" . SubStr(hex,2*A_Index-1,2)
      , code, A_Index-1, "char")
  Ptr:=A_PtrSize ? "Ptr" : "UInt"
  DllCall("VirtualProtect", Ptr,&code, Ptr
    ,VarSetCapacity(code), "uint",0x40, Ptr . "*",0)
  SetBatchLines, %bch%
  ListLines, On
}

base64tobit(s) {
  ListLines, Off
  s:=RegExReplace(s,"\s+")
  Chars:="0123456789+/ABCDEFGHIJKLMNOPQRSTUVWXYZ"
    . "abcdefghijklmnopqrstuvwxyz"
  SetFormat, IntegerFast, d
  StringCaseSense, On
  Loop, Parse, Chars
  {
    i:=A_Index-1, v:=(i>>5&1) . (i>>4&1)
      . (i>>3&1) . (i>>2&1) . (i>>1&1) . (i&1)
    s:=StrReplace(s,A_LoopField,v)
  }
  StringCaseSense, Off
  s:=SubStr(s,1,InStr(s,"1",0,0)-1)
  ListLines, On
  Return, s
}

bit2base64(s) {
  ListLines, Off
  s:=RegExReplace(s,"\s+")
  s.=SubStr("100000",1,6-Mod(StrLen(s),6))
  s:=RegExReplace(s,".{6}","|$0")
  Chars:="0123456789+/ABCDEFGHIJKLMNOPQRSTUVWXYZ"
    . "abcdefghijklmnopqrstuvwxyz"
  SetFormat, IntegerFast, d
  Loop, Parse, Chars
  {
    i:=A_Index-1, v:="|" . (i>>5&1) . (i>>4&1)
      . (i>>3&1) . (i>>2&1) . (i>>1&1) . (i&1)
    s:=StrReplace(s,v,A_LoopField)
  }
  ListLines, On
  Return, s
}


/************  机器码的C源码 ************

int __attribute__((__stdcall__)) OCR( int mode
  , unsigned int c, unsigned int dc
  , int jiange, unsigned char * Bmp, int Stride
  , int sx, int sy, int sw, int sh
  , unsigned char * gs, char * ss
  , char * wz, int * s1, int * s0
  , int * in, int num, int * out )
{
  int x, y, o=sy*Stride+sx*4, j=Stride-4*sw, i=0;
  int o1, o2, w, h, max, len1, len0, e1, e0;
  int sx1=0, sy1=0, sw1=sw, sh1=sh, Ptr=0;

  //准备工作一：先将图像各点在ss中转化为01字符
  if (mode==0)    //颜色模式
  {
    int R=(c>>16)&0xFF, G=(c>>8)&0xFF, B=c&0xFF;
    int dR=(dc>>16)&0xFF, dG=(dc>>8)&0xFF, dB=dc&0xFF;
    int R1=R-dR, G1=G-dG, B1=B-dB;
    int R2=R+dR, G2=G+dG, B2=B+dB;
    for (y=0; y<sh; y++, o+=j)
      for (x=0; x<sw; x++, o+=4, i++)
      {
        if ( Bmp[2+o]>=R1 && Bmp[2+o]<=R2
          && Bmp[1+o]>=G1 && Bmp[1+o]<=G2
          && Bmp[o]  >=B1 && Bmp[o]  <=B2 )
            ss[i]='1';
      }
  }
  else if (mode==1)    //灰度阀值模式
  {
    c=(c+1)*128;
    for (y=0; y<sh; y++, o+=j)
      for (x=0; x<sw; x++, o+=4, i++)
        if (Bmp[2+o]*38+Bmp[1+o]*75+Bmp[o]*15<c)
          ss[i]='1';
  }
  else    //mode==2，边缘灰差模式
  {
    for (y=0; y<sh; y++, o+=j)
    {
      for (x=0; x<sw; x++, o+=4, i++)
        gs[i]=(Bmp[2+o]*38+Bmp[1+o]*75+Bmp[o]*15)>>7;
    }
    w=sw-1; h=sh-1;
    for (y=1; y<h; y++)
    {
      for (x=1; x<w; x++)
      {
        i=y*sw+x; j=gs[i]+c;
        if (gs[i-1]>j || gs[i+1]>j
          || gs[i-sw]>j || gs[i+sw]>j)
            ss[i]='1';
      }
    }
  }

  //准备工作二：生成s1、s0查表数组
  for (i=0; i<num; i+=7)
  {
    o=o1=o2=in[i]; w=in[i+1]; h=in[i+2];
    for (y=0; y<h; y++)
    {
      for (x=0; x<w; x++)
      {
        if (wz[o++]=='1')
          s1[o1++]=y*sw+x;
        else
          s0[o2++]=y*sw+x;
      }
    }
  }

  //正式工作：ss中每一点都进行一次全字库匹配
  NextWenzi:
  o1=sy1*sw+sx1;
  for (x=0; x<sw1; x++)
  {
    for (y=0; y<sh1; y++)
    {
      o=y*sw+x+o1;
      for (i=0; i<num; i+=7)
      {
        w=in[i+1]; h=in[i+2];
        if (x+w>sw1 || y+h>sh1)
          continue;
        o2=in[i]; len1=in[i+3]; len0=in[i+4];
        e1=in[i+5]; e0=in[i+6];
        max=len1>len0 ? len1 : len0;
        for (j=0; j<max; j++)
        {
          if (j<len1 && ss[o+s1[o2+j]]!='1' && (--e1)<0)
            goto NoMatch;
          if (j<len0 && ss[o+s0[o2+j]]!='0' && (--e0)<0)
            goto NoMatch;
        }
        //成功找到文字或图像
        if (Ptr==0)
        {
          out[0]=sx+x; out[1]=sy+y;
          out[2]=w; out[3]=h; Ptr=4;
          //找到第一个字就确定后续查找的上下范围和右边范围
          sy1=y-h; sh1=h*3; sw1=h*10+100;
          if (sy1<0)
            sy1=0;
          if (sh1>sh-sy1)
            sh1=sh-sy1;
        }
        else if (x>mode+jiange)  //与前一字间隔较远就添加*号
          out[Ptr++]=-1;
        mode=w-1; out[Ptr++]=i+7;
        if (Ptr>1021)    //返回的int数组中元素个数不超过1024
          goto ReturnOK;
        //清除找到文字，后续查找的左边范围为找到位置的X坐标+1
        for (j=0; j<len1; j++)
          ss[o+s1[o2+j]]='0';
        sx1+=x+1;
        if (sw1>sw-sx1)
          sw1=sw-sx1;
        goto NextWenzi;
        //------------
        NoMatch:
        continue;
      }
    }
  }
  if (Ptr==0)
    return 0;
  ReturnOK:
  out[Ptr]=0;
  return 1;
}

*/


;============ 脚本结束 =================

;