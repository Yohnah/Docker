@echo off

set current_path=%~dp0
set docker_path=%userprofile%\AppData\Local\Yohnah\Docker

rmdir /S /Q %docker_path%

reg delete HKCU\Environment /v DOCKER_HOST /f