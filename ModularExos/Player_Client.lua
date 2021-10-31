function PlayerUI_GetExoRepairAvailable()

    local player = Client.GetLocalPlayer()

    if player and player:GetIsPlaying() and player:isa("Exo") and player.GetRepairAllowed then

        return player:GetRepairAllowed(), player:GetFuel() >= kExoRepairMinFuel, player.repairActive

    end

    return false, false, false

end

function PlayerUI_GetExoThrustersAvailable()

    local player = Client.GetLocalPlayer()

    if player and player:GetIsPlaying() and player:isa("Exo") and player.GetIsThrusterAllowed then

        return player:GetIsThrusterAllowed(), player:GetFuel() >= kExoThrusterMinFuel, player.thrustersActive

    end

    return false, false, false

end