kExoModuleCategories = enum{
    "PowerSupply",
    "Weapon",
    "Utility",
}
-- The slots that modules go in
kExoModuleSlots = enum{
    "PowerSupply",
    "RightArm",
    "LeftArm",
    "Utility",
}

-- Slot data
kExoModuleSlotsData = {
    [kExoModuleSlots.PowerSupply] = {
        category = kExoModuleCategories.PowerSupply,
        required = true,
    },
    [kExoModuleSlots.LeftArm] = {
        category = kExoModuleCategories.Weapon,
        required = true,
    },
    [kExoModuleSlots.RightArm] = {
        category = kExoModuleCategories.Weapon,
        required = true,
    },
    [kExoModuleSlots.Utility] = {
        category = kExoModuleCategories.Utility,
        required = false,
    },
}

-- Module types
kExoModuleTypes = enum{
    "None",
    "Power1",
    "Claw",
    "Welder",
    "Shield",
	"Railgun",
    "Minigun",
    "Flamethrower",
    "Armor",
	"NanoModule",
    "Thrusters",
    "PhaseModule",
}

-- Information to decide which model to use for weapon combos
kExoArmTypes = enum{
    "Claw",
    "Minigun",
    "Railgun",
}

-- Module type data
kExoModuleTypesData = {
    -- Power modules
    [kExoModuleTypes.Power1] = {
        category = kExoModuleCategories.PowerSupply,
        powerSupply = 10,
        resourceCost = 0,
        weight = 0,
		levels = 1,
		requiredTechId = Exo.PowerTech1,
    },
    
    -- Weapon modules
	[kExoModuleTypes.Claw] = {
        category = kExoModuleCategories.Weapon,
        powerCost = 0,
		resourceCost = kClawCost,
        mapName = Claw.kMapName,
        armType = kExoArmTypes.Claw,
        weight = kClawWeight,
    },
    [kExoModuleTypes.Welder] = {
        category = kExoModuleCategories.Weapon,
        powerCost = 0,
		resourceCost = kExoWelderCost,
        mapName = ExoWelder.kMapName,
        armType = kExoArmTypes.Railgun,
        weight = kExoWelderWeight,
		requiredTechId = Exo.ExoWelderTech
    }, 
	[kExoModuleTypes.Minigun] = {
        category = kExoModuleCategories.Weapon,
        powerCost = 0,
		resourceCost = kMinigunCost,
        mapName = Minigun.kMapName,
        armType = kExoArmTypes.Minigun,
        weight = kMinigunWeight,
		requiredTechId = Exo.MinigunTech
    }, 
	[kExoModuleTypes.Railgun] = {
        category = kExoModuleCategories.Weapon,
        powerCost = 0,
		resourceCost = kRailgunCost,
        mapName = Railgun.kMapName,
        armType = kExoArmTypes.Railgun,
        weight = kRailgunWeight,
		requiredTechId = Exo.RailgunTech
    },
    [kExoModuleTypes.Flamethrower] = {
        category = kExoModuleCategories.Weapon,
        powerCost = 0,
		resourceCost = kExoFlamerCost,
        mapName = ExoFlamer.kMapName,
        armType = kExoArmTypes.Railgun,
        weight = 0.12,
		requiredTechId = Exo.ExoFlamerTech
    },
  /*  [kExoModuleTypes.Shield] = {
        category = kExoModuleCategories.Weapon,
        powerCost = 0,
		resourceCost = kExoShieldCost,
        mapName = ExoShield.kMapName,
        armType = kExoArmTypes.Claw,
        weight = kExoShieldWeight,
		requiredTechId = Exo.ExoShieldTech
    },  */
    
    
    
    -- Utility modules
		[kExoModuleTypes.Thrusters] = {
		category = kExoModuleCategories.Utility,
        powerCost = 0,
		resourceCost = kThrustersCost,
        weight = kThrustersWeight,
		requiredTechId = Exo.ThrusterModuleTech
	
    },
		[kExoModuleTypes.PhaseModule] = {
        category = kExoModuleCategories.Utility,
        powerCost = 0,
		resourceCost = kPhaseModuleCost,
        weight = kPhaseModuleWeight,
		requiredTechId = Exo.PhaseModuleTech

    },
	    [kExoModuleTypes.Armor] = {
        category = kExoModuleCategories.Utility,
        powerCost = 0,
		resourceCost = kArmorModuleCost,
        armorBonus = 150,
        weight = kArmorModuleWeight,
		requiredTechId = Exo.ArmorModuleTech

    },
	--	[kExoModuleTypes.NanoModule] = {
    --    category = kExoModuleCategories.Utility,
    --    powerCost = 0,
	--	resourceCost = kNanoModuleCost,

   -- },

    
    [kExoModuleTypes.None] = { },
}

-- Model data for weapon combos (data[rightArmType][leftArmType])
kExoWeaponRightLeftComboModels = {
    [kExoArmTypes.Minigun] = {
        isValid = true,
        [kExoArmTypes.Minigun] = {
            isValid = true,
            worldModel = "models/marine/exosuit/exosuit_mm.model",
            worldAnimGraph  = "models/marine/exosuit/exosuit_mm.animation_graph",
            viewModel  = "models/marine/exosuit/exosuit_mm_view.model",
			viewAnimGraph = "models/marine/exosuit/exosuit_mm_view.animation_graph",
        },
        [kExoArmTypes.Railgun] = {
            isValid = false,
        },
        [kExoArmTypes.Claw] = {
            isValid = true,
            worldModel = "models/marine/exosuit/exosuit_cm.model",
            worldAnimGraph  = "models/marine/exosuit/exosuit_cm.animation_graph",
            viewModel  = "models/marine/exosuit/exosuit_cm_view.model",
			viewAnimGraph   = "models/marine/exosuit/exosuit_cm_view.animation_graph",
        },
    },
    [kExoArmTypes.Railgun] = {
        isValid = true,
        [kExoArmTypes.Minigun] = {
            isValid = false,
        },
        [kExoArmTypes.Railgun] = {
            isValid = true,
		    worldModel = "models/marine/exosuit/exosuit_rr.model",
            worldAnimGraph  = "models/marine/exosuit/exosuit_rr.animation_graph",
            viewModel  = "models/marine/exosuit/exosuit_rr_view.model",
			viewAnimGraph   = "models/marine/exosuit/exosuit_rr_view.animation_graph",
        },
        [kExoArmTypes.Claw] = {
            isValid = true,
            worldModel = "models/marine/exosuit/exosuit_cr.model",
            worldAnimGraph  = "models/marine/exosuit/exosuit_cr.animation_graph",
            viewModel  = "models/marine/exosuit/exosuit_cr_view.model",
			viewAnimGraph   = "models/marine/exosuit/exosuit_cr_view.animation_graph",
        },
    },
    [kExoArmTypes.Claw] = {
        isValid = false,

        [kExoArmTypes.Minigun] = {
            isValid = false,
        },
        [kExoArmTypes.Railgun] = {
            isValid = false,
        },
        [kExoArmTypes.Claw] = {
            isValid =false,
            worldModel = "models/marine/exosuit/exosuit_cm.model",
            worldAnimGraph  = "models/marine/exosuit/exosuit_cm.animation_graph",
            viewModel  = "models/marine/exosuit/exosuit_cm_view.model",
			viewAnimGraph   = "models/marine/exosuit/exosuit_cm_view.animation_graph",
        },
    },
}
