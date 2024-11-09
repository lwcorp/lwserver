#AutoIt3Wrapper_Run_After=del "%scriptfile%_x32.exe"
#AutoIt3Wrapper_Run_After=ren "%out%" "%scriptfile%_x32.exe"
#AutoIt3Wrapper_Run_After=del "%scriptfile%_stripped.au3"
#AutoIt3Wrapper_Run_Au3Stripper=y
#Au3Stripper_Parameters=/PreExpand /StripOnly /RM ;/RenameMinimum
#AutoIt3Wrapper_Compile_both=y
#AutoIt3Wrapper_Res_Description=LWServer
#AutoIt3Wrapper_Res_Fileversion=1.1
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
#include <WinAPIError.au3> ; for http/s
#include <Inet.au3> ; for _TCPIpToName
#include <Array.au3> ; for MX records

global $simulator_programname="LWServer"
global $simulator_programdesc = "Both a http/s proxy and SMTP server/emulator for sending incoming messages outside." & @crlf & _
"The proxy server allows others to use your device as VPN"
global $simulator_version="1.1"
global $simulator_thedate=@YEAR

if StringRegExp(@ScriptName, "^" & $simulator_programname & ".*[_\.]") then
	simulator()
EndIf

Func simulator($mainwin = Null, $margin_left=default, $margin_top=default, $defaultProxyType = "")

;AutoItSetOption("TCPTimeout", 100)

global $simulator_iIP, $simulator_iPort, $simulator_iPortType, $simulator_iProxyType, $simulator_iEmulate, $simulator_iLog
global $simulator_thelimit = '1mb'
local $filename = "output.log"
OnAutoItExitRegister("_simulator_OnExit")

$simulator_thelimit = simulator_SizeToBytes($simulator_thelimit)

global $simulator_MainWindow
local $self = IsKeyword($mainwin) = $KEYWORD_NULL

if $self then
	$simulator_MainWindow = GUICreate($simulator_programname, 400, 455)
else
	$simulator_MainWindow = GUICreate($simulator_programname, 400, 455, $margin_left, $margin_top, $WS_POPUPWINDOW, $WS_EX_MDICHILD, $mainwin)
EndIf
local $helpmenu = GUICtrlCreateMenu("&Help")
global $simulator_helpitem_about = GUICtrlCreateMenuItem("&About", $helpmenu)
GUICtrlCreateLabel("Proxy Type", 10, 13)
global $simulator_hProxyType = GUICtrlCreateCombo("", 72, 10, 70, 20, BitOr($GUI_SS_DEFAULT_COMBO, $CBS_DROPDOWNLIST))
GUICtrlSetData(-1, "HTTP/S|SMTP", "HTTP/S")
GUICtrlSetTip(-1, "HTTP/S is a VPN service; SMTP emulates accepting outgoing messages")
GUICtrlCreateLabel("Usage", 150, 13)
global $simulator_hUsage = GUICtrlCreateCombo("", 187, 10, 90, default, $CBS_DROPDOWNLIST)
GUICtrlSetData(-1, "Internal|LAN|LAN+Router", "Internal")
GUICtrlSetTip(-1, "If you didn't do it before, note LAN should prompt your OS' Firewall alerts once clicking Start")
global $simulator_hPortType = GUICtrlCreateCombo("", 287, 10, 50, default, $CBS_DROPDOWNLIST)
GUICtrlSetData(-1, "TCP|UDP", "TCP")
GUICtrlCreateLabel("Listening on", 10, 43)
global $simulator_hIP = GUICtrlCreateInput("", 72, 40, 80, 20)
global $simulator_hCopyButton_IP = GUICtrlCreateButton("Copy", 154, 37, 50)
GUICtrlCreateLabel("Port", 210, 43)
global $simulator_hPort = GUICtrlCreateCombo("", 233, 40, 50, 20)
GUICtrlSetData(-1, "8080|25", "8080")
global $simulator_hCopyButton_Port = GUICtrlCreateButton("Copy", 287, 37, 50)
global $simulator_hEdit = GUICtrlCreateEdit("", 10, 70, 380, 215, BitOR(BitAND($GUI_SS_DEFAULT_EDIT, BitNOT($WS_HSCROLL), bitnot($ES_AUTOHSCROLL)), $ES_READONLY, $WS_TABSTOP))
global $simulator_hHidden = GUICtrlCreateDummy()
global $simulator_hCopyButton = GUICtrlCreateButton("Copy", 10, 295, 80, 30)
global $simulator_hClearButton = GUICtrlCreateButton("Clear", 100, 295, 80, 30)
global $simulator_hSave = GUICtrlCreateButton("Save As", 190, 295, 80, 30)
GUICtrlSetTip(-1, "Save last message")
global $hFile = GUICtrlCreateInput($filename, 275, 300, 100, 20)
global $simulator_hEmulate = GUICtrlCreateCheckbox("Just emulate", 10, 327)
GUICtrlSetState(-1, $GUI_CHECKED)
GUICtrlSetTip(-1, "Uncheck to actually try re-routing incoming mail to the real destination")
GUICtrlSetState(-1, $GUI_HIDE)
global $simulator_hLog = GUICtrlCreateCheckbox("Log", 10, 344)
GUICtrlSetState(-1, $GUI_HIDE)
global $simulator_hStartButton = GUICtrlCreateButton("Start", 110, 330, 80, 30)
global $simulator_hStopButton = GUICtrlCreateButton("Stop", 210, 330, 80, 30)
GUICtrlSetState($simulator_hStopButton, $GUI_DISABLE)
GUICtrlCreateLabel("Status:", 10, 363)
global $simulator_hCopyButton_Status = GUICtrlCreateButton("Copy", 10, 376, 34, 19)
global $simulator_hStatus = GUICtrlCreateEdit("Stopped", 70, 363, 300, 46, BitOR(BitAND($GUI_SS_DEFAULT_EDIT, BitNOT($WS_HSCROLL), bitnot($ES_AUTOHSCROLL), bitnot($WS_VSCROLL), bitnot($ES_AUTOVSCROLL)), $ES_READONLY, $WS_TABSTOP), $WS_EX_TRANSPARENT)
GUICtrlSetColor($simulator_hStatus, eval("COLOR_BLUE"))
global $simulator_hStatus_changed = false
GUICtrlCreateLabel("Public IP:", 8, 396)
global $simulator_hExternalIP = GUICtrlCreateInput("Checked on Start", 10, 411, 90, default, BitOR($GUI_SS_DEFAULT_INPUT, $ES_READONLY, $WS_TABSTOP))
global $simulator_hCopyButton_ExternalIP = GUICtrlCreateButton("Copy", 103, 408, 50)
GUISetState()

