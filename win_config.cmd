
@echo off
rem             CMD Executer for Installation System (PS1)
rem             Author: @robtzcraft
rem             Version: 1.0.0

rem             Starting
PowerShell -Command "& {Start-Process PowerShell -ArgumentList '-ExecutionPolicy Bypass -File ""%~dp0/src/installer.ps1""' -Verb RunAs}"
