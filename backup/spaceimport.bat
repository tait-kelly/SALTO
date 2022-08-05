@echo off


REM ============================CURRENT STATUS===================================================
REM ============================CURRENT STATUS===================================================


REM =================================NOTES=======================================================
REM Version 2.0
REM New version for SALTO SPACE imports
REM 2022-06-10 Finished script to a point of needing to parse the student import file.
REM Version 2.4
REM Most functionality is working for imports
REM Added option for conference imports
REM Version 2.5
REM Fixes issues with updating script
REM Version 2.6
REM Testing to finalize script
REM Imporoved outputs for ease of use.
REM =================================NOTES=======================================================

REM ==============================Pending Changes / Improvements=================================
REM Need to test working on templates and make a requirement using start /wait for the opening of files to ensure they are closed before trying to parse and import.
REM ==============================Pending Changes / Improvements=================================

REM =====================KNOWN ISSUES / BUGS=====================================================
REM =====================KNOWN ISSUES / BUGS=====================================================

REM =====================PAST SCRIPT WORKFLOW====================================================
REM Prompt for if running for Student Residence of general users
REM Prompt if you want to import files or just create a template for doing the import yourself
REM If Student Import parsing of file to create import proper inport file then providing instructions for the import process
REM If Student Import template then create import template then walk user through process of importing
REM If General User import parse file provided and then create proper import file
REM If General User import template create template file and then provide instructions for importing
REM =====================PAST SCRIPT WORKFLOW====================================================

REM =====================NEW SCRIPT WORKFLOW====================================================
REM Prompt for if running for Student Residence of general users
REM Prompt if you want to import files or just create a template for doing the import yourself
REM Prompt for when the imported users should expire
REM If Student Import need to prompt user to ensure that required file and data is in the desired location and format
REM If Student Import parsing of file to create proper import file then upload to the salto server in the desired location, then providing instructions for the import process
REM If Student Import template then create import template open file for user to complete it, then walk user through process of importing
REM If General User import parse file, then upload to the salto server, then provided and then create proper import file
REM If General User import template create template file and then provide instructions for importing
REM =====================NEW SCRIPT WORKFLOW====================================================



set VERSION=2.6
set COMPILED=August 5th, 2022
for /f "delims=." %%a in ('wmic OS Get localdatetime ^| find "."') do set dt=%%a
set today=%dt:~0,14%
REM echo today is:%TODAY%
set GITHUBKEY=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
set TITLE=Welcome to the new Salto Import script version %VERSION% compiled on %COMPILED%


set IMPORTTYPE=0
set IMPORTTEMPLATE=0
set EXPIRY=0
set CONFIRMEDFILE=0
set CORRECT=0
set DOOREXTID=0
REM echo this script was called with the paramter of:%1
if NOT "%1"=="s" (
	call:SCRIPTUPDATE
)
GOTO IMPORTTYPE

:IMPORTTYPE
Set /P IMPORTTYPE="Are you using the script for Residence(R) imports or General users(G) or Conference Users(C) ? (R or G or C)"
if /I %importtype%==R goto IMPORTORTEMPLATE
if /I %importtype%==G goto IMPORTORTEMPLATE
if /I %importtype%==C goto IMPORTORTEMPLATE
echo Looks like you made an invalid selection press any key to restart
PAUSE
GOTO IMPORTTYPE

:IMPORTORTEMPLATE
Set /P IMPORTORTEMPLATE="Do you have a CSV file for import (Y) or do you need help with creating the file(H)?"
if /I %IMPORTORTEMPLATE%==Y goto USEREXPIRY
if /I %IMPORTORTEMPLATE%==H goto USEREXPIRY
echo Looks like you made an invalid selection press any key to restart
PAUSE
GOTO IMPORTORTEMPLATE

:USEREXPIRY
echo An Expiry needs to be set for the users to be imported please provide the expiry in a format of YYYY-MM-DD
echo NOTE: if it is not entered correctly the expiry will be set to one month from the import day.
set /p EXPIRY="Expiry Date (YYYY-MM-DD):"
set EXPIRY=%EXPIRY%T23:59:00
REM echo set and expiry to:%EXPIRY%
if /I %importtype%==R goto STARTR
if /I %importtype%==G goto STARTG
if /I %importtype%==C goto STARTC
GOTO EOF

