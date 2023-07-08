::Stops the Task "SteamIdler" that the task is only run once
schtasks.exe /change /tn "SteamIdler_1" /disable

::Start ASF Run-Task
schtasks.exe /run /tn "SteamIdler_2"