#AutoIt3Wrapper_Run_After=del "%scriptfile%_x32.exe"
#AutoIt3Wrapper_Run_After=ren "%out%" "%scriptfile%_x32.exe"
#AutoIt3Wrapper_Run_After=del "%scriptfile%_stripped.au3"
#AutoIt3Wrapper_Run_Au3Stripper=y
#Au3Stripper_Parameters=/PreExpand /StripOnly /RM ;/RenameMinimum
#AutoIt3Wrapper_Compile_both=y
#AutoIt3Wrapper_Res_Description=LWSMTP Server Emulator
#AutoIt3Wrapper_Res_Fileversion=0.3
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

#include-once
#include <GUIConstantsEx.au3>
#include <WindowsConstants.au3>
#include <EditConstants.au3>
#include <ComboConstants.au3>
#include <Constants.au3>

global $simulator_programname="LWSMTP Server Emulator"
global $simulator_programdesc = "An emulator which shows any outgoing SMTP message your local mail clients try to send"
global $simulator_version="0.3"
global $simulator_thedate=@YEAR

if StringRegExp(@ScriptName, "^LWSMTP Server.*[_\.]") then
	simulator()
EndIf

Func simulator($mainwin = Null, $margin_left=default, $margin_top=default)

;AutoItSetOption("TCPTimeout", 100)

global $simulator_iIP = "127.0.0.1", $simulator_iPort
global $simulator_thelimit = '1mb'
local $filename = "message.eml"
OnAutoItExitRegister("_simulator_OnExit")

$simulator_thelimit = simulator_SizeToBytes($simulator_thelimit)

global $simulator_MainWindow
local $self = IsKeyword($mainwin) = $KEYWORD_NULL

if $self then
	$simulator_MainWindow = GUICreate($simulator_programname, 400, 420)
else
	$simulator_MainWindow = GUICreate($simulator_programname, 400, 420, $margin_left, $margin_top, $WS_POPUPWINDOW, $WS_EX_MDICHILD, $mainwin)
EndIf
local $helpmenu = GUICtrlCreateMenu("&Help")
global $simulator_helpitem_about = GUICtrlCreateMenuItem("&About", $helpmenu)
GUICtrlCreateLabel("Proxy Type", 10, 10)
global $simulator_hProxyType = GUICtrlCreateCombo("", 72, 10, 70, 20, BitOr($GUI_SS_DEFAULT_COMBO, $CBS_DROPDOWNLIST))
GUICtrlSetData(-1, "SMTP", "SMTP")
GUICtrlCreateLabel("Listening on", 10, 43)
global $simulator_hIP = GUICtrlCreateInput($simulator_iIP, 72, 40, 80, 20)
global $simulator_hCopyButton_IP = GUICtrlCreateButton("Copy", 154, 37, 50)
GUICtrlCreateLabel("Port", 210, 43)
global $simulator_hPort = GUICtrlCreateCombo("", 233, 40, 50, 20)
GUICtrlSetData(-1, "25|8080", "25")
global $simulator_hCopyButton_Port = GUICtrlCreateButton("Copy", 287, 37, 50)
global $simulator_hEdit = GUICtrlCreateEdit("", 10, 70, 380, 215, BitOR(BitAND($GUI_SS_DEFAULT_EDIT, BitNOT($WS_HSCROLL)), $ES_READONLY))
global $simulator_hHidden = GUICtrlCreateDummy()
global $simulator_hCopyButton = GUICtrlCreateButton("Copy", 10, 295, 80, 30)
global $simulator_hClearButton = GUICtrlCreateButton("Clear", 100, 295, 80, 30)
global $simulator_hSave = GUICtrlCreateButton("Save As", 190, 295, 80, 30)
GUICtrlSetTip(-1, "Save last message")
global $hFile = GUICtrlCreateInput($filename, 275, 300, 100, 20)
global $simulator_hStartButton = GUICtrlCreateButton("Start", 110, 330, 80, 30)
global $simulator_hStopButton = GUICtrlCreateButton("Stop", 210, 330, 80, 30)
GUICtrlSetState($simulator_hStopButton, $GUI_DISABLE)
GUICtrlCreateLabel("Status:", 10, 370)
global $simulator_hStatus = GUICtrlCreateLabel("Stopped", 70, 370, 250, 20)
GUICtrlSetColor($simulator_hStatus, eval("COLOR_BLUE"))
GUISetState()

if $self then
	While 1
		simulator_choices(GUIGetMsg(), True)
	WEnd
EndIf
EndFunc

