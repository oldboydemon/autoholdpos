#SingleInstance,Force
#Include JSON.ahk
#Include GuiButtonIcon.ahk
#NoTrayIcon

; Variable to check whether script is active
scriptEnabled := 0

; Layout Variables
mainWidth := 300
mainHeight := 375
defaultXPadding := 10
defaultYPadding := 10
headingY := 10
checkboxColumnX := defaultXPadding
abilityColumnX := 50
bindingColumnX := 120
abilityColumnWidth := 62
bindingColumnWidth := 100
rebindColumnX := 250
inputPopupWidth := 250
inputPopupHeight := 100
inputPopupVPadding := 20
customPopupWidth := 220
customPopupHeight := 100
customPopupVPadding := 20
abilityLineVPadding := 10
buttonVPadding := 7
buttonHPadding := 10
rebindPopUpTitle := "Rebind Key"
settingsButtonHW := 30
settingsButtonPadding := 10
settingsPopUpH := 180
settingsPopUpW := 200
settingsPopUpTitle := "Settings"

; Checkbox Variables
abilityCheckArr := {0: 0, 1: 0, 2: 0, 3: 0, 4: 0, 5: 0}

; Text Variables
windowTitleString := "AutoHoldPos"
diabloWinName := "Diablo IV"
enableAbilityString := "Ability"
enableCheckboxHString := "Enable"
currentBindingString := "Current Binding"
rebindKeyString := "Rebind"
enableKeyString := "On/Off Key"
holdPosKeybindString := "Hold Position"
enableAllString := "Check All"
disableAllString := "Uncheck All"
enableDisableHKStrings := {0: "Enable Hotkeys", 1: "Disable Hotkeys"}
enableDisableStrings := {0: "Enable", 1: "Disable"}
activeInactiveStrings := {0: "Inactive", 1: "Active"}
statusString := "Status:"
rebindPopupString := "Please press the key you use for Ability"
rebindHoldPosString := "Please press the key you use for Hold Position"
rebindActivationString := "Please pick a hotkey to enable/disable the script"
rebindCancelledString := "Key was not rebound!"
rebindConflictString := "Key is already bound!"
savedString := "Saved!"
cancelString := "Cancel"
okString := "OK"
closeString := "Close"
minimizeString := "Start Minimized"
startEnabledString := "Start Enabled"
muteString := "Mute 'Enable/Disable' Sound"
focusCheckString := "Check if Game Window is in Focus"
trayCurrentStatus := enableDisableStrings[0]
trayNameString := "AutoHoldPos"

; Color Variables
statusColors := {0: "bf1818", 1: "3bb23d"}

; Option Variables
optionsArr := {startMinimized: "0", isMuted: "0", focusCheck: "1", startEnabled: "0", releaseDelay: "30"}
releaseDelayMin := 0
releaseDelayMax := 1000
releaseDelayCharLimit := StrLen(releaseDelayMax)
releaseDelayString := "Release Delay in ms (Max " . releaseDelayMax . "):"

; Keybind Variables
listeningForRebinds := 0
ih := InputHook("L1", "{Esc}{Tab}{LControl}{RControl}{LAlt}{RAlt}{LShift}{RShift}{LWin}{RWin}{AppsKey}{Space}{F1}{F2}{F3}{F4}{F5}{F6}{F7}{F8}{F9}{F10}{F11}{F12}{Left}{Right}{Up}{Down}{Home}{End}{PgUp}{PgDn}{Del}{Ins}{BS}{CapsLock}{ScrollLock}{NumLock}{PrintScreen}{Pause}")
abilityKeyArr := {0: "1", 1: "2", 2: "3", 3: "4", 4: "q", 5: "e"}
abilityKeysHeld := {}
isHoldKeyHeld := 0
holdKeyReleaseDelay := 30
holdPositionKey := "LShift"
enableScriptKey := "F1"

; Extract and use resource files
FileInstall, resources\aud\disable.wav, %A_Temp%\disable.wav, 1
FileInstall, resources\aud\enable.wav, %A_Temp%\enable.wav, 1
FileInstall, resources\img\gear.png, %A_Temp%\gear.png, 1

