-------------------------------------------------------------------------------
-- Project: AscensionAccountSync
-- Author: Aka-DoctorCode
-- File: Modules/Gameplay/Combat.lua
-------------------------------------------------------------------------------
---@diagnostic disable: undefined-global, undefined-field, inject-field

local addonName, AAS = ...

AAS.Modules = AAS.Modules or {}
AAS.Modules.Combat = {}
local Combat = AAS.Modules.Combat

Combat.Name = "Combat"
Combat.Title = "Combat Options"

Combat.Definitions = {
    personalResourceDisplay = {
        title = "Personal Resource Display",
        type = "cvar_bool",
        cvar = "nameplateShowSelf",
    },
    selfHighlight = {
        title = "Self Highlight",
        type = "cvar_number",
        cvar = "findYourselfMode",
    },
    selfHighlightSilhouette = {
        title = "Silhouette when Obscured",
        type = "cvar_bool",
        cvar = "findYourselfAnywhere",
    },
    targetOfTarget = {
        title = "Target of Target",
        type = "cvar_bool",
        cvar = "showTargetOfTarget",
    },
    doNotFlashLowHealth = {
        title = "Do Not Flash at Low Health",
        type = "cvar_bool",
        cvar = "doNotFlashLowHealthWarning",
    },
    lossOfControlAlerts = {
        title = "Loss of Control Alerts",
        type = "cvar_bool",
        cvar = "lossOfControl",
    },
    floatingCombatTextSelf = {
        title = "Scrolling Combat Text for Self",
        type = "cvar_bool",
        cvar = "enableFloatingCombatText",
    },
    mouseoverCast = {
        title = "Mouseover Cast",
        type = "mouseover_combo",
        cvar = "enableMouseoverCast",
        action = "MOUSEOVERCAST",
    },
    selfCast = {
        title = "Self Cast & Key",
        type = "selfcast_combo",
        cvar = "autoSelfCast",
        action = "SELFCAST",
    },
    focusCastKey = {
        title = "Focus Cast Key",
        type = "modifiedClick",
        action = "FOCUSCAST",
    },
    empoweredSpellInput = {
        title = "Empowered Spell Input",
        type = "cvar_number",
        cvar = "empoweredSpellInput",
    },
    spellAlertOpacity = {
        title = "Spell Alert Opacity",
        type = "cvar_number",
        cvar = "spellActivationOverlayOpacity",
    },
    pressAndHoldCasting = {
        title = "Press and Hold Casting",
        type = "cvar_bool",
        cvar = "pressAndHoldSpellCasting",
    },
    actionTargeting = {
        title = "Enable Action Targeting",
        type = "cvar_action_target",
        cvar = "SoftTargetEnemy",
    },
}

function Combat:GetSetting(key)
    local def = self.Definitions[key]
    if not def then return nil end

    if def.type == "cvar_bool" then
        return GetCVar(def.cvar) == "1"
    elseif def.type == "cvar_number" then
        return tonumber(GetCVar(def.cvar)) or 0
    elseif def.type == "cvar_action_target" then
        local val = tonumber(GetCVar(def.cvar)) or 0
        return val > 0
    elseif def.type == "modifiedClick" then
        local val = GetModifiedClick(def.action)
        return (val and val ~= "" and val) or "NONE"
    elseif def.type == "mouseover_combo" then
        return {
            enabled = GetCVar(def.cvar) == "1",
            key = GetModifiedClick(def.action) or "NONE",
        }
    elseif def.type == "selfcast_combo" then
        return {
            mode = tonumber(GetCVar(def.cvar)) or 1,
            key = GetModifiedClick(def.action) or "ALT",
        }
    end

    return nil
end

function Combat:SetSetting(key, val)
    local def = self.Definitions[key]
    if not def or val == nil then return end

    if def.type == "cvar_bool" then
        local targetVal = val and "1" or "0"
        if GetCVar(def.cvar) ~= targetVal then
            SetCVar(def.cvar, targetVal)
        end
    elseif def.type == "cvar_number" then
        local targetVal = tostring(val)
        if GetCVar(def.cvar) ~= targetVal then
            SetCVar(def.cvar, targetVal)
        end
    elseif def.type == "cvar_action_target" then
        local targetVal = val and "3" or "0"
        if GetCVar(def.cvar) ~= targetVal then
            SetCVar(def.cvar, targetVal)
        end
    elseif def.type == "modifiedClick" then
        local targetVal = (val and val ~= "NONE" and val ~= "") and val or nil
        SetModifiedClick(def.action, targetVal)
    elseif def.type == "mouseover_combo" then
        if type(val) == "table" then
            local cvarVal = val.enabled and "1" or "0"
            if GetCVar(def.cvar) ~= cvarVal then SetCVar(def.cvar, cvarVal) end
            local keyVal = (val.key and val.key ~= "NONE" and val.key ~= "") and val.key or nil
            SetModifiedClick(def.action, keyVal)
        elseif type(val) == "boolean" then
            local cvarVal = val and "1" or "0"
            if GetCVar(def.cvar) ~= cvarVal then SetCVar(def.cvar, cvarVal) end
        end
    elseif def.type == "selfcast_combo" then
        if type(val) == "table" then
            if val.mode ~= nil then SetCVar(def.cvar, tostring(val.mode)) end
            local keyVal = (val.key and val.key ~= "NONE" and val.key ~= "") and val.key or nil
            SetModifiedClick(def.action, keyVal)
        end
    end
end

function Combat:ApplySettings(settings, notify)
    if not settings then return end

    for key, val in pairs(settings) do
        local def = self.Definitions[key]
        if def and AAS.SyncEngine:IsModuleSyncEnabled(key, "gameplay", "combat") then
            self:SetSetting(key, val)
        end
    end

    if notify then
        AAS.ShowToast("Combat settings synchronization applied.")
    end
end

function Combat:SaveSettings(notify, specificKey)
    if not AAS.db or not AAS.db.profile then return end

    AAS.db.profile.gameplay = AAS.db.profile.gameplay or {}
    AAS.db.profile.gameplay.combat = AAS.db.profile.gameplay.combat or {}

    local targetTable = AAS.db.profile.gameplay.combat

    if specificKey then
        local def = self.Definitions[specificKey]
        if def and AAS.SyncEngine:IsModuleSyncEnabled(specificKey, "gameplay", "combat") then
            targetTable[specificKey] = self:GetSetting(specificKey)
        end
    else
        for key, def in pairs(self.Definitions) do
            if AAS.SyncEngine:IsModuleSyncEnabled(key, "gameplay", "combat") then
                targetTable[key] = self:GetSetting(key)
            end
        end
    end

    if notify then
        AAS.ShowToast("Combat settings saved to profile.")
    end
end

function Combat:OnCVarUpdate(cvarName)
    for key, def in pairs(self.Definitions) do
        if def.cvar and def.cvar:lower() == cvarName:lower() then
            if AAS.SyncEngine:IsModuleSyncEnabled(key, "gameplay", "combat") then
                self:SaveSettings(false, key)
            end
            return
        end
    end
end
