#pragma once

class LGUILua5Frame :
	public LGUIFrame
{
public:
	LGUILua5Frame(char *p_Factory, LGUIElement *p_pParent, char *p_Name);
	~LGUILua5Frame(void);
	bool IsTypeOf(char *TestFactory);
	bool FromXML(class XMLNode *pXML, class XMLNode *pTemplate=0);
	void OnCreate();
	void Render();

	LGUIText *pText;
	unsigned long Count;
};

extern LGUIFactory<LGUILua5Frame> Lua5FrameFactory;

