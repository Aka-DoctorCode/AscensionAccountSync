-------------------------------------------------------------------------------
-- Project: AscensionAccountSync
-- Author: Aka-DoctorCode
-- File: Modules/Gameplay/GameplayEnhancements.lua
-------------------------------------------------------------------------------
---@diagnostic disable: undefined-global, undefined-field, inject-field

local addonName, AAS = ...

AAS.Modules = AAS.Modules or {}
AAS.Modules.GameplayEnhancements = {}
local GameplayEnhancements = AAS.Modules.GameplayEnhancements

GameplayEnhancements.Name = "GameplayEnhancements"
GameplayEnhancements.Title = "Gameplay Enhancements"

GameplayEnhancements.Definitions = {
    -- Combat Assistant
    assistedCombatReduceHighlights = {
        title = "Reduce Highlights on Abilities",
        type = "cvar_bool",
        cvar = "assistedCombatReduceHighlights",
    },
    assistedCombatHighlight = {
        title = "Assisted Highlight",
        type = "cvar_bool",
        cvar = "assistedCombatHighlight",
    },

    -- Boss Warnings
    encounterWarningsEnabled = {
        title = "Enable Boss Warnings",
        type = "cvar_bool",
        cvar = "encounterWarningsEnabled",
    },
    encounterWarningsLevel = {
        title = "Enable Text Warnings",
        type = "cvar_number",
        cvar = "encounterWarningsLevel",
    },
    encounterWarningsHideIfNotTargetingPlayer = {
        title = "Hide When Not Targeted",
        type = "cvar_bool",
        cvar = "encounterWarningsHideIfNotTargetingPlayer",
    },
    encounterTimelineEnabled = {
        title = "Enable Boss Abilities",
        type = "cvar_bool",
        cvar = "encounterTimelineEnabled",
    },
    encounterTimelineHideLongCountdowns = {
        title = "Hide Long Countdowns",
        type = "cvar_bool",
        cvar = "encounterTimelineHideLongCountdowns",
    },
    encounterTimelineHideQueuedCountdowns = {
        title = "Hide Queued Countdowns",
        type = "cvar_bool",
        cvar = "encounterTimelineHideQueuedCountdowns",
    },
    encounterTimelineHideForOtherRoles = {
        title = "Hide Countdowns for Other Roles",
        type = "cvar_bool",
        cvar = "encounterTimelineHideForOtherRoles",
    },
    encounterTimelineIconographyEnabled = {
        title = "Spell Support Iconography",
        type = "cvar_bool",
        cvar = "encounterTimelineIconographyEnabled",
    },

    -- Cooldown Manager
    cooldownViewerEnabled = {
        title = "Enable Cooldown Manager",
        type = "cvar_bool",
        cvar = "cooldownViewerEnabled",
    },

    -- External Defensives
    externalDefensivesEnabled = {
        title = "Enable External Defensives",
        type = "cvar_bool",
        cvar = "externalDefensivesEnabled",
    },

    -- Damage Meter
    damageMeterEnabled = {
        title = "Enable Damage Meter",
        type = "cvar_bool",
        cvar = "damageMeterEnabled",
    },
    damageMeterResetOnNewInstance = {
        title = "Auto Reset Damage Meter",
        type = "cvar_bool",
        cvar = "damageMeterResetOnNewInstance",
    },

    -- Diminishing Returns
    spellDiminishPVPEnemiesEnabled = {
        title = "Diminishing Returns Tracking",
        type = "cvar_bool",
        cvar = "spellDiminishPVPEnemiesEnabled",
    },
    spellDiminishPVPOnlyTriggerableByMe = {
        title = "Only Castable by Me",
        type = "cvar_bool",
        cvar = "spellDiminishPVPOnlyTriggerableByMe",
    },
}

function GameplayEnhancements:GetSetting(key)
    local def = self.Definitions[key]
    if not def then return nil end

    if def.type == "cvar_bool" then
        return GetCVar(def.cvar) == "1"
    elseif def.type == "cvar_number" then
        return tonumber(GetCVar(def.cvar)) or 0
    end

    return nil
end

function GameplayEnhancements:SetSetting(key, val)
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
    end
end

function GameplayEnhancements:ApplySettings(settings, notify)
    if not settings then return end

    for key, val in pairs(settings) do
        local def = self.Definitions[key]
        if def and AAS.SyncEngine:IsModuleSyncEnabled(key, "gameplay", "gameplayEnhancements") then
            self:SetSetting(key, val)
        end
    end

    if notify then
        AAS.ShowToast("Gameplay Enhancements synchronization applied.")
    end
end

function GameplayEnhancements:SaveSettings(notify, specificKey)
    if not AAS.db or not AAS.db.profile then return end

    AAS.db.profile.gameplay = AAS.db.profile.gameplay or {}
    AAS.db.profile.gameplay.gameplayEnhancements = AAS.db.profile.gameplay.gameplayEnhancements or {}

    local targetTable = AAS.db.profile.gameplay.gameplayEnhancements

    if specificKey then
        local def = self.Definitions[specificKey]
        if def and AAS.SyncEngine:IsModuleSyncEnabled(specificKey, "gameplay", "gameplayEnhancements") then
            targetTable[specificKey] = self:GetSetting(specificKey)
        end
    else
        for key, def in pairs(self.Definitions) do
            if AAS.SyncEngine:IsModuleSyncEnabled(key, "gameplay", "gameplayEnhancements") then
                targetTable[key] = self:GetSetting(key)
            end
        end
    end

    if notify then
        AAS.ShowToast("Gameplay Enhancements saved to profile.")
    end
end

function GameplayEnhancements:OnCVarUpdate(cvarName)
    local lower = cvarName:lower()
    for key, def in pairs(self.Definitions) do
        if def.cvar and def.cvar:lower() == lower then
            if AAS.SyncEngine:IsModuleSyncEnabled(key, "gameplay", "gameplayEnhancements") then
                self:SaveSettings(false, key)
            end
            return
        end
    end
end