simulator_choices($simulator_hUsage)
if $defaultProxyType <> "" then
	GUICtrlSetData($simulator_hProxyType, $defaultProxyType)
	simulator_choices($simulator_hProxyType)
	simulator_choices($simulator_hStartButton)
EndIf

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
			local $porter = 0, $output_file = ""
			if GUICtrlRead($simulator_hProxyType) == "SMTP" then
				if GUICtrlRead($simulator_hPort) <> 25 then
					$porter = 25
				EndIf
				if GUICtrlRead($hFile) <> "message.eml" then
					$output_file = "message.eml"
				EndIf
			elseif GUICtrlRead($simulator_hProxyType) == "HTTP/S" then
				if GUICtrlRead($simulator_hPort) <> 8080 then
					$porter = 8080
				endif
				if GUICtrlRead($hFile) <> "output.log" then
					$output_file = "output.log"
				EndIf
			EndIf
			if $porter > 0 then
				GUICtrlSetData($simulator_hPort, $porter)
			endif
			if $output_file <> "" Then
				GUICtrlSetData($hFile, $output_file)
			EndIf
			If BitAND(GUICtrlGetState($simulator_hEmulate), $GUI_SHOW) == $GUI_SHOW Then
				GUICtrlSetState($simulator_hEmulate, $GUI_HIDE)
			else
				GUICtrlSetState($simulator_hEmulate, $GUI_SHOW)
			endif
			If BitAND(GUICtrlGetState($simulator_hLog), $GUI_SHOW) == $GUI_SHOW Then
				GUICtrlSetState($simulator_hLog, $GUI_HIDE)
			else
				GUICtrlSetState($simulator_hLog, $GUI_SHOW)
			endif
		Case $simulator_hUsage
			local $use_ip
			if GUICtrlRead($simulator_hUsage) <> "Internal" then
				$use_ip = "0.0.0.0"
			else
				$use_ip = "127.0.0.1"
			EndIf
			if GUICtrlRead($simulator_hIP) <> $use_ip then
				GUICtrlSetData($simulator_hIP, $use_ip)
			EndIf
		Case $simulator_hCopyButton_IP
			simulator_copier($simulator_MainWindow, $simulator_hIP)
        Case $simulator_hCopyButton_Port
			simulator_copier($simulator_MainWindow, $simulator_hPort)
        Case $simulator_hCopyButton
			simulator_copier($simulator_MainWindow, $simulator_hEdit)
		Case $simulator_hCopyButton_Status
			simulator_copier($simulator_MainWindow, $simulator_hStatus)
		Case $simulator_hCopyButton_ExternalIP
			simulator_copier($simulator_MainWindow, $simulator_hExternalIP)
		Case $simulator_hClearButton
            GUICtrlSetData($simulator_hEdit, "")
        Case $simulator_hSave
			if (GUICtrlRead($simulator_hProxyType) == "SMTP" and GUICtrlRead($simulator_hHidden) == "") or GUICtrlRead($simulator_hEdit) == "" Then
				msgbox($MB_ICONERROR, "Nothing to save", "There's currently nothing to save")
			else
				local $extension = StringSplit(GUICtrlRead($hFile), ".")
				$extension = $extension[UBound($extension)-1]
				local $filesave = FileSaveDialog("Save As", @WorkingDir, "All (*.*)|(*." & $extension & ")", 16, GUICtrlRead($hFile), $simulator_MainWindow)
				if not @error then
					FileWrite(fileopen(GUICtrlRead($hFile), 2), GUICtrlRead((GUICtrlRead($simulator_hProxyType) == "SMTP") ? $simulator_hHidden : $simulator_hEdit))
				EndIf
			EndIf
		Case $simulator_hStartButton
			simulator_start()
		Case $simulator_hStopButton
			simulator_stop()
		Case $simulator_helpitem_about
			simulator_about()
    EndSwitch
EndFunc

func routerport($port, $type, $desc, $ipaddress, $open = true)
	local $invalid_ips = "|0.0.0.0|127.0.0.1|"
	if StringInStr($invalid_ips, $ipaddress)>0 then
		$ipaddress = _GetGateway()[0]
	EndIf
	local $oRouter = ObjCreate( "HNetCfg.NATUPnP")
	local $oPortList = $oRouter.StaticPortMappingCollection

	if isobj($oPortList) Then
		if $open then
			$oPortList.Add($port, $type, $port, $ipaddress, TRUE, $desc)
		Else
			$oPortList.Remove($port, $type)
		EndIf
		if @error then
			MsgBox($MB_ICONERROR, "Error", "Router port management failed with " & @error)
			return false
		EndIf
	else
		MsgBox($MB_ICONERROR, "Error", "Could not create a UPnP object " & @error)
		return false
	endif
	return true
endfunc

