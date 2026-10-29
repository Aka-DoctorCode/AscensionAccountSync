-------------------------------------------------------------------------------
-- Project: AscensionAccountSync
-- Author: Aka-DoctorCode
-- File: Core.lua
-------------------------------------------------------------------------------
---@diagnostic disable: undefined-global, undefined-field, inject-field

local addonName, AAS = ...

local AceAddon = LibStub("AceAddon-3.0")
local AscensionAccountSync = AceAddon:NewAddon(AAS, "AscensionAccountSync", "AceEvent-3.0", "AceConsole-3.0")

_G["AscensionAccountSync"] = AAS

local defaults = {
    global = {
        firstLoginDone = {}, -- [charKey] = true
    },
    profile = {
        syncModules = {
            gameplay = {
                controls = {
                    stickyTargeting = true,
                    autoDismountInFlight = true,
                    autoCancelAwayMode = true,
                    interactOnLeftClick = true,
                    openLootWindowAtMouse = true,
                    autoLoot = true,
                    combineBags = true,
                    enableInteractKey = true,
                    interactKeySoundCue = true,
                    lockCursorToWindow = true,
                    invertMouse = true,
                    mouseLookSpeed = true,
                    enableMouseSensitivity = true,
                    clickToMove = true,
                    clickToMoveCameraStyle = true,
                    waterCollision = true,
                    autoFollowSpeed = true,
                    cameraFollowingStyle = true,
                },
                interface = {
                    -- Display
                    inGameNavigation = true,
                    tutorials = true,
                    outlineMode = true,
                    statusText = true,
                    chatBubbles = true,
                    chatBubblesParty = true,
                    chatBubblesRaid = true,
                    replaceOtherPlayerPortraits = true,
                    replaceMyPlayerPortrait = true,
                    -- Quests
                    showWarbandCompletedQuests = true,
                    showLowLevelQuests = true,
                    -- Raid Frames
                    raidIncomingHeals = true,
                    raidPowerBars = true,
                    raidOnlyHealerPowerBars = true,
                    raidAggroHighlight = true,
                    raidClassColors = true,
                    raidHealthBarColorBG = true,
                    raidPets = true,
                    raidMainTankAndAssist = true,
                    raidDebuffs = true,
                    raidBiggerRoleDebuffs = true,
                    raidOnlyDispellableDebuffs = true,
                    raidCenterBigDefensives = true,
                    raidDispelIndicatorType = true,
                    raidDispelIndicatorColor = true,
                    raidDispelIndicatorFlashing = true,
                    raidDispelIndicatorAnimatedBorder = true,
                    raidHealthText = true,
                    -- Arena Enemy Frames
                    arenaPowerBars = true,
                    arenaOnlyHealerPowerBars = true,
                    arenaClassColors = true,
                    arenaPets = true,
                    arenaHealthText = true,
                    -- Housing
                    housingLightRadius = true,
                    housingSelectedDecor = true,
                    housingOtherDecor = true,
                    -- Map Coordinates
                    playerMapCoords = true,
                    cursorMapCoords = true,
                    playerMinimapCoords = true,
                    coordsInTenths = true,
                },
                actionBars = {
                    actionBar2 = true,
                    actionBar3 = true,
                    actionBar4 = true,
                    actionBar5 = true,
                    actionBar6 = true,
                    actionBar7 = true,
                    actionBar8 = true,
                    lockActionBars = true,
                    pickupActionKey = true,
                    countdownForCooldowns = true,
                },
                combat = {
                    personalResourceDisplay = true,
                    selfHighlight = true,
                    selfHighlightSilhouette = true,
                    targetOfTarget = true,
                    doNotFlashLowHealth = true,
                    lossOfControlAlerts = true,
                    floatingCombatTextSelf = true,
                    mouseoverCast = true,
                    selfCast = true,
                    focusCastKey = true,
                    empoweredSpellInput = true,
                    spellAlertOpacity = true,
                    pressAndHoldCasting = true,
                    actionTargeting = true,
                },
                social = {
                    disableChat = true,
                    chatFiltering = true,
                    profanityFilter = true,
                    guildMemberAlert = true,
                    blockTrades = true,
                    blockGuildInvites = true,
                    blockNeighborhoodInvites = true,
                    restrictCalendarInvites = true,
                    blockChannelInvites = true,
                    locationVisibility = true,
                    onlineFriendsToast = true,
                    offlineFriendsToast = true,
                    broadcastUpdatesToast = true,
                    friendRequestsToast = true,
                    showToastWindow = true,
                    autoAcceptQuickJoin = true,
                    chatStyle = true,
                    whisperMode = true,
                    chatTimestamps = true,
                    discordDisplayName = true,
                    discordClientEnabled = true,
                },
                pingSystem = {
                    enablePings = true,
                    pingMode = true,
                    pingSounds = true,
                    pingTarget = true,
                    showPingsInChat = true,
                    showPingsOnRaidFrames = true,
                },
                gameplayEnhancements = {
                    assistedCombatReduceHighlights = true,
                    assistedCombatHighlight = true,
                    encounterWarningsEnabled = true,
                    encounterWarningsLevel = true,
                    encounterWarningsHideIfNotTargetingPlayer = true,
                    encounterTimelineEnabled = true,
                    encounterTimelineHideLongCountdowns = true,
                    encounterTimelineHideQueuedCountdowns = true,
                    encounterTimelineHideForOtherRoles = true,
                    encounterTimelineIconographyEnabled = true,
                    cooldownViewerEnabled = true,
                    externalDefensivesEnabled = true,
                    damageMeterEnabled = true,
                    damageMeterResetOnNewInstance = true,
                    spellDiminishPVPEnemiesEnabled = true,
                    spellDiminishPVPOnlyTriggerableByMe = true,
                },
            },
        },
        gameplay = {
            controls = {},
            interface = {},
            actionBars = {},
            combat = {},
            social = {},
            pingSystem = {},
            gameplayEnhancements = {},
        },
    }
}

