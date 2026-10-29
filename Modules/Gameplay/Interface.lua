-------------------------------------------------------------------------------
-- Project: AscensionAccountSync
-- Author: Aka-DoctorCode
-- File: Modules/Gameplay/Interface.lua
-------------------------------------------------------------------------------
---@diagnostic disable: undefined-global, undefined-field, inject-field

local addonName, AAS = ...

AAS.Modules = AAS.Modules or {}
AAS.Modules.Interface = {}
local Interface = AAS.Modules.Interface

Interface.Name = "Interface"
Interface.Title = "Interface Options"

Interface.Definitions = {
    -- 1. DISPLAY
    inGameNavigation = {
        title = "In Game Navigation",
        type = "cvar",
        cvar = "showInGameNavigation",
        group = "display",
    },
    tutorials = {
        title = "Tutorials",
        type = "cvar",
        cvar = "showTutorials",
        group = "display",
    },
    outlineMode = {
        title = "Outline Mode",
        type = "cvar",
        cvar = "Outline",
        group = "display",
    },
    statusText = {
        title = "Status Text",
        type = "cvar",
        cvar = "statusTextDisplay",
        group = "display",
    },
    chatBubbles = {
        title = "Chat Bubbles",
        type = "cvar",
        cvar = "chatBubbles",
        group = "display",
    },
    chatBubblesParty = {
        title = "Party Chat Bubbles",
        type = "cvar",
        cvar = "chatBubblesParty",
        group = "display",
    },
    chatBubblesRaid = {
        title = "Instance and Raid Chat Bubbles",
        type = "cvar",
        cvar = "chatBubblesRaid",
        group = "display",
    },
    replaceOtherPlayerPortraits = {
        title = "Replace Player Frame Portraits",
        type = "cvar",
        cvar = "ReplaceOtherPlayerPortraits",
        group = "display",
    },
    replaceMyPlayerPortrait = {
        title = "Replace My Frame Portrait",
        type = "cvar",
        cvar = "ReplaceMyPlayerPortrait",
        group = "display",
    },

    -- 2. QUESTS
    showWarbandCompletedQuests = {
        title = "Show Warband Completed Quests",
        type = "tracking",
        tracking = "AccountCompletedQuests",
        group = "quests",
    },
    showLowLevelQuests = {
        title = "Show Low-Level Quests",
        type = "tracking",
        tracking = "TrivialQuests",
        group = "quests",
    },

    -- 3. RAID FRAMES
    raidIncomingHeals = {
        title = "Display Incoming Heals",
        type = "cvar",
        cvar = "raidFramesDisplayIncomingHeals",
        group = "raidFrames",
    },
    raidPowerBars = {
        title = "Display Power Bars",
        type = "cvar",
        cvar = "raidFramesDisplayPowerBars",
        group = "raidFrames",
    },
    raidOnlyHealerPowerBars = {
        title = "Display Only Healer Power Bars",
        type = "cvar",
        cvar = "raidFramesDisplayOnlyHealerPowerBars",
        group = "raidFrames",
    },
    raidAggroHighlight = {
        title = "Display Aggro Highlight",
        type = "cvar",
        cvar = "raidFramesDisplayAggroHighlight",
        group = "raidFrames",
    },
    raidClassColors = {
        title = "Display Class Colors",
        type = "cvar",
        cvar = "raidFramesDisplayClassColor",
        group = "raidFrames",
    },
    raidHealthBarColorBG = {
        title = "Background Color",
        type = "cvar",
        cvar = "raidFramesHealthBarColorBG",
        group = "raidFrames",
    },
    raidPets = {
        title = "Display Pets",
        type = "cvar",
        cvar = "raidOptionDisplayPets",
        group = "raidFrames",
    },
    raidMainTankAndAssist = {
        title = "Display Main Tank and Assist",
        type = "cvar",
        cvar = "raidOptionDisplayMainTankAndAssist",
        group = "raidFrames",
    },
    raidDebuffs = {
        title = "Show Debuffs",
        type = "cvar",
        cvar = "raidFramesDisplayDebuffs",
        group = "raidFrames",
    },
    raidBiggerRoleDebuffs = {
        title = "Bigger Role Debuffs",
        type = "cvar",
        cvar = "raidFramesDisplayLargerRoleSpecificDebuffs",
        group = "raidFrames",
    },
    raidOnlyDispellableDebuffs = {
        title = "Display Only Dispellable Debuffs",
        type = "cvar",
        cvar = "raidFramesDisplayOnlyDispellableDebuffs",
        group = "raidFrames",
    },
    raidCenterBigDefensives = {
        title = "Center Big Defensives",
        type = "cvar",
        cvar = "raidFramesCenterBigDefensive",
        group = "raidFrames",
    },
    raidDispelIndicatorType = {
        title = "Dispellable Debuff Indicator",
        type = "cvar",
        cvar = "raidFramesDispelIndicatorType",
        group = "raidFrames",
    },
    raidDispelIndicatorColor = {
        title = "Debuff Indicator Color",
        type = "cvar",
        cvar = "raidFramesDispelIndicatorOverlay",
        group = "raidFrames",
    },
    raidDispelIndicatorFlashing = {
        title = "Flashing Animation",
        type = "cvar",
        cvar = "raidFramesDispelIndicatorOverlayAnimation",
        group = "raidFrames",
    },
    raidDispelIndicatorAnimatedBorder = {
        title = "Animated Border",
        type = "cvar",
        cvar = "raidFramesDispelIndicatorAnimatedBorder",
        group = "raidFrames",
    },
    raidHealthText = {
        title = "Display Health Text",
        type = "cvar",
        cvar = "raidFramesHealthText",
        group = "raidFrames",
    },

    -- 4. ARENA ENEMY FRAMES
    arenaPowerBars = {
        title = "Display Power Bars",
        type = "cvar",
        cvar = "pvpFramesDisplayPowerBars",
        group = "arenaFrames",
    },
    arenaOnlyHealerPowerBars = {
        title = "Display Only Healer Power Bars",
        type = "cvar",
        cvar = "pvpFramesDisplayOnlyHealerPowerBars",
        group = "arenaFrames",
    },
    arenaClassColors = {
        title = "Display Class Colors",
        type = "cvar",
        cvar = "pvpFramesDisplayClassColor",
        group = "arenaFrames",
    },
    arenaPets = {
        title = "Display Pets",
        type = "cvar",
        cvar = "pvpOptionDisplayPets",
        group = "arenaFrames",
    },
    arenaHealthText = {
        title = "Display Health Text",
        type = "cvar",
        cvar = "pvpFramesHealthText",
        group = "arenaFrames",
    },

    -- 5. HOUSING
    housingLightRadius = {
        title = "Light Radius Indicators",
        type = "cvar",
        cvar = "housingDecorLightRadiusIndicatorsEnabled",
        group = "housing",
    },
    housingSelectedDecor = {
        title = "Selected Decor",
        type = "cvar",
        cvar = "housingSelectedDecorLightRadiusIndicatorType",
        group = "housing",
    },
    housingOtherDecor = {
        title = "Other Decor",
        type = "cvar",
        cvar = "housingOtherDecorLightRadiusIndicatorType",
        group = "housing",
    },

    -- 6. MAP COORDINATES
    playerMapCoords = {
        title = "Player Map Coordinates",
        type = "cvar",
        cvar = "worldMapShowPlayerCoords",
        group = "mapCoordinates",
    },
    cursorMapCoords = {
        title = "Cursor Map Coordinates",
        type = "cvar",
        cvar = "worldMapShowCursorCoords",
        group = "mapCoordinates",
    },
    playerMinimapCoords = {
        title = "Player Minimap Coordinates",
        type = "cvar",
        cvar = "minimapShowPlayerCoords",
        group = "mapCoordinates",
    },
    coordsInTenths = {
        title = "Coordinates in Tenths",
        type = "cvar",
        cvar = "coordsByTenths",
        group = "mapCoordinates",
    },
}

