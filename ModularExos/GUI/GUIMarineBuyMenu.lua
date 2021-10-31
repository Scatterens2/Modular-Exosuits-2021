
Script.Load("lua/GUIMarineBuyMenu.lua")
Script.Load("lua/ModularExos/GUI/GUIMarineBuyMenu_Data.lua")

local kWeaponGroupButtonPositions =
{

    [GUIMarineBuyMenu.kButtonGroupFrame_Unlabeled_x2] =
    {
        Vector(4, 4, 0),
        Vector(4, 122, 0)
    },

    [GUIMarineBuyMenu.kButtonGroupFrame_Labeled_x3] =
    {
        Vector(4, 20, 0),
        Vector(4, 140, 0),
        Vector(4, 258, 0),
    },

    [GUIMarineBuyMenu.kButtonGroupFrame_Labeled_x4] =
    {
        Vector(4, 25, 0),
        Vector(4, 143, 0),
        Vector(4, 262, 0),
        Vector(4, 380, 0)
    }

}

local kButtonShowState = enum({
    'Uninitialized',
    'NotHosted',
    'Occupied',
    'Equipped',
    'Unresearched',
    'InsufficientFunds',
    'Available',
    'Disabled', -- Tutorial should block 'Axe' purchasing, for example. Override 'GUIMarineBuyMenu:GetTechIDDisabled(techID)' for this.
})

local kButtonShowStateDefinitions =
{
    [kButtonShowState.Disabled] = {
        ShowError = true,
        Text = "BUYMENU_ERROR_DISABLED",
        TextColor = Color(239/255, 94/255, 80/255)
    },

    [kButtonShowState.NotHosted] = {
        ShowError = true,
        Text = "BUYMENU_ERROR_UNAVAILABLE",
        TextColor = Color(94/255, 116/255, 128/255)
    },

    [kButtonShowState.Occupied] = {
        ShowError = true,
        Text = "BUYMENU_ERROR_OCCUPIED",
        TextColor = Color(94/255, 116/255, 128/255)
    },

    [kButtonShowState.Equipped] = {
        ShowError = true,
        Text = "BUYMENU_ERROR_EQUIPPED",
        TextColor = Color(2/255, 230/255, 255/255)
    },

    [kButtonShowState.Unresearched] = {
        ShowError = true,
        Text = "BUYMENU_ERROR_NOTRESEARCHED",
        TextColor = Color(94/255, 116/255, 128/255)
    },

    [kButtonShowState.InsufficientFunds] = {
        ShowError = true,
        Text = "BUYMENU_ERROR_INSUFFICIENTFUNDS",
        TextColor = Color(239/255, 94/255, 80/255)
    },

    [kButtonShowState.Available] = {
        ShowError = false,
    },
}

local kBuyMenuTexture = "ui/marine_buy_textures.dds"
local kBuyHUDTexture = "ui/marine_buy_icons.dds"
local kRepeatingBackground = "ui/menu/grid.dds"
local kContentBgTexture = "ui/menu/repeating_bg.dds"
local kContentBgBackTexture = "ui/menu/repeating_bg_black.dds"
local kResourceIconTexture = "ui/pres_icon_big.dds"
local kBigIconTexture = "ui/marine_buy_bigicons.dds"
local kButtonTexture = "ui/marine_buymenu_button.dds"
local kMenuSelectionTexture = "ui/marine_buymenu_selector.dds"
local kScanLineTexture = "ui/menu/scanLine_big.dds"
local kArrowTexture = "ui/menu/arrow_horiz.dds"

-- may the creator forgive me for this code...
local kEquippedMouseoverColor = Color(1, 1, 1, 1)
local kEquippedColor = Color(0.5, 0.5, 0.5, 0.5)

local gBigIconIndex = nil
local kSmallIconScale = 0.9


local kDescriptionFontSize = GUIScale(20)
local kScanLineHeight = GUIScale(256)
local kArrowWidth = GUIScale(32)
local kArrowHeight = GUIScale(32)

-- Big Item Icons
local kBigIconSize = GUIScale( Vector(320, 256, 0) )
local kBigIconOffset = GUIScale(20)

local kSmallIconSize = GUIScale( Vector(100, 50, 0) )
local kMenuIconSize = GUIScale( Vector(190, 80, 0) ) * kSmallIconScale
local kSelectorSize = GUIScale( Vector(215, 110, 0) ) * kSmallIconScale
local kIconTopOffset = GUIScale(10)
local kItemIconYOffset = {}

local kEquippedIconTopOffset = GUIScale(58)

local kMenuWidth = GUIScale(190)
local kPadding = GUIScale(8)

local kEquippedWidth = GUIScale(128)

local kBackgroundWidth = GUIScale(600)
local kBackgroundHeight = GUIScale(640)
-- We want the background graphic to look centered around the circle even though there is the part coming off to the right.
local kBackgroundXOffset = GUIScale(0)

