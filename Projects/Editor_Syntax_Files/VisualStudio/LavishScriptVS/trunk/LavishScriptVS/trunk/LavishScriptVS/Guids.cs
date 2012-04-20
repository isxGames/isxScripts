// Guids.cs
// MUST match guids.h
using System;

namespace Company.LavishScriptVS
{
    static class GuidList
    {
        public const string guidLavishScriptVSPkgString = "4dbe00db-21d6-4bcc-8c7d-86909337fec2";
        public const string guidLavishScriptVSCmdSetString = "e13cfb7f-c64d-4270-a6b4-88978af2f00b";

        public static readonly Guid guidLavishScriptVSCmdSet = new Guid(guidLavishScriptVSCmdSetString);
    };
}