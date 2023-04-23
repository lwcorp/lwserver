#AutoIt3Wrapper_Run_After=del "%scriptfile%_x32.exe"
#AutoIt3Wrapper_Run_After=ren "%out%" "%scriptfile%_x32.exe"
#AutoIt3Wrapper_Run_After=del "%scriptfile%_stripped.au3"
#AutoIt3Wrapper_Run_Au3Stripper=y
#Au3Stripper_Parameters=/PreExpand /StripOnly /RM ;/RenameMinimum
#AutoIt3Wrapper_Compile_both=y
#AutoIt3Wrapper_Res_Description=LWSMTP Server Emulator
#AutoIt3Wrapper_Res_Fileversion=0.1
#AutoIt3Wrapper_Res_LegalCopyright=Copyright (C) https://lior.weissbrod.com

#cs
Copyright (C) https://lior.weissbrod.com

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <https://www.gnu.org/licenses/>.

Additional restrictions under GNU GPL version 3 section 7:

In accordance with item 7b), it is required to preserve the reasonable legal notices/author attributions in the material and in the Appropriate Legal Notices displayed by works containing it (including in the footer).
In accordance with item 7c), misrepresentation of the origin of the material must be marked in reasonable ways as different from the original version.
#ce

#include <GUIConstantsEx.au3>
#include <WindowsConstants.au3>
#include <EditConstants.au3>

$programname="LWSMTP Server Emulator"
$programdesc = "An emulator which shows any outgoing SMTP message your local mail clients try to send"
$version="0.1"
$thedate="2023"

TCPStartup()
;AutoItSetOption("TCPTimeout", 100)

Global $iIP = "127.0.0.1"
Global $iPort = 25
Global $iListenSocket = TCPListen($iIP, $iPort)
$limit = '1mb'
$filename = "message.eml"
OnAutoItExitRegister("_OnExit")
AdlibRegister("_Listen", 1000)

If $iListenSocket = -1 Then
    MsgBox(262144, "", "Error listening on port " & $iPort)
    Exit
EndIf

$limit = SizeToBytes($limit)

Global $MainWindow = GUICreate($programname, 400, 320)
$helpmenu = GUICtrlCreateMenu("&Help")
$helpitem_about = GUICtrlCreateMenuItem("&About", $helpmenu)
GUICtrlCreateLabel("Listening on", 10, 13)
$hIP = GUICtrlCreateEdit($iIP, 72, 10, 80, 20, $ES_READONLY)
Global $hCopyButton_IP = GUICtrlCreateButton("Copy", 154, 7, 50)
GUICtrlCreateLabel("Port", 210, 13)
$hPort = GUICtrlCreateEdit($iPort, 233, 10, 40, 20, $ES_READONLY)
Global $hCopyButton_Port = GUICtrlCreateButton("Copy", 277, 7, 50)
Global $hEdit = GUICtrlCreateEdit("", 10, 40, 380, 215, BitOR($ES_READONLY, $WS_VSCROLL))
Global $hHidden = GUICtrlCreateDummy()
Global $hCopyButton = GUICtrlCreateButton("Copy", 10, 260, 80, 30)
Global $hClearButton = GUICtrlCreateButton("Clear", 100, 260, 80, 30)
Global $hSave = GUICtrlCreateButton("Save As", 190, 260, 80, 30)
GUICtrlSetTip(-1, "Save last message")
Global $hFile = GUICtrlCreateEdit($filename, 275, 265, 100, 20, $ES_WANTRETURN)
GUISetState(@SW_SHOW)

While 1
    Switch GUIGetMsg()
        Case $GUI_EVENT_CLOSE
            ExitLoop
        Case $hCopyButton_IP
			copier($hIP)
        Case $hCopyButton_Port
			copier($hPort)
        Case $hCopyButton
			copier($hEdit)
		Case $hClearButton
            GUICtrlSetData($hEdit, "")
        Case $hSave
			local $extension = StringSplit(GUICtrlRead($hFile), ".")
			$extension = $extension[UBound($extension)-1]
			local $filesave = FileSaveDialog("Save As", @WorkingDir, "All (*.*)|(*." & $extension & ")", 16, GUICtrlRead($hFile), $MainWindow)
			if not @error then
				FileWrite(fileopen(GUICtrlRead($hFile), 2), GUICtrlRead($hHidden))
			EndIf
		Case $helpitem_about
			about()
    EndSwitch
WEnd

GUIDelete($MainWindow)
AdlibUnRegister("_Listen")

func copier($field)
	ClipPut(GUICtrlRead($field))
	ControlFocus($MainWindow, "", $field)
	GUICtrlSendMsg($field, $EM_SETSEL, 0, -1)
EndFunc


