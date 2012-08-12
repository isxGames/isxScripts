#include "ISXLua5.h"
#include "LGUILua5Frame.h"

LGUIFactory<LGUILua5Frame> Lua5FrameFactory("lua5frame");

LGUILua5Frame::LGUILua5Frame(char *p_Factory, LGUIElement *p_pParent, char *p_Name):LGUIFrame(p_Factory,p_pParent,p_Name)
{
	pText=0;
	Count=0;
}
LGUILua5Frame::~LGUILua5Frame(void)
{
}
bool LGUILua5Frame::IsTypeOf(char *TestFactory)
{
	return (!stricmp(TestFactory,"lua5frame")) || LGUIFrame::IsTypeOf(TestFactory);
}
bool LGUILua5Frame::FromXML(class XMLNode *pXML, class XMLNode *pTemplate)
{
	if (!pTemplate)
		pTemplate=g_UIManager.FindTemplate(XMLHelper::GetStringAttribute(pXML,"Template"));
	if (!pTemplate)
		pTemplate=g_UIManager.FindTemplate("lua5frame");
	if (!LGUIFrame::FromXML(pXML,pTemplate))
		return false;

	// custom xml properties
	return true;
}

void LGUILua5Frame::OnCreate()
{
	// All children of this element are guaranteed to have been created now.
	pText = (LGUIText*)FindUsableChild("Output","text");
}

void LGUILua5Frame::Render()
{
	Count++;
	if (pText)
	{
		char Temp[256];
		sprintf(Temp,"This frame has been rendered %d times.",Count);
		pText->SetText(Temp);
	}

	LGUIFrame::Render();
}


