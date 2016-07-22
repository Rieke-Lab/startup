# Startup

This is a collection of files that make it convenient to start Symphony and Stage Server in the Rieke Lab and keep user git packages up-to-date.

- **Stage Server.bat** - batch script that starts MATLAB and calls startStageServer.m
- **Stage Server.ico** - Stage icon for Windows
- **Stage Server.lnk** - shortcut that runs "Stage Server.bat"
- **Symphony.bat** - batch script that starts MATLAB and calls startSymphony.m
- **Symphony.ico** - Symphony icon for Windows
- **Symphony.lnk** - shortcut that runs "Symphony.bat"
- **startStageServer.m** - MATLAB script that adds the Symphony search path to the MATLAB path and starts the Symphony Server app
- **startSymphony.m** - MATLAB script that updates all git repos on the Symphony search path and starts the Symphony app

Note that that \*.lnk shortcuts only exist because batch scripts cannot be added to the Window's taskbar. A workaround is to have a shortcut that points to the batch script and add the shortcut to the taskbar. Thus we have shortcuts so we can add Symphony and Stage Server to the Window's taskbar.
