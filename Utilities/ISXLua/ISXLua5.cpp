//
// ISXLua5
//

#include "ISXLua5.h"
#pragma comment(lib,"isxdk.lib")
// The mandatory pre-setup function.  Our name is "ISXLua5", and the class is ISXLua5.
// This sets up a "ModulePath" variable which contains the path to this module in case we want it,
// and a "PluginLog" variable, which contains the path and filename of what we should use for our
// debug logging if we need it.  It also sets up a variable "pExtension" which is the pointer to
// our instanced class.
ISXPreSetup("ISXLua5",ISXLua5);

// Basic LavishScript datatypes, these get retrieved on startup by our initialize function, so we can
// use them in our Top-Level Objects or custom datatypes
LSType *pStringType=0;
LSType *pIntType=0;
LSType *pBoolType=0;
LSType *pFloatType=0;
LSType *pTimeType=0;
LSType *pByteType=0;
LSType *pIntPtrType=0;
LSType *pBoolPtrType=0;
LSType *pFloatPtrType=0;
LSType *pBytePtrType=0;

ISInterface *pISInterface=0;

HISXSERVICE hHTTPService;
HISXSERVICE hScriptEngineService;
ISXLuaEngine g_LuaEngine;

unsigned long TypeAddedEvent=0;

// Forward declarations of callbacks
void __cdecl HTTPService(bool Broadcast, unsigned long MSG, void *lpData);
void __cdecl ScriptEngineService(bool Broadcast, unsigned long MSG, void *lpData);


// The constructor of our class.  General initialization cannot be done yet, because we're not given
// the pointer to the Inner Space interface until it is ready for us to initialize.  Just set the
// pointer we have to the interface to 0.  Initialize data members, too.
ISXLua5::ISXLua5(void)
{
}

// Free any remaining resources in the destructor.  This is called when the DLL is unloaded, but
// Inner Space calls the "Shutdown" function first.  Most if not all of the shutdown process should
// be done in Shutdown.
ISXLua5::~ISXLua5(void)
{
}

void __cdecl LSTypeAdded(int argc, char *argv[], PLSOBJECT pThisObject)
{
	if (argc==1 && argv && argv[0])
	{
		//ISXLuaScript *pScript=g_LuaEngine.Scripts
		for(map<utf8stringnocase,ISXLuaScript*>::iterator i=g_LuaEngine.Scripts.begin() ; i!=g_LuaEngine.Scripts.end() ; i++)
		if (ISXLuaScript *pScript=i->second)
		{
			pScript->AddDynamicLibrary(argv[0]);
		}
	}
}

// Initialize is called by Inner Space when the extension should initialize.
bool ISXLua5::Initialize(ISInterface *p_ISInterface)
{
	pISInterface=p_ISInterface;

	// retrieve basic ISData types
	pStringType=pISInterface->FindLSType("string");
	pIntType=pISInterface->FindLSType("int");
	pBoolType=pISInterface->FindLSType("bool");
	pFloatType=pISInterface->FindLSType("float");
	pTimeType=pISInterface->FindLSType("time");
	pByteType=pISInterface->FindLSType("byte");
	pIntPtrType=pISInterface->FindLSType("intptr");
	pBoolPtrType=pISInterface->FindLSType("boolptr");
	pFloatPtrType=pISInterface->FindLSType("floatptr");
	pBytePtrType=pISInterface->FindLSType("byteptr");

	ConnectServices();

	RegisterCommands();
	RegisterAliases();
	RegisterDataTypes();
	RegisterTopLevelObjects();
    RegisterServices();
    RegisterTriggers();

	// register engine
	IS_ScriptEngineAdd(this,pISInterface,hScriptEngineService,&g_LuaEngine);
	// register file extensions
	IS_ScriptEngineAddFileExt(this,pISInterface,hScriptEngineService,&g_LuaEngine,"lua");

	TypeAddedEvent=pISInterface->RegisterEvent("Datatype Added");
	pISInterface->AttachEventTarget(TypeAddedEvent,LSTypeAdded);

	printf("ISXLua5 Loaded");
	return true;
}

// shutdown sequence
void ISXLua5::Shutdown()
{
	// unregister engine
	IS_ScriptEngineRemove(this,pISInterface,hScriptEngineService,&g_LuaEngine);

	pISInterface->DetachEventTarget(TypeAddedEvent,LSTypeAdded);


	DisconnectServices();

	UnRegisterServices();
	UnRegisterTopLevelObjects();
	UnRegisterDataTypes();
	UnRegisterAliases();
	UnRegisterCommands();
}



