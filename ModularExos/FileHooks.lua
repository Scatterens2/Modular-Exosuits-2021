ModLoader.SetupFileHook( "lua/Server.lua", "lua/ModularExos/Server.lua", "post" )
ModLoader.SetupFileHook( "lua/Shared.lua", "lua/ModularExos/Shared.lua", "post" )
ModLoader.SetupFileHook( "lua/TechTreeConstants.lua", "lua/ModularExos/TechTreeConstants.lua", "post" )
ModLoader.SetupFileHook( "lua/TechData.lua", "lua/ModularExos/TechData.lua", "post" )
ModLoader.SetupFileHook( "lua/Globals.lua", "lua/ModularExos/Globals.lua", "post" )


ModLoader.SetupFileHook( "lua/MarineTeam.lua", "lua/ModularExos/MarineTeam.lua", "post" )
ModLoader.SetupFileHook( "lua/Marine.lua", "lua/ModularExos/Marine.lua", "post" )


-- Load new Exosuit weapons through Entity.lua
ModLoader.SetupFileHook( "lua/Entity.lua", "lua/ModularExos/Entity.lua", "post" )

ModLoader.SetupFileHook( "lua/Weapons/Marine/Minigun.lua", "lua/ModularExos/ExoWeapons/Minigun.lua", "post" )
ModLoader.SetupFileHook( "lua/Weapons/Marine/Railgun.lua", "lua/ModularExos/ExoWeapons/Railgun.lua", "post" )

-- Weapon Overrides Marine and Alien
ModLoader.SetupFileHook( "lua/Weapons/Marine/ExoWeaponHolder.lua", "lua/ModularExos/ExoWeapons/ExoWeaponHolder.lua", "post" )
ModLoader.SetupFileHook( "lua/Weapons/DotMarker.lua", "lua/ModularExos/ExoWeapons/DotMarker.lua", "post" )

-- Exosuit releavant
ModLoader.SetupFileHook( "lua/ReadyRoomExo.lua", "lua/ModularExos/ReadyRoomExo.lua", "post" )
ModLoader.SetupFileHook( "lua/Player_Client.lua", "lua/ModularExos/Player_Client.lua", "post" )



ModLoader.SetupFileHook( "lua/MarineWeaponEffects.lua", "lua/ModularExos/MarineWeaponEffects.lua", "post" )
ModLoader.SetupFileHook( "lua/NanoShieldMixin.lua", "lua/ModularExos/NanoShieldMixin.lua", "post" )


-- Structure overrides
ModLoader.SetupFileHook( "lua/PrototypeLab.lua", "lua/ModularExos/PrototypeLab.lua", "post" )

-- Shield Related 
ModLoader.SetupFileHook( "lua/PhysicsGroups.lua", "lua/ModularExos/PhysicsGroups.lua", "post" )

--ModLoader.SetupFileHook( "lua/Weapons/Alien/Bomb.lua", "lua/ModularExos/ExoWeapons/Bomb.lua", "post" )
ModLoader.SetupFileHook( "lua/Weapons/Marine/Grenade.lua", "lua/ModularExos/ExoWeapons/Grenade.lua", "post" )

-- Exos
ModLoader.SetupFileHook( "lua/Exosuit.lua", "lua/ModularExos/Exosuit.lua", "post" )
ModLoader.SetupFileHook( "lua/Exo.lua", "lua/ModularExos/Exo.lua", "post" )

-- Other
ModLoader.SetupFileHook( "lua/LiveMixin.lua", "lua/ModularExos/LiveMixin.lua", "post" )

-- BUYMENU HELL
ModLoader.SetupFileHook( "lua/GUIMarineBuyMenu.lua", "lua/ModularExos/GUI/GUIMarineBuyMenu.lua", "post" )





