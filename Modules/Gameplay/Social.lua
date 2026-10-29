-------------------------------------------------------------------------------
-- Project: AscensionAccountSync
-- Author: Aka-DoctorCode
-- File: Modules/Gameplay/Social.lua
-------------------------------------------------------------------------------
---@diagnostic disable: undefined-global, undefined-field, inject-field

local addonName, AAS = ...

AAS.Modules = AAS.Modules or {}
AAS.Modules.Social = {}
local Social = AAS.Modules.Social

Social.Name = "Social"
Social.Title = "Social Options"

Social.Definitions = {
    disableChat = {
        title = "Disable Chat",
        type = "chat_disabled",
    },
    chatFiltering = {
        title = "Real Time Chat Filtering",
        type = "cvar_number",
        cvar = "excludedCensorSources",
    },
    profanityFilter = {
        title = "Mature Language Filter",
        type = "cvar_bool",
        cvar = "profanityFilter",
    },
    guildMemberAlert = {
        title = "Guild Member Alert",
        type = "cvar_bool",
        cvar = "guildMemberNotify",
    },
    blockTrades = {
        title = "Block Trades",
        type = "cvar_bool",
        cvar = "blockTrades",
    },
    blockGuildInvites = {
        title = "Block Guild Invites",
        type = "guild_invites",
    },
    blockNeighborhoodInvites = {
        title = "Block Neighborhood Invites",
        type = "neighborhood_invites",
    },
    restrictCalendarInvites = {
        title = "Restrict Calendar Invites",
        type = "cvar_bool",
        cvar = "restrictCalendarInvites",
    },
    blockChannelInvites = {
        title = "Block Chat Channel Invites",
        type = "cvar_bool",
        cvar = "blockChannelInvites",
    },
    locationVisibility = {
        title = "Location Visibility",
        type = "location_visibility",
    },
    onlineFriendsToast = {
        title = "Online Friends",
        type = "cvar_bool",
        cvar = "showToastOnline",
    },
    offlineFriendsToast = {
        title = "Offline Friends",
        type = "cvar_bool",
        cvar = "showToastOffline",
    },
    broadcastUpdatesToast = {
        title = "Broadcast Updates",
        type = "cvar_bool",
        cvar = "showToastBroadcast",
    },
    friendRequestsToast = {
        title = "Battle.net Friend Requests",
        type = "cvar_bool",
        cvar = "showToastFriendRequest",
    },
    showToastWindow = {
        title = "Show Toast Window",
        type = "cvar_bool",
        cvar = "showToastWindow",
    },
    autoAcceptQuickJoin = {
        title = "Auto Accept Quick Join Requests",
        type = "cvar_bool",
        cvar = "autoAcceptQuickJoinRequests",
    },
    chatStyle = {
        title = "Chat Style",
        type = "cvar_string",
        cvar = "chatStyle",
    },
    whisperMode = {
        title = "New Whispers",
        type = "cvar_string",
        cvar = "whisperMode",
    },
    chatTimestamps = {
        title = "Chat Timestamps",
        type = "cvar_string",
        cvar = "showTimestamps",
    },
    discordDisplayName = {
        title = "Discord Display Name",
        type = "cvar_string",
        cvar = "discordDisplayName",
    },
    discordClientEnabled = {
        title = "Enable Discord Functionality",
        type = "cvar_bool",
        cvar = "discordClientEnabled",
    },
}

function Social:GetSetting(key)
    local def = self.Definitions[key]
    if not def then return nil end

    if def.type == "cvar_bool" then
        return GetCVar(def.cvar) == "1"
    elseif def.type == "cvar_number" then
        return tonumber(GetCVar(def.cvar)) or 0
    elseif def.type == "cvar_string" then
        return GetCVar(def.cvar) or ""
    elseif def.type == "chat_disabled" then
        if C_SocialRestrictions and C_SocialRestrictions.IsChatDisabled then
            return C_SocialRestrictions.IsChatDisabled()
        end
        return false
    elseif def.type == "guild_invites" then
        if GetAutoDeclineGuildInvites then
            return GetAutoDeclineGuildInvites()
        end
        return false
    elseif def.type == "neighborhood_invites" then
        if GetAutoDeclineNeighborhoodInvites then
            return GetAutoDeclineNeighborhoodInvites()
        end
        return false
    elseif def.type == "location_visibility" then
        if GetAllowRecentAlliesSeeLocation then
            return GetAllowRecentAlliesSeeLocation()
        end
        return true
    end

    return nil
end

function Social:SetSetting(key, val)
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
    elseif def.type == "cvar_string" then
        local targetVal = tostring(val)
        if GetCVar(def.cvar) ~= targetVal then
            SetCVar(def.cvar, targetVal)
        end
    elseif def.type == "chat_disabled" then
        if C_SocialRestrictions and C_SocialRestrictions.SetChatDisabled then
            C_SocialRestrictions.SetChatDisabled(val and true or false)
        end
    elseif def.type == "guild_invites" then
        if SetAutoDeclineGuildInvites then
            SetAutoDeclineGuildInvites(val and true or false)
        end
    elseif def.type == "neighborhood_invites" then
        if SetAutoDeclineNeighborhoodInvites then
            SetAutoDeclineNeighborhoodInvites(val and true or false)
        end
    elseif def.type == "location_visibility" then
        if SetAllowRecentAlliesSeeLocation then
            SetAllowRecentAlliesSeeLocation(val and true or false)
        end
    end
end

function Social:ApplySettings(settings, notify)
    if not settings then return end

    for key, val in pairs(settings) do
        local def = self.Definitions[key]
        if def and AAS.SyncEngine:IsModuleSyncEnabled(key, "gameplay", "social") then
            self:SetSetting(key, val)
        end
    end

    if notify then
        AAS.ShowToast("Social settings synchronization applied.")
    end
end

function Social:SaveSettings(notify, specificKey)
    if not AAS.db or not AAS.db.profile then return end

    AAS.db.profile.gameplay = AAS.db.profile.gameplay or {}
    AAS.db.profile.gameplay.social = AAS.db.profile.gameplay.social or {}

    local targetTable = AAS.db.profile.gameplay.social

    if specificKey then
        local def = self.Definitions[specificKey]
        if def and AAS.SyncEngine:IsModuleSyncEnabled(specificKey, "gameplay", "social") then
            targetTable[specificKey] = self:GetSetting(specificKey)
        end
    else
        for key, def in pairs(self.Definitions) do
            if AAS.SyncEngine:IsModuleSyncEnabled(key, "gameplay", "social") then
                targetTable[key] = self:GetSetting(key)
            end
        end
    end

    if notify then
        AAS.ShowToast("Social settings saved to profile.")
    end
end

function Social:OnCVarUpdate(cvarName)
    for key, def in pairs(self.Definitions) do
        if def.cvar and def.cvar:lower() == cvarName:lower() then
            if AAS.SyncEngine:IsModuleSyncEnabled(key, "gameplay", "social") then
                self:SaveSettings(false, key)
            end
            return
        end
    end
end
