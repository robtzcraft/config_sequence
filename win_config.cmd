
@echo off
rem             CMD Executer for Installation System (Windows Powershell)
rem             Author: @robtzcraft
rem             Version: 1.0.1

rem             Starting
PowerShell -Command "& {Start-Process PowerShell -ArgumentList '-ExecutionPolicy Bypass -File ""%~dp0/src/index.ps1""' -Verb RunAs}"
