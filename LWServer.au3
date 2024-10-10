#AutoIt3Wrapper_Run_After=del "%scriptfile%_x32.exe"
#AutoIt3Wrapper_Run_After=ren "%out%" "%scriptfile%_x32.exe"
#AutoIt3Wrapper_Run_After=del "%scriptfile%_stripped.au3"
#AutoIt3Wrapper_Run_Au3Stripper=y
#Au3Stripper_Parameters=/PreExpand /StripOnly /RM ;/RenameMinimum
#AutoIt3Wrapper_Compile_both=y
#AutoIt3Wrapper_Res_Description=LWBlat GUI
#cs
[FileVersion]
#ce
#AutoIt3Wrapper_Res_Fileversion=1.4.1
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

#include <GuiButton.au3>
#include <WinAPI.au3>
#include <WindowsConstants.au3>
#include <TabConstants.au3>
#include <EditConstants.au3>
#include <ComboConstants.au3>
#include <GUIConstantsEx.au3>
#include <UpDownConstants.au3>
#include <ColorConstants.au3>
#Include <File.au3>
#include <Inet.au3>
#include <Crypt.au3>
#include <LWServer.au3>

$default_content_type="Plain Text"
$html_content_type="HTML"
$enriched_content_type="Rich Text"
$default_charset="Auto"
$charsets=$default_charset & "|Windows-1255|UTF-8|*Custom*"
$default_profile="Default"
$profiles=$default_profile & "|*Custom*"
$default_debug="No debug"
$default_attachmentpath=""
$default_signaturepath="signature.txt"
$default_bodypath = "body.txt"
$default_logpath = "log.txt"
$default_editorpath = "%windir%\notepad.exe"
$default_blatexepath = "full\blat.exe"
$default_blatpath = "full\blat.dll"
$default_helppath = ""
$default_search = "build"

$content_types=$default_content_type & "|" & $enriched_content_type & "|" & $html_content_type
$sPassword = ""

$programname="LWBlat GUI"
$extension=".ini"
$version =StringRegExpReplace(@Compiled ? StringRegExpReplace(FileGetVersion(@ScriptFullPath), "\.0+$", "") : IniRead(@ScriptFullPath, "FileVersion", "#AutoIt3Wrapper_Res_Fileversion", "0.0.0"), "(\d+\.\d+\.\d+)\.(\d+)", "$1 beta $2")
$thedate=@YEAR
$search_keyword=""

if $cmdline[0]>0 then
	exit launchdll_execute($cmdline[1], StringEncrypt(False, $cmdline[ubound($cmdline)-1]))
EndIf

$configfile = $programname & $extension
$windowtitle = $programname & " - " & $configfile

$_HiddenAUTHPassword = ""
$_HiddenPOP3Password = ""
$_HiddenIMAPPassword = ""

$configfile_default=defaultpath($configfile)

$MainWindow = GUICreate($windowtitle, 440, 580, -1, -1, -1, $WS_EX_ACCEPTFILES)

Opt("GUICoordMode", 1)


; --- Menu ---

$filemenu = GUICtrlCreateMenu("&File")
$fileitem_open = GUICtrlCreateMenuItem("&Open", $filemenu)
$fileitem_saveas = GUICtrlCreateMenuItem("&Save as", $filemenu)
GUICtrlCreateMenuItem("", $filemenu)
$fileitem_save = GUICtrlCreateMenuItem("&Save default", $filemenu)
$fileitem_load = GUICtrlCreateMenuItem("&Load default", $filemenu)
$fileitem_reset = GUICtrlCreateMenuItem("&Reset default", $filemenu)

$commandmenu = GUICtrlCreateMenu("C&ommand")
$commanditem_create = GUICtrlCreateMenuItem("&Create", $commandmenu)
$commanditem_simulator = GUICtrlCreateMenuItem("&Open Simulator", $commandmenu)
$commanditem_send = GUICtrlCreateMenuItem("&Send", $commandmenu)

$profilemenu = GUICtrlCreateMenu("&Profiles")
$profileitem_listprofiles = GUICtrlCreateMenuItem("&List installed profiles", $profilemenu)
$profileitem_saveprofile = GUICtrlCreateMenuItem("&Save to registry", $profilemenu)
$profileitem_deleteprofile = GUICtrlCreateMenuItem("&Delete from registry", $profilemenu)
$profileitem_deleteprofiles = GUICtrlCreateMenuItem("Delete &all from registry", $profilemenu)

$helpmenu = GUICtrlCreateMenu("&Help")
$helpitem_blathomepage = GUICtrlCreateMenuItem("&Visit Blat homepage", $helpmenu)
$helpitem_syntax = GUICtrlCreateMenuItem("&Blat Syntax", $helpmenu)
$helpitem_searchsyntax = GUICtrlCreateMenuItem("&Search Blat Syntax", $helpmenu)
$helpitem_about = GUICtrlCreateMenuItem("&About", $helpmenu)


; --- Tab ---

$MainTab = GUICtrlCreateTab(5, 5, 430, 440, $TCS_MULTILINE + $TCS_RIGHTJUSTIFY)


GUICtrlCreateTabItem("Mail")

GUICtrlCreateLabel("From", 15, 45)
$Input_from = GUICtrlCreateInput("", 85, 45, 340, 20)

GUICtrlCreateLabel("(Organization", 15, 70)
$Input_organization = GUICtrlCreateInput("", 85, 70, 335, 20)
GUICtrlCreateLabel(")", 421, 70)

GUICtrlCreateLabel("(Reply-to", 15, 95)
$Input_replyto = GUICtrlCreateInput("", 85, 95, 335, 20)
GUICtrlCreateLabel(")", 421, 100)

GUICtrlCreateLabel("To", 15, 130)
$Input_to = GUICtrlCreateInput("", 85, 130, 340, 20)

GUICtrlCreateLabel("CC", 15, 155)
$Input_cc = GUICtrlCreateInput("", 85, 155, 340, 20)

GUICtrlCreateLabel("BCC", 15, 180)
$Input_bcc = GUICtrlCreateInput("", 85, 180, 340, 20)

GUICtrlCreateLabel("Subject", 15, 215)
$Input_subject = GUICtrlCreateInput("", 85, 215, 340, 20)

GUICtrlCreateLabel("Attachment", 15, 240)
$Checkbox_attachment = GUICtrlCreateCheckbox("", 85, 240, 20, 20)
$Input_attachment = GUICtrlCreateInput("", 105, 240, 275, 20)
GUICtrlSetState(-1, $GUI_DROPACCEPTED)
$Button_chooseattachmentpath = GUICtrlCreateButton("Select", 385, 240, 40, 20)
$env_Input_attachment = GUICtrlCreateInput("", -1, -1)
GUICtrlSetState(-1, $GUI_HIDE)

GUICtrlCreateLabel("Signature", 15, 265)
$Checkbox_signature = GUICtrlCreateCheckbox("", 85, 265, 20, 20)
$Input_signature = GUICtrlCreateInput("", 105, 265, 230, 20)
GUICtrlSetState(-1, $GUI_DROPACCEPTED)
$env_Input_signature = GUICtrlCreateInput("", -1, -1)
GUICtrlSetState(-1, $GUI_HIDE)
$Button_choosesignaturepath = GUICtrlCreateButton("Select", 385, 265, 40, 20)
$Button_signature = GUICtrlCreateButton("Edit", 340, 265, 40, 20)

GUICtrlCreateLabel("Body file", 15, 290)
$Checkbox_bodypath = GUICtrlCreateCheckbox("", 85, 290, 20, 20)
$Input_file = GUICtrlCreateInput("", 105, 290, 230, 20)
GUICtrlSetState(-1, $GUI_DROPACCEPTED)
$env_Input_file = GUICtrlCreateInput("", -1, -1)
GUICtrlSetState(-1, $GUI_HIDE)

$Button_editbody = GUICtrlCreateButton("Edit", 340, 290, 40, 20)
$Button_choosebodypath = GUICtrlCreateButton("Select", 385, 290, 40, 20)

GUICtrlCreateLabel("Body text", 15, 315)
$Checkbox_bodytext = GUICtrlCreateCheckbox("", 85, 315, 20, 20)
$Input_bodytext = GUICtrlCreateInput("", 105, 315, 320, 100, bitor($ES_AUTOVSCROLL, $ES_MULTILINE, $ES_WANTRETURN)) ; no default=use wrapping

GUICtrlCreateTabItem("")   ;==>Mail

GUICtrlCreateTabItem("Options")

GUICtrlCreateLabel("Content type", 15, 43)
$input_content_type=GUICtrlCreateCombo("", 90, 40, 75, default, $CBS_DROPDOWNLIST)
GUICtrlSetData(-1, $content_types)

GUICtrlCreateLabel("Charset", 15, 73)
$input_charset=GUICtrlCreateCombo("", 90, 70, 100)
GUICtrlSetData(-1, $charsets)
GUICtrlCreateLabel("Auto = iso-8859-1 / UTF-7 / UTF-8", 195, 74)
GUICtrlSetTip(-1, "Based on the content and server")
GUICtrlSetFont(-1, 8.4)

GUICtrlCreateLabel("Confirmation", 15, 103)
$Checkbox_disposition = GUICtrlCreateCheckbox("Disposition notification", 90, 100, 120, 20)
$Checkbox_receipt = GUICtrlCreateCheckbox("Return receipt", 220, 100, 90, 20)

GUICtrlCreateLabel("Priority", 15, 128)
$Input_priority = GUICtrlCreateCombo("", 90, 125, 50, 20, $CBS_DROPDOWNLIST)
GUICtrlSetData(-1, "None|Low|High")

GUICtrlCreateLabel("Max. names", 15, 155)
GUICtrlSetTip(-1, "Send to groups of <x> number of recipients")
$Checkbox_maxNames = GUICtrlCreateCheckbox("", 90, 155, 20, 20)
$Input_maxNames = GUICtrlCreateInput("", 110, 155, 50, 20, $ES_NUMBER + $ES_RIGHT)
GUICtrlCreateUpdown(-1, bitor($UDS_ARROWKEYS, $UDS_NOTHOUSANDS))
GUICtrlSetLimit(-1,32767,1)

