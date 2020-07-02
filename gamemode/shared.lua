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
Add automatic commendation system for player performance(kills/ton, capture time, etc)
Anti AFK
Game music
Move weapon lists to their own folder for both client and sv
Add support for non spherical safezones *shrug*
Win sounds
Mapvoting
Add point name display




]]--



GameVars = {}
--Because for some reason files dont like to include propperly on servers :/
--went through 3 different include formats

--AddCSLuaFile( "baiknorii/gamemode/initializing/teamsetup.lua" )
--AddCSLuaFile( "baiknorii/gamemode/initializing/maplist_setup.lua" )
--AddCSLuaFile( "baiknorii/gamemode/playerandhud/hud.lua" )

--include( "baiknorii/gamemode/initializing/teamsetup.lua" )
--include( "baiknorii/gamemode/initializing/maplist_setup.lua" )

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






team.SetUp( 0, "Unasigned", Color( 255, 255, 255 ))
team.SetUp( 1, "Freedom", Color( 0, 255, 0 ))
team.SetUp( 2, "Duty", Color( 255, 0, 0 ))

teams = {}

teams[0] = {
	name = "Unasigned",
	color = Vector(1.0,1.0,0.0),
	weapons = {}
}
teams[1] = {
	name = "Freedom",
	color = Vector(0,1.0,0),
	weapons = {}
}
teams[2] = {
	name = "Duty",
	color = Vector(1.0,0,0),
	weapons = {}
}



function GM:Initialize()
	
	
	self.BaseClass.Initialize( self )
	if not CLIENT then
		timer.Simple( 1, function() setupGamemode() end )
		timer.Simple( 1, function() setupTeams() end )
	end
end


--Will create an error that can be ignored if playing SP, Low in priority to fix.
if not CLIENT then
util.AddNetworkString( "update_cappoints_freedom" )
util.AddNetworkString( "update_cappoints_duty" )

util.AddNetworkString( "update_propcount_freedom" )
util.AddNetworkString( "update_propcount_duty" )

util.AddNetworkString( "update_weight_freedom" )
util.AddNetworkString( "update_weight_duty" )
end

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


local MapName = game.GetMap()

GameVars.DutySpawn = Vector(0,0,0)
GameVars.FreedomSpawn = Vector(0,0,0)
GameVars.PointCount = 0
GameVars.PointEntities = {}
local PointPositions = {}--Most point information is temporary
local PointNames = {}

GameVars.WeightLimit = 120 --WeightLimit in metric tons (1000kg)
GameVars.CapMul = 0.015 --Feel free to override this in map setup
GameVars.PropCountMax = 300 --Feel free to override this in map setup

GameVars.SZRadius = 750 --Radius of safezones around spawns in units

if MapName == "gm_construct" then

	GameVars.FreedomSpawn = Vector(727,548,-143)
	GameVars.DutySpawn = Vector(-4970,-3434,251)
	GameVars.WeightLimit = 80
	GameVars.PropCountMax = 400
	GameVars.PointCount = 2
	GameVars.CapMul = 1 --Feel free to override this in map setup
	GameVars.SZRadius = 750
	PointPositions = {Vector(-2563,-1217,240),Vector(-2563,-417,240)}
	PointNames = {"Roof","Roof1"}

elseif MapName == "gm_baik_citycentre_v3" then
	GameVars.FreedomSpawn = Vector(5280, 4760, 256)
	GameVars.DutySpawn = Vector(-5280,-4760, 256)
	GameVars.WeightLimit = 80
	GameVars.PropCountMax = 300
	GameVars.PointCount = 2
	GameVars.CapMul = 0.02	
	GameVars.SZRadius = 4000
	PointPositions = {Vector(3400, -1928, 16),Vector(-3400, 1928, 16)}
	PointNames = {"Green Park","Red Park"}

elseif MapName == "gm_baik_coast_03" then
	GameVars.FreedomSpawn = Vector(-4678, -5985, 501)
	GameVars.DutySpawn = Vector(7312, 4011, 295)
	GameVars.WeightLimit = 120
	GameVars.PropCountMax = 400
	GameVars.PointCount = 2
	GameVars.CapMul = 0.025	
	GameVars.SZRadius = 5000
	PointPositions = {Vector(-5137, 3755, 256),Vector(-217, 8201, 62)}
	PointNames = {"Beach House","Docks"}
elseif MapName == "gm_baik_coast_03_night" then
	GameVars.FreedomSpawn = Vector(-4678, -5985, 501)
	GameVars.DutySpawn = Vector(7312, 4011, 295)
	GameVars.WeightLimit = 120
	GameVars.PropCountMax = 400
	GameVars.PointCount = 2
	GameVars.CapMul = 0.025	
	GameVars.SZRadius = 5000
	PointPositions = {Vector(-5137, 3755, 256),Vector(-217, 8201, 62)}
	PointNames = {"Beach House","Docks"}
elseif MapName == "gm_baik_construct_draft1" then
	GameVars.FreedomSpawn = Vector(-3038, 3038, 17)
	GameVars.DutySpawn = Vector(3038, -3038, 17)
	GameVars.WeightLimit = 60
	GameVars.PropCountMax = 250
	GameVars.PointCount = 3
	GameVars.CapMul = 0.02	
	GameVars.SZRadius = 3000
	PointPositions = {Vector(2802, 3016, 4),Vector(0,0,424),Vector(-2802, -3016, 4)}
	PointNames = {"Parking Lot A","Parking Garage","Parking Lot B"}
