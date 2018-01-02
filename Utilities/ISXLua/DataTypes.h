#pragma once
#include "DataTypeList.h"

// custom data type declarations 
/*
class Lua5Type : public LSTypeDefinition
{
public:
	// All data members (retrieving data) should be listed in this enumeration
	enum Lua5TypeMembers
	{
		RetrieveData,
	};
	// All data methods (performing actions on or with the object) should be listed in this enumeration
	enum Lua5TypeMethods
	{
		PerformAction,
	};

	Lua5Type() : LSType("lua5")
	{
		// Use the TypeMember macro to activate each member, or use AddMember
		TypeMember(RetrieveData);

		// Use the TypeMethod macro to activate each member, or use AddMethod
		TypeMethod(PerformAction);
	}

	virtual bool GetMember(LSOBJECTDATA ObjectData, char * Member, int argc, char * argv[], LSOBJECT &Object);
	virtual bool GetMethod(LSOBJECTDATA &ObjectData, char * Method, int argc, char * argv[]);
	virtual bool ToString(LSOBJECTDATA ObjectData, char * Destination);
};
/**/