:STARTR
REM echo now in the start procedure with a importtype:%importtype% and importtemplate of:%IMPORTORTEMPLATE%
if /I %IMPORTORTEMPLATE%==Y (
REM	echo You specified you will be providing a data file for this script to parse and import into salto.
	echo The data file you need to provide must be in the format of "Student #,Last Name,First Name,Email,Area,Building,Floor,Room,Bed"
	echo The file should also be in the folder %CD%.
	echo This folder will be opened for you to copy the file into it.
	echo Once you have copied the file to the folder %CD% press enter on this screen to continue
	REM PAUSE
	explorer.exe %CD%
	PAUSE
	call:STUDENTIMPORTPARSE
	echo Looks like all should be done for the parsing now so need to go to import instructions
)
if /I %IMPORTORTEMPLATE%==H (
	REM echo You have specified that you would like a template created for you and then import the data
	cls
	echo Next a template will be created and opened for you to complete once done please select save then continue on this script
	echo Please note that fields can not be left blank or the import will work correctly.
	PAUSE
	call:STUDENTTEMPLATE
	start %USERNAME%template%TODAY%.csv
	PAUSE
	call:STUDENTIMPORTPARSE	
	echo Looks like all should be done for the parsing now so need to go to import instructions
) 
call:COPYTOSALTO
if EXIST files.txt del files.txt
if EXIST results.txt del results.txt
if EXIST doorswithids.txt del doorswithids.txt
if EXIST accesslevelswithids.txt del accesslevelswithids.txt
if EXIST count.txt del count.txt					
call:IMPORTINSTRUCTIONS
REM echo looks like the process should be done.
GOTO EOF

	
:STARTG
REM echo now in the start procedure with a importtype:%importtype% and importtemplate of:%IMPORTORTEMPLATE%
if /I %IMPORTORTEMPLATE%==Y (
REM	echo You specified you will be providing a data file for this script to parse and import into salto.
	echo The data file you need to provide must be in the format of "Last Name,First Name,Department" as a csv file
	echo NOTE: For the department field it must be enered Exactly as required.
	echo The file should also be in the folder %CD%.
	echo This folder will be opened for you to copy the file into it.
	echo Once you have copied the file to the folder %CD% press enter on this screen to continue
	REM PAUSE
	explorer.exe %CD%
	PAUSE
	call:GENERALIMPORTPARSE
	echo Looks like all should be done for the parsing now so need to go to import instructions
)
if /I %IMPORTORTEMPLATE%==H (
	REM echo You have specified that you would like a template created for you and then import the data
	cls
	echo Next a template will opened for you to complete once done please select save as a csv file and close then continue on this script
	echo NOTE: If the file is not saved as a csv file the import will not be able to proceed.
	PAUSE
	call:GENERALTEMPLATE
	start /wait GeneralTemplate.xlsx
	PAUSE
	call:GENERALIMPORTPARSE	
	echo Looks like all should be done for the parsing now so need to go to import instructions
) 
call:COPYTOSALTO
if EXIST files.txt del files.txt
if EXIST results.txt del results.txt
if EXIST doorswithids.txt del doorswithids.txt
if EXIST accesslevelswithids.txt del accesslevelswithids.txt
if EXIST count.txt del count.txt					
call:IMPORTINSTRUCTIONS
echo looks like the process should be done.
GOTO EOF

:STARTC
REM echo now in the start procedure with a importtype:%importtype% and importtemplate of:%IMPORTORTEMPLATE%
if /I %IMPORTORTEMPLATE%==Y (
REM	echo You specified you will be providing a data file for this script to parse and import into salto.
	echo The data file you need to provide must be in the format of "Student #,Last Name,First Name,Email,Area,Building,Floor,Room,Bed"
	echo The file should also be in the folder %CD%.
	echo This folder will be opened for you to copy the file into it.
	echo Once you have copied the file to the folder %CD% press enter on this screen to continue
	REM PAUSE
	explorer.exe %CD%
	PAUSE
	call:CONFERENCEIMPORTPARSE
	echo Looks like all should be done for the parsing now so need to go to import instructions
)
if /I %IMPORTORTEMPLATE%==H (
	REM echo You have specified that you would like a template created for you and then import the data
	cls
	echo Next a template will be created and opened for you to complete once done please select save and close then continue on this script
	PAUSE
	call:CONFERENCETEMPLATE
	start /wait %USERNAME%template%TODAY%.csv
	PAUSE
	call:CONFERENCEIMPORTPARSE	
	echo Looks like all should be done for the parsing now so need to go to import instructions
) 
call:COPYTOSALTO
if EXIST files.txt del files.txt
if EXIST results.txt del results.txt
if EXIST doorswithids.txt del doorswithids.txt
if EXIST accesslevelswithids.txt del accesslevelswithids.txt
if EXIST count.txt del count.txt					
call:IMPORTINSTRUCTIONS
echo looks like the process should be done.
GOTO EOF


	


