-------------------------------------------------------------------------------
-- Project: AscensionAccountSync
-- Author: Aka-DoctorCode
-- File: UI.lua
-------------------------------------------------------------------------------
---@diagnostic disable: undefined-global, undefined-field, inject-field

local addonName, AAS = ...

AAS.ConfigUI = {}
local ConfigUI = AAS.ConfigUI

local mainFrame = nil

function ConfigUI:Toggle()
    if mainFrame and mainFrame:IsShown() then
        mainFrame:Hide()
        return
    end
    self:Show()
end

function ConfigUI:Show()
    if mainFrame then
        mainFrame:Show()
        return
    end

    local lib = LibStub("AscensionSuit-UI", true)
    if not lib then
        error("AscensionAccountSync requires AscensionSuit-UI")
    end

    local context = (lib.CreateContext and lib:CreateContext()) or lib.Context
    local styles = (context and context.styles) or lib.DefaultStyles
    context.styles = styles

    local colors = styles.colors

    -- Frame Base
    local f = CreateFrame("Frame", "AscensionAccountSyncConfigFrame", UIParent, "BackdropTemplate")
    f:SetSize(820, 580)
    f:SetPoint("CENTER")
    f:SetFrameStrata("DIALOG")
    f:SetClampedToScreen(true)
    f:EnableMouse(true)

    f:SetBackdrop({
        bgFile = styles.files.bgFile,
        edgeFile = styles.files.edgeFile,
        edgeSize = 2,
        insets = { left = 2, right = 2, top = 2, bottom = 2 }
    })
    f:SetBackdropColor(unpack(colors.mainBackground))
    f:SetBackdropBorderColor(unpack(colors.sidebarAccent))

    -- UX Behaviors
    if lib.UX then
        if lib.UX.makeMovable then
            lib.UX:makeMovable(f)
        end
        if lib.UX.makeEscable then
            lib.UX:makeEscable(f)
        elseif lib.UX.enableEsc then
            lib.UX:enableEsc(f)
        elseif lib.UX.closeOnEscape then
            lib.UX:closeOnEscape(f)
        end
    end

    -- Allow closing with ESC key
    local frameName = "AscensionAccountSyncConfigFrame"
    if not tContains(UISpecialFrames, frameName) then
        tinsert(UISpecialFrames, frameName)
    end

    -- Header Title
    local title = f:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    title:SetPoint("TOPLEFT", f, "TOPLEFT", 16, -14)
    title:SetTextColor(unpack(colors.gold))
    title:SetText("Ascension Account Sync")

    -- Close Button
    local closeBtn = context:createCloseButton(f, function() f:Hide() end)
    closeBtn:SetPoint("TOPRIGHT", f, "TOPRIGHT", -10, -10)

    -- Left Navigation Tabs
    local tabNames = { "Gameplay", "Accessibility", "System", "Profiles" }
    local buildFuncs = {
        function(panel) self:BuildGameplayTab(panel, context) end,
        function(panel) self:BuildAccessibilityTab(panel, context) end,
        function(panel) self:BuildSystemTab(panel, context) end,
        function(panel) self:BuildProfilesTab(panel, context) end,
    }

    local tabSystem = context:createTabbedInterface(f, tabNames, buildFuncs, 1)
    f.tabSystem = tabSystem

    mainFrame = f
    f:Show()
end

-- Helper to safely get/set a sync toggle in DB
local function getSyncToggle(category, subcategory, key, defaultVal)
    if defaultVal == nil and type(key) == "boolean" then
        defaultVal = key
        key = subcategory
        subcategory = nil
    end

    if not AAS.db or not AAS.db.profile then return defaultVal end
    local sync = AAS.db.profile.syncModules or {}
    if sync[category] and type(sync[category]) == "table" then
        if subcategory and sync[category][subcategory] and sync[category][subcategory][key] ~= nil then
            return sync[category][subcategory][key]
        end
        if sync[category][key] ~= nil then
            return sync[category][key]
        end
    end
    return defaultVal
end

local function setSyncToggle(category, subcategory, key, val)
    if val == nil then
        val = key
        key = subcategory
        subcategory = nil
    end

    if not AAS.db or not AAS.db.profile then return end
    AAS.db.profile.syncModules = AAS.db.profile.syncModules or {}
    AAS.db.profile.syncModules[category] = AAS.db.profile.syncModules[category] or {}
    if subcategory then
        AAS.db.profile.syncModules[category][subcategory] = AAS.db.profile.syncModules[category][subcategory] or {}
        AAS.db.profile.syncModules[category][subcategory][key] = val
    else
        AAS.db.profile.syncModules[category][key] = val
    end
    AAS.ShowToast("Synchronization setting updated.")
end

-- Collapsible state per session
local sectionStates = {
    controls = false,
    interface = false,
    actionBars = false,
    combat = false,
    social = false,
    pingSystem = false,
    gameplayEnhancements = false,
}

local function CreateCollapsibleHeader(parent, title, initialExpanded, onToggle)
    local btn = CreateFrame("Button", nil, parent, "BackdropTemplate")
    btn:SetSize(590, 28)
    btn:EnableMouse(true)

    btn:SetBackdrop({
        bgFile = "Interface\\Buttons\\WHITE8X8",
        edgeFile = "Interface\\Buttons\\WHITE8X8",
        edgeSize = 1,
        insets = { left = 1, right = 1, top = 1, bottom = 1 }
    })
    btn:SetBackdropColor(0.12, 0.12, 0.14, 0.85)
    btn:SetBackdropBorderColor(0.3, 0.3, 0.35, 0.7)

    local arrow = btn:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    arrow:SetPoint("LEFT", btn, "LEFT", 10, 0)
    arrow:SetText(initialExpanded and "[ - ]" or "[ + ]")
    arrow:SetTextColor(0.9, 0.8, 0.4, 1)

    local text = btn:CreateFontString(nil, "OVERLAY", "GameFontHighlightMedium")
    text:SetPoint("LEFT", arrow, "RIGHT", 8, 0)
    text:SetText(title)

    btn:SetScript("OnEnter", function()
        btn:SetBackdropColor(0.18, 0.18, 0.22, 0.95)
        btn:SetBackdropBorderColor(0.5, 0.45, 0.7, 0.9)
    end)
    btn:SetScript("OnLeave", function()
        btn:SetBackdropColor(0.12, 0.12, 0.14, 0.85)
        btn:SetBackdropBorderColor(0.3, 0.3, 0.35, 0.7)
    end)

    btn.isExpanded = initialExpanded
    btn.arrow = arrow

    btn:SetScript("OnClick", function()
        btn.isExpanded = not btn.isExpanded
        arrow:SetText(btn.isExpanded and "[ - ]" or "[ + ]")
        if onToggle then onToggle(btn.isExpanded) end
    end)

    return btn
end

