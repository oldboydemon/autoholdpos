# AutoHoldPos
An AutoHotKey script for Diablo IV to automatically hold your position for individually specified abilities.

## About
I made this as a QoL program for myself when Diablo IV first released. I found it annoying to have to keep using the hold position key for separate abilities, especially when you're firing different abilities in quick succession. I stopped playing shortly before Season 1, so I also stopped tinkering with this project, but recently revisited it and decided to share it for those that may find a use for it. I'm honestly surprised this still isn't a built-in feature of the game, especially since Path of Exile already has this feature. This program hasn't been thourougly tested so you're likely to find some minor bugs/issues, but it does work well. I'm not really planning to keep working on it, but if there are any major issues found, I will do my best to put aside some time to fix them.

## How to Use
There are six checkboxes, one for each ability. Checking any of these will enable the hold position functionality for the relevant ability. This means once you enable the main functionality, you don't have to hold the hold position key when using that ability. To the right of each ability is a rebind button. You should rebind the ability keys and hold position key to match your in-game bindings if they aren't already. There is also an option to rebind the enable/disable key for your convenience. Minimizing the window will hide it to the system tray. There you can double click to restore the window, or right click for further options.

## Settings
Clicking the gear at the bottom right will open a settings window. Here you will find 5 settings.

**Start Minimized** - Exactly what it sounds like. Upon next starting the program, it will start minimized in the system tray.

**Start Enabled** - Upon next starting the program, the main functionality will be enabled already.

**Mute 'Enable/Disable' Sound** - When enabling/disabling the main functionality, you will hear a sound that lets you know it has been enabled/disabled. If you find this annoying, you can tick this option to turn it off.

**Check if Game Window is in Focus** - This will tell the main functionality to only work if the Diablo IV game window is the currently focused window. This can help prevent unintended inputs in other windows if you like to alt-tab a lot.

**Release Delay in ms** - On testing, I found a minor issue where the hold key would seemingly be released before an ability key has finished inputting, causing the character to slightly move before performing the ability. Adding a delay for the hold position key to be released can offset this effect. Though, adding a high delay will make the hold position key be held down for longer and may interfere with any following ability inputs that aren't set to be auto held. You may have to tweak this to find your personal sweet spot, or you can set it to 0 for no delay.

These settings (along with you bindings) will be saved each time you close the program. The save location can be found at C:\Users\*YOURUSERNAME*\AppData\Roaming\AutoHoldPos\cfg.json
If you have any issues with the config file, you can delete it, and AutoHoldPos will generate a new one the next time it closes.

# WARNING
This is an AutoHotKey script, and as such may not fully comply with Blizzard's ToS. Though I've searched and can't find any information about AutoHotKey specifically being disallowed, it does technically fall under the category of an external macro. Blizzard's stance on external macros is unclear, and reliable information on the rules regarding external macros is hard to find. The best I could find was a guideline stating that "one key press should be equal to one action". This program follows that guideline in that using the hold position key and attacking results in one action(attacking in one spot). HOWEVER, I cannot guarantee that this is safe from bans, and Blizzard may exercise their right to suspend accounts they find to be in violation of their ToS. While I have used this program myself and had no problems, that doesn't necessarily mean it's safe to use. If you download and use this program, you do so at your own risk. I am not responsible for any bans resulting from using this program. YOU HAVE BEEN WARNED.

## VirusTotal
I uploaded the .exe file to VirusTotal for a scan. You can see the results here: https://www.virustotal.com/gui/file/b7e3051c23d3ebb7e670aab6919022e1ef87ce63fc5273efb79b8546675250ce

While there are some flags, I can assure you they are false positives, which is why I've uploaded the source code here so anyone can check and even compile the script themselves.
