GM.Name 	= "Baiknor II"
GM.Author 	= "RDC"
GM.Email 	= "N/A"
GM.Website 	= "N/A"



--[[
V1.0

<--- Current Maplist --->
gm_construct(debug)
gm_baik_citycentre_v3
gm_baik_coast_03
gm_baik_coast_03_night
gm_baik_construct_draft1
gm_de_port_opened_v2
gm_emp_arid
gm_emp_manticore
gm_emp_midbridge
gm_emp_palmbay
gm_greenchoke


*TODO*

*Planned*
Anti AFK
Game music
Move weapon lists to their own folder for both client and sv
Add support for non spherical safezones *shrug*
Win sounds
Mapvoting
Add point name display




]]--



GameVars = {}

AddCSLuaFile( "Initializing/teamsetup.lua" )
AddCSLuaFile( "Initializing/maplist_setup.lua" )
AddCSLuaFile( "PlayerAndHud/hud.lua" )

include( "Initializing/teamsetup.lua" )
include( "Initializing/maplist_setup.lua" )

DeriveGamemode("sandbox")
	
GameVars.PointsFree = 300
GameVars.PointsDuty = 300
GameVars.WinsToRestart = 2 --Wins until a mapvote is called
GameVars.PropsFreeCount = 0
GameVars.PropsDutyCount = 0
GameVars.WeightFreeCount = 0
GameVars.WeightDutyCount = 0
GameVars.DupeWaitTime = {} --Used to keep track of player dupe spawn delays

GameVars.GameThinkTick = 0 --Every 30 iterations the game thinks
GameVars.Searchtick = 0 --Every 100 normal iterations do an entity search

--local points = ents.FindByClass( "baiknor_controlpoint" )


function GM:Initialize()
	
	
	self.BaseClass.Initialize( self )
	if not CLIENT then
		timer.Simple( 1, function() setupGamemode() end )
		timer.Simple( 1, function() setupTeams() end )
	end
end


--Will create an error that can be ignored if playing SP, Low in priority to fix.
util.AddNetworkString( "update_cappoints_freedom" )
util.AddNetworkString( "update_cappoints_duty" )

util.AddNetworkString( "update_propcount_freedom" )
util.AddNetworkString( "update_propcount_duty" )

util.AddNetworkString( "update_weight_freedom" )
util.AddNetworkString( "update_weight_duty" )


function GamemodeThinkingThing()

	GameVars.GameThinkTick = GameVars.GameThinkTick + 1

	if GameVars.GameThinkTick >= 5 then
		GameVars.GameThinkTick = 0

		if not CLIENT then

			GameVars.Searchtick = GameVars.Searchtick + 1

			if GameVars.Searchtick >= 100 then
				GameVars.Searchtick = 0
				print("[Baik2] Updating Propcount")
				updatePropcount()
			end

			--pl:GetMoveType()


			local allplayers = player.GetAll()
		
			for i, ply in ipairs( player.GetAll() ) do --Reset each player table to 0
				local searchteam = ply:Team()
				if searchteam == 1 then
					inrange = ((ply:GetPos():Distance( GameVars.FreedomSpawn )) < GameVars.SZRadius)
				elseif searchteam == 2 then
					inrange = ((ply:GetPos():Distance( GameVars.DutySpawn )) < GameVars.SZRadius)
				else
					inrange = 1
				end
			if not inrange then
				ply:GodDisable()

				if ply:GetMoveType() == MOVETYPE_NOCLIP and (not ply:IsAdmin()) then --Kill non admins out of noclip, stops people from launching themselves out of SZ and rocketing people
					ply:Kill()
				end

			else
				ply:GodEnable()
			end

		
			end			





	local CapPoints = 0

	for i=1,GameVars.PointCount or 0 do 
		if IsValid(GameVars.PointEntities[i]) then
		CapPoints = CapPoints + GameVars.PointEntities[i].CapOwnership
		end
	end 

	if CapPoints < 0 then

		GameVars.PointsFree = GameVars.PointsFree - math.abs(CapPoints*GameVars.CapMul)

	elseif CapPoints > 0 then

		GameVars.PointsDuty = GameVars.PointsDuty - math.abs(CapPoints*GameVars.CapMul)

	end

	if GameVars.PointsFree < 0 then

--	EmitSound( "mvm/mvm_warning.wav", Vector(0,0,0), -2, CHAN_VOICE, 1, 75, 0, 100 )
	PrintMessage(HUD_PRINTTALK, "Freedom has won the round!!!")
	setupGamemode()
	GameVars.WinsToRestart = GameVars.WinsToRestart - 1

	elseif GameVars.PointsDuty < 0 then

--	EmitSound( "mvm/mvm_warning.wav", Vector(0,0,0), -2, CHAN_VOICE, 1, 75, 0, 100 )
	PrintMessage(HUD_PRINTTALK, "Duty has won the round!!!")
	setupGamemode()
	GameVars.WinsToRestart = GameVars.WinsToRestart - 1

	end

	net.Start("update_cappoints_freedom")
	net.WriteInt(math.floor(GameVars.PointsFree),10)
