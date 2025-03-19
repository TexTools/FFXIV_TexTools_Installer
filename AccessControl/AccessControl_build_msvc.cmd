@echo off
setlocal ENABLEEXTENSIONS DISABLEDELAYEDEXPANSION
set _=%~f0\..
set CL=/LD /W3 /O1 /GF /Gz /GS- /GR- /GL /Zl /Osy
set CL_x86=/Ogsy
set LINK=/OPT:REF /OPT:ICF,99 /MERGE:.rdata=.text /OPT:NOWIN98 /NODEFAULTLIB kernel32.lib user32.lib advapi32.lib
set AMD64=
set types=nsis_ansi nsis_unicode
(>nul (( 2>&1 call cl "/?" )|find /I "AMD64"))&&(set AMD64=1&set types=nsis_unicode)
(>nul (( 2>&1 call cl "/?" )|find /I "x86"))&&set CL=%CL% %CL_x86%
for %%A in (%types%) do call :B %%A
@goto :EOF

:B
set C=/I%_%/Contrib/AccessControl/%1
set L=%_%/Contrib/AccessControl/%1/pluginapi.lib
set ARC=i386-unicode
(echo.%~1|find /I "ANSI" >nul)&&set ARC=i386-ansi
if not "%AMD64%" == "" set ARC=amd64-unicode
if not "%AMD64%" == "" if %1 == nsis_ansi @goto :EOF
if not "%AMD64%" == "" call :B_UseNsisSource
md %_%\Plugins\%ARC% >nul 2>&1
set DEF=/Fe%_%/Plugins/%ARC%/AccessControl.dll
(echo.%~1|find /I "ANSI" >nul)||set DEF=/DUNICODE /D_UNICODE %DEF%
call cl %DEF% %C%  %_%/Contrib/AccessControl/AccessControl.cpp /FItchar.h /link %L%
@goto :EOF


:B_UseNsisSource
set NSISTRUNK=%_%/../../../../SCM-CO/NSIS/trunk
if not exist "%NSISTRUNK%\Source\exehead\ui.c" echo.FATAL: Invalid NSISTRUNK!
REM /Zl only sets _VC_NODEFAULTLIB in VS2005+
set CL=%CL% /D_VC_NODEFAULTLIB /I"%NSISTRUNK%\Source\exehead" /FI"%NSISTRUNK%\Contrib\ExDLL\pluginapi.c"
@goto :EOF
