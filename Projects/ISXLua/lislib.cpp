// Inner Space LUA library 
#include "ISXLua5.h"
#define lislib_c

extern "C"
{
#include "lua-5.0.2/include/lua.h"
#include "lua-5.0.2/include/lauxlib.h"
#include "lua-5.0.2/include/lualib.h"
};


// console echo

int is_echo (lua_State *L) {
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
    if (i>1) 
	{
		*pOut='\t';
		pOut++;
	}
	pOut+=sprintf(pOut,"%s",s);
    lua_pop(L, 1);  /* pop result */
  }

  if (Output[0])
		pISInterface->Print(Output);
  return 0;
}


static const luaL_reg islib[] = {
  {"echo",   is_echo},
  {NULL, NULL}
};

static const luaL_reg is_baselib[] = {
  {"echo",   is_echo},
  {NULL, NULL}
};

/*
** Open IS library
*/
LUALIB_API int luaopen_is (lua_State *L) {
  luaL_openlib(L, "is", islib, 0);

  lua_pushliteral(L, "_G");
  lua_pushvalue(L, LUA_GLOBALSINDEX);
  luaL_openlib(L, NULL, is_baselib, 0);  /* open lib into global table */

  return 1;
}

