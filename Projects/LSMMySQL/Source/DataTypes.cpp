#include "LSMMySQL.h"
#define DATATYPE(_class_,_variable_,_inherits_) class _class_ *_variable_=0
#include "DataTypeList.h"
#undef DATATYPE

#define pMySQL ((MYSQL*)ObjectData.Ptr)
bool LSMySQLType::GetMember(LSOBJECTDATA ObjectData, PLSTYPEMEMBER pMember, int argc, char *argv[], LSOBJECT &Object)
{
	if (!pMySQL)
		return false;
	switch(pMember->ID)
	{
	case Connected:
		Object.DWord=(mysql_ping(pMySQL)==0);
		Object.Type=pBoolType;
		return true;
	case AffectedRows:
		Object.DWord=(unsigned int)mysql_affected_rows(pMySQL);
		if (Object.Int==-1)
			return false;
		Object.Type=pUintType;
		return true;
	case InsertID:
		Object.DWord=(unsigned int)mysql_insert_id(pMySQL);
		Object.Type=pUintType;
		return true;
	case LastError:
		if (Object.ConstCharPtr=mysql_error(pMySQL))
		{
			Object.Type=pStringType;
			return true;
		}
		return false;
	}
	return false;
}
bool LSMySQLType::GetMethod(LSOBJECTDATA &ObjectData, PLSTYPEMETHOD pMethod, int argc, char *argv[])
{
	if (!pMySQL)
		return false;
	switch(pMethod->ID)
	{
	case Connect:
		if (argc>=4)
		{
			char *host=argv[0];
			char *user=argv[1];
			char *pass=argv[2];
			char *db=argv[3];
			unsigned int port=argc>=5?atoi(argv[4]):0;
			char *unix_socket=0;
			unsigned int flags=0;
			return mysql_real_connect(pMySQL,host,user,pass,db,port,unix_socket,flags)!=0;
		}
	case Ping:
		return mysql_ping(pMySQL)==0;
	case Query:
		if (argc)
		{
			CMySQLResult *pResult=0;
			if (argc>1)
			{
				// grab result object
				LSOBJECT Object;
				if (!pLSInterface->DataParse(argv[1],Object))
				{
					printf("Could not resolve '%s'",argv[1]);
					return false;
				}
				if (Object.Type==pMySQLResultType)
					pResult=(CMySQLResult *)Object.Ptr;
			}
			if (mysql_query(pMySQL,argv[0]))
			{
				printf("Query Failed: %s", argv[0]);
				return false;
			}
			else
			{
				MYSQL_RES *result;
				result = mysql_store_result(pMySQL);

				if (result)
				{
					if (pResult)
						pResult->InitializeResult(mysql_store_result(pMySQL));
					return true;
				}
				else  // mysql_store_result() returned nothing; should it have?
				{
					if (mysql_field_count(pMySQL) == 0) // Nope
					{
						return true;
					}
					else 
					{
						fprintf(stderr, "Error: %s\n", mysql_error(pMySQL));
						return false;
					}
				}
			}
		}
		return false;
	}
	return false;
}
bool LSMySQLType::ToText(LSOBJECTDATA ObjectData, char *buf, unsigned int buflen)
{
	return false;
}

bool LSMySQLType::InitVariable(LSOBJECTDATA &ObjectData, const char *SubType)
{
	if (SubType && SubType[0])
		return false;
	ObjectData.Ptr=new MYSQL;
	mysql_init(pMySQL);
	return true;
}
void LSMySQLType::FreeVariable(LSOBJECTDATA &ObjectData)
{
	mysql_close(pMySQL);
	delete pMySQL;
}

bool LSMySQLType::FromText(LSOBJECTDATA &ObjectData, int argc, char *argv[])
{
	// ignore
	return true;
}
#undef pMySQL


void CMySQLResult::Clear()
{
	Res=0;
	nRows=0;
	Row=0;
	nFields=0;
	FieldNames.clear();
}