; Resource Variables
enableDisableAud := {0: A_Temp "\disable.wav", 1: A_Temp "\enable.wav"}
settingsIcon := A_Temp "\gear.png"

; Save Data Variables
saveFileName := A_AppData "\AutoHoldPos\cfg.json"

; Total Ability Count
abilityCount := abilityCheckArr.Count()

InitGui()
LoadConfig()
InitHotkeys()

if (optionsArr["startMinimized"])
{
	Menu, Tray, Icon
}
else
{
	Gui, Main:Show, w%mainWidth% h%mainHeight%
}

if (optionsArr["startEnabled"])
{
	UpdateEnabledStatus(1)
}

return

InitGui()
{
	global

	Gui, Main:New,, %windowTitleString%
	GuiControl, Main:, -Default, OK

	InitGuiAbilityLines()
	InitGuiActivationButtons()
	InitGuiStatusText()
	InitGuiSettingsButton()

	Gui, Main:+OwnDialogs

	InitGuiTray()
}

InitGuiTray()
{
	global
	
	Menu, Tray, NoStandard
	Menu, Tray, NoMainWindow
	Menu, Tray, Tip, %trayNameString%
	Menu, Tray, Add, %trayCurrentStatus%, EnableDisable
	Menu, Tray, Add, Restore, Restore
	Menu, Tray, Add, Exit, MainGuiClose
	Menu, Tray, default, Restore
	Menu, Tray, Click, 2
}

InitGuiAbilityLines()
{
	global

	local checkboxX
	local rebindX
	local displayKey

	Gui, Add, Text, x%checkboxColumnX% y%headingY% vCheckboxHeader, %enableCheckboxHString%
	Gui, Add, Text, +center x%abilityColumnX% y%headingY% w%abilityColumnWidth% vAbilityHeader, %enableAbilityString%
	Gui, Add, Text, +center x%bindingColumnX% yp w%bindingColumnWidth% vBindingHeader, %currentBindingString%

	GuiControlGet, checkHeaderTransform, Pos, CheckboxHeader

	; Ability Checkboxes
	Loop, %abilityCount%
	{
		local trueIndex := A_Index - 1

		local abilityKey := abilityKeyArr[trueIndex]

		displayKey := AbilityKeyToUpperString(abilityKey)

		Gui, Add, CheckBox, y+%abilityLineVPadding% gOnAbilityCheck%trueIndex% vAbility%trueIndex%
		Gui, Add, Text, +center x%abilityColumnX% yp w%abilityColumnWidth% vAbilityText%trueIndex%, %A_Index%
		Gui, Add, Text, +center x%bindingColumnX% yp w%bindingColumnWidth% vAbilityKeyText%trueIndex%, %displayKey%
		Gui, Add, Button, x%rebindColumnX% yp gRebindKey%trueIndex% vRebindButton%trueIndex%, %rebindKeyString%

		if (%trueIndex% == 0)
		{
			checkboxX := checkboxColumnX + (checkHeaderTransformW/4)

			GuiControlGet, buttonTransform, Pos, RebindButton%trueIndex%
			rebindX := mainWidth - (buttonTransformW + defaultXPadding)
		}
		GuiControl, Move, Ability%trueIndex%, x%checkboxX%

		; Recentering Rebind Buttons Positions
		GuiControlGet, buttonTransform, Pos, RebindButton%trueIndex%
		local buttonYPos := buttonTransformY-(buttonTransformH/4)
		GuiControl, Move, RebindButton%trueIndex%, x%rebindX% y%buttonYPos%
	}

	displayKey := AbilityKeyToUpperString(holdPositionKey)

	; Hold Position Button
	Gui, Add, Text, +center x%abilityColumnX% y+%abilityLineVPadding% w%abilityColumnWidth% vHoldPosText, %holdPosKeybindString%
	Gui, Add, Text, +center x%bindingColumnX% yp w%bindingColumnWidth% vHoldPosKeyText, %displayKey%
	Gui, Add, Button, x%rebindX% yp gRebindHoldPos vRebindHoldPos, %rebindKeyString%

	GuiControlGet, buttonTransform, Pos, RebindHoldPos
	local buttonYPos := buttonTransformY-(buttonTransformH/4)
	GuiControl, Move, RebindHoldPos, y%buttonYPos%

	displayKey := AbilityKeyToUpperString(enableScriptKey)

	; Activation Key Binding
	Gui, Add, Text, +center x%abilityColumnX% y+%abilityLineVPadding% w%abilityColumnWidth% vActivationText, %enableKeyString%
	Gui, Add, Text, +center x%bindingColumnX% yp w%bindingColumnWidth% vActivationKeyText, %displayKey%
	Gui, Add, Button, x%rebindX% yp gRebindActivation vRebindActivationButton, %rebindKeyString%

	GuiControlGet, buttonTransform, Pos, RebindActivationButton
	buttonYPos := buttonTransformY-(buttonTransformH/4)
	GuiControl, Move, RebindActivationButton, y%buttonYPos%
}

