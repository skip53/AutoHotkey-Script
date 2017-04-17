## 缘起

Windows的启动器，如`ALTRun`、`Claunch`、`Rolan`、`FARR`、`WOX`、`Listary`等，不能保证**两键**以内，启动常用程序。而且启动时，顺便做点附带操作，也不便定制。所以我转用AutoHotkey。

但用AutoHotkey，给常用程序绑定快捷键，又会产生**记忆负担**。一些没到绝对常用地步、但偶尔常用的快捷键，又经常记不住。如果都用易记的首字母，快捷键也不够用。

这个函数，是为了解决这问题。

## 作用

给每个软件，绑定一个**容易记忆**的快捷键。按下该快捷键后：

* 如果只绑定1个软件：直接启动。
* 如果绑定的软件2个以上：弹出小菜单，供选择

## 调用格式

> appStarter(hotkeys, calledString, itemName)

* `hotkeys` ：快捷键
* `calledString` ：启动的程序，**字符串**格式，支持软件 _路径_、_函数_、_标签_。例如

```AutoHotkey
;普通路径
appStarter("#c", "cmd", "cmd")
appStarter("#f", "d:\ProgramFiles\firefox\firefox.exe")
appStarter("#h", "shell:::{645FF040-5081-101B-9F08-00AA002F954E}", "回收站")

;标签
appStarter("#g", "录制gif")
录制gif:
	;your code
	return

;函数
appStarter("#g", "batchPdg")
batchPdg() {
     ;your code
}
```

* `itemName` ：菜单中显示的名称。_可选_ 参数

## Todo

解放鼠标：菜单弹出后，按下1 2 3…快捷启动第一、二、三项…或者，像Ditto那样，再多按一下就往下移动一项

## 地址

[GitHub](https://github.com/waldens/AutoHotkey-Script/tree/master/Functions/appStarter%20%E5%BF%AB%E9%80%9F%E5%90%AF%E5%8A%A8%E5%99%A8)

