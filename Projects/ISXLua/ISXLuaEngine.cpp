#include "ISXLua5.h"
#include "ISXLuaEngine.h"


#include <signal.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define lua_c

extern "C" {
#include "lua-5.0.2/include/lua.h"
#include "lua-5.0.2/include/lauxlib.h"
#include "lua-5.0.2/include/lualib.h"
};


ISXLuaEngine::ISXLuaEngine(void)
{
}

ISXLuaEngine::~ISXLuaEngine(void)
{
	for(map<utf8stringnocase,ISXLuaScript*>::iterator i=Scripts.begin() ; i!=Scripts.end() ; i++)
	if (ISXLuaScript *pScript=i->second)
	{
		delete pScript;
	}
}

bool ISXLuaEngine::GetCaps(ISXSCRIPTENGINECAPS &Dest)
{
	if (Dest.Sizeof==sizeof(ISXSCRIPTENGINECAPS))
	{
		Dest.bMultipleScripts=1;
		Dest.bPersistent=1;
		Dest.bPreprocessor=0;
		return true;
	}
	// unknown size, ignore for now. ideally, check size before each member, returning true
	// when the correct size is met
	return false;
}

void ISXLuaEngine::Pulse()
{
	for(map<utf8stringnocase,ISXLuaScript*>::iterator i=Scripts.begin() ; i!=Scripts.end() ; i++)
	if (ISXLuaScript *pScript=i->second)
	{
//		printf("Pulsing Lua script %s",i->first.c_str());
		if (!pScript->bDone)
			pScript->Pulse();
		if (pScript->bDone)
		{
//			printf("Lua script %s ends",pScript->ShortName);
			EndScript(pScript->ShortName);
		}
	}
}

bool ISXLuaEngine::ExecuteScript(const char *FullFilename, int argc, char *argv[])
{
	// get short name
	char ShortName[128];
	ShortName[0]=0;
	_splitpath(FullFilename,0,0,ShortName,0);
	if (!ShortName[0])
	{
		printf("ISXLua5: Failed to execute %s",FullFilename);
		return false;
	}
//	printf("ISXLua5: ExecuteScript(%s)",ShortName);
	ISXLuaScript *pScript = new ISXLuaScript(FullFilename,ShortName);
	if (!pScript->Begin(argc,argv))
	{
		delete pScript;
		printf("ISXLua5: Failed to execute %s",FullFilename);
		return false;
	}

	Scripts[ShortName]=pScript;
	IS_ScriptEngineScriptBegins(pExtension,pISInterface,hScriptEngineService,this,ShortName);
	return true;
}

bool ISXLuaEngine::EndScript(const char *Name)
{
//	printf("ISXLua5: EndScript(%s)",Name);
	ISXLuaScript *pScript = Scripts[Name];
	if (!pScript)
	{
		printf("ISXLua5: Failed to end %s",Name);
		return false;
	}
	
	Scripts[Name]=0;
//	printf("Removed script %s",Name);
	IS_ScriptEngineScriptEnds(pExtension,pISInterface,hScriptEngineService,this,Name);
	delete pScript;
	return true;
}



ISXLuaScript::ISXLuaScript(const char *p_Filename, const char *p_ShortName)
{
	ShortName=_tcsdup(p_ShortName);
	FullFilename=_tcsdup(p_Filename);
	pState=0;
	Buffer=0;
	bDone=false;
}

ISXLuaScript::~ISXLuaScript()
{
	if (Buffer)
		free(Buffer);
	free(ShortName);
	free(FullFilename);
	if (pState)
		lua_close(pState);
	Functions.Cleanup();
}



#ifndef lua_userinit
#define lua_userinit(L)		openstdlibs(L)
#endif


#ifndef LUA_EXTRALIBS
#define LUA_EXTRALIBS	/* empty */
#endif


extern int luaopen_is (lua_State *L);
extern int luaopen_ls (lua_State *L);


static const luaL_reg lualibs[] = {
  {"base", luaopen_base},
  {"table", luaopen_table},
  {"io", luaopen_io},
  {"string", luaopen_string},
  {"math", luaopen_math},
  {"debug", luaopen_debug},
  {"loadlib", luaopen_loadlib},
  /* add your libraries here */
  {"is", luaopen_is},
  {"ls", luaopen_ls},
  LUA_EXTRALIBS
  {NULL, NULL}
};

static void openstdlibs (lua_State *l) {
  const luaL_reg *lib = lualibs;
  for (; lib->func; lib++) {
    lib->func(l);  /* open library */
    lua_settop(l, 0);  /* discard any results */
  }
}




void ISXLuaScript::Pulse()
{
	if (pState)
	{
		if (lua_resume(pState,0)!=0)
		{
			const char *msg=lua_tostring(pState, -1);
			if (msg && stricmp(msg,"cannot resume dead coroutine"))
			{
				printf("ISXLua5: %s ends: %s",FullFilename,msg);
			}
			bDone=true;
		}
	}
}