Func simulator_start()
    $simulator_iIP = GUICtrlRead($simulator_hIP)
    $simulator_iPort = GUICtrlRead($simulator_hPort)
	$simulator_iPortType = GUICtrlRead($simulator_hPortType)
	$simulator_iProxyType = GUICtrlRead($simulator_hProxyType)
	$simulator_iEmulate = $simulator_hEmulate
	$simulator_iLog = $simulator_hLog
	If BitAND(GUICtrlGetState($simulator_iEmulate), $GUI_SHOW) == $GUI_SHOW and GUICtrlRead($simulator_iEmulate) == $GUI_CHECKED Then
		$simulator_iEmulate = true
	else
		$simulator_iEmulate = false
	EndIf
	If BitAND(GUICtrlGetState($simulator_iLog), $GUI_SHOW) == $GUI_SHOW and GUICtrlRead($simulator_iLog) == $GUI_CHECKED Then
		$simulator_iLog = true
	else
		$simulator_iLog = false
	EndIf
	if GUICtrlRead($simulator_hUsage) == "LAN+Router" then
		local $router_chosen
		if routerport($simulator_iPort, $simulator_iPortType, $simulator_iProxyType, $simulator_iIP) then
			global $router = true
		EndIf
	EndIf
	TCPStartup()
    global $simulator_iListenSocket = ($simulator_iPortType == "TCP") ? TCPListen($simulator_iIP, $simulator_iPort) : ""
    If @error Then
        _UpdateStatus("Error starting the server on " & $simulator_iIP & ":" & $simulator_iPort)
    Else
		AdlibRegister("_simulator_Listen", 1000)
		_UpdateStatus("Running")
		local $externalIPField = GUICtrlRead($simulator_hExternalIP)
		if IsDeclared("router_chosen") Then
			local $ipaddress = _GetIP()
			if $externalIPField <> $ipaddress then
				GUICtrlSetData($simulator_hExternalIP, $ipaddress)
			EndIf
		else
			local $externalIPFieldNote = "Not using Router"
			if $externalIPField <> $externalIPFieldNote then
				GUICtrlSetData($simulator_hExternalIP, $externalIPFieldNote)
			EndIf
		endif
		GUICtrlSetState($simulator_hStartButton, $GUI_DISABLE)
		GUICtrlSetState($simulator_hProxyType, $GUI_DISABLE)
		GUICtrlSetState($simulator_hUsage, $GUI_DISABLE)
		GUICtrlSetState($simulator_hPortType, $GUI_DISABLE)
		GUICtrlSetState($simulator_hIP, $GUI_DISABLE)
		GUICtrlSetState($simulator_hPort, $GUI_DISABLE)
		GUICtrlSetState($simulator_hEmulate, $GUI_DISABLE)
		GUICtrlSetState($simulator_hLog, $GUI_DISABLE)
		GUICtrlSetState($simulator_hStopButton, $GUI_ENABLE)
    EndIf
EndFunc

Func simulator_stop()
	_simulator_OnExit()
	_UpdateStatus("Stopped")
	GUICtrlSetData($simulator_hExternalIP, "Checked on Start")
	GUICtrlSetState($simulator_hStartButton, $GUI_ENABLE)
	GUICtrlSetState($simulator_hProxyType, $GUI_ENABLE)
	GUICtrlSetState($simulator_hUsage, $GUI_ENABLE)
	GUICtrlSetState($simulator_hPortType, $GUI_ENABLE)
	GUICtrlSetState($simulator_hIP, $GUI_ENABLE)
	GUICtrlSetState($simulator_hPort, $GUI_ENABLE)
	GUICtrlSetState($simulator_hEmulate, $GUI_ENABLE)
	GUICtrlSetState($simulator_hLog, $GUI_ENABLE)
	GUICtrlSetState($simulator_hStopButton, $GUI_DISABLE)
EndFunc

func simulator_copier($mainwin, $field)
	ClipPut(GUICtrlRead($field))
	ControlFocus($mainwin, "", $field)
	GUICtrlSendMsg($field, $EM_SETSEL, 0, -1)
EndFunc

