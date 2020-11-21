AddCSLuaFile ("cl_init.lua")
AddCSLuaFile ("shared.lua")
 
include ('shared.lua')

SWEP.DeployDelay = 3 --No more rocket 2 taps or sprinting lawnchairs

function SWEP:Equip()

	self:DoAmmoStatDisplay()
	self:SetNextPrimaryFire( CurTime() + self.DeployDelay )
end