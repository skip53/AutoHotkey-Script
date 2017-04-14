evernoteInsertHTML(str) {
	
}
return

evernoteInsertHTML("<div style='margin: 3px 0px; border-top-width: 2px; border-top-style: solid; border-top-color: rgb(116, 98, 67); font-size: 3px'>　</div><span style='font-size: 12px'>&nbsp;</span>")

;~ commands = ("d:\Dropbox\Technical_Backup\ProgramFiles.Trust\Handle 查看文件夹或文件 被哪个程序占用 而无法删除\handle64.exe" %Clipboard% & echo "直接taskkill /PID来结束进程")
;~ runwait, %comspec% /k %commands%

F1::
	method := 1
	if( method = 1 )
		MsgBox, 111