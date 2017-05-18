# AutoHotkey Script [![AutoHotkey](https://img.shields.io/badge/Language-AutoHotkey-yellowgreen.svg)](https://autohotkey.com/) [![License: GPL v3](https://img.shields.io/badge/License-GPL%20v3-blue.svg)](http://www.gnu.org/licenses/gpl-3.0) :cn:

*个人使用的 AutoHotkey 脚本*

## 鼓励

如果这个仓库对你有用，请慷慨点击 _★Star_。你的支持将鼓励我继续分享！

## 目录结构


```
├─_MyScript			主脚本
├─Archive			回收站（待删除）
├─Functions			函数、库
├─其它语言函数or库
├─收集的独立运行脚本
└─辅助工具
```

## 主要脚本

主脚本，都在`_MyScript`目录下

### 1. 印象笔记 编辑器增强

印象笔记的编辑器太简单。该脚本利用HTML代码构造样式，再借助剪贴板，直接把带格式的文字段，粘贴回印象笔记内，扩展其编辑功能。

具体说明，参见：[印象笔记-编辑增强](https://github.com/waldens/AutoHotkey-Script/tree/master/_MyScript/%E5%8D%B0%E8%B1%A1%E7%AC%94%E8%AE%B0%E7%BC%96%E8%BE%91%E5%A2%9E%E5%BC%BA)

相关讨论：
* [[HELP] Enhance Evernote editor by using WinClip](https://autohotkey.com/boards/viewtopic.php?f=5&t=7231)
* [请教一个 关于 Evernote 行距的 AutoHotkey 问题](https://www.v2ex.com/t/225853)

![](http://ww1.sinaimg.cn/large/88e10423gw1erqo6ymzahg20ar08lteh.gif)

### 2. 图片一键上传七牛云.ahk

* 复制 *图片* 到剪贴板后，按下<kbd>Alt</kbd>-<kbd>U</kbd>，一键上传它到七牛云图床，并自动设置剪贴板为其图床地址
* 选中 *GIF动图* 硬盘文件后，按下<kbd>Alt</kbd>-<kbd>O</kbd>，一键上传它到七牛云图床，并自动设置剪贴板为动图的图床地址

Python 脚本修改自：[将图片上传到七牛云存储并直接返回markdown可用的图片链接](https://github.com/mjnhmd/markdown-upload-qiniu)

### 3. 表情包.ahk

在QQ、网页、论坛、Github等地方，插入自定义收藏的表情：
* 按下<kbd>Alt</kbd>-<kbd>B</kbd>后，弹出类似QQ的表情选择框，如下图
* 支持以Markdown、BBCode、HTML格式插入
  * 单纯点击表情，插入BBCode格式
  * 按住<kbd>Shift</kbd>点击表情，插入Markdown格式
  * 按住<kbd>Alt</kbd>点击，插入HTML格式
  * 按住<kbd>Ctrl</kbd>点击，在富文本位置插入图片，例如QQ、Telegram对话框
* 支持表情分组（下图只有一个“最爱”分组）

![](http://onuia4d7l.bkt.clouddn.com/2017_04_23_20170423002936.png)

### 4. 快速启动器.ahk

AutoHotkey做软件启动器时，有一个麻烦。这个函数，试图解决这个麻烦。

具体说明，参见：[appStarter() 快速启动器](https://github.com/waldens/AutoHotkey-Script/tree/master/Functions/appStarter%20%E5%BF%AB%E9%80%9F%E5%90%AF%E5%8A%A8%E5%99%A8)

### 5. 自动保存文件.ahk

编辑U盘内的PDF等文件时，如果忘记保存，而拔下U盘，会导致之前添加的批注等意外丢失。该脚本对指定程序，启用自动保存。

### 6. 结束垃圾进程.ahk

某些常驻的垃圾进程：如搜狗输入法的`SogouCloud.exe`、Spotify的`SpotifyWebHelper.exe`等，自动结束进程。

