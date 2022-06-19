AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )

include( 'shared.lua' )

hook.Add( "PlayerInitialSpawn", "FullLoadSetup", function( ply ) --"When the player first joins the server and spawns" function

	local FreeCount = team.NumPlayers(1) or 0
	local DutyCount = team.NumPlayers(2) or 0

	if FreeCount < DutyCount then --Unbalanced Teams autobalance free
		ply:SetTeam( 1 )
		ply:Spawn()	
	elseif DutyCount < FreeCount then --Unbalanced Teams autobalance duty
		ply:SetTeam( 2 )
		ply:Spawn()	
	else
		ply:SetTeam( 0 )
		ply:ConCommand( "team_menu" )
	end

	EqArmor = ply:GetPData("Baik_Armor", -1) or -1
	if EqArmor == -1 then
		ply:SetPData("Baik_Armor",1)
		EqArmor = 1
	end
	local eqArmorString = ArmorTable[math.floor(EqArmor)]
	local model = "models/player/Group03/Male_0"..math.random(1,9)..".mdl"
	if eqArmorString == "None" then
		model = "models/player/Group01/Male_0"..math.random(1,9)..".mdl"
	elseif eqArmorString == "Light"  then
		model = "models/player/Group03/Male_0"..math.random(1,9)..".mdl"
	elseif eqArmorString == "Medium"  then
		model = "models/player/barney.mdl"
	elseif eqArmorString == "Heavy"  then
		model = "models/player/police.mdl"
	elseif eqArmorString == "Juggernaut"  then
		model = "models/player/combine_super_soldier.mdl"
	end
	ply:SetModel( model)

	ply:SetWalkSpeed( 200 ) --RIP in nerf
	ply:SetRunSpeed( 350 ) --RIP in nerf

	chatMessagePly(ply, "[TPG] Press F2 to change teams, press F3 to change loadout, press F4 to enter a nearby vehicle you are looking at." , Color( 0, 255, 0 ) )

	ply:SendLua( "LocalPlayer():EmitSound( 'garrysmod/save_load1.wav' )" )

end)



function GM:PlayerSetModel( ply ) --Double double check
	EqArmor = ply:GetPData("Baik_Armor", -1) or -1
	if EqArmor == -1 then
		ply:SetPData("Baik_Armor",1)
		EqArmor = 1
	end
	local eqArmorString = ArmorTable[math.floor(EqArmor)]
	local model = "models/player/Group03/Male_0"..math.random(1,9)..".mdl"
	if eqArmorString == "None" then
		model = "models/player/Group01/Male_0"..math.random(1,9)..".mdl"
	elseif eqArmorString == "Light"  then
		model = "models/player/Group03/Male_0"..math.random(1,9)..".mdl"
	elseif eqArmorString == "Medium"  then
		model = "models/player/barney.mdl"
	elseif eqArmorString == "Heavy"  then
		model = "models/player/police.mdl"
	elseif eqArmorString == "Juggernaut"  then
		model = "models/player/combine_super_soldier.mdl"
	end
	ply:SetModel( model)
end

