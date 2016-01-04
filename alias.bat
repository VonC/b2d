@echo off
if "%1"=="" (
	doskey /macros
	goto :EOF
)
doskey /macros:%1
