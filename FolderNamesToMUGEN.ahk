#SingleInstance  ignore

; ===== CONFIGURATION =====
backupSelectFile := true
foldersDir = %A_WorkingDir%

;INI does the following:
/*
selectFileDir = D:\Games\MUGEN\mugen\data\mugen1
selectFileName = select.def
selectBackupFileName = select_backup.def

alertSelectContentBefore := false
alertSelectContentAfter := false
alertSelectContentChanges := true
startLine = 16
endLine = 43
*/

; ===== DONT EDIT BELOW =====
SplitPath, A_ScriptName,,,, ScriptName

IfNotExist, %ScriptName%.ini
{
    CreateIni(ScriptName)
}

IniRead, selectFileDir, %ScriptName%.ini, General, SelectFileDir
IniRead, selectFileName, %ScriptName%.ini, General, SelectFileName
IniRead, selectBackupFileName, %ScriptName%.ini, General, SelectBackupFileName

IniRead, alertSelectContentBefore, %ScriptName%.ini, Advanced, AlertSelectContentBefore
IniRead, alertSelectContentAfter, %ScriptName%.ini, Advanced, AlertSelectContentAfter
IniRead, alertSelectContentChanges, %ScriptName%.ini, Advanced, AlertSelectContentChanges
IniRead, startLine, %ScriptName%.ini, Advanced, StartLine
IniRead, endLine, %ScriptName%.ini, Advanced, EndLine

alertSelectContentBefore := %alertSelectContentBefore%
alertSelectContentAfter := %alertSelectContentAfter%
AlertSelectContentChanges := %AlertSelectContentChanges%

backupSelectFile := true
foldersDir = %A_WorkingDir%

selectFilePath = %selectFileDir%\%selectFileName%
selectBackupFilePath = %selectFileDir%\%selectBackupFileName%

if !FileExist(selectFilePath) {
    MsgBox, 0x10, Error Finding File, File does not exist:`n%selectFilePath%`n`nAttempting to use file:`n%A_WorkingDir%\%selectFileName%
    selectFileDir = %A_WorkingDir%
    selectFilePath = %selectFileDir%\%selectFileName%
    selectBackupFilePath = %selectFileDir%\%selectBackupFileName%

    if !FileExist(selectFilePath) {
        MsgBox, 0x10, Error Finding File, File does not exist:`n%selectFilePath% 
        return
    }
}

files := getFolderNames(foldersDir)
if (files.Length() < 1) {
    MsgBox, 0x40, MUGEN %selectFileName% file unchanged, No folder names to add.
    return
}
endLine := Min(endLine, startLine+files.Length()-1)

Loop, Read, %selectFilePath%
{
   totalLines = %A_Index%
}

FileRead, fileContents, %selectFilePath%
if ErrorLevel
{
    MsgBox, 0x10, Error Reading File, Error reading file:`n%selectFilePath% 
    return
}

if (backupSelectFile) {
    FileMove %selectFilePath%, %selectBackupFilePath%, 1
    if ErrorLevel
    {
        MsgBox, 0x10, Error Moving File, Error moving file:`n%selectFilePath%\n\nTo:%selectBackupFilePath%
        return
    }
} else {
    FileDelete, %selectFilePath%
    if ErrorLevel
    {
        MsgBox, 0x10, Error Deleting File, Error deleting file:`n%selectFilePath%
        return
    }
}

i = 1
a = 1
Loop, Parse, fileContents, `n
{
    if (i >= startLine && i <= endLine) {
        newLine = % files[a]
        a++
    } else {
        newLine = %A_loopfield%
    }
    if (i < totalLines) {
        newLine = %newLine%`n
    }
    newFileContents = %newFileContents%%newLine%
    i++
}
fileappend, %newFileContents%, %selectFilePath%

if (alertSelectContentBefore) {
    MsgBox, 0x40, %selectFileName% - Before, %fileContents%
}
if (alertSelectContentAfter || alertSelectContentChanges) {
    oldFileContents = %fileContents%
    FileRead, fileContents, %selectFilePath%

    if (alertSelectContentAfter) {
        MsgBox, 0x40, %selectFileName% - After, %fileContents%
    }

    if (alertSelectContentChanges) {
        oldFileLines := StrSplit(oldFileContents, "`n")
        fileLines := StrSplit(fileContents, "`n")
        i = %startLine%
        changes = 0
        while (i>=startLine && i<= endLine && i<=oldFileLines.Length() && i<=fileLines.Length()) {
            old := oldFileLines[i]
            new := fileLines[i]

            if (old != new) {
                fileChanges = %fileChanges%#%i%: %old% -> %new%`n
                changes++
            }
            i++
        }
        
        if (StrLen(fileChanges) < 1) {
            fileChanges = No new changes were made. Previous file was identical.
        }
        successAlertAppend = `n`nChanges: (%changes%)`n%fileChanges%
    }
}

MsgBox, 0x40, MUGEN %selectFileName% file changed, Successfully added folder names...`n`nFrom:`n%foldersDir%`n`nTo:`n%selectFilePath%%successAlertAppend%

; ===== FUNCTIONS =====

CreateIni(fileName)
{
    FileAppend, 
    (
[General]
SelectFileDir=D:\Games\MUGEN\mugen\data\mugen1
SelectFileName=select.def
SelectBackupFileName=select_backup.def

[Advanced]
AlertSelectContentBefore=false
AlertSelectContentAfter=false
AlertSelectContentChanges=true
StartLine=16
EndLine=43
    ), %fileName%.ini
}

getFolderNames(Directory)
{
	files := []
    Loop, Files, %A_WorkingDir%\*.*, D
	{
		files.Push(A_LoopFileName)
	}
	return files
}

join( strArray, joinString=", " )
{
  s := ""
  for i,v in strArray
    s .= joinString . v
  return substr(s, 3)
}