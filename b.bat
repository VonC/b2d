@echo off

call %~dp0senv.bat

call nodes\kv\senv.bat
set ff=""
if "%1"=="%f" (
	set ff="-f"
)
dmsshcmd kv ". .ashrc; ls -alrth; . ./next ; pwd; ./build" %ff%
call nodes\blessed\senv.bat
dmsshcmd blessed ". .ashrc; pwd; . ./next ; pwd; ./build" %ff%
if "%SKIP_STAGING%"=="" (
	echo staging
	call nodes\staging\senv.bat
	dmsshcmd staging ". .ashrc; . ./next ; pwd; ./build" %ff%
	call docker-machine restart staging
	dmsshcmd staging ". .ashrc; . ./next ; pwd; ./build" %ff%
)
if "%SKIP_EXTERNAL%"=="" (
	echo external
	call nodes\external\senv.bat
	dmsshcmd external ". .ashrc; . ./next ; pwd; ./build" %ff%
	call docker-machine restart external
	dmsshcmd external ". .ashrc; . ./next ; pwd; ./build" %ff%

)
