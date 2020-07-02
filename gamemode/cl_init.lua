include( 'shared.lua' )
--include( "baiknorii/gamemode/playerandhud/hud.lua" )--Do some change to refresh the hud 


function openTeamMenu()
 
    local frame = vgui.Create( "DFrame" )
    frame:SetPos( ScrW() / 2-300, ScrH() / 2-150 ) --Set the window in the middle of the players screen/game window
    frame:SetSize( 600, 300 ) --Set the size
    frame:SetTitle( "Change Team" ) --Set title
    frame:SetVisible( true )
    frame:SetDraggable( false )
    frame:ShowCloseButton( true )
    frame:MakePopup()
     
    team_1 = vgui.Create( "DButton", frame )
    team_1:SetPos( frame:GetWide() / 2 - 250, frame:GetTall()/2 - 50) --Place it half way on the tall and 5 units in hirizontal
    team_1:SetSize( 100, 100 )
    team_1:SetText( "Freedom" )
    team_1.DoClick = function() --Make the player join team 1
     
        RunConsoleCommand( "team_change", 1 )
        frame:Close()
        --print("Tried to go to freedom")
    end
     
    team_2 = vgui.Create( "DButton", frame )
    team_2:SetPos( frame:GetWide() / 2 + 150, frame:GetTall()/2 - 50) --Place it next to our previous one
    team_2:SetSize( 100, 100 )
    team_2:SetText( "Duty" )
    team_2.DoClick = function() --Make the player join team 2
     
        RunConsoleCommand( "team_change", 2 )
        frame:Close()
     
    end

    team_3 = vgui.Create( "DButton", frame )
    team_3:SetPos( frame:GetWide() / 2-50, frame:GetTall()/2 - 50) --Place it next to our previous one
    team_3:SetSize( 100, 100 )
    team_3:SetText( "Unassigned" )
    team_3.DoClick = function() --Make the player join team 2
     
        RunConsoleCommand( "team_change", 0 )
        frame:Close()

    end
     
end
    
concommand.Add( "team_menu", openTeamMenu )

--IK its inefficient
PrimaryWeaponsTable = {}
PrimaryWeaponsTable["NoWeapon"] = 0
PrimaryWeaponsTable["m16"] = 1
PrimaryWeaponsTable["ak47"] = 2
PrimaryWeaponsTable["famas"] = 3
PrimaryWeaponsTable["aug"] = 4
PrimaryWeaponsTable["m3super90"] = 5
PrimaryWeaponsTable["xm1014"] = 6
PrimaryWeaponsTable["p90"] = 7
PrimaryWeaponsTable["tmp"] = 8
PrimaryWeaponsTable["awp"] = 9
PrimaryWeaponsTable["scout"] = 10
PrimaryWeaponsTable["m249saw"] = 11



SecWeaponsTable = {}
SecWeaponsTable["NoWeapon"] = 0
SecWeaponsTable["glock"] = 1
SecWeaponsTable["fiveseven"] = 2
SecWeaponsTable["deagle"] = 3
SecWeaponsTable["grenade"] = 4
SecWeaponsTable["medkit"] = 5

SpWeaponsTable = {}
SpWeaponsTable["NoWeapon"] = 0
SpWeaponsTable["at4"] = 1
SpWeaponsTable["at4t"] = 2
SpWeaponsTable["amr"] = 3
SpWeaponsTable["xm25"] = 4
SpWeaponsTable["mines"] = 5