static void getargs (lua_State *L, int argc, char *argv[]) {
  int i;
  lua_newtable(L);
  for (i=0; i<argc ; i++) {
    lua_pushnumber(L, i);
    lua_pushstring(L, argv[i]);
    lua_rawset(L, -3);
  }
  /* arg.n = maximum index in table `arg' */
  lua_pushliteral(L, "n");
  lua_pushnumber(L, i-1);
  lua_rawset(L, -3);
}

void __cdecl EnumAddDynamicType(const char *Name, void *pData)
{
	ISXLuaScript *pScript=(ISXLuaScript *)pData;
	pScript->AddDynamicLibrary(Name);
    lua_settop(pScript->pState, 0);  /* discard any results */
}

bool ISXLuaScript::Begin(int argc, char *argv[])
{
	FILE *file=fopen(FullFilename,"rb");
	if (!file)
		return false;
	fseek(file,0,SEEK_END);
	unsigned long Size=ftell(file);
	fseek(file,0,SEEK_SET);
	Buffer=(char*)malloc(Size+1);
	if (fread(Buffer,1,Size,file)!=Size)
	{
		free(Buffer);
		fclose(file);
		return false;
	}
	Buffer[Size]=0;
	fclose(file);
	/**/

	  int result;
	  pState = lua_open();  /* create state */
  lua_userinit(pState);  /* open libraries (openstdlibs) */ 
	pISInterface->EnumLSTypeDefinitions(EnumAddDynamicType,this);
	AddDynamicTLOLibrary();
	AddDynamicCMDLibrary();

	/* Compile the script */
	if((result = luaL_loadbuffer(pState, Buffer, Size, FullFilename)) != 0)
	{
		printf(lua_tostring(pState, -1));
		return false;
	}

	  getargs(pState,argc,argv);
      lua_setglobal(pState, "arg");
//		printf("Begin() returns true");
	  return true;
}

void __cdecl LSEnumCount(const char *Name, void *pData)
{
	unsigned long *pCount=(unsigned long *)pData;
	*pCount=(*pCount)+1;
}

int dyn_getmember(lua_State *L, const char *Name)
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

	pType->GetMemberEx(pIn->ObjectData,(char*)Name,Indices.argc,Indices.argv,*pRet);

	if (pRet->Type)
	{
		char MetaTable[128];
		MetaTable[0]=0;
		ISXLuaScript::MakeDynamicLibraryName(pRet->Type->GetName(),MetaTable,sizeof(MetaTable));
		luaL_getmetatable(L, MetaTable);
		lua_setmetatable(L, -2);
	}

	return 1;
}

int dyn_getmethod(lua_State *L, const char *Name)
{
	LSOBJECT *pIn=(LSOBJECT*)lua_touserdata(L, 1);
	LSTypeDefinition *pType=pIn->Type;
	if (!pType)
	{
		lua_pushnil(L);
		return 1;
	}
	LuaIndices Indices(L,1);

	int Ret=pType->GetMethodEx(pIn->ObjectData,(char*)Name,Indices.argc,Indices.argv);
	lua_pushnumber(L,Ret==1);
	return 1;
}