:STUDENTIMPORTPARSE
REM This will now create a proper template file for the import
REM In this procedure we are going to export the user file
SETLOCAL enabledelayedexpansion
REM cls
REM call:FILECHECK CONFIRMEDFILE
if EXIST file.csv del file.csv
REM echo I am in the parsing with a file of:%~1
if EXIST files.txt del files.txt
if EXIST %USERNAME%import%today%.csv del %USERNAME%import%today%.csv
dir "%CD%"\*.csv /b >> "%CD%"\files.txt
find /v /c "" files.txt >count.txt 
findstr /C:"1" count.txt >NUL
if %ERRORLEVEL%==0 (
	REM echo looks like there is only one file.
	for /F "tokens=*" %%a in (files.txt) do (
		REM echo Reading in the file named %%a and creating the import files
		set CONFIRMEDFILE=%%a
		REM if /I %CORRECT%==Y echo Already have the confirmed file
		REM if NOT /I %CORRECT%==Y CALL:FILECONFIRMLOOP %%a CORRECT 
)
)
findstr /C:"1" count.txt >NUL
if NOT %ERRORLEVEL%==0 (
	echo looks like there is more than one file. Please enter the file to use in based on the list below.
	type files.txt
	set /p CONFIRMEDFILE="Enter the file name to use for import exactly as shown above:"
)
echo The System is now going to parse file named:%CONFIRMEDFILE%
REM echo now the file will be parsed.
set COUNT=0

echo Action;ExtID;First Name;Last Name;Title;Privacy;AuditOpenings;CalendarID;ExtAccessLevelIDList;EXTDoorIDList;UserExpiration.EXPDate >> %USERNAME%import%today%.csv
REM @echo on
set EXTID=!TODAY!!USERNAME!
REM echo I just created an EXTID of:%EXTID%
curl -LJo doorswithids.txt  https://%GITHUBKEY%@github.com/tait-kelly/Salto/raw/main/doorswithids.txt > NUL
curl -LJo accesslevelswithids.txt  https://%GITHUBKEY%@github.com/tait-kelly/Salto/raw/main/accesslevelswithids.txt > NUL
for /F "skip=1 tokens=1-20 delims=," %%b in (%CONFIRMEDFILE%) do (
	REM The new format for the exported file from ereslife is Student#(b), Last Name (c), Firstname (d), email (e), Area(f), Building (g), Floor (h), Suite (i), Room (j), Bed (k)
	REM Sample provide by Melissa on June 10th 2022 is "Student ID,Last Name,First Name,Email,St. Jerome's University,Siegfried Hall (South Tower),Level 2,2517 (Don Room),2517,A"
	REM Only need Last Name (c), Firstname (d), Building (g), Floor (h), Room (j) for the parsing
	REM echo I have values of:%%b,%%c,%%d,%%g,%%h,%%i,%%j
	REM echo I am going to create the user import file now
	set floor=%%h
	REM echo floor should be the last number of %%f
	REM echo I want to set the floor to:!floor:~-1!
	set floornum=!floor:~-1!
	REM echo got a floor of !floornum!
	REM echo now I have to find out which Building will be assigned based on %%e I am going to feed in %%e and do a findstring on it.
	echo %%g|findstr /C:"Ryan" >NUL
	if !errorlevel!==0 (
		set building=RH
		set "BUILDINGNAME=Ryan Hall"
		set ROOM=RB-%%i
	)
	echo %%g|findstr /C:"Siegfried" >NUL
	if !errorlevel!==0 (
		set building=SH
		set "BUILDINGNAME=Siegfried Hall"
		set ROOM=RB-%%i
	)
	echo %%g|findstr /C:"Finn" >NUL
	if !errorlevel!==0 (
		set building=JRF
		set BUILDINGNAME=Finn
		set ROOM=JRF-%%i
	)
	REM echo got a building of !building!
	REM echo I am going to wire the line:RES!floornum!!building!,%%d,%%c,%%b,%today% to the file
	REM echo calling to get the door ID with:!ROOM!
	call:GETRESDOOREXTID DOORID,!ROOM!
	REM echo Looks like I got a return of:!DOORID!
	REM echo Building name is:!BUILDINGNAME!
	call:GETRESACCESSLEVELEXTID ACCESSID,!FLOORNUM!,!BUILDINGNAME!
	REM echo Looks like I got a return of:!ACCESSID!
	set EXTID=!TODAY!!USERNAME!!COUNT!
	
	SET /A COUNT=COUNT+1
	REM echo the count is now:%COUNT%
	REM echo I am adding the line:1;%EXTID%!COUNT!;%%d;%%c;RES!floornum!!building!;0;1;6;!ACCESSID!;!DOORID!;%EXPIRY%
	echo 1;%EXTID%!COUNT!;%%d;%%c;RES!floornum!!building!;0;1;6;!ACCESSID!;!DOORID!;%EXPIRY% >> %USERNAME%import%today%.csv
	REM echo RES!floornum!!building!,%%d,%%c,%%b,%today% >> userimport%today%.csv
	REM if  !building!==JRF echo RES!floornum!!building! %%d %%c,JRF%%g-Residence Room >>importuserdoor%today%.csv
	REM echo RES!floornum!!building! %%d %%c,RB%%g>>importuserdoor%today%.csv
)

