@echo off


REM ============================CURRENT STATUS===================================================
REM ============================CURRENT STATUS===================================================


REM =================================NOTES=======================================================
REM Version 2.0
REM New version for SALTO SPACE imports
REM 2022-06-10 Finished script to a point of needing to parse the student import file.
REM =================================NOTES=======================================================

REM ==============================Pending Changes / Improvements=================================
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



set VERSION=2.0
set COMPILED=June 10th, 2022
for /f "delims=." %%a in ('wmic OS Get localdatetime ^| find "."') do set dt=%%a
set today=%dt:~0,8%
set GITHUBKEY=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
set TITLE=Welcome to the new Salto Import script version %VERSION% compiled on %COMPILED%
GOTO IMPORTTYPE

set IMPORTTYPE=0
set IMPORTTEMPLATE=0
set EXPIRY=0

curl -LJo doorswithids.csv  https://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@github.com/tait-kelly/Salto/raw/main/doorswithids.csv

:IMPORTTYPE
Set /P IMPORTTYPE="Are you using the script for Residence imports or for standard users? (R or S)"
if /I %importtype%==R goto IMPORTORTEMPLATE
if /I %importtype%==S goto IMPORTORTEMPLATE
echo Looks like you made an invalid selection press any key to restart
PAUSE
GOTO IMPORTTYPE

:IMPORTORTEMPLATE
Set /P IMPORTORTEMPLATE="Do you have a file with all the data to be processed (D) or do you need a template created that you can complete and then import (T)"
if /I %IMPORTORTEMPLATE%==D goto USEREXPIRY
if /I %IMPORTORTEMPLATE%==T goto USEREXPIRY
echo Looks like you made an invalid selection press any key to restart
PAUSE
GOTO IMPORTORTEMPLATE

:USEREXPIRY
echo Next will be an prompt for the imported user expiry. The data must be entered in a format of YYYY-MM-DD, if it is not entered correctly the expiry will be set to one month from the import day.
set /p EXPIRY="Expiry Date: YYYY-MM-DD."
set EXPIRY=%EXPIRY%T23:59:00
echo set and expiry to:%EXPIRY%
PAUSE
if /I %importtype%==R goto STARTR
if /I %importtype%==S goto STARTS

:STARTR
echo now in the start procedure with a importtype:%importtype% and importtemplate of:%IMPORTORTEMPLATE%
PAUSE
if /I %IMPORTORTEMPLATE%==D (
	echo You specified you will be providing a data file for this script to parse and import into salto.
	echo The data file should be a CSV-Comma Separated Values- in the format of "Last Name,First Name,Building,Floor,Room"
	echo The file should also be in the folder %CD%. Press enter at the next prompt to open file explorer to this folder
	echo Once you have copied the file to the folder %CD% press enter on this screen to continue
	REM PAUSE
	explorer.exe %CD%
	PAUSE
	GOTO STUDENTIMPORTPARSE
	echo Looks like all should be done for the parsing now so need to go to import instructions
)
if /I %IMPORTORTEMPLATE%==T (
	echo You have specified that you would like a template created for you and then import the data
	echo Next a template will be created and opened for you to complete once done please select save then continue on this script
	PAUSE
	call:STUDENTTEMPLATE
	%TODAY%%USERNAME%.csv
	PAUSE
	GOTO STUDENTIMPORTPARSE	
	echo Looks like all should be done for the parsing now so need to go to import instructions
)
	
:STARTS

	


