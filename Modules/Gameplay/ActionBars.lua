-------------------------------------------------------------------------------
-- Project: AscensionAccountSync
-- Author: Aka-DoctorCode
-- File: Modules/Gameplay/ActionBars.lua
-------------------------------------------------------------------------------
---@diagnostic disable: undefined-global, undefined-field, inject-field

local addonName, AAS = ...

AAS.Modules = AAS.Modules or {}
AAS.Modules.ActionBars = {}
local ActionBars = AAS.Modules.ActionBars

ActionBars.Name = "ActionBars"
ActionBars.Title = "Action Bars"

local FRAME_MAP = {
    [2] = "MultiBarBottomLeft",
    [3] = "MultiBarBottomRight",
    [4] = "MultiBarRight",
    [5] = "MultiBarLeft",
    [6] = "MultiBar5",
    [7] = "MultiBar6",
    [8] = "MultiBar7",
}

local function GetBarVisibility(barIndex)
    if Settings and Settings.GetSetting then
        local setting = Settings.GetSetting("PROXY_SHOW_ACTIONBAR_" .. barIndex)
        if setting then
            return setting:GetValue() and true or false
        end
    end
    local frame = _G[FRAME_MAP[barIndex]]
    return frame and frame:IsShown() and true or false
end

local function SetBarVisibility(barIndex, enabled)
    local targetVal = enabled and true or false
    if Settings and Settings.SetValue then
        local setting = Settings.GetSetting and Settings.GetSetting("PROXY_SHOW_ACTIONBAR_" .. barIndex)
        if setting then
            Settings.SetValue("PROXY_SHOW_ACTIONBAR_" .. barIndex, targetVal)
            return
        end
    end

    -- Fallback for legacy bars 2-5 if Settings API not ready
    if barIndex >= 2 and barIndex <= 5 and SetActionBarToggles and GetActionBarToggles then
        local b1, b2, b3, b4 = GetActionBarToggles()
        local toggles = { [2] = b1, [3] = b2, [4] = b3, [5] = b4 }
        toggles[barIndex] = targetVal and 1 or 0
        SetActionBarToggles(toggles[2], toggles[3], toggles[4], toggles[5])
    end

    local frame = _G[FRAME_MAP[barIndex]]
    if frame then
        if targetVal then frame:Show() else frame:Hide() end
    end
end

ActionBars.Definitions = {
    actionBar2 = {
        title = "Action Bar 2",
        type = "actionBar",
        barIndex = 2,
    },
    actionBar3 = {
        title = "Action Bar 3",
        type = "actionBar",
        barIndex = 3,
    },
    actionBar4 = {
        title = "Action Bar 4",
        type = "actionBar",
        barIndex = 4,
    },
    actionBar5 = {
        title = "Action Bar 5",
        type = "actionBar",
        barIndex = 5,
    },
    actionBar6 = {
        title = "Action Bar 6",
        type = "actionBar",
        barIndex = 6,
    },
    actionBar7 = {
        title = "Action Bar 7",
        type = "actionBar",
        barIndex = 7,
    },
    actionBar8 = {
        title = "Action Bar 8",
        type = "actionBar",
        barIndex = 8,
    },
    lockActionBars = {
        title = "Lock Action Bars",
        type = "cvar",
        cvar = "lockActionBars",
    },
    pickupActionKey = {
        title = "Lock Modifier Key",
        type = "modifiedClick",
        action = "PICKUPACTION",
    },
    countdownForCooldowns = {
        title = "Show Numbers for Cooldowns",
        type = "cvar",
        cvar = "countdownForCooldowns",
    },
}

function ActionBars:GetSetting(key)
    local def = self.Definitions[key]
    if not def then return nil end

    if def.type == "actionBar" then
        return GetBarVisibility(def.barIndex)
    elseif def.type == "cvar" then
        local val = GetCVar(def.cvar)
        return val == "1"
    elseif def.type == "modifiedClick" then
        local val = GetModifiedClick(def.action)
        return (val and val ~= "" and val) or "SHIFT"
    end

    return nil
end

function ActionBars:SetSetting(key, val)
    local def = self.Definitions[key]
    if not def then return end

    if def.type == "actionBar" then
        SetBarVisibility(def.barIndex, val)
    elseif def.type == "cvar" then
        local cvarVal = val and "1" or "0"
        if GetCVar(def.cvar) ~= cvarVal then
            SetCVar(def.cvar, cvarVal)
        end
    elseif def.type == "modifiedClick" then
        local targetVal = (val and val ~= "NONE" and val ~= "") and val or nil
        SetModifiedClick(def.action, targetVal)
    end
end

function ActionBars:ApplySettings(settings, notify)
    if not settings then return end

    for key, val in pairs(settings) do
        local def = self.Definitions[key]
        if def and AAS.SyncEngine:IsModuleSyncEnabled(key, "gameplay", "actionBars") then
            self:SetSetting(key, val)
        end
    end

    if notify then
        AAS.ShowToast("Action Bars synchronization applied.")
    end
end

function ActionBars:SaveSettings(notify, specificKey)
    if not AAS.db or not AAS.db.profile then return end

    AAS.db.profile.gameplay = AAS.db.profile.gameplay or {}
    AAS.db.profile.gameplay.actionBars = AAS.db.profile.gameplay.actionBars or {}

    local targetTable = AAS.db.profile.gameplay.actionBars

    if specificKey then
        local def = self.Definitions[specificKey]
        if def and AAS.SyncEngine:IsModuleSyncEnabled(specificKey, "gameplay", "actionBars") then
            targetTable[specificKey] = self:GetSetting(specificKey)
        end
    else
        for key, def in pairs(self.Definitions) do
            if AAS.SyncEngine:IsModuleSyncEnabled(key, "gameplay", "actionBars") then
                targetTable[key] = self:GetSetting(key)
            end
        end
    end

    if notify then
        AAS.ShowToast("Action Bars settings saved to profile.")
    end
end