ENDLOCAL
EXIT /b

:GENERALIMPORTPARSE
REM This will now create a proper template file for the import
REM In this procedure we are going to export the user file
SETLOCAL enabledelayedexpansion
REM cls
REM call:FILECHECK CONFIRMEDFILE
if EXIST file.csv del file.csv
REM echo I am in the parsing with a file of:%~1
if EXIST files.txt del files.txt
if EXIST GeneralTemplate.xlsx del GeneralTemplate.xlsx
dir "%CD%"\*.csv /b >> "%CD%"\files.txt
find /v /c "" files.txt >count.txt 
findstr /C:"1" count.txt >NUL
if %ERRORLEVEL%==0 (
	REM echo looks like there is only one file.
	for /F "tokens=*" %%a in (files.txt) do (
		REM echo Reading in the file named %%a and creating the import files
		set CONFIRMEDFILE=%%a
		REM if /I %CORRECT%==Y echo Already have the confirmed file
		REM if NOT /I %CORRECT%==Y CALL:FILECONFIRMLOOP %%a CORRECT 
)
)
findstr /C:"1" count.txt >NUL
if NOT %ERRORLEVEL%==0 (
	echo looks like there is more than one file. Please enter the file to use in based on the list below.
	type files.txt
	set /p CONFIRMEDFILE="Enter the file name to use for import exactly as shown above:"
)
echo The System is now going to parse file named:%CONFIRMEDFILE%
REM echo now the file will be parsed.
set COUNT=0