local kPlayersTextSize = GUIScale(24)
local kResearchTextSize = GUIScale(24)

local kResourceDisplayHeight = GUIScale(64)

local kResourceIconWidth = GUIScale(32)
local kResourceIconHeight = GUIScale(32)

local kMouseOverInfoTextSize = GUIScale(20)
local kMouseOverInfoOffset = Vector(GUIScale(-30), GUIScale(-20), 0)
local kMouseOverInfoResIconOffset = Vector(GUIScale(-40), GUIScale(-60), 0)

local kButtonWidth = GUIScale(160)
local kButtonHeight = GUIScale(64)

local kItemNameOffsetX = GUIScale(28)
local kItemNameOffsetY = GUIScale(256)

local kItemDescriptionOffsetY = GUIScale(300)
local kItemDescriptionSize = GUIScale( Vector(450, 180, 0) )
local kFont = Fonts.kAgencyFB_Small
local kCloseButtonColor = Color(1, 1, 0, 1)
local kTextColor = Color(kMarineFontColor)

local kDisabledColor = Color(0.5, 0.5, 0.5, 0.5)
local kCannotBuyColor = Color(1, 0, 0, 0.5)
local kEnabledColor = Color(1, 1, 1, 1)

local orig_MarineBuy_GetCosts = MarineBuy_GetCosts
function MarineBuy_GetCosts(techId)
    if techId == kTechId.Exosuit then
        local minResCost = 1337
        for moduleType, moduleTypeName in ipairs(kExoModuleTypes) do
            local moduleTypeData = kExoModuleTypesData[moduleType]
            if moduleTypeData and moduleTypeData.category == kExoModuleCategories.PowerSupply then
                minResCost = math.min(minResCost, moduleTypeData.resourceCost)
            end
        end
        return minResCost
    end
    return orig_MarineBuy_GetCosts(techId)
end

local kConfigAreaXOffset = kPadding
local kConfigAreaYOffset = kPadding
local kUpgradeButtonAreaHeight = GUIScale(30)
--GUIMarineBuyMenu.kUpgradeButtonWidth = GUIScale(160)
--GUIMarineBuyMenu.kUpgradeButtonHeight = GUIScale(64)
local kConfigAreaWidth = 1000
local kConfigAreaHeight = 900

local kSlotPanelBackgroundColor = Color(0.5, 0.8, 0.8, 1)

local kSmallModuleButtonSize = GUIScale(Vector(60, 60, 0))
local kWideModuleButtonSize = GUIScale(Vector(150, 60, 0))
local kMediumModuleButtonSize = GUIScale(Vector(100, 60, 0))
local kWeaponImageSize = GUIScale(Vector(80, 40, 0))
local kUtilityImageSize = GUIScale(Vector(39, 39, 0))
local kModuleButtonGap = GUIScale(7)
local kPanelTitleHeight = GUIScale(35)

GUIMarineBuyMenu.kExoSlotData = {


    [kExoModuleSlots.RightArm] = {
        label = "RIGHT ARM",--label = "EXO_MODULESLOT_RIGHT_ARM",
        xp = 0.0, yp = 0.0, anchorX = GUIItem.Left, gap = kModuleButtonGap*0.4,
        makeButton = function(self, moduleType, moduleTypeData, offsetX, offsetY)
            return self:MakeWeaponModuleButton(moduleType, moduleTypeData, offsetX, offsetY, kExoModuleSlots.RightArm)
        end,
    },
    [kExoModuleSlots.LeftArm] = {
        label = "LEFT ARM",--label = "EXO_MODULESLOT_LEFT_ARM",
        xp = 1.0, yp = 0.0, anchorX = GUIItem.Right, gap = kModuleButtonGap*0.4,
        makeButton = function(self, moduleType, moduleTypeData, offsetX, offsetY)
            return self:MakeWeaponModuleButton(moduleType, moduleTypeData, offsetX, offsetY, kExoModuleSlots.LeftArm)
        end,
    },

    [kExoModuleSlots.Utility] = {
        label = "UTILITY",--label = "EXO_MODULESLOT_UTILITY",
        xp = 0.12, yp = 0.8, anchorX = GUIItem.Left, gap = kModuleButtonGap*0.4,
        makeButton = function(self, moduleType, moduleTypeData, offsetX, offsetY)
            return self:MakeUtilityModuleButton(moduleType, moduleTypeData, offsetX, offsetY)
        end,
    },
}

local orig_GUIMarineBuyMenu_SetHostStructure = GUIMarineBuyMenu.SetHostStructure
function GUIMarineBuyMenu:SetHostStructure(hostStructure)
    orig_GUIMarineBuyMenu_SetHostStructure(self, hostStructure)
    if hostStructure:isa("PrototypeLab") then
        self:_InitializeExoModularButtons()
        self:_RefreshExoModularButtons()
    end
end

