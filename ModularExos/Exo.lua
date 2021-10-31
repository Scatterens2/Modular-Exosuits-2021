Script.Load("lua/Mixins/JumpMoveMixin.lua")
Script.Load("lua/PhaseGateUserMixin.lua")

Exo.kModelName = PrecacheAsset("models/marine/exosuit/exosuit_cm.model")
Exo.kAnimationGraph = PrecacheAsset("models/marine/exosuit/exosuit_cm.animation_graph")

Exo.kClawRailgunModelName = PrecacheAsset("models/marine/exosuit/exosuit_cr.model")
Exo.kClawRailgunAnimationGraph = PrecacheAsset("models/marine/exosuit/exosuit_cr.animation_graph")

Exo.kDualModelName = PrecacheAsset("models/marine/exosuit/exosuit_mm.model")
Exo.kDualAnimationGraph = PrecacheAsset("models/marine/exosuit/exosuit_mm.animation_graph")

Exo.kDualRailgunModelName = PrecacheAsset("models/marine/exosuit/exosuit_rr.model")
Exo.kDualRailgunAnimationGraph = PrecacheAsset("models/marine/exosuit/exosuit_rr.animation_graph")

local kMaxSpeed = 8



kExoThrusterMinFuel = 0.3
kExoThrusterFuelUsageRate = 1.5
kExoThrusterLateralAccel = 50
kExoThrusterVerticleAccel = 8
kExoThrusterMaxSpeed = 5

kExoShieldMinFuel = 0.99
kExoShieldDamageReductionScalar = 0.75
kExoShieldFuelUsageRate = 2

kExoRepairMinFuel = 0.1
kExoRepairPerSecond = 15
kExoRepairFuelUsageRate = 25
kExoRepairInterval = 0.5

kExoFuelRechargeRate = 10
kMinigunFuelUsageScalar = 1
kRailgunFuelUsageScalar = 1.5
local kExoDeployDuration = 1.4
local kThrustersCooldownTime = 2.5
local kThrusterDuration = 1.5
local kThrusterRefuelCooldownTime = 0.75
local kMinTimeBetweenThrusterActivations = 0.75
local kMinFuelForThrusterActivation = 0.3

local networkVars = {
    powerModuleType    = "enum kExoModuleTypes",
	rightArmModuleType = "enum kExoModuleTypes",
	leftArmModuleType  = "enum kExoModuleTypes",
    utilityModuleType  = "enum kExoModuleTypes",
	repairActive = "boolean",
	shieldActive = "boolean",
	hasThrusters = "boolean",
	hasPhaseModule = "boolean",
    armorBonus = "float (0 to 2045 by 1)",
	inventoryWeight = "float",

}

function Exo:InitExoModel(overrideAnimGraph)
    
	local leftArmType = (kExoModuleTypesData[self.leftArmModuleType] or {}).armType
    local rightArmType = (kExoModuleTypesData[self.rightArmModuleType] or {}).armType
    local modelData = (kExoWeaponRightLeftComboModels[rightArmType] or {})[leftArmType] or {}
    local modelName = modelData.worldModel or "models/marine/exosuit/exosuit_rr.model"
    local graphName = modelData.worldAnimGraph or "models/marine/exosuit/exosuit_rr.animation_graph"
    self:SetModel(modelName, overrideAnimGraph or graphName)
    self.viewModelName = modelData.viewModel or "models/marine/exosuit/exosuit_rr_view.model"
    self.viewModelGraphName = modelData.viewAnimGraph or "models/marine/exosuit/exosuit_rr_view.animation_graph"
end