echo Action;ExtID;First Name;Last Name;Title;Privacy;AuditOpenings;CalendarID;UserExpiration.EXPDate >> %USERNAME%import%today%.csv
REM @echo on
set EXTID=!TODAY!!USERNAME!
REM echo I just created an EXTID of:%EXTID%
REM curl -LJo doorswithids.txt  https://%GITHUBKEY%@github.com/tait-kelly/Salto/raw/main/doorswithids.txt > NUL
REM curl -LJo accesslevelswithids.txt  https://%GITHUBKEY%@github.com/tait-kelly/Salto/raw/main/accesslevelswithids.txt > NUL
for /F "skip=1 tokens=1-20 delims=," %%b in (%CONFIRMEDFILE%) do (
	echo %%c|findstr /C:"Advancement Department"
	if !errorlevel!==0 (
		set TITLE=ADV
	) 
	echo %%c|findstr /C:"ASA Executive Office"
	if !errorlevel!==0 (
		set TITLE=ASA
	) 
	echo %%c|findstr /C:"BOG Access"
	if !errorlevel!==0 (
		set TITLE=BOG
	) 
	echo %%c|findstr /C:"Campus Ministry Help"
	if !errorlevel!==0 (
		set TITLE=CM
	) 
	echo %%c|findstr /C:"Campus Ministry Staff"
	if !errorlevel!==0 (
		set TITLE=CM
	) 
	echo %%c|findstr /C:"Campus Ministy Student Leaders"
	if !errorlevel!==0 (
		set TITLE=CM
	) 
	echo %%c|findstr /C:"CAS"
	if !errorlevel!==0 (
		set TITLE=CAS
	) 
	echo %%c|findstr /C:"Cleaning Staff"
	if !errorlevel!==0 (
		set TITLE=CLEAN BEST
	) 
	echo %%c|findstr /C:"Deans Department"
	if !errorlevel!==0 (
		set TITLE=DEAN
	) 
	echo %%c|findstr /C:"DragonLab Admin"
	if !errorlevel!==0 (
		set TITLE=HIST-DLAB
	) 
	echo %%c|findstr /C:"Dragonlab Fellows"
	if !errorlevel!==0 (
		set TITLE=HIST-DLAB
	) 
	echo %%c|findstr /C:"DragonLab Members"
	if !errorlevel!==0 (
		set TITLE=HIST-DLAB
	) 
	echo %%c|findstr /C:"English"
	if !errorlevel!==0 (
		set TITLE=ENGLISH
	) 
	echo %%c|findstr /C:"Finance Department"
	if !errorlevel!==0 (
		set TITLE=FINANCE
	) 
	echo %%c|findstr /C:"Finn Community Partners"
	if !errorlevel!==0 (
		set TITLE=COMMPARTNER
	) 
	echo %%c|findstr /C:"FOOD Services"
	if !errorlevel!==0 (
		set TITLE=FOOD
	) 
	echo %%c|findstr /C:"History"
	if !errorlevel!==0 (
		set TITLE=HISTORY
	) 
	echo %%c|findstr /C:"HR and Admin"
	if !errorlevel!==0 (
		set TITLE=HR
	) 
	echo %%c|findstr /C:"Infrastructure Department"
	if !errorlevel!==0 (
		set TITLE=IND
	) 
	echo %%c|findstr /C:"Infrastructure Security"
	if !errorlevel!==0 (
		set TITLE=INF-SEC
	) 
	echo %%c|findstr /C:"Italian and French Studies"
	if !errorlevel!==0 (
		set TITLE=I&FSTUDIES
	) 
	echo %%c|findstr /C:"Library Staff"
	if !errorlevel!==0 (
		set TITLE=LIBRARY
	) 
	echo %%c|findstr /C:"Library Students"
	if !errorlevel!==0 (
		set TITLE=LIB STUDENT
	) 
	echo %%c|findstr /C:"Masters Catholic Thought"
	if !errorlevel!==0 (
		set TITLE=MCT
	) 
	echo %%c|findstr /C:"Medieval Studies"
	if !errorlevel!==0 (
		set TITLE=MEDIEVAL
	) 
	echo %%c|findstr /C:"Philosophy"
	if !errorlevel!==0 (
		set TITLE=PHILOSOPHY
	) 
	echo %%c|findstr /C:"Philosophy - ECL LAB - Coordinator"
	if !errorlevel!==0 (
		set TITLE=PHIL-ECLLAB
	) 
	echo %%c|findstr /C:"Philosophy - ECL Lab RA"
	if !errorlevel!==0 (
		set TITLE=PHIL-ECLLAB
	) 
	echo %%c|findstr /C:"Presidents Office"
	if !errorlevel!==0 (
		set TITLE=PRES
	) 
	echo %%c|findstr /C:"Psychology"
	if !errorlevel!==0 (
		set TITLE=PSYCH
	) 
	echo %%c|findstr /C:"Psychology RA"
	if !errorlevel!==0 (
		set TITLE=PSYCHRA
	) 
	echo %%c|findstr /C:"Psychology TA"
	if !errorlevel!==0 (
		set TITLE=PSYCHTA
	) 
	echo %%c|findstr /C:"Registrars Department"
	if !errorlevel!==0 (
		set TITLE=REGISTRARS
	) 
	echo %%c|findstr /C:"Religious Studies"
	if !errorlevel!==0 (
		set TITLE=RELIGIOUS
	) 
	echo %%c|findstr /C:"SMF"
	if !errorlevel!==0 (
		set TITLE=SMF
	) 
	echo %%c|findstr /C:"SMF Assistants"
	if !errorlevel!==0 (
		set TITLE=SMF-ASSIST
	) 
	echo %%c|findstr /C:"SMF Student Society"
	if !errorlevel!==0 (
		set TITLE=SMF-STUD
	) 
	echo %%c|findstr /C:"SMF TA"
	if !errorlevel!==0 (
		set TITLE=SMF-TA
	) 
	echo %%c|findstr /C:"Sociology & Legal Studies"
	if !errorlevel!==0 (
		set TITLE=SOCLEGAL
	) 
	echo %%c|findstr /C:"Student Affairs Department"
	if !errorlevel!==0 (
		set TITLE=SA
	) 
	echo %%c|findstr /C:"Students Union"
	if !errorlevel!==0 (
		set TITLE=SU
	) 
	echo %%c|findstr /C:"TNQ"
	if !errorlevel!==0 (
		set TITLE=TNQ
	)
	set EXTID=!TODAY!!USERNAME!!COUNT!
	SET /A COUNT=COUNT+1
	REM echo the count is now:%COUNT%
	echo 1;%EXTID%!COUNT!;%%a;%%b;%TITLE%;0;1;0;%EXPIRY% >> %USERNAME%import%today%.csv
)

ENDLOCAL
EXIT /b

:CONFERENCEIMPORTPARSE
REM This will now create a proper template file for the import
REM In this procedure we are going to export the user file
SETLOCAL enabledelayedexpansion
REM cls
REM call:FILECHECK CONFIRMEDFILE
if EXIST file.csv del file.csv
REM echo I am in the parsing with a file of:%~1
if EXIST files.txt del files.txt
if EXIST %USERNAME%import%today%.csv del %USERNAME%import%today%.csv
dir "%CD%"\*.csv /b >> "%CD%"\files.txt
find /v /c "" files.txt >count.txt 
findstr /C:"1" count.txt >NUL
if %ERRORLEVEL%==0 (
	REM echo looks like there is only one file.
	for /F "tokens=*" %%a in (files.txt) do (
		REM echo Reading in the file named %%a and creating the import files
		set CONFIRMEDFILE=%%a
		REM if /I %CORRECT%==Y echo Already have the confirmed file
		REM if NOT /I %CORRECT%==Y CALL:FILECONFIRMLOOP %%a CORRECT 
)
)
findstr /C:"1" count.txt >NUL
if NOT %ERRORLEVEL%==0 (
	echo looks like there is more than one file. Please enter the file to use in based on the list below.
	type files.txt
	set /p CONFIRMEDFILE="Enter the file name to use for import exactly as shown above:"
)
echo The System is now going to parse file named:%CONFIRMEDFILE%
REM echo now the file will be parsed.
set COUNT=0