function  GUIMarineBuyMenu:_InitializeExoModularButtons()
    self.activeExoConfig = nil
    local player = Client.GetLocalPlayer()
    if player and player:isa("Exo") then
        self.activeExoConfig = ModularExo_ConvertNetMessageToConfig(player)
        local isValid, badReason, resourceCost, powerSupply = ModularExo_GetIsConfigValid(self.activeExoConfig)
        self.activeExoConfigResCost = resourceCost
        self.activeExoConfigPowerSupply = powerSupply
        self.exoConfig = self.activeExoConfig
    else
		self.activeExoConfig = {}
        self.activeExoConfigResCost = 0
        self.activeExoConfigPowerSupply = 0
        self.exoConfig = {
            [kExoModuleSlots.PowerSupply] = kExoModuleTypes.Power1,
            [kExoModuleSlots.RightArm   ] = kExoModuleTypes.Minigun,
            [kExoModuleSlots.LeftArm    ] = kExoModuleTypes.Claw,
            [kExoModuleSlots.Utility    ] = kExoModuleTypes.None,
        }
    end
    
    self.modularExoConfigActive = false
    self.modularExoGraphicItemsToDestroyList = {}
    self.modularExoModuleButtonList = {}
	
	-------UPGRADE/BUY Button ---
    self.modularExoBuyButton = GUIManager:CreateGraphicItem()
    table.insert(self.modularExoGraphicItemsToDestroyList, self.modularExoBuyButton)
    self.modularExoBuyButton:SetAnchor(GUIItem.Middle, GUIItem.Center)
    self.modularExoBuyButton:SetSize(Vector(kButtonWidth, kButtonHeight, 0))
	self.modularExoBuyButton:SetPosition(Vector(kConfigAreaXOffset + 0.77*kConfigAreaWidth,kConfigAreaYOffset+0.8*kConfigAreaHeight ,0))
	
	self.modularExoBuyButton:SetTexture(kButtonTexture)
    self.modularExoBuyButton:SetLayer(kGUILayerPlayerHUDForeground4)
    self.rightSideRoot:AddChild(self.modularExoBuyButton)
    
    self.modularExoBuyButtonText = GUIManager:CreateTextItem()
    table.insert(self.modularExoGraphicItemsToDestroyList, self.modularExoBuyButtonText)
    self.modularExoBuyButtonText:SetAnchor(GUIItem.Middle, GUIItem.Center)
    self.modularExoBuyButtonText:SetPosition(Vector(0, 0, 0))
    self.modularExoBuyButtonText:SetFontName(kFont)
    self.modularExoBuyButtonText:SetTextAlignmentX(GUIItem.Align_Center)
    self.modularExoBuyButtonText:SetTextAlignmentY(GUIItem.Align_Center)
    self.modularExoBuyButtonText:SetText("UPGRADE")
    self.modularExoBuyButtonText:SetFontIsBold(true)
    self.modularExoBuyButtonText:SetColor(kCloseButtonColor)
    self.modularExoBuyButton:AddChild(self.modularExoBuyButtonText)
    
    self.modularExoCostText = GUIManager:CreateTextItem()
    table.insert(self.modularExoGraphicItemsToDestroyList, self.modularExoCostText)
    self.modularExoCostText:SetAnchor(GUIItem.Right, GUIItem.Center)
    self.modularExoCostText:SetPosition(Vector(-kPadding*7, 0, 0))
    self.modularExoCostText:SetFontName(kFont)
    self.modularExoCostText:SetTextAlignmentX(GUIItem.Align_Min)
    self.modularExoCostText:SetTextAlignmentY(GUIItem.Align_Center)
    self.modularExoCostText:SetText("69")
    self.modularExoCostText:SetFontIsBold(true)
    self.modularExoCostText:SetColor(kTextColor)
    self.modularExoBuyButton:AddChild(self.modularExoCostText)
    
    self.modularExoCostIcon = GUIManager:CreateGraphicItem()
    table.insert(self.modularExoGraphicItemsToDestroyList, self.modularExoCostIcon)
    self.modularExoCostIcon:SetSize(Vector(kResourceIconWidth * 0.8, kResourceIconHeight * 0.8, 0))
    self.modularExoCostIcon:SetAnchor(GUIItem.Right, GUIItem.Center)
    self.modularExoCostIcon:SetPosition(Vector(-kPadding*11, -kResourceIconHeight*0.4, 0))
    self.modularExoCostIcon:SetTexture(kResourceIconTexture)
    self.modularExoCostIcon:SetColor(kTextColor)
    self.modularExoBuyButton:AddChild(self.modularExoCostIcon)

	
	--BUY/UPGRADE BUTTON ENDS HERE
	
    for slotType, slotGUIDetails in pairs(GUIMarineBuyMenu.kExoSlotData) do
        local panelBackground = GUIManager:CreateGraphicItem()
        table.insert(self.modularExoGraphicItemsToDestroyList, panelBackground)
        panelBackground:SetTexture(kButtonTexture)
        panelBackground:SetColor(kSlotPanelBackgroundColor)
        panelBackground:SetAnchor(GUIItem.Left, GUIItem.Top)
        local panelSize = nil
       
		local slotTypeData = kExoModuleSlotsData[slotType]
		
		local panelTitle = GetGUIManager():CreateTextItem()
		table.insert(self.modularExoGraphicItemsToDestroyList, panelTitle)
		panelTitle:SetFontName(kFont)
		panelTitle:SetFontIsBold(true)
		panelTitle:SetPosition(Vector(kPadding*2, kPadding, 0))
		panelTitle:SetAnchor(GUIItem.Left, GUIItem.Top)
		panelTitle:SetTextAlignmentX(GUIItem.Align_Min)
		panelTitle:SetTextAlignmentY(GUIItem.Align_Min)
		panelTitle:SetColor(kTextColor)
		panelTitle:SetText(slotGUIDetails.label)--(Locale.ResolveString("BUY"))
		panelBackground:AddChild(panelTitle)
		
		local buttonCount = 0
		local startOffsetX = kPadding*1
		local startOffsetY = kPanelTitleHeight
		local offsetX, offsetY = startOffsetX, startOffsetY
		for moduleType, moduleTypeName in ipairs(kExoModuleTypes) do
			local moduleTypeData = kExoModuleTypesData[moduleType]
			local isSameType = (moduleTypeData and moduleTypeData.category == slotTypeData.category)
			if moduleType == kExoModuleTypes.None and not slotTypeData.required then
				isSameType = true
				moduleTypeData = {}
			end
			if isSameType then
				local buttonGraphic, newOffsetX, newOffsetY = slotGUIDetails.makeButton(self, moduleType, moduleTypeData, offsetX, offsetY)
				if newOffsetX ~= offsetX then 
					offsetX = offsetX+slotGUIDetails.gap 
				end
				if newOffsetY ~= offsetY then 
					offsetY = offsetY+slotGUIDetails.gap
				end
				offsetX, offsetY = newOffsetX, newOffsetY
				panelBackground:AddChild(buttonGraphic)
			end
		end
		if offsetX == startOffsetX then 
			offsetX = offsetX+kWideModuleButtonSize.x 
		end 
		
		if offsetY == startOffsetY then 
			offsetY = kSmallModuleButtonSize.y
			panelTitle:SetPosition(Vector(0, 0, 0))
		end
		panelSize = Vector(kWideModuleButtonSize.x+kPadding*1.5, offsetY+kPadding*1, 0)
            
        
        panelBackground:SetSize(panelSize)
        local panelX = slotGUIDetails.xp*kConfigAreaWidth
        local panelY = slotGUIDetails.yp*kConfigAreaHeight
        if slotGUIDetails.anchorX == GUIItem.Right then
            panelX = panelX-panelSize.x
        end
		
		

        panelBackground:SetPosition(Vector(
            0+0 ,
            kConfigAreaYOffset+panelY, 0
        ))
        self.rightSideRoot:AddChild(panelBackground)
    end
