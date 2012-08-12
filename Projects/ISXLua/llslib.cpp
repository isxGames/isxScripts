// Inner Space LUA library 
#include "ISXLua5.h"
#define llslib_c

extern "C"
{
#include "lua-5.0.2/include/lua.h"
#include "lua-5.0.2/include/lauxlib.h"
#include "lua-5.0.2/include/lualib.h"
};

int ls_exec(lua_State *L)
{
	char Output[4096];
	Output[0]=0;
	char *pOut=Output;
  int n = lua_gettop(L);  /* number of arguments */
  int i;
  lua_getglobal(L, "tostring");
  for (i=1; i<=n; i++) {
    const char *s;
    lua_pushvalue(L, -1);  /* function to be called */
    lua_pushvalue(L, i);   /* value to print */
    lua_call(L, 1, 1);
    s = lua_tostring(L, -1);  /* get result */
    if (s == NULL)
      return luaL_error(L, "`tostring' must return a string to `print'");
	pOut+=sprintf(pOut,"%s",s);
    lua_pop(L, 1);  /* pop result */
  }

  if (Output[0])
		pISInterface->ExecuteCommand(Output);
  return 0;
}

int ls_eval(lua_State *L)
{
	char Output[4096];
	Output[0]=0;
	char *pOut=Output;
  int n = lua_gettop(L);  /* number of arguments */
  int i;
  lua_getglobal(L, "tostring");
  for (i=1; i<=n; i++) {
    const char *s;
    lua_pushvalue(L, -1);  /* function to be called */
    lua_pushvalue(L, i);   /* value to print */
    lua_call(L, 1, 1);
    s = lua_tostring(L, -1);  /* get result */
    if (s == NULL)
      return luaL_error(L, "`tostring' must return a string to `print'");
	pOut+=sprintf(pOut,"%s",s);
    lua_pop(L, 1);  /* pop result */
  }

	char Data[4096];
	if (!pISInterface->DataParse(Output,Data,sizeof(Data)))
	{
		lua_pushnil(L);
		return 1;
	}
	lua_pushstring(L,Data);
	return 1;
}



int ls_getobject(lua_State *L)
{
	const char *name=luaL_checkstring(L,1);
	LSOBJECT *pRet=(LSOBJECT *)lua_newuserdata(L,sizeof(LSOBJECT));
	pRet->Ptr=0;
	pRet->Type=0;
	if (!name || !name[0])
	{
		return 1;
	}
	
	fLSTopLevelObject func=pISInterface->IsTopLevelObject(name);
	if (!func)
	{
		return 1;
	}
	LuaIndices Indices(L,1);

	if (!func(Indices.argc,Indices.argv,*pRet))
	{
		return 1;
	}
	char MetaTable[128];
	MetaTable[0]=0;
	ISXLuaScript::MakeDynamicLibraryName(pRet->Type->GetName(),MetaTable,sizeof(MetaTable));
	luaL_getmetatable(L, MetaTable);
	lua_setmetatable(L, -2);

	return 1;
}
int ls_getmember(lua_State *L)
{
	LSOBJECT *pIn=(LSOBJECT*)lua_touserdata(L, 1);

	LSOBJECT *pRet=(LSOBJECT *)lua_newuserdata(L,sizeof(LSOBJECT));
	pRet->Ptr=0;
	pRet->Type=0;
	LSTypeDefinition *pType=pIn->Type;

	if (!pType)
	{
		return 1;
	}
	LuaIndices Indices(L,1);

//	LSOBJECT Ret;
	pType->GetMemberEx(pIn->ObjectData,(char*)luaL_checkstring(L,2),Indices.argc,Indices.argv,*pRet);

	if (pRet->Type)
	{
		char MetaTable[128];
		MetaTable[0]=0;
		ISXLuaScript::MakeDynamicLibraryName(pRet->Type->GetName(),MetaTable,sizeof(MetaTable));
		luaL_getmetatable(L, MetaTable);
		lua_setmetatable(L, -2);
	}

//	lua_pushnumber(L,Ret.Int);
//	lua_pushstring(L,Ret.Type->GetName());
	return 1;
}
int ls_getmethod(lua_State *L)
{
	LSOBJECT *pIn=(LSOBJECT*)lua_touserdata(L, 1);
	LSTypeDefinition *pType=pIn->Type;
	if (!pType)
	{
		lua_pushnil(L);
		return 1;
	}
	LuaIndices Indices(L,1);

	int Ret=pType->GetMethodEx(pIn->ObjectData,(char*)luaL_checkstring(L,2),Indices.argc,Indices.argv);
	lua_pushnumber(L,Ret==1);
	return 1;
}
int ls_gettext(lua_State *L)
{
	LSOBJECT *pIn=(LSOBJECT*)lua_touserdata(L, 1);
	LSTypeDefinition *pType=pIn->Type;
	if (!pType)
	{
		lua_pushnil(L);
		return 1;
	}

	char Dest[4096];
	Dest[0]=0;
	if (!pType->ToText(pIn->ObjectData,Dest))
	{
		lua_pushnil(L);
		return 1;
	}
	lua_pushstring(L,Dest);
	return 1;
}

static const luaL_reg lslib[] = {
  {"exec",   ls_exec},
  {"eval",   ls_eval},
  {"getobject", ls_getobject},
  {"getmember",	ls_getmember},
  {"getmethod",	ls_getmethod},
  {"gettext", ls_gettext},
  {NULL, NULL}
};


/*
** Open LS library
*/
LUALIB_API int luaopen_ls (lua_State *L) {
  luaL_openlib(L, "ls", lslib, 0);

  return 1;
}


