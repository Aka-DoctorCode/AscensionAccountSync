-------------------------------------------------------------------------------
-- Project: AscensionAccountSync
-- Author: Aka-DoctorCode
-- File: FirstLoginDialog.lua
-------------------------------------------------------------------------------
---@diagnostic disable: undefined-global, undefined-field, inject-field

local addonName, AAS = ...

AAS.FirstLoginDialog = {}
local Dialog = AAS.FirstLoginDialog

local dialogFrame = nil

local function createDialog()
    if dialogFrame then return dialogFrame end

    local lib = LibStub("AscensionSuit-UI", true)
    local context = lib and lib.Context

    local f = CreateFrame("Frame", "AscensionAccountSyncFirstLoginDialog", UIParent, "BackdropTemplate")
    f:SetSize(430, 240)
    f:SetPoint("CENTER", UIParent, "CENTER", 0, 80)
    f:SetFrameStrata("DIALOG")
    f:SetClampedToScreen(true)
    f:EnableMouse(true)
    f:Hide()

    local bgFile = "Interface\\ChatFrame\\ChatFrameBackground"
    local edgeFile = "Interface\\Buttons\\WHITE8X8"
    if context and context.styles and context.styles.files then
        bgFile = context.styles.files.bgFile or bgFile
        edgeFile = context.styles.files.edgeFile or edgeFile
    end

    f:SetBackdrop({
        bgFile = bgFile,
        edgeFile = edgeFile,
        edgeSize = 2,
        insets = { left = 2, right = 2, top = 2, bottom = 2 }
    })
    f:SetBackdropColor(0.05, 0.05, 0.07, 0.98)
    f:SetBackdropBorderColor(0.40, 0.08, 0.93, 0.95)

    -- Header Icon
    local icon = f:CreateTexture(nil, "ARTWORK")
    icon:SetSize(32, 32)
    icon:SetPoint("TOPLEFT", f, "TOPLEFT", 18, -16)
    icon:SetTexture("Interface\\AddOns\\AscensionAccountSync\\Media\\AkaDoctorCode.png")

    -- Title
    local title = f:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    title:SetPoint("LEFT", icon, "RIGHT", 10, 0)
    title:SetTextColor(0.93, 0.73, 0.12, 1.0)
    title:SetText("Ascension Account Sync")

    -- SubTitle
    local subTitle = f:CreateFontString(nil, "OVERLAY", "GameFontHighlightMedium")
    subTitle:SetPoint("TOPLEFT", icon, "BOTTOMLEFT", 0, -14)
    subTitle:SetTextColor(1, 1, 1, 1)
    subTitle:SetText("Welcome to Ascension Account Sync!")

    -- Description Body
    local desc = f:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    desc:SetPoint("TOPLEFT", subTitle, "BOTTOMLEFT", 0, -8)
    desc:SetWidth(390)
    desc:SetJustifyH("LEFT")
    desc:SetTextColor(0.85, 0.85, 0.85, 1.0)
    desc:SetText("How would you like to configure this character?\n\nYou can link it to your shared Account Profile to synchronize your options across characters, or keep an independent profile for this character.")

    -- Buttons Area
    -- Option 1: Use Account Profile (Default)
    local btnAccount = CreateFrame("Button", nil, f, "BackdropTemplate")
    btnAccount:SetSize(185, 36)
    btnAccount:SetPoint("BOTTOMLEFT", f, "BOTTOMLEFT", 20, 20)
    btnAccount:SetBackdrop({
        bgFile = bgFile,
        edgeFile = edgeFile,
        edgeSize = 1,
    })
    btnAccount:SetBackdropColor(0.20, 0.00, 0.50, 1.0)
    btnAccount:SetBackdropBorderColor(0.40, 0.08, 0.93, 0.90)

    local txtAccount = btnAccount:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    txtAccount:SetPoint("CENTER")
    txtAccount:SetText("Use Account Profile")
    btnAccount.text = txtAccount

    btnAccount:SetScript("OnEnter", function(self)
        self:SetBackdropColor(0.35, 0.05, 0.70, 1.0)
    end)
    btnAccount:SetScript("OnLeave", function(self)
        self:SetBackdropColor(0.20, 0.00, 0.50, 1.0)
    end)
    btnAccount:SetScript("OnClick", function()
        f:Hide()
        AAS.SyncEngine:SetProfileForCharacter("Default")
        AAS.SyncEngine:ApplyCurrentProfile(true)
        AAS.ShowToast("Linked to Account Profile.")
    end)

    -- Option 2: Independent Profile
    local btnNew = CreateFrame("Button", nil, f, "BackdropTemplate")
    btnNew:SetSize(185, 36)
    btnNew:SetPoint("BOTTOMRIGHT", f, "BOTTOMRIGHT", -20, 20)
    btnNew:SetBackdrop({
        bgFile = bgFile,
        edgeFile = edgeFile,
        edgeSize = 1,
    })
    btnNew:SetBackdropColor(0.15, 0.15, 0.18, 1.0)
    btnNew:SetBackdropBorderColor(0.30, 0.30, 0.35, 1.0)

    local txtNew = btnNew:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    txtNew:SetPoint("CENTER")
    txtNew:SetText("Independent Profile")
    btnNew.text = txtNew

    btnNew:SetScript("OnEnter", function(self)
        self:SetBackdropColor(0.25, 0.25, 0.30, 1.0)
    end)
    btnNew:SetScript("OnLeave", function(self)
        self:SetBackdropColor(0.15, 0.15, 0.18, 1.0)
    end)
    btnNew:SetScript("OnClick", function()
        f:Hide()
        local charKey = AAS:GetCharacterKey()
        AAS.SyncEngine:SetProfileForCharacter(charKey)
        AAS.ShowToast("Independent profile created for this character.")
    end)

    dialogFrame = f
    return f
end

function Dialog:ShowPrompt()
    local f = createDialog()
    f:Show()
end
