#SingleInstance FORCE	;决定当脚本已经运行时是否允许它再次运行,记得用force，这样主脚本reload时，子脚本也自动reload了
SetTitleMatchMode Regex	;更改进程匹配模式为正则
SendMode Input			;所有Send命令，统一采用最快的SendInput





class FunctionObject {
    __Call(method, args*) {
        if (method = "")
            return this.Call(args*)
        if (IsObject(method))
            return this.Call(method, args*)
    }
}
class FuncArrayType extends FunctionObject {
    Call(obj, params*) {
        ; Call a list of functions.
        Loop % this.Length()
            this[A_Index].Call(params*)
    }
}
; Create an array of functions.
funcArray := new FuncArrayType
; Add some functions to the array (can be done at any point).
funcArray.Push(Func("One"))
funcArray.Push(Func("Two"))
; Create an object which uses the array as a method.
obj := {method: funcArray}
; Call the method.
obj.method("foo", "bar")
   ;~ -> funcArray.call("", "foo", "bar")          ;这两行是我加的注释 演示调用过程
       ;~ -> Func("One").Call("foo", "bar")
One(param1, param2) {
    ListVars
    MsgBox
}
Two(param1, param2) {
    ListVars
    MsgBox
}
