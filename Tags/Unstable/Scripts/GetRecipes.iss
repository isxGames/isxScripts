;-----------------------------------------------------------------------------------------------
; GetRecipes.iss Version 1.0  Updated: 06/16/06
;
; Written by: Blazer
;
; Description:
; ------------
; Retrieves all Recipes in your Recipe Book and saves it into the appropriate recipe files
; to be used with Craft.
;-----------------------------------------------------------------------------------------------

#include moveto.iss

variable int tempvar
variable int pathindex
variable filepath RecipePath="${LavishScript.HomeDirectory}/Scripts/EQ2Craft/Recipe Data/"
variable filepath NavigationPath="${LavishScript.HomeDirectory}/Scripts/EQ2Craft/Navigational Paths/"
variable string World
variable float WPX
variable float WPZ
variable string NearestPoint
variable string recipefile
variable string resourcefile
variable string Recipe
variable string CurrentFile
variable int startlevel=${xLevel}
variable int endlevel=${yLevel}
variable string classfile[9]
variable string crafttype

function main(int xLevel,int yLevel)
{
	Script:Squelch

	if ${startlevel}>${Me.TSLevel} || ${startlevel}<1
	{
		startlevel:Set[${Me.TSLevel}]
	}

	if ${yLevel}
	{
		EQ2Echo Retrieving ALL Recipes from Level ${startlevel} to Level ${endlevel}
	}
	else
	{
		endlevel:Set[${startlevel}]
		startlevel:Set[1]
		EQ2Echo Retrieving ALL Recipes up to and including Level ${endlevel}
	}

	classfile[1]:Set[Armorer.xml]
	classfile[2]:Set[Tailor.xml]
	classfile[3]:Set[Weaponsmith.xml]
	classfile[4]:Set[Alchemist.xml]
	classfile[5]:Set[Jeweler.xml]
	classfile[6]:Set[Sage.xml]
	classfile[7]:Set[Carpenter.xml]
	classfile[8]:Set[Woodworker.xml]
	classfile[9]:Set[Provisioner.xml]

	tempvar:Set[0]
	while ${tempvar:Inc}<=9
	{
		XMLSetting -load "${RecipePath}${classfile[${tempvar}]}"
	}
	
	resourcefile:Set[${RecipePath}Resources.xml]

	World:Set[${Zone.ShortName}]
	Navigation -reset
	Navigation -load "${NavigationPath}${Zone.ShortName}.xml"

	call MovetoDevice "Chemistry Table"
	call GetRecipeData "Chemistry Table"

	call MovetoDevice "Work Bench"
	call GetRecipeData "Work Bench"

	call MovetoDevice "Sewing Table & Mannequin"
	call GetRecipeData "Sewing Table & Mannequin"
	call GetRecipeData "Loom"

	call MovetoDevice "Woodworking Table"
	call GetRecipeData "Woodworking Table"
	call GetRecipeData "Sawhorse"

	call MovetoDevice "Stove & Keg"
	call GetRecipeData "Stove & Keg"
	call GetRecipeData "Stove and Keg"

	call MovetoDevice "Forge"
	call GetRecipeData "Forge"

	call MovetoDevice "Engraved Desk"
	call GetRecipeData "Engraved Desk"
}

