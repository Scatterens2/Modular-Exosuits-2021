local oldInitTechTree = MarineTeam.InitTechTree
function MarineTeam:InitTechTree()

    local oldSetComplete = TechTree.SetComplete
    TechTree.SetComplete = function() end
    
    oldInitTechTree(self)
        
	self.techTree:AddResearchNode(kTechId.ClawRailgunExosuit,    kTechId.ExosuitTech, kTechId.None)
    self.techTree:AddBuyNode(kTechId.Exosuit,                    kTechId.ExosuitTech, kTechId.None)
		
    TechTree.SetComplete = oldSetComplete
    self.techTree:SetComplete()
    
end

local oldAddResearchNode = TechTree.AddResearchNode
function TechTree:AddResearchNode(techId, prereq1, prereq2, addOnTechId)

    if techId == kTechId.JetpackTech then
	   prereq1 = kTechId.AdvancedArmory
    end
    oldAddResearchNode(self, techId, prereq1, prereq2, addOnTechId)
end

local oldAddBuildNode = TechTree.AddBuildNode
function TechTree:AddBuildNode(techId, prereq1, prereq2, isRequired)

    if techId == kTechId.PrototypeLab then
	   prereq1 = kTechId.Armory
    end
    oldAddBuildNode(self, techId, prereq1, prereq2, addOnTechId)
end