-------------------------------------------------------------------------------
-- TAB 1: GAMEPLAY (Hierarchical Submenus: Controls & Interface)
-------------------------------------------------------------------------------
function ConfigUI:BuildGameplayTab(panel, context)
    local layout = context.layoutModel:reset(panel.content, -15)

    layout:header(nil, "Gameplay Synchronization")
    layout:label(nil, "Toggle which in-game settings will synchronize across your account:")

    local CONTROLS_KEYS = {
        "stickyTargeting", "autoDismountInFlight", "autoCancelAwayMode", "interactOnLeftClick",
        "openLootWindowAtMouse", "autoLoot", "combineBags",
        "enableInteractKey", "interactKeySoundCue", "lockCursorToWindow", "invertMouse",
        "mouseLookSpeed", "enableMouseSensitivity", "clickToMove", "clickToMoveCameraStyle",
        "waterCollision", "autoFollowSpeed", "cameraFollowingStyle"
    }

    local INTERFACE_KEYS = {
        "inGameNavigation", "tutorials", "outlineMode", "statusText",
        "replaceOtherPlayerPortraits", "chatBubbles", "chatBubblesParty", "chatBubblesRaid", "replaceMyPlayerPortrait",
        "showWarbandCompletedQuests", "showLowLevelQuests",
        "raidIncomingHeals", "raidPowerBars", "raidOnlyHealerPowerBars", "raidAggroHighlight",
        "raidClassColors", "raidHealthBarColorBG", "raidPets", "raidMainTankAndAssist",
        "raidDebuffs", "raidBiggerRoleDebuffs", "raidOnlyDispellableDebuffs", "raidCenterBigDefensives",
        "raidDispelIndicatorType", "raidDispelIndicatorColor", "raidDispelIndicatorFlashing",
        "raidDispelIndicatorAnimatedBorder", "raidHealthText",
        "arenaPowerBars", "arenaOnlyHealerPowerBars", "arenaClassColors", "arenaPets", "arenaHealthText",
        "housingLightRadius", "housingSelectedDecor", "housingOtherDecor",
        "playerMapCoords", "cursorMapCoords", "playerMinimapCoords", "coordsInTenths"
    }

    local ACTION_BAR_KEYS = {
        "actionBar2", "actionBar3", "actionBar4", "actionBar5",
        "actionBar6", "actionBar7", "actionBar8", "lockActionBars",
        "pickupActionKey", "countdownForCooldowns"
    }

    local COMBAT_KEYS = {
        "personalResourceDisplay", "selfHighlight", "selfHighlightSilhouette",
        "targetOfTarget", "doNotFlashLowHealth", "lossOfControlAlerts",
        "floatingCombatTextSelf", "mouseoverCast", "selfCast",
        "focusCastKey", "empoweredSpellInput", "spellAlertOpacity",
        "pressAndHoldCasting", "actionTargeting"
    }

    local SOCIAL_KEYS = {
        "disableChat", "chatFiltering", "profanityFilter", "guildMemberAlert",
        "blockTrades", "blockGuildInvites", "blockNeighborhoodInvites", "restrictCalendarInvites",
        "blockChannelInvites", "locationVisibility", "onlineFriendsToast", "offlineFriendsToast",
        "broadcastUpdatesToast", "friendRequestsToast", "showToastWindow", "autoAcceptQuickJoin",
        "chatStyle", "whisperMode", "chatTimestamps", "discordDisplayName", "discordClientEnabled"
    }

    local PING_SYSTEM_KEYS = {
        "enablePings", "pingMode", "pingSounds",
        "pingTarget", "showPingsInChat", "showPingsOnRaidFrames"
    }

    local GAMEPLAY_ENHANCEMENTS_KEYS = {
        "assistedCombatReduceHighlights", "assistedCombatHighlight",
        "encounterWarningsEnabled", "encounterWarningsLevel", "encounterWarningsHideIfNotTargetingPlayer",
        "encounterTimelineEnabled", "encounterTimelineHideLongCountdowns", "encounterTimelineHideQueuedCountdowns",
        "encounterTimelineHideForOtherRoles", "encounterTimelineIconographyEnabled",
        "cooldownViewerEnabled", "externalDefensivesEnabled",
        "damageMeterEnabled", "damageMeterResetOnNewInstance",
        "spellDiminishPVPEnemiesEnabled", "spellDiminishPVPOnlyTriggerableByMe"
    }

    local function IsAllGameplaySynced()
        if not AAS.db or not AAS.db.profile then return false end
        for _, k in ipairs(CONTROLS_KEYS) do
            if not getSyncToggle("gameplay", "controls", k, true) then
                return false
            end
        end
        for _, k in ipairs(INTERFACE_KEYS) do
            if not getSyncToggle("gameplay", "interface", k, true) then
                return false
            end
        end
        for _, k in ipairs(ACTION_BAR_KEYS) do
            if not getSyncToggle("gameplay", "actionBars", k, true) then
                return false
            end
        end
        for _, k in ipairs(COMBAT_KEYS) do
            if not getSyncToggle("gameplay", "combat", k, true) then
                return false
            end
        end
        for _, k in ipairs(SOCIAL_KEYS) do
            if not getSyncToggle("gameplay", "social", k, true) then
                return false
            end
        end
        for _, k in ipairs(PING_SYSTEM_KEYS) do
            if not getSyncToggle("gameplay", "pingSystem", k, true) then
                return false
            end
        end
        for _, k in ipairs(GAMEPLAY_ENHANCEMENTS_KEYS) do
            if not getSyncToggle("gameplay", "gameplayEnhancements", k, true) then
                return false
            end
        end
        return true
    end

    local trackedCheckboxes = {}
    local masterCb = nil

    local function RefreshAllCheckboxes()
        for _, item in ipairs(trackedCheckboxes) do
            if item.cb and item.cb.SetChecked and item.getFunc then
                item.cb:SetChecked(item.getFunc())
            end
        end
        if masterCb and masterCb.SetChecked then
            masterCb:SetChecked(IsAllGameplaySynced())
        end
    end

    local function SetAllGameplaySync(val)
        if not AAS.db or not AAS.db.profile then return end
        AAS.db.profile.syncModules = AAS.db.profile.syncModules or {}
        AAS.db.profile.syncModules.gameplay = AAS.db.profile.syncModules.gameplay or {}
        AAS.db.profile.syncModules.gameplay.controls = AAS.db.profile.syncModules.gameplay.controls or {}
        AAS.db.profile.syncModules.gameplay.interface = AAS.db.profile.syncModules.gameplay.interface or {}
        AAS.db.profile.syncModules.gameplay.actionBars = AAS.db.profile.syncModules.gameplay.actionBars or {}
        AAS.db.profile.syncModules.gameplay.combat = AAS.db.profile.syncModules.gameplay.combat or {}
        AAS.db.profile.syncModules.gameplay.social = AAS.db.profile.syncModules.gameplay.social or {}
        AAS.db.profile.syncModules.gameplay.pingSystem = AAS.db.profile.syncModules.gameplay.pingSystem or {}
        AAS.db.profile.syncModules.gameplay.gameplayEnhancements = AAS.db.profile.syncModules.gameplay.gameplayEnhancements or {}

        for _, k in ipairs(CONTROLS_KEYS) do
            AAS.db.profile.syncModules.gameplay.controls[k] = val
        end
        for _, k in ipairs(INTERFACE_KEYS) do
            AAS.db.profile.syncModules.gameplay.interface[k] = val
        end
        for _, k in ipairs(ACTION_BAR_KEYS) do
            AAS.db.profile.syncModules.gameplay.actionBars[k] = val
        end
        for _, k in ipairs(COMBAT_KEYS) do
            AAS.db.profile.syncModules.gameplay.combat[k] = val
        end
        for _, k in ipairs(SOCIAL_KEYS) do
            AAS.db.profile.syncModules.gameplay.social[k] = val
        end
        for _, k in ipairs(PING_SYSTEM_KEYS) do
            AAS.db.profile.syncModules.gameplay.pingSystem[k] = val
        end
        for _, k in ipairs(GAMEPLAY_ENHANCEMENTS_KEYS) do
            AAS.db.profile.syncModules.gameplay.gameplayEnhancements[k] = val
        end

        if val and AAS.Modules.Controls then
            AAS.Modules.Controls:SaveSettings(false, "autoLoot")
        end

        RefreshAllCheckboxes()

        if val then
            AAS.ShowToast("All gameplay synchronization enabled.")
        else
            AAS.ShowToast("All gameplay synchronization disabled.")
        end
    end

    -- Add vertical breathing room between intro text and master toggle
    layout.y = layout.y - 14

    -- Master "Sync Everything" Toggle
    masterCb = layout:checkbox(nil, "|cffEDBA1FSync Everything|r (All Gameplay Settings)",
        "Enable or disable synchronization for all Controls and Interface settings across your account.",
        function() return IsAllGameplaySynced() end,
        function(val)
            SetAllGameplaySync(val)
        end)

    local startY = (layout and layout.y and (layout.y - 16)) or -130

    local colWidth = 280
    local col1X = 0
    local col2X = 315

    -- Track child checkboxes automatically through layoutModel hook
    local origCheckbox = context.layoutModel.checkbox
    context.layoutModel.checkbox = function(self, parent, label, tooltip, getFunc, setFunc)
        local cb = origCheckbox(self, parent, label, tooltip, getFunc, function(val)
            setFunc(val)
            if masterCb and masterCb.SetChecked then
                masterCb:SetChecked(IsAllGameplaySynced())
            end
        end)
        if cb then
            table.insert(trackedCheckboxes, { cb = cb, getFunc = getFunc })
        end
        return cb
    end

    -- -----------------------------------------------------------------------
    -- SUBSECTION 1: CONTROLS
    -- -----------------------------------------------------------------------
    local controlsContainer = CreateFrame("Frame", nil, panel.content)
    controlsContainer:SetWidth(590)

    local cLayout = context.layoutModel:reset(controlsContainer, 0)

    cLayout:header(nil, "General Controls")
    cLayout:beginColumn(col1X, colWidth)
    cLayout:checkbox(nil, "Sticky Targeting", "Synchronize Sticky Targeting option.",
        function() return getSyncToggle("gameplay", "controls", "stickyTargeting", true) end,
        function(v) setSyncToggle("gameplay", "controls", "stickyTargeting", v) end)
    cLayout:checkbox(nil, "Auto Dismount in Flight", "Synchronize Auto Dismount in Flight option.",
        function() return getSyncToggle("gameplay", "controls", "autoDismountInFlight", true) end,
        function(v) setSyncToggle("gameplay", "controls", "autoDismountInFlight", v) end)
    cLayout:checkbox(nil, "Auto Cancel Away Mode", "Synchronize Auto Cancel Away Mode option.",
        function() return getSyncToggle("gameplay", "controls", "autoCancelAwayMode", true) end,
        function(v) setSyncToggle("gameplay", "controls", "autoCancelAwayMode", v) end)
    cLayout:checkbox(nil, "Interact On Left Click", "Synchronize Interact On Left Click option.",
        function() return getSyncToggle("gameplay", "controls", "interactOnLeftClick", true) end,
        function(v) setSyncToggle("gameplay", "controls", "interactOnLeftClick", v) end)
    cLayout:checkbox(nil, "Open Loot at Mouse", "Synchronize Open Loot Window at Mouse option.",
        function() return getSyncToggle("gameplay", "controls", "openLootWindowAtMouse", true) end,
        function(v) setSyncToggle("gameplay", "controls", "openLootWindowAtMouse", v) end)
    cLayout:endColumn()

    cLayout:beginColumn(col2X, colWidth)
    cLayout:checkbox(nil, "Auto Loot", "Synchronize Auto Loot option.",
        function() return getSyncToggle("gameplay", "controls", "autoLoot", true) end,
        function(v)
            setSyncToggle("gameplay", "controls", "autoLoot", v)
            if v and AAS.Modules.Controls then AAS.Modules.Controls:SaveSettings(true, "autoLoot") end
        end)
    cLayout:checkbox(nil, "Combine Bags", "Synchronize Combine Bags single window layout option.",
        function() return getSyncToggle("gameplay", "controls", "combineBags", true) end,
        function(v) setSyncToggle("gameplay", "controls", "combineBags", v) end)
    cLayout:checkbox(nil, "Interact Key", "Synchronize Enable Interact Key option.",
        function() return getSyncToggle("gameplay", "controls", "enableInteractKey", true) end,
        function(v) setSyncToggle("gameplay", "controls", "enableInteractKey", v) end)
    cLayout:checkbox(nil, "Interact Sound Cue", "Synchronize Interact Key Sound Cue audio alert.",
        function() return getSyncToggle("gameplay", "controls", "interactKeySoundCue", true) end,
        function(v) setSyncToggle("gameplay", "controls", "interactKeySoundCue", v) end)
    cLayout:endColumn()
    cLayout:columnsFinalize(controlsContainer, 16)

    cLayout:header(nil, "Mouse")
    cLayout:beginColumn(col1X, colWidth)
    cLayout:checkbox(nil, "Lock Cursor to Window", "Synchronize Lock Cursor to Window option.",
        function() return getSyncToggle("gameplay", "controls", "lockCursorToWindow", true) end,
        function(v) setSyncToggle("gameplay", "controls", "lockCursorToWindow", v) end)
    cLayout:checkbox(nil, "Invert Mouse", "Synchronize Invert Mouse pitch option.",
        function() return getSyncToggle("gameplay", "controls", "invertMouse", true) end,
        function(v) setSyncToggle("gameplay", "controls", "invertMouse", v) end)
    cLayout:checkbox(nil, "Mouse Look Speed", "Synchronize Mouse Look Speed camera sensitivity.",
        function() return getSyncToggle("gameplay", "controls", "mouseLookSpeed", true) end,
        function(v) setSyncToggle("gameplay", "controls", "mouseLookSpeed", v) end)
    cLayout:endColumn()

    cLayout:beginColumn(col2X, colWidth)
    cLayout:checkbox(nil, "Mouse Sensitivity", "Synchronize Enable Mouse Sensitivity option and slider.",
        function() return getSyncToggle("gameplay", "controls", "enableMouseSensitivity", true) end,
        function(v) setSyncToggle("gameplay", "controls", "enableMouseSensitivity", v) end)
    cLayout:checkbox(nil, "Click-to-Move", "Synchronize Click-to-Move auto-interaction option.",
        function() return getSyncToggle("gameplay", "controls", "clickToMove", true) end,
        function(v) setSyncToggle("gameplay", "controls", "clickToMove", v) end)
    cLayout:checkbox(nil, "Click-to-Move Camera", "Synchronize Click-to-Move Camera Style dropdown selection.",
        function() return getSyncToggle("gameplay", "controls", "clickToMoveCameraStyle", true) end,
        function(v) setSyncToggle("gameplay", "controls", "clickToMoveCameraStyle", v) end)
    cLayout:endColumn()
    cLayout:columnsFinalize(controlsContainer, 16)

    cLayout:header(nil, "Camera")
    cLayout:beginColumn(col1X, colWidth)
    cLayout:checkbox(nil, "Water Collision", "Synchronize Water Collision camera behavior.",
        function() return getSyncToggle("gameplay", "controls", "waterCollision", true) end,
        function(v) setSyncToggle("gameplay", "controls", "waterCollision", v) end)
    cLayout:checkbox(nil, "Auto Follow Speed", "Synchronize Auto Follow Speed camera slider value.",
        function() return getSyncToggle("gameplay", "controls", "autoFollowSpeed", true) end,
        function(v) setSyncToggle("gameplay", "controls", "autoFollowSpeed", v) end)
    cLayout:endColumn()

    cLayout:beginColumn(col2X, colWidth)
    cLayout:checkbox(nil, "Camera Following Style", "Synchronize Camera Following Style dropdown selection.",
        function() return getSyncToggle("gameplay", "controls", "cameraFollowingStyle", true) end,
        function(v) setSyncToggle("gameplay", "controls", "cameraFollowingStyle", v) end)
    cLayout:endColumn()
    cLayout:columnsFinalize(controlsContainer, 20)

    local controlsContentHeight = math.abs(cLayout.y) + 10
    controlsContainer:SetHeight(controlsContentHeight)

    -- -----------------------------------------------------------------------
    -- SUBSECTION 2: INTERFACE
    -- -----------------------------------------------------------------------
    local interfaceContainer = CreateFrame("Frame", nil, panel.content)
    interfaceContainer:SetWidth(590)

    local iLayout = context.layoutModel:reset(interfaceContainer, 0)

    -- 1. DISPLAY
    iLayout:header(nil, "Display")
    iLayout:beginColumn(col1X, colWidth)
    iLayout:checkbox(nil, "In Game Navigation", "Synchronize In Game Navigation toggle.",
        function() return getSyncToggle("gameplay", "interface", "inGameNavigation", true) end,
        function(v) setSyncToggle("gameplay", "interface", "inGameNavigation", v) end)
    iLayout:checkbox(nil, "Tutorials", "Synchronize Tutorials display toggle.",
        function() return getSyncToggle("gameplay", "interface", "tutorials", true) end,
        function(v) setSyncToggle("gameplay", "interface", "tutorials", v) end)
    iLayout:checkbox(nil, "Outline Mode", "Synchronize Outline Mode target highlight setting.",
        function() return getSyncToggle("gameplay", "interface", "outlineMode", true) end,
        function(v) setSyncToggle("gameplay", "interface", "outlineMode", v) end)
    iLayout:checkbox(nil, "Status Text", "Synchronize Status Text numeric display style.",
        function() return getSyncToggle("gameplay", "interface", "statusText", true) end,
        function(v) setSyncToggle("gameplay", "interface", "statusText", v) end)
    iLayout:checkbox(nil, "Target 3D Portraits", "Synchronize 3D class portraits for target & player frames.",
        function() return getSyncToggle("gameplay", "interface", "replaceOtherPlayerPortraits", true) end,
        function(v) setSyncToggle("gameplay", "interface", "replaceOtherPlayerPortraits", v) end)
    iLayout:endColumn()

    iLayout:beginColumn(col2X, colWidth)
    iLayout:checkbox(nil, "Chat Bubbles", "Synchronize Chat Bubbles toggle.",
        function() return getSyncToggle("gameplay", "interface", "chatBubbles", true) end,
        function(v) setSyncToggle("gameplay", "interface", "chatBubbles", v) end)
    iLayout:checkbox(nil, "Party Chat Bubbles", "Synchronize Party Chat Bubbles toggle.",
        function() return getSyncToggle("gameplay", "interface", "chatBubblesParty", true) end,
        function(v) setSyncToggle("gameplay", "interface", "chatBubblesParty", v) end)
    iLayout:checkbox(nil, "Raid Chat Bubbles", "Synchronize Instance and Raid Chat Bubbles toggle.",
        function() return getSyncToggle("gameplay", "interface", "chatBubblesRaid", true) end,
        function(v) setSyncToggle("gameplay", "interface", "chatBubblesRaid", v) end)
    iLayout:checkbox(nil, "Player 3D Portrait", "Synchronize 3D class portrait for player frame.",
        function() return getSyncToggle("gameplay", "interface", "replaceMyPlayerPortrait", true) end,
        function(v) setSyncToggle("gameplay", "interface", "replaceMyPlayerPortrait", v) end)
    iLayout:endColumn()
    iLayout:columnsFinalize(interfaceContainer, 16)

    -- 2. QUESTS
    iLayout:header(nil, "Quests")
    iLayout:beginColumn(col1X, colWidth)
    iLayout:checkbox(nil, "Warband Completed Quests", "Synchronize Warband Completed Quests map tracking.",
        function() return getSyncToggle("gameplay", "interface", "showWarbandCompletedQuests", true) end,
        function(v) setSyncToggle("gameplay", "interface", "showWarbandCompletedQuests", v) end)
    iLayout:endColumn()

    iLayout:beginColumn(col2X, colWidth)
    iLayout:checkbox(nil, "Low-Level Quests", "Synchronize Low-Level (trivial) Quests tracking.",
        function() return getSyncToggle("gameplay", "interface", "showLowLevelQuests", true) end,
        function(v) setSyncToggle("gameplay", "interface", "showLowLevelQuests", v) end)
    iLayout:endColumn()
    iLayout:columnsFinalize(interfaceContainer, 16)

    -- 3. RAID FRAMES
    iLayout:header(nil, "Raid Frames")
    iLayout:beginColumn(col1X, colWidth)
    iLayout:checkbox(nil, "Incoming Heals", "Synchronize Display Incoming Heals on raid frames.",
        function() return getSyncToggle("gameplay", "interface", "raidIncomingHeals", true) end,
        function(v) setSyncToggle("gameplay", "interface", "raidIncomingHeals", v) end)
    iLayout:checkbox(nil, "Power Bars", "Synchronize Display Power Bars on raid frames.",
        function() return getSyncToggle("gameplay", "interface", "raidPowerBars", true) end,
        function(v) setSyncToggle("gameplay", "interface", "raidPowerBars", v) end)
    iLayout:checkbox(nil, "Only Healer Power Bars", "Synchronize Display Only Healer Power Bars on raid frames.",
        function() return getSyncToggle("gameplay", "interface", "raidOnlyHealerPowerBars", true) end,
        function(v) setSyncToggle("gameplay", "interface", "raidOnlyHealerPowerBars", v) end)
    iLayout:checkbox(nil, "Aggro Highlight", "Synchronize Display Aggro Highlight border.",
        function() return getSyncToggle("gameplay", "interface", "raidAggroHighlight", true) end,
        function(v) setSyncToggle("gameplay", "interface", "raidAggroHighlight", v) end)
    iLayout:checkbox(nil, "Class Colors", "Synchronize Display Class Colors on raid frames.",
        function() return getSyncToggle("gameplay", "interface", "raidClassColors", true) end,
        function(v) setSyncToggle("gameplay", "interface", "raidClassColors", v) end)
    iLayout:checkbox(nil, "Background Color", "Synchronize custom raid frame background color.",
        function() return getSyncToggle("gameplay", "interface", "raidHealthBarColorBG", true) end,
        function(v) setSyncToggle("gameplay", "interface", "raidHealthBarColorBG", v) end)
    iLayout:checkbox(nil, "Show Pets", "Synchronize Display Pets on raid frames.",
        function() return getSyncToggle("gameplay", "interface", "raidPets", true) end,
        function(v) setSyncToggle("gameplay", "interface", "raidPets", v) end)
    iLayout:checkbox(nil, "Main Tank & Assist", "Synchronize Display Main Tank and Assist units.",
        function() return getSyncToggle("gameplay", "interface", "raidMainTankAndAssist", true) end,
        function(v) setSyncToggle("gameplay", "interface", "raidMainTankAndAssist", v) end)
    iLayout:endColumn()

    iLayout:beginColumn(col2X, colWidth)
    iLayout:checkbox(nil, "Show Debuffs", "Synchronize Show Debuffs on raid frames.",
        function() return getSyncToggle("gameplay", "interface", "raidDebuffs", true) end,
        function(v) setSyncToggle("gameplay", "interface", "raidDebuffs", v) end)
    iLayout:checkbox(nil, "Bigger Role Debuffs", "Synchronize Bigger Role Debuffs on raid frames.",
        function() return getSyncToggle("gameplay", "interface", "raidBiggerRoleDebuffs", true) end,
        function(v) setSyncToggle("gameplay", "interface", "raidBiggerRoleDebuffs", v) end)
    iLayout:checkbox(nil, "Only Dispellable Debuffs", "Synchronize Display Only Dispellable Debuffs on raid frames.",
        function() return getSyncToggle("gameplay", "interface", "raidOnlyDispellableDebuffs", true) end,
        function(v) setSyncToggle("gameplay", "interface", "raidOnlyDispellableDebuffs", v) end)
    iLayout:checkbox(nil, "Center Big Defensives", "Synchronize Center Big Defensives icon display.",
        function() return getSyncToggle("gameplay", "interface", "raidCenterBigDefensives", true) end,
        function(v) setSyncToggle("gameplay", "interface", "raidCenterBigDefensives", v) end)
    iLayout:checkbox(nil, "Dispel Indicator Type", "Synchronize Dispellable Debuff Indicator style.",
        function() return getSyncToggle("gameplay", "interface", "raidDispelIndicatorType", true) end,
        function(v) setSyncToggle("gameplay", "interface", "raidDispelIndicatorType", v) end)
    iLayout:checkbox(nil, "Dispel Indicator Color", "Synchronize Debuff Indicator Color overlay.",
        function() return getSyncToggle("gameplay", "interface", "raidDispelIndicatorColor", true) end,
        function(v) setSyncToggle("gameplay", "interface", "raidDispelIndicatorColor", v) end)
    iLayout:checkbox(nil, "Dispel Flashing Anim", "Synchronize Flashing Animation for dispel indicators.",
        function() return getSyncToggle("gameplay", "interface", "raidDispelIndicatorFlashing", true) end,
        function(v) setSyncToggle("gameplay", "interface", "raidDispelIndicatorFlashing", v) end)
    iLayout:checkbox(nil, "Dispel Animated Border", "Synchronize Animated Border for dispel indicators.",
        function() return getSyncToggle("gameplay", "interface", "raidDispelIndicatorAnimatedBorder", true) end,
        function(v) setSyncToggle("gameplay", "interface", "raidDispelIndicatorAnimatedBorder", v) end)
    iLayout:checkbox(nil, "Health Text", "Synchronize Display Health Text on raid frames.",
        function() return getSyncToggle("gameplay", "interface", "raidHealthText", true) end,
        function(v) setSyncToggle("gameplay", "interface", "raidHealthText", v) end)
    iLayout:endColumn()
    iLayout:columnsFinalize(interfaceContainer, 16)

    -- 4. ARENA ENEMY FRAMES
    iLayout:header(nil, "Arena Enemy Frames")
    iLayout:beginColumn(col1X, colWidth)
    iLayout:checkbox(nil, "Power Bars", "Synchronize Display Power Bars on arena enemy frames.",
        function() return getSyncToggle("gameplay", "interface", "arenaPowerBars", true) end,
        function(v) setSyncToggle("gameplay", "interface", "arenaPowerBars", v) end)
    iLayout:checkbox(nil, "Only Healer Power Bars", "Synchronize Display Only Healer Power Bars on arena enemy frames.",
        function() return getSyncToggle("gameplay", "interface", "arenaOnlyHealerPowerBars", true) end,
        function(v) setSyncToggle("gameplay", "interface", "arenaOnlyHealerPowerBars", v) end)
    iLayout:checkbox(nil, "Class Colors", "Synchronize Display Class Colors on arena enemy frames.",
        function() return getSyncToggle("gameplay", "interface", "arenaClassColors", true) end,
        function(v) setSyncToggle("gameplay", "interface", "arenaClassColors", v) end)
    iLayout:endColumn()

    iLayout:beginColumn(col2X, colWidth)
    iLayout:checkbox(nil, "Show Pets", "Synchronize Display Pets on arena enemy frames.",
        function() return getSyncToggle("gameplay", "interface", "arenaPets", true) end,
        function(v) setSyncToggle("gameplay", "interface", "arenaPets", v) end)
    iLayout:checkbox(nil, "Health Text", "Synchronize Display Health Text on arena enemy frames.",
        function() return getSyncToggle("gameplay", "interface", "arenaHealthText", true) end,
        function(v) setSyncToggle("gameplay", "interface", "arenaHealthText", v) end)
    iLayout:endColumn()
    iLayout:columnsFinalize(interfaceContainer, 16)

    -- 5. HOUSING
    iLayout:header(nil, "Housing")
    iLayout:beginColumn(col1X, colWidth)
    iLayout:checkbox(nil, "Light Radius Indicators", "Synchronize Light Radius Indicators in housing editor.",
        function() return getSyncToggle("gameplay", "interface", "housingLightRadius", true) end,
        function(v) setSyncToggle("gameplay", "interface", "housingLightRadius", v) end)
    iLayout:checkbox(nil, "Selected Decor", "Synchronize Selected Decor highlight mode.",
        function() return getSyncToggle("gameplay", "interface", "housingSelectedDecor", true) end,
        function(v) setSyncToggle("gameplay", "interface", "housingSelectedDecor", v) end)
    iLayout:endColumn()

    iLayout:beginColumn(col2X, colWidth)
    iLayout:checkbox(nil, "Other Decor", "Synchronize Other Decor highlight mode.",
        function() return getSyncToggle("gameplay", "interface", "housingOtherDecor", true) end,
        function(v) setSyncToggle("gameplay", "interface", "housingOtherDecor", v) end)
    iLayout:endColumn()
    iLayout:columnsFinalize(interfaceContainer, 16)

    -- 6. MAP COORDINATES
    iLayout:header(nil, "Map Coordinates")
    iLayout:beginColumn(col1X, colWidth)
    iLayout:checkbox(nil, "Player Map Coords", "Synchronize Player Map Coordinates on world map.",
        function() return getSyncToggle("gameplay", "interface", "playerMapCoords", true) end,
        function(v) setSyncToggle("gameplay", "interface", "playerMapCoords", v) end)
    iLayout:checkbox(nil, "Cursor Map Coords", "Synchronize Cursor Map Coordinates on world map.",
        function() return getSyncToggle("gameplay", "interface", "cursorMapCoords", true) end,
        function(v) setSyncToggle("gameplay", "interface", "cursorMapCoords", v) end)
    iLayout:endColumn()

    iLayout:beginColumn(col2X, colWidth)
    iLayout:checkbox(nil, "Player Minimap Coords", "Synchronize Player Minimap Coordinates.",
        function() return getSyncToggle("gameplay", "interface", "playerMinimapCoords", true) end,
        function(v) setSyncToggle("gameplay", "interface", "playerMinimapCoords", v) end)
    iLayout:checkbox(nil, "Precision in Tenths", "Synchronize Coordinates precision in tenths.",
        function() return getSyncToggle("gameplay", "interface", "coordsInTenths", true) end,
        function(v) setSyncToggle("gameplay", "interface", "coordsInTenths", v) end)
    iLayout:endColumn()
    iLayout:columnsFinalize(interfaceContainer, 20)

    local interfaceContentHeight = math.abs(iLayout.y) + 10
    interfaceContainer:SetHeight(interfaceContentHeight)

    -- -----------------------------------------------------------------------
    -- SUBSECTION 3: ACTION BARS
    -- -----------------------------------------------------------------------
    local actionBarsContainer = CreateFrame("Frame", nil, panel.content)
    actionBarsContainer:SetWidth(590)

    local abLayout = context.layoutModel:reset(actionBarsContainer, 0)

    abLayout:header(nil, "Action Bars")
    abLayout:beginColumn(col1X, colWidth)
    abLayout:checkbox(nil, "Action Bar 2", "Synchronize Action Bar 2 (Bottom Left) visibility.",
        function() return getSyncToggle("gameplay", "actionBars", "actionBar2", true) end,
        function(v) setSyncToggle("gameplay", "actionBars", "actionBar2", v) end)
    abLayout:checkbox(nil, "Action Bar 3", "Synchronize Action Bar 3 (Bottom Right) visibility.",
        function() return getSyncToggle("gameplay", "actionBars", "actionBar3", true) end,
        function(v) setSyncToggle("gameplay", "actionBars", "actionBar3", v) end)
    abLayout:checkbox(nil, "Action Bar 4", "Synchronize Action Bar 4 (Right Bar 1) visibility.",
        function() return getSyncToggle("gameplay", "actionBars", "actionBar4", true) end,
        function(v) setSyncToggle("gameplay", "actionBars", "actionBar4", v) end)
    abLayout:checkbox(nil, "Action Bar 5", "Synchronize Action Bar 5 (Right Bar 2) visibility.",
        function() return getSyncToggle("gameplay", "actionBars", "actionBar5", true) end,
        function(v) setSyncToggle("gameplay", "actionBars", "actionBar5", v) end)
    abLayout:checkbox(nil, "Action Bar 6", "Synchronize Action Bar 6 visibility.",
        function() return getSyncToggle("gameplay", "actionBars", "actionBar6", true) end,
        function(v) setSyncToggle("gameplay", "actionBars", "actionBar6", v) end)
    abLayout:endColumn()

    abLayout:beginColumn(col2X, colWidth)
    abLayout:checkbox(nil, "Action Bar 7", "Synchronize Action Bar 7 visibility.",
        function() return getSyncToggle("gameplay", "actionBars", "actionBar7", true) end,
        function(v) setSyncToggle("gameplay", "actionBars", "actionBar7", v) end)
    abLayout:checkbox(nil, "Action Bar 8", "Synchronize Action Bar 8 visibility.",
        function() return getSyncToggle("gameplay", "actionBars", "actionBar8", true) end,
        function(v) setSyncToggle("gameplay", "actionBars", "actionBar8", v) end)
    abLayout:checkbox(nil, "Lock Action Bars", "Synchronize Lock Action Bars setting.",
        function() return getSyncToggle("gameplay", "actionBars", "lockActionBars", true) end,
        function(v) setSyncToggle("gameplay", "actionBars", "lockActionBars", v) end)
    abLayout:checkbox(nil, "Lock Modifier Key", "Synchronize pickup action modifier key (Shift/Alt/Ctrl).",
        function() return getSyncToggle("gameplay", "actionBars", "pickupActionKey", true) end,
        function(v) setSyncToggle("gameplay", "actionBars", "pickupActionKey", v) end)
    abLayout:checkbox(nil, "Numbers for Cooldowns", "Synchronize numeric countdown timers on cooldowns.",
        function() return getSyncToggle("gameplay", "actionBars", "countdownForCooldowns", true) end,
        function(v) setSyncToggle("gameplay", "actionBars", "countdownForCooldowns", v) end)
    abLayout:endColumn()
    abLayout:columnsFinalize(actionBarsContainer, 20)

    local actionBarsContentHeight = math.abs(abLayout.y) + 10
    actionBarsContainer:SetHeight(actionBarsContentHeight)

    -- -----------------------------------------------------------------------
    -- SUBSECTION 4: COMBAT
    -- -----------------------------------------------------------------------
    local combatContainer = CreateFrame("Frame", nil, panel.content)
    combatContainer:SetWidth(590)

    local cbLayout = context.layoutModel:reset(combatContainer, 0)

    cbLayout:header(nil, "Combat")
    cbLayout:beginColumn(col1X, colWidth)
    cbLayout:checkbox(nil, "Personal Resource Display", "Synchronize Personal Resource Display on character.",
        function() return getSyncToggle("gameplay", "combat", "personalResourceDisplay", true) end,
        function(v) setSyncToggle("gameplay", "combat", "personalResourceDisplay", v) end)
    cbLayout:checkbox(nil, "Self Highlight", "Synchronize self character highlight mode (Circle/Outline).",
        function() return getSyncToggle("gameplay", "combat", "selfHighlight", true) end,
        function(v) setSyncToggle("gameplay", "combat", "selfHighlight", v) end)
    cbLayout:checkbox(nil, "Silhouette when Obscured", "Synchronize self highlight silhouette when obscured.",
        function() return getSyncToggle("gameplay", "combat", "selfHighlightSilhouette", true) end,
        function(v) setSyncToggle("gameplay", "combat", "selfHighlightSilhouette", v) end)
    cbLayout:checkbox(nil, "Target of Target", "Synchronize Target of Target frame display.",
        function() return getSyncToggle("gameplay", "combat", "targetOfTarget", true) end,
        function(v) setSyncToggle("gameplay", "combat", "targetOfTarget", v) end)
    cbLayout:checkbox(nil, "Do Not Flash at Low Health", "Synchronize low health screen flash warning setting.",
        function() return getSyncToggle("gameplay", "combat", "doNotFlashLowHealth", true) end,
        function(v) setSyncToggle("gameplay", "combat", "doNotFlashLowHealth", v) end)
    cbLayout:checkbox(nil, "Loss of Control Alerts", "Synchronize Loss of Control alert messages.",
        function() return getSyncToggle("gameplay", "combat", "lossOfControlAlerts", true) end,
        function(v) setSyncToggle("gameplay", "combat", "lossOfControlAlerts", v) end)
    cbLayout:checkbox(nil, "Scrolling Combat Text for Self", "Synchronize Floating Combat Text scrolling over self.",
        function() return getSyncToggle("gameplay", "combat", "floatingCombatTextSelf", true) end,
        function(v) setSyncToggle("gameplay", "combat", "floatingCombatTextSelf", v) end)
    cbLayout:endColumn()

    cbLayout:beginColumn(col2X, colWidth)
    cbLayout:checkbox(nil, "Mouseover Cast", "Synchronize base mouseover casting and modifier key.",
        function() return getSyncToggle("gameplay", "combat", "mouseoverCast", true) end,
        function(v) setSyncToggle("gameplay", "combat", "mouseoverCast", v) end)
    cbLayout:checkbox(nil, "Self Cast & Key", "Synchronize Auto Self Cast mode and modifier key.",
        function() return getSyncToggle("gameplay", "combat", "selfCast", true) end,
        function(v) setSyncToggle("gameplay", "combat", "selfCast", v) end)
    cbLayout:checkbox(nil, "Focus Cast Key", "Synchronize Focus Cast modifier key.",
        function() return getSyncToggle("gameplay", "combat", "focusCastKey", true) end,
        function(v) setSyncToggle("gameplay", "combat", "focusCastKey", v) end)
    cbLayout:checkbox(nil, "Empowered Spell Input", "Synchronize Empowered Spell Input method (Hold vs Tap).",
        function() return getSyncToggle("gameplay", "combat", "empoweredSpellInput", true) end,
        function(v) setSyncToggle("gameplay", "combat", "empoweredSpellInput", v) end)
    cbLayout:checkbox(nil, "Spell Alert Opacity", "Synchronize Spell Activation Overlay alert opacity.",
        function() return getSyncToggle("gameplay", "combat", "spellAlertOpacity", true) end,
        function(v) setSyncToggle("gameplay", "combat", "spellAlertOpacity", v) end)
    cbLayout:checkbox(nil, "Press and Hold Casting", "Synchronize Press and Hold continuous spell casting.",
        function() return getSyncToggle("gameplay", "combat", "pressAndHoldCasting", true) end,
        function(v) setSyncToggle("gameplay", "combat", "pressAndHoldCasting", v) end)
    cbLayout:checkbox(nil, "Enable Action Targeting", "Synchronize Action / Soft Targeting auto-targeting.",
        function() return getSyncToggle("gameplay", "combat", "actionTargeting", true) end,
        function(v) setSyncToggle("gameplay", "combat", "actionTargeting", v) end)
    cbLayout:endColumn()
    cbLayout:columnsFinalize(combatContainer, 20)

    local combatContentHeight = math.abs(cbLayout.y) + 10
    combatContainer:SetHeight(combatContentHeight)

    -- -----------------------------------------------------------------------
    -- SUBSECTION 5: SOCIAL
    -- -----------------------------------------------------------------------
    local socialContainer = CreateFrame("Frame", nil, panel.content)
    socialContainer:SetWidth(590)

    local scLayout = context.layoutModel:reset(socialContainer, 0)

    scLayout:header(nil, "Social")
    scLayout:beginColumn(col1X, colWidth)
    scLayout:checkbox(nil, "Disable Chat", "Synchronize Disable Chat option.",
        function() return getSyncToggle("gameplay", "social", "disableChat", true) end,
        function(v) setSyncToggle("gameplay", "social", "disableChat", v) end)
    scLayout:checkbox(nil, "Real Time Chat Filtering", "Synchronize Real Time Chat Filtering mode.",
        function() return getSyncToggle("gameplay", "social", "chatFiltering", true) end,
        function(v) setSyncToggle("gameplay", "social", "chatFiltering", v) end)
    scLayout:checkbox(nil, "Mature Language Filter", "Synchronize Mature Language Filter option.",
        function() return getSyncToggle("gameplay", "social", "profanityFilter", true) end,
        function(v) setSyncToggle("gameplay", "social", "profanityFilter", v) end)
    scLayout:checkbox(nil, "Guild Member Alert", "Synchronize Guild Member login alert option.",
        function() return getSyncToggle("gameplay", "social", "guildMemberAlert", true) end,
        function(v) setSyncToggle("gameplay", "social", "guildMemberAlert", v) end)
    scLayout:checkbox(nil, "Block Trades", "Synchronize Block Trades option.",
        function() return getSyncToggle("gameplay", "social", "blockTrades", true) end,
        function(v) setSyncToggle("gameplay", "social", "blockTrades", v) end)
    scLayout:checkbox(nil, "Block Guild Invites", "Synchronize Block Guild Invites option.",
        function() return getSyncToggle("gameplay", "social", "blockGuildInvites", true) end,
        function(v) setSyncToggle("gameplay", "social", "blockGuildInvites", v) end)
    scLayout:checkbox(nil, "Block Neighborhood Invites", "Synchronize Block Neighborhood Invites option.",
        function() return getSyncToggle("gameplay", "social", "blockNeighborhoodInvites", true) end,
        function(v) setSyncToggle("gameplay", "social", "blockNeighborhoodInvites", v) end)
    scLayout:checkbox(nil, "Restrict Calendar Invites", "Synchronize Restrict Calendar Invites option.",
        function() return getSyncToggle("gameplay", "social", "restrictCalendarInvites", true) end,
        function(v) setSyncToggle("gameplay", "social", "restrictCalendarInvites", v) end)
    scLayout:checkbox(nil, "Block Chat Channel Invites", "Synchronize Block Chat Channel Invites option.",
        function() return getSyncToggle("gameplay", "social", "blockChannelInvites", true) end,
        function(v) setSyncToggle("gameplay", "social", "blockChannelInvites", v) end)
    scLayout:checkbox(nil, "Discord Display Name", "Synchronize Discord display name in chat.",
        function() return getSyncToggle("gameplay", "social", "discordDisplayName", true) end,
        function(v) setSyncToggle("gameplay", "social", "discordDisplayName", v) end)
    scLayout:checkbox(nil, "Enable Discord", "Synchronize Enable Discord Functionality option.",
        function() return getSyncToggle("gameplay", "social", "discordClientEnabled", true) end,
        function(v) setSyncToggle("gameplay", "social", "discordClientEnabled", v) end)
    scLayout:endColumn()

    scLayout:beginColumn(col2X, colWidth)
    scLayout:checkbox(nil, "Online Friends", "Synchronize Online Friends toast alerts.",
        function() return getSyncToggle("gameplay", "social", "onlineFriendsToast", true) end,
        function(v) setSyncToggle("gameplay", "social", "onlineFriendsToast", v) end)
    scLayout:checkbox(nil, "Offline Friends", "Synchronize Offline Friends toast alerts.",
        function() return getSyncToggle("gameplay", "social", "offlineFriendsToast", true) end,
        function(v) setSyncToggle("gameplay", "social", "offlineFriendsToast", v) end)
    scLayout:checkbox(nil, "Broadcast Updates", "Synchronize Broadcast Updates toast alerts.",
        function() return getSyncToggle("gameplay", "social", "broadcastUpdatesToast", true) end,
        function(v) setSyncToggle("gameplay", "social", "broadcastUpdatesToast", v) end)
    scLayout:checkbox(nil, "Location Visibility", "Synchronize Location Visibility for Recent Allies.",
        function() return getSyncToggle("gameplay", "social", "locationVisibility", true) end,
        function(v) setSyncToggle("gameplay", "social", "locationVisibility", v) end)
    scLayout:checkbox(nil, "Battle.net Friend Requests", "Synchronize Battle.net Friend Requests toast alerts.",
        function() return getSyncToggle("gameplay", "social", "friendRequestsToast", true) end,
        function(v) setSyncToggle("gameplay", "social", "friendRequestsToast", v) end)
    scLayout:checkbox(nil, "Show Toast Window", "Synchronize Show Toast Window option.",
        function() return getSyncToggle("gameplay", "social", "showToastWindow", true) end,
        function(v) setSyncToggle("gameplay", "social", "showToastWindow", v) end)
    scLayout:checkbox(nil, "Auto Accept Quick Join Requests", "Synchronize Auto Accept Quick Join Requests.",
        function() return getSyncToggle("gameplay", "social", "autoAcceptQuickJoin", true) end,
        function(v) setSyncToggle("gameplay", "social", "autoAcceptQuickJoin", v) end)
    scLayout:checkbox(nil, "Chat Style", "Synchronize Chat Edit Box Style (Classic / IM).",
        function() return getSyncToggle("gameplay", "social", "chatStyle", true) end,
        function(v) setSyncToggle("gameplay", "social", "chatStyle", v) end)
    scLayout:checkbox(nil, "New Whispers", "Synchronize New Whispers placement (Inline / Popout).",
        function() return getSyncToggle("gameplay", "social", "whisperMode", true) end,
        function(v) setSyncToggle("gameplay", "social", "whisperMode", v) end)
    scLayout:checkbox(nil, "Chat Timestamps", "Synchronize Chat Timestamps format.",
        function() return getSyncToggle("gameplay", "social", "chatTimestamps", true) end,
        function(v) setSyncToggle("gameplay", "social", "chatTimestamps", v) end)
    scLayout:endColumn()
    scLayout:columnsFinalize(socialContainer, 20)

    local socialContentHeight = math.abs(scLayout.y) + 10
    socialContainer:SetHeight(socialContentHeight)

    -- -----------------------------------------------------------------------
    -- SUBSECTION 6: PING SYSTEM
    -- -----------------------------------------------------------------------
    local pingSystemContainer = CreateFrame("Frame", nil, panel.content)
    pingSystemContainer:SetWidth(590)

    local psLayout = context.layoutModel:reset(pingSystemContainer, 0)

    psLayout:header(nil, "Ping System")
    psLayout:beginColumn(col1X, colWidth)
    psLayout:checkbox(nil, "Enable Pings", "Synchronize Enable Pings option.",
        function() return getSyncToggle("gameplay", "pingSystem", "enablePings", true) end,
        function(v) setSyncToggle("gameplay", "pingSystem", "enablePings", v) end)
    psLayout:checkbox(nil, "Ping Mode", "Synchronize Ping Mode (Quick Ping vs Ping Wheel).",
        function() return getSyncToggle("gameplay", "pingSystem", "pingMode", true) end,
        function(v) setSyncToggle("gameplay", "pingSystem", "pingMode", v) end)
    psLayout:checkbox(nil, "Ping Sounds", "Synchronize Ping audio alerts and volume.",
        function() return getSyncToggle("gameplay", "pingSystem", "pingSounds", true) end,
        function(v) setSyncToggle("gameplay", "pingSystem", "pingSounds", v) end)
    psLayout:endColumn()

    psLayout:beginColumn(col2X, colWidth)
    psLayout:checkbox(nil, "Ping Target", "Synchronize Ping Target display setting.",
        function() return getSyncToggle("gameplay", "pingSystem", "pingTarget", true) end,
        function(v) setSyncToggle("gameplay", "pingSystem", "pingTarget", v) end)
    psLayout:checkbox(nil, "Show Pings in Chat", "Synchronize Show Pings in Chat option.",
        function() return getSyncToggle("gameplay", "pingSystem", "showPingsInChat", true) end,
        function(v) setSyncToggle("gameplay", "pingSystem", "showPingsInChat", v) end)
    psLayout:checkbox(nil, "Show Pings on Raid Frames", "Synchronize Show Pings on Raid Frames option.",
        function() return getSyncToggle("gameplay", "pingSystem", "showPingsOnRaidFrames", true) end,
        function(v) setSyncToggle("gameplay", "pingSystem", "showPingsOnRaidFrames", v) end)
    psLayout:endColumn()
    psLayout:columnsFinalize(pingSystemContainer, 20)

    local pingSystemContentHeight = math.abs(psLayout.y) + 10
    pingSystemContainer:SetHeight(pingSystemContentHeight)

    -- -----------------------------------------------------------------------
    -- SUBSECTION 7: GAMEPLAY ENHANCEMENTS
    -- -----------------------------------------------------------------------
    local gameplayEnhancementsContainer = CreateFrame("Frame", nil, panel.content)
    gameplayEnhancementsContainer:SetWidth(590)

    local geLayout = context.layoutModel:reset(gameplayEnhancementsContainer, 0)

    geLayout:header(nil, "Gameplay Enhancements")
    geLayout:beginColumn(col1X, colWidth)
    geLayout:checkbox(nil, "Reduce Highlights on Abilities", "Synchronize Reduce Highlights on Abilities setting.",
        function() return getSyncToggle("gameplay", "gameplayEnhancements", "assistedCombatReduceHighlights", true) end,
        function(v) setSyncToggle("gameplay", "gameplayEnhancements", "assistedCombatReduceHighlights", v) end)
    geLayout:checkbox(nil, "Assisted Highlight", "Synchronize Assisted Highlight setting.",
        function() return getSyncToggle("gameplay", "gameplayEnhancements", "assistedCombatHighlight", true) end,
        function(v) setSyncToggle("gameplay", "gameplayEnhancements", "assistedCombatHighlight", v) end)
    geLayout:checkbox(nil, "Enable Boss Warnings", "Synchronize Enable Boss Warnings setting.",
        function() return getSyncToggle("gameplay", "gameplayEnhancements", "encounterWarningsEnabled", true) end,
        function(v) setSyncToggle("gameplay", "gameplayEnhancements", "encounterWarningsEnabled", v) end)
    geLayout:checkbox(nil, "Enable Text Warnings", "Synchronize Enable Text Warnings setting.",
        function() return getSyncToggle("gameplay", "gameplayEnhancements", "encounterWarningsLevel", true) end,
        function(v) setSyncToggle("gameplay", "gameplayEnhancements", "encounterWarningsLevel", v) end)
    geLayout:checkbox(nil, "Hide When Not Targeted", "Synchronize Hide When Not Targeted setting.",
        function() return getSyncToggle("gameplay", "gameplayEnhancements", "encounterWarningsHideIfNotTargetingPlayer", true) end,
        function(v) setSyncToggle("gameplay", "gameplayEnhancements", "encounterWarningsHideIfNotTargetingPlayer", v) end)
    geLayout:checkbox(nil, "Enable Boss Abilities", "Synchronize Enable Boss Abilities setting.",
        function() return getSyncToggle("gameplay", "gameplayEnhancements", "encounterTimelineEnabled", true) end,
        function(v) setSyncToggle("gameplay", "gameplayEnhancements", "encounterTimelineEnabled", v) end)
    geLayout:checkbox(nil, "Hide Long Countdowns", "Synchronize Hide Long Countdowns setting.",
        function() return getSyncToggle("gameplay", "gameplayEnhancements", "encounterTimelineHideLongCountdowns", true) end,
        function(v) setSyncToggle("gameplay", "gameplayEnhancements", "encounterTimelineHideLongCountdowns", v) end)
    geLayout:checkbox(nil, "Hide Queued Countdowns", "Synchronize Hide Queued Countdowns setting.",
        function() return getSyncToggle("gameplay", "gameplayEnhancements", "encounterTimelineHideQueuedCountdowns", true) end,
        function(v) setSyncToggle("gameplay", "gameplayEnhancements", "encounterTimelineHideQueuedCountdowns", v) end)
    geLayout:endColumn()

    geLayout:beginColumn(col2X, colWidth)
    geLayout:checkbox(nil, "Hide for Other Roles", "Synchronize Hide Countdowns for Other Roles setting.",
        function() return getSyncToggle("gameplay", "gameplayEnhancements", "encounterTimelineHideForOtherRoles", true) end,
        function(v) setSyncToggle("gameplay", "gameplayEnhancements", "encounterTimelineHideForOtherRoles", v) end)
    geLayout:checkbox(nil, "Spell Support Iconography", "Synchronize Spell Support Iconography setting.",
        function() return getSyncToggle("gameplay", "gameplayEnhancements", "encounterTimelineIconographyEnabled", true) end,
        function(v) setSyncToggle("gameplay", "gameplayEnhancements", "encounterTimelineIconographyEnabled", v) end)
    geLayout:checkbox(nil, "Enable Cooldown Manager", "Synchronize Enable Cooldown Manager setting.",
        function() return getSyncToggle("gameplay", "gameplayEnhancements", "cooldownViewerEnabled", true) end,
        function(v) setSyncToggle("gameplay", "gameplayEnhancements", "cooldownViewerEnabled", v) end)
    geLayout:checkbox(nil, "Enable External Defensives", "Synchronize Enable External Defensives setting.",
        function() return getSyncToggle("gameplay", "gameplayEnhancements", "externalDefensivesEnabled", true) end,
        function(v) setSyncToggle("gameplay", "gameplayEnhancements", "externalDefensivesEnabled", v) end)
    geLayout:checkbox(nil, "Enable Damage Meter", "Synchronize Enable Damage Meter setting.",
        function() return getSyncToggle("gameplay", "gameplayEnhancements", "damageMeterEnabled", true) end,
        function(v) setSyncToggle("gameplay", "gameplayEnhancements", "damageMeterEnabled", v) end)
    geLayout:checkbox(nil, "Auto Reset Damage Meter", "Synchronize Auto Reset Damage Meter setting.",
        function() return getSyncToggle("gameplay", "gameplayEnhancements", "damageMeterResetOnNewInstance", true) end,
        function(v) setSyncToggle("gameplay", "gameplayEnhancements", "damageMeterResetOnNewInstance", v) end)
    geLayout:checkbox(nil, "Diminishing Returns Tracking", "Synchronize Diminishing Returns Tracking setting.",
        function() return getSyncToggle("gameplay", "gameplayEnhancements", "spellDiminishPVPEnemiesEnabled", true) end,
        function(v) setSyncToggle("gameplay", "gameplayEnhancements", "spellDiminishPVPEnemiesEnabled", v) end)
    geLayout:checkbox(nil, "Only Castable by Me", "Synchronize Only Castable by Me setting.",
        function() return getSyncToggle("gameplay", "gameplayEnhancements", "spellDiminishPVPOnlyTriggerableByMe", true) end,
        function(v) setSyncToggle("gameplay", "gameplayEnhancements", "spellDiminishPVPOnlyTriggerableByMe", v) end)
    geLayout:endColumn()
    geLayout:columnsFinalize(gameplayEnhancementsContainer, 20)

    local gameplayEnhancementsContentHeight = math.abs(geLayout.y) + 10
    gameplayEnhancementsContainer:SetHeight(gameplayEnhancementsContentHeight)

    -- Restore layoutModel.checkbox for other tabs
    if origCheckbox then
        context.layoutModel.checkbox = origCheckbox
    end

    -- -----------------------------------------------------------------------
    -- COLLAPSIBLE CONTROLLER & UPDATE LAYOUT
    -- -----------------------------------------------------------------------
    local controlsHeaderBtn
    local interfaceHeaderBtn
    local actionBarsHeaderBtn
    local combatHeaderBtn
    local socialHeaderBtn
    local pingSystemHeaderBtn
    local gameplayEnhancementsHeaderBtn

    local function UpdateLayout()
        local y = startY

        -- Controls header
        controlsHeaderBtn:ClearAllPoints()
        controlsHeaderBtn:SetPoint("TOPLEFT", panel.content, "TOPLEFT", 16, y)
        y = y - 32
        if sectionStates.controls then
            controlsContainer:Show()
            controlsContainer:ClearAllPoints()
            controlsContainer:SetPoint("TOPLEFT", panel.content, "TOPLEFT", 16, y)
            y = y - controlsContentHeight - 16
        else
            controlsContainer:Hide()
            y = y - 6
        end

        -- Interface header
        interfaceHeaderBtn:ClearAllPoints()
        interfaceHeaderBtn:SetPoint("TOPLEFT", panel.content, "TOPLEFT", 16, y)
        y = y - 32
        if sectionStates.interface then
            interfaceContainer:Show()
            interfaceContainer:ClearAllPoints()
            interfaceContainer:SetPoint("TOPLEFT", panel.content, "TOPLEFT", 16, y)
            y = y - interfaceContentHeight - 16
        else
            interfaceContainer:Hide()
            y = y - 6
        end

        -- Action Bars header
        actionBarsHeaderBtn:ClearAllPoints()
        actionBarsHeaderBtn:SetPoint("TOPLEFT", panel.content, "TOPLEFT", 16, y)
        y = y - 32
        if sectionStates.actionBars then
            actionBarsContainer:Show()
            actionBarsContainer:ClearAllPoints()
            actionBarsContainer:SetPoint("TOPLEFT", panel.content, "TOPLEFT", 16, y)
            y = y - actionBarsContentHeight - 16
        else
            actionBarsContainer:Hide()
            y = y - 6
        end

        -- Combat header
        combatHeaderBtn:ClearAllPoints()
        combatHeaderBtn:SetPoint("TOPLEFT", panel.content, "TOPLEFT", 16, y)
        y = y - 32
        if sectionStates.combat then
            combatContainer:Show()
            combatContainer:ClearAllPoints()
            combatContainer:SetPoint("TOPLEFT", panel.content, "TOPLEFT", 16, y)
            y = y - combatContentHeight - 16
        else
            combatContainer:Hide()
            y = y - 6
        end

        -- Social header
        socialHeaderBtn:ClearAllPoints()
        socialHeaderBtn:SetPoint("TOPLEFT", panel.content, "TOPLEFT", 16, y)
        y = y - 32
        if sectionStates.social then
            socialContainer:Show()
            socialContainer:ClearAllPoints()
            socialContainer:SetPoint("TOPLEFT", panel.content, "TOPLEFT", 16, y)
            y = y - socialContentHeight - 16
        else
            socialContainer:Hide()
            y = y - 6
        end

        -- Ping System header
        pingSystemHeaderBtn:ClearAllPoints()
        pingSystemHeaderBtn:SetPoint("TOPLEFT", panel.content, "TOPLEFT", 16, y)
        y = y - 32
        if sectionStates.pingSystem then
            pingSystemContainer:Show()
            pingSystemContainer:ClearAllPoints()
            pingSystemContainer:SetPoint("TOPLEFT", panel.content, "TOPLEFT", 16, y)
            y = y - pingSystemContentHeight - 16
        else
            pingSystemContainer:Hide()
            y = y - 6
        end

        -- Gameplay Enhancements header
        gameplayEnhancementsHeaderBtn:ClearAllPoints()
        gameplayEnhancementsHeaderBtn:SetPoint("TOPLEFT", panel.content, "TOPLEFT", 16, y)
        y = y - 32
        if sectionStates.gameplayEnhancements then
            gameplayEnhancementsContainer:Show()
            gameplayEnhancementsContainer:ClearAllPoints()
            gameplayEnhancementsContainer:SetPoint("TOPLEFT", panel.content, "TOPLEFT", 16, y)
            y = y - gameplayEnhancementsContentHeight - 16
        else
            gameplayEnhancementsContainer:Hide()
            y = y - 6
        end

        panel.content:SetHeight(math.abs(y) + 40)
    end

    controlsHeaderBtn = CreateCollapsibleHeader(panel.content, "Controls", sectionStates.controls, function(isExp)
        sectionStates.controls = isExp
        UpdateLayout()
    end)

    interfaceHeaderBtn = CreateCollapsibleHeader(panel.content, "Interface", sectionStates.interface, function(isExp)
        sectionStates.interface = isExp
        UpdateLayout()
    end)

    actionBarsHeaderBtn = CreateCollapsibleHeader(panel.content, "Action Bars", sectionStates.actionBars, function(isExp)
        sectionStates.actionBars = isExp
        UpdateLayout()
    end)

    combatHeaderBtn = CreateCollapsibleHeader(panel.content, "Combat", sectionStates.combat, function(isExp)
        sectionStates.combat = isExp
        UpdateLayout()
    end)

    socialHeaderBtn = CreateCollapsibleHeader(panel.content, "Social", sectionStates.social, function(isExp)
        sectionStates.social = isExp
        UpdateLayout()
    end)

    pingSystemHeaderBtn = CreateCollapsibleHeader(panel.content, "Ping System", sectionStates.pingSystem, function(isExp)
        sectionStates.pingSystem = isExp
        UpdateLayout()
    end)

    gameplayEnhancementsHeaderBtn = CreateCollapsibleHeader(panel.content, "Gameplay Enhancements", sectionStates.gameplayEnhancements, function(isExp)
        sectionStates.gameplayEnhancements = isExp
        UpdateLayout()
    end)

    UpdateLayout()
