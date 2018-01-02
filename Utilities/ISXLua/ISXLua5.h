#pragma once
#include <isxdk.h>
#include <windows.h>
#include "ISXLuaEngine.h"

class ISXLua5 :
	public ISXInterface
{
public:
	ISXLua5(void);
	~ISXLua5(void);

	virtual bool Initialize(ISInterface *p_ISInterface);
	virtual void Shutdown();

	void ConnectServices();
	void RegisterCommands();
	void RegisterAliases();
	void RegisterDataTypes();
	void RegisterTopLevelObjects();
	void RegisterServices();
	void RegisterTriggers();

	void DisconnectServices();
	void UnRegisterCommands();
	void UnRegisterAliases();
	void UnRegisterDataTypes();
	void UnRegisterTopLevelObjects();
	void UnRegisterServices();

};

extern ISInterface *pISInterface;
extern HISXSERVICE hPulseService;
extern HISXSERVICE hMemoryService;
extern HISXSERVICE hHTTPService;
extern HISXSERVICE hTriggerService;
extern HISXSERVICE hScriptEngineService;

extern ISXLua5 *pExtension;
#define printf pISInterface->Printf

#define EzDetour(Address, Detour, Trampoline) IS_Detour(pExtension,pISInterface,hMemoryService,(unsigned long)Address,Detour,Trampoline)
#define EzUnDetour(Address) IS_UnDetour(pExtension,pISInterface,hMemoryService,(unsigned long)Address)
#define EzDetourAPI(_Detour_,_DLLName_,_FunctionName_,_FunctionOrdinal_) IS_DetourAPI(pExtension,pISInterface,hMemoryService,_Detour_,_DLLName_,_FunctionName_,_FunctionOrdinal_)
#define EzUnDetourAPI(Address) IS_UnDetourAPI(pExtension,pISInterface,hMemoryService,(unsigned long)Address)

#define EzModify(Address,NewData,Length,Reverse) Memory_Modify(pExtension,pISInterface,hMemoryService,(unsigned long)Address,NewData,Length,Reverse)
#define EzUnModify(Address) Memory_UnModify(pExtension,pISInterface,hMemoryService,(unsigned long)Address)

#define EzHttpRequest(_URL_,_pData_) IS_HttpRequest(pExtension,pISInterface,hHTTPService,_URL_,_pData_)

#define EzAddTrigger(Text,Callback,pUserData) IS_AddTrigger(pExtension,pISInterface,hTriggerService,Text,Callback,pUserData)
#define EzRemoveTrigger(ID) IS_RemoveTrigger(pExtension,pISInterface,hTriggerService,ID)
#define EzCheckTriggers(Text) IS_CheckTriggers(pExtension,pISInterface,hTriggerService,Text)

extern LSType *pStringType;
extern LSType *pIntType;
extern LSType *pBoolType;
extern LSType *pFloatType;
extern LSType *pTimeType;
extern LSType *pByteType;
extern LSType *pIntPtrType;
extern LSType *pBoolPtrType;
extern LSType *pFloatPtrType;
extern LSType *pBytePtrType;

#include "Commands.h"
#include "DataTypes.h"
#include "TopLevelObjects.h"
#include "Services.h"

extern ISXLuaEngine g_LuaEngine;
