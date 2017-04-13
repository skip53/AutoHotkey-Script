#SingleInstance FORCE	;决定当脚本已经运行时是否允许它再次运行,记得用force，这样主脚本reload时，子脚本也自动reload了
SetTitleMatchMode Regex	;更改进程匹配模式为正则
SendMode Input			;所有Send命令，统一采用最快的SendInput

;~ Class A {
	;~ Static x := 1
	;~ y := 2
	;~ __New() {
		;~ This.z := 3 ; there should be a function, there is the Static section for constants
	;~ }
	
	;~ Class sub {
		;~ static subx := 4
		;~ suby := 5
		;~ __New() {
			;~ this.subz := 6
		;~ }
		;~ getParent() {
			;~ return this
		;~ }
	;~ }
;~ }
;~ B := A, C := new A, D := new C.sub
;~ MsgBox, 先看下最基本的类和实例的区别(static的用法)
;~ MsgBox % "B.x=" B.x "`tB.y=" B.y "`tB.z=" B.z "`nC.x=" C.x "`tC.y=" C.y "`tC.z=" C.z

;~ MsgBox, 再看下子类(先是子类static的用法)
;~ MsgBox % "B.sub.subx=" B.sub.subx "`tB.sub.suby=" B.sub.suby "`tB.sub.subz=" B.sub.subz "`nC.sub.subx=" C.sub.subx "`tC.sub.suby=" C.sub.suby  "`tC.sub.subz=" C.sub.subz 
;~ MsgBox, 因为没有实例化子类,所以访问为空

;~ MsgBox, 那样怎么访问子类的实例呢?
;~ MsgBox % "`nC.D.subx=" C.D.subx "`tC.D.suby=" C.D.suby "`tC.D.subz=" C.D.subz "`nD.sub=" D.subx "`tD.suby=" D.suby "`tD.subz=" D.subz
;~ MsgBox, 看到了吧?要直接访问子类,不能有父类前缀. 那要怎么知道子实例的父实例是谁?
;~ MsgBox, % D.getParent()



;~ class funcC {
	;~ Call(obj, str) {
	   ;~ MsgBox % str
	;~ }
;~ }
	;~ called := new funcC
	;~ called1 := called.Bind("", "123")

;~ F1::
	;~ Menu, A, Add, aaaa, %called%
	;~ menu, A, show

IME_GET(WinTitle="A")  {
		ControlGet,hwnd,HWND,,,%WinTitle%
		if  (WinActive(WinTitle))   {
			ptrSize := !A_PtrSize ? 4 : A_PtrSize
			VarSetCapacity(stGTI, cbSize:=4+4+(PtrSize*6)+16, 0)
			NumPut(cbSize, stGTI,  0, "UInt")   ;   DWORD   cbSize;
			hwnd := DllCall("GetGUIThreadInfo", Uint,0, Uint,&stGTI)
					 ? NumGet(stGTI,8+PtrSize,"UInt") : hwnd
		}
		return DllCall("SendMessage"
			, UInt, DllCall("imm32\ImmGetDefaultIMEWnd", Uint,hwnd)
			, UInt, 0x0283  ;Message : WM_IME_CONTROL
			,  Int, 0x0005  ;wParam  : IMC_GETOPENSTATUS
			,  Int, 0)      ;lParam  : 0
	}	
	
	
f1::MsgBox % IME_GET()