end


function GUIMarineBuyMenu:MakeWeaponModuleButton(moduleType, moduleTypeData, offsetX, offsetY, slotType)
    local moduleTypeGUIDetails = GUIMarineBuyMenu.kExoModuleData[moduleType]
    
    local buttonGraphic = GUIManager:CreateGraphicItem()
    table.insert(self.modularExoGraphicItemsToDestroyList, buttonGraphic)
    buttonGraphic:SetSize(kWideModuleButtonSize)
    buttonGraphic:SetAnchor(GUIItem.Left, GUIItem.Top)
    buttonGraphic:SetPosition(Vector(0, offsetY, 0))
    buttonGraphic:SetTexture(kMenuSelectionTexture)
    
    local weaponLabel = GetGUIManager():CreateTextItem()
    table.insert(self.modularExoGraphicItemsToDestroyList, weaponLabel)
    weaponLabel:SetFontName(kFont)
    weaponLabel:SetPosition(Vector(0, 0, 0))
    weaponLabel:SetAnchor(GUIItem.Left, GUIItem.Top)
    --weaponLabel:SetTextAlignmentX(GUIItem.Align_Min)
    --weaponLabel:SetTextAlignmentY(GUIItem.Align_Min)
    weaponLabel:SetColor(kTextColor)
    weaponLabel:SetText(tostring(moduleTypeGUIDetails.label))--(Locale.ResolveString("BUY"))
    buttonGraphic:AddChild(weaponLabel)
    
    local weaponImage = GUIManager:CreateGraphicItem()
    table.insert(self.modularExoGraphicItemsToDestroyList, weaponImage)
    weaponImage:SetPosition(Vector(0, kWeaponImageSize.y*-1, 0))
    weaponImage:SetSize(kWeaponImageSize)
    weaponImage:SetAnchor(GUIItem.Right, GUIItem.Bottom)
    weaponImage:SetTexture(moduleTypeGUIDetails.image)
    weaponImage:SetTexturePixelCoordinates(unpack(moduleTypeGUIDetails.imageTexCoords))
    weaponImage:SetColor(Color(1, 1, 1, 1))
    buttonGraphic:AddChild(weaponImage)
    
    local powerCostLabel = GetGUIManager():CreateTextItem()
    table.insert(self.modularExoGraphicItemsToDestroyList, powerCostLabel)
    powerCostLabel:SetPosition(Vector(0, -kPadding*0.5, 0))
    powerCostLabel:SetFontName(kFont)
    powerCostLabel:SetAnchor(GUIItem.Left, GUIItem.Bottom)
    powerCostLabel:SetTextAlignmentX(GUIItem.Align_Min)
    powerCostLabel:SetTextAlignmentY(GUIItem.Align_Max)
    powerCostLabel:SetColor(kTextColor)
    powerCostLabel:SetText(tostring(moduleTypeData.resourceCost))--(Locale.ResolveString("BUY"))
    buttonGraphic:AddChild(powerCostLabel)
    
    local powerIcon = GUIManager:CreateGraphicItem()
    table.insert(self.modularExoGraphicItemsToDestroyList, powerIcon)
    powerIcon:SetPosition(Vector(0, -kPadding*0.5+kResourceIconHeight * -0.8, 0))
    powerIcon:SetSize(Vector(kResourceIconWidth * 0.8, kResourceIconHeight * 0.8, 0))
    powerIcon:SetAnchor(GUIItem.Left, GUIItem.Bottom)
    powerIcon:SetTexture(kResourceIconTexture)
    --local iconX, iconY = GetMaterialXYOffset(kTechId.PowerSurge)
    --powerIcon:SetTexturePixelCoordinates(iconX*80, iconY*80, iconX*80+80, iconY*80+80)
    powerIcon:SetColor(kTextColor)
    buttonGraphic:AddChild(powerIcon)
    
    table.insert(self.modularExoModuleButtonList, {
        slotType = slotType,
        moduleType = moduleType,
        buttonGraphic = buttonGraphic,
        weaponLabel = weaponLabel, weaponImage = weaponImage,
        costLabel = powerCostLabel, costIcon = powerIcon,
        thingsToRecolor = { weaponLabel, --[[weaponImage,]] powerCostLabel, powerIcon},
    })
    
    offsetY = offsetY+kWideModuleButtonSize.y

    return buttonGraphic, offsetX, offsetY
