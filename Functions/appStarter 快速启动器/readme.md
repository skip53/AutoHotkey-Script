## 缘起

Windows下的常见启动器，如`ALTRun`、`Claunch`、`Rolan`、`FARR`、`WOX`、`Listary`等，都不能保证**两键**以内，启动常用程序。而且启动时顺便做点附带操作，也不方便定制。所以我转用AutoHotkey。

但用AutoHotkey给每个常用程序，绑定启动快捷键，又会产生**记忆负担**。某些没到绝对常用地步、但偶尔常用的启动快捷键，我又记不住。用软件的第一个拼音首字母，又可能冲突，比如GoogleChrome和录制GIF的工具，我第一反应都是Win+G。

这个小函数，是为了解决这问题。

## 作用

给每个软件绑定个**容易记忆**的启动快捷键。按下该快捷键后：

* 如果只绑定一个软件，则直接启动。
* 如果绑定的软件不止一个，则弹出小菜单，供选择

## 调用格式

> appStarter(hotkeys, calledString, itemName)

* `hotkeys` ：快捷键
* `calledString` ：启动的程序，**字符串**格式，支持软件_路径_、_函数_、_标签_。例如

```AutoHotkey
;普通路径
appStarter("#c", "cmd", "cmd")
appStarter("#f", "d:\TechnicalSupport\ProgramFiles\Firefox-pcxFirefox\firefox\firefox.exe")
appStarter("#h", "shell:::{645FF040-5081-101B-9F08-00AA002F954E}", "回收站")

;标签
appStarter("#g", "录制gif")
录制gif:
	;blablabla
	return

;函数
appStarter("#g", "batchPdg")
batchPdg() {
     ;blablabla
}
```

* `itemName` ：菜单中显示的名称。_可选_参数

## Todo

彻底解放鼠标：菜单弹出后，按下1 2 3…快捷启动第一、二、三项…或者，像Ditto那样，再多按一下就往下移动一项

## 地址

[GitHub](https://github.com/waldens/AutoHotkey-Script/tree/master/Functions/appStarter 快速启动器)