local kDeploy2DSound = PrecacheAsset("sound/NS2.fev/marine/heavy/deploy_2D")
function Exo:InitWeapons()
    Player.InitWeapons(self)
    
    local weaponHolder = self:GetWeapon(ExoWeaponHolder.kMapName)
    if not weaponHolder then
        weaponHolder = self:GiveItem(ExoWeaponHolder.kMapName, false)   
    end
    
    local leftArmModuleTypeData = kExoModuleTypesData[self.leftArmModuleType]
    local rightArmModuleTypeData = kExoModuleTypesData[self.rightArmModuleType]
    weaponHolder:SetWeapons(leftArmModuleTypeData.mapName, rightArmModuleTypeData.mapName)
    
    weaponHolder:TriggerEffects("exo_login")
	self.inventoryWeight = self:CalculateWeight()


	self:SetActiveWeapon(ExoWeaponHolder.kMapName)
    StartSoundEffectForPlayer(kDeploy2DSound, self)
end


AddMixinNetworkVars(PhaseGateUserMixin, networkVars)
AddMixinNetworkVars(JumpMoveMixin, networkVars)
 
local orig_Exo_OnCreate = Exo.OnCreate
function Exo:OnCreate()
	orig_Exo_OnCreate(self)
    self.inventoryWeight = 0

	InitMixin(self, PhaseGateUserMixin)
	InitMixin(self, JumpMoveMixin)
end 

local orig_Exo_OnInitialized = Exo.OnInitialized
function Exo:OnInitialized()
    self.powerModuleType = self.powerModuleType or kExoModuleTypes.Power1
    self.leftArmModuleType = self.leftArmModuleType or kExoModuleTypes.Claw
    self.rightArmModuleType = self.rightArmModuleType or kExoModuleTypes.Minigun
    self.utilityModuleType = self.utilityModuleType or kExoModuleTypes.None
    
    local armorModuleData = kExoModuleTypesData[self.utilityModuleType]
    self.armorBonus = armorModuleData and armorModuleData.armorBonus or 0
    self.hasPhaseModule = (self.utilityModuleType == kExoModuleTypes.PhaseModule)
    self.hasThrusters = (self.utilityModuleType == kExoModuleTypes.Thrusters)
	
    orig_Exo_OnInitialized(self)
	
	self.shieldActive = false
	self.repairActive = false
	self.timeAutoRepairHealed = 0
	self.lastActivatedRepair = 0
	self.lastActivatedShield = 0
	
	if Server then
		-- Prevent people from ejecting to get fuel back instantly
		self:SetFuel(0.2)
	end	
end
 

function Exo:GetCanPhase()
	return self.hasPhaseModule and PhaseGateUserMixin.GetCanPhase(self)
end

function Exo:GetIsBeaconable(obsEnt, toOrigin)
	return self.hasPhaseModule
end

function Exo:GetInventorySpeedScalar(player)
    return 1 - self.inventoryWeight
end

function Exo:GetCanJump()
	return not self:GetIsWebbed() and self:GetIsOnGround() 
end

debug.setupvaluex(Exo.GetMaxSpeed, "kMaxSpeed", kMaxSpeed)

local orig_Exo_GetIsThrusterAllowed = Exo.GetIsThrusterAllowed
function Exo:GetIsThrusterAllowed()
	return self.hasThrusters and orig_Exo_GetIsThrusterAllowed(self)
end

function Exo:GetSlowOnLand()
    return true
end

function Exo:GetWebSlowdownScalar()
    return 0.6
end

function Exo:GetJumpHeight()
    return Player.kJumpHeight - Player.kJumpHeight * self.slowAmount * 0.5
end

function Exo:GetArmorAmount(armorLevels)
	
	if not armorLevels then
    
        armorLevels = 0
    
        if GetHasTech(self, kTechId.Armor3, true) then
            armorLevels = 3
        elseif GetHasTech(self, kTechId.Armor2, true) then
            armorLevels = 2
        elseif GetHasTech(self, kTechId.Armor1, true) then
            armorLevels = 1
        end
    
    end

	return Exo.kExosuitArmor + armorLevels * Exo.kExosuitArmorPerUpgradeLevel + self.armorBonus 
end

function Exo:ProcessExoModularBuyAction(message)
    ModularExo_HandleExoModularBuy(self, message)
end