InitGuiActivationButtons()
{
	global

	local centerX := (mainWidth/2)

	local defaultEnableButtonText := enableDisableHKStrings[0]

	; Enable/Disable Checkboxes Buttons
	Gui, Add, Button, y+%buttonVPadding% gEnableAll vCheckAllButton, %enableAllString%
	Gui, Add, Button, yp gDisableAll vUncheckAllButton, %disableAllString%

	; Enable/Disable Script Button
	Gui, Add, Button, x%defaultXPadding% y+%buttonVPadding% gEnableDisable vEnableDisableButton, %defaultEnableButtonText%

	GuiControlGet, checkAllTransform, Pos, CheckAllButton
	GuiControlGet, uncheckAllTransform, Pos, UncheckAllButton
	GuiControlGet, enableDisableTransform, Pos, EnableDisableButton

	local checkUncheckTotalW := buttonHPadding + (checkAllTransformW + uncheckAllTransformW)
	local checkAllX := centerX - (checkUncheckTotalW / 2)
	local uncheckAllX := checkAllX + (checkAllTransformW + buttonHPadding)
	local enableDisableX := centerX - (enableDisableTransformW/2)

	GuiControl, Move, CheckAllButton, x%checkAllX%
	GuiControl, Move, UncheckAllButton, x%uncheckAllX%
	GuiControl, Move, EnableDisableButton, x%enableDisableX%
}

InitGuiStatusText()
{
	global

	local centerX := (mainWidth/2)

	local defaultColor := statusColors[0]
	local defaultActiveText := activeInactiveStrings[0]

	; Status Text
	Gui, Add, Text, vStatusText, %statusString%
	Gui, Add, Text, +center vActiveText, %defaultActiveText%
	GuiControl, +c%defaultColor%, ActiveText

	GuiControlGet, statusTransform, Pos, StatusText
	GuiControlGet, activeTransform, Pos, ActiveText

	local statusTotalW := statusTransformW + activeTransformW
	local statusX := centerX - (statusTotalW / 2)
	local activeX := statusX + statusTransformW
	local activeStatusY := mainHeight - (defaultYPadding + statusTransformH)

	GuiControl, Move, StatusText, x%statusX% y%activeStatusY%
	GuiControl, Move, ActiveText, x%activeX% y%activeStatusY%
}

InitGuiSettingsButton()
{
	global

	local yPos := mainHeight - (settingsButtonPadding + settingsButtonHW)
	local xPos := mainWidth - (settingsButtonPadding + settingsButtonHW)

	Gui, Add, Button, x%xPos% y%yPos% w%settingsButtonHW% h%settingsButtonHW% hwndSettingsHndl gOpenSettings vSettingsButton
	GuiButtonIcon(SettingsHndl, settingsIcon, 0, "s20")
}