concommand.Add( "team_change", function( ply, cmd, args )

	local	testteam = ply:Team() or 0
	local FreeCount = 0
	local DutyCount = 0 

	if testteam == 1 then --No unbalance 4 you
		FreeCount = team.NumPlayers(1)-1 or 0 --If I remove the parenthesis the game sometimes reads just the variable 'team' and kills the script
		DutyCount = team.NumPlayers(2) or 0 --Honestly I don't know why, its confusing as hell but it happens sometime
	elseif testteam == 2 then
		FreeCount = team.NumPlayers(1) or 0 --If I remove the parenthesis the game sometimes reads just the variable 'team' and kills the script
		DutyCount = team.NumPlayers(2)-1 or 0 --Honestly I don't know why, its confusing as hell but it happens sometime
	else
		FreeCount = team.NumPlayers(1) or 0 --If I remove the parenthesis the game sometimes reads just the variable 'team' and kills the script
		DutyCount = team.NumPlayers(2) or 0 --Honestly I don't know why, its confusing as hell but it happens sometime	
	end


	n = math.Round(args[1] or 0,0)
--	print(teams[n].name)

	if not teams[n] then print("[TPG] ERR: Invalid Team") return end

	 if n == 1 and (FreeCount>DutyCount) then --Cannot manually unbalance teams
		chatMessagePly(ply, "[TPG] Teams cannot be unbalanced." , Color( 255, 0, 0 ) )
		return
	 elseif n == 2 and (DutyCount>FreeCount) then
		chatMessagePly(ply, "[TPG] Teams cannot be unbalanced." , Color( 255, 0, 0 ) )
		return
	 end



	ply:SetTeam(n)
	ply:Spawn()	
	ply:SetPlayerColor( teams[n].color)
	ply:SetWeaponColor( teams[n].color )
	
	EqArmor = ply:GetPData("Baik_Armor", -1) or -1
	if EqArmor == -1 then
		ply:SetPData("Baik_Armor",1)
		EqArmor = 1
	end
	local eqArmorString = ArmorTable[math.floor(EqArmor)]
	local model = "models/player/Group03/Male_0"..math.random(1,9)..".mdl"
	if eqArmorString == "None" then
		model = "models/player/Group01/Male_0"..math.random(1,9)..".mdl"
	elseif eqArmorString == "Light"  then
		model = "models/player/Group03/Male_0"..math.random(1,9)..".mdl"
	elseif eqArmorString == "Medium"  then
		model = "models/player/barney.mdl"
	elseif eqArmorString == "Heavy"  then
		model = "models/player/police.mdl"
	elseif eqArmorString == "Juggernaut"  then
		model = "models/player/combine_super_soldier.mdl"
	end
	ply:SetModel( model)

	print( "["..ply:Nick().. "] has been assigned to team ["..teams[n].name.."]" )
	chatMessagePly(ply, "You have joined team ["..teams[n].name.."]" , Color( 0, 255, 255 ) )	

	if n == 1 then

		ply:SetPos( GameVars.FreedomSpawn )

	elseif n == 2 then

		ply:SetPos( GameVars.DutySpawn )
	
	end

	chatMessagePly(ply, "[TPG] Press F2 to change teams, press F3 to change loadout, press F4 to enter a nearby vehicle you are looking at." , Color( 0, 255, 0 ) )

end )

function chatMessagePly( ply , message, color) --In the name of colored chat!

	net.Start( "chatmessage" )
		net.WriteColor( color or Color( 255, 255, 255 ) ) --Must go first
		net.WriteString( message )
	net.Send( ply )
	
	end

function chatMessageGlobal( message, color) --Like chatMessagePly but it just goes to everyone.

	net.Start( "chatmessage" )
		net.WriteColor( color or Color( 255, 255, 255 ) ) --Must go first
		net.WriteString( message )
	net.Broadcast()
		
end

--IK its inefficient
PrimaryWeaponsTable = {}
PrimaryWeaponsTable[0] = "NoWeapon"
PrimaryWeaponsTable[1] = "m16"
PrimaryWeaponsTable[2] = "ak47"
PrimaryWeaponsTable[3] = "galil"
PrimaryWeaponsTable[4] = "famas"
PrimaryWeaponsTable[5] = "aug"
PrimaryWeaponsTable[6] = "sg552"
PrimaryWeaponsTable[7] = "m3super90"
PrimaryWeaponsTable[8] = "xm1014"
PrimaryWeaponsTable[9] = "p90"
PrimaryWeaponsTable[10] = "ump45"
PrimaryWeaponsTable[11] = "mp5"
PrimaryWeaponsTable[12] = "tmp"
PrimaryWeaponsTable[13] = "mac10"
PrimaryWeaponsTable[14] = "scout"
PrimaryWeaponsTable[15] = "awp"
PrimaryWeaponsTable[16] = "m249saw"

SecWeaponsTable = {}
SecWeaponsTable[0] = "NoWeapon"
SecWeaponsTable[1] = "glock"
SecWeaponsTable[2] = "fiveseven"
SecWeaponsTable[3] = "p228"
SecWeaponsTable[4] = "usp"
SecWeaponsTable[5] = "deagle"
SecWeaponsTable[6] = "elite"
SecWeaponsTable[7] = "grenade"
SecWeaponsTable[8] = "weapon_medkit"

SpWeaponsTable = {}
SpWeaponsTable[0] = "NoWeapon"
SpWeaponsTable[1] = "at4"
SpWeaponsTable[2] = "at4t"
SpWeaponsTable[3] = "amr"
SpWeaponsTable[4] = "xm25"
SpWeaponsTable[5] = "mines"


ArmorTable = {}
ArmorTable[0] = "None"
ArmorTable[1] = "Light"
ArmorTable[2] = "Medium"
ArmorTable[3] = "Heavy"
ArmorTable[4] = "Juggernaut"