:STUDENTIMPORTPARSE
REM This will now create a proper template file for the import
REM In this procedure we are going to export the user file
SETLOCAL enabledelayedexpansion
REM cls
del file.csv
set COUNT=0
REM echo I am in the parsing with a file of:%~1
del files.txt
dir "%CD%"\*.csv /b >> "%CD%"\files.txt
for /F "tokens=*" %%a in (files.txt) do (
	REM echo Reading in the file named %%a and creating the import files
	CALL:FILECONFIRMLOOP "%%a"
)
echo Action,ExtID,First Name,Last Name,Title,Privacy,AuditOpenings,CalendarID,ExtAccessLevelIDList,EXTDoorIDList,UserExpiration.EXPDate >> %USERNAME%import%today%.csv
for /F "skip=1 tokens=1-20 delims=," %%b in (%CONFRIMEDFILE%) do (
	REM The new format for the exported file from ereslife is Student#(b), Last Name (c), Firstname (d), email (e), Area(f), Building (g), Floor (h), Suite (i), Room (j), Bed (k)
	REM Sample provide by Melissa on June 10th 2022 is "Student ID,Last Name,First Name,Email,St. Jerome's University,Siegfried Hall (South Tower),Level 2,2517 (Don Room),2517,A"
	REM Only need Last Name (c), Firstname (d), Building (g), Floor (h), Room (j) for the parsing
	
	REM echo I am going to create the user import file now
	set floor=%%h
	REM echo floor should be the last number of %%f
	REM echo I want to set the floor to:!floor:~-1!
	set floornum=!floor:~-1!
	REM echo got a floor of !floornum!
	REM echo now I have to find out which Building will be assigned based on %%e I am going to feed in %%e and do a findstring on it.
	echo %%g|findstr /C:"Ryan" 
	if !errorlevel!==0 (
		set building=RH
		set BUILDINGNAME=Ryan Hall
		set ROOM=RB-%%j
	)
	echo %%g|findstr /C:"Siegfried"
	if !errorlevel!==0 (
		set building=SH
		set BUILDINGNAME=Siegfried Hall
		set ROOM=RB-%%j
	)
	echo %%g|findstr /C:"Finn"
	if !errorlevel!==0 (
		set building=JRF
		set BUILDINGNAME=Finn
		set ROOM=JRF-%%j
	)
	REM echo got a building of !building!
	REM echo I am going to wire the line:RES!floornum!!building!,%%d,%%c,%%b,%today% to the file
	call:GETRESDOOREXTID DOOREXTID %ROOM%
	call:GETRESACCESSLEVELEXTID ACCEESSEXTID "Resident %FLOORNUM% %BUILDINGNAME%"
	set EXTID=%TODAY%%USERNAME%%COUNT%
	echo I just created an EXTID of:%EXTID%
	SET /A COUNT=COUNT+1
	echo the count is now:%COUNT%
	echo 1;%EXTID%;%%d;%%c;RES!floornum!!building!;0;1;6;;;%ACCESSEXTID%;%DOOREXTID%;%EXPIRY% >> %USERNAME%import%today%.csv
	REM echo RES!floornum!!building!,%%d,%%c,%%b,%today% >> userimport%today%.csv
	REM if  !building!==JRF echo RES!floornum!!building! %%d %%c,JRF%%g-Residence Room >>importuserdoor%today%.csv
	REM echo RES!floornum!!building! %%d %%c,RB%%g>>importuserdoor%today%.csv
)
del file.csv
ENDLOCAL
EXIT /b


:FILECONFIRMLOOP
REM THis will be a loop to confirm that the CSV file found is the correct one.
echo Looks like there is a CSV file in the %CD% named %~1 If this is the file to be parsed for the import it should be in a format with the one user per line in a format of "Student #,Last Name,First Name,Building,Floor,Suite,Room,Bed"
set /p CONFIRMED="Is the file named %~1 the correct file and in the correct format (Y) of should we check for more files (N)?"
if /I "%CONFIRMED%"=="Y" set CONFIRMEDFILE=%~1
if /I "%CONFIRMED%"=="N" EXIT /b
EXIT /b

:STUDENTTEMPLATE
echo Last Name,First Name,Building,Floor,Room > %TODAY%%USERNAME%.csv
exit /b