InitHotkeys()
{
	global

	UnpackAbilityKeys()

	#If abilityCheckArr[0] == 1 && shouldTrigger() == 1
	#If abilityCheckArr[1] == 1 && shouldTrigger() == 1
	#If abilityCheckArr[2] == 1 && shouldTrigger() == 1
	#If abilityCheckArr[3] == 1 && shouldTrigger() == 1
	#If abilityCheckArr[4] == 1 && shouldTrigger() == 1
	#If abilityCheckArr[5] == 1 && shouldTrigger() == 1
	#If listeningForRebinds == 0
	#If

	Hotkey, If, abilityCheckArr[0] == 1 && shouldTrigger() == 1
	Hotkey, *$%AK0%, AbilityHK0
	Hotkey, *$%AK0% Up, AbilityHK0UP

	Hotkey, If, abilityCheckArr[1] == 1 && shouldTrigger() == 1
	Hotkey, *$%AK1%, AbilityHK1
	Hotkey, *$%AK1% Up, AbilityHK1UP

	Hotkey, If, abilityCheckArr[2] == 1 && shouldTrigger() == 1
	Hotkey, *$%AK2%, AbilityHK2
	Hotkey, *$%AK2% Up, AbilityHK2UP

	Hotkey, If, abilityCheckArr[3] == 1 && shouldTrigger() == 1
	Hotkey, *$%AK3%, AbilityHK3
	Hotkey, *$%AK3% Up, AbilityHK3UP

	Hotkey, If, abilityCheckArr[4] == 1 && shouldTrigger() == 1
	Hotkey, *$%AK4%, AbilityHK4
	Hotkey, *$%AK4% Up, AbilityHK4UP

	Hotkey, If, abilityCheckArr[5] == 1 && shouldTrigger() == 1
	Hotkey, *$%AK5%, AbilityHK5
	Hotkey, *$%AK5% Up, AbilityHK5UP

	Hotkey, If, listeningForRebinds == 0
	Hotkey, ~%enableScriptKey%, EnableDisable
}

LoadConfig()
{
	global

	if (FileExist(saveFileName))
	{
		local lineFeed
		local displayKey

		FileReadLine, lineFeed, %saveFileName%, 1
		abilityCheckArr := JSON.Load(lineFeed)

		FileReadLine, lineFeed, %saveFileName%, 2
		abilityKeyArr := JSON.Load(lineFeed)

		FileReadLine, lineFeed, %saveFileName%, 3
		holdPositionKey := JSON.Load(lineFeed)

		FileReadLine, lineFeed, %saveFileName%, 4
		enableScriptKey := JSON.Load(lineFeed)

		FileReadLine, lineFeed, %saveFileName%, 5
		optionsArr := JSON.Load(lineFeed)

		holdKeyReleaseDelay := optionsArr["releaseDelay"]

		Loop, %abilityCount%
		{
			local trueIndex := A_Index - 1
			local keybindText := abilityKeyArr[trueIndex]
			local abilityIsChecked := abilityCheckArr[trueIndex]

			displayKey := AbilityKeyToUpperString(keybindText)

			GuiControl, Main:, AbilityKeyText%trueIndex%, %displayKey%
			GuiControl, Main:, Ability%trueIndex%, %abilityIsChecked%
			gosub, OnAbilityCheck%trueIndex%
		}

		displayKey := AbilityKeyToUpperString(holdPositionKey)
		GuiControl, Main:, HoldPosKeyText, %displayKey%

		displayKey := AbilityKeyToUpperString(enableScriptKey)
		GuiControl, Main:, ActivationKeyText, %displayKey%
	}
}

SaveConfig()
{
	global

	IfNotExist, % A_AppData "\AutoHoldPos"
    	FileCreateDir, % A_AppData "\AutoHoldPos"

	RepackAbilityKeys()
	optionsArr["releaseDelay"] := holdKeyReleaseDelay

	checkboxJsonStr := JSON.Dump(abilityCheckArr)
	abilityKeybindJsonStr := JSON.Dump(abilityKeyArr)
	holdPosKeybindJsonStr := JSON.Dump(holdPositionKey)
	activationKeybindJsonStr := JSON.Dump(enableScriptKey)
	optionsJsonStr := JSON.Dump(optionsArr)

	saveFile := FileOpen(saveFileName, "w")
	saveFile.WriteLine(checkboxJsonStr)
	saveFile.WriteLine(abilityKeybindJsonStr)
	saveFile.WriteLine(holdPosKeybindJsonStr)
	saveFile.WriteLine(activationKeybindJsonStr)
	saveFile.WriteLine(optionsJsonStr)
	saveFile.Read(0)
	file.Close()
}