function GM:PlayerLoadout( ply )
	
	ply:Give( "weapon_physgun" )
	ply:Give( "gmod_camera" )
	ply:Give( "weapon_crowbar" )

	n = ply:Team() or 0

	if n == 1 then

		ply:SetPos( GameVars.FreedomSpawn )

	elseif n == 2 then

		ply:SetPos( GameVars.DutySpawn )
	else
		n = 0
	end
	
--	GameVars.PlayerSafezoneTime[ply] = 5
--Loadout part

if n == 0 then
	 return true 
end --Neutral shouldn't get weapons

ply:SetPlayerColor( teams[n].color or Color(255,255,255) )
ply:SetWeaponColor( teams[n].color or Color(255,255,255) )

ply:SendLua( "LocalPlayer():EmitSound( 'acf_extra/tankfx/gnomefather/rack.wav' )" )

ply:Give( "gmod_tool" ) --Just so people dont dupe before joining a team.

--Default loadout is an m16, no pistol, and an at-4, else set loadout to player sql

PrimWep = ply:GetPData("Baik_PrimeWep", -1) or -1 --If you see this failz, this is the one thing i didnt want to change so servers dont have to overload the SQL file
if PrimWep == -1 then
	ply:SetPData("Baik_PrimeWep",1)
	PrimWep = 1
end

SecWep = ply:GetPData("Baik_SecWep", -1) or -1
if SecWep == -1 then
	ply:SetPData("Baik_SecWep",0)
	SecWep = 0
end

SpecWep = ply:GetPData("Baik_SpecWep", -1) or -1
if SpecWep == -1 then
	ply:SetPData("Baik_SpecWep",1)
	SpecWep = 1
end

EqArmor = ply:GetPData("Baik_Armor", -1) or -1
if EqArmor == -1 then
	ply:SetPData("Baik_Armor",1)
	EqArmor = 1
end


local pWepString = PrimaryWeaponsTable[math.floor(PrimWep)]
local sWepString = SecWeaponsTable[math.floor(SecWep)]
local spWepString = SpWeaponsTable[math.floor(SpecWep)]
local eqArmorString = ArmorTable[math.floor(EqArmor)]
local speed = 55 --50 percent is slowest speed you can get from weapons

if pWepString == "NoWeapon" then speed = speed + 15 else
	ply:Give( pWepString )
end --Adds 20% speed for forgoing a primary weapon

if sWepString == "NoWeapon" then speed = speed + 10 else
	ply:Give( sWepString )
end --Adds 10% speed for forgoing a secondary weapon

if spWepString == "NoWeapon" then --Adds 30% speed for forgoing a special weapon
	speed = speed + 20 
	ply:Give( "disposableat" )
elseif spWepString == "mines" then
	ply:Give( "antipersonmine" )
	ply:Give( "boundingmine" )
	ply:Give( "antitankmine" )
else
	ply:Give( spWepString )	
end

local hp = 100
local armor = 25

local model = "models/player/Group03/Male_0"..math.random(1,9)..".mdl"

if eqArmorString == "None" then
	hp = 30
	armor = 0
	speed = speed + 10 
	model = "models/player/Group01/Male_0"..math.random(1,9)..".mdl"
elseif eqArmorString == "Light"  then
	hp = 75
	armor = 50
	speed = speed + 0 
	model = "models/player/Group03/Male_0"..math.random(1,9)..".mdl"
elseif eqArmorString == "Medium"  then
	hp = 100
	armor = 120
	speed = speed - 10 
	model = "models/player/barney.mdl"
elseif eqArmorString == "Heavy"  then
	hp = 150
	armor = 200
	speed = speed - 15 
	model = "models/player/police.mdl"
elseif eqArmorString == "Juggernaut"  then
	hp = 500
	armor = 999999
	speed = speed - 40 
	model = "models/player/combine_super_soldier.mdl"
end

ply:SetModel( model)

ply:SetHealth(hp)
ply:SetMaxHealth(hp)
ply:SetArmor(armor)
ply:SetWalkSpeed( (speed/100)*400 ) --RIP in nerf
ply:SetRunSpeed( (speed/100)*600 ) --RIP in nerf

--End of loadouts

	return true
end


concommand.Add( "loadout_change", function( ply, cmd, args )
local	wepclass = math.floor(args[1])
local	wid = math.floor(args[2]) --Because sometimes an integer becomes a floating point somehow *shrugs*

--If you manually enter this in console and get a wrong value your stupid and I am not helping you if you enter it wrong.

if wepclass == 1 then
	ply:SetPData("Baik_PrimeWep",wid or 1)
elseif wepclass == 2 then
	ply:SetPData("Baik_SecWep",wid or 1)
elseif wepclass == 3 then
	ply:SetPData("Baik_SpecWep",wid or 1)
elseif wepclass == 4 then
	ply:SetPData("Baik_Armor",wid or 1)
end



end )

