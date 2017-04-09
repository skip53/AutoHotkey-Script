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
		getParent() {
			return this
		}
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



;~ x(z) {
	;~ return z
;~ }

;~ y(ByRef bingo) {
	;~ MsgBox, % bingo("111")
;~ }

;~ y(x)



;~ class a {
	;~ x := 1
	;~ class b {
		;~ y := 2
	;~ }
;~ }

;~ instA := new a
;~ MsgBox % instA.x
;~ instB := new instA.b
;~ instB := new a.b
;~ MsgBox % instB.y	;能正常弹出2吗？

class a {
	b() {
		MsgBox, 111
	}
}

x := new a
x.b()
a.b()