Func _simulator_Listen()
    Local $thesocket=$simulator_iListenSocket, $thetext = $simulator_hEdit, $msg = $simulator_hHidden, $limit = $simulator_thelimit, $sReceived

	local $iSocket = ($simulator_iPortType == "TCP") ? TCPAccept($thesocket) : UDPBind($simulator_iIP, $simulator_iPort)
	if @error then
		_CloseConnection("client", $iSocket, @error & " " & _WinAPI_GetErrorMessage(@error))
	EndIf

	If ($simulator_iPortType == "TCP" and $iSocket <> -1) or $simulator_iPortType <> "TCP" then
		if GUICtrlRead($simulator_hProxyType) == "SMTP" then
			TCPorUDPSend($iSocket, "220 Service ready" & @CRLF)
			Local $sFromAddress, $sToAddress, $aBody
			While 1
				$sReceived = TCPorUDPRecv($iSocket, $limit)
				if $simulator_iPortType <> "TCP" and $sReceived == ("220 Service ready" & @CRLF) Then
					$sReceived = ""
				endif
				If $sReceived <> "" Then
					_Monitor("Received: " & $sReceived)
					StringReplace($sReceived, @CRLF, ""); Returns the number of replacements performed stored in the @extended macro.
					if @extended>1 then
						GUICtrlSetData($msg, StringRegExpReplace(StringTrimRight($sReceived, stringlen(@CRLF & "." & @CRLF)), "(?m)^\.{2}", "."))
					EndIf
					If StringInStr($sReceived, "EHLO") Then
						TCPorUDPSend($iSocket, "250-Hello" & @CRLF)
						TCPorUDPSend($iSocket, "250-8BITMIME" & @CRLF)
						TCPorUDPSend($iSocket, "250 SIZE" & @CRLF)
					ElseIf StringInStr($sReceived, "MAIL FROM") Then
						$sFromAddress = StringRegExp($sReceived, "<(.*?)>", 1)[0]
						TCPorUDPSend($iSocket, "250 Sender OK" & @CRLF)
					ElseIf StringInStr($sReceived, "RCPT TO") Then
						$sToAddress = StringRegExp($sReceived, "<(.*?)>", 1)[0]
						TCPorUDPSend($iSocket, "250 Recipient OK" & @CRLF)
					ElseIf StringInStr($sReceived, "DATA") Then
						TCPorUDPSend($iSocket, "354 Start mail input; end with <CRLF>.<CRLF>" & @CRLF)
					ElseIf StringInStr($sReceived, @CRLF & "." & @CRLF) Then
						$aBody = $sReceived
						TCPorUDPSend($iSocket, "250 Message accepted for delivery" & @CRLF)
					ElseIf StringInStr($sReceived, "QUIT") Then
						TCPorUDPSend($iSocket, "221 Bye" & @CRLF)
						local $sRecipientDomain, $DNSRecords, $DNSRecord, $smtpSocket, $response, $bMailSent, $bMailSent = false, $failed = ""
						if $sFromAddress = "" then
							$failed = "empty From Address"
						else
							if $sToAddress = "" then
								$failed = "empty To Address"
							else
								$sRecipientDomain = StringSplit($sToAddress, "@", 2)[1]
								if $sRecipientDomain = "" then
									$failed = "empty server in " & $sToAddress
								EndIf
							EndIf
						endif
						if $failed <> "" then
							_UpdateStatus(($simulator_iEmulate ? "W" : "C") & "ouldn't send message due to " & $failed)
						else
							$DNSRecords = DNSRecords($sRecipientDomain)
							if not IsArray($DNSRecords) Then
								_UpdateStatus(($simulator_iEmulate ? "W" : "C") & "ouldn't send message because " & $sRecipientDomain & " has neither MX nor A records")
								ExitLoop
							endif
							For $i = 1 To $DNSRecords[0][0]
								$DNSRecord = $DNSRecords[$i][0]
								if $simulator_iEmulate then
									_UpdateStatus("Would have tried to send the message to" & @CRLF & $DNSRecord)
									$bMailSent = true
									ExitLoop
								EndIf
								$smtpSocket = TCPConnect($DNSRecords[0][1] == "A" ? $DNSRecord : TCPNameToIP($DNSRecord), 25)
								If @error Then
									if $simulator_iLog then
										_Monitor("Failed to connect to MX server " & $DNSRecord & " with error " & @error & " " & _WinAPI_GetErrorMessage(@error))
									EndIf
									ContinueLoop
								EndIf
								_UpdateStatus(sendStatus($smtpSocket, $limit, $DNSRecord))
								sendStatus($smtpSocket, $limit, $DNSRecord, "EHLO " & @ComputerName)
								sendStatus($smtpSocket, $limit, $DNSRecord, "MAIL FROM:<" & $sFromAddress & ">")
								sendStatus($smtpSocket, $limit, $DNSRecord, "RCPT TO:<" & $sToAddress & ">")
								sendStatus($smtpSocket, $limit, $DNSRecord, "DATA")
								$response = sendStatus($smtpSocket, $limit, $DNSRecord, $aBody)
								If StringInStr($response, "250") Then
									$bMailSent = True
								EndIf
								$response = sendStatus($smtpSocket, $limit, $DNSRecord, "QUIT")
								TCPCloseSocket($smtpSocket)
								If StringInStr($response, "550") Then
									$bMailSent = False
									$failed = $response
									ExitLoop
								EndIf
								If $bMailSent Then
									_UpdateStatus("Message sent succesfully to " & $DNSRecord)
									ExitLoop
								EndIf
							next
							If not $bMailSent Then
								_UpdateStatus(($failed == "") ? ("Message failed to get sent to " & $DNSRecord) : $failed)
							EndIf
						EndIf
						ExitLoop
					Elseif $simulator_iPortType == "TCP" then
						TCPorUDPSend($iSocket, "500 Syntax error" & @CRLF)
					else
						UDPCloseSocket($iSocket)
					EndIf
				elseif @error then
					TCPorUDPSend($iSocket, "554 Transaction failed" & @CRLF)
					_CloseConnection("client", $iSocket, "554 Transaction failed")
					exitloop
				elseif $simulator_iPortType <> "TCP" then
					UDPCloseSocket($iSocket)
					exitloop
				EndIf
			WEnd
		elseif GUICtrlRead($simulator_hProxyType) == "HTTP/S" then
			if $simulator_iPortType == "TCP" then
				local $client_address = SocketToIP($iSocket)
				if $client_address == 0 then
					$client_address = "Uknown"
				else
					$client_address &= " (" & _TCPIpToName($client_address) & ")"
				EndIf
				_Monitor("New client connection from: " & $client_address)
			EndIf
			$sReceived = TCPorUDPRecv($iSocket, $limit)
			If $sReceived = "" Then
				if $simulator_iPortType == "TCP" Then
					_CloseConnection("client", $iSocket, "client returning error or empty data")
				Else
					UDPCloseSocket($iSocket)
				EndIf
			elseif not @error then
				if $simulator_iPortType <> "TCP" then
					_Monitor("New client connection from: " & $iSocket[2])
				EndIf
				_Monitor("Received from client: " & @CRLF & $sReceived)
				_ProcessRequest($iSocket, $sReceived)
			EndIf
		EndIf
	EndIf
EndFunc

func sendStatus($smtpSocket, $limit, $sMxServer, $str = "")
	local $log = $simulator_iLog
	if $str == "" then
		if $log Then _Monitor("Connected to MX Server " & $sMxServer)
	else
		TCPSend($smtpSocket, $str & @CRLF)
		if $log Then _Monitor("Sent: " & $str)
	EndIf
	local $response = TCPRecv($smtpSocket, $limit)
	if $log then
		_Monitor("Received: " & $response)
	endif
	return $response
EndFunc