function TestTeamLims(ArgTable) --Use the same arguments as the original function you're hooking to

	local	testplayer = ArgTable[1]["Player"]
	local	testteam = testplayer:Team() or 0
	local	proplist = ArgTable[1]["CreatedEntities"]

	if testteam == 1 then --Redundant but for deltas, deal with it.
		oldtestprops = GameVars.PropsGreenCount
		oldtestweight = GameVars.WeightGreenCount / 1000
	elseif testteam == 2 then
		oldtestprops = GameVars.PropsRedCount
		oldtestweight = GameVars.WeightRedCount / 1000
	else
		oldtestprops = 0
		oldtestweight = 0
	end
	
		testprops = 0
		testweight = 0
		local noValid = 0
		local class = nil

	for id, ent in pairs( proplist ) do
		noValid = 0

		if not ent:IsValid() then
			noValid = 1
--			print("NoValid")
		else
			class = ent:GetClass()
		end
		
		if class == "acf_ammo" then
--			print("Ammo")
			if ent.BulletData.Type == "Refill" then
--				print("Refill")
				noValid = 1
			end
		end

		if noValid == 0 then

			if class == "prop_physics" then
				testprops = testprops + 1
			end
			
			testweight = testweight + (ent:GetPhysicsObject():GetMass())/1000
		end
	end
	
--	print("TP: "..testprops)
	print("TW: "..testweight)

	if testweight > 5.5 or testprops > 140 then --Makes 5ts able to spawn with a maxed weightlimit since neither of these should change the weight or proplimit. Also bypasses duplicator cooldown.
			--5.5T for light vehicle leniency. Don't abuse it playerbase!!!
		if testweight > 65 then
			print("TW: "..testweight)
			chatMessagePly(testplayer, "[TPG] Contraption exceeding 65T has been removed." , Color( 255, 0, 0 ) )	
			for id, ent in pairs( proplist ) do
				ent:Remove()
			end
		elseif (testprops+oldtestprops) > GameVars.PropCountMax then
				--		print("TW: "..testweight)

				--		print("OverOnProps")
						chatMessagePly(testplayer, "[TPG] Contraption deleted due to going over prop limit" , Color( 255, 0, 0 ) )	
						for id, ent in pairs( proplist ) do
							ent:Remove()
						end
		elseif (testweight+oldtestweight) > GameVars.WeightLimit then

				--		print("TW: "..testweight)

				--		print("OverOnProps")
				chatMessagePly(testplayer, "[TPG] Contraption deleted due to going over weight limit" , Color( 255, 0, 0 ) )	
				for id, ent in pairs( proplist ) do
					ent:Remove()
				end

		elseif CurTime() < (GameVars.DupeWaitTime[testplayer] or 0) then

			local waitdelay = GameVars.DupeWaitTime[testplayer]-CurTime()

			chatMessagePly(testplayer, "[TPG] Contraption removed. duplicator still on cooldown for ["..math.ceil(waitdelay).."] seconds." , Color( 255, 0, 0 ) )	
			for id, ent in pairs( proplist ) do --Updates propcount and prop weight of each player
				ent:Remove()
			end

		else

			chatMessagePly(testplayer, "[TPG] 60 second duplicator grace period." , Color( 0, 255, 0 ) )				

			timer.Simple( 60, function()

				testweight = 0

				for id, ent in pairs( proplist ) do --I'm sorry server. FORGIVE ME!!!
					noValid = 0
			
					if ent:IsValid() then
						class = ent:GetClass()
			--			print("NoValid")
					else
						noValid = 1
					end
					
					if class == "acf_ammo" then
			--			print("Ammo")
						if ent.BulletData and ent.BulletData.Type == "Refill" then
			--				print("Refill")
							noValid = 1
						end
					end
			
					if noValid == 0 then
						
						testweight = testweight + (ent:GetPhysicsObject():GetMass())/1000
					end
				end

				local spawndelay = testweight*2 --6 seconds per ton, makes 360 second wait for 60t, done to prevent vehicle spam

				local TestNewSpawnTime = (GameVars.TimeVars["Time"] or 0) + spawndelay
				if TestNewSpawnTime > (GameVars.DupeWaitTime[testplayer] or 0) then
					
					GameVars.DupeWaitTime[testplayer] = TestNewSpawnTime

				end
				chatMessagePly(testplayer, "[TPG] duplicator on cooldown for ["..math.ceil(spawndelay).."] seconds." , Color( 0, 255, 255 ) )	
			end)

			updatePropcount(1)--Update propcount after dupefinish
		end



	else --Lightweight vehicle

		chatMessagePly(testplayer, "[TPG] Light vehicle spawned, duplicator cooldown bypassed." , Color( 0, 255, 255 ) )	

	end

