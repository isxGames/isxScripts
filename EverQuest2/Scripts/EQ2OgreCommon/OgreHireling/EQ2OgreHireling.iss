;Version 1.01
;Created by Kannkor (HotShot)
;Version 1.01 - Kannkor
;Changed default to T12(12)

variable int OptionNum=12
variable int tierNum=1
variable int selNum=1
variable string Communication=Waiting
variable bool HunterDone=FALSE
variable bool MinerDone=FALSE
variable bool GathererDone=FALSE
variable int DefaultTimeToWait=72000
variable int TimeToWait=72000
;This one may change in the script
function main(int TempNum=12, bool LoopScript=TRUE)
{

	OptionNum:Set[${TempNum}]
	Event[EQ2_onIncomingChatText]:AttachAtom[EQ2_onIncomingChatText]
	Event[EQ2_onIncomingText]:AttachAtom[EQ2_onIncomingText]

	;Selects second dialog based off of tier selection
	if ${OptionNum} >= 7
	{
		tierNum:Set[2]
	}

	;Selects proper dialog based off tier selection
	if ${OptionNum} == 7
	{
		selNum:Set[1]
	}
	elseif ${OptionNum} == 8
	{
		selNum:Set[2]
	}
	elseif ${OptionNum} == 9
	{
		selNum:Set[3]
	}
	elseif ${OptionNum} == 10
	{
		selNum:Set[4]
	}
	elseif ${OptionNum} == 11
	{
		selNum:Set[5]
	}
	elseif ${OptionNum} == 12
	{
		selNum:Set[6]
	}
	else
	{
		selNum:Set[${OptionNum}]
	}

	do
	{
		Communication:Set[Waiting]
		;Target Guild Hunter, hail to check his conversation
		if !${HunterDone} && ${Actor[guild, guild hunter](exists)}
		{
			Actor[guild, guild hunter]:DoTarget
			wait 100 ${Target.Guild.Equal[guild hunter]}
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
				EQ2UIPage[ProxyActor,Conversation].Child[composite,replies].Child[button,${tierNum}]:LeftClick
				wait 25
				EQ2UIPage[ProxyActor,Conversation].Child[composite,replies].Child[button,${selNum}]:LeftClick
				HunterDone:Set[TRUE]
			}
			elseif ${Communication.Find[Harvesting]}
			{
				echo ${Time}: Hunter hireling is still out harvesting. Set timer to 15 mins and try again
				TimeToWait:Set[9000]
				HunterDone:Set[TRUE]
			}
		}
		elseif !${MinerDone} && ${Actor[guild, guild miner](exists)}
		{
			Actor[guild, guild miner]:DoTarget
			wait 100 ${Target.Guild.Equal[guild miner]}
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
				EQ2UIPage[ProxyActor,Conversation].Child[composite,replies].Child[button,${tierNum}]:LeftClick
				wait 25
				EQ2UIPage[ProxyActor,Conversation].Child[composite,replies].Child[button,${selNum}]:LeftClick
				MinerDone:Set[TRUE]
			}
			elseif ${Communication.Find[Harvesting]}
			{
				echo ${Time}: Miner hireling is still out harvesting. Set timer to 15 mins and try again
				TimeToWait:Set[9000]
				MinerDone:Set[TRUE]
			}
		}
		elseif !${GathererDone} && ${Actor[guild, guild gatherer](exists)}
		{
			Actor[guild, guild gatherer]:DoTarget
			wait 100 ${Target.Guild.Equal[guild gatherer]}
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
				EQ2UIPage[ProxyActor,Conversation].Child[composite,replies].Child[button,${tierNum}]:LeftClick
				wait 25
				EQ2UIPage[ProxyActor,Conversation].Child[composite,replies].Child[button,${selNum}]:LeftClick
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
	if ${ChatType}==26 && ${Message.Find[Shall I give you the resources we collected]} && ${Actor[${Speaker}].Guild.Equal[guild hunter]}
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