Func _ProcessRequest($iClientSocket, $sRequest)
    Local $aRequestLines = StringSplit($sRequest, @CRLF, 1)
    Local $sRequestLine = $aRequestLines[1]
    Local $aRequestParts = StringSplit($sRequestLine, " ")
    If $aRequestParts[0] < 3 Then
        _CloseConnection("client", $iClientSocket, "not enough spaces in request")
        Return
    EndIf

    Local $sMethod = $aRequestParts[1]
    Local $sURL = $aRequestParts[2]

    ; Handle CONNECT method for HTTPS requests
    If $sMethod = "CONNECT" Then
        _HandleHTTPSConnect($iClientSocket, $sURL) ; should resemble CONNECT example.com:443 HTTP/1.1
    Else
        _HandleHTTPRequest($iClientSocket, $sURL, $sRequest) ; should resemble GET http://example.com/index.html HTTP/1.1
    EndIf
EndFunc

Func _HandleHTTPSConnect($iClientSocket, $sURL)
    Local $aHostPort = StringSplit($sURL, ":")
    If $aHostPort[0] <> 2 Then
        _CloseConnection("client", $iClientSocket, "invalid HTTPS URL")
        Return
    EndIf

    Local $sHost = $aHostPort[1]
    Local $iPort = Number($aHostPort[2])
    Local $sIP = TCPNameToIP($sHost)

    ; Connect to the target server for HTTPS
    Local $iServerSocket = TCPConnect($sIP, $iPort)
    If @error Then
        _CloseConnection("client", $iClientSocket, "server connection error for HTTPS")
        Return
    EndIf

    ; Send 200 Connection Established to client
    Local $sResponse = "HTTP/1.1 200 Connection Established" & @CRLF & @CRLF
    TCPorUDPSend($iClientSocket, $sResponse)

    ; Log the response sent to client
    _Monitor("Sent to client: " & $sResponse)

    ; Relay encrypted data
    _RelayData("https", $iClientSocket, $iServerSocket)
EndFunc

Func _HandleHTTPRequest($iClientSocket, $sURL, $sRequest)
    Local $sHost = "", $iPort = 80, $sPath = "/"

    ; Parse the URL from the request
    If Not _ParseURL($sURL, $sHost, $iPort, $sPath) Then
        _CloseConnection("client", $iClientSocket, "URL parsing error in " & $sURL)
        Return
    EndIf

    ; Split the URL to remove the scheme
    Local $aURLParts = StringSplit($sURL, "://", 1)
    Local $sURLWithoutScheme = "/" & StringSplit($aURLParts[2], $sPath, 1)[2] ; Extract the part without the scheme and host

    ; Replace the full URL (without the scheme) in the original request with the path ($sPath)
    $sRequest = StringReplace($sRequest, $sURL, $sURLWithoutScheme, 1)

    ; Connect to the target server
    Local $sIP = TCPNameToIP($sHost)
    Local $iServerSocket = TCPConnect($sIP, $iPort)
    If @error Then
        _CloseConnection("client", $iClientSocket, "server " & $sHost & Chr(32) & $sIP & ":" & $iPort & " returning error " & @error & ": " & _WinAPI_GetErrorMessage(@error))
        Return
    EndIf

    ; Send the modified request to the server
    TCPSend($iServerSocket, $sRequest)
    _Monitor("Sent to server: " & @CRLF & $sRequest)

    ; Relay data between client and server
    _RelayData("http", $iClientSocket, $iServerSocket)
EndFunc

Func _RelayData($which, $iClientSocket, $iServerSocket)
	Local $limit = $simulator_thelimit
    Local $iEmptyDataCount = 0 ; Counter for empty data received
    Local $iLimitDataCount = 10
	local $encrypted = ""
	if StringRight($which, 1) == "s" then
		$encrypted = "(encrypted)"
	EndIf

    While True
        ; Relay data from client to server
        Local $sClientData = TCPorUDPRecv($iClientSocket, $limit)
        If @error Then
            _Monitor("Client error while receiving data. Error: " & @error & " - " & _WinAPI_GetErrorMessage(@error))
            ExitLoop ; Exit on client error
        ElseIf $sClientData = "" Then
            $iEmptyDataCount += 1
            If $iEmptyDataCount >= $iLimitDataCount Then
                _Monitor("Client disconnected (received empty data " & $iLimitDataCount & " times).")
                ExitLoop ; Exit after receiving empty data multiple times
            EndIf
        Else
            _Monitor("Relaying data from client to server: " & (($encrypted<>"") ? $encrypted : $sClientData))
            TCPSend($iServerSocket, $sClientData)
            $iEmptyDataCount = 0 ; Reset count on valid data
        EndIf

        ; Relay data from server to client
        Local $sServerData = TCPRecv($iServerSocket, $limit)
        If @error Then
            _Monitor("Server error while receiving data. Error: " & @error & " - " & _WinAPI_GetErrorMessage(@error))
            ExitLoop ; Exit on server error
        ElseIf $sServerData = "" Then
            $iEmptyDataCount += 1
            If $iEmptyDataCount >= $iLimitDataCount Then
                _Monitor("Server disconnected (received empty data " & $iLimitDataCount & " times).")
                ExitLoop ; Exit after receiving empty data multiple times
            EndIf
        Else
            _Monitor("Relaying data from server to client: " & (($encrypted<>"") ? $encrypted : $sServerData))
            TCPOrUDPSend($iClientSocket, $sServerData)
            $iEmptyDataCount = 0 ; Reset count on valid data
        EndIf
    WEnd

    ; Close the connection when done
    _CloseConnection("client", $iClientSocket, "Relay complete")
	_CloseConnection("server", $iServerSocket, "Relay complete")
EndFunc

Func _ParseURL($sURL, ByRef $sHost, ByRef $iPort, ByRef $sPath)
    $sHost = ""
    $iPort = 80
    $sPath = "/"

    If StringInStr($sURL, "://") Then
        Local $aURLParts = StringSplit($sURL, "://")
        If $aURLParts[0] < 2 Then Return False
        $sURL = $aURLParts[2]
    EndIf

    Local $iPos = StringInStr($sURL, "/")
    If $iPos > 0 Then
        $sHost = StringLeft($sURL, $iPos - 1)
        $sPath = StringMid($sURL, $iPos)
    Else
        $sHost = $sURL
    EndIf

    If StringInStr($sHost, ":") Then
        Local $aHostParts = StringSplit($sHost, ":")
        If $aHostParts[0] < 2 Then Return False
        $sHost = $aHostParts[1]
        $iPort = Number($aHostParts[2])
    EndIf

    Return True
