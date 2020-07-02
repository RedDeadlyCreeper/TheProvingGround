include( 'shared.lua' )
include( "baiknorii/gamemode/PlayerAndHud/hud.lua" )--Do some change to refresh the hud 


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

