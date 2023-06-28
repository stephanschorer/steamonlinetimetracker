# Steam Online Time Tracker
This tool will track your Steam Online time (the time not playing any games) on your Steam Profil, like this:

![Screenshot 2023-06-26 214647](https://github.com/stephanschorer/steamonlinetracker/assets/63855548/f6416fac-93ba-43ea-b252-434d5b67ac1d)

## ASF instance
First you will need to setup an ASF instance on your local pc:  
https://github.com/JustArchiNET/ArchiSteamFarm

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

## Test script files
❗Note you will need to run each bat files at least once with admin privileges.  
❗Keep in mind you will need to adjust the files to your local environment  

You will need to adjust the following variables inside the *runASF.bat* file
- pcname
- username
- task names (if you dont use SteamIdler, SteamIdlerExit)
- path to ArchiSteamFarm.exe

Afterwards you can try to run both files (with admin privileges)

If everything works, you should be prompted to enter the credetials for the choosen user (only one time required).  
You should see that the ASF console starts in the background.  
And if you execute *exitASF.bat* with admin privileges the ASF console should close.

## Windows Hacking
Now that you can manually start and stop the tracking of the Online Time, you probably want to automate this.  
This is done with Windows Task Scheduler.

You will need three tasks.
- One that starts the process in the background (we will name it **SteamIdler**)
- One that stops the process if you exit Steam (we will name it **SteamIdlerExit**)
- And one that re-enables the start process if you do not exit Steam before shutting down your pc

But before you can create the tasks, you will need to enable the logging for application starts/stops:
1. Start and enter secpol.msc into the Run box
2. Navigate to Local Policies/Audit Policy
3. Double Click Audit process tracking and enable Success
4. Now, if you start any application, if you look in Event Viewer / Security Log you will see a Process Creation event 4688 each time an application is started and 4689 for each application stop.    

Now start the Task Scheduler (taskschd.msc) and create your first task:
1. On the "General" Tab, give the task a name (**SteamIdler**)
2. On the "Triggers" tab, create a new trigger, and choose On an event as the trigger
3. Choose Custom, and click New Event Filter
4. Switch to the XML tab and tick "edit manually"
5. Insert the following query: (note you may need to change the Steam path)
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
6. Click "OK" two times
7. On the "Action" tab create new action "run programm"
8. Browse to the path and select *runASF.bat*
9. Click "OK" two times

Now you will need to create the second task to stop the process automatically (**SteamIdlerExit**).  
All steps are the same except the Query in Step 5:
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

and the script in Step 8:  
--> *exitASF.bat*

The last Task is really simple:
1. On the "General" Tab, give the task a name (**SteamIdlerEnableOnStart**)
2. On the "Triggers" tab, create a new trigger, and choose "on login" for your specific user
3. Click "OK"
4. On the "Action" tab create new action "run programm"
5. Browse to the path and select *exitASF.bat*

## Finished

Now everytime you start Steam the ASF process will be started automatically in the background.
And if you exit Steam completely the ASF process will be stopped.
