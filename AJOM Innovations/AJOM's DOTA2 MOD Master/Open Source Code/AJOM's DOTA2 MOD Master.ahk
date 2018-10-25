;;optimize speed of script
#NoEnv
;#MaxHotkeysPerInterval 99000000
;#HotkeyInterval 99000000
#KeyHistory 0
#Persistent
#SingleInstance ignore
;#MaxThreads 1
#MaxThreadsPerHotkey 1
SetBatchLines -1
SetControlDelay,-1
SetWinDelay, -1
ListLines Off
Process, Priority, , A
SetKeyDelay, -1, -1
SetMouseDelay, -1
SetDefaultMouseSpeed, 0
SendMode Input
AutoTrim,Off
;;


full_command_line := DllCall("GetCommandLine", "str")

if not (A_IsAdmin or RegExMatch(full_command_line, " /restart(?!\S)"))
{
    ; if a file is opened/dragged using this dota2 mod master, this code will able to detect them all and restart dota2 mod master while still dragging this files to dota2 mod master
	draggedfiles=
	for n, GivenPath in A_Args  ; For each parameter (or file dropped onto a script):
	{
		Loop Files, %GivenPath%, F  ; Include files and directories.
		{
			; LongPath := A_LoopFileLongPath
			; InStr(A_LoopFileLongPath,".",,0)+1 searches for the offset position of the extension(dot ".") and after finding it, moves one step to the right excluding the dot(.) on the right side
			; StrLen(A_LoopFileLongPath) is the number of characters in the whole path
			; StrLen(A_LoopFileLongPath)-InStr(A_LoopFileLongPath,".",,0) counts the number of characters of the extension, excluding "."
			; SubStr(A_LoopFileLongPath,InStr(A_LoopFileLongPath,".",,0)+1,StrLen(A_LoopFileLongPath)-InStr(A_LoopFileLongPath,".",,0)) ; extracts the whole extension excluding the dot(.)
			if (A_LoopFileExt = "aldrin_dota2hidb") or (A_LoopFileExt = "aldrin_dota2db")
			{
				draggedfiles="%A_LoopFileLongPath%" %draggedfiles%
			}
		}
	}
	;
    try
    {
        if A_IsCompiled
            Run *RunAs "%A_ScriptFullPath%" /restart %draggedfiles% ; restart dota2 mod master with admin priviledges, also redragg all dragged files to admined dota2 mod master
        else
            Run *RunAs "%A_AhkPath%" /restart "%A_ScriptFullPath%" %draggedfiles%  ; restart dota2 mod master with admin priviledges, also redragg all dragged files to admined dota2 mod master
    }
    ExitApp
}

Menu, Tray, Add, &Exit, k_MenuExit
Menu, Tray, NoStandard

version=2.2.0 BETA

databasemessage=~ ~ ~ ~ MAIN DATABASE Version 2 : Don't Edit anything here to avoid DATABASE CORRUPTION!!! ~ ~ ~ ~`n`n
ListViewSave(databasemessage) ; sets the default message in the beggining of the database and store to "static ExtraMessage"
ListViewLoad(,databasemessage) ; stores to "static ExtraMessage" which will be the reference that there is an extra message at the begginging(done by listviewsave)
defaultshoutout=(Always Relaunch this Tool and Reinject all item sets everytime DOTA2 has an Update with Newly Arrived Items!)

if A_Is64bitOS=1
{
	variablehllib=%A_ScriptDir%\Plugins\hllib246\bin\x64\HLExtract.exe
}
else
{
	variablehllib=%A_ScriptDir%\Plugins\hllib246\bin\x86\HLExtract.exe
}

RegRead, SteamPath, HKEY_CURRENT_USER, Software\Valve\Steam, SteamPath
StringReplace,SteamPath,SteamPath,/,\,1
IfExist,%A_ScriptDir%\Settings.aldrin_dota2mod
{
	IniRead,mapdota2dir,%A_ScriptDir%\Settings.aldrin_dota2mod,Edits,mapdota2dir
	ifnotexist,%mapdota2dir%\game\dota\
	{
		mapdota2dir=
		gosub,d2dirdetection
	}
	else
	{
		dota2dir=%mapdota2dir%
	}
}
else ifnotexist,%SteamPath%\steamapps\common\dota 2 beta\game\dota\pak01_dir.vpk
{
	gosub,d2dirdetection
}
else
{
	mapdota2dir=%SteamPath%\steamapps\common\dota 2 beta
	dota2dir=%SteamPath%\steamapps\common\dota 2 beta
}
GoSub,default_settings
param=%A_ScriptDir%\Library\,%A_ScriptDir%\Generated MOD\,%A_ScriptDir%\External Files\
loop,parse,param,`,
{
	IfNotExist,%A_LoopField%
	{
		FileCreateDir,%A_LoopField%
	}
}
FileCopyDir,%A_ScriptDir%\Plugins\Sound,%A_Temp%\Sound,1
param=root\scripts\items\items_game.txt,root\scripts\npc\activelist.txt,root\scripts\npc\portraits.txt
tmp1=0
loop,parse,param,`,
{
	IfExist,%A_ScriptDir%\Plugins\hllib246\lib%A_Index%.bat
	{
		FileDelete,%A_ScriptDir%\Plugins\hllib246\lib%A_Index%.bat
	}
	FileAppend,"%variablehllib%" -p "%dota2dir%\game\dota\pak01_dir.vpk" -d "%A_ScriptDir%\Library" -e "%A_LoopField%"`r`ndel `%0,%A_ScriptDir%\Plugins\hllib246\lib%A_Index%.bat
	run,"%A_ScriptDir%\Plugins\hllib246\lib%A_Index%.bat",,Hide UseErrorLevel,lib%A_Index%
	tmp1+=1
}
loop 
{
	wait=0
	loop %tmp1%
	{
		tmp:=lib%A_Index%
		ifwinexist,ahk_pid %tmp%
		{
			wait=1
		}
		else ifexist,%A_ScriptDir%\Plugins\hllib246\lib%A_Index%.bat
		{
			ifwinnotexist,ahk_pid %tmp%
			{
				run,%A_ScriptDir%\Plugins\VPKCreator\lib%A_Index%.bat,,Hide UseErrorLevel,lib%A_Index%
				wait=1
			}
			else
			{
				wait=1
			}
		}
	}
	if wait=0
	{
		Break
	}
}
IfNotExist,%A_ScriptDir%\Library\items_game.txt
{
	msgbox,16,ERROR!!! "items_game.txt" is MISSING!,It looks like:`n`n"%A_ScriptDir%\Library\items_game.txt"`n`nIs missing. But since this tool already supports auto-extraction of "items_game.txt"`, please restart this application. Before using the "inject" feature of this tool`, make sure to add the original "items_game.txt" inside "%A_ScriptDir%\Library" Folder OR ELSE THE ID INJECTION WILL NOT WORK!`n`nIf you dont have an Idea where to find the "items_game.txt"`,here is a few steps:`n1)Download "GCFScape" application. Alternatively if GCFScape produces "ERROR" when opening "Pak01_dir.vpk"`, Download "Valve's Resource Viewer" application instead.`n2)Use "GCFScape" or "Valve's Resource Viewer" to open "Pak01_dir.vpk"(commonly it is located at "Steam\steamapps\common\dota 2 beta\game\dota\").`n3)Hit "CTRL+F"(or press "find" elsewhere) and search for "items_game.txt" without punctuation marks.`n4)If successfully found`,Right-Click the file(items_game.txt) and extract it to "%A_ScriptDir%\Library" folder.
}
else IfNotExist,%A_ScriptDir%\Library\activelist.txt
{
	msgbox,16,ERROR!!! "activelist.txt" is MISSING!,It looks like:`n`n"%A_ScriptDir%\Library\activelist.txt"`n`nIs missing. But since this tool already supports auto-extraction of "activelist.txt"`, please restart this application. Before using the "inject" feature of this tool`, make sure to add the original "activelist.txt" inside "%A_ScriptDir%\Library" Folder OR ELSE THE HERO Recognition for Handy Injection Section WILL NOT WORK!`n`nIf you dont have an Idea where to find the "activelist.txt"`,here is a few steps:`n1)Download "GCFScape" application. Alternatively if GCFScape produces "ERROR" when opening "Pak01_dir.vpk"`, Download "Valve's Resource Viewer" application instead.`n2)Use "GCFScape" or "Valve's Resource Viewer" to open "Pak01_dir.vpk"(commonly it is located at "Steam\steamapps\common\dota 2 beta\game\dota\").`n3)Hit "CTRL+F"(or press "find" elsewhere) and search for "activelist.txt" without punctuation marks.`n4)If successfully found`,Right-Click the file(activelist.txt) and extract it to "%A_ScriptDir%\Library" folder.
}

param=ucr,mapinvdirview,mapdatadirview,maphdatadirview,mapmdirview,autovpk,pet,usemisc,mapgiloc,mappetstyle,maplowprocessor,usedversion,mapdota2dir,soundon,useextportraitfile,useextfile,useextitemgamefile,fastmisc,showtooltips
Loop,parse,param,`,
{
	IniRead,%A_LoopField%,%A_ScriptDir%\Settings.aldrin_dota2mod,Edits,%A_LoopField%
}

; if a file is opened/dragged using this dota2 mod master, this code will able to detect them all
draggedfilesg=
draggedfilesh=
for tmp1, GivenPath in A_Args  ; For each parameter (or file dropped onto a script):
{
	Loop Files, %GivenPath%, F  ; Include files only not folders for faster tabulation.
	{
		if A_LoopFileExt = aldrin_dota2hidb
		{
			draggedfilesh=%A_LoopFileLongPath%|%draggedfilesh%
		}
		else if A_LoopFileExt = aldrin_dota2db
		{
			draggedfilesg=%A_LoopFileLongPath%|%draggedfilesg%
		}
	}
}
tmp1 := StrReplace(draggedfilesg,"|","|",tmp2),tmp1 := StrReplace(draggedfilesh,"|","|",tmp3),tmp2+=tmp3
if (draggedfilesg<>"") or (draggedfilesh<>"")
{
	if tmp2>=2 ;; if two or more files are dragged into the script, it will ask the user to selectonly one file for each section: general and handy injection
	{
		Gui, draggedfilesgui:+Resize +MinSize
		Gui, draggedfilesgui:Add, Text,w400 vtext47,You have selected Multiple Files for DOTA2 MOD Master to Handle`, but unfortunately DOTA2 MOD Master can only Browse one Database File. Select the most preffered Database File.
		Gui, draggedfilesgui:Add, Text,,General Database
		Gui, draggedfilesgui:Add, Text, x205 y60 vtext49,Handy-Injection Database
		Gui, draggedfilesgui:Add,ComboBox,x1 w200 vselectedfileg Choose1 Simple,%draggedfilesg%
		Gui, draggedfilesgui:Add,ComboBox,x205 y79 w200 vselectedfileh Choose1 Simple,%draggedfilesh%
		Gui, draggedfilesgui:Add, Button, default xm galldraggedfiles vtext48, Select
		Gui, draggedfilesgui:Show,,Choose One File to Open
		return
	}
	else if tmp2=1
	{
		draggedfilesh:=StrReplace(draggedfilesh,"|",""),draggedfilesg:=StrReplace(draggedfilesg,"|","")
		Loop Files,%draggedfilesh%, F
		{
			if A_LoopFileExt=aldrin_dota2hidb
			{
				maphdatadirview:=A_LoopFileLongPath
			}
		}
		Loop Files,%draggedfilesg%, F
		{
			if A_LoopFileExt=aldrin_dota2db
			{
				mapdatadirview:=A_LoopFileLongPath
			}
		}
	}
}
draggedfilesguiguiclose:
continueexecution:
Gui,draggedfilesgui:Destroy
;;;;

mapherochoice=
FileRead, tmp1,%A_ScriptDir%\Library\activelist.txt
Loop
{
	StringGetPos, ipos, tmp1,npc_dota_hero_,L%A_Index%
	if ipos<1
	{
		Break
	}
	StringGetPos, ipos1, tmp1,",,%ipos% ;"
	StringMid,tmp2,tmp1,% ipos+1,% ipos1-ipos
	StringTrimLeft, tmp2, tmp2, 14
	if tmp2<>
	{
		mapherochoice=%mapherochoice%|%tmp2%
	}
	if ErrorLevel=1
	{
		Break
	}
}
ifexist,%A_ScriptDir%\CustomHeroes.aldrin_dota2mod
{
	customherocount=0
	FileRead,tmp,%A_ScriptDir%\CustomHeroes.aldrin_dota2mod
	Loop
	{
		tmp1=CustomHero%A_Index%
		if InStr(tmp,tmp1)
		{
			IniRead,tmp2,%A_ScriptDir%\CustomHeroes.aldrin_dota2mod,CustomHeroes,CustomHero%A_Index%
			StringTrimLeft, tmp2, tmp2, 14
			mapherochoice=%mapherochoice%|%tmp2%
			customherocount+=1
		}
		else
		{
			Break
		}
	}
}
Sort mapherochoice, A D|
mapherochoice=None%mapherochoice%
IniRead,RegisteredDirectory,%mapdatadirview%,Edits,RegisteredDirectory
IniRead,hRegisteredDirectory,%maphdatadirview%,Edits,hRegisteredDirectory
checkparam=mapinvdirview,mapdatadirview,maphdatadirview,mapmdirview,mapgiloc,mapdota2dir
loop,parse,checkparam,`,
{
	if %A_LoopField%=ERROR
	{
		%A_LoopField%=
	}
}
DllCall("QueryPerformanceFrequency", "Int64P", freq)
Gui, MainGUI:+Resize +MinSize
IniRead,choosetab,%A_ScriptDir%\Settings.aldrin_dota2mod,Edits,choosetab
tablist=General|Search|Handy Injection|Migration|Miscellaneous|Advanced
Gui, MainGUI:Add, Tab2,x0 y0 h500 w550 -Wrap vOuterTab gSelectOuterTab choose%choosetab%, %tablist%
Gui, MainGUI:Tab,2
Gui, MainGUI:Add, Button,gbuttonsearch vtext9 x1 y30 h20 Default,Search for(keyword):
Gui, MainGUI:Add, Text, x66 y70 vtext10,ID:
Gui, MainGUI:Add, Text, x48 y90 vtext11,Name:
Gui, MainGUI:Add, Text, x45 y110 vtext12,Prefab:
Gui, MainGUI:Add, Text, x35 y130 vtext13,Item Slot:
Gui, MainGUI:Add, Text, x22 y150 vtext14,Model Path:
Gui, MainGUI:Add, Text, x1 y170 vtext15,Used by Heroes:
Gui, MainGUI:Add, Edit,vsearchbar x125 y30 w409 -WantReturn,
Gui, MainGUI:Add, Edit, vidbar x90 y70 w454 +ReadOnly,
Gui, MainGUI:Add, Edit, vnamebar x90 y90 w454 +ReadOnly,
Gui, MainGUI:Add, Edit, vprefabbar x90 y110 w454 +ReadOnly,
Gui, MainGUI:Add, Edit, vitemslotbar x90 y130 w454 +ReadOnly,
Gui, MainGUI:Add, Edit, vmodelpathbar x90 y150 w454 +ReadOnly,
Gui, MainGUI:Add, Edit, vheroesbar x90 y170 w454 +ReadOnly,
Gui, MainGUI:Add, Edit, vsearchshow x4 y190 w540 h260 +ReadOnly,
Gui, MainGUI:Tab,3
Gui, MainGUI:Tab,4
Gui, MainGUI:Add, text, vtext21,Select your "items_game.txt" you wish to be migrated on the latest "items_game.txt"
Gui, MainGUI:Add, DropDownList,choose1 x70 y50 w445 h21 gdirremover vmdirview,%mapmdirview%
mdirview_TT=To remove a list on this dropdownlist`, simply left-click this dropdownlist and then left-click the list you want to remove.
Gui, MainGUI:Font,Bold
Gui, MainGUI:Add, Button, x1 y50 w60 h21 gmdirbrowse vtext22, Browse
Gui, MainGUI:Add, Button, x205  y475 gmselectinject vtext23 hwndHBTN, Inject and Migrate
SetBtnTxtColor(HBTN, "Blue")
Gui, MainGUI:Font
Gui, MainGUI:Add, Text,x6 y80 w540 vtext24,"Migration System" is a Technique specially supported by this tool which allows the user to easily migrate all "default_item" assets of his/her old "items_game.txt" into the new "items_game.txt"(commonly targeted on newer patches of DOTA2). what this system do is:`n`n1)It copies every single item that has "prefab=default_item"`n2)Analyze every single item's "Unique ID" and remembers it`n3)Scans for "default_item" occurence on the "new items_game.txt" and compares both "old items_game.txt VS. new items_game.txt" using "ID assets comparement method"`n4)If the assets of both "old ID"(from old items_game.txt) assets does not pair the "new ID"(from new items_game.txt) assets`, that is where the migration will start. It will inject the "old ID assets" inside the "new ID assets"`,in other words "Copy the old assets then replace all new assets by paste ".
Gui, MainGUI:Tab,5
Gui, MainGUI:Tab,6
Gui, MainGUI:Add, CheckBox, checked%autovpk% x9 y70 gautovpkon vautovpkon,Auto-Shutnik Method(Requires "VPKCreator" present on same Directory)(SELF-ACTIVE)
autovpkon_TT=If this Option is ~ `n`nCHECKED : Everytime you Inject items at "General" and "Handy Injection"`, DOTA2 MOD Master will automatically generate a pak01_dir.vpk at "%dota2dir%\game\Aldrin_Mods\" Folder when the whole process is finished.`n`n*Prosequences`n-The whole MODDING Operation will be standalone`, meaning there is no need to do anything and DOTA2 will automatically be MODDED including all injected item sets since the user commands a straight forward operation on DOTA2 MOD Master.`n-Advisable for Beginners who dont know anything about "Manual Modding"`n`nConsequences`n-Since the straightforward operation auto-creates a .vpk file`, the user cannot manually edit the MOD anymore. But its OK if you dont know anything about manual modding.`n`n`nUNCHECKED : Everytime you Inject items at "General" and "Handy Injection"`, DOTA2 MOD Master will NOT generate a pak01_dir.vpk but instead will generate a "pak01_dir" folder found at "%A_ScriptDir%\Generated MOD\" Folder when the whole process is finished.`n`n*Prosequences`n-The user can browse all generated files by the injector and is free to modify its files for "Manual Modding". This is commonly used by MODDERS if they want to reupdate all cosmetic items by letting the injector extract cosmetic items from the real "%dota2dir%\game\dota\pak01_dir.vpk" folder.`n`nConsequences`n-DOTA2 MOD Master will not be responsible about the files found inside the "Generated MOD" Folder.`n-You have to Manually MOD DOTA2 by yourself.
Gui, MainGUI:Add, CheckBox, checked%maplowprocessor% x9 y90 vlowprocessor,Low-Processor Mode(Will result slow injection.Check this If you Experience your Computer HANG during Injection)
lowprocessor_TT=If this Option is ~ `n`nUNCHECKED : everytime you inject multiple command consoles will be launched when extracting model files.`n`n*Prosequences`n-the Operation will be a lot faster because the extraction is done simultaneously by multiple command consoles.`n`n*Consequences:`n-This will consume a lot of memory`, make sure that you have atleast 4gb RAM if you leave this option unchecked`n`n`nCHECKED : everytime you inject only a single command console will be launched when extracting model files.`n`n*Prosequences`n-It will not consume RAM when extracting models since only one command console is done one at a time. Leaving this option checked is advisable for Low-End PC's`n`n*Consequences`n-The operation will consume a lot of TIME since the since every command console finishes its extraction process for an approximate 3-5 seconds. If you have included almost 300+ items on the operation`, expect a 300 x 5 = 1500 seconds(25 minutes) plus additional time on the operation.
if (mapdota2dir="") or (!FileExist(mapdota2dir))
{
	ifexist,%SteamPath%\steamapps\common\dota 2 beta\game\dota\pak01_dir.vpk
	{
		mapdota2dir=%SteamPath%\steamapps\common\dota 2 beta
		IniWrite,%mapdota2dir%,%A_ScriptDir%\Settings.aldrin_dota2mod,Edits,mapdota2dir
	}
	else
	{
		msgbox,16,ERROR!!!,DOTA2 Directory cannot be detected`, Please Locate the Directory of your DOTA2 Game with this specific location exist inside that folder "game\dota\pak01_dir.vpk" found at "%SteamPath%/steamapps/common/"
		d2find=1
	}
}
Gui, MainGUI:Add, DropDownList,choose1 x65 y125 w430 h21 vdota2dir,%mapdota2dir%
Gui, MainGUI:Font,Bold
Gui, MainGUI:Add, Button, x1 y125 w60 h21 gd2locbrowse vd2locbrowse, Browse
d2locbrowse_TT=Browse where the DOTA2 Game Folder is located
if d2find=1
{
	gosub,d2locbrowse
}
if (mapgiloc="") or (FileExist(mapgiloc)="")
{
	ifexist,%dota2dir%\game\dota\gameinfo.gi
	{
		mapgiloc=%dota2dir%\game\dota\gameinfo.gi
		IniWrite,%mapgiloc%,%A_ScriptDir%\Settings.aldrin_dota2mod,Edits,mapgiloc
	}
}
Gui, MainGUI:Add, Button, x1 y45 w60 h21 ggilocbrowse vgilocbrowse, Browse
gilocbrowse_TT=Browse the location of DOTA2's gameinfo.gi
Gui, MainGUI:Add, Button,gpatchgi h15 x1 y30 hwndHBTN vpatchgi,Patch "gameinfo.gi" Location
SetBtnTxtColor(HBTN, "Blue")
patchgi_TT=Press this button to manually patch gameinfo.gi.`n`nThis button requires gameinfo.gi to be defined below this button. If not defined yet`, press browse button and located gameinfo.gi(found at steam\steamapps\common\dota\gameinfo.gi)`n`nWhat is the importance of gameinfo.gi?`nThe registration of the MOD's main location will be registered on this file. If this file is not defined or is missing`, Auto-Shutnik Method will not work.
Gui, MainGUI:Add, Button, x165 y475 gselectreset vtext26 hwndHBTN,Remove MOD on DOTA2
SetBtnTxtColor(HBTN, "Red")
Gui, MainGUI:Font
Gui, MainGUI:Add, Text,x1 y110,"DOTA2" Location(found at "steam\steamapps\common\")
Gui, MainGUI:Add, DropDownList,choose1 x65 y45 w430 h21 gdirremover vgiloc,%mapgiloc%
giloc_TT=To remove a list on this dropdownlist`, simply left-click this dropdownlist and then left-click the list you want to remove.`n`nNote: Game Info(GI) is important for Auto-Shutnik Method. So keep in mind emptying the list on this dropdownlist will lose functionality to auto-shutnik method.
Gui, MainGUI:Add, Text,x180 y30,(commonly exist at "dota 2 beta\game\dota\")
Gui, MainGUI:Add, CheckBox, checked%soundon% x9 y150 vsoundon,Enable Voice-Actived Narrator
soundon_TT=Checking this Option will use Artificial Narration that announces current operation status.
Gui, MainGUI:Add, CheckBox, checked%fastmisc% x9 y170 vfastmisc,Remember Miscellaneous Resources for fast Preload(Not advisable to be checked. if you want to accurately preload all Miscellaneous resources`, leave this option unchecked)
fastmisc_TT=If this Option is ~ `n`nCHECKED : Everytime DOTA2 MOD Master preloads Miscellaneous resources`, it automatically remembers all Miscellaneous resources upon the next start by creating a reference file. So that if the real items_game.txt is not changed by updates/patches`, Fast Preloading will be done.`n`n*Prosequences`n-Ultra Fast Preloading every start of DOTA2 MOD Master.`n-Does not need to Redefine all Miscellaneous Resources every start.`n`n*Consequences`n-Since I still have not proved if this option will produce innacurate results`, the most expected consequence that I predicted is "Innacurate" Resources. It might have some "MISSING Miscellaneous Resources" that should be present or might produce an "Extra BLANK Row" that is irritating.`n`n`nUNCHECKED : It always scan Miscellaneous Resources at items_game.txt file every start.`n`n*Prosequences`n-Preloading Miscellaneous resources is FULLY Accurate since it always scans items_game.txt every start. Making sure that every single Miscellaneous resource will be present on every lists.`n`n*Consequences`n-Slower Startup since DOTA2 MOD Master needs to Preload "Miscellaneous" Resources first before it is allowed to be used. 
Gui, MainGUI:Add, CheckBox, checked%showtooltips% x9 y190 vshowtooltips gshowtooltips,Show Tooltip Guides on every Controls.
Gui, MainGUI:Add, text,x4 y210,ERROR Log
Gui, MainGUI:Add, Edit, verrorshow x4 y225 w266 h226 +ReadOnly,
Gui, MainGUI:Add, text,x276 y210 vtext32,Report Log
Gui, MainGUI:Add, Edit, vreportshow x276 y225 w266 h226 +ReadOnly,
Gui, MainGUI:Tab
Gui, MainGUI:Add, Progress, x4 y452 w540 -smooth vMyProgress Range0-1000,
GuiControl,MainGUI:Hide,MyProgress
Gui, MainGUI:Add, Button, x2 y475 gselectsave vtext30,Save Settings
text30_TT=All Settings found at "Advanced" Section will be Saved`n`n`nSaves the current priority ranking of External Folders found at "External Files" Sub-Section since it is not autosaved.
Gui, MainGUI:Font,Bold
Gui, MainGUI:Add, Button, x430 y475 h23 ginvccabout vtext31 hwndHBTN, About MOD Master
SetBtnTxtColor(HBTN, "Gold")
Gui, MainGUI:Add, Text,x450 y5 hwndHBTN vtext45,v%version%
SetBtnTxtColor(HBTN, "Bronze")
Gui, MainGUI:Font
Gui, MainGUI:Add, Text,vsearchnofound x4 y455 w540,%defaultshoutout%
Gui, MainGUI:Font,Bold cred
Gui, MainGUI:Add, CheckBox,checked%usemisc% x145 y475 gusemiscon vusemiscon,Use Miscellaneous on Future Injection
usemiscon_TT=Miscellaneous is used by "Handy Injection" and "General" Section which injects extra functionalities`n`n`nIf this Option is ~ `n`nCHECKED : Miscellaneous Resources will be preloaded On Startup`, allowing the use of Miscellaneous.`n`n*Prosequences`n-Allows "Handy Injection" and "General" Section to inject selected miscellaneous resources.`n-Allows "Handy Injection" and "General" Section's Saved List Database to preload their present Miscellaneous Data's`n-Allows "Handy Injection" and "General" Section to Add Miscellaneous Data's when saving a Database List.`n`n*Consequences`n-Requires to Preload all Miscellaneous first on startup which will take time ti finish.`n`n`nUNCHECKED : Miscellaneous Resources will not be loaded on startup.`n`n*Prosequences`n-Instant Startup since Miscellaneous will not be Preloaded.`n`n*Consequences`n-"Handy Injection" and "General" Section will not include Miscellaneous Section on its Operations.`n-"Handy Injection" and "General" Section's WILL NOT include Miscellaneous Data's when preloading a database list`n-"Handy Injection" and "General" Section will not include Miscellaneous Data's when creating a Database List.
Gui, MainGUI:Font

Gui, MainGUI:Font,Bold
Gui, MainGUI:Add, CheckBox,checked%useextportraitfile% x1 y145 w300 vuseextportraitfile,Use the External File's "portraits.txt" instead of the Operation's "portraits.txt"
Gui, MainGUI:Add, Button, x180 y60 h23 gextlistrefresh vextlistrefresh hwndHBTN, Refresh Lists
extlistrefresh_TT=Rescans all present folders found at Folder:`n%A_ScriptDir%\External Files\`n`nAlso defines some informations about the folder.
SetBtnTxtColor(HBTN, "Green")
Gui, MainGUI:Add, Button, x50 y50 h23 gextlistup vextlistup hwndHBTN, Move Up
extlistup_TT=Any selected rows on the listview below will move upwards`, increasing its priority rank.
SetBtnTxtColor(HBTN, "PURPLE")
Gui, MainGUI:Add, Button, x43 y75 h23 gextlistdown vextlistdown hwndHBTN, Move Down
extlistdown_TT=Any selected rows on the listview below will move downwards`, decreasing its priority rank.
SetBtnTxtColor(HBTN, "GRAY")
Gui, MainGUI:Font,Bold cblue
Gui, MainGUI:Add, CheckBox,checked%useextfile% x112 y475 vuseextfile,Include the External Files on Future Operations
Gui, MainGUI:Font,Bold cred
Gui, MainGUI:Add, CheckBox,checked%useextitemgamefile% x1 y100 h45 w300 vuseextitemgamefile,Use the External File's "items_game.txt" instead of the Operation's "items_game.txt"
useextitemgamefile_TT=This is not advisable to be checked since the operations's generated items_game.txt is accurate and stable. ANY PRESENCE OF AN UNUPDATED/CORRUPTED ITEMS_GAME.TXT while this option is checked might lead to UNEXPECTED GAME CRASH`,IMMEDIATE TERMINATION OF THE GAME. Check this at your own risk and make sure that you know what you are doing
Gui, MainGUI:Font
Gui, MainGUI:Add, Text,vtext46 x305 y45 w225 h400,This Section is all about adding custom files. If you wish to include custom model(.vmdl_c)`,particle effects(.vpcf_c)`, or even your own items_game.txt`,You can include external files that will be added on the operations files.`n`nExternal Files is commonly used if you have your own "pak01_dir" folder which have custom item sets(including arcanas) and "you want to use this files that instead of using the operational files(.vmdl_c`,.vpcf_c`,items_game.txt`,ect)".`n`nExternal Files is the "workaround" for "malfunctioning cosmetic items in online games"(eg. arcana items`,no default prefab cosmetic items)`, to Do this`, Put your custom "pak01_dir" folder at:`n`n%A_ScriptDir%\External Files\`n`nAny folder found at the "External Files" Folder will be included on the listview(make sure to click "Refresh Lists").`n`nThe Priority Ranking indicates the Majority ranking of the external files`,any rows that are above other rows will not be overwritten by the rows beneath them`, but rows that are below other rows will be overwritten by files with the same match which a row above it has.
Gui, MainGUI:Add, ListView,x1 y170 w280 h250 vextfilelist AltSubmit checked NoSortHdr NoSort ,Priority Rank|Folder Name|Model Files Present|Particle Files Present|Has items_game.txt|Has portraits.txt|Folder Location


;;;controls the external file's controls and also all hidden controls
hiddencontrols=InnerTab,InnerTab1,InnerTab2,usemiscon
hiddencontrolscontroller=Miscellaneous,Handy Injection,General,Miscellaneous

exthiddencontrols=extlistrefresh,extlistup,extlistdown,extfilelist,text46,useextitemgamefile,useextfile,useextportraitfile
exthiddencontrolscontroller=Handy Injection,General
exthiddencontrolstab=InnerTab1,InnerTab2
;;;;

IniRead,inchoosetab2,%A_ScriptDir%\Settings.aldrin_dota2mod,Edits,inchoosetab2
intablist2=Main|External Files
Gui, MainGUI:Add, Tab2,x0 y20 h480 w550 -Wrap gSelectOuterTab vInnerTab2 hwndInnerTab2 choose%inchoosetab2%,%intablist2%
Gui, MainGUI:Tab,1
Gui, MainGUI:Add, Edit,Number x185 y110 w140 h23 vinjectto,
Gui, MainGUI:Font,Bold
Gui, MainGUI:Add, Button, x460 y112 w84 h23 ginvupdate vtext1 hwndHBTN, Update
text1_TT=Add's the properties in the listview`, defining that "Code to Inject(ID)" will inject "Inject to(ID)".`n`n`nIf "Code to Inject(ID)" is already present on the listview's "Resource ID" Column`, it will just update the "Injected ID" of the same row into the defined "Inject to(ID)"`n`n`nIf "Inject to(ID)" is already present on the listview's "Injected ID" Column`, it will just update the "Resource ID" of the same row into the defined "Code to Inject(ID)"
SetBtnTxtColor(HBTN, "Green")
Gui, MainGUI:Add, Button, x460 y80 w84 h23 ginvdelete vtext2 hwndHBTN, Delete
text2_TT=Deletes all selected rows on the listview`, you can select multiple rows to delete the all at the same time.
SetBtnTxtColor(HBTN, "Red")
Gui, MainGUI:Add, Button, x1 y420 h21 gdatabrowse vtext6, Browse Database
text6_TT=Browse a General Database that has an extension of ( .aldrin_dota2db ).`n`nPreloading a database will define all your collections of items.`n`n`nTake Note : General Database( .aldrin_dota2db ) is different from Handy Injection Database( .aldrin_dota2hidb )
Gui, MainGUI:Add, Button, x116 y475 gdatasave vtext7 hwndHBTN,Save List Database
text7_TT=Saves all items found on the listview including all selected miscellaneous resources`, creating a General Database with Extension ( .aldrin_dota2db ).`n`n`nCreating a General Database will allow you to define all your collections and redefine all of them in the future. So that you can continue your previous work and just update the database.
SetBtnTxtColor(HBTN, "Green")
Gui, MainGUI:Add, Button, x273 y475 gselectinject vtext8 hwndHBTN, Inject all Actived ID's
SetBtnTxtColor(HBTN, "Blue")
Gui, MainGUI:Add, Button, x1 y45 w60 h21 ginvbrowse vtext5, Browse
text5_TT=Browse your custom "items_game.txt" if you want to use it instead of the current items_game.txt
Gui, MainGUI:Font
Gui, MainGUI:Add, ListView, vinvlv ginvlv x1 y138 w545 h280 checked AltSubmit, Resource ID|Injected ID|Resource Name|Injected Name|Item Styles Count|Current Item Style
invlv_TT=Right-Click an item to change its Item Style
Gui, MainGUI:Add, Text, x10 y95 vtext3,Code to Inject(ID)
Gui, MainGUI:Add, Text, x185 y95 vtext4,Inject to(ID)
Gui, MainGUI:Add, Edit,Number x10 y110 w140 h23 vinjectfrom,
Gui, MainGUI:Add, DropDownList,choose1 x61 y45 w485 h21 gdirremover vinvdirview,%mapinvdirview% ; 30+15
invdirview_TT=To remove a list on this dropdownlist`, simply left-click this dropdownlist and then left-click the list you want to remove.
Gui, MainGUI:Add, CheckBox, checked%ucr% x6 y70 vucron gucron,Use the custom "items_game.text"(chosen above) as Resource ID?
ucron_TT=If you have your own "items_game.txt" and you want to use this custom items_game.txt on the General's Operations instead of the real items_game.txt`, Check this Option. This Option is commonly used by MODDERS who know what they're doing.`n`n`nIf this Option is ~ `n`nCHECKED : Uses the custom "items_game.txt" on the future Operations here at "General" Section. This option can only be checked if you already defined the custom items_game.txt above.`n`n*Prosequences`n-If you have a modified items_game.txt(with latest references) for example`, have a modified dire/radiant towers which DOTA2 MOD Master still does not support yet. The injector will use this MODIFIED items_game.txt for future use`n`n*Consequences`n-If the "custom items_game.txt" is OLD/corrupted/unstable`, it will lead to EVIL CRASH when playing the game. That is why it is unadvisable checking this option if you dont know what you're doing`n`n`nUNCHECKED : Uses the real "items_game.txt" provided by DOTA2 MOD Master on the future Operations here at "General" Section.`n`n*Prosequences`n-Stable and Successful Operation.
Gui, MainGUI:Add, DropDownList,choose1 x112 y420 w435 h21 gdirremover vdatadirview,%mapdatadirview%
datadirview_TT=To remove a list on this dropdownlist`, simply left-click this dropdownlist and then left-click the list you want to remove.


IniRead,inchoosetab1,%A_ScriptDir%\Settings.aldrin_dota2mod,Edits,inchoosetab1
intablist1=Hero Items Selection|Used Items Database|Statistics|Custom Heroes|External Files
Gui, MainGUI:Add, Tab2,x0 y20 h480 w550 -Wrap gSelectOuterTab vInnerTab1 hwndInnerTab1 choose%inchoosetab1%,%intablist1%
Gui, MainGUI:Tab,1
Gui, MainGUI:Add, ComboBox,x1 y45 w155 h405 gherochoice vherochoice Choose1 Simple,%mapherochoice%
Gui, MainGUI:Add, ListView,NoSort vshowitems gdoitems x173 y45 w375 h405 checked AltSubmit,Item Name|Item Slot|Rarity|Item ID|Used by|Styles Count|Active Style
showitems_TT=Right-Click an item to:`n`n*Change its Item Style`n`n*Delete Selected Rows
Gui, MainGUI:Font,Bold
Gui, MainGUI:Add, Button, x283 y475 ghdatasave vtext16 hwndHBTN,Save List Database
text16_TT=Saves all items found on "Used Items Database" Sub-Section's Listview including all selected miscellaneous resources`, creating a Handy Injection Database with Extension ( .aldrin_dota2hidb ).`n`n`nCreating a Handy Injection Database will allow you to define all your collections and redefine all of them in the future. So that you can continue your previous work and just update the database.
SetBtnTxtColor(HBTN, "Green")
Gui, MainGUI:Add, Button, x116  y475 ghselectinject vtext17 hwndHBTN, Inject all Actived ID's
SetBtnTxtColor(HBTN, "Blue")
Gui, MainGUI:Font
Gui, MainGUI:Tab,2
Gui, MainGUI:Add, ListView,gitemview vitemview x1 y45 w545 h371 AltSubmit,Item Name|Item Slot|Rarity|Item ID|Used by|Styles Count|Active Style
itemview_TT=Right-Click an item to change its Item Style
Gui, MainGUI:Add, DropDownList,choose1 x112 y420 w280 h21 gdirremover vhdatadirview,%maphdatadirview%
hdatadirview_TT=To remove a list on this dropdownlist`, simply left-click this dropdownlist and then left-click the list you want to remove.
Gui, MainGUI:Font,Bold
Gui, MainGUI:Add, Button,x395 y420 w150 h21 gVerifyListviewIntegrity vtext51 hwndHBTN,Verify ListView Integrity
text51_TT=Examine all informations found at the ListView. Detecting Errors,Corruption affecting the database.`n`nThis Also Refreshes all informations that have errors, See ErrorLog at Advanced Section for further Details about the Operation Afterwards.
SetBtnTxtColor(HBTN, "Purple")
Gui, MainGUI:Add, Button, x1 y420 h21 ghdatabrowse vtext18, Browse Database
text18_TT=Browse a Handy Injection Database that has an extension of ( .aldrin_dota2hidb ).`n`nPreloading a database will define all your collections of items.`n`n`nTake Note : Handy Injection Database( .aldrin_dota2hidb ) is different from General Database( .aldrin_dota2db )
Gui, MainGUI:Add, Button, x283 y475 ghdatasave vtext19 hwndHBTN,Save List Database
text19_TT=Saves all items found on the Listview above including all selected miscellaneous resources`, creating a Handy Injection Database with Extension ( .aldrin_dota2hidb ).`n`n`nCreating a Handy Injection Database will allow you to define all your collections and redefine all of them in the future. So that you can continue your previous work and just update the database.
SetBtnTxtColor(HBTN, "Green")
Gui, MainGUI:Add, Button, x116  y475 ghselectinject vtext20 hwndHBTN, Inject all Actived ID's
SetBtnTxtColor(HBTN, "Blue")
Gui, MainGUI:Font
Menu, MyContextMenu, Add, Delete, hbuttondelete
Menu, MyContextMenu, Add, Change Style, hbuttonstyle
Gui, MainGUI:Tab,3
Gui, MainGUI:Add, Text, x1 y45,Calibrator Settings
Gui, MainGUI:Add, ListView,NoSort vstatscalibrator gstatscalibrator x1 y60 w150 h390 checked AltSubmit,Item Slot
statscalibrator_TT=You can manually calibrate what the statistics will recognize as a valid item slot.`n`nIf the Item Slot is checked, the statistics will include this item slot when counting hero number of item slots.`n`nIf the Item Slot is unchecked, the statistics will reject this item slot when counting hero number of item slots.
Gui, MainGUI:Add, ListView,vslotstats x155 y45 w391 h405 AltSubmit,Hero Name|Item Slots Count|Item Slots Occupied|Item Slots Unoccupied
Gui, MainGUI:Tab,4
Gui, MainGUI:Add, ListView,gchview vchview x1 y45 w300 h405 AltSubmit,Custom Hero|Existence
Gui, MainGUI:Font,Bold
Gui, MainGUI:Add, Button, x310 y75 gchadd vtext25 hwndHBTN,Add Hero
SetBtnTxtColor(HBTN, "Blue")
Gui, MainGUI:Add, Button, x425 y75 gchsave vtext27 hwndHBTN,Save and Reload
text27_TT=You need to Save all the list you just added and reload the script so that on the next start it will be included on the combobox found at "Hero Items Selection" Sub-Section.
SetBtnTxtColor(HBTN, "Green")
Gui, MainGUI:Font
Gui, MainGUI:Add, Edit, vchbar x310 y45 w225,
Gui, MainGUI:Add, Text, x310 y105 w225 vtext28,This section is all about adding custom heroes and be used on future count of heroes present at "Handy Injection" Section`n`nCommon reasons of adding "Custom Heroes":`n-You are testing a custom added hero of yours on DOTA2 and added "item slots" on it.`n`nwhat is inside this section where:`n*Edit Box-type the FULL HERO NAME(npc_dota_hero_***) here. Example:npc_dota_hero_rubick and NOT rubick(without npc_dota_hero_)`n*List(left-side)-this is where the list of custom heroes are listed`n*Add-adds the current typed hero on the list`n*Save and Reload-if you are already finished adding custom heroes and ready to use it.This tool needs to preload its resources first by reloading the script and saving the names of the custom heroes.
Menu, chContextMenu, Add, Delete, chbuttondelete
IniRead,inchoosetab,%A_ScriptDir%\Settings.aldrin_dota2mod,Edits,inchoosetab
intablist=Single Source|Multiple Styles|Multiple Source|Optional Features
Gui, MainGUI:Add, Tab2,x0 y20 h480 w550 -Wrap vInnerTab hwndInnerTab choose%inchoosetab%,%intablist%
Gui, MainGUI:Tab,1
Gui, MainGUI:Add, ListView,x1 y45 w137 h201 gbasicmisc vterrainchoice AltSubmit checked,Terrain Name|Rarity|ID
Gui, MainGUI:Add, ListView,x137 y45 w137 h201 gbasicmisc vweatherchoice AltSubmit checked,Weather-Effect Name|Rarity|ID
Gui, MainGUI:Add, ListView,x274 y45 w137 h201 gbasicmisc vmultikillchoice AltSubmit checked,Multikill-Banner Name|Rarity|ID
Gui, MainGUI:Add, ListView,x411 y45 w137 h201 gbasicmisc vemblemchoice AltSubmit checked,Emblem Name|Rarity|ID
Gui, MainGUI:Add, ListView,x1 y248 w182 h201 gbasicmisc vmusicchoice AltSubmit checked,Music-Pack Name|Rarity|ID
Gui, MainGUI:Add, ListView,x184 y248 w182 h201 gbasicmisc vcursorchoice AltSubmit checked,Cursor-Pack Name|Rarity|ID
Gui, MainGUI:Add, ListView,x367 y248 w182 h201 vloadingscreenchoice gbasicmisc AltSubmit checked,Loading-Screen Name|Rarity|ID
Gui, MainGUI:Tab,2
Gui, MainGUI:Add, ListView,x365 y45 w180 h201 gmiscstyle vhudchoice AltSubmit checked,HUD-Skin Name|Rarity|ID|Styles Count|Active Style
Gui, MainGUI:Add, ListView,x365 y248 w180 h201 gmiscstyle vradcreepchoice AltSubmit checked,Radiant Creeps Name|Rarity|ID|Styles Count|Active Style
Gui, MainGUI:Add, ListView,x183 y248 w180 h201 gmiscstyle vdirecreepchoice AltSubmit checked,Dire Creeps Name|Rarity|ID|Styles Count|Active Style
Gui, MainGUI:Add, ListView,x1 y45 w180 h404 vcourierchoice gmiscstyle AltSubmit checked,Courier Name|Rarity|ID|Styles Count|Active Style
Gui, MainGUI:Add, ListView,x183 y45 w180 h201 vwardchoice gmiscstyle AltSubmit checked,Ward Name|Rarity|ID|Styles Count|Active Style
Gui, MainGUI:Tab,3
Gui, MainGUI:Add, ListView,gannouncerview vannouncerview x275 y45 w272 h404 AltSubmit NoSort checked,Announcer Name|Item Slot|Rarity|ID
Gui, MainGUI:Add, ListView,gtauntview vtauntview x1 y45 w272 h404 AltSubmit NoSort checked,Taunt Name|Rarity|ID|Used by
Gui, MainGUI:Tab,4
Gui, MainGUI:Add, CheckBox, checked%pet% x9 y60 vpeton,Active "Almond the Frondillo" Pet with Style:
if (mappetstyle="") or (mappetstyle="ERROR")
{
	mappetstyle=3
}
else if mappetstyle=0
{
	mappetstyle=1
}
Gui, MainGUI:Add, DropDownList,R3 x240 y60 w40 h20 vpetstyle choose%mappetstyle%,0|1|2
petstyle_TT=Select the current style of Almond the Frondillo:`n`n`nStyle 0 - Natural Color`n`nStyle 1 - Red Shelled Almond the Frondillo`n`nStyle 2 - Golden Shelled Almond the Frondillo
innertabparam=InnerTab,InnerTab1,InnerTab2 ;;;used always at anchor
loop,parse,innertabparam,`,
{
	tempo:=%A_LoopField%
	WinSet Top,, ahk_id %tempo%
}

Gui, MainGUI:Submit, NoHide
gosub, SelectOuterTab
Gui, MainGUI:Show, h500 w550 ,AJOM's Dota 2 MOD Master
Gui, MainGUI:Default
gosub,MainGUIGuiSize ; Anchor Function requires this command so that it will get all the offsets of each controls
if usemiscon=1
{
	GoSub,miscreload
}
if A_DefaultListView<>itemview
{
	Gui, MainGUI:ListView,itemview
}
LV_Delete()
GoSub,chreload
if datadirview<>
{
	if usemiscon=1
	{
		if (hdatadirview<>"") and (datadirview<>"")
		{
			Gui MainGUI:+OwnDialogs
			SetTimer,ChangeButtonNames,1
			msgbox,292,Miscellaneous Resources Conflict,The tool currently preloads two database files`, a General Database and a Handy-Injection Database. Miscellaneous can only be used by one database file. Choose which database will use the Miscellaneous Resources.`n`n`nNote: The other unselected one will not preload its Miscellaneous Resources.
			IfMsgBox, Yes 
			{
				tempo=1
			}
		}
		else tempo=1
	}
	GoSub,datareload
	if (usemiscon=1) and (tempo=1)
	{
		reloadmisc(datadirview) ; ;Scans the database then put a checkmark on each miscellaneous it uses
	}
	if soundon=1
	{
		SoundPlay,%A_Temp%\Sound\loaddatacomplete.wav
	}
}
else tempo=0
if hdatadirview<>
{
	hdatareload(hdatadirview)
	checkdetector() ; check any field that exist on the listview "itemview"
	if (usemiscon=1) and (tempo<>1)
	{
		reloadmisc(hdatadirview) ; ;Scans the database then put a checkmark on each miscellaneous it uses
	}
	if soundon=1
	{
		SoundPlay,%A_Temp%\Sound\loaddatacomplete.wav
	}
}
gosub,extlistrefresh

;;
GuiControl,-g,statscalibrator
gosub,slotstats ; construct the handy-injection statistics
GuiControl,+gstatscalibrator,statscalibrator
;;

if newuser=1
{
	msgbox,36,Welcome New User!,It Looks like this is the first time you have used this Tool. Would you like to know the facts about using this Tool?(This will be helpful if you dont have an idea using this tool)
	IfMsgBox Yes
	{
		gosub,invccabout
		guicontrol,aboutgui:ChooseString,tababout,Fact
	}
}
else if version>%usedversion%
{
	msgbox,36,Hey There!,It Looks like this Version is Newer. Would you like to know the Changelog of this Version?
	IfMsgBox Yes
	{
		gosub,invccabout
		guicontrol,aboutgui:ChooseString,tababout,Changelog
	}
}
if version<>%usedversion%
{
	IniWrite,%version%,%A_ScriptDir%\Settings.aldrin_dota2mod,Edits,usedversion
}
gosub,leakdestroyer
gosub,showtooltips
Gui, MainGUI:Default
return

ChangeButtonNames:
IfWinNotExist,Miscellaneous Resources Conflict
    return  ; Keep waiting.
SetTimer, ChangeButtonNames, Off
ControlSetText, Button1,General
ControlSetText, Button2,HandyInjection
return

patchgi:
Gui, MainGUI:Submit, NoHide
ifnotExist,%giloc%
{
	Gui, MainGUI:+Disabled 
	guicontrol,,autovpkon,0
	msgbox,20,ERROR!,The located "gameinfo.gi" path Does not EXIST! Would you Like to browse the "gameinfo.gi" location? exist at "steam\steamapps\common\dota 2 beta\game\dota\gameinfo.gi"
	if IfMsgBox Yes
	{
		gosub,gilocbrowse
		if invfile<>
		{
			guicontrol,,autovpkon,1
		}
		else
		{
			return
		}
	}
	else
	{
		return
	}
	Gui, MainGUI:-Disabled 
}
else if giloc=
{
	Gui, MainGUI:+Disabled 
	guicontrol,,autovpkon,0
	msgbox,20,ERROR!,Please locate "gameinfo.gi" first before activating this feature. Would you Like to browse the "gameinfo.gi" location? exist at "steam\steamapps\common\dota 2 beta\game\dota\gameinfo.gi"
	if IfMsgBox Yes
	{
		gosub,gilocbrowse
		if invfile<>
		{
			guicontrol,,autovpkon,1
		}
		else
		{
			return
		}
	}
	else
	{
		return
	}
	Gui, MainGUI:-Disabled 
}
Gui, MainGUI:+Disabled 
GuiControl,Text,searchnofound,Patching gameinfo.gi
Gui, MainGUI:Submit, NoHide
gosub,gipatcher
GuiControl,Text,searchnofound,%defaultshoutout%
Gui, MainGUI:-Disabled 
return

percentsound:
if (progress>=250) and (soundswitch1=0) and (sound25=1)
{
	soundswitch1=1
	SoundPlay,%A_Temp%\Sound\25.wav
}
else if (progress>=350) and (soundswitch2=0) and (sound25=1)
{
	soundswitch2=1
	SoundPlay,%A_Temp%\Sound\35.wav
}
else if (progress>=500) and (soundswitch3=0) and (sound25=1)
{
	soundswitch3=1
	SoundPlay,%A_Temp%\Sound\50.wav
}
else if (progress>=650) and (soundswitch4=0) and (sound25=1)
{
	soundswitch4=1
	SoundPlay,%A_Temp%\Sound\65.wav
}
else if (progress>=750) and (soundswitch5=0) and (sound25=1)
{
	soundswitch5=1
	SoundPlay,%A_Temp%\Sound\75.wav
}
return

initsound:
sound25:=sound35:=sound50:=sound65:=sound75:=soundswitch1:=soundswitch2:=soundswitch3:=soundswitch4:=soundswitch5:=0
soundratio2:=soundint*0.75
soundratio:=soundratio2/30
if (soundratio<5) and (soundratio>1)
{
	soundratio1:=soundratio2/soundratio
	loop %soundratio%
	{
		if A_Index=1
		{
			tmp4:=soundratio1
		}
		else if A_Index=%soundratio%
		{
			tmp4:=soundratio2
		}
		else
		{
			tmp4:=soundratio2/A_Index
		}
		if tmp4<29.99
		{
			sound25=1
		}
		else if (tmp4>=30) and (tmp4<50)
		{
			sound35=1
		}
		else if (tmp4>=42.5) and (tmp4<57.49)
		{
			sound50=1
		}
		else if (tmp4>=57.5) and (tmp4<69.99)
		{
			sound65=1
		}
		else if tmp4>=70
		{
			sound75=1
		}
	}
}
else if soundratio>1
{
	sound25:=sound35:=sound50:=sound65:=sound75:=1
}
return

ucron:
Gui, MainGUI:Submit, NoHide
if ucron=1
{
	if invdirview=
	{
		Gui, MainGUI:+Disabled 
		guicontrol,,ucron,0
		msgbox,16,ERROR!,Please locate the custom "items_game.txt" first before activating this feature.
		Gui, MainGUI:-Disabled 
	}
	else ifnotExist,%invdirview%
	{
		Gui, MainGUI:+Disabled 
		guicontrol,,ucron,0
		msgbox,16,ERROR!,The located custom "items_game.txt" path Does not EXIST!
		Gui, MainGUI:-Disabled 
	}
}
return

SelectOuterTab:
Gui, MainGUI:Submit, NoHide
;uses hiddencontrols and hiddencontrolscontroller
loop,parse,hiddencontrolscontroller,`,
{
	tabintparam=%A_Index%
	tabfieldsaver=%A_LoopField%
	loop,parse,hiddencontrols,`,
	{
		if tabintparam=%A_Index%
		{
			if OuterTab=%tabfieldsaver%
			{
				GuiControl, MainGUI:Show,%A_LoopField%
			}
			else
			{
				GuiControl, MainGUI:Hide,%A_LoopField%
			}
		}
	}
}
;uses exthiddencontrols and exthiddencontrolscontroller
tabswitch=0
loop,parse,exthiddencontrolscontroller,`,
{
	tabfieldsaver=%A_LoopField%
	tabintparam=%A_Index%
	loop,parse,exthiddencontrolstab,`,
	{
		tempo:=%A_LoopField%
		if tabintparam=%A_Index%
		{
			loop,parse,exthiddencontrols,`,
			{
				if (OuterTab=tabfieldsaver) and (tempo="External Files")
				{
					GuiControl, MainGUI:Show,%A_LoopField%
					tabswitch=1
				}
				else
				{
					GuiControl, MainGUI:Hide,%A_LoopField%
				}
			}
		}
	}
	if tabswitch=1
	{
		break
	}
}
if (OuterTab="Handy Injection") and (InnerTab1="Statistics")
{
	refreshstatistics() ; construct the statistics sub section
}
WinSet, Redraw, , A
return

selectreset:
Gui MainGUI:+OwnDialogs
msgbox,68,Confirm Removal,You are about to REMOVE the MOD from your DOTA2. Are you sure you want to to Continue?
IfMsgBox Yes
{
	Gui, MainGUI:+Disabled 
	GuiControl,MainGUI:Text,searchnofound,Deleting "%dota2dir%\game\Aldrin_Mods" Folder
	FileRemoveDir,%dota2dir%\game\Aldrin_Mods,1
	if soundon=1
	{
		SoundPlay,%A_Temp%\Sound\Removed.wav
	}
	GuiControl,MainGUI:Text,searchnofound,%defaultshoutout%
	
	Gui, MainGUI:-Disabled 
}
return

showprogress:
GuiControl,MainGUI:, MyProgress,
GuiControl,MainGUI:Show,MyProgress
return

hideprogress:
GuiControl,MainGUI:Hide,MyProgress
GuiControl,MainGUI:, MyProgress,
return

createvpk:
ifnotexist,%A_ScriptDir%\Plugins\VPKCreator\vpk.exe
{
	IfNotExist,%A_ScriptDir%\Generated MOD\
	{
		FileCreateDir, %A_ScriptDir%\Generated MOD
	}
	ifexist,%A_ScriptDir%\Generated MOD\items_game.txt
	{
		FileDelete,%A_ScriptDir%\Generated MOD\items_game.txt
	}
	FileAppend,%masterfilecontent%,%A_ScriptDir%\Generated MOD\items_game.txt
	Run, %A_ScriptDir%\Generated MOD\
	msgbox,16,ERROR!,"vpk.exe" is missing at:`n`n%A_ScriptDir%\Plugins\VPKCreator\`n`nMake sure to download "VPKCreator" and put all its files inside the required directory(%A_ScriptDir%\Plugins\VPKCreator\)`n`nAlternatively`,manually creating items_game.txt
	return
}
else ifnotexist,%giloc%
{
	IfNotExist,%A_ScriptDir%\Generated MOD\
	{
		FileCreateDir, %A_ScriptDir%\Generated MOD
	}
	ifexist,%A_ScriptDir%\Generated MOD\items_game.txt
	{
		FileDelete,%A_ScriptDir%\Generated MOD\items_game.txt
	}
	FileAppend,%masterfilecontent%,%A_ScriptDir%\Generated MOD\items_game.txt
	Run, %A_ScriptDir%\Generated MOD\
	msgbox,16,ERROR!,%giloc%`n`ndoes not exist! Cancelling vpk creation and manually creating items_game.txt
	return
}
gosub,hideprogress
GuiControl,Text,searchnofound,Shutnik Method: patching gameinfo.gi
IfNotExist,%A_ScriptDir%\Plugins\VPKCreator\pak01_dir\scripts\items\
{
	FileCreateDir,%A_ScriptDir%\Plugins\VPKCreator\pak01_dir\scripts\items
}
else ifexist,%A_ScriptDir%\Plugins\VPKCreator\pak01_dir\scripts\items\items_game.txt
{
	FileDelete,%A_ScriptDir%\Plugins\VPKCreator\pak01_dir\scripts\items\items_game.txt
}
FileAppend,%masterfilecontent%,%A_ScriptDir%\Plugins\VPKCreator\pak01_dir\scripts\items\items_game.txt
IfNotExist,%A_ScriptDir%\Plugins\VPKCreator\pak01_dir\scripts\npc\
{
	FileCreateDir,%A_ScriptDir%\Plugins\VPKCreator\pak01_dir\scripts\npc\
}
else ifexist,%A_ScriptDir%\Plugins\VPKCreator\pak01_dir\scripts\npc\portraits.txt
{
	FileDelete,%A_ScriptDir%\Plugins\VPKCreator\pak01_dir\scripts\npc\portraits.txt
}
FileAppend,%portstring%,%A_ScriptDir%\Plugins\VPKCreator\pak01_dir\scripts\npc\portraits.txt
gosub,externalfiles
gosub,gipatcher
GuiControl,Text,searchnofound,Shutnik Method: Creating pak01_dir.vpk
if InStr(giloc,"/dota/")>0
{
	stringgetpos,length,giloc,/dota/
}
else
{
	stringgetpos,length,giloc,\dota\
}
stringmid,modloc,giloc,1,%length%
ifexist,%A_ScriptDir%\Plugins\VPKCreator\build_vpk.bat
{
	FileDelete,%A_ScriptDir%\Plugins\VPKCreator\build_vpk.bat
}

vpkdeletefailed=0
IfNotExist,%A_ScriptDir%\Generated MOD\
{
	writer=%writer%md "%A_ScriptDir%\Generated MOD"`r`n
}
IfNotExist,%modloc%\Aldrin_Mods\
{
	writer=%writer%md "%modloc%\Aldrin_Mods"`r`n
}
else IfExist,%modloc%\Aldrin_Mods\pak01_dir.vpk
{
	FileDelete,%modloc%\Aldrin_Mods\pak01_dir.vpk
	if ErrorLevel>0 ;; if the deletion was unsuccessful, place the vpk at the generated mods folder
	{
		writer=%writer%"%A_ScriptDir%\Plugins\VPKCreator\vpk.exe" "%A_ScriptDir%\Plugins\VPKCreator\pak01_dir"`r`nmove "%A_ScriptDir%\Plugins\VPKCreator\pak01_dir.vpk" "%A_ScriptDir%\Generated MOD\"`r`ndel `%0
		vpkdeletefailed=1
		if soundon=1
		{
			SoundPlay,%A_Temp%\Sound\vpkdeletefailed.wav
		}
	}
	else ;; else move the vpk at aldrin_mods folder
	{
		writer=%writer%"%A_ScriptDir%\Plugins\VPKCreator\vpk.exe" "%A_ScriptDir%\Plugins\VPKCreator\pak01_dir"`r`nmove "%A_ScriptDir%\Plugins\VPKCreator\pak01_dir.vpk" "%modloc%\Aldrin_Mods\"`r`ndel `%0
	}
}
else
{
	writer=%writer%"%A_ScriptDir%\Plugins\VPKCreator\vpk.exe" "%A_ScriptDir%\Plugins\VPKCreator\pak01_dir"`r`nmove "%A_ScriptDir%\Plugins\VPKCreator\pak01_dir.vpk" "%modloc%\Aldrin_Mods\"`r`ndel `%0
}

ifexist,%A_ScriptDir%\Plugins\VPKCreator\build_vpk.bat
{
	FileDelete,%A_ScriptDir%\Plugins\VPKCreator\build_vpk.bat
}
FileAppend,%writer%,%A_ScriptDir%\Plugins\VPKCreator\build_vpk.bat

;param1:=extract%A_Index% "," misc%A_Index% ; second degree parameters
param1=extract%A_Index%,misc%A_Index% ; first degree parameters
param2=%commandloop%,6

batchstarttimer:=A_TickCount
loop
{
	wait=0 ;; always set this to zero so that it indicates at the ened of the loop that it needs to be breaked
	
	;;;; this section detects when the  process exists when the pid is running(buggy, it sometimes encounter that the pid of this batch file was reused by other processes, shit!!!)
	;;loop %commandloop%
	;;{
	;;	tmp:=extract%A_Index%
	;;	ifwinexist,ahk_pid %tmp%
	;;	{
	;;		wait=1
	;;	}
	;;}
	;;loop,6
	;;{
	;;	tmp:=misc%A_Index%
	;;	ifwinexist,ahk_pid %tmp%
	;;	{
	;;		wait=1
	;;	}
	;;}
	;;;;
	;;
	;;if wait=0 ; this section detects when the batch files was not launched
	;;{
	;;	loop %commandloop%
	;;	{
	;;		ifexist,%A_ScriptDir%\Plugins\VPKCreator\extract%A_Index%.bat
	;;		{
	;;			run,%A_ScriptDir%\Plugins\VPKCreator\extract%A_Index%.bat,,Hide UseErrorLevel,extract%A_Index%
	;;			wait=1
	;;		}
	;;	}
	;;	loop,6
	;;	{
	;;		ifexist,%A_ScriptDir%\Plugins\VPKCreator\misc%A_Index%.bat
	;;		{
	;;			run,%A_ScriptDir%\Plugins\VPKCreator\misc%A_Index%.bat,,Hide UseErrorLevel,misc%A_Index%
	;;			wait=1
	;;		}
	;;	}
	;;	if wait=0
	;;	{
	;;		Break
	;;	}
	;;}
	
	if (A_TickCount-batchstarttimer)/1000=120 ;; I set this detector to 2 minutes, this detects when the execution of file is taking forever... Rerun all of the batch files that exists!!!
	{
			batchstarttimer:=A_TickCount ;; reset the timer into the present time so that the rechecking every 2 minutes will remerce
			loop %commandloop%
			{
				ifexist,%A_ScriptDir%\Plugins\VPKCreator\extract%A_Index%.bat
				{
					run,%A_ScriptDir%\Plugins\VPKCreator\extract%A_Index%.bat,,Hide UseErrorLevel,extract%A_Index%
					wait=1
				}
			}
			loop,6
			{
				ifexist,%A_ScriptDir%\Plugins\VPKCreator\misc%A_Index%.bat
				{
					run,%A_ScriptDir%\Plugins\VPKCreator\misc%A_Index%.bat,,Hide UseErrorLevel,misc%A_Index%
					wait=1
				}
			}
			if wait=1
			{
				continue ;; skip all next iterations and proceed on a new index of the loop
			}
	}
	
	;;this system detects when the batch file process is strill running and also if the batch file still exists on its directory
	loop,parse,param1,`,
	{
		savestring:=%A_LoopField% ;; extract the second degree information of the variable ( x := %n% = % %n%)
		tmpint:=A_Index ;; extract the first degree of information of a variable (x := n = %n%)
		loop,parse,param2,`,
		{
			if tmpint=%A_Index% ;; equality of indexes of two parameters
			{
				loop %A_LoopField% ;; loopfiled of second param which is commandloop, 6, ect
				{
					ifexist,%A_ScriptDir%\Plugins\VPKCreator\%savestring%.bat
					{
						if !WinExist("ahk_pid " savestring) ;not win exist
						{
							run,%A_ScriptDir%\Plugins\VPKCreator\%savestring%.bat,,Hide UseErrorLevel,%savestring% ;; rerun the batch file with unique pid
						}
						wait=1 ;; automatically wait when bat file was found
					}
				}
			}
		}
	}
	;;
	
	if wait=0 ;; if there are no more batch files and processes detected, end the loop
	{
		Break
	}
}
GuiControl,Text,searchnofound,Shutnik Method: Executing Batch File... It will take more time if there are many cosmetic items injected!
loop
{
	runwait,"%A_ScriptDir%\Plugins\VPKCreator\build_vpk.bat",,Hide UseErrorLevel
	if (ErrorLevel<>ERROR) and (A_LastError=0) ;;  if the run is successful
		break ;; terminate the loop
	;; if the there was an error, rerun the batch file
}

if vpkdeletefailed=1 ;; if unsuccessful vpk deletion lately, try the following
{
	FileDelete,%modloc%\Aldrin_Mods\pak01_dir.vpk
	if ErrorLevel=0 ;; if the deletion was successful this time, place the vpk at aldrin_mods folder
	{
		FileMove,%A_ScriptDir%\Generated MOD\pak01_dir.vpk,%modloc%\Aldrin_Mods\,1
	}
	else ;; if the condition fails, the vpk file will be found at the generated mods folder
	{
		Run, %A_ScriptDir%\Generated MOD\
		msgbox,16,WARNING!,Task:`nFile Deletion`n`nFilePath:`n%modloc%\Aldrin_Mods\pak01_dir.vpk`n`nStatus:`nFAILED`n`nResult:`n-pak01_dir.vpk was moved at"%A_ScriptDir%\Generated MOD\" Folder.`n`nPossible Inconvenience:`n- DOTA2 might be Running`n- pak01_dir.vpk is currently in used(opened) by other applications.`n`nFix:`n1) Manually delete the pak01_dir.vpk found at the "FilePath".`n2) Move the generated pak01_dir.vpk found at "%A_ScriptDir%\Generated MOD\" Folder directly to "FilePath".
	}
	
}

GuiControl,+cDefault,searchnofound
GuiControl,Text,searchnofound,%defaultshoutout%
return

miscstyle:
if A_GuiEvent = RightClick
{
	Gui, MainGUI:Default
	if A_DefaultListView<>%A_GuiControl%
	{
		Gui, MainGUI:ListView,%A_GuiControl%
	}
	LV_GetText(stylescount,A_EventInfo,4)
	LV_GetText(countcheck,A_EventInfo,5)
	if stylescount>%countcheck%
	{
		countcheck+=1
	}
	else
	{
		countcheck=0
	}
	LV_Modify(A_EventInfo,"Col5",countcheck)
}
if InStr(ErrorLevel, "C", true)
{
	if A_DefaultListView<>%A_GuiControl%
	{
		Gui, MainGUI:ListView, %A_GuiControl%
	}
	Loop % LV_GetCount()
	{
		if A_EventInfo<>%A_Index%
		{
			LV_Modify(A_Index,"-Check")
		}
	}
}
return

execmisc:
extrafilter=`r`n%A_Tab%%A_Tab%%A_Tab%"baseitem"%A_Tab%%A_Tab%"1"`r`n
replacefrom=`r`n%A_Tab%%A_Tab%%A_Tab%"name"
replaceto=`r`n%A_Tab%%A_Tab%%A_Tab%"baseitem"%A_Tab%%A_Tab%"1"`r`n%A_Tab%%A_Tab%%A_Tab%"name"
replaceto4=`r`n%A_Tab%%A_Tab%%A_Tab%"baseitem"%A_Tab%%A_Tab%"1"`r`n%A_Tab%%A_Tab%%A_Tab%"item_slot"%A_Tab%%A_Tab%"courier"`r`n%A_Tab%%A_Tab%%A_Tab%"name"
replaceto5=`r`n%A_Tab%%A_Tab%%A_Tab%"baseitem"%A_Tab%%A_Tab%"1"`r`n%A_Tab%%A_Tab%%A_Tab%"item_slot"%A_Tab%%A_Tab%"ward"`r`n%A_Tab%%A_Tab%%A_Tab%"name"
sfinder=`r`n%A_Tab%%A_Tab%}`r`n%A_Tab%%A_Tab%" ;"
param=terrain,hud_skin,loading_screen,courier,ward,music,cursor_pack,radiantcreeps,direcreeps
param2=terrainchoice,hudchoice,loadingscreenchoice,courierchoice,wardchoice,musicchoice,cursorchoice,radcreepchoice,direcreepchoice
IPS:=A_TickCount
loop,parse,param2,`,
{
	if A_DefaultListView<>%A_LoopField%
	{
		Gui, MainGUI:ListView,%A_LoopField%
	}
	if LV_GetNext(,"Checked")<1
	{
		continue
	}
	intsaver=%A_Index%
	loop,parse,param,`,
	{
		if intsaver=%A_Index%
		{
			subject=%A_LoopField%
			GuiControl,Text,searchnofound,Injecting %A_LoopField%
			Loop
			{
				firstloop=%A_Index%
				htarget=`r`n%A_Tab%%A_Tab%%A_Tab%"prefab"%A_Tab%%A_Tab%"%subject%"`r`n
				StringGetPos, ipos, masterfilecontent,%htarget%,L%firstloop%
				if ipos<0
				{
					Break
				}
				StringLen,filelength,masterfilecontent
				rightpos:=filelength-ipos
				StringGetPos, ipos1, masterfilecontent,%sfinder%,,%ipos%
				StringGetPos, ipos2, masterfilecontent,%sfinder%,R1,%rightpos%
				startpos:=ipos2+8
				ipos3:=ipos1-ipos2
				StringMid,misccontent,masterfilecontent,%startpos%,%ipos3%
				if InStr(misccontent,extrafilter)>0
				{
					filecontent=%misccontent%
					if (intsaver=4) or (intsaver=5) ;;; information generation for extraction about cour,ward
					{
						itemname:=visualsdetector(filecontent) ; detects the Visual Section of the content
						StringLen,tmplength,itemname
						if intsaver=4
						{
							namecount=4
							impint=0 ; offset for the extraction count for cour, mean from 1 to 4
						}
						else if intsaver=5
						{
							namecount=2
							impint=4 ; offset for the extraction count for ward, mean from 5 to 6
						}
						loop,%namecount%
						{
							impint1:=impint+A_Index
							defaultmisc%impint1%:=defaultmiscloc%impint1%:=extractmisc%impint1%:=extractfile%impint1%:=""
							StringGetPos, ipos1, itemname,.vmdl,L%A_Index%
							StringGetPos, ipos2, itemname,",,%ipos1%
							rightpos:=tmplength-ipos1
							StringGetPos, ipos3, itemname,",R1,%rightpos%
							tmp:=ipos2-ipos3-1
							startpos:=ipos3+2
							StringMid,defaultfile,itemname,%startpos%,%tmp%
							defaultfile=%defaultfile%_c
							StringReplace,defaultfile,defaultfile,/,\,1
							StringGetPos, pos, itemname,`r`n%A_Tab%%A_Tab%%A_Tab%%A_Tab%},,%ipos1%
							StringGetPos, pos1, itemname,`r`n%A_Tab%%A_Tab%%A_Tab%%A_Tab%{,R1,%rightpos%
							tmp:=pos-pos1
							startpos:=pos1+1
							StringMid,modifierstring,itemname,%startpos%,%tmp%
							StringLen,varlength,defaultfile
							StringGetPos, ipos1, defaultfile,\,R1
							StringTrimLeft,defaultname,defaultfile,% ipos1+1
							StringTrimRight,defaultloc,defaultfile,% varlength-ipos1
							if intsaver=4
							{
								miscparam="type"%A_Tab%%A_Tab%"courier","type"%A_Tab%%A_Tab%"courier","type"%A_Tab%%A_Tab%"courier_flying","type"%A_Tab%%A_Tab%"courier_flying"
								miscparam1="asset"%A_Tab%%A_Tab%"radiant","asset"%A_Tab%%A_Tab%"dire","asset"%A_Tab%%A_Tab%"radiant","asset"%A_Tab%%A_Tab%"dire"
								loop,parse,miscparam,`,
								{
									saveparam=%A_LoopField%
									saveindex=%A_Index%
									loop,parse,miscparam1,`,
									{
										if saveindex=%A_Index%
										{
											if (InStr(modifierstring,saveparam)>0) and (InStr(modifierstring,A_LoopField)>0)
											{
												defaultmisc%saveindex%=%defaultname%
												defaultmiscloc%saveindex%=%defaultloc%
											}
										}
									}
								}
							}
							if intsaver=5
							{
								miscparam="asset"%A_Tab%%A_Tab%"npc_dota_observer_wards","asset"%A_Tab%%A_Tab%"npc_dota_sentry_wards"
								loop,parse,miscparam,`,
								{
									saveindex:=A_Index+4
									if InStr(modifierstring,A_LoopField)>0
									{
										defaultmisc%saveindex%=%defaultname%
										defaultmiscloc%saveindex%=%defaultloc%
									}
								}
							}
						}
					}
					tmpbar:=iddetector(filecontent) ;filecontent := extracted content from items_game.txt
					defid=%tmpbar%
					LV_GetText(tmpstring,LV_GetNext(,"Checked"),3)
					tmpfind=%subject%
					filecontent:=miscdetector("prefab",tmpfind,tmpstring) ;filecontent:=miscdetector("prefab",tmpfind,tmpstring,filestring) ; detects the contents of a miscellaneous item... In expression "prefab" means item_slot
					StringReplace,filecontent,filecontent,%tmpstring%"`r`n%A_Tab%%A_Tab%{,%defid%"`r`n%A_Tab%%A_Tab%{
					if (intsaver=4) or (intsaver=5)
					{
						itemname:=visualsdetector(filecontent) ; detects the Visual Section of the content
						tmp:=StrReplace(itemname,.vmdl",.vmdl",extractcount)
						loop,%extractcount%
						{
							StringGetPos, ipos1, itemname,.vmdl,L%A_Index%
							StringGetPos, ipos2, itemname,",,%ipos1%
							rightpos:=tmplength-ipos1
							StringGetPos, ipos3, itemname,",R1,%rightpos%
							tmp:=ipos2-ipos3-1
							startpos:=ipos3+2
							StringMid,defaultfile,itemname,%startpos%,%tmp%
							defaultfile=%defaultfile%_c
							StringReplace,defaultfile,defaultfile,/,\,1
							StringGetPos, pos, itemname,`r`n%A_Tab%%A_Tab%%A_Tab%%A_Tab%},,%ipos1%
							StringGetPos, pos1, itemname,`r`n%A_Tab%%A_Tab%%A_Tab%%A_Tab%{,R1,%rightpos%
							tmp:=pos-pos1
							startpos:=pos1+1
							StringMid,modifierstring,itemname,%startpos%,%tmp%
							StringLen,varlength,defaultfile
							StringGetPos, ipos1, defaultfile,\,R1
							StringTrimLeft,extractname,defaultfile,% ipos1+1
							LV_GetText(numcheck,LV_GetNext(,"Checked"),4)
							LV_GetText(stylechecker,LV_GetNext(,"Checked"),5)
							tmp="style"%A_Tab%%A_Tab%"%stylechecker%"
							save1="style"
							if ((intsaver=4) and (numcheck>0) and (InStr(modifierstring,tmp)>0)) or ((intsaver=5) and (numcheck>0) and (InStr(modifierstring,tmp)>0)) or (numcheck=0) or ((numcheck>0) and (InStr(modifierstring,save1)<1))
							{
								if intsaver=4
								{
									miscparam="type"%A_Tab%%A_Tab%"courier","type"%A_Tab%%A_Tab%"courier","type"%A_Tab%%A_Tab%"courier_flying","type"%A_Tab%%A_Tab%"courier_flying"
									miscparam1="asset"%A_Tab%%A_Tab%"radiant","asset"%A_Tab%%A_Tab%"dire","asset"%A_Tab%%A_Tab%"radiant","asset"%A_Tab%%A_Tab%"dire"
									loop,parse,miscparam,`,
									{
										saveparam=%A_LoopField%
										saveindex=%A_Index%
										loop,parse,miscparam1,`,
										{
											if saveindex=%A_Index%
											{
												if (InStr(modifierstring,saveparam)>0) and (InStr(modifierstring,A_LoopField)>0)
												{
													extractmisc%saveindex%=%extractname%
													extractfile%saveindex%=%defaultfile%
												}
											}
										}
									}
								}
								if intsaver=5
								{
									miscparam="asset"%A_Tab%%A_Tab%"npc_dota_observer_wards","asset"%A_Tab%%A_Tab%"npc_dota_sentry_wards"
									loop,parse,miscparam,`,
									{
										saveindex:=A_Index+4
										if InStr(modifierstring,A_LoopField)>0
										{
											extractmisc%saveindex%=%extractname%
											extractfile%saveindex%=%defaultfile%
										}
									}
								}
							}
						}
					}
					if (intsaver=4) or (intsaver=5) or (intsaver=2) or (intsaver=8) or (intsaver=9)
					{
						if (intsaver=2) or (intsaver=8) or (intsaver=9)
						{
							;produces animation bug on creeps thats why disabled
							;if (intsaver=8) or (intsaver=9)
							;{
							;	LV_GetText(numcheck,A_Index,4)
							;	LV_GetText(stylechecker,A_Index,5)
							;	contentport=%filecontent%
							;	gosub,extractmodel
							;}
							StringReplace,filecontent,filecontent,%replacefrom%,%replaceto%
						}
						else if (intsaver=4) or (intsaver=5)
						{
							StringReplace,filecontent,filecontent,%replacefrom%,% replaceto%intsaver%
							portparam=game,game,game_flying,game_flying,game
							portparam1=donkey,donkey_dire,donkey_wings,donkey_dire_wings,default_ward
							loop,parse,portparam1,`,
							{
								porthero=%A_LoopField%
								portint=%A_Index%
								loop,parse,portparam,`,
								{
									if portint=%A_Index%
									{
										portfind=`r`n%A_Tab%%A_Tab%%A_Tab%%A_Tab%"%A_LoopField%"`r`n%A_Tab%%A_Tab%%A_Tab%%A_Tab%{
										if InStr(replaceto,portfind)>0
										{
											contentport=%replaceto%
											porttmp=models/props_gameplay/%porthero%.vmdl
											gosub,execportrait
										}
									}
								}
							}
						}
						LV_GetText(stylechecker,LV_GetNext(,"Checked"),5)
						if stylechecker>0
						{
							filecontent:=stylechanger(stylechecker,filecontent) ;stylechanger will change the style of all particle effects and even the model
						}
						else
						{
							StringReplace,filecontent,filecontent,`r`n%A_Tab%%A_Tab%%A_Tab%%A_Tab%%A_Tab%"style"%A_Tab%%A_Tab%"0",,1
						}
					}
					else
					{
						StringReplace,filecontent,filecontent,%replacefrom%,%replaceto%
					}
					StringReplace,masterfilecontent,masterfilecontent,%misccontent%,%filecontent%,1
					; measures the number of items injected per second
					Gui,MainGUI:Show, NoActivate,% floor(1000/(A_TickCount-IPS)) " Items per Second"
					IPS:=A_TickCount
					;
					Break
				}
				Else
				{
					misccontent=
				}
				if ErrorLevel=1
				{
					Break
				}
			}
		}
	}
}
command=
loop,6
{
	if (defaultmiscloc%A_Index%<>"") and (extractfile%A_Index%<>"")
	{
		tmp:=defaultmiscloc%A_Index%
		tmp1:=extractfile%A_Index%
		tmp2:=extractmisc%A_Index%
		tmp3:=defaultmisc%A_Index%
		repmocount:=repmocount+1
		IniWrite,%tmp%,%A_ScriptDir%\Plugins\ReportLog.aldrin_report,Present Models,ModelLocationPath_%repmocount%
		IniWrite,%tmp3%,%A_ScriptDir%\Plugins\ReportLog.aldrin_report,Present Models,ModelDefaultName_%repmocount%
		IniWrite,%tmp2%,%A_ScriptDir%\Plugins\ReportLog.aldrin_report,Present Models,ModelRealName_%repmocount%
		if (A_Index<>1) and (A_Index<>3) and (A_Index<>5)
		{
			command=%command%md "%A_ScriptDir%\Plugins\VPKCreator\pak01_dir\%tmp%"`r`n"%variablehllib%" -p "%dota2dir%\game\dota\pak01_dir.vpk" -d "%A_ScriptDir%\Plugins\VPKCreator\pak01_dir\%tmp%" -e "root\%tmp1%"`r`nrename "%A_ScriptDir%\Plugins\VPKCreator\pak01_dir\%tmp%\%tmp2%" "%tmp3%"`r`ndel `%0
			ifexist,%A_ScriptDir%\Plugins\VPKCreator\misc%A_Index%.bat
			{
				FileDelete,%A_ScriptDir%\Plugins\VPKCreator\misc%A_Index%.bat
			}
			fileappend,%command%,%A_ScriptDir%\Plugins\VPKCreator\misc%A_Index%.bat
			if (lowprocessor=0)
			{
				loop
				{
					run,"%A_ScriptDir%\Plugins\VPKCreator\misc%A_Index%.bat",,Hide UseErrorLevel,misc%A_Index%
					if (ErrorLevel<>ERROR) and (A_LastError=0) ;;  if the run is successful
						break ;; terminate the loop
					;; if the there was an error, rerun the batch file
				}
				
				;run,"%A_ScriptDir%\Plugins\VPKCreator\misc%A_Index%.bat",,Hide UseErrorLevel,misc%A_Index%
			}
			else
			{
				loop
				{
					runwait,"%A_ScriptDir%\Plugins\VPKCreator\misc%A_Index%.bat",,Hide UseErrorLevel,misc%A_Index%
					if (ErrorLevel<>ERROR) and (A_LastError=0) ;;  if the run is successful
						break ;; terminate the loop
					;; if the there was an error, rerun the batch file
				}
				
				;runwait,"%A_ScriptDir%\Plugins\VPKCreator\misc%A_Index%.bat",,Hide UseErrorLevel,misc%A_Index%
			}
			command=
		}
		else
		{
			command=md "%A_ScriptDir%\Plugins\VPKCreator\pak01_dir\%tmp%"`r`n"%variablehllib%" -p "%dota2dir%\game\dota\pak01_dir.vpk" -d "%A_ScriptDir%\Plugins\VPKCreator\pak01_dir\%tmp%" -e "root\%tmp1%"`r`nrename "%A_ScriptDir%\Plugins\VPKCreator\pak01_dir\%tmp%\%tmp2%" "%tmp3%"`r`n ;"
		}
	}
}
if A_DefaultListView<>announcerview
{
	Gui, MainGUI:ListView,announcerview
}
loop % LV_GetCount()
{
	if (A_Index=LV_GetNext(A_Index-1,"Checked"))
	{
		LV_GetText(matcher,LV_GetNext(A_Index-1,"Checked"),2)
		LV_GetText(tmpstring,LV_GetNext(A_Index-1,"Checked"),4)
		GuiControl,Text,searchnofound,Injecting %matcher%
		htarget=`r`n%A_Tab%%A_Tab%%A_Tab%"item_slot"%A_Tab%%A_Tab%"%matcher%"`r`n
		Loop
		{
			StringGetPos, ipos, masterfilecontent,%htarget%,L%A_Index%
			StringLen,filelength,masterfilecontent
			rightpos:=filelength-ipos
			StringGetPos, ipos1, masterfilecontent,%sfinder%,,%ipos%
			StringGetPos, ipos2, masterfilecontent,%sfinder%,R1,%rightpos%
			startpos:=ipos2+8
			ipos3:=ipos1-ipos2
			StringMid,misccontent,masterfilecontent,%startpos%,%ipos3%
			if InStr(misccontent,extrafilter)>0
			{
				filecontent=%misccontent%
				tmpbar:=iddetector(filecontent) ;filecontent := extracted content from items_game.txt
				defid=%tmpbar%
				tmpfind=%matcher%
				filecontent:=miscdetector("item_slot",tmpfind,tmpstring) ;filecontent:=miscdetector("item_slot",tmpfind,tmpstring,filestring) ; detects the contents of a miscellaneous item... In expression "item_slot" means item_slot
				StringReplace,filecontent,filecontent,%tmpstring%"`r`n%A_Tab%%A_Tab%{,%defid%"`r`n%A_Tab%%A_Tab%{
				StringReplace,filecontent,filecontent,%replacefrom%,%replaceto%
				StringReplace,masterfilecontent,masterfilecontent,%misccontent%,%filecontent%,1
				; measures the number of items injected per second
				Gui,MainGUI:Show, NoActivate,% floor(1000/(A_TickCount-IPS)) " Items per Second"
				IPS:=A_TickCount
				;
				Break
			}
			Else
			{
				misccontent=
			}
			if ErrorLevel=1
			{
				Break
			}
		}
		
	}
}
if A_DefaultListView<>tauntview
{
	Gui, MainGUI:ListView,tauntview
}
GuiControl,Text,searchnofound,Injecting Taunt/s
if LV_GetNext(,"Checked")>0
{
	htarget=`r`n%A_Tab%%A_Tab%%A_Tab%"item_slot"%A_Tab%%A_Tab%"taunt"`r`n
	filter=`r`n%A_Tab%%A_Tab%%A_Tab%"used_by_heroes"`r`n%A_Tab%%A_Tab%%A_Tab%{`r`n%A_Tab%%A_Tab%%A_Tab%%A_Tab%"all"%A_Tab%%A_Tab%"1"`r`n%A_Tab%%A_Tab%%A_Tab%}
	Loop
	{
		StringGetPos, ipos, masterfilecontent,%htarget%,L%A_Index%
		StringLen,filelength,masterfilecontent
		rightpos:=filelength-ipos
		StringGetPos, ipos1, masterfilecontent,%sfinder%,,%ipos%
		StringGetPos, ipos2, masterfilecontent,%sfinder%,R1,%rightpos%
		startpos:=ipos2+8
		ipos3:=ipos1-ipos2
		StringMid,misccontent,masterfilecontent,%startpos%,%ipos3%
		if InStr(misccontent,filter)>0
		{
			StringReplace,tmp,misccontent,`r`n%A_Tab%%A_Tab%%A_Tab%"prefab"%A_Tab%%A_Tab%"default_item"`r`n,`r`n%A_Tab%%A_Tab%%A_Tab%"prefab"%A_Tab%%A_Tab%"wearable"`r`n,1
			StringReplace,masterfilecontent,masterfilecontent,%misccontent%,%tmp%,1
			; measures the number of items injected per second
			Gui,MainGUI:Show, NoActivate,% floor(1000/(A_TickCount-IPS)) " Items per Second"
			IPS:=A_TickCount
			;
			Break
		}
		Else
		{
			misccontent=
		}
		if ErrorLevel=1
		{
			Break
		}
	}
}
loop % LV_GetCount()
{
	if (A_Index=LV_GetNext(A_Index-1,"Checked"))
	{
		LV_GetText(tmpstring,LV_GetNext(A_Index-1,"Checked"),3)
		tmpfind=taunt
		filecontent:=miscdetector("prefab",tmpfind,tmpstring) ;filecontent:=miscdetector("prefab",tmpfind,tmpstring,filestring) ; detects the contents of a miscellaneous item... In expression "prefab" means item_slot
		StringReplace,tmp,filecontent,%replacefrom%,%replaceto%
		StringReplace,tmp,tmp,`r`n%A_Tab%%A_Tab%%A_Tab%"prefab"%A_Tab%%A_Tab%"taunt"`r`n,`r`n%A_Tab%%A_Tab%%A_Tab%"baseitem"%A_Tab%%A_Tab%"1"`r`n%A_Tab%%A_Tab%%A_Tab%"prefab"%A_Tab%%A_Tab%"taunt"`r`n
		StringReplace,masterfilecontent,masterfilecontent,%filecontent%,%tmp%,1
		; measures the number of items injected per second
		Gui,MainGUI:Show, NoActivate,% floor(1000/(A_TickCount-IPS)) " Items per Second"
		IPS:=A_TickCount
		;
	}
}
if A_DefaultListView<>weatherchoice
{
	Gui, MainGUI:ListView,weatherchoice
}
GuiControl,Text,searchnofound,Injecting Weather Effect
if LV_GetNext(,"Checked")>0
{
	filter=`r`n%A_Tab%%A_Tab%%A_Tab%"prefab"%A_Tab%%A_Tab%"misc"`r`n
	htarget=`r`n%A_Tab%%A_Tab%%A_Tab%"prefab"%A_Tab%%A_Tab%"weather"`r`n
	Loop
	{
		StringGetPos, ipos, masterfilecontent,%htarget%,L%A_Index%
		StringLen,filelength,masterfilecontent
		rightpos:=filelength-ipos
		StringGetPos, ipos1, masterfilecontent,%sfinder%,,%ipos%
		StringGetPos, ipos2, masterfilecontent,%sfinder%,R1,%rightpos%
		startpos:=ipos2+8
		ipos3:=ipos1-ipos2
		StringMid,misccontent,masterfilecontent,%startpos%,%ipos3%
		if InStr(misccontent,extrafilter)>0
		{
			filecontent=%misccontent%
			tmpbar:=iddetector(filecontent) ;filecontent := extracted content from items_game.txt
			defid=%tmpbar%
			LV_GetText(tmpstring,LV_GetNext(,"Checked"),3)
			tmpfind=misc
			filecontent:=miscdetector("prefab",tmpfind,tmpstring) ;filecontent:=miscdetector("prefab",tmpfind,tmpstring,filestring) ; detects the contents of a miscellaneous item... In expression "prefab" means item_slot
			if InStr(filecontent,filter)>0
			{
				StringReplace,filecontent,filecontent,%tmpstring%"`r`n%A_Tab%%A_Tab%{,%defid%"`r`n%A_Tab%%A_Tab%{
				StringReplace,filecontent,filecontent,%replacefrom%,%replaceto%
				StringReplace,masterfilecontent,masterfilecontent,%misccontent%,%filecontent%,1
				; measures the number of items injected per second
				Gui,MainGUI:Show, NoActivate,% floor(1000/(A_TickCount-IPS)) " Items per Second"
				IPS:=A_TickCount
				;
				Break
			}
		}
		Else
		{
			misccontent=
		}
		if ErrorLevel=1
		{
			Break
		}
	}
}
if A_DefaultListView<>multikillchoice
{
	Gui, MainGUI:ListView,multikillchoice
}
GuiControl,Text,searchnofound,Injecting MultiKill-Banner
if LV_GetNext(,"Checked")>0
{
			LV_GetText(tmpstring,LV_GetNext(,"Checked"),3)
			tmpfind=misc
			filecontent:=miscdetector("prefab",tmpfind,tmpstring) ;filecontent:=miscdetector("prefab",tmpfind,tmpstring,filestring) ; detects the contents of a miscellaneous item... In expression "prefab" means item_slot
			StringReplace,misccontent,filecontent,`r`n%A_Tab%%A_Tab%%A_Tab%"item_slot"%A_Tab%%A_Tab%"multikill_banner"`r`n,`r`n%A_Tab%%A_Tab%%A_Tab%"baseitem"%A_Tab%%A_Tab%"1"`r`n%A_Tab%%A_Tab%%A_Tab%"item_slot"%A_Tab%%A_Tab%"multikill_banner"`r`n
			StringReplace,masterfilecontent,masterfilecontent,%filecontent%,%misccontent%,1
			; measures the number of items injected per second
			Gui,MainGUI:Show, NoActivate,% floor(1000/(A_TickCount-IPS)) " Items per Second"
			IPS:=A_TickCount
			;
}
if A_DefaultListView<>emblemchoice
{
	Gui, MainGUI:ListView,emblemchoice
}
GuiControl,Text,searchnofound,Injecting emblem
if LV_GetNext(,"Checked")>0
{
			LV_GetText(tmpstring,LV_GetNext(,"Checked"),3)
			tmpfind=emblem
			filecontent:=miscdetector("prefab",tmpfind,tmpstring) ;filecontent:=miscdetector("prefab",tmpfind,tmpstring,filestring) ; detects the contents of a miscellaneous item... In expression "prefab" means item_slot
			StringReplace,misccontent,filecontent,`r`n%A_Tab%%A_Tab%%A_Tab%"prefab"%A_Tab%%A_Tab%"emblem",`r`n%A_Tab%%A_Tab%%A_Tab%"baseitem"%A_Tab%%A_Tab%"1"`r`n%A_Tab%%A_Tab%%A_Tab%"prefab"%A_Tab%%A_Tab%"emblem"
			StringReplace,masterfilecontent,masterfilecontent,%filecontent%,%misccontent%,1
			; measures the number of items injected per second
			Gui,MainGUI:Show, NoActivate,% floor(1000/(A_TickCount-IPS)) " Items per Second"
			IPS:=A_TickCount
			;
}
if peton=1
{
	GuiControl,Text,searchnofound,Activating Almond the Frondillo`, current status: Searching for default_item pet for heroes
	filter=`r`n%A_Tab%%A_Tab%%A_Tab%"item_slot"%A_Tab%%A_Tab%"summon"`r`n
	filter1=npc_dota_hero_
	htarget=`r`n%A_Tab%%A_Tab%%A_Tab%"prefab"%A_Tab%%A_Tab%"default_item"`r`n
	Loop
	{
		StringGetPos, ipos, masterfilecontent,%htarget%,L%A_Index%
		StringLen,filelength,masterfilecontent
		rightpos:=filelength-ipos
		StringGetPos, ipos1, masterfilecontent,%sfinder%,,%ipos%
		StringGetPos, ipos2, masterfilecontent,%sfinder%,R1,%rightpos%
		startpos:=ipos2+8
		ipos3:=ipos1-ipos2
		StringMid,misccontent,masterfilecontent,%startpos%,%ipos3%
		if InStr(misccontent,filter)>0
		{
			filecontent=%misccontent%
			itemname:=miscusersdetector(filecontent) ; detects the user of the pet from multiple instances
			tmp:= StrReplace(itemname,filter1, filter1, existencecount)
			if existencecount>1
			{
				GuiControl,Text,searchnofound,Activating Almond the Frondillo`, current status: Searching for Almond the Frondillo item
				tmpbar:=iddetector(filecontent) ;filecontent := extracted content from items_game.txt
				defid=%tmpbar%
				1htarget=`r`n%A_Tab%%A_Tab%%A_Tab%"prefab"%A_Tab%%A_Tab%"wearable"`r`n
				Loop
				{
					StringGetPos, ipos, masterfilecontent,%filter%,L%A_Index%
					StringLen,filelength,masterfilecontent
					rightpos:=filelength-ipos
					StringGetPos, ipos1, masterfilecontent,%sfinder%,,%ipos%
					StringGetPos, ipos2, masterfilecontent,%sfinder%,R1,%rightpos%
					startpos:=ipos2+8
					ipos3:=ipos1-ipos2
					StringMid,filecontent,masterfilecontent,%startpos%,%ipos3%
					if InStr(filecontent,1htarget)>0
					{
						itemname:=miscusersdetector(filecontent) ; detects the user of the pet from multiple instances
						tmp:= StrReplace(itemname,filter1, filter1, existencecount)
						if existencecount>1
						{
							GuiControl,Text,searchnofound,Activating Almond the Frondillo`, current status: Finalyzing
							tmpbar:=iddetector(filecontent) ;filecontent := extracted content from items_game.txt
							tmp=%tmpbar%
							StringReplace,filecontent,filecontent,%tmp%"`r`n%A_Tab%%A_Tab%{,%defid%"`r`n%A_Tab%%A_Tab%{
							StringReplace,filecontent,filecontent,%1htarget%,%htarget%,1
							if petstyle>0
							{
								stylechecker=%petstyle%
								if stylechecker>0
								{
									filecontent:=stylechanger(stylechecker,filecontent) ;stylechanger will change the style of all particle effects and even the model
								}
								else
								{
									StringReplace,filecontent,filecontent,`r`n%A_Tab%%A_Tab%%A_Tab%%A_Tab%%A_Tab%"style"%A_Tab%%A_Tab%"0",,1
								}
							}
							StringReplace,masterfilecontent,masterfilecontent,%misccontent%,%filecontent%,1
							; measures the number of items injected per second
							Gui,MainGUI:Show, NoActivate,% floor(1000/(A_TickCount-IPS)) " Items per Second"
							IPS:=A_TickCount
							;
							Break
						}
						else
						{
							filecontent=
						}
					}
					else
					{
						filecontent=
					}
					if ErrorLevel=1
					{
						Break
					}
				}
				Break
			}
			else
			{
				misccontent=
			}
		}
		Else
		{
			misccontent=
		}
		if ErrorLevel=1
		{
			Break
		}
	}
}
return

/*
required variables
contentport - - - for the portraits
filecontent - - - for the visualsdetector,ect
numcheck
stylechecker
*/
extractmodel:
fileread,npchero,%dota2dir%\game\dota\scripts\npc\npc_heroes.txt
fileread,npcunit,%dota2dir%\game\dota\scripts\npc\npc_units.txt
itemname:=visualsdetector(filecontent) ; detects the Visual Section of the content
StringLen,modeltmplength,itemname
modelcount:=rptpermit:=0
tmp:=StrReplace(itemname,.vmdl",.vmdl",modelcount)
loop,%modelcount%
{
	StringGetPos, ipos1, itemname,.vmdl,L%A_Index%
	StringGetPos, ipos2, itemname,",,%ipos1% ;"
	rightpos:=modeltmplength-ipos1
	StringGetPos, ipos3, itemname,`r`n,R1,%rightpos%
	StringMid,modifierconfirm,itemname,% ipos3+2,% ipos2-ipos3-1
	tmp="asset"
	if InStr(modifierconfirm,tmp)>0
	{
		continue
	}
	StringGetPos, ipos3, itemname,",R1,%rightpos% ;"
	StringMid,modelextractfile,itemname,% ipos3+2,% ipos2-ipos3-1
	portfind=`r`n%A_Tab%%A_Tab%%A_Tab%%A_Tab%"game"`r`n%A_Tab%%A_Tab%%A_Tab%%A_Tab%{
	if InStr(contentport,portfind)>0
	{
		porttmp=%modelextractfile%
		gosub,execportrait
	}
	modelextractfile=%modelextractfile%_c
	StringReplace,modelextractfile,modelextractfile,/,\,1
	StringGetPos, newpos, modelextractfile,\,R1
	StringTrimLeft,modelextractname,modelextractfile,% newpos+1
	StringGetPos, pos, itemname,`r`n%A_Tab%%A_Tab%%A_Tab%%A_Tab%},,%ipos1%
	StringGetPos, pos1, itemname,`r`n%A_Tab%%A_Tab%%A_Tab%%A_Tab%{,R1,%rightpos%
	StringMid,modifierstring,itemname,% pos1+1,% pos-pos1
	StringGetPos, newpos, modifierstring,"asset"%A_Tab%%A_Tab%"
	StringGetPos, newpos1, modifierstring,",L3,newpos
	StringGetPos, newpos, modifierstring,",L2,newpos1 ;"
	StringMid,check,modifierstring,% newpos1+2, % newpos-newpos1-1
	IfInString,check,npc_dota_hero
	{
		readdir=%npchero%
	}
	else IfInString,check,dota_
	{
		readdir=%npcunit%
	}
	else
	{
		IfInString,check,.vmdl
		{
			subjectcontent=%check%_c
			StringLen,modelvarlength,subjectcontent
			StringReplace,subjectcontent,subjectcontent,/,\,1
			StringGetPos, newpos, subjectcontent,\,R1
			StringTrimLeft,modeldefaultname,subjectcontent,% newpos+1
			StringTrimRight,modeldefaultloc,subjectcontent,% modelvarlength-newpos
			if (modeldefaultloc<>"") and (modelextractfile<>"")
			{
				tmp="item_rarity"%A_Tab%%A_Tab%"arcana"
				if (InStr(filecontent,tmp)>0) and (FileExist("%A_ScriptDir%\Plugins\VPKCreator\pak01_dir\%modeldefaultloc%\%modeldefaultname%"))
				{
					FileDelete,%A_ScriptDir%\Plugins\VPKCreator\pak01_dir\%modeldefaultloc%\%modeldefaultname%
				}
				IfNotExist,%A_ScriptDir%\Plugins\VPKCreator\pak01_dir\%modeldefaultloc%\%modeldefaultname%
				{
					commandloop+=1
					repmocount+=1
					IniWrite,%modeldefaultloc%,%A_ScriptDir%\Plugins\ReportLog.aldrin_report,Present Models,ModelLocationPath_%repmocount%
					IniWrite,%modeldefaultname%,%A_ScriptDir%\Plugins\ReportLog.aldrin_report,Present Models,ModelDefaultName_%repmocount%
					IniWrite,ModelRealName_%repmocount%,%A_ScriptDir%\Plugins\ReportLog.aldrin_report,Present Models,%modelextractname%
					command=md "%A_ScriptDir%\Plugins\VPKCreator\pak01_dir\%modeldefaultloc%"`r`n"%variablehllib%" -p "%dota2dir%\game\dota\pak01_dir.vpk" -d "%A_ScriptDir%\Plugins\VPKCreator\pak01_dir\%modeldefaultloc%" -e "root\%modelextractfile%"`r`nrename "%A_ScriptDir%\Plugins\VPKCreator\pak01_dir\%modeldefaultloc%\%modelextractname%" "%modeldefaultname%"`r`ndel `%0
					ifexist,%A_ScriptDir%\Plugins\VPKCreator\extract%commandloop%.bat
					{
						FileDelete,%A_ScriptDir%\Plugins\VPKCreator\extract%commandloop%.bat
					}
					fileappend,%command%,%A_ScriptDir%\Plugins\VPKCreator\extract%commandloop%.bat
					if lowprocessor=0
					{
						loop
						{
							run,"%A_ScriptDir%\Plugins\VPKCreator\extract%commandloop%.bat",,Hide UseErrorLevel,extract%commandloop%
							if (ErrorLevel<>ERROR) and (A_LastError=0) ;;  if the run is successful
								break ;; terminate the loop
							;; if the there was an error, rerun the batch file
						}
						
						;run,"%A_ScriptDir%\Plugins\VPKCreator\extract%commandloop%.bat",,Hide UseErrorLevel,extract%commandloop%
					}
					else
					{
						loop
						{
							runwait,"%A_ScriptDir%\Plugins\VPKCreator\extract%commandloop%.bat",,Hide UseErrorLevel,extract%commandloop%
							if (ErrorLevel<>ERROR) and (A_LastError=0) ;;  if the run is successful
								break ;; terminate the loop
							;; if the there was an error, rerun the batch file
						}
						
						;runwait,"%A_ScriptDir%\Plugins\VPKCreator\extract%commandloop%.bat",,Hide UseErrorLevel,extract%commandloop%
					}
				}
			}
		}
		continue
	}
	save=`r`n%A_Tab%%A_Tab%%A_Tab%%A_Tab%%A_Tab%"style"%A_Tab%%A_Tab%"%stylechecker%"
	save1=`r`n%A_Tab%%A_Tab%%A_Tab%%A_Tab%%A_Tab%"style"%A_Tab%%A_Tab%
	if ((numcheck>0) and (InStr(modifierstring,save)>0)) or (numcheck=0) or ((numcheck>0) and (InStr(modifierstring,save1)<1))
	{
		StringGetPos, newpos, readdir,`r`n%A_Tab%"%check% ;"
		StringGetPos, newpos1, readdir,`r`n%A_Tab%},,%newpos%
		StringMid,subjectcontent,readdir,% newpos+1, % newpos1-newpos-1
		StringGetPos, newpos, subjectcontent,`r`n%A_Tab%%A_Tab%"Model"
		StringGetPos, newpos1, subjectcontent,",L3,%newpos% ;"
		StringGetPos, newpos, subjectcontent,",L2,%newpos1% ;"
		StringMid,subjectcontent,subjectcontent,% newpos1+2, % newpos-newpos1-1
		subjectcontent=%subjectcontent%_c
		StringLen,modelvarlength,subjectcontent
		StringReplace,subjectcontent,subjectcontent,/,\,1
		StringGetPos, newpos, subjectcontent,\,R1
		StringTrimLeft,modeldefaultname,subjectcontent,% newpos+1
		StringTrimRight,modeldefaultloc,subjectcontent,% modelvarlength-newpos
		if (modeldefaultloc<>"") and (modelextractfile<>"")
		{
			tmp="item_rarity"%A_Tab%%A_Tab%"arcana"
			if (InStr(filecontent,tmp)>0) and (FileExist("%A_ScriptDir%\Plugins\VPKCreator\pak01_dir\%modeldefaultloc%\%modeldefaultname%"))
			{
				FileDelete,%A_ScriptDir%\Plugins\VPKCreator\pak01_dir\%modeldefaultloc%\%modeldefaultname%
			}
			IfNotExist,%A_ScriptDir%\Plugins\VPKCreator\pak01_dir\%modeldefaultloc%\%modeldefaultname%
			{
				commandloop+=1
				repmocount+=1
				IniWrite,%modeldefaultloc%,%A_ScriptDir%\Plugins\ReportLog.aldrin_report,Present Models,ModelLocationPath_%repmocount%
				IniWrite,%modeldefaultname%,%A_ScriptDir%\Plugins\ReportLog.aldrin_report,Present Models,ModelDefaultName_%repmocount%
				IniWrite,ModelRealName_%repmocount%,%A_ScriptDir%\Plugins\ReportLog.aldrin_report,Present Models,%modelextractname%
				command=md "%A_ScriptDir%\Plugins\VPKCreator\pak01_dir\%modeldefaultloc%"`r`n"%variablehllib%" -p "%dota2dir%\game\dota\pak01_dir.vpk" -d "%A_ScriptDir%\Plugins\VPKCreator\pak01_dir\%modeldefaultloc%" -e "root\%modelextractfile%"`r`nrename "%A_ScriptDir%\Plugins\VPKCreator\pak01_dir\%modeldefaultloc%\%modelextractname%" "%modeldefaultname%"`r`ndel `%0
				ifexist,%A_ScriptDir%\Plugins\VPKCreator\extract%commandloop%.bat
				{
					FileDelete,%A_ScriptDir%\Plugins\VPKCreator\extract%commandloop%.bat
				}
				fileappend,%command%,%A_ScriptDir%\Plugins\VPKCreator\extract%commandloop%.bat
				if lowprocessor=0
				{
					loop
					{
						run,"%A_ScriptDir%\Plugins\VPKCreator\extract%commandloop%.bat",,Hide UseErrorLevel,extract%commandloop%
						if (ErrorLevel<>ERROR) and (A_LastError=0) ;;  if the run is successful
							break ;; terminate the loop
						;; if the there was an error, rerun the batch file
					}
					
					;run,"%A_ScriptDir%\Plugins\VPKCreator\extract%commandloop%.bat",,Hide UseErrorLevel,extract%commandloop%
				}
				else
				{
					loop
					{
						runwait,"%A_ScriptDir%\Plugins\VPKCreator\extract%commandloop%.bat",,Hide UseErrorLevel,extract%commandloop%
						if (ErrorLevel<>ERROR) and (A_LastError=0) ;;  if the run is successful
							break ;; terminate the loop
						;; if the there was an error, rerun the batch file
					}
					
					;runwait,"%A_ScriptDir%\Plugins\VPKCreator\extract%commandloop%.bat",,Hide UseErrorLevel,extract%commandloop%
				}
			}
		}
	}
}
modelcount=0
tmp=`r`n%A_Tab%%A_Tab%%A_Tab%%A_Tab%%A_Tab%"asset"
tmp:=StrReplace(itemname,tmp,tmp,modelcount)
loop,%modelcount%
{
	StringGetPos, ipos1, itemname,`r`n%A_Tab%%A_Tab%%A_Tab%%A_Tab%%A_Tab%"asset",L%A_Index%
	StringGetPos, ipos2, itemname,`r`n%A_Tab%%A_Tab%%A_Tab%%A_Tab%},,%ipos1%
	rightpos:=modeltmplength-ipos1
	StringGetPos, ipos3, itemname,`r`n%A_Tab%%A_Tab%%A_Tab%%A_Tab%{,R1,%rightpos%
	StringMid,modifierstring,itemname,% ipos3+2,% ipos2-ipos3-1
	StringGetPos, newpos, modifierstring,`r`n%A_Tab%%A_Tab%%A_Tab%%A_Tab%%A_Tab%"asset"
	StringGetPos, newpos1, modifierstring,",L3,%newpos%
	StringGetPos, newpos, modifierstring,",L2,%newpos1%
	StringMid,check,modifierstring,% newpos1+2, % newpos-newpos1-1
	if (SubStr(check,-4,5)=".vpcf") and (((numcheck>0) and (InStr(modifierstring,save)>0)) or (numcheck=0) or ((numcheck>0) and (InStr(modifierstring,save1)<1)))
	{
		check=%check%_c
		StringReplace,check,check,/,\,1
		StringGetPos, newpos, check,\,R1
		StringTrimLeft,modeldefaultname,check,% newpos+1
		StringLen,modelvarlength,check
		StringTrimRight,modeldefaultloc,check,% modelvarlength-newpos
		StringGetPos, newpos, modifierstring,`r`n%A_Tab%%A_Tab%%A_Tab%%A_Tab%%A_Tab%"modifier"
		StringGetPos, newpos1, modifierstring,",L3,%newpos%
		StringGetPos, newpos, modifierstring,",L2,%newpos1%
		StringMid,modelextractfile,modifierstring,% newpos1+2, % newpos-newpos1-1
		modelextractfile=%modelextractfile%_c
		StringReplace,modelextractfile,modelextractfile,/,\,1
		StringGetPos, newpos, modelextractfile,\,R1
		StringTrimLeft,modelextractname,modelextractfile,% newpos+1
		tmp="type"%A_Tab%%A_Tab%"particle_combined"
		if InStr(modifierstring,tmp)>0
		{
			IniRead,tmp1,%A_ScriptDir%\Plugins\ReportLog.aldrin_report,Present Particle Effects,%modeldefaultname%
			if tmp1<>ERROR
			{
				StringReplace,tmp1,tmp1,ParticleRealName_,,1
				IniRead,modeldefaultloc,%A_ScriptDir%\Plugins\ReportLog.aldrin_report,Present Particle Effects,ParticleLocationPath_%tmp1%
				IniRead,modeldefaultname,%A_ScriptDir%\Plugins\ReportLog.aldrin_report,Present Particle Effects,ParticleDefaultName_%tmp1%
				rptlimit=%rptlimit%%herousercheck%,
				rptpermit=1
			}
			else
			{
				modeldefaultloc:=modelextractfile:=""
			}
		}
		if (modeldefaultloc<>"") and (modelextractfile<>"")
		{
			tmp="item_rarity"%A_Tab%%A_Tab%"arcana"
			if ((InStr(filecontent,tmp)>0) and (FileExist("%A_ScriptDir%\Plugins\VPKCreator\pak01_dir\%modeldefaultloc%\%modeldefaultname%")) and (InStr(rptlimit,herousercheck)>0)) or (rptpermit=1)
			{
				FileDelete,%A_ScriptDir%\Plugins\VPKCreator\pak01_dir\%modeldefaultloc%\%modeldefaultname%
				if rptpermit=1
				{
					rptpermit=0
				}
			}
			IfNotExist,%A_ScriptDir%\Plugins\VPKCreator\pak01_dir\%modeldefaultloc%\%modeldefaultname%
			{
				commandloop+=1
				repparcount+=1
				IniWrite,%modeldefaultloc%,%A_ScriptDir%\Plugins\ReportLog.aldrin_report,Present Particle Effects,ParticleLocationPath_%repparcount%
				IniWrite,%modeldefaultname%,%A_ScriptDir%\Plugins\ReportLog.aldrin_report,Present Particle Effects,ParticleDefaultName_%repparcount%
				IniWrite,ParticleRealName_%repparcount%,%A_ScriptDir%\Plugins\ReportLog.aldrin_report,Present Particle Effects,%modelextractname%
				command=md "%A_ScriptDir%\Plugins\VPKCreator\pak01_dir\%modeldefaultloc%"`r`n"%variablehllib%" -p "%dota2dir%\game\dota\pak01_dir.vpk" -d "%A_ScriptDir%\Plugins\VPKCreator\pak01_dir\%modeldefaultloc%" -e "root\%modelextractfile%"`r`nrename "%A_ScriptDir%\Plugins\VPKCreator\pak01_dir\%modeldefaultloc%\%modelextractname%" "%modeldefaultname%"`r`ndel `%0
				ifexist,%A_ScriptDir%\Plugins\VPKCreator\extract%commandloop%.bat
				{
					FileDelete,%A_ScriptDir%\Plugins\VPKCreator\extract%commandloop%.bat
				}
				fileappend,%command%,%A_ScriptDir%\Plugins\VPKCreator\extract%commandloop%.bat
				if lowprocessor=0
				{
					loop
					{
						run,"%A_ScriptDir%\Plugins\VPKCreator\extract%commandloop%.bat",,Hide UseErrorLevel,extract%commandloop%
						if (ErrorLevel<>ERROR) and (A_LastError=0) ;;  if the run is successful
							break ;; terminate the loop
						;; if the there was an error, rerun the batch file
					}
					
					;run,"%A_ScriptDir%\Plugins\VPKCreator\extract%commandloop%.bat",,Hide UseErrorLevel,extract%commandloop%
				}
				else
				{
					loop
					{
						runwait,"%A_ScriptDir%\Plugins\VPKCreator\extract%commandloop%.bat",,Hide UseErrorLevel,extract%commandloop%
						if (ErrorLevel<>ERROR) and (A_LastError=0) ;;  if the run is successful
							break ;; terminate the loop
						;; if the there was an error, rerun the batch file
					}
					
					;runwait,"%A_ScriptDir%\Plugins\VPKCreator\extract%commandloop%.bat",,Hide UseErrorLevel,extract%commandloop%
				}
			}
		}
	}
}
return

gipatcher:
fileread,vpktmp,%giloc%
StringLen,filelength,vpktmp
clone=%vpktmp%
finder=Aldrin_Mods
if InStr(vpktmp,finder)
{
	check1=
	check2=
	check3=
	loop
	{
		StringGetPos, ipos, vpktmp,%finder%,L%A_Index%
		if ipos<0
		{
			Break
		}
		rightpos:=filelength-ipos
		StringGetPos, ipos1, vpktmp,`r`n,L2,%ipos%
		StringGetPos, ipos2, vpktmp,`r`n,R1,%rightpos%
		startpos:=ipos2
		ipos3:=ipos1-ipos2
		StringMid,tmp,vpktmp,%startpos%,%ipos3%
		param=Game_Language,Game_LowViolence,Mod
		loop,parse,param,`,
		{
			tmp1=%A_Tab%%A_Tab%%A_Tab%%A_LoopField%
			if InStr(tmp,tmp1)
			{
				check%A_Index%=1
			}
		}
		if ErrorLevel=1
		{
			Break
		}
	}
	param=`r`n%A_Tab%%A_Tab%%A_Tab%Game_Language%A_Tab%%A_Tab%dota_*LANGUAGE*`r`n|`r`n%A_Tab%%A_Tab%%A_Tab%Game_LowViolence%A_Tab%dota_lv`r`n|`r`n%A_Tab%%A_Tab%%A_Tab%Mod%A_Tab%%A_Tab%%A_Tab%%A_Tab%%A_Tab%dota`r`n
	param1=`r`n%A_Tab%%A_Tab%%A_Tab%Game%A_Tab%%A_Tab%%A_Tab%%A_Tab%%finder%`r`n%A_Tab%%A_Tab%%A_Tab%Game_Language%A_Tab%%A_Tab%dota_*LANGUAGE*`r`n|`r`n%A_Tab%%A_Tab%%A_Tab%Game%A_Tab%%A_Tab%%A_Tab%%A_Tab%%finder%`r`n%A_Tab%%A_Tab%%A_Tab%Game_LowViolence%A_Tab%dota_lv`r`n|`r`n%A_Tab%%A_Tab%%A_Tab%Mod%A_Tab%%A_Tab%%A_Tab%%A_Tab%%A_Tab%%finder%`r`n%A_Tab%%A_Tab%%A_Tab%Mod%A_Tab%%A_Tab%%A_Tab%%A_Tab%%A_Tab%dota`r`n
	loop,parse,param,|
	{
		saver=%A_LoopField%
		intsaver=%A_Index%
		loop,parse,param1,|
		{
			if intsaver=%A_Index%
			{
				if check%A_Index%<>1
				{
					StringReplace,vpktmp,vpktmp,%saver%,%A_LoopField%,1
					Break
				}
			}
		}
	}
}
else
{
	param=`r`n%A_Tab%%A_Tab%%A_Tab%Game_Language%A_Tab%%A_Tab%dota_*LANGUAGE*`r`n|`r`n%A_Tab%%A_Tab%%A_Tab%Game_LowViolence%A_Tab%dota_lv`r`n|`r`n%A_Tab%%A_Tab%%A_Tab%Mod%A_Tab%%A_Tab%%A_Tab%%A_Tab%%A_Tab%dota`r`n
	param1=`r`n%A_Tab%%A_Tab%%A_Tab%Game%A_Tab%%A_Tab%%A_Tab%%A_Tab%%finder%`r`n%A_Tab%%A_Tab%%A_Tab%Game_Language%A_Tab%%A_Tab%dota_*LANGUAGE*`r`n|`r`n%A_Tab%%A_Tab%%A_Tab%Game%A_Tab%%A_Tab%%A_Tab%%A_Tab%%finder%`r`n%A_Tab%%A_Tab%%A_Tab%Game_LowViolence%A_Tab%dota_lv`r`n|`r`n%A_Tab%%A_Tab%%A_Tab%Mod%A_Tab%%A_Tab%%A_Tab%%A_Tab%%A_Tab%%finder%`r`n%A_Tab%%A_Tab%%A_Tab%Mod%A_Tab%%A_Tab%%A_Tab%%A_Tab%%A_Tab%dota`r`n
	loop,parse,param,|
	{
		saver=%A_LoopField%
		intsaver=%A_Index%
		index=1
		loop
		{
			StringGetPos, ipos, vpktmp,%saver%
			if ipos<1
			{
				Break
			}
			StringLen,filelength,vpktmp
			rightpos:=filelength-ipos
			if intsaver=3
			{
				tmp2=%A_Tab%%A_Tab%%A_Tab%Mod%A_Tab%
				tmp1=%A_Tab%%A_Tab%%A_Tab%Mod%A_Tab%%A_Tab%%A_Tab%%A_Tab%%finder%
			}
			else
			{
				tmp2=%A_Tab%%A_Tab%%A_Tab%Game%A_Tab%
				tmp1=%A_Tab%%A_Tab%%A_Tab%Game%A_Tab%%A_Tab%%A_Tab%%A_Tab%%finder%
			}
			StringGetPos, ipos1, vpktmp,%tmp2%,R%index%,%rightpos%
			if ipos1<1
			{
				Break
			}
			rightpos:=filelength-ipos1
			StringGetPos, ipos2, vpktmp,`r`n,R1,%rightpos%
			startpos:=ipos2+1
			ipos3:=ipos-ipos2
			StringMid,tmp,vpktmp,%startpos%,%ipos3%
			if (InStr(tmp,tmp1)<1) and (InStr(tmp,tmp2)>0)
			{
				StringReplace,vpktmp,vpktmp,%tmp%,,1
			}
			else
			{
				index:=index+1
			}
			if ErrorLevel=1
			{
				Break
			}
		}
		loop,parse,param1,|
		{
			if intsaver=%A_Index%
			{
				StringReplace,vpktmp,vpktmp,%saver%,%A_LoopField%,1
				Break
			}
		}
	}
}
if clone<>%vpktmp%
{
	FileDelete,%giloc%
	FileAppend,%vpktmp%,%giloc%
}
return

usemiscon:
Gui, MainGUI:Submit, NoHide
GoSub,default_settings
if usemiscon=1
{
	MsgBox, 36, Reload Required!, Checking Miscellaneous requires this tool to be reloaded in order to preload all miscellaneous resources`, any unsaved data/'s will be lost. Do you want to continue? (Press YES or NO)
	IfMsgBox Yes
	{
		IniWrite,%usemiscon%,%A_ScriptDir%\Settings.aldrin_dota2mod,Edits,usemisc
		gosub,savetab
		Reload
		Sleep 1000
		msgbox,16,Error,Cannont Reload`,Please reload the Script Manually!
	}
	else
	{
		guicontrol,,usemiscon,0
	}
}
else
{
	IniWrite,%usemiscon%,%A_ScriptDir%\Settings.aldrin_dota2mod,Edits,usemisc
}
return

miscreload:
Gui, MainGUI:+Disabled 
FileRead,filestring,%A_ScriptDir%\Library\items_game.txt
StringLen,filelength,filestring
sfinder=`r`n%A_Tab%%A_Tab%}`r`n%A_Tab%%A_Tab%" ;"
GuiControl,+cBlue,searchnofound
htarget=`r`n%A_Tab%%A_Tab%%A_Tab%"prefab"%A_Tab%%A_Tab%"announcer"`r`n
lvparam=terrainchoice,hudchoice,courierchoice,wardchoice,loadingscreenchoice,announcerview,tauntview,weatherchoice,musicchoice,cursorchoice,multikillchoice,emblemchoice,radcreepchoice,direcreepchoice
loop,parse,lvparam,`,
{
	GuiControl, MainGUI:-Redraw, %A_LoopField%
}
GuiControl,Text,searchnofound,Detecting changes on the latest "items_game.txt" file
FileRead,compare1,%A_ScriptDir%\Library\items_game.txt
firstmessage=`n;;;;This Section is the indicator if "items_game.txt" is changed`,PLEASE DONT EDIT ANYTHING ON THIS SECTION!!!;;;;`n`n
lastmessage=`n;;;;End of AJOM Indicator;;;;`n`n
readwritefileref=%A_ScriptDir%\Library\Reference.aldrin_dota2mod ; used by varread() and varwrite()
VarWrite(,readwritefileref) ; sets varwrite() inspected variable into readwritefileref
ifexist,%A_ScriptDir%\Library\Reference.aldrin_dota2mod
{
	if fastmisc=1
	{
		FileRead,compare2,%A_ScriptDir%\Library\Reference.aldrin_dota2mod
		compare2:=StrReplace(SubStr(compare2,InStr(compare2,firstmessage),InStr(compare2,lastmessage)-InStr(compare2,firstmessage)),firstmessage)
		if compare1=%compare2%
		{
			; IniRead,tempo,%A_ScriptDir%\Library\Reference.aldrin_dota2mod,Announcers,AnnouncersCount,%A_Space%
			GuiControl,Text,searchnofound,Preloading Reference File
			FileRead,tempo,%readwritefileref%
			VarRead(,tempo) ; remember the contents of the variable and store to "static Var" that is inspected by varread
			if A_DefaultListView<>announcerview
			{
				Gui, MainGUI:ListView,announcerview
			}
			tempo:=VarRead("AnnouncersCount")
			loop %tempo%
			{
				; IniRead,hitemname,%A_ScriptDir%\Library\Reference.aldrin_dota2mod,Announcers,AnnouncerName%A_Index%
				hitemname:=VarRead("AnnouncerName" A_Index)
				GuiControl,Text,searchnofound,Fast Preloading %hitemname%
				; IniRead,hitemslot,%A_ScriptDir%\Library\Reference.aldrin_dota2mod,Announcers,AnnouncerSlot%A_Index%
				; IniRead,hitemrarity,%A_ScriptDir%\Library\Reference.aldrin_dota2mod,Announcers,AnnouncerRarity%A_Index%
				; IniRead,hitemid,%A_ScriptDir%\Library\Reference.aldrin_dota2mod,Announcers,AnnouncerID%A_Index%
				hitemslot:=VarRead("AnnouncerSlot" A_Index)
				hitemrarity:=VarRead("AnnouncerRarity" A_Index)
				hitemid:=VarRead("AnnouncerID" A_Index)
				LV_Add(,hitemname,hitemslot,hitemrarity,hitemid)
			}
			GoSub,lvautosize
			LV_ModifyCol(2,"Sort")
			
			; IniRead,tempo,%A_ScriptDir%\Library\Reference.aldrin_dota2mod,Taunts,TauntsCount
			if A_DefaultListView<>tauntview
			{
				Gui, MainGUI:ListView,tauntview
			}
			tempo:=VarRead("TauntsCount")
			loop %tempo%
			{
				; IniRead,hitemname,%A_ScriptDir%\Library\Reference.aldrin_dota2mod,Taunts,TauntName%A_Index%
				hitemname:=VarRead("TauntName" A_Index)
				GuiControl,Text,searchnofound,Fast Preloading %hitemname%
				; IniRead,hitemrarity,%A_ScriptDir%\Library\Reference.aldrin_dota2mod,Taunts,TauntRarity%A_Index%
				; IniRead,hitemid,%A_ScriptDir%\Library\Reference.aldrin_dota2mod,Taunts,TauntID%A_Index%
				; IniRead,hherouser,%A_ScriptDir%\Library\Reference.aldrin_dota2mod,Taunts,TauntUser%A_Index%
				hitemrarity:=VarRead("TauntRarity" A_Index)
				hitemid:=VarRead("TauntID" A_Index)
				hherouser:=VarRead("TauntUser" A_Index)
				LV_Add(,hitemname,hitemrarity,hitemid,hherouser)
			}
			GoSub,lvautosize
			LV_ModifyCol(4,"Sort")
			
			param=terrain,loading_screen,music,cursor_pack,emblem,weather,multikill_banner
			param2=terrainchoice,loadingscreenchoice,musicchoice,cursorchoice,emblemchoice,weatherchoice,multikillchoice
			loop,parse,param2,`,
			{
				tmplistview=%A_LoopField%
				intsaver=%A_Index%
				loop,parse,param,`,
				{
					if intsaver=%A_Index%
					{
						subject=%A_LoopField%
						if A_DefaultListView<>%tmplistview%
						{
							Gui, MainGUI:ListView,%tmplistview%
						}
						; IniRead,tempo,%A_ScriptDir%\Library\Reference.aldrin_dota2mod,%subject%,%subject%Count
						tempo:=VarRead(subject "Count")
						loop %tempo%
						{
							; IniRead,hitemname,%A_ScriptDir%\Library\Reference.aldrin_dota2mod,%subject%,%subject%Name%A_Index%
							hitemname:=VarRead(subject "Name" A_Index)
							GuiControl,Text,searchnofound,Fast Preloading %subject%: %hitemname%
							; IniRead,hitemrarity,%A_ScriptDir%\Library\Reference.aldrin_dota2mod,%subject%,%subject%Rarity%A_Index%
							; IniRead,hitemid,%A_ScriptDir%\Library\Reference.aldrin_dota2mod,%subject%,%subject%ID%A_Index%
							hitemrarity:=VarRead(subject "Rarity" A_Index)
							hitemid:=VarRead(subject "ID" A_Index)
							LV_Add(,hitemname,hitemrarity,hitemid)
						}
						GoSub,lvautosize
					}
				}
			}
			
			param=courier,ward,hud_skin,radiantcreeps,direcreeps
			param2=courierchoice,wardchoice,hudchoice,radcreepchoice,direcreepchoice
			loop,parse,param2,`,
			{
				tmplistview=%A_LoopField%
				intsaver=%A_Index%
				loop,parse,param,`,
				{
					if intsaver=%A_Index%
					{
						subject=%A_LoopField%
						if A_DefaultListView<>%tmplistview%
						{
							Gui, MainGUI:ListView,%tmplistview%
						}
						; IniRead,tempo,%A_ScriptDir%\Library\Reference.aldrin_dota2mod,%subject%,%subject%Count
						tempo:=VarRead(subject "Count")
						loop %tempo%
						{
							; IniRead,hitemname,%A_ScriptDir%\Library\Reference.aldrin_dota2mod,%subject%,%subject%Name%A_Index%
							hitemname:=VarRead(subject "Name" A_Index)
							GuiControl,Text,searchnofound,Fast Preloading %subject%: %hitemname%
							; IniRead,hitemrarity,%A_ScriptDir%\Library\Reference.aldrin_dota2mod,%subject%,%subject%Rarity%A_Index%
							; IniRead,hitemid,%A_ScriptDir%\Library\Reference.aldrin_dota2mod,%subject%,%subject%ID%A_Index%
							; IniRead,stylescount,%A_ScriptDir%\Library\Reference.aldrin_dota2mod,%subject%,%subject%StyleCount%A_Index%
							; IniRead,tempo,%A_ScriptDir%\Library\Reference.aldrin_dota2mod,%subject%,%subject%ActivedStyle%A_Index%
							hitemrarity:=VarRead(subject "Rarity" A_Index)
							hitemid:=VarRead(subject "ID" A_Index)
							stylescount:=VarRead(subject "StyleCount" A_Index)
							tempo:=VarRead(subject "ActivedStyle" A_Index)
							LV_Add(,hitemname,hitemrarity,hitemid,stylescount,tempo)
						}
						GoSub,lvautosize
					}
				}
			}
			
			loop,parse,lvparam,`,
			{
				GuiControl, MainGUI:+Redraw, %A_LoopField%
			}
			GuiControl,+cDefault,searchnofound
			Gui, MainGUI:-Disabled
			return
		}
	}
	
	
	FileDelete,%A_ScriptDir%\Library\Reference.aldrin_dota2mod
	; FileAppend,%firstmessage%%compare1%%lastmessage%,%A_ScriptDir%\Library\Reference.aldrin_dota2mod
	VarWrite( )				;blanks Function Static "Var" variable! Always start Writing in a blank variable, avoiding Rewritings (Faster) 
}


misccounter=0 ; resets back to zero
Loop
{
	if A_DefaultListView<>announcerview
	{
		Gui, MainGUI:ListView,announcerview
	}
	StringGetPos, ipos, filestring,%htarget%,L%A_Index%
	if ipos<0
	{
		;if fastmisc=1
		;{
			; IniWrite,%misccounter%,%A_ScriptDir%\Library\Reference.aldrin_dota2mod,Announcers,AnnouncersCount
			VarWrite("AnnouncersCount",misccounter)	;VarWrite(Key := "", Value := "")
		;}
		Break
	}
	rightpos:=filelength-ipos
	StringGetPos, ipos1, filestring,%sfinder%,,%ipos%
	StringGetPos, ipos2, filestring,%sfinder%,R1,%rightpos%
	startpos:=ipos2+8
	ipos3:=ipos1-ipos2
	StringMid,filecontent,filestring,%startpos%,%ipos3%
	itemname:=searchstringdetector(filecontent,"""name""") ; detects the name of the item
	hitemname=%itemname%
	tmpbar:=iddetector(filecontent) ;filecontent := extracted content from items_game.txt
	hitemid=%tmpbar%
	itemname:=searchstringdetector(filecontent,"""item_rarity""") ; detects the item's rarity
	hitemrarity=%itemname%
	itemname:=searchstringdetector(filecontent,"""item_slot""") ; detects the hero body slot of the item
	hitemslot=%itemname%
	;if fastmisc=1
	;{
		misccounter+=1 ; used by items count
		; IniWrite,%hitemname%,%A_ScriptDir%\Library\Reference.aldrin_dota2mod,Announcers,AnnouncerName%misccounter%
		; IniWrite,%hitemslot%,%A_ScriptDir%\Library\Reference.aldrin_dota2mod,Announcers,AnnouncerSlot%misccounter%
		; IniWrite,%hitemrarity%,%A_ScriptDir%\Library\Reference.aldrin_dota2mod,Announcers,AnnouncerRarity%misccounter%
		; IniWrite,%hitemid%,%A_ScriptDir%\Library\Reference.aldrin_dota2mod,Announcers,AnnouncerID%misccounter%
		VarWrite("AnnouncerName" misccounter,hitemname)	;VarWrite(Key := "", Value := "")
		VarWrite("AnnouncerSlot" misccounter,hitemslot)	;VarWrite(Key := "", Value := "")
		VarWrite("AnnouncerRarity" misccounter,hitemrarity)	;VarWrite(Key := "", Value := "")
		VarWrite("AnnouncerID" misccounter,hitemid)	;VarWrite(Key := "", Value := "")
	;}
	LV_Add(,hitemname,hitemslot,hitemrarity,hitemid)
	GoSub,lvautosize
	GuiControl,Text,searchnofound,Preloading %hitemname%
	LV_ModifyCol(2,"Sort")
	if ErrorLevel=1
	{
		;if fastmisc=1
		;{
			; IniWrite,%misccounter%,%A_ScriptDir%\Library\Reference.aldrin_dota2mod,Announcers,AnnouncersCount
			VarWrite("AnnouncersCount",misccounter)	;VarWrite(Key := "", Value := "")
		;}
		Break
	}
}
htarget=`r`n%A_Tab%%A_Tab%%A_Tab%"prefab"%A_Tab%%A_Tab%"taunt"`r`n
misccounter=0 ; resets back to zero
Loop
{
	if A_DefaultListView<>tauntview
	{
		Gui, MainGUI:ListView,tauntview
	}
	StringGetPos, ipos, filestring,%htarget%,L%A_Index%
	if ipos<0
	{
		;if fastmisc=1
		;{
			; IniWrite,%misccounter%,%A_ScriptDir%\Library\Reference.aldrin_dota2mod,Taunts,TauntsCount
			VarWrite("TauntsCount",misccounter)	;VarWrite(Key := "", Value := "")
		;}
		Break
	}
	rightpos:=filelength-ipos
	StringGetPos, ipos1, filestring,%sfinder%,,%ipos%
	StringGetPos, ipos2, filestring,%sfinder%,R1,%rightpos%
	startpos:=ipos2+8
	ipos3:=ipos1-ipos2
	StringMid,filecontent,filestring,%startpos%,%ipos3%
	itemname:=searchstringdetector(filecontent,"""name""") ; detects the name of the item
	hitemname=%itemname%
	tmpbar:=iddetector(filecontent) ;filecontent := extracted content from items_game.txt
	hitemid=%tmpbar%
	itemname:=searchstringdetector(filecontent,"""item_rarity""") ; detects the item's rarity
	hitemrarity=%itemname%
	itemname:=searchstringdetector(filecontent,"""used_by_heroes""") ; detects the hero who uses the item
	hherouser=%itemname%
	StringTrimLeft, hherouser, hherouser, 14
	;if fastmisc=1
	;{
		misccounter+=1 ; used by items count
		;IniWrite,%hitemname%,%A_ScriptDir%\Library\Reference.aldrin_dota2mod,Taunts,TauntName%misccounter%
		;IniWrite,%hitemrarity%,%A_ScriptDir%\Library\Reference.aldrin_dota2mod,Taunts,TauntRarity%misccounter%
		;IniWrite,%hitemid%,%A_ScriptDir%\Library\Reference.aldrin_dota2mod,Taunts,TauntID%misccounter%
		;IniWrite,%hherouser%,%A_ScriptDir%\Library\Reference.aldrin_dota2mod,Taunts,TauntUser%misccounter%
		VarWrite("TauntName" misccounter,hitemname)	;VarWrite(Key := "", Value := "")
		VarWrite("TauntRarity" misccounter,hitemrarity)	;VarWrite(Key := "", Value := "")
		VarWrite("TauntID" misccounter,hitemid)	;VarWrite(Key := "", Value := "")
		VarWrite("TauntUser" misccounter,hherouser)	;VarWrite(Key := "", Value := "")
	;}
	LV_Add(,hitemname,hitemrarity,hitemid,hherouser)
	GoSub,lvautosize
	GuiControl,Text,searchnofound,Preloading %hitemname%
	LV_ModifyCol(4,"Sort")
	if ErrorLevel=1
	{
		;if fastmisc=1
		;{
			; IniWrite,%misccounter%,%A_ScriptDir%\Library\Reference.aldrin_dota2mod,Taunts,TauntsCount
			VarWrite("TauntsCount",misccounter)	;VarWrite(Key := "", Value := "")
		;}
		Break
	}
}
filter=`r`n%A_Tab%%A_Tab%%A_Tab%"prefab"%A_Tab%%A_Tab%"misc"`r`n
param=weather,multikill_banner
param2=weatherchoice,multikillchoice
loop,parse,param2,`,
{
	tmplistview=%A_LoopField%
	intsaver=%A_Index%
	loop,parse,param,`,
	{
		if intsaver=%A_Index%
		{
			subject=%A_LoopField%
			misccounter=0 ; resets back to zero
			Loop
			{
				if A_DefaultListView<>%tmplistview%
				{
					Gui, MainGUI:ListView,%tmplistview%
				}
				htarget=`r`n%A_Tab%%A_Tab%%A_Tab%"item_slot"%A_Tab%%A_Tab%"%subject%"`r`n
				StringGetPos, ipos, filestring,%htarget%,L%A_Index%
				rightpos:=filelength-ipos
				StringGetPos, ipos1, filestring,%sfinder%,,%ipos%
				StringGetPos, ipos2, filestring,%sfinder%,R1,%rightpos%
				startpos:=ipos2+8
				ipos3:=ipos1-ipos2
				StringMid,filecontent,filestring,%startpos%,%ipos3%
				if InStr(filecontent,filter)>0
				{
					itemname:=searchstringdetector(filecontent,"""name""") ; detects the name of the item
					hitemname=%itemname%
					tmpbar:=iddetector(filecontent) ;filecontent := extracted content from items_game.txt
					hitemid=%tmpbar%
					itemname:=searchstringdetector(filecontent,"""item_rarity""") ; detects the item's rarity
					hitemrarity=%itemname%
					;if fastmisc=1
					;{
						misccounter+=1 ; used by items count
						; IniWrite,%hitemname%,%A_ScriptDir%\Library\Reference.aldrin_dota2mod,%subject%,%subject%Name%misccounter%
						; IniWrite,%hitemrarity%,%A_ScriptDir%\Library\Reference.aldrin_dota2mod,%subject%,%subject%Rarity%misccounter%
						; IniWrite,%hitemid%,%A_ScriptDir%\Library\Reference.aldrin_dota2mod,%subject%,%subject%ID%misccounter%
						VarWrite(subject "Name" misccounter,hitemname)	;VarWrite(Key := "", Value := "")
						VarWrite(subject "Rarity" misccounter,hitemrarity)	;VarWrite(Key := "", Value := "")
						VarWrite(subject "ID" misccounter,hitemid)	;VarWrite(Key := "", Value := "")
					;}
					LV_Add(,hitemname,hitemrarity,hitemid)
					GoSub,lvautosize
					GuiControl,Text,searchnofound,Preloading %subject% Effect: %hitemname%
				}
				if ErrorLevel=1
				{
					;if fastmisc=1
					;{
						; IniWrite,%misccounter%,%A_ScriptDir%\Library\Reference.aldrin_dota2mod,%subject%,%subject%Count
						VarWrite(subject "Count",misccounter)	;VarWrite(Key := "", Value := "")
					;}
					Break
				}
			}
		}
	}
}
param=terrain,loading_screen,music,cursor_pack,emblem
param2=terrainchoice,loadingscreenchoice,musicchoice,cursorchoice,emblemchoice
loop,parse,param2,`,
{
	tmplistview=%A_LoopField%
	intsaver=%A_Index%
	loop,parse,param,`,
	{
		if intsaver=%A_Index%
		{
			subject=%A_LoopField%
			misccounter=0 ; resets back to zero
			Loop
			{
				firstloop=%A_Index%
				if A_DefaultListView<>%tmplistview%
				{
					Gui, MainGUI:ListView,%tmplistview%
				}
				htarget=`r`n%A_Tab%%A_Tab%%A_Tab%"prefab"%A_Tab%%A_Tab%"%subject%"`r`n
				StringGetPos, ipos, filestring,%htarget%,L%firstloop%
				if ipos<0
				{
					;if fastmisc=1
					;{
						; IniWrite,%misccounter%,%A_ScriptDir%\Library\Reference.aldrin_dota2mod,%subject%,%subject%Count
						VarWrite(subject "Count",misccounter)	;VarWrite(Key := "", Value := "")
					;}
					Break
				}
				rightpos:=filelength-ipos
				StringGetPos, ipos1, filestring,%sfinder%,,%ipos%
				StringGetPos, ipos2, filestring,%sfinder%,R1,%rightpos%
				startpos:=ipos2+8
				ipos3:=ipos1-ipos2
				StringMid,filecontent,filestring,%startpos%,%ipos3%
				itemname:=searchstringdetector(filecontent,"""name""") ; detects the name of the item
				hitemname=%itemname%
				tmpbar:=iddetector(filecontent) ;filecontent := extracted content from items_game.txt
				hitemid=%tmpbar%
				itemname:=searchstringdetector(filecontent,"""item_rarity""") ; detects the item's rarity
				hitemrarity=%itemname%
				;if fastmisc=1
				;{
					misccounter+=1 ; used by items count
					; IniWrite,%hitemname%,%A_ScriptDir%\Library\Reference.aldrin_dota2mod,%subject%,%subject%Name%misccounter%
					; IniWrite,%hitemrarity%,%A_ScriptDir%\Library\Reference.aldrin_dota2mod,%subject%,%subject%Rarity%misccounter%
					; IniWrite,%hitemid%,%A_ScriptDir%\Library\Reference.aldrin_dota2mod,%subject%,%subject%ID%misccounter%
					VarWrite(subject "Name" misccounter,hitemname)	;VarWrite(Key := "", Value := "")
					VarWrite(subject "Rarity" misccounter,hitemrarity)	;VarWrite(Key := "", Value := "")
					VarWrite(subject "ID" misccounter,hitemid)	;VarWrite(Key := "", Value := "")
				;}
				LV_Add(,hitemname,hitemrarity,hitemid)
				GoSub,lvautosize
				GuiControl,Text,searchnofound,Preloading %subject%: %hitemname%
				if ErrorLevel=1
				{
					;if fastmisc=1
					;{
						; IniWrite,%misccounter%,%A_ScriptDir%\Library\Reference.aldrin_dota2mod,%subject%,%subject%Count
						VarWrite(subject "Count",misccounter)	;VarWrite(Key := "", Value := "")
					;}
					Break
				}
			}
		}
	}
}
param=courier,ward,hud_skin,radiantcreeps,direcreeps
param2=courierchoice,wardchoice,hudchoice,radcreepchoice,direcreepchoice
loop,parse,param2,`,
{
	tmplistview=%A_LoopField%
	intsaver=%A_Index%
	loop,parse,param,`,
	{
		if intsaver=%A_Index%
		{
			subject=%A_LoopField%
			misccounter=0 ; resets back to zero
			Loop
			{
				firstloop=%A_Index%
				if A_DefaultListView<>%tmplistview%
				{
					Gui, MainGUI:ListView,%tmplistview%
				}
				htarget=`r`n%A_Tab%%A_Tab%%A_Tab%"prefab"%A_Tab%%A_Tab%"%subject%"`r`n
				StringGetPos, ipos, filestring,%htarget%,L%firstloop%
				if ipos<0
				{
					;if fastmisc=1
					;{
						; IniWrite,%misccounter%,%A_ScriptDir%\Library\Reference.aldrin_dota2mod,%subject%,%subject%Count
						VarWrite(subject "Count",misccounter)	;VarWrite(Key := "", Value := "")
					;}
					Break
				}
				rightpos:=filelength-ipos
				StringGetPos, ipos1, filestring,%sfinder%,,%ipos%
				StringGetPos, ipos2, filestring,%sfinder%,R1,%rightpos%
				startpos:=ipos2+8
				ipos3:=ipos1-ipos2
				StringMid,filecontent,filestring,%startpos%,%ipos3%
				itemname:=searchstringdetector(filecontent,"""name""") ; detects the name of the item
				hitemname=%itemname%
				tmpbar:=iddetector(filecontent) ;filecontent := extracted content from items_game.txt
				hitemid=%tmpbar%
				itemname:=searchstringdetector(filecontent,"""item_rarity""") ; detects the item's rarity
				hitemrarity=%itemname%
				stylescount:=stylecountdetector(filecontent) ;counts the number of allowed styles of an item
				;if fastmisc=1
				;{
					misccounter+=1 ; used by items count
					; IniWrite,%hitemname%,%A_ScriptDir%\Library\Reference.aldrin_dota2mod,%subject%,%subject%Name%misccounter%
					; IniWrite,%hitemrarity%,%A_ScriptDir%\Library\Reference.aldrin_dota2mod,%subject%,%subject%Rarity%misccounter%
					; IniWrite,%hitemid%,%A_ScriptDir%\Library\Reference.aldrin_dota2mod,%subject%,%subject%ID%misccounter%
					; IniWrite,%stylescount%,%A_ScriptDir%\Library\Reference.aldrin_dota2mod,%subject%,%subject%StyleCount%misccounter%
					; IniWrite,0,%A_ScriptDir%\Library\Reference.aldrin_dota2mod,%subject%,%subject%ActivedStyle%misccounter%
					VarWrite(subject "Name" misccounter,hitemname)	;VarWrite(Key := "", Value := "")
					VarWrite(subject "Rarity" misccounter,hitemrarity)	;VarWrite(Key := "", Value := "")
					VarWrite(subject "ID" misccounter,hitemid)	;VarWrite(Key := "", Value := "")
					VarWrite(subject "StyleCount" misccounter,stylescount)	;VarWrite(Key := "", Value := "")
					VarWrite(subject "ActivedStyle" misccounter,"0")	;VarWrite(Key := "", Value := "")
				;}
				LV_Add(,hitemname,hitemrarity,hitemid,stylescount,"0")
				GoSub,lvautosize
				GuiControl,Text,searchnofound,Preloading %subject%: %hitemname%
				if ErrorLevel=1
				{
					;if fastmisc=1
					;{
						; IniWrite,%misccounter%,%A_ScriptDir%\Library\Reference.aldrin_dota2mod,%subject%,%subject%Count
						VarWrite(subject "Count",misccounter)	;VarWrite(Key := "", Value := "")
					;}
					Break
				}
			}
		}
	}
}
GuiControl,Text,searchnofound,Creating Reference File
FileAppend,% VarWrite( , "GetVar") "`r`n" firstmessage compare1 lastmessage,%A_ScriptDir%\Library\Reference.aldrin_dota2mod ;"VarWrite( ,"GetVar")" function returns the text that will be stored in the file choosed by user, the first parameter must be omitted or blank
loop,parse,lvparam,`,
{
	GuiControl, MainGUI:+Redraw, %A_LoopField%
}
GuiControl,+cDefault,searchnofound
Gui, MainGUI:-Disabled 
return

autovpkon:
Gui, MainGUI:Submit, NoHide
if autovpkon=1
{
	ifnotExist,%giloc%
	{
		Gui, MainGUI:+Disabled 
		guicontrol,,autovpkon,0
		msgbox,16,ERROR!,The located "gameinfo.gi" path Does not EXIST!
		Gui, MainGUI:-Disabled 
	}
	else if giloc=
	{
		Gui, MainGUI:+Disabled 
		guicontrol,,autovpkon,0
		msgbox,16,ERROR!,Please locate "gameinfo.gi" first before activating this feature.
		Gui, MainGUI:-Disabled 
	}
}
return

basicmisc:
if InStr(ErrorLevel, "C", true)
{
	if A_DefaultListView<>%A_GuiControl%
	{
		Gui, MainGUI:ListView, %A_GuiControl%
	}
	Loop % LV_GetCount()
	{
		if A_EventInfo<>%A_Index%
		{
			LV_Modify(A_Index,"-Check")
		}
	}
}
return

announcerview:
if InStr(ErrorLevel, "C", true)
{
	if A_DefaultListView<>announcerview
	{
		Gui, MainGUI:ListView,announcerview
	}
	LV_GetText(tmp,A_EventInfo,2)
	Loop % LV_GetCount()
	{
		if A_EventInfo<>%A_Index%
		{
			LV_GetText(tmp1,A_Index,2)
			if tmp=%tmp1%
			{
				LV_Modify(A_Index,"-Check")
			}
		}
	}
}
return

tauntview:
if InStr(ErrorLevel, "C", true)
{
	if A_DefaultListView<>tauntview
	{
		Gui, MainGUI:ListView,tauntview
	}
	LV_GetText(tmp,A_EventInfo,4)
	Loop % LV_GetCount()
	{
		if A_EventInfo<>%A_Index%
		{
			LV_GetText(tmp1,A_Index,4)
			if tmp=%tmp1%
			{
				LV_Modify(A_Index,"-Check")
			}
		}
	}
}
return

d2locbrowse:
Gui MainGUI:+OwnDialogs
FileSelectFolder,invfolder,*%SteamPath%\steamapps\common\,,Browse DOTA2 Directory
if invfolder<>
{
	ifexist,%invfolder%\game\dota\pak01_dir.vpk
	{
		msgbox,36,Confirmation,Are you Sure that:`n`n%invfolder%\`n`nIs the Directory of your DOTA2 Beta?
		IfMsgBox Yes
		{
			GuiControl,Text,dota2dir,%invfolder%||
			dota2dir=%invfolder%
			mapdota2dir=%invfolder%
		}
		else
		{
			gosub,d2locbrowse
		}
	}
	else
	{
		msgbox,48,ERROR!!!,%invfolder%\game\dota\pak01_dir.vpk should exist on the folder you selected!!! TRY AGAIN!!!
		gosub,d2locbrowse
	}
}
return

d2dirdetection:
RegRead, SteamPath, HKEY_CURRENT_USER, Software\Valve\Steam, SteamPath
StringReplace,SteamPath,SteamPath,/,\,1
Loop,%SteamPath%\steamapps\common\*,2
{
	ifexist,%A_LoopFileFullPath%\game\dota\pak01_dir.vpk
	{
		dota2dir=%A_LoopFileFullPath%
		mapdota2dir=%A_LoopFileFullPath%
		GuiControl,Text,dota2dir,%A_LoopFileFullPath%||
		Break
	}
}
if dota2dir=
{
	msgbox,16,ERROR!!!,DOTA2 Directory cannot be detected`, Please Locate the Directory of your DOTA2 Game found at "%SteamPath%/steamapps/common/"`n`nERROR Result: "game/dota/pak01_dir.vpk" cannot be detected.
	gosub,d2locbrowse
}
return

gilocbrowse:
Gui MainGUI:+OwnDialogs
FileSelectFile,invfile,3,,gameinfo.gi,gameinfo.gi
if invfile<>
{
	GuiControl,Text,giloc,%invfile%||
}
return

dirremover:
if (invdirview<>"") and (A_GuiControl="invdirview")
{
	msgbox,36,Confirm Dropdownlist Removal, Your are about to disable the use of "Custom items_game.txt". Are you sure you want to remove:`n"%invdirview%"
	IfMsgBox No
	{
		return
	}
	else IfMsgBox Yes
	{
		guicontrol,,ucron,0
	}
}
else if (giloc<>"") and (A_GuiControl="giloc")
{
	msgbox,36,Confirm Dropdownlist Removal, Your are about to disable the use of "Auto-Shutnik Method". The Following consequences will be initiated:`n`nENABLED-Auto-Creation of pak01_dir Folder with all hero cosmetic item files inside at:`n"%A_ScriptDir%\Generated MOD\"`nDISABLED-Auto-Patching of "gameinfo.gi"`nDISABLED-Auto-Creation of pak01_dir.vpk archieve at:`n"%dota2dir%\game\Aldrin_Mods\"`n`nAre you sure you want to Clear this path on the list?:`n"%giloc%"
	IfMsgBox No
	{
		return
	}
	else IfMsgBox Yes
	{
		guicontrol,,autovpkon,0
	}
}
else if (datadirview<>"") and (A_GuiControl="datadirview")
{
	msgbox,36,Confirm Dropdownlist Removal, Your are about to EMPTY the Datalists.Are you sure you want to Clear this path on the list?:`n"%datadirview%"
	IfMsgBox No
	{
		return
	}
	else IfMsgBox Yes
	{
		if A_DefaultListView<>invlv
		{
			Gui, MainGUI:ListView, invlv
		}
		LV_Delete()
	}
}
else if (hdatadirview<>"") and (A_GuiControl="hdatadirview")
{
	msgbox,36,Confirm Dropdownlist Removal, Your are about to EMPTY the Datalists.Are you sure you want to Clear this path on the list?:`n"%hdatadirview%"
	IfMsgBox No
	{
		return
	}
	else IfMsgBox Yes
	{
		if A_DefaultListView<>itemview
		{
			Gui, MainGUI:ListView, itemview
		}
		LV_Delete()
	}
}
GuiControl,MainGUI:Text,%A_GuiControl%,|
Gui, MainGUI:Submit, NoHide
return

chreload:
Gui, MainGUI:Default
Gui, MainGUI:+Disabled 
if A_DefaultListView<>chview
{
	Gui, MainGUI:ListView, chview
}
Loop %customherocount%
{
	IniRead,tmp2,%A_ScriptDir%\CustomHeroes.aldrin_dota2mod,CustomHeroes,CustomHero%A_Index%
	tmp := StrReplace(tmp,chbar,chbar,existencecount)
	LV_Add(,tmp2,existencecount)
	GoSub,lvautosize
}
Gui, MainGUI:-Disabled 
return

chbuttondelete:
Gui, MainGUI:Default
if A_DefaultListView<>chview
{
	Gui, MainGUI:ListView, chview
}
gosub,deleterow
return

chview:
if A_GuiControl=chview
{
	if A_GuiEvent=RightClick
	{
		Menu, chContextMenu, Show
	}
}
return

chadd:
Gui, MainGUI:Submit, NoHide
if InStr(mapherochoice,chbar)
{
	return
}
if A_DefaultListView<>chview
{
	Gui, MainGUI:ListView, chview
}
Loop % LV_GetCount()
{
	LV_GetText(checker,A_Index,1)
	if checker=%chbar%
	{
		return
	}
}
FileRead,tmp,%A_ScriptDir%\Library\items_game.txt
tmp := StrReplace(tmp,chbar,chbar,existencecount)
LV_Add(,chbar,existencecount)
GoSub,lvautosize
return

chsave:
gosub,leakdestroyer
Gui, MainGUI:Submit, NoHide
ifexist,%A_ScriptDir%\CustomHeroes.aldrin_dota2mod
{
	FileDelete,%A_ScriptDir%\CustomHeroes.aldrin_dota2mod
}
FileAppend,%masterfilecontent%,%A_ScriptDir%\CustomHeroes.aldrin_dota2mod
Loop % LV_GetCount()
{
	LV_GetText(tmp,A_Index,1)
	IniWrite,%tmp%,%A_ScriptDir%\CustomHeroes.aldrin_dota2mod,CustomHeroes,CustomHero%A_Index%
}
gosub,savetab
Reload
Sleep 1000
msgbox Failed to Reload`,Please Restart this Tool Manually
return

default_settings:
IfNotExist,%A_ScriptDir%\Settings.aldrin_dota2mod
{
	FileAppend,,%A_ScriptDir%\Settings.aldrin_dota2mod
	IniWrite,0,%A_ScriptDir%\Settings.aldrin_dota2mod,Edits,ucr
	param=0,1,3,1,0,0,0,0,1
	param1=pet,usemisc,mappetstyle,soundon,useextportraitfile,useextfile,useextitemgamefile,fastmisc,showtooltips
	loop,parse,param,`,
	{
		paramtmp=%A_LoopField%
		saver=%A_Index%
		loop,parse,param1,`,
		{
			if saver=%A_Index%
			{
				IniWrite,%paramtmp%,%A_ScriptDir%\Settings.aldrin_dota2mod,Edits,%A_LoopField%
			}
		}
	}
	RegRead, SteamPath, HKEY_CURRENT_USER, Software\Valve\Steam, SteamPath
	StringReplace,SteamPath,SteamPath,/,\,1
	ifexist,%dota2dir%\game\dota\gameinfo.gi
	{
		IniWrite,%dota2dir%\game\dota\gameinfo.gi,%A_ScriptDir%\Settings.aldrin_dota2mod,Edits,mapgiloc
		IniWrite,1,%A_ScriptDir%\Settings.aldrin_dota2mod,Edits,autovpk
	}
	else
	{
		IniWrite,0,%A_ScriptDir%\Settings.aldrin_dota2mod,Edits,autovpk
	}
	ifexist,%SteamPath%\steamapps\common\dota 2 beta\game\dota\pak01_dir.vpk
	{
		IniWrite,%SteamPath%\steamapps\common\dota 2 beta,%A_ScriptDir%\Settings.aldrin_dota2mod,Edits,mapdota2dir
	}
	else ifexist,%dota2dir%\game\dota\pak01_dir.vpk
	{
		IniWrite,%dota2dir%,%A_ScriptDir%\Settings.aldrin_dota2mod,Edits,mapdota2dir
	}
	newuser=1
}
return

mdirbrowse:
Gui MainGUI:+OwnDialogs
Gui,MainGUI:Submit,NoHide
FileSelectFile,invfile,3,,items_game.txt,items_game.txt
checker:=SubStr(invfile,-13,14)
If checker=items_game.txt
{
	GuiControl,Text,mdirview,%invfile%||
}
return

mselectinject:
gosub,leakdestroyer
ifnotexist,%A_ScriptDir%\Library\items_game.txt
{
	msgbox,16,Error!!!,"%A_ScriptDir%\Library\items_game.txt"`n`nIs Missing!!! Make sure to add the original "items_game.txt" at "%A_ScriptDir%\Library" Folder.`n`nIf you dont have an Idea how to get the original "items_game.txt" use "GCFScape.exe" or "Valve's Resource Viewer" application to access "Pak01_dir.vpk". Inside the VPK Archive`,Hit "Ctrl+F"(Find) and search for "items_game.txt". If successfully found`, extract it(items_game.txt) at "%A_ScriptDir%\Library\" Folder.
	return
}
Gui, MainGUI:+Disabled 
Gui,MainGUI:Submit,NoHide
FileRead,filefrom,%mdirview%
StringLen,filefromlength,filefrom
FileRead,fileto,%A_ScriptDir%\Library\items_game.txt
StringLen,filetolength,fileto
filechecker:=fileto,masterfilecontent:=fileto,IPS:=A_TickCount
usedFinder=%A_Tab%%A_Tab%%A_Tab%"prefab"%A_Tab%%A_Tab%"default_item"
usedBarrier=%A_Tab%%A_Tab%}`r`n%A_Tab%%A_Tab%" ;"
GuiControl,+cBlue,searchnofound
Loop
{
	StringGetPos, pos, filefrom,%usedFinder%,L%A_Index%
	if pos<0
	{
		Break
	}
	StringGetPos, pos1, filefrom,%usedBarrier%,,pos
	rightpos:=filefromlength-pos1
	StringGetPos, pos2, filefrom,%usedBarrier%,R1,rightpos
	length:=pos1-pos2
	StringMid,comparedfrom,filefrom,%pos2%,%length%
	if comparedfrom=
	{
		Break
	}
	filecontent=%comparedfrom%
	itemname:=searchstringdetector(filecontent,"""item_slot""") ; detects the hero body slot of the item
	itemslotfrom=%itemname%
	itemname:=searchstringdetector(filecontent,"""used_by_heroes""") ; detects the hero who uses the item
	herouserfrom=%itemname%
	if herouserfrom<>name
	{
		tmpbar:=iddetector(filecontent) ;filecontent := extracted content from items_game.txt
		idfrom=%tmpbar%
		tmpstring=%tmpbar%
		; measures the number of items injected per second
		Gui,MainGUI:Show, NoActivate,% floor(1000/(A_TickCount-IPS)) " Items per Second"
		IPS:=A_TickCount
		;
		GuiControl,Text,searchnofound,Please Stand By`, Migrating %herouserfrom%'s %itemslotfrom%
		filestring=%fileto%
		filecontent:=itemdetector(tmpstring) ;filecontent:=itemdetector(tmpstring,filestring)
		comparedto=%filecontent%
		itemname:=searchstringdetector(filecontent,"""item_slot""") ; detects the hero body slot of the item
		itemslotto=%itemname%
		itemname:=searchstringdetector(filecontent,"""used_by_heroes""") ; detects the hero who uses the item
		herouserto=%itemname%
		if (itemslotto=itemslotfrom) and (herouserto=herouserfrom) and (comparedto<>comparedfrom)
		{
			StringReplace,masterfilecontent,masterfilecontent,%comparedto%,%comparedfrom%,1
		}
		else if comparedto<>%comparedfrom%
		{
			loop
			{
				StringGetPos, pos, fileto,%herouserfrom%,L%A_Index%
				if pos<0
				{
					Break
				}
				StringGetPos, pos1, fileto,%usedBarrier%,,pos
				rightpos:=filetolength-pos1
				StringGetPos, pos2, fileto,%usedBarrier%,R1,rightpos
				length:=pos1-pos2
				StringMid,comparedto,fileto,%pos2%,%length%
				if comparedto=
				{
					Break
				}
				filecontent=%comparedto%
				itemname:=searchstringdetector(filecontent,"""item_slot""") ; detects the hero body slot of the item
				itemslotto=%itemname%
				itemname:=searchstringdetector(filecontent,"""used_by_heroes""") ; detects the hero who uses the item
				herouserto=%itemname%
				if (InStr(comparedto,"default_item")) and (itemslotto=itemslotfrom)
				{
					tmpbar:=iddetector(filecontent) ;filecontent := extracted content from items_game.txt
					idto=%tmpbar%
					StringReplace,comparedfrom,comparedfrom,"%idfrom%","%idto%",1
					StringReplace,masterfilecontent,masterfilecontent,%comparedto%,%comparedfrom%,1
					Break
				}
				If ErrorLevel=1
				{
					Break
				}
			}
		}
		If ErrorLevel=1
		{
			Break
		}
	}
}
if usemiscon=1
{
	GoSub,execmisc
}
if masterfilecontent=%filechecker%
{
	msgbox,16,ERROR!,No change was found to be migrated!
}
else
{
	IfNotExist,%A_ScriptDir%\Generated MOD\
	{
		FileCreateDir, %A_ScriptDir%\Generated MOD
	}
	else ifexist,%A_ScriptDir%\Generated MOD\items_game.txt
	{
		FileDelete,%A_ScriptDir%\Generated MOD\items_game.txt
	}
	FileAppend,%masterfilecontent%,%A_ScriptDir%\Generated MOD\items_game.txt
	GuiControl,+cGreen,searchnofound
	GuiControl,Text,searchnofound,Operation Finished!
	sleep 1000
	Run, %A_ScriptDir%\Generated MOD\
}
GuiControl,+cDefault,searchnofound
GuiControl,Text,searchnofound,%defaultshoutout%
Gui,MainGUI:Show, NoActivate,AJOM's Dota 2 MOD Master
Gui, MainGUI:-Disabled 
return

itemview:
if A_GuiControl=itemview
{
	if A_GuiEvent=RightClick
	{
		position=%A_EventInfo%
		Menu, MyContextMenu, Show
	}
}
return

hbuttondelete:
Gui, MainGUI:Default
if A_DefaultListView<>itemview
{
	Gui, MainGUI:ListView, itemview
}
gosub,deleterow
checkdetector() ; check any field that exist on the listview "itemview"
return

hbuttonstyle:
Gui, MainGUI:Default
if A_DefaultListView<>itemview
{
	Gui, MainGUI:ListView, itemview
}
LV_GetText(stylescount,position,6)
LV_GetText(countcheck,position,7)
if stylescount>%countcheck%
{
	LV_Modify(position,"Select" "Col7",,,,,,,countcheck+1)
}
else
{
	LV_Modify(position,"Select" "Col7",,,,,,,"0")
}
checkdetector() ; check any field that exist on the listview "itemview"
return

movepak:
loop
{
	wait=0
	loop %commandloop%
	{
		tmp:=extract%A_Index%
		ifwinexist,ahk_pid %tmp%
		{
			wait=1
		}
	}
	loop,6
	{
		tmp:=misc%A_Index%
		ifwinexist,ahk_pid %tmp%
		{
			wait=1
		}
	}
	if wait=0
	{
		loop %commandloop%
		{
			ifexist,%A_ScriptDir%\Plugins\VPKCreator\extract%A_Index%.bat
			{
				run,%A_ScriptDir%\Plugins\VPKCreator\extract%A_Index%.bat,,Hide UseErrorLevel
				wait=1
			}
		}
		loop,6
		{
			ifexist,%A_ScriptDir%\Plugins\VPKCreator\misc%A_Index%.bat
			{
				run,%A_ScriptDir%\Plugins\VPKCreator\misc%A_Index%.bat,,Hide UseErrorLevel
				wait=1
			}
		}
		if wait=0
		{
			Break
		}
	}
}
IfNotExist,%A_ScriptDir%\Generated MOD\
{
	FileCreateDir, %A_ScriptDir%\Generated MOD
}
else ifexist,%A_ScriptDir%\Generated MOD\pak01_dir\
{
	GuiControl,Text,searchnofound,Deleting pak01_dir Folder at Generated MOD Folder
	FileRemoveDir,%A_ScriptDir%\Generated MOD\pak01_dir,1
}
IfNotExist,%A_ScriptDir%\Plugins\VPKCreator\pak01_dir\scripts\items\
{
	FileCreateDir,%A_ScriptDir%\Plugins\VPKCreator\pak01_dir\scripts\items\
}
else ifexist,%A_ScriptDir%\Plugins\VPKCreator\pak01_dir\scripts\items\items_game.txt
{
	FileDelete,%A_ScriptDir%\Plugins\VPKCreator\pak01_dir\scripts\items\items_game.txt
}
FileAppend,%masterfilecontent%,%A_ScriptDir%\Plugins\VPKCreator\pak01_dir\scripts\items\items_game.txt
IfNotExist,%A_ScriptDir%\Plugins\VPKCreator\pak01_dir\scripts\npc\
{
	FileCreateDir,%A_ScriptDir%\Plugins\VPKCreator\pak01_dir\scripts\npc\
}
else ifexist,%A_ScriptDir%\Plugins\VPKCreator\pak01_dir\scripts\npc\portraits.txt
{
	FileDelete,%A_ScriptDir%\Plugins\VPKCreator\pak01_dir\scripts\npc\portraits.txt
}
FileAppend,%portstring%,%A_ScriptDir%\Plugins\VPKCreator\pak01_dir\scripts\npc\portraits.txt
gosub,externalfiles
FileMoveDir,%A_ScriptDir%\Plugins\VPKCreator\pak01_dir,%A_ScriptDir%\Generated MOD\pak01_dir,2
if soundon=1
{
	SoundPlay,%A_Temp%\Sound\OperationFinished.wav
}
GuiControl,+cGreen,searchnofound
GuiControl,Text,searchnofound,Operation Finished!
sleep 1000
Run, %A_ScriptDir%\Generated MOD\
GuiControl,+cDefault,searchnofound
GuiControl,MainGUI:Text,searchnofound,%defaultshoutout%

return

;Scans the database then put a checkmark on each miscellaneous it uses
reloadmisc(invfile) {
	Gui, MainGUI:+Disabled 
	gosub,hideprogress
	GuiControl,+cBlue,searchnofound
	
	if VarRead("@DataBaseVersion!")=2
	{
		param=terrainchoice,weatherchoice,hudchoice,courierchoice,wardchoice,loadingscreenchoice,tauntview,announcerview,musicchoice,cursorchoice,multikillchoice,emblemchoice,radcreepchoice,direcreepchoice
		Loop,parse,param,`,
		{
			if A_DefaultListView<>%A_LoopField%
			{
				Gui, MainGUI:ListView,%A_LoopField%
			}
			LV_Modify(0,"-check")
		}
		loop ; everlasting loop until encountering redundancy(errorlevel=1)
		{
			miscid:=VarRead("miscid" A_Index)
			GuiControl,Text,searchnofound, Preloading Miscellaneous ID: %miscid%
			miscidname:=VarRead("miscidname" A_Index)
			misclv:=VarRead("misclv" A_Index)
			;IniRead,miscid%A_Index%,%invfile%,Miscellaneous,miscid%A_Index%
			;IniRead,miscidname%A_Index%,%invfile%,Miscellaneous,miscidname%A_Index%
			;IniRead,misclv%A_Index%,%invfile%,Miscellaneous,misclv%A_Index%
			if A_DefaultListView<>% misclv
			{
				Gui, MainGUI:ListView,% misclv
			}
			GuiControl,-g,% misclv
			if (misclv="courierchoice") or (misclv="wardchoice") or (misclv="hudchoice") or (misclv="radcreepchoice") or (misclv="direcreepchoice")
			{
				;IniRead,miscstyle%A_Index%,%invfile%,Miscellaneous,miscstyle%A_Index%
				miscstyle:=VarRead("miscstyle" A_Index)
			}
			loop % LV_GetCount()
			{
				if misclv=announcerview
				{
					LV_GetText(tmp,A_Index,4)
				}
				else
				{
					LV_GetText(tmp,A_Index,3)
				}
				if miscid=%tmp%
				{
					LV_GetText(tmp,A_Index,1)
					if miscidname<>%tmp%
					{
						tmpbar:=newiddetector(miscidname) ;tmpbar:=newiddetector(miscidname,filestring) ; tmpstring:=item name , filestring:=items_game.txt
						if tmpbar<>
						{
							maperrorshow=% maperrorshow "Section: Miscellaneous:`nListview: " A_DefaultListView "`nName: " miscidname "`nRegistered ID: "  miscid "`nProblem: Name does not pair with the Registered ID!`nSolution: changing the Registered ID into " tmpbar "`nStatus: Solved! No need for Further User Action`n`n"
							miscid=%tmpbar%
						}
						else
						{
							maperrorshow=% maperrorshow "Section: Miscellaneous:`nListview: " A_DefaultListView "`nID: " miscid "Registered Name: " miscidname "`nProblem: ID has a different name!`nSolution: changing the registered name into " tmp "`nStatus: Solved! No need for Further User Action`n`n"
						}
					}
					if (misclv="courierchoice") or (misclv="wardchoice") or (misclv="hudchoice") or (misclv="radcreepchoice") or (misclv="direcreepchoice")
					{
						LV_GetText(checker,A_Index,4)
						if miscstyle<=%checker%
						{
							LV_Modify(A_Index,"Col5",miscstyle)
						}
					}
					LV_Modify(A_Index,"check")
					Break
				}
			}
			if (misclv="announcerview") or (misclv="tauntview")
			{
				GuiControl,% "+g" misclv,% misclv
			}
			else if (misclv="courierchoice") or (misclv="wardchoice") or (misclv="hudchoice") or (misclv="radcreepchoice") or (misclv="direcreepchoice")
			{
				GuiControl,+gmiscstyle,% misclv
			}
			else
			{
				GuiControl,+gbasicmisc,% misclv
			}
			If ErrorLevel=1 ;;; If the loop proves redundancy, terminate it
			{
				Break
			}
		}
		pet:=VarRead("pet")
		mappetstyle:=VarRead("mappetstyle")
		;IniRead,pet,%invfile%,Miscellaneous,pet
		;IniRead,mappetstyle,%invfile%,Miscellaneous,mappetstyle
		if pet<>1
		{
			pet=0
		}
		GuiControl,,peton,%pet%
		GuiControl,ChooseString,petstyle,%mappetstyle%
	}
	else ;;; if version 1(oldest version) the slowest one but the most accurate one
	{
		fileread,tmp,%invfile%
		loop
		{
			checker=miscid%A_Index%
			if InStr(tmp,checker)
			{
				count=%A_Index%
			}
			else
			{
				Break
			}
			If ErrorLevel=1
			{
				Break
			}
		}
		param=terrainchoice,weatherchoice,hudchoice,courierchoice,wardchoice,loadingscreenchoice,tauntview,announcerview,musicchoice,cursorchoice,multikillchoice,emblemchoice,radcreepchoice,direcreepchoice
		Loop,parse,param,`,
		{
			if A_DefaultListView<>%A_LoopField%
			{
				Gui, MainGUI:ListView,%A_LoopField%
			}
			LV_Modify(0,"-check")
		}
		loop %count%
		{
			IniRead,miscid%A_Index%,%invfile%,Miscellaneous,miscid%A_Index%
			IniRead,miscidname%A_Index%,%invfile%,Miscellaneous,miscidname%A_Index%
			GuiControl,Text,searchnofound,% "Preloading Miscellaneous ID: " miscid%A_Index%
			IniRead,misclv%A_Index%,%invfile%,Miscellaneous,misclv%A_Index%
			if A_DefaultListView<>% misclv%A_Index%
			{
				Gui, MainGUI:ListView,% misclv%A_Index%
			}
			GuiControl,-g,% misclv%A_Index%
			if (misclv%A_Index%="courierchoice") or (misclv%A_Index%="wardchoice") or (misclv%A_Index%="hudchoice") or (misclv%A_Index%="radcreepchoice") or (misclv%A_Index%="direcreepchoice")
			{
				IniRead,miscstyle%A_Index%,%invfile%,Miscellaneous,miscstyle%A_Index%
			}
			intsaver=%A_Index%
			loop % LV_GetCount()
			{
				if misclv%intsaver%=announcerview
				{
					LV_GetText(tmp,A_Index,4)
				}
				else
				{
					LV_GetText(tmp,A_Index,3)
				}
				if miscid%intsaver%=%tmp%
				{
					LV_GetText(tmp,A_Index,1)
					if miscidname%intsaver%<>%tmp%
					{
						tmpstring:=miscidname%intsaver%
						tmpbar:=newiddetector(tmpstring) ;tmpbar:=newiddetector(tmpstring,filestring) ; tmpstring:=item name , filestring:=items_game.txt
						if tmpbar<>
						{
							maperrorshow=% maperrorshow "Section: Miscellaneous:`nListview: " A_DefaultListView "`nName: " miscidname%intsaver% "`nRegistered ID: "  miscid%intsaver% "`nProblem: Name does not pair with the Registered ID!`nSolution: changing the Registered ID into " tmpbar "`nStatus: Solved! No need for Further User Action`n`n"
							miscid%intsaver%=%tmpbar%
							IniWrite,%tmpbar%,%invfile%,Miscellaneous,miscid%intsaver%
						}
						else
						{
							maperrorshow=% maperrorshow "Section: Miscellaneous:`nListview: " A_DefaultListView "`nID: " miscid%intsaver% "Registered Name: " miscidname%intsaver% "`nProblem: ID has a different name!`nSolution: changing the registered name into " tmp "`nStatus: Solved! No need for Further User Action`n`n"
						}
					}
					if (misclv%intsaver%="courierchoice") or (misclv%intsaver%="wardchoice") or (misclv%intsaver%="hudchoice") or (misclv%intsaver%="radcreepchoice") or (misclv%intsaver%="direcreepchoice")
					{
						LV_GetText(checker,A_Index,4)
						if miscstyle%intsaver%<=%checker%
						{
							LV_Modify(A_Index,"Col5",miscstyle%intsaver%)
						}
					}
					LV_Modify(A_Index,"check")
					Break
				}
			}
			if (misclv%intsaver%="announcerview") or (misclv%intsaver%="tauntview")
			{
				GuiControl,% "+g" misclv%A_Index%,% misclv%A_Index%
			}
			else if (misclv%intsaver%="courierchoice") or (misclv%intsaver%="wardchoice") or (misclv%intsaver%="hudchoice") or (misclv%intsaver%="radcreepchoice") or (misclv%intsaver%="direcreepchoice")
			{
				GuiControl,+gmiscstyle,% misclv%A_Index%
			}
			else
			{
				GuiControl,+gbasicmisc,% misclv%A_Index%
			}
		}
		IniRead,pet,%invfile%,Miscellaneous,pet
		IniRead,mappetstyle,%invfile%,Miscellaneous,mappetstyle
		if pet<>1
		{
			pet=0
		}
		GuiControl,,peton,%pet%
		GuiControl,ChooseString,petstyle,%mappetstyle%
	}
	GuiControl,+cDefault,searchnofound
	GuiControl,MainGUI:Text,searchnofound,%defaultshoutout%
	GuiControl,Text,errorshow,%maperrorshow%
	Gui,MainGUI:Submit,NoHide
	if errorshow<>
	{
		msgbox,16,ERROR DETECTED!,Preloading Database Complete! But There are ERRORS Detected and the Injector Distinguished them All. Check the "Advance" Section to view the ERROR Report and How the Injector Dealt them.
	}
	
	Gui, MainGUI:-Disabled 
}

savemisc:
param=terrainchoice,weatherchoice,hudchoice,loadingscreenchoice,tauntview,announcerview,courierchoice,wardchoice,musicchoice,cursorchoice,multikillchoice,emblemchoice,radcreepchoice,direcreepchoice
gosub,hideprogress
count:=0
if MyObject.FileTypeIndex=1
{
	loop,parse,param,`,
	{
		if A_DefaultListView<>%A_LoopField%
		{
			Gui, MainGUI:ListView,%A_LoopField%
		}
		saver=%A_LoopField%
		intsaver=%A_Index%
		if LV_GetNext(,"Checked")>0
		{
			Loop % LV_GetCount()
			{
				if (A_Index=LV_GetNext(A_Index-1,"Checked"))
				{
					if intsaver=6
					{
						LV_GetText(tmp,A_Index,4)
					}
					else
					{
						LV_GetText(tmp,A_Index,3)
					}
					count+=1
					
					IniWrite, %tmp%, %invfile%, Miscellaneous, miscid%count%
					
					GuiControl,Text,searchnofound,Saving Miscellaneous ID: %tmp%
					
					IniWrite, %saver%, %invfile%, Miscellaneous, misclv%count%
					
					if (intsaver=7) or (intsaver=8) or (intsaver=3)
					{
						LV_GetText(tmp,A_Index,5)
						
						IniWrite, %tmp%, %invfile%, Miscellaneous, miscstyle%count%
						
					}
					LV_GetText(tmp,A_Index,1)
					
					IniWrite, %tmp%, %invfile%, Miscellaneous, miscidname%count%
					
				}
			}
		}
	}
	
	IniWrite,%peton%, %invfile%, Miscellaneous, pet
	IniWrite,%petstyle%, %invfile%, Miscellaneous, mappetstyle
}
else if MyObject.FileTypeIndex=2
{	
	loop,parse,param,`,
	{
		if A_DefaultListView<>%A_LoopField%
		{
			Gui, MainGUI:ListView,%A_LoopField%
		}
		saver=%A_LoopField%
		intsaver=%A_Index%
		if LV_GetNext(,"Checked")>0
		{
			Loop % LV_GetCount()
			{
				if (A_Index=LV_GetNext(A_Index-1,"Checked"))
				{
					if intsaver=6
					{
						LV_GetText(tmp,A_Index,4)
					}
					else
					{
						LV_GetText(tmp,A_Index,3)
					}
					count+=1
					
					VarWrite("miscid" count,tmp)	;VarWrite(Key := "", Value := "")
					
					GuiControl,Text,searchnofound,Saving Miscellaneous ID: %tmp%
					
					VarWrite("misclv" count,saver)	;VarWrite(Key := "", Value := "")
					
					if (intsaver=7) or (intsaver=8) or (intsaver=3)
					{
						LV_GetText(tmp,A_Index,5)
						
						VarWrite("miscstyle" count,tmp)	;VarWrite(Key := "", Value := "")
						
					}
					LV_GetText(tmp,A_Index,1)
					
					VarWrite("miscidname" count,tmp)	;VarWrite(Key := "", Value := "")
					
				}
			}
		}
	}
	
	VarWrite("pet",peton)	;VarWrite(Key := "", Value := "")
	VarWrite("mappetstyle",petstyle)	;VarWrite(Key := "", Value := "")
}

return

hdatasave:
gosub,leakdestroyer
Gui, MainGUI:Submit, NoHide
Gui, MainGUI:Default
if A_DefaultListView<>itemview
{
	Gui, MainGUI:ListView, itemview
}
if LV_GetCount()=0
{
	GuiControl,MainGUI:Text,searchnofound,%defaultshoutout%
	gosub,hideprogress
	
	return
}
Gui, MainGUI:+Disabled 
;FileSelectFile,invfile,S24,,Name your Database and Specify where to Save,Handy Injection Database (*.aldrin_dota2hidb)

;;; SaveFile Returns two index on an object:
;;; File			-	the inputted filename
;;; FileTypeIndex	-	the chosen Filter(Files of type dropdownlist of the explorer gui)... This will Return the number of row of the selected filetype extension
MyObject := SaveFile( [0, "Name your Database and Specify where to Save"]    ; [owner, title/prompt]
             , ""    ; RootDir\Filename
             , {"Handy Injection Database Version 1": "*.aldrin_dota2hidb","Handy Injection Database Version 2 (EXPERIMENTAL)": "*.aldrin_dota2hidb"}     ; Filter
			 , 1	 ; Chosen Row at Filter Dropdownlist. Take note that the arrangement IS SORTED FIRST at the beggining, so after the arrangement of filter was sorted it will next choose the "2nd" row.
             , ""    ; CustomPlaces
             , 2)    ; Options ( 2 = FOS_OVERWRITEPROMPT )
invfile := MyObject.File

if invfile<>
{
	Gui, MainGUI:Show
	If SubStr(invfile,-16,17)<>.aldrin_dota2hidb
	{
		invfile=%invfile%.aldrin_dota2hidb
	}
	IfExist,%invfile%
	{
		FileDelete, %invfile%
	}
	
	if MyObject.FileTypeIndex=1
	{
		;;;;; the old method
		adder:=1000/LV_GetCount()
		progress=0
		gosub,showprogress
		FileAppend,,%invfile%
		hRegisteredDirectory=0
		Loop % LV_GetCount()
		{
			hRegisteredDirectory+=1
			LV_GetText(mapinvfilehk,A_Index,4)
			LV_GetText(mapItemStyle,A_Index,7)
			IniWrite, %mapinvfilehk%, %invfile%, Edits, ItemID%A_Index%
			IniWrite, %mapItemStyle%, %invfile%, Edits, ItemStyle%A_Index%
			LV_GetText(tmp,A_Index,1)
			IniWrite, %tmp%, %invfile%, Edits, ItemIDName%A_Index%
			LV_GetText(tmp,A_Index,5)
			IniWrite, %tmp%, %invfile%, Edits, ItemHeroUser%A_Index%
			progress+=adder
			GuiControl,MainGUI:, MyProgress,%progress%
		}
		IniWrite, %hRegisteredDirectory%, %invfile%, Edits, hRegisteredDirectory
		
		if usemiscon=1
		{
			GoSub,savemisc
			VarWrite( ) ; blanks Function Static "Var" variable! Always start Writing in a blank variable, avoiding Rewritings (Faster) 
			VarWrite("@DataBaseVersion!",MyObject.FileTypeIndex)	;VarWrite(Key := "", Value := "") ; Saves the Database Version for future version detection
			FileAppend,% VarWrite( , "GetVar"),%invfile%  ;"VarWrite( ,"GetVar")" function returns the text that will be stored in the file choosed by user, the first parameter must be omitted or blank
		}
	}
	else if MyObject.FileTypeIndex=2
	{
		LVSData:=ListViewSave()
		
		if usemiscon=1
		{
			VarWrite( ) ; blanks Function Static "Var" variable! Always start Writing in a blank variable, avoiding Rewritings (Faster) 
			GoSub,savemisc
			VarWrite("@DataBaseVersion!",MyObject.FileTypeIndex)	;VarWrite(Key := "", Value := "") ; Saves the Database Version for future version detection
			LVSData.=VarWrite( , "GetVar") ;"VarWrite( ,"GetVar")" function returns the text that will be stored in the file choosed by user, the first parameter must be omitted or blank
		}
		FileAppend,% LVSData,% invfile
	}
	if soundon=1
	{
		SoundPlay,%A_Temp%\Sound\savedatacomplete.wav
	}
}
GuiControl,MainGUI:Text,searchnofound,%defaultshoutout%
; gosub,hideprogress
Gui, MainGUI:-Disabled 
return

heroportrait:
porthero:=npcherodetector(porthero,dota2dir "\game\dota\scripts\npc\npc_heroes.txt")
StringGetPos, portpos, porthero,`r`n%A_Tab%%A_Tab%"Model"
StringGetPos, portpos1, porthero,",L3,%portpos%
StringGetPos, portpos, porthero,",L2,%portpos1%
StringMid,porttmp,porthero,% portpos1+2, % portpos-portpos1-1
gosub,execportrait
return

execportrait:
if InStr(portstring,porttmp)<1
{
	porttmp1=%porttmp%
	tmp1=%filecontent%
	tmp2=%itemname%
	filecontent=%contentport%
	itemname:=searchstringdetector(filecontent,"""used_by_heroes""") ; detects the hero who uses the item
	porthero=%itemname%
	filecontent=%tmp1%
	itemname=%tmp2%
	fileread,npchero,%dota2dir%\game\dota\scripts\npc\npc_heroes.txt
	StringGetPos, portpos, npchero,`r`n%A_Tab%"%porthero% ;"
	StringGetPos, portpos1, npchero,`r`n%A_Tab%},,%portpos%
	StringMid,porthero,npchero,% portpos+1, % portpos1-portpos-1
	StringGetPos, portpos, porthero,`r`n%A_Tab%%A_Tab%"Model"
	StringGetPos, portpos1, porthero,",L3,%portpos%
	StringGetPos, portpos, porthero,",L2,%portpos1%
	StringMid,porttmp,porthero,% portpos1+2, % portpos-portpos1-1
	
	StringGetPos, portpos2, portstring,%porttmp%
	StringGetPos, portpos1, portstring,`r`n%A_Tab%},,%portpos2%
	StringGetPos, portpos, portstring,`r`n%A_Tab%",R1,% StrLen(portstring)-portpos1
	StringGetPos, portpos1, portstring,},,%portpos1%
	StringMid,tmp1,portstring,% portpos+1, % portpos1-portpos+1
	StringReplace,tmp2,tmp1,%porttmp%,%porttmp1%,1
	StringReplace,portstring,portstring,%tmp1%,%tmp1%%tmp2%,1
}
StringGetPos, portpos, contentport,%portfind%
StringGetPos, portpos1, contentport,",L2,%portpos%
StringGetPos, portpos, contentport,`r`n%A_Tab%%A_Tab%%A_Tab%%A_Tab%},,%portpos1%
StringGetPos, portpos, contentport,},,%portpos%
StringMid,toportcontent1,contentport,% portpos1+2, % portpos-portpos1

StringGetPos, portpos2, portstring,%porttmp%
StringGetPos, portpos1, portstring,`r`n%A_Tab%{`r`n,,%portpos2%
StringGetPos, portpos, portstring,`r`n%A_Tab%},,%portpos1%
StringGetPos, portpos, portstring,},,%portpos%
StringMid,fromportcontent1,portstring,% portpos1+1, % portpos-portpos1+1
StringMid,fromportcontent,portstring,% portpos2+1, % portpos-portpos2+1
StringReplace,toportcontent,fromportcontent,%fromportcontent1%,%toportcontent1%,1

StringReplace,portstring,portstring,%fromportcontent%,%toportcontent%,1
return

hselectinject:
gosub,leakdestroyer
Gui, MainGUI:Submit, NoHide
Gui, MainGUI:Default
if A_DefaultListView<>itemview
{
	Gui, MainGUI:ListView, itemview
}
ifnotexist,%A_ScriptDir%\Library\items_game.txt
{
	msgbox,16,Error!!!,"%A_ScriptDir%\Library\items_game.txt"`n`nIs Missing!!! Make sure to add the original "items_game.txt" at "%A_ScriptDir%\Library" Folder.`n`nIf you dont have an Idea how to get the original "items_game.txt" use "GCFScape.exe" or "Valve's Resource Viewer" application to access "Pak01_dir.vpk". Inside the VPK Archive`,Hit "Ctrl+F"(Find) and search for "items_game.txt". If successfully found`, extract it(items_game.txt) at "%A_ScriptDir%\Library\" Folder.
	return
}
repmocount:=repparcount:=0
ifexist,%A_ScriptDir%\Plugins\ReportLog.aldrin_report
{
	FileDelete,%A_ScriptDir%\Plugins\ReportLog.aldrin_report
}
fileappend,**This Report can be sent to the Creator of the Injector that can be useful for investigation about your current Injection**`r`nReportLog Location Path:`r`n%A_ScriptDir%\ReportLog.aldrin_report,%A_ScriptDir%\Plugins\ReportLog.aldrin_report
writer=
commanddir=
commandextract=
commandrename=
rptlimit=
commandloop=0
ifexist,%A_ScriptDir%\Plugins\VPKCreator\pak01_dir\
{
	GuiControl,MainGUI:Text,searchnofound,Deleting pak01_dir Folder.
	FileRemoveDir,%A_ScriptDir%\Plugins\VPKCreator\pak01_dir,1
}
FileCreateDir,%A_ScriptDir%\Plugins\VPKCreator\pak01_dir\
FileRead,masterfilecontent,%A_ScriptDir%\Library\items_game.txt
;FileRead,filestring2,%A_ScriptDir%\Library\items_game.txt
filestring2:=masterfilecontent
FileRead,portstring,%A_ScriptDir%\Library\portraits.txt
StringLen,filelength,filestring2
GuiControl,Text,errorshow,
maperrorshow=
Gui, MainGUI:+Disabled 
if LV_GetCount()=0
{
	if usemiscon=1
	{
		Goto,hinjectjump
	}
	else
	{
		GuiControl,MainGUI:Text,searchnofound,%defaultshoutout%
		gosub,hideprogress
		msgbox,16,Empty Task to be Injected,No "ID's" detected on the list!
		Gui, MainGUI:-Disabled 
		return
	}
}
adder:=1000/LV_GetCount()
if soundon=1
{
	soundint:=LV_GetCount()
	gosub,initsound
}
progress:=0,IPS:=StartTimer:=A_TickCount
gosub,showprogress
;LV_ModifyCol(4,"Sort Integer") ; this increases the speed when finding the items... Type of strategy, lowest id number >>> highest id number
LV_ModifyCol(4,"SortDesc Integer") ; this increases the speed when finding the items... Type of strategy, highest id number >>> lowest id number
Loop % LV_GetCount()
{
	progress+=adder
	if soundon=1
	{
		if (progress>=250) and (soundswitch1=0) and (sound25=1)
		{
			soundswitch1=1
			SoundPlay,%A_Temp%\Sound\25.wav
		}
		else if (progress>=350) and (soundswitch2=0) and (sound25=1)
		{
			soundswitch2=1
			SoundPlay,%A_Temp%\Sound\35.wav
		}
		else if (progress>=500) and (soundswitch3=0) and (sound25=1)
		{
			soundswitch3=1
			SoundPlay,%A_Temp%\Sound\50.wav
		}
		else if (progress>=650) and (soundswitch4=0) and (sound25=1)
		{
			soundswitch4=1
			SoundPlay,%A_Temp%\Sound\65.wav
		}
		else if (progress>=750) and (soundswitch5=0) and (sound25=1)
		{
			soundswitch5=1
			SoundPlay,%A_Temp%\Sound\75.wav
		}
	}
	GuiControl,MainGUI:, MyProgress,%progress%
	skip=0
	LV_GetText(itemslotcheck,A_Index,2)
	LV_GetText(string1,A_Index,4)
	LV_GetText(herousercheck,A_Index,5)
	herousercheck=npc_dota_hero_%herousercheck%
	tmpstring=%string1%
	filecontent:=itemdetector(tmpstring) ;filecontent:=itemdetector(tmpstring,filestring)
	LV_GetText(numcheck,A_Index,6)
	LV_GetText(stylechecker,A_Index,7)
	contentport=%filecontent%
	gosub,extractmodel
	porthero=%herousercheck%
	if stylechecker>0
	{
		filecontent:=stylechanger(stylechecker,filecontent) ;stylechanger will change the style of all particle effects and even the model
	}
	else
	{
		StringReplace,filecontent,filecontent,`r`n%A_Tab%%A_Tab%%A_Tab%%A_Tab%%A_Tab%"style"%A_Tab%%A_Tab%"0",,1
	}
	stringcontent1=%filecontent%
	if stringcontent1=
	{
		maperrorshow=%maperrorshow%Cannot Find ID number "string1"!(Resource ID)`n
		skip=1
	}
	else if InStr(stringcontent1,"prefab")=0
	{
		maperrorshow=%maperrorshow%ID number "string1" was found but sadly it is not an "ITEM"!(Resource ID)`n
		skip=1
	}
	tmp=%A_Tab%%A_Tab%%A_Tab%"model_player ;"
	tmp:=StrReplace(stringcontent1,tmp,tmp,modelplayercount)
	loop %modelplayercount%
	{
		modelloop:=A_Index-1
		itemname:=modelpathdetector(filecontent,modelloop) ;detect the item root directory and change all slash into backslash
		itemname=%itemname%_c
		extractfile%A_Index%=%itemname%
		StringGetPos,pos,itemname,\,R1
		StringTrimLeft,extractname%A_Index%,itemname,% pos+1
	}
	StringReplace,stringcontent1,stringcontent1,"prefab"%A_Tab%%A_Tab%"wearable","prefab"%A_Tab%%A_Tab%"default_item",1
	Finder=%A_Tab%%A_Tab%%A_Tab%"used_by_heroes"`r`n%A_Tab%%A_Tab%%A_Tab%{`r`n%A_Tab%%A_Tab%%A_Tab%%A_Tab%"%herousercheck%"%A_Tab%%A_Tab%"1"`r`n%A_Tab%%A_Tab%%A_Tab%}
	defaultslotfinder=%A_Tab%%A_Tab%%A_Tab%"prefab"%A_Tab%%A_Tab%"default_item"
	Barrier=%A_Tab%%A_Tab%}`r`n%A_Tab%%A_Tab%" ;"
	Loop
	{
		
		
		StringGetPos, pos, filestring2,%Finder%,L%A_Index%
		;rightpos:=filelength-pos
		;StringGetPos, pos1, filestring2,%Barrier%,,%pos%
		;StringGetPos, pos2, filestring2,%Barrier%,R1,%rightpos%
		;pos3:=pos1-pos2
		;StringMid,filecontent,filestring2,%pos2%,%pos3%
		
		filecontent:=keyworddetector(pos) ;filecontent:=keyworddetector(pos,filestring2)
		
		if InStr(filecontent,defaultslotfinder)<>0
		{
			itemname:=searchstringdetector(filecontent,"""item_slot""") ; detects the hero body slot of the item
			if itemname=%itemslotcheck%
			{
				tmpbar:=iddetector(filecontent) ;filecontent := extracted content from items_game.txt
				string2=%tmpbar%
				if filecontent=
				{
					maperrorshow=%maperrorshow%Cannot Find ID number "string2"!(Injected ID)`n
					skip=1
				}
				else if InStr(filecontent,"prefab")=0
				{
					maperrorshow=%maperrorshow%ID number "string2" was found but sadly it is not an "ITEM"!(Injected ID)`n
					skip=1
				}
				if skip=1
				{
					continue
				}
				portfind=`r`n%A_Tab%%A_Tab%%A_Tab%%A_Tab%"game"`r`n%A_Tab%%A_Tab%%A_Tab%%A_Tab%{
				if InStr(stringcontent1,portfind)>0
				{
					contentport=%stringcontent1%
					gosub,heroportrait
				}
				StringReplace,stringcontent1,stringcontent1,%string1%,%string2%,1
				StringReplace,masterfilecontent,masterfilecontent,%filecontent%,%stringcontent1%,1
				; measures the number of items injected per second
				Gui,MainGUI:Show, NoActivate,% floor(1000/(A_TickCount-IPS)) " Items per Second"
				IPS:=A_TickCount
				;
				
				tmp=%A_Tab%%A_Tab%%A_Tab%"model_player ;"
				tmp:=StrReplace(filecontent,tmp,tmp,modelplayercount)
				loop %modelplayercount%
				{
					extractfile:=extractfile%A_Index%
					extractname:=extractname%A_Index%
					modelloop:=A_Index-1
					itemname:=modelpathdetector(filecontent,modelloop) ;detect the item root directory and change all slash into backslash
					itemname=%itemname%_c
					StringLen,varlength,itemname
					StringGetPos,pos,itemname,\,R1
					StringTrimLeft,defaultname,itemname,% pos+1
					StringTrimRight,defaultloc,itemname,% varlength-pos
					if (defaultloc<>"") and (defaultname<>"")
					{
						ifnotExist,%A_ScriptDir%\Plugins\VPKCreator\pak01_dir\%defaultloc%
						{
							commanddir=md "%A_ScriptDir%\Plugins\VPKCreator\pak01_dir\%defaultloc%"`r`n
						}
						commandextract="%variablehllib%" -p "%dota2dir%\game\dota\pak01_dir.vpk" -d "%A_ScriptDir%\Plugins\VPKCreator\pak01_dir\%defaultloc%" -e "root\%extractfile%"`r`n
						commandrename=rename "%A_ScriptDir%\Plugins\VPKCreator\pak01_dir\%defaultloc%\%extractname%" "%defaultname%"`r`n
						commandloop+=1
						ifexist,%A_ScriptDir%\Plugins\VPKCreator\extract%commandloop%.bat
						{
							FileDelete,%A_ScriptDir%\Plugins\VPKCreator\extract%commandloop%.bat
						}
						fileappend,%commanddir%%commandextract%%commandrename%del `%0,%A_ScriptDir%\Plugins\VPKCreator\extract%commandloop%.bat
						; measures the number of items injected per second
						Gui,MainGUI:Show, NoActivate,% floor(1000/(A_TickCount-IPS)) " Items per Second"
						IPS:=A_TickCount
						;
						if lowprocessor=0
						{
							loop
							{
								run,"%A_ScriptDir%\Plugins\VPKCreator\extract%commandloop%.bat",,Hide UseErrorLevel,extract%commandloop%
								if (ErrorLevel<>ERROR) and (A_LastError=0) ;;  if the run is successful
									break ;; terminate the loop
								;; if the there was an error, rerun the batch file
							}
							
							;run,"%A_ScriptDir%\Plugins\VPKCreator\extract%commandloop%.bat",,Hide UseErrorLevel,extract%commandloop%
						}
						else
						{
							loop
							{
								runwait,"%A_ScriptDir%\Plugins\VPKCreator\extract%commandloop%.bat",,Hide UseErrorLevel,extract%commandloop%
								if (ErrorLevel<>ERROR) and (A_LastError=0) ;;  if the run is successful
									break ;; terminate the loop
								;; if the there was an error, rerun the batch file
							}
							
							;runwait,"%A_ScriptDir%\Plugins\VPKCreator\extract%commandloop%.bat",,Hide UseErrorLevel,extract%commandloop%
						}
					}
				}
				Break
			}
		}
		If ErrorLevel=1
		{
			Break
		}
	}
}
if masterfilecontent=%filestring2%
{
	GuiControl,MainGUI:Text,searchnofound,%defaultshoutout%
	Gui,MainGUI:Show, NoActivate,AJOM's Dota 2 MOD Master
	gosub,hideprogress
	
	msgbox,16,Empty Task to be Injected,No present actived/valid "ID's" detected on the list!
	Gui, MainGUI:-Disabled 
	if soundon=1
	{
		SoundPlay,%A_Temp%\Sound\finishederror.wav
	}
	return
}
hinjectjump:
gosub,hideprogress
if usemiscon=1
{
	GoSub,execmisc
}
GuiControl,Text,errorshow,%maperrorshow%
if autovpkon=0
{
	GoSub,movepak
}
else
{
	GoSub,createvpk
}
Gui,MainGUI:Submit,NoHide

IniWrite,% A_TickCount-StartTimer,%A_ScriptDir%\Plugins\ReportLog.aldrin_report,TotalOperationTime
FileMove,%A_ScriptDir%\Plugins\ReportLog.aldrin_report,%A_ScriptDir%\,1
fileread,tmp1,%A_ScriptDir%\ReportLog.aldrin_report

GuiControl,Text,reportshow,%tmp1%
if errorshow<>
{
	if soundon=1
	{
		SoundPlay,%A_Temp%\Sound\finishederror.wav
	}
	msgbox,16,ERROR DETECTED!,Injection Complete! But There are ERRORS Detected and the Injector Distinguished them All. Check the "Advance" Section to view the ERROR Report and How the Injector Dealt them.
}
else
{
	if soundon=1
	{
		SoundPlay,%A_Temp%\Sound\OperationFinished.wav
	}
}
GuiControl,MainGUI:Text,searchnofound,%defaultshoutout%
Gui,MainGUI:Show, NoActivate,AJOM's Dota 2 MOD Master
Gui, MainGUI:-Disabled 
return

doitems:
Critical
if A_GuiEvent = RightClick
{
	Gui, MainGUI:Default
	if A_DefaultListView<>showitems
	{
		Gui, MainGUI:ListView, showitems
	}
	loop 5
	{
		LV_GetText(del%A_Index%,A_EventInfo,A_Index)
	}
	LV_GetText(stylescount,A_EventInfo,6)
	LV_GetText(countcheck,A_EventInfo,7)
	if stylescount>%countcheck%
	{
		countcheck+=1
	}
	else
	{
		countcheck=0
	}
	LV_Modify(A_EventInfo,"Select" "Col7",,,,,,,countcheck)
	if A_DefaultListView<>itemview
	{
		Gui, MainGUI:ListView, itemview
	}
	loop % LV_GetCount()
	{
		delint=%A_Index%
		loop 5
		{
			LV_GetText(del1%A_Index%,delint,A_Index)
		}
		if del11=%del1%
		{
			if del12=%del2%
			{
				if del13=%del3%
				{
					if del14=%del4%
					{
						if del15=%del5%
						{
							LV_Modify(A_Index,"Select" "Col7",,,,,,,countcheck)
						}
					}
				}
			}
		}
	}
}
if InStr(ErrorLevel, "C", true)
{
	Gui, MainGUI:Default
	if A_DefaultListView<>showitems
	{
		Gui, MainGUI:ListView, showitems
	}
	LV_GetText(itemat1,A_EventInfo,2)
	Loop % LV_GetCount()
	{
		if A_DefaultListView<>showitems
		{
			Gui, MainGUI:ListView, showitems
		}
		if A_Index<>%A_EventInfo%
		{
			if A_Index= % LV_GetNext(A_Index-1,"Checked")
			{
				LV_GetText(itemat,A_Index,2)
				if itemat1=%itemat%
				{
					LV_Modify(A_Index,"-Check")
					delsaver=%A_Index%
					GoSub,autoshowitemsdelete
				}
			}
		}
	}
	if A_DefaultListView<>showitems
	{
		Gui, MainGUI:ListView, showitems
	}
	loop 7
	{
		LV_GetText(itemat%A_Index%,A_EventInfo,A_Index)
	}
	if A_DefaultListView<>itemview
	{
		Gui, MainGUI:ListView, itemview
	}
	LV_Add(, itemat1,itemat2,itemat3,itemat4,itemat5,itemat6,itemat7)
	GoSub,lvautosize
	LV_ModifyCol(2,"Sort")
}
else if InStr(ErrorLevel, "c", true)
{
	delsaver=%A_EventInfo%
	GoSub,autoshowitemsdelete
}
return

autoshowitemsdelete:
Gui, MainGUI:Default
if A_DefaultListView<>showitems
{
	Gui, MainGUI:ListView, showitems
}
loop 5
{
	LV_GetText(del%A_Index%,delsaver,A_Index)
}
if A_DefaultListView<>itemview
{
	Gui, MainGUI:ListView, itemview
}
loop % LV_GetCount()
{
	delint=%A_Index%
	loop 5
	{
		LV_GetText(del1%A_Index%,delint,A_Index)
	}
	if del11=%del1%
	{
		if del12=%del2%
		{
			if del13=%del3%
			{
				if del14=%del4%
				{
					if del15=%del5%
					{
						LV_Delete(delint)
					}
				}
			}
		}
	}
}
return

hdatabrowse: ;;;When user clicks browse database at handy injection section
Gui MainGUI:+OwnDialogs
gosub,leakdestroyer
FileSelectFile,invfile,3,,.aldrin_dota2hidb,*.aldrin_dota2hidb
If SubStr(invfile,-16,17)=.aldrin_dota2hidb
{
	timeconsumed:=A_TickCount
	GuiControl,Text,hdatadirview,%invfile%||
	Gui,MainGUI:Submit,NoHide
	Gui, MainGUI:Default
	if A_DefaultListView<>itemview
	{
		Gui, MainGUI:ListView,itemview
	}
	LV_Delete()
	maperrorshow=
	GuiControl,Text,errorshow,
	hdatareload(hdatadirview)
	checkdetector() ; check any field that exist on the listview "itemview"
	if usemiscon=1 ; use miscellaneous section on future injection is checked, reload all misc resources
	{
		reloadmisc(invfile) ; ;Scans the database then put a checkmark on each miscellaneous it uses
	}
	
	Gui,MainGUI:Show, NoActivate,% (A_TickCount-timeconsumed)/1000 "s Preloading Time"
	GuiControl,MainGUI:Text,searchnofound,%defaultshoutout%
	SetTimer,restorguititle,-5000,-1
	
	
	if soundon=1
	{
		SoundPlay,%A_Temp%\Sound\loaddatacomplete.wav
	}
}
return

restorguititle: ;;; Restore the Title of the GUI into the default one
Gui,MainGUI:Show, NoActivate,AJOM's Dota 2 MOD Master
return

;;; hdatareload function will preload the database of handy injection section listview
hdatareload(hdatadirview) {
	Gui, MainGUI:Default
	Gui, MainGUI:+Disabled 
	GuiControl,MainGUI:Hide,searchnofound
	if A_DefaultListView<>itemview
	{
		Gui, MainGUI:ListView, itemview
	}
	GuiControl, MainGUI:-Redraw, itemview
	FileRead,FileData,%hdatadirview%
	VarRead(,FileData) ; remember the contents of the variable and store to "static Var" that is inspected by varread
	if VarRead("@DataBaseVersion!")=2
	{
		VarRead(,ListViewLoad(FileData))	;the function loads the table and automatically returns Extra text found from the loaded file (Extra text found will be stored in "ExtraTextReturned" variable) and stores it at "static var" of varread
		
		;;; detects if the listview header was corrupted
		headercorrupted:=0
		param=Item Name|Item Slot|Rarity|Item ID|Used by|Styles Count|Active Style
		loop,parse,param,|
		{
			LV_GetText(tmp,0,A_Index)
			if tmp<>%A_LoopField%
			{
				LV_ModifyCol(A_Index,"AutoHdr",A_LoopField)
				maperrorshow=% maperrorshow "Section: Handy Injection`nSub-Section: Used Items Database`nControl: Listview`nColumn: " A_Index "`nRegistered Header Name: " tmp "`nProblem: DATABASE MIGHT BE CORRUPTED!!! The Database's Column " A_Index " Header Name does not match with the ListView Header Name. The Results on the Listview might show SCRAMBLED Informations on each rows that does not match on their specific Columns.`nStatus: UNKNOWN! DOTA2 MOD Master did not include this cosmetic item on the list.`nSolution: At ""Hero Items Selection"" Subsection, track down the cosmetic item and recheck that information.`n`n"
				headercorrupted=1 ; tell the system that the listview header was corrupted
			}
		}
		if headercorrupted>=1
		{
			gosub,VerifyListviewIntegrity ;if the listview header is corrupted, automatically verify the informations. 
		}
		else
		{
			;SetTimer,timedverinteg,-1,-500 ; low priority integrity verification
			;gosub,dummy
		}
		;;;
	}
	else ;;; if version 1(oldest version) the slowest one but the most accurate one
	{
		if InStr(FileData,"hRegisteredDirectory")
		{
			IniRead,hRegisteredDirectory,%hdatadirview%,Edits,hRegisteredDirectory
		}
		else
		{
			hRegisteredDirectory=0
			Loop
			{
				tmp1=ItemID%A_Index%
				if InStr(FileData,tmp1)
				{
					hRegisteredDirectory=%A_Index%
				}
				else
				{
					IniWrite,%hRegisteredDirectory%,%hdatadirview%,Edits,hRegisteredDirectory
					Break
				}
			}
		}
		adder:=1000/hRegisteredDirectory
		gosub,showprogress
		progress=0
		FileRead,filestring,%A_ScriptDir%\Library\items_game.txt
		Loop, %hRegisteredDirectory%
		{
			IniRead,ItemID%A_Index%,%hdatadirview%,Edits,ItemID%A_Index%
			IniRead,ItemIDName%A_Index%,%hdatadirview%,Edits,ItemIDName%A_Index%
			IniRead,ItemStyle%A_Index%,%hdatadirview%,Edits,ItemStyle%A_Index%
			mapinjectfrom:=ItemID%A_Index%
			checker=
			varlength=
			zeroloop=
			StringLen,varlength,mapinjectfrom
			Loop, %varlength%
			{
				zeroloop=0%zeroloop%
				StringLeft,checker,mapinjectfrom,%A_Index%
				if checker=%zeroloop%
				{
					StringTrimLeft,mapinjectfrom,mapinjectfrom,%A_Index%
				}
			}
			tmpstring:=ItemID%A_Index%
			filecontent:=itemdetector(tmpstring) ;filecontent:=itemdetector(tmpstring,filestring)
			if filecontent=
			{
				tmpstring:=ItemIDName%A_Index%
				tmpbar:=newiddetector(tmpstring) ;tmpbar:=newiddetector(tmpstring,filestring) ; tmpstring:=item name , filestring:=items_game.txt
				IniRead,ItemHeroUser%A_Index%,%hdatadirview%,Edits,ItemHeroUser%A_Index%
				if tmpbar<>
				{
					maperrorshow=% maperrorshow "Section: Handy Injection`nHero: " ItemHeroUser%A_Index% "`nRegistered Item Name: " ItemIDName%A_Index% "`nRegistered ID: " ItemID%A_Index% "`nCurrent Style: " ItemStyle%A_Index% "`nProblem: Registered ID does not exist! But the Registered Name was found.`nSolution: Analyzing the Registered Name information at items_game.txt, FOUND ID " tmpbar ".`nStatus: Solved! DOTA2 MOD Master Changed the Registered ID into " tmpbar ", No need for Further User Action.`n`n"
					ItemID%A_Index%=%tmpbar%
					IniWrite,%tmpbar%,%hdatadirview%,Edits,ItemID%A_Index%
					GuiControl,Text,errorshow,%maperrorshow%
				}
				else
				{
					maperrorshow=% maperrorshow "Section: Handy Injection`nHero: " ItemHeroUser%A_Index% "`nRegistered ID: " ItemID%A_Index% "`nRegistered Item Name: " ItemIDName%A_Index% "`nCurrent Style: " ItemStyle%A_Index% "`nProblem: Registered ID nor the Registered Name for the Hero does not Exist! It might not be a valid item that has prefab and a Hero User`nStatus: UNSOLVED! DOTA2 MOD Master did not include this cosmetic item on the list.`nSolution: At ""Hero Items Selection"" Subsection, track down the cosmetic item and recheck that information.`n`n"
					GuiControl,Text,errorshow,%maperrorshow%
					continue
				}
			}
			itemname:=searchstringdetector(filecontent,"""name""") ; detects the name of the item
			if ItemIDName%A_Index%<>%itemname%
			{
				tmpstring:=ItemIDName%A_Index%
				tmpbar:=newiddetector(tmpstring) ;tmpbar:=newiddetector(tmpstring,filestring) ; tmpstring:=item name , filestring:=items_game.txt
				IniRead,ItemHeroUser%A_Index%,%hdatadirview%,Edits,ItemHeroUser%A_Index%
				if tmpbar<>
				{
					maperrorshow=% maperrorshow "Section: Handy Injection`nHero: " ItemHeroUser%A_Index% "`nRegistered Item Name: " ItemIDName%A_Index% "`nRegistered ID: " ItemID%A_Index% "`nCurrent Style: " ItemStyle%A_Index% "`nProblem: Hero Item Name Of the Registered ID from items_game.txt does not pair with the Database's Registered Item Name of the Hero`nSolution: Using the Hero User and the Item Name, Identify the item ID of this item. Found " tmpbar ".`nStatus: Solved! DOTA2 MOD Master Changed the Registered ID into " tmpbar ", No need for Further User Action.`n`n"
					ItemID%A_Index%=%tmpbar%
					IniWrite,%tmpbar%,%hdatadirview%,Edits,ItemID%A_Index%
					GuiControl,Text,errorshow,%maperrorshow%
				}
				else
				{
					maperrorshow=% maperrorshow "Section: Handy Injection`nHero: " ItemHeroUser%A_Index% "`nRegistered Item Name: " ItemIDName%A_Index% "`nRegistered ID: " ItemID%A_Index% "`nProblem: Registered ID for the Hero has a different cosmetic name at items_game.txt, it was does not match the Database's Registered Item Name`nSolution: Changing the Registered Name into " itemname ".`nStatus: Solved! No need for Further User Action`n`n"
					IniWrite,%itemname%,%hdatadirview%,Edits,ItemIDName%A_Index%
					GuiControl,Text,errorshow,%maperrorshow%
				}
			}
			tmpname1:=searchstringdetector(filecontent,"""name"""),tmpname2:=searchstringdetector(filecontent,"""item_slot"""),tmpname3:=searchstringdetector(filecontent,"""item_rarity"""),tmpname4:=searchstringdetector(filecontent,"""used_by_heroes""")
			StringTrimLeft, tmpname4, tmpname4, 14
			stylescount:=stylecountdetector(filecontent) ;counts the number of allowed styles of an item
			LV_Add(, tmpname1, tmpname2,tmpname3,ItemID%A_Index%,tmpname4,stylescount,ItemStyle%A_Index%)
			LV_ModifyCol(5,"Sort")
			GoSub,lvautosize
			progress+=adder
			GuiControl,MainGUI:, MyProgress,%progress%
		}
		gosub,hideprogress
	}
	GuiControl,MainGUI:Show,searchnofound
	GuiControl, MainGUI:+Redraw, itemview
	Gui,MainGUI:Submit,NoHide
	if errorshow<>
	{
		msgbox,16,ERROR DETECTED!,Preloading Database Complete! But There are ERRORS Detected and the Injector Distinguished them All. Check the "Advance" Section to view the ERROR Report and How the Injector Dealt them.
	}
	
	Gui, MainGUI:-Disabled
	
	return
	
	
}

dummy:
msgbox here %A_DefaultListView%
SetTimer,timedverinteg,-1,-500 ; low priority integrity verification
return

timedverinteg: ; indicates that the function is low priority timer
if A_DefaultListView<>itemview
{
	Gui, MainGUI:ListView, itemview
}
msgbox shit %A_DefaultListView%
timedverinteg()
return

timedverinteg() {
adder:=1000/LV_GetCount(),progress:=0
gosub,showprogress
FileRead,filestring,%A_ScriptDir%\Library\items_game.txt
DataArray:={} ; decalares that the property of this array is associative 
if A_DefaultListView<>itemview
{
	Gui, MainGUI:ListView, itemview
}
Loop % LV_GetCount() ; constructs the data array
{
	LV_GetText(ItemIDName,A_Index,1),LV_GetText(ItemID,A_Index,4),LV_GetText(ItemHeroUser,A_Index,5)
	DataArray[ItemIDName%A_Index%]:=ItemIDName,DataArray[ItemID%A_Index%]:=ItemID,DataArray[ItemHeroUser%A_Index%]:=ItemHeroUser
}
;do not attempt to merge the above loop to below loop
msgbox % LV_GetCount()
loop % LV_GetCount()
{
	NewItemID:="" ; start the detection for new item ID as blank, so that if later it was changed, the switch detection that the ID was changed will be true
	filecontent:=itemdetector(DataArray[ItemID%A_Index%]) ;filecontent:=itemdetector(ItemID,filestring)
	if filecontent=
	{
		tmpbar:=newiddetector(DataArray[ItemIDName%A_Index%]) ;tmpbar:=newiddetector(DataArray[ItemIDName%A_Index%],filestring) ; tmpstring:=item name , filestring:=items_game.txt
		if tmpbar<>
		{
			maperrorshow=% maperrorshow "Section: Handy Injection`nHero: " DataArray[ItemHeroUser%A_Index%] "`nRegistered Item Name: " DataArray[ItemIDName%A_Index%] "`nRegistered ID: " DataArray[ItemID%A_Index%] "`nCurrent Style: " ItemStyle "`nProblem: Registered ID does not exist! But the Registered Name was found.`nSolution: Analyzing the Registered Name information at items_game.txt, FOUND ID " tmpbar ".`nStatus: Solved! DOTA2 MOD Master Changed the Registered ID into " tmpbar ", No need for Further User Action.`n`n"
			NewItemID=%tmpbar%
		}
		else
		{
			maperrorshow=% maperrorshow "Section: Handy Injection`nHero: " DataArray[ItemHeroUser%A_Index%] "`nRegistered ID: " DataArray[ItemID%A_Index%] "`nRegistered Item Name: " DataArray[ItemIDName%A_Index%] "`nCurrent Style: " ItemStyle "`nProblem: Registered ID nor the Registered Name for the Hero does not Exist! It might not be a valid item that has prefab and a Hero User`nStatus: UNSOLVED! DOTA2 MOD Master did not include this cosmetic item on the list.`nSolution: At ""Hero Items Selection"" Subsection, track down the cosmetic item and recheck that information.`n`n"
			continue
		}
	}
	itemname:=searchstringdetector(filecontent,"""name""") ; detects the name of the item
	if DataArray[ItemIDName%A_Index%]<>%itemname%
	{
		tmpbar:=newiddetector(DataArray[ItemIDName%A_Index%]) ;tmpbar:=newiddetector(DataArray[ItemIDName%A_Index%],filestring) ; tmpstring:=item name , filestring:=items_game.txt
		if tmpbar<>
		{
			maperrorshow=% maperrorshow "Section: Handy Injection`nHero: " DataArray[ItemHeroUser%A_Index%] "`nRegistered Item Name: " DataArray[ItemIDName%A_Index%] "`nRegistered ID: " DataArray[ItemID%A_Index%] "`nCurrent Style: " ItemStyle "`nProblem: Hero Item Name Of the Registered ID from items_game.txt does not pair with the Database's Registered Item Name of the Hero`nSolution: Using the Hero User and the Item Name, Identify the item ID of this item. Found " tmpbar ".`nStatus: Solved! DOTA2 MOD Master Changed the Registered ID into " tmpbar ", No need for Further User Action.`n`n"
			NewItemID=%tmpbar%
		}
		else
		{
			maperrorshow=% maperrorshow "Section: Handy Injection`nHero: " DataArray[ItemHeroUser%A_Index%] "`nRegistered Item Name: " DataArray[ItemIDName%A_Index%] "`nRegistered ID: " DataArray[ItemID%A_Index%] "`nProblem: Registered ID for the Hero has a different cosmetic name at items_game.txt, it was does not match the Database's Registered Item Name`nSolution: Changing the Registered Name into " itemname ".`nStatus: Solved! No need for Further User Action`n`n"
		}
	}
	if NewItemID= ; there is no problem on the cosmetic item
	{
		NewItemID:=DataArray[ItemID%A_Index%]
	}
	tmpname1:=searchstringdetector(filecontent,"""name"""),tmpname2:=searchstringdetector(filecontent,"""item_slot"""),tmpname3:=searchstringdetector(filecontent,"""item_rarity"""),tmpname4:=searchstringdetector(filecontent,"""used_by_heroes""") ; define its field which are informations for the user for the listview
	StringTrimLeft, tmpname4, tmpname4, 14 ; remove "npc_dota_hero_"(14 characters on the left side)
	stylescount:=stylecountdetector(filecontent) ;counts the number of allowed styles of an item
	if (DataArray[ItemIDName%A_Index%]<>tmpname1) or (ItemSlot<>tmpname2) or (ItemRarity<>tmpname3) or (DataArray[ItemID%A_Index%]<>NewItemID) or (tmpname4<>DataArray[ItemHeroUser%A_Index%]) or (stylescount<>ItemCountStyle) ; detects when there was an error on the any informations on the listview
	{
		if A_DefaultListView<>itemview
		{
			Gui, MainGUI:ListView, itemview
		}
		LV_Modify(A_Index,, tmpname1, tmpname2,tmpname3,NewItemID,tmpname4,stylescount,ItemStyle) ; update informations on our listview
	}
	progress+=adder
	GuiControl,MainGUI:, MyProgress,%progress%
}
msgbox finish
LV_ModifyCol(5,"Sort") ; sorts the column 5 which is "hero user" column into a - z - A - Z - 0 - 9 - special chars
GoSub,lvautosize ; Fit all contents of the 7 columns including the header
GuiControl,Text,errorshow,%maperrorshow%
gosub,hideprogress
}

VerifyListviewIntegrity:
Gui, MainGUI:Default
Gui, MainGUI:+Disabled 
GuiControl,MainGUI:Hide,searchnofound
if A_DefaultListView<>itemview
{
	Gui, MainGUI:ListView, itemview
}
GuiControl, MainGUI:-Redraw, itemview
GuiControl,MainGUI:Text,searchnofound,
Gui,MainGUI:Submit,NoHide
VerifyListviewIntegrity()
GuiControl,MainGUI:Text,searchnofound,%defaultshoutout%
GuiControl,MainGUI:Show,searchnofound
GuiControl, MainGUI:+Redraw, itemview
Gui, MainGUI:-Disabled
return

VerifyListviewIntegrity() {
adder:=1000/LV_GetCount(),progress:=0
gosub,showprogress
FileRead,filestring,%A_ScriptDir%\Library\items_game.txt
Loop % LV_GetCount()
{
	LV_GetText(ItemIDName,A_Index,1),LV_GetText(ItemSlot,A_Index,2),LV_GetText(ItemRarity,A_Index,3),LV_GetText(ItemID,A_Index,4),LV_GetText(ItemHeroUser,A_Index,5),LV_GetText(ItemCountStyle,A_Index,6),LV_GetText(ItemStyle,A_Index,7)
	NewItemID:="" ; start the detection for new item ID as blank, so that if later it was changed, the switch detection that the ID was changed will be true
	filecontent:=itemdetector(ItemID) ;filecontent:=itemdetector(ItemID,filestring)
	if filecontent=
	{
		tmpbar:=newiddetector(ItemIDName) ;tmpbar:=newiddetector(ItemIDName,filestring) ; tmpstring:=item name , filestring:=items_game.txt
		if tmpbar<>
		{
			maperrorshow=% maperrorshow "Section: Handy Injection`nHero: " ItemHeroUser "`nRegistered Item Name: " ItemIDName "`nRegistered ID: " ItemID "`nCurrent Style: " ItemStyle "`nProblem: Registered ID does not exist! But the Registered Name was found.`nSolution: Analyzing the Registered Name information at items_game.txt, FOUND ID " tmpbar ".`nStatus: Solved! DOTA2 MOD Master Changed the Registered ID into " tmpbar ", No need for Further User Action.`n`n"
			NewItemID=%tmpbar%
		}
		else
		{
			maperrorshow=% maperrorshow "Section: Handy Injection`nHero: " ItemHeroUser "`nRegistered ID: " ItemID "`nRegistered Item Name: " ItemIDName "`nCurrent Style: " ItemStyle "`nProblem: Registered ID nor the Registered Name for the Hero does not Exist! It might not be a valid item that has prefab and a Hero User`nStatus: UNSOLVED! DOTA2 MOD Master did not include this cosmetic item on the list.`nSolution: At ""Hero Items Selection"" Subsection, track down the cosmetic item and recheck that information.`n`n"
			continue
		}
	}
	itemname:=searchstringdetector(filecontent,"""name""") ; detects the name of the item
	if ItemIDName<>%itemname%
	{
		tmpbar:=newiddetector(ItemIDName) ;tmpbar:=newiddetector(ItemIDName,filestring) ; tmpstring:=item name , filestring:=items_game.txt
		if tmpbar<>
		{
			maperrorshow=% maperrorshow "Section: Handy Injection`nHero: " ItemHeroUser "`nRegistered Item Name: " ItemIDName "`nRegistered ID: " ItemID "`nCurrent Style: " ItemStyle "`nProblem: Hero Item Name Of the Registered ID from items_game.txt does not pair with the Database's Registered Item Name of the Hero`nSolution: Using the Hero User and the Item Name, Identify the item ID of this item. Found " tmpbar ".`nStatus: Solved! DOTA2 MOD Master Changed the Registered ID into " tmpbar ", No need for Further User Action.`n`n"
			NewItemID=%tmpbar%
		}
		else
		{
			maperrorshow=% maperrorshow "Section: Handy Injection`nHero: " ItemHeroUser "`nRegistered Item Name: " ItemIDName "`nRegistered ID: " ItemID "`nProblem: Registered ID for the Hero has a different cosmetic name at items_game.txt, it was does not match the Database's Registered Item Name`nSolution: Changing the Registered Name into " itemname ".`nStatus: Solved! No need for Further User Action`n`n"
		}
	}
	if NewItemID= ; there is no problem on the cosmetic item
	{
		NewItemID:=ItemID
	}
	tmpname1:=searchstringdetector(filecontent,"""name"""),tmpname2:=searchstringdetector(filecontent,"""item_slot"""),tmpname3:=searchstringdetector(filecontent,"""item_rarity"""),tmpname4:=searchstringdetector(filecontent,"""used_by_heroes""") ; define its field which are informations for the user for the listview
	StringTrimLeft, tmpname4, tmpname4, 14 ; remove "npc_dota_hero_"(14 characters on the left side)
	stylescount:=stylecountdetector(filecontent) ;counts the number of allowed styles of an item
	if (ItemIDName<>tmpname1) or (ItemSlot<>tmpname2) or (ItemRarity<>tmpname3) or (ItemID<>NewItemID) or (tmpname4<>ItemHeroUser) or (stylescount<>ItemCountStyle) ; detects when there was an error on the any informations on the listview
	{
		LV_Modify(A_Index,, tmpname1, tmpname2,tmpname3,NewItemID,tmpname4,stylescount,ItemStyle) ; update informations on our listview
	}
	progress+=adder
	GuiControl,MainGUI:, MyProgress,%progress%
}
LV_ModifyCol(5,"Sort") ; sorts the column 5 which is "hero user" column into a - z - A - Z - 0 - 9 - special chars
GoSub,lvautosize ; Fit all contents of the 7 columns including the header
GuiControl,Text,errorshow,%maperrorshow%
gosub,hideprogress
}

generateheroitems:
Gui, MainGUI:+Disabled 
Gui, MainGUI:Submit, NoHide
Gui, MainGUI:Default
if A_DefaultListView<>showitems
{
	Gui, MainGUI:ListView, showitems
}
GuiControl, MainGUI:-Redraw, showitems
LV_Delete()
FileRead,filestring,%A_ScriptDir%\Library\items_game.txt
StringLen, filelength, filestring
sfinder=`r`n%A_Tab%%A_Tab%}`r`n%A_Tab%%A_Tab%" ;"
StringTrimLeft, tmp, mapherochoice, 5
animcount=0
itemcount=0
GuiControl,-g, showitems
GuiControl,+cBlue,searchnofound
loop,parse,tmp,|
{
	herouiname=npc_dota_hero_%A_LoopField%
	herorealname=%A_LoopField%
	htarget=%A_Tab%%A_Tab%%A_Tab%"used_by_heroes"`r`n%A_Tab%%A_Tab%%A_Tab%{`r`n%A_Tab%%A_Tab%%A_Tab%%A_Tab%"%herouiname%"%A_Tab%%A_Tab%"1"`r`n%A_Tab%%A_Tab%%A_Tab%}
	filter=%A_Tab%%A_Tab%%A_Tab%"prefab"%A_Tab%%A_Tab%"wearable"
	if herochoice=%herorealname%
	{
		Loop
		{
			StringGetPos, ipos, filestring,%htarget%,L%A_Index%
			rightpos:=filelength-ipos
			StringGetPos, ipos1, filestring,%sfinder%,,%ipos%
			StringGetPos, ipos2, filestring,%sfinder%,R1,%rightpos%
			startpos:=ipos2+8
			ipos3:=ipos1-ipos2
			StringMid,filecontent,filestring,%startpos%,%ipos3%
			if InStr(filecontent,filter)>0
			{
				if herochoice=None
				{
					Break
				}
				else 
				{
					itemname:=searchstringdetector(filecontent,"""name""") ; detects the name of the item
					hitemname=%itemname%
					itemname:=searchstringdetector(filecontent,"""item_slot""") ; detects the hero body slot of the item
					hitemslot=%itemname%
					tmpbar:=iddetector(filecontent) ;filecontent := extracted content from items_game.txt
					hitemid=%tmpbar%
					itemname:=searchstringdetector(filecontent,"""item_rarity""") ; detects the item's rarity
					hitemrarity=%itemname%
					stylescount:=stylecountdetector(filecontent) ;counts the number of allowed styles of an item
					LV_Add(,hitemname,hitemslot,hitemrarity,hitemid,herorealname,stylescount,"0")
					GoSub,lvautosize
					LV_ModifyCol(2,"Sort")
					itemcount+=1
					animcount+=1
					animdot=%animdot%.
					GuiControl,Text,searchnofound,%itemcount% Items Found for "%herouiname%"! Please Stand By%animdot%
					if animcount=30
					{
						animcount=0
						animdot=
					}
				}
			}
			if ErrorLevel=1
			{
				Break
			}
		}
	}
	else
	{
		continue
	}
}
checkdetector() ; check any field that exist on the listview "itemview"
GuiControl,+cDefault,searchnofound
GuiControl,Text,searchnofound,%defaultshoutout%
GuiControl, MainGUI:+Redraw, showitems
Gui, MainGUI:-Disabled 
return

herochoice:
Gui, MainGUI:Submit, NoHide
if lastherochoice=%herochoice%
{
	return
}
else if A_GuiEvent=DoubleClick
{
	lastherochoice=%herochoice%
	gosub,generateheroitems
}
return

selectinject:
gosub,leakdestroyer
Gui, MainGUI:Submit, NoHide
Gui, MainGUI:Default
if A_DefaultListView<>invlv
{
	Gui, MainGUI:ListView, invlv
}
ifnotexist,%A_ScriptDir%\Library\items_game.txt
{
	msgbox,16,Error!!!,"%A_ScriptDir%\Library\items_game.txt"`n`nIs Missing!!! Make sure to add the original "items_game.txt" at "%A_ScriptDir%\Library" Folder.`n`nIf you dont have an Idea how to get the original "items_game.txt" use "GCFScape.exe" or "Valve's Resource Viewer" application to access "Pak01_dir.vpk". Inside the VPK Archive`,Hit "Ctrl+F"(Find) and search for "items_game.txt". If successfully found`, extract it(items_game.txt) at "%A_ScriptDir%\Library\" Folder.
	return
}
FileRead,masterfilecontent,%A_ScriptDir%\Library\items_game.txt
FileRead,filestring2,%A_ScriptDir%\Library\items_game.txt
FileRead,portstring,%A_ScriptDir%\Library\portraits.txt
if ucron=1
{
	FileRead,filestring1,%invdirview%
}
else
{
	FileRead,filestring1,%A_ScriptDir%\Library\items_game.txt
}
GuiControl,Text,errorshow,
maperrorshow=
Gui, MainGUI:+Disabled 
if LV_GetCount()=0
{
	if usemiscon=1
	{
		Goto,injectjump
	}
	else
	{
		GuiControl,MainGUI:Text,searchnofound,%defaultshoutout%
		gosub,hideprogress
		
		msgbox,16,Empty Task to be Injected,No "ID's" detected on the list!
		Gui, MainGUI:-Disabled 
		return
	}
}
repmocount:=repparcount:=0
ifexist,%A_ScriptDir%\Plugins\ReportLog.aldrin_report
{
	FileDelete,%A_ScriptDir%\Plugins\ReportLog.aldrin_report
}
fileappend,**This Report can be sent to the Creator of the Injector that can be useful for investigation about your current Injection**`r`nReportLog Location Path:`r`n%A_ScriptDir%\ReportLog.aldrin_report,%A_ScriptDir%\Plugins\ReportLog.aldrin_report
writer=
commanddir=
commandextract=
commandrename=
rptlimit=
commandloop=0
ifexist,%A_ScriptDir%\Plugins\VPKCreator\pak01_dir\
{
	GuiControl,MainGUI:Text,searchnofound,Deleting pak01_dir Folder.
	FileRemoveDir,%A_ScriptDir%\Plugins\VPKCreator\pak01_dir,1
}
FileCreateDir,%A_ScriptDir%\Plugins\VPKCreator\pak01_dir\
adder:=1000/LV_GetCount()
if soundon=1
{
	soundint:=LV_GetCount()
	gosub,initsound
}
progress:=0,IPS:=StartTimer:=A_TickCount
gosub,showprogress
Loop % LV_GetCount()
{
	progress+=adder
	if soundon=1
	{
		if (progress>=250) and (soundswitch1=0) and (sound25=1)
		{
			soundswitch1=1
			SoundPlay,%A_Temp%\Sound\25.wav
		}
		else if (progress>=350) and (soundswitch2=0) and (sound25=1)
		{
			soundswitch2=1
			SoundPlay,%A_Temp%\Sound\35.wav
		}
		else if (progress>=500) and (soundswitch3=0) and (sound25=1)
		{
			soundswitch3=1
			SoundPlay,%A_Temp%\Sound\50.wav
		}
		else if (progress>=650) and (soundswitch4=0) and (sound25=1)
		{
			soundswitch4=1
			SoundPlay,%A_Temp%\Sound\65.wav
		}
		else if (progress>=750) and (soundswitch5=0) and (sound25=1)
		{
			soundswitch5=1
			SoundPlay,%A_Temp%\Sound\75.wav
		}
	}
	GuiControl,MainGUI:, MyProgress,%progress%
	if ( A_Index = LV_GetNext(A_Index-1,"Checked"))
	{
		skip=0
		LV_GetText(string1,A_Index,1)
		LV_GetText(string2,A_Index,2)
		tmpstring=%string1%
		filecontent:=itemdetector(tmpstring) ;filecontent:=itemdetector(tmpstring,filestring)
		LV_GetText(numcheck,A_Index,5)
		LV_GetText(stylechecker,A_Index,6)
		itemname:=searchstringdetector(filecontent,"""used_by_heroes""") ; detects the hero who uses the item
		contentport=%filecontent%
		gosub,extractmodel
		porthero=%itemname%
		if stylechecker>0
		{
			filecontent:=stylechanger(stylechecker,filecontent) ;stylechanger will change the style of all particle effects and even the model
		}
		else
		{
			StringReplace,filecontent,filecontent,`r`n%A_Tab%%A_Tab%%A_Tab%%A_Tab%%A_Tab%"style"%A_Tab%%A_Tab%"0",,1
		}
		stringcontent1=%filecontent%
		if stringcontent1=
		{
			maperrorshow=%maperrorshow%Cannot Find ID number "string1"!(Resource ID)`n
			skip=1
		}
		else if InStr(stringcontent1,"prefab")=0
		{
			maperrorshow=%maperrorshow%ID number "string1" was found but sadly it is not an "ITEM"!(Resource ID)`n
			skip=1
		}
		tmp=%A_Tab%%A_Tab%%A_Tab%"model_player ;"
		tmp:=StrReplace(stringcontent1,tmp,tmp,modelplayercount)
		loop %modelplayercount%
		{
			modelloop:=A_Index-1
			itemname:=modelpathdetector(filecontent,modelloop) ;detect the item root directory and change all slash into backslash
			itemname=%itemname%_c
			extractfile%A_Index%=%itemname%
			StringLen,varlength,itemname
			StringGetPos,pos,itemname,\,R1
			StringTrimLeft,extractname%A_Index%,itemname,% pos+1
		}
		StringReplace,stringcontent1,stringcontent1,"prefab"%A_Tab%%A_Tab%"wearable","prefab"%A_Tab%%A_Tab%"default_item",1
		StringReplace,stringcontent1,stringcontent1,%string1%,%string2%,1
		tmpstring=%string2%
		filecontent:=itemdetector(tmpstring) ;filecontent:=itemdetector(tmpstring,filestring)
		if filecontent=
		{
			maperrorshow=%maperrorshow%Cannot Find ID number "string2"!(Injected ID)`n
			skip=1
		}
		else if InStr(filecontent,"prefab")=0
		{
			maperrorshow=%maperrorshow%ID number "string2" was found but sadly it is not an "ITEM"!(Injected ID)`n
			skip=1
		}
		if skip=1
		{
			continue
		}
		StringReplace,masterfilecontent,masterfilecontent,%filecontent%,%stringcontent1%,1
		; measures the number of items injected per second
		Gui,MainGUI:Show, NoActivate,% floor(1000/(A_TickCount-IPS)) " Items per Second"
		IPS:=A_TickCount
		;
		portfind=`r`n%A_Tab%%A_Tab%%A_Tab%%A_Tab%"game"`r`n%A_Tab%%A_Tab%%A_Tab%%A_Tab%{
		if InStr(stringcontent1,portfind)>0
		{
			contentport=%stringcontent1%
			gosub,heroportrait
		}
		tmp=%A_Tab%%A_Tab%%A_Tab%"model_player ;"
		tmp:=StrReplace(stringcontent1,tmp,tmp,modelplayercount)
		loop %modelplayercount%
		{
			extractname:=extractname%A_Index%
			extractfile:=extractfile%A_Index%
			modelloop:=A_Index-1
			itemname:=modelpathdetector(filecontent,modelloop) ;detect the item root directory and change all slash into backslash
			itemname=%itemname%_c
			StringLen,varlength,itemname
			StringGetPos,pos,itemname,\,R1
			StringTrimLeft,defaultname,itemname,% pos+1
			StringTrimRight,defaultloc,itemname,% varlength-pos
			if (defaultloc<>"") and (defaultname<>"")
			{
				ifnotExist,%A_ScriptDir%\Plugins\VPKCreator\pak01_dir\%defaultloc%
				{
					commanddir=md "%A_ScriptDir%\Plugins\VPKCreator\pak01_dir\%defaultloc%"`r`n
				}
				commandextract="%variablehllib%" -p "%dota2dir%\game\dota\pak01_dir.vpk" -d "%A_ScriptDir%\Plugins\VPKCreator\pak01_dir\%defaultloc%" -e "root\%extractfile%"`r`n
				commandrename=rename "%A_ScriptDir%\Plugins\VPKCreator\pak01_dir\%defaultloc%\%extractname%" "%defaultname%"`r`n
				if lowprocessor=0
				{
					commandloop+=1
					ifexist,%A_ScriptDir%\Plugins\VPKCreator\extract%commandloop%.bat
					{
						FileDelete,%A_ScriptDir%\Plugins\VPKCreator\extract%commandloop%.bat
					}
					fileappend,%commanddir%%commandextract%%commandrename%del `%0,%A_ScriptDir%\Plugins\VPKCreator\extract%commandloop%.bat
					; measures the number of items injected per second
					Gui,MainGUI:Show, NoActivate,% floor(1000/(A_TickCount-IPS)) " Items per Second"
					IPS:=A_TickCount
					;
					if lowprocessor=0
					{
						loop
						{
							run,"%A_ScriptDir%\Plugins\VPKCreator\extract%commandloop%.bat",,Hide UseErrorLevel,extract%commandloop%
							if (ErrorLevel<>ERROR) and (A_LastError=0) ;;  if the run is successful
								break ;; terminate the loop
							;; if the there was an error, rerun the batch file
						}
						
						;run,"%A_ScriptDir%\Plugins\VPKCreator\extract%commandloop%.bat",,Hide UseErrorLevel,extract%commandloop%
					}
					else
					{
						loop
						{
							runwait,"%A_ScriptDir%\Plugins\VPKCreator\extract%commandloop%.bat",,Hide UseErrorLevel,extract%commandloop%
							if (ErrorLevel<>ERROR) and (A_LastError=0) ;;  if the run is successful
								break ;; terminate the loop
							;; if the there was an error, rerun the batch file
						}
						
						;runwait,"%A_ScriptDir%\Plugins\VPKCreator\extract%commandloop%.bat",,Hide UseErrorLevel,extract%commandloop%
					}
				}
				else
				{
					fileappend,%commanddir%%commandextract%%commandrename%,%A_ScriptDir%\Plugins\VPKCreator\extract%commandloop%.bat
				}
			}
		}
	}
}
if masterfilecontent=%filestring%
{
	GuiControl,MainGUI:Text,searchnofound,%defaultshoutout%
	Gui,MainGUI:Show, NoActivate,AJOM's Dota 2 MOD Master
	gosub,hideprogress
	if soundon=1
	{
		SoundPlay,%A_Temp%\Sound\finishederror.wav
	}
	msgbox,16,Empty Task to be Injected,No present actived/valid "ID's" detected on the list!
	Gui, MainGUI:-Disabled 
	return
}
injectjump:
gosub,hideprogress
if usemiscon=1
{
	GoSub,execmisc
}
GuiControl,Text,errorshow,%maperrorshow%
if autovpkon=0
{
	GoSub,movepak
}
else
{
	GoSub,createvpk
}
Gui,MainGUI:Submit,NoHide

IniWrite,% A_TickCount-StartTimer,%A_ScriptDir%\Plugins\ReportLog.aldrin_report,TotalOperationTime
FileMove,%A_ScriptDir%\Plugins\ReportLog.aldrin_report,%A_ScriptDir%\,1
fileread,tmp1,%A_ScriptDir%\ReportLog.aldrin_report

GuiControl,Text,reportshow,%tmp1%
if errorshow<>
{
	if soundon=1
	{
		SoundPlay,%A_Temp%\Sound\finishederror.wav
	}
	msgbox,16,ERROR DETECTED!,Injection Complete! But There are ERRORS Detected and the Injector Distinguished them All. Check the "Advance" Section to view the ERROR Report and How the Injector Dealt them.
}
else
{
	if soundon=1
	{
		SoundPlay,%A_Temp%\Sound\OperationFinished.wav
	}
}
GuiControl,MainGUI:Text,searchnofound,%defaultshoutout%
Gui,MainGUI:Show, NoActivate,AJOM's Dota 2 MOD Master
Gui, MainGUI:-Disabled 
return

selectsave:
gosub,leakdestroyer
Gui, MainGUI:Submit, NoHide
GoSub,default_settings
param=ucr,mapinvdirview,mapdatadirview,maphdatadirview,mapmdirview,pet,autovpk,usemisc,mappetstyle,mapgiloc,maplowprocessor,mapdota2dir,soundon,useextportraitfile,useextfile,useextitemgamefile,fastmisc,showtooltips
param1=%ucron%,%invdirview%,%datadirview%,%hdatadirview%,%mdirview%,%peton%,%autovpkon%,%usemiscon%,%petstyle%,%giloc%,%lowprocessor%,%dota2dir%,%soundon%,%useextportraitfile%,%useextfile%,%useextitemgamefile%,%fastmisc%,%showtooltips%
Loop,parse,param,`,
{
	tmpstring=%A_LoopField%
	tmpint=%A_Index%
	Loop,parse,param1,`,
	{
		if tmpint=%A_Index%
		{
			IniWrite,%A_LoopField%, %A_ScriptDir%\Settings.aldrin_dota2mod, Edits,%tmpstring%
			Break
		}
	}
}
if A_DefaultListView<>extfilelist
{
	Gui, MainGUI:ListView, extfilelist
}
IniRead,tmpint, %A_ScriptDir%\Settings.aldrin_dota2mod,External_Files,CountExternalFolder,0
Loop %tmpint%
{
	IniDelete,%A_ScriptDir%\Settings.aldrin_dota2mod,External_Files,ExternalFolder%A_Index%
	IniDelete,%A_ScriptDir%\Settings.aldrin_dota2mod,External_Files,ExternalFolder%A_Index%Enabled
}
IniDelete,%A_ScriptDir%\Settings.aldrin_dota2mod,External_Files,CountExternalFolder
tmpint=0
Loop % LV_GetCount()
{
	tmpint+=1
	LV_GetText(tmpstring,A_Index ,7)
	IniWrite,%tmpstring% , %A_ScriptDir%\Settings.aldrin_dota2mod,External_Files,ExternalFolder%tmpint%
	if ( A_Index = LV_GetNext(A_Index-1,"Checked") )
	{
		IniWrite,+check, %A_ScriptDir%\Settings.aldrin_dota2mod,External_Files,ExternalFolder%tmpint%Enabled
	}
	else IniWrite,-check, %A_ScriptDir%\Settings.aldrin_dota2mod,External_Files,ExternalFolder%tmpint%Enabled
}
IniWrite,%tmpint% , %A_ScriptDir%\Settings.aldrin_dota2mod,External_Files,CountExternalFolder
return

invupdate:
Gui,MainGUI:Submit,NoHide
if injectfrom=
{
	return
}
else if injectto=
{
	return
}
Gui, MainGUI:Default
if A_DefaultListView<>invlv
{
	Gui, MainGUI:ListView, invlv
}
booleanexist=0
invstringhk:=injectfrom
checker=
varlength=
zeroloop=
StringLen,varlength,invstringhk
Loop, %varlength%
{
	zeroloop=0%zeroloop%
	StringLeft,checker,invstringhk,%A_Index%
	if checker=%zeroloop%
	{
		StringTrimLeft,invstringhk,invstringhk,%A_Index%
	}
}
checker=
varlength=
zeroloop=
StringLen,varlength,injectto
Loop, %varlength%
{
	zeroloop=0%zeroloop%
	StringLeft,checker,injectto,%A_Index%
	if checker=%zeroloop%
	{
		StringTrimLeft,injectto,injectto,%A_Index%
	}
}
Loop % LV_GetCount()
{
	LV_GetText(checker,A_Index ,2)
	if checker=%injectto%
	{
		LV_Modify(A_Index,"Select",invstringhk)
		booleanexist=1
		FileRead,filestring,%A_ScriptDir%\Library\items_game.txt
		tmpstring=%checker%
		filecontent:=itemdetector(tmpstring) ;filecontent:=itemdetector(tmpstring,filestring)
		if InStr(filecontent,"prefab")<1
		{
			return
		}
		itemname:=searchstringdetector(filecontent,"""name""") ; detects the name of the item
		LV_Modify(A_Index,"Col4",itemname)
		if ucron=1
		{
			FileRead,filestring,%invdirview%
		}
		else
		{
			FileRead,filestring,%A_ScriptDir%\Library\items_game.txt
		}
		LV_GetText(checker,A_Index ,1)
		tmpstring=%checker%
		filecontent:=itemdetector(tmpstring) ;filecontent:=itemdetector(tmpstring,filestring)
		if InStr(filecontent,"prefab")<1
		{
			return
		}
		itemname:=searchstringdetector(filecontent,"""name""") ; detects the name of the item
		LV_Modify(A_Index,"Col3",itemname)
		stylescount:=stylecountdetector(filecontent) ;counts the number of allowed styles of an item
		LV_Modify(A_Index,"Col5",stylescount)
		LV_Modify(A_Index,"Col6","0")
	}
}
if booleanexist=0
{
	FileRead,filestring,%A_ScriptDir%\Library\items_game.txt
	tmpstring=%injectto%
	filecontent:=itemdetector(tmpstring) ;filecontent:=itemdetector(tmpstring,filestring)
	if InStr(filecontent,"prefab")<1
	{
		return
	}
	itemname:=searchstringdetector(filecontent,"""name""") ; detects the name of the item
	tmpname2=%itemname%
	if ucron=1
	{
		FileRead,filestring,%invdirview%
	}
	else
	{
		FileRead,filestring,%A_ScriptDir%\Library\items_game.txt
	}
	tmpstring=%invstringhk%
	filecontent:=itemdetector(tmpstring) ;filecontent:=itemdetector(tmpstring,filestring)
	itemname:=searchstringdetector(filecontent,"""name""") ; detects the name of the item
	tmpname1=%itemname%
	stylescount:=stylecountdetector(filecontent) ;counts the number of allowed styles of an item
	LV_Add("Check", invstringhk, injectto,tmpname1,tmpname2,stylescount,"0")
}
GoSub,lvautosize
return

datareload:
Gui, MainGUI:Default
Gui, MainGUI:+Disabled 
if A_DefaultListView<>invlv
{
	Gui, MainGUI:ListView, invlv
}
GuiControl, MainGUI:-Redraw, invlv
FileRead,tmp,%datadirview%
if InStr(tmp,"RegisteredDirectory")
{
	IniRead,RegisteredDirectory,%datadirview%,Edits,RegisteredDirectory
}
else
{
	RegisteredDirectory=0
	Loop
	{
		tmp1=ItemID%A_Index%
		if InStr(tmp,tmp1)
		{
			RegisteredDirectory=%A_Index%
		}
		else
		{
			IniWrite,%RegisteredDirectory%,%datadirview%,Edits,RegisteredDirectory
			Break
		}
	}
}
adder:=1000/RegisteredDirectory
gosub,showprogress
progress=0
Loop, %RegisteredDirectory%
{
	IniRead,IDInjected%A_Index%,%datadirview%,Edits,IDInjected%A_Index%
	IniRead,ResourceID%A_Index%,%datadirview%,Edits,ResourceID%A_Index%
	IniRead,ActiveStyle%A_Index%,%datadirview%,Edits,ActiveStyle%A_Index%
	IniRead,ResourceID%A_Index%Enabled,%datadirview%,Edits,ResourceID%A_Index%Enabled
	IniRead,IDInjectedName%A_Index%,%datadirview%,Edits,IDInjectedName%A_Index%
	IniRead,ResourceIDName%A_Index%,%datadirview%,Edits,ResourceIDName%A_Index%
	mapinjectfrom:=ResourceID%A_Index%
	mapinjectto:=IDInjected%A_Index%
	invwaschecked:=ResourceID%A_Index%Enabled
	checker=
	varlength=
	zeroloop=
	StringLen,varlength,mapinjectfrom
	Loop, %varlength%
	{
		zeroloop=0%zeroloop%
		StringLeft,checker,mapinjectfrom,%A_Index%
		if checker=%zeroloop%
		{
			StringTrimLeft,mapinjectfrom,mapinjectfrom,%A_Index%
		}
	}
	checker=
	varlength=
	zeroloop=
	StringLen,varlength,mapinjectto
	Loop, %varlength%
	{
		zeroloop=0%zeroloop%
		StringLeft,checker,mapinjectto,%A_Index%
		if checker=%zeroloop%
		{
			StringTrimLeft,mapinjectto,mapinjectto,%A_Index%
		}
	}
	FileRead,filestring,%A_ScriptDir%\Library\items_game.txt
	tmpstring:=IDInjected%A_Index%
	filecontent:=itemdetector(tmpstring) ;filecontent:=itemdetector(tmpstring,filestring)
	if filecontent=
	{
		tmpstring:=IDInjectedName%A_Index%
		tmpbar:=newiddetector(tmpstring) ;tmpbar:=newiddetector(tmpstring,filestring) ; tmpstring:=item name , filestring:=items_game.txt
		if tmpbar<>
		{
			maperrorshow=% maperrorshow "Section: General`nInjected ID: " IDInjected%A_Index% "`nInjected Registered Item Name: " IDInjectedName%A_Index% "`nProblem: The ID Injected does not exist! on items_game.txt, but the Registered Item Name was Found/Existed.`nSolution: analyzing the contents of the Item Name found at items_game.txt, FOUND ID " tmpbar "`nStatus: Solved! DOTA2 MOD Master changed the ID Injected into " tmpbar ", No need for Further User Action.`n`n"
			IDInjected%A_Index%=%tmpbar%
			IniWrite,%tmpbar%,%datadirview%,Edits,IDInjected%A_Index%
			GuiControl,Text,errorshow,%maperrorshow%
		}
		else
		{
			maperrorshow=% maperrorshow "Section: General`nResource ID: " ResourceID%A_Index% "`nResource Registered Item Name: " ResourceIDName%A_Index% "`nInjected ID: "IDInjected%A_Index% "`nInjected Registered Item Name: " IDInjectedName%A_Index% "`nActived Style: " ActiveStyle%A_Index% "`nChecked: " ResourceID%A_Index%Enabled "`nProblem: ID Injected nor the Injected Registered Item Name does not Exist!`nStatus: UNSOLVED! The General Information about the ID Injected is corrupted, and will not be included on the listview.`nSolution: Use all the information above, track down and configure the injected ID properly.`n`n"
			GuiControl,Text,errorshow,%maperrorshow%
			continue
		}
	}
	itemname:=searchstringdetector(filecontent,"""name""") ; detects the name of the item
	if IDInjectedName%A_Index%<>%itemname%
	{
		tmpstring:=IDInjectedName%A_Index%
		tmpbar:=newiddetector(tmpstring) ;tmpbar:=newiddetector(tmpstring,filestring) ; tmpstring:=item name , filestring:=items_game.txt
		if tmpbar<>
		{
			maperrorshow=% maperrorshow "Section: General`nInjected ID: " IDInjected%A_Index% "`nInjected Registered Item Name: " IDInjectedName%A_Index% "`nProblem: Registered Item Name does not pair with the Injected ID!`nSolution: changing the ID into " tmpbar "`nStatus: Solved: No need for Further User Action.`n`n"
			GuiControl,Text,errorshow,%maperrorshow%
			IDInjected%A_Index%=%tmpbar%
			IniWrite,%tmpbar%,%datadirview%,Edits,IDInjected%A_Index%
			itemname:=searchstringdetector(filecontent,"""name""") ; detects the name of the item
		}
		else
		{
			maperrorshow=% maperrorshow "Section: General`nInjected ID: " IDInjected%A_Index% "`nInjected Registered Item Name: " IDInjectedName%A_Index% "`nProblem: ID has a different name and does not match with the Registered Item Name. It was " itemname "`nSolution: Changing the Registered Item name into" itemname "`nStatus: Solved: No need for Further User Action.`n`n"
			GuiControl,Text,errorshow,%maperrorshow%
		}
	}
	tmpname2=%itemname%
	if ucron=1
	{
		FileRead,filestring,%invdirview%
	}
	else
	{
		FileRead,filestring,%A_ScriptDir%\Library\items_game.txt
	}
	tmpstring:=ResourceID%A_Index%
	filecontent:=itemdetector(tmpstring) ;filecontent:=itemdetector(tmpstring,filestring)
	itemname:=searchstringdetector(filecontent,"""name""") ; detects the name of the item
	if ResourceIDName%A_Index%<>%itemname%
	{
		tmpstring:=ResourceIDName%A_Index%
		tmpbar:=newiddetector(tmpstring) ;tmpbar:=newiddetector(tmpstring,filestring) ; tmpstring:=item name , filestring:=items_game.txt
		if tmpbar<>
		{
			maperrorshow=% maperrorshow "Section: General`nResource ID: " ResourceID%A_Index% "`nResource Registered Item Name: " ResourceIDName%A_Index% "`nProblem: Registered Item Name does not pair at the Resource ID.`nSolution: Changing the ID into " tmpbar "`nStatus: Solved: No need for Further User Action.`n`n"
			GuiControl,Text,errorshow,%maperrorshow%
			ResourceID%A_Index%=%tmpbar%
			IniWrite,%tmpbar%,%datadirview%,Edits,ResourceID%A_Index%
			itemname:=searchstringdetector(filecontent,"""name""") ; detects the name of the item
		}
		else
		{
			maperrorshow=% maperrorshow "Section: General`nResource ID: " ResourceID%A_Index% "`nResource Registered Item Name: " ResourceIDName%A_Index% "`nProblem: ID has a different name at items_game.txt and was not Registered Item Name. It was " itemname "`nSolution: Changing Registered Item Name into " itemname "`nStatus: Solved: No need for Further User Action.`n`n"
			GuiControl,Text,errorshow,%maperrorshow%
		}
	}
	tmpname1=%itemname%
	stylescount:=stylecountdetector(filecontent) ;counts the number of allowed styles of an item
	if invwaschecked=+
	{
		LV_Add("Check", ResourceID%A_Index%, IDInjected%A_Index%,tmpname1,tmpname2,stylescount,ActiveStyle%A_Index%)
	}
	else
	{
		LV_Add("-Check", ResourceID%A_Index%, IDInjected%A_Index%,tmpname1,tmpname2,stylescount,ActiveStyle%A_Index%)
	}
	if invwaschecked=+
	{
		LV_Modify(A_Index, "check")
	}
	else
	{
		LV_Modify(A_Index, "-check")
	}
	GoSub,lvautosize
	progress+=adder
	GuiControl,MainGUI:, MyProgress,%progress%
}
GuiControl,MainGUI:Text,searchnofound,%defaultshoutout%
gosub,hideprogress
GuiControl, MainGUI:+Redraw, invlv
Gui,MainGUI:Submit,NoHide
if errorshow<>
{
	msgbox,16,ERROR DETECTED!,Preloading Database Complete! But There are ERRORS Detected and the Injector Distinguished them All. Check the "Advance" Section to view the ERROR Report and How the Injector Dealt them.
}

Gui, MainGUI:-Disabled 
return

;;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~Detectors~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

miscusersdetector(filecontent) {
;miscusersdetector detects multiple hero users from an item, example: almond the frondillo pet has multiple hero users
;filecontent	-	content extracted from items_game.txt
StringGetPos, tmppos, filecontent,"used_by_heroes"
StringGetPos, tmppos1, filecontent,`r`n%A_Tab%%A_Tab%%A_Tab%}`r`n,,%tmppos%
tmplength:=tmppos1-tmppos
startpos:=tmppos+2
StringMid,itemname,filecontent,%startpos%,%tmplength%
return,itemname
}

checkdetector() {
;checkdetector will check any field that exist on the listview "itemview"
	GuiControl,-g, showitems
	if A_DefaultListView<>showitems
	{
		Gui,MainGUI:ListView,showitems
	}
	LV_Modify(0, "-check")
	if A_DefaultListView<>itemview
	{
		Gui,MainGUI:ListView,itemview
	}
	Loop % LV_GetCount()
	{
		if A_DefaultListView<>itemview
		{
			Gui,MainGUI:ListView,itemview
		}
		rowint1=%A_Index%
		loop 7
		{
			LV_GetText(col%A_Index%,rowint1,A_Index)
		}
		if A_DefaultListView<>showitems
		{
			Gui,MainGUI:ListView,showitems
		}
		Loop % LV_GetCount()
		{
			rowint=%A_Index%
			loop 7
			{
				LV_GetText(col1%A_Index%,rowint,A_Index)
			}
			if col11=%col1%
			{
				if col12=%col2%
				{
					if col13=%col3%
					{
						if col14=%col4%
						{
							if col15=%col5%
							{
								LV_Modify(A_Index,"check")
								LV_Modify(A_Index,"Col7",col7)
								Break
							}
						}
					}
				}
			}
		}
	}
	GuiControl,+gdoitems, showitems
}

visualsdetector(filecontent) {
;detects the Visual Section of the content
;filecontent	-	content extracted from items_game.txt
StringGetPos, tmppos, filecontent,`r`n%A_Tab%%A_Tab%%A_Tab%"visuals"`r`n%A_Tab%%A_Tab%%A_Tab%{
StringGetPos, tmppos1, filecontent,`r`n%A_Tab%%A_Tab%%A_Tab%},,%tmppos%
tmplength:=tmppos1-tmppos
startpos:=tmppos+1
StringMid,itemname,filecontent,%startpos%,%tmplength%
return,itemname
}

modelpathchanger(ByRef itemname,ByRef savestring,searchstring) {
;modelpathchanger will return two variables:
;itemname	-	the root location directory of the item
;savestring	-	the whole information subcontent
;required variable:
;searchstring	-	sub-content that will be searched
StringGetPos, tmppos, searchstring,"model_player"
if tmppos<1
{
	savestring=
}
else
{
	StringGetPos, tmppos1, searchstring,`r`n,,%tmppos%
	StringLen,stringlength,searchstring
	rightpos:=stringlength-tmppos
	StringGetPos, tmppos2, searchstring,`r`n,R1,%rightpos%
	tmplength:=tmppos1-tmppos2
	startpos:=tmppos2+1
	StringMid,itemname,searchstring,%startpos%,%tmplength%
	savestring=%itemname%
	StringGetPos, tmppos, itemname,"model_player"
	StringGetPos, tmppos1, itemname,",L3,%tmppos%
	StringGetPos, tmppos2, itemname,",L2,%tmppos1%
	tmplength:=tmppos2-tmppos1-1
	startpos:=tmppos1+2
	StringMid,itemname,itemname,%startpos%,%tmplength%
}
return
}

iddetector(filecontent) {
	;iddetector will detect an ID from a specific content
	;filecontent	-	a content extracted from items_game.txt
	StringGetPos, tmppos,filecontent,"
	StringGetPos, tmppos1,filecontent,",L2,%tmppos%
	tmplength:=tmppos1-tmppos-1
	startpos:=tmppos+2
	StringMid,tmpbar,filecontent,%startpos%,%tmplength%
	return,tmpbar
}

searchstringdetector(filecontent,searchstring) {
	;~~~~~~~~~~~
	;searchstringdetector will detect the item name from a content using a searchstring
	;searchstring	-	quoted commonly("string") this is the string that will be inspected on finding offest value
	;filecontent	-	a content extracted form items_game.txt
	
	;tmppos:=InStr(filecontent,searchstring)					; - determine the offset position of the serched string
	;~~~~~~~~~~~
	
	;~~~~~~~~~~~
	;stringdetector detects the righthand side name from an offset position
	;tmppos			-	offset position
	;filecontent	-	a content extracted from items_game.txt that will be scanned
	
	;tmppos1 := InStr(filecontent,"""",,tmppos,3)				; - Search for the first boundary which is a one double quotation mark(")
	;tmppos := InStr(filecontent,"""",,tmppos,4)				; - Search for the second boundary which is a one double quotation mark(")
	;itemname := SubStr(filecontent,tmppos1+1,tmppos-tmppos1-1)	; - Extract the characters between the two boundaries
	;~~~~~~~~~~~
	
	
	if tmppos:=InStr(filecontent,searchstring)
	{
		tmppos1 := InStr(filecontent,"""",,tmppos,3),tmppos := InStr(filecontent,"""",,tmppos,4),itemname := SubStr(filecontent,tmppos1+1,tmppos-tmppos1-1)
	}
	else
	{
		itemname=Undefined
	}
	return,itemname
}

modelpathdetector(filecontent,modelloop:=0) {
	;~~~~~~~~~~~
	;modelpathdetector will extract the cosmetic item's root directory location
	;modelloop	-	the number of present model names the hero item posseses, if ommited the value will automatically be zero
	;filecontent-	content extracted from items_game.txt
	
	;tmppos:=InStr(filecontent,"""model_player" modelloop """")					; - determine the offset position of the model with respect to its index
	;~~~~~~~~~~~
	
	;~~~~~~~~~~~
	;stringdetector detects the righthand side name from an offset position
	;tmppos			-	offset position
	;filecontent	-	a content extracted from items_game.txt that will be scanned
	
	;tmppos1 := InStr(filecontent,"""",,tmppos,3)				; - Search for the first boundary which is a one double quotation mark(")
	;tmppos := InStr(filecontent,"""",,tmppos,4)				; - Search for the second boundary which is a one double quotation mark(")
	;itemname := SubStr(filecontent,tmppos1+1,tmppos-tmppos1-1)	; - Extract the characters between the two boundaries
	;~~~~~~~~~~~
	;itemname := StrReplace(itemname,"/","\")					; - Changes slash into backslash(explorer directory mode)

	if modelloop=0 ; if modelloop is zero, then don't include any index value on the searched string
	{
		modelloop=
	}
	if tmppos:=InStr(filecontent,"""model_player" modelloop """")
	{
		tmppos1 := InStr(filecontent,"""",,tmppos,3),tmppos := InStr(filecontent,"""",,tmppos,4),itemname := StrReplace(SubStr(filecontent,tmppos1+1,tmppos-tmppos1-1),"/","\")
	}
	return,itemname
}

stylecountdetector(filecontent) {
;stylecountdetector counts the number of allowed styles of an item
stylefinder=%A_Tab%%A_Tab%%A_Tab%%A_Tab%"styles"`r`n%A_Tab%%A_Tab%%A_Tab%%A_Tab%{
stylescount=0
if InStr(filecontent,stylefinder)>0
{
	StringGetPos, stylepos, filecontent,%stylefinder%
	StringGetPos, stylepos1, filecontent,`r`n%A_Tab%%A_Tab%%A_Tab%%A_Tab%}`r`n,,%stylepos%
	stylepos2:=stylepos1-stylepos
	StringMid,stylesname,filecontent,%stylepos%,%stylepos2%
	Loop
	{
		tmpbarrier=%A_Tab%%A_Tab%%A_Tab%%A_Tab%%A_Tab%"%A_Index%"
		if InStr(stylesname,tmpbarrier)>0
		{
			stylescount+=1
		}
		Else
		{
			Break
		}
	}
}
return,stylescount
}

stylechanger(stylechecker,filecontent) {
;stylechanger will change the style of all particle effects and even the model
;stylechecker(integer)	-	the numerical value of the style
;filecontent	-	a content extracted from the items_game.txt
stylefinder=%A_Tab%%A_Tab%%A_Tab%%A_Tab%"styles"`r`n%A_Tab%%A_Tab%%A_Tab%%A_Tab%{
stylescount=0
if InStr(filecontent,stylefinder)>0
{
	StringGetPos, stylepos, filecontent,%stylefinder%
	StringGetPos, stylepos1, filecontent,`r`n%A_Tab%%A_Tab%%A_Tab%%A_Tab%}`r`n,,%stylepos%
	StringGetPos, stylepos2, filecontent,`r`n%A_Tab%%A_Tab%%A_Tab%%A_Tab%{`r`n,,%stylepos%
	StringGetPos, stylepos, filecontent,%A_Tab%,L5,%stylepos2%
	stylepos3:=stylepos1-stylepos+1
	StringMid,stylesname,filecontent,%stylepos%,%stylepos3%
	StringGetPos, stylepos, stylesname,%A_Tab%%A_Tab%%A_Tab%%A_Tab%%A_Tab%"%stylechecker%"
	StringGetPos, stylepos1, stylesname,`r`n%A_Tab%%A_Tab%%A_Tab%%A_Tab%%A_Tab%},,%stylepos%
	StringGetPos, stylepos2, stylesname,},,%stylepos1%
	stylepos2:=stylepos2-stylepos+2
	StringMid,replacestylesname,stylesname,%stylepos%,%stylepos2%
	StringReplace,filecontent,filecontent,%stylesname%,%replacestylesname%,1
	StringReplace,filecontent,filecontent,`r`n%A_Tab%%A_Tab%%A_Tab%%A_Tab%%A_Tab%"style"%A_Tab%%A_Tab%"%stylechecker%",,1
	StringReplace,filecontent,filecontent,`r`n%A_Tab%%A_Tab%%A_Tab%%A_Tab%%A_Tab%"style"%A_Tab%%A_Tab%"0",`r`n%A_Tab%%A_Tab%%A_Tab%%A_Tab%%A_Tab%"style"%A_Tab%%A_Tab%"%stylechecker%",1
	searchstring=%replacestylesname%
	modelpathchanger(itemname,savestring,searchstring) ; savestring returns the garbage and itemname returns our target modelpath
	if savestring<>
	{
		stringreplace,filecontent,filecontent,%savestring%,,1
		replaceas=%itemname%
		searchstring=%filecontent%
		modelpathchanger(itemname,savestring,searchstring) ; savestring returns the garbage and itemname returns our target modelpath
		stringreplace,filecontent,filecontent,%itemname%,%replaceas%,1
	}
}
return,filecontent
}

newiddetector(tmpstring,newfilestring:="") {
	;newiddetector will scan an ID from items_game.txt using a specific item name
	;tmpstring	-	item name
	;newfilestring	-	items_game.txt that will be the new value of the static variable "filestring"
	
	Static filestring
	if newfilestring<> ;if the caller wants to change the value of the static variable "filestring"
	{
		filestring:=newfilestring
	}
	
	if filestring= ; the function cannot operate properly if there is no reference items_game.txt, this will check if it is blank
	{
		ifexist,%A_ScriptDir%\Library\items_game.txt
		{
			FileRead,filestring,%A_ScriptDir%\Library\items_game.txt ; redefine items_game.txt reference
		}
		if filestring=
		{
			return ; terminate function if still no value
		}
	}
	
	tmpbar=
	Loop
	{
		StringGetPos, tmppos, filestring,`r`n%A_Tab%%A_Tab%%A_Tab%"name"%A_Tab%%A_Tab%"%tmpstring%"`r`n,L%A_Index%
		if tmppos<1
		{
			Break
		}
		filecontent:=keyworddetector(tmppos) ;filecontent:=keyworddetector(tmppos,filestring) ; tmppos:=offset position , filestring:=items_game.txt
		if (InStr(filecontent,"`r`n			""prefab""		""")>0) or (InStr(filecontent,"`r`n			""used_by_heroes""`r`n			{`r`n")>0)
		{
			tmpbar:=iddetector(filecontent) ;filecontent := extracted content from items_game.txt
			Break
		}
		if ErrorLevel=1
		{
			Break
		}
	}
	return,tmpbar
}

keyworddetector(tmppos,newfilestring:="") {
	;keyworddetector detects an item content using an offset position at items_game.txt
	;tmppos	-	offset position(integer)
	;filestring	-	items_game.txt
	
	Static filestring
	if newfilestring<> ;if the caller wants to change the value of the static variable "filestring"
	{
		filestring:=newfilestring
	}
	
	if filestring= ; the function cannot operate properly if there is no reference items_game.txt, this will check if it is blank
	{
		ifexist,%A_ScriptDir%\Library\items_game.txt
		{
			FileRead,filestring,%A_ScriptDir%\Library\items_game.txt ; redefine items_game.txt reference
		}
		if filestring=
		{
			return ; terminate function if still no value
		}
	}
	
	pos := InStr(filestring,"		}`r`n		""",,1+tmppos-StrLen(filestring))
	pos2 := InStr(filestring,"`r`n		}",,tmppos)
	filecontent := SubStr(filestring,pos,pos2-pos)
	
	;StringLen,tmp,filestring
	;StringGetPos, tmppos1, filestring,%A_Tab%%A_Tab%}`r`n%A_Tab%%A_Tab%",,%tmppos% ;"
	;rightpos:=tmp-tmppos
	;StringGetPos, tmppos2, filestring,`r`n%A_Tab%%A_Tab%}`r`n%A_Tab%%A_Tab%",R1,%rightpos% ;"
	;StringGetPos, tmppos3, filestring,%A_Tab%%A_Tab%",,%tmppos2% ;"
	;tmplength:=tmppos1-tmppos3
	;startpos:=tmppos3
	;StringMid,filecontent,filestring,%startpos%,%tmplength%
	return,filecontent
}

miscdetector(searchedfilter,tmpfind,tmpstring,newfilestring:="") {
;miscdetector detects the contents of a miscellaneous item
;tmpfind	-	item slot of the miscellaneous(eg announcer or mega-kill announcer), this will confirm if the detected content is valid
;tmpstring	-	ID of the miscellaneous
;filestring	-	reference. it can be an extracted content or items_game.txt

	Static filestring
	if newfilestring<> ;if the caller wants to change the value of the static variable "filestring"
	{
		filestring:=newfilestring
	}
	
	if filestring= ; the function cannot operate properly if there is no reference items_game.txt, this will check if it is blank
	{
		ifexist,%A_ScriptDir%\Library\items_game.txt
		{
			FileRead,filestring,%A_ScriptDir%\Library\items_game.txt ; redefine items_game.txt reference
		}
		if filestring=
		{
			return ; terminate function if still no value
		}
	}

	Finder=%A_Tab%%A_Tab%}`r`n%A_Tab%%A_Tab%"%tmpstring%"`r`n%A_Tab%%A_Tab%{
	Barrier=%A_Tab%%A_Tab%}`r`n%A_Tab%%A_Tab%" ;"
	filter1=`r`n%A_Tab%%A_Tab%%A_Tab%"%searchedfilter%"%A_Tab%%A_Tab%"%tmpfind%"`r`n
	StringLen,FinderLength,Finder
	Loop
	{
		StringGetPos, pos, filestring,%Finder%,L%A_Index%
		pos1:=pos+FinderLength
		StringGetPos, pos2, filestring,%Barrier%,,%pos1%
		startpos:=pos+6
		pos3:=pos2-pos
		StringMid,filecontent,filestring,%startpos%,%pos3%
		if InStr(filecontent,filter1)>0
		{
			Break
		}
		if ErrorLevel=1
		{
			Break
		}
		if pos<0
		{
			filecontent=
			Break
		}
	}
	return,filecontent
}

itemdetector(tmpstring,newfilestring:="") {
	;itemdetector will detect the contents of an ID using items_game.txt
	;tmpstring	-	is the ID of the contents you want to recover
	;filestring	-	items_game.txt contents
	
	Static filestring
	if newfilestring<> ;if the caller wants to change the value of the static variable "filestring"
	{
		filestring:=newfilestring
	}
	
	if filestring= ; the function cannot operate properly if there is no reference items_game.txt, this will check if it is blank
	{
		ifexist,%A_ScriptDir%\Library\items_game.txt
		{
			FileRead,filestring,%A_ScriptDir%\Library\items_game.txt ; redefine items_game.txt reference
		}
		if filestring=
		{
			return ; terminate function if still no value
		}
	}
	
	Loop
	{
		;	pos := InStr(filestring,"		}`r`n		""" tmpstring """`r`n		{",,,A_Index)	-	scans for the first pattern(starting barrier)
		;	pos2 := InStr(filestring,"`r`n		}",,pos)											-	scans for the last pattern(ending barrier)
		;	filecontent := SubStr(filestring,pos,pos2-pos)											-	extracts the specified content between two barriers
		pos := InStr(filestring,"		}`r`n		""" tmpstring """`r`n		{",,,A_Index),pos2 := InStr(filestring,"`r`n		}",,pos),filecontent := SubStr(filestring,pos,pos2-pos)
		if ((InStr(filecontent,"prefab")>0) and (InStr(filecontent,"used_by_heroes")>0)) or (ErrorLevel=1)
		{
			Break
		}
		if pos<0
		{
			filecontent=
			Break
		}
	}
	
	return,filecontent
}

npcherodetector(porthero,npcheroestxtdir,newnpchero:="") {
;npcherodetector will inspect npc_heroes.txt and extract the data of a certain hero
;porthero			-	the starting offset string. it commonly needs npc_dota_hero_*****
;npcheroestxtdir	-	location of npc_heroes.txt
;newnpchero			-	incase you want to replace the variable inside npc heroes
	
	Static npchero
	if newnpchero<> ;if the caller wants to change the value of the static variable "npchero"
	{
		npchero:=newnpchero
	}
	
	if npchero= ; the function cannot operate properly if there is no reference items_game.txt, this will check if it is blank
	{
		ifexist,%npcheroestxtdir%
		{
			fileread,npchero,%npcheroestxtdir% ; redefine items_game.txt reference
		}
		if npchero=
		{
			return ; terminate function if still no value
		}
	}
	;; fileread,npchero,%dota2dir%\game\dota\scripts\npc\npc_heroes.txt
	;; StringGetPos, portpos, npchero,`r`n%A_Tab%"%porthero% ;"
	;; StringGetPos, portpos1, npchero,`r`n%A_Tab%},,%portpos%
	;; StringMid,porthero,npchero,% portpos+1, % portpos1-portpos-1
	
	portpos := InStr(npchero,"`r`n	""" porthero) ; detects the leftmost barrier
	portpos1 := InStr(npchero,"`r`n	}",,portpos) ; detects the rightmost barrier
	porthero := SubStr(npchero,portpos+2,portpos1-portpos+2)
	
	return porthero
}

npcitemslotsdetector(herodata,ByRef itemslotscount,includetauntandpet:=0) {
;npcitemslotsdetector will extract tbe contents of the hero's item slots
;herodata			-	the contents of an hero which will be inspected by this function
;itemslotscount		-	any variable stored here will return the number of item slots found here()
;includetauntandpet	-	if this is equal to 1, it will include the taunt slot and pet slot when counting the number of item slots that will be returned for variable "itemslotscount"

	portpos := InStr(herodata,"`r`n		""ItemSlots""`r`n") ; detects the leftmost barrier
	portpos1 := InStr(herodata,"`r`n		}",,portpos) ; detects the rightmost barrier
	itemslotscontent := SubStr(herodata,portpos+2,portpos1-portpos+3)
	itemslotscount:=0 ; starting number of slot count
	;allitemslots:=[] ; declare as an array
	loop
	{
		portpos := InStr(itemslotscontent,"""`r`n			{",,,A_Index) ; detects the leftmost barrier
		if (ErrorLevel<>1) and (portpos>0)
		{
			portpos1 := InStr(itemslotscontent,"`r`n			}",,portpos) ; detects the rightmost barrier
			slotdata:=SubStr(itemslotscontent,portpos-2,portpos1-portpos+8)	;detects the specific slot content
			slotname:=searchstringdetector(slotdata,"""SlotName""") ; detects the specific slot name
			if (slotname<>"taunt") and (slotname<>"ambient_effects")
			{
				if (slotname<>"summon") or ((slotname="summon") and (InStr(slotdata,"""npc_dota_companion""")<=0))
				{
					itemslotscount++
				}
			}
			else if includetauntandpet=1
				itemslotscount++
			
			;; tells whether the string is already a value of an element of this array
			;for index, value in allitemslots
			;{
			;	if value = %slotname%
			;	{
			;		boolean=1
			;		break
			;	}
			;	else if shit<>0
			;	{
			;		boolean=0
			;	}
			;}
			
			if A_DefaultListView<>statscalibrator
			{
				Gui, MainGUI:ListView,statscalibrator
			}
			boolean=0
			loop % LV_GetCount()
			{
				LV_GetText(value,A_Index,1)
				
				if value = %slotname%
				{
					boolean=1
					break
				}
			}
			
			;
			
			if boolean=0
			{
				;allitemslots.push(slotname) ; stores the itemslot name to the last unused element(rightmost element)
				
				if (slotname<>"taunt") and (slotname<>"ambient_effects")
					LV_Add("+Check",slotname)
				else LV_Add("-Check",slotname)
				LV_ModifyCol(1,"AutoHdr Sort")
			}
			
		}
		else
		{
			break
		}
	}
	;;construct the calibrator
	;loop % allitemslots.Length()
	;{
	;	if A_DefaultListView<>statscalibrator
	;	{
	;		Gui, MainGUI:ListView,statscalibrator
	;	}
	;	if (allitemslots[A_Index]<>"taunt") and (allitemslots[A_Index]<>"ambient_effects")
	;		LV_Add("+Check",allitemslots[A_Index])
	;	else LV_Add("-Check",allitemslots[A_Index])
	;}
	;LV_ModifyCol(1,"AutoHdr Sort")
	;;
	
	return itemslotscontent
}

refreshnpcitemslotsdetector(herodata,ByRef itemslotscount) {
;npcitemslotsdetector will extract tbe contents of the hero's item slots
;herodata			-	the contents of an hero which will be inspected by this function
;itemslotscount		-	any variable stored here will return the number of item slots found here()

	portpos := InStr(herodata,"`r`n		""ItemSlots""`r`n") ; detects the leftmost barrier
	portpos1 := InStr(herodata,"`r`n		}",,portpos) ; detects the rightmost barrier
	itemslotscontent := SubStr(herodata,portpos+2,portpos1-portpos+3)
	itemslotscount:=0 ; starting number of slot count
	;allitemslots:=[] ; declare as an array
	loop
	{
		portpos := InStr(itemslotscontent,"""`r`n			{",,,A_Index) ; detects the leftmost barrier
		if (ErrorLevel<>1) and (portpos>0)
		{
			portpos1 := InStr(itemslotscontent,"`r`n			}",,portpos) ; detects the rightmost barrier
			slotdata:=SubStr(itemslotscontent,portpos-2,portpos1-portpos+8)	;detects the specific slot content
			slotname:=searchstringdetector(slotdata,"""SlotName""") ; detects the specific slot name
			
			if (slotname<>"summon") or ((slotname="summon") and (InStr(slotdata,"""npc_dota_companion""")<=0))
			{
				if A_DefaultListView<>statscalibrator
				{
					Gui, MainGUI:ListView,statscalibrator
				}
				loop % LV_GetCount()
				{
					 if LV_GetNext(A_Index-1,"Checked")=A_Index ; if this row was checked
					 {
						LV_GetText(value,A_Index,1)
						if value=%slotname% ; if they both slot name matched, means it existed as referenced
							itemslotscount++
						
					 }
				}
			}
			
		}
		else
		{
			break
		}
	}
	
	return itemslotscontent
}
;;~~~~~~~~~~~~~~~~~~~~~~~~~~~~End of Detectors~~~~~~~~~~~~~~~~~~~~~~~~~~~

lvautosize:
loop 7
{
	LV_ModifyCol(A_Index,"AutoHdr")
}
return

invdelete:
Gui, MainGUI:Default
if A_DefaultListView<>invlv
{
	Gui, MainGUI:ListView, invlv
}
gosub,deleterow
return

deleterow:
Gui,MainGUI:+Disabled
GuiControl, MainGUI:-Redraw,%A_DefaultListView%
invrownumber = 0
Loop
{
    invrownumber := LV_GetNext(invrownumber - 1)
    if not invrownumber
        break
    LV_Delete(invrownumber)
}
GoSub,lvautosize
GuiControl, MainGUI:+Redraw,%A_DefaultListView%
Gui,MainGUI:-Disabled
return

invlv:
if A_GuiEvent = DoubleClick
{
	Gui, MainGUI:Default
	if A_DefaultListView<>invlv
	{
		Gui, MainGUI:ListView, invlv
	}
	LV_GetText(mapinjectfrom, A_EventInfo,1)
	LV_GetText(mapinjectto, A_EventInfo,2)
	if mapinjectfrom=Resource ID
	{
		return
	}
	else if mapinjectto=Injected ID
	{
		return
	}
	GuiControl,Text,injectfrom,%mapinjectfrom%
	GuiControl,Text,injectto,%mapinjectto%
	Gui,MainGUI:Submit,NoHide
}
else if A_GuiEvent = RightClick
{
	Gui, MainGUI:Default
	if A_DefaultListView<>invlv
	{
		Gui, MainGUI:ListView, invlv
	}
	LV_GetText(stylescount,A_EventInfo,5)
	LV_GetText(countcheck,A_EventInfo,6)
	if stylescount>%countcheck%
	{
		LV_Modify(A_EventInfo,"Select" "Col6",,,,,,countcheck+1)
	}
	else
	{
		LV_Modify(A_EventInfo,"Select" "Col6",,,,,,"0")
	}
}
return

invccabout:
Gui, aboutgui:+ownerMainGUI
Gui,MainGUI:+Disabled
Gui, aboutgui:+Resize +MinSize
Gui, aboutgui:Add, Tab2,x0 y0 h450 w500 vtababout, About|Limitations|Changelog|Fact|Tutorials|Credits
Gui,aboutgui:Add,Edit,x0 y20 h400 w500 ReadOnly vtext35,Version %version%`n`nAJOM's Dota 2 MOD Master is a "code analyzing tool" which targets present "ID" and copies its contents`, thus replacing the other target "ID's" contents simultaneously. Since manual "copy/paste" method on items_game.txt(accourding to my experience) is hard enough`,this tool is best and can sacrifice less effort on your time.`n`nOne of the best reasons why I(Aldrin John Olaer Manalansan) created this tool is that:`n->Imagine every released "patch" of DOTA2`, they add new codes inside "items_game.txt" so that they can register its "use". Also`,you might not notice`, they change some existed "ID's Contents" into something new`, without you ever knowing.`n->Generates a "Modified Clone" of "items_game.txt" from the "Library" Folder where all the desired code are injected.
Gui, aboutgui:Tab,2
Gui,aboutgui:Add,Edit,x0 y20 h400 w500 ReadOnly vtext44,This Tool gives a bright help for MODDING DOTA2 and is very handy compared to manual MODDING`, but there will always be Limitations that this Injector(Until now) Cannot Fix.Current Issues that exist(7.03 patch):`n`n*This Tool needs to ReRun and ReInject all Item Sets every New Update/Patch with newly arrived items. It is because "items_game.txt" which is the script inside the MOD needs to be Reupdated/Repatched`, the injector's work is to ReUpdate the Script to be compatible with the newly arrived items listed at the new "items_game.txt". IF THIS INSTRUCTION IS NOT FOLLOWED`, YOU WILL ENCOUNTER WHEN LAUNCHING DOTA2 "ERROR PARSING SCRIPT" WHICH WILL IMMEDIATELY CRASH YOUR DOTA2 AND WILL REMAIN UNPLAYABLE UNTIL YOU EITHER "REMOVE THE MOD FROM YOUR DOTA2" OR "RELAUNCH THE TOOL AND REINJECT ALL ITEM SETS". Take Responsibility on the Risks!!!`n`n*Bristleback's "Piston Impaler" item does not stack with "Mace of the Wrathrunner(morning-star like)" item. This is due to the unhandled process of bristleback's "piston impaler animation" vs bristleback's "morning-star animation".`n`n*When playing "Online" Mode`, some item skin parts for heroes do not show if "it has no default cosmetic item". In other words`, this following posibilities will occur:`n-Ancient Apparition's "Shattering Blast Crown" "Head" item does not show up because "there is no default head item attached to Ancient Apparition".`n-Tinker's "Boots of Travel" "Misc" item does not show up because "there is no default misc item attached to Tinker".`n`nThis problem is common on "Modding by Scripting Method" but the MOD perfectly works on "offline/LAN mode".`n`n*Cosmetic items that "the model's item animation was substituted into the default model animation" does not function properly as expected`, Example:`n-The animation of Legion Commander's "Blades of Voth Domosh" functions as single wield type animation (wields only one sword).`n-Techies "Swine of the Sunken Gallery Set's" third member(which is Spoon) does not walk properly.`n-Witch Doctor's "Bonkers the Mad's" Monkey was not moving properly but instead was touching witch doctor's Butt.
Gui, aboutgui:Tab,3
Gui,aboutgui:Add,Edit,x0 y20 h400 w500 ReadOnly vtext36,v2.2.0 BETA*Changed all Subroutines into Separate Functions inside this Application's Code. Still in BETA Stage because uncommon bugs are still not known and is still waiting to be tracked.`n*Added Database VERSION 2. An experimental database that has no integrity verification`, resulting blazing writing and reading speed on version 2 database files. `n-DISADVANTAGE: When the Database has will not inspect for corrupted item specification lines.`n-Fix: "Verify Integrity Cache" Button is Added`n*Added "Statistics" Sub-Section at "Handy-Injection" Section. This will report the number of item slots occupied by all heroes at the "Used Items Database" Sub-Section. The Statistics is helpful incase you missed applying a Modification on an item slot for a specific hero.`n*You can now Open ".aldrin_dota2db" and ".aldrin_dota2hidb" directly using DOTA2 MOD Master. This will automatically Preload the opened Database file. To do this`, simply Execute the ".aldrin_dota2db" or ".aldrin_dota2hidb" using DOTA2 MOD Master.exe .`n*Improved ERROR Logging`n*Fixed some bugs`n`nv2.1.0`n*Added two new features at Multiple Styles Subsection of Miscellaneous Section:`n~ Radiant Creeps - Scans all ID's with prefab = radiantcreeps .`n-Dire Creeps - Scans all ID's with prefab = direcreeps .`n*Fast Preloading Reference File now will be recreated every standard preload.`n*Fixed Some Bugs`n`nv2.0.0`n*Added the External Files System. This feature can allow external files to be merged with the pak01_dir generated by this tool. This Feature is very helpful if you want to merge your custom model(.vmdl_c) and even particle(.vpfc_c) files to be merged with the operation. just include a folder where your custom files inside at "%A_ScriptDir%\External Files"`n*Added "Fast Miscellaneous Preload" Feature at "Advanced" Section. This feature can lessen your waiting time preloading miscellaneous files`, thanks to V for Vendetta's "VarWrite" and "VarRead" Function which made file writings and readings to perform blazingly fast. But this is just optional`,since we always like to make sure that preloading miscellaneous should be accurate`, it depends on you if you want to use this feature`n*Integrated Alpha Bravo's "WM_MOUSEMOVE" Function which allows each controls to have tooltips. Now each questionable controls will have a tooltip present as guide. This will be helpful for new users of this tool. Incase you want to disable this feature`, you can uncheck "Advanced > show tooltip guides"`n`nv1.7.2`n*Updated "Relic" into "Emblem".`n*Integrated "Klark92's Draws" Function. This new Feature allowed buttons to have custom colors.`n*Added "Patch gameinfo.gi" Button Option at "Advanced Section". Pressing this Button will Manually Patch gameinfo.gi Reactivating the MOD(pak01_dir.vpk) Found at "%dota2dir%\game\Aldrin_Mods\" Folder.`n`nv1.7.1`n*Improved "pak01_dir.vpk" detection`n*Fixed a Bug where the default settings does not detect gameinfo.gi location leaving autoshutnik-method unchecked as default.`n`nv1.7.0`n*Added Voice-Actived Narrator Option at "Advanced" Section. When Enabled`, a Narrator announces statistics about the Injector's Operations`n*"HandyInjection"`,"H.I. Used Items"`, and "Custom Heroes" now belongs on a SINGLE Section named "Handy Injection". Inside the "Handy Injection" Section there are three another Sections`, the "Hero Items Selection"(the Old Name of this Section is HandyInjection)`, the "Used Items Database"(the Old Name of this Section is H.I. Used Items)`, and "Custom Heroes"`n*Fixed a bug where adding check marks on specific items at "Hero Items Selection" fails to be updated at "Used Items Database"`n*Fixed a bug where Heroes with "Multiple Alternate Models" are not extracted`n*Fixed a bug where some extracted models and particles with the same name on a directory fails to extract`, this was fixed by extracting and renaming them one at a time(which multiple CMD will not be applied on files with the same name)`n*Changed the Name this tool from "items_game.txt injector" > MOD Master`n`nv1.6.0`n*Added two new SINGLE SOURCE features at "Miscellaneous" Section`n-Multikill-Banner : When you continously kill enemy heroes within 10 seconds`, A Glowing effect on the streak message will show up.`n-emblem : A Person with the highest battlepass level will gain this emblem EFFECT`, But playing OFFLINE will result the main user's hero to gain a emblem EFFECT.`n*The Injector now Patches the "Portraits.txt" which change the orientation of the Hero on the HEROBAR.`n*Cured the Bug where the HLLIB manipulation is wrongly approached resulting PARTICLE CORRUPTION among certain particle files`, which some particles pops MULTIPLE RED CROSS(not yet 100`% fixed)`n*The Progress-Bar now Flickers and has borders sketching the complete progress`n*Added a New Feature on "Advanced" Section which is the "REPORT LOG". This feature reports what files are extracted and where can you find it. This can be helpful in some cases if you want to analyze all the Files which the injector had managed accourding to the amount of Data you wished to inject from your "Previous Operation".`n-The Report Log is only Generated from "General" and "Handy Injection" Operation`n-ModelRealName : The Name of the extracted File`n-ModelLocationPath : The Location where the "ModelRealName" was extracted`n-ModelDefaultName : "ModelRealName" was renamed into this name found at "ModelLocationPath"`n-ParticleRealName : The Name of the extracted File`n-ParticleLocationPath : The Location where the "ParticleRealName" was extracted`n-ParticleDefaultName : "ParticleRealName" was renamed into this name found at "ParticleLocationPath"`n`nv1.5.0`n*The Injector now AUTOMATICALLY DETECTS New Heroes through "activelist.txt" feature. Unlike the last version has its defined hero list`, but now using "activelist.txt" the injector now will scan all characters defined by DOTA2.`n*Reworked "Migration" Method Section`, which becomes more accurate on migrating items_game.txt.`n*Improved LEAK Checking which now will slightly save process required space.`n*Fixed "Custom Hero" Section where the "ADD" button malfuctioned`n*Can now capture lastly used Section. In which when you exit this tool`, it will save the current tab and make it as the default tab that will be opened on the next use of this Tool.`n`nv1.4.0`n*Added "Cursor-Pack" Feature at "Miscellaneous" Section`n*Reorganized the "Miscellaneous" Section`,dividing it into FOUR Sections: Single Source`,Multi-Styles`,Multi-Source`,Optional Features.`n*Fixed the Bug where the "HUD-Skin" writes incorrectly at "items_game.txt" causing "battlepass is missing failed to load items_def" ERROR when launching DOTA2.`n`nv1.3.5`n*Recompiled into a more stable Analyzer script.`n`nv1.3.4`n*Fixed a bug : If players installed their steam on a specific path... But Suddenly Relocate it to another Location`, The Registry Location will not be valid anymore. : So for those Player who have done that`, Relocate your DOTA2 path Manually!`n`nv1.3.3`n*Reworked Taunts setting it as "baseitem=1"`n`nv1.3.2`n*Fixed A bug where autoextract and gameinfo.gi auto-editing malfunctions because of the newly reworked method of detecting the dota 2 directory.`n`nv1.3.1`n*Reworked the Detection of the DOTA2 Directory. Deflecting the Encryption of "appmanifest.acf"`, in other words this tool will not read appmanifest anymore.`n`nv1.3.0`n*Added "Low-Processor Mode" at Advanced Section for those users who uses Low Processor Machines(2gb RAM below)`n`nv1.2.0`n*Added "Remove MOD on DOTA2" feature at "Advanced" section`n`nv1.1.0`n*Added "Music-Pack" feature at "Miscellaneous" section`n*Fixed the bug where at general section`,pressing "inject all actived id's" pops up multiple command prompts instead of hiding it.`n*Added the Detection of DOTA2 Registry Folder(for users that installed DOTA2 before the birth of DOTA2 BETA)`n*when "Auto-shutnik method" is turned off. It will now generate a "pak01_dir" folder including all cosmetic items plus items_game.txt. This option is best for MODDERs who wants to MANUALLY MOD DOTA2.`n`nv1.0.2`n*Fixed the bug where instead a cosmetic item should be renamed as ".vmdl_c"`, it was renamed as ".vmdl"(without _c) resulting arcana sets to malfunction`n`nv1.0.1`n*Universally fixes all dislocations of cosmetic items.`n*Improved the detection of both default item and injected item when extracting .vmdl files at pak01_dir folder.`n*Added the Detection of Cosmetic Particles`, which fixes the bug which particle effects do not work online.`n`nv1.0.0`n*Added the "HLLIB" Plugin which allows this tool to have the ability to extract cosmetic items from the original "pak01_dir.vpk" at steam folder. This Fixes the items injected to not show up online.`n*Relocates some settings to the "NEW Section" which is the "Advance" Section`,this section is optional for ADVANCE USERS who knows what they are doing`n*Makes this Tool even more interactive to Users`n`nv0.1.1`n*Fixed the BUG which the MOD does not show up ingame. This bug was caused by the new "auto-detection of gameinfo.gi"`n`nv0.1.0`n*Added "Titan's Anchor Logic" that allows this Tool to change its size or be maximized.`n*Maintainably Fixed "auto_vpk.bat ERROR cannot be executed because it does not exist".`n`nv0.0.1`n*Added "Miscellaneous" Section. This section is revolutional which supports multiple features:`n-Terrain Select`n-Weather Effect Select`n-HUD-Skin Select`n-Courier Select(supports changable styles)`n-Ward Select(supports changable styles)`n-Loading-Screen Select`n-Taunt for Heroes Select`n-Announcer and Mega-Kills Select`n-Activate Pet "Almond the Frondillo"`n*Added "Auto-Shutnik Method" Feature at "Miscellaneous" Section which allows this script to do all the work activating the "MOD" without requiring you to study "Shutnik Method". But this feature crucially requires "VPKCreator"(you can download it at the internet if its not present just search "dota2 vpkcreator") or else this feature will be disabled. ACTIVATING THIS FEATURE DOES NOT REQUIRE THE "Use Miscellaneous on Future Injection" TO BE ENABLED`, but ofcourse you need to locate the location of "gameinfo.gi". It is commonly located at "C:\Program Files (x86)\Steam\steamapps\common\dota 2 beta\game\dota\" Folder.`n*Improved the Speed of Item Scanning by 50`%`, in other words`, if its slower for you. Then that constant speed is the fastest scan this application can do. SO HAVE PATIENCE!
Gui, aboutgui:Tab,4
Gui,aboutgui:Add,Edit,x0 y20 h400 w500 vtext37 ReadOnly,*Right-Click an item to change "Styles"(if it has an available alternative style).`n`n*At "Handy Injection>Hero Items Selection" Section`,every Hero can ONLY have ONE ITEM PER ITEM SLOT. Adding a "Check" Mark on an item will REMOVE THE OTHER CHECK MARK ON AN ITEM WITH THE SAME ITEM SLOT(eg. juggernaut's bladeform legacy is an Head Item slot`, it will deselect any item that are Head Item Slot Like Mask of a Thousand Faces).`n`n*On every Dropdownlist(eg. The Custom Items Location Path Found at the General Section... The gameinfo.gi Location Path found at the Advanced Section)`, to clear the control just left click the dropdownlist and left click the location path. This will clear the location path and disable its future controls.`n`n*To Manually Patch gameinfo.gi using the injector`, go to "advanced>patch gameinfo.gi". Clicking this button will Activate the MOD(pak01_dir.vpk) found at "%dota2dir%\" Folder.`n`n*It is good that "use miscellaneous on future injection" Feature at "Miscellaneous" Section is "TURNED OFF" if you do not use any feature on that section. Because every start`, this Tool will need to preload all miscellaneous assets which will consume much time`n`n*"AUTO-SHUTNIK METHOD" is a very important feature of this Tool`,it was built for users who dont know how to "Manually MOD DOTA2".`n`n*Turning Off "AUTO-SHUTNIK METHOD" will Generate a "pak01_dir" folder at the "Generated MOD" Folder found on the same folder of this Tool. This is HELPFUL for users who wants to MANUALLY MOD DOTA2`n`n*Turning ON "Low-Processor Mode" at "Advanced" Section will command this Tool not to consume alot of RAM when "Injecting items"`, executing only ONE COMMAND PROMPT to execute the Extraction of Items through their specific locations. BUT AS PENALTY`, it will CONSUME ALOT OF TIME for the Injection to Finish!!! So if you are "Injecting 400 items"... I appoximate each items will be extracted after "5 seconds"`, so 400 x 5 is equal to 2000 seconds(33 minutes)`n`n*"Save Settings" button on the bottom left does NOT SAVE DATALISTS`,it only saves "directories" which you selected and checkboxes that are not inside a "DATALIST". If you want to save a Datalist. Use "Save DataBase List" instead.`n`n*"Save DataBase List" at "Hero Items Selection" and "Used Items Database" from Handy Injection Section do the same thing.`n`n*"Save DataBase List" at the "General" Section is different on "Save DataBase List" for "Handy Injection". In other words`, it only saves the datalist PRESENT ON THAT SECTION PLUS ALL Miscellaneous DATALIST(if enabled).`n`n*"Migration" Feature only prioritize items with "prefab=default_item". In other words`, it does not support "terrain`,weather`,hud`,loadingscreen`,ect"`n`n*At "Search" Section`,You can press "Enter/Return" Key and it will do the same job pressing "Search for(keyword)" button.`n`n*Pressing "Search for(keyword)" Button(Or Enter/Return) with the same "Keyword" you have searched last time will move to the next occurence... Until there is no match found``, it will go back to the very first occurence.`n`n*The "ERROR LOG" at "Advanced" Section reports certain coincidence that is rarely different from what the injector has scanned before the last launch. This happens when a new update comes out with newly added cosmetic items`, those items are registered at the "items_game.txt" that have unique ID's that not present on the earlier patches. But sometimes`, they are REGISTERED AT AN EXISTED ID... While the OLD REGISTERED item on that ID that was REPLACED by this newly arrived item``,was MOVED INTO ANOTHER UNIQUE ID!!! So this Tool will able to detect those coincidence WHEN YOU HAVE A DATABASE.`n`n*Expect that when an "ITEM was Announced" at the "ERROR LOG"`,it will be UNCHECKED at either "Handy Injection" section or "General" Section`, in other words it will be unused. You need to "recheck" it again on that section to "Activate" it again.`n`n*This Tool detects the DOTA2 Directory by pairing a combination pattern... It scans all Folder inside the "steamapps\common" then scans if the picked folder has "game\dota" subfolder inside.`n`n*The Injector needs 150MB of RAM when making its Operation. If your computer is very weak to handle this amount of memory`, then please do not use this injector and Throw this Tool at your Recycle Bin!
Gui, aboutgui:Tab,5
Gui,aboutgui:Add, Link,vtext39,*General Section: <a href="https://www.youtube.com/watch?v=N8POaZ2nXbA&t=25s">https://www.youtube.com/watch?v=N8POaZ2nXbA&t=25s</a>
Gui,aboutgui:Add, Link,vtext40,*Handy Injection Section: <a href="https://www.youtube.com/watch?v=-BETnaBBLME&t=25s">https://www.youtube.com/watch?v=-BETnaBBLME&t=25s</a>
Gui,aboutgui:Add, Link,vtext41,*Miscellaneous Section: <a href="https://www.youtube.com/watch?v=y9HYHBtBYXs&t=834s">https://www.youtube.com/watch?v=y9HYHBtBYXs&t=834s</a>
Gui,aboutgui:Add, Link,vtext50,*External Files: <a href="https://www.youtube.com/watch?v=eG2XRCj7Sy0&t=365s">https://www.youtube.com/watch?v=eG2XRCj7Sy0&t=365s</a>
Gui,aboutgui:Add, Link,vtext33,*Create your Own Database: <a href="https://www.youtube.com/watch?v=kC1-2UtXp_U">https://www.youtube.com/watch?v=kC1-2UtXp_U</a>
Gui,aboutgui:Add, Link,vtext34,*Edit a Database: <a href="https://www.youtube.com/watch?v=wF2DnfrgWkg">https://www.youtube.com/watch?v=wF2DnfrgWkg</a>
Gui,aboutgui:Add, Link,vtext42,*ERROR! Items_game.txt is missing!: <a href="https://www.youtube.com/watch?v=l4w2fT_lY10&t=3s">https://www.youtube.com/watch?v=l4w2fT_lY10&t=3s</a>
Gui, aboutgui:Tab,6
Gui,aboutgui:Add,Edit,x0 y20 h400 w500 vtext38 ReadOnly,This are lifetime credits to those people who suffered bugs and are concerned to report to us. Making this tool More better every time!`n`nv2.1.0`n*7u7u74n9- inspected a bug where the injector only extracts npc_dota assets. Eg. Spirits of the Mothbinder's vmdl counterpart is "dota_death_prophet_exorcism_spirit" that has no "npc" at the beggining`, making the injector to ignore this asset.`n`nv2.0.0`n*Alpha Bravo- as I currently use his "WM_MOUSEMOVE" Function.`n*Obi-Wahn- for his "LV_MoveRow" Function that is integrated on this tool.`n*Pulover [Rodolfo U. Batista]- for his "Eval" Function that I currently used evaluating strings into numbers.`n*V for Vendetta- for his "VarWrite" and "VarRead" Function.`n`n`nv1.7.2`n*Klark92-as I currently use his "Draw" Function`n`nv1.6.1`n*7u7u74n9-inspected how the injector generates all files and confirmed its inaccuracy. Reported main cost problems including missing .vmdl files extracted at pak01_dir`, Alternate Models(for three level grow of tiny`,night stalker at night`,terrorblade's demon form`,lycan's shapeshift`,lone druid' druid form`,ect) failed to extract. Suggested Keyholes and some details.`n`nv1.3.4`n*Kush Manek-reported the bug where when he relocated his steam folder to another path`,the tool cant identify the location anymore. Concluding "Cats are not good on hide and seek".`n`nv1.0.1`n*John Kris Uytiepo-reported specific heroes which has bugs which the items does not show when playing online. This Bug was fixed by optimizing detection to prevent dislocations on its specific location.`n`nv0.1.1`n*Edwin Santos-reported the bug of not showing items even if a good procedure was met.`n`nv0.1.1`n*Titan-as I currently use his "Anchor" Logic Function
Gui, aboutgui:Tab
Gui, aboutgui:Add, Button, vtext43 x230 y420, OK
Gui,aboutgui:Show,h450 w500,About AJOM's Dota 2 MOD Master
return

aboutguiButtonOK:
aboutguiGuiClose:
aboutguiGuiEscape:
Gui,MainGUI:-Disabled
Gui,aboutgui:Destroy
return

k_MenuExit:
MainGUIGuiClose:
gosub,savetab
ExitApp
return

savetab:
Gui,MainGUI:Submit,NoHide
tabparam=tablist,intablist,intablist1,intablist2
tabparam1=choosetab,inchoosetab,inchoosetab1,inchoosetab2
tabparam2=OuterTab,%innertabparam%
loop,Parse,tabparam,`,
{
	intparam=%A_Index%
	loop,parse,%A_LoopField%,|
	{
		save=%A_LoopField%
		intparam1=%A_Index%
		loop,parse,tabparam2,`,
		{
			if (save=%A_LoopField%) and (intparam=A_Index)
			{
				loop,Parse,tabparam1,`,
				{
					if intparam=%A_Index%
					{
						IniWrite,%intparam1%,%A_ScriptDir%\Settings.aldrin_dota2mod,Edits,%A_LoopField%
					}
				}
			}
		}
	}
}
return

invbrowse:
Gui MainGUI:+OwnDialogs
Gui,MainGUI:Submit,NoHide
FileSelectFile,invfile,3,,items_game.txt,items_game.txt
checker:=SubStr(invfile,-13,14)
If checker=items_game.txt
{
	GuiControl,Text,invdirview,%invfile%||
}
return

databrowse:
Gui MainGUI:+OwnDialogs
gosub,leakdestroyer
FileSelectFile,invfile,3,,.aldrin_dota2db,*.aldrin_dota2db
If SubStr(invfile,-14,15)=.aldrin_dota2db
{
	GuiControl,Text,datadirview,%invfile%||
	Gui,MainGUI:Submit,NoHide
	Gui, MainGUI:Default
	if A_DefaultListView<>invlv
	{
		Gui, MainGUI:ListView, invlv
	}
	LV_Delete()
	maperrorshow=
	GuiControl,Text,errorshow,
	GoSub,datareload
	if usemiscon=1
	{
		reloadmisc(invfile) ; ;Scans the database then put a checkmark on each miscellaneous it uses
	}
	if soundon=1
	{
		SoundPlay,%A_Temp%\Sound\loaddatacomplete.wav
	}
}
return

datasave:
gosub,leakdestroyer
Gui, MainGUI:Submit, NoHide
Gui, MainGUI:Default
if A_DefaultListView<>invlv
{
	Gui, MainGUI:ListView, invlv
}
if LV_GetCount()=0
{
	GuiControl,MainGUI:Text,searchnofound,%defaultshoutout%
	gosub,hideprogress
	
	return
}
Gui, MainGUI:-Disabled 
;FileSelectFile,invfile,S24,,.aldrin_dota2db,*.aldrin_dota2db

;;; SaveFile Returns two index on an object:
;;; File			-	the inputted filename
;;; FileTypeIndex	-	the chosen Filter(Files of type dropdownlist of the explorer gui)... This will Return the number of row of the selected filetype extension
MyObject := SaveFile( [0, "Name your Database and Specify where to Save"]    ; [owner, title/prompt]
             , ""    ; RootDir\Filename
             , {"General Database Version 1": "*.aldrin_dota2hidb","General Database Version 2 (Latest)": "*.aldrin_dota2hidb"}     ; Filter
			 , 2	 ; Chosen Row at Filter Dropdownlist. Take note that the arrangement IS SORTED FIRST at the beggining, so after the arrangement of filter was sorted it will next choose the "2nd" row.
             , ""    ; CustomPlaces
             , 2)    ; Options ( 2 = FOS_OVERWRITEPROMPT )
invfile := MyObject.File

if invfile<>
{
	if MyObject.FileTypeIndex=1
	{
		Gui, MainGUI:Show
		adder:=1000/LV_GetCount()
		progress=0
		gosub,showprogress
		If SubStr(invfile,-14,15)<>.aldrin_dota2db
		{
			invfile=%invfile%.aldrin_dota2db
		}
		IfExist,%invfile%
		{
			FileDelete, %invfile%
		}
		FileAppend,,%invfile%
		RegisteredDirectory=0
		Loop % LV_GetCount()
		{
			RegisteredDirectory+=1
			LV_GetText(mapinvfilehk,A_Index,1)
			LV_GetText(mapinvdirbox,A_Index,2)
			LV_GetText(mapActiveStyle,A_Index,6)
			if ( A_Index = LV_GetNext(A_Index-1,"Checked"))
			{
				checker=+
			}
			else
			{
				checker=-
			}
			
			IniWrite, %mapinvdirbox%, %invfile%, Edits, IDInjected%A_Index%
			IniWrite, %mapinvfilehk%, %invfile%, Edits, ResourceID%A_Index%
			IniWrite, %mapActiveStyle%, %invfile%, Edits, ActiveStyle%A_Index%
			IniWrite, %checker%, %invfile%, Edits, ResourceID%A_Index%Enabled
			
			LV_GetText(tmp,A_Index,3)
			
			IniWrite, %tmp%, %invfile%, Edits, ResourceIDName%A_Index%
			
			LV_GetText(tmp,A_Index,4)
			
			IniWrite, %tmp%, %invfile%, Edits, IDInjectedName%A_Index%
			
			progress+=adder
			GuiControl,MainGUI:, MyProgress,%progress%
		}
		gosub,hideprogress
		
		IniWrite, %RegisteredDirectory%, %invfile%, Edits, RegisteredDirectory
		
		if usemiscon=1
		{
			GoSub,savemisc
		}
		VarWrite( ) ; blanks Function Static "Var" variable! Always start Writing in a blank variable, avoiding Rewritings (Faster) 
		VarWrite("@DataBaseVersion!",MyObject.FileTypeIndex)	;VarWrite(Key := "", Value := "") ; Saves the Database Version for future version detection
		FileAppend,% VarWrite( , "GetVar"),%invfile%  ;"VarWrite( ,"GetVar")" function returns the text that will be stored in the file choosed by user, the first parameter must be omitted or blank
	}
	else if MyObject.FileTypeIndex=2
	{
		VarWrite( ) ; blanks Function Static "Var" variable! Always start Writing in a blank variable, avoiding Rewritings (Faster) 
		Gui, MainGUI:Show
		adder:=1000/LV_GetCount()
		progress=0
		gosub,showprogress
		If SubStr(invfile,-14,15)<>.aldrin_dota2db
		{
			invfile=%invfile%.aldrin_dota2db
		}
		IfExist,%invfile%
		{
			FileDelete, %invfile%
		}
		RegisteredDirectory=0
		Loop % LV_GetCount()
		{
			RegisteredDirectory+=1
			LV_GetText(mapinvfilehk,A_Index,1)
			LV_GetText(mapinvdirbox,A_Index,2)
			LV_GetText(mapActiveStyle,A_Index,6)
			if ( A_Index = LV_GetNext(A_Index-1,"Checked"))
			{
				checker=+
			}
			else
			{
				checker=-
			}
			
			VarWrite("IDInjected" A_Index,mapinvdirbox)	;VarWrite(Key := "", Value := "")
			VarWrite("ResourceID" A_Index,mapinvfilehk)	;VarWrite(Key := "", Value := "")
			VarWrite("ActiveStyle" A_Index,mapActiveStyle)	;VarWrite(Key := "", Value := "")
			VarWrite("ResourceID" A_Index "Enabled",checker)	;VarWrite(Key := "", Value := "")
			
			LV_GetText(tmp,A_Index,3)
			
			VarWrite("ResourceIDName" A_Index,tmp)	;VarWrite(Key := "", Value := "")
			
			LV_GetText(tmp,A_Index,4)
			
			VarWrite("IDInjectedName" A_Index,tmp)	;VarWrite(Key := "", Value := "")
			
			progress+=adder
			GuiControl,MainGUI:, MyProgress,%progress%
		}
		gosub,hideprogress
		
		VarWrite("RegisteredDirectory",RegisteredDirectory)	;VarWrite(Key := "", Value := "")
		
		if usemiscon=1
		{
			GoSub,savemisc
		}
		VarWrite("@DataBaseVersion!","2")	;VarWrite(Key := "", Value := "") ; Saves the Database Version for future version detection
		FileAppend,% VarWrite( , "GetVar"),%invfile%  ;"VarWrite( ,"GetVar")" function returns the text that will be stored in the file choosed by user, the first parameter must be omitted or blank
	}
	if soundon=1
	{
		SoundPlay,%A_Temp%\Sound\savedatacomplete.wav
	}
}
GuiControl,MainGUI:Text,searchnofound,%defaultshoutout%
Gui, MainGUI:-Disabled 
return

buttonsearch:
Gui,MainGUI:Submit,NoHide
if searchbar<>
{
	ifnotexist,%A_ScriptDir%\Library\items_game.txt
	{
		msgbox,16,Error!!!,"%A_ScriptDir%\Library\items_game.txt"`n`nIs Missing!!! Make sure to add the original "items_game.txt" at "%A_ScriptDir%\Library" Folder.`n`nIf you dont have an Idea how to get the original "items_game.txt" use "GCFScape.exe" or "Valve's Resource Viewer" application to access "Pak01_dir.vpk". Inside the VPK Archive`,Hit "Ctrl+F"(Find) and search for "items_game.txt". If successfully found`, extract it(items_game.txt) at "%A_ScriptDir%\Library\" Folder.
		return
	}
	FileRead,filestring,%A_ScriptDir%\Library\items_game.txt
	StringLen, filelength, filestring
	sfinder=`r`n%A_Tab%%A_Tab%}`r`n%A_Tab%%A_Tab%" ;"
	Loop
	{
		if searchbarsaver=%searchbar%
		{
			if A_Index<=%searchnext%
			{
				continue
			}
		}
		else
		{
			searchnext=1
		}
		StringGetPos, spos, filestring,%searchbar%,L%A_Index%
		rightpos:=filelength-spos
		StringGetPos, spos1, filestring,%sfinder%,,%spos%
		StringGetPos, spos2, filestring,%sfinder%,R1,%rightpos%
		startpos:=spos2+8
		spos3:=spos1-spos2
		StringMid,filecontent,filestring,%startpos%,%spos3%
		if InStr(filecontent,"prefab")>0
		{
			if searchbarsaver=%searchbar%
			{
				if oldfilecontent<>%filecontent%
				{
					oldfilecontent=%filecontent%
					searchnext=%A_Index%
					Break
				}
				else
				{
					oldfilecontent=%filecontent%
				}
			}
			else
			{
				oldfilecontent=%filecontent%
				Break
			}
		}
		else
		{
			filecontent=
		}
		if ErrorLevel=1
		{
			GuiControl,+cRed, searchnofound
			if searchbarsaver=%searchbar%
			{
				GuiControl,Text, searchnofound,No Matched Item Found this Time!
				searchnext=0
			}
			else
			{
				GuiControl,Text, searchnofound,No Matched Item Found!
				searchnext=0
			}
			sleep 1000
			GuiControl,+cDefault, searchnofound
			GuiControl,Text,searchnofound,%defaultshoutout%
			return
		}
	}
	searchbarsaver=%searchbar%
	if filecontent<>
	{
		param1=namebar|prefabbar|itemslotbar|modelpathbar|heroesbar
		param2="name"|"prefab"|"item_slot"|"model_player"|"used_by_heroes"
		loop,parse,param2,|
		{
			StringGetPos, tmppos,filecontent,%A_LoopField%
			StringGetPos, tmppos1,filecontent,",L3,%tmppos%
			StringGetPos, tmppos2,filecontent,",L2,%tmppos1%
			tmplength:=tmppos2-tmppos1-1
			startpos:=tmppos1+2
			StringMid,tmpbar,filecontent,%startpos%,%tmplength%
			integer=%A_Index%
			loop,parse,param1,|
			{
				if integer=%A_Index%
				{
					GuiControl,Text,%A_LoopField%,%tmpbar%
					Break
				}
			}
		}
		StringReplace,filecontent,filecontent,`r`n%A_Tab%%A_Tab%,`r`n,1
		StringTrimLeft, filecontent, filecontent, 2
		tmpbar:=iddetector(filecontent) ;filecontent := extracted content from items_game.txt
		GuiControl,Text,idbar,%tmpbar%
		GuiControl,Text,searchshow,%filecontent%
	}
}
return

;;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~Functions~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Anchor(i, a := "", r := true) {
    static c, cs := 12, cx := 255, cl := 0, g, gs := 8, gl := 0, gpi, gw, gh, z := 0, k := 0xffff, ptr
    if z = 0
        VarSetCapacity(g, gs * 99, 0), VarSetCapacity(c, cs * cx, 0), ptr := A_PtrSize ? "Ptr" : "UInt", z := true
    if !WinExist("ahk_id" . i) {
        GuiControlGet t, Hwnd, %i%
        if ErrorLevel = 0
            i := t
        else ControlGet i, Hwnd,, %i%
    }
    VarSetCapacity(gi, 68, 0), DllCall("GetWindowInfo", "UInt", gp := DllCall("GetParent", "UInt", i), ptr, &gi)
        , giw := NumGet(gi, 28, "Int") - NumGet(gi, 20, "Int"), gih := NumGet(gi, 32, "Int") - NumGet(gi, 24, "Int")
    if (gp != gpi) {
        gpi := gp
        loop %gl%
            if NumGet(g, cb := gs * (A_Index - 1), "UInt") == gp {
                gw := NumGet(g, cb + 4, "Short"), gh := NumGet(g, cb + 6, "Short"), gf := 1
                break
            }
        if !gf
            NumPut(gp, g, gl, "UInt"), NumPut(gw := giw, g, gl + 4, "Short"), NumPut(gh := gih, g, gl + 6, "Short"), gl += gs
    }
    ControlGetPos dx, dy, dw, dh,, ahk_id %i%
    loop %cl%
        if NumGet(c, cb := cs * (A_Index - 1), "UInt") == i {
            if (a = "") {
                cf := 1
                break
            }
            giw -= gw, gih -= gh, as := 1, dx := NumGet(c, cb + 4, "Short"), dy := NumGet(c, cb + 6, "Short")
                , cw := dw, dw := NumGet(c, cb + 8, "Short"), ch := dh, dh := NumGet(c, cb + 10, "Short")
            loop Parse, a, xywh
                if A_Index > 1
                    av := SubStr(a, as, 1), as += 1 + StrLen(A_LoopField)
                        , d%av% += (InStr("yh", av) ? gih : giw) * (A_LoopField + 0 ? A_LoopField : 1)
            DllCall("SetWindowPos", "UInt", i, "UInt", 0, "Int", dx, "Int", dy
                , "Int", InStr(a, "w") ? dw : cw, "Int", InStr(a, "h") ? dh : ch, "Int", 4)
            if r != 0
                DllCall("RedrawWindow", "UInt", i, "UInt", 0, "UInt", 0, "UInt", 0x0101) ; RDW_UPDATENOW | RDW_INVALIDATE
            return
        }
    if cf != 1
        cb := cl, cl += cs
    bx := NumGet(gi, 48, "UInt"), by := NumGet(gi, 16, "Int") - NumGet(gi, 8, "Int") - gih - NumGet(gi, 52, "UInt")
    if cf = 1
        dw -= giw - gw, dh -= gih - gh
    NumPut(i, c, cb, "UInt"), NumPut(dx - bx, c, cb + 4, "Short"), NumPut(dy - by, c, cb + 6, "Short")
        , NumPut(dw, c, cb + 8, "Short"), NumPut(dh, c, cb + 10, "Short")
    return true
}

SetBtnTxtColor(HWND, TxtColor) {
   Static HTML := {BLACK: "000000", GRAY: "808080", SILVER: "C0C0C0", WHITE: "FFFFFF", MAROON: "800000"
                , PURPLE: "800080", FUCHSIA: "FF00FF", RED: "FF0000", GREEN:  "008000", OLIVE:  "808000"
                , YELLOW: "FFFF00", LIME: "00FF00", NAVY: "000080", TEAL: "008080", AQUA: "00FFFF", BLUE: "0000FF", GOLD: "D4AF37", BRONZE: "8C7853"}
   Static BS_CHECKBOX := 0x2, BS_RADIOBUTTON := 0x4, BS_GROUPBOX := 0x7, BS_AUTORADIOBUTTON := 0x9
        , BS_LEFT := 0x100, BS_RIGHT := 0x200, BS_CENTER := 0x300, BS_TOP := 0x400, BS_BOTTOM := 0x800
        , BS_VCENTER := 0xC00, BS_BITMAP := 0x0080, SA_LEFT := 0x0, SA_CENTER := 0x1, SA_RIGHT := 0x2
        , WM_GETFONT := 0x31, BCM_SETIMAGELIST := 0x1602, IMAGE_BITMAP := 0x0, BITSPIXEL := 0xC
        , RCBUTTONS := BS_CHECKBOX | BS_RADIOBUTTON | BS_AUTORADIOBUTTON
        , BUTTON_IMAGELIST_ALIGN_LEFT := 0, BUTTON_IMAGELIST_ALIGN_RIGHT := 1, BUTTON_IMAGELIST_ALIGN_CENTER := 4
   ; -------------------------------------------------------------------------------------------------------------------
   ErrorLevel := ""
   GDIPDll := DllCall("Kernel32.dll\LoadLibrary", "Str", "Gdiplus.dll", "Ptr")
   VarSetCapacity(SI, 24, 0)
   Numput(1, SI)
   DllCall("Gdiplus.dll\GdiplusStartup", "PtrP", GDIPToken, "Ptr", &SI, "Ptr", 0)
   If (!GDIPToken) {
       ErrorLevel := "GDIPlus could not be started!`n`nSetBtnTxtColor won't work!"
       Return False
   }
   If !DllCall("User32.dll\IsWindow", "Ptr", HWND) {
      GoSub, CreateImageButton_GDIPShutdown
      ErrorLevel := "Invalid parameter HWND!"
      Return False
   }
   WinGetClass, BtnClass, ahk_id %HWND%
   ControlGet, BtnStyle, Style, , , ahk_id %HWND%
   If (BtnClass != "Button") || ((BtnStyle & 0xF ^ BS_GROUPBOX) = 0) || ((BtnStyle & RCBUTTONS) > 1) {
      GoSub, CreateImageButton_GDIPShutdown
      ErrorLevel := "You can use SetBtnTxtColor only for PushButtons!"
      Return False
   }
   PFONT := 0
   DC := DllCall("User32.dll\GetDC", "Ptr", HWND, "Ptr")
   BPP := DllCall("Gdi32.dll\GetDeviceCaps", "Ptr", DC, "Int", BITSPIXEL)
   HFONT := DllCall("User32.dll\SendMessage", "Ptr", HWND, "UInt", WM_GETFONT, "Ptr", 0, "Ptr", 0, "Ptr")
   DllCall("Gdi32.dll\SelectObject", "Ptr", DC, "Ptr", HFONT)
   DllCall("Gdiplus.dll\GdipCreateFontFromDC", "Ptr", DC, "PtrP", PFONT)
   DllCall("User32.dll\ReleaseDC", "Ptr", HWND, "Ptr", DC)
   If !(PFONT) {
      GoSub, CreateImageButton_GDIPShutdown
      ErrorLevel := "Couldn't get button's font!"
      Return False
   }
   VarSetCapacity(RECT, 16, 0)
   If !(DllCall("User32.dll\GetClientRect", "Ptr", HWND, "Ptr", &RECT)) {
      GoSub, CreateImageButton_GDIPShutdown
      ErrorLevel := "Couldn't get button's rectangle!"
      Return False
   }
   W := NumGet(RECT,  8, "Int"), H := NumGet(RECT, 12, "Int")
   BtnCaption := ""
   Len := DllCall("User32.dll\GetWindowTextLength", "Ptr", HWND) + 1
   If (Len > 1) {
      VarSetCapacity(BtnCaption, Len * (A_IsUnicode ? 2 : 1), 0)
      If !(DllCall("User32.dll\GetWindowText", "Ptr", HWND, "Str", BtnCaption, "Int", Len)) {
         GoSub, CreateImageButton_GDIPShutdown
         ErrorLevel := "Couldn't get button's caption!"
         Return False
      }
      VarSetCapacity(BtnCaption, -1)
   } Else {
      GoSub, CreateImageButton_GDIPShutdown
      ErrorLevel := "Couldn't get button's caption!"
      Return False
   }
   If HTML.HasKey(TxtColor)
      TxtColor := HTML[TxtColor]
   DllCall("Gdiplus.dll\GdipCreateBitmapFromScan0", "Int", W, "Int", H, "Int", 0
         , "UInt", 0x26200A, "Ptr", 0, "PtrP", PBITMAP)
   DllCall("Gdiplus.dll\GdipGetImageGraphicsContext", "Ptr", PBITMAP, "PtrP", PGRAPHICS)
   DllCall("Gdiplus.dll\GdipStringFormatGetGenericTypographic", "PtrP", PFORMAT)
   HALIGN := (BtnStyle & BS_CENTER) = BS_CENTER ? SA_CENTER : (BtnStyle & BS_CENTER) = BS_RIGHT ? SA_RIGHT
           : (BtnStyle & BS_CENTER) = BS_Left ? SA_LEFT : SA_CENTER
   DllCall("Gdiplus.dll\GdipSetStringFormatAlign", "Ptr", PFORMAT, "Int", HALIGN)
   VALIGN := (BtnStyle & BS_VCENTER) = BS_TOP ? 0 : (BtnStyle & BS_VCENTER) = BS_BOTTOM ? 2 : 1
   DllCall("Gdiplus.dll\GdipSetStringFormatLineAlign", "Ptr", PFORMAT, "Int", VALIGN)
   DllCall("Gdiplus.dll\GdipSetTextRenderingHint", "Ptr", PGRAPHICS, "Int", 3)
   NumPut(4, RECT, 0, "Float"), NumPut(2, RECT, 4, "Float")
   NumPut(W - 8, RECT, 8, "Float"), NumPut(H - 4, RECT, 12, "Float")
   DllCall("Gdiplus.dll\GdipCreateSolidFill", "UInt", "0xFF" . TxtColor, "PtrP", PBRUSH)
   DllCall("Gdiplus.dll\GdipDrawString", "Ptr", PGRAPHICS, "WStr", BtnCaption, "Int", -1, "Ptr", PFONT, "Ptr", &RECT
         , "Ptr", PFORMAT, "Ptr", PBRUSH)
   DllCall("Gdiplus.dll\GdipCreateHBITMAPFromBitmap", "Ptr", PBITMAP, "PtrP", HBITMAP, "UInt", 0X00FFFFFF)
   DllCall("Gdiplus.dll\GdipDisposeImage", "Ptr", PBITMAP)
   DllCall("Gdiplus.dll\GdipDeleteBrush", "Ptr", PBRUSH)
   DllCall("Gdiplus.dll\GdipDeleteStringFormat", "Ptr", PFORMAT)
   DllCall("Gdiplus.dll\GdipDeleteGraphics", "Ptr", PGRAPHICS)
   DllCall("Gdiplus.dll\GdipDeleteFont", "Ptr", PFONT)
   HIL := DllCall("Comctl32.dll\ImageList_Create", "UInt", W, "UInt", H, "UInt", BPP, "Int", 1, "Int", 0, "Ptr")
   DllCall("Comctl32.dll\ImageList_Add", "Ptr", HIL, "Ptr", HBITMAP, "Ptr", 0)
   VarSetCapacity(BIL, 20 + A_PtrSize, 0)
   NumPut(HIL, BIL, 0, "Ptr"), Numput(BUTTON_IMAGELIST_ALIGN_CENTER, BIL, A_PtrSize + 16, "UInt")
   GuiControl, , %HWND%
   SendMessage, BCM_SETIMAGELIST, 0, 0, , ahk_id %HWND%
   SendMessage, BCM_SETIMAGELIST, 0, &BIL, , ahk_id %HWND%
   GoSub, CreateImageButton_FreeBitmaps
   GoSub, CreateImageButton_GDIPShutdown
   Return True
   ; -------------------------------------------------------------------------------------------------------------------
   CreateImageButton_FreeBitmaps:
      DllCall("Gdi32.dll\DeleteObject", "Ptr", HBITMAP)
   Return    
   ; -------------------------------------------------------------------------------------------------------------------
   CreateImageButton_GDIPShutdown:
      DllCall("Gdiplus.dll\GdiplusShutdown", "Ptr", GDIPToken)
      DllCall("Kernel32.dll\FreeLibrary", "Ptr", GDIPDll)
   Return
}

LV_MoveRow(moveup = true) {
	; Original by diebagger (Guest) from:
	; http://de.autohotkey.com/forum/viewtopic.php?p=58526#58526
	; Slightly Modifyed by Obi-Wahn
	If moveup not in 1,0
		Return	; If direction not up or down (true or false)
	while x := LV_GetNext(x)	; Get selected lines
		i := A_Index, i%i% := x
	If (!i) || ((i1 < 2) && moveup) || ((i%i% = LV_GetCount()) && !moveup)
		Return	; Break Function if: nothing selected, (first selected < 2 AND moveup = true) [header bug]
				; OR (last selected = LV_GetCount() AND moveup = false) [delete bug]
	cc := LV_GetCount("Col"), fr := LV_GetNext(0, "Focused"), d := moveup ? -1 : 1
	; Count Columns, Query Line Number of next selected, set direction math.
	Loop, %i% {	; Loop selected lines
		r := moveup ? A_Index : i - A_Index + 1, ro := i%r%, rn := ro + d
		; Calculate row up or down, ro (current row), rn (target row)
		Loop, %cc% {	; Loop through header count
			LV_GetText(to, ro, A_Index), LV_GetText(tn, rn, A_Index)
			; Query Text from Current and Targetrow
			LV_Modify(rn, "Col" A_Index, to), LV_Modify(ro, "Col" A_Index, tn)
			; Modify Rows (switch text)
		}
		if ro = % LV_GetNext(ro-1, "Checked")
			ckn=Check
		else
			ckn=-Check
		if rn = % LV_GetNext(rn-1, "Checked")
			cko=Check
		else
			cko=-Check
		LV_Modify(ro, "-select -focus " cko), LV_Modify(rn, "select vis " ckn)
		If (ro = fr)
			LV_Modify(rn, "Focus")
	}
}

;=======================================================================================
;
; Function:			Eval
; Description:		Evaluate Expressions in Strings.
; Return value:		An array (object) with the result of each expression.
;
; Author:			Pulover [Rodolfo U. Batista]
; Credits:			ExprEval() by Uberi
;
;=======================================================================================
;
; Parameters:
;
;	$x:				The input string to be evaluated. You can enter multiple expressions
;						separated by commas (inside the string).
;	_CustomVars:	An optional Associative Array object containing variables names
;					  as keys and values to replace them.
;					For example, setting it to {A_Index: A_Index} inside a loop will replace
;						occurrences of A_Index with the correct value for the iteration.
;	_Init:			Used internally for the recursive calls. If TRUE it resets the static
;						object _Objects, which holds objects references to be restored.
;
;=======================================================================================
Eval($x, _CustomVars := "", _Init := true)
{
	Static _Objects
	_Elements := {}
	If (_Init)
		_Objects := {}
	
	; Strip off comments
	$x := RegExReplace($x, "U)/\*.*\*/"), $x := RegExReplace($x, "U)\s;.*(\v|$)")
	
	; Replace brackets, braces, parenthesis and literal strings
	
	While (RegExMatch($x, "sU)"".*""", _String))
		_Elements["&_String" A_Index "_&"] := _String
	,	$x := RegExReplace($x, "sU)"".*""", "&_String" A_Index "_&",, 1)
	While (RegExMatch($x, "\[([^\[\]]++|(?R))*\]", _Bracket))
		_Elements["&_Bracket" A_Index "_&"] := _Bracket
	,	$x := RegExReplace($x, "\[([^\[\]]++|(?R))*\]", "&_Bracket" A_Index "_&",, 1)
	While (RegExMatch($x, "\{[^\{\}]++\}", _Brace))
		_Elements["&_Brace" A_Index "_&"] := _Brace
	,	$x := RegExReplace($x, "\{[^\{\}]++\}", "&_Brace" A_Index "_&",, 1)
	While (RegExMatch($x, "\(([^()]++|(?R))*\)", _Parent))
		_Elements["&_Parent" A_Index "_&"] := _Parent
	,	$x := RegExReplace($x, "\(([^()]++|(?R))*\)", "&_Parent" A_Index "_&",, 1)
	
	; Split multiple expressions
	$z := StrSplit($x, ",", " `t")
	
	For $i, $v in $z
	{
		; Check for Ternary expression and evaluate
		If (RegExMatch($z[$i], "([^\?:=]+?)\?([^\?:]+?):(.*)", _Match))
		{
			Loop, 3
			{
				$o := A_Index, _Match%$o% := Trim(_Match%$o%)
			,	_Match%$o% := RestoreElements(_Match%$o%, _Elements)
			}
			EvalResult := Eval(_Match1, _CustomVars, false)
		,	$y := EvalResult[1]
			If ($y)
			{
				EvalResult := Eval(_Match2, _CustomVars, false)
			,	$y := StrJoin(EvalResult,, true, false)
			,	ObjName := RegExReplace(_Match2, "\W", "_")
				If (IsObject($y))
					_Objects[ObjName] := $y
				$z[$i] := StrReplace($z[$i], _Match, IsObject($y) ? """<~#" ObjName "#~>""" : $y)
			}
			Else
			{
				EvalResult := Eval(_Match3, _CustomVars, false)
			,	$y := StrJoin(EvalResult,, true, false)
			,	ObjName := RegExReplace(_Match3, "\W", "_")
				If (IsObject($y))
					_Objects[ObjName] := $y
				$z[$i] := StrReplace($z[$i], _Match, IsObject($y) ? """<~#" ObjName "#~>""" : $y)
			}
		}
		
		_Pos := 1
		; Check for Object calls
		While (RegExMatch($z[$i], "([\w%]+)(\.|&_Bracket|&_Parent\d+_&)[\w\.&%]+(.*)", _Match, _Pos))
		{
			AssignParse(_Match, VarName, Oper, VarValue)
			If (Oper != "")
			{
				VarValue := RestoreElements(VarValue, _Elements)
			,	EvalResult := Eval(VarValue, _CustomVars, false)
			,	VarValue := StrJoin(EvalResult)
				If (!IsObject(VarValue))
					VarValue := RegExReplace(VarValue, """{2,2}", """")
			}
			Else
				_Match := StrReplace(_Match, _Match3), VarName := _Match

			VarName := RestoreElements(VarName, _Elements)
			
			If _Match1 is Number
			{
				_Pos += StrLen(_Match1)
				continue
			}
			
			$y := ParseObjects(VarName, _CustomVars, Oper, VarValue)
		,	ObjName := RegExReplace(_Match, "\W", "_")
			
			If (IsObject($y))
				_Objects[ObjName] := $y
			Else If $y is not Number
			{
				$y := """" StrReplace($y, """", """""") """"
			,	HidString := "&_String" (ObjCount(_Elements) + 1) "_&"
			,	_Elements[HidString] := $y
			,	$y := HidString
			}
			$z[$i] := StrReplace($z[$i], _Match, IsObject($y) ? """<~#" ObjName "#~>""" : $y,, 1)
		}
		
		; Assign Arrays
		While (RegExMatch($z[$i], "&_Bracket\d+_&", $pd))
		{
			$z[$i] := StrReplace($z[$i], $pd, _Elements[$pd],, 1)
		,	RegExMatch($z[$i], "\[(.*)\]", _Match)
		,	_Match1 := RestoreElements(_Match1, _Elements)
		,	$y := Eval(_Match1, _CustomVars, false)
		,	ObjName := RegExReplace(_Match, "\W", "_")
		,	_Objects[ObjName] := $y
		,	$z[$i] := StrReplace($z[$i], _Match, """<~#" ObjName "#~>""")
		}
		
		; Assign Associative Arrays
		While (RegExMatch($z[$i], "&_Brace\d+_&", $pd))
		{
			$y := {}, o_Elements := {}
		,	$o := _Elements[$pd]
		,	$o := RestoreElements($o, _Elements)
		,	$o := SubStr($o, 2, -1)
			While (RegExMatch($o, "sU)"".*""", _String%A_Index%))
				o_Elements["&_String" A_Index "_&"] := _String%A_Index%
			,	$o := RegExReplace($o, "sU)"".*""", "&_String" A_Index "_&", "", 1)
			While (RegExMatch($o, "\[([^\[\]]++|(?R))*\]", _Bracket))
				o_Elements["&_Bracket" A_Index "_&"] := _Bracket
			,	$o := RegExReplace($o, "\[([^\[\]]++|(?R))*\]", "&_Bracket" A_Index "_&",, 1)
			While (RegExMatch($o, "\{[^\{\}]++\}", _Brace))
				o_Elements["&_Brace" A_Index "_&"] := _Brace
			,	$o := RegExReplace($o, "\{[^\{\}]++\}", "&_Brace" A_Index "_&",, 1)
			While (RegExMatch($o, "\(([^()]++|(?R))*\)", _Parent))
				o_Elements["&_Parent" A_Index "_&"] := _Parent
			,	$o := RegExReplace($o, "\(([^()]++|(?R))*\)", "&_Parent" A_Index "_&",, 1)
			Loop, Parse, $o, `,, %A_Space%%A_Tab%
			{
				$o := StrSplit(A_LoopField, ":", " `t")
			,	$o.1 := RestoreElements($o.1, o_Elements)
			,	$o.2 := RestoreElements($o.2, o_Elements)
			,	EvalResult := Eval($o.2, _CustomVars, false)
			,	$o.1 := Trim($o.1, """")
			,	$y[$o.1] := EvalResult[1]
			}
			ObjName := RegExReplace(_Match, "\W", "_")
		,	_Objects[ObjName] := $y
		,	$z[$i] := StrReplace($z[$i], $pd, """<~#" ObjName "#~>""")
		}
		
		; Restore and evaluate any remaining parenthesis
		While (RegExMatch($z[$i], "&_Parent\d+_&", $pd))
		{
			_oMatch := StrSplit(_Elements[$pd], ",", " `t()")
		,	_Match := RegExReplace(_Elements[$pd], "\((.*)\)", "$1")
		,	_Match := RestoreElements(_Match, _Elements)
		,	EvalResult := Eval(_Match, _CustomVars, false)
		,	RepString := "("
			For _i, _v in EvalResult
			{
				ObjName := RegExReplace($pd . _i, "\W", "_")
				If (IsObject(_v))
					_Objects[ObjName] := _v
				Else If _v is not Number
				{
					If (_oMatch[_i] != "")
					{
						_v := """" _v """"
					,	HidString := "&_String" (ObjCount(_Elements) + 1) "_&"
					,	_Elements[HidString] := _v
					,	_v := HidString
					}
				}
				RepString .= (IsObject(_v) ? """<~#" ObjName "#~>""" : _v) ", "
			}
			RepString := RTrim(RepString, ", ") ")"
		,	$z[$i] := StrReplace($z[$i], $pd, RepString,, 1)
		}
		
		; Check whether the whole string is an object
		$y := $z[$i]
		Try
		{
			If (_CustomVars.HasKey($y))
			{
				If (IsObject(_CustomVars[$y]))
				{
					ObjName := RegExReplace($y, "\W", "_")
				,	_Objects[ObjName] := _CustomVars[$y].Clone()
				,	$z[$i] := """<~#" ObjName "#~>"""
				}
			}
			Else If (IsObject(%$y%))
			{
				ObjName := RegExReplace($y, "\W", "_")
			,	_Objects[ObjName] := %$y%.Clone()
			,	$z[$i] := """<~#" ObjName "#~>"""
			}
		}
		
		; Check for Functions
		While (RegExMatch($z[$i], "s)([\w%]+)\((.*?)\)", _Match))
		{
			_Match1 := (RegExMatch(_Match1, "^%(\S+)%$", $pd)) ? %$pd1% : _Match1
		,	_Match2 := RestoreElements(_Match2, _Elements)
		,	_Params := Eval(_Match2, _CustomVars)
		,	$y := %_Match1%(_Params*)
		,	ObjName := RegExReplace(_Match, "\W", "_")
			If (IsObject($y))
				_Objects[ObjName] := $y
			Else If $y is not Number
			{
				$y := """" $y """"
			,	HidString := "&_String" (ObjCount(_Elements) + 1) "_&"
			,	_Elements[HidString] := $y
			,	$y := HidString
			}
			$z[$i] := StrReplace($z[$i], _Match, IsObject($y) ? """<~#" ObjName "#~>""" : $y,, 1)
		}
		
		; Dereference variables in percent signs
		While (RegExMatch($z[$i], "U)%(\S+)%", _Match))
			EvalResult := Eval(_Match1, _CustomVars, false)
		,	$z[$i] := StrReplace($z[$i], _Match, EvalResult[1])
		
		; ExprEval() cannot parse Unicode strings, so the "real" strings are "hidden" from ExprCompile() and restored later
		$z[$i] := RestoreElements($z[$i], _Elements)
	,	__Elements := {}
		While (RegExMatch($z[$i], "sU)""(.*)""", _String))
			__Elements["&_String" A_Index "_&"] := _String1
		,	$z[$i] := RegExReplace($z[$i], "sU)"".*""", "&_String" A_Index "_&",, 1)
		$z[$i] := RegExReplace($z[$i], "&_String\d+_&", """$0""")
		
		; Add concatenate operator after strings where necessary
		While (RegExMatch($z[$i], "(""&_String\d+_&""\s+)([^\d\.,\s:\?])"))
			$z[$i] := RegExReplace($z[$i], "(""&_String\d+_&""\s+)([^\d\.,\s:\?])", "$1. $2")
		
		; Evaluate parsed expression with ExprEval()
		ExprInit()
	,	CompiledExpression := ExprCompile($z[$i])
	,	$Result := ExprEval(CompiledExpression, _CustomVars, _Objects, __Elements)
	,	$Result := StrSplit($Result, Chr(1))
		
		; Restore object references
		For _i, _v in $Result
		{
			If (RegExMatch(_v, "^<~#(.*)#~>$", $pd))
				$Result[_i] := _Objects[$pd1]
		}
		
		$z[$i] := StrJoin($Result,, false, _Init)
	}
	
	; If returning to the original call, remove missing expressions from the array
	If (_Init)
	{
		$x := StrSplit($x, ",", " `t")
		For _i, _v in $x
		{
			If (_v = "")
				$z.Delete(_i)
		}
	}
	
	return $z
}

ParseObjects(v_String, _CustomVars := "", o_Oper := "", o_Value := "")
{
	Static _needle := "([\w%]+\.?|\(([^()]++|(?R))*\)\.?|\[([^\[\]]++|(?R))*\]\.?)"
	
	l_Matches := [], _Pos := 1
	While (_Pos := RegExMatch(v_String, _needle, l_Found, _Pos))
		l_Matches.Push(RegExMatch(RTrim(l_Found, "."), "^%(\S+)%$", $pd) ? %$pd1% : RTrim(l_Found, "."))
	,	_Pos += StrLen(l_Found)
	v_Obj := l_Matches[1]
	If (_CustomVars.HasKey(v_Obj))
		_ArrayObject := _CustomVars[v_Obj]
	Else
		Try _ArrayObject := %v_Obj%
	For $i, $v in l_Matches
	{
		If (RegExMatch($v, "^\((.*)\)$"))
			continue
		If (RegExMatch($v, "^\[(.*)\]$", l_Found))
			_Key := Eval(l_Found1, _CustomVars, false)
		Else
			_Key := [$v]
		$n := l_Matches[$i + 1]
		If (RegExMatch($n, "^\((.*)\)$", l_Found))
		{
			_Key := _Key[1]
		,	_Params := Eval(l_Found1, _CustomVars, false)
			
			Try
			{
				If ($i = 1)
					_ArrayObject := %_Key%(_Params*)
				Else
					_ArrayObject := _ArrayObject[_Key](_Params*)
			}
			Catch e
			{
				If (InStr(e.Message, "0x800A03EC"))
				{
					; Workaround for strange bug in some Excel methods
					For _i, _v in _Params
						_Params[_i] := " " _v
				
					If ($i = 1)
						_ArrayObject := %_Key%(_Params*)
					Else
						_ArrayObject := _ArrayObject[_Key](_Params*)
				}
				Else
					Throw e
			}
		}
		Else If (($i = l_Matches.Length()) && (o_Value != ""))
		{
			Try
			{
				If (o_Oper = ":=")
					_ArrayObject := _ArrayObject[_Key*] := o_Value ? o_Value : false
				Else If (o_Oper = "+=")
					_ArrayObject := _ArrayObject[_Key*] += o_Value ? o_Value : false
				Else If (o_Oper = "-=")
					_ArrayObject := _ArrayObject[_Key*] -= o_Value ? o_Value : false
				Else If (o_Oper = "*=")
					_ArrayObject := _ArrayObject[_Key*] *= o_Value ? o_Value : false
				Else If (o_Oper = "/=")
					_ArrayObject := _ArrayObject[_Key*] /= o_Value ? o_Value : false
				Else If (o_Oper = "//=")
					_ArrayObject := _ArrayObject[_Key*] //= o_Value ? o_Value : false
				Else If (o_Oper = ".=")
					_ArrayObject := _ArrayObject[_Key*] .= o_Value ? o_Value : false
				Else If (o_Oper = "|=")
					_ArrayObject := _ArrayObject[_Key*] |= o_Value ? o_Value : false
				Else If (o_Oper = "&=")
					_ArrayObject := _ArrayObject[_Key*] &= o_Value ? o_Value : false
				Else If (o_Oper = "^=")
					_ArrayObject := _ArrayObject[_Key*] ^= o_Value ? o_Value : false
				Else If (o_Oper = ">>=")
					_ArrayObject := _ArrayObject[_Key*] >>= o_Value ? o_Value : false
				Else If (o_Oper = "<<=")
					_ArrayObject := _ArrayObject[_Key*] <<= o_Value ? o_Value : false
			}
		}
		Else If ($i > 1)
			_ArrayObject := _ArrayObject[_Key*]
	}
	return _ArrayObject
}

RestoreElements(_String, _Elements)
{
	While (RegExMatch(_String, "&_\w+_&", $pd))
		_String := StrReplace(_String, $pd, _Elements[$pd])
	return _String
}

AssignParse(String, ByRef VarName, ByRef Oper, ByRef VarValue)
{
	RegExMatch(String, "(.*?)(:=|\+=|-=|\*=|/=|//=|\.=|\|=|&=|\^=|>>=|<<=)(?=([^""]*""[^""]*"")*[^""]*$)(.*)", Out)
,	VarName := Trim(Out1), Oper := Out2, VarValue := Trim(Out4)
}

StrJoin(InputArray, JChr := "", Quote := false, Init := true)
{
	For i, v in InputArray
	{
		If (IsObject(v))
			return v
		If v is not Number
		{
			If (!Init)
				v := RegExReplace(v, """{1,2}", """""")
			If (Quote)
				v := """" v """"
		}
		JoinedStr .= v . JChr
	}
	If (JChr != "")
		JoinedStr := SubStr(JoinedStr, 1, -(StrLen(JChr)))
	return JoinedStr
}

ObjCount(Obj)
{
	return NumGet(&Obj + 4 * A_PtrSize)
}

;##################################################
; Author: Uberi
; Modified by: Pulover
; http://autohotkey.com/board/topic/64167-expreval-evaluate-expressions/
;##################################################
ExprInit()
{
	global
	Exprot:="`n:= 0 R 2`n+= 0 R 2`n-= 0 R 2`n*= 0 R 2`n/= 0 R 2`n//= 0 R 2`n.= 0 R 2`n|= 0 R 2`n&= 0 R 2`n^= 0 R 2`n>>= 0 R 2`n<<= 0 R 2`n|| 3 L 2`n&& 4 L 2`n\! 5 R 1`n= 6 L 2`n== 6 L 2`n<> 6 L 2`n!= 6 L 2`n> 7 L 2`n< 7 L 2`n>= 7 L 2`n<= 7 L 2`n\. 8 L 2`n& 9 L 2`n^ 9 L 2`n| 9 L 2`n<< 10 L 2`n>> 10 L 2`n+ 11 L 2`n- 11 L 2`n* 12 L 2`n/ 12 L 2`n// 12 L 2`n\- 13 R 1`n! 13 R 1`n~ 13 R 1`n\& 13 R 1`n\* 13 R 1`n** 14 R 2`n\++ 15 R 1`n\-- 15 R 1`n++ 15 L 1`n-- 15 L 1`n. 16 L 2`n`% 17 R 1`n",Exprol:=SubStr(RegExReplace(Exprot,"iS) \d+ [LR] \d+\n","`n"),2,-1)
	Sort,Exprol,FExprols
}

ExprCompile(e)
{
	e:=Exprt(e)
	Loop,Parse,e,% Chr(1)
	{
		lf:=A_LoopField,tt:=SubStr(lf,1,1),to:=SubStr(lf,2)
		If tt=f
		Exprp1(s,lf)
		Else If lf=,
		{
			While,s<>""&&Exprp3(s)<>"("
			Exprp1(ou,Exprp2(s))
		}
		Else If tt=o
		{
			While,SubStr(so:=Exprp3(s),1,1)="o"
			{
				ta:=Expras(to),tp:=Exprpr(to),sop:=Exprpr(SubStr(so,2))
				If ((ta="L"&&tp>sop)||(ta="R"&&tp>=sop))
				Break
				Exprp1(ou,Exprp2(s))
			}
			Exprp1(s,lf)
		}
		Else If lf=(
		Exprp1(s,"(")
		Else If lf=)
		{
			While,Exprp3(s)<>"("
			{
				If s=
				Return
				Exprp1(ou,Exprp2(s))
			}
			Exprp2(s)
			If (SubStr(Exprp3(s),1,1)="f")
			Exprp1(ou,Exprp2(s))
		}
		Else Exprp1(ou,lf)
	}
	While,s<>""
	{
		t1:=Exprp2(s)
		If t1 In (,)
		Return
		Exprp1(ou,t1)
	}
	Return,ou
}

ExprEval(e,lp,eo,el)
{
	c1:=Chr(1)
	Loop,Parse,e,%c1%
	{
		lf:=A_LoopField,tt:=SubStr(lf,1,1),t:=SubStr(lf,2)
		While (RegExMatch(lf,"&_String\d+_&",rm))
		lf:=StrReplace(lf,rm,el[rm])
		If tt In l,v
		lf:=Exprp1(s,lf)
		Else{
			If tt=f
			t1:=InStr(t," "),a:=SubStr(t,1,t1-1),t:=SubStr(t,t1+1)
			Else a:=Exprac(t)
			Exprp1(s,Exprap(t,s,a,lp,eo))
		}
	}
	
	Loop,Parse,s,%c1%
	{
		lf:=A_LoopField
		If (SubStr(lf,1,1)="v")
		t1:=SubStr(lf,2),r.=(lp.HasKey(t1) ? lp[t1] : %t1%) . c1
		Else r.=SubStr(lf,2) . c1
	}
	Return,SubStr(r,1,-1)
}

Exprap(o,ByRef s,ac,lp,eo)
{
	local i,t1,a1,a2,a3,a4,a5,a6,a1v,a2v,a3v,a4v,a5v,a6v,a7v,a8v,a9v
	Loop,%ac%
	i:=ac-(A_Index-1),t1:=Exprp2(s),a%i%:=SubStr(t1,2),(SubStr(t1,1,1)="v")?(a%i%v:=1)
	Loop, 10
	{
		If (RegExMatch(a%A_Index%,"^<~#(.*)#~>$",rm))
		a%A_Index%:=eo[rm1],a%A_Index%v:=0
		Else If (lp.HasKey(a%A_Index%))
		a%A_Index%:=lp[a%A_Index%],a%A_Index%v:=0
	}
	If o=++
	Return,"l" . %a1%++
	If o=--
	Return,"l" . %a1%--
	If o=\++
	Return,"l" . ++%a1%
	If o=\--
	Return,"l" . --%a1%
	If o=`%
	Return,"v" . %a1%
	If o=!
	Return,"l" . !(a1v ? %a1%:a1)
	If o=\!
	Return,"l" . (a1v ? %a1%:a1)
	If o=~
	Return,"l" . ~(a1v ? %a1%:a1)
	If o=**
	Return,"l" . ((a1v ? %a1%:a1)**(a2v ? %a2%:a2))
	If o=*
	Return,"l" . ((a1v ? %a1%:a1)*(a2v ? %a2%:a2))
	If o=\*
	Return,"l" . *(a1v ? %a1%:a1)
	If o=/
	Return,"l" . ((a1v ? %a1%:a1)/(a2v ? %a2%:a2))
	If o=//
	Return,"l" . ((a1v ? %a1%:a1)//(a2v ? %a2%:a2))
	If o=+
	Return,"l" . ((a1v ? %a1%:a1)+(a2v ? %a2%:a2))
	If o=-
	Return,"l" . ((a1v ? %a1%:a1)-(a2v ? %a2%:a2))
	If o=\-
	Return,"l" . -(a1v ? %a1%:a1)
	If o=<<
	Return,"l" . ((a1v ? %a1%:a1)<<(a2v ? %a2%:a2))
	If o=>>
	Return,"l" . ((a1v ? %a1%:a1)>>(a2v ? %a2%:a2))
	If o=&
	Return,"l" . ((a1v ? %a1%:a1)&(a2v ? %a2%:a2))
	If o=\&
	Return,"l" . &(a1v ? %a1%:a1)
	If o=^
	Return,"l" . ((a1v ? %a1%:a1)^(a2v ? %a2%:a2))
	If o=|
	Return,"l" . ((a1v ? %a1%:a1)|(a2v ? %a2%:a2))
	If o=\.
	Return,"l" . ((a1v ? %a1%:a1) . (a2v ? %a2%:a2))
	If o=.
	Return,"v" . a1
	If o=<
	Return,"l" . ((a1v ? %a1%:a1)<(a2v ? %a2%:a2))
	If o=>
	Return,"l" . ((a1v ? %a1%:a1)>(a2v ? %a2%:a2))
	If o==
	Return,"l" . ((a1v ? %a1%:a1)=(a2v ? %a2%:a2))
	If o===
	Return,"l" . ((a1v ? %a1%:a1)==(a2v ? %a2%:a2))
	If o=<>
	Return,"l" . ((a1v ? %a1%:a1)<>(a2v ? %a2%:a2))
	If o=!=
	Return,"l" . ((a1v ? %a1%:a1)!=(a2v ? %a2%:a2))
	If o=>=
	Return,"l" . ((a1v ? %a1%:a1)>=(a2v ? %a2%:a2))
	If o=<=
	Return,"l" . ((a1v ? %a1%:a1)<=(a2v ? %a2%:a2))
	If o=&&
	Return,"l" . ((a1v ? %a1%:a1)&&(a2v ? %a2%:a2))
	If o=||
	Return,"l" . ((a1v ? %a1%:a1)||(a2v ? %a2%:a2))
	If o=:=
	{
		%a1%:=(a2v ? %a2%:a2)
		Return,"v" . a1
	}
	If o=+=
	{
		%a1%+=(a2v ? %a2%:a2)
		Return,"v" . a1
	}
	If o=-=
	{
		%a1%-=(a2v ? %a2%:a2)
		Return,"v" . a1
	}
	If o=*=
	{
		%a1%*=(a2v ? %a2%:a2)
		Return,"v" . a1
	}
	If o=/=
	{
		%a1%/=(a2v ? %a2%:a2)
		Return,"v" . a1
	}
	If o=//=
	{
		%a1%//=(a2v ? %a2%:a2)
		Return,"v" . a1
	}
	If o=.=
	{
		%a1%.=(a2v ? %a2%:a2)
		Return,"v" . a1
	}
	If o=|=
	{
		%a1%|=(a2v ? %a2%:a2)
		Return,"v" . a1
	}
	If o=&=
	{
		%a1%&=(a2v ? %a2%:a2)
		Return,"v" . a1
	}
	If o=^=
	{
		%a1%^=(a2v ? %a2%:a2)
		Return,"v" . a1
	}
	If o=>>=
	{
		%a1%>>=(a2v ? %a2%:a2)
		Return,"v" . a1
	}
	If o=<<=
	{
		%a1%<<=(a2v ? %a2%:a2)
		Return,"v" . a1
	}
	If ac=0
	Return,"l" . %o%()
	If ac=1
	Return,"l" . %o%(a1v ? %a1%:a1)
	If ac=2
	Return,"l" . %o%((a1v ? %a1%:a1),(a2v ? %a2%:a2))
	If ac=3
	Return,"l" . %o%((a1v ? %a1%:a1),(a2v ? %a2%:a2),(a3v ? %a3%:a3))
	If ac=4
	Return,"l" . %o%((a1v ? %a1%:a1),(a2v ? %a2%:a2),(a3v ? %a3%:a3),(a4v ? %a4%:a4))
	If ac=5
	Return,"l" . %o%((a1v ? %a1%:a1),(a2v ? %a2%:a2),(a3v ? %a3%:a3),(a4v ? %a4%:a4),(a5v ? %a5%:a5))
	If ac=6
	Return,"l" . %o%((a1v ? %a1%:a1),(a2v ? %a2%:a2),(a3v ? %a3%:a3),(a4v ? %a4%:a4),(a5v ? %a5%:a5),(a6v ? %a6%:a6))
	If ac=7
	Return,"l" . %o%((a1v ? %a1%:a1),(a2v ? %a2%:a2),(a3v ? %a3%:a3),(a4v ? %a4%:a4),(a5v ? %a5%:a5),(a6v ? %a6%:a6),(a7v ? %a7%:a7))
	If ac=8
	Return,"l" . %o%((a1v ? %a1%:a1),(a2v ? %a2%:a2),(a3v ? %a3%:a3),(a4v ? %a4%:a4),(a5v ? %a5%:a5),(a6v ? %a6%:a6),(a7v ? %a7%:a7),(a8v ? %a8%:a8))
	If ac=9
	Return,"l" . %o%((a1v ? %a1%:a1),(a2v ? %a2%:a2),(a3v ? %a3%:a3),(a4v ? %a4%:a4),(a5v ? %a5%:a5),(a6v ? %a6%:a6),(a7v ? %a7%:a7),(a8v ? %a8%:a8),(a9v ? %a9%:a9))
	If ac=10
	Return,"l" . %o%((a1v ? %a1%:a1),(a2v ? %a2%:a2),(a3v ? %a3%:a3),(a4v ? %a4%:a4),(a5v ? %a5%:a5),(a6v ? %a6%:a6),(a7v ? %a7%:a7),(a8v ? %a8%:a8),(a9v ? %a9%:a9),(a10v ? %a10%:a10))
}

Exprt(e)
{
	global Exprol
	c1:=Chr(1),f:=1,f1:=1
	While,(f:=RegExMatch(e,"S)""(?:[^""]|"""")*""",m,f))
	{
		t1:=SubStr(m,2,-1)
	,	t1:=StrReplace(t1,"""""","""")
	,	t1:=StrReplace(t1,"'","'27")
	,	t1:=StrReplace(t1,"````",c1)
	,	t1:=StrReplace(t1,"``n","`n")
	,	t1:=StrReplace(t1,"``r","`r")
	,	t1:=StrReplace(t1,"``b","`b")
	,	t1:=StrReplace(t1,"``t","`t")
	,	t1:=StrReplace(t1,"``v","`v")
	,	t1:=StrReplace(t1,"``a","`a")
	,	t1:=StrReplace(t1,"``f","`f")
	,	t1:=StrReplace(t1,c1,"``")
		SetFormat,IntegerFast,Hex
		While,RegExMatch(t1,"iS)[^\w']",c)
		t1:=StrReplace(t1,c,"'" . SubStr("0" . SubStr(Asc(c),3),-1))
		SetFormat,IntegerFast,D
		e1.=SubStr(e,f1,f-f1) . c1 . "l" . t1 . c1,f+=StrLen(m),f1:=f
	}
	e1.=SubStr(e,f1),e:=InStr(e1,"""")? "":e1,e1:="",e:=RegExReplace(e,"S)/\*.*?\*/|[ \t]`;.*?(?=\r|\n|$)")
,	e:=StrReplace(e,"`t"," ")
,	e:=RegExReplace(e,"S)([\w#@\$] +|\) *)(?=" . Chr(1) . "*[\w#@\$\(])","$1 . ")
,	e:=StrReplace(e," . ","\.")
,	e:=StrReplace(e," ")
,	f:=1,f1:=1
	While,(f:=RegExMatch(e,"iS)(^|[^\w#@\$\.'])(0x[0-9a-fA-F]+|\d+(?:\.\d+)?|\.\d+)(?=[^\d\.]|$)",m,f))
	{
		If ((m1="\") && (RegExMatch(m2,"\.\d+")))
		m1:="",m2:=SubStr(m2,2)
		m2+=0
		m2:=StrReplace(m2,".","'2E",,1)
		e1.=SubStr(e,f1,f-f1) . m1 . c1 . "n" . m2 . c1,f+=StrLen(m),f1:=f
	}
	e:=e1 . SubStr(e,f1),e1:="",e:=RegExReplace(e,"S)(^|\(|[^" . c1 . "-])-" . c1 . "n","$1" . c1 . "n'2D")
,	e:=StrReplace(e,c1 "n",c1 "l")
,	e:=RegExReplace(e,"\\\.(\d+)\.(\d+)",c1 . "l$1'2E$2" . c1)
,	e:=RegExReplace(RegExReplace(e,"S)(%[\w#@\$]{1,253})%","$1"),"S)(?:^|[^\w#@\$'" . c1 . "])\K[\w#@\$]{1,253}(?=[^\(\w#@\$]|$)",c1 . "v$0" . c1),f:=1,f1:=1
	While,(f:=RegExMatch(e,"S)(^|[^\w#@\$'])([\w#@\$]{1,253})(?=\()",m,f))
	{
		t1:=f+StrLen(m)
		If (SubStr(e,t1+1,1)=")")
		ac=0
		Else
		{
			If !Exprmlb(e,t1,fa)
			Return
			fa:=StrReplace(fa,"`,","`,",c)
			ac:=c+1
		}
		e1.=SubStr(e,f1,f-f1) . m1 . c1 . "f" . ac . "'20" . m2 . c1,f+=StrLen(m),f1:=f
	}
	e:=e1 . SubStr(e,f1),e1:=""
,	e:=StrReplace(e,"\." c1 "vNot" c1 "\.","!")
,	e:=StrReplace(e,"\." c1 "vAnd" c1 "\.","&&")
,	e:=StrReplace(e,"\." c1 "vOr" c1 "\.","||")
,	e:=StrReplace(e,c1 "vNot" c1 "\.","!")
,	e:=StrReplace(e,c1 "vAnd" c1 "\.","&&")
,	e:=StrReplace(e,c1 "vOr" c1 "\.","||")
,	e:=RegExReplace(e,"S)(^|[^" . c1 . "\)-])-" . c1 . "(?=[lvf])","$1\-" . c1)
,	e:=RegExReplace(e,"S)(^|[^" . c1 . "\)&])&" . c1 . "(?=[lvf])","$1\&" . c1)
,	e:=RegExReplace(e,"S)(^|[^" . c1 . "\)\*])\*" . c1 . "(?=[lvf])","$1\*" . c1)
,	e:=RegExReplace(e,"S)(^|[^" . c1 . "\)])(\+\+|--)" . c1 . "(?=[lvf])","$1\$2" . c1)
,	t1:=RegExReplace(Exprol,"S)[\\\.\*\?\+\[\{\|\(\)\^\$]","\$0")
,	t1:=StrReplace(t1,"`n","|")
,	e:=RegExReplace(e,"S)" . t1,c1 . "o$0" . c1)
,	e:=StrReplace(e,"`,",c1 "`," c1)
,	e:=StrReplace(e,"(",c1 "(" c1)
,	e:=StrReplace(e,")",c1 ")" c1)
,	e:=StrReplace(e,c1 . c1,c1)
	If RegExMatch(e,"S)" . c1 . "[^lvfo\(\),\n]")
	Return
	e:=SubStr(e,2,-1),f:=0
	While,(f:=InStr(e,"'",False,f + 1))
	{
		If ((t1:=SubStr(e,f+1,2))<>27)
		e:=StrReplace(e,"'" t1,Chr("0x" . t1))
	}
	e:=StrReplace(e,"'27","'")
	Return,e
}

Exprols(o1,o2)
{
	Return,StrLen(o2)-StrLen(o1)
}

Exprpr(o)
{
	global Exprot
	t:=InStr(Exprot,"`n" . o . " ")+StrLen(o)+2
	Return,SubStr(Exprot,t,InStr(Exprot," ",0,t)-t)
}

Expras(o)
{
	global Exprot
	Return,SubStr(Exprot,InStr(Exprot," ",0,InStr(Exprot,"`n" . o . " ")+StrLen(o)+2)+1,1)
}

Exprac(o)
{
	global Exprot
	Return,SubStr(Exprot,InStr(Exprot,"`n",0,InStr(Exprot,"`n" . o . " ")+1)-1,1)
}

Exprmlb(ByRef s,p,ByRef o="",b="(",e=")")
{
	t:=SubStr(s,p),bc:=0,VarSetCapacity(o,StrLen(t))
	If (SubStr(t,1,1)<>b)
	Return,0
	Loop,Parse,t
	{
		lf:=A_LoopField
		If lf=%b%
		bc++
		Else If lf=%e%
		{
			bc--
			If bc=0
			Return,p
		}
		Else If bc=1
		o.=lf
		p++
	}
	Return,0
}

Exprp1(ByRef dl,d)
{
	dl.=((dl="")? "":Chr(1)) . d
}

Exprp2(ByRef dl)
{
	t:=InStr(dl,Chr(1),0,0),t ?(t1:=SubStr(dl,t+1),dl:=SubStr(dl,1,t-1)):(t1:=dl,dl:="")
	Return,t1
}

Exprp3(ByRef dl)
{
	Return,SubStr(dl,InStr(dl,Chr(1),0,0)+1)
}

;;;;end of EVAL

VarWrite(Key := "", Value := "")		;_____________ VarWrite (Function) __________________
{
Static Var	;"Static" variables are always implicitly "local", but differ from "locals" variables because their values are remembered between calls.

	if Key =	;if "Key" is blank
	{
	if Value = GetVar
	return, Var

	Var = %Value%
	return
	}

Value := RegExReplace(Value, "#","##")	;replace any "#" to "##" (Ensures that no String\Character is enclosed by "##")
Value := RegExReplace(Value, "`r`n","#L#")	;replace any New Line "`r`n" to "#L#" (these replacements will be the only String\Character enclosed by "##") 

	If RegExMatch(Var, "m)^" Key "=""(.*)""" , Matched) 	;"m)" Search for a line \ "^" that starts by \ "Key" the string choosed by user \ followed by =" string \ (.*)"" match any string until last " character is found in that line
	{					;All the match wil be stored in "Matched" variable \ the match inside first "( )" will be stored in "Matched1" \ the match inside second "( )" will be stored in "Matched2", and so on ...
	if (Matched1 == Value)				;first " treats second " as literal character \ "= =" case sensitive (a is not A)
	return					;return if the value to be rewritten is the same as the "key" value (Faster this way)

	Value := RegExReplace(Value, "\$", "$$$$")	;replace any "$" to "$$" (necessary because "$" is a special character in RegExReplace 3rd parameter)
					;"\" treats "$" as literal character  -  "$$$$" the first "$" treats the second "$" as literal character, so, "$$$$" = "$$" literal string in RegExReplace 3rd parameter

	Var := RegExReplace(Var, "m)(^" Key "=).*", "$1""" Value """")	;[""], first " treats second " as literal character, so, """" means that there is a literal " character between two Special " characers 
	}						;"$1", in this case, it's a backreference to (^" Key "=) \ $2 would be  a backreference to the second ( ) \ $3 for the 3rd ( ) \ and so on ...
	else						;".*" match any string (the rest of the string left) of that line
	Var = %Var%`r`n%Key%="%Value%"			;"value", the value specified by user
}


VarRead(Key := "", Variable := "")	;_______________ VarRead (Function) by V for Vendetta________________
{
Static Var	;"Static" variables are always implicitly "local", but differ from "locals" variables because their values are remembered between calls.

	if Key =	;if "Key" is blank
	{
	Var = %Variable%
	return
	}

RegExMatch(Var, "m)^" Key "=""(.*)""" , Matched)
					;"m)" Search for a line \ "^" that starts by \ "Key" the string choosed by user \ followed by  =" string
					;(.*)"" match any string until last " character from that line is found
					;All the match wil be stored in "Matched" variable
					;the match inside first "( )" will be stored in "Matched1"
					;the match inside second "( )" will be stored in "Matched2", and so on ...
					;first " treats second " as literal character

Matched1 := RegExReplace(Matched1, "##(*SKIP)(*F)|#L#", "`r`n")	;replace any "#L#" to "`r`n" (any "##" will be skipped)
Matched1 := RegExReplace(Matched1, "##", "#")		;replace any "##" to "#" (necessary because "VarWrite( )" Function replaces any "#" to "##")

return, Matched1
}

WM_MOUSEMOVE() ; by Alpha Bravo
{
    static CurrControl, PrevControl, _TT  ; _TT is kept blank for use by the ToolTip command below.
    CurrControl := A_GuiControl
    If (CurrControl <> PrevControl and not InStr(CurrControl, " "))
    {
        ToolTip  ; Turn off any previous tooltip.
        SetTimer, DisplayToolTip, 1
        PrevControl := CurrControl
    }
    return

    DisplayToolTip:
    SetTimer, DisplayToolTip, Off
    ToolTip % %CurrControl%_TT  ; The leading percent sign tell it to use an expression.
    return

    RemoveToolTip:
    SetTimer, RemoveToolTip, Off
    ToolTip
    return
}

	;tested in Autohotkey 32 bit unicode

	;"ListView" control treats charcaters such as "space", "tab", "`r" (carriage return), "`n" (linefeed), "`r`n" (new lines) as invisible characters
	;The characters are there, but they are invisibles from "ListView" control
	;if saved to a ".txt" file for example, these characters can be seen\detected, such as "space", "tab", "`r`n" (new lines), etc, etc

	;"Separator" parameter from "ListViewSave( )" and "ListViewLoad( )" functions can be any character (Except "#" character)
	;"#" is used to Save and Load special characters ("S", "R" and "N") \ "#S#" = "Separator" character \ "#R#" = `r (carriage return) \ "#N#" = `n (linefeed)
	;"$", though no bugs was found while testing "$" as "Separator" character, "$" is not recommended to be used as such, because it is a special character in "RegExReplace" third parameter and  "ListViewLoad( )" function does not escape it with another "$" character!
ListViewSave(BeginningMessage:="",Separator := "	")	;_________________ ListView Save (Function) __________________
{
	;Default BeginningMessage is "Blank"! This argument will allow this function to "add" an extra message at the beginning of the text. DO NOT GO OVERBOARD SPECIFYING THIS FIELD EVERY CALL, calling this function with this field ONCE IS ALREADY ENOUGH because this function will remember it all the time
	; To Remove the Comment on Beginning Message, put variable A_Space
	
	;Default "Separator" is "Tab" Character \ "Separator" can be any character except "#" \ Avoid using "$" as "Separator" because it is a special character in "RegExReplace" third parameter!
	
	Static ExtraMessage	;"Static" variables are always implicitly "local", but differ from "locals" variables because their values are remembered between calls.
	if BeginningMessage=%A_Space%
	{
		ExtraMessage=
	}
	else if BeginningMessage<>
	{
		ExtraMessage:=BeginningMessage
	}
	TableText.=ExtraMessage ; If an ExtraMessage is present, the starting line of the database will have an extra message
	

TotalColumns := LV_GetCount("Column")	;"LV_GetCount("Column")" retrieves total columns in the listview control

	
	;;; I just added this for ajom purposes, if you want to reuse this func on your own script remove these lines
	adder:=1000/(LV_GetCount()+1) ;;; +1 adds the header on the counting
	progress=0
	gosub,showprogress
	;;;;;
	
	loop, % LV_GetCount( ) + 1	;"LV_GetCount( )" retrieves listview total rows \ "+1" plus the listview Columns "Header" row
	{
	RowNumber := a_index - 1

	if RowNumber > 0	;"0" is the Columns Header Row (not necessary to add "`r`n" before this row)
	TableText .= "`r`n"

		loop, %TotalColumns%
		{
		LV_GetText(TempText, RowNumber, a_index)		;"TempText", variable to store value from a given Cell
							;"RowNumber", "0" gets text from columns "Header" Row  
							;"a_index" is the column number

		TempText := RegExReplace(TempText, "#", "##")		;ensures that no character\string is enclosed by "##"
		TempText := RegExReplace(TempText, "\Q" Separator, "#S#")	;replace any "Separator" character with "#S#" string - "\Q" treats any RegEx Special characters at its right as literal characters (except "\E" special string)
		TempText := RegExReplace(TempText, "\r", "#R#")		;"\r" represents "carriage return" character (replace any "`r" with "#R#")
		TempText := RegExReplace(TempText, "\n", "#N#")		;"\n" represents "linefeed" character (replace any "`n" with "#N#")
	
		if a_index = 1
		TableText .= TempText
		else
		TableText .= Separator TempText
		}
		
	;;;; delete this also its for ajom purposes
	progress+=adder
	GuiControl,MainGUI:, MyProgress,%progress%
	;;;;;
	}

TableText .= "`r`nEnd >`r`r`r`r`r`r`r`r`r`r< End`r`n`r`n"		;"End >`r`r`r`r`r`r`r`r`r`r< End" indicates the "End" of ListView contents (Extra texts, like "Keys = Values" can be added below)
																;since any "`r" (carriage return) is saved as "#R#", it is not possible to find any "`r`r`r`r`r`r`r`r`r`r" string above this line

;;;; ajom purpose you can delete this also
gosub,hideprogress
;;;;

return, TableText
}


ListViewLoad(FileText:="",BeginningMessage:="", ColOptions := "AutoHdr", RowOptions := "", Separator := "	")	;__________________ ListView Load (Function) _____________________
{
	;Default BeginningMessage is "Blank"! This argument will allow this function to detect what the "ListViewSave" Extra Added. This value will replace any occurence on the "FileText" with a blank value later. DO NOT GO OVERBOARD SPECIFYING THIS FIELD EVERY CALL, calling this function with this field ONCE IS ALREADY ENOUGH because this function will remember it all the time
	;Default "Separator" is "Tab" Character \ "Separator" can be any character except "#" \ Avoid using "$" as "Separator" because it is a special character in "RegExReplace" third parameter!
	;Default "ColOptions" is "50", which is the columns width \ Others options such as sort type can be specified, for example: "50 Integer" or "Auto Integer" or "100 Text Logical", etc, etc ... I Changed it to AutoHdr because I added custom function to it
	;Default "RowOptions" is "Blank"! Row options such as "Check", "Select" or "Check Select", etc, etc can be specified! (Probably not necessary, but added this parameter anyway)
	;The function returns all the text below "End >`r`r`r`r`r`r`r`r`r`r< End" line! If the returned text contains "Key = Values" contents, "VarRead( )" function can be used to read the Keys values!
	
	Static ExtraMessage	;"Static" variables are always implicitly "local", but differ from "locals" variables because their values are remembered between calls.
	if BeginningMessage=%A_Space%
	{
		ExtraMessage=
	}
	else if BeginningMessage<>
	{
		ExtraMessage:=BeginningMessage
	}
	if FileText=
	{
		return
	}

LV_Delete( )	;delete all rows

loop, % LV_GetCount("Column")	;"LV_GetCount("Column")" retrieves listview total columns
LV_DeleteCol(1)		;Delete "Column 1" multiple times until there are no more columns to delete

	if ExtraMessage<> ; if begginingmessage has a value/set by the user
	{
		FileText := StrReplace(FileText,ExtraMessage,"") ; change all begginingmessage into a blank value so that it will not interefere with further operation
	}

	Loop, Parse, FileText, `n, `r	;"`n" is the Delimiter \ any "`r" will be excluded from the beginning and end of each substring (remove any extra "`r" character added while saving)
	{
		if (A_LoopField == "End >`r`r`r`r`r`r`r`r`r`r< End")	;"= =" is case-sensitive \ since any "`r" (carriage return) is saved as "#R#", if "`r`r`r`r`r`r`r`r`r`r" string is found indicates the end of lisview contents
		{
		RegExMatch(FileText, "s)End >`r`r`r`r`r`r`r`r`r`r< End(.*)", ExtraText)		;"s)" allows "." to match "`r`n" newlines too \ "ExtraText" contains all the match found \ "ExtraText1" contains the match from the first "( )" \ "ExtraText2" contains the match from the second "( )" \ and so on ...
		if ColOptions=AutoHdr
		{
			Loop %NextCol%
			{
				LV_ModifyCol(A_Index,"AutoHdr")
				
			}
		}
		return, ExtraText1						;The function returns all the text below the first "End >`r`r`r`r`r`r`r`r`r`r< End" line\string found 
		}

	RowNumber := a_index - 1

	if RowNumber > 0	;"0" is the columns Header Row (This Row already exist by default, so, does not need to be added)
	LV_Add( )		;add a row

		loop, parse, A_LoopField, %Separator%
		{								;"s)" option allows "." to match "`r`n" newlines too \ "?", prevents skipping all the string at once between the first "#" and last "#" character! 
		TempText := RegExReplace(A_LoopField, "s)#S#|#.*?#(*SKIP)(*F)", Separator)		;skip any "# 0 or more characters #", but, any "#S#" shall be replaced with "Separator" character
		TempText := RegExReplace(TempText, "s)#R#|#.*?#(*SKIP)(*F)", "`r")		;skip any "# 0 or more characters #", but, any "#R#" shall be replaced with "carriage return" character (`r)
		TempText := RegExReplace(TempText, "s)#N#|#.*?#(*SKIP)(*F)", "`n")		;skip any "# 0 or more characters #", but, any "#N#" shall be replaced with "linefeed" character (`n)
		TempText := RegExReplace(TempText, "##", "#")				;remove any extra "#" character added while saving

			if RowNumber = 0
			{
			NextCol++
			LV_InsertCol(NextCol, ColOptions, TempText)	;"NextCol" the new column is added to the end of the list (to the right of the last column)
								;"TempText" is the column Title \ "ColOptions" specify columns options such as "width", "sort type", etc, etc, ...
			}	
			else
			{
				LV_Modify( RowNumber, "Col" a_index " " RowOptions, TempText)	;Fill ListView Control Cells \ "TempText" is the Cell Value
									;"RowOptions", specify row options such as "Select", "Check" or "Select Check", etc, etc (propably not necessary, but added it anyway)
			}
		}
	}
}

DirExist(DirName)
{
    loop Files, % DirName, D
        return A_LoopFileAttrib
}

/*
    Displays a standard dialog that allows the user to save a file.
    Parámetros:
    Parameters:
        Owner / Title:
            The identifier of the window that owns this dialog. This value can be zero.
            An Array with the identifier of the owner window and the title. If the title is an empty string, it is set to the default.
        FileName:
            The path to the file or directory selected by default. If you specify a directory, it must end with a backslash.
        Filter:
            Specify a file filter. You must specify an object, each key represents the description and the value the file types.
            To specify the filter selected by default, add the "`n" character to the value.
		FileTypeIndex:
			Specify the Chosen Row at Filter Dropdownlist. Defaults to first row
			Take note that the filter dropdownlist will first sort the lists in alphanumerical order before the dropdownlist will choose the row...
        CustomPlaces:
            Specify an Array with the custom directories that will be displayed in the left pane. Missing directories will be omitted.
            To specify the location in the list, specify an Array with the directory and its location (0 = Lower, 1 = Upper).
        Options:
            Determina el comportamiento del diálogo. Este parámetro debe ser uno o más de los siguientes valores.
                0x00000002  (FOS_OVERWRITEPROMPT) = When saving a file, prompt before overwriting an existing file of the same name.
                0x00000004  (FOS_STRICTFILETYPES) = Only allow the user to choose a file that has one of the file name extensions specified through Filter.
                0x00040000 (FOS_HIDEPINNEDPLACES) = Hide items shown by default in the view's navigation pane.
                0x10000000  (FOS_FORCESHOWHIDDEN) = Include hidden and system items.
                0x02000000  (FOS_DONTADDTORECENT) = Do not add the item being opened or saved to the recent documents list (SHAddToRecentDocs).
            You can check all available values at https://msdn.microsoft.com/en-us/library/windows/desktop/dn457282(v=vs.85).aspx.
    Return:
        Returns 0 if the user canceled the dialog, otherwise returns the path of the selected file.
*/
SaveFile(Owner, FileName := "", Filter := "", FileTypeIndex := 1, CustomPlaces := "", Options := 0x6)
{
    ; IFileSaveDialog interface
    ; https://msdn.microsoft.com/en-us/library/windows/desktop/bb775688(v=vs.85).aspx
    local IFileSaveDialog := ComObjCreate("{C0B4E2F3-BA21-4773-8DBA-335EC946EB8B}", "{84BCCD23-5FDE-4CDB-AEA4-AF64B83D78AB}")
        ,           Title := IsObject(Owner) ? Owner[2] . "" : ""
        ,           Flags := Options     ; FILEOPENDIALOGOPTIONS enumeration (https://msdn.microsoft.com/en-us/library/windows/desktop/dn457282(v=vs.85).aspx)
        ,      IShellItem := PIDL := 0   ; PIDL recibe la dirección de memoria a la estructura ITEMIDLIST que debe ser liberada con la función CoTaskMemFree
        ,             Obj := {}, foo := bar := ""
        ,       Directory := FileName
    Owner := IsObject(Owner) ? Owner[1] : (WinExist("ahk_id" . Owner) ? Owner : 0)
    Filter := IsObject(Filter) ? Filter : {"All files": "*.*"}


    if ( FileName != "" )
    {
        if ( InStr(FileName, "\") )
        {
            if !( FileName ~= "\\$" )    ; si «FileName» termina con "\" se trata de una carpeta
            {
                local File := ""
                SplitPath FileName, File, Directory
                ; IFileDialog::SetFileName
                ; https://msdn.microsoft.com/en-us/library/windows/desktop/bb775974(v=vs.85).aspx
                DllCall(NumGet(NumGet(IFileSaveDialog+0)+15*A_PtrSize), "UPtr", IFileSaveDialog, "UPtr", &File)
            }
            
            while ( InStr(Directory,"\") && !DirExist(Directory) )                   ; si el directorio no existe buscamos directorios superiores
                Directory := SubStr(Directory, 1, InStr(Directory, "\",, -1) - 1)    ; recupera el directorio superior
            if ( DirExist(Directory) )
            {
                DllCall("Shell32.dll\SHParseDisplayName", "UPtr", &Directory, "Ptr", 0, "UPtrP", PIDL, "UInt", 0, "UInt", 0)
                DllCall("Shell32.dll\SHCreateShellItem", "Ptr", 0, "Ptr", 0, "UPtr", PIDL, "UPtrP", IShellItem)
                ObjRawSet(Obj, IShellItem, PIDL)
                ; IFileDialog::SetFolder method
                ; https://msdn.microsoft.com/en-us/library/windows/desktop/bb761828(v=vs.85).aspx
                DllCall(NumGet(NumGet(IFileSaveDialog+0)+12*A_PtrSize), "Ptr", IFileSaveDialog, "UPtr", IShellItem)
            }
        }
        else    ; si «FileName» es únicamente el nombre de un archivo
            DllCall(NumGet(NumGet(IFileSaveDialog+0)+15*A_PtrSize), "UPtr", IFileSaveDialog, "UPtr", &FileName)
    }


    ; COMDLG_FILTERSPEC structure
    ; https://msdn.microsoft.com/en-us/library/windows/desktop/bb773221(v=vs.85).aspx
    local Description := "", FileTypes := "" ; , FileTypeIndex := 1
    ObjSetCapacity(Obj, "COMDLG_FILTERSPEC", 2*Filter.Count() * A_PtrSize)
    for Description, FileTypes in Filter
    {
        FileTypeIndex := InStr(FileTypes,"`n") ? A_Index : FileTypeIndex
        ObjRawSet(Obj, "#" . A_Index, Trim(Description)), ObjRawSet(Obj, "@" . A_Index, Trim(StrReplace(FileTypes,"`n")))
        NumPut(ObjGetAddress(Obj,"#" . A_Index), ObjGetAddress(Obj,"COMDLG_FILTERSPEC") + A_PtrSize * 2*(A_Index-1))        ; COMDLG_FILTERSPEC.pszName
        NumPut(ObjGetAddress(Obj,"@" . A_Index), ObjGetAddress(Obj,"COMDLG_FILTERSPEC") + A_PtrSize * (2*(A_Index-1)+1))    ; COMDLG_FILTERSPEC.pszSpec
    }

    ; IFileDialog::SetFileTypes method
    ; https://msdn.microsoft.com/en-us/library/windows/desktop/bb775980(v=vs.85).aspx
    DllCall(NumGet(NumGet(IFileSaveDialog+0)+4*A_PtrSize), "UPtr", IFileSaveDialog, "UInt", Filter.Count(), "UPtr", ObjGetAddress(Obj,"COMDLG_FILTERSPEC"))

    ; IFileDialog::SetFileTypeIndex method
    ; https://msdn.microsoft.com/en-us/library/windows/desktop/bb775978(v=vs.85).aspx
    DllCall(NumGet(NumGet(IFileSaveDialog+0)+5*A_PtrSize), "UPtr", IFileSaveDialog, "UInt", FileTypeIndex)


    if ( IsObject(CustomPlaces := IsObject(CustomPlaces) || CustomPlaces == "" ? CustomPlaces : [CustomPlaces]) )
    {
        local Directory := ""
        for foo, Directory in CustomPlaces    ; foo = index
        {
            foo := IsObject(Directory) ? Directory[2] : 0    ; FDAP enumeration (https://msdn.microsoft.com/en-us/library/windows/desktop/bb762502(v=vs.85).aspx)
            if ( DirExist(Directory := IsObject(Directory) ? Directory[1] : Directory) )
            {
                DllCall("Shell32.dll\SHParseDisplayName", "UPtr", &Directory, "Ptr", 0, "UPtrP", PIDL, "UInt", 0, "UInt", 0)
                DllCall("Shell32.dll\SHCreateShellItem", "Ptr", 0, "Ptr", 0, "UPtr", PIDL, "UPtrP", IShellItem)
                ObjRawSet(Obj, IShellItem, PIDL)
                ; IFileDialog::AddPlace method
                ; https://msdn.microsoft.com/en-us/library/windows/desktop/bb775946(v=vs.85).aspx
                DllCall(NumGet(NumGet(IFileSaveDialog+0)+21*A_PtrSize), "UPtr", IFileSaveDialog, "UPtr", IShellItem, "UInt", foo)
            }
        }
    }


    ; IFileDialog::SetTitle method
    ; https://msdn.microsoft.com/en-us/library/windows/desktop/bb761834(v=vs.85).aspx
    DllCall(NumGet(NumGet(IFileSaveDialog+0)+17*A_PtrSize), "UPtr", IFileSaveDialog, "UPtr", Title == "" ? 0 : &Title)

    ; IFileDialog::SetOptions method
    ; https://msdn.microsoft.com/en-us/library/windows/desktop/bb761832(v=vs.85).aspx
    DllCall(NumGet(NumGet(IFileSaveDialog+0)+9*A_PtrSize), "UPtr", IFileSaveDialog, "UInt", Flags)


    ; IModalWindow::Show method
    ; https://msdn.microsoft.com/en-us/library/windows/desktop/bb761688(v=vs.85).aspx
    local Result := FALSE
    if ( !DllCall(NumGet(NumGet(IFileSaveDialog+0)+3*A_PtrSize), "UPtr", IFileSaveDialog, "Ptr", Owner, "UInt") )
    {
        ; IFileDialog::GetFileTypeIndex method
        ; https://msdn.microsoft.com/es-es/bb775958
        DllCall(NumGet(NumGet(IFileSaveDialog+0)+6*A_PtrSize), "UPtr", IFileSaveDialog, "UIntP", FileTypeIndex)

        ; IFileDialog::GetResult method
        ; https://msdn.microsoft.com/en-us/library/windows/desktop/bb775964(v=vs.85).aspx
        if ( !DllCall(NumGet(NumGet(IFileSaveDialog+0)+20*A_PtrSize), "UPtr", IFileSaveDialog, "UPtrP", IShellItem) )
        {
            VarSetCapacity(Result, 32767 * 2, 0)
            DllCall("Shell32.dll\SHGetIDListFromObject", "UPtr", IShellItem, "UPtrP", PIDL)
            DllCall("Shell32.dll\SHGetPathFromIDListEx", "UPtr", PIDL, "Str", Result, "UInt", 32767, "UInt", 0)
            ObjRawSet(Obj, IShellItem, PIDL)
        }
    }


    for foo, bar in Obj      ; foo = IShellItem interface (ptr)  |  bar = PIDL structure (ptr)
        if foo is integer    ; IShellItem?
            ObjRelease(foo), DllCall("Ole32.dll\CoTaskMemFree", "UPtr", bar)
    ObjRelease(IFileSaveDialog)

    return Result ? {File: Result, FileTypeIndex: FileTypeIndex} : FALSE
} ; https://github.com/flipeador/AutoHotkey/blob/master/Lib/dlg/SaveFile.ahk
;;~~~~~~~~~~~~~~~~~~~~~~~End of Functions~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

aboutguiguisize:
Gui,aboutgui:Default
links=text39,text40,text41,text42,text33,text34,text50
buttons=text43
commandparam=text35,text36,text37,text38,tababout,%links%,%buttons%,text44
loop,parse,commandparam,`,
{
	if InStr(links,A_LoopField)
	{
		Anchor(A_LoopField,"w")
	}
	else if InStr(buttons,A_LoopField)
	{
		Anchor(A_LoopField,"x0.5 y")
	}
	else
	{
		Anchor(A_LoopField,"wh")
	}
}
return

MainGUIGuiSize:
Gui, MainGUI:Default
DllCall("QueryPerformanceCounter", "Int64P", t0)


wv1d4_hv1d2_param=terrainchoice

xv1d2_wv1d2_param=injectto

xv1d2_wv1d2_h_param=showitems,announcerview,reportshow
xv2d3_wv1d3_hv1d2_param=hudchoice
xv1d3_wv1d3_hv1d2_param=wardchoice

xv1d4_wv1d4_hv1d2_param=weatherchoice
xv2d4_wv1d4_hv1d2_param=multikillchoice
xv3d4_wv1d4_hv1d2_param=emblemchoice

yv1d2_wv1d3_hv1d2_param=musicchoice

xv1d3_yv1d2_wv1d3_hv1d2_param=cursorchoice,direcreepchoice
xv2d3_yv1d2_wv1d3_hv1d2_param=loadingscreenchoice,radcreepchoice

wv1d2_h_param=herochoice,tauntview,errorshow
wv1d3_h_param=courierchoice

x_y_param=text31,text51
y_w_param=datadirview,hdatadirview,MyProgress,searchnofound
x_h_param=text46
w_h_param=invlv,searchshow,itemview,chview,OuterTab,%innertabparam%,extfilelist,slotstats

wv1d2_param=injectfrom

xv1d2_param=text4,text32
xv5d16_param=extlistup,extlistdown
xv11d16_param=extlistrefresh

xv1d3_y_param=text7,text17,text20
xv2d3_y_param=text8,text16,text19
xv1d2_y_param=text23,usemiscon,text26,useextfile

x_param=text1,text2,text25,chbar,text27,chsave,text28,text45
y_param=text6,text18,text30
w_param=searchbar,idbar,namebar,prefabbar,itemslotbar,modelpathbar,heroesbar,invdirview,mdirview,text24,giloc,dota2dir,useextitemgamefile,useextportraitfile
h_param=statscalibrator

commandparam=w_h_param,x_y_param,y_w_param,x_param,y_param,xv1d2_wv1d2_h_param,w_param,wv1d3_h_param,wv1d2_param,xv1d2_wv1d2_param,xv1d2_param,xv1d2_y_param,wv1d2_h_param,xv2d3_wv1d3_hv1d2_param,xv1d3_wv1d3_hv1d2_param,xv1d3_y_param,xv2d3_y_param,wv1d4_hv1d2_param,xv1d4_wv1d4_hv1d2_param,xv2d4_wv1d4_hv1d2_param,xv3d4_wv1d4_hv1d2_param,yv1d2_wv1d3_hv1d2_param,xv2d3_yv1d2_wv1d3_hv1d2_param,xv1d3_yv1d2_wv1d3_hv1d2_param,x_h_param,xv5d16_param,xv11d16_param,h_param
loop,parse,commandparam,`,
{
	StringTrimRight,command,A_LoopField,5
	sizesave=%A_LoopField%
	tempo := StrReplace(A_LoopField,"v","v",sizeint)
	loop %sizeint%
	{
		StringReplace,command,command,% SubStr(sizesave,InStr(sizesave,"v",,,A_Index)+1,InStr(sizesave,"_",,InStr(sizesave,"v",,,A_Index)) - InStr(sizesave,"v",,,A_Index)-1),% StrJoin(Eval(StrReplace(SubStr(sizesave,InStr(sizesave,"v",,,A_Index)+1,InStr(sizesave,"_",,InStr(sizesave,"v",,,A_Index)) - InStr(sizesave,"v",,,A_Index)-1),"d","/")), "`n"),1
	}
	StringReplace,command,command,v,,1
	StringReplace,command,command,_,%A_Space%,1
	loop,parse,%A_LoopField%,`,
	{
		Anchor(A_LoopField,command)
	}
}
GuiControl,MoveDraw,searchnofound
GuiControl,MoveDraw,text30
GuiControl,MoveDraw,text31
GuiWidth := A_GuiWidth
DllCall("QueryPerformanceCounter", "Int64P", t1)
WinSet, Redraw, , A
Return

leakdestroyer:
tmp:=tmp1:=vpktmp:=npchero:=npcunit:=filestring1:=filestring2:=filefrom:=fileto:=masterfilecontent:=portstring:=""
return

externalfiles:
if useextfile=1
{
	Gui,MainGUI:Show, NoActivate,AJOM's Dota 2 MOD Master ; remove that irritating items per second
	IfNotExist,%A_ScriptDir%\Generated MOD\
	{
		FileCreateDir, %A_ScriptDir%\Generated MOD
	}
	else ifexist,%A_ScriptDir%\Generated MOD\pak01_dir\
	{
		FileRemoveDir,%A_ScriptDir%\Generated MOD\pak01_dir,1
	}
	if A_DefaultListView<>extfilelist
	{
		Gui, MainGUI:ListView, extfilelist
	}
	Loop % LV_GetCount()
	{
		LV_GetText(tmpstring,A_Index,2)
		GuiControl,Text,searchnofound,Merging External Files with the Operation Files`, Current Folder : %tmpstring%
		if tmpstring="OPERATION FILES"
		{
			if useextportraitfile<>1
			{
				ifnotexist,%A_ScriptDir%\Plugins\VPKCreator\backup\
				{
					FileCreateDir,%A_ScriptDir%\Plugins\VPKCreator\backup
				}
				FileMove,%A_ScriptDir%\Plugins\VPKCreator\pak01_dir\scripts\npc\portraits.txt,%A_ScriptDir%\Plugins\VPKCreator\backup\,1
			}
			if useextitemgamefile<>1
			{
				ifnotexist,%A_ScriptDir%\Plugins\VPKCreator\backup\
				{
					FileCreateDir,%A_ScriptDir%\Plugins\VPKCreator\backup
				}
				FileMove,%A_ScriptDir%\Plugins\VPKCreator\pak01_dir\scripts\items\items_game.txt,%A_ScriptDir%\Plugins\VPKCreator\backup\,1
			}
			FileMoveDir,%A_ScriptDir%\Plugins\VPKCreator\pak01_dir,%A_ScriptDir%\Generated MOD\pak01_dir,2
		}
		else if (A_Index=LV_GetNext(A_Index-1,"Checked"))
		{
			LV_GetText(tmpstring,A_Index,7)
			filecopydir,%tmpstring%\,%A_ScriptDir%\Generated MOD\pak01_dir,1
		}
	}
	if useextportraitfile<>1
	{
		FileMove,%A_ScriptDir%\Plugins\VPKCreator\backup\portraits.txt,%A_ScriptDir%\Generated MOD\pak01_dir\scripts\npc\,1
	}
	else
	{
		FileMove,%A_ScriptDir%\Plugins\VPKCreator\backup\portraits.txt,%A_ScriptDir%\Generated MOD\pak01_dir\scripts\npc\,0
	}
	if useextitemgamefile<>1
	{
		FileMove,%A_ScriptDir%\Plugins\VPKCreator\backup\items_game.txt,%A_ScriptDir%\Generated MOD\pak01_dir\scripts\items\,1
	}
	else
	{
		FileMove,%A_ScriptDir%\Plugins\VPKCreator\backup\items_game.txt,%A_ScriptDir%\Generated MOD\pak01_dir\scripts\items\,0
	}
	FileMoveDir,%A_ScriptDir%\Generated MOD\pak01_dir,%A_ScriptDir%\Plugins\VPKCreator\pak01_dir,2
}
return

extlistrefresh:
Gui, MainGUI:+Disabled
IfNotExist,%A_ScriptDir%\External Files\
{
	FileCreateDir,%A_ScriptDir%\External Files\
}
else
{
	GuiControl, MainGUI:-Redraw, extfilelist
	if A_DefaultListView<>extfilelist
	{
		Gui, MainGUI:ListView, extfilelist
	}
	LV_Delete()
	Loop, Files,%A_ScriptDir%\External Files\*,D
	{
		intsaver:=position:=boolean:=boolean1:=""
		GuiControl,Text,searchnofound,External Files :  Found %A_LoopFileName% : Counting Model Files Present
		Loop, Files,%A_LoopFilePath%\*.vmdl_c,R
		{
			intsaver=%A_Index%
		}
		GuiControl,Text,searchnofound,External Files :  Found %A_LoopFileName% : Counting Particle Files Present
		Loop, Files,%A_LoopFilePath%\*.vpcf_c,R
		{
			position=%A_Index%
		}
		IfExist,%A_LoopFilePath%\scripts\items\items_game.txt
		{
			boolean=True
		}
		else boolean=False
		IfExist,%A_LoopFilePath%\scripts\npc\portraits.txt
		{
			boolean1=True
		}
		else boolean1=False
		LV_Add(,A_Space,A_LoopFileName,intsaver,position,boolean,boolean1,A_LoopFilePath) ; the first "A_Space" variable here is a dummy character to avoid EVIL CRASH, Please dont touch it or else spamming the refresh list button will lead to crash
	}
	;"operation files" is used at ExternalFiles Label
	LV_Add(,LV_GetCount()+1,"""OPERATION FILES""","---->","This Row is the ","MAIN Files generated ","by this tool. ","It is not advisable reordering this row upwards unless you know what you're doing`, moving this row upwards will make OPERATION FILES more superior than External Files found beneath this row so keep that in mind.") ; the first "A_Space" variable here is a dummy character to avoid EVIL CRASH, Please dont touch it or else spamming the refresh list button will lead to crash
	IniRead,tmpint, %A_ScriptDir%\Settings.aldrin_dota2mod,External_Files,CountExternalFolder,0
	loop %tmpint%
	{
		intsaver:=boolean:=boolean1:=tmpint:=tmpstring:=""
		position=%A_Index%
		IniRead,intsaver, %A_ScriptDir%\Settings.aldrin_dota2mod,External_Files,ExternalFolder%A_Index%Enabled,%A_Space%
		IniRead,tmpint, %A_ScriptDir%\Settings.aldrin_dota2mod,External_Files,ExternalFolder%A_Index%,%A_Space%
		Loop % LV_GetCount()
		{
			LV_GetText(tmpstring,A_Index,7)
			if tmpint=%tmpstring%
			{
				LV_Modify(A_Index,intsaver,position)
			}
		}
	}
	LV_ModifyCol(1,"Sort Integer")
	intsaver:=position:=boolean:=boolean1:=tmpint:=tmpstring:=""
	gosub,extrerank
	gosub,lvautosize
	GuiControl, MainGUI:+Redraw, extfilelist
}
GuiControl,Text,searchnofound,%defaultshoutout%
Gui, MainGUI:-Disabled
return

extrerank:
loop % LV_GetCount()
{
	LV_Modify(A_Index,,A_Index)
}
loop 4
{
	LV_ModifyCol(A_Index+2,"Center")
}
return

extlistup:
if A_DefaultListView<>extfilelist
{
	Gui, MainGUI:ListView, extfilelist
}
LV_MoveRow()
gosub,extrerank
return

extlistdown:
if A_DefaultListView<>extfilelist
{
	Gui, MainGUI:ListView, extfilelist
}
LV_MoveRow(false)
gosub,extrerank
return

showtooltips:
Gui,MainGUI:Submit,NoHide
if showtooltips=1
{
	OnMessage(0x200, "WM_MOUSEMOVE")
}
else
{
	OnMessage(0x200,"")
	WM_MOUSEMOVE()
}
return

alldraggedfiles:
Gui,draggedfilesgui:Submit,NoHide
Loop Files,%selectedfileh%, F
{
	if A_LoopFileExt=aldrin_dota2hidb
	{
		maphdatadirview:=A_LoopFileLongPath
	}
}
Loop Files,%selectedfileg%, F
{
	if A_LoopFileExt=aldrin_dota2db
	{
		mapdatadirview:=A_LoopFileLongPath
	}
}
goto,continueexecution
return



draggedfilesguiguisize:
Gui,draggedfilesgui:Default
Anchor("text47","w")
Anchor("selectedfileg","w0.5 h")
Anchor("selectedfileh","x0.5 w0.5 h")
Anchor("text48","y")
Anchor("text49","x0.5")
return

slotstats:
GuiControl,Text,searchnofound,Constructing Handy-Injection Statistics.
herolist:=[] ; declares that this is an array
FileRead, tmp1,%A_ScriptDir%\Library\activelist.txt
Loop
{
	StringGetPos, ipos, tmp1,npc_dota_hero_,L%A_Index%
	if ipos<1
	{
		Break
	}
	StringGetPos, ipos1, tmp1,",,%ipos% ;"
	StringMid,tmp2,tmp1,% ipos+1,% ipos1-ipos
	if tmp2<>
	{
		herolist.push(tmp2) ; stores the npc_dota_hero_*** to the last unused element(rightmost element)
	}
	if ErrorLevel=1
	{
		Break
	}
}
GuiControl, MainGUI:-Redraw,slotstats
GuiControl, MainGUI:-Redraw,statscalibrator
Loop % herolist.Length() ; counts the number of elements inside the array
{
	npcherodata:=npcherodetector(herolist[A_Index],dota2dir "\game\dota\scripts\npc\npc_heroes.txt")
	npcitemslotsdetector(npcherodata,itemslotscount) ; itemslotscount returns the number of item slots of a hero
	if A_DefaultListView<>slotstats
	{
		Gui, MainGUI:ListView,slotstats
	}
	heroname:=StrReplace(herolist[A_Index],"npc_dota_hero_") ; removes this irritating line npc_dota_hero_
	LV_Add(,heroname,itemslotscount,0,itemslotscount) ; (slot count, slot occupied, slot unused count)
}
LV_ModifyCol(1,"Sort")
gosub,lvautosize
herolist= ; voids the array
GuiControl, MainGUI:+Redraw,slotstats
GuiControl, MainGUI:+Redraw,statscalibrator
GuiControl,Text,searchnofound,%defaultshoutout%
return

refreshstatistics() {
;everytime the statistics subsection of handy injection is pressed, this will rescan the items occupied at the operations
	;GuiControl,Text,searchnofound,Constructing Handy-Injection Statistics.
	GuiControl, MainGUI:-Redraw,slotstats
	GuiControl, MainGUI:-Redraw,itemview
	Gui, MainGUI:ListView,slotstats
	LV_DeleteCol(3),LV_InsertCol(3,,"Item Slots Occupied") ; temporary deletes the column and brings it back with an empty resources, this method is for performance purposes
	Gui, MainGUI:ListView,itemview
	loop % LV_GetCount()
	{
		Gui, MainGUI:ListView,itemview
		LV_GetText(heroname1,A_Index,5) ; get the hero user at this listview(column 5)
		Gui, MainGUI:ListView,slotstats
		loop % LV_GetCount()
		{
			LV_GetText(heroname2,A_Index,1) ; get the hero user at this listview(column 1)
			if heroname1=%heroname2%
			{
				;msgbox %heroname1%`n`n%heroname2%
				LV_GetText(slotmax,A_Index,2) ; get the current number of slots
				LV_GetText(slotcount,A_Index,3) ; get the current number of slots
				slotcount++ ; add 1 to the current number of slots
				LV_Modify(A_Index,"Col3",slotcount,slotmax-slotcount)
				break
			}
		}
	}
	GuiControl, MainGUI:+Redraw,slotstats
	GuiControl, MainGUI:+Redraw,itemview
	;GuiControl,Text,searchnofound,%defaultshoutout%
}

statscalibrator:
if (InStr(ErrorLevel, "C", true)) or (InStr(ErrorLevel, "c", true))
{
	if A_DefaultListView<>slotstats
	{
		Gui, MainGUI:ListView,slotstats
	}
	loop % LV_GetCount()
	{
		if A_DefaultListView<>slotstats
		{
			Gui, MainGUI:ListView,slotstats
		}
		LV_GetText(heroname,A_Index,1)
		heroname=npc_dota_hero_%heroname%
		npcherodata:=npcherodetector(heroname,dota2dir "\game\dota\scripts\npc\npc_heroes.txt") ; extracts the data of a specific hero
		refreshnpcitemslotsdetector(npcherodata,itemslotscount) ; itemslotscount returns the number of item slots of a hero
		
		if A_DefaultListView<>slotstats
		{
			Gui, MainGUI:ListView,slotstats
		}
		LV_GetText(occupiedslots,A_Index,3)
		if occupiedslots=
			occupiedslots:=0
		LV_Modify(A_Index,"Col2",itemslotscount,occupiedslots,itemslotscount-occupiedslots) ; edits the listview statistics again
	}
	
}
return

/*

;for testing purposes

$y::
Gui, MainGUI:Default
Gui, MainGUI:Submit, NoHide
if A_DefaultListView<>itemview
{
	Gui, MainGUI:ListView, itemview
}
Gui, MainGUI:Submit, NoHide
LV_ModifyCol(4,"SortDesc Integer")
msgbox % A_DefaultListView "`n" LV_GetCount()
return

*/

/*

add teleport effect
add blink effect
add socket gem
make misc like handy injection method
bug sa general redraw
preloading database to var func
custom items_game.txt para sa handy injection
warn user kung nagbago items_game.txt compare sa last generated pak01_dir items_game.txt generate as scriptdir/library/mod_items_game.txt
divide number of items into multiple custom processes
timedverinteg function di madetect variables sa timer

*/