net.Broadcast()

net.Start("update_cappoints_duty")
	net.WriteInt(math.floor(GameVars.PointsDuty),10)
net.Broadcast()

net.Start("update_propcount_freedom")
	net.WriteInt(math.floor(GameVars.PropsFreeCount),12)--Higher bitrate for larger propcounts even though it should theoretically never exceed 300
net.Broadcast()

net.Start("update_propcount_duty")
	net.WriteInt(math.floor(GameVars.PropsDutyCount),12)
net.Broadcast()

net.Start("update_weight_freedom")
	net.WriteInt(math.ceil(GameVars.WeightFreeCount/500),13)--Extra High bitrate for weight with weight compressed into half tons.
net.Broadcast()

net.Start("update_weight_duty")
	net.WriteInt(math.ceil(GameVars.WeightDutyCount/500),13)
net.Broadcast()

	--BroadcastLua( "print( 'Hello World!' )" ) --honestly I wonder if broadcast lua would have been less painful.

	--		net.WriteInt(math.floor(GameVars.PointsDuty),11)

		end

	end


end


hook.Add("Think", "SecondPrint", GamemodeThinkingThing)

hook.Add("PlayerGiveSWEP", "AdminOnlySWEPs", function( ply, class, wep )
	chatMessagePly(ply, "Only admins can spawn SWEPS." )
	return ply:IsAdmin()
end)

function updatePropcount() --I am ready to be roasted for creating this hellish function which does not distribute load over multiple seconds
	--I should also be burnent because this is called before and after duplication and because it isn't the most optimized
	local allplayers = player.GetAll( )

	--Special rules: Vehicles below 5 tons will not count towards weight limit, vehicles below 5 tons and 150 props will not count towards prop limit.

	GameVars.PlayerPropInfo = {} --Kept here to clean up disconnected player entries

	for i, ply in ipairs( player.GetAll() ) do --Reset each player table to 0

		GameVars.PlayerPropInfo[ply] = {}
		GameVars.PlayerPropInfo[ply][1] = 0 --Weight of props
		GameVars.PlayerPropInfo[ply][2] = 0 --Count of props

	end

	local proplist = ents.FindByClass( "prop_*" ) --Iterate through all props


	for id, ent in pairs( proplist ) do --Updates propcount and prop weight of each player
 --		owner = ent

		owner = ent:CPPIGetOwner()
		if IsValid(owner) then --If prop is owned by valid player
		--print(ent:CPPIGetOwner())

		GameVars.PlayerPropInfo[owner][2] = GameVars.PlayerPropInfo[owner][2] + 1 --Add 1 to propcount
		GameVars.PlayerPropInfo[owner][1] = GameVars.PlayerPropInfo[owner][1] + ent:GetPhysicsObject():GetMass()

		end

	end

	--Reset everything
	GameVars.PropsFreeCount = 0
	GameVars.PropsDutyCount = 0
	GameVars.WeightFreeCount = 0
	GameVars.WeightDutyCount = 0

	for i, ply in ipairs( player.GetAll() ) do

		searchteam = ply:Team()
	if GameVars.PlayerPropInfo[ply][1] > 5000 then --All vehicles above 5000 weight add to the prop count and tonnage no matter what

		if searchteam == 1 then
			GameVars.PropsFreeCount = GameVars.PropsFreeCount + GameVars.PlayerPropInfo[ply][2]
			GameVars.WeightFreeCount = GameVars.WeightFreeCount + GameVars.PlayerPropInfo[ply][1]		
		elseif searchteam == 2 then
			GameVars.PropsDutyCount = GameVars.PropsDutyCount + GameVars.PlayerPropInfo[ply][2]
			GameVars.WeightDutyCount = GameVars.WeightDutyCount + GameVars.PlayerPropInfo[ply][1]
		end

	else --Vehicles below wont add to weight but might add to prop count of above 150 props

		if GameVars.PlayerPropInfo[ply][2] > 150 then
			
			if searchteam == 1 then
				GameVars.PropsFreeCount = GameVars.PropsFreeCount + GameVars.PlayerPropInfo[ply][2]	
			elseif searchteam == 2 then
				GameVars.PropsDutyCount = GameVars.PropsDutyCount + GameVars.PlayerPropInfo[ply][2]
			end

		end

	end


	end

end


local function DisableNoclip( objPl )
	local searchteam = objPl:Team()

	if searchteam == 1 then
		inrange = ((objPl:GetPos():Distance( GameVars.FreedomSpawn )) < GameVars.SZRadius)
	elseif searchteam == 2 then
		inrange = ((objPl:GetPos():Distance( GameVars.DutySpawn )) < GameVars.SZRadius)
	else
		inrange = 1
	end

	return objPl:IsAdmin() or inrange

end
hook.Add("PlayerNoClip", "DisableNoclip", DisableNoclip)