function GetRecipeData(string devicename)
{
	variable string recipetext
	variable string recipeqty
	variable int keycnt
	variable int produceqty
	variable string temptext

	tempvar:Set[1]
	do
	{
		if ${Me.Recipe[${tempvar}].Level}<${startlevel} || ${Me.Recipe[${tempvar}].Level}>${endlevel}
		{
			continue
		}

		Switch "${Me.Recipe[${tempvar}].Device}"
		{
			case Chemistry Table
			case Work Bench
			case Sewing Table & Mannequin
			case Loom
			case Woodworking Table
			case Sawhorse
			case Stove and Keg
			case Stove & Keg
			case Forge
			case Engraved Desk
				break

			Default
				EQ2Echo Unknown Device: ${Me.Recipe[${tempvar}].Device}
				break
		}

		if (${Me.Recipe[${tempvar}].Device.Equal[${devicename}]})
		{
			Me.Recipe[${tempvar}]:Create
			Recipe:Set[${Me.Recipe[${tempvar}].Name}]
			wait 30 ${EQ2UIPage[Tradeskills,Tradeskills].Child[text,Prepare.RecipeName].Label.Equal[${Recipe}]}

			crafttype:Set[${SettingXML[${RecipePath}Common.xml].Set[Tradeskill Type].GetString[${Me.Recipe[${tempvar}].Knowledge}]}]
			CurrentFile:Set[${RecipePath}${crafttype}.xml]
			SettingXML[${CurrentFile}].Set[${Recipe}]:Set[RecipeID,${Me.Recipe[${tempvar}].ID}]
			SettingXML[${CurrentFile}].Set[${Recipe}]:Set[Level,${Me.Recipe[${tempvar}].Level}]
			SettingXML[${CurrentFile}].Set[${Recipe}]:Set[Knowledge,${Me.Recipe[${tempvar}].Knowledge}]
			SettingXML[${CurrentFile}].Set[${Recipe}]:Set[Device,${Target.Name}]
			
			recipetext:Set[${EQ2UIPage[Tradeskills,Tradeskills].Child[text,prepare.summarypage.pcdesc].Label}]
			if !${Recipe.Find[Imbued]}
			{
				temptext:Set[${SettingXML[${resourcefile}].Set[Harvest List].GetString[${recipetext},${recipetext}]}]
			}
			
			SettingXML[${CurrentFile}].Set[${Recipe}]:Set[PrimaryComponent,${recipetext}]

			recipetext:Set[${EQ2UIPage[Tradeskills,Tradeskills].Child[text,prepare.summarypage.bcdesc1].Label}]
			temptext:Set[${SettingXML[${resourcefile}].Set[Harvest List].GetString[${recipetext},${recipetext}]}]
			recipeqty:Set[${EQ2UIPage[Tradeskills,Tradeskills].Child[text,prepare.summarypage.BCCount1].Label}]
			SettingXML[${CurrentFile}].Set[${Recipe}]:Set[BuildComp1,${recipeqty.Token[2,/].Right[-1]} ${recipetext}]

			recipetext:Set[${EQ2UIPage[Tradeskills,Tradeskills].Child[text,prepare.summarypage.bcdesc2].Label}]
			recipeqty:Set[${EQ2UIPage[Tradeskills,Tradeskills].Child[text,prepare.summarypage.BCCount2].Label}]

			if ${recipeqty.Token[2,/].Right[-1].NotEqual[0]}
			{
				SettingXML[${CurrentFile}].Set[${Recipe}]:Set[BuildComp2,${recipeqty.Token[2,/].Right[-1]} ${recipetext}]
				temptext:Set[${SettingXML[${resourcefile}].Set[Harvest List].GetString[${recipetext},${recipetext}]}]
			}

			recipetext:Set[${EQ2UIPage[Tradeskills,Tradeskills].Child[text,prepare.summarypage.bcdesc3].Label}]
			temptext:Set[${SettingXML[${resourcefile}].Set[Harvest List].GetString[${recipetext},${recipetext}]}]
			recipeqty:Set[${EQ2UIPage[Tradeskills,Tradeskills].Child[text,prepare.summarypage.BCCount3].Label}]
			if ${recipeqty.Token[2,/].Right[-1].NotEqual[0]}
			{
				SettingXML[${CurrentFile}].Set[${Recipe}]:Set[BuildComp3,${recipeqty.Token[2,/].Right[-1]} ${recipetext}]
				temptext:Set[${SettingXML[${resourcefile}].Set[Harvest List].GetString[${recipetext},${recipetext}]}]
			}

			recipetext:Set[${EQ2UIPage[Tradeskills,Tradeskills].Child[text,prepare.summarypage.bcdesc4].Label}]
			recipeqty:Set[${EQ2UIPage[Tradeskills,Tradeskills].Child[text,prepare.summarypage.BCCount4].Label}]
			if ${recipeqty.Token[2,/].Right[-1].NotEqual[0]}
			{
				SettingXML[${CurrentFile}].Set[${Recipe}]:Set[BuildComp4,${recipeqty.Token[2,/].Right[-1]} ${recipetext}]
				temptext:Set[${SettingXML[${resourcefile}].Set[Harvest List].GetString[${recipetext},${recipetext}]}]
			}

			recipeqty:Set[${EQ2UIPage[Tradeskills,Tradeskills].Child[text,prepare.summarypage.FuelCount].Label}]
			SettingXML[${CurrentFile}].Set[${Recipe}]:Set[FuelComponent,${recipeqty.Token[2,/].Right[-1]} ${EQ2UIPage[Tradeskills,Tradeskills].Child[text,prepare.summarypage.fueldesc].Label}]

			EQ2UIPage[Tradeskills,Tradeskills].Child[text,prepare.summarypage.CancelButton]:LeftClick
		}
	}
	while ${tempvar:Inc}<=${Me.NumRecipes}

	if ${EQ2UIPage[Tradeskills,Tradeskills].Child[button,Tradeskills.Prepare.SummaryPage.CancelButton](exists)}
	{
		wait 10
		EQ2UIPage[Tradeskills,Tradeskills].Child[button,Tradeskills.Prepare.SummaryPage.CancelButton]:LeftClick
		wait 10
		EQ2Execute /hide_window TradeSkills.TradeSkills
	}
}

