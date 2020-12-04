GM.Name 	= "The Proving Ground"
GM.Author 	= "RDC"
GM.Email 	= "N/A"
GM.Website 	= "N/A"



--[[
V1.5

<--- Current Maplist --->

Open Maps
gm_emp_palmbay
gm_emp_midbridge
gm_greenchoke
gm_emp_arid
gm_baik_coast_03
gm_baik_coast_03_night
gm_baik_frontline -
gm_baik_trenches -
gm_baik_valley_split - 
gm_diprip_village -
gm_emp_bush -
gm_greenland -
gm_islandrain_v3 -
gm_pacific_island_a3 -
gm_toysoldiers

Urban Maps
gm_emp_manticore
gm_baik_stalingrad -
gm_bigcity_improved -
gm_diprip_refinery -
gm_emp_commandergrad -
gm_freedom_city -
gm_yanov -
gm_baik_construct_draft1
gm_baik_citycentre_v3
gm_de_port_opened_v2

*Planned*

Game music
Propperly sort functions by clientside and serverside

Re-arm/Repair Stations -- MEH
Find out why includes were screwed --IDK
Add support for non spherical safezones *shrug*
Fix safezone scaling
Move weapon lists to their own folder for both client and sv - Only if i can get includes to work on total nerdery
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
GameVars.PropsGreenCount = 0
GameVars.PropsRedCount = 0
GameVars.WeightGreenCount = 0
GameVars.WeightRedCount = 0
GameVars.DupeWaitTime = {} --Used to keep track of player dupe spawn delays
GameVars.DupeProps = {} --Temporarily used to store the props of a dupe. Used for dupe cooldown calculation. This had to be done to allow players to despawn dupes.
GameVars.GameType = math.Rand(0,1) --Current game type. 1 = control points, 2 = KOTH, 3 = Deathmatch, 4 = CTF

if GameVars.GameType < 0.2 then
	GameVars.GameType = 2
elseif GameVars.GameType < 0.2 then
	GameVars.GameType = 3
else
	GameVars.GameType = 1
end



--GameVars.GameType = 3
--GameVars.DeathTickets = 0 --Whether to subtract tickets on death from each team.

GameVars.GameThinkTick = 0 --Every 30 iterations the game thinks
GameVars.Searchtick = 0 --Every 100 normal iterations do an entity search

GameVars.PlayerSafezoneTime = {} --Used to allow players to have spawn protection after leaving the SZ

GameVars.SeatEntities = {} --Also holds seat position and velocity information updated on gamethink.
GameVars.TimeVars = {}
GameVars.VoteMapList = {"Map1", "Map2", "Map3", "Map4"} --Populated at time of mapvoting
GameVars.PlayerScoreTrackers = {} -- Holds all of the players in this array,
--[1]Kills, [2]Kills/Ton, [3]Objective kills, [4]Captures, [99] Boolean RTV, [100] Boolean Votescramble

team.SetUp( 0, "Unasigned", Color( 255, 255, 255 ))
team.SetUp( 1, "The Green Terror", Color( 0, 255, 0 ))
team.SetUp( 2, "The Red Menace", Color( 255, 0, 0 ))

teams = {}

teams[0] = {
	name = "Unasigned",
	color = Vector(1.0,1.0,0.0),
	weapons = {}
}
teams[1] = {
	name = "The Green Terror",
	color = Vector(0,1.0,0),
	weapons = {}
}
teams[2] = {
	name = "The Red Menace",
	color = Vector(1.0,0,0),
	weapons = {}
}



function GM:Initialize()
	
	
	self.BaseClass.Initialize( self )
	if not CLIENT then
		timer.Simple( 3, function() 
			setupGamemode() 
			--For server owners who never set these.

	RunConsoleCommand( "sbox_godmode", "0" ) --For use in sandbox servers that enable god mode by default.
	RunConsoleCommand( "sbox_playershurtplayers", "1" ) --For use in sandbox servers that enable god mode by default.

	RunConsoleCommand( "sv_alltalk", "0" ) --Team voice chat, makes voice chat useful.

	RunConsoleCommand( "mp_falldamage", "1" ) --No more 10 fall damage from falling from space.

	RunConsoleCommand( "sbox_maxprops", "200" ) --Optimize your vehicles, P L E A S E. Your team will HATE you otherwise.
	RunConsoleCommand( "wire_holograms_max", "150" ) --Some kind person spawned a 1000 holo vehicle. I was not amused at my 3 frames. Games should not be won by frying your opponent's computer.

		end )
	end
end

if not CLIENT then

util.AddNetworkString( "chatmessage" )

util.AddNetworkString( "update_cappoints_green" )
util.AddNetworkString( "update_cappoints_red" )

util.AddNetworkString( "update_propcount_green" )
util.AddNetworkString( "update_propcount_red" )

util.AddNetworkString( "update_weight_green" )
util.AddNetworkString( "update_weight_red" )
end

function GamemodeThinkingThing()

	GameVars.GameThinkTick = GameVars.GameThinkTick + 1

	if GameVars.GameThinkTick >= 5 then
		GameVars.GameThinkTick = 0

		if not CLIENT then

			GameVars.Searchtick = GameVars.Searchtick + 1

			if GameVars.Searchtick >= 100 then
				GameVars.Searchtick = 0
				print("[TPG] Updating Propcount")
				updatePropcount(0)
			end

			--pl:GetMoveType()


			local allplayers = player.GetAll()
		
			for i, ply in ipairs( allplayers ) do --Reset each player table to 0

				ply:SetColor( Color(255, 255, 255, 255) ) --Imagine having players make themselves invisible.
				ply:SetMaterial("") --Some players used an invisible material, no fun for you.

				local searchteam = ply:Team()
				if searchteam == 1 then
					inrange = ((ply:GetPos():Distance( GameVars.FreedomSpawn )) < GameVars.SZRadius)
					inenemyrange = ((ply:GetPos():Distance( GameVars.DutySpawn )) < GameVars.SZRadius)
				elseif searchteam == 2 then
					inrange = ((ply:GetPos():Distance( GameVars.DutySpawn )) < GameVars.SZRadius)
					inenemyrange = ((ply:GetPos():Distance( GameVars.FreedomSpawn )) < GameVars.SZRadius)
				else
					inrange = 1
					inenemyrange = 0
				end


				if not ply:GetVehicle():IsValid() then

					if ply:WaterLevel() >= 2 then

						ply:Kill()
						chatMessagePly(ply, "[TPG] HALP I CANNOT SWIM!!!" , Color( 255, 0, 0 ) )
	
						if searchteam == 1 then
	
							ply:SetPos( GameVars.FreedomSpawn )
					
						elseif searchteam == 2 then
					
							ply:SetPos( GameVars.DutySpawn )
						
						end

					end

				end

				
			if not inrange then
				--ply:GodDisable()

		local SZT = GameVars.PlayerSafezoneTime[ply] or 0
				if SZT > 0 then
					
					if SZT == 5 then --Truly stops people from flinging themselves outside SZ
						ply:SetVelocity(-ply:GetVelocity()) --Setting player velocity is wierd
					end

						GameVars.PlayerSafezoneTime[ply] = SZT - 0.1
					if GameVars.PlayerSafezoneTime[ply] <= 0 then
						GameVars.PlayerSafezoneTime[ply] = 0 --Value when SP is off
						chatMessagePly(ply, "[TPG] Your spawn protection wore off. SpawnMenu is disabled. You can now do damage." , Color( 0, 255, 255 ) )
						ply:GodDisable()
					end

				end

				if ply:GetMoveType() == MOVETYPE_NOCLIP and (not ply:IsAdmin()) and (not ply:InVehicle()) then --Kill non admins out of noclip, stops people from launching themselves out of SZ and rocketing people
					ply:Kill()
					chatMessagePly(ply, "[TPG] Cannot noclip outside spawn." , Color( 255, 0, 0 ) )
				end

				if inenemyrange then --Stay away from enemy spawn.
					ply:Kill()
					chatMessagePly(ply, "[TPG] Stay away from enemy spawn." , Color( 255, 0, 0 ) )

					if searchteam == 1 then

						ply:SetPos( GameVars.FreedomSpawn )
				
					elseif searchteam == 2 then
				
						ply:SetPos( GameVars.DutySpawn )
					
					end
					
				end

			else
				ply:GodEnable()
				GameVars.PlayerSafezoneTime[ply] = 5
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

			local allplayers = player.GetAll()
		
				for i, ply in ipairs( player.GetAll() ) do --Reset each player table to 0

					if ply:Team() == 2 then --Plays local sound for each player
						ply:SendLua( "LocalPlayer():EmitSound( 'mvm/mvm_tele_activate.wav' )" )
					else
						ply:SendLua( "LocalPlayer():EmitSound( 'mvm/mvm_warning.wav' )" )
					end
					
					GameVars.DupeWaitTime[ply] = 0

				end

			chatMessageGlobal( "The Red Menace has won the round!!!" , Color( 255, 0, 0 ) )
			setupGamemode()
			GameVars.WinsToRestart = GameVars.WinsToRestart - 1

			commendPlayers()
			
			if GameVars.WinsToRestart <= 0 then
			populateMapChoices()
			

			for i, ply in ipairs( player.GetAll() ) do
				ply:ConCommand( "tpg_votemap_menu" )
			end

			chatMessageGlobal( "[TPG] 20 seconds to vote for the next map!" , Color( 0, 255, 255 ) )
			timer.Simple( 10, function() chatMessageGlobal( "[TPG] 10 seconds to vote for the next map!" , Color( 0, 255, 255 ) ) end )
			timer.Simple( 15, function() chatMessageGlobal( "[TPG] 5 seconds to vote for the next map!" , Color( 255, 0, 0 ) ) end )
			timer.Simple( 21, function() tallyVotes() end ) --1 extra second because people are stupid
			end

		elseif GameVars.PointsDuty < 0 then

			local allplayers = player.GetAll()
		
			for i, ply in ipairs( player.GetAll() ) do --Reset each player table to 0
			--	Entity:EmitSound( string soundName, number soundLevel = 75, number pitchPercent = 100, number volume = 1, number channel = CHAN_AUTO, CHAN_WEAPON for weapons )
				
				if ply:Team() == 1 then --Plays local sound for each player
					ply:SendLua( "LocalPlayer():EmitSound( 'mvm/mvm_tele_activate.wav' )" )
				else
					ply:SendLua( "LocalPlayer():EmitSound( 'mvm/mvm_warning.wav' )" )
				end

				GameVars.DupeWaitTime[ply] = 0

			end

			chatMessageGlobal( "The Green Terror has won the round!!!" , Color( 255, 0, 0 ) )
			setupGamemode()
			GameVars.WinsToRestart = GameVars.WinsToRestart - 1

			commendPlayers()

			if GameVars.WinsToRestart <= 0 then
			populateMapChoices()
			

			for i, ply in ipairs( player.GetAll() ) do
				ply:ConCommand( "tpg_votemap_menu" )
			end

			chatMessageGlobal( "[TPG] 20 seconds to vote for the next map!" , Color( 0, 255, 255 ) )
			timer.Simple( 10, function() chatMessageGlobal( "[TPG] 10 seconds to vote for the next map!" , Color( 0, 255, 255 ) ) end )
			timer.Simple( 15, function() chatMessageGlobal( "[TPG] 5 seconds to vote for the next map!" , Color( 255, 0, 0 ) ) end )
			timer.Simple( 21, function() tallyVotes() end ) --1 extra second because people are stupid
			end

		end

		net.Start("update_cappoints_green")
			net.WriteInt(math.floor(GameVars.PointsFree),10)
		net.Broadcast()

		net.Start("update_cappoints_red")
			net.WriteInt(math.floor(GameVars.PointsDuty),10)
		net.Broadcast()

		net.Start("update_propcount_green")
			net.WriteInt(math.floor(GameVars.PropsGreenCount),12)--Higher bitrate for larger propcounts even though it should theoretically never exceed 300
		net.Broadcast()

		net.Start("update_propcount_red")
			net.WriteInt(math.floor(GameVars.PropsRedCount),12)
		net.Broadcast()

		net.Start("update_weight_green")
			net.WriteInt(math.ceil(GameVars.WeightGreenCount/500),13)--Extra High bitrate for weight with weight compressed into half tons.
		net.Broadcast()

		net.Start("update_weight_red")
			net.WriteInt(math.ceil(GameVars.WeightRedCount/500),13)
		net.Broadcast()

		end

		--Positional inaccuracy did this, blame it not me

		GameVars.TimeVars["LTime"] = GameVars.TimeVars["Time"] or 0
	
		local deltatime = math.Max(GameVars.TimeVars["Time"] - GameVars.TimeVars["LTime"],0.01)
	
		for id = 1, table.Count( GameVars.SeatEntities ) do
			if	IsValid( GameVars.SeatEntities[id]["Ent"] ) then
				calculateForceLimits(id,deltatime)
			end
		end

	end

	--Rapid calculations begin here
	GameVars.TimeVars["Time"] = CurTime()


end


hook.Add("Think", "SecondPrint", GamemodeThinkingThing)

hook.Add("PlayerGiveSWEP", "AdminOnlySWEPs", function( ply, class, wep )
	chatMessagePly(ply, "Only admins can spawn SWEPS." , Color( 255, 0, 0 ) )
	return ply:IsAdmin()
end)

function updatePropcount(ContextCalled)
	--I am ready to be roasted for creating this hellish function which does not distribute load over multiple seconds
	--I should also be burnent because this is called before and after duplication and because it isn't the most optimized
	local allplayers = player.GetAll( )
	local callingcontext = ContextCalled or 0 --0 is called by updatecount function, 1 is called by dupefinished
	--Used to exclude stationary props from team weight addition

	--Special rules: Vehicles below 5 tons will not count towards weight limit, vehicles below 5 tons and 150 props will not count towards prop limit.

	GameVars.PlayerPropInfo = {} --Kept here to clean up disconnected player entries

	for i, ply in ipairs( player.GetAll() ) do --Reset each player table to 0

		GameVars.PlayerPropInfo[ply] = {}
		GameVars.PlayerPropInfo[ply][1] = 0 --Weight of props
		GameVars.PlayerPropInfo[ply][2] = 0 --Count of props

	end

	local proplist = ents.FindByClass( "prop_vehicle_prisoner_pod" ) 

	for id, ent in pairs( proplist ) do --Updates valid seats for a player, also presets force limit information
		GameVars.SeatEntities[id] = {}
		GameVars.SeatEntities[id]["Ent"] = ent	
	end


	local proplist = ents.FindByClass( "prop_*" ) --Iterate through all props

	for id, ent in pairs( proplist ) do --Updates propcount and prop weight of each player
 --		owner = ent

		owner = ent:CPPIGetOwner()
		if IsValid(owner) then --If prop is owned by valid player
		--print(ent:CPPIGetOwner())

		GameVars.PlayerPropInfo[owner][2] = GameVars.PlayerPropInfo[owner][2] + 1 --Add 1 to propcount
		local physobj = ent:GetPhysicsObject()
		if callingcontext == 0 then

--			if physobj:IsMotionEnabled() then --Will exclude the weight of things like stationary bunkers from team weight limit.
				GameVars.PlayerPropInfo[owner][1] = GameVars.PlayerPropInfo[owner][1] + physobj:GetMass()
--			end
			
		else

			GameVars.PlayerPropInfo[owner][1] = GameVars.PlayerPropInfo[owner][1] + physobj:GetMass()
		
		end

		end

	end

	

	--Reset everything
	GameVars.PropsGreenCount = 0
	GameVars.PropsRedCount = 0
	GameVars.WeightGreenCount = 0
	GameVars.WeightRedCount = 0

	for i, ply in ipairs( player.GetAll() ) do

		searchteam = ply:Team()
	if GameVars.PlayerPropInfo[ply][1] > 5000 then --All vehicles above 5000 weight add to the prop count and tonnage no matter what

		if searchteam == 1 then
			GameVars.PropsGreenCount = GameVars.PropsGreenCount + GameVars.PlayerPropInfo[ply][2]
			GameVars.WeightGreenCount = GameVars.WeightGreenCount + GameVars.PlayerPropInfo[ply][1]		
		elseif searchteam == 2 then
			GameVars.PropsRedCount = GameVars.PropsRedCount + GameVars.PlayerPropInfo[ply][2]
			GameVars.WeightRedCount = GameVars.WeightRedCount + GameVars.PlayerPropInfo[ply][1]
		end

	else --Vehicles below wont add to weight but might add to prop count of above 150 props

		if GameVars.PlayerPropInfo[ply][2] > 150 then
			
			if searchteam == 1 then
				GameVars.PropsGreenCount = GameVars.PropsGreenCount + GameVars.PlayerPropInfo[ply][2]	
			elseif searchteam == 2 then
				GameVars.PropsRedCount = GameVars.PropsRedCount + GameVars.PlayerPropInfo[ply][2]
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
GameVars.PointPositions = {}--Most point information is temporary
GameVars.PointNames = {}

GameVars.WeightLimit = 100 --WeightLimit in metric tons (1000kg)
GameVars.CapMul = 0.015 --Feel free to override this in map setup
GameVars.PropCountMax = 300 --Feel free to override this in map setup

GameVars.SZRadius = 750 --Radius of safezones around spawns in units


--I Could use tables buuuuuuuuuuut meh.
--Brace yourself for the mother of all if statements.
--GameVars.GameType
if GameVars.GameType == 1 then
	if MapName == "gm_construct" then

		GameVars.FreedomSpawn = Vector(727,548,-143)
		GameVars.DutySpawn = Vector(-4970,-3434,251)
		GameVars.WeightLimit = 120
		GameVars.PropCountMax = 200
		GameVars.PointCount = 2
		GameVars.CapMul = 3 --Feel free to override this in map setup
		GameVars.SZRadius = 750
		GameVars.PointPositions = {Vector(-2563,-1217,240),Vector(-2563,-417,240)}
		GameVars.PointNames = {"Roof","Roof1"}
		GameVars.WinsToRestart = 5
		
	elseif MapName == "gm_baik_citycentre_v3" then
		GameVars.FreedomSpawn = Vector(5280, 4760, 256)
		GameVars.DutySpawn = Vector(-5280,-4760, 256)
		GameVars.WeightLimit = 60
		GameVars.PropCountMax = 150
		GameVars.PointCount = 2
		GameVars.CapMul = 0.02	
		GameVars.SZRadius = 750
		GameVars.PointPositions = {Vector(3400, -1928, 16),Vector(-3400, 1928, 16)}
		GameVars.PointNames = {"Green Park","Red Park"}

	elseif MapName == "gm_baik_coast_03" then
		GameVars.FreedomSpawn = Vector(-4678, -5985, 501)
		GameVars.DutySpawn = Vector(7312, 4011, 295)
		GameVars.WeightLimit = 120
		GameVars.PropCountMax = 300
		GameVars.PointCount = 2
		GameVars.CapMul = 0.025	
		GameVars.SZRadius = 750
		GameVars.PointPositions = {Vector(-5137, 3755, 256),Vector(-217, 8201, 62)}
		GameVars.PointNames = {"Beach House","Docks"}
	elseif MapName == "gm_baik_construct_draft1" then
		GameVars.FreedomSpawn = Vector(-3038, 3038, 17)
		GameVars.DutySpawn = Vector(3038, -3038, 17)
		GameVars.WeightLimit = 40
		GameVars.PropCountMax = 150
		GameVars.PointCount = 3
		GameVars.CapMul = 0.02	
		GameVars.SZRadius = 750
		GameVars.PointPositions = {Vector(2802, 3016, 4),Vector(0,0,424),Vector(-2802, -3016, 4)}
		GameVars.PointNames = {"Parking Lot A","Parking Garage","Parking Lot B"}
	elseif MapName == "gm_de_port_opened_v2" then --V1 not included
		GameVars.FreedomSpawn = Vector(-1920, 3944, 513)
		GameVars.DutySpawn = Vector(2245, -3674, 777)
		GameVars.WeightLimit = 40
		GameVars.PropCountMax = 150
		GameVars.PointCount = 3
		GameVars.CapMul = 0.02	
		GameVars.SZRadius = 750
		GameVars.PointPositions = {Vector(-1022, 137, 512),Vector(1119, 190, 642),Vector(2212, 1339, 512)}
		GameVars.PointNames = {"Warehouse","Oil","Coast"}
	elseif MapName == "gm_emp_arid" then
		GameVars.FreedomSpawn = Vector(13127,-11026,513)
		GameVars.DutySpawn = Vector(-11004, 12164, 537)
		GameVars.WeightLimit = 120
		GameVars.PropCountMax = 300
		GameVars.PointCount = 3
		GameVars.CapMul = 0.02	
		GameVars.SZRadius = 750
		GameVars.PointPositions = {Vector(-1065, -12302, 512),Vector(-604, -874, 359),Vector(-4341, 6071, 472)}
		GameVars.PointNames = {"Bunker","Bridge","Small Hill"}
	elseif MapName == "gm_emp_manticore" then
		GameVars.FreedomSpawn = Vector(-6670, -3958, 1760)
		GameVars.DutySpawn = Vector(10288, 2047, 1761)
		GameVars.WeightLimit = 80
		GameVars.PropCountMax = 250
		GameVars.PointCount = 3
		GameVars.CapMul = 0.02	
		GameVars.SZRadius = 750
		GameVars.PointPositions = {Vector(3897, -4170, 1744),Vector(12,251,2048),Vector(-3988, 4155, 1744)}
		GameVars.PointNames = {"Brick Factory","Bridge","Office"}
	elseif MapName == "gm_emp_midbridge" then
		GameVars.FreedomSpawn = Vector(632, -9715, 2081)
		GameVars.DutySpawn = Vector(-628, 9755, 2081)
		GameVars.WeightLimit = 160
		GameVars.PropCountMax = 300
		GameVars.PointCount = 4
		GameVars.CapMul = 0.01	
		GameVars.SZRadius = 750
		GameVars.PointPositions = {Vector(7931, -3408, 32),Vector(-7909, 3435, 32),Vector(0,0,2048),Vector(0,0,-255)}
		GameVars.PointNames = {"A Ruins","B Ruins","Hell aBridged","Under the Bridge"}
	elseif MapName == "gm_emp_palmbay" then
		GameVars.FreedomSpawn = Vector(-6577, -8994, -2331)
		GameVars.DutySpawn = Vector(8857, 10746, -2331)
		GameVars.WeightLimit = 80
		GameVars.PropCountMax = 250
		GameVars.PointCount = 3
		GameVars.CapMul = 0.02	
		GameVars.SZRadius = 750
		GameVars.PointPositions = {Vector(-7173, 11422, -2884),Vector(313, -499, -2953),Vector(3801, -9546, -2575)}
		GameVars.PointNames = {"Island","Beach House","Grassland"}
	elseif MapName == "gm_greenchoke" then
		GameVars.FreedomSpawn = Vector(-9156, 10610, 1038)
		GameVars.DutySpawn = Vector(9055, -10722, 1038)
		GameVars.WeightLimit = 100
		GameVars.PropCountMax = 250
		GameVars.PointCount = 5
		GameVars.CapMul = 0.01	
		GameVars.SZRadius = 750
		GameVars.PointPositions = {Vector(6295, 2018, 1043),Vector(-5961, 2032, 929),Vector(495, -1037, 1184),Vector(-85, 3492, 910),Vector(175, -5296, 844)}
		GameVars.PointNames = {"Mountain Outpost","Town Outpost","Bridge","Island A","Island B"}
	elseif MapName == "gm_baik_frontline" then
		GameVars.FreedomSpawn = Vector(-9284, 357, -20)
		GameVars.DutySpawn = Vector(6748, 485, -21)
		GameVars.WeightLimit = 60
		GameVars.PropCountMax = 200
		GameVars.PointCount = 3
		GameVars.CapMul = 0.02	
		GameVars.SZRadius = 750
		GameVars.PointPositions = {Vector(1718, 30, -45),Vector(-1260, 409, 79),Vector(-4932, 142, -49)}
		GameVars.PointNames = {"No Mans Land A","Fort Center","No Mans Land A"}
	elseif MapName == "gm_baik_stalingrad" then
		GameVars.FreedomSpawn = Vector(-1360, -8207, 1)
		GameVars.DutySpawn = Vector(-1428, 2101, 1)
		GameVars.WeightLimit = 80
		GameVars.PropCountMax = 250
		GameVars.PointCount = 3
		GameVars.CapMul = 0.02	
		GameVars.SZRadius = 750
		GameVars.PointPositions = {Vector(-7549, -2147, 0),Vector(-2254, -2538, -56),Vector(1516, -2438, 448)}
		GameVars.PointNames = {"Railroad","Factory Ruins","Office Ruins"}
	elseif MapName == "gm_baik_trenches" then
		GameVars.FreedomSpawn = Vector(3852,0,102)
		GameVars.DutySpawn = Vector(-3852,0,102)
		GameVars.WeightLimit = 60
		GameVars.PropCountMax = 200
		GameVars.PointCount = 3
		GameVars.CapMul = 0.02	
		GameVars.SZRadius = 750
		GameVars.PointPositions = {Vector(-2874, 2570, 201),Vector(0,0,3),Vector(2647, -2775, 194)}
		GameVars.PointNames = {"Corner Hill A","No-Mans Land","Corner Hill A"}
	elseif MapName == "gm_baik_valley_split" then
		GameVars.FreedomSpawn = Vector(-6285, -5632, 7)
		GameVars.DutySpawn = Vector(6193, 723, 8)
		GameVars.WeightLimit = 80
		GameVars.PropCountMax = 200
		GameVars.PointCount = 3
		GameVars.CapMul = 0.02	
		GameVars.SZRadius = 750
		GameVars.PointPositions = {Vector(6011, -5034, 3),Vector(0,-2559, 2),Vector(-5958,-95,3)}
		GameVars.PointNames = {"Red Camp","The Center","Green Camp"}
	elseif MapName == "gm_bigcity_improved" then
		GameVars.FreedomSpawn = Vector(-10163,11922,-11136)
		GameVars.DutySpawn = Vector(11937,-7932,-11136)
		GameVars.WeightLimit = 120
		GameVars.PropCountMax = 300
		GameVars.PointCount = 2
		GameVars.CapMul = 0.025	
		GameVars.SZRadius = 750
		GameVars.PointPositions = {Vector(-983,-949,-11140),Vector(5060,6094,-11144)}
		GameVars.PointNames = {"Park","Sludge"}
	elseif MapName == "gm_diprip_refinery" then
		GameVars.FreedomSpawn = Vector(-7754, 6833, 161)
		GameVars.DutySpawn = Vector(4141, -5520, 320)
		GameVars.WeightLimit = 120
		GameVars.PropCountMax = 300
		GameVars.PointCount = 3
		GameVars.CapMul = 0.02
		GameVars.SZRadius = 750
		GameVars.PointPositions = {Vector(5874, 6349, 320),Vector(128,128,480),Vector(-5389,-5864, 320)}
		GameVars.PointNames = {"Rail tunnels","Shipping and Handling","Dock Cranes"}
	elseif MapName == "gm_diprip_village" then
		GameVars.FreedomSpawn = Vector(5974, 3971, 7)
		GameVars.DutySpawn = Vector(-8421, -11827, 185)
		GameVars.WeightLimit = 60
		GameVars.PropCountMax = 200
		GameVars.PointCount = 3
		GameVars.CapMul = 0.02
		GameVars.SZRadius = 750
		GameVars.PointPositions = {Vector(-9910, -331, 32),Vector(-449, -3181, 48),Vector(5456, -10558, -32)}
		GameVars.PointNames = {"Sawmill","Coal Mine","Silos"}
	elseif MapName == "gm_emp_bush" then
		GameVars.FreedomSpawn = Vector(-11392, -11104, -3333)
		GameVars.DutySpawn = Vector(10060, 11788, -3327)
		GameVars.WeightLimit = 160
		GameVars.PropCountMax = 300
		GameVars.PointCount = 3
		GameVars.CapMul = 0.02
		GameVars.SZRadius = 750
		GameVars.PointPositions = {Vector(-10196, 9406, -3320),Vector(72, -286, -3449),Vector(8196, -8603, -2994)}
		GameVars.PointNames = {"Green Field","Fort Center","Corner Hill"}
	elseif MapName == "gm_emp_commandergrad" then
		GameVars.FreedomSpawn = Vector(3216, 12558, 9)
		GameVars.DutySpawn = Vector(-7078, -13608, 9)
		GameVars.WeightLimit = 120
		GameVars.PropCountMax = 250
		GameVars.PointCount = 3
		GameVars.CapMul = 0.02
		GameVars.SZRadius = 750
		GameVars.PointPositions = {Vector(7137, 4178, 1094),Vector(-1574, -714, 624),Vector(-10160, -4701, 1112)}
		GameVars.PointNames = {"Mansion","City Center","Haunted House"}
	elseif MapName == "gm_freedom_city" then
		GameVars.FreedomSpawn = Vector(-10769, 3232, 34)
		GameVars.DutySpawn = Vector(6398,1988,464)
		GameVars.WeightLimit = 100
		GameVars.PropCountMax = 300
		GameVars.PointCount = 3
		GameVars.CapMul = 0.02
		GameVars.SZRadius = 750
		GameVars.PointPositions = {Vector(1943, -9289, 21),Vector(-9000, -3721, 33),Vector(-2534, -434, 21)} 
		GameVars.PointNames = {"Trainstop","City Trainstop","The Crossroad"}
	elseif MapName == "gm_greenland" then
		GameVars.FreedomSpawn = Vector(-3461, -10270, 2)
		GameVars.DutySpawn = Vector(3461, 10270, 2)
		GameVars.WeightLimit = 120
		GameVars.PropCountMax = 300
		GameVars.PointCount = 3
		GameVars.CapMul = 0.02
		GameVars.SZRadius = 750
		GameVars.PointPositions = {Vector(-3429, 8739, 183),Vector(78,2053,576),Vector(3694, -5634, 192)} 
		GameVars.PointNames = {"Oil Well","Railroad Tracks","The Forest"}
	elseif MapName == "gm_islandrain_v3" then
		GameVars.FreedomSpawn = Vector(-3831, 10741, -1200)
		GameVars.DutySpawn = Vector(8391, -9920, -1175)
		GameVars.WeightLimit = 80
		GameVars.PropCountMax = 200
		GameVars.PointCount = 3
		GameVars.CapMul = 0.02
		GameVars.SZRadius = 750
		GameVars.PointPositions = {Vector(-10637, -10705, -1161),Vector(6302, 4246, 1122),Vector(9443, 9233, -981)} 
		GameVars.PointNames = {"Beach","The Mountain","Waterside Cliff"}
	elseif MapName == "gm_pacific_island_a3" then
		GameVars.FreedomSpawn = Vector(13995,8546,-10539)
		GameVars.DutySpawn = Vector(636,13393,-10612)
		GameVars.WeightLimit = 60
		GameVars.PropCountMax = 200
		GameVars.PointCount = 3
		GameVars.CapMul = 0.02
		GameVars.SZRadius = 750
		GameVars.PointPositions = {Vector(5744,7011,-10578),Vector(8721,11872,-9559),Vector(13502, 11900, -10752)} 
		GameVars.PointNames = {"Beachside Bunker","The Tower","End of the line"}
	elseif MapName == "gm_toysoldiers" then
		GameVars.FreedomSpawn = Vector(-5186,5086,-383)
		GameVars.DutySpawn = Vector(5186,-5086,-383)
		GameVars.WeightLimit = 80
		GameVars.PropCountMax = 300
		GameVars.PointCount = 3
		GameVars.CapMul = 0.02
		GameVars.SZRadius = 750
		GameVars.PointPositions = {Vector(-5250, -5132, -440),Vector(4908, 4919, -430),Vector(1787, 790, -430)} 
		GameVars.PointNames = {"The Darkest Corner","The Lighter Side","Confused Boat"}
	elseif MapName == "gm_yanov" then
		GameVars.FreedomSpawn = Vector(-4246, -4855, 65)
		GameVars.DutySpawn = Vector(-3856, 1488,65)
		GameVars.WeightLimit = 40
		GameVars.PropCountMax = 150
		GameVars.PointCount = 3
		GameVars.CapMul = 0.02
		GameVars.SZRadius = 750
		GameVars.PointPositions = {Vector(-1968, -1324, -74),Vector(2609, -2517, 40),Vector(1728, 918, 64)} 
		GameVars.PointNames = {"Extremely Confused Boat","Broken Car","Garage"}
	end

elseif GameVars.GameType == 2 then --KOTH
	if MapName == "gm_construct" then

		GameVars.FreedomSpawn = Vector(727,548,-143)
		GameVars.DutySpawn = Vector(-4970,-3434,251)
		GameVars.WeightLimit = 120
		GameVars.PropCountMax = 200
		GameVars.PointCount = 1
		GameVars.CapMul = 0.15 --Feel free to override this in map setup
		GameVars.SZRadius = 750
		GameVars.PointPositions = {Vector(-2563,-1217,240)}
		GameVars.PointNames = {"The Hill"}
		GameVars.WinsToRestart = 5
		
	elseif MapName == "gm_baik_citycentre_v3" then
		GameVars.FreedomSpawn = Vector(5280, 4760, 256)
		GameVars.DutySpawn = Vector(-5280,-4760, 256)
		GameVars.WeightLimit = 40
		GameVars.PropCountMax = 100
		GameVars.PointCount = 1
		GameVars.CapMul = 0.15	
		GameVars.SZRadius = 750
		GameVars.PointPositions = {Vector(0, 0, 16)}
		GameVars.PointNames = {"The Hill"}

	elseif MapName == "gm_baik_coast_03" then
		GameVars.FreedomSpawn = Vector(-4678, -5985, 501)
		GameVars.DutySpawn = Vector(7312, 4011, 295)
		GameVars.WeightLimit = 60
		GameVars.PropCountMax = 100
		GameVars.PointCount = 1
		GameVars.CapMul = 0.15	
		GameVars.SZRadius = 750
		GameVars.PointPositions = {Vector(-6480,10373,219)}
		GameVars.PointNames = {"The Hill"}
	elseif MapName == "gm_baik_construct_draft1" then
		GameVars.FreedomSpawn = Vector(-3038, 3038, 17)
		GameVars.DutySpawn = Vector(3038, -3038, 17)
		GameVars.WeightLimit = 20
		GameVars.PropCountMax = 100
		GameVars.PointCount = 1
		GameVars.CapMul = 0.15	
		GameVars.SZRadius = 750
		GameVars.PointPositions = {Vector(0, 0, 2)}
		GameVars.PointNames = {"The Hill"}
	elseif MapName == "gm_de_port_opened_v2" then --V1 not included
		GameVars.FreedomSpawn = Vector(-1920, 3944, 513)
		GameVars.DutySpawn = Vector(2245, -3674, 777)
		GameVars.WeightLimit = 20
		GameVars.PropCountMax = 100
		GameVars.PointCount = 1
		GameVars.CapMul = 0.15	
		GameVars.SZRadius = 750
		GameVars.PointPositions = {Vector(1119, 190, 642)}
		GameVars.PointNames = {"The Hill"}
	elseif MapName == "gm_emp_arid" then
		GameVars.FreedomSpawn = Vector(13127,-11026,513)
		GameVars.DutySpawn = Vector(-11004, 12164, 537)
		GameVars.WeightLimit = 60
		GameVars.PropCountMax = 200
		GameVars.PointCount = 1
		GameVars.CapMul = 0.15	
		GameVars.SZRadius = 750
		GameVars.PointPositions = {Vector(-604, -874, 359)}
		GameVars.PointNames = {"The Hill"}
	elseif MapName == "gm_emp_manticore" then
		GameVars.FreedomSpawn = Vector(-6670, -3958, 1760)
		GameVars.DutySpawn = Vector(10288, 2047, 1761)
		GameVars.WeightLimit = 60
		GameVars.PropCountMax = 150
		GameVars.PointCount = 1
		GameVars.CapMul = 0.15	
		GameVars.SZRadius = 750
		GameVars.PointPositions = {Vector(12,251,2048)}
		GameVars.PointNames = {"The Hill"}
	elseif MapName == "gm_emp_midbridge" then
		GameVars.FreedomSpawn = Vector(632, -9715, 2081)
		GameVars.DutySpawn = Vector(-628, 9755, 2081)
		GameVars.WeightLimit = 80
		GameVars.PropCountMax = 200
		GameVars.PointCount = 1
		GameVars.CapMul = 0.15	
		GameVars.SZRadius = 750
		GameVars.PointPositions = {Vector(0,0,-255)}
		GameVars.PointNames = {"The Hill"}
	elseif MapName == "gm_emp_palmbay" then
		GameVars.FreedomSpawn = Vector(-6577, -8994, -2331)
		GameVars.DutySpawn = Vector(8857, 10746, -2331)
		GameVars.WeightLimit = 60
		GameVars.PropCountMax = 200
		GameVars.PointCount = 1
		GameVars.CapMul = 0.15	
		GameVars.SZRadius = 750
		GameVars.PointPositions = {Vector(313, -499, -2953)}
		GameVars.PointNames = {"The Hill"}
	elseif MapName == "gm_greenchoke" then
		GameVars.FreedomSpawn = Vector(-9156, 10610, 1038)
		GameVars.DutySpawn = Vector(9055, -10722, 1038)
		GameVars.WeightLimit = 60
		GameVars.PropCountMax = 150
		GameVars.PointCount = 1
		GameVars.CapMul = 0.15	
		GameVars.SZRadius = 750
		GameVars.PointPositions = {Vector(495, -1037, 1184)}
		GameVars.PointNames = {"The Hill"}
	elseif MapName == "gm_baik_frontline" then
		GameVars.FreedomSpawn = Vector(-9284, 357, -20)
		GameVars.DutySpawn = Vector(6748, 485, -21)
		GameVars.WeightLimit = 60
		GameVars.PropCountMax = 200
		GameVars.PointCount = 1
		GameVars.CapMul = 0.15	
		GameVars.SZRadius = 750
		GameVars.PointPositions = {Vector(-1260, 409, 79)}
		GameVars.PointNames = {"The Hill"}
	elseif MapName == "gm_baik_stalingrad" then
		GameVars.FreedomSpawn = Vector(-1360, -8207, 1)
		GameVars.DutySpawn = Vector(-1428, 2101, 1)
		GameVars.WeightLimit = 40
		GameVars.PropCountMax = 150
		GameVars.PointCount = 1
		GameVars.CapMul = 0.15	
		GameVars.SZRadius = 750
		GameVars.PointPositions = {Vector(-2254, -2538, -56)}
		GameVars.PointNames = {"The Hill"}
	elseif MapName == "gm_baik_trenches" then
		GameVars.FreedomSpawn = Vector(3852,0,102)
		GameVars.DutySpawn = Vector(-3852,0,102)
		GameVars.WeightLimit = 60
		GameVars.PropCountMax = 200
		GameVars.PointCount = 1
		GameVars.CapMul = 0.15	
		GameVars.SZRadius = 750
		GameVars.PointPositions = {Vector(0,0,3)}
		GameVars.PointNames = {"The Hill"}
	elseif MapName == "gm_baik_valley_split" then
		GameVars.FreedomSpawn = Vector(-6285, -5632, 7)
		GameVars.DutySpawn = Vector(6193, 723, 8)
		GameVars.WeightLimit = 80
		GameVars.PropCountMax = 200
		GameVars.PointCount = 1
		GameVars.CapMul = 0.15	
		GameVars.SZRadius = 750
		GameVars.PointPositions = {Vector(0,-2559, 2)}
		GameVars.PointNames = {"The Hill"}
	elseif MapName == "gm_bigcity_improved" then
		GameVars.FreedomSpawn = Vector(-10163,11922,-11136)
		GameVars.DutySpawn = Vector(11937,-7932,-11136)
		GameVars.WeightLimit = 120
		GameVars.PropCountMax = 300
		GameVars.PointCount = 1
		GameVars.CapMul = 0.15	
		GameVars.SZRadius = 750
		GameVars.PointPositions = {Vector(-983,-949,-11140)}
		GameVars.PointNames = {"The Hill"}
	elseif MapName == "gm_diprip_refinery" then
		GameVars.FreedomSpawn = Vector(-7754, 6833, 161)
		GameVars.DutySpawn = Vector(4141, -5520, 320)
		GameVars.WeightLimit = 60
		GameVars.PropCountMax = 150
		GameVars.PointCount = 1
		GameVars.CapMul = 0.15
		GameVars.SZRadius = 750
		GameVars.PointPositions = {Vector(128,128,480)}
		GameVars.PointNames = {"The Hill"}
	elseif MapName == "gm_diprip_village" then
		GameVars.FreedomSpawn = Vector(5974, 3971, 7)
		GameVars.DutySpawn = Vector(-8421, -11827, 185)
		GameVars.WeightLimit = 40
		GameVars.PropCountMax = 150
		GameVars.PointCount = 1
		GameVars.CapMul = 0.15
		GameVars.SZRadius = 750
		GameVars.PointPositions = {Vector(-449, -3181, 48)}
		GameVars.PointNames = {"The Hill"}
	elseif MapName == "gm_emp_bush" then
		GameVars.FreedomSpawn = Vector(-11392, -11104, -3333)
		GameVars.DutySpawn = Vector(10060, 11788, -3327)
		GameVars.WeightLimit = 120
		GameVars.PropCountMax = 200
		GameVars.PointCount = 1
		GameVars.CapMul = 0.15
		GameVars.SZRadius = 750
		GameVars.PointPositions = {Vector(72, -286, -3449)}
		GameVars.PointNames = {"The Hill"}
	elseif MapName == "gm_emp_commandergrad" then
		GameVars.FreedomSpawn = Vector(3216, 12558, 9)
		GameVars.DutySpawn = Vector(-7078, -13608, 9)
		GameVars.WeightLimit = 60
		GameVars.PropCountMax = 150
		GameVars.PointCount = 1
		GameVars.CapMul = 0.15
		GameVars.SZRadius = 750
		GameVars.PointPositions = {Vector(-1574, -714, 624)}
		GameVars.PointNames = {"The Hill"}
	elseif MapName == "gm_freedom_city" then
		GameVars.FreedomSpawn = Vector(-10769, 3232, 34)
		GameVars.DutySpawn = Vector(6398,1988,464)
		GameVars.WeightLimit = 80
		GameVars.PropCountMax = 200
		GameVars.PointCount = 1
		GameVars.CapMul = 0.15
		GameVars.SZRadius = 750
		GameVars.PointPositions = {Vector(166,-4929, 33)} 
		GameVars.PointNames = {"The Hill"}
	elseif MapName == "gm_greenland" then
		GameVars.FreedomSpawn = Vector(-3461, -10270, 2)
		GameVars.DutySpawn = Vector(3461, 10270, 2)
		GameVars.WeightLimit = 60
		GameVars.PropCountMax = 200
		GameVars.PointCount = 1
		GameVars.CapMul = 0.15
		GameVars.SZRadius = 750
		GameVars.PointPositions = {Vector(78,2053,576)} 
		GameVars.PointNames = {"The Hill"}
	elseif MapName == "gm_islandrain_v3" then
		GameVars.FreedomSpawn = Vector(-3831, 10741, -1200)
		GameVars.DutySpawn = Vector(8391, -9920, -1175)
		GameVars.WeightLimit = 60
		GameVars.PropCountMax = 150
		GameVars.PointCount = 1
		GameVars.CapMul = 0.15
		GameVars.SZRadius = 750
		GameVars.PointPositions = {Vector(6302, 4246, 1122)} 
		GameVars.PointNames = {"The Hill"}
	elseif MapName == "gm_pacific_island_a3" then
		GameVars.FreedomSpawn = Vector(13995,8546,-10539)
		GameVars.DutySpawn = Vector(636,13393,-10612)
		GameVars.WeightLimit = 40
		GameVars.PropCountMax = 100
		GameVars.PointCount = 1
		GameVars.CapMul = 0.15
		GameVars.SZRadius = 750
		GameVars.PointPositions = {Vector(8721,11872,-9559)} 
		GameVars.PointNames = {"The Hill"}
	elseif MapName == "gm_toysoldiers" then
		GameVars.FreedomSpawn = Vector(-5186,5086,-383)
		GameVars.DutySpawn = Vector(5186,-5086,-383)
		GameVars.WeightLimit = 60
		GameVars.PropCountMax = 200
		GameVars.PointCount = 1
		GameVars.CapMul = 0.15
		GameVars.SZRadius = 750
		GameVars.PointPositions = {Vector(1787, 790, -430)} 
		GameVars.PointNames = {"The Hill"}
	elseif MapName == "gm_yanov" then
		GameVars.FreedomSpawn = Vector(-4246, -4855, 65)
		GameVars.DutySpawn = Vector(-3856, 1488,65)
		GameVars.WeightLimit = 20
		GameVars.PropCountMax = 100
		GameVars.PointCount = 1
		GameVars.CapMul = 0.15
		GameVars.SZRadius = 750
		GameVars.PointPositions = {2173,-763,72} 
		GameVars.PointNames = {"The Hill"}
	end
elseif GameVars.GameType == 3 then --DM
	GameVars.DeathTickets = 1 --The staple of deathmatch
	if MapName == "gm_construct" then

		GameVars.FreedomSpawn = Vector(727,548,-143)
		GameVars.DutySpawn = Vector(-4970,-3434,251)
		GameVars.WeightLimit = 120
		GameVars.PropCountMax = 200
		GameVars.PointCount = 0
		GameVars.CapMul = 0.15 --Feel free to override this in map setup
		GameVars.SZRadius = 750
		GameVars.PointPositions = {}
		GameVars.PointNames = {}
		GameVars.WinsToRestart = 5
		
	elseif MapName == "gm_baik_citycentre_v3" then
		GameVars.FreedomSpawn = Vector(5280, 4760, 256)
		GameVars.DutySpawn = Vector(-5280,-4760, 256)
		GameVars.WeightLimit = 80
		GameVars.PropCountMax = 200
		GameVars.PointCount = 0
		GameVars.CapMul = 0.15	
		GameVars.SZRadius = 750
		GameVars.PointPositions = {}
		GameVars.PointNames = {}

	elseif MapName == "gm_baik_coast_03" then
		GameVars.FreedomSpawn = Vector(-4678, -5985, 501)
		GameVars.DutySpawn = Vector(7312, 4011, 295)
		GameVars.WeightLimit = 120
		GameVars.PropCountMax = 200
		GameVars.PointCount = 0
		GameVars.CapMul = 0.15	
		GameVars.SZRadius = 750
		GameVars.PointPositions = {}
		GameVars.PointNames = {}
	elseif MapName == "gm_baik_construct_draft1" then
		GameVars.FreedomSpawn = Vector(-3038, 3038, 17)
		GameVars.DutySpawn = Vector(3038, -3038, 17)
		GameVars.WeightLimit = 60
		GameVars.PropCountMax = 200
		GameVars.PointCount = 0
		GameVars.CapMul = 0.15	
		GameVars.SZRadius = 750
		GameVars.PointPositions = {}
		GameVars.PointNames = {}
	elseif MapName == "gm_de_port_opened_v2" then --V1 not included
		GameVars.FreedomSpawn = Vector(-1920, 3944, 513)
		GameVars.DutySpawn = Vector(2245, -3674, 777)
		GameVars.WeightLimit = 40
		GameVars.PropCountMax = 200
		GameVars.PointCount = 0
		GameVars.CapMul = 0.15	
		GameVars.SZRadius = 750
		GameVars.PointPositions = {}
		GameVars.PointNames = {}
	elseif MapName == "gm_emp_arid" then
		GameVars.FreedomSpawn = Vector(13127,-11026,513)
		GameVars.DutySpawn = Vector(-11004, 12164, 537)
		GameVars.WeightLimit = 120
		GameVars.PropCountMax = 300
		GameVars.PointCount = 0
		GameVars.CapMul = 0.15	
		GameVars.SZRadius = 750
		GameVars.PointPositions = {}
		GameVars.PointNames = {}
	elseif MapName == "gm_emp_manticore" then
		GameVars.FreedomSpawn = Vector(-6670, -3958, 1760)
		GameVars.DutySpawn = Vector(10288, 2047, 1761)
		GameVars.WeightLimit = 120
		GameVars.PropCountMax = 200
		GameVars.PointCount = 0
		GameVars.CapMul = 0.15	
		GameVars.SZRadius = 750
		GameVars.PointPositions = {}
		GameVars.PointNames = {}
	elseif MapName == "gm_emp_midbridge" then
		GameVars.FreedomSpawn = Vector(632, -9715, 2081)
		GameVars.DutySpawn = Vector(-628, 9755, 2081)
		GameVars.WeightLimit = 120
		GameVars.PropCountMax = 300
		GameVars.PointCount = 0
		GameVars.CapMul = 0.15	
		GameVars.SZRadius = 750
		GameVars.PointPositions = {}
		GameVars.PointNames = {}
	elseif MapName == "gm_emp_palmbay" then
		GameVars.FreedomSpawn = Vector(-6577, -8994, -2331)
		GameVars.DutySpawn = Vector(8857, 10746, -2331)
		GameVars.WeightLimit = 80
		GameVars.PropCountMax = 200
		GameVars.PointCount = 0
		GameVars.CapMul = 0.15	
		GameVars.SZRadius = 750
		GameVars.PointPositions = {}
		GameVars.PointNames = {}
	elseif MapName == "gm_greenchoke" then
		GameVars.FreedomSpawn = Vector(-9156, 10610, 1038)
		GameVars.DutySpawn = Vector(9055, -10722, 1038)
		GameVars.WeightLimit = 80
		GameVars.PropCountMax = 200
		GameVars.PointCount = 0
		GameVars.CapMul = 0.15	
		GameVars.SZRadius = 750
		GameVars.PointPositions = {}
		GameVars.PointNames = {}
	elseif MapName == "gm_baik_frontline" then
		GameVars.FreedomSpawn = Vector(-9284, 357, -20)
		GameVars.DutySpawn = Vector(6748, 485, -21)
		GameVars.WeightLimit = 60
		GameVars.PropCountMax = 200
		GameVars.PointCount = 0
		GameVars.CapMul = 0.15	
		GameVars.SZRadius = 750
		GameVars.PointPositions = {}
		GameVars.PointNames = {}
	elseif MapName == "gm_baik_stalingrad" then
		GameVars.FreedomSpawn = Vector(-1360, -8207, 1)
		GameVars.DutySpawn = Vector(-1428, 2101, 1)
		GameVars.WeightLimit = 60
		GameVars.PropCountMax = 200
		GameVars.PointCount = 0
		GameVars.CapMul = 0.15	
		GameVars.SZRadius = 750
		GameVars.PointPositions = {}
		GameVars.PointNames = {}
	elseif MapName == "gm_baik_trenches" then
		GameVars.FreedomSpawn = Vector(3852,0,102)
		GameVars.DutySpawn = Vector(-3852,0,102)
		GameVars.WeightLimit = 60
		GameVars.PropCountMax = 200
		GameVars.PointCount = 0
		GameVars.CapMul = 0.15	
		GameVars.SZRadius = 750
		GameVars.PointPositions = {}
		GameVars.PointNames = {}
	elseif MapName == "gm_baik_valley_split" then
		GameVars.FreedomSpawn = Vector(-6285, -5632, 7)
		GameVars.DutySpawn = Vector(6193, 723, 8)
		GameVars.WeightLimit = 80
		GameVars.PropCountMax = 200
		GameVars.PointCount = 0
		GameVars.CapMul = 0.15	
		GameVars.SZRadius = 750
		GameVars.PointPositions = {}
		GameVars.PointNames = {}
	elseif MapName == "gm_bigcity_improved" then
		GameVars.FreedomSpawn = Vector(-10163,11922,-11136)
		GameVars.DutySpawn = Vector(11937,-7932,-11136)
		GameVars.WeightLimit = 120
		GameVars.PropCountMax = 300
		GameVars.PointCount = 0
		GameVars.CapMul = 0.15	
		GameVars.SZRadius = 750
		GameVars.PointPositions = {}
		GameVars.PointNames = {}
	elseif MapName == "gm_diprip_refinery" then
		GameVars.FreedomSpawn = Vector(-7754, 6833, 161)
		GameVars.DutySpawn = Vector(4141, -5520, 320)
		GameVars.WeightLimit = 120
		GameVars.PropCountMax = 200
		GameVars.PointCount = 0
		GameVars.CapMul = 0.15
		GameVars.SZRadius = 750
		GameVars.PointPositions = {}
		GameVars.PointNames = {}
	elseif MapName == "gm_diprip_village" then
		GameVars.FreedomSpawn = Vector(5974, 3971, 7)
		GameVars.DutySpawn = Vector(-8421, -11827, 185)
		GameVars.WeightLimit = 60
		GameVars.PropCountMax = 200
		GameVars.PointCount = 0
		GameVars.CapMul = 0.15
		GameVars.SZRadius = 750
		GameVars.PointPositions = {}
		GameVars.PointNames = {}
	elseif MapName == "gm_emp_bush" then
		GameVars.FreedomSpawn = Vector(-11392, -11104, -3333)
		GameVars.DutySpawn = Vector(10060, 11788, -3327)
		GameVars.WeightLimit = 120
		GameVars.PropCountMax = 200
		GameVars.PointCount = 0
		GameVars.CapMul = 0.15
		GameVars.SZRadius = 750
		GameVars.PointPositions = {}
		GameVars.PointNames = {}
	elseif MapName == "gm_emp_commandergrad" then
		GameVars.FreedomSpawn = Vector(3216, 12558, 9)
		GameVars.DutySpawn = Vector(-7078, -13608, 9)
		GameVars.WeightLimit = 80
		GameVars.PropCountMax = 200
		GameVars.PointCount = 0
		GameVars.CapMul = 0.15
		GameVars.SZRadius = 750
		GameVars.PointPositions = {}
		GameVars.PointNames = {}
	elseif MapName == "gm_freedom_city" then
		GameVars.FreedomSpawn = Vector(-10769, 3232, 34)
		GameVars.DutySpawn = Vector(6398,1988,464)
		GameVars.WeightLimit = 120
		GameVars.PropCountMax = 300
		GameVars.PointCount = 0
		GameVars.CapMul = 0.15
		GameVars.SZRadius = 750
		GameVars.PointPositions = {} 
		GameVars.PointNames = {}
	elseif MapName == "gm_greenland" then
		GameVars.FreedomSpawn = Vector(-3461, -10270, 2)
		GameVars.DutySpawn = Vector(3461, 10270, 2)
		GameVars.WeightLimit = 60
		GameVars.PropCountMax = 200
		GameVars.PointCount = 0
		GameVars.CapMul = 0.15
		GameVars.SZRadius = 750
		GameVars.PointPositions = {} 
		GameVars.PointNames = {}
	elseif MapName == "gm_islandrain_v3" then
		GameVars.FreedomSpawn = Vector(-3831, 10741, -1200)
		GameVars.DutySpawn = Vector(8391, -9920, -1175)
		GameVars.WeightLimit = 120
		GameVars.PropCountMax = 200
		GameVars.PointCount = 0
		GameVars.CapMul = 0.15
		GameVars.SZRadius = 750
		GameVars.PointPositions = {} 
		GameVars.PointNames = {}
	elseif MapName == "gm_pacific_island_a3" then
		GameVars.FreedomSpawn = Vector(13995,8546,-10539)
		GameVars.DutySpawn = Vector(636,13393,-10612)
		GameVars.WeightLimit = 60
		GameVars.PropCountMax = 150
		GameVars.PointCount = 0
		GameVars.CapMul = 0.15
		GameVars.SZRadius = 750
		GameVars.PointPositions = {} 
		GameVars.PointNames = {}
	elseif MapName == "gm_toysoldiers" then
		GameVars.FreedomSpawn = Vector(-5186,5086,-383)
		GameVars.DutySpawn = Vector(5186,-5086,-383)
		GameVars.WeightLimit = 120
		GameVars.PropCountMax = 300
		GameVars.PointCount = 0
		GameVars.CapMul = 0.15
		GameVars.SZRadius = 750
		GameVars.PointPositions = {} 
		GameVars.PointNames = {}
	elseif MapName == "gm_yanov" then
		GameVars.FreedomSpawn = Vector(-4246, -4855, 65)
		GameVars.DutySpawn = Vector(-3856, 1488,65)
		GameVars.WeightLimit = 40
		GameVars.PropCountMax = 150
		GameVars.PointCount = 0
		GameVars.CapMul = 0.15
		GameVars.SZRadius = 750
		GameVars.PointPositions = {} 
		GameVars.PointNames = {}
	end
end



--Do not edit below here

function spawnPoint(pointnum)

	local ent = ents.Create( "tpg_controlpoint" )
	
	if ( IsValid( ent ) ) then

		ent:SetPos( GameVars.PointPositions[pointnum] )
		ent:Spawn()
		ent.PointID = pointnum --Adjusted by the spawn command, this adjusts the output signal.
		ent.PointName = GameVars.PointNames[pointnum] or "Unnamed Point"
		GameVars.PointEntities[pointnum] = ent
	end

	--No point defending juggernauts for now
--[[
	local guard = ents.Create("npc_combine_s")

	if ( IsValid( ent ) ) then

		guard:SetPos( GameVars.PointPositions[pointnum] + Vector( 0, 0 , 150 ) )
		guard:Spawn()
		guard:Activate()
		guard:Give("weapon_ar2")
		guard:SetHealth( 500 )
		guard:DropToFloor()
	end
]]--

end

--Swaps spawns around so the teams start at the propper spawns
local storespawn = GameVars.FreedomSpawn
GameVars.FreedomSpawn = GameVars.DutySpawn
GameVars.DutySpawn = storespawn

GameVars.SZRadius = math.Clamp(GameVars.SZRadius,200,3000) --CLAMP DAMN YOU

function setupGamemode()

	GameVars.SZRadius = math.Clamp(GameVars.SZRadius,200,3000)

	game.CleanUpMap( true )


	local	storespawn = GameVars.FreedomSpawn
	
	GameVars.FreedomSpawn = GameVars.DutySpawn
	GameVars.DutySpawn = storespawn

	for i, ply in ipairs( player.GetAll() ) do --kills every player to ready respawns
		ply:Kill()
	end

	GameVars.PointsFree = 300
	GameVars.PointsDuty = 300
	GameVars.PropsGreenCount = 0
	GameVars.PropsRedCount = 0

	for i=1,GameVars.PointCount do 
		spawnPoint(i)
	end 

	--Creates 2 circular safezone indicators
	local ent = ents.Create( "tpg_safezonemarker" )
	
	if ( IsValid( ent ) ) then

		ent:SetPos( GameVars.FreedomSpawn )
		ent:Spawn()
		ent.Scale = GameVars.SZRadius*2
		ent.PointID = pointnum --Adjusted by the spawn command, this adjusts the output signal.
	end

	local ent = ents.Create( "tpg_safezonemarker" )

	if ( IsValid( ent ) ) then

		ent:SetPos( GameVars.DutySpawn )
		ent:Spawn()
		ent.Scale = GameVars.SZRadius*2
		ent.PointID = pointnum --Adjusted by the spawn command, this adjusts the output signal.
	end


end


hook.Add("PlayerSpawnedProp", "NoSpawnDupeProp", function(ply, model, ent)
	if not CLIENT then
local searchteam = ply:Team()
if searchteam == 1 then
	inrange = ((ply:GetPos():Distance( GameVars.FreedomSpawn )) < GameVars.SZRadius)
elseif searchteam == 2 then
	inrange = ((ply:GetPos():Distance( GameVars.DutySpawn )) < GameVars.SZRadius)
else
	inrange = 0 --If has no team cannot spawn
end

if !inrange then --Fail stuck spawning stuff, better than breaking.
	
ent:Remove()
--GameVars.PlayerSafezoneTime[player] = 5
end

end

end)

hook.Add("PlayerSpawnedSENT", "NoSpawnDupeSENT", function(ply, ent)
	if not CLIENT then
local searchteam = ply:Team()
if searchteam == 1 then
	inrange = ((ply:GetPos():Distance( GameVars.FreedomSpawn )) < GameVars.SZRadius)
elseif searchteam == 2 then
	inrange = ((ply:GetPos():Distance( GameVars.DutySpawn )) < GameVars.SZRadius)
else
	inrange = 0 --If has no team cannot spawn
end

if !inrange then --Fail stuck spawning stuff, better than breaking.
	
ent:Remove()
--GameVars.PlayerSafezoneTime[player] = 5
end

end

end)

hook.Add("PlayerSpawnedVehicle", "NoSpawnDupeVehicle", function(ply, ent)
	if not CLIENT then
local searchteam = ply:Team()
if searchteam == 1 then
	inrange = ((ply:GetPos():Distance( GameVars.FreedomSpawn )) < GameVars.SZRadius)
elseif searchteam == 2 then
	inrange = ((ply:GetPos():Distance( GameVars.DutySpawn )) < GameVars.SZRadius)
else
	inrange = 0 --If has no team cannot spawn
end

if !inrange then --Fail stuck spawning stuff, better than breaking.
	
ent:Remove()
--GameVars.PlayerSafezoneTime[player] = 5
end

end

end)

hook.Add("PlayerSpawnedEffect", "NoSpawnDupeEffect", function(ply, model, ent)
	if not CLIENT then
local searchteam = ply:Team()
if searchteam == 1 then
	inrange = ((ply:GetPos():Distance( GameVars.FreedomSpawn )) < GameVars.SZRadius)
elseif searchteam == 2 then
	inrange = ((ply:GetPos():Distance( GameVars.DutySpawn )) < GameVars.SZRadius)
else
	inrange = 0 --If has no team cannot spawn
end

if !inrange then --Fail stuck spawning stuff, better than breaking.
	
ent:Remove()
--GameVars.PlayerSafezoneTime[player] = 5
end

end

end)

--[[ 
--WHY U NO WORK, REEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEE
hook.Add("PlayerSpawnedSENT", "NoSpawnDupeSENT", function(ply, ent)
	if not CLIENT then
local searchteam = ply:Team()
if searchteam == 1 then
	inrange = ((ply:GetPos():Distance( GameVars.FreedomSpawn )) < GameVars.SZRadius)
elseif searchteam == 2 then
	inrange = ((ply:GetPos():Distance( GameVars.DutySpawn )) < GameVars.SZRadius)
else
	inrange = 0 --If has no team cannot spawn
end

if !inrange then --Fail stuck spawning stuff, better than breaking.
	
ent:Remove()
--GameVars.PlayerSafezoneTime[player] = 5
end

end

end)
]]--

--I wonder how fast the redundant hook functions that can be combined into 1 function will be noticed. Patch this out later or if they find it.


function calculateForceLimits(id,Deltime) --Will boot a player out of their seat and kill them if they exceed G force. Also updates various seat variables
	--Speed limit is 3500, G force limit is 50G
	local ent = GameVars.SeatEntities[id]["Ent"]

	local lastPos = GameVars.SeatEntities[id]["Pos"] or ent:GetPos() --Parented seats best seats
	GameVars.SeatEntities[id]["Pos"] = ent:GetPos()


	local lastVel = GameVars.SeatEntities[id]["Vel"] or Vector(0,0,0)
	GameVars.SeatEntities[id]["Vel"] = ((GameVars.SeatEntities[id]["Pos"]-lastPos) / Deltime)*0.1 --Gets change in position over time

	local Accel = ((GameVars.SeatEntities[id]["Vel"]-lastVel) / Deltime)*0.1 --Change in velocity
	local Driver = ent:GetDriver()
	--19291*4
	--7716400 old
	--129921 ~= 50G
--	if Accel:Length() > (24000) then--129921, 999999999999999  --Pulling about 50g. If you pull this hard you should get something checked out.
if Accel:Length() > (9999999999) then--129921, 999999999999999  --Pulling about 50g. If you pull this hard you should get something checked out.
--print(Accel:Length())
		if IsValid(Driver) then
		Driver:ExitVehicle()
--		Driver:Kill()
		chatMessagePly(Driver, "[TPG] Exceeded G-Limit." , Color( 255, 0, 0 ) )
		end

--	elseif lastVel:Length() > 3500 then --9999999999 , 3500 about 200 mph
	elseif lastVel:Length() > 9999999999 then --9999999999 , 3500 about 200 mph

---		print(lastVel:Length())
		if IsValid(Driver) then
		Driver:ExitVehicle()
--		Driver:Kill()
		chatMessagePly(Driver, "[TPG] Exceeded 200 MPH in speed." , Color( 255, 0, 0 ) )
--		print(lastVel:Length())
		end

	elseif IsValid(Driver) then

		if Driver:GetMaxHealth() == 500 then
			Driver:ExitVehicle()
			chatMessagePly(Driver, "[TPG] Your armor is too heavy for the chair." , Color( 255, 0, 0 ) )
		end
	end

end


function commendPlayers() --Called at end of round 10 seconds before votemap starts. Rewards are shared between teams for now.
--[1]Kills, [2]Kills/Ton, [3]Objective kills, [4]Captures
	local allplayers = player.GetAll()

	local BestPlayer = nil
	local BestVal = -1 --Ensures somebody gets a reward even if they did nothing.
	local Val = 0
	local MedalCount = 0
	
	--
	--
	--Kill count commendation
	--
	--

	for i, ply in ipairs( allplayers ) do
		Val1 = GameVars.PlayerScoreTrackers[ply] or {}
		Val = Val1[1] or 0
		if Val > BestVal then
			BestVal = Val
			BestPlayer = ply
		end

	end

	MedalCount = BestPlayer:GetPData("TPG_KillAwards", -1) --Give the player a medal.
	if PrimWep == -1 then
		BestPlayer:SetPData("TPG_KillAwards",1)
		MedalCount = 1
	else
		MedalCount = MedalCount + 1
		BestPlayer:SetPData("TPG_KillAwards",MedalCount)
	end

	if BestPlayer:Team() == 1 then
	chatMessageGlobal( "[TPG] "..BestPlayer:Name().." had the most kills with ["..BestVal.."] kills. They have earned this medal ["..MedalCount.."] times" , Color( 0, 255, 0 ) )
	else
	chatMessageGlobal( "[TPG] "..BestPlayer:Name().." had the most kills with ["..BestVal.."] kills. They have earned this medal ["..MedalCount.."] times" , Color( 255, 0, 0 ) )
	end

	--
	--
	--Kills per ton count commendation
	--
	--

	BestPlayer = nil
	BestVal = -1 --Ensures somebody gets a reward even if they did nothing.
	Val = 0
	MedalCount = 0

	for i, ply in ipairs( allplayers ) do
		Val1 = GameVars.PlayerScoreTrackers[ply] or {}
		Val = Val1[2] or 0
		if Val > BestVal then
			BestVal = Val
			BestPlayer = ply
		end

	end

	MedalCount = BestPlayer:GetPData("TPG_KPTAwards", -1) --Give the player a medal.
	if PrimWep == -1 then
		BestPlayer:SetPData("TPG_KPTAwards",1)
		MedalCount = 1
	else
		MedalCount = MedalCount + 1
		BestPlayer:SetPData("TPG_KPTAwards",MedalCount)
	end

	if BestPlayer:Team() == 1 then
	chatMessageGlobal( "[TPG] "..BestPlayer:Name().." had the most kills per ton with ["..BestVal.."] weighted kills. They have earned this medal ["..MedalCount.."] times" , Color( 0, 255, 0 ) )
	else
	chatMessageGlobal( "[TPG] "..BestPlayer:Name().." had the most kills per ton with ["..BestVal.."] weighted kills. They have earned this medal ["..MedalCount.."] times" , Color( 255, 0, 0 ) )
	end

	--
	--
	--Objective Kills commendation
	--
	--

	BestPlayer = nil
	BestVal = -1 --Ensures somebody gets a reward even if they did nothing.
	Val = 0
	MedalCount = 0

	for i, ply in ipairs( allplayers ) do
		Val1 = GameVars.PlayerScoreTrackers[ply] or {}
		Val = Val1[3] or 0
		if Val > BestVal then
			BestVal = Val
			BestPlayer = ply
		end

	end

	MedalCount = BestPlayer:GetPData("TPG_OBJKAwards", -1) --Give the player a medal.
	if PrimWep == -1 then
		BestPlayer:SetPData("TPG_OBJKAwards",1)
		MedalCount = 1
	else
		MedalCount = MedalCount + 1
		BestPlayer:SetPData("TPG_OBJKAwards",MedalCount)
	end

	if BestPlayer:Team() == 1 then
	chatMessageGlobal( "[TPG] "..BestPlayer:Name().." had the most objective kills with ["..BestVal.."] near-point kills. They have earned this medal ["..MedalCount.."] times" , Color( 0, 255, 0 ) )
	else
	chatMessageGlobal( "[TPG] "..BestPlayer:Name().." had the most objective kills with ["..BestVal.."] near-point kills. They have earned this medal ["..MedalCount.."] times" , Color( 255, 0, 0 ) )
	end

	--
	--
	--Captures commendation
	--
	--

	BestPlayer = nil
	BestVal = -1 --Ensures somebody gets a reward even if they did nothing.
	Val = 0
	MedalCount = 0

	for i, ply in ipairs( allplayers ) do
		Val1 = GameVars.PlayerScoreTrackers[ply] or {}
		Val = Val1[4] or 0
		if Val > BestVal then
			BestVal = Val
			BestPlayer = ply
		end

	end

	MedalCount = BestPlayer:GetPData("TPG_CapAwards", -1) --Give the player a medal.
	if PrimWep == -1 then
		BestPlayer:SetPData("TPG_CapAwards",1)
		MedalCount = 1
	else
		MedalCount = MedalCount + 1
		BestPlayer:SetPData("TPG_CapAwards",MedalCount)
	end

	if BestPlayer:Team() == 1 then
	chatMessageGlobal( "[TPG] "..BestPlayer:Name().." captured the most points with ["..BestVal.."] total captures. They have earned this medal ["..MedalCount.."] times" , Color( 0, 255, 0 ) )
	else
	chatMessageGlobal( "[TPG] "..BestPlayer:Name().." captured the most points with ["..BestVal.."] total captures. They have earned this medal ["..MedalCount.."] times" , Color( 255, 0, 0 ) )
	end



	GameVars.PlayerScoreTrackers = {} --Clean Slate

end