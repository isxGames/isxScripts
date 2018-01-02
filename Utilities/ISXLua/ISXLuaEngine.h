#pragma once

typedef int (*dyn_func)(struct lua_State *L, const char *Name);

class CDynamicLibraryFunction
{
public:
	CDynamicLibraryFunction(const char *Name, dyn_func func);
	~CDynamicLibraryFunction();

	char *Name;
	unsigned char Function[32];
	
};

class LuaIndices
{
public:

	LuaIndices(struct lua_State *L, int nSkip, char *First=0);
	~LuaIndices();

	int argc;
	char **argv;
};


class ISXLuaScript
{
public:
	ISXLuaScript(const char *p_Filename, const char *p_ShortName);
	~ISXLuaScript();

	void AddDynamicCMDLibrary();
	void AddDynamicTLOLibrary();

	void AddDynamicLibrary(const char *TypeName);
	unsigned long FindDynamicLibrary(const char *TypeName);
	static char *MakeDynamicLibraryName(const char *Name, char *buf, unsigned long buflen);

	CDynamicLibraryFunction *AddFunction(const char *Name, dyn_func func);

	bool Begin(int argc, char *argv[]);

	void Pulse();

	char *Buffer;

	char *ShortName;
	char *FullFilename;

	struct lua_State *pState;
	bool bDone;

	map<utf8string,unsigned long> DynamicLibraries;
	CIndex<CDynamicLibraryFunction *> Functions;
};

class ISXLuaEngine :
	public ISXScriptEngine
{
public:
	ISXLuaEngine(void);
	~ISXLuaEngine(void);

	virtual const char *GetName() 
	{
		return "Lua";
	}
	virtual const char *GetVersion()	// used by extensions. implement however you want
	{
		return "5.0.2";
	}
	virtual bool GetCaps(ISXSCRIPTENGINECAPS &Dest); // used by extensions to retrieve engine capabilities
	
	virtual void Pulse(); // for persistent scripts, use this to process microthreads, etc.

	virtual bool ExecuteScript(const char *FullFilename, int argc, char *argv[]); // used by RunScript command
	virtual bool EndScript(const char *Name); // used by EndScript

	map<utf8stringnocase,ISXLuaScript*> Scripts;
};
