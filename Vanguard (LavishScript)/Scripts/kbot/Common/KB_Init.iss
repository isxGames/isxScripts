/*


DO NOT CHANGE ANYTHING IN HERE!


*/

#define KB_PAUSE					0

#define KB_BUFF						10
#define KB_TOGGLEBUFF				11
#define KB_FORMS					12
#define KB_HEAL						13
#define KB_REST						14
#define KB_SAFECHECK				15
#define KB_DEAD						16
#define KB_FORAGE					17

#define KB_CORPSECHECK				30
#define KB_LOOT						31
#define KB_HARVESTCHECK				32
#define KB_HARVEST					33
#define KB_SKIN						34
#define KB_NECROPSY					35
#define KB_GETENERGY				36
#define KB_GETMINIONS				37

#define KB_MOVE						41
#define KB_LEASH					42
#define KB_MANAGE_ADD				43
#define KB_MOVESAFE					44

#define KB_FINDTARGET				70
#define KB_COMBATPULL				71
#define KB_COMBATBUFF				72
#define KB_COMBATFORMS				73
#define KB_COMBATPETS				74
#define KB_COMBATHEAL				75
#define KB_COMBATSNARE				76
#define KB_COMBATFD					77
#define KB_COMBATCANNI				78

#define KB_COMBATCHECK				80

#define KB_ATTACK					90
#define KB_DOT						93
#define KB_CHAIN					95
#define KB_COUNTER					96
#define KB_RESCUE					97

#define KB_FIGHT					100


function KB_Init()
{

	declare SaveDir				filepath			script 	"${Script.CurrentDirectory}/save/"
	declare ConfigFile			string				script 	"${Script.CurrentDirectory}/save/${Me.FName}_config.xml"
	declare OutputFile			string				script 	"${Script.CurrentDirectory}/save/${Me.FName}_debug.log"
	declare VGPathsDir			filepath			script 	"${Script.CurrentDirectory}/vgpaths/"

	declare AutoRespondFile 	string				script 	"${Script.CurrentDirectory}/common/autorespond.xml"

	declare setConfig			settingsetref 		script
	declare setPath				settingsetref 		script
	declare setAutoRespond		settingsetref 		script


	declare CurrentWP			int					script 	1
	declare LastWP				int					script 	1
	declare WPDirection			string				script 	"Forward"

	declare leashToFar			bool				script 	FALSE
	declare justPorted			bool				script 	FALSE
	declare justAte				bool				script 	FALSE
	declare isSitting			bool				script 	FALSE
	declare isHarvesting		bool				script 	FALSE
	declare justNuked			bool				script 	FALSE
	declare hasStarted			bool				script 	FALSE

	declare BadTargetID[5] 		int64 				script
	BadTargetID[1]:Set[NULL]
	BadTargetID[2]:Set[NULL]
	BadTargetID[3]:Set[NULL]
	BadTargetID[4]:Set[NULL]
	BadTargetID[5]:Set[NULL]

	declare PlayerAgroRange		int					script 	60
	declare MobAgroRange		int					script 	10

	;General declare s
	declare Tank				string				script
	declare TankID				int64				script

	declare TotalKills 			int					script
	declare CurrentXP 			int					script
	declare StartingXP 			int					script
	declare GainedXP			int					script

	declare LastCorpseID		int64				script
	declare isRunning			bool 				script 	FALSE
	declare isPaused			bool 				script 	FALSE

	;Totally AFK declare s
	declare  TotallyAFK			bool				script 	FALSE
	declare  AFKAbility 		string				script
	declare  AFKMessage 		string				script

	;Combat declare s
	declare AttackOrder			int 				script 	1
	declare StuckLoop			int 				script 	0
	declare PullAttempts 		int 				script 	1
	declare MaxLevel			int 				script 	0
	declare MinLevel			int 				script 	0
	declare Pulled				bool 				script 	FALSE

	; object defined in bnavobjects.iss
	;declare navi				bnav				global
	;declare PathFinder			astarpathfinder 	global
	;declare CurrentConnection	lnavconnection 		global
	;declare CurrentRegion 		string 				global
	;declare LastRegion			string 				global
	;declare mypath				lnavpath 			script
	;declare bpathindex			int 				global 	0
	declare CurrentChunk		string 				global
	declare pointcount			int 				global 	0
	declare isMapping			bool 				script 	TRUE
	declare autoMapOn			bool				script	TRUE

	; Other Stuff
	declare DoWeHaveFD			bool				script
	declare FeignDeath			string 				script
	declare FeignDeathAt		int 				script
	declare FightOnAt			int 				script

	declare DoWeHaveCanni		bool				script
	declare Canni				string 				script
	declare CanniHPAt			int 				script
	declare CanniEgAt			int					script

	declare RequiredJin 		int 				script

	; Blacklisting Variables
	declare Reset_GUIDBlacklist	bool				script 	TRUE
	declare GUIDBlacklist		collection:int64	script
	declare NameBlacklist		collection:int  	script
}