echo Action;ExtID;First Name;Last Name;Title;Privacy;AuditOpenings;CalendarID;ExtAccessLevelIDList;EXTDoorIDList;UserExpiration.EXPDate >> %USERNAME%import%today%.csv
REM @echo on
set EXTID=!TODAY!!USERNAME!
REM echo I just created an EXTID of:%EXTID%
curl -LJo doorswithids.txt  https://%GITHUBKEY%@github.com/tait-kelly/Salto/raw/main/doorswithids.txt > NUL
curl -LJo accesslevelswithids.txt  https://%GITHUBKEY%@github.com/tait-kelly/Salto/raw/main/accesslevelswithids.txt > NUL
for /F "skip=1 tokens=1-20 delims=," %%b in (%CONFIRMEDFILE%) do (
	REM The format for file is Last Name(b),First Name(c),Building(d),Floor(e),Room(f) 
	set floor=%%d
	REM echo floor should be the last number of %%f
	REM echo I want to set the floor to:!floor:~-1!
	set floornum=!floor:~-1!
	REM echo got a floor of !floornum!
	REM echo now I have to find out which Building will be assigned based on %%e I am going to feed in %%e and do a findstring on it.
	echo %%c|findstr /C:"Ryan" 
	if !errorlevel!==0 (
		set building=RH
		set "BUILDINGNAME=N"
		set ROOM=RB-%%e
	)
	echo %%c|findstr /C:"Siegfried" >NUL
	if !errorlevel!==0 (
		set building=SH
		set "BUILDINGNAME=S"
		set ROOM=RB-%%e
	)
	echo %%c|findstr /C:"Finn" >NUL
	if !errorlevel!==0 (
		set building=JRF
		set BUILDINGNAME=F
		set ROOM=JRF-%%e
	)
	REM echo got a building of !building!
	REM echo I am going to wire the line:RES!floornum!!building!,%%d,%%c,%%b,%today% to the file
	REM echo calling to get the door ID with:!ROOM!
	call:GETRESDOOREXTID DOORID,!ROOM!
	REM echo Looks like I got a return of:!DOORID!
	REM echo Building name is:!BUILDINGNAME!
	echo calling getconfaccesslevelextid with !FLOORNUM!,!BUILDINGNAME!
	call:GETCONFACCESSLEVELEXTID ACCESSID,!FLOORNUM!,!BUILDINGNAME!
	REM echo Looks like I got a return of:!ACCESSID!
	set EXTID=!TODAY!!USERNAME!!COUNT!
	
	SET /A COUNT=COUNT+1
	REM echo the count is now:%COUNT%
	REM echo I am adding the line:1;%EXTID%!COUNT!;%%d;%%c;RES!floornum!!building!;0;1;6;!ACCESSID!;!DOORID!;%EXPIRY%
	echo 1;%EXTID%!COUNT!;%%b;%%a;CONF!floornum!!building!;0;1;6;!ACCESSID!;!DOORID!;%EXPIRY% >> %USERNAME%import%today%.csv
	REM echo RES!floornum!!building!,%%d,%%c,%%b,%today% >> userimport%today%.csv
	REM if  !building!==JRF echo RES!floornum!!building! %%d %%c,JRF%%g-Residence Room >>importuserdoor%today%.csv
	REM echo RES!floornum!!building! %%d %%c,RB%%g>>importuserdoor%today%.csv
)

ENDLOCAL
EXIT /b

:COPYTOSALTO
if exist x: net use x: /delete > NUL
net use x: \\172.25.126.100\imports
copy %USERNAME%import%today%.csv x:\
if NOT %ERRORLEVEL%==0 (
	echo looks like there was a problem copying the import file to the salto server please confirm you are on the wired network on SJU and then start this again
	GOTO EOF
)

EXIT /b

:FILECHECK FILE
if EXIST file.csv del file.csv
REM echo I am in the parsing with a file of:%~1
if EXIST files.txt del files.txt
dir "%CD%"\*.csv /b >> "%CD%"\files.txt
type files.txt
set /p FILE="Enter the file name from the list above to use for the import:"
REM for /F "tokens=*" %%a in (files.txt) do (
	REM echo Reading in the file named %%a and creating the import files
REM	echo confirmed file is:%CONFIRMEDFILE%
REM	PAUSE
REM 	if /I %CORRECT%==Y echo Already have the confirmed file
REM 	if NOT /I %CORRECT%==Y CALL:FILECONFIRMLOOP %%a CORRECT 
REM )
EXIT /b