-- Fast lookup maps
local cvarToKey = {}
local trackingToKey = {}
for key, def in pairs(Interface.Definitions) do
    if def.cvar then
        cvarToKey[string.upper(def.cvar)] = key
    elseif def.tracking then
        trackingToKey[string.upper(def.tracking)] = key
    end
end

local isApplying = false

--- Helper to read minimap tracking state
local function GetTrackingState(trackingName)
    if not C_Minimap or not C_Minimap.GetNumTrackingTypes then return nil end
    local count = C_Minimap.GetNumTrackingTypes()
    for i = 1, count do
        local name, _, active, category = C_Minimap.GetTrackingInfo(i)
        if name == trackingName or category == trackingName then
            return active and "1" or "0"
        end
    end
    if trackingName == "AccountCompletedQuests" and C_Minimap.IsTrackingAccountCompletedQuests then
        return C_Minimap.IsTrackingAccountCompletedQuests() and "1" or "0"
    end
    return nil
end

--- Helper to set minimap tracking state
local function SetTrackingState(trackingName, val)
    if not C_Minimap or not C_Minimap.GetNumTrackingTypes then return false end
    local active = (val == "1" or val == true or val == 1)
    local count = C_Minimap.GetNumTrackingTypes()
    for i = 1, count do
        local name, _, currentActive, category = C_Minimap.GetTrackingInfo(i)
        if name == trackingName or category == trackingName then
            if currentActive ~= active then
                C_Minimap.SetTracking(i, active)
                return true
            end
            return false
        end
    end
    return false
