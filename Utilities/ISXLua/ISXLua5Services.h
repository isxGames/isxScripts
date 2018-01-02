#pragma once
/**********************************************************************
 ISXLua5Services.h is a redistributable file that can be used 
 by other extensions to access the services provided by ISXLua5.
 It should contain all information for any message that can be sent to
 clients from the master (individually or broadcast), or to the master 
 from clients.

 All "in/out" information is relative to the client.  If it says "in"
 it means the client feeds information in.  If it says "out" it means
 the client pulls information out.
 **********************************************************************/

// ----- "Lua5 Service" messages ------------------------------
// Note: ISXSERVICE_MSG defines the starting point for service-specific
//       message numbers.  Numbers below ISXSERVICE_MSG are reserved for
//       future system use.
//       These message numbers are PER SERVICE, so you can and should
//       reuse numbers for different services

/* in  (requests) */
#define Lua5_FOO						(ISXSERVICE_MSG+1)
// add all requests

/* out (notifications) */
#define Lua5_BAR						(ISXSERVICE_MSG+2)
// add all notifications

// ----- "Lua5 Service" request structures ---------------------
// These structures are sent as the "lpData" in requests or notifications.

// Lua5_FOO
struct Lua5Request_Foo
{
	/* in  */ char *Text; 

	/* out */ bool Success;
};

// ----- "Lua5 Service" Helper Functions -----------------------
// Put any helper functions for REQUESTS here.  Notifications are done by
// the service master, and do not need redistributable helper functions.

static inline bool Lua5Foo(ISXInterface *pClient, ISInterface *pISInterface, HISXSERVICE hLua5Service, char *Text)
{
	// set up lpData
	Lua5Request_Foo Foo;
	Foo.Text=Text;
	Foo.Success=false;
	// return true if a) the service request was sent correctly and b) the service set Success to true, indicating
	// that the Foo operation was successfully completed
	return pISInterface->ServiceRequest(pClient,hLua5Service,Lua5_FOO,&Foo) && Foo.Success;
}
// Most extensions will opt to use the default naming conventions, with a global pISInterface and pExtension,
// and your service handle name.  This means you can make an "easy" macro to call Lua5Foo for them,
// and they can just use EzFoo:
#define EzFoo(_text_) Lua5Foo(pExtension,pISInterface,hLua5Service,Text)

// ----- "Lua5 Service" notification structures ---------------------
// The following structures are for use in Lua5 Service notification handlers
// Lua5_BAR
// NOTE: For structures that have only one data item, we dont really need a structure.  But to make things
//       easy to use and understand, it's perfectly fine and compiles to the same machine code anyway.
struct Lua5Notification_Bar
{
	/* out */ char *Text;
};

