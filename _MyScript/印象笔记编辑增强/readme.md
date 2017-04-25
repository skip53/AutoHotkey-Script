## 作用

印象笔记的编辑器，太简单，这个脚本为它增加一些编辑快捷键

## 快捷键

| 快捷键 |  作用 |
|----|-----|
| <kbd>Ctrl</kbd>+<kbd>Space</kbd>  | 简化格式（不再触发输入法切换）|
|<kbd>Alt</kbd>+<kbd>F</kbd>        |  方(F)框环绕、代码块<br>![](http://onuia4d7l.bkt.clouddn.com/2017_04_25_55555.gif)|
|<kbd>Alt</kbd>+<kbd>S</kbd>       |   超(Super)级标题<br>![](http://onuia4d7l.bkt.clouddn.com/2017_04_25_6666.gif)
|<kbd>Alt</kbd>+<kbd>Y</kbd>      |   引(Y)用<br>![](http://onuia4d7l.bkt.clouddn.com/2017_04_25_7777.gif)
|<kbd>Alt</kbd>-1/2/3/4  | 字体 红/蓝/灰/绿 色<br>![](http://onuia4d7l.bkt.clouddn.com/2017_04_25_999.gif)

## 原理

利用 *HTML代码* 构造样式，以 *剪贴板* 为中转，把文字拷贝到剪贴板，增加样式后，再粘贴回去。
重点，不是这些快捷键，而是原理。明了原理后，你可以修改 *HTML代码*，增加更多样式