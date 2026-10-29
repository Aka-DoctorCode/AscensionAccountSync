-------------------------------------------------------------------------------
-- Project: AscensionAccountSync
-- Author: Aka-DoctorCode
-- File: Toast.lua
-------------------------------------------------------------------------------
---@diagnostic disable: undefined-global, undefined-field, inject-field

local addonName, AAS = ...

local UIFactory = LibStub("AscensionSuit-UI", true)

AAS.Toast = {}
local Toast = AAS.Toast

local toastFrame = nil
local hideTimer = nil

local function getToastFrame()
    if toastFrame then return toastFrame end

    local f = CreateFrame("Frame", "AscensionAccountSyncToast", UIParent, "BackdropTemplate")
    f:SetSize(320, 52)
    f:SetPoint("TOP", UIParent, "TOP", 0, -60)
    f:SetFrameStrata("TOOLTIP")
    f:SetClampedToScreen(true)
    f:Hide()

    -- Aesthetic styling matching AscensionSuit dark purple/slate palette
    f:SetBackdrop({
        bgFile = "Interface\\ChatFrame\\ChatFrameBackground",
        edgeFile = "Interface\\Buttons\\WHITE8X8",
        edgeSize = 1,
        insets = { left = 2, right = 2, top = 2, bottom = 2 }
    })
    f:SetBackdropColor(0.06, 0.06, 0.08, 0.95)
    f:SetBackdropBorderColor(0.40, 0.08, 0.93, 0.90) -- Purple accent

    -- Icon
    local icon = f:CreateTexture(nil, "ARTWORK")
    icon:SetSize(28, 28)
    icon:SetPoint("LEFT", f, "LEFT", 12, 0)
    icon:SetTexture("Interface\\AddOns\\AscensionAccountSync\\Media\\AkaDoctorCode.png")
    f.icon = icon

    -- Title
    local title = f:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    title:SetPoint("TOPLEFT", icon, "TOPRIGHT", 10, 0)
    title:SetTextColor(0.80, 0.55, 1.00, 1.0) -- Soft purple title
    title:SetText("Ascension Account Sync")
    f.title = title

    -- Message
    local msg = f:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    msg:SetPoint("BOTTOMLEFT", icon, "BOTTOMRIGHT", 10, 0)
    msg:SetWidth(250)
    msg:SetJustifyH("LEFT")
    msg:SetWordWrap(false)
    f.msg = msg

    toastFrame = f
    return f
end

--- Shows a non-intrusive notification toast
--- @param message string Text message to display
--- @param duration number|nil Optional duration in seconds (default 3.5s)
function Toast:Show(message, duration)
    if not message or message == "" then return end

    if UIFactory and UIFactory.ShowToast then
        UIFactory:ShowToast("AscensionAccountSync", {
            message = message,
            duration = duration or 3.5,
            type = "info"
        })
        return
    end

    local f = getToastFrame()

    if hideTimer then
        hideTimer:Cancel()
        hideTimer = nil
    end

    f.msg:SetText(message)
    f:SetAlpha(1)
    f:Show()

    local staySec = duration or 3.5
    hideTimer = C_Timer.NewTimer(staySec, function()
        UIFrameFadeOut(f, 0.5, 1, 0)
        C_Timer.After(0.55, function()
            if f:GetAlpha() <= 0.05 then
                f:Hide()
            end
        end)
    end)
end

AAS.ShowToast = function(msg, dur)
    Toast:Show(msg, dur)
end