EndFunc

Func SocketToIP($iSocket)
        Local $tSockAddr = 0, $aRet = 0
        $tSockAddr = DllStructCreate("short;ushort;uint;char[8]")
        $aRet = DllCall("Ws2_32.dll", "int", "getpeername", "int", $iSocket, "struct*", $tSockAddr, "int*", DllStructGetSize($tSockAddr))
        If Not @error And $aRet[0] = 0 Then
                $aRet = DllCall("Ws2_32.dll", "str", "inet_ntoa", "int", DllStructGetData($tSockAddr, 3))
                If Not @error Then Return $aRet[0]
        EndIf
        Return 0
EndFunc   ;==>SocketToIP

Func _Monitor($sText, $log = true)
    If StringRight($sText, StringLen(@CRLF & @CRLF)) = @CRLF & @CRLF Then
        $sText = StringTrimRight($sText, StringLen(@CRLF))
    EndIf
    If StringRight($sText, StringLen(@CRLF)) <> @CRLF Then
        $sText &= @CRLF
    EndIf
    GUICtrlSetData($simulator_hEdit, GUICtrlRead($simulator_hEdit) & ($log ? (@HOUR & ":" & @MIN & ":" & @SEC & chr(32)) : "") & $sText)
EndFunc

Func _CloseConnection($which, $iSocket, $sReason)
    _Monitor("Closing " & $which & " connection: " & $sReason)
    if $simulator_iPortType == "TCP" then
		TCPCloseSocket($iSocket)
	else
		UDPCloseSocket($iSocket)
	EndIf
EndFunc

Func _UpdateStatus($sText)
	if StringLen($sText) > 100 then
		$simulator_hStatus_changed = true
		GUICtrlSetFont($simulator_hStatus, 6.75)
	elseif $simulator_hStatus_changed then
		$simulator_hStatus_changed = false
		GUICtrlSetFont($simulator_hStatus, Default)
	endif
    GUICtrlSetData($simulator_hStatus, $sText)
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

func TCPorUDPSend($iSocket, $msg)
	local $output
	$output = ($simulator_iPortType == "TCP") ? TCPSend($iSocket, $msg) : UDPSend($iSocket, $msg)
	if $simulator_iLog Then
		_Monitor("Sent: " & $msg)
	EndIf
	return $output
EndFunc

func TCPorUDPRecv($iSocket, $limit)
	return ($simulator_iPortType == "TCP") ? TCPRecv($iSocket, $limit) : UDPRecv($iSocket, $limit)
EndFunc

Func DNSRecords($domain, $DNSRecord = "MX-A-AAAA") ; Can be MX, A or SRV but also X-Z, X-Y-Z, etc. (X record, but if fails try Y instead)
    Local $DNSRecords = StringSplit($DNSRecord, "-"), $binary_data
	Local $loc_serv = _GetGateway(), $loc_serv_final = ""
	If IsArray($loc_serv) Then
		if StringSplit($loc_serv[1], ".", 2)[0] <> "192" Then ; this kind of server is not what we want
			$loc_serv_final = $loc_serv[1]
		EndIf
	EndIf
	UDPStartup()
	for $i = 1 to $DNSRecords[0]
		$DNSRecord = $DNSRecords[$i]
		$binary_data = DNSQueryServer($domain, $DNSRecord, $loc_serv_final)
		if $binary_data <> -1 Then
			ExitLoop
		EndIf
	Next
	UDPShutdown()
	If $binary_data == -1 then
		Return -1
	EndIf

    Local $output
	switch $DNSRecord
		case "MX"
			$output = ExtractMXServerData($binary_data)
		case "A"
			$output = _DNS_ExtractAData($binary_data, $DNSRecord)
		case "AAAA"
			$output = _DNS_ExtractAData($binary_data, $DNSRecord)
		case "SRV"
			$output = ExtractSRVServerData($binary_data)
		case Else
			Return -1
	EndSwitch
    If @error Then Return -1
    if IsArray($output) then
		local $lastCol = ubound($output, 2)-1
		if $output[1][$lastCol] <> "" then
			_ArraySort($output, default, 1, default, $lastCol - ($DNSRecord == "SRV" ? 1 : 0))
			if $DNSRecord == "SRV" then
				Local $iStart = -1
				For $iX = 1 To $output[0][0]
					If $output[$iX][$lastCol-1] = $output[$iX - 1][$lastCol-1] And $iStart = -1 Then
						$iStart = $iX - 1
					ElseIf $output[$iX][$lastCol-1] <> $output[$iX - 1][$lastCol-1] And $iStart <> -1 Then
						_ArraySort($output, 1, $iStart, $iX - 1, $lastCol)
						$iStart = -1
					EndIf
				Next
				If $iStart <> -1 Then
					_ArraySort($output, 1, $iStart, $iX - 1, $lastCol)
				EndIf
			EndIf
		EndIf
	EndIf

    Return $output
EndFunc   ;==>DNSRecords

