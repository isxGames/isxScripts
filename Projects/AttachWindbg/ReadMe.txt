AttachWindbg v1 by CyberTech
 Description:
    Attaches windbg to a launched process immediately after Inner Space
    starts it, without additional clicks
 Instructions:
    1) Place the .cs and .xml in Scripts\AttachWindbg\
    2) Add the following to Pre-Startup for the game you wish to attach:
        <Setting Name="AttachWindbg">execute ${If[${LavishScript.Executable.Find[ExeFile.exe](exists)},run AttachWindbg exefile.exe]}</Setting>