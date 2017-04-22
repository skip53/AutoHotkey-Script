#Include d:\Dropbox\Technical_Backup\AHKScript\Functions\GDI+ standard library\Gdip_All 支持unicode u64等各种版本，最好用这个.ahk
pToken:=GDIP_Startup()
OnExit, Exit
SplashGUI("Some awesome text",5000,"d:\Dropbox\@\收集图\表情包\4尴尬 惭愧 汗\被吓到.jpg")
return

Exit:
GDIP_Shutdown(pToken)
ExitApp

SplashGUI(Text="",Time=0,Image="")
{
Static XPos:=-200,YPos,hwnd1:=0
If (XPos<0)
{
WinGetPos, StartX, StartY, StartW, StartH, ahk_class Shell_TrayWnd
YPos:=StartY-200
XPos:=A_ScreenWidth-200
}
If !hwnd1
{
Gui, SplashGUI: -Caption +E0x80000 +LastFound +AlwaysOnTop +ToolWindow +OwnDialogs
Gui, SplashGUI: Show, NA, % SubStr(A_ScriptName,1,-4)
hwnd1:=WinExist()
}
Gui, SplashGUI:Submit
If !Text
return
hbm := CreateDIBSection(200,200)
hdc := CreateCompatibleDC()
obm := SelectObject(hdc, hbm)
G := Gdip_GraphicsFromHDC(hdc)
Gdip_SetInterpolationMode(G, 7)
Gdip_SetSmoothingMode(G, 4)
;make background
pBrush := Gdip_BrushCreateSolid(0xff79CDCD)
Gdip_FillRectangle(G, pBrush, 0, 160, 200, 40)
;make image
pBitmap := Gdip_CreateBitmapFromFile(Image)
Height:=GDIP_GetImageHeight(pBitmap), Width:=GDIP_GetImageWidth(pBitmap)
Gdip_DrawImage(G,pBitmap,0,0,200,160,0,0,Width,Height)
Gdip_DisposeImage(pBitmap)
;add text
GDIP_TextToGraphics(G,Text,"x5 y165 cffffffff r4 s11 Bold","Arial") ;time text
UpdateLayeredWindow(hwnd1, hdc, XPos, YPos,200,200)
Gui, SplashGUI:Show, NA
;cleanup
SelectObject(hdc, obm)
DeleteObject(hbm)
DeleteDC(hdc)
Gdip_DeleteGraphics(G)
If Time
SetTimer, KillGUI, -%Time%
return

KillGUI:
Gui, SplashGUI:Submit
return
}