static inline bool IsNumber(const char *String)
{
	if (*String==0)
		return false;
	while(*String)
	{
		if (!((*String>='0' && *String<='9') || *String=='.'))
			return false;
		++String;
	}
	return true;
}
void CMySQLResult::InitializeResult(MYSQL_RES *p_Res)
{
	if (Res)
	{
		Clear();
	}
	Res=p_Res;
	nRows=(unsigned int)mysql_num_rows(Res);
	nFields=mysql_num_fields(Res);

	// get field names
	MYSQL_FIELD *fields=mysql_fetch_fields(Res);
	for(unsigned int i = 0; i < nFields; i++)
	{
		FieldNames[fields[i].name]=i;
	}
}

char *CMySQLResult::GetFieldByText(const char *Text)
{
	if (!Row)
		return 0;
	char *Field=GetFieldByName(Text);
	if (Field)
		return Field;
	if (!IsNumber(Text))
		return 0;
	unsigned int nField=atoi(Text)-1; // 1-base to 0-base conversion
	if (nField>=nFields)
		return 0; // out of range
	return Row[nField];
}

bool LSMySQLResultType::GetMember(LSOBJECTDATA ObjectData, PLSTYPEMEMBER pMember, int argc, char *argv[], LSOBJECT &Object)
{
	if (!(CMySQLResult*)ObjectData.Ptr)
		return false;
	switch(pMember->ID)
	{
	case Valid:
		Object.Type=pBoolType;
		Object.Ptr=((CMySQLResult*)ObjectData.Ptr)->Res;
		return true;
	case ValidRow:
		Object.Type=pBoolType;
		Object.Ptr=((CMySQLResult*)ObjectData.Ptr)->Row;
		return true;
	case Fields:
		Object.Type=pUintType;
		Object.DWord=((CMySQLResult*)ObjectData.Ptr)->nFields;
		return true;
	case Rows:
		Object.Type=pUintType;
		Object.DWord=((CMySQLResult*)ObjectData.Ptr)->nRows;
		return true;
	case GetString:
		if (argc)
		{
			if (Object.CharPtr=((CMySQLResult*)ObjectData.Ptr)->GetFieldByText(argv[0]))
			{
				Object.Type=pStringType;
				return true;
			}
		}
		return false;
	case GetInt:
		if (argc)
		{
			if (char *Field=((CMySQLResult*)ObjectData.Ptr)->GetFieldByText(argv[0]))
			{
				Object.Int=atoi(Field);
				Object.Type=pIntType;
				return true;
			}
		}
		return false;
	case GetFloat:
		if (argc)
		{
			if (char *Field=((CMySQLResult*)ObjectData.Ptr)->GetFieldByText(argv[0]))
			{
				Object.Float=(float)atof(Field);
				Object.Type=pFloatType;
				return true;
			}
		}
		return false;
	}
	return false;
}
bool LSMySQLResultType::GetMethod(LSOBJECTDATA &ObjectData, PLSTYPEMETHOD pMethod, int argc, char *argv[])
{
	if (!(CMySQLResult*)ObjectData.Ptr)
		return false;
	switch(pMethod->ID)
	{
	case Clear:
		((CMySQLResult*)ObjectData.Ptr)->Clear();
		return true;
	case FetchRow:
		if (((CMySQLResult*)ObjectData.Ptr)->Res)
		{
			((CMySQLResult*)ObjectData.Ptr)->Row=mysql_fetch_row(((CMySQLResult*)ObjectData.Ptr)->Res);

			return ((CMySQLResult*)ObjectData.Ptr)->Row!=0;
		}
		return false;
	}
	return false;
}

bool LSMySQLResultType::InitVariable(LSOBJECTDATA &ObjectData, const char *SubType)
{
	if (SubType && SubType[0])
		return false;
	ObjectData.Ptr=new CMySQLResult; 
	return true;
}
void LSMySQLResultType::FreeVariable(LSOBJECTDATA &ObjectData)
{
	if (((CMySQLResult*)ObjectData.Ptr)->Res)
	{
		mysql_free_result(((CMySQLResult*)ObjectData.Ptr)->Res);
		delete (CMySQLResult*)ObjectData.Ptr;
	}
}
bool LSMySQLResultType::ToText(LSOBJECTDATA ObjectData, char *buf, unsigned int buflen)
{
	// does not reduce
	return false;
}

bool LSMySQLResultType::FromText(LSOBJECTDATA &ObjectData, int argc, char *argv[])
{
	// ignore
	return true;
}