:GETRESDOOREXTID VAR ROOMNAME
::                   -- VAR   [in]     - return variable
::                   -- ROOMNAME [in] - door name to be searched for.
REM This is going to a procedure call to determine and return the EXTID of the door assignments based on what is in the ereslife export file
curl -LJo doorswithids.csv  https://%GITHUBKEY%@github.com/tait-kelly/Salto/raw/main/doorswithids.csv
findstr /b /c:"%~2" doorswithids.csv > results.txt
for /F "tokens=*" %%a in (results.txt) do (
	REM echo Reading in the file named %%a and creating the import files
	set VAR=%%b
	echo looks like the Door EXTID should be %VAR%
	PAUSE
)
EXIT /b

:GETRESACCESSLEVELEXTID VAR ACCESSLEVEL 
REM This is going to be a procedure call to determine and return the EXTID of the access level based on the assignment in the ereslife export

curl -LJo doorswithids.csv  https://%GITHUBKEY%@github.com/tait-kelly/Salto/raw/main/doorswithids.csv
findstr /b /c:"%~2" accesslevelswithids.csv > results.txt
for /F "tokens=*" %%a in (results.txt) do (
	REM echo Reading in the file named %%a and creating the import files
	set VAR=%%b
	echo looks like the Access Level EXTID should be %VAR%
	PAUSE
)
EXIT /b

:SCRIPTUPDATE
REM echo I am in the script update section
REM I can grab the current version listing from github via curl -LJO  https://%GITHUBKEY%@github.com/tait-kelly/ducs/raw/main/Version.txt
REM echo I am in the script update section
if EXIST %CD%\Versions.txt del %CD%\Version.txt
curl -LJOs  https://%GITHUBKEY%@github.com/tait-kelly/ducs/raw/main/Version.txt > NUL
for /f "tokens=1-2 delims=:" %%a in ('FINDSTR /C:"Version:" Version.txt') do set CURRVER=%%b
if %CURRVER% LEQ %VERSION% echo well looks like we have the current version lets resume the script.
if "%CURRVER%" GTR "%VERSION%" (
	echo looks like there is a newer version
	curl -LJo newducs%CURRVER%.bat  https://%GITHUBKEY%@github.com/tait-kelly/ducs/raw/main/newducs.bat
	set /p RUNNEW="I have the new script version do you want to run it now (y/n or yes/no)?"
	if "%RUNNEW%"=="y" start newducs%CURRVER%.bat s
	if "%RUNNEW%"=="yes" start newducs%CURRVER%.bat s
	copy newducs.bat newducs%VERSION%.bat
	GOTO EOF
)
del Version.txt
EXIT /b


:IMPORTINSTRUCTIONS
REM This will be the instructions for performing an import. Need to have a few conditionals based on if it is a student import or general.
REM Steps Login to salto at http://172.25.126.100:8100/index.html
REM Login to salto
REM Click on the menu option tools -> Syncronization
REM Select CSV import and click OK.
REM Confirm that under the entity section User is selected
REM If User specified Student Import ensure that Student Affairs is selected for Partition for new entities
REM If User specified general import ensure that General is selected for Partition for new entities
REM Under File Configuration specify C:\SALTO\ProAccess Space\data\imports\ and then file name (this should be generated not user named)
REM Change Skip Row to skip first row which will the headers
REM ensure Custom is selected for separator and that ; is the separator with , as secondary and " as text qualifier (this is all the default settings)
REM Select Next 
REM Add in a total of 11 Fields and specify each field in the order by selecting each field and searching for the field name
REM 1. Action [Action]
REM 2. Ext ID [ExtID]
REM 3. First name [FirstName]
REM 4. Last name [LastName]
REM 5. Title [Title]
REM 6. Override privacy [Privacy]
REM 7. Enable auditor in the key [AuditOpenings]
REM 8. Calendar [CalendarID]
REM 9. Access level ID list [ExtAccessLevelIDList]
REM 10. Access point ID list [EXTDoorIDList]
REM 11. User expiration [UserExpiration.EXPDate]
REM Verify all fields are set exactly as listed then click next
REM Verify the basic information on the next screen is correct and then click Finish to start the import process
REM When done if no errors verify that the users where all imported correctly by viewing them in the user list in salto
REM Prompt user to confirm if import worked correctly and if it did not confirm that they should submit a Jira ticket and then open sju.ca/rt-it for them.