UnpackAbilityKeys()
{
	global

	Loop, %abilityCount%
	{
		local trueIndex := A_Index - 1

		AK%trueIndex% := abilityKeyArr[trueIndex]
	}
}

RepackAbilityKeys()
{
	global

	Loop, %abilityCount%
	{
		local trueIndex := A_Index - 1

		abilityKeyArr[trueIndex] := AK%trueIndex%
	}
}

ShouldTrigger()
{
	global
	
	local shouldTrigger := 0

	if (listeningForRebinds == 0 and scriptEnabled == 1 and PassedFocusCheck())
	{
		shouldTrigger := 1
	}

	return shouldTrigger
}

PassedFocusCheck()
{
	global

	local focusCheckPassed := 0

	if (optionsArr["focusCheck"])
	{
		if (WinActive(diabloWinName))
		{
			focusCheckPassed := 1
		}
	}
	else
	{
		focusCheckPassed := 1
	}

	return focusCheckPassed
}

IsValidKey(pInput)
{
	inputIsMatch := 1

	if (pInput == "Escape" || pInput == "LWin" || pInput == "RWin" || pInput == "AppsKey" || pInput == "BS" || pInput == "")
	{
		inputIsMatch := 0
	}

	return inputIsMatch
}

KeybindExists(pInput)
{
	global

	local keybindExists := 0

	Loop, %abilityCount%
	{
		local trueIndex := A_Index - 1
		local retrievedKey := AK%trueIndex%

		if (pInput == retrievedKey)
		{
			keybindExists := 1
			break
		}
		
	}

	if (keybindExists == 0)
	{
		if (pInput == holdPositionKey || pInput == enableScriptKey)
		{
			keybindExists := 1
		}
	}

	return keybindExists
}

RebindKey(pAbilityNum)
{
	global

	local keyRebound := 0
	local abilityVarName := AK%pAbilityNum%

	local popUpString := rebindPopupString " " (pAbilityNum+1)

	DisplayRebindPopUp(popUpString)

	ih.Start()
	ih.Wait()

	local receivedInput := ih.input

	if (ih.EndReason == "EndKey")
	{
		receivedInput := ih.EndKey
	}

	if (IsValidKey(receivedInput) == 1 && KeybindExists(receivedInput) == 0)
	{

		Hotkey, If, abilityCheckArr[%pAbilityNum%] == 1 && shouldTrigger() == 1
		Hotkey, $%abilityVarName%, AbilityHK%pAbilityNum%, off
		AK%pAbilityNum% := receivedInput
		Hotkey, $%receivedInput%, AbilityHK%pAbilityNum%, on

		local displayKey := AbilityKeyToUpperString(receivedInput)

		GuiControl, Main:, AbilityKeyText%pAbilityNum%, %displayKey%

		keyRebound := 1
	}

	CloseRebindPopUp()

	if (%keyRebound% == 0)
	{
		if (KeybindExists(receivedInput))
		{
			DisplayCustomPopUp(rebindConflictString, rebindPopUpTitle)
		}
		else
		{
			DisplayCustomPopUp(rebindCancelledString, rebindPopUpTitle)
		}
	}
}

RebindHoldPosKey()
{
	global

	local keyRebound := 0

	DisplayRebindPopUp(rebindHoldPosString)

	ih.Start()
	ih.Wait()

	local receivedInput := ih.input

	if (ih.EndReason == "EndKey")
	{
		receivedInput := ih.EndKey
	}

	if (IsValidKey(receivedInput) == 1 && KeybindExists(receivedInput) == 0)
	{
		holdPositionKey := receivedInput

		local displayKey := AbilityKeyToUpperString(receivedInput)

		GuiControl, Main:, HoldPosKeyText, %displayKey%

		keyRebound := 1
	}

	CloseRebindPopUp()

	if (%keyRebound% == 0)
	{
		if (KeybindExists(receivedInput))
		{
			DisplayCustomPopUp(rebindConflictString, rebindPopUpTitle)
		}
		else
		{
			DisplayCustomPopUp(rebindCancelledString, rebindPopUpTitle)
		}
	}
}

