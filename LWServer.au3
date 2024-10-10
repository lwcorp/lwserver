#AutoIt3Wrapper_Run_After=del "%scriptfile%_x32.exe"
#AutoIt3Wrapper_Run_After=ren "%out%" "%scriptfile%_x32.exe"
#AutoIt3Wrapper_Run_After=del "%scriptfile%_stripped.au3"
#AutoIt3Wrapper_Run_Au3Stripper=y
#Au3Stripper_Parameters=/PreExpand /StripOnly /RM ;/RenameMinimum
#AutoIt3Wrapper_Compile_both=y
#AutoIt3Wrapper_Res_Description=LWServer
#AutoIt3Wrapper_Res_Fileversion=1.0
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

global $simulator_programname="LWServer"
global $simulator_programdesc = "Both a http/s proxy server and mail emulator accepting outgoing SMTP messages." & @crlf & _
"The proxy server allows others to use your device as VPN"
global $simulator_version="1.0"
global $simulator_thedate=@YEAR

if StringRegExp(@ScriptName, "^" & $simulator_programname & ".*[_\.]") then
	simulator()
EndIf

Func simulator($mainwin = Null, $margin_left=default, $margin_top=default, $defaultProxyType = "")

;AutoItSetOption("TCPTimeout", 100)

global $simulator_iIP, $simulator_iPort, $simulator_iPortType, $simulator_iProxyType
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
global $simulator_hStartButton = GUICtrlCreateButton("Start", 110, 330, 80, 30)
global $simulator_hStopButton = GUICtrlCreateButton("Stop", 210, 330, 80, 30)
GUICtrlSetState($simulator_hStopButton, $GUI_DISABLE)
GUICtrlCreateLabel("Status:", 10, 370)
global $simulator_hStatus = GUICtrlCreateLabel("Stopped", 70, 370, 250, 20)
GUICtrlSetColor($simulator_hStatus, eval("COLOR_BLUE"))
GUICtrlCreateLabel("Public IP:", 8, 395)
global $simulator_hExternalIP = GUICtrlCreateInput("Checked on Start", 10, 410, 90, default, BitOR($GUI_SS_DEFAULT_INPUT, $ES_READONLY, $WS_TABSTOP))
global $simulator_hCopyButton_ExternalIP = GUICtrlCreateButton("Copy", 103, 407, 50)
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
			While 1
				$sReceived = TCPorUDPRecv($iSocket, $limit)
				if $simulator_iPortType <> "TCP" and $sReceived == ("220 Service ready" & @CRLF) Then
					$sReceived = ""
				endif
				If $sReceived <> "" Then
					_Monitor("Received: " & $sReceived, false)
					StringReplace($sReceived, @CRLF, "")
					if @extended>1 then
						GUICtrlSetData($msg, $sReceived)
					EndIf
					If StringInStr($sReceived, "EHLO") Then
						TCPorUDPSend($iSocket, "250-Hello" & @CRLF)
						TCPorUDPSend($iSocket, "250-8BITMIME" & @CRLF)
						TCPorUDPSend($iSocket, "250 SIZE" & @CRLF)
					ElseIf StringInStr($sReceived, "MAIL FROM") Then
						TCPorUDPSend($iSocket, "250 Sender OK" & @CRLF)
					ElseIf StringInStr($sReceived, "RCPT TO") Then
						TCPorUDPSend($iSocket, "250 Recipient OK" & @CRLF)
					ElseIf StringInStr($sReceived, "DATA") Then
						TCPorUDPSend($iSocket, "354 Start mail input; end with <CRLF>.<CRLF>" & @CRLF)
					ElseIf StringInStr($sReceived, @CRLF & "." & @CRLF) Then
						TCPorUDPSend($iSocket, "250 Message accepted for delivery" & @CRLF)
					ElseIf StringInStr($sReceived, "QUIT") Then
						TCPorUDPSend($iSocket, "221 Bye" & @CRLF)
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
	return ($simulator_iPortType == "TCP") ? TCPSend($iSocket, $msg) : UDPSend($iSocket, $msg)
EndFunc

func TCPorUDPRecv($iSocket, $limit)
	return ($simulator_iPortType == "TCP") ? TCPRecv($iSocket, $limit) : UDPRecv($iSocket, $limit)
EndFunc

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
        SetError(-1, "No WMI Objects Found for class: Win32_NetworkAdapterConfiguration", "")
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
