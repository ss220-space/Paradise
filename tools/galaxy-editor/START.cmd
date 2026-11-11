@echo off
cd /d "%~dp0..\.."
node tools\galaxy-editor\server.mjs --open
pause