elseif MapName == "gm_de_port_opened_v2" then --V1 not included
	GameVars.FreedomSpawn = Vector(-1920, 3944, 513)
	GameVars.DutySpawn = Vector(2245, -3674, 777)
	GameVars.WeightLimit = 40
	GameVars.PropCountMax = 200
	GameVars.PointCount = 3
	GameVars.CapMul = 0.02	
	GameVars.SZRadius = 3000
	PointPositions = {Vector(-1022, 137, 512),Vector(1119, 190, 642),Vector(2212, 1339, 512)}
	PointNames = {"Warehouse","Oil","Coast"}
elseif MapName == "gm_emp_arid" then
	GameVars.FreedomSpawn = Vector(13127,-11026,513)
	GameVars.DutySpawn = Vector(-11004, 12164, 537)
	GameVars.WeightLimit = 120
	GameVars.PropCountMax = 400
	GameVars.PointCount = 3
	GameVars.CapMul = 0.02	
	GameVars.SZRadius = 5000
	PointPositions = {Vector(-1065, -12302, 512),Vector(-604, -874, 359),Vector(-4341, 6071, 472)}
	PointNames = {"Bunker","Bridge","Small Hill"}
elseif MapName == "gm_emp_manticore" then
	GameVars.FreedomSpawn = Vector(-6670, -3958, 1760)
	GameVars.DutySpawn = Vector(10288, 2047, 1761)
	GameVars.WeightLimit = 80
	GameVars.PropCountMax = 300
	GameVars.PointCount = 3
	GameVars.CapMul = 0.02	
	GameVars.SZRadius = 5000
	PointPositions = {Vector(3897, -4170, 1744),Vector(12,251,2048),Vector(-3988, 4155, 1744)}
	PointNames = {"Brick Factory","Bridge","Office"}
elseif MapName == "gm_emp_midbridge" then
	GameVars.FreedomSpawn = Vector(632, -9715, 2081)
	GameVars.DutySpawn = Vector(-628, 9755, 2081)
	GameVars.WeightLimit = 120
	GameVars.PropCountMax = 400
	GameVars.PointCount = 4
	GameVars.CapMul = 0.01	
	GameVars.SZRadius = 8000
	PointPositions = {Vector(7931, -3408, 32),Vector(-7909, 3435, 32),Vector(0,0,2048),Vector(0,0,-255)}
	PointNames = {"A Ruins","B Ruins","Hell aBridged","Under the Bridge"}
elseif MapName == "gm_emp_palmbay" then
	GameVars.FreedomSpawn = Vector(-6577, -8994, -2331)
	GameVars.DutySpawn = Vector(8857, 10746, -2331)
	GameVars.WeightLimit = 40
	GameVars.PropCountMax = 200
	GameVars.PointCount = 3
	GameVars.CapMul = 0.02	
	GameVars.SZRadius = 5000
	PointPositions = {Vector(-7173, 11422, -2884),Vector(313, -499, -2953),Vector(3801, -9546, -2575)}
	PointNames = {"Island","Beach House","Grassland"}
elseif MapName == "gm_greenchoke" then
	GameVars.FreedomSpawn = Vector(-9156, 10610, 1038)
	GameVars.DutySpawn = Vector(9055, -10722, 1038)
	GameVars.WeightLimit = 80
	GameVars.PropCountMax = 250
	GameVars.PointCount = 5
	GameVars.CapMul = 0.01	
	GameVars.SZRadius = 5000
	PointPositions = {Vector(6295, 2018, 1043),Vector(-5961, 2032, 929),Vector(495, -1037, 1184),Vector(-85, 3492, 910),Vector(175, -5296, 844)}
	PointNames = {"Mountain Outpost","Town Outpost","Bridge","Island A","Island B"}
end

--Do not edit below here

GameVars.SZRadius = math.Clamp(GameVars.SZRadius,200,9540)

function spawnPoint(pointnum)

	local ent = ents.Create( "baiknor_controlpoint" )
	
	if ( IsValid( ent ) ) then

		ent:SetPos( PointPositions[pointnum] )
		ent:Spawn()
		ent.PointID = pointnum --Adjusted by the spawn command, this adjusts the output signal.
		ent.PointName = PointNames[pointnum] or "Unnamed Point"
		GameVars.PointEntities[pointnum] = ent
	end


end

--Swaps spawns around so the teams start at the propper spawns
local storespawn = GameVars.FreedomSpawn
GameVars.FreedomSpawn = GameVars.DutySpawn
GameVars.DutySpawn = storespawn

function setupGamemode()

	game.CleanUpMap( true )

local	storespawn = GameVars.FreedomSpawn
	GameVars.FreedomSpawn = GameVars.DutySpawn
	GameVars.DutySpawn = storespawn

	for i, ply in ipairs( player.GetAll() ) do --kills every player to ready respawns
		ply:Kill()
	end

	GameVars.PointsFree = 300
	GameVars.PointsDuty = 300
	GameVars.PropsFreeCount = 0
	GameVars.PropsDutyCount = 0

	for i=1,GameVars.PointCount do 
		spawnPoint(i)
	end 

	--Creates 2 circular safezone indicators
	local ent = ents.Create( "baiknor_safezonemarker" )
	
	if ( IsValid( ent ) ) then

		ent:SetPos( GameVars.FreedomSpawn )
		ent:Spawn()
		ent.Scale = GameVars.SZRadius*2
		ent.PointID = pointnum --Adjusted by the spawn command, this adjusts the output signal.
	end

	local ent = ents.Create( "baiknor_safezonemarker" )

	if ( IsValid( ent ) ) then

		ent:SetPos( GameVars.DutySpawn )
		ent:Spawn()
		ent.Scale = GameVars.SZRadius*2
		ent.PointID = pointnum --Adjusted by the spawn command, this adjusts the output signal.
	end


end