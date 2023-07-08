::Starts the Task "SteamIdler" again for "listening" to the start events on steam.exe
schtasks.exe /change /tn "SteamIdler_1" /enable

::Stops ASF process
taskkill /F /IM ArchiSteamFarm.exe