end

function GUIMarineBuyMenu:MakeUtilityModuleButton(moduleType, moduleTypeData, offsetX, offsetY, slotType)
    local moduleTypeGUIDetails = GUIMarineBuyMenu.kExoModuleData[moduleType]
    
    local buttonGraphic = GUIManager:CreateGraphicItem()
    table.insert(self.modularExoGraphicItemsToDestroyList, buttonGraphic)
    buttonGraphic:SetSize(kMediumModuleButtonSize)
    buttonGraphic:SetAnchor(GUIItem.Left, GUIItem.Top)
    buttonGraphic:SetPosition(Vector(25+offsetX, kPadding, 0))
    buttonGraphic:SetTexture(kMenuSelectionTexture)
    
    local utilityLabel = GetGUIManager():CreateTextItem()
    table.insert(self.modularExoGraphicItemsToDestroyList, utilityLabel)
    utilityLabel:SetFontName(kFont)
    utilityLabel:SetPosition(Vector(kModuleButtonGap*2, 5.5, 0))
    utilityLabel:SetAnchor(GUIItem.Left, GUIItem.Top)
    utilityLabel:SetTextAlignmentX(GUIItem.Align_Min)
    utilityLabel:SetTextAlignmentY(GUIItem.Align_Min)
    utilityLabel:SetColor(kTextColor)
    utilityLabel:SetText(tostring(moduleTypeGUIDetails.label))--(Locale.ResolveString("BUY"))
    buttonGraphic:AddChild(utilityLabel)
    
    local utilityImage = GUIManager:CreateGraphicItem()
    table.insert(self.modularExoGraphicItemsToDestroyList, utilityImage)
    utilityImage:SetPosition(Vector(kWeaponImageSize.x*-0.45, kWeaponImageSize.y*-1, 0))
    utilityImage:SetSize(kUtilityImageSize)
    utilityImage:SetAnchor(GUIItem.Right, GUIItem.Bottom)
    utilityImage:SetTexture(moduleTypeGUIDetails.image)
    utilityImage:SetTexturePixelCoordinates(unpack(moduleTypeGUIDetails.imageTexCoords))
    utilityImage:SetColor(Color(1, 1, 1, 1))
    buttonGraphic:AddChild(utilityImage)
    
    local powerCostLabel = GetGUIManager():CreateTextItem()
    table.insert(self.modularExoGraphicItemsToDestroyList, powerCostLabel)
    powerCostLabel:SetPosition(Vector(kModuleButtonGap*2.3, -kPadding*0.5, 0))
    powerCostLabel:SetFontName(kFont)
    powerCostLabel:SetAnchor(GUIItem.Left, GUIItem.Bottom)
    powerCostLabel:SetTextAlignmentX(GUIItem.Align_Min)
    powerCostLabel:SetTextAlignmentY(GUIItem.Align_Max)
    powerCostLabel:SetColor(kTextColor)
    powerCostLabel:SetText(tostring(moduleTypeData.resourceCost or "0"))--(Locale.ResolveString("BUY"))
    buttonGraphic:AddChild(powerCostLabel)
    
    local powerIcon = GUIManager:CreateGraphicItem()
    table.insert(self.modularExoGraphicItemsToDestroyList, powerIcon)
    powerIcon:SetPosition(Vector(kModuleButtonGap*4.3, -kPadding*0.5+kResourceIconHeight * -0.8, 0))
    powerIcon:SetSize(Vector(kResourceIconWidth * 0.8, kResourceIconHeight * 0.8, 0))
    powerIcon:SetAnchor(GUIItem.Left, GUIItem.Bottom)
    powerIcon:SetTexture(kResourceIconTexture)
   --local iconX, iconY = GetMaterialXYOffset(kTechId.PowerSurge)
   --powerIcon:SetTexturePixelCoordinates(iconX*80, iconY*80, iconX*80+80, iconY*80+80)
    powerIcon:SetColor(kTextColor)
    buttonGraphic:AddChild(powerIcon)
    
    table.insert(self.modularExoModuleButtonList, {
        slotType = kExoModuleSlots.Utility,
        moduleType = moduleType,
        buttonGraphic = buttonGraphic,
        utilityLabel = utilityLabel, utilityImage = utilityImage,
        costLabel = powerCostLabel, costIcon = powerIcon,
        thingsToRecolor = { utilityLabel, --[[utilityImage,]] powerCostLabel, powerIcon},
    })
    
    offsetX = offsetX+kMediumModuleButtonSize.x
    return buttonGraphic, offsetX, offsetY