end

--- Reads a setting's current in-game value
function Interface:GetInGameValue(key)
    local def = self.Definitions[key]
    if not def then return nil end

    if def.type == "cvar" then
        return GetCVar(def.cvar)
    elseif def.type == "tracking" then
        return GetTrackingState(def.tracking)
    end
    return nil
end

--- Sets an in-game value
function Interface:SetInGameValue(key, value)
    local def = self.Definitions[key]
    if not def or value == nil then return false end

    if def.type == "cvar" then
        local current = GetCVar(def.cvar)
        if current ~= tostring(value) then
            SetCVar(def.cvar, tostring(value))
            return true
        end
    elseif def.type == "tracking" then
        return SetTrackingState(def.tracking, value)
    end
    return false
end

--- Helper to get active profile storage for interface
local function GetStorage()
    if not AAS.db or not AAS.db.profile then return nil end
    AAS.db.profile.gameplay = AAS.db.profile.gameplay or {}
    AAS.db.profile.gameplay.interface = AAS.db.profile.gameplay.interface or {}
    return AAS.db.profile.gameplay.interface
end

--- Applies all enabled Interface settings to the character
function Interface:ApplySettings(savedData, notify)
    savedData = savedData or GetStorage()
    if not savedData then return false end
    isApplying = true

    local changedCount = 0
    local lastChangedTitle = nil

    for key, def in pairs(self.Definitions) do
        if AAS.SyncEngine:IsModuleSyncEnabled(key, "gameplay", "interface") then
            local savedVal = savedData[key]
            if savedVal ~= nil then
                local didChange = self:SetInGameValue(key, savedVal)
                if didChange then
                    changedCount = changedCount + 1
                    lastChangedTitle = def.title
                end
            end
        end
    end

    isApplying = false

    if changedCount > 0 and notify then
        if changedCount == 1 and lastChangedTitle then
            AAS.ShowToast(lastChangedTitle .. " synchronized.")
        else
            AAS.ShowToast("Interface: " .. changedCount .. " settings synchronized.")
        end
    end

    return changedCount > 0
end

--- Saves current in-game settings into the active profile
function Interface:SaveSettings(notify, specificKey)
    if isApplying then return end
    local storage = GetStorage()
    if not storage then return end

    local charKey = AAS:GetCharacterKey()

    if specificKey then
        local def = self.Definitions[specificKey]
        if def and AAS.SyncEngine:IsModuleSyncEnabled(specificKey, "gameplay", "interface") then
            local val = self:GetInGameValue(specificKey)
            storage[specificKey] = val
            storage.lastUpdatedBy = charKey
            storage.lastUpdatedAt = GetServerTime()

            if notify then
                AAS.ShowToast(def.title .. " saved to account.")
            end
        end
    else
        local count = 0
        for key, def in pairs(self.Definitions) do
            if AAS.SyncEngine:IsModuleSyncEnabled(key, "gameplay", "interface") then
                storage[key] = self:GetInGameValue(key)
                count = count + 1
            end
        end
        storage.lastUpdatedBy = charKey
        storage.lastUpdatedAt = GetServerTime()

        if notify and count > 0 then
            AAS.ShowToast("Interface options saved to account.")
        end
    end
end

--- Hooked into CVAR_UPDATE
function Interface:OnCVarUpdate(cvarName)
    if isApplying then return end
    if not cvarName then return end

    local key = cvarToKey[string.upper(cvarName)]
    if key and AAS.SyncEngine:IsModuleSyncEnabled(key, "gameplay", "interface") then
        self:SaveSettings(true, key)
    end
end

--- Hooked into MINIMAP_UPDATE_TRACKING
function Interface:OnTrackingUpdate()
    if isApplying then return end
    for key, def in pairs(self.Definitions) do
        if def.type == "tracking" and AAS.SyncEngine:IsModuleSyncEnabled(key, "gameplay", "interface") then
            local current = self:GetInGameValue(key)
            local storage = GetStorage()
            if storage and storage[key] ~= current then
                self:SaveSettings(true, key)
            end
        end
    end
end