if Server then
    local orig_Exo_PerformEject = Exo.PerformEject
    function Exo:PerformEject()
        if self:GetIsAlive() then
            -- pickupable version
            local exosuit = CreateEntity(Exosuit.kMapName, self:GetOrigin(), self:GetTeamNumber(), {
                powerModuleType    = self.powerModuleType   ,
                rightArmModuleType = self.rightArmModuleType,
                leftArmModuleType  = self.leftArmModuleType ,
                utilityModuleType  = self.utilityModuleType ,
            })
            exosuit:SetCoords(self:GetCoords())
            exosuit:SetMaxArmor(self:GetMaxArmor())
            exosuit:SetArmor(self:GetArmor())
            
            local reuseWeapons = self.storedWeaponsIds ~= nil
            
            local marine = self:Replace(self.prevPlayerMapName or Marine.kMapName, self:GetTeamNumber(), false, self:GetOrigin() + Vector(0, 0.2, 0), { preventWeapons = reuseWeapons })
            marine:SetHealth(self.prevPlayerHealth or kMarineHealth)
            marine:SetMaxArmor(self.prevPlayerMaxArmor or kMarineArmor)
            marine:SetArmor(self.prevPlayerArmor or kMarineArmor)
            
            exosuit:SetOwner(marine)
            
            marine.onGround = false
            local initialVelocity = self:GetViewCoords().zAxis
            initialVelocity:Scale(1*3.5)
            initialVelocity.y = 2*2
            marine:SetVelocity(initialVelocity)
            
            if reuseWeapons then
                for _, weaponId in ipairs(self.storedWeaponsIds) do
                    local weapon = Shared.GetEntity(weaponId)
                    if weapon then
                        marine:AddWeapon(weapon)
                    end
                end
            end
            marine:SetHUDSlotActive(1)
            if marine:isa("JetpackMarine") then
                marine:SetFuel(0)
            end
        end
        return false
    end 
end

if Client then
    function Exo:BuyMenu(structure)
        if self:GetTeamNumber() ~= 0 and Client.GetLocalPlayer() == self then
            if not self.buyMenu then
                self.buyMenu = GetGUIManager():CreateGUIScript("GUIMarineBuyMenu")
                MarineUI_SetHostStructure(structure)
                if structure then
                    self.buyMenu:SetHostStructure(structure)
                end
                self:TriggerEffects("marine_buy_menu_open")
               
            end
        end
    end
end

-- New Exo energy system.
function Exo:ConsumingFuel()
    return self.thrustersActive or self.shieldActive or self.repairActive
end

function Exo:GetFuel()
    if self:ConsumingFuel() then
        return Clamp(self.fuelAtChange - (Shared.GetTime() - self.timeFuelChanged) / self:GetFuelUsageRate(), 0, 1)
    else
        return Clamp(self.fuelAtChange + (Shared.GetTime() - self.timeFuelChanged) / self:GetFuelRechargeRate(), 0, 1)
    end
end

function Exo:GetFuelRechargeRate()
	return kExoFuelRechargeRate
end

function Exo:GetFuelUsageRate()
    local usageScalar = self:GetHasMinigun() and kMinigunFuelUsageScalar or kRailgunFuelUsageScalar
    if self.thrustersActive then
    	return kExoThrusterFuelUsageRate * usageScalar
    elseif self.repairActive then
    	return kExoRepairFuelUsageRate * usageScalar
	elseif self.shieldActive then
    	return kExoShieldFuelUsageRate * usageScalar
    else
    	return 1
    end
end

function Exo:GetShieldAllowed()
    return not self.thrustersActive or not self.repairActive 
end

function Exo:GetRepairAllowed()
    return not self.thrustersActive or self.shieldActive
end