end

local orig_GUIMarineBuyMenu_Update = GUIMarineBuyMenu.Update
function GUIMarineBuyMenu:Update()
    orig_GUIMarineBuyMenu_Update(self)
    self:_UpdateExoModularButtons()
end

local function GetIsMouseOver(self, overItem)

    local mouseX, mouseY = Client.GetCursorPosScreen()
    local mouseOver = GUIItemContainsPoint(overItem, mouseX, mouseY, true)
    if mouseOver and not self.mouseOverStates[overItem] then
        MarineBuy_OnMouseOver()
    end

    local changed = self.mouseOverStates[overItem] ~= mouseOver
    self.mouseOverStates[overItem] = mouseOver
    return mouseOver, changed
    
end

function GUIMarineBuyMenu:_UpdateExoModularButtons(deltaTime)
	if self.hoveringExo then

	   self:_RefreshExoModularButtons()
        if not MarineBuy_IsResearched(kTechId.DualMinigunExosuit) or PlayerUI_GetPlayerResources() < self.exoConfigResourceCost-self.activeExoConfigResCost then
            self.modularExoBuyButton:SetColor(Color(1, 0, 0, 1))
            
            self.modularExoBuyButtonText:SetColor(Color(0.5, 0.5, 0.5, 1))
            self.modularExoCostText:SetColor(kCannotBuyColor)
            self.modularExoCostIcon:SetColor(kCannotBuyColor)
        else
            if GetIsMouseOver(self, self.modularExoBuyButton) then
                self.modularExoBuyButton:SetColor(Color(1, 1, 1, 1))
            else
                self.modularExoBuyButton:SetColor(Color(0.5, 0.5, 0.5, 1))
            end
            
            self.modularExoBuyButtonText:SetColor(kCloseButtonColor)
            self.modularExoCostText:SetColor(kTextColor)
            self.modularExoCostIcon:SetColor(kTextColor)
        end
        for buttonI, buttonData in ipairs(self.modularExoModuleButtonList) do
            if GetIsMouseOver(self, buttonData.buttonGraphic) then
                if buttonData.state == "enabled" then
                    buttonData.buttonGraphic:SetColor(Color(0, 0.7, 1, 1))
                end
            else
                buttonData.buttonGraphic:SetColor(buttonData.col)
            end
        end
    end
end