--	print("Player: "..testplayer)

	
end
hook.Add("AdvDupe_FinishPasting","TPGPropLimitCleanupHook",TestTeamLims)


--ply:Team()
--updatePropcount()

--[[ Broken
function GM:PostCleanupMap()

	print( "[TPG] Reseting gamemode due to cleanup") 

	local	storespawn = GameVars.FreedomSpawn
	GameVars.FreedomSpawn = GameVars.DutySpawn
	GameVars.DutySpawn = storespawn

	setupGamemode(1) --Tells to ignore cleanup

end
]]--


concommand.Add( "easy_entry", function( ply, cmd, args ) --Yes IK people can move away, but will they honestly do that within 4 seconds and be back by their vehicle? prob not.
	local etr = ply:GetEyeTrace()
	local eowner = etr.Entity:CPPIGetOwner() or nil

	if ply == eowner then --Valid entry, player is owner of entity

		local proplist = GameVars.SeatEntities
		local BestDist = 99999
		local dist = 99999
		local bestEnt = nil
			for id, entry in pairs( proplist ) do --Updates propcount and prop weight of each player
				ent = entry["Ent"]
				if ent:CPPIGetOwner() == eowner then --Owns seat

					dist = (ply:GetPos():Distance( ent:GetPos() )) --Gets distance to seat entity

					if dist < 750 then --Seat is within range of player

						if dist < BestDist then
							BestDist = dist
							bestEnt = ent
						end


					end
	


				end




			end

			if IsValid(bestEnt) then --Enter vehicle in 4 seconds if nearby
				timer.Simple( 4, function() EasyEntry(ply,bestEnt) end )
				chatMessagePly(ply, "[TPG] EasyEntry: Entering vehicle in 4 seconds, DO NOT MOVE." , Color( 0, 255, 255 ) )
			else
				chatMessagePly(ply, "[TPG] EasyEntry: Enterable vehicle not found." , Color( 255, 0, 0 ) )
			end

	end


end)


function EasyEntry(ply,seat)

	dist = (ply:GetPos():Distance( seat:GetPos() ))

	if dist < 750 then --Seat is within range of player

		chatMessagePly(ply, "[TPG] EasyEntry: Succesfully entered vehicle." , Color( 0, 255, 255 ) )
		ply:EnterVehicle( seat )
	else
		chatMessagePly(ply, "[TPG] EasyEntry: Moved away too far from vehicle." , Color( 255, 0, 0 ) )
	end


end