:FILECONFIRMLOOP FILENAME CORRECT
REM THis will be a loop to confirm that the CSV file found is the correct one.
echo Looks like there is a CSV file in the %CD% named %~1 If this is the file to be parsed for the import it should be in a format with the one user per line in a format of "Student #,Last Name,First Name,Building,Floor,Suite,Room,Bed"
set /p CONFIRMED="Is the file named %~1 the correct file and in the correct format (Y) or should we check for more files (N)?"
if /I "%CONFIRMED%"=="Y" (
	set CONFIRMEDFILE=%~1
	set CORRECT=%CONFIRMED%
)
if /I "%CONFIRMED%"=="N" EXIT /b
EXIT /b

:STUDENTTEMPLATE
echo Student #,Last Name,First Name,Email,Area (St. Jerome's University),Building (Ryan Hall (North Tower) or Siegfried Hall (South Tower) of FINN),Floor (Level X),Room (XXXX),Bed > %USERNAME%template%TODAY%.csv
exit /b

:CONFERENCETEMPLATE
echo Last Name,First Name,Building (Ryan Hall (North Tower) or Siegfried Hall (South Tower)of FINN),Floor (Level X),Room (XXXX) > %USERNAME%template%TODAY%.csv
exit /b

:GENERALTEMPLATE
REM echo Last Name,First Name,Department > %USERNAME%template%TODAY%.csv
curl -LJo GeneralTemplate.xlsx  https://%GITHUBKEY%@github.com/tait-kelly/Salto/raw/main/GeneralTemplate.xlsx > NUL
exit /b

:GETRESDOOREXTID VAR ROOMNAME
::                   -- VAR   [in]     - return variable
::                   -- ROOMNAME [in] - door name to be searched for.
REM This is going to a procedure call to determine and return the EXTID of the door assignments based on what is in the ereslife export file
REM echo time to find the string matching:%~2
findstr /b /C:"%~2" doorswithids.txt > results.txt
for /F "tokens=1-2 delims=," %%a in (results.txt) do (
	REM echo Reading in the file named %%a and creating the import files
REM	echo we have delims of %%a and %%b
	set "%~1=%%b"
	REM set DOOREXTID=%~1
REM echo looks like the Door EXTID should be %%b
REM	PAUSE
)
EXIT /b

:GETRESACCESSLEVELEXTID VAR FLOOR BUILDINGNAME 
REM This is going to be a procedure call to determine and return the EXTID of the access level based on the assignment in the ereslife export
findstr /b /c:"Resident %~2 %~3 %~4" accesslevelswithids.txt > results.txt
for /F "tokens=1-2 delims=," %%a in (results.txt) do (
	REM echo Reading in the file named %%a and creating the import files
	set "%~1=%%b"
	REM echo looks like the Access Level EXTID should be %%b
	REM PAUSE
)
EXIT /b

:GETCONFACCESSLEVELEXTID VAR FLOOR BUILDINGNAME 
REM This is going to be a procedure call to determine and return the EXTID of the access level based on the assignment in the ereslife export
REM echo I am going to search for Conference %~2%~3 in the access levles file.
findstr /b /c:"CONFERENCE %~2%~3" accesslevelswithids.txt > results.txt
for /F "tokens=1-2 delims=," %%a in (results.txt) do (
	REM echo Reading in the file named %%a and creating the import files
	set "%~1=%%b"
	REM echo looks like the Access Level EXTID should be %%b
	REM PAUSE
)
REM PAUSE
EXIT /b



:SCRIPTUPDATE
REM echo I am in the script update section
REM I can grab the current version listing from github via curl -LJO  https://%GITHUBKEY%@github.com/tait-kelly/SALTO/raw/main/Version.txt
if EXIST "%CD%\Version.txt" del "%CD%\Version.txt"
curl -LJOs https://%GITHUBKEY%@github.com/tait-kelly/SALTO/raw/main/Version.txt > NUL
for /f "tokens=1-2 delims=:" %%a in ('FINDSTR /C:"Version:" Version.txt') do set CURRVER=%%b
REM echo time for the comparison.
if "%CURRVER%" LEQ "%VERSION%" (
	echo well looks like we have the current version lets resume the script.
	exit /b
)
echo time to check if %CURRVER% GTR %VERSION%
if "%CURRVER%" GEQ "%VERSION%" (
	curl -LJo spaceimport%CURRVER%.bat https://%GITHUBKEY%@github.com/tait-kelly/SALTO/raw/main/spaceimport.bat

)
set /p RUNNEW="I have the new script version do you want to run it now (y/n or yes/no)?"
if /I "%RUNNEW%"=="y" (
REM	echo if you selected yes I should launch spaceimport%CURRVER%.bat s
REM 	echo I am going to start the new script now
	copy spaceimport.bat spaceimport%VERSION%.bat
	cls
	start "Salto Space Import Version %CURRVER%" /B spaceimport%CURRVER%.bat s
	EXIT
)	
if /I "%RUNNEW%"=="yes" (
REM 		echo I am going to start the new script now
	copy spaceimport.bat spaceimport%VERSION%.bat
	cls
	start "Salto Space Import Version %CURRVER%" /B spaceimport%CURRVER%.bat s
	EXIT
)
exit /b