local oldSetDetails = GUIMarineBuyMenu._SetDetailsSectionTechId
function GUIMarineBuyMenu:_SetDetailsSectionTechId(techId, techCost)

	oldSetDetails(self, techId, techCost)


	if techId == kTechId.DualMinigunExosuit then
		self.itemTitle:SetIsVisible(false)
		self.costText:SetIsVisible(false)
		self.itemDescription:SetIsVisible(false)
		self.bigPicture:SetPosition(Vector(375, 100, 0))
		self.bigPicture:SetAnchor(GUIItem.Top, GUIItem.Left)
		
		self.currentMoneyText:SetIsVisible(false)
		self.currentMoneyTextIcon:SetIsVisible(false)
		self.rangeBar:SetIsVisible(false)
        self.vsStructuresBar:SetIsVisible(false)
        self.vsLifeformBar:SetIsVisible(false)

        self.rangeText:SetIsVisible(false)
        self.vsStructuresText:SetIsVisible(false)
        self.vsLifeformsText:SetIsVisible(false)
	else
		self.itemTitle:SetIsVisible(true)
		self.costText:SetIsVisible(true)
		self.itemDescription:SetIsVisible(true)
		self.bigPicture:SetIsVisible(true)
		self.currentMoneyText:SetIsVisible(true)
		self.currentMoneyTextIcon:SetIsVisible(true)
	
	end

end



function GUIMarineBuyMenu:_RefreshExoModularButtons()
    local isValid, badReason, resourceCost, powerSupply, powerCost, texturePath = ModularExo_GetIsConfigValid(self.exoConfig)
    resourceCost = resourceCost or 0
    self.exoConfigResourceCost = resourceCost
    self.modularExoCostText:SetText(tostring(resourceCost-self.activeExoConfigResCost))
    
    for buttonI, buttonData in ipairs(self.modularExoModuleButtonList) do
        local current = self.exoConfig[buttonData.slotType]
        local col = nil
        local canAfford = true
        if current == buttonData.moduleType then
            if PlayerUI_GetPlayerResources() < self.exoConfigResourceCost-self.activeExoConfigResCost then
                --buttonData.state = "disabled"
               -- buttonData.buttonGraphic:SetColor(kDisabledColor)
                col = kDisabledColor
               --canAfford = false
            else
                buttonData.state = "selected"
                buttonData.buttonGraphic:SetColor(kEnabledColor)
                col = kEnabledColor
            end
        else
            self.exoConfig[buttonData.slotType] = buttonData.moduleType
            local isValid, badReason, resourceCost, powerSupply, powerCost, texturePath = ModularExo_GetIsConfigValid(self.exoConfig)
            if buttonData.slotType == kExoModuleSlots.PowerSupply then
                if buttonData.powerSupply < self.activeExoConfigPowerSupply then
                    isValid = false
                    badReason = "no refunds!"
                elseif isValid then
                    resourceCost = resourceCost-self.activeExoConfigResCost
                    if PlayerUI_GetPlayerResources() < resourceCost then
                        isValid = false
                        canAfford = false
                    end
                elseif badReason == "not enough power" then
                    isValid = true
                    buttonData.forceToDefaultConfig = true
                else
                    buttonData.forceToDefaultConfig = false
                end
            end
            if buttonData.slotType == kExoModuleSlots.RightArm and badReason == "bad model left" then
                isValid = true
                buttonData.forceLeftToClaw = true
            else
                buttonData.forceLeftToClaw = false
            end
            if isValid then
                buttonData.state = "enabled"
                buttonData.buttonGraphic:SetColor(kDisabledColor)
                col = kDisabledColor
            else
                buttonData.state = "disabled"
                buttonData.buttonGraphic:SetColor(kDisabledColor)
                col = kDisabledColor
                if badReason == "not enough power" then
                    canAfford = false
                end
            end
            if not isValid and (badReason == "bad model right" or badReason == "bad model left") then
                col = Color(0.2, 0.2, 0.2, 0.4)
                buttonData.weaponImage:SetColor(Color(0.2, 0.2, 0.2, 0.4))
            elseif buttonData.weaponImage ~= nil then
                buttonData.weaponImage:SetColor(Color(1, 1, 1, 1))
            end
            self.exoConfig[buttonData.slotType] = current
        end
        buttonData.col = col
        for thingI, thing in ipairs(buttonData.thingsToRecolor) do
            thing:SetColor(col)
        end
        if not canAfford then
            if buttonData.costLabel then buttonData.costLabel:SetColor(kCannotBuyColor) end
            if buttonData.costIcon then buttonData.costIcon:SetColor(kCannotBuyColor) end
        end
    end
end

