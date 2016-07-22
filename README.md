# Startup

This is a collection of files that make it convenient to start Symphony and Stage Server in the Rieke Lab and keep user packages up-to-date.

- **Stage Server.bat** - batch script that starts MATLAB and calls startStageServer.m
- **Stage Server.ico** - Stage icon for Windows
- **Stage Server.lnk** - shortcut that runs "Stage Server.bat" (exists because batch scripts cannot be added to the Windows taskbar)
- **Symphony.bat** - batch script that starts MATLAB and calls startSymphony.m
- **Symphony.ico** - Symphony icon for Windows
- **Symphony.lnk** - shortcut that runs "Symphony.bat" (exists because batch scripts cannot be added to the Windows taskbar)
- **startStageServer.m** - MATLAB script that adds the Symphony search path to the MATLAB path and starts the Symphony Server app
- **startSymphony.m** - MATLAB script that updates all git repos on the Symphony search path and starts the Symphony app