Func DNSQueryServer($domain, $DNSRecord, $loc_serv)
    Local $domain_array
    $domain_array = StringSplit($domain, ".", 1)

    Local $binarydom
    For $el = 1 To $domain_array[0]
        $binarydom &= Hex(BinaryLen($domain_array[$el]), 2) & Hex(Binary($domain_array[$el]))
    Next
    $binarydom_suffix = "00" ; for example, 'gmail.com' will be '05676D61696C03636F6D00' and 'autoit.com' will be '066175746F697403636F6D00'

    Local $identifier = Hex(Random(0, 1000, 1), 2) ; random hex number serving as a handle for the data that will be received
    Local $server_bin = "0x00" & $identifier & "01000001000000000000" & $binarydom & $binarydom_suffix ; this is our query
	switch $DNSRecord
		case "MX"
			$server_bin &= "000F0001"
		case "A"
			$server_bin &= "00010001"
		case "AAAA"
			$server_bin &= "001C0001"
		case "SRV"
			$server_bin &= "00210001"
		case else
			Return -1
	EndSwitch
    Local $num_time, $data

    For $num_time = 1 To 10
        Local $query_server ; ten(10) DNS servers, we'll start with one that is our's default, if no response or local one switch to public free servers
        Switch $num_time
			Case 1
				$query_server = $loc_serv
            Case 2
                $query_server = "4.2.2.1"
            Case 3
                $query_server = "67.138.54.100"
            Case 4
                $query_server = "208.67.222.222"
            Case 5
                $query_server = "4.2.2.2"
            Case 6
                $query_server = "4.2.2.3"
            Case 7
                $query_server = "208.67.220.220"
            Case 8
                $query_server = "4.2.2.4"
            Case 9
                $query_server = "4.2.2.5"
            Case 10
                $query_server = "4.2.2.6"
        EndSwitch

        If $query_server <> "" Then
            Local $sock
            $sock = UDPOpen($query_server, 53)
            If @error Or $sock = -1 Then ; ok, that happens
                UDPCloseSocket($sock)
                ContinueLoop ; change server and try again
            EndIf

            UDPSend($sock, $server_bin) ; sending query

            Local $tik = 0
            Do
                $data = UDPRecv($sock, 512)
                $tik += 1
                Sleep(100)
            Until $data <> "" Or $tik = 8 ; waiting reasonable time for the response

            If $data And Hex(BinaryMid($data, 2, 1)) = $identifier Then
                Return $data ; if there is data for us, return
            EndIf
        EndIf
    Next

    Return -1
EndFunc   ;==>DNSQueryServer

Func ExtractMXServerData($binary_data)
    Local $num_answ = Dec(StringMid($binary_data, 15, 4)) ; representing number of answers provided by the server
    Local $arr = StringSplit($binary_data, "C00C000F0001", 1) ; splitting input; "C00C000F0001" - translated to human: "this is the answer for your MX query"

    If $num_answ <> $arr[0] - 1 Or $num_answ = 0 Then Return -1 ; dealing with possible options

    Local $pref[$arr[0]] ; preference number(s)
    Local $server[$arr[0]] ; server name(s)
    Local $output[1][2] = [[$arr[0] - 1, "MX"]]
    ; this goes out containing both server names and coresponding preference numbers

    Local $offset = 10 ; initial offset

    For $i = 2 To $arr[0]
        $arr[$i] = "0x" & $arr[$i] ; well, it is binary data
        $pref[$i - 1] = Dec(StringRight(BinaryMid($arr[$i], 7, 2), 4))
        $offset += BinaryLen($arr[$i - 1]) + 6 ; adding length of every past part plus length of that "C00C000F0001" used for splitting
        Local $array = ReadBinary($binary_data, $offset) ; extraction of server names starts here
        While $array[1] = 192 ; dealing with special case
            $array = ReadBinary($binary_data, $array[6] + 2)
        WEnd

        $server[$i - 1] &= $array[2] & "."
        While $array[3] <> 0 ; the end will obviously be at $array[3] = 0
            If $array[3] = 192 Then
                $array = ReadBinary($array[0], $array[4] + 2)
                If $array[3] = 0 Then
                    $server[$i - 1] &= $array[2]
                    ExitLoop
                Else
                    $server[$i - 1] &= $array[2] & "."
                EndIf
            Else
                $array = ReadBinary($array[0], $array[5])
                If $array[3] = 0 Then
                    $server[$i - 1] &= $array[2]
                    ExitLoop
                Else
                    $server[$i - 1] &= $array[2] & "."
                EndIf
            EndIf
        WEnd
        _ArrayAdd($output, $server[$i - 1])
        $output[ubound($output)-1][1] = $pref[$i - 1]
    Next

    Return $output ; two-dimensional array
EndFunc   ;==>ExtractMXServerData

Func _DNS_ExtractAData($bBinary, $DNSRecord)
    Local $aAnswers = StringSplit($bBinary, "C00C" & (($DNSRecord == "A") ? "0001" : "001C") & "0001", 1)
    If UBound($aAnswers) > 1 Then
		Local $ipLen = ($DNSRecord == "A") ? 4 : 16
        Local $bData = BinaryMid($bBinary, 6 + BinaryLen($aAnswers[1]) + 6)
        Local $tARaw = DllStructCreate("byte[" & BinaryLen($bData) & "]")
        DllStructSetData($tARaw, 1, $bData)
        Local $tAData = DllStructCreate("byte DataLength; byte IP[" & $ipLen & "];", DllStructGetPtr($tARaw))
		Local $ip[0]
        For $i = 1 To $ipLen Step ($DNSRecord == "A") ? 1 : 2
			_ArrayAdd($ip, ($DNSRecord == "A") ? DllStructGetData($tAData, "IP", $i) : Hex(DllStructGetData($tAData, "IP", $i) * 256 + DllStructGetData($tAData, "IP", $i + 1), 4))
		Next
		$ip = ($DNSRecord == "A") ? _ArrayToString($ip, ".") : CompressIPv6(_ArrayToString($ip, ":"))
		Local $output[2][2] = [[1, $DNSRecord], [$ip]]
		Return $output
    EndIf
    Return SetError(1, 0, "")
EndFunc   ;==>_DNS_ExtractAData

