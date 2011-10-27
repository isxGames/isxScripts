#pragma once
#include <lsmodule.h>


class LSMMySQL :
	public LSModuleInterface
{
public:
	LSMMySQL(void);
	~LSMMySQL(void);

	virtual bool Initialize(LSInterface *p_LSInterface);
	virtual void Shutdown();
	virtual void Pulse();
	virtual void AddPreprocessorDefinitions();

	void RegisterCommands();
	void RegisterAliases();
	void RegisterDataTypes();
	void RegisterTopLevelObjects();

	void UnRegisterCommands();
	void UnRegisterAliases();
	void UnRegisterDataTypes();
	void UnRegisterTopLevelObjects();

};

extern LSInterface *pLSInterface;
extern LSMMySQL *pModule;
#define printf pLSInterface->Printf

extern LSType *pStringType;
extern LSType *pIntType;
extern LSType *pUintType;
extern LSType *pBoolType;
extern LSType *pFloatType;
extern LSType *pTimeType;
extern LSType *pByteType;
extern LSType *pIntPtrType;
extern LSType *pBoolPtrType;
extern LSType *pFloatPtrType;
extern LSType *pBytePtrType;

#include <mysql.h>
#include "DataTypes.h"