end

-------------------------------------------------------------------------------
-- TAB 2: ACCESSIBILITY
-------------------------------------------------------------------------------
function ConfigUI:BuildAccessibilityTab(panel, context)
    local layout = context.layoutModel:reset(panel.content, -15)

    layout:header(nil, "Accessibility Options")
    layout:label(nil, "Synchronize accessibility, audio assistance, and visual filters:")

    local colWidth = 265
    local col1X = 16
    local col2X = col1X + colWidth + 24

    -- Column 1
    layout:beginColumn(col1X, colWidth)

    layout:header(nil, "Interface")
    layout:checkbox(nil, "UI Scale & Minimum Size", "Overall interface scaling and minimum text size settings.",
        function() return getSyncToggle("accessibility", "interfaceScale", true) end,
        function(v) setSyncToggle("accessibility", "interfaceScale", v) end)

    layout:header(nil, "Audio Assist")
    layout:checkbox(nil, "Audio Description & Alerts", "Audio narration, sound cues for events, and transcriptor features.",
        function() return getSyncToggle("accessibility", "audioAssist", true) end,
        function(v) setSyncToggle("accessibility", "audioAssist", v) end)

    layout:header(nil, "Subtitles")
    layout:checkbox(nil, "Cinematic & NPC Subtitles", "Subtitles for cinematics, cutscenes, and NPC world dialogues.",
        function() return getSyncToggle("accessibility", "subtitles", true) end,
        function(v) setSyncToggle("accessibility", "subtitles", v) end)

    layout:endColumn()

    -- Column 2
    layout:beginColumn(col2X, colWidth)

    layout:header(nil, "General")
    layout:checkbox(nil, "Motion Sickness & Camera Shake", "Motion sickness reduction, camera head bobbing, and screen shake.",
        function() return getSyncToggle("accessibility", "generalMotion", true) end,
        function(v) setSyncToggle("accessibility", "generalMotion", v) end)

    layout:header(nil, "Colors")
    layout:checkbox(nil, "Colorblind Filters", "Colorblind accessibility filters (Protanopia, Deuteranopia, Tritanopia).",
        function() return getSyncToggle("accessibility", "colorsFilters", true) end,
        function(v) setSyncToggle("accessibility", "colorsFilters", v) end)

    layout:header(nil, "Mounts")
    layout:checkbox(nil, "Dragonriding & Mount VFX", "Visual assistance, speed lines, and dynamic flight camera adjustments.",
        function() return getSyncToggle("accessibility", "mountsAssist", true) end,
        function(v) setSyncToggle("accessibility", "mountsAssist", v) end)

    layout:endColumn()

    layout:columnsFinalize(panel.content, 40)