Func CompressIPv6($ip)
    ; Step 1: Remove leading zeros in each segment; replace '0000' with '0' if necessary
    Local $output = ""
    Local $segments = StringSplit($ip, ":", 2)
    For $i = 0 To UBound($segments) - 1
        $output &= ($i > 0 ? ":" : "") & (StringRegExpReplace($segments[$i], "\b0+", "") ? StringRegExpReplace($segments[$i], "\b0+", "") : "0")
    Next

    ; Step 2: Find all occurrences of continuous '0' segments
    Local $zeros = StringRegExp($output, "\b:?(?:0+:?){2,}", 3)
    Local $max = ""

    ; Step 3: Identify the longest occurrence of consecutive '0' segments
    For $i = 0 To UBound($zeros) - 1
        If StringReplace($zeros[$i], ":", "") > StringReplace($max, ":", "") Then
            $max = $zeros[$i]
        EndIf
    Next

    ; Step 4: Replace the longest sequence of '0' segments with '::' if found
    If $max <> "" Then $output = StringReplace($output, $max, "::", 1)

    ; Step 5: Return the compressed IPv6 address
    Return StringLower($output)
EndFunc

Func ExtractSRVServerData($binary_data)
    Local $num_answ = Dec(StringMid($binary_data, 15, 4)) ; representing number of answers provided by the server
    Local $arr = StringSplit($binary_data, "C00C00210001", 1) ; splitting input; "C00C000F0001" - translated to human: "this is the answer for your MX query"

    If $num_answ <> $arr[0] - 1 Or $num_answ = 0 Then Return -1 ; dealing with possible options

    Local $iPriority[$arr[0]]
    Local $iWeight[$arr[0]]
    Local $iPort[$arr[0]]
    Local $sTarget[$arr[0]] ; server name(s)
    ;Local $output[$arr[0] - 1][4] ; this goes out containing both server names and coresponding priority/weight and port numbers
	Local $output[1][4] = [[$arr[0]-1, "SRV"]] ; this goes out containing both server names and coresponding priority/weight and port numbers
    Local $offset = 14 ; initial offset

    For $i = 2 To $arr[0]

        $arr[$i] = "0x" & $arr[$i] ; well, it is binary data
        $iPriority[$i - 1] = Dec(StringRight(BinaryMid($arr[$i], 7, 2), 4))
        $iWeight[$i - 1] = Dec(StringRight(BinaryMid($arr[$i], 9, 2), 4))
        $iPort[$i - 1] = Dec(StringRight(BinaryMid($arr[$i], 11, 2), 4))
        $offset += BinaryLen($arr[$i - 1]) + 6 ; adding lenght of every past part plus lenght of that "C00C000F0001" used for splitting
        Local $array = ReadBinary($binary_data, $offset) ; extraction of server names starts here
        While $array[1] = 192 ; dealing with special case
            $array = ReadBinary($binary_data, $array[6] + 2)
        WEnd
        $sTarget[$i - 1] &= $array[2] & "."

        While $array[3] <> 0 ; the end will obviously be at $array[3] = 0
            If $array[3] = 192 Then
                $array = ReadBinary($array[0], $array[4] + 2)
                If $array[3] = 0 Then
                    $sTarget[$i - 1] &= $array[2]
                    ExitLoop
                Else
                    $sTarget[$i - 1] &= $array[2] & "."
                EndIf
            Else
                $array = ReadBinary($array[0], $array[5])
                If $array[3] = 0 Then
                    $sTarget[$i - 1] &= $array[2]
                    ExitLoop
                Else
                    $sTarget[$i - 1] &= $array[2] & "."
                EndIf

            EndIf
        WEnd

		local $result[][] = [[$sTarget[$i - 1], $iPort[$i - 1], $iPriority[$i - 1], $iWeight[$i - 1]]]
		_ArrayAdd($output, $result)
    Next

    Return $output ; two-dimensional array
EndFunc   ;==>ExtractSRVServerData

Func ReadBinary($binary_data, $offset)
    Local $len = Dec(StringRight(BinaryMid($binary_data, $offset - 1, 1), 2))
    Local $data_bin = BinaryMid($binary_data, $offset, $len)
    Local $checker = Dec(StringRight(BinaryMid($data_bin, 1, 1), 2))
    Local $data = BinaryToString($data_bin)
    Local $triger = Dec(StringRight(BinaryMid($binary_data, $offset + $len, 1), 2))
    Local $new_offset = Dec(StringRight(BinaryMid($binary_data, $offset + $len + 1, 1), 2))
    Local $another_offset = $offset + $len + 1
    Local $array[7] = [$binary_data, $len, $data, $triger, $new_offset, $another_offset, $checker] ; bit of this and bit of that
    Return $array
EndFunc   ;==>ReadBinary

Func _GetGateway()
	; Based on:
    ; Rajesh V R
    ; v 1.0 01 June 2009

       ; use the adapter name as seen in the network connections dialog...
    Const $wbemFlagReturnImmediately = 0x10
    Const $wbemFlagForwardOnly = 0x20
    Local $colNICs="", $NIC, $strQuery, $objWMIService

    $strQuery = "SELECT * FROM Win32_NetworkAdapterConfiguration"
    $objWMIService = ObjGet("winmgmts:\\.\root\CIMV2")
    $colNICs = $objWMIService.ExecQuery($strQuery, "WQL", $wbemFlagReturnImmediately + $wbemFlagForwardOnly)

    Local $output[2]

    If IsObj($colNICs) Then
        For $NIC In $colNICs
			if isstring($NIC.DefaultIPGateway(0)) then
				$output[0] = $NIC.IPAddress(0)
				$output[1] = $NIC.DefaultIPGateway(0)
				ExitLoop
			endif
        Next
    Else
        Return SetError(-1, 0, "No WMI Objects Found for class: Win32_NetworkAdapterConfiguration")
    EndIf
    Return $output
EndFunc

Func _simulator_OnExit()
	AdlibUnRegister("_simulator_Listen")
	if IsDeclared("simulator_iListenSocket") and $simulator_iListenSocket > 0 then
		TCPCloseSocket($simulator_iListenSocket)
	endif
	TCPShutdown()
	if IsDeclared("router") and $router then
		routerport($simulator_iPort, $simulator_iPortType, $simulator_iProxyType, $simulator_iIP, false)
		$router = false
	EndIf
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
