-------------------------------------------------------------------------------
-- Project: AscensionAccountSync
-- Author: Aka-DoctorCode
-- File: SyncEngine.lua
-------------------------------------------------------------------------------
---@diagnostic disable: undefined-global, undefined-field, inject-field

local addonName, AAS = ...

AAS.SyncEngine = {}
local SyncEngine = AAS.SyncEngine

--- Checks whether sync is enabled for a given module/cvar in the active profile
--- @param moduleKey string
--- @param category string|nil Optional category (e.g., "gameplay", "accessibility", "system")
--- @param subcategory string|nil Optional subcategory (e.g., "controls", "interface")
--- @return boolean
function SyncEngine:IsModuleSyncEnabled(moduleKey, category, subcategory)
    if not AAS.db or not AAS.db.profile or not AAS.db.profile.syncModules then
        return true
    end

    local sync = AAS.db.profile.syncModules

    if category and subcategory and sync[category] and type(sync[category]) == "table" and sync[category][subcategory] then
        if sync[category][subcategory][moduleKey] ~= nil then
            return sync[category][subcategory][moduleKey]
        end
    end

    if category and sync[category] and type(sync[category]) == "table" then
        if sync[category][moduleKey] ~= nil then
            return sync[category][moduleKey]
        end
    end

    if sync[moduleKey] ~= nil then
        return sync[moduleKey]
    end

    if sync.gameplay and type(sync.gameplay) == "table" and sync.gameplay[moduleKey] ~= nil then
        return sync.gameplay[moduleKey]
    end

    return true
end

--- Sets the active profile for the current character
--- @param profileName string
function SyncEngine:SetProfileForCharacter(profileName)
    if not AAS.db then return end
    AAS.db:SetProfile(profileName)
    local charKey = AAS:GetCharacterKey()
    AAS.db.global.firstLoginDone[charKey] = true
end

--- Applies all enabled modules from the active profile to the current character
--- @param notify boolean
function SyncEngine:ApplyCurrentProfile(notify)
    if not AAS.db or not AAS.db.profile then return end

    local gp = AAS.db.profile.gameplay or {}

    -- Apply Controls (includes Auto Loot, Sticky Targeting, Camera, Mouse, etc.)
    if AAS.Modules.Controls then
        AAS.Modules.Controls:ApplySettings(gp.controls or AAS.db.profile.controls, notify)
    end

    -- Apply Interface (Display, Quests, Raid Frames, Arena Frames, Housing, Coordinates)
    if AAS.Modules.Interface then
        AAS.Modules.Interface:ApplySettings(gp.interface or AAS.db.profile.interface, notify)
    end

    -- Apply Action Bars (Bars 2-8, Lock Action Bars, Modifier Key, Cooldown Numbers)
    if AAS.Modules.ActionBars then
        AAS.Modules.ActionBars:ApplySettings(gp.actionBars or AAS.db.profile.actionBars, notify)
    end

    -- Apply Combat (Personal Resource, Highlights, Targeting, Casting, Alerts)
    if AAS.Modules.Combat then
        AAS.Modules.Combat:ApplySettings(gp.combat or AAS.db.profile.combat, notify)
    end

    -- Apply Social (Chat, Filters, Invites, Toasts, Visibility)
    if AAS.Modules.Social then
        AAS.Modules.Social:ApplySettings(gp.social or AAS.db.profile.social, notify)
    end

    -- Apply Ping System (Pings, Mode, Sounds, Target, Chat, Raid Frames)
    if AAS.Modules.PingSystem then
        AAS.Modules.PingSystem:ApplySettings(gp.pingSystem or AAS.db.profile.pingSystem, notify)
    end

    -- Apply Gameplay Enhancements (Assistant, Boss Warnings, Cooldowns, Defensives, Damage Meter, DR)
    if AAS.Modules.GameplayEnhancements then
        AAS.Modules.GameplayEnhancements:ApplySettings(gp.gameplayEnhancements or AAS.db.profile.gameplayEnhancements, notify)
    end
end

--- Saves current state of all enabled modules into the active profile
--- @param notify boolean
function SyncEngine:SaveCurrentProfile(notify)
    if not AAS.db or not AAS.db.profile then return end

    -- Save Controls
    if AAS.Modules.Controls then
        AAS.Modules.Controls:SaveSettings(notify)
    end

    -- Save Interface
    if AAS.Modules.Interface then
        AAS.Modules.Interface:SaveSettings(notify)
    end

    -- Save Action Bars
    if AAS.Modules.ActionBars then
        AAS.Modules.ActionBars:SaveSettings(notify)
    end

    -- Save Combat
    if AAS.Modules.Combat then
        AAS.Modules.Combat:SaveSettings(notify)
    end

    -- Save Social
    if AAS.Modules.Social then
        AAS.Modules.Social:SaveSettings(notify)
    end

    -- Save Ping System
    if AAS.Modules.PingSystem then
        AAS.Modules.PingSystem:SaveSettings(notify)
    end

    -- Save Gameplay Enhancements
    if AAS.Modules.GameplayEnhancements then
        AAS.Modules.GameplayEnhancements:SaveSettings(notify)
    end
end
