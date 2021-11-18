function Railgun:GetIsAffectedByWeaponUpgrades()
    return false
end 

local kChargeTime = 0.5
-- The Railgun will automatically shoot if it is charged for too long.
local kChargeForceShootTime = 2.2
local kRailgunRange = 400
local kRailgunSpread = Math.Radians(0)
local kBulletSize = 0.3

local kRailgunChargeTime = 1.4


--Allows railguns to fire simulataneously
function Railgun:OnPrimaryAttack(player)
    
    local exoWeaponHolder = player:GetActiveWeapon()
    local otherSlotWeapon = self:GetExoWeaponSlot() == ExoWeaponHolder.kSlotNames.Left and exoWeaponHolder:GetRightSlotWeapon() or exoWeaponHolder:GetLeftSlotWeapon()
    if  self.timeOfLastShot + kRailgunChargeTime <= Shared.GetTime() then

        if not self.railgunAttacking then
            self.timeChargeStarted = Shared.GetTime()           
        end
        self.railgunAttacking = true
        
    end
    
end

debug.setupvaluex(Railgun.GetChargeAmount, "kChargeTime", kChargeTime)