Func simulator_choices($choice, $exit=False)
    Switch $choice
		Case $GUI_EVENT_CLOSE
			if $exit then
				Exit;Loop
            Else
				GUIDelete($simulator_MainWindow)
			EndIf
        Case $simulator_hProxyType
			local $porter = 0
			if GUICtrlRead($simulator_hProxyType) == "SMTP" and GUICtrlRead($simulator_hPort) <> 25 then
				$porter = 25
			elseif GUICtrlRead($simulator_hProxyType) == "HTTP/S" and GUICtrlRead($simulator_hPort) <> 8080 then
				$porter = 8080
			endif
			if $porter > 0 then
				GUICtrlSetData($simulator_hPort, $porter)
			endif
		Case $simulator_hCopyButton_IP
			simulator_copier($simulator_MainWindow, $simulator_hIP)
        Case $simulator_hCopyButton_Port
			simulator_copier($simulator_MainWindow, $simulator_hPort)
        Case $simulator_hCopyButton
			simulator_copier($simulator_MainWindow, $simulator_hEdit)
		Case $simulator_hClearButton
            GUICtrlSetData($simulator_hEdit, "")
        Case $simulator_hSave
			local $extension = StringSplit(GUICtrlRead($hFile), ".")
			$extension = $extension[UBound($extension)-1]
			local $filesave = FileSaveDialog("Save As", @WorkingDir, "All (*.*)|(*." & $extension & ")", 16, GUICtrlRead($hFile), $simulator_MainWindow)
			if not @error then
				FileWrite(fileopen(GUICtrlRead($hFile), 2), GUICtrlRead($simulator_hHidden))
			EndIf
		Case $simulator_hStartButton
			simulator_start()
		Case $simulator_hStopButton
			simulator_stop()
		Case $simulator_helpitem_about
			simulator_about()
    EndSwitch
EndFunc

Func simulator_start()
    $simulator_iIP = GUICtrlRead($simulator_hIP)
    $simulator_iPort = GUICtrlRead($simulator_hPort)
	TCPStartup()
    global $simulator_iListenSocket = TCPListen($simulator_iIP, $simulator_iPort)
    If @error Then
        GUICtrlSetData($simulator_hStatus, "Error starting the server on " & $simulator_iIP & ":" & $simulator_iPort)
    Else
		AdlibRegister("_simulator_Listen", 10000)
		GUICtrlSetData($simulator_hStatus, "Running")
		GUICtrlSetState($simulator_hStartButton, $GUI_DISABLE)
		GUICtrlSetState($simulator_hProxyType, $GUI_DISABLE)
		GUICtrlSetState($simulator_hIP, $GUI_DISABLE)
		GUICtrlSetState($simulator_hPort, $GUI_DISABLE)
		GUICtrlSetState($simulator_hStopButton, $GUI_ENABLE)
    EndIf
EndFunc

Func simulator_stop()
	_simulator_OnExit()
	GUICtrlSetData($simulator_hStatus, "Stopped")
	GUICtrlSetState($simulator_hStartButton, $GUI_ENABLE)
	GUICtrlSetState($simulator_hProxyType, $GUI_ENABLE)
	GUICtrlSetState($simulator_hIP, $GUI_ENABLE)
	GUICtrlSetState($simulator_hPort, $GUI_ENABLE)
	GUICtrlSetState($simulator_hStopButton, $GUI_DISABLE)
EndFunc

func simulator_copier($mainwin, $field)
	ClipPut(GUICtrlRead($field))
	ControlFocus($mainwin, "", $field)
	GUICtrlSendMsg($field, $EM_SETSEL, 0, -1)
EndFunc

Func _simulator_Listen()
    Local $thesocket=$simulator_iListenSocket, $thetext = $simulator_hEdit, $msg = $simulator_hHidden, $limit = $simulator_thelimit

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

Func simulator_SizeToBytes($sSize)
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

Func _simulator_OnExit()
	AdlibUnRegister("_simulator_Listen")
	If IsDeclared("simulator_iListenSocket") then
		TCPCloseSocket($simulator_iListenSocket)
	EndIf
	TCPShutdown()
EndFunc

Func simulator_about()
  local $programname=$simulator_programname, $programdesc=$simulator_programdesc, $version=$simulator_version, $thedate=$simulator_thedate
  GUICreate("About " & $programname, 435, 410, -1, -1, -1, $WS_EX_MDICHILD, $simulator_MainWindow)
  local $localleft=10
  local $localtop=10
  local $message=$programname & " - Version " & $version & @crlf & _
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
  local $okay=GUICtrlCreateButton("OK", $localleft+160, $localtop+365, 100)

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
