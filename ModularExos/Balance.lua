-- Module pricing
kExoWelderCost = 20
kRailgunCost = 30

kMinigunCost = 35
kExoFlamerCost = 30
kExoShieldCost = 35
kClawCost = 10
kPhaseModuleCost = 15
kThrustersCost = 15
kArmorModuleCost = 15
kNanoModuleCost = 10


kMinigunMovementSlowdown = 1
kRailgunMovementSlowdown = 1



--Exo

Exo.kExosuitArmor = kExosuitArmor
Exo.kExosuitArmorPerUpgradeLevel = kExosuitArmorPerUpgradeLevel
Exo.kVertThrust = 0
Exo.kHorizThrust = 50
Exo.kMaxSpeed = 6
Exo.kThrustersCooldownTime = 2.5
Exo.kThrusterDuration = 5

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


--Tech Research

Exo.ExoShieldTech = kTechId.ExosuitTech
Exo.ExoFlamerTech = kTechId.ExosuitTech
Exo.ExoWelderTech = kTechId.ExosuitTech
Exo.RailgunTech = kTechId.ExosuitTech
Exo.MinigunTech = kTechId.ExosuitTech
Exo.PowerTech1 = kTechId.ExosuitTech
Exo.PowerTech2 = kTechId.ExosuitTech
Exo.PowerTech3 = kTechId.ExosuitTech
Exo.ArmorModuleTech = kTechId.ExosuitTech
Exo.PhaseModuleTech = kTechId.ExosuitTech
Exo.ThrusterModuleTech = kTechId.ExosuitTech

--Weapons
/*
--RAILGUN --
kRailgunDamage = 30
kRailChargeDamage = 50
Railgun.kRailChargeDamage = 50
Railgun.kChargeTime = 2
Railgun.kChargeForceShootTime = 2.2
Railgun.kRailgunRange = 400
Railgun.kRailgunSpread = Math.Radians(0)
Railgun.kBulletSize = 0.3
Railgun.kRailgunMovementSlowdown = 0.8
Railgun.kRailgunChargeTime = 1.4
Railgun.kRailgunDamage = 30
*/

kRailgunWeight = 0.1
kRailgunDamage = 35
kRailgunChargeDamage = 175

-- CLAW
kClawWeight = 0.00
kClawDamage = 50 --Default 50

-- MINIGUN --

kMinigunDamage = 10 -- original value 6 but only a dual minigun is available
kMinigunDamageType = kDamageType.Heavy --original heavy
kMinigunWeight = 0.15

-- FLAMETHROWER --
kExoFlamerWeight = 0.12

ExoFlamer.kConeWidth = 0.17
ExoFlamer.kCoolDownRate = 0.20
ExoFlamer.kDualGunHeatUpRate = 0.03
ExoFlamer.kHeatUpRate = 0.1
ExoFlamer.kFireRate = 1/3
ExoFlamer.kTrailLength = 15.5
ExoFlamer.kExoFlamerDamage = 15
kExoFlamerRange = 15

-- WELDER --
kExoWelderWeight = 0.05
ExoWelder.kWeldRange = 4
ExoWelder.kWelderEffectRate = 0.45
ExoWelder.kHealScoreAdded = 2
ExoWelder.kAmountHealedForPoints = 600
ExoWelder.kWelderFireDelay = 0.2
ExoWelder.kWelderDamagePerSecond = 30
ExoWelder.kSelfWeldAmount = 3
ExoWelder.kPlayerWeldRate = 30
ExoWelder.kStructureWeldRate = 60

-- SHIELD --
kExoShieldWeight = 0.08
ExoShield.kHeatPerDamage = 0.0015

ExoShield.kHeatUndeployedDrainRate = 0.2
ExoShield.kHeatActiveDrainRate = 0.1
ExoShield.kHeatOverheatedDrainRate = 0.13
ExoShield.kHeatCombatDrainRate = 0.05
ExoShield.kCombatDuration = 2.5

ExoShield.kIdleBaseHeatMin = 0.0
ExoShield.kIdleBaseHeatMax = 0.2
ExoShield.kIdleBaseHeatMaxDelay = 10--30
ExoShield.kCombatBaseHeatExtra = 0.1
ExoShield.kOverheatCooldownGoal = 0

ExoShield.kCorrodeDamageScalar = 0.5 -- move to ModularExo_Balance.lua!

ExoShield.kContactEnergyDrainRateFixed = 0 -- X energy per second
ExoShield.kContactEnergyDrainRatePercent = 0.1 -- X% of energy per second

ExoShield.kShieldOnDelay = 0.1
ExoShield.kShieldToggleDelay = 0.1 -- prevent spamming (should be longer than kShieldOnDelay)

ExoShield.kShieldDistance = 2.2
--ExoShield.kShieldAnglePitchMin = math.rad(50) -- down
--ExoShield.kShieldAnglePitchMax = math.rad(50) -- up
ExoShield.kShieldHeightMin = 2.1 -- down
ExoShield.kShieldHeightMax = 1

ExoShield.kPhysBodyColCount = 6
ExoShield.kPhysBodyRowCount = 3
ExoShield.kShieldDepth = 0.1
ExoShield.kShieldEffectOnDelay = 1
ExoShield.kShieldEffectOffDelay = 0.6

-- Thrusters
kThrustersWeight = 0.05
kPhaseModuleWeight = 0.1
kArmorModuleWeight = 0.15