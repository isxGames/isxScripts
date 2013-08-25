@echo off
set PROJECTDIR=%~1
set TARGETDIR=%~2
set TARGETFILENAME=%3
set OBFUSCATE=%~4

SET PDB_FILE=
set CHANGELOG=LSMMySQL_Changelog.txt
:: delims is a TAB followed by a space
if not defined InnerSpacePath FOR /F "tokens=2* delims=	 " %%A IN ('REG QUERY "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\App Paths\InnerSpace.exe" /v "Path"') DO SET InnerSpacePath=%%B
if not defined InnerSpacePath FOR /F "tokens=2* delims=	 " %%A IN ('REG QUERY "HKCU\Software\Microsoft\IntelliPoint\AppSpecific\InnerSpace.exe" /v "Path"') DO SET InnerSpacePath=%%B
if not defined InnerSpacePath FOR /F "tokens=2* delims=	 " %%A IN ('REG QUERY "HKCU\Software\Microsoft\IntelliType Pro\AppSpecific\InnerSpace.exe" /v "Path"') DO SET InnerSpacePath=%%B
if not defined InnerSpacePath goto :ERROR

if "%InnerSpacePath:~-15%" == "\InnerSpace.exe" set InnerSpacePath=%InnerSpacePath:~0,-15%

:COPY_DLL
	IF EXIST "%InnerSpacePath%\LavishScript Modules\%TARGETFILENAME%" echo Removing existing "%InnerSpacePath%\LavishScript Modules\%TARGETFILENAME%"
	IF EXIST "%InnerSpacePath%\LavishScript Modules\%TARGETFILENAME%" del "%InnerSpacePath%\LavishScript Modules\%TARGETFILENAME%"
	IF EXIST "%InnerSpacePath%\LavishScript Modules\%TARGETFILENAME%" echo "%InnerSpacePath%\LavishScript Modules\%TARGETFILENAME%" is in use, unable to delete!
	IF EXIST "%InnerSpacePath%\LavishScript Modules\%TARGETFILENAME%" exit /B 1

:COPY_BINARY
	echo PostBuild: Copying %TARGETFILENAME% to "%InnerSpacePath%\LavishScript Modules\%TARGETFILENAME%"
	copy /Y "%TARGETDIR%\%TARGETFILENAME%" "%InnerSpacePath%\LavishScript Modules\%TARGETFILENAME%"

:COPY_CHANGELOG
	echo PostBuild: Copying %CHANGELOG% to "%InnerSpacePath%\LavishScript Modules\%CHANGELOG%"
	copy /Y "%PROJECTDIR%\%CHANGELOG%" "%InnerSpacePath%\LavishScript Modules\%CHANGELOG%"
	goto COPY_CRASH_REPORTER

:COPY_CRASH_REPORTER
@REM	echo PostBuild: Copying ISXGames_CrashReporter.exe to "%InnerSpacePath%\Extensions\ISXGames_CrashReporter.exe"
@REM	copy /Y "%PROJECTDIR%\..\libisxGames\CrashRpt\bin\ISXGames_CrashReporter.exe" "%InnerSpacePath%\Extensions\ISXGames_CrashReporter.exe"
@REM	echo PostBuild: Copying ISXGames_CrashReporter.ini to "%InnerSpacePath%\Extensions\ISXGames_CrashReporter.ini"
@REM	copy /Y "%PROJECTDIR%\..\libisxGames\CrashRpt\bin\ISXGames_CrashReporter.ini" "%InnerSpacePath%\Extensions\ISXGames_CrashReporter.ini"
@REM	goto COPY_SYMBOLS

:COPY_SYMBOLS
	IF EXIST "C:\Program Files (x86)\Windows Kits\8.0\Debuggers\x86\symstore.exe" goto COPY_SYMBOLS_SymStorePath1
	goto DONE

:COPY_SYMBOLS_SymStorePath1
@REM To use this setup, set
@REM   _NT_SYMBOL_PATH=I:\SymbolCache\Personal;srv*I:\SymbolCache\Microsoft*http://msdl.microsoft.com/download/symbols
@REM Note that there are TWO dirs there, the Personal dir, and the Microsoft cache dir. The Personal dir is ONLY for files
@REM locally generated, and the Microsoft dir is the cache for files from the MS Symbol Server
	IF NOT EXIST "I:\SymbolCache\Personal" GOTO DONE

	echo PostBuild: Committing DLL files to Personal Symbol Store...
	C:\"Program Files (x86)"\"Windows Kits"\"8.0"\Debuggers\x86\symstore.exe add /r /f "..\*.dll" /s "I:\SymbolCache\Personal" /t ISXEVE /z pri

	echo PostBuild: Committing PDB files to Personal Symbol Store...
	C:\"Program Files (x86)"\"Windows Kits"\"8.0"\Debuggers\x86\symstore.exe add /r /f "..\*.pdb" /s "I:\SymbolCache\Personal" /t ISXEVE /z pri

	echo PostBuild: Deleting symbols which haven't been accessed in 100 days
	C:\"Program Files (x86)"\"Windows Kits"\"8.0"\Debuggers\x86\agestore.exe I:\SymbolCache\Personal -days=100 -k -y -q
	goto DONE

:ERROR
	echo Error
	exit /B 1

:DONE
	exit /B 0
