//
// LSMMySQL
//
#include <windows.h>
#include "LSMMySQL.h"
#pragma comment(lib,"lsmodule.lib")
#include <mysql.h>
#pragma comment(lib,"libmysql.lib") // DLL
//#pragma comment(lib,"mysqlclient.lib") // Static 

// The mandatory pre-setup function.  Our name is "LSMMySQL", and the class is LSMMySQL.
// This sets up a "ModulePath" variable which contains the path to this module in case we want it,
// and a "PluginLog" variable, which contains the path and filename of what we should use for our
// debug logging if we need it.  It also sets up a variable "pModule" which is the pointer to
// our instanced class.
LSModulePreSetup("MySQL",LSMMySQL);

// Basic LavishScript datatypes, these get retrieved on startup by our initialize function, so we can
// use them in our Top-Level Objects or custom datatypes
LSType *pStringType=0;
LSType *pIntType=0;
LSType *pUintType=0;
LSType *pBoolType=0;
LSType *pFloatType=0;
LSType *pTimeType=0;
LSType *pByteType=0;
LSType *pIntPtrType=0;
LSType *pBoolPtrType=0;
LSType *pFloatPtrType=0;
LSType *pBytePtrType=0;

LSInterface *pLSInterface=0;

#include "Commands.h"
#include "TopLevelObjects.h"

// The constructor of our class.  General initialization cannot be done yet, because we're not given
// the pointer to the Inner Space interface until it is ready for us to initialize.  Just set the
// pointer we have to the interface to 0.  Initialize data members, too.
LSMMySQL::LSMMySQL(void)
{
}

// Free any remaining resources in the destructor.  This is called when the DLL is unloaded, but
// Inner Space calls the "Shutdown" function first.  Most if not all of the shutdown process should
// be done in Shutdown.
LSMMySQL::~LSMMySQL(void)
{
}

// Initialize is called by Inner Space when the extension should initialize.
bool LSMMySQL::Initialize(LSInterface *p_LSInterface)
{
	pLSInterface=p_LSInterface;

	// retrieve basic ISData types
	pStringType=pLSInterface->FindLSType("string");
	pIntType=pLSInterface->FindLSType("int");
	pUintType=pLSInterface->FindLSType("uint");
	pBoolType=pLSInterface->FindLSType("bool");
	pFloatType=pLSInterface->FindLSType("float");
	pTimeType=pLSInterface->FindLSType("time");
	pByteType=pLSInterface->FindLSType("byte");
	pIntPtrType=pLSInterface->FindLSType("intptr");
	pBoolPtrType=pLSInterface->FindLSType("boolptr");
	pFloatPtrType=pLSInterface->FindLSType("floatptr");
	pBytePtrType=pLSInterface->FindLSType("byteptr");

	RegisterCommands();
	RegisterAliases();
	RegisterDataTypes();
	RegisterTopLevelObjects();

	return true;
}

// shutdown sequence
void LSMMySQL::Shutdown()
{
	UnRegisterTopLevelObjects();
	UnRegisterDataTypes();
	UnRegisterAliases();
	UnRegisterCommands();
}



void LSMMySQL::RegisterCommands()
{
	// add any commands
//	pLSInterface->AddCommand("MySQL",CMD_MySQL,true,false);
#define COMMAND(name,cmd,parse,hide) pLSInterface->AddCommand(name,cmd,parse,hide);
#include "Commands.h"
#undef COMMAND
}

void LSMMySQL::RegisterAliases()
{
	// add any aliases
}

void LSMMySQL::RegisterDataTypes()
{
	// add any datatypes
	// pMyType = new MyType;
	// pLSInterface->AddLSType(*pMyType);
#define DATATYPE(_class_,_variable_,_inherits_) _variable_ = new _class_; pLSInterface->AddLSType(*_variable_); _variable_->SetInheritance(_inherits_);
#include "DataTypeList.h"
#undef DATATYPE
}

void LSMMySQL::RegisterTopLevelObjects()
{
	// add any Top-Level Objects
	//pLSInterface->AddTopLevelObject("MySQL",TLO_MySQL);
#define TOPLEVELOBJECT(name,funcname) pLSInterface->AddTopLevelObject(name,funcname);
#include "TopLevelObjects.h"
#undef TOPLEVELOBJECT
}

void LSMMySQL::UnRegisterCommands()
{
	// remove commands
//	pLSInterface->RemoveCommand("MySQL");
#define COMMAND(name,cmd,parse,hide) pLSInterface->RemoveCommand(name);
#include "Commands.h"
#undef COMMAND
}
void LSMMySQL::UnRegisterAliases()
{
	// remove aliases
}
void LSMMySQL::UnRegisterDataTypes()
{
	// remove data types
	//pLSInterface->RemoveLSType(*pMyType);
	//delete pMyType;
#define DATATYPE(_class_,_variable_,_inherits_) pLSInterface->RemoveLSType(*_variable_); delete _variable_;
#include "DataTypeList.h"
#undef DATATYPE
}
void LSMMySQL::UnRegisterTopLevelObjects()
{
	// remove Top-Level Objects
//	pLSInterface->RemoveTopLevelObject("MySQL");
#define TOPLEVELOBJECT(name,funcname) pLSInterface->RemoveTopLevelObject(name);
#include "TopLevelObjects.h"
#undef TOPLEVELOBJECT
}

void LSMMySQL::Pulse()
{
	// Anything to be processed once per "frame".  Frames are not at precise intervals, and
	// are product-dependent.  For example, Inner Space frames are dependent on the framerate
	// of the game.
}

void LSMMySQL::AddPreprocessorDefinitions()
{
	pLSInterface->AddPreprocessorDefinition("LSMMYSQL","1.00");
}




