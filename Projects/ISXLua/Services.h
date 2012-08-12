#ifndef SERVICE
#define SERVICE_SELF
#define SERVICE(_name_,_callback_,_variable_) extern HISXSERVICE _variable_;extern void __cdecl _callback_(ISXInterface *pClient, unsigned long MSG, void *lpData);
#endif
// ----------------------------------------------------
// services

SERVICE("Lua5 Service",Lua5Service,hLua5Service);












// ----------------------------------------------------
#ifdef SERVICE_SELF
#undef SERVICE_SELF
#undef SERVICE
#endif