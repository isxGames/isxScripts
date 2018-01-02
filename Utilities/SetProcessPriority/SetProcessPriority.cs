using System;
using System.Text;
using System.Diagnostics;
using InnerSpaceAPI;

namespace SetProcessPriority
{
	class Program
	{
		static void Main(string[] args)
		{
			if (args == null || args.Length == 0)
			{
				InnerSpace.Echo(" ");
				InnerSpace.Echo("SetProcessPriority v1 by CyberTech");
				InnerSpace.Echo(" Description:");
				InnerSpace.Echo("    Set the app priority for an app just launched by Inner Space");
				InnerSpace.Echo(" Instructions:");
				InnerSpace.Echo("    1) Place the .cs and .xml in Scripts\\SetProcessPriority\\");
				InnerSpace.Echo("    2) Add the following to Pre-Startup for the game you wish to attach:");
				InnerSpace.Echo("        \"<Setting Name=\"SetProcessPriority\">execute ${If[${LavishScript.Executable.Find[ExeFile.exe](exists)},run SetProcessPriority ${System.APICall[${System.GetProcAddress[\"kernel32.dll\",\"GetCurrentProcessId\"]}]}]}</Setting>\"");
				InnerSpace.Echo("    3) Be sure to update the executable name (ExeFile.exe) in the above command");
				InnerSpace.Echo(" ");
				InnerSpace.Echo("Error: Executable to attach to must be specified on the command line");
				return;
			}
			try
			{
				// See http://msdn.microsoft.com/en-us/library/system.diagnostics.processpriorityclass%28v=vs.110%29.aspx for priorities
				Int32 pid = Int32.parse(args0);
				System.Diagnostics.Process.GetProcessById(pid).PriorityClass = System.Diagnostics.ProcessPriorityClass.Normal;
			}
			catch (Exception e)
			{
				InnerSpace.Echo("SetProcessPriority Error: Unable to set priority");
			}
		}
	}
}

