// Guids.cs
// MUST match guids.h
using System;

namespace Company.LavishScriptVS
{
    static class GuidList
    {
        public const string guidLavishScriptVSPkgString = "d502acfb-e020-427d-bd40-af3b310749eb";
        public const string guidLavishScriptVSCmdSetString = "ebc62b19-4678-4bff-aa94-9c5f3ef0bb73";

        public static readonly Guid guidLavishScriptVSCmdSet = new Guid(guidLavishScriptVSCmdSetString);
    };
}