function Exo:UpdateShields(input)

    local buttonPressed = bit.band(input.commands, Move.Use) ~= 0
    if buttonPressed and self:GetShieldAllowed() then

        if self:GetFuel() >= kExoShieldMinFuel and not self.shieldActive and self.lastActivatedShield + 1 < Shared.GetTime() then
        	self:SetFuel(self:GetFuel())
            self.shieldActive = true
            self.lastActivatedShield = Shared.GetTime()
            self:ActivateNanoShield()
        end
    end

    if self.shieldActive and (self:GetFuel() == 0 or not buttonPressed) then
    	self:SetFuel(self:GetFuel())
        self:DeactivateNanoShield()
        self.shieldActive = false
    end

end

function Exo:UpdateRepairs(input)

    local buttonPressed = bit.band(input.commands, Move.Reload) ~= 0
    local repairDesired = self:GetArmor() < self:GetMaxArmor()
    if buttonPressed and self:GetRepairAllowed() and repairDesired then

    	if self:GetFuel() >= kExoRepairMinFuel and not self.repairActive and self.lastActivatedRepair + 1 < Shared.GetTime() then
    		self:SetFuel(self:GetFuel())
            self.lastActivatedRepair = Shared.GetTime()
        	self.repairActive = true
        end
    end

    if self.repairActive and (self:GetFuel() == 0 or not buttonPressed or not repairDesired) then
    	self:SetFuel(self:GetFuel())
        self.repairActive = false
    end

    if self.repairActive and self.timeAutoRepairHealed + kExoRepairInterval < Shared.GetTime() then            
        self:SetArmor(self:GetArmor() + kExoRepairInterval * kExoRepairPerSecond, false)
		self.timeAutoRepairHealed = Shared.GetTime()
    end

end

function Exo:HandleButtons(input)

    if self.ejecting or self.creationTime + kExoDeployDuration > Shared.GetTime() then

        input.commands = bit.band(input.commands, bit.bnot(bit.bor(Move.Use, Move.Buy, Move.Jump,
                                                                   Move.PrimaryAttack, Move.SecondaryAttack,
                                                                   Move.SelectNextWeapon, Move.SelectPrevWeapon, Move.Reload,
                                                                   Move.Taunt, Move.Weapon1, Move.Weapon2,
                                                                   Move.Weapon3, Move.Weapon4, Move.Weapon5, Move.Crouch, Move.MovementModifier)))
                                                                   
        input.move:Scale(0)
    
    end

    Player.HandleButtons(self, input)
    
    self:UpdateThrusters(input)
    --self:UpdateRepairs(input)
    --self:UpdateShields(input)

    if bit.band(input.commands, Move.Drop) ~= 0 then
       self:EjectExo()
    end
    
end

function Exo:UpdateThrusters(input)

    local lastThrustersActive = self.thrustersActive
    local jumpPressed = bit.band(input.commands, Move.Jump) ~= 0
    local movementSpecialPressed = bit.band(input.commands, Move.MovementModifier) ~= 0
    local thrusterDesired = (movementSpecialPressed) and self:GetIsThrusterAllowed()
    
    if thrusterDesired ~= lastThrustersActive then
    
        if thrusterDesired then
                
            local desiredMode = 
                jumpPressed and kExoThrusterMode.Vertical 
                or input.move.x < 0 and kExoThrusterMode.StrafeLeft 
                or input.move.x > 0 and kExoThrusterMode.StrafeRight
                or input.move.z < 0 and kExoThrusterMode.DodgeBack 
                or input.move.z > 0 and kExoThrusterMode.Horizontal
                or nil
                
            local now = Shared.GetTime()
            if desiredMode and self:GetFuel() >= kMinFuelForThrusterActivation and
                    now >= self.timeThrustersEnded + kMinTimeBetweenThrusterActivations then

                self:HandleThrusterStart(desiredMode)
            end

        else
            self:HandleThrusterEnd()
        end
        
    end
    
    if self.thrustersActive and self:GetFuel() == 0 then
        self:HandleThrusterEnd()
    end

end

function Exo:CalculateWeight()
    return ModularExo_GetConfigWeight(ModularExo_ConvertNetMessageToConfig(self))
end

Shared.LinkClassToMap("Exo", Exo.kMapName, networkVars, true)