RebindActivationKey()
{
	global

	local keyRebound := 0

	DisplayRebindPopUp(rebindActivationString)

	ih.Start()
	ih.Wait()

	local receivedInput := ih.input

	if (ih.EndReason == "EndKey")
	{
		receivedInput := ih.EndKey
	}

	if (IsValidKey(receivedInput) == 1 && KeybindExists(receivedInput) == 0)
	{
		Hotkey, If, listeningForRebinds == 0
		Hotkey, ~%enableScriptKey%, EnableDisable, off
		enableScriptKey := receivedInput
		Hotkey, ~%enableScriptKey%, EnableDisable, on

		local displayKey := AbilityKeyToUpperString(receivedInput)

		GuiControl, Main:, ActivationKeyText, %displayKey%

		keyRebound := 1
	}

	CloseRebindPopUp()

	if (%keyRebound% == 0)
	{
		if (KeybindExists(receivedInput))
		{
			DisplayCustomPopUp(rebindConflictString, rebindPopUpTitle)
		}
		else
		{
			DisplayCustomPopUp(rebindCancelledString, rebindPopUpTitle)
		}
	}
}

KeybindToString(pKeyInput)
{
	newString := % pKeyInput

	return newString
}

DisplayRebindPopUp(pPopUpString)
{
	global

	listeningForRebinds := 1

	Gui, Main:+Disabled

	Gui, RebindPopUp:New, AlwaysOnTop, %rebindPopUpTitle%
	Gui, RebindPopUp:+OwnDialogs +Owner -SysMenu

	Gui, Add, Text, y%inputPopupVPadding% vRebindText, %pPopUpString%
	GuiControlGet, textTransform, Pos, RebindText
	local textXPos := (inputPopupWidth/2) - (textTransformW/2)
	GuiControl, Move, RebindText, x%textXPos%

	Gui, Add, Button, gCancelRebind vCancelButton, %cancelString%
	GuiControlGet, buttonTransform, Pos, CancelButton
	local buttonXPos := (inputPopupWidth/2) - (buttonTransformW/2)
	local buttonYPos := inputPopupHeight-(inputPopupVPadding+buttonTransformH)
	GuiControl, Move, CancelButton, x%buttonXPos% y%buttonYPos%

	Gui, Show, w%inputPopupWidth% h%inputPopupHeight%
}

CloseRebindPopUp()
{
	global
	
	Gui, Main:-Disabled
	Gui, Destroy
	listeningForRebinds := 0
}

DisplayCustomPopUp(pPopUpText, pPopUpTitle)
{
	global

	Gui, Main:+Disabled

	Gui, CustomPopUp:New, AlwaysOnTop, %pPopUpTitle%
	Gui, CustomPopUp:+OwnDialogs +Owner -SysMenu

	Gui, Add, Text, y%customPopupVPadding% vCustomText, %pPopUpText%
	GuiControlGet, textTransform, Pos, CustomText
	local textXPos := (customPopupWidth/2) - (textTransformW/2)
	GuiControl, Move, CustomText, x%textXPos%

	Gui, Add, Button, gConfirmButton vConfirmButton, %okString%
	GuiControlGet, buttonTransform, Pos, ConfirmButton
	local buttonXPos := (customPopupWidth/2) - (buttonTransformW/2)
	local buttonYPos := customPopupHeight-(customPopupVPadding+buttonTransformH)
	GuiControl, Move, ConfirmButton, x%buttonXPos% y%buttonYPos%

	Gui, Show, w%customPopupWidth% h%customPopupHeight%
}