function openLoadoutMenu()
 
    local frame = vgui.Create( "DFrame" )
    frame:SetPos( ScrW() / 2-300, ScrH() / 2-150 ) --Set the window in the middle of the players screen/game window
    frame:SetSize( 250, 300 ) --Set the size
    frame:SetTitle( "Change Loadout" ) --Set title
    frame:SetVisible( true )
    frame:SetDraggable( false )
    frame:ShowCloseButton( true )
    frame:MakePopup()
     
    local DComboBox = vgui.Create( "DComboBox", frame )
    DComboBox:SetPos( 50, 50 )
    DComboBox:SetSize( 150, 30 )
    DComboBox:SetValue( "Primary Wep" )
    DComboBox:AddChoice( "NoWeapon" )
    DComboBox:AddChoice( "m16" )
    DComboBox:AddChoice( "ak47" )
    DComboBox:AddChoice( "famas" )
    DComboBox:AddChoice( "aug" )
    DComboBox:AddChoice( "m3super90" )
    DComboBox:AddChoice( "xm1014" )
    DComboBox:AddChoice( "p90" )
    DComboBox:AddChoice( "tmp" )
    DComboBox:AddChoice( "awp" )
    DComboBox:AddChoice( "scout" )
    DComboBox:AddChoice( "m249saw" )

    DComboBox.OnSelect = function( self, index, value )
        print( value .." was selected as a primary weapon" )
        RunConsoleCommand( "loadout_change", 1 ,PrimaryWeaponsTable[value] )
    end

    DComboBox = vgui.Create( "DComboBox", frame )
    DComboBox:SetPos( 50, 100 )
    DComboBox:SetSize( 150, 30 )
    DComboBox:SetValue( "Secondary Wep" )
    DComboBox:AddChoice( "NoWeapon" )
    DComboBox:AddChoice( "glock" )
    DComboBox:AddChoice( "fiveseven" )
    DComboBox:AddChoice( "deagle" )
    DComboBox:AddChoice( "grenade" )
    DComboBox:AddChoice( "medkit" )

    DComboBox.OnSelect = function( self, index, value )
        print( value .." was selected as a secondary weapon" )
        RunConsoleCommand( "loadout_change", 2 ,SecWeaponsTable[value] )
    end   
    
    DComboBox = vgui.Create( "DComboBox", frame )
    DComboBox:SetPos( 50, 150 )
    DComboBox:SetSize( 150, 30 )
    DComboBox:SetValue( "Special Wep" )
    DComboBox:AddChoice( "NoWeapon" )
    DComboBox:AddChoice( "at4" )
    DComboBox:AddChoice( "at4t" )
    DComboBox:AddChoice( "amr" )
    DComboBox:AddChoice( "xm25" )
    DComboBox:AddChoice( "mines" )

    DComboBox.OnSelect = function( self, index, value )
        print( value .." was selected as a special weapon" )
        RunConsoleCommand( "loadout_change", 3 ,SpWeaponsTable[value] )
    end   

    respawnbutton = vgui.Create( "DButton", frame )
    respawnbutton:SetPos( 60, 200) --Place it next to our previous one
    respawnbutton:SetSize( 125, 50 )
    respawnbutton:SetText( "Respawn" )
    respawnbutton.DoClick = function() --Make the player join team 2
     
        RunConsoleCommand( "kill")
        frame:Close()

    end

end
    
concommand.Add( "loadout_menu", openLoadoutMenu )

function GM:PlayerBindPress( ply, bind, pressed ) --Loadsa jank
    if ( bind == "gm_showteam" ) then RunConsoleCommand( "team_menu" ) end
        if ( bind == "gm_showspare1" ) then RunConsoleCommand( "loadout_menu" ) end
end

--    timer.Create( "HudRefreshThing", 5 , 0, HUD())

GameVars.PointEntities = {}





function HUD()
	local client = LocalPlayer()
	
	if !client:Alive() then
		return
	end

	Team = client:Team()
--	Team = 2

if Team == 1 then

	TeamColor = Color(0,200,0)
	TeamPropCount = GameVars.PropsFreeCount or 0
	TeamWeight = GameVars.WeightFreeCount/1000
elseif Team == 2 then
	TeamColor = Color(200,0,0)
	TeamPropCount = GameVars.PropsDutyCount or 0
	TeamWeight = GameVars.WeightDutyCount/1000
else
	TeamColor = Color(200,200,200)
	TeamPropCount = 0	
	TeamWeight = 0
end

	--IK this is bad, I hate myself for doing this. Deal with it, its 3am. Better than 5 networked variables. Will prob make search occur every once in a while.

	local points = ents.FindByClass( "baiknor_controlpoint" )

	for id, ent in pairs( points ) do

		local point = ent:GetPos() + ent:OBBCenter() + Vector (0,0,100)
		local data2D = point:ToScreen()