local function HandleItemClicked(self)

    if self.hoveredBuyButton then

        local item = self.hoveredBuyButton

        local researched = self:_GetResearchInfo(item.TechID)
        local itemCost = MarineBuy_GetCosts(item.TechID)
        local canAfford = PlayerUI_GetPlayerResources() >= itemCost
        local hasItem = PlayerUI_GetHasItem(item.TechID)

        if not item.Disabled and researched and canAfford and not hasItem and item.TechID ~= kTechId.DualMinigunExosuit then

            MarineBuy_PurchaseItem(item.TechID)
            MarineBuy_OnClose()

            return true, true

        end

    end
	if self.hoveringExo then
		if GetIsMouseOver(self, self.modularExoBuyButton) and MarineBuy_IsResearched(kTechId.Exosuit) then
			
			Client.SendNetworkMessage("ExoModularBuy", ModularExo_ConvertConfigToNetMessage(self.exoConfig))
			MarineBuy_OnClose()
			return true, true
		end
		for buttonI, buttonData in ipairs(self.modularExoModuleButtonList) do
			if GetIsMouseOver(self, buttonData.buttonGraphic) then
				if buttonData.state == "enabled" then
					self.exoConfig[buttonData.slotType] = buttonData.moduleType
					if buttonData.forceToDefaultConfig then
						self.exoConfig[kExoModuleSlots.RightArm] = kExoModuleTypes.Minigun
						self.exoConfig[kExoModuleSlots.LeftArm ] = kExoModuleTypes.Claw
						self.exoConfig[kExoModuleSlots.Utility ] = kExoModuleTypes.None
					end
					if buttonData.forceLeftToClaw then
						self.exoConfig[kExoModuleSlots.LeftArm] = kExoModuleTypes.Claw
					end
					self:_RefreshExoModularButtons()
				end
			end
		end
	end
    return false, false
    
end


local origUpdate = GUIMarineBuyMenu.Update
function GUIMarineBuyMenu:Update(deltaTime)
	origUpdate(self, deltaTime)
		
	if self.hoveredBuyButton and self.hoveredBuyButton.TechID == kTechId.DualMinigunExosuit or (self.hoveredBuyButton == nil and self.hoveringExo) then
		self.hoveringExo = true
        self.modularExoConfigActive = true
        for elementI, element in ipairs(self.modularExoGraphicItemsToDestroyList) do
            element:SetIsVisible(true)
        end
        
        return
    end
    if self.modularExoGraphicItemsToDestroyList then
        self.hoveringExo = false
        self.modularExoConfigActive = false
        for elementI, element in ipairs(self.modularExoGraphicItemsToDestroyList) do
            element:SetIsVisible(false)
        end
    end
end

function GUIMarineBuyMenu:SendKeyEvent(key, down)

    local closeMenu = false
    local inputHandled = false

    if key == InputKey.MouseButton0 and self.mousePressed ~= down then

        self.mousePressed = down

        if down then
            inputHandled, closeMenu = HandleItemClicked(self)
        end

    end

    -- No matter what, this menu consumes MouseButton0/1.
    if key == InputKey.MouseButton0 or key == InputKey.MouseButton1 then
        inputHandled = true
    end

    if InputKey.Escape == key and not down then

        closeMenu = true
        inputHandled = true
        MarineBuy_OnClose()

    end

    if closeMenu then
        MarineBuy_Close()
    end

    return inputHandled
    
end

function GUIMarineBuyMenu:CreatePrototypeLabUI()

    self.defaultTechId = kTechId.Jetpack

    self.background = self:CreateAnimatedGraphicItem()
    self.background:SetTexture(self.kPrototypeLabBackgroundTexture)
    self.background:SetSizeFromTexture()
    self.background:SetIsScaling(false)
    self.background:SetAnchor(GUIItem.Middle, GUIItem.Center)
    self.background:SetHotSpot(Vector(0.5, 0.5, 0))
    self.background:SetScale(self.customScaleVector)
    self.background:SetOptionFlag(GUIItem.CorrectScaling)
    self.background:SetLayer(kGUILayerMarineBuyMenu)

    local buttonGroupX = 97
    local buttonGroupY = 149

    local buttonPositions = kWeaponGroupButtonPositions[self.kButtonGroupFrame_Unlabeled_x2]

    local buttonGroup = self:CreateAnimatedGraphicItem()
    buttonGroup:AddAsChildTo(self.background)
    buttonGroup:SetIsScaling(false)
    buttonGroup:SetPosition(Vector(buttonGroupX, buttonGroupY, 0))
    buttonGroup:SetTexture(self.kButtonGroupFrame_Unlabeled_x2)
    buttonGroup:SetSizeFromTexture()
    buttonGroup:SetOptionFlag(GUIItem.CorrectScaling)
    self:_InitializeWeaponGroup(buttonGroup, buttonPositions,
    {
        kTechId.Jetpack,
        kTechId.DualMinigunExosuit,
            })

    local groupLabel = self:CreateAnimatedTextItem()
    groupLabel:SetIsScaling(false)
    groupLabel:AddAsChildTo(buttonGroup)
    groupLabel:SetPosition(Vector(330, -1, 0))
    groupLabel:SetAnchor(GUIItem.Left, GUIItem.Top)
    groupLabel:SetTextAlignmentX(GUIItem.Align_Min)
    groupLabel:SetTextAlignmentY(GUIItem.Align_Min)
    groupLabel:SetText(Locale.ResolveString("BUYMENU_GROUPLABEL_SPECIAL"))
    groupLabel:SetOptionFlag(GUIItem.CorrectScaling)
    GUIMakeFontScale(groupLabel, "kAgencyFB", 24)

    local rightSideStartPos = Vector(580, 38, 0)
    self:_CreateRightSide(rightSideStartPos)

end