@echo off

set current_path=%~dp0
set docker_path=%userprofile%\AppData\Local\Yohnah\Docker
set serviceip=<ip address to parser>

call:main&goto:EOF

:setdockerhost
echo "Set DOCKER_HOST environment variable"
for /f "tokens=2" %%h in ('vagrant ssh-config ^|findstr "HostName"') do ( SET vagrant_hn=%%h)
for /f "tokens=1" %%b in ('vagrant port --guest 2375') do ( SET vagrant_port=%%b)
setx DOCKER_HOST tcp://%vagrant_hn%:%vagrant_port%

echo Docker service running at tcp://%vagrant_hn%:%vagrant_port%
goto:EOF

:copydockercli
echo Copying Docker cli to folder %docker_path%
robocopy %current_path%\docker %docker_path% /MIR
goto:EOF

:createdockerpath
echo Creating folder %docker_path%
md %docker_path%
goto:EOF

:setpath
echo Set the PATH environment variable
setx PATH %~1;%docker_path%
goto:EOF

:check_path
echo Checking the environment variable PATH
for /f "tokens=3" %%a in ('reg query HKCU\Environment /v Path') do ( SET variable=%%a)
echo %variable%|find "%docker_path%"
if errorlevel 1 ( call:setpath %variable% )
goto:EOF


:main
call:check_path
call:createdockerpath
call:copydockercli
call:setdockerhost
goto:EOF