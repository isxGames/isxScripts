#ifndef DATATYPE
#define DATATYPE_SELF
#define DATATYPE(_class_,_variable_) extern class _class_ *_variable_
#endif
// ----------------------------------------------------
// data types

// sample
//DATATYPE(Lua5Type,pLua5Type);











// ----------------------------------------------------
#ifdef DATATYPE_SELF
#undef DATATYPE_SELF
#undef DATATYPE
#endif