GUICtrlCreateLabel("Multipart", 15, 180)
GUICtrlSetTip(-1, "Send multipart messages, breaking attachments on <size>")
$Checkbox_multipart_yes = GUICtrlCreateCheckbox("", 90, 180, 20, 20)
$Input_multipart = GUICtrlCreateInput("", 110, 180, 55, 20, $ES_NUMBER + $ES_RIGHT)
GUICtrlCreateUpdown(-1, bitor($UDS_ARROWKEYS, $UDS_NOTHOUSANDS))
GUICtrlSetLimit(-1,32767,0)
GUICtrlCreateLabel(",000 B", 165, 185)
GUICtrlCreateLabel("(0=max)", 110, 200)
GUICtrlSetFont(-1, 8.4)
$Checkbox_multipart_no = GUICtrlCreateCheckbox("Do not allow multipart messages", 220, 180, 175, 20)

GUICtrlCreateLabel("X-mailer", 15, 220)
$Checkbox_xmailer = GUICtrlCreateCheckbox("Hide x-mailer", 90, 217, 100, 20)
$Checkbox_xmailerurl = GUICtrlCreateCheckbox("Hide blat url", 217, 217, 100, 20)

GUICtrlCreateLabel("Log", 15, 245)
$Checkbox_log = GUICtrlCreateCheckbox("", 90, 245, 20, 20)
$Input_log = GUICtrlCreateInput("", 110, 245, 225, 20)
GUICtrlSetState($Input_log, $GUI_DROPACCEPTED)
$Button_chooselogpath = GUICtrlCreateButton("Select", 385, 245, 40, 20)
$Button_log = GUICtrlCreateButton("Edit", 340, 245, 40, 20)
$Checkbox_timestamp = GUICtrlCreateCheckbox("Use timestamp", 90, 265)
GUICtrlSetTip(-1, "Add a timestamp is added to each log line")
$Checkbox_overwritelog = GUICtrlCreateCheckbox("Overwrite", 220, 265)
$input_debug=GUICtrlCreateCombo("", 305, 269, 115, default, $CBS_DROPDOWNLIST)
GUICtrlSetData(-1, $default_debug & "|Debug|Superdebug text|Superdebug|SuperDuperDebug")

GUICtrlCreateLabel("Send attempts", 15, 290)
$Input_try = GUICtrlCreateInput("", 90, 290, 55, 20)
GUICtrlCreateUpdown(-1, bitor($UDS_ARROWKEYS, $UDS_NOTHOUSANDS))
GUICtrlSetLimit(-1, 32767, 1)
GUICtrlCreateLabel("(1=infinite)", 150, 292)

GUICtrlCreateLabel("Hostname", 15, 315)
GUICtrlSetTip(-1, "Select the hostname used to send the message via SMTP")
$Button_hostinfo = GUICtrlCreateButton("Default info", 67, 315, 65, 20)
GUICtrlSetTip(-1, "Get information about the default hostname")
$Input_host = GUICtrlCreateInput("", 140, 315, 285, 20)

GUICtrlCreateLabel("Final header 1 (name: value)", 15, 340)
GUICtrlSetTip(-1, "Custom header")
$Input_finalheader1 = GUICtrlCreateInput("", 155, 340, 270, 20)

GUICtrlCreateLabel("Final header 2 (name: value)", 15, 365)
GUICtrlSetTip(-1, "Custom header")
$Input_finalheader2 = GUICtrlCreateInput("", 155, 365, 270, 20)

GUICtrlCreateLabel("Extra arguments", 15, 390)
$Input_arguments = GUICtrlCreateInput("", 96, 390, 329, 20)

GUICtrlCreateLabel("Custom registry", 15, 418)
$checkbox_registry=GUICtrlCreateCheckbox("", 90, 415, 20, 20)
GUICtrlCreateLabel("Profile", 115, 418, 35, 20)
$Input_profile = GUICtrlCreateCombo("", 150, 415, 90)
GUICtrlSetData(-1, $profiles)

GUICtrlCreateTabItem("")   ;==>Options

$auth_tab = GUICtrlCreateTabItem("Authentication")

GUICtrlCreateLabel("Server", 15, 43)
$Input_server = GUICtrlCreateInput("", 85, 40, 220, 20)
$Button_serverinfo = GUICtrlCreateButton("&Info", 315, 40, 40, 20)
GUICtrlCreateLabel("Port", 360, 43)
$Input_port = GUICtrlCreateInput("", 385, 40, 40, 20, bitor($GUI_SS_DEFAULT_INPUT,$ES_NUMBER))

GUICtrlCreateLabel("AUTH user", 15, 65)
$Input_authuser = GUICtrlCreateInput("", 85, 65, 340, 20)
GUICtrlCreateLabel("AUTH pass", 15, 90)
$Input_authpass = GUICtrlCreateInput("", 85, 90, 340, 20, $ES_PASSWORD)

GUICtrlCreateLabel("POP3 user", 15, 125)
$Input_pop3user = GUICtrlCreateInput("", 85, 125, 340, 20)
GUICtrlCreateLabel("POP3 pass", 15, 150)
$Input_pop3pass = GUICtrlCreateInput("", 85, 150, 340, 20, $ES_PASSWORD)

GUICtrlCreateLabel("IMAP user", 15, 190)
$Input_imapuser = GUICtrlCreateInput("", 85, 190, 340, 20)
GUICtrlCreateLabel("IMAP pass", 15, 215)
$Input_imappass = GUICtrlCreateInput("", 85, 215, 340, 20, $ES_PASSWORD)

GUICtrlCreateTabItem("")   ;==>Authentication

GUICtrlCreateTabItem("Preferences")

GUICtrlCreateLabel("Blat DLL path", 15, 40)
$Input_blatpath = GUICtrlCreateInput("", 85, 40, 295, 20)
GUICtrlSetState($Input_blatpath, $GUI_DROPACCEPTED)
$env_Input_blatpath = GUICtrlCreateInput("", -1, -1)
GUICtrlSetState(-1, $GUI_HIDE)
$Button_chooseblatpath = GUICtrlCreateButton("Select", 385, 40, 40, 20)

GUICtrlCreateLabel("Blat EXE path", 15, 65)
$Input_blatexepath = GUICtrlCreateInput("", 85, 65, 295, 20)
GUICtrlSetState($Input_blatexepath, $GUI_DROPACCEPTED)
$Button_chooseblatexepath = GUICtrlCreateButton("Select", 385, 65, 40, 20)

GUICtrlCreateLabel("Editor path", 15, 90)
$Input_editorpath = GUICtrlCreateInput("", 85, 90, 295, 20)
GUICtrlSetState($Input_editorpath, $GUI_DROPACCEPTED)
$env_editorpath = GUICtrlCreateInput("", -1, -1)
GUICtrlSetState(-1, $GUI_HIDE)
$Button_chooseeditorpath = GUICtrlCreateButton("Select", 385, 90, 40, 20)

GUICtrlCreateLabel("Help path", 15, 115)
$Input_helppath = GUICtrlCreateInput("", 85, 115, 295, 20)
GUICtrlSetState($Input_helppath, $GUI_DROPACCEPTED)
$env_Input_helppath = GUICtrlCreateInput("", -1, -1)
GUICtrlSetState(-1, $GUI_HIDE)
$Button_choosehelppath = GUICtrlCreateButton("Select", 385, 115, 40, 20)

GUICtrlCreateLabel("File names", 15, 150)
$Checkbox_absolutepaths = GUICtrlCreateCheckbox("Use absolute paths", 85, 150, 125, 20)

GUICtrlCreateLabel("Shutdown", 15, 190)
$Checkbox_shutdown = GUICtrlCreateCheckbox("Shutdown computer", 85, 190, 115, 20)
$Input_shutdown = GUICtrlCreateInput("", 205, 190, 40, 20, $ES_NUMBER + $ES_RIGHT)
GUICtrlCreateLabel("seconds after sending", 250, 190, 180)

GUICtrlCreateTabItem("")   ;==>Preferences

; --- Buttons ---

$Button_create = GUICtrlCreateButton("&Create", 5, 445, 85, 25)
GUICtrlSetTip(-1, "Combine all info into a synatx that can be sent")
$Button_simulator = GUICtrlCreateButton("&Open Simulator", 170, 445, 85, 25)
GUICtrlSetTip(-1, "Simulate how the messages will appear in the inbox without actually sending them")
$Button_send = GUICtrlCreateButton("&Send", 350, 445, 85, 25)


; --- Command Line ---

$Input_commandline = GUICtrlCreateInput("", 5, 472, 430, 80, bitor($ES_AUTOVSCROLL, $ES_MULTILINE)) ; no default=use wrapping

loadconfig($configfile_default)

GUISetState()