:IMPORTINSTRUCTIONS
REM This will be the instructions for performing an import. Need to have a few conditionals based on if it is a student import or general.
cls
echo Now is the start of the instructions and manual process please follow the instructions that follow exactly.
echo INSTRUCTIONS PART 1 OF 2
echo -----------------------------------------------------------
echo 1. Login to salto at http://172.25.126.100:8100/index.html
echo 2. Click on the menu option tools then Syncronization
echo 3. Select CSV import and click OK.
echo 4. Confirm that under the entity section User is selected
if /I %importtype%==R echo 5. Ensure that Student Affairs is selected for Partition for new entities
if /I %importtype%==G echo 5. Ensure that General is selected for Partition for new entities
if /I %importtype%==C echo 5. Ensure that General is selected for Partition for new entities
echo 6. Under "Select File to import/Syncronize" enter C:\SALTO\ProAccess Space\data\imports\%USERNAME%import%today%.csv
echo 7. Change Skip Row to "1" skip first row which will the headers
echo 8. Ensure Custom is selected for separator and that ; is the separator with , as secondary and " as text qualifier (this is all the default settings)
echo 9. Select Next 
echo Press enter to continue to the next part of the instructions
PAUSE
cls
echo INSTRUCTIONS PART 2 OF 2
echo -----------------------------------------------------------
if /I %importtype%==R (
	echo 10. Add in a total of 11 Fields and specify each field in the order by selecting each field and searching for the field name
	echo ---1. Action [Action]
	echo ---2. Ext ID [ExtID]
	echo ---3. First name [FirstName]
	echo ---4. Last name [LastName]
	echo ---5. Title [Title]
	echo ---6. Override privacy [Privacy]
	echo ---7. Enable auditor in the key [AuditOpenings]
	echo ---8. Calendar [CalendarID]
	echo ---9. Access level ID list [ExtAccessLevelIDList]
	echo ---10. Access point ID list [EXTDoorIDList]
	echo ---11. User expiration [UserExpiration.EXPDate]
)
if /I %importtype%==G (
	echo 10. Add in a total of 9 Fields and specify each field in the order by selecting each field and searching for the field name
		echo ---1. Action [Action]
	echo ---2. Ext ID [ExtID]
	echo ---3. First name [FirstName]
	echo ---4. Last name [LastName]
	echo ---5. Title [Title]
	echo ---6. Override privacy [Privacy]
	echo ---7. Enable auditor in the key [AuditOpenings]
	echo ---8. Calendar [CalendarID]
	echo ---9. User expiration [UserExpiration.EXPDate]
)
if /I %importtype%==C (
	echo 10. Add in a total of 11 Fields and specify each field in the order by selecting each field and searching for the field name
	echo ---1. Action [Action]
	echo ---2. Ext ID [ExtID]
	echo ---3. First name [FirstName]
	echo ---4. Last name [LastName]
	echo ---5. Title [Title]
	echo ---6. Override privacy [Privacy]
	echo ---7. Enable auditor in the key [AuditOpenings]
	echo ---8. Calendar [CalendarID]
	echo ---9. Access level ID list [ExtAccessLevelIDList]
	echo ---10. Access point ID list [EXTDoorIDList]
	echo ---11. User expiration [UserExpiration.EXPDate]
)
echo 11. Verify all fields are set exactly as listed then click next
echo 12. Verify the basic information on the next screen is correct and then click Finish to start the import process
echo 13. When done if no errors verify that the users where all imported correctly by viewing them in the user list in salto
set /p WORKED="Please confirm if the import appears to have worked or not (Y/N)?"
if "WORKED"=="Y" echo Great glad the import worked
if "WORKED"=="N" (
	echo Sorry the import didn't work correctly please submit a request at sju.ca/rt-it 
	echo This script will now open the browser to submit the request
	timeout /T 10
	start "" https://uwaterloo.atlassian.net/servicedesk/customer/portal/14/group/259/create/1072
)	
EXIT /B

:EOF
REM echo Looks like this is the end of the script
if EXIST files.txt del files.txt
if EXIST results.txt del results.txt
if EXIST doorswithids.txt del doorswithids.txt
if EXIST accesslevelswithids.txt del accesslevelswithids.txt
if EXIST count.txt del count.txt
if EXIST %USERNAME%import%today%.csv del %USERNAME%import%today%.csv
echo Everything should now be done please press enter to close this window.
PAUSE
EXIT
