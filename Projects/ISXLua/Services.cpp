#include "ISXLua5.h"
#include "ISXLua5Services.h"

#define SERVICE(_name_,_callback_,_variable_) HISXSERVICE _variable_=0;
#include "Services.h"
#undef SERVICE

void __cdecl Lua5Service(ISXInterface *pClient, unsigned long MSG, void *lpData)
{
	switch(MSG)
	{
	case ISXSERVICE_CLIENTADDED:
		// This message indicates that a new client has been added to the service
		// pClient is 0, because this message is a system message from Inner Space
		// lpData is an ISXInterface* that is the pointer to the new client
		{
			// use lpData as the actual type, not as void *.  We can make a new
			// variable to do this:
			ISXInterface *pNewClient=(ISXInterface *)lpData;

			printf("Lua5Service client added: %X",pNewClient);
			// You may use the client pointer (pNewClient here) as an ID to track client-specific
			// information.  Some services such as the memory service do this to automatically
			// remove memory modifications made by an extension when that extension is unloaded.
		}
		break;
	case ISXSERVICE_CLIENTREMOVED:
		// This message indicates that a client has been removed from the service
		// pClient is 0, because this message is a system message from Inner Space
		// lpData is an ISXInterface* that is the pointer to the removed client
		{
			// use lpData as the actual type, not as void *.  We can make a new
			// variable to do this:
			ISXInterface *pRemovedClient=(ISXInterface *)lpData;

			printf("Lua5Service client removed: %X",pRemovedClient);
		}
		break;
	case Lua5_FOO:
		// This is a custom service request defined in ISXLua5Services.h
		// pClient is a valid pointer to the client that sent this request
		// lpData is a Lua5Request_Foo* as sent by the client
		{
			Lua5Request_Foo *pFoo=(Lua5Request_Foo*)lpData;
			// as described in ISXLua5Services.h, pFoo has "Success" which we need
			// to set to true if we succeed, and "Text" which we make use of.

			// Our Foo operation sends a Bar broadcast.  Set up the Bar data
			Lua5Notification_Bar Bar;
			Bar.Text=pFoo->Text;
			pFoo->Success=pISInterface->ServiceBroadcast(pExtension,hLua5Service,Lua5_BAR,&Bar);

			// and that's it!
		}
		break;
	}
}


