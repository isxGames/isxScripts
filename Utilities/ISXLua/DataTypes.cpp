#include "ISXLua5.h"
#define DATATYPE(_class_,_variable_) class _class_ *_variable_=0
#include "DataTypeList.h"
#undef DATATYPE

// A LavishScript data type is much like a C++ class.  It has data members and methods, and can use
// inheritance.  A data type describes the view of a type of object; it is not the object itself.

// The sample data type does NOT allow variables to be created of its type.  That is slightly more
// advanced, and unnecessary for most purposes.  If you need help with that, please get in touch with
// Lax for an example.
/*
bool Lua5Type::ToString(LSOBJECTDATA ObjectData, PCHAR Destination)
{
	// The ToString function is used when a data sequence ends with an object of this type.  Its job is
	// to fill the Destinatino with the default value of this object.  For example, the "int" type simply 
	// performs itoa (integer to ascii conversion).

	// ObjectData is the object, or a pointer to the object.  Validate the object here.
	if (!ObjectData.Ptr)
		return false;

	strcpy(Destination,"ISXLua5");
	return true;
}

bool Lua5Type::GetMember(LSOBJECTDATA ObjectData, char * Member, int argc, char * argv[], LSOBJECT &Object)
{
	// The GetMember function is used when a data sequence accesses a member of an object of this type.
	// Its job is to take the member name (such as RetrieveData), retrieve the requested data, and place
	// it in Dest, to be used as the next object in the data sequence.  argc and argv are used if the member
	// access uses an index, such as RetrieveData[1] or RetrieveData[my coat,1,seventeen].  argc is the
	// number of parameters (or dimensions) separated by commas, and does NOT include the name of the member.

	// As a general rule, members should NOT make changes to the object, or perform actions -- that is what
	// methods are for :)

	// LSOBJECT, used for Dest, is ObjectData with a Type.  Type should be set to a pointer to a data type,
	// such as Dest.Type=pIntType for integers.  Do not set the Type or return true if the data retrieval
	// fails (there is no object).  For example, if the requested data is a string, and the string does
	// not exist, return false and do not set the type.

	// ObjectData is the object, or a pointer to the object.  Validate the object here.
	if (!ObjectData.Ptr)
		return false;

	// Retrieve a pointer to the member data (which contains the name and ID) for this member
	PLSTYPEMEMBER pMember=Lua5Type::FindMember(Member);
	// If the member did not exist, perform inheritance lookups or return false
	if (!pMember)
	{
		// sample inheritance lookup:
		// return pIntType->FindMember(ObjectData,Member,argc,argv,Dest);

		// ObjectData may also be changed to another object for the inheritance lookup:
		// ObjectData.CharPtr=SomeCharacterArray;
		// return pStringType->FindMember(ObjectData,Member,argc,argv,Dest);
		return false;
	}

	switch((Lua5TypeMembers)pMember->ID)
	{
	case RetrieveData:
		// Handle the "RetrieveData" member
		{
			// use argc and argv if you need to process parameters
			// return true if you set Dest to a new, valid object. otherwise, return false.
			return false;
		}
	}

	return false;
}

bool Lua5Type::GetMethod(LSOBJECTDATA &ObjectData, char * Method, int argc, char * argv[])
{
	// The GetMethod function is used when a data sequence access a method of an object of this type.
	// Its job is to take the method name (such as PerformAction), and perform the requested action.
	// Unlike members, methods do not result in a new object -- they may make changes to the original 
	// object, but always result in the same object (return true), or no object if the object was deleted
	// (return false).

	// ObjectData here is passed by reference, so that you may modify the value stored if necessary.  32-bit
	// (or less) integer types, for example, use a value directly in the ObjectData, rather than a pointer 
	// to an object.

	// ObjectData is the object, or a pointer to the object.  Validate the object here.
	if (!ObjectData.Ptr)
		return false;

	// Retrieve a pointer to the method data (which contains the name and ID) for this method
	PLSTYPEMETHOD pMethod=Lua5Type::FindMethod(Method);
	// If the method did not exist, perform inheritance lookups or return false
	if (!pMethod)
	{
		// sample inheritance lookup:
		// return pIntType->FindMethod(ObjectData,Method,argc,argv,Dest);

		// A temporary ObjectData may also be used to use another object for the inheritance lookup:
		// LSOBJECTDATA TempObjectData.CharPtr=SomeCharacterArray;
		// return pStringType->FindMember(TempObjectData,Method,argc,argv,Dest);
		return false;
	}

	switch((Lua5TypeMethods)pMethod->ID)
	{
	case PerformAction:
		// Handle the "PerformAction" member
		{
			// use argc and argv if you need to process parameters
			// return true if the object is still valid. return false if not.
			return true;
		}
	}

	return false;
}
/**/
