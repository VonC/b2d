@echo off

call %~dp0senv.bat

rem call nodes\kv\senv.bat
rem dmsshcmd kv ". .ashrc; . ./next ; pwd; ./build" -f
rem call nodes\blessed\senv.bat
rem dmsshcmd blessed ". .ashrc; . ./next ; pwd; ./build" -f
if "%SKIP_STAGING%"=="" (
	echo staging
	call nodes\staging\senv.bat
	dmsshcmd staging ". .ashrc; . ./next ; pwd; ./build" -f
	call docker-machine restart staging
	dmsshcmd staging ". .ashrc; . ./next ; pwd; ./build" -f
)
if "%SKIP_EXTERNAL%"=="" (
	echo external
	call nodes\external\senv.bat
	dmsshcmd external ". .ashrc; . ./next ; pwd; ./build" -f
	call docker-machine restart external
	dmsshcmd external ". .ashrc; . ./next ; pwd; ./build" -f

)
