-------------------------------------------------------------------------------
-- Project: AscensionAccountSync
-- Author: Aka-DoctorCode
-- File: Modules/Gameplay/Controls.lua
-------------------------------------------------------------------------------
---@diagnostic disable: undefined-global, undefined-field, inject-field

local addonName, AAS = ...

AAS.Modules = AAS.Modules or {}
AAS.Modules.Controls = {}
local Controls = AAS.Modules.Controls

Controls.Name = "Controls"
Controls.Title = "Controls & Camera"

-- Definition of all CVars managed under Gameplay -> Controls, Mouse, Camera, Auto Loot
Controls.Definitions = {
    -- CONTROLS
    stickyTargeting = {
        title = "Sticky Targeting",
        type = "cvar",
        cvar = "deselectOnClick",
        -- Note: Sticky Targeting in WoW UI is inverted: deselectOnClick="0" means sticky is ON
        isInverted = true,
    },
    autoDismountInFlight = {
        title = "Auto Dismount in Flight",
        type = "cvar",
        cvar = "autoDismountFlying",
    },
    autoCancelAwayMode = {
        title = "Auto Cancel Away Mode",
        type = "cvar",
        cvar = "autoClearAFK",
    },
    interactOnLeftClick = {
        title = "Interact On Left Click",
        type = "cvar",
        cvar = "interactOnLeftClick",
    },
    openLootWindowAtMouse = {
        title = "Open Loot Window at Mouse",
        type = "cvar",
        cvar = "lootUnderMouse",
    },
    autoLoot = {
        title = "Auto Loot",
        type = "cvar",
        cvar = "autoLootDefault",
    },
    combineBags = {
        title = "Combine Bags",
        type = "cvar",
        cvar = "combinedBags",
    },
    enableInteractKey = {
        title = "Enable Interact Key",
        type = "cvar",
        cvar = "SoftTargetInteract",
        -- 3 = Enabled for KBM, 0 = Disabled
        isSpecialInteract = true,
    },
    interactKeySoundCue = {
        title = "Interact Key Sound Cue",
        type = "cvar",
        cvar = "softTargettingIntecactKeySound",
    },

    -- MOUSE
    lockCursorToWindow = {
        title = "Lock Cursor to Window",
        type = "cvar",
        cvar = "ClipCursor",
    },
    invertMouse = {
        title = "Invert Mouse",
        type = "cvar",
        cvar = "mouseInvertPitch",
    },
    mouseLookSpeed = {
        title = "Mouse Look Speed",
        type = "cvar",
        cvar = "cameraYawMoveSpeed",
    },
    enableMouseSensitivity = {
        title = "Enable Mouse Sensitivity",
        type = "cvar",
        cvar = "mouseSpeed",
    },
    clickToMove = {
        title = "Click-to-Move",
        type = "cvar",
        cvar = "autointeract",
    },
    clickToMoveCameraStyle = {
        title = "Click-to-Move Camera Style",
        type = "cvar",
        cvar = "cameraSmoothTrackingStyle",
    },

    -- CAMERA
    waterCollision = {
        title = "Water Collision",
        type = "cvar",
        cvar = "cameraWaterCollision",
    },
    autoFollowSpeed = {
        title = "Auto Follow Speed",
        type = "cvar",
        cvar = "cameraSmoothSpeed",
    },
    cameraFollowingStyle = {
        title = "Camera Following Style",
        type = "cvar",
        cvar = "cameraSmoothStyle",
    },
}

-- Fast lookup map: uppercase CVar -> key
local cvarToKey = {}
for key, def in pairs(Controls.Definitions) do
    if def.cvar then
        cvarToKey[string.upper(def.cvar)] = key
    end
end

local isApplying = false

--- Reads a setting's current in-game value
function Controls:GetInGameValue(key)
    local def = self.Definitions[key]
    if not def then return nil end

    if def.type == "cvar" then
        return GetCVar(def.cvar)
    elseif def.type == "modifiedClick" then
        return GetModifiedClick(def.action)
    end
    return nil
end

--- Sets an in-game value
function Controls:SetInGameValue(key, value)
    local def = self.Definitions[key]
    if not def or value == nil then return false end

    if def.type == "cvar" then
        local current = GetCVar(def.cvar)
        if current ~= tostring(value) then
            SetCVar(def.cvar, tostring(value))
            return true
        end
    elseif def.type == "modifiedClick" then
        local current = GetModifiedClick(def.action)
        if current ~= value then
            SetModifiedClick(def.action, value)
            return true
        end
    end
    return false
end

--- Helper to get active profile storage for controls
local function GetStorage()
    if not AAS.db or not AAS.db.profile then return nil end
    AAS.db.profile.gameplay = AAS.db.profile.gameplay or {}
    AAS.db.profile.gameplay.controls = AAS.db.profile.gameplay.controls or AAS.db.profile.controls or {}
    return AAS.db.profile.gameplay.controls
end

--- Applies all enabled Controls settings to the character
function Controls:ApplySettings(savedData, notify)
    savedData = savedData or GetStorage()
    if not savedData then return false end
    isApplying = true

    local changedCount = 0
    local lastChangedTitle = nil

    for key, def in pairs(self.Definitions) do
        if AAS.SyncEngine:IsModuleSyncEnabled(key, "gameplay", "controls") then
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
            AAS.ShowToast("Controls: " .. changedCount .. " settings synchronized.")
        end
    end

    return changedCount > 0
end

--- Saves current in-game settings into the active profile
function Controls:SaveSettings(notify, specificKey)
    if isApplying then return end
    local storage = GetStorage()
    if not storage then return end

    local charKey = AAS:GetCharacterKey()

    if specificKey then
        local def = self.Definitions[specificKey]
        if def and AAS.SyncEngine:IsModuleSyncEnabled(specificKey, "gameplay", "controls") then
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
            if AAS.SyncEngine:IsModuleSyncEnabled(key, "gameplay", "controls") then
                storage[key] = self:GetInGameValue(key)
                count = count + 1
            end
        end
        storage.lastUpdatedBy = charKey
        storage.lastUpdatedAt = GetServerTime()

        if notify and count > 0 then
            AAS.ShowToast("Controls saved to account.")
        end
    end
end

--- Hooked into CVAR_UPDATE
function Controls:OnCVarUpdate(cvarName)
    if isApplying then return end
    if not cvarName then return end

    local key = cvarToKey[string.upper(cvarName)]
    if key and AAS.SyncEngine:IsModuleSyncEnabled(key, "gameplay", "controls") then
        self:SaveSettings(true, key)
    end
end