function AAS:GetCharacterKey()
    local name, realm = UnitFullName("player")
    realm = realm or GetNormalizedRealmName() or GetRealmName() or "UnknownRealm"
    return (name or "Unknown") .. "-" .. realm
end

function AscensionAccountSync:OnInitialize()
    self.db = LibStub("AceDB-3.0"):New("AscensionAccountSyncDB", defaults, true)
    AAS.db = self.db

    -- Migrate legacy flat profile data if present
    if self.db.profile then
        self.db.profile.gameplay = self.db.profile.gameplay or {}
        if self.db.profile.controls and not self.db.profile.gameplay.controls then
            self.db.profile.gameplay.controls = self.db.profile.controls
        end
        if self.db.profile.autoLoot and self.db.profile.gameplay.controls then
            for k, v in pairs(self.db.profile.autoLoot) do
                if self.db.profile.gameplay.controls[k] == nil then
                    self.db.profile.gameplay.controls[k] = v
                end
            end
        end
    end

    -- Register Slash Commands
    self:RegisterChatCommand("aas", "SlashCommand")
    self:RegisterChatCommand("ascensionsync", "SlashCommand")
end

function AscensionAccountSync:OnEnable()
    self:RegisterEvent("PLAYER_ENTERING_WORLD")
    self:RegisterEvent("CVAR_UPDATE")
    self:RegisterEvent("MINIMAP_UPDATE_TRACKING")
    pcall(function() self:RegisterEvent("LET_RECENT_ALLIES_SEE_LOCATION_SETTING_UPDATED") end)
end

function AscensionAccountSync:PLAYER_ENTERING_WORLD(event, isInitialLogin, isReloadingUi)
    local charKey = AAS:GetCharacterKey()

    -- Check if first-time login for this character
    if not self.db.global.firstLoginDone[charKey] then
        C_Timer.After(1.5, function()
            AAS.FirstLoginDialog:ShowPrompt()
        end)
    else
        -- Normal login: apply profile if not in combat
        C_Timer.After(1.5, function()
            if not InCombatLockdown() then
                AAS.SyncEngine:ApplyCurrentProfile(true)
            end
        end)
    end
end

function AscensionAccountSync:CVAR_UPDATE(event, cvarName, value)
    if InCombatLockdown() then return end

    if AAS.Modules.Controls and AAS.Modules.Controls.OnCVarUpdate then
        AAS.Modules.Controls:OnCVarUpdate(cvarName)
    end
    if AAS.Modules.Interface and AAS.Modules.Interface.OnCVarUpdate then
        AAS.Modules.Interface:OnCVarUpdate(cvarName)
    end
    if AAS.Modules.ActionBars and (cvarName == "lockActionBars" or cvarName == "countdownForCooldowns") then
        local key = (cvarName == "lockActionBars" and "lockActionBars") or "countdownForCooldowns"
        if AAS.SyncEngine:IsModuleSyncEnabled(key, "gameplay", "actionBars") then
            AAS.Modules.ActionBars:SaveSettings(false, key)
        end
    end
    if AAS.Modules.Combat and AAS.Modules.Combat.OnCVarUpdate then
        AAS.Modules.Combat:OnCVarUpdate(cvarName)
    end
    if AAS.Modules.Social and AAS.Modules.Social.OnCVarUpdate then
        AAS.Modules.Social:OnCVarUpdate(cvarName)
    end
    if AAS.Modules.PingSystem and AAS.Modules.PingSystem.OnCVarUpdate then
        AAS.Modules.PingSystem:OnCVarUpdate(cvarName)
    end
    if AAS.Modules.GameplayEnhancements and AAS.Modules.GameplayEnhancements.OnCVarUpdate then
        AAS.Modules.GameplayEnhancements:OnCVarUpdate(cvarName)
    end
end

function AscensionAccountSync:MINIMAP_UPDATE_TRACKING(event)
    if InCombatLockdown() then return end

    if AAS.Modules.Interface and AAS.Modules.Interface.OnTrackingUpdate then
        AAS.Modules.Interface:OnTrackingUpdate()
    end
end

function AscensionAccountSync:LET_RECENT_ALLIES_SEE_LOCATION_SETTING_UPDATED()
    if InCombatLockdown() then return end

    if AAS.Modules.Social and AAS.SyncEngine:IsModuleSyncEnabled("locationVisibility", "gameplay", "social") then
        AAS.Modules.Social:SaveSettings(false, "locationVisibility")
    end
end

function AscensionAccountSync:SlashCommand(input)
    input = input and input:trim():lower() or ""
    if input == "save" then
        AAS.SyncEngine:SaveCurrentProfile(true)
    elseif input == "load" then
        AAS.SyncEngine:ApplyCurrentProfile(true)
    else
        AAS.ConfigUI:Toggle()
    end
end