DisplaySettingsPopUp()
{
	global

	local startMinimized := optionsArr["startMinimized"]
	local startEnabled := optionsArr["startEnabled"]
	local isMuted := optionsArr["isMuted"]
	local shouldFocusCheck := optionsArr["focusCheck"]

	Gui, Main:+Disabled

	Gui, SettingsPopUp:New, AlwaysOnTop, %settingsPopUpTitle%
	Gui, SettingsPopUp:+OwnDialogs +Owner -SysMenu

	Gui, Add, Checkbox, Checked%startMinimized% x%defaultXPadding% y%defaultYPadding% gOnMinimizeCheck vStartMinimizedCheck, %minimizeString%
	Gui, Add, Checkbox, Checked%startEnabled% x%defaultXPadding% y+%abilityLineVPadding% gOnStartEnabledCheck vStartEnabledCheck, %startEnabledString%
	Gui, Add, Checkbox, Checked%isMuted% x%defaultXPadding% y+%abilityLineVPadding% gOnMuteCheck vMuteCheck, %muteString%
	Gui, Add, Checkbox, Checked%shouldFocusCheck% x%defaultXPadding% y+%abilityLineVPadding% gOnFocusCheck vFocusCheck, %focusCheckString%

	Gui, Add, Text, x%defaultXPadding% y+%abilityLineVPadding%, %releaseDelayString%
	Gui, Add, Edit, x%defaultXPadding% gOnReleaseDelayChange vReleaseDelayBox Limit%releaseDelayCharLimit%
	Gui, Add, UpDown, gOnReleaseDelayChange vReleaseDelayUpDown Range%releaseDelayMin%-%releaseDelayMax%, %holdKeyReleaseDelay%

	Gui, Add, Button, gCloseSettings vCloseSettingsButton, %closeString%

	GuiControlGet, closeButtonTransform, Pos, CloseSettingsButton

	local xPos := (settingsPopUpW / 2) - (closeButtonTransformW / 2)
	local yPos := settingsPopUpH - (closeButtonTransformH + defaultYPadding)

	GuiControl, Move, CloseSettingsButton, x%xPos% y%yPos%

	Gui, Show, w%settingsPopUpW% h%settingsPopUpH%
}

UpdateEnabledStatus(pFromStartup)
{
	global

	scriptEnabled := !scriptEnabled

	local isMuted := optionsArr["isMuted"]

	local newColor := statusColors[scriptEnabled]
	local newStatusText := activeInactiveStrings[scriptEnabled]
	local newButtonText := enableDisableHKStrings[scriptEnabled]
	local soundToPlay := enableDisableAud[scriptEnabled]
	local trayNewStatus := enableDisableStrings[scriptEnabled]

	GuiControl, Main:+c%newColor%, ActiveText
	GuiControl, Main:, ActiveText, %newStatusText%
	GuiControl, Main:, EnableDisableButton, %newButtonText%

	Menu, Tray, Rename, %trayCurrentStatus%, %trayNewStatus%
	trayCurrentStatus:= trayNewStatus

	if (!isMuted && !pFromStartup)
	{
		SoundPlay, %soundToPlay%
	}
}

AbilityKeyToUpperString(pInput)
{
	global

	local inStr := pInput
	local outStr := pInput

	if (StrLen(inStr) == 1)
	{
		StringUpper, outStr, inStr
	}

	return outStr
}

CheckForHeldKeys()
{
	global

	Loop, %abilityCount%
	{
		if (abilityKeysHeld[A_Index - 1] == 1)
		{
			return 1
			break
		}
	}

	return 0
}

ReleaseHoldKey()
{
	global
	SendInput, {%holdPositionKey% up}
	isHoldKeyHeld := 0
}

HandleInput(pIndex, pSetHeld)
{
	global

	abilityKeysHeld[pIndex] := pSetHeld
	local isHotkeyHeld := CheckForHeldKeys()

	if (isHotkeyHeld == 1 and isHoldKeyHeld == 0)
	{
		SetTimer, ReleaseHoldKey, Off
		SendInput, {%holdPositionKey% down}
		isHoldKeyHeld := 1
	}
	else if (isHotkeyHeld == 0 and isHoldKeyHeld == 1)
	{
		SetTimer, ReleaseHoldKey, -%holdKeyReleaseDelay%
	}

	if (pSetHeld == 1)
	{
		local keyToSend := AK%pIndex%
		SendInput, %keyToSend%
	}
}

