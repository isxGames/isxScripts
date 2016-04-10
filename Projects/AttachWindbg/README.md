# AttachWindbg 
Version 1 by Cybertech
---
Attaches windbg to a launched process immediately after Inner Space starts it, without additional clicks

## Instructions

1. Place the .cs and .xml in Scripts\AttachWindbg\
2. Add the following to Pre-Startup for the game you wish to attach:
```
<Setting Name="AttachWindbg">execute ${If[${LavishScript.Executable.Find[ExeFile.exe](exists)},run AttachWindbg ${System.APICall[${System.GetProcAddress["kernel32.dll","GetCurrentProcessId"].Hex}]}]}</Setting>
```

## Example
```
<Set Name="Pre-Startup Sequence" GUID="1863684435">
    <Setting Name="Debugger">execute ${If[${LavishScript.Executable.Find[ExeFile.exe](exists)},run AttachWindbg ${System.APICall[${System.GetProcAddress["kernel32.dll","GetCurrentProcessId"].Hex}]}]}</Setting>
</Set>
```