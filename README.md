# AutoHotkey Script

*个人使用的 AutoHotkey 脚本*


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

具体说明，参见：

相关讨论：
* [[HELP] Enhance Evernote editor by using WinClip](https://autohotkey.com/boards/viewtopic.php?f=5&t=7231)
* [请教一个 关于 Evernote 行距的 AutoHotkey 问题](https://www.v2ex.com/t/225853)

![](http://ww1.sinaimg.cn/large/88e10423gw1erqo6ymzahg20ar08lteh.gif)

### 2. 图片 _一键_ 上传七牛云.ahk

剪贴板内的图片，一键上传七牛云图床，并设置剪贴板为图片地址。

Python 脚本修改自：[将图片上传到七牛云存储并直接返回markdown可用的图片链接](https://github.com/mjnhmd/markdown-upload-qiniu)

### 3. 表情包.ahk

快速插入收藏的表情，支持Markdown、BBCode、HTML格式，支持分组
![](http://onuia4d7l.bkt.clouddn.com/2017_04_23_20170423002936.png)

### 4. 快速启动器.ahk

具体说明，参见：[appStarter() 快速启动器](https://github.com/waldens/AutoHotkey-Script/tree/master/Functions/appStarter%20%E5%BF%AB%E9%80%9F%E5%90%AF%E5%8A%A8%E5%99%A8)

### 5. 自动保存文件.ahk

编辑U盘内的PDF等文件时，如果忘记保存，而拔下U盘，会导致之前添加的批注等意外丢失。该脚本对指定程序，启用自动保存。

### 6. 结束垃圾进程.ahk

某些常驻的垃圾进程：如搜狗输入法的`SogouCloud.exe`、Spotify的`SpotifyWebHelper.exe`等，自动结束进程。

## 鼓励

如果这个仓库对你有用，请慷慨点击 _★Star_。你的支持将鼓励我继续分享！