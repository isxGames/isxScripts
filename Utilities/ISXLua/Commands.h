#ifndef COMMAND
#define COMMAND_SELF
#define COMMAND(name,cmd,parse,hide) extern int cmd(int argc, char *argv[])
#endif
// ----------------------------------------------------
// commands

// sample
COMMAND("Lua5",CMD_Lua5,true,false);






// ----------------------------------------------------
#ifdef COMMAND_SELF
#undef COMMAND_SELF
#undef COMMAND
#endif