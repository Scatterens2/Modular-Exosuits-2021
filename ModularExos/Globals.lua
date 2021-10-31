/*function GetPrecachedCosmeticMaterial( className, variantId, viewOnly )
    if className == "Claw"  then
		className = "Minigun"
	elseif (className == "ExoWelder") or (className ==  "ExoFlamer") then
		className = "Railgun"
	end
	
	assert(className and className ~= "")
    assert(variantId)
    assert(kPrecachedCosmeticMaterials[className])
    assert(kPrecachedCosmeticMaterials[className][variantId])
	
    if viewOnly then
    --View Model material

        if kPrecachedCosmeticMaterials[className][variantId].viewMaterial then
            return kPrecachedCosmeticMaterials[className][variantId].viewMaterial
        end

        if kPrecachedCosmeticMaterials[className][variantId].viewMaterials then
            return kPrecachedCosmeticMaterials[className][variantId].viewMaterials
        end

        Log("ERROR: No view materials matched for Class[%s] of Variant[%s]", className, variantId)
        return false

    end

    if kPrecachedCosmeticMaterials[className][variantId].worldMaterial then
        return kPrecachedCosmeticMaterials[className][variantId].worldMaterial
    end

    if kPrecachedCosmeticMaterials[className][variantId].worldMaterials then
        return kPrecachedCosmeticMaterials[className][variantId].worldMaterials
    end

    Log("ERROR: No world materials matched for Class[%s] of Variant[%s]", className, variantId)
    return false
end*/