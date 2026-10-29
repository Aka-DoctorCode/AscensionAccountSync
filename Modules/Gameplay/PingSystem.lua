-------------------------------------------------------------------------------
-- Project: AscensionAccountSync
-- Author: Aka-DoctorCode
-- File: Modules/Gameplay/PingSystem.lua
-------------------------------------------------------------------------------
---@diagnostic disable: undefined-global, undefined-field, inject-field

local addonName, AAS = ...

AAS.Modules = AAS.Modules or {}
AAS.Modules.PingSystem = {}
local PingSystem = AAS.Modules.PingSystem

PingSystem.Name = "PingSystem"
PingSystem.Title = "Ping System Options"

PingSystem.Definitions = {
    enablePings = {
        title = "Enable Pings",
        type = "cvar_bool",
        cvar = "enablePings",
    },
    pingMode = {
        title = "Ping Mode",
        type = "cvar_number",
        cvar = "pingMode",
    },
    pingSounds = {
        title = "Ping Sounds",
        type = "sound_combo",
        cvar_enable = "Sound_EnablePingSounds",
        cvar_volume = "Sound_PingVolume",
    },
    pingTarget = {
        title = "Ping Target",
        type = "cvar_number",
        cvar = "pingTarget",
    },
    showPingsInChat = {
        title = "Show Pings in Chat",
        type = "cvar_bool",
        cvar = "showPingsInChat",
    },
    showPingsOnRaidFrames = {
        title = "Show Pings on Raid Frames",
        type = "cvar_bool",
        cvar = "showPingsOnRaidFrames",
    },
}

function PingSystem:GetSetting(key)
    local def = self.Definitions[key]
    if not def then return nil end

    if def.type == "cvar_bool" then
        return GetCVar(def.cvar) == "1"
    elseif def.type == "cvar_number" then
        return tonumber(GetCVar(def.cvar)) or 0
    elseif def.type == "sound_combo" then
        return {
            enabled = GetCVar(def.cvar_enable) == "1",
            volume = tonumber(GetCVar(def.cvar_volume)) or 1.0,
        }
    end

    return nil
end

function PingSystem:SetSetting(key, val)
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
    elseif def.type == "sound_combo" then
        if type(val) == "table" then
            local enableVal = val.enabled and "1" or "0"
            if GetCVar(def.cvar_enable) ~= enableVal then
                SetCVar(def.cvar_enable, enableVal)
            end
            if val.volume ~= nil then
                local volumeVal = tostring(val.volume)
                if GetCVar(def.cvar_volume) ~= volumeVal then
                    SetCVar(def.cvar_volume, volumeVal)
                end
            end
        elseif type(val) == "boolean" then
            local enableVal = val and "1" or "0"
            if GetCVar(def.cvar_enable) ~= enableVal then
                SetCVar(def.cvar_enable, enableVal)
            end
        end
    end
end

function PingSystem:ApplySettings(settings, notify)
    if not settings then return end

    for key, val in pairs(settings) do
        local def = self.Definitions[key]
        if def and AAS.SyncEngine:IsModuleSyncEnabled(key, "gameplay", "pingSystem") then
            self:SetSetting(key, val)
        end
    end

    if notify then
        AAS.ShowToast("Ping System settings synchronization applied.")
    end
end

function PingSystem:SaveSettings(notify, specificKey)
    if not AAS.db or not AAS.db.profile then return end

    AAS.db.profile.gameplay = AAS.db.profile.gameplay or {}
    AAS.db.profile.gameplay.pingSystem = AAS.db.profile.gameplay.pingSystem or {}

    local targetTable = AAS.db.profile.gameplay.pingSystem

    if specificKey then
        local def = self.Definitions[specificKey]
        if def and AAS.SyncEngine:IsModuleSyncEnabled(specificKey, "gameplay", "pingSystem") then
            targetTable[specificKey] = self:GetSetting(specificKey)
        end
    else
        for key, def in pairs(self.Definitions) do
            if AAS.SyncEngine:IsModuleSyncEnabled(key, "gameplay", "pingSystem") then
                targetTable[key] = self:GetSetting(key)
            end
        end
    end

    if notify then
        AAS.ShowToast("Ping System settings saved to profile.")
    end
end

function PingSystem:OnCVarUpdate(cvarName)
    local lower = cvarName:lower()
    for key, def in pairs(self.Definitions) do
        if def.cvar and def.cvar:lower() == lower then
            if AAS.SyncEngine:IsModuleSyncEnabled(key, "gameplay", "pingSystem") then
                self:SaveSettings(false, key)
            end
            return
        elseif def.type == "sound_combo" then
            if def.cvar_enable:lower() == lower or def.cvar_volume:lower() == lower then
                if AAS.SyncEngine:IsModuleSyncEnabled(key, "gameplay", "pingSystem") then
                    self:SaveSettings(false, key)
                end
                return
            end
        end
    end
end