int dyn_tlo(lua_State *L, const char *Name)
{
	LSOBJECT *pRet=(LSOBJECT *)lua_newuserdata(L,sizeof(LSOBJECT));
	pRet->Ptr=0;
	pRet->Type=0;
	
	fLSTopLevelObject func=pISInterface->IsTopLevelObject(Name);
	if (!func)
	{
		return 1;
	}
	LuaIndices Indices(L,0);

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

int dyn_cmd(lua_State *L, const char *Name)
{

	fLSCommand func=pISInterface->IsCommand(Name);
	if (!func)
	{
		lua_pushnil(L);
		return 1;
	}
	LuaIndices Indices(L,0,(char*)Name);

	lua_pushnumber(L,func(Indices.argc,Indices.argv));
	return 1;
}


struct AddStruct
{
	luaL_reg *pCur;
	ISXLuaScript *pScript;
};

void __cdecl DynAddMember(const char *Name, void *pData)
{
	AddStruct *pS=(AddStruct*)pData;
	luaL_reg *pCur=pS->pCur;

	pCur->name=_tcsdup(Name);
	CDynamicLibraryFunction *pFunc=pS->pScript->AddFunction(Name,dyn_getmember);
	lua_CFunction f=(lua_CFunction)&pFunc->Function;
	pCur->func=f;

	pCur++;
	pS->pCur=pCur;
}

void __cdecl DynAddMethod(const char *Name, void *pData)
{
	AddStruct *pS=(AddStruct*)pData;
	luaL_reg *pCur=pS->pCur;

	unsigned long Length=_tcsnbcnt(Name,0x7fffffff)+1;
	char *Text=(char *)malloc(Length+1);
	Text[0]='_';
	memcpy(&Text[1],Name,Length);
	pCur->name=Text;
	CDynamicLibraryFunction *pFunc=pS->pScript->AddFunction(Name,dyn_getmethod);
	lua_CFunction f=(lua_CFunction)&pFunc->Function;
	pCur->func=f;

	pCur++;
	pS->pCur=pCur;
}

void __cdecl DynAddCommand(const char *Name, void *pData)
{
	AddStruct *pS=(AddStruct*)pData;
	luaL_reg *pCur=pS->pCur;

//	printf("add command '%s'",Name);
	pCur->name=_tcsdup(Name);
	CDynamicLibraryFunction *pFunc=pS->pScript->AddFunction(Name,dyn_cmd);
	lua_CFunction f=(lua_CFunction)&pFunc->Function;
	pCur->func=f;

	pCur++;
	pS->pCur=pCur;
}

void __cdecl DynAddTopLevelObject(const char *Name, void *pData)
{
	AddStruct *pS=(AddStruct*)pData;
	luaL_reg *pCur=pS->pCur;

	//printf("add TLO '%s'",Name);
	pCur->name=_tcsdup(Name);
	CDynamicLibraryFunction *pFunc=pS->pScript->AddFunction(Name,dyn_tlo);
	lua_CFunction f=(lua_CFunction)&pFunc->Function;
	pCur->func=f;

	pCur++;
	pS->pCur=pCur;
}

extern int ls_gettext(lua_State *L);

void ISXLuaScript::AddDynamicLibrary(const char *TypeName)
{
	char Name[128];
	Name[0]=0;
	if (!MakeDynamicLibraryName(TypeName,Name,sizeof(Name)))
		return;
	if (DynamicLibraries[Name])
		return;
//	printf("Adding library for type '%s'",TypeName);
	DynamicLibraries[Name]=1;

	luaL_reg *pLib=0;
	LSTypeDefinition *pType=pISInterface->FindLSTypeDefinition(TypeName);
	unsigned long Size=2;

	// handle inheritance
	LSTypeDefinition *pInherit=pType;
	while(pInherit)
	{
		pInherit->EnumMembers(LSEnumCount,&Size);
		pInherit->EnumMethods(LSEnumCount,&Size);
		pInherit=pInherit->GetInheritance();
	}
	

//	printf("Allocating %d members and methods",Size);

	unsigned long Allocated=sizeof(luaL_reg)*Size;
	pLib=(luaL_reg*)malloc(Allocated);
	luaL_reg *pCur=pLib;

	pCur->name="__tostring";
	pCur->func=ls_gettext;
	pCur++;

	AddStruct data;
	data.pCur=pCur;
	data.pScript=this;

	pInherit=pType;
	while(pInherit)
	{
		pInherit->EnumMembers(DynAddMember,&data);
		pInherit->EnumMethods(DynAddMethod,&data);
		pInherit=pInherit->GetInheritance();
	}

	pCur=data.pCur;
	pCur->name=0;
	pCur->func=0;

	
      luaL_newmetatable(pState, Name);
    
      lua_pushstring(pState, "__index");
      lua_pushvalue(pState, -2);  // pushes the metatable 
      lua_settable(pState, -3);  // metatable.__index = metatable
    
      luaL_openlib(pState, NULL, pLib, 0);
	  /**/
	pCur=pLib;
	pCur++;

	for(pCur ; pCur->name ; pCur++)
	{
		free((void*)pCur->name);
		pCur->name=0;
	}
	free(pLib);
	pLib=0;
}

void ISXLuaScript::AddDynamicCMDLibrary()
{
	if (DynamicLibraries["cmd"])
		return;
//	printf("Adding library for type '%s'",TypeName);
	DynamicLibraries["cmd"]=1;

	luaL_reg *pLib=0;
	unsigned long Size=1;

	pISInterface->EnumCommands(LSEnumCount,&Size);

	unsigned long Allocated=sizeof(luaL_reg)*Size;
	pLib=(luaL_reg*)malloc(Allocated);
	luaL_reg *pCur=pLib;

	AddStruct data;
	data.pCur=pCur;
	data.pScript=this;

	
	pISInterface->EnumCommands(DynAddCommand,&data);

	pCur=data.pCur;
	pCur->name=0;
	pCur->func=0;

  luaL_openlib(pState, "cmd", pLib, 0);
    lua_settop(pState, 0);  /* discard any results */
	
	pCur=pLib;

	for(pCur ; pCur->name ; pCur++)
	{
		free((void*)pCur->name);
		pCur->name=0;
	}
	free(pLib);
	pLib=0;
}

void ISXLuaScript::AddDynamicTLOLibrary()
{
	if (DynamicLibraries["tlo"])
		return;
//	printf("Adding library for type '%s'",TypeName);
	DynamicLibraries["tlo"]=1;

	luaL_reg *pLib=0;
	unsigned long Size=1;

	pISInterface->EnumTopLevelObjects(LSEnumCount,&Size);

	unsigned long Allocated=sizeof(luaL_reg)*Size;
	pLib=(luaL_reg*)malloc(Allocated);
	luaL_reg *pCur=pLib;

	AddStruct data;
	data.pCur=pCur;
	data.pScript=this;

	
	pISInterface->EnumTopLevelObjects(DynAddTopLevelObject,&data);

	pCur=data.pCur;
	pCur->name=0;
	pCur->func=0;

  lua_pushliteral(pState, "_G");
  lua_pushvalue(pState, LUA_GLOBALSINDEX);
  luaL_openlib(pState, NULL, pLib, 0);
    lua_settop(pState, 0);  /* discard any results */
	
	pCur=pLib;

	for(pCur ; pCur->name ; pCur++)
	{
		free((void*)pCur->name);
		pCur->name=0;
	}
	free(pLib);
	pLib=0;
}


unsigned long ISXLuaScript::FindDynamicLibrary(const char *TypeName)
{
	char Name[128];
	Name[0]=0;
	if (!MakeDynamicLibraryName(TypeName,Name,sizeof(Name)))
		return 0;
	return DynamicLibraries[Name];	
}

char *ISXLuaScript::MakeDynamicLibraryName(const char *Name, char *buf, unsigned long buflen)
{
	unsigned long Length=_tcsnbcnt(Name,0x7fffffff);
	if (buflen<Length+13)
		return 0;
	//          01234567890123
	strcpy(buf,"LavishScript.");
	strcpy(&buf[13],Name);
	return buf;
}

CDynamicLibraryFunction *ISXLuaScript::AddFunction(const char *Name, dyn_func func)
{
	CDynamicLibraryFunction *pFunc=new CDynamicLibraryFunction(Name,func);
	Functions+=pFunc;
	return pFunc;
}

CDynamicLibraryFunction::CDynamicLibraryFunction(const char *p_Name, dyn_func func)
{
	Name=_tcsdup(p_Name);

	/*
.text:10001A20                         arg_0           = dword ptr  4
.text:10001A20
.text:10001A20 A1 B8 71 06 10                          mov     eax, googleflop
.text:10001A25 8B 4C 24 04                             mov     ecx, [esp+arg_0]
.text:10001A29 50                                      push    eax
.text:10001A2A 51                                      push    ecx
.text:10001A2B E8 E0 FF FF FF                          call    dyn_googleflop2
.text:10001A30 83 C4 08                                add     esp, 8
.text:10001A33 C3                                      retn
/**/

	unsigned char *pPos=&Function[0];

	// mov eax, Name
	*pPos=0xB8;
	pPos++;
	*(unsigned long*)pPos=(unsigned long)Name;
	pPos+=4;

	// mov ecx, esp+arg_0
	*(unsigned long*)pPos=0x04244c8b;
	pPos+=4;

	*pPos=0x50;
	pPos++;

	*pPos=0x51;
	pPos++;

	// mov eax, function
	*pPos=0xB8;
	pPos++;

	*(unsigned long*)pPos=(unsigned long)func;
	pPos+=4;

	// call eax
	*pPos=0xFF;
	pPos++;
	*pPos=0xD0;
	pPos++;

	// add esp, 8
	// retn
	*(unsigned long*)pPos=0xc308c483;
	pPos+=4;

}

CDynamicLibraryFunction::~CDynamicLibraryFunction()
{
	free(Name);

}



LuaIndices::LuaIndices(lua_State *L, int nSkip, char *First)
{
	int n = lua_gettop(L);  /* number of arguments */
	argc=n-nSkip;
	if (First)
		argc++;
	if (argc<=0)
	{
		argc=0;
		argv=0;
	}
	else
	{
		argv=(char**)malloc(argc*sizeof(char*));
		if (First)
		{
			argv[0]=_tcsdup(First);
			for (int i = 1 ; i < argc ; i++)
			{
				const char *s=lua_tostring(L,i+nSkip);
				if (s)
					argv[i]=_tcsdup(s);
				else
					argv[i]=_tcsdup("");
			}
		}
		else
		{
			for (int i = 0 ; i < argc ; i++)
			{
				const char *s=lua_tostring(L,i+nSkip+1);
				if (s)
					argv[i]=_tcsdup(s);
				else
					argv[i]=_tcsdup("");
			}
		}
	}
}

LuaIndices::~LuaIndices()
{
	if (argv)
	{
		for (int i = 0 ; i < argc ; i++)
		{
			free(argv[i]);
		}
		free(argv);
	}
}