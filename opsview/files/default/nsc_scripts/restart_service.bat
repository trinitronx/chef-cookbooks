@echo off
REM Get the name of the service
SET SERVICE=%1

for /F "tokens=3 delims=: " %%H in ('sc query "%SERVICE%" ^| findstr "        STATE"') do (
	if /I "%%H" NEQ "RUNNING" (
		net start "%SERVICE%"
	)	else (
		echo The service is already running.
	)
)

exit /B 0