function populateMapChoices() --Fills the map votelist with votemap choices.
--GameVars.VoteMapList


	--Open maps
	local MapList1 = {"rp_wasteland","gm_emp_palmbay","gm_emp_midbridge","gm_greenchoke","gm_emp_arid","gm_baik_coast_03","gm_baik_coast_03_night","gm_baik_frontline","gm_baik_trenches","gm_baik_valley_split","gm_diprip_village","gm_emp_bush","gm_greenland","gm_islandrain_v3","gm_pacific_island_a3","gm_toysoldiers"}
	local Count1 = table.Count( MapList1 )


	--Urban maps
	local MapList2 = {"gm_emp_manticore","gm_baik_stalingrad","gm_bigcity_improved","gm_diprip_refinery","gm_emp_commandergrad","gm_freedom_city","gm_yanov","gm_baik_construct_draft1","gm_de_port_opened_v2","gm_baik_citycentre_v3"}
	local Count2 = table.Count( MapList2 )

	local Map1 = MapList1[math.random( 1, Count1 )]
	GameVars.VoteMapList[1] = Map1

	local Map2 = MapList1[math.random( 1, Count1 )]	
	GameVars.VoteMapList[2] = Map2

	if Count1 > 1 then --Are there enough maps for us to re-roll?
		while Map2 == Map1 do --No repeating maps for you, more choices for everyone.
			Map2 = MapList1[math.random( 1, Count1 )]	
			GameVars.VoteMapList[2] = Map2
		end
	end

	local Map3 = MapList2[math.random( 1, Count2 )]	
	GameVars.VoteMapList[3] = Map3

	local Map4 = ""
	--Randomly pick between an urban map or open map
	if math.Rand(0,1) > 0.4 then --Urban
		Map4 = MapList2[math.random( 1, Count2 )]	
		GameVars.VoteMapList[4] = Map4

		if Count2 > 1 then --Reroll if more than 2 maps exist in map list 1
			while Map4 ==  Map3 do --No repeating maps for you, more choices for everyone.
				Map4 = MapList2[math.random( 1, Count2 )]	
				GameVars.VoteMapList[4] = Map4
			end
		end
		
	else --Open
		local Map4 = MapList1[math.random( 1, Count1 )]
		GameVars.VoteMapList[4] = Map4

		if Count1 > 2 then --Are there enough maps for us to re-roll?
			while Map4 == Map1 do --No repeating maps for you, more choices for everyone.
				Map4 = MapList1[math.random( 1, Count1 )]
				GameVars.VoteMapList[4] = Map4
			end

			while Map4 == Map2 do --No repeating maps for you, more choices for everyone.
				Map4 = MapList1[math.random( 1, Count1 )]
				GameVars.VoteMapList[4] = Map4
			end
		end

	end

	local allplayers = player.GetAll()
		
	for i, ply in ipairs( player.GetAll() ) do --Fucks given: 0

		ply:SendLua( "GameVars.VoteMapList[1]=\"" .. GameVars.VoteMapList[1] .. "\";" )
		ply:SendLua( "GameVars.VoteMapList[2]=\"" .. GameVars.VoteMapList[2] .. "\";" )
		ply:SendLua( "GameVars.VoteMapList[3]=\"" .. GameVars.VoteMapList[3] .. "\";" )
		ply:SendLua( "GameVars.VoteMapList[4]=\"" .. GameVars.VoteMapList[4] .. "\";" )

	end

	print("Open Map [1]: "..GameVars.VoteMapList[1])
	print("Open Map [2]: "..GameVars.VoteMapList[2])
	print("Urban Map [1]: "..GameVars.VoteMapList[3])
	print("Bonus Map [1]: "..GameVars.VoteMapList[4])

end

GameVars.PlayerVotes = {}
concommand.Add( "tpg_votemap", function( ply, cmd, args )
	GameVars.PlayerVotes[ply] =math.ceil(args[1])
	chatMessageGlobal( "[TPG] "..ply:GetName().." voted for map ("..GameVars.VoteMapList[math.ceil(args[1])]..")" , Color( 0, 0, 255 ) )
end)


function tallyVotes()

	local Votes = {}
	Votes[1] = 0
	Votes[2] = 0
	Votes[3] = 0
	Votes[4] = 0
		
	for i, ply in ipairs( player.GetAll() ) do
		local vote = GameVars.PlayerVotes[ply] 

		if vote == 1 then
			Votes[1] = Votes[1] + 1
		elseif vote == 2 then
			Votes[2] = Votes[2] + 1
		elseif vote == 3 then
			Votes[3] = Votes[3] + 1
		elseif vote == 4 then
			Votes[4] = Votes[4] + 1
		end
	end
	bestvote = math.ceil(1) --Change to integer
	votecount = 0

	for I=1, 4 do
		local curvotecount = Votes[I]

		if curvotecount >= votecount then
			votecount = curvotecount
			bestvote = math.ceil(I) --Change to integer
		end

	end

	print(bestvote)
	print("BV: "..GameVars.VoteMapList[bestvote])
	print("V1: "..Votes[1])
	print("V2: "..Votes[2])
	print("V3: "..Votes[3])
	print("V4: "..Votes[4])

	RunConsoleCommand( "gamemode", "theprovingground" ) --Can never be too cautious
	RunConsoleCommand( "changelevel", GameVars.VoteMapList[bestvote] )

chatMessageGlobal( "[TPG] Changing to map ["..GameVars.VoteMapList[bestvote].."]" , Color( 0, 255, 0 ) )


end



--GameVars.PlayerScoreTrackers = {} -- Holds all of the players in this array,
--[1]Kills, [2]Kills/Ton, [3]Objective kills

