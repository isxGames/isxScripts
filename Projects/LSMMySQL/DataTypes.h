#pragma once
#include "DataTypeList.h"

// custom data type declarations 

class LSMySQLType : public LSTypeDefinition
{
public:
	// All data members (retrieving data) should be listed in this enumeration
	enum LSMySQLTypeMembers
	{
		Connected,

		AffectedRows,
		InsertID,
		LastError,
	};
	// All data methods (performing actions on or with the object) should be listed in this enumeration
	enum LSMySQLTypeMethods
	{
		Connect,
		Ping,

		Query,
	};

	LSMySQLType() : LSType("mysql")
	{
		// Use the TypeMember macro to activate each member, or use AddMember
		TypeMember(Connected);

		// Use the TypeMethod macro to activate each member, or use AddMethod
		TypeMethod(Connect);
		TypeMethod(Ping);

		TypeMethod(Query);
	}

	virtual bool GetMember(LSOBJECTDATA ObjectData, PLSTYPEMEMBER pMember, int argc, char *argv[], LSOBJECT &Object);
	virtual bool GetMethod(LSOBJECTDATA &ObjectData, PLSTYPEMETHOD pMethod, int argc, char *argv[]);
	virtual bool ToText(LSOBJECTDATA ObjectData, char *buf, unsigned int buflen);

    virtual bool InitVariable(LSOBJECTDATA &ObjectData, const char *SubType);
	virtual void FreeVariable(LSOBJECTDATA &ObjectData);

	virtual bool FromText(LSOBJECTDATA &ObjectData, int argc, char *argv[]);
};

class CMySQLResult
{
public:
	CMySQLResult()
	{
		Res=0;
		nRows=0;
		Row=0;
		nFields=0;
	}
	~CMySQLResult()
	{
		Clear();
	}

	void Clear();
	void InitializeResult(MYSQL_RES *p_Res);

	MYSQL_RES* Res;
	unsigned int nRows;

	MYSQL_ROW Row;
	unsigned int nFields;

	map<utf8string,unsigned int> FieldNames;
	char *GetFieldByName(const char *Name)
	{
		map<utf8string,unsigned int>::iterator i=FieldNames.find(Name);
		if (i==FieldNames.end())
			return 0;
		return Row[i->second];
	}
	char *GetFieldByText(const char *Text);

};

class LSMySQLResultType : public LSTypeDefinition
{
public:
	// All data members (retrieving data) should be listed in this enumeration
	enum LSMySQLResultTypeMembers
	{
		Valid,
		ValidRow,

		Fields,
		Rows,

		GetString,
		GetInt,
		GetFloat,
	};
	// All data methods (performing actions on or with the object) should be listed in this enumeration
	enum LSMySQLTypeResultMethods
	{
		FetchRow,
		Clear,
	};

	LSMySQLResultType() : LSType("mysqlresult")
	{
		TypeMember(Valid);
		TypeMember(ValidRow);

		TypeMember(GetString);
		TypeMember(GetInt);
		TypeMember(GetFloat);

		TypeMember(Fields);
		TypeMember(Rows);

		TypeMethod(FetchRow);
	}

	virtual bool GetMember(LSOBJECTDATA ObjectData, PLSTYPEMEMBER pMember, int argc, char *argv[], LSOBJECT &Object);
	virtual bool GetMethod(LSOBJECTDATA &ObjectData, PLSTYPEMETHOD pMethod, int argc, char *argv[]);
	virtual bool ToText(LSOBJECTDATA ObjectData, char *buf, unsigned int buflen);

    virtual bool InitVariable(LSOBJECTDATA &ObjectData, const char *SubType);
	virtual void FreeVariable(LSOBJECTDATA &ObjectData);

	virtual bool FromText(LSOBJECTDATA &ObjectData, int argc, char *argv[]);
};