While 1

  local $msg_array = GUIGetMsg(1); Use advanced parameter to get array to support multiple menus
  local $msg = $msg_array[0]
  If Not IsHWnd($msg_array[1]) Then ContinueLoop; preventing subsequent lines from processing when nothing happens
  global $used_simulator = IsDeclared("simulator_MainWindow") and IsHWnd($simulator_MainWindow)
  Switch $msg_array[1]; check which GUI sent the message

   case $MainWindow

	Select

		Case $msg = $GUI_EVENT_CLOSE

			ExitLoop

		Case $msg = $fileitem_open

			$new_configfile = FileOpenDialog("Open " & $programname& " Configuration File", "", _
			$programname & " Configuration File (*" & $extension & ")", 3, "", $MainWindow)
			If Not $new_configfile = "" Then
				$configfile = $new_configfile
				LoadConfig($configfile)
				$StringSplitConfigFile = StringSplit($configfile, "\")
				$windowtitle = $programname & " - " & $StringSplitConfigFile[$StringSplitConfigFile[0]]
				WinSetTitle($MainWindow, "", $windowtitle)
			EndIf

		Case $msg = $fileitem_save

			SaveConfig($configfile_default)

		Case $msg = $fileitem_saveas

			$new_configfile = FileSaveDialog("Save as", "", $programname & " Configuration File (*" & $extension & ")", 18, "")
			If Not $new_configfile = "" Then
				If StringRight($new_configfile, 4) = $extension Then
					$configfile = $new_configfile
				Else
					$configfile = $new_configfile & $extension
				EndIf
				SaveConfig($configfile)
				$StringSplitConfigFile = StringSplit($configfile, "\")
				$windowtitle = $programname & " - " & $StringSplitConfigFile[$StringSplitConfigFile[0]]
				WinSetTitle($MainWindow, "", $windowtitle)
			EndIf

		Case $msg = $fileitem_load

			LoadConfig($configfile_default)

		Case $msg = $fileitem_reset

			filedelete($configfile_default)
			LoadConfig($configfile_default)

		Case $msg = $profileitem_listprofiles

			Run(@ComSpec & ' /c title ' & $programname & ' && color 0A && "' & _
			defaultpath(GUICtrlRead($Input_blatexepath, 1)) & '" -profile|more' & ' && pause')

		Case $msg = $profileitem_saveprofile

			$blat_command="-SaveSettings "
			If GUICtrlRead($Input_server, 1) = "" Then
				GUICtrlSetState($auth_tab, $GUI_SHOW)
				GUICtrlSetState($Input_server, $GUI_FOCUS)
				GUICtrlSetData($Input_server, "Please supply a server")
				GUICtrlSetBkColor($Input_server, eval("COLOR_RED"))
				msgbox(48, "No server supplied", "You must supply a server", default, $MainWindow)
				GUICtrlSetData($Input_server, "")
				GUICtrlSetBkColor($Input_server, eval("COLOR_WHITE"))
			else
				$blat_command &= GUICtrlRead($Input_server, 1)
				$blat_command &= command_add(filtertext(GUICtrlRead($Input_from, 1)))
				$blat_command &= command_add(GUICtrlRead($Input_try, 1), "numeric")
				$blat_command &= command_add(GUICtrlRead($Input_port, 1))
				$blat_command &= command_add(GUICtrlRead($Input_profile, 1), "default")
				if GUICtrlRead($Input_authuser, 1)<>"" then
					$blat_command &= " " & GUICtrlRead($Input_authuser, 1)
					if GUICtrlRead($Input_authpass, 1)<>"" then
						$blat_command &= " " & GUICtrlRead($Input_authpass, 1)
					endif
				endif
				$blat_command &= " -hkcu"
				$return_code = launchdll($blat_command)
				if IsNumber($return_code) then
					switch $return_code
						case 0
							$return_title="Success"
							$return_msg="Successfully saved"
						case Else
							$return_title="Failure"
							$return_msg="Failed saving"
					endswitch
					if GUICtrlRead($Input_profile, 1)="" then
						$return_msg &= " the default profile"
					else
						$return_msg &= ' profile "' & GUICtrlRead($Input_profile, 1) & '"'
					endif
					msgbox(0, $return_title, $return_msg & " to the registry.", default, $MainWindow)
				endif
			endif

		Case $msg = $profileitem_deleteprofile or $msg = $profileitem_deleteprofiles
			$blat_command = "-profile -delete -hkcu "
			if $msg = $profileitem_deleteprofiles then
				$blat_command &= '"<all>"'
			elseif GUICtrlRead($Input_profile, 1)="" or GUICtrlRead($Input_profile, 1)=$default_profile or _
				GUICtrlRead($Input_profile, 1)="*Custom*" then
				$blat_command &= '"<default>"'
			else
				$blat_command &= GUICtrlRead($Input_profile, 1)
			endif
			$return_code = launchdll($blat_command)
			if IsNumber($return_code) then
				switch $return_code
					case 0
						$return_title="Success"
						$return_msg="Successfully deleted"
					case Else
						$return_title="Failure"
						$return_msg="Failed deleting"
				endswitch
				if $msg = $profileitem_deleteprofiles then
					$return_msg &= " all profiles "
				elseif GUICtrlRead($Input_profile, 1)="" then
					$return_msg &= " the default profile "
				else
					$return_msg &= ' the following profiles:' & @crlf & GUICtrlRead($Input_profile, 1) & @crlf
				endif
				msgbox(0, $return_title, $return_msg & "from the registry.", default, $MainWindow)
			endif

		Case $msg = $helpitem_blathomepage

			ShellExecute("https://www.blat.net")

		Case $msg = $helpitem_syntax OR $msg = $helpitem_searchsyntax

			$helppath_temp=""
			if GUICtrlRead($Input_helppath, 1)<>"" then
				$helppath_temp=pathfull(defaultpath(_WinAPI_ExpandEnvironmentStrings(GUICtrlRead($Input_helppath, 1))))
			endif
			If $helppath_temp<>"" AND fileexists($helppath_temp) Then
				ShellExecute($helppath_temp)
			Else
				$findsyntax_error=false
				$findsyntax_title=""
				$findsyntax_str=""
				if $msg = $helpitem_searchsyntax Then
					if $search_keyword="" Then
						$search_keyword=$default_search
					endif
					$findsyntax_str=InputBox("Search", "Enter search word", $search_keyword)
					if $findsyntax_str<>"" Then
						$search_keyword=$findsyntax_str
						$findsyntax_title='The word "' & $findsyntax_str & '" in the help'
						$findsyntax_str='|find /i "' & $findsyntax_str & '"'
					elseif @error>0 then
						$findsyntax_error=true
					endif
				endif
				if not $findsyntax_error then
					Run(@ComSpec & ' /c title ' & $findsyntax_title & ' && color 0A && "' & _
					defaultpath(GUICtrlRead($Input_blatexepath, 1)) & '" -h' & $findsyntax_str & '|more' & ' && pause')
				endif
			EndIf

		Case $msg = $helpitem_about

			about()

		Case $msg = $Button_create Or $msg = $commanditem_create

			GUICtrlSetData($env_Input_file, _WinAPI_ExpandEnvironmentStrings(GUICtrlRead($Input_file, 1)))
			GUICtrlSetData($env_Input_blatpath, _WinAPI_ExpandEnvironmentStrings(GUICtrlRead($Input_blatpath, 1)))
			GUICtrlSetData($env_Input_attachment, _WinAPI_ExpandEnvironmentStrings(GUICtrlRead($Input_attachment, 1)))
			GUICtrlSetData($env_Input_signature, _WinAPI_ExpandEnvironmentStrings(GUICtrlRead($Input_signature, 1)))

			If GUICtrlRead($Input_bodytext) = "" Or GUICtrlRead($Checkbox_bodytext, 0) = $GUI_UNCHECKED Then
				$_bodytext = ''
			Else
				$_bodytext = '-body "' & filtertext(GUICtrlRead($Input_bodytext)) & '"'
			EndIf

			If GUICtrlRead($Input_file, 1) = "" Or GUICtrlRead($Checkbox_bodypath, 0) = $GUI_UNCHECKED Then
				$_bodyfile = ''
			Else
				$_bodyfile=localize($Input_blatpath, $Input_file)
			EndIf

			if (GUICtrlRead($Checkbox_bodytext, 0) = $GUI_UNCHECKED and GUICtrlRead($Checkbox_bodypath, 0) = $GUI_UNCHECKED) or _
				($_bodytext="" and $_bodyfile="") Then
				$_bodytext='-body " "'
			endif

			If GUICtrlRead($Input_from, 1) = "" Then
				$_f = ''
			Else
				$_f = ' -f "' & filtertext(GUICtrlRead($Input_from, 1)) & '"'
			EndIf

			If GUICtrlRead($Input_organization, 1) = "" Then
				$_organization = ''
			Else
				$_organization = ' -organization "' & filtertext(GUICtrlRead($Input_organization, 1)) & '"'
			EndIf

			If GUICtrlRead($Input_replyto, 1) = "" Then
				$_replyto = ''
			Else
				$_replyto = ' -replyto "' & filtertext(GUICtrlRead($Input_replyto, 1)) & '"'
			EndIf

			If GUICtrlRead($Input_to, 1) = "" Then
				if GUICtrlRead($Input_from, 1) = "" and GUICtrlRead($Input_cc, 1) = "" then
					$_to = ' -ur'
				else
					$_to = ' -to "' & filtertext(GUICtrlRead($Input_from, 1)) & '"'
				endif
			Else
				$_to = ' -to "' & filtertext(GUICtrlRead($Input_to, 1)) & '"'
			EndIf

			If GUICtrlRead($Input_cc, 1) = "" Then
				$_cc = ''
			Else
				$_cc = ' -cc "' & filtertext(GUICtrlRead($Input_cc, 1)) & '"'
			EndIf

			If GUICtrlRead($Input_bcc, 1) = "" Then
				$_bcc = ''
			Else
				$_bcc = ' -bcc "' & filtertext(GUICtrlRead($Input_bcc, 1)) & '"'
			EndIf

			If GUICtrlRead($Input_subject, 1) = "" Then
				$_subject = ' -ss'
			Else
				$_subject = ' -subject "' & filtertext(GUICtrlRead($Input_subject, 1)) & '"'
			EndIf

			If GUICtrlRead($Input_attachment, 1) = "" Or GUICtrlRead($Checkbox_attachment, 0) = $GUI_UNCHECKED Then
				$_attachment = ''
			Else
				$_attachment = ' -attach ' & localize($Input_blatpath, $Input_attachment)
			EndIf

			If GUICtrlRead($Input_host, 1) = "" Then
				$_hostname = ''
			Else
				$_hostname = ' -hostname "' & GUICtrlRead($Input_host, 1) & '"'
			EndIf

			if $used_simulator then
				$_server = ' -server "' & GUICtrlRead($simulator_hIP, 1) & '"'
			ElseIf GUICtrlRead($Input_server, 1) = "" Then
				$_server = ''
			Else
				$_server = ' -server "' & GUICtrlRead($Input_server, 1) & '"'
			EndIf

			If $used_simulator or GUICtrlRead($Input_port, 1) = "" Then
				$_port = ''
			Else
				$_port = ' -port ' & GUICtrlRead($Input_port, 1)
			EndIf

			$_htmlenriched = ''
			Switch GUICtrlRead($Input_content_type, 1)
				case $html_content_type
					$_htmlenriched = ' -html'
				case $enriched_content_type
					$_htmlenriched = ' -enriched'
			endswitch

			If GUICtrlRead($Input_maxNames, 1) = "" Or GUICtrlRead($Checkbox_maxNames, 0) = $GUI_UNCHECKED Then
				$_maxNames = ''
			Else
				$_maxNames = ' -maxNames "' & GUICtrlRead($Input_maxNames, 1) & '"'
			EndIf

			If GUICtrlRead($Checkbox_signature, 0) = $GUI_UNCHECKED Then
				$_signature = ''
			Else
				$_signature = ' -sig ' & localize($Input_blatpath, $Input_signature)
			EndIf

			If GUICtrlRead($Checkbox_multipart_yes, 0) = $GUI_CHECKED Then
				if GUICtrlRead($Input_multipart, 1)="" or GUICtrlRead($Input_multipart, 1)=0 then
					$_multipart = ' -multipart'
				else
					$_multipart = ' -multipart "' & GUICtrlRead($Input_multipart, 1) & '"'
				endif
			ElseIf GUICtrlRead($Checkbox_multipart_no, 0) = $GUI_CHECKED Then
				$_multipart = ' -nomps'
			Else
				$_multipart = ''
			EndIf

			If GUICtrlRead($Checkbox_log, 0) = $GUI_UNCHECKED Then
				$_log = ''
			elseif GUICtrlRead($Input_log, 1)="" then
				$_log = '' ; Always on anyway in DLL mode
			Else
				$_log = ' -log ' & localize($Input_blatpath, $Input_log)
				If GUICtrlRead($Checkbox_timestamp, 0) = $GUI_CHECKED Then
					$_log &= ' -timestamp'
				EndIf
				If GUICtrlRead($Checkbox_overwritelog, 0) = $GUI_CHECKED Then
					$_log &= ' -overwritelog'
				EndIf
				If GUICtrlRead($input_debug) = "Debug" Then
					$_log &= ' -debug'
				elseif GUICtrlRead($input_debug) = "Superdebug Text" Then
					$_log &= ' -superdebugT'
				elseif GUICtrlRead($input_debug) = "Superdebug" Then
					$_log &= ' -superdebug'
				elseif GUICtrlRead($input_debug) = "superDuperDebug" Then
					$_log &= ' -superDuperDebug'
				EndIf
			EndIf

			If GUICtrlRead($Checkbox_xmailer, 0) = $GUI_CHECKED Then
				$_xmailer = ' -noh2'
			Else
				If GUICtrlRead($Checkbox_xmailerurl, 0) = $GUI_CHECKED Then
					$_xmailer = ' -noh'
				Else
					$_xmailer = ''
				EndIf
			EndIf

			If GUICtrlRead($input_charset, 1) = "" OR GUICtrlRead($input_charset, 1) = $default_charset _
				OR GUICtrlRead($input_charset, 1) = "*custom*" Then
				$_charset = ''
			ElseIf GUICtrlRead($input_charset, 1)="Unicode" then
				$_charset = ' -unicode'
			else
				$_charset = ' -charset "' & GUICtrlRead($Input_charset, 1) & '"'
			EndIf

			If GUICtrlRead($Input_priority, 1)<>"low" AND GUICtrlRead($Input_priority, 1)<>"high" then
				$_priority = ''
			Else
				$_priority = ' -priority ' & filterpriority(GUICtrlRead($Input_priority, 1))
			EndIf

			If GUICtrlRead($Checkbox_disposition, 0) = $GUI_UNCHECKED Then
				$_disposition = ''
			Else
				$_disposition = ' -d'
			Endif

			If GUICtrlRead($Checkbox_receipt, 0) = $GUI_UNCHECKED Then
				$_receipt = ''
			Else
				$_receipt = ' -r'
			Endif

			If GUICtrlRead($Input_try, 1) < 2 Then
				$_retry = ''
			Else
				$_retry = ' -try ' & GUICtrlRead($Input_try, 1)
			EndIf

			If GUICtrlRead($Input_finalheader1, 1) = "" Then
				$_finalheader1 = ''
			Else
				$_finalheader1 = ' -a1 "' & GUICtrlRead($Input_finalheader1, 1) & '"'
			EndIf
			If GUICtrlRead($Input_finalheader2, 1) = "" Then
				$_finalheader2 = ''
			Else
				$_finalheader2 = ' -a2 "' & GUICtrlRead($Input_finalheader2, 1) & '"'
			EndIf

			If GUICtrlRead($Input_arguments, 1) = "" Then
				$_arguments = ''
			Else
				$_arguments = ' ' & GUICtrlRead($Input_arguments, 1)
			EndIf

			$_profile = ''
			If GUICtrlRead($Checkbox_registry, 0)=$GUI_CHECKED and GUICtrlRead($Input_profile, 1)<>"" _
				and GUICtrlRead($Input_profile, 1)<>$default_profile and GUICtrlRead($Input_profile, 1)<>"*Custom*" Then
					$_profile &= ' -p "' & GUICtrlRead($Input_profile, 1) & '"'
			EndIf

			If GUICtrlRead($Input_authuser, 1) = "" Then
				$_u = ''
			Else
				$_u = ' -u "' & GUICtrlRead($Input_authuser, 1) & '"'
			EndIf
			If GUICtrlRead($Input_authpass, 1) = "" Then
				$_pw = ''
			Else
				$_pw = ' -pw "<auth_password>"'
				$_HiddenAUTHPassword = GUICtrlRead($Input_authpass, 1)
			EndIf

			If GUICtrlRead($Input_pop3user, 1) = "" Then
				$_pu = ''
			Else
				$_pu = ' -pu "' & GUICtrlRead($Input_pop3user, 1) & '"'
			EndIf
			If GUICtrlRead($Input_pop3pass, 1) = "" Then
				$_ppw = ''
			Else
				$_ppw = ' -ppw "<pop3_password>"'
				$_HiddenPOP3Password = GUICtrlRead($Input_pop3pass, 1)
			EndIf

			If GUICtrlRead($Input_imapuser, 1) = "" Then
				$_iu = ''
			Else
				$_iu = ' -iu "' & GUICtrlRead($Input_imapuser, 1) & '"'
			EndIf
			If GUICtrlRead($Input_imappass, 1) = "" Then
				$_ipw = ''
			Else
				$_ipw = ' -ipw "<imap_password>"'
				$_HiddenIMAPPassword = GUICtrlRead($Input_imappass, 1)
			EndIf

			$CreateCommand = $_bodytext & $_bodyfile & $_f & $_organization & $_replyto & $_to & $_cc & $_bcc & $_subject & _
			$_attachment & $_hostname & $_server & $_port & $_retry & $_htmlenriched & $_maxNames & $_signature & $_xmailer & $_multipart & $_log _
			& $_u & $_pw & $_pu & $_ppw & $_iu & $_ipw & $_priority & $_charset & $_disposition & $_receipt & $_finalheader1 & _
			$_finalheader2 & $_arguments & $_profile

			GUICtrlSetData($Input_commandline, $CreateCommand)

			; --- Validate arguments ---

			$val_body = 0
			$val_recipient = 0
			$val_sender = 0
			$val_server = 0
			$val_sendmail = 0
			$val_installation = 0
			$val_listprofiles = 0
			$val_help = 0
			$val_optionfile = 0
			$StSpCom = StringSplit($CreateCommand, " ")

			For $CommandE = 1 To $StSpCom[0]

				If $StSpCom[$CommandE] = "-body" Or GUICtrlRead($Checkbox_bodypath, 0) = $GUI_CHECKED Then
					$val_body = 1
				EndIf
				If $StSpCom[$CommandE] = "-t" Or $StSpCom[$CommandE] = "-to" Or $StSpCom[$CommandE] = "-tf" Or $StSpCom[$CommandE] = "-c" Or $StSpCom[$CommandE] = "-cc" Or $StSpCom[$CommandE] = "-cf" Or $StSpCom[$CommandE] = "-b" Or $StSpCom[$CommandE] = "-bcc" Or $StSpCom[$CommandE] = "-bf" Then
					$val_recipient = 1
				EndIf
				If $StSpCom[$CommandE] = "-f" Or $StSpCom[$CommandE] = "-p" Then
					$val_sender = 1
				EndIf
				If $StSpCom[$CommandE] = "-server" Or $StSpCom[$CommandE] = "-p" Then
					$val_server = 1
				EndIf
				If $val_body = 1 And $val_recipient = 1 And $val_sender = 1 And $val_server = 1 Then
					$val_sendmail = 1
				Else
					$val_sendmail = 0
				EndIf

				If $StSpCom[$CommandE] = "-SaveSettings" Or $StSpCom[$CommandE] = "-install" Or $StSpCom[$CommandE] = "-installSMTP" Or $StSpCom[$CommandE] = "-installNNTP" Or $StSpCom[$CommandE] = "-installPOP3" Or $StSpCom[$CommandE] = "-installIMAP" Then
					$val_installation = 1
				EndIf

				If $StSpCom[$CommandE] = "-profile" Then
					$val_listprofiles = 1
				EndIf

				If $StSpCom[$CommandE] = "-h" Or $StSpCom[$CommandE] = "-help" Or $StSpCom[$CommandE] = "/help" Or $StSpCom[$CommandE] = "-?" Or $StSpCom[$CommandE] = "/?" Then
					$val_help = 1
				EndIf

				If $StSpCom[$CommandE] = "-of" Then
					$val_optionfile = 1
				EndIf

			Next

			$val_msg = ""

			if $_to="" then $val_msg &= "Empty To" & @CRLF

			If GUICtrlRead($Input_from, 1) = "" Then
				if GUICtrlRead($Checkbox_registry, 0) = $GUI_UNCHECKED then
					$val_msg &= "Empty From" & @CRLF
				endif
			ElseIf ValidateEMailInput($Input_from) = 2 Then
				$val_msg &= "Input 'from' contains an invalid e-mail address." & @CRLF
			EndIf
			If ValidateEMailInput($Input_to) = 2 Then
				$val_msg &= "Input 'to' contains an invalid e-mail address." & @CRLF
			EndIf
			If ValidateEMailInput($Input_cc) = 2 Then
				$val_msg &= "Input 'cc' contains an invalid e-mail address." & @CRLF
			EndIf
			If ValidateEMailInput($Input_bcc) = 2 Then
				$val_msg &= "Input 'bcc' contains an invalid e-mail address." & @CRLF
			EndIf

			If GUICtrlRead($Checkbox_attachment, 0) = $GUI_CHECKED And _
				Not FileExistsRelative(GUICtrlRead($env_Input_attachment, 1), $Input_blatpath) Then
				$val_msg &= "File 'attachment' does not exist." & @CRLF
			EndIf
			If GUICtrlRead($Checkbox_signature, 0) = $GUI_CHECKED And _
				Not FileExistsRelative(GUICtrlRead($env_Input_signature, 1), $Input_blatpath) Then
				$val_msg &= "File 'signature' does not exist." & @CRLF
			EndIf
			If GUICtrlRead($Checkbox_bodypath, 0) = $GUI_CHECKED And _
				Not FileExistsRelative(GUICtrlRead($env_Input_file, 1), $Input_blatpath) Then
				$val_msg &= "File 'body file' does not exist." & @CRLF
			EndIf

			If Not GUICtrlRead($Input_server, 1) = "" And StringInStr(GUICtrlRead($Input_server), ".") = 0 Then
				$val_msg &= "Input 'server' is not a valid server address." & @CRLF
			EndIf

			If GUICtrlRead($Checkbox_maxNames, 0) = $GUI_CHECKED And GUICtrlRead($Input_maxNames, 1) = "0" Then
				$val_msg &= "Input 'max. names' is '0'." & @CRLF
			EndIf
			If GUICtrlRead($Checkbox_maxNames, 0) = $GUI_CHECKED And GUICtrlRead($Input_maxNames, 1) = "" Then
				$val_msg &= "Input 'max. names' is blank." & @CRLF
			EndIf

			If Not $val_msg = "" Then
				MsgBox(262144, "Warning", $val_msg, default, $MainWindow)
			EndIf

		Case $msg = $Button_simulator Or $msg = $commanditem_simulator

			if $used_simulator then
				GUIDelete($simulator_MainWindow)
				_simulator_OnExit()
			else
				simulator($MainWindow, -WinGetPos($MainWindow)[2]+44, WinGetPos($MainWindow)[1]-78, "SMTP")
			EndIf
			_GUICtrlButton_Click($Button_create)

		Case $msg = $Button_send Or $msg = $commanditem_send

			If GUICtrlRead($Input_commandline) = "" Then
				MsgBox(262144, "No command created", "Create a command first.", default, $MainWindow)
			Else
				$blat_command_1 = StringReplace(GUICtrlRead($Input_commandline), "<auth_password>", $_HiddenAUTHPassword)
				$blat_command_2 = StringReplace($blat_command_1, "<pop3_password>", $_HiddenPOP3Password)
				$blat_command = StringReplace($blat_command_2, "<imap_password>", $_HiddenIMAPPassword)
				$return_code = launchdll($blat_command, true)
				if IsNumber($return_code) then
					switch $return_code
						case 0
							$return_title="Success"
						case Else
							$return_title="Failure"
					endswitch
					switch $return_code
						Case 2
							$return_msg="Failure due to either:" & @crlf & _
							"* The server actively denied our connection." & @crlf & _
							"* The mail server doesn't like the sender name."
						Case 1
							$return_msg="Failure due to either:" & @crlf & _
							"* Unable to open SMTP socket" & @crlf & _
							"* SMTP get line did not return 220" & @crlf & _
							"* command unable to write to socket" & @crlf & _
							"* Server does not like To: address" & @crlf & _
							"* Mail server error accepting message data"
						Case 0
							$return_msg="The message was sent."
						Case 12
							$return_msg="-server or -f options not specified and not found in registry"
						Case 14 ; documented in ChangeLog.txt
							$return_msg="Unicode is not supported with Windows earlier than Windows 2000"
						case Else
							$return_msg=""
					endswitch
					if $return_msg<>"" then $return_msg&=@crlf & @crlf
  					$return_msg &= "(Code " & $return_code & ")" & _
					@crlf & @crlf & _
 					"- From https://www.blat.net/examples/blat_return_codes.htm"
					Msgbox(0, $return_title, $return_msg, default, $MainWindow)
					If GUICtrlRead($Checkbox_shutdown, 0) = $GUI_CHECKED Then
						Shutdown(1)
						Exit
					EndIf
				EndIf
			EndIf

		Case $msg = $Checkbox_bodytext

			If GUICtrlRead($Checkbox_bodytext) = $GUI_CHECKED Then
				GUICtrlSetState($Checkbox_bodypath, $GUI_UNCHECKED)
				GUICtrlSetState($Input_bodytext, $GUI_ENABLE)
				GUICtrlSetState($Input_file, $GUI_DISABLE)
			Else
				GUICtrlSetState($Input_bodytext, $GUI_DISABLE)
			EndIf

		Case $msg = $Checkbox_bodypath

			If GUICtrlRead($Checkbox_bodypath) = $GUI_CHECKED Then
				GUICtrlSetState($Checkbox_bodytext, $GUI_UNCHECKED)
				GUICtrlSetState($Input_file, $GUI_ENABLE)
				GUICtrlSetState($Input_bodytext, $GUI_DISABLE)
			Else
				GUICtrlSetState($Input_file, $GUI_DISABLE)
			EndIf

		Case $msg = $Button_editbody

			editor(GUICtrlRead($Input_file, 1), GUICtrlRead($Input_editorpath, 1), "body")

		Case $msg = $Button_choosebodypath

			$new_bodypath = FileOpenDialog("Select File", "", "All (*.*)", 0, "", $MainWindow)
			If Not $new_bodypath = "" Then
				$bodypath = $new_bodypath
				GUICtrlSetData($Input_file, localize($Input_blatpath, $bodypath, false))
				GUICtrlSetState($Checkbox_bodytext, $GUI_UNCHECKED)
				GUICtrlSetState($Input_file, $GUI_ENABLE)
				GUICtrlSetState($Checkbox_bodypath, $GUI_CHECKED)
				GUICtrlSetState($Input_bodytext, $GUI_DISABLE)
			EndIf

		Case $msg = $Checkbox_attachment

			If GUICtrlRead($Checkbox_attachment) = $GUI_CHECKED Then
				GUICtrlSetState($Input_attachment, $GUI_ENABLE)
			Else
				GUICtrlSetState($Input_attachment, $GUI_DISABLE)
			EndIf

		Case $msg = $Button_serverinfo

			If StringInStr(GUICtrlRead($Input_server), ".") = 0 Then
				MsgBox(262144, "Error", "Enter a valid server name first.", default, $MainWindow)
			Else
				GUICtrlSetState($Button_serverinfo, $GUI_DISABLE)
				$serverclean = StringSplit(GUICtrlRead($Input_server), ":")
				$getping = Ping($serverclean[1])
				If $getping = 0 And @error = 1 Then
					$ping = "ERROR - Host is offline"
				ElseIf $getping = 0 And @error = 2 Then
					$ping = "ERROR - Host is unreachable"
				ElseIf $getping = 0 And @error = 3 Then
					$ping = "ERROR - Bad destination"
				ElseIf $getping = 0 And @error = 4 Then
					$ping = "ERROR"
				Else
					$ping = $getping & " milliseconds"
				EndIf

				TCPStartup()
				$sip = TCPNameToIP($serverclean[1])
				$servername = _TCPIpToName($sip)
				If $servername = "" Then
					$servername = "Unknown"
				endif
				If $sip = "" Then
					$sip = "ERROR"
					$servername = "ERROR"
				EndIf
				TCPShutdown()
				MsgBox(262144, "Server Info", "Server name: " & $servername & @CRLF & "IP: " & $sip & @CRLF & "Ping: " & $ping, default, $MainWindow)
				GUICtrlSetState($Button_serverinfo, $GUI_ENABLE)
			EndIf

		Case $msg = $Button_hostinfo

			GUICtrlSetState($Button_hostinfo, $GUI_DISABLE)
			$hip = _GetIP()
			If $hip = -1 Then
				$hip = "ERROR"
			EndIf
			MsgBox(262144, "Host Info", "Computer name: " & @ComputerName & @CRLF & "IP: " & $hip, default, $MainWindow)
			GUICtrlSetState($Button_hostinfo, $GUI_ENABLE)

		Case $msg = $Button_signature

			editor(GUICtrlRead($Input_signature, 1), GUICtrlRead($Input_editorpath, 1), "signature")

		Case $msg = $Checkbox_signature

			If GUICtrlRead($Checkbox_signature) = $GUI_CHECKED Then
				GUICtrlSetState($Input_signature, $GUI_ENABLE)
			Else
				GUICtrlSetState($Input_signature, $GUI_DISABLE)
			EndIf

		Case $msg = $Checkbox_maxNames

			If GUICtrlRead($Checkbox_maxNames) = $GUI_CHECKED Then
				GUICtrlSetState($Input_maxNames, $GUI_ENABLE)
			Else
				GUICtrlSetState($Input_maxNames, $GUI_DISABLE)
			EndIf

		Case $msg = $Checkbox_multipart_yes

			If GUICtrlRead($Checkbox_multipart_yes) = $GUI_CHECKED Then
				GUICtrlSetState($Checkbox_multipart_no, $GUI_UNCHECKED)
				GUICtrlSetState($Input_multipart, $GUI_ENABLE)
			Else
				GUICtrlSetState($Input_multipart, $GUI_DISABLE)
			EndIf

		Case $msg = $Checkbox_multipart_no

			If GUICtrlRead($Checkbox_multipart_no) = $GUI_CHECKED Then
				GUICtrlSetState($Checkbox_multipart_yes, $GUI_UNCHECKED)
				GUICtrlSetState($Input_multipart, $GUI_DISABLE)
			EndIf

		Case $msg = $Button_log

			editor(GUICtrlRead($Input_log, 1), GUICtrlRead($Input_editorpath, 1), "log")

		Case $msg = $Checkbox_xmailer

			If GUICtrlRead($Checkbox_xmailer) = $GUI_CHECKED Then
				GUICtrlSetState($Checkbox_xmailerurl, $GUI_DISABLE)
			Else
				GUICtrlSetState($Checkbox_xmailerurl, $GUI_ENABLE)
			EndIf

		Case $msg = $Checkbox_log

			If GUICtrlRead($Checkbox_log) = $GUI_CHECKED Then
				GUICtrlSetState($Input_log, $GUI_ENABLE)
				GUICtrlSetState($Checkbox_timestamp, $GUI_ENABLE)
				GUICtrlSetState($Checkbox_overwritelog, $GUI_ENABLE)
				GUICtrlSetState($input_debug, $GUI_ENABLE)
			Else
				GUICtrlSetState($Input_log, $GUI_DISABLE)
				GUICtrlSetState($Checkbox_timestamp, $GUI_DISABLE)
				GUICtrlSetState($Checkbox_overwritelog, $GUI_DISABLE)
				GUICtrlSetState($input_debug, $GUI_DISABLE)
			EndIf

		Case $msg = $Checkbox_registry

			If GUICtrlRead($Checkbox_registry, 0)=$GUI_CHECKED Then
				GUICtrlSetState($Input_profile, $GUI_ENABLE)
			Else
				GUICtrlSetState($Input_profile, $GUI_DISABLE)
			EndIf

		Case $msg = $Checkbox_shutdown

			If GUICtrlRead($Checkbox_shutdown) = $GUI_CHECKED Then
				GUICtrlSetState($Input_shutdown, $GUI_ENABLE)
			Else
				GUICtrlSetState($Input_shutdown, $GUI_DISABLE)
			EndIf

		Case $msg = $Button_chooseattachmentpath

			$new_attachmentpath = FileOpenDialog("Select Attachment", "", "All (*.*)", 0, "", $MainWindow)
			If Not $new_attachmentpath = "" Then
				$attachmentpath = $new_attachmentpath
				GUICtrlSetData($Input_attachment, localize($Input_blatpath, $attachmentpath, false))
				GUICtrlSetState($Checkbox_attachment, $GUI_CHECKED)
				GUICtrlSetState($Input_attachment, $GUI_ENABLE)
			EndIf

		Case $msg = $Button_choosesignaturepath

			$new_signaturepath = FileOpenDialog("Select Signature File", "", "All (*.*)", 0, "", $MainWindow)
			If Not $new_signaturepath = "" Then
				$signaturepath = $new_signaturepath
				GUICtrlSetData($Input_signature, localize($Input_blatpath, $signaturepath, false))
				GUICtrlSetState($Checkbox_signature, $GUI_CHECKED)
				GUICtrlSetState($Input_signature, $GUI_ENABLE)
			EndIf

		Case $msg = $Button_chooselogpath

			$new_logpath = FileOpenDialog("Select Log File", "", "All (*.*)", 0, "", $MainWindow)
			If Not $new_logpath = "" Then
				$logpath = $new_logpath
				GUICtrlSetData($Input_log, localize($Input_blatpath, $logpath, false))
				GUICtrlSetState($Checkbox_log, $GUI_CHECKED)
				GUICtrlSetState($Input_log, $GUI_ENABLE)
				GUICtrlSetState($Checkbox_timestamp, $GUI_ENABLE)
				GUICtrlSetState($Checkbox_overwritelog, $GUI_ENABLE)
				GUICtrlSetState($input_debug, $GUI_ENABLE)
			EndIf

		Case $msg = $Button_chooseblatpath

			$new_blatpath = FileOpenDialog("Select Blat", "", "DLL (*.dll)|All (*.*)", 0, $default_blatpath, $MainWindow)
			If Not $new_blatpath = "" Then
				$blatpath = $new_blatpath
				GUICtrlSetData($Input_blatpath, localize(@scriptfullpath, $blatpath, false))
			EndIf

		Case $msg = $Button_chooseblatexepath

			$new_blatexepath = FileOpenDialog("Select Blat", "", "Executables (*.exe)|All (*.*)", 0, $default_blatexepath, $MainWindow)
			If Not $new_blatexepath = "" Then
				$blatexepath = $new_blatexepath
				GUICtrlSetData($Input_blatexepath, localize(@scriptfullpath, $blatexepath, false))
			EndIf

		Case $msg = $Button_chooseeditorpath

			$new_editorpath = FileOpenDialog("Select Editor", "", "Executables (*.exe)|All (*.*)", 0, "", $MainWindow)
			If Not $new_editorpath = "" Then
				$editorpath = $new_editorpath
				GUICtrlSetData($Input_editorpath, localize(@scriptfullpath, $editorpath, false))
			EndIf

		Case $msg = $Button_choosehelppath

			$new_helppath = FileOpenDialog("Select Help File", "", "All (*.*)", 0, "", $MainWindow)
			If Not $new_helppath = "" Then
				$helppath = $new_helppath
				GUICtrlSetData($Input_helppath, localize(@scriptfullpath, $helppath, false))
			EndIf

	EndSelect

   case $simulator_MainWindow
	simulator_choices($msg)

  EndSwitch

WEnd


; --- Functions ---

Func StringEncrypt($fEncrypt, $sData)
	if $sData="" then
		return $sData
	endif

    Local $sReturn = ''
    If $fEncrypt Then
        $sReturn = _Crypt_EncryptData($sData, $sPassword, $CALG_RC4)
    Else
        If IsString($sData) Then
            $sData=Binary($sData)
        EndIf
        $sReturn = BinaryToString(_Crypt_DecryptData($sData, $sPassword, $CALG_RC4))
    EndIf
    Return $sReturn
EndFunc   ;==>StringEncrypt

Func ValidateEMailInput($InpCon)

	$StSpEmail = StringSplit(GUICtrlRead($InpCon, 1), ",")
	If GUICtrlRead($InpCon, 1) = "" Then
		$val_email = 0
	Else
		$val_email = 1
		For $n = 1 To $StSpEmail[0]
			$StSpSingleEmail = StringSplit(StringStripWS($StSpEmail[$n], 1), "@")
			$StSpServerDomain = StringSplit($StSpSingleEmail[$StSpSingleEmail[0]], ".")
			If StringInStr($StSpEmail[$n], "@") = 0 Then
				$val_email = 2
			EndIf
			If StringInStr($StSpSingleEmail[$StSpSingleEmail[0]], ".") = 0 Then
				$val_email = 2
			EndIf
			If StringLen($StSpSingleEmail[1]) < 1 Then
				$val_email = 2
			EndIf
			If StringLen($StSpServerDomain[$StSpServerDomain[0]]) < 2 Then
				$val_email = 2
			EndIf
			If StringLen($StSpServerDomain[1]) < 1 Then
				$val_email = 2
			EndIf
		Next
	EndIf
	Return $val_email

EndFunc   ;==>ValidateEMailInput


Func SaveConfig($configfile)

	If GUICtrlRead($Checkbox_bodytext, 0) = $GUI_CHECKED Then
		save2ini($configfile, "settings", "usebodytext", "yes")
	Else
		save2ini($configfile, "settings", "usebodytext", "no")
	EndIf

	save2ini($configfile, "settings", "bodytext", stringreplace(GUICtrlRead($Input_bodytext, 1), @crlf, chr(01)))

	If GUICtrlRead($Checkbox_bodypath, 0) = $GUI_CHECKED Then
		save2ini($configfile, "settings", "usebodypath", "yes")
	Else
		save2ini($configfile, "settings", "usebodypath", "no")
	EndIf
	GUICtrlSetData($Input_file, localize($Input_blatpath, $Input_file, false, false))
	save2ini($configfile, "paths", "bodypath", GUICtrlRead($Input_file, 1))
	save2ini($configfile, "settings", "html/enriched", GUICtrlRead($input_content_type, 1))
	save2ini($configfile, "settings", "from", GUICtrlRead($Input_from, 1))
	save2ini($configfile, "settings", "organization", GUICtrlRead($Input_organization, 1))
	save2ini($configfile, "settings", "replyto", GUICtrlRead($Input_replyto, 1))
	save2ini($configfile, "settings", "to", GUICtrlRead($Input_to, 1))
	save2ini($configfile, "settings", "cc", GUICtrlRead($Input_cc, 1))
	save2ini($configfile, "settings", "bcc", GUICtrlRead($Input_bcc, 1))
	save2ini($configfile, "settings", "subject", GUICtrlRead($Input_subject, 1))

	If GUICtrlRead($Checkbox_attachment, 0) = $GUI_CHECKED Then
		save2ini($configfile, "settings", "useattachmentpath", "yes")
	Else
		save2ini($configfile, "settings", "useattachmentpath", "no")
	EndIf
	GUICtrlSetData($Input_attachment, localize($Input_blatpath, $Input_attachment, false, false))
	save2ini($configfile, "paths", "attachmentpath", GUICtrlRead($Input_attachment, 1))

	save2ini($configfile, "settings", "server", GUICtrlRead($Input_server, 1))
	save2ini($configfile, "settings", "port", GUICtrlRead($Input_port, 1))
	save2ini($configfile, "settings", "host", GUICtrlRead($Input_host, 1))

	If GUICtrlRead($Checkbox_maxNames, 0) = $GUI_UNCHECKED Then
		save2ini($configfile, "settings", "usemaxNames", "no")
	Else
		save2ini($configfile, "settings", "usemaxNames", "yes")
	EndIf
	save2ini($configfile, "settings", "maxNames", GUICtrlRead($Input_maxNames, 1))

	If GUICtrlRead($Checkbox_signature, 0) = $GUI_UNCHECKED Then
		save2ini($configfile, "settings", "usesignature", "no")
	Else
		save2ini($configfile, "settings", "usesignature", "yes")
	EndIf
	GUICtrlSetData($Input_signature, localize($Input_blatpath, $Input_signature, false, false))
	save2ini($configfile, "paths", "signaturepath", GUICtrlRead($Input_signature, 1))

	If GUICtrlRead($Checkbox_multipart_yes, 0) = $GUI_CHECKED Then
		save2ini($configfile, "settings", "multipart", "yes")
	ElseIf GUICtrlRead($Checkbox_multipart_no, 0) = $GUI_CHECKED Then
		save2ini($configfile, "settings", "multipart", "no")
	EndIf
	save2ini($configfile, "settings", "multipartsize", GUICtrlRead($Input_multipart, 1))

	If GUICtrlRead($Checkbox_log, 0) = $GUI_UNCHECKED Then
		save2ini($configfile, "settings", "uselog", "no")
	Else
		save2ini($configfile, "settings", "uselog", "yes")
	EndIf
	GUICtrlSetData($Input_log, localize($Input_blatpath, $Input_log, false, false))
	save2ini($configfile, "paths", "logpath", GUICtrlRead($Input_log, 1))
	If GUICtrlRead($Checkbox_timestamp, 0) = $GUI_UNCHECKED Then
		save2ini($configfile, "settings", "usetimestamp", "no")
	Else
		save2ini($configfile, "settings", "usetimestamp", "yes")
	EndIf
	If GUICtrlRead($Checkbox_overwritelog, 0) = $GUI_UNCHECKED Then
		save2ini($configfile, "settings", "overwritelog", "no")
	Else
		save2ini($configfile, "settings", "overwritelog", "yes")
	EndIf
	save2ini($configfile, "settings", "debug", GUICtrlRead($input_debug))
	If GUICtrlRead($Checkbox_xmailer, 0) = $GUI_UNCHECKED Then
		save2ini($configfile, "settings", "hidexmailer", "no")
	Else
		save2ini($configfile, "settings", "hidexmailer", "yes")
	EndIf
	If GUICtrlRead($Checkbox_xmailerurl, 0) = $GUI_UNCHECKED Then
		save2ini($configfile, "settings", "hidexmailerurl", "no")
	Else
		save2ini($configfile, "settings", "hidexmailerurl", "yes")
	EndIf

	If GUICtrlRead($Checkbox_disposition, 0) = $GUI_UNCHECKED Then
		save2ini($configfile, "settings", "disposition", "no")
	Else
		save2ini($configfile, "settings", "disposition", "yes")
	EndIf

	If GUICtrlRead($Checkbox_receipt, 0) = $GUI_UNCHECKED Then
		save2ini($configfile, "settings", "receipt", "no")
	Else
		save2ini($configfile, "settings", "receipt", "yes")
	EndIf

	save2ini($configfile, "settings", "retry", GUICtrlRead($Input_try, 1))

	If GUICtrlRead($input_charset, 1)="" or GUICtrlRead($input_charset, 1)="*custom*" Then
		guictrlsetdata($input_charset, $default_charset)
	endif
	save2ini($configfile, "settings", "charset", GUICtrlRead($Input_charset, 1))
	if GUICtrlRead($Input_priority, 1)="None" OR GUICtrlRead($Input_priority, 1)="low" OR GUICtrlRead($Input_priority, 1)="high" then
		save2ini($configfile, "settings", "priority", GUICtrlRead($Input_priority, 1))
	endif
	save2ini($configfile, "settings", "finalheader1", GUICtrlRead($Input_finalheader1, 1))
	save2ini($configfile, "settings", "finalheader2", GUICtrlRead($Input_finalheader2, 1))
	save2ini($configfile, "settings", "arguments", GUICtrlRead($Input_arguments, 1))
	if GUICtrlRead($Checkbox_registry, 0) = $GUI_UNCHECKED then
		save2ini($configfile, "settings", "registry", "no")
	else
		save2ini($configfile, "settings", "registry", "yes")
	endif
	If GUICtrlRead($input_profile, 1)="" or GUICtrlRead($input_profile, 1)="*custom*" Then
		guictrlsetdata($input_profile, $default_profile)
	elseif GUICtrlRead($input_profile, 1)<>$default_profile then
		save2ini($configfile, "settings", "profile", GUICtrlRead($Input_profile, 1))
	endif

	save2ini($configfile, "settings", "authuser", GUICtrlRead($Input_authuser, 1))
	save2ini($configfile, "settings", "authpass", StringEncrypt(True, GUICtrlRead($Input_authpass, 1)))

	save2ini($configfile, "settings", "pop3user", GUICtrlRead($Input_pop3user, 1))
	save2ini($configfile, "settings", "pop3pass", StringEncrypt(True, GUICtrlRead($Input_pop3pass, 1)))

	save2ini($configfile, "settings", "imapuser", GUICtrlRead($Input_imapuser, 1))
	save2ini($configfile, "settings", "imappass", StringEncrypt(True, GUICtrlRead($Input_imappass, 1)))

	GUICtrlSetData($Input_blatpath, localize(@scriptfullpath, $Input_blatpath, false, false))
	save2ini($configfile, "paths", "blatpath", GUICtrlRead($Input_blatpath, 1))
	GUICtrlSetData($Input_blatexepath, localize(@scriptfullpath, $Input_blatexepath, false, false))
	save2ini($configfile, "paths", "blatexepath", GUICtrlRead($Input_blatexepath, 1))
	GUICtrlSetData($Input_editorpath, localize(@scriptfullpath, $Input_editorpath, false, false))
	save2ini($configfile, "paths", "editorpath", GUICtrlRead($Input_editorpath, 1))
	GUICtrlSetData($Input_helppath, localize(@scriptfullpath, $Input_helppath, false, false))
	save2ini($configfile, "paths", "helppath", GUICtrlRead($Input_helppath, 1))

	If GUICtrlRead($Checkbox_absolutepaths, 0) = $GUI_UNCHECKED Then
		save2ini($configfile, "settings", "absolutepaths", "no")
	Else
		save2ini($configfile, "settings", "absolutepaths", "yes")
	EndIf

	If GUICtrlRead($Checkbox_shutdown, 0) = $GUI_UNCHECKED Then
		save2ini($configfile, "settings", "shutdown", "no")
	Else
		save2ini($configfile, "settings", "shutdown", "yes")
	EndIf
	save2ini($configfile, "settings", "shutdowndelay", GUICtrlRead($Input_shutdown, 1))

EndFunc   ;==>SaveConfig


Func LoadConfig($configfile)

	If IniRead($configfile, "settings", "usebodytext", "yes") = "yes" Then
		GUICtrlSetState($Checkbox_bodytext, $GUI_CHECKED)
		GUICtrlSetState($Input_bodytext, $GUI_ENABLE)
	Else
		GUICtrlSetState($Checkbox_bodytext, $GUI_UNCHECKED)
		GUICtrlSetState($Input_bodytext, $GUI_DISABLE)
	EndIf

	GUICtrlSetData($Input_bodytext, stringreplace(IniRead($configfile, "settings", "bodytext", ""), chr(01), @crlf))

	GUICtrlSetData($Input_file, IniRead($configfile, "paths", "bodypath", $default_bodypath))
	If IniRead($configfile, "settings", "usebodypath", "no") = "yes" Then
		GUICtrlSetState($Checkbox_bodypath, $GUI_CHECKED)
		GUICtrlSetState($Input_file, $GUI_ENABLE)
	Else
		GUICtrlSetState($Checkbox_bodypath, $GUI_UNCHECKED)
		GUICtrlSetState($Input_file, $GUI_DISABLE)
	EndIf
	GUICtrlSetData($Input_content_type, IniRead($configfile, "settings", "html/enriched", $default_content_type))
	GUICtrlSetData($Input_from, IniRead($configfile, "settings", "from", ""))
	GUICtrlSetData($Input_organization, IniRead($configfile, "settings", "organization", ""))
	GUICtrlSetData($Input_replyto, IniRead($configfile, "settings", "replyto", ""))
	GUICtrlSetData($Input_to, IniRead($configfile, "settings", "to", ""))
	GUICtrlSetData($Input_cc, IniRead($configfile, "settings", "cc", ""))
	GUICtrlSetData($Input_bcc, IniRead($configfile, "settings", "bcc", ""))
	GUICtrlSetData($Input_subject, IniRead($configfile, "settings", "subject", ""))
	GUICtrlSetData($Input_attachment, IniRead($configfile, "paths", "attachmentpath", $default_attachmentpath))
	If IniRead($configfile, "settings", "useattachmentpath", "no") = "yes" Then
		GUICtrlSetState($Checkbox_attachment, $GUI_CHECKED)
		GUICtrlSetState($Input_attachment, $GUI_ENABLE)
	Else
		GUICtrlSetState($Checkbox_attachment, $GUI_UNCHECKED)
		GUICtrlSetState($Input_attachment, $GUI_DISABLE)
	EndIf

	If IniRead($configfile, "settings", "usesignature", "no") = "yes" Then
		GUICtrlSetState($Checkbox_signature, $GUI_CHECKED)
		GUICtrlSetState($Input_signature, $GUI_ENABLE)
	Else
		GUICtrlSetState($Checkbox_signature, $GUI_UNCHECKED)
		GUICtrlSetState($Input_signature, $GUI_DISABLE)
	EndIf
	GUICtrlSetData($Input_signature, IniRead($configfile, "paths", "signaturepath", $default_signaturepath))
	GUICtrlSetData($Input_server, IniRead($configfile, "settings", "server", ""))
	GUICtrlSetData($Input_port, IniRead($configfile, "settings", "port", ""))
	GUICtrlSetData($Input_host, IniRead($configfile, "settings", "host", ""))

	If IniRead($configfile, "settings", "usemaxNames", "no") = "yes" Then
		GUICtrlSetState($Checkbox_maxNames, $GUI_CHECKED)
		GUICtrlSetState($Input_maxNames, $GUI_ENABLE)
	Else
		GUICtrlSetState($Checkbox_maxNames, $GUI_UNCHECKED)
		GUICtrlSetState($Input_maxNames, $GUI_DISABLE)
	EndIf
	GUICtrlSetData($Input_maxNames, IniRead($configfile, "settings", "maxNames", ""))

	GUICtrlSetData($Input_multipart, IniRead($configfile, "settings", "multipartsize", ""))
	If IniRead($configfile, "settings", "multipart", "") = "yes" Then
		GUICtrlSetState($Checkbox_multipart_yes, $GUI_CHECKED)
		GUICtrlSetState($Checkbox_multipart_no, $GUI_UNCHECKED)
		GUICtrlSetState($Input_multipart, $GUI_ENABLE)
	ElseIf IniRead($configfile, "settings", "multipart", "") = "no" Then
		GUICtrlSetState($Checkbox_multipart_yes, $GUI_UNCHECKED)
		GUICtrlSetState($Checkbox_multipart_no, $GUI_CHECKED)
		GUICtrlSetState($Input_multipart, $GUI_DISABLE)
	Else
		GUICtrlSetState($Checkbox_multipart_yes, $GUI_UNCHECKED)
		GUICtrlSetState($Checkbox_multipart_no, $GUI_UNCHECKED)
		GUICtrlSetState($Input_multipart, $GUI_DISABLE)
	EndIf

	If IniRead($configfile, "settings", "uselog", "no") = "yes" Then
		GUICtrlSetState($Checkbox_log, $GUI_CHECKED)
		GUICtrlSetState($Input_log, $GUI_ENABLE)
		GUICtrlSetState($Checkbox_timestamp, $GUI_ENABLE)
		GUICtrlSetState($Checkbox_overwritelog, $GUI_ENABLE)
		GUICtrlSetState($input_debug, $GUI_ENABLE)
	Else
		GUICtrlSetState($Checkbox_log, $GUI_UNCHECKED)
		GUICtrlSetState($Input_log, $GUI_DISABLE)
		GUICtrlSetState($Checkbox_timestamp, $GUI_DISABLE)
		GUICtrlSetState($Checkbox_overwritelog, $GUI_DISABLE)
		GUICtrlSetState($input_debug, $GUI_DISABLE)
	EndIf
	GUICtrlSetData($Input_log, IniRead($configfile, "paths", "logpath", $default_logpath))
	If IniRead($configfile, "settings", "usetimestamp", "no") = "yes" Then
		GUICtrlSetState($Checkbox_timestamp, $GUI_CHECKED)
	Else
		GUICtrlSetState($Checkbox_timestamp, $GUI_UNCHECKED)
	EndIf
	If IniRead($configfile, "settings", "overwritelog", "no") = "yes" Then
		GUICtrlSetState($Checkbox_overwritelog, $GUI_CHECKED)
	Else
		GUICtrlSetState($Checkbox_overwritelog, $GUI_UNCHECKED)
	EndIf
	GUICtrlSetData($input_debug, IniRead($configfile, "settings", "debug", $default_debug))
	If IniRead($configfile, "settings", "hidexmailer", "no") = "yes" Then
		GUICtrlSetState($Checkbox_xmailer, $GUI_CHECKED)
		GUICtrlSetState($Checkbox_xmailerurl, $GUI_DISABLE)
	Else
		GUICtrlSetState($Checkbox_xmailer, $GUI_UNCHECKED)
		GUICtrlSetState($Checkbox_xmailerurl, $GUI_ENABLE)
	EndIf
	If IniRead($configfile, "settings", "hidexmailerurl", "no") = "yes" Then
		GUICtrlSetState($Checkbox_xmailerurl, $GUI_CHECKED)
	Else
		GUICtrlSetState($Checkbox_xmailerurl, $GUI_UNCHECKED)
	EndIf
	If IniRead($configfile, "settings", "disposition", "no") = "yes" Then
		GUICtrlSetState($Checkbox_disposition, $GUI_CHECKED)
	Else
		GUICtrlSetState($Checkbox_disposition, $GUI_UNCHECKED)
	EndIf
	If IniRead($configfile, "settings", "receipt", "no") = "yes" Then
		GUICtrlSetState($Checkbox_receipt, $GUI_CHECKED)
	Else
		GUICtrlSetState($Checkbox_receipt, $GUI_UNCHECKED)
	EndIf
	GUICtrlSetData($Input_try, IniRead($configfile, "settings", "retry", "1"))

	$charsets_temp="|" & $charsets
	$new_charset=IniRead($configfile, "settings", "charset", $default_charset)
	if StringRegExp($charsets, $new_charset & "(\||$)")=0 Then
		$charsets_temp&="|" & $new_charset
	endif
	GUICtrlSetData($input_charset, $charsets_temp, $new_charset)
	GUICtrlSetData($Input_priority, IniRead($configfile, "settings", "priority", "None"))
	GUICtrlSetData($input_finalheader1, IniRead($configfile, "settings", "finalheader1", ""))
	GUICtrlSetData($input_finalheader2, IniRead($configfile, "settings", "finalheader2", ""))
	GUICtrlSetData($Input_arguments, IniRead($configfile, "settings", "arguments", ""))
	$profiles_temp="|" & $profiles
	$new_profile=IniRead($configfile, "settings", "profile", $default_profile)
	if StringRegExp($profiles, $new_profile & "(\||$)")=0 Then
		$profiles_temp&="|" & $new_profile
	endif
	GUICtrlSetData($input_profile, $profiles_temp, $new_profile)
	If IniRead($configfile, "settings", "registry", "no") = "yes" Then
		GUICtrlSetState($Checkbox_registry, $GUI_CHECKED)
		GUICtrlSetState($Input_profile, $GUI_ENABLE)
	else
		GUICtrlSetState($Checkbox_registry, $GUI_UNCHECKED)
		GUICtrlSetState($Input_profile, $GUI_DISABLE)
	endif

	GUICtrlSetData($Input_authuser, IniRead($configfile, "settings", "authuser", ""))
	GUICtrlSetData($Input_authpass, StringEncrypt(False, IniRead($configfile, "settings", "authpass", "")))

	GUICtrlSetData($Input_pop3user, IniRead($configfile, "settings", "pop3user", ""))
	GUICtrlSetData($Input_pop3pass, StringEncrypt(False, IniRead($configfile, "settings", "pop3pass", "")))

	GUICtrlSetData($Input_imapuser, IniRead($configfile, "settings", "imapuser", ""))
	GUICtrlSetData($Input_imappass, StringEncrypt(False, IniRead($configfile, "settings", "imappass", "")))

	GUICtrlSetData($Input_blatpath, IniRead($configfile, "paths", "blatpath", $default_blatpath))
	GUICtrlSetData($Input_blatexepath, IniRead($configfile, "paths", "blatexepath", $default_blatexepath))
	GUICtrlSetData($Input_editorpath, IniRead($configfile, "paths", "editorpath", $default_editorpath))
	GUICtrlSetData($Input_helppath, IniRead($configfile, "paths", "helppath", $default_helppath))

	If IniRead($configfile, "settings", "absolutepaths", "no") = "yes" Then
		GUICtrlSetState($Checkbox_absolutepaths, $GUI_CHECKED)
	Else
		GUICtrlSetState($Checkbox_absolutepaths, $GUI_UNCHECKED)
	EndIf

	If IniRead($configfile, "settings", "shutdown", "no") = "yes" Then
		GUICtrlSetState($Checkbox_shutdown, $GUI_CHECKED)
		GUICtrlSetState($Input_shutdown, $GUI_ENABLE)
	Else
		GUICtrlSetState($Checkbox_shutdown, $GUI_UNCHECKED)
		GUICtrlSetState($Input_shutdown, $GUI_DISABLE)
	EndIf
	GUICtrlSetData($Input_shutdown, IniRead($configfile, "settings", "shutdowndelay", "30"))

	GUICtrlSetData($Input_commandline, "")

EndFunc   ;==>LoadConfig

func defaultpath($path)
	if $path<>"" and StringInStr($path, "\")=0 Then
		$path=@scriptdir & "\" & $path
	endif
	return $path
endfunc

func editor($file, $editor, $description)
	$file=pathfull(defaultpath(_WinAPI_ExpandEnvironmentStrings($file)), $Input_blatpath)
	$editor=pathfull(defaultpath(_WinAPI_ExpandEnvironmentStrings($editor)))
	if fileexists($file) Then
		if fileexists($editor) Then
			ShellExecute($editor, $file)
		Else
			ShellExecute($file, "", "", "edit")
		EndIf
	Else
		MsgBox(262144, "File not found", "Could not find " & $description & " file.", default, $MainWindow)
	EndIf
EndFunc

func localize($file1, $file2, $quotations=true, $alreadyread=true)
	$file1=GUICtrlRead($file1, 1)
	if $quotations or not $alreadyread then
		$file2=GUICtrlRead($file2, 1)
	endif

	if GUICtrlRead($Checkbox_absolutepaths, 0) = $GUI_UNCHECKED then
		$file1=_WinAPI_ExpandEnvironmentStrings($file1)
		$file1=defaultpath($file1)
		$path1 = StringRegExpReplace($file1, "(^.*)\\(.*)", "\1")
		$file2=_PathGetRelative($path1, $file2)
	EndIf

	if $quotations then
		$file2 = '"' & $file2 & '"'
	endif
	return $file2
endfunc

func filtertext($text)
	$text=stringreplace($text, '"', '\"')
	$text=stringreplace($text, @crlf, "|")
	return $text
endfunc

func filterpriority($text)
	$text=stringreplace($text, "low", 0)
	$text=stringreplace($text, "high", 1)
	return $text
endfunc

func save2ini($file, $section, $name, $value)
	if iniread($file, $section, $name, "")<>$value Then
		if $value="" Then
			inidelete($file, $section, $name)
		else
			IniWrite($file, $section, $name, $value)
		endif
	endif
endfunc

func command_add($command, $special="")
	if $special="default" and ($command=$default_profile or $command="*Custom*") Then
		$command=""
	elseif $special="numeric" and $command=0 Then
		$command=""
	elseif stringinstr($command, " ") Then
		$command = '"' & $command & '"'
	endif
	$str = " "
	If $command = "" Then
		$str &= "-"
	else
		$str &= $command
	endif
	return $str
EndFunc

func pathfull($path, $originalpath=@scriptdir)
	if $originalpath<>@scriptdir then
		$originalpath = GUICtrlRead($originalpath, 1)
		$originalpath=defaultpath($originalpath)
		$originalpath = StringRegExpReplace($originalpath, "(^.*)\\(.*)", "\1")
	endif
	return _PathFull($path, $originalpath)
endfunc

func FileExistsRelative($path, $originalpath=@scriptdir)
	$exists=false
	if fileexists(pathfull($path, $originalpath)) then
		$exists=True
	endif
	return $exists
EndFunc

Func launchdll($command, $visual=false)
	$return_code=""
	$blatpath_temp=defaultpath(_WinAPI_ExpandEnvironmentStrings(GUICtrlRead($Input_blatpath, 1)))
	if FileExistsRelative($blatpath_temp) Then
		if $visual then
			GUICtrlSetState($Button_send, $GUI_DISABLE)
		endif
;		$return_code = DllCall($blatpath_temp,"int","SendW","wstr", $command) ; W/w is for Unicode support
;		$return_code = $return_code[0]
		if ($used_simulator) then
			if @Compiled Then
				$return_code = ShellExecuteWait(@ScriptName, chr(34) & $blatpath_temp & chr(34) & " " & StringEncrypt(True, $command))
			Else
				$return_code = ShellExecuteWait(@AutoItExe, chr(34) & @ScriptName & chr(34) & " " & chr(34) & $blatpath_temp & chr(34) & " " & StringEncrypt(True, $command))
			EndIf
		Else
			$return_code = launchdll_execute($blatpath_temp, $command)
		endif
		if $visual then
			GUICtrlSetState($Button_send, $GUI_ENABLE)
		endif
	Else
		MsgBox(262144, "File not found", "Could not find Blat.", default, $MainWindow)
	endif
	return $return_code
endfunc

Func launchdll_execute($path, $command)
	local $return_code = DllCall($path,"int","SendW","wstr", $command) ; W/w is for Unicode support
	return $return_code[0]
EndFunc

Func about()
  GUICreate("About " & $programname, 435, 410, -1, -1, -1, $WS_EX_MDICHILD, $MainWindow)
  $localleft=10
  $localtop=10
  $message=$programname & " - Version " & $version & @crlf & _
  @crlf & _
  $programname & " is a portable frontend for the command line mail client Blat."
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