Func _Listen()
    Local $thesocket=$iListenSocket, $thetext = $hEdit, $msg = $hHidden

	local $iSocket = TCPAccept($thesocket)
    If $iSocket <> -1 Then
        TCPSend($iSocket, "220 Service ready" & @CRLF)
        While 1
            Local $sReceived = TCPRecv($iSocket, $limit)
            If $sReceived <> "" Then
                GUICtrlSetData($thetext, GUICtrlRead($thetext) & "Received: " & $sReceived)
				StringReplace($sReceived, @CRLF, "")
				if @extended>1 then
					GUICtrlSetData($msg, $sReceived)
				EndIf
                If StringInStr($sReceived, "EHLO") Then
                    TCPSend($iSocket, "250-Hello" & @CRLF)
                    TCPSend($iSocket, "250-8BITMIME" & @CRLF)
                    TCPSend($iSocket, "250 SIZE" & @CRLF)
                ElseIf StringInStr($sReceived, "MAIL FROM") Then
                    TCPSend($iSocket, "250 Sender OK" & @CRLF)
                ElseIf StringInStr($sReceived, "RCPT TO") Then
                    TCPSend($iSocket, "250 Recipient OK" & @CRLF)
                ElseIf StringInStr($sReceived, "DATA") Then
                    TCPSend($iSocket, "354 Start mail input; end with <CRLF>.<CRLF>" & @CRLF)
                ElseIf StringInStr($sReceived, @CRLF & "." & @CRLF) Then
                    TCPSend($iSocket, "250 Message accepted for delivery" & @CRLF)
                ElseIf StringInStr($sReceived, "QUIT") Then
                    TCPSend($iSocket, "221 Bye" & @CRLF)
                    ExitLoop
                Else
                    TCPSend($iSocket, "500 Syntax error" & @CRLF)
                EndIf
            elseif @error then
				TCPSend($iSocket, "554 Transaction failed" & @CRLF)
				TCPCloseSocket($iSocket)
				exitloop
			EndIf
            Sleep(100)
        WEnd
    EndIf
EndFunc

Func SizeToBytes($sSize)
    Local $iMultiplier = 1
    $sSize = StringUpper($sSize)
    If StringRight($sSize, 2) == "KB" Then
        $iMultiplier = 1024
        $sSize = StringTrimRight($sSize, 2)
    ElseIf StringRight($sSize, 2) == "MB" Then
        $iMultiplier = 1024 * 1024
        $sSize = StringTrimRight($sSize, 2)
    EndIf
    Return Int($sSize) * $iMultiplier
EndFunc

Func _OnExit()
    TCPCloseSocket($iListenSocket)
    TCPShutdown()
EndFunc

Func about()
  GUICreate("About " & $programname, 435, 410, -1, -1, -1, $WS_EX_MDICHILD, $MainWindow)
  $localleft=10
  $localtop=10
  $message=$programname & " - Version " & $version & @crlf & _
  @crlf & _
  $programdesc & "."
  GUICtrlCreateLabel($message, $localleft, $localtop)
  $message = chr(169) & $thedate & " LWC"
  GUICtrlCreateLabel($message, $localleft, ControlGetPos(GUICtrlGetHandle(-1), "", 0)[3]+18)
  local $aLabel = GUICtrlCreateLabel("https://lior.weissbrod.com", ControlGetPos(GUICtrlGetHandle(-1), "", 0)[2]+10, _
  ControlGetPos(GUICtrlGetHandle(-1), "", 0)[1]+ControlGetPos(GUICtrlGetHandle(-1), "", 0)[3]-$localtop-12)
  GUICtrlSetFont(-1,-1,-1,4)
  GUICtrlSetColor(-1,0x0000cc)
  GUICtrlSetCursor(-1,0)
  $message="    This program is free software: you can redistribute it and/or modify" & _
@crlf & "    it under the terms of the GNU General Public License as published by" & _
@crlf & "    the Free Software Foundation, either version 3 of the License, or" & _
@crlf & "    (at your option) any later version." & _
@crlf & _
@crlf & "    This program is distributed in the hope that it will be useful," & _
@crlf & "    but WITHOUT ANY WARRANTY; without even the implied warranty of" & _
@crlf & "    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the" & _
@crlf & "    GNU General Public License for more details." & _
@crlf & _
@crlf & "    You should have received a copy of the GNU General Public License" & _
@crlf & "    along with this program.  If not, see <https://www.gnu.org/licenses/>." & _
@crlf & @crlf & _
"Additional restrictions under GNU GPL version 3 section 7:" & _
@crlf & @crlf & _
"* In accordance with item 7b), it is required to preserve the reasonable legal notices/author attributions in the material and in the Appropriate Legal Notices displayed by works containing it (including in the footer)." & _
@crlf & @crlf & _
"* In accordance with item 7c), misrepresentation of the origin of the material must be marked in reasonable ways as different from the original version."
  GUICtrlCreateLabel($message, $localleft, $localtop+85, 420, 280)
  $okay=GUICtrlCreateButton("OK", $localleft+160, $localtop+365, 100)

  GUISetState(@SW_SHOW)
  While 1
	$msg=guigetmsg()
	switch $msg
		case $GUI_EVENT_CLOSE, $okay
			guidelete()
			ExitLoop
		case $aLabel
			ShellExecute(GUICtrlRead($msg))
	endswitch
  WEnd
EndFunc