hook.Add( "PlayerDeath", "CommendationTracker", function( victim, inflictor, attacker )

	if victim == attacker then
		return
	end

	local attackerIsPlayer = attacker:IsPlayer()

	if attackerIsPlayer then --Player killed player
		GameVars.PlayerScoreTrackers[attacker] = GameVars.PlayerScoreTrackers[attacker] or {} --Create if table does not exist

		--Kill tracker
		GameVars.PlayerScoreTrackers[attacker][1] = (GameVars.PlayerScoreTrackers[attacker][1] or 0) + 1

		--Kills/ton tracker
		local plypropinfo = GameVars.PlayerPropInfo[attacker] or {}
		GameVars.PlayerScoreTrackers[attacker][2] = (GameVars.PlayerScoreTrackers[attacker][2] or 0) + (1 / math.max((plypropinfo[1] or 1),1) )

			--Objective kills tracer
			local bestdist = 99999999

			local points = ents.FindByClass( "tpg_controlpoint" )

			for id, ent in pairs( points ) do
				local dist = (victim:GetPos():Distance( ent:GetPos() ))
				if dist < bestdist then
					bestdist = dist
				end
			end

			if bestdist < 2000 then
				GameVars.PlayerScoreTrackers[attacker][3] = (GameVars.PlayerScoreTrackers[attacker][3] or 0) + 1
			end

			local searchteam = attacker:Team() or 0

			if searchteam == 1 then
				inrange = ((attacker:GetPos():Distance( GameVars.FreedomSpawn )) < GameVars.SZRadius)
			elseif searchteam == 2 then
				inrange = ((attacker:GetPos():Distance( GameVars.DutySpawn )) < GameVars.SZRadius)
			else
				inrange = 1
			end

			--For people who kill in safezone with a drone.
			if inrange == 1 then
				chatMessagePly(attacker, "[TPG] Do not kill while in safezone." , Color( 255, 0, 0 ) )	
				attacker:Kill()		
				attacker:Spawn()			
			end

	end

	local deathteam = victim:Team() or 0
	local FreeCount = team.NumPlayers(1) or 0
	local DutyCount = team.NumPlayers(2) or 0

	if deathteam == 1 and (DutyCount+1 < FreeCount) then
		victim:SetTeam( 1 )
		victim:Spawn()	
		chatMessagePly(victim, "[TPG] You have been autobalanced." , Color( 255, 255, 0 ) )	
	elseif deathteam == 2 and (FreeCount+1 < DutyCount) then
		victim:SetTeam( 2 )
		victim:Spawn()	
		chatMessagePly(victim, "[TPG] You have been autobalanced." , Color( 255, 255, 0 ) )	
	end

	if GameVars.DeathTickets == 1 then --The only way to cheese this is to get another person to drive your vehicle while you sit comfy at base. But what are the odds someone will do this?
		if deathteam == 1 then
			GameVars.PointsFree = GameVars.PointsFree - math.ceil((math.max(GameVars.PlayerPropInfo[victim][1] or 1,1))/2000) --Every 2 tons of armor = a ticket
		elseif deathteam == 2 then
			GameVars.PointsDuty = GameVars.PointsDuty - math.ceil((math.max(GameVars.PlayerPropInfo[victim][1] or 1,1))/2000)
		end

	end
end)


--Credit to Salamafet for his simple AFK script. Slightly modified.
--Git: https://github.com/Salamafet/AFK_Kicker/blob/master/lua/autorun/server/AFK_Kicker.lua

--------------------------------------------------
AFK_WARN_TIME = 600

AFK_TIME = 900
--------------------------------------------------

hook.Add("PlayerInitialSpawn", "MakeAFKVar", function(ply)
	ply.NextAFK = CurTime() + AFK_TIME
end)

