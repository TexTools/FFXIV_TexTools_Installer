RequestExecutionLevel admin

!include "MUI.nsh"
!include "FileAssociation.nsh"
!include "DotNetChecker.nsh"

!include LogicLib.nsh
!include x64.nsh

!define MUI_PRODUCT "FFXIV TexTools"
!define MUI_VERSION "2.2.1"
!define MUI_BRANDINGTEXT "FFXIV TexTools"

 
!define MUI_ICON "ffxiv2.ico"
!define MUI_UNICON "ffxiv2.ico"


 
# define installation directory
InstallDir "$PROGRAMFILES64\FFXIV TexTools"


Function .onInit
UserInfo::GetAccountType
pop $0
${If} $0 != "admin" ;Require admin rights on NT4+
    MessageBox mb_iconstop "This installer must be run as Administrator to continue."
    SetErrorLevel 740 ;ERROR_ELEVATION_REQUIRED
    Quit
${EndIf}
FunctionEnd

!define MUI_PAGE_HEADER_TEXT "Installing FFXIV TexTools"
!define MUI_DIRECTORYPAGE_VARIABLE $INSTDIR
!define MUI_UNINSTALLER


Var StartMenuFolder

!insertmacro MUI_PAGE_DIRECTORY 
!insertmacro MUI_PAGE_STARTMENU "Application" $StartMenuFolder
!insertmacro MUI_PAGE_INSTFILES
#!insertmacro MUI_PAGE_STARTMENU "FFXIV TexTools" $StartMenuFolder
 
 
#name of installer
OutFile "Install_TexTools.exe"
Name "FFXIV TexTools"

 
# start default section
Section "Install"

	!insertmacro CheckNetFramework 472
	
 
    # set the installation directory as the destination for the following actions
    SetOutPath "$INSTDIR\FFXIV_TexTools"
	
	File /a /r "FFXIV_TexTools\"
	
	# VC Redistributables
	
	# 2019 is used by the FBX Converter
	File "2019_redist.x86.exe" 	
	ExecWait '"$INSTDIR\FFXIV_TexTools\2019_redist.x86.exe"  /passive /norestart'	
    Delete "$INSTDIR\FFXIV_TexTools\2019_redist.x86.exe"
	
	# 2012 is used by NotAssetCC
	File "2012_redist.x86.exe" 	
	ExecWait '"$INSTDIR\FFXIV_TexTools\2012_redist.x86.exe"  /passive /norestart'	
    Delete "$INSTDIR\FFXIV_TexTools\2012_redist.x86.exe"
	
	
	# Only install the 64 bit files if we're actually on a 64 bit machine.
${If} ${RunningX64}
	File "2019_redist.x64.exe" 	
	ExecWait '"$INSTDIR\FFXIV_TexTools\2019_redist.x64.exe"  /passive /norestart'	
    Delete "$INSTDIR\FFXIV_TexTools\2019_redist.x64.exe"
 
	File "2012_redist.x64.exe" 	
	ExecWait '"$INSTDIR\FFXIV_TexTools\2012_redist.x64.exe"  /passive /norestart'
    Delete "$INSTDIR\FFXIV_TexTools\2012_redist.x64.exe"
${EndIf}  

	
	
 
    # create a shortcut named "new shortcut" in the start menu programs directory
    # point the new shortcut at the program uninstaller
	CreateDirectory "$SMPROGRAMS\FFXIV TexTools"
    CreateShortcut "$SMPROGRAMS\FFXIV TexTools\FFXIV TexTools.lnk" "$INSTDIR\FFXIV_TexTools\FFXIV_TexTools.exe"
    CreateShortcut "$SMPROGRAMS\FFXIV TexTools\Uninstall Textools.lnk" "$INSTDIR\uninstall.exe"
	
	# Create Uninstaller Registry Entry
	WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\FFXIV_TexTools" \
                 "DisplayName" "FFXIV TexTools"
				 
	WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\FFXIV_TexTools" \
                 "DisplayIcon" "$\"$INSTDIR\FFXIV_TexTools\Resources\ffxiv2.ico$\""
				 
	WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\FFXIV_TexTools" \
                 "DisplayVersion" "2.2.1"
				 
	WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\FFXIV_TexTools" \
                 "UninstallString" "$\"$INSTDIR\uninstall.exe$\""
				 
	WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\FFXIV_TexTools" \
                 "InstallLocation" "$\"$INSTDIR$\""
				 
	WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\ImageMaker" \
					 "QuietUninstallString" "$\"$INSTDIR\uninstall.exe$\" /S"
					 
	WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\ImageMaker" \
					 "Publisher" "TexTools Github Group"
					 
	WriteRegDWORD HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\ImageMaker" \
					 "VersionMajor" 0x2
					 
	WriteRegDWORD HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\ImageMaker" \
					 "VersionMinor" 0x2
					 
	WriteRegDWORD HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\ImageMaker" \
					 "NoModify" 0x1
				 
	WriteRegDWORD HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\ImageMaker" \
					 "NoRepair" 0x1
			
	${registerExtension} "$\"$INSTDIR\FFXIV_TexTools\FFXIV_TexTools.exe$\"" ".ttmp" "TexTools Mod File"
	${registerExtension} "$\"$INSTDIR\FFXIV_TexTools\FFXIV_TexTools.exe$\"" ".ttmp2" "TexTools2 Mod File"
	  
    # create the uninstaller
    WriteUninstaller "$INSTDIR\Uninstall.exe"		 
SectionEnd
 
# uninstaller section start
Section "Uninstall"
	
    # first, delete the uninstaller
    Delete "$INSTDIR\uninstall.exe"
	
	# Remove windows add/remove programs entry.
	DeleteRegKey HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\FFXIV_TexTools"
	
	# Remove TexTools files and shortcuts
	RMDir /r "$INSTDIR\FFXIV_TexTools"
	RMDir /r "$SMPROGRAMS\FFXIV TexTools"

	# Unregister file extensions
	${unregisterExtension} ".ttmp" "TexTools Mod File"
	${unregisterExtension} ".ttmp2" "TexTools2 Mod File"
	
	# Remove installation folder if it's empty.
    RMDir $INSTDIR
# uninstaller section end
SectionEnd