void ISXLua5::ConnectServices()
{
	// connect to any services.  Here we connect to "Pulse" which receives a
	// message every frame (after the frame is displayed) and "Memory" which
	// wraps "detours" and memory modifications
	hHTTPService=pISInterface->ConnectService(this,"HTTP",HTTPService);
	hScriptEngineService=pISInterface->ConnectService(this,"Script Engines",ScriptEngineService);
}
void ISXLua5::RegisterCommands()
{
	// add any commands
//	pISInterface->AddCommand("ISXLua5",CMD_ISXLua5,true,false);
#define COMMAND(name,cmd,parse,hide) pISInterface->AddCommand(name,cmd,parse,hide);
#include "Commands.h"
#undef COMMAND
}

void ISXLua5::RegisterAliases()
{
	// add any aliases
}

void ISXLua5::RegisterDataTypes()
{
	// add any datatypes
	// pMyType = new MyType;
	// pISInterface->AddLSType(*pMyType);
#define DATATYPE(_class_,_variable_) _variable_ = new _class_; pISInterface->AddLSType(*_variable_);
#include "DataTypeList.h"
#undef DATATYPE
}

void ISXLua5::RegisterTopLevelObjects()
{
	// add any Top-Level Objects
	//pISInterface->AddTopLevelObject("ISXLua5",TLO_ISXLua5);
#define TOPLEVELOBJECT(name,funcname) pISInterface->AddTopLevelObject(name,funcname);
#include "TopLevelObjects.h"
#undef TOPLEVELOBJECT
}

void ISXLua5::RegisterServices()
{
	// register any services.  Here we demonstrate a service that does not use a
	// callback
	// set up a 1-way service (broadcast only)
//	hISXLua5Service=pISInterface->RegisterService(this,"ISXLua5 Service",0);
	// broadcast a message, which is worthless at this point because nobody will receive it
	// (nobody has had a chance to connect)
//	pISInterface->ServiceBroadcast(this,hISXLua5Service,ISXSERVICE_MSG+1,0);

#define SERVICE(_name_,_callback_,_variable_) _variable_=pISInterface->RegisterService(this,_name_,_callback_);
#include "Services.h"
#undef SERVICE
}

void ISXLua5::RegisterTriggers()
{
	// add any Triggers
}

void ISXLua5::DisconnectServices()
{
	// gracefully disconnect from services
	if (hHTTPService)
	{
		pISInterface->DisconnectService(this,hHTTPService);
	}
	if (hScriptEngineService)
		pISInterface->DisconnectService(this,hScriptEngineService);

}

void ISXLua5::UnRegisterCommands()
{
	// remove commands
//	pISInterface->RemoveCommand("ISXLua5");
#define COMMAND(name,cmd,parse,hide) pISInterface->RemoveCommand(name);
#include "Commands.h"
#undef COMMAND
}
void ISXLua5::UnRegisterAliases()
{
	// remove aliases
}
void ISXLua5::UnRegisterDataTypes()
{
	// remove data types
#define DATATYPE(_class_,_variable_) pISInterface->RemoveLSType(*_variable_); delete _variable_;
#include "DataTypeList.h"
#undef DATATYPE

}
void ISXLua5::UnRegisterTopLevelObjects()
{
	// remove Top-Level Objects
//	pISInterface->RemoveTopLevelObject("ISXLua5");
#define TOPLEVELOBJECT(name,funcname) pISInterface->RemoveTopLevelObject(name);
#include "TopLevelObjects.h"
#undef TOPLEVELOBJECT
}
void ISXLua5::UnRegisterServices()
{
	// shutdown our own services
//	if (hISXLua5Service)
//		pISInterface->ShutdownService(this,hISXLua5Service);

#define SERVICE(_name_,_callback_,_variable_) _variable_=pISInterface->ShutdownService(this,_variable_);
#include "Services.h"
#undef SERVICE
}

void __cdecl HTTPService(bool Broadcast, unsigned long MSG, void *lpData)
{
	switch(MSG)
	{
#define pReq ((HttpFile*)lpData)
	case HTTPSERVICE_FAILURE:
		// HTTP request failed to retrieve document
		printf("ISXLua5 URL %s failed",pReq->URL);
		break;
	case HTTPSERVICE_SUCCESS:
		// HTTP request successfully retrieved document
		printf("ISXLua5 URL %s -- %d bytes",pReq->URL,pReq->Size);
		// Retrieved data buffer is pReq->pBuffer and is null-terminated
		break;
#undef pReq
	}
}

void __cdecl ScriptEngineService(bool Broadcast, unsigned long MSG, void *lpData)
{
	// The messages in this service are more for extensions that want to USE your engine, not
	// the implementation of the engine
}