--hook.Add("Think", "HandleAFKPlayers", function()
timer.Create("AFK_Think", 1, 0, function()
	for _, ply in pairs (player.GetAll()) do
		if ( ply:IsConnected() and ply:IsFullyAuthenticated() ) then
			if (!ply.NextAFK) then
				ply.NextAFK = CurTime() + AFK_TIME
			end
		
			local afktime = ply.NextAFK
			if (CurTime() >= afktime - AFK_WARN_TIME) and (!ply.Warning) then
				chatMessagePly(ply, "[TPG] AFK Warning:" , Color( 255, 0, 0 ) )	
				chatMessagePly(ply, "[TPG] You will be disconnected in 5 minutes if you do not move." , Color( 255, 0, 0 ) )	
				ply:SendLua([[system.FlashWindow()]])
				ply.Warning = true
			elseif (CurTime() >= afktime) and (ply.Warning) then
				ply.Warning = nil
				ply.NextAFK = nil
				ply:Kick("\nAFK!!!")
			end
		end
	end
end)

hook.Add("KeyPress", "PlayerMoved", function(ply, key)
	ply.NextAFK = CurTime() + AFK_TIME
	if ply.Warning == true then
		ply.Warning = false
		chatMessagePly(ply, "[TPG] You are no longer AFK." , Color( 0, 255, 0 ) )	
	end
end)





concommand.Add( "rock_the_vote", function( ply, cmd, args ) --Don't like the current map or gamemode? Change it!

	GameVars.PlayerScoreTrackers[ply] = GameVars.PlayerScoreTrackers[ply] or {}

	GameVars.PlayerScoreTrackers[ply][99] = 1

	local VoteTally = 0
	local TotalPlayers = 0
	for _, aply in pairs (player.GetAll()) do
		GameVars.PlayerScoreTrackers[aply] = GameVars.PlayerScoreTrackers[aply] or {}
		VoteTally = VoteTally + (GameVars.PlayerScoreTrackers[aply][99] or 0)
		TotalPlayers = TotalPlayers + 1
	end

	local reqdplayers = math.ceil(math.max(TotalPlayers/2,3)) --A minimum of 3 players are required to RTV.

	chatMessagePly(ply, "[TPG] You have succesfully voted to rock the vote." , Color( 0, 255, 0 ) )	

	if VoteTally >= reqdplayers then

		chatMessageGlobal( "[TPG] Vote to change map was succesful. Commencing voting." , Color( 0, 255, 0 ) )

		populateMapChoices()
			

		for i, ply in ipairs( player.GetAll() ) do
			ply:ConCommand( "tpg_votemap_menu" )
		end

		for _, aply in pairs (player.GetAll()) do
			GameVars.PlayerScoreTrackers[aply] = GameVars.PlayerScoreTrackers[aply] or {}
			GameVars.PlayerScoreTrackers[aply][99] = 0

		end

		chatMessageGlobal( "[TPG] 20 seconds to vote for the next map!" , Color( 0, 255, 255 ) )
		timer.Simple( 10, function() chatMessageGlobal( "[TPG] 10 seconds to vote for the next map!" , Color( 0, 255, 255 ) ) end )
		timer.Simple( 15, function() chatMessageGlobal( "[TPG] 5 seconds to vote for the next map!" , Color( 255, 0, 0 ) ) end )
		timer.Simple( 21, function() tallyVotes() end ) --1 extra second because people are stupid



	else

		chatMessageGlobal( "[TPG] ("..reqdplayers-VoteTally..") more players are required to change maps." , Color( 255, 255, 0 ) )
	end


end)


concommand.Add( "votescramble", function( ply, cmd, args ) --Teams too unbalanced? How about no!
	if not ply:IsAdmin() then
		chatMessagePly(ply, "[TPG] You must be admin to scramble the teams." , Color( 255, 0, 0 ) )	

		return
	end

	GameVars.PlayerScoreTrackers[ply] = GameVars.PlayerScoreTrackers[ply] or {}

	GameVars.PlayerScoreTrackers[ply][100] = 1

	local VoteTally = 0
	local TotalPlayers = 0
	for _, aply in pairs (player.GetAll()) do
		GameVars.PlayerScoreTrackers[aply] = GameVars.PlayerScoreTrackers[aply] or {}
		VoteTally = VoteTally + (GameVars.PlayerScoreTrackers[aply][100] or 0)
		TotalPlayers = TotalPlayers + 1
	end

	local reqdplayers = math.ceil(math.max(TotalPlayers*0.6,2)) --A minimum of 2 players are required to votescramble or 60% of all players.
	reqdplayers = 1
	--chatMessagePly(ply, "[TPG] You have succesfully voted to scramble teams." , Color( 0, 255, 0 ) )	

	if VoteTally >= reqdplayers then

		chatMessageGlobal( "[TPG] Scrambing teams." , Color( 0, 255, 0 ) )
		
		for _, aply in pairs (player.GetAll()) do
			GameVars.PlayerScoreTrackers[aply] = GameVars.PlayerScoreTrackers[aply] or {}
			GameVars.PlayerScoreTrackers[aply][99] = 0
			ply:SetTeam( 0 )
		end

		for _, aply in pairs (player.GetAll()) do
			local FreeCount = team.NumPlayers(1) or 0
			local DutyCount = team.NumPlayers(2) or 0
		
			if FreeCount < DutyCount then --Unbalanced Teams autobalance free
				aply:SetTeam( 1 )
				aply:Spawn()	
			elseif DutyCount < FreeCount then --Unbalanced Teams autobalance duty
				aply:SetTeam( 2 )
				aply:Spawn()	
			else
				aply:SetTeam( math.random(1,2) )
				aply:Spawn()	
			end
		end

	else

		chatMessageGlobal( "[TPG] ("..reqdplayers-VoteTally..") more players are required to scramble teams." , Color( 255, 255, 0 ) )
	end


end)