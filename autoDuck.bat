@echo off
if NOT EXIST "%temp%\autoDuck.ps1" (
powershell -noprofile -Command "iwr https://raw.githubusercontent.com/Naggelus/autoDuck/master/autoDuck.ps1 -OutFile $env:TEMP\autoDuck.ps1"
)
powershell -NoProfile -Command "& {Start-Process PowerShell.exe -ArgumentList '-NoProfile -ExecutionPolicy Bypass -File ""$env:TEMP\autoDuck.ps1""' -Verb RunAs}"