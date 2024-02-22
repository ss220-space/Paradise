@echo off
cd "%~dp0\.."
call npm run lint -- --fix
timeout /t 9