AbilityHK0:
	HandleInput(0, 1)
	return
	
AbilityHK0UP:
	HandleInput(0, 0)
	return

AbilityHK1:
	HandleInput(1, 1)
	return

AbilityHK1UP:
	HandleInput(1, 0)
	return

AbilityHK2:
	HandleInput(2, 1)
	return

AbilityHK2UP:
	HandleInput(2, 0)
	return

AbilityHK3:
	HandleInput(3, 1)
	return

AbilityHK3UP:
	HandleInput(3, 0)
	return

AbilityHK4:
	HandleInput(4, 1)
	return

AbilityHK4UP:
	HandleInput(4, 0)
	return

AbilityHK5:
	HandleInput(5, 1)
	return

AbilityHK5UP:
	HandleInput(5, 0)
	return

OnAbilityCheck0:
	GuiControlGet, checked,, Ability0
	abilityCheckArr[0] := checked
	return

OnAbilityCheck1:
	GuiControlGet, checked,, Ability1
	abilityCheckArr[1] := checked
	return

OnAbilityCheck2:
	GuiControlGet, checked,, Ability2
	abilityCheckArr[2] := checked
	return

OnAbilityCheck3:
	GuiControlGet, checked,, Ability3
	abilityCheckArr[3] := checked
	return

OnAbilityCheck4:
	GuiControlGet, checked,, Ability4
	abilityCheckArr[4] := checked
	return

OnAbilityCheck5:
	GuiControlGet, checked,, Ability5
	abilityCheckArr[5] := checked
	return

RebindKey0:
	RebindKey(0)
	return

RebindKey1:
	RebindKey(1)
	return

RebindKey2:
	RebindKey(2)
	return

RebindKey3:
	RebindKey(3)
	return

RebindKey4:
	RebindKey(4)
	return

RebindKey5:
	RebindKey(5)
	return

RebindHoldPos:
	RebindHoldPosKey()
	return

RebindActivation:
	RebindActivationKey()
	return

ConfirmButton:
	Gui, Main:-Disabled
	Gui, Destroy
	return

CancelRebind:
	ih.stop()
	return

OnMinimizeCheck:
	GuiControlGet, checked,, StartMinimizedCheck
	optionsArr["startMinimized"] := checked
	return

OnStartEnabledCheck:
	GuiControlGet, checked,, StartEnabledCheck
	optionsArr["startEnabled"] := checked
	return

OnMuteCheck:
	GuiControlGet, checked,, MuteCheck
	optionsArr["isMuted"] := checked
	return

OnFocusCheck:
	GuiControlGet, checked,, FocusCheck
	optionsArr["focusCheck"] := checked
	return

OnReleaseDelayChange:
	GuiControlGet, delay,, ReleaseDelayBox
	StringReplace, delay, delay, `,, , All
	holdKeyReleaseDelay := delay
	return

EnableAll:
	Loop, %abilityCount%
	{
		trueIndex := A_Index - 1
		GuiControl, Main:, Ability%trueIndex%, 1	
		gosub, OnAbilityCheck%trueIndex%
	}

	return

DisableAll:
	Loop, %abilityCount%
	{
		trueIndex := A_Index - 1
		GuiControl, Main:, Ability%trueIndex%, 0	
		gosub, OnAbilityCheck%trueIndex%
	}

	return

EnableDisable:
	UpdateEnabledStatus(0)
	return

OpenSettings:
	DisplaySettingsPopUp()
	return

CloseSettings:
	Gui, Main:-Disabled
	Gui, Destroy
	return

MainGuiSize:
	if (A_EventInfo == 1)
	{
		Gui, Main:Hide
		Menu, Tray, Icon
	}

	return

Restore:
	Gui, Main:Show, w%mainWidth% h%mainHeight%
	Menu, Tray, NoIcon
	return

CustomPopUpClose:
	Gui, Main:-Disabled
	return

RebindPopUpGuiClose:
	ih.Stop()
	return

SettingsPopUpClose:
	Gui, Main:-Disabled
	return

MainGuiClose:
	SaveConfig()
	ExitApp