function MovetoDevice(string devicename)
{
	NavPath:Clear
	pathindex:Set[1]
	
	NearestPoint:Set[${Navigation.World["${World}"].NearestPoint[${Me.X},${Me.Y},${Me.Z}]}]

	NavPath "${World}" "${NearestPoint}" "${devicename} 1"

	if "${NavPath.Points}>0"
	{
		press MOVEFORWARD
		do
		{
			; Move to next Waypoint
			WPX:Set[${NavPath.Point[${pathindex}].X}]
			WPZ:Set[${NavPath.Point[${pathindex}].Z}]

			call moveto ${WPX} ${WPZ} 3 1 5

			if "${Return.Equal[STUCK]}"
			{
				echo we are stuck!
				pathindex:Dec[10]
				if ${pathindex}<1
				{
					pathindex:Set[1]
				}
				continue
			}

			if "${Navigation.World[${Zone.ShortName}].Point[${NavPath.PointName[${pathindex}]}].Note.Equal[Open]}"
			{
				wait 3
				press MOVEFORWARD
				press ESC
				press ESC
				press ESC
				EQ2:CreateCustomActorArray[byDist]
				CustomActor[2]:DoubleClick
				wait 15
				press MOVEFORWARD
			}
		}		
		while ${pathindex:Inc}<=${NavPath.Points}
		press MOVEFORWARD
	}

	wait 10
	target ${devicename}
	wait 10 "${Target.ID}==${Target[${devicename}].ID}"
	face
	wait 10
}

function atexit()
{
	SettingXML[${resourcefile}].Set[Harvest List]:Sort
	SettingXML[${resourcefile}]:Save
	SettingXML[${resourcefile}]:Unload
	
	tempvar:Set[0]
	while ${tempvar:Inc}<=9
	{
		SettingXML[${RecipePath}${classfile[${tempvar}]}]:Sort
		SettingXML[${RecipePath}${classfile[${tempvar}]}]:Save
		SettingXML[${RecipePath}${classfile[${tempvar}]}]:Unload
	}

	EQ2Echo Recipe Retrieval Complete!
}
