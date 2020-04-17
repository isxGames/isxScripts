/*
Version 1.06
Created by Kannkor (HotShot)

Version 1.06
	Changed default tier to 10 from 9
Version 1.05
	Added additional args for specifying which tier per type (Thanks to Noob536 for the intiial code)
Version 1.04
	Added rendering time
Version 1.03
	Added facing
Version 1.02 - Kannkor
	Updated text so gather works
Version 1.01 - Kannkor
	Changed default to T9
*/
variable int OptionNum=9
variable string Communication=Waiting
variable bool HunterDone=FALSE
variable bool MinerDone=FALSE
variable bool GathererDone=FALSE
variable int GathererTier
variable int HunterTier
variable int MinerTier 
variable int DefaultTimeToWait=72000
;// 72000 should be 2 hours
variable int TimeToWait=72000
;// This one may change in the script
function main(int TempNum=12, bool LoopScript=TRUE, ... Args)
{

	OptionNum:Set[${TempNum}]
	GathererTier:Set[${TempNum}]
	HunterTier:Set[${TempNum}]
	MinerTier:Set[${TempNum}]
	
	variable int i
	for(i:Set[1]; ${i} <= ${Args.Used}; i:Inc)
	{
		switch ${Args[${i}]}
		{
			case -g
			case -gatherer
				i:Inc
				if ${Args[${i}]} > 0
					GathererTier:Set[${Args[${i}]}]
				break
			case -h
			case -hunter
				i:Inc
				if ${Args[${i}]} > 0				
					HunterTier:Set[${Args[${i}]}]
				break
			case -m
			case -miner
				i:Inc
				if ${Args[${i}]} > 0
					MinerTier:Set[${Args[${i}]}]
				break
		}
	}


	Event[EQ2_onIncomingChatText]:AttachAtom[EQ2_onIncomingChatText]
	Event[EQ2_onIncomingText]:AttachAtom[EQ2_onIncomingText]

	;// Should help rendering...
	variable int RenderCounter
	for ( RenderCounter:Set[1] ; ${RenderCounter} < 20  ; RenderCounter:Inc )
	{
		if !${Actor[guild, guild hunter].Name(exists)} || !${Actor[guild, guild miner].Name(exists)} || !${Actor[guild, guild gatherer].Name(exists)}
			wait 10
		else
			break
	}
	if !${Actor[guild, guild hunter].Name(exists)} || !${Actor[guild, guild miner].Name(exists)} || !${Actor[guild, guild gatherer].Name(exists)}
	{
		echo ${Time}: OgreHireling: Unable to find a hireling: !${Actor[guild, guild hunter].Name(exists)} || !${Actor[guild, guild miner].Name(exists)} || !${Actor[guild, guild gatherer].Name(exists)}
		return
	}

	do
	{
		Communication:Set[Waiting]
		;// Target Guild Hunter, hail to check his conversation
		if !${HunterDone} && ${Actor[guild, guild hunter].Name(exists)}
		{
			Actor[guild, guild hunter]:DoTarget
			wait 100 ${Target.Guild.Equal[guild hunter]}
			Actor[guild, guild hunter]:DoFace
			wait 2
			Actor[guild, guild hunter]:DoubleClick
			;Waiting for the atom to change the line below so we can continue
			wait 10000 !${Communication.Equal[Waiting]}
			if ${Communication.Find[collect]}
			{
				echo ${Time}: Collecting Hunter hireling
				EQ2UIPage[ProxyActor,Conversation].Child[composite,replies].Child[button,1]:LeftClick
			}
			elseif ${Communication.Find[GoHarvest]}
			{
				echo ${Time}: Sending Hunter hireling out
				if ${HunterTier} <= 6
				{
					EQ2UIPage[ProxyActor,Conversation].Child[composite,replies].Child[button,1]:LeftClick
					wait 5
					EQ2UIPage[ProxyActor,Conversation].Child[composite,replies].Child[button,${HunterTier}]:LeftClick
				}
				else
				{
					EQ2UIPage[ProxyActor,Conversation].Child[composite,replies].Child[button,2]:LeftClick
					wait 5
					EQ2UIPage[ProxyActor,Conversation].Child[composite,replies].Child[button,${Math.Calc64[${HunterTier}-6]}]:LeftClick
				}
				HunterDone:Set[TRUE]
			}
			elseif ${Communication.Find[Harvesting]}
			{
				echo ${Time}: Hunter hireling is still out harvesting. Set timer to 15 mins and try again
				TimeToWait:Set[9000]
				HunterDone:Set[TRUE]
			}
		}
		elseif !${MinerDone} && ${Actor[guild, guild miner].Name(exists)}
		{
			Actor[guild, guild miner]:DoTarget
			wait 100 ${Target.Guild.Equal[guild miner]}
			Actor[guild, guild miner]:DoFace
			wait 2
			Actor[guild, guild miner]:DoubleClick
			;Waiting for the atom to change the line below so we can continue
			wait 10000 !${Communication.Equal[Waiting]}
			if ${Communication.Find[collect]}
			{
				echo ${Time}: Collecting Miner hireling
				EQ2UIPage[ProxyActor,Conversation].Child[composite,replies].Child[button,1]:LeftClick
			}
			elseif ${Communication.Find[GoHarvest]}
			{
				echo ${Time}: Sending miner hireling out
				if ${MinerTier} <= 6
				{
					EQ2UIPage[ProxyActor,Conversation].Child[composite,replies].Child[button,1]:LeftClick
					wait 5
					EQ2UIPage[ProxyActor,Conversation].Child[composite,replies].Child[button,${MinerTier}]:LeftClick				
				}
				else
				{
					EQ2UIPage[ProxyActor,Conversation].Child[composite,replies].Child[button,2]:LeftClick
					wait 5
					EQ2UIPage[ProxyActor,Conversation].Child[composite,replies].Child[button,${Math.Calc64[${MinerTier}-6]}]:LeftClick
				}
				MinerDone:Set[TRUE]
			}
			elseif ${Communication.Find[Harvesting]}
			{
				echo ${Time}: Miner hireling is still out harvesting. Set timer to 15 mins and try again
				TimeToWait:Set[9000]
				MinerDone:Set[TRUE]
			}
		}
		elseif !${GathererDone} && ${Actor[guild, guild gatherer].Name(exists)}
		{
			Actor[guild, guild gatherer]:DoTarget
			wait 100 ${Target.Guild.Equal[guild gatherer]}
			Actor[guild, guild gatherer]:DoFace
			wait 2
			Actor[guild, guild gatherer]:DoubleClick
			;Waiting for the atom to change the line below so we can continue
			wait 10000 !${Communication.Equal[Waiting]}
			if ${Communication.Find[collect]}
			{
				echo ${Time}: Collecting Gatherer hireling
				EQ2UIPage[ProxyActor,Conversation].Child[composite,replies].Child[button,1]:LeftClick
			}
			elseif ${Communication.Find[GoHarvest]}
			{
				echo ${Time}: Sending gatherer hireling out
				if ${GathererTier} <= 6
				{
					EQ2UIPage[ProxyActor,Conversation].Child[composite,replies].Child[button,1]:LeftClick
					wait 5
					EQ2UIPage[ProxyActor,Conversation].Child[composite,replies].Child[button,${GathererTier}]:LeftClick				
				}
				else
				{
					EQ2UIPage[ProxyActor,Conversation].Child[composite,replies].Child[button,2]:LeftClick
					wait 5
					EQ2UIPage[ProxyActor,Conversation].Child[composite,replies].Child[button,${Math.Calc64[${GathererTier}-6]}]:LeftClick
				}	
				GathererDone:Set[TRUE]
			}
			elseif ${Communication.Find[Harvesting]}
			{
				echo ${Time}: Gatherer hireling is still out harvesting. Set timer to 15 mins and try again
				TimeToWait:Set[9000]
				GathererDone:Set[TRUE]
			}
		}
		elseif ${HunterDone} && ${MinerDone} && ${GathererDone}
		{
			;If we are not suppose to loop and the wait time is the default ( 2 hours ) then don't loop.
			if !${LoopScript} && ${TimeToWait}==${DefaultTimeToWait}
				return

			;This means everything is done. Lets wait our time then check again
			;Waiting how ever much time is specified, then resetting back to the default.
			wait ${TimeToWait}
			HunterDone:Set[FALSE]
			MinerDone:Set[FALSE]
			GathererDone:Set[FALSE]
			TimeToWait:Set[${DefaultTimeToWait}]
		}
		wait 10
	}
	while 1
echo EQ2OgreHireling is completed.
}
atom(script) EQ2_onIncomingChatText(int ChatType, string Message, string Speaker, string ChatTarget, string SpeakerIsNPC, string ChannelName)
{
	;Chat type 15=group, 16=raid, 28=tell, 8=say
	if ${ChatType}==26 && ${Message.Find["Shall I give you the resources we collected"]} && ${Actor[${Speaker}].Guild.Equal[guild hunter]}
		Communication:Set[Collect]
	elseif ${ChatType}==26 && ${Message.Find[Shall I give them to ye]} && ${Actor[${Speaker}].Guild.Equal[guild miner]}
		Communication:Set[Collect]
	elseif ${ChatType}==26 && ${Message.Find[Shall I give you the resources we collected]} && ${Actor[${Speaker}].Guild.Equal[guild gatherer]}
		Communication:Set[Collect]
	elseif ${ChatType}==26 && ${Message.Find[Are you in need of my beast hunting skills]} && ${Actor[${Speaker}].Guild.Equal[guild hunter]}
		Communication:Set[GoHarvest]
	elseif ${ChatType}==26 && ${Message.Find[How may me and the boys be o' service]} && ${Actor[${Speaker}].Guild.Equal[guild miner]}
		Communication:Set[GoHarvest]
	elseif ${ChatType}==26 && ${Message.Find[What is it that you need gathered from the wilds of Norrath]} && ${Actor[${Speaker}].Guild.Equal[guild gatherer]}
		Communication:Set[GoHarvest]
	elseif ${ChatType}==8 && ${Message.Find[The hunting expedition is still under way.]} && ${Actor[${Speaker}].Guild.Equal[guild hunter]}
		Communication:Set[Harvesting]
	elseif ${ChatType}==8 && ${Message.Find[The boys are a still diggin' up the current order.]} && ${Actor[${Speaker}].Guild.Equal[guild miner]}
		Communication:Set[Harvesting]
	elseif ${ChatType}==8 && ${Message.Find[Our people are still out in the wilds.]} && ${Actor[${Speaker}].Guild.Equal[guild gatherer]}
		Communication:Set[Harvesting]
}
atom(script) EQ2_onIncomingText(int ChatType, string Message, string Speaker, string ChatTarget, string SpeakerIsNPC, string ChannelName)
{
	;echo here
}