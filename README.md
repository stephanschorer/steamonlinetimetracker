# Steam Online Time Tracker
This tool will track your Steam Online time (the time not playing any games) on your Steam Profil, like this:

![Screenshot 2023-06-26 214647](https://github.com/stephanschorer/steamonlinetracker/assets/63855548/f6416fac-93ba-43ea-b252-434d5b67ac1d)

## Step 1: ASF instance
First you will need to setup an ASF instance on your local pc.    

A good starting point will be the getting started wiki page:    
https://github.com/JustArchiNET/ArchiSteamFarm/wiki/Setting-up

Keep in mind, you will need to adjust the bot config file, that the bot will "farm" the Steam App:    
example config bot.json
```
{
  "Enabled": true,
  "GamesPlayedWhileIdle": [
    753
  ],
  "OnlineStatus": 0,
  "RemoteCommunication": 0,
  "SteamLogin": "username",
  "SteamPassword": "password"
}
```

## Step 2: Download Batch files
Download the following [files](https://github.com/stephanschorer/steamonlinetimetracker/tree/main/batch%20files) and save them into your destination folder:
- SteamIdler_1.bat
- SteamIdler_2.bat
- SteamIdlerExit.bat 

## Step 3: Adjust and test batch files
❗Keep in mind you will need to adjust the files to your local environment  
❗If you keep the schedule task names, you only need to change the *SteamIdler_2.bat* file

### SteamIdler_1.bat
If you want to change the task names, you will need to change them in all the files.
```
::Stops the Task "SteamIdler" that the task is only run once
schtasks.exe /change /tn "SteamIdler_1" /disable

::Start ASF Run-Task
schtasks.exe /run /tn "SteamIdler_2"
```

### SteamIdler_2.bat
Change the path to your ArchiSteamFarm.exe
```
::Start ASF as your local user
cmd /c start /min C:\Path\To\ArchiSteamFarm.exe
```

### SteamIdlerExit.bat
If you want to change the task names, you will need to change them in all the files.    
You don't need to adjust the ArchiSteamFarm.exe in this file, because with the taskkill the process itself will be killed - therefore no path declaration is required.
```
::Starts the Task "SteamIdler" again for "listening" to the start events on steam.exe
schtasks.exe /change /tn "SteamIdler_1" /enable

::Stops ASF process
taskkill /F /IM ArchiSteamFarm.exe
```

Afterwards you can try to run the *SteamIdler_2.bat* file, this should start your ASF instance.

## Step 4: Windows Hacking
Now that you can manually start and stop the tracking of the Online Time, you probably want to automate this.  
This is done with Windows Task Scheduler.

You will need four tasks:
- **SteamIdler_1**: Disables the listening for steam.exe execution events and runs the task which will start the ASF instance as the desired user
- **SteamIdler_2**: Runs the ArchiSteamFarm process minimized in background as your local user
- **SteamIdlerExit**: Enables the SteamIdler_1 task again and stops the ArchiSteamFarm process if you exit out of Steam
- **SteamIdlerEnableOnStart**: Enables the SteamIdler_1 task after a restart (in case you did not close Steam before shutting down your pc)

### Enable Logging for application events    
Before you can create the tasks, you will need to enable the logging for application starts/stops:
1. Run secpol.msc (search with Windows search)
2. Navigate to Local Policies/Audit Policy
3. Double Click Audit process tracking and enable Success
4. Now, each application start/stop will be logged in the event log

### Task Creation  
Now start the Task Scheduler (taskschd.msc) and create the four tasks:

#### SteamIdler_1
1. Right click, create new task
2. On the "General" Tab, give the task a name (**SteamIdler_1**)
3. Tick "Run with highest privileges"
4. On the "Triggers" tab, create a new trigger, and choose "On an event" as the trigger
5. Choose Custom, and click New Event Filter
6. Switch to the XML tab and tick "edit manually"
7. Insert the following query: (note you may need to change the Steam path)
```
<QueryList>
  <Query Id="0" Path="Security">
    <Select Path="Security">
       *[System[Provider[@Name='Microsoft-Windows-Security-Auditing'] and (band(Keywords,9007199254740992)) and (EventID=4688)]]
        and
       *[EventData[Data[@Name='NewProcessName'] and (Data='C:\Program Files (x86)\Steam\steam.exe')]]
     </Select>
  </Query>
</QueryList>
```
8. Click "OK" two times
9. 8. On the "Action" tab create new action "run programm"
10. Browse to the path and select *SteamIdler_1.bat*
11. Click "OK" two times
12. You may need to enter your Windows password

#### SteamIdler_2
1. Right click, create new task
2. On the "General" Tab, give the task a name (**SteamIdler_2**)
8. On the "Action" tab create new action "run programm"
9. Browse to the path and select *SteamIdler_2.bat*
10. Click "OK" two times
    
#### SteamIdlerExit
1. Right click, create new task
2. On the "General" Tab, give the task a name (**SteamIdlerExit**)
3. Tick "Run with highest privileges"
4. On the "Triggers" tab, create a new trigger, and choose "On an event" as the trigger
5. Choose Custom, and click New Event Filter
6. Switch to the XML tab and tick "edit manually"
7. Insert the following query: (note you may need to change the Steam path)
```
<QueryList>
  <Query Id="0" Path="Security">
    <Select Path="Security">
       *[System[Provider[@Name='Microsoft-Windows-Security-Auditing'] and (band(Keywords,9007199254740992)) and (EventID=4689)]]
        and
       *[EventData[(Data='C:\Program Files (x86)\Steam\steam.exe')]]
     </Select>
  </Query>
</QueryList>
```
8. Click "OK" two times
9. 8. On the "Action" tab create new action "run programm"
10. Browse to the path and select *SteamIdlerExit.bat*
11. Click "OK" two times
12. You may need to enter your Windows password

#### SteamIdlerEnableOnStart
1. Right click, create new task
2. On the "General" Tab, give the task a name (**SteamIdlerEnableOnStart**)
3. Tick "Run with highest privileges"
4. On the "Triggers" tab, create a new trigger, and choose "On startup" as the trigger
5. Click "OK"
6. On the "Action" tab create new action "run programm"
7. Browse to the path and select *SteamIdlerExit.bat*
8. Click "OK" two times
9. You may need to enter your Windows password

## Finished
Now everytime you start Steam the ASF process will be started automatically in the background.
If you exit Steam, the ASF process will be stopped.

## Uninstallation
To disable all of this again, you just need to delete the four tasks.