end

-------------------------------------------------------------------------------
-- TAB 3: SYSTEM
-------------------------------------------------------------------------------
function ConfigUI:BuildSystemTab(panel, context)
    local layout = context.layoutModel:reset(panel.content, -15)

    layout:header(nil, "System Options")
    layout:label(nil, "Synchronize performance, sound volumes, network, and peripheral settings:")

    local colWidth = 265
    local col1X = 16
    local col2X = col1X + colWidth + 24

    -- Column 1
    layout:beginColumn(col1X, colWidth)

    layout:header(nil, "Graphics")
    layout:checkbox(nil, "Graphics & Display Modes", "FPS limits, render scale preferences, and vertical sync options.",
        function() return getSyncToggle("system", "graphics", false) end,
        function(v) setSyncToggle("system", "graphics", v) end)

    layout:header(nil, "Audio")
    layout:checkbox(nil, "Sound Volumes & Channels", "Master volume, music, sound effects, ambience, and sound in background.",
        function() return getSyncToggle("system", "audio", true) end,
        function(v) setSyncToggle("system", "audio", v) end)

    layout:header(nil, "Languages")
    layout:checkbox(nil, "Text & Audio Locale", "Text language, audio dubbing, and client font localization.",
        function() return getSyncToggle("system", "languages", false) end,
        function(v) setSyncToggle("system", "languages", v) end)

    layout:endColumn()

    -- Column 2
    layout:beginColumn(col2X, colWidth)

    layout:header(nil, "Network")
    layout:checkbox(nil, "Network & Latency Optimization", "Optimize network speed, IPv6 support, and advanced connection settings.",
        function() return getSyncToggle("system", "network", true) end,
        function(v) setSyncToggle("system", "network", v) end)

    layout:header(nil, "Keyboard Options")
    layout:checkbox(nil, "Key Repeat & Modifier Keys", "Modifier keys (Self Cast, Focus Cast) and key repeat rate options.",
        function() return getSyncToggle("system", "keyboard", true) end,
        function(v) setSyncToggle("system", "keyboard", v) end)

    layout:endColumn()

    layout:columnsFinalize(panel.content, 40)
