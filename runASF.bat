::Stops the Task "SteamIdler" that the task is only run once
schtasks.exe /change /tn "SteamIdler" /disable

::Start ASF as your local user
runas /user:pcname\username /savecred "cmd /c start /min C:\path\to\ArchiSteamFarm.exe"