--		if ( not data2D.visible ) then continue end

	draw.RoundedBox(10, data2D.x-5, data2D.y-5, 13, 13, ent:GetColor())

	draw.RoundedBox(3,ScrW()/2-30*GameVars.PointCount/2+2+((id-1)*30), 70, 20, 20,ent:GetColor())

--		draw.SimpleText( ent.PointName, "Default", data2D.x, data2D.y, Color( 255, 255, 255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )

	end

	points = team.GetPlayers(Team)

	for id, ent in pairs( points ) do
		local point = ent:GetPos() + ent:OBBCenter()
		local data2D = point:ToScreen()

--		if ( not data2D.visible ) then continue end

	surface.SetDrawColor(TeamColor)
	surface.DrawRect(data2D.x-5, data2D.y-5, 5, 5)

--		draw.SimpleText( ent.PointName, "Default", data2D.x, data2D.y, Color( 255, 255, 255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )

	end

	--Team Props and tonnage available
	draw.RoundedBox(5,20, 20, 230, 80, TeamColor or Color(255, 255, 255) )--CornerCurvature radius, x, y, width, height, color
	draw.SimpleText("Team Props: "..TeamPropCount.."/"..GameVars.PropCountMax, "DermaDefaultBold", 40, 30, Color(255,255,255), 0, 0)
	draw.SimpleText("Team Weight: "..TeamWeight.."/"..GameVars.WeightLimit, "DermaDefaultBold", 40, 70, Color(255,255,255), 0, 0)
	draw.RoundedBox(5,12.5, 10, 245, 95, Color(0,0,0,100) )--CornerCurvature radius, x, y, width, height, color
	
	--Middle Point Box
	
	draw.RoundedBox(5,ScrW()/2-375, 10, 750, 50, Color(0,0,0,100) )--CornerCurvature radius, x, y, width, height, color	

	--*Health Boxes*
	local Length = math.max(GameVars.PointsFree/300,0.0001) --Point Ratio
	draw.RoundedBox(5,ScrW()/2-370*1, 15, 365*Length, 40, Color(0,255,0,255) ) --Freedom
	Length = math.max(GameVars.PointsDuty/300,0.0001)
	draw.RoundedBox(5,ScrW()/2+370*(1-Length), 15, 365*Length, 40, Color(255,0,0,255) ) --Duty

	--Points Left Text
	draw.SimpleText(GameVars.PointsFree, "DermaDefaultBold", ScrW()/2-200, 28, Color(255,255,255), 0, 0)	
	draw.SimpleText(GameVars.PointsDuty, "DermaDefaultBold", ScrW()/2+180, 28, Color(255,255,255), 0, 0)	
	--GameVars.setNWInt("PointsFree",GameVars.PointsFree)
	--GameVars.setNWInt("PointsDuty",GameVars.PointsDuty)





end

hook.Add("HUDPaint", "DrawGamemodeHud", HUD)

local hide = { -- CHudHealth", "CHudBattery", "CHudAmmo", "CHudSecondaryAmmo
	["CHudBattery"] = true
}

hook.Add( "HUDShouldDraw", "HideHUD", function( name )
	if ( hide[ name ] ) then return false end

	-- Don't return anything here, it may break other addons that rely on this hook.
end )

--concommand.Add( "team_menu", set_team )

net.Receive("update_cappoints_freedom", function()
	GameVars.PointsFree = net.ReadInt(10) or -1
--	print(GameVars.PointsFree)
end)

net.Receive("update_cappoints_duty", function()
	GameVars.PointsDuty = net.ReadInt(10) or -1
--	print(GameVars.PointsDuty)
end)

net.Receive("update_propcount_freedom", function()
	GameVars.PropsFreeCount = net.ReadInt(10) or -1
end)

net.Receive("update_propcount_duty", function()
	GameVars.PropsDutyCount = net.ReadInt(12) or -1
end)

net.Receive("update_weight_freedom", function()
	GameVars.WeightFreeCount = net.ReadInt(13)*500 or -1
--	print(GameVars.PointsFree)
end)

net.Receive("update_weight_duty", function()
	GameVars.WeightDutyCount = net.ReadInt(13)*500 or -1
--	print(GameVars.PointsDuty)
end)