local oldBuildTechData = BuildTechData
function BuildTechData()
    
    local techData = oldBuildTechData()
							
	table.insert(techData,{ 
	
            [kTechDataId] = kTechId.ExoWelder } )
	
	
	table.insert(techData,{ 
	
            [kTechDataId] = kTechId.ExoFlamer } )
   
    return techData

end


local function TechDataChanges(techData)

    for techIndex, record in ipairs(techData) do
     /*   local techDataId = record[kTechDataId]
		if techDataId == kTechId.Observatory then
            record[kTechDataSupply] = kObservatorySupply
        elseif techDataId == kTechId.SentryBattery then
            record[kTechDataSupply] = kSentryBatterySupply
		end*/
    end
	
end

local oldBuildTechData = BuildTechData
function BuildTechData()
    local techData = oldBuildTechData()
    TechDataChanges(techData)
    return techData
end
