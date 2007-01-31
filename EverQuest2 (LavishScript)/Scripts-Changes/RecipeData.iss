#include moveto.iss

function main()
{
	declare tempvar int script
	declare pathindex int script
	declare xmlpath string script "./XML/"
	declare World string script
	declare WPX float script
	declare WPZ float script
	declare NearestPoint string script
	declare recipefile string script
	declare alternatefile string script
	declare Recipe string script
	declare CurrentFile string script

	Script:Squelch

	recipefile:Set[${xmlpath}NewCraft${Me.TSSubClass}.xml]
	alternatefile:Set[${xmlpath}NewCraftAlternate.xml]

	XMLSetting -load "${recipefile}"
	XMLSetting -load "${alternatefile}"

	World:Set[${Zone.ShortName}]
	Navigation -reset
	Navigation -load "${xmlpath}EQ2Navigation_${Zone.ShortName}.xml"

	call MovetoDevice "Chemistry Table"
	call GetRecipeData "Chemistry Table"

	call MovetoDevice "Work Bench"
	call GetRecipeData "Work Bench"

	call MovetoDevice "Sewing Table & Mannequin"
	call GetRecipeData "Sewing Table & Mannequin"
	call MovetoDevice "Sewing Table & Mannequin"
	call GetRecipeData "Loom"

	call MovetoDevice "Woodworking Table"
	call GetRecipeData "Woodworking Table"
	call MovetoDevice "Woodworking Table"
	call GetRecipeData "Sawhorse"

	call MovetoDevice "Stove & Keg"
	call GetRecipeData "Keg"
	call MovetoDevice "Stove & Keg"
	call GetRecipeData "Stove and Keg"

	call MovetoDevice "Forge"
	call GetRecipeData "Forge"

	call MovetoDevice "Engraved Desk"
	call GetRecipeData "Engraved Desk"
}

function GetRecipeData(string devicename)
{
	declare recipetext string local
	declare recipeqty string local
	declare keycnt int local
	declare tmprecipe string local
	declare produceqty int local

	tempvar:Set[1]
	do
	{
		if ${Me.Recipe[${tempvar}].Level}<50
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
			case Keg
			case Stove and Keg
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
			wait 15

			tmprecipe:Set[${Me.Recipe[${tempvar}].Name}]
			if ${tmprecipe.Find[:]}
			{
				CurrentFile:Set[${alternatefile}]
				Recipe:Set[${tmprecipe.Token[1,:]}]
			}
			else
			{
				CurrentFile:Set[${recipefile}]
				Recipe:Set[${tmprecipe}]
			}

			SettingXML[${CurrentFile}].Set[${Recipe}]:Set[RecipeID,${Me.Recipe[${tempvar}].ID.Unsigned}]
			SettingXML[${CurrentFile}].Set[${Recipe}]:Set[Process,${Me.Recipe[${tempvar}].Process}]
			SettingXML[${CurrentFile}].Set[${Recipe}]:Set[Level,${Me.Recipe[${tempvar}].Level}]
			SettingXML[${CurrentFile}].Set[${Recipe}]:Set[Knowledge,${Me.Recipe[${tempvar}].Knowledge}]
			SettingXML[${CurrentFile}].Set[${Recipe}]:Set[Device,${Me.Recipe[${tempvar}].Device}]
			SettingXML[${CurrentFile}].Set[${Recipe}]:Set[PrimaryComponent,${EQ2UIPage[Tradeskills,Tradeskills].Child[text,prepare.summarypage.pcdesc].Label}]

			recipeqty:Set[${EQ2UIPage[Tradeskills,Tradeskills].Child[text,prepare.summarypage.BCCount1].Label}]
			SettingXML[${CurrentFile}].Set[${Recipe}]:Set[BuildComp1,${recipeqty.Token[2,/].Right[-1]} ${EQ2UIPage[Tradeskills,Tradeskills].Child[text,prepare.summarypage.bcdesc1].Label}]

			recipetext:Set[${EQ2UIPage[Tradeskills,Tradeskills].Child[text,prepare.summarypage.bcdesc2].Label}]
			recipeqty:Set[${EQ2UIPage[Tradeskills,Tradeskills].Child[text,prepare.summarypage.BCCount2].Label}]

			if ${recipeqty.Token[2,/].Right[-1].NotEqual[0]}
			{
				SettingXML[${CurrentFile}].Set[${Recipe}]:Set[BuildComp2,${recipeqty.Token[2,/].Right[-1]} ${recipetext}]
			}

			recipetext:Set[${EQ2UIPage[Tradeskills,Tradeskills].Child[text,prepare.summarypage.bcdesc3].Label}]
			recipeqty:Set[${EQ2UIPage[Tradeskills,Tradeskills].Child[text,prepare.summarypage.BCCount3].Label}]
			if ${recipeqty.Token[2,/].Right[-1].NotEqual[0]}
			{
				SettingXML[${CurrentFile}].Set[${Recipe}]:Set[BuildComp3,${recipeqty.Token[2,/].Right[-1]} ${recipetext}]
			}

			recipetext:Set[${EQ2UIPage[Tradeskills,Tradeskills].Child[text,prepare.summarypage.bcdesc4].Label}]
			recipeqty:Set[${EQ2UIPage[Tradeskills,Tradeskills].Child[text,prepare.summarypage.BCCount4].Label}]
			if ${recipeqty.Token[2,/].Right[-1].NotEqual[0]}
			{
				SettingXML[${CurrentFile}].Set[${Recipe}]:Set[BuildComp4,${recipeqty.Token[2,/].Right[-1]} ${recipetext}]
			}

			recipeqty:Set[${EQ2UIPage[Tradeskills,Tradeskills].Child[text,prepare.summarypage.FuelCount].Label}]
			SettingXML[${CurrentFile}].Set[${Recipe}]:Set[FuelComponent,${recipeqty.Token[2,/].Right[-1]} ${EQ2UIPage[Tradeskills,Tradeskills].Child[text,prepare.summarypage.fueldesc].Label}]

			if ${Recipe.Find[wash]} || ${Recipe.Find[oil]} || ${Recipe.Find[resin]} || ${Recipe.Find[temper]}
			{
				produceqty:Set[4]
			}
			else
			{
				produceqty:Set[1]
			}
			SettingXML[${CurrentFile}].Set[${Recipe}]:Set[Produce,${produceqty}]

			SettingXML[${CurrentFile}]:Save

			EQ2UIPage[Tradeskills,Tradeskills].Child[text,prepare.summarypage.CancelButton]:LeftClick
		}
	}
	while ${tempvar:Inc}<=${Me.NumRecipes}

	press esc
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
				wait 5
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
	SettingXML[${recipefile}]:Unload
	SettingXML[${alternatefile}]:Unload
}