end

-------------------------------------------------------------------------------
-- TAB 4: PROFILES
-------------------------------------------------------------------------------
function ConfigUI:BuildProfilesTab(panel, context)
    local layout = context.layoutModel:reset(panel.content, -15)

    layout:header(nil, "Account Profile Management")

    local currentProfile = AAS.db:GetCurrentProfile()
    local charKey = AAS:GetCharacterKey()

    layout:label(nil, "Active Profile: |cffEDBA1F" .. currentProfile .. "|r")
    layout:label(nil, "Current Character: |cffFFFFFF" .. charKey .. "|r")
    layout:label(nil, "Choose whether this character shares settings account-wide or stays independent:")

    local contentParent = panel.content

    -- Row 1: Profile switches
    local yPos1 = layout.y - 12
    context:createButton({
        parent = contentParent,
        text = "Link to Account Profile (Default)",
        width = 250,
        height = 30,
        xOffset = 16,
        yOffset = yPos1,
        tooltip = "Connect this character to the shared global account profile.",
        onClick = function()
            AAS.SyncEngine:SetProfileForCharacter("Default")
            AAS.SyncEngine:ApplyCurrentProfile(true)
            AAS.ShowToast("Linked to Account Profile.")
            if panel.updateLayout then panel.updateLayout(panel) end
        end
    })

    context:createButton({
        parent = contentParent,
        text = "Create/Use Character Profile",
        width = 250,
        height = 30,
        xOffset = 280,
        yOffset = yPos1,
        tooltip = "Create an independent profile exclusive to this character without affecting your account.",
        onClick = function()
            local charKey = AAS:GetCharacterKey()
            AAS.SyncEngine:SetProfileForCharacter(charKey)
            AAS.ShowToast("Using independent profile: " .. charKey)
            if panel.updateLayout then panel.updateLayout(panel) end
        end
    })

    layout.y = yPos1 - 45

    layout:header(nil, "Manual Synchronization Actions")

    local yPos2 = layout.y - 12
    context:createButton({
        parent = contentParent,
        text = "Save Options to Account",
        width = 250,
        height = 30,
        xOffset = 16,
        yOffset = yPos2,
        tooltip = "Save the current settings of this character to the active account profile.",
        onClick = function()
            AAS.SyncEngine:SaveCurrentProfile(true)
        end
    })

    context:createButton({
        parent = contentParent,
        text = "Apply Options from Account",
        width = 250,
        height = 30,
        xOffset = 280,
        yOffset = yPos2,
        tooltip = "Download and apply active profile settings onto this character.",
        onClick = function()
            AAS.SyncEngine:ApplyCurrentProfile(true)
        end
    })

    layout.y = yPos2 - 45

    layout:header(nil, "First Login Experience")
    layout:label(nil, "If you want to view the initial onboarding modal again for this character:")

    context:createButton({
        parent = contentParent,
        text = "Show Welcome Prompt Again",
        width = 230,
        height = 28,
        xOffset = 16,
        yOffset = layout.y - 10,
        tooltip = "Re-open the profile choice dialog for this character.",
        onClick = function()
            AAS.FirstLoginDialog:ShowPrompt()
        end
    })

    panel.content:SetHeight(math.abs(layout.y) + 100)
end
