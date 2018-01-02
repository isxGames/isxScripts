#ifndef TOPLEVELOBJECT
#define TOPLEVELOBJECT_SELF
#define TOPLEVELOBJECT(name,funcname) extern bool funcname(int argc, char *argv[], LSTYPEVAR &Ret);
#endif

// ----------------------------------------------------
// Top-Level Objects

//TOPLEVELOBJECT("Lua5",TLO_Lua5);

















// ----------------------------------------------------
#ifdef TOPLEVELOBJECT_SELF
#undef TOPLEVELOBJECT_SELF
#undef TOPLEVELOBJECT
#endif