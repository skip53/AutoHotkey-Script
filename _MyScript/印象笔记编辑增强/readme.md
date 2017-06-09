## 鼓励

如果这个工具对你有用，请慷慨点击 _★Star_。你的支持将鼓励我继续分享！

## 作用

印象笔记的编辑器，太简单。这个脚本，为它增加一些快捷键。仅支持Windows，不支持Mac

## 快捷键

| 快捷键 |  作用 | 截图
|----|-----| ----|
|<kbd>Alt</kbd> + <kbd>F</kbd>        |  方(F)框环绕、代码块| ![](https://ooo.0o0.ooo/2017/04/25/58ff5abc37a5b.gif)|
|<kbd>Alt</kbd> + <kbd>S</kbd>       |   超(Super)级标题 | ![](https://ooo.0o0.ooo/2017/04/25/58ff5abcdb470.gif)
|<kbd>Alt</kbd> + <kbd>Y</kbd>      |   引(Y)用 | ![](https://ooo.0o0.ooo/2017/04/25/58ff5abebd25a.gif)
|<kbd>Alt</kbd> + <kbd>F1</kbd> / <kbd>F2</kbd> / <kbd>F3</kbd> / <kbd>F4</kbd>  | 字体 红 / 蓝 / 灰 / 绿 色 （方案一）| ![](https://ooo.0o0.ooo/2017/04/25/58ff5ac69e046.gif)
|<kbd>Win</kbd> + <kbd>1</kbd> / <kbd>2</kbd> / <kbd>3</kbd> / <kbd>4</kbd>  | 字体 红 / 蓝 / 灰 / 绿 色 （方案二）<sup>①</sup>| ![](https://ooo.0o0.ooo/2017/06/09/593aa74f1de6f.gif)
|<kbd>Alt</kbd> + <kbd>1</kbd> / <kbd>2</kbd> / <kbd>3</kbd> / <kbd>4</kbd>  | 黄 / 蓝 / 灰 / 绿 背景色高亮<sup>①</sup> | ![](https://ooo.0o0.ooo/2017/06/09/593aa205ef372.gif)
| <kbd>Ctrl</kbd> + <kbd>Space</kbd>  | 简化格式（不再触发输入法切换）| |
| 双击右键  | 文字高亮 | |

* 方案二和背景色高亮，不可应用于段落，会导致换行失效

## 原理

利用 *HTML代码* 构造样式，以 *剪贴板* 为中转，把文字拷贝到剪贴板，增加样式后，再粘贴回去。

重点，不是这些快捷键，而是原理。明了原理后，你可以修改 *HTML代码*，增加更多你喜欢的样式

