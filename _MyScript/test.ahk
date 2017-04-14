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

GetProcessMemory_Private(ProcName, Units:="K") {
		Process, Exist, %ProcName%
		pid := Errorlevel
		MsgBox, % pid

		; get process handle
		hProcess := DllCall( "OpenProcess", UInt, 0x10|0x400, Int, false, UInt, pid )

		; get memory info
		PROCESS_MEMORY_COUNTERS_EX := VarSetCapacity(memCounters, 44, 0)
		DllCall( "psapi.dll\GetProcessMemoryInfo", UInt, hProcess, UInt, &memCounters, UInt, PROCESS_MEMORY_COUNTERS_EX )
		DllCall( "CloseHandle", UInt, hProcess )

		SetFormat, Float, 0.0 ; round up K

		PrivateBytes := NumGet(memCounters, 40, "UInt")
		if (Units == "B")
			return PrivateBytes
		if (Units == "K")
			Return PrivateBytes / 1024
		if (Units == "M")
			Return PrivateBytes / 1024 / 1024
	}
	
	GetProcessMemory_All(ProcName) {
		Process, Exist, %ProcName%
		pid := Errorlevel

		; get process handle
		hProcess := DllCall( "OpenProcess", UInt, 0x10|0x400, Int, false, UInt, pid )

		; get memory info
		PROCESS_MEMORY_COUNTERS_EX := VarSetCapacity(memCounters, 44, 0)
		DllCall( "psapi.dll\GetProcessMemoryInfo", UInt, hProcess, UInt, &memCounters, UInt, PROCESS_MEMORY_COUNTERS_EX )
		DllCall( "CloseHandle", UInt, hProcess )

		list := "cb,PageFaultCount,PeakWorkingSetSize,WorkingSetSize,QuotaPeakPagedPoolUsage"
			  . ",QuotaPagedPoolUsage,QuotaPeakNonPagedPoolUsage,QuotaNonPagedPoolUsage"
			  . ",PagefileUsage,PeakPagefileUsage,PrivateUsage"

		n := 0
		Loop, Parse, list, `,
		{
			n += 4
; REMOVED: 			SetFormat, Float, 0.0 ; round up K
			this := A_Loopfield
			this := NumGet( memCounters, (A_Index = 1 ? 0 : n-4), "UInt") / 1024

			; omit cb
			if (A_Index != 1)
				info .= A_Loopfield . ": " . this . " K" . ( A_Loopfield != "" ? "`n" : "" )
		}

		Return "[" . pid . "] " . pname . "`n`n" . info ; for everything
	}
	
	
MsgBox % GetProcessMemory_All("firefox.exe")