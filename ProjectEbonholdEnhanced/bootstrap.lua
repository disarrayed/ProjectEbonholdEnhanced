local addonName = ... or "ProjectEbonholdEnhanced"

ProjectEbonholdEnhanced = ProjectEbonholdEnhanced or {}

local overlay = ProjectEbonholdEnhanced
overlay.name = addonName
overlay.version = "0.1.61"
overlay.enabled = false
overlay.isPTR = false

local PANEL_WIDTH = 360
local PANEL_HEIGHT = 188
local PANEL_EDGE_SIZE = 4
local PANEL_INSET = 14
local STATUS_PANEL_AUTO_HIDE_DELAY = 3
local STATUS_PANEL_FADE_DURATION = 0.35
local MAGE_BLUE = {0.247, 0.78, 0.922}
local HOVER_BLUE = {0.16, 0.88, 1.0}
local CREAM = {1, 0.92, 0.82}
local MUTED = {0.72, 0.72, 0.72}
local WHITE = {1, 1, 1}
local SOFT_WHITE = {0.9, 0.9, 0.9}
local GREEN = {0.38, 0.9, 0.48}
local DARK = {0.039, 0.039, 0.039}
local BLACK = {0, 0, 0}
local HOVER_BLUE_BACKDROP = {0.02, 0.22, 0.36}
local SELECT_BACKDROP = {0.08, 0.28, 0.1}
local FREEZE_BACKDROP = {0.06, 0.12, 0.28}
local BANISH_BACKDROP = {0.32, 0.1, 0.1}
local REROLL_BACKDROP = {0.22, 0.06, 0.06}
local SELECT_HOVER_BACKDROP = {0.18, 0.42, 0.2}
local SELECT_HOVER_BORDER = {0.24, 0.72, 0.3}
local FREEZE_HOVER_BACKDROP = {0.14, 0.28, 0.5}
local BANISH_HOVER_BACKDROP = {0.48, 0.16, 0.14}
local REROLL_HOVER_BACKDROP = {0.5, 0.12, 0.12}
local REROLL_HOVER_BORDER = {0.9, 0.2, 0.2}
local CHOOSE_HOVER_BORDER = {0.4, 0.7, 1.0}
overlay.buttonBorders = {
    select = {0.18, 0.55, 0.22},
    freeze = {0.2, 0.5, 1.0},
    banish = {0.82, 0.22, 0.2},
    reroll = {0.82, 0.22, 0.2},
    freezeHover = {0.28, 0.58, 1.0},
    banishHover = {1.0, 0.28, 0.24}
}
overlay.perkButtonLayoutVersion = 4
overlay.hardcoreTierText = {
    [1] = "I",
    [2] = "II",
    [3] = "III",
    [4] = "IV",
    [5] = "V"
}
overlay.hardcoreTierByText = {
    I = 1,
    II = 2,
    III = 3,
    IV = 4,
    V = 5
}

local DEFAULT_SETTINGS = {
    transparentDesign = true,
    fontScale = 1.0,
    backdropOpacity = 0.8,
    disablePerkFadeAnimations = true,
    removeRerollConfirm = true,
    autoShowEchoChoices = false,
    keepEchoesVisibleOnLevelUp = true,
    perkUIScale = 1.0
}

local function IsPTRRealm()
    if not GetRealmName then
        return false
    end

    local realmName = GetRealmName()
    return realmName and realmName:find("PTR", 1, true) ~= nil
end

local function PrintMessage(message)
    if DEFAULT_CHAT_FRAME and DEFAULT_CHAT_FRAME.AddMessage then
        DEFAULT_CHAT_FRAME:AddMessage("|cff3FC7EB[PEE]|r " .. message)
    end
end

overlay.PrintMessage = PrintMessage

local function EnsureSavedVariables()
    ProjectEbonholdEnhancedDB = ProjectEbonholdEnhancedDB or {}
    ProjectEbonholdEnhancedCharDB = ProjectEbonholdEnhancedCharDB or {}

    overlay.db = ProjectEbonholdEnhancedDB
    overlay.charDB = ProjectEbonholdEnhancedCharDB

    if type(overlay.db.statusPanel) ~= "table" then
        overlay.db.statusPanel = {}
    end

    if type(overlay.db.playerRunCompact) ~= "table" then
        overlay.db.playerRunCompact = {}
    end

    if type(overlay.charDB.hardmode) ~= "table" then
        overlay.charDB.hardmode = {}
    end

    if type(overlay.db.skillTreeFrame) ~= "table" then
        overlay.db.skillTreeFrame = {}
    end

    if type(overlay.db.perkButtons) ~= "table" then
        overlay.db.perkButtons = {}
    end

    if type(overlay.db.settings) ~= "table" then
        overlay.db.settings = {}
    end

    for key, value in pairs(DEFAULT_SETTINGS) do
        if overlay.db.settings[key] == nil then
            overlay.db.settings[key] = value
        end
    end
end

local function ClampNumber(value, minimum, maximum, fallback)
    value = tonumber(value)
    if not value then
        return fallback
    end

    if value < minimum then
        return minimum
    end

    if value > maximum then
        return maximum
    end

    return value
end

local function GetSetting(key)
    EnsureSavedVariables()
    return overlay.db.settings[key]
end

local function SetSetting(key, value)
    EnsureSavedVariables()
    overlay.db.settings[key] = value
end

local function IsTransparentDesignEnabled()
    return GetSetting("transparentDesign") == true
end

local function ScaledFontSize(baseSize)
    local scale = GetSetting("fontScale") or DEFAULT_SETTINGS.fontScale
    return math.max(1, math.floor(baseSize * scale + 0.5))
end

local function GetBackdropOpacity()
    return GetSetting("backdropOpacity") or DEFAULT_SETTINGS.backdropOpacity
end

function overlay.IsPerkFadeAnimationDisabled()
    return GetSetting("disablePerkFadeAnimations") == true
end

function overlay.IsRerollConfirmationRemoved()
    return GetSetting("removeRerollConfirm") == true
end

function overlay.IsAutoShowEchoChoicesEnabled()
    return GetSetting("autoShowEchoChoices") == true
end

function overlay.IsKeepEchoesVisibleOnLevelUpEnabled()
    return GetSetting("keepEchoesVisibleOnLevelUp") == true
end

function overlay.GetPerkUIScale()
    return ClampNumber(GetSetting("perkUIScale"), 0.5, 3.0, DEFAULT_SETTINGS.perkUIScale)
end

local SERVER_OPTION_OVERRIDES = {
    noPerkFadeAnimations = function()
        return overlay.IsPerkFadeAnimationDisabled()
    end,
    noRerollConfirm = function()
        return overlay.IsRerollConfirmationRemoved()
    end,
    rerollAutoRepopulate = function()
        return true
    end,
    echoesVisibleOnLevelUp = function()
        return overlay.IsKeepEchoesVisibleOnLevelUpEnabled()
    end,
    autoShowEchoes = function()
        return overlay.IsAutoShowEchoChoicesEnabled()
    end,
    perkDirectBanish = function()
        return true
    end,
    perkShowSelectCount = function()
        return true
    end,
    perkUIScale = function()
        return overlay.GetPerkUIScale()
    end,
    transparentDesign = function()
        return overlay.IsTransparentDesignEnabled()
    end
}

local function GetServerOptionOverride(key)
    local provider = SERVER_OPTION_OVERRIDES[key]
    if not provider then
        return nil, false
    end

    return provider(), true
end

function overlay.InstallServerOptionReadOverrides()
    local service = _G and _G.ProjectEbonholdOptionsService
    if not service or type(service.GetSetting) ~= "function" or service._peeOptionReadOverridesInstalled then
        return
    end

    local originalGetSetting = service.GetSetting
    service._peeOriginalGetSetting = originalGetSetting
    service.GetSetting = function(selfOrKey, maybeKey, ...)
        local key = type(selfOrKey) == "string" and selfOrKey or maybeKey
        if overlay.enabled and not overlay.isPTR then
            local value, found = GetServerOptionOverride(key)
            if found then
                return value
            end
        end

        if type(selfOrKey) == "string" then
            return originalGetSetting(service, selfOrKey, maybeKey, ...)
        end

        return originalGetSetting(selfOrKey, maybeKey, ...)
    end
    service._peeOptionReadOverridesInstalled = true
end

local function FormatPercent(value)
    return math.floor((value or 0) * 100 + 0.5) .. "%"
end

local function GetThemeSummary()
    local transparentText = IsTransparentDesignEnabled() and "on" or "off"
    return "Theme: transparent " .. transparentText ..
        ", font " .. FormatPercent(GetSetting("fontScale")) ..
        ", opacity " .. FormatPercent(GetBackdropOpacity()) ..
        ", perk UI " .. FormatPercent(overlay.GetPerkUIScale())
end

local function SetFrameBackdrop(frame, edgeSize, inset)
    if not frame or not frame.SetBackdrop then
        return
    end

    local backdropKey = tostring(edgeSize) .. ":" .. tostring(inset)
    if frame._peeBackdropKey == backdropKey then
        return
    end

    frame:SetBackdrop({
        bgFile = "Interface\\Buttons\\WHITE8x8",
        edgeFile = "Interface\\Buttons\\WHITE8x8",
        tile = true,
        tileSize = 16,
        edgeSize = edgeSize,
        insets = { left = inset, right = inset, top = inset, bottom = inset }
    })
    frame._peeBackdropKey = backdropKey
end

local function SetFrameSize(frame, width, height)
    if frame.SetSize then
        frame:SetSize(width, height)
        return
    end

    if frame.SetWidth then
        frame:SetWidth(width)
    end

    if frame.SetHeight then
        frame:SetHeight(height)
    end
end

local function SetDarkBackdrop(frame, edgeSize, inset)
    if not frame then
        return
    end

    SetFrameBackdrop(frame, edgeSize, inset)

    if frame.SetBackdropColor then
        frame:SetBackdropColor(DARK[1], DARK[2], DARK[3], GetBackdropOpacity())
    end

    if frame.SetBackdropBorderColor then
        frame:SetBackdropBorderColor(0, 0, 0, 1)
    end
end

local function HideTextureRegion(frame, texturePath)
    if not frame or not frame.GetRegions then
        return
    end

    local regions = { frame:GetRegions() }
    for _, region in ipairs(regions) do
        if region and region.GetTexture and region.Hide and region:GetTexture() == texturePath then
            region:Hide()
        end
    end
end

overlay.GetSetting = GetSetting
overlay.SetSetting = SetSetting
overlay.IsTransparentDesignEnabled = IsTransparentDesignEnabled
overlay.ScaledFontSize = ScaledFontSize
overlay.GetBackdropOpacity = GetBackdropOpacity
overlay.GetThemeSummary = GetThemeSummary

local function SetTextColor(fontString, color)
    fontString:SetTextColor(color[1], color[2], color[3], 1)
end

local function ConfigureText(fontString, width)
    fontString:SetFont("Fonts\\FRIZQT__.TTF", ScaledFontSize(12), "OUTLINE")
    fontString:SetWidth(width)
    fontString:SetWordWrap(true)
    fontString:SetNonSpaceWrap(false)
    fontString:SetJustifyH("LEFT")
end

local function CreatePanelText(parent, anchor, yOffset)
    local fontString = parent:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    fontString:SetPoint("TOPLEFT", anchor, "BOTTOMLEFT", 0, yOffset)
    ConfigureText(fontString, PANEL_WIDTH - (PANEL_INSET * 2))
    return fontString
end

local function CreateFlatButton(parent, text, width, height)
    local button = CreateFrame("Button", nil, parent)
    button:SetWidth(width)
    button:SetHeight(height)
    button:SetBackdrop({
        bgFile = "Interface\\Buttons\\WHITE8x8",
        edgeFile = "Interface\\Buttons\\WHITE8x8",
        tile = false,
        edgeSize = 2,
        insets = { left = 1, right = 1, top = 1, bottom = 1 }
    })
    button:SetBackdropColor(0.03, 0.07, 0.09, GetBackdropOpacity())
    button:SetBackdropBorderColor(BLACK[1], BLACK[2], BLACK[3], 1)

    button.text = button:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    button.text:SetFont("Fonts\\FRIZQT__.TTF", ScaledFontSize(12), "OUTLINE")
    button.text:SetPoint("CENTER")
    button.text:SetText(text)
    SetTextColor(button.text, CREAM)

    button:SetScript("OnEnter", function(self)
        self:SetBackdropColor(
            HOVER_BLUE_BACKDROP[1],
            HOVER_BLUE_BACKDROP[2],
            HOVER_BLUE_BACKDROP[3],
            GetBackdropOpacity()
        )
        self:SetBackdropBorderColor(HOVER_BLUE[1], HOVER_BLUE[2], HOVER_BLUE[3], 1)
    end)
    button:SetScript("OnLeave", function(self)
        self:SetBackdropColor(0.03, 0.07, 0.09, GetBackdropOpacity())
        self:SetBackdropBorderColor(BLACK[1], BLACK[2], BLACK[3], 1)
    end)

    return button
end

function overlay.ForceTextureRegionHidden(texture)
    if not texture then
        return
    end

    local setAlpha = texture._peeRawSetAlpha or texture.SetAlpha
    if setAlpha then
        setAlpha(texture, 0)
    end

    local hide = texture._peeRawHide or texture.Hide
    if hide then
        hide(texture)
    end
end

function overlay.SuppressTextureRegion(texture)
    if not texture then
        return
    end
    if texture._peeAllowRuntimeVisual then
        return
    end

    if not texture._peeTextureSuppressionWrapped then
        if texture.SetTexture then
            texture._peeRawSetTexture = texture.SetTexture
            texture.SetTexture = function(self, ...)
                if self._peeSuppressVisual then
                    self._peeRawSetTexture(self, nil)
                    overlay.ForceTextureRegionHidden(self)
                    return
                end
                return self._peeRawSetTexture(self, ...)
            end
        end

        if texture.SetAlpha then
            texture._peeRawSetAlpha = texture.SetAlpha
            texture.SetAlpha = function(self, alpha)
                if self._peeSuppressVisual then
                    return self._peeRawSetAlpha(self, 0)
                end
                return self._peeRawSetAlpha(self, alpha)
            end
        end

        if texture.Show then
            texture._peeRawShow = texture.Show
            texture.Show = function(self, ...)
                if self._peeSuppressVisual then
                    overlay.ForceTextureRegionHidden(self)
                    return
                end
                return self._peeRawShow(self, ...)
            end
        end

        if texture.Hide then
            texture._peeRawHide = texture.Hide
        end

        texture._peeTextureSuppressionWrapped = true
    end

    texture._peeSuppressVisual = true
    if texture.SetTexture then
        texture:SetTexture(nil)
    end
    overlay.ForceTextureRegionHidden(texture)
end

local HideButtonTextures

function overlay.LockButtonTextureSetters(button)
    if not button or button._peeButtonTextureSettersLocked then
        return
    end

    local setterNames = {
        "SetNormalTexture",
        "SetPushedTexture",
        "SetHighlightTexture",
        "SetDisabledTexture"
    }

    for _, setterName in ipairs(setterNames) do
        local setter = button[setterName]
        if setter then
            local rawKey = "_peeRaw" .. setterName
            button[rawKey] = setter
            button[setterName] = function(self, ...)
                if self._peeButtonTextureSettersLocked and not self._peeApplyingButtonTexture then
                    overlay.HideButtonTextures(self, true)
                    return
                end
                return self[rawKey](self, ...)
            end
        end
    end

    button._peeButtonTextureSettersLocked = true
end

overlay.HideButtonTextures = function(button)
    local textureGetters = {
        "GetNormalTexture",
        "GetPushedTexture",
        "GetHighlightTexture",
        "GetDisabledTexture"
    }

    for _, getterName in ipairs(textureGetters) do
        local getter = button and button[getterName]
        if getter then
            local texture = getter(button)
            overlay.SuppressTextureRegion(texture)
        end
    end
end

HideButtonTextures = overlay.HideButtonTextures

local function SkinFlatButton(button)
    if not button then
        return
    end

    SetFrameBackdrop(button, 2, 1)

    if button.SetBackdropColor then
        button:SetBackdropColor(0.03, 0.07, 0.09, GetBackdropOpacity())
    end

    if button.SetBackdropBorderColor then
        button:SetBackdropBorderColor(BLACK[1], BLACK[2], BLACK[3], 1)
    end

    HideButtonTextures(button)

    local fontString = button.text
    if button.GetFontString then
        fontString = button:GetFontString() or fontString
    end

    if fontString then
        fontString:SetFont("Fonts\\FRIZQT__.TTF", ScaledFontSize(12), "OUTLINE")
        SetTextColor(fontString, CREAM)
    end

    if button.SetScript then
        button:SetScript("OnEnter", function(self)
            if self.SetBackdropColor then
                self:SetBackdropColor(
                    HOVER_BLUE_BACKDROP[1],
                    HOVER_BLUE_BACKDROP[2],
                    HOVER_BLUE_BACKDROP[3],
                    GetBackdropOpacity()
                )
            end
            if self.SetBackdropBorderColor then
                self:SetBackdropBorderColor(HOVER_BLUE[1], HOVER_BLUE[2], HOVER_BLUE[3], 1)
            end
        end)
        button:SetScript("OnLeave", function(self)
            if self.SetBackdropColor then
                self:SetBackdropColor(0.03, 0.07, 0.09, GetBackdropOpacity())
            end
            if self.SetBackdropBorderColor then
                self:SetBackdropBorderColor(BLACK[1], BLACK[2], BLACK[3], 1)
            end
        end)
    end
end

local function ButtonIsEnabled(button)
    if button and button.IsEnabled then
        return button:IsEnabled()
    end

    return true
end

local function SetButtonBackdrop(button, backdropColor, borderColor)
    if not button then
        return
    end

    button._peeApplyingBackdrop = true
    local setBackdropColor = button._peeRawSetBackdropColor or button.SetBackdropColor
    if setBackdropColor then
        setBackdropColor(button, backdropColor[1], backdropColor[2], backdropColor[3], GetBackdropOpacity())
    end

    local setBackdropBorderColor = button._peeRawSetBackdropBorderColor or button.SetBackdropBorderColor
    if setBackdropBorderColor then
        setBackdropBorderColor(button, borderColor[1], borderColor[2], borderColor[3], 1)
    end
    button._peeApplyingBackdrop = false
end

local function LockRuntimeButtonBackdrop(button)
    if not button or button._peeBackdropLocked then
        return
    end

    if button.SetBackdropColor then
        button._peeRawSetBackdropColor = button.SetBackdropColor
        button.SetBackdropColor = function(self, red, green, blue, alpha)
            if self._peeBackdropLocked and not self._peeApplyingBackdrop then
                return
            end
            return self._peeRawSetBackdropColor(self, red, green, blue, alpha)
        end
    end

    if button.SetBackdropBorderColor then
        button._peeRawSetBackdropBorderColor = button.SetBackdropBorderColor
        button.SetBackdropBorderColor = function(self, red, green, blue, alpha)
            if self._peeBackdropLocked and not self._peeApplyingBackdrop then
                return
            end
            return self._peeRawSetBackdropBorderColor(self, red, green, blue, alpha)
        end
    end

    button._peeBackdropLocked = true
end

function overlay.LockRuntimeButtonTextColor(fontString)
    if not fontString or fontString._peeTextColorLocked or not fontString.SetTextColor then
        return
    end

    fontString._peeRawSetTextColor = fontString.SetTextColor
    fontString.SetTextColor = function(self, red, green, blue, alpha)
        if self._peeTextColorLocked and not self._peeApplyingTextColor then
            return
        end
        return self._peeRawSetTextColor(self, red, green, blue, alpha)
    end
    fontString._peeTextColorLocked = true
end

function overlay.SetRuntimeButtonTextColor(fontString, color)
    if not fontString or not fontString.SetTextColor or not color then
        return
    end

    fontString._peeApplyingTextColor = true
    local setTextColor = fontString._peeRawSetTextColor or fontString.SetTextColor
    setTextColor(fontString, color[1], color[2], color[3], 1)
    fontString._peeApplyingTextColor = false
end

local function SuppressExistingButtonTextureRegions(button, flagName)
    if not button or button[flagName] or not button.GetRegions then
        return
    end

    local ok, regions = pcall(function()
        return { button:GetRegions() }
    end)
    if ok then
        for _, region in ipairs(regions) do
            if region and region.SetTexture then
                overlay.SuppressTextureRegion(region)
            end
        end
    end
    button[flagName] = true
end

local function SkinRuntimeButton(button, restingColor, textColor, restingBorder, hoverBackdrop, hoverBorder)
    if not button then
        return
    end

    if not button._peeRuntimeTexturesHidden then
        HideButtonTextures(button, true)
        overlay.LockButtonTextureSetters(button)
        button._peeRuntimeTexturesHidden = true
    end
    if not button._peeRuntimeBackdropReady then
        SetFrameBackdrop(button, 2, 1)
        button._peeRuntimeBackdropReady = true
    end
    if button.SetAlpha then
        button:SetAlpha(1)
    end

    LockRuntimeButtonBackdrop(button)

    button._peeRestingBackdrop = restingColor
    button._peeRestingBorder = restingBorder or BLACK
    button._peeHoverBackdrop = hoverBackdrop or HOVER_BLUE_BACKDROP
    button._peeHoverBorder = hoverBorder or HOVER_BLUE

    if button._peeHovering and ButtonIsEnabled(button) then
        SetButtonBackdrop(button, button._peeHoverBackdrop, button._peeHoverBorder)
    else
        SetButtonBackdrop(button, restingColor, button._peeRestingBorder)
    end

    local fontString = button.text
    if button.GetFontString then
        fontString = button:GetFontString() or fontString
    end

    if fontString and fontString.SetFont then
        fontString:SetFont("Fonts\\FRIZQT__.TTF", ScaledFontSize(12), "OUTLINE")
    end

    if fontString then
        overlay.LockRuntimeButtonTextColor(fontString)
        overlay.SetRuntimeButtonTextColor(fontString, textColor or CREAM)
    end

    if button._peeRuntimeButtonHooks then
        return
    end

    local function onEnter(self)
        if not ButtonIsEnabled(self) then
            return
        end

        self._peeHovering = true
        SetButtonBackdrop(self, self._peeHoverBackdrop or HOVER_BLUE_BACKDROP, self._peeHoverBorder or HOVER_BLUE)
    end

    local function onLeave(self)
        self._peeHovering = false
        SetButtonBackdrop(self, self._peeRestingBackdrop or DARK, self._peeRestingBorder or BLACK)
    end

    if button.HookScript then
        button:HookScript("OnEnter", onEnter)
        button:HookScript("OnLeave", onLeave)
        button._peeRuntimeButtonHooks = true
        return
    end

    if button.SetScript and not button.GetScript then
        button:SetScript("OnEnter", onEnter)
        button:SetScript("OnLeave", onLeave)
        button._peeRuntimeButtonHooks = true
        return
    end

    local hasEnterHandler = button.GetScript and button:GetScript("OnEnter")
    local hasLeaveHandler = button.GetScript and button:GetScript("OnLeave")
    if button.SetScript and button.GetScript and not hasEnterHandler and not hasLeaveHandler then
        button:SetScript("OnEnter", onEnter)
        button:SetScript("OnLeave", onLeave)
        button._peeRuntimeButtonHooks = true
    end
end

local function RestorePanelPosition(panel)
    local position = overlay.db and overlay.db.statusPanel

    panel:ClearAllPoints()
    if position and position.point then
        panel:SetPoint(
            position.point,
            UIParent,
            position.relativePoint or position.point,
            position.x or 0,
            position.y or 0
        )
    else
        panel:SetPoint("CENTER", UIParent, "CENTER", 0, 120)
    end
end

local function SavePanelPosition(panel)
    if not overlay.db or not overlay.db.statusPanel then
        return
    end

    local point, _, relativePoint, xOffset, yOffset = panel:GetPoint(1)
    overlay.db.statusPanel.point = point
    overlay.db.statusPanel.relativePoint = relativePoint
    overlay.db.statusPanel.x = xOffset
    overlay.db.statusPanel.y = yOffset
end

local function GetStatusSummary()
    local realmName = "Unknown"
    if GetRealmName then
        realmName = GetRealmName() or realmName
    end

    local realmType = overlay.isPTR and "PTR" or "Live"
    local state = overlay.enabled and "Active" or "Inactive"

    return state, realmType, realmName
end

overlay.GetStatusSummary = GetStatusSummary

local function UpdateStatusPanel()
    local panel = overlay.statusPanel
    if not panel then
        return
    end

    local state, realmType, realmName = GetStatusSummary()
    local stateColor = overlay.enabled and GREEN or MUTED

    panel.stateText:SetText("Overlay: " .. state)
    SetTextColor(panel.stateText, stateColor)
    panel.realmText:SetText("Realm: " .. realmName .. " (" .. realmType .. ")")
    panel.detailText:SetText(GetThemeSummary())
    panel.hintText:SetText("Drag to move. Use /pee to toggle.")

    panel:SetBackdropColor(0.039, 0.039, 0.039, GetBackdropOpacity())

end

local function ResetStatusPanelFade(panel)
    if not panel then
        return
    end

    panel._peeStatusFadeElapsed = 0
    panel._peeStatusDragging = false
    if panel.SetAlpha then
        panel:SetAlpha(1)
    end
end

local function UpdateStatusPanelFade(panel, elapsed)
    if not panel or panel._peeStatusDragging or not panel:IsShown() then
        return
    end

    panel._peeStatusFadeElapsed = (panel._peeStatusFadeElapsed or 0) + (elapsed or 0)
    if panel._peeStatusFadeElapsed <= STATUS_PANEL_AUTO_HIDE_DELAY then
        return
    end

    local fadeElapsed = panel._peeStatusFadeElapsed - STATUS_PANEL_AUTO_HIDE_DELAY
    local alpha = 1 - math.min(1, fadeElapsed / STATUS_PANEL_FADE_DURATION)
    if panel.SetAlpha then
        panel:SetAlpha(alpha)
    end

    if alpha <= 0 then
        panel:Hide()
        ResetStatusPanelFade(panel)
    end
end

local function CreateStatusPanel()
    if overlay.statusPanel then
        return overlay.statusPanel
    end

    local panel = CreateFrame("Frame", "PEEStatusPanel", UIParent)
    panel:SetWidth(PANEL_WIDTH)
    panel:SetHeight(PANEL_HEIGHT)
    panel:SetFrameStrata("DIALOG")
    panel:SetMovable(true)
    panel:EnableMouse(true)
    if panel.SetClampedToScreen then
        panel:SetClampedToScreen(true)
    end
    panel:RegisterForDrag("LeftButton")
    panel:SetScript("OnDragStart", function(self)
        self._peeStatusDragging = true
        if self.SetAlpha then
            self:SetAlpha(1)
        end
        self:StartMoving()
    end)
    panel:SetScript("OnDragStop", function(self)
        self:StopMovingOrSizing()
        SavePanelPosition(self)
        ResetStatusPanelFade(self)
    end)
    panel:SetScript("OnUpdate", UpdateStatusPanelFade)
    panel:SetBackdrop({
        bgFile = "Interface\\Buttons\\WHITE8x8",
        edgeFile = "Interface\\Buttons\\WHITE8x8",
        tile = false,
        edgeSize = PANEL_EDGE_SIZE,
        insets = { left = 1, right = 1, top = 1, bottom = 1 }
    })
    panel:SetBackdropColor(0.039, 0.039, 0.039, GetBackdropOpacity())
    panel:SetBackdropBorderColor(BLACK[1], BLACK[2], BLACK[3], 1)

    local title = panel:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    title:SetPoint("TOPLEFT", panel, "TOPLEFT", PANEL_INSET, -PANEL_INSET)
    title:SetFont("Fonts\\FRIZQT__.TTF", ScaledFontSize(16), "OUTLINE")
    title:SetWidth(PANEL_WIDTH - 70)
    title:SetWordWrap(false)
    title:SetText("Project Ebonhold Enhanced")
    SetTextColor(title, MAGE_BLUE)
    panel.title = title

    local closeButton = CreateFlatButton(panel, "X", 26, 24)
    closeButton:SetPoint("TOPRIGHT", panel, "TOPRIGHT", -10, -10)
    closeButton:SetScript("OnClick", function()
        panel:Hide()
    end)
    panel.closeButton = closeButton

    local stateText = CreatePanelText(panel, title, -16)
    stateText:SetFont("Fonts\\FRIZQT__.TTF", ScaledFontSize(13), "OUTLINE")
    panel.stateText = stateText

    local realmText = CreatePanelText(panel, stateText, -8)
    SetTextColor(realmText, CREAM)
    panel.realmText = realmText

    local detailText = CreatePanelText(panel, realmText, -10)
    SetTextColor(detailText, CREAM)
    panel.detailText = detailText

    local hintText = CreatePanelText(panel, detailText, -12)
    hintText:SetFont("Fonts\\FRIZQT__.TTF", ScaledFontSize(11), "OUTLINE")
    SetTextColor(hintText, MUTED)
    panel.hintText = hintText

    RestorePanelPosition(panel)
    panel:Hide()
    overlay.statusPanel = panel

    return panel
end

local function ShowStatusPanel()
    if not overlay.enabled then
        PrintMessage("Inactive on PTR.")
        return
    end

    local panel = CreateStatusPanel()
    UpdateStatusPanel()
    ResetStatusPanelFade(panel)
    panel:Show()
end

overlay.ShowStatusPanel = ShowStatusPanel

local function ToggleStatusPanel()
    if not overlay.enabled then
        PrintMessage("Inactive on PTR.")
        return
    end

    local panel = CreateStatusPanel()
    UpdateStatusPanel()

    if panel:IsShown() then
        panel:Hide()
    else
        ResetStatusPanelFade(panel)
        panel:Show()
    end
end

overlay.ShowReloadPopup = function()
    if not _G or not _G.StaticPopupDialogs or not _G.StaticPopup_Show then
        PrintMessage("Reload required. Use /reload when ready.")
        return
    end

    _G.StaticPopupDialogs.PEE_RELOAD_REQUIRED = {
        text = "A UI reload is required for this change to take effect.\n\nReload now?",
        button1 = "Reload",
        button2 = "Later",
        OnAccept = function()
            if _G.ReloadUI then
                _G.ReloadUI()
            end
        end,
        timeout = 0,
        whileDead = true,
        hideOnEscape = true,
        preferredIndex = 3,
    }

    if _G.StaticPopup_Visible and _G.StaticPopup_Visible("PEE_RELOAD_REQUIRED") then
        return
    end

    _G.StaticPopup_Show("PEE_RELOAD_REQUIRED")
end

local function RefreshVisibleTheme()
    if overlay.statusPanel then
        UpdateStatusPanel()
    end

    if overlay.ApplyPlayerRunTheme then
        overlay.ApplyPlayerRunTheme()
    end

    if overlay.ApplyPerkBrowserTheme then
        overlay.ApplyPerkBrowserTheme()
    end

    if overlay.ApplyPerkChoiceTheme then
        overlay.ApplyPerkChoiceTheme()
    end

    if overlay.ApplyExtractionTheme then
        overlay.ApplyExtractionTheme()
    end

    if overlay.ApplyPatchPopupTheme then
        overlay.ApplyPatchPopupTheme()
    end

    if overlay.ApplyHardmodeTheme then
        overlay.ApplyHardmodeTheme()
    end

    if overlay.ApplySkillTreeTheme then
        overlay.ApplySkillTreeTheme()
    end
end

overlay.RefreshVisibleTheme = RefreshVisibleTheme

overlay.BuildPickedEchoExportRows = function(grantedPerks)
    local rows = {}

    for spellName, instances in pairs(grantedPerks or {}) do
        local byQuality = {}
        for _, instance in ipairs(instances or {}) do
            local quality = instance.quality or 0
            local row = byQuality[quality]
            if not row then
                row = {
                    name = spellName,
                    quality = quality,
                    count = 0,
                    spellId = instance.spellId,
                }
                byQuality[quality] = row
            end
            row.count = row.count + (instance.stack or 1)
            row.spellId = row.spellId or instance.spellId
        end

        for _, row in pairs(byQuality) do
            rows[#rows + 1] = row
        end
    end

    table.sort(rows, function(left, right)
        if (left.quality or 0) ~= (right.quality or 0) then
            return (left.quality or 0) > (right.quality or 0)
        end
        if (left.count or 0) ~= (right.count or 0) then
            return (left.count or 0) > (right.count or 0)
        end
        if (left.name or "") ~= (right.name or "") then
            return (left.name or "") < (right.name or "")
        end
        return (left.spellId or 0) < (right.spellId or 0)
    end)

    return rows
end

overlay.BuildLockedEchoExportRows = function(grantedPerks, lockedPerks)
    local rows = {}

    for spellId, lockedPerk in pairs(lockedPerks or {}) do
        local resolvedSpellId = lockedPerk.spellId or spellId
        local spellName = lockedPerk.name
        if not spellName and GetSpellInfo then
            spellName = GetSpellInfo(resolvedSpellId)
        end

        local quality = lockedPerk.quality or 0
        local ownedCount = 0
        for _, instance in ipairs((spellName and grantedPerks and grantedPerks[spellName]) or {}) do
            if (instance.quality or 0) == quality then
                ownedCount = ownedCount + (instance.stack or 1)
            end
        end
        local lockedCount = ownedCount + (lockedPerk.stack or 1)

        rows[#rows + 1] = {
            name = spellName or ("Spell " .. tostring(resolvedSpellId or "Unknown")),
            quality = quality,
            count = lockedCount,
            spellId = resolvedSpellId,
        }
    end

    table.sort(rows, function(left, right)
        if (left.quality or 0) ~= (right.quality or 0) then
            return (left.quality or 0) > (right.quality or 0)
        end
        if (left.name or "") ~= (right.name or "") then
            return (left.name or "") < (right.name or "")
        end
        return (left.spellId or 0) < (right.spellId or 0)
    end)

    return rows
end

overlay.AddEchoExportRows = function(lines, sectionName, rows)
    local qualityNames = {
        [-1] = "Unknown",
        [0] = "Common",
        [1] = "Uncommon",
        [2] = "Rare",
        [3] = "Epic",
        [4] = "Legendary",
    }

    lines[#lines + 1] = sectionName
    lines[#lines + 1] = "Name\tQuality\tCount\tSpell ID"

    if not rows or #rows == 0 then
        lines[#lines + 1] = "None"
        lines[#lines + 1] = ""
        return
    end

    for _, row in ipairs(rows) do
        lines[#lines + 1] = table.concat({
            row.name or ("Spell " .. tostring(row.spellId or "Unknown")),
            qualityNames[row.quality or -1] or qualityNames[-1],
            tostring(row.count or 0),
            tostring(row.spellId or "Unknown"),
        }, "\t")
    end

    lines[#lines + 1] = ""
end

overlay.BuildEchoExportText = function()
    local perkService = _G and _G.ProjectEbonhold and _G.ProjectEbonhold.PerkService
    local grantedPerks = perkService and perkService.GetGrantedPerks and perkService.GetGrantedPerks() or {}
    local lockedPerks = perkService and perkService.GetLockedPerks and perkService.GetLockedPerks() or {}
    local lines = { "Project Ebonhold Enhanced Echoes", "" }
    local overlayGrantedPerks = overlay.GetMergedGrantedPerksForOverlay and
        overlay.GetMergedGrantedPerksForOverlay(grantedPerks) or grantedPerks

    overlay.AddEchoExportRows(lines, "Locked Echoes",
        overlay.BuildLockedEchoExportRows(overlayGrantedPerks, lockedPerks))
    overlay.AddEchoExportRows(lines, "Picked Echoes", overlay.BuildPickedEchoExportRows(overlayGrantedPerks))

    return table.concat(lines, "\n")
end

overlay.ShowEchoExportFrame = function()
    if not overlay.enabled or overlay.isPTR then
        return
    end

    if not overlay.echoExportFrame then
        local exportFrame = CreateFrame("Frame", "PEEEchoExportFrame", UIParent)
        SetFrameSize(exportFrame, 460, 360)
        exportFrame:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
        exportFrame:SetFrameStrata("DIALOG")
        exportFrame:EnableMouse(true)
        exportFrame:SetMovable(true)
        exportFrame:RegisterForDrag("LeftButton")
        exportFrame:SetScript("OnDragStart", exportFrame.StartMoving)
        exportFrame:SetScript("OnDragStop", exportFrame.StopMovingOrSizing)
        SetDarkBackdrop(exportFrame, 4, 4)

        if UISpecialFrames then
            table.insert(UISpecialFrames, "PEEEchoExportFrame")
        end

        local title = exportFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        title:SetPoint("TOP", exportFrame, "TOP", 0, -14)
        title:SetFont("Fonts\\FRIZQT__.TTF", ScaledFontSize(14), "OUTLINE")
        title:SetTextColor(MAGE_BLUE[1], MAGE_BLUE[2], MAGE_BLUE[3], 1)
        title:SetText("Export Echoes")

        local closeButton = CreateFrame("Button", nil, exportFrame, "UIPanelCloseButton")
        closeButton:SetPoint("TOPRIGHT", exportFrame, "TOPRIGHT", -5, -5)

        local bodyFrame = CreateFrame("Frame", nil, exportFrame)
        bodyFrame:SetPoint("TOPLEFT", exportFrame, "TOPLEFT", 18, -44)
        bodyFrame:SetPoint("BOTTOMRIGHT", exportFrame, "BOTTOMRIGHT", -34, 18)
        SetFrameBackdrop(bodyFrame, 2, 2)
        if bodyFrame.SetBackdropColor then
            bodyFrame:SetBackdropColor(0.02, 0.02, 0.02, 1)
        end
        if bodyFrame.SetBackdropBorderColor then
            bodyFrame:SetBackdropBorderColor(0.25, 0.25, 0.25, 1)
        end

        local scrollFrame = CreateFrame("ScrollFrame", "PEEEchoExportScroll", bodyFrame, "UIPanelScrollFrameTemplate")
        scrollFrame:SetPoint("TOPLEFT", bodyFrame, "TOPLEFT", 6, -6)
        scrollFrame:SetPoint("BOTTOMRIGHT", bodyFrame, "BOTTOMRIGHT", -24, 6)

        local editBox = CreateFrame("EditBox", nil, scrollFrame)
        if editBox.SetMultiLine then
            editBox:SetMultiLine(true)
        end
        if editBox.SetAutoFocus then
            editBox:SetAutoFocus(false)
        end
        if editBox.SetFont then
            editBox:SetFont("Fonts\\FRIZQT__.TTF", ScaledFontSize(11), nil)
        end
        if editBox.SetTextColor then
            editBox:SetTextColor(1, 1, 1, 1)
        end
        if editBox.SetWidth then
            editBox:SetWidth(370)
        end
        if editBox.SetTextInsets then
            editBox:SetTextInsets(4, 4, 4, 4)
        end
        editBox:SetScript("OnEscapePressed", function(self)
            self:ClearFocus()
            exportFrame:Hide()
        end)
        editBox:SetScript("OnEditFocusGained", function(self)
            self:HighlightText()
        end)
        editBox:SetScript("OnMouseUp", function(self)
            self:HighlightText()
        end)
        scrollFrame:SetScrollChild(editBox)

        exportFrame.editBox = editBox
        exportFrame.title = title
        overlay.echoExportFrame = exportFrame
    end

    local text = overlay.BuildEchoExportText()
    local _, lineBreaks = text:gsub("\n", "\n")
    overlay.echoExportFrame.editBox:SetHeight(math.max(260, (lineBreaks + 1) * 15))
    overlay.echoExportFrame.editBox:SetText(text)
    overlay.echoExportFrame:Show()
    overlay.echoExportFrame.editBox:SetFocus()
    overlay.echoExportFrame.editBox:HighlightText()
end

overlay.EnsureEchoExportButton = function(empowermentFrame)
    if not empowermentFrame or empowermentFrame.peeExportButton or not CreateFrame then
        return
    end

    local exportButton = CreateFrame("Button", nil, empowermentFrame)
    SetFrameSize(exportButton, 20, 20)
    if empowermentFrame.browserButton then
        exportButton:SetPoint("RIGHT", empowermentFrame.browserButton, "LEFT", -4, 0)
    else
        exportButton:SetPoint("TOPRIGHT", empowermentFrame, "TOPRIGHT", -40, -10)
    end

    local exportIcon = exportButton:CreateTexture(nil, "ARTWORK")
    exportIcon:SetAllPoints()
    exportIcon:SetTexture("Interface\\Icons\\INV_Misc_Note_01")
    exportIcon:SetTexCoord(0.07, 0.93, 0.07, 0.93)

    exportButton:SetScript("OnEnter", function(self)
        exportIcon:SetVertexColor(1.2, 1.2, 1.2, 1)
        if GameTooltip then
            GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
            GameTooltip:SetText("Export Echoes", 1, 1, 1)
            GameTooltip:AddLine("Copy locked and picked echoes.", nil, nil, nil, true)
            GameTooltip:Show()
        end
    end)
    exportButton:SetScript("OnLeave", function()
        exportIcon:SetVertexColor(1, 1, 1, 1)
        if GameTooltip then
            GameTooltip:Hide()
        end
    end)
    exportButton:SetScript("OnClick", function()
        overlay.ShowEchoExportFrame()
    end)

    empowermentFrame.peeExportButton = exportButton
end

overlay.GetFontStringText = function(fontString)
    if fontString and fontString.GetText then
        return fontString:GetText()
    end

    return fontString and fontString.text
end

overlay.GetFrameTitleText = function(frame)
    local titleText = overlay.GetFontStringText(frame and frame.title)
    if titleText then
        return titleText
    end

    if frame and frame.GetRegions then
        local regions = { frame:GetRegions() }
        for _, region in ipairs(regions) do
            titleText = overlay.GetFontStringText(region)
            if titleText then
                return titleText
            end
        end
    end

    return nil
end

overlay.FindPermanentEchoSelectorFrame = function()
    if not UIParent or not UIParent.GetChildren then
        return nil
    end

    local children = { UIParent:GetChildren() }
    for _, child in ipairs(children) do
        if overlay.GetFontStringText(child and child.title) == "Select Echo to Make Permanent" then
            return child
        end
    end

    for _, child in ipairs(children) do
        if not child.title and overlay.GetFrameTitleText(child) == "Select Echo to Make Permanent" then
            return child
        end
    end

    return nil
end

overlay.GetSelectorScrollChild = function(scrollFrame)
    if not scrollFrame then
        return nil
    end

    if scrollFrame.GetScrollChild then
        return scrollFrame:GetScrollChild()
    end

    if scrollFrame.scrollChild then
        return scrollFrame.scrollChild
    end

    if scrollFrame.GetChildren then
        local children = { scrollFrame:GetChildren() }
        return children[1]
    end

    return nil
end

overlay.FindPermanentEchoSelectorScrollFrame = function(selectorFrame)
    if not selectorFrame or not selectorFrame.GetChildren then
        return nil, nil
    end

    local children = { selectorFrame:GetChildren() }
    for _, child in ipairs(children) do
        local scrollChild = overlay.GetSelectorScrollChild(child)
        if scrollChild and scrollChild.GetChildren then
            local rows = { scrollChild:GetChildren() }
            if #rows > 0 then
                return child, scrollChild
            end
        end
    end

    return nil, nil
end

overlay.GetPermanentEchoRowName = function(row)
    if not row then
        return nil
    end

    if row._peePermanentEchoRowName then
        return row._peePermanentEchoRowName
    end

    if row.GetRegions then
        local regions = { row:GetRegions() }
        for _, region in ipairs(regions) do
            local text = overlay.GetFontStringText(region)
            if text and text ~= "" then
                row._peePermanentEchoRowName = text:lower()
                return row._peePermanentEchoRowName
            end
        end
    end

    return nil
end

overlay.FilterPermanentEchoSelector = function(selectorFrame)
    local searchBox = selectorFrame and selectorFrame.peeSearchBox
    local _, scrollChild = overlay.FindPermanentEchoSelectorScrollFrame(selectorFrame)
    if not searchBox or not scrollChild or not scrollChild.GetChildren then
        return
    end

    local needle = ""
    if searchBox.GetText then
        needle = (searchBox:GetText() or ""):lower()
    end

    local searchChanged = selectorFrame._peePermanentEchoLastSearch ~= needle
    selectorFrame._peePermanentEchoLastSearch = needle

    local visibleIndex = 0
    local rows = { scrollChild:GetChildren() }
    for _, row in ipairs(rows) do
        local rowName = overlay.GetPermanentEchoRowName(row) or ""
        if needle == "" or rowName:find(needle, 1, true) then
            visibleIndex = visibleIndex + 1
            if row.ClearAllPoints then
                row:ClearAllPoints()
            end
            if row.SetPoint then
                row:SetPoint("TOP", scrollChild, "TOP", 0, -(visibleIndex - 1) * 40)
            end
            if row.Show then
                row:Show()
            end
        elseif row.Hide then
            row:Hide()
        end
    end

    if scrollChild.SetHeight then
        scrollChild:SetHeight(math.max(visibleIndex * 40, 1))
    end

    local scrollFrame = selectorFrame.peeSelectorScrollFrame
    if scrollFrame and scrollFrame.UpdateScrollChildRect then
        scrollFrame:UpdateScrollChildRect()
    end
    if scrollFrame and scrollFrame.SetVerticalScroll and searchChanged then
        scrollFrame:SetVerticalScroll(0)
    end
end

overlay.ApplyPermanentEchoSelectorSearch = function()
    if not overlay.enabled or overlay.isPTR then
        return
    end

    local selectorFrame = overlay.FindPermanentEchoSelectorFrame()
    if not selectorFrame then
        return
    end

    if overlay.HookPermanentEchoSelectorFrame then
        overlay.HookPermanentEchoSelectorFrame(selectorFrame)
    end

    SetDarkBackdrop(selectorFrame, 4, 4)

    if selectorFrame.title and selectorFrame.title.ClearAllPoints then
        selectorFrame.title:ClearAllPoints()
    end
    if selectorFrame.title and selectorFrame.title.SetPoint then
        selectorFrame.title:SetPoint("TOP", selectorFrame, "TOP", 0, -12)
    end

    local scrollFrame = overlay.FindPermanentEchoSelectorScrollFrame(selectorFrame)
    if not scrollFrame then
        return
    end

    selectorFrame.peeSelectorScrollFrame = scrollFrame
    if scrollFrame.ClearAllPoints then
        scrollFrame:ClearAllPoints()
    end
    if scrollFrame.SetPoint then
        scrollFrame:SetPoint("TOPLEFT", selectorFrame, "TOPLEFT", 10, -60)
        scrollFrame:SetPoint("BOTTOMRIGHT", selectorFrame, "BOTTOMRIGHT", -30, 10)
    end

    if not selectorFrame.peeSearchBox then
        local searchBox = CreateFrame("EditBox", nil, selectorFrame)
        searchBox:SetHeight(22)
        searchBox:SetPoint("TOPLEFT", selectorFrame, "TOPLEFT", 10, -34)
        searchBox:SetPoint("TOPRIGHT", selectorFrame, "TOPRIGHT", -30, -34)
        if searchBox.SetAutoFocus then
            searchBox:SetAutoFocus(false)
        end
        if searchBox.SetFontObject then
            searchBox:SetFontObject("GameFontHighlightSmall")
        elseif searchBox.SetFont then
            searchBox:SetFont("Fonts\\FRIZQT__.TTF", ScaledFontSize(11), nil)
        end
        if searchBox.SetTextInsets then
            searchBox:SetTextInsets(6, 6, 0, 0)
        end
        SetFrameBackdrop(searchBox, 1, 1)
        if searchBox.SetBackdropColor then
            searchBox:SetBackdropColor(0.02, 0.02, 0.02, 1)
        end
        if searchBox.SetBackdropBorderColor then
            searchBox:SetBackdropBorderColor(BLACK[1], BLACK[2], BLACK[3], 1)
        end

        local hint = searchBox:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
        hint:SetPoint("LEFT", searchBox, "LEFT", 8, 0)
        hint:SetText("Search echoes...")
        hint:SetTextColor(0.5, 0.5, 0.5, 1)
        selectorFrame.peeSearchHint = hint

        searchBox:SetScript("OnEditFocusGained", function(self)
            if self.SetBackdropBorderColor then
                self:SetBackdropBorderColor(HOVER_BLUE[1], HOVER_BLUE[2], HOVER_BLUE[3], 1)
            end
            if hint.Hide then
                hint:Hide()
            end
        end)
        searchBox:SetScript("OnEditFocusLost", function(self)
            if self.SetBackdropBorderColor then
                self:SetBackdropBorderColor(BLACK[1], BLACK[2], BLACK[3], 1)
            end
            if self.GetText and self:GetText() == "" and hint.Show then
                hint:Show()
            end
        end)
        searchBox:SetScript("OnEscapePressed", function(self)
            if self.ClearFocus then
                self:ClearFocus()
            end
        end)
        searchBox:SetScript("OnEnterPressed", function(self)
            if self.ClearFocus then
                self:ClearFocus()
            end
        end)
        searchBox:SetScript("OnTextChanged", function(self)
            if self.GetText and self:GetText() == "" and hint.Show then
                hint:Show()
            elseif hint.Hide then
                hint:Hide()
            end
            overlay.FilterPermanentEchoSelector(selectorFrame)
        end)

        selectorFrame.peeSearchBox = searchBox
    end

    overlay.FilterPermanentEchoSelector(selectorFrame)
end

overlay.HookPermanentEchoSelectorFrame = function(selectorFrame)
    if not selectorFrame or selectorFrame._peePermanentEchoSelectorHooked then
        return
    end

    selectorFrame._peePermanentEchoSelectorHooked = true

    if selectorFrame.HookScript then
        selectorFrame:HookScript("OnShow", function()
            overlay.ApplyPermanentEchoSelectorSearch()
        end)
        return
    end

    if selectorFrame.GetScript and selectorFrame.SetScript then
        local originalOnShow = selectorFrame:GetScript("OnShow")
        selectorFrame:SetScript("OnShow", function(self, ...)
            if type(originalOnShow) == "function" then
                originalOnShow(self, ...)
            end
            overlay.ApplyPermanentEchoSelectorSearch()
        end)
    end
end

overlay.EnsurePermanentEchoSelectorWatcher = function()
    if overlay.permanentEchoSelectorWatcher then
        return
    end

    local watcher = CreateFrame("Frame")
    watcher.elapsed = 0
    watcher:SetScript("OnUpdate", function(self, elapsed)
        if not overlay.enabled or overlay.isPTR then
            return
        end

        self.elapsed = (self.elapsed or 0) + (elapsed or 0)
        if self.elapsed < 0.25 then
            return
        end

        self.elapsed = 0

        local empowermentFrame = _G and _G.ProjectEbonholdEmpowermentFrame
        if empowermentFrame and empowermentFrame.IsShown and not empowermentFrame:IsShown() then
            return
        end

        local selectorFrame = overlay.FindPermanentEchoSelectorFrame()
        if not selectorFrame then
            return
        end

        overlay.HookPermanentEchoSelectorFrame(selectorFrame)
        if selectorFrame.IsShown and not selectorFrame:IsShown() then
            return
        end

        overlay.ApplyPermanentEchoSelectorSearch()
    end)

    overlay.permanentEchoSelectorWatcher = watcher
end

overlay.FormatCompactNumber = function(value)
    value = value or 0
    if value >= 1000000 then
        return string.format("%.1fM", value / 1000000)
    elseif value >= 1000 then
        return string.format("%.1fK", value / 1000)
    end

    return string.format("%.0f", value)
end

overlay.FormatGoldRate = function(copper)
    copper = copper or 0
    local sign = copper < 0 and "-" or ""
    local absoluteCopper = math.abs(copper)
    local gold = math.floor(absoluteCopper / 10000)
    local silver = math.floor((absoluteCopper % 10000) / 100)

    if gold > 0 then
        return sign .. gold .. "g" .. silver .. "s"
    end

    return sign .. silver .. "s"
end

overlay.FormatTrackerTime = function(seconds)
    seconds = seconds or 0
    local hours = math.floor(seconds / 3600)
    local minutes = math.floor((seconds % 3600) / 60)
    local displaySeconds = math.floor(seconds % 60)

    if hours > 0 then
        return string.format("%d:%02d:%02d", hours, minutes, displaySeconds)
    end

    return string.format("%d:%02d", minutes, displaySeconds)
end

overlay.GetPlayerRunTrackerTime = function()
    if GetTime then
        return GetTime()
    end

    return 0
end

overlay.GetPlayerRunGold = function()
    if GetMoney then
        return GetMoney()
    end

    return 0
end

overlay.ResetPlayerRunAshTracker = function(playerRunFrame)
    if not playerRunFrame then
        return
    end

    local now = overlay.GetPlayerRunTrackerTime()
    playerRunFrame._peeAshTrackStartValue = playerRunFrame.currentSoulPoints or 0
    playerRunFrame._peeTrackerActiveTime = 0
    playerRunFrame._peeAshLastTick = now
    if not playerRunFrame._peeGoldLastTick then
        playerRunFrame._peeGoldTrackStartValue = overlay.GetPlayerRunGold()
        playerRunFrame._peeGoldLastTick = now
    end
    playerRunFrame._peeTrackerPaused = false
    playerRunFrame._peeTrackerOOCTimer = 0
    if playerRunFrame.ashRateText and playerRunFrame.ashRateText.SetText then
        playerRunFrame.ashRateText:SetText("|cff888888tracking...|r")
    end
end

overlay.ResetPlayerRunGoldTracker = function(playerRunFrame)
    if not playerRunFrame then
        return
    end

    local now = overlay.GetPlayerRunTrackerTime()
    playerRunFrame._peeGoldTrackStartValue = overlay.GetPlayerRunGold()
    playerRunFrame._peeTrackerActiveTime = 0
    if not playerRunFrame._peeAshLastTick and playerRunFrame.currentSoulPoints ~= nil then
        playerRunFrame._peeAshTrackStartValue = playerRunFrame.currentSoulPoints
        playerRunFrame._peeAshLastTick = now
    end
    playerRunFrame._peeGoldLastTick = now
    playerRunFrame._peeTrackerPaused = false
    playerRunFrame._peeTrackerOOCTimer = 0
    if playerRunFrame.goldRateText and playerRunFrame.goldRateText.SetText then
        playerRunFrame.goldRateText:SetText("|cff888888tracking...|r")
    end
end

overlay.UpdatePlayerRunTrackerText = function(playerRunFrame)
    if not playerRunFrame then
        return
    end

    if not playerRunFrame._peeAshLastTick and playerRunFrame.currentSoulPoints ~= nil then
        overlay.ResetPlayerRunAshTracker(playerRunFrame)
    end

    if not playerRunFrame._peeGoldLastTick then
        overlay.ResetPlayerRunGoldTracker(playerRunFrame)
    end

    local activeTime = playerRunFrame._peeTrackerActiveTime or 0
    local pauseTag = playerRunFrame._peeTrackerPaused and "  |cffaa5555paused|r" or ""

    if playerRunFrame.timerText and playerRunFrame.timerText.SetText then
        playerRunFrame.timerText:SetText("|cff777777" .. overlay.FormatTrackerTime(activeTime) .. "|r")
    end

    if playerRunFrame.ashRateText and playerRunFrame.ashRateText.SetText then
        local gainedAsh = (playerRunFrame.currentSoulPoints or 0) - (playerRunFrame._peeAshTrackStartValue or 0)
        if activeTime > 5 and gainedAsh > 0 then
            local perMinute = gainedAsh / (activeTime / 60)
            local perHour = perMinute * 60
            playerRunFrame._compactAshPerMin = perMinute
            playerRunFrame._compactAshPerHr = perHour
            playerRunFrame.ashRateText:SetText("|cffbbbbbb" ..
                overlay.FormatCompactNumber(perMinute) .. "/min  " ..
                overlay.FormatCompactNumber(perHour) .. "/hr|r" .. pauseTag)
        else
            playerRunFrame._compactAshPerMin = nil
            playerRunFrame._compactAshPerHr = nil
            playerRunFrame.ashRateText:SetText("|cff888888tracking...|r" .. pauseTag)
        end
    end

    if playerRunFrame.goldRateText and playerRunFrame.goldRateText.SetText then
        local gainedCopper = overlay.GetPlayerRunGold() - (playerRunFrame._peeGoldTrackStartValue or 0)
        if activeTime > 5 and gainedCopper ~= 0 then
            local perHourCopper = gainedCopper / (activeTime / 3600)
            playerRunFrame._compactGoldPerHr = perHourCopper
            local color = gainedCopper > 0 and "|cfff0d440" or "|cffff4444"
            playerRunFrame.goldRateText:SetText(color .. overlay.FormatGoldRate(perHourCopper) .. "/hr|r" .. pauseTag)
        else
            playerRunFrame._compactGoldPerHr = nil
            playerRunFrame.goldRateText:SetText("|cff888888tracking...|r" .. pauseTag)
        end
    end

    if playerRunFrame.RefreshCompact then
        playerRunFrame.RefreshCompact()
    end
end

overlay.EnsurePlayerRunTrackerFrame = function(playerRunFrame)
    if overlay.playerRunTrackerFrame then
        overlay.playerRunTrackerFrame.playerRunFrame = playerRunFrame
        return
    end

    local trackerFrame = CreateFrame("Frame", nil, UIParent)
    trackerFrame.playerRunFrame = playerRunFrame
    trackerFrame.elapsed = 0
    trackerFrame:RegisterEvent("PLAYER_REGEN_DISABLED")
    trackerFrame:RegisterEvent("PLAYER_REGEN_ENABLED")
    trackerFrame:RegisterEvent("PLAYER_MONEY")
    trackerFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
    trackerFrame:SetScript("OnEvent", function(self, event)
        local frame = self.playerRunFrame
        if not frame then
            return
        end

        if event == "PLAYER_REGEN_DISABLED" then
            frame._peeTrackerInCombat = true
            frame._peeTrackerOOCTimer = 0
            if frame._peeTrackerPaused then
                frame._peeTrackerPaused = false
                frame._peeAshLastTick = overlay.GetPlayerRunTrackerTime()
                frame._peeGoldLastTick = overlay.GetPlayerRunTrackerTime()
            end
        elseif event == "PLAYER_REGEN_ENABLED" then
            frame._peeTrackerInCombat = false
            frame._peeTrackerOOCTimer = 0
        else
            overlay.UpdatePlayerRunTrackerText(frame)
        end
    end)
    trackerFrame:SetScript("OnUpdate", function(self, elapsed)
        local frame = self.playerRunFrame
        if not frame then
            return
        end

        if (frame._peeAshLastTick or frame._peeGoldLastTick) and not frame._peeTrackerPaused then
            if not frame._peeTrackerInCombat then
                frame._peeTrackerOOCTimer = (frame._peeTrackerOOCTimer or 0) + elapsed
                if frame._peeTrackerOOCTimer >= 30 then
                    frame._peeTrackerPaused = true
                end
            end

            if not frame._peeTrackerPaused then
                frame._peeTrackerActiveTime = (frame._peeTrackerActiveTime or 0) + elapsed
            end
        end

        self.elapsed = (self.elapsed or 0) + elapsed
        if self.elapsed >= 1 then
            self.elapsed = 0
            overlay.UpdatePlayerRunTrackerText(frame)
        end
    end)

    overlay.playerRunTrackerFrame = trackerFrame
end

overlay.EnsurePlayerRunTrackers = function(playerRunFrame)
    if not playerRunFrame or playerRunFrame.peeTrackersReady or not CreateFrame then
        return
    end

    local parentFrame = playerRunFrame
    if playerRunFrame.soulAshIcon then
        parentFrame = (playerRunFrame.soulAshIcon.GetParent and playerRunFrame.soulAshIcon:GetParent()) or
            playerRunFrame.soulAshIcon.parent or parentFrame
    end

    if not playerRunFrame.timerText and parentFrame.CreateFontString then
        local timerText = parentFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        if playerRunFrame.soulAshIcon and timerText.SetPoint then
            timerText:SetPoint("TOP", playerRunFrame.soulAshIcon, "TOP", 0, 0)
        end
        timerText:SetPoint("RIGHT", parentFrame, "RIGHT", -2, 0)
        timerText:SetFont("Fonts\\FRIZQT__.TTF", ScaledFontSize(10), nil)
        timerText:SetTextColor(0.5, 0.5, 0.5, 1)
        if timerText.SetJustifyH then
            timerText:SetJustifyH("RIGHT")
        end
        playerRunFrame.timerText = timerText
    end

    local ashRateText = parentFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    ashRateText:SetPoint("TOPLEFT", parentFrame, "TOPLEFT", 0, -36)
    ashRateText:SetFont("Fonts\\FRIZQT__.TTF", ScaledFontSize(10), nil)
    ashRateText:SetTextColor(0.6, 0.6, 0.6, 1)
    ashRateText:SetText("")
    playerRunFrame.ashRateText = ashRateText

    local ashResetButton = CreateFrame("Button", nil, parentFrame)
    SetFrameSize(ashResetButton, 10, 10)
    ashResetButton:SetPoint("LEFT", ashRateText, "RIGHT", 4, 0)
    local ashResetText = ashResetButton:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    ashResetText:SetPoint("CENTER", ashResetButton, "CENTER", 0, 0)
    ashResetText:SetFont("Fonts\\FRIZQT__.TTF", ScaledFontSize(8), "OUTLINE")
    ashResetText:SetText("|cffaa5555x|r")
    ashResetButton:SetScript("OnClick", function()
        overlay.ResetPlayerRunAshTracker(playerRunFrame)
    end)
    ashResetButton:SetScript("OnEnter", function(self)
        ashResetText:SetText("|cffff4444x|r")
        if GameTooltip then
            GameTooltip:SetOwner(self, "ANCHOR_TOP")
            GameTooltip:SetText("Reset Tracker", 1, 0.5, 0.5)
            GameTooltip:AddLine("Restart soul ash rate tracking from now.", 0.8, 0.8, 0.8, true)
            GameTooltip:Show()
        end
    end)
    ashResetButton:SetScript("OnLeave", function()
        ashResetText:SetText("|cffaa5555x|r")
        if GameTooltip then
            GameTooltip:Hide()
        end
    end)
    playerRunFrame.ashResetBtn = ashResetButton

    local goldRateText = parentFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    goldRateText:SetPoint("TOPLEFT", parentFrame, "TOPLEFT", 0, -48)
    goldRateText:SetFont("Fonts\\FRIZQT__.TTF", ScaledFontSize(10), nil)
    goldRateText:SetTextColor(0.6, 0.6, 0.6, 1)
    goldRateText:SetText("")
    playerRunFrame.goldRateText = goldRateText

    local goldResetButton = CreateFrame("Button", nil, parentFrame)
    SetFrameSize(goldResetButton, 10, 10)
    goldResetButton:SetPoint("LEFT", goldRateText, "RIGHT", 4, 0)
    local goldResetText = goldResetButton:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    goldResetText:SetPoint("CENTER", goldResetButton, "CENTER", 0, 0)
    goldResetText:SetFont("Fonts\\FRIZQT__.TTF", ScaledFontSize(8), "OUTLINE")
    goldResetText:SetText("|cffaa5555x|r")
    goldResetButton:SetScript("OnClick", function()
        overlay.ResetPlayerRunGoldTracker(playerRunFrame)
    end)
    goldResetButton:SetScript("OnEnter", function(self)
        goldResetText:SetText("|cffff4444x|r")
        if GameTooltip then
            GameTooltip:SetOwner(self, "ANCHOR_TOP")
            GameTooltip:SetText("Reset Gold Tracker", 1, 0.5, 0.5)
            GameTooltip:AddLine("Restart gold rate tracking from now.", 0.8, 0.8, 0.8, true)
            GameTooltip:Show()
        end
    end)
    goldResetButton:SetScript("OnLeave", function()
        goldResetText:SetText("|cffaa5555x|r")
        if GameTooltip then
            GameTooltip:Hide()
        end
    end)
    playerRunFrame.goldResetBtn = goldResetButton

    playerRunFrame.peeTrackersReady = true
    playerRunFrame._peeTrackerActiveTime = playerRunFrame._peeTrackerActiveTime or 0
    playerRunFrame._peeTrackerPaused = false
    playerRunFrame._peeTrackerOOCTimer = 0
    playerRunFrame._peeTrackerInCombat = false
    overlay.EnsurePlayerRunTrackerFrame(playerRunFrame)
    overlay.UpdatePlayerRunTrackerText(playerRunFrame)
end

overlay.FormatGoldCompact = function(copper)
    local sign = copper < 0 and "-" or ""
    local absoluteCopper = math.abs(copper or 0)
    local gold = math.floor(absoluteCopper / 10000)

    if gold >= 1000000 then
        return sign .. string.format("%.1fMg", gold / 1000000)
    elseif gold >= 1000 then
        return sign .. string.format("%.1fKg", gold / 1000)
    elseif gold > 0 then
        local silver = math.floor((absoluteCopper % 10000) / 100)
        return sign .. gold .. "g" .. (silver > 0 and (silver .. "s") or "")
    end

    local silver = math.floor((absoluteCopper % 10000) / 100)
    return sign .. silver .. "s"
end

overlay.GetPlayerRunCompactStore = function()
    EnsureSavedVariables()
    if type(overlay.db.playerRunCompact) ~= "table" then
        overlay.db.playerRunCompact = {}
    end

    return overlay.db.playerRunCompact
end

overlay.GetHardmodeStore = function()
    ProjectEbonholdEnhancedCharDB = ProjectEbonholdEnhancedCharDB or {}
    overlay.charDB = overlay.charDB or ProjectEbonholdEnhancedCharDB
    if type(overlay.charDB.hardmode) ~= "table" then
        overlay.charDB.hardmode = {}
    end
    return overlay.charDB.hardmode
end

overlay.CreatePlayerRunCompactText = function(parent, size, flags)
    local fontString = parent:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    fontString:SetFont("Fonts\\FRIZQT__.TTF", ScaledFontSize(size), flags)
    return fontString
end

overlay.GetPlayerRunIntensity = function(playerRunFrame)
    local project = _G and _G.ProjectEbonhold
    local playerRunService = project and project.PlayerRunService
    if playerRunService and playerRunService.GetIntensityData then
        local intensityData = playerRunService.GetIntensityData() or {}
        return intensityData.intensity or playerRunFrame.currentIntensity or 0
    end

    return playerRunFrame.currentIntensity or 0
end

overlay.GetHardcoreTierText = function(tier)
    tier = tonumber(tier)
    return overlay.hardcoreTierText[tier] or tostring(tier or "")
end

overlay.GetHardmodeDisplayText = function(difficulty)
    difficulty = tonumber(difficulty)
    if difficulty and difficulty > 1 then
        return "|cffFF4444Hardcore " .. overlay.GetHardcoreTierText(difficulty - 1) .. "|r"
    end

    return "|cffAAAAAANormal|r"
end

overlay.ParseHardmodeDifficultyText = function(text)
    if type(text) ~= "string" or text == "" then
        return nil
    end
    if text:find("Normal", 1, true) then
        return 1
    end

    local tierText = text:match("Hardcore%s+([IVX]+)") or text:match("Hardcore%s+(%d+)")
    if not tierText then
        return nil
    end

    local tier = tonumber(tierText) or overlay.hardcoreTierByText[tierText:upper()]
    if not tier then
        return nil
    end

    return tier + 1
end

overlay.RememberHardmodeDifficulty = function(difficulty, clearNormal)
    difficulty = tonumber(difficulty)
    if not difficulty then
        return
    end

    local store = overlay.GetHardmodeStore()
    if difficulty > 1 then
        store.difficulty = difficulty
    elseif clearNormal then
        store.difficulty = nil
    end
end

overlay.GetServiceHardmodeDifficulty = function()
    local project = _G and _G.ProjectEbonhold
    local service = project and project.HardmodeService
    if service and service.GetCurrentDifficulty then
        return tonumber(service.GetCurrentDifficulty())
    end

    return nil
end

overlay.GetPlayerRunHardmodeDifficulty = function(playerRunFrame, authoritative)
    local serviceDifficulty = overlay.GetServiceHardmodeDifficulty()
    if authoritative and serviceDifficulty then
        overlay.RememberHardmodeDifficulty(serviceDifficulty, true)
        return serviceDifficulty
    end

    if serviceDifficulty and serviceDifficulty > 1 then
        overlay.RememberHardmodeDifficulty(serviceDifficulty, false)
        return serviceDifficulty
    end

    if playerRunFrame and playerRunFrame.hardmodeTierText and playerRunFrame.hardmodeTierText.GetText then
        local textDifficulty = overlay.ParseHardmodeDifficultyText(playerRunFrame.hardmodeTierText:GetText() or "")
        if textDifficulty and textDifficulty > 1 then
            overlay.RememberHardmodeDifficulty(textDifficulty, false)
            return textDifficulty
        end
    end

    local storedDifficulty = overlay.GetHardmodeStore().difficulty
    if storedDifficulty and storedDifficulty > 1 then
        return storedDifficulty
    end

    return serviceDifficulty or 1
end

overlay.GetPlayerRunHardmodeText = function(playerRunFrame, authoritative)
    return overlay.GetHardmodeDisplayText(overlay.GetPlayerRunHardmodeDifficulty(playerRunFrame, authoritative))
end

overlay.ToggleHardmodeFrameFromPEE = function()
    local project = _G and _G.ProjectEbonhold
    if project and type(project.ToggleHardmodeFrame) == "function" then
        project.ToggleHardmodeFrame()
        return true
    end
    if project and type(project.ToggleTormentFrame) == "function" then
        project.ToggleTormentFrame()
        return true
    end
    return false
end

overlay.SyncPlayerRunHardmodeLabels = function(playerRunFrame, authoritative)
    if not playerRunFrame then
        return
    end

    local text = overlay.GetPlayerRunHardmodeText(playerRunFrame, authoritative)
    if playerRunFrame.hardmodeTierText and playerRunFrame.hardmodeTierText.SetText then
        playerRunFrame.hardmodeTierText:SetText(text)
    end

    local compactFrame = playerRunFrame.compactFrame
    if compactFrame and compactFrame.hardmodeText then
        compactFrame.hardmodeText:SetText(text)
    end
end

overlay.RefreshPlayerRunCompact = function(playerRunFrame)
    local compactFrame = playerRunFrame and playerRunFrame.compactFrame
    if not compactFrame or not compactFrame.IsShown or not compactFrame:IsShown() then
        return
    end

    overlay.SyncPlayerRunHardmodeLabels(playerRunFrame, false)

    if compactFrame.ashCount and playerRunFrame.currentSoulPoints ~= nil then
        compactFrame.ashCount:SetText(
            "|cffffffff" .. overlay.FormatCompactNumber(playerRunFrame.currentSoulPoints) .. "|r"
        )
    end

    if compactFrame.multiplier and playerRunFrame.multiplierText and playerRunFrame.multiplierText.GetText then
        compactFrame.multiplier:SetText(playerRunFrame.multiplierText:GetText() or "")
    elseif compactFrame.multiplier and playerRunFrame.currentMultiplier then
        compactFrame.multiplier:SetText(string.format("|cff00ff00+%.0f%%|r", playerRunFrame.currentMultiplier * 100))
    end

    local pauseTag = playerRunFrame._peeTrackerPaused and "  |cffaa5555paused|r" or ""
    local perHourAsh = playerRunFrame._compactAshPerHr
    if compactFrame.ashRate then
        if perHourAsh then
            compactFrame.ashRate:SetText("|cffbbbbbb" .. overlay.FormatCompactNumber(perHourAsh) .. "/hr|r" .. pauseTag)
        else
            compactFrame.ashRate:SetText("|cff888888tracking...|r" .. pauseTag)
        end
    end

    local perHourGold = playerRunFrame._compactGoldPerHr
    if compactFrame.goldRate then
        if perHourGold then
            local color = perHourGold > 0 and "|cfff0d440" or "|cffff4444"
            compactFrame.goldRate:SetText(color .. overlay.FormatGoldCompact(perHourGold) .. "/hr|r" .. pauseTag)
        else
            compactFrame.goldRate:SetText("|cff888888tracking...|r" .. pauseTag)
        end
    end

    if compactFrame.timerText then
        local activeTime = playerRunFrame._peeTrackerActiveTime or 0
        compactFrame.timerText:SetText(
            activeTime > 0 and ("|cff777777" .. overlay.FormatTrackerTime(activeTime) .. "|r") or ""
        )
    end

    if compactFrame.reaperIcon then
        local intensityData = {}
        local project = _G and _G.ProjectEbonhold
        local service = project and project.PlayerRunService
        if service and service.GetIntensityData then
            intensityData = service.GetIntensityData() or {}
        elseif playerRunFrame.currentData then
            intensityData = playerRunFrame.currentData
        end

        local areaName = intensityData.areaNameReaper or "0"
        if areaName ~= "0" then
            compactFrame.reaperIcon:SetTexCoord(0.214844, 0.312500, 0.894531, 0.996094)
        else
            compactFrame.reaperIcon:SetTexCoord(0.121094, 0.214844, 0.898438, 0.996094)
        end
    end

    if compactFrame.intensityText then
        local project = _G and _G.ProjectEbonhold
        local constants = project and project.Constants or {}
        local intensity = overlay.GetPlayerRunIntensity(playerRunFrame)
        local color = intensity >= (constants.INTENSITY_LEVEL_1 or 1) and "|cffff8800" or "|cff888888"
        compactFrame.intensityText:SetText(color .. "Intensity: " .. intensity .. "|r")
    end
end

overlay.SetPlayerRunMinimized = function(playerRunFrame, minimized)
    if not playerRunFrame or not playerRunFrame.compactFrame then
        return
    end

    local compactFrame = playerRunFrame.compactFrame
    local store = overlay.GetPlayerRunCompactStore()
    playerRunFrame._peeMinimized = minimized and true or false
    store.minimized = playerRunFrame._peeMinimized

    if playerRunFrame.peeMinimizeText then
        local minimizeText = playerRunFrame._peeMinimized and "|cffbbbbbb[Show]|r" or "|cffbbbbbb[Mini]|r"
        playerRunFrame.peeMinimizeText:SetText(minimizeText)
    end

    local empowermentFrame = _G and _G.ProjectEbonholdEmpowermentFrame
    if playerRunFrame._peeMinimized then
        overlay.perkChoiceForceShown = false
        playerRunFrame._peeRestoreEmpowermentShown =
            empowermentFrame and empowermentFrame.IsShown and empowermentFrame:IsShown()
        if playerRunFrame.Hide then
            playerRunFrame:Hide()
        end
        if empowermentFrame and empowermentFrame.Hide then
            empowermentFrame:Hide()
        end
        if overlay.HidePerkChoiceSurfaces then
            overlay.HidePerkChoiceSurfaces(true)
        end
        compactFrame:Show()
        overlay.RefreshPlayerRunCompact(playerRunFrame)
        if overlay.ApplyCompactTooltipExtras then
            overlay.ApplyCompactTooltipExtras(playerRunFrame)
        end
    else
        compactFrame:Hide()
        if playerRunFrame.Show then
            playerRunFrame:Show()
        end
        if empowermentFrame and empowermentFrame.Show and playerRunFrame._peeRestoreEmpowermentShown then
            empowermentFrame:Show()
        end
    end
end

overlay.RefreshGrantedPerksForEmpowerment = function(empowermentFrame)
    local project = _G and _G.ProjectEbonhold
    local service = project and project.PerkService
    if not service or type(service.RequestGrantedPerks) ~= "function" then
        return
    end

    local granted = service.GetGrantedPerks and service.GetGrantedPerks() or nil
    if granted then
        for _, instances in pairs(granted) do
            if type(instances) == "table" and #instances > 0 then
                return
            end
        end
    end

    if overlay._grantedPerkRequestPending then
        return
    end

    local now = GetTime and GetTime() or 0
    local lastRefresh = empowermentFrame and empowermentFrame._peeEmptyEchoRefreshAt or 0
    if lastRefresh > 0 and now > 0 and now - lastRefresh < 3 then
        return
    end

    if empowermentFrame then
        empowermentFrame._peeEmptyEchoRefreshAt = now
    end
    overlay._grantedPerkRequestPending = true
    service.RequestGrantedPerks()

    if C_Timer and C_Timer.After then
        C_Timer.After(1, function()
            overlay._grantedPerkRequestPending = nil
        end)
    else
        overlay._grantedPerkRequestPending = nil
    end
end

overlay.ScheduleGrantedPerkDisplayRefresh = function()
    local project = _G and _G.ProjectEbonhold
    overlay._grantedPerkRequestPending = nil
    overlay.ApplyGrantedPerkFallbackVisuals(_G and _G.ProjectEbonholdEmpowermentFrame)

    local perkUI = project and project.PerkUI
    if perkUI and type(perkUI.RefreshOwnedCounts) == "function" then
        perkUI.RefreshOwnedCounts()
    elseif overlay.RefreshVisiblePerkOwnedCounts then
        overlay.RefreshVisiblePerkOwnedCounts()
    end
end

overlay.ServerGrantedPerksContainSpell = function(grantedPerks, spellId, spellName)
    if spellName and grantedPerks and grantedPerks[spellName] then
        return true
    end

    for _, instances in pairs(grantedPerks or {}) do
        for _, instance in ipairs(instances or {}) do
            if instance.spellId == spellId then
                return true
            end
        end
    end

    return false
end

overlay.GetMergedGrantedPerksForOverlay = function(grantedPerks)
    local merged = {}
    for key, instances in pairs(grantedPerks or {}) do
        merged[key] = instances
    end

    for key, instances in pairs(overlay.grantedPerkFallbacks or {}) do
        if not merged[key] then
            merged[key] = instances
        end
    end

    return merged
end

overlay.GetGrantedPerkFallbackRows = function()
    local rows = {}
    for key, instances in pairs(overlay.grantedPerkFallbacks or {}) do
        local totalStacks = 0
        local highestQuality = 0
        local primarySpellId = nil
        for _, instance in ipairs(instances or {}) do
            totalStacks = totalStacks + (instance.stack or 1)
            if (instance.quality or 0) >= highestQuality then
                highestQuality = instance.quality or 0
                primarySpellId = instance.spellId
            end
        end
        if primarySpellId then
            rows[#rows + 1] = {
                key = key,
                spellName = key:match("^__id:") and nil or key,
                spellId = primarySpellId,
                instances = instances,
                totalStacks = totalStacks,
                quality = highestQuality,
            }
        end
    end

    table.sort(rows, function(left, right)
        if (left.quality or 0) ~= (right.quality or 0) then
            return (left.quality or 0) > (right.quality or 0)
        end
        if (left.totalStacks or 0) ~= (right.totalStacks or 0) then
            return (left.totalStacks or 0) > (right.totalStacks or 0)
        end
        return (left.spellId or 0) < (right.spellId or 0)
    end)

    return rows
end

overlay.GetEchoQualityDisplay = function(quality)
    local qualityInfo = {
        [0] = { name = "Common", color = { 1, 1, 1 }, border = 0 },
        [1] = { name = "Uncommon", color = { 0.1, 1.0, 0.1 }, border = 1 },
        [2] = { name = "Rare", color = { 0.0, 0.4, 1.0 }, border = 2 },
        [3] = { name = "Epic", color = { 0.6, 0.2, 1.0 }, border = 3 },
        [4] = { name = "Legendary", color = { 1.0, 0.5, 0.0 }, border = 4 },
    }

    return qualityInfo[quality or 0] or qualityInfo[0]
end

overlay.ClearGrantedPerkFallbackVisuals = function(empowermentFrame)
    for _, iconFrame in ipairs((empowermentFrame and empowermentFrame.peeFallbackPerkIcons) or {}) do
        if iconFrame.Hide then
            iconFrame:Hide()
        end
    end
end

overlay.ApplyGrantedPerkFallbackVisuals = function(empowermentFrame)
    if not empowermentFrame or not empowermentFrame.gridContainer or not CreateFrame then
        return
    end

    local rows = overlay.GetGrantedPerkFallbackRows()
    if #rows == 0 then
        overlay.ClearGrantedPerkFallbackVisuals(empowermentFrame)
        return
    end

    empowermentFrame.peeFallbackPerkIcons = empowermentFrame.peeFallbackPerkIcons or {}
    local gridContainer = empowermentFrame.gridContainer
    local iconSize = 32
    local iconSpacing = 11
    local verticalSpacing = 14
    local columns = 5
    local gridWidth = gridContainer.GetWidth and gridContainer:GetWidth() or 210
    local totalGridWidth = (columns * iconSize) + ((columns - 1) * iconSpacing)
    local startX = math.floor((gridWidth - totalGridWidth) / 2)
    local maxSlots = 0
    local project = _G and _G.ProjectEbonhold
    local service = project and project.PerkService
    if service and type(service.GetMaximumPermanentEchoes) == "function" then
        maxSlots = service.GetMaximumPermanentEchoes() or 0
    end
    local startY = 12
    if maxSlots > 0 then
        startY = startY - 52 - 10
    end
    startY = startY - 10

    local existingCount = type(empowermentFrame.perkIcons) == "table" and #empowermentFrame.perkIcons or 0
    for index, rowData in ipairs(rows) do
        local iconFrame = empowermentFrame.peeFallbackPerkIcons[index]
        if not iconFrame then
            iconFrame = CreateFrame("Button", nil, gridContainer)
            iconFrame._iconBase = iconFrame:CreateTexture(nil, "BACKGROUND")
            iconFrame._iconBase:SetAllPoints(iconFrame)
            iconFrame._icon = iconFrame:CreateTexture(nil, "ARTWORK")
            iconFrame._icon:SetPoint("TOPLEFT", iconFrame, "TOPLEFT", 4, -4)
            iconFrame._icon:SetPoint("BOTTOMRIGHT", iconFrame, "BOTTOMRIGHT", -4, 4)
            iconFrame._border = iconFrame:CreateTexture(nil, "OVERLAY")
            iconFrame._border:SetAllPoints(iconFrame)
            iconFrame._badge = CreateFrame("Frame", nil, gridContainer)
            iconFrame._badge:SetSize(22, 14)
            iconFrame._badge:SetBackdrop({
                bgFile = "Interface\\Buttons\\WHITE8x8",
                edgeFile = "Interface\\Buttons\\WHITE8x8",
                edgeSize = 1,
            })
            iconFrame._badge:SetBackdropColor(0, 0, 0, 0.85)
            iconFrame._badge:SetBackdropBorderColor(0, 0, 0, 1)
            iconFrame._badgeText = iconFrame._badge:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
            iconFrame._badgeText:SetPoint("CENTER", iconFrame._badge, "CENTER", 0, 0)
            iconFrame._badgeText:SetFont("Fonts\\FRIZQT__.TTF", ScaledFontSize(10), "OUTLINE")
            iconFrame:SetScript("OnEnter", function(self)
                if not self._peeFallbackPerkData or not GameTooltip then
                    return
                end

                local perkData = self._peeFallbackPerkData
                local qualityDisplay = overlay.GetEchoQualityDisplay(perkData.quality)
                GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
                if GameTooltip.ClearLines then
                    GameTooltip:ClearLines()
                end
                GameTooltip:AddLine(perkData.spellName or ("Spell " .. tostring(perkData.spellId)),
                    qualityDisplay.color[1], qualityDisplay.color[2], qualityDisplay.color[3])
                GameTooltip:AddLine(qualityDisplay.name, 0.5, 0.5, 0.5)
                if _G.utils and utils.GetSpellDescription then
                    GameTooltip:AddLine(" ")
                    GameTooltip:AddLine(utils.GetSpellDescription(perkData.spellId, 500, perkData.totalStacks or 1),
                        1, 0.82, 0, true)
                end
                GameTooltip:Show()
            end)
            iconFrame:SetScript("OnLeave", function()
                if GameTooltip then
                    GameTooltip:Hide()
                end
            end)
            empowermentFrame.peeFallbackPerkIcons[index] = iconFrame
        end

        local visibleIndex = existingCount + index
        local gridRow = math.floor((visibleIndex - 1) / columns)
        local gridColumn = (visibleIndex - 1) % columns
        iconFrame:SetSize(iconSize, iconSize)
        iconFrame:ClearAllPoints()
        iconFrame:SetPoint("TOPLEFT", gridContainer, "TOPLEFT",
            startX + (gridColumn * (iconSize + iconSpacing)),
            startY - (gridRow * (iconSize + verticalSpacing)))
        if iconFrame.SetFrameLevel and gridContainer.GetFrameLevel then
            iconFrame:SetFrameLevel(gridContainer:GetFrameLevel() + 12)
        end

        local qualityDisplay = overlay.GetEchoQualityDisplay(rowData.quality)
        iconFrame._iconBase:SetTexture("Interface\\AddOns\\ProjectEbonhold\\assets\\perk_quality_" ..
            qualityDisplay.border)
        iconFrame._border:SetTexture("Interface\\AddOns\\ProjectEbonhold\\assets\\perk_border_quality_" ..
            qualityDisplay.border)

        local spellName, _, spellIcon
        if GetSpellInfo then
            spellName, _, spellIcon = GetSpellInfo(rowData.spellId)
        end
        rowData.spellName = spellName or rowData.spellName
        if spellIcon and SetPortraitToTexture then
            SetPortraitToTexture(iconFrame._icon, spellIcon)
        else
            iconFrame._icon:SetTexture("Interface\\Icons\\INV_Misc_QuestionMark")
        end
        iconFrame._peeFallbackPerkData = rowData
        iconFrame._badge:ClearAllPoints()
        iconFrame._badge:SetPoint("TOP", iconFrame, "TOP", 0, 10)
        if iconFrame._badge.SetFrameLevel and iconFrame.GetFrameLevel then
            iconFrame._badge:SetFrameLevel(iconFrame:GetFrameLevel() + 5)
        end
        iconFrame._badgeText:SetText(tostring(rowData.totalStacks or 1))
        iconFrame._badgeText:SetTextColor(qualityDisplay.color[1], qualityDisplay.color[2], qualityDisplay.color[3])
        iconFrame._badge:Show()
        iconFrame:Show()
    end

    for index = #rows + 1, #empowermentFrame.peeFallbackPerkIcons do
        local iconFrame = empowermentFrame.peeFallbackPerkIcons[index]
        if iconFrame then
            iconFrame:Hide()
            if iconFrame._badge then
                iconFrame._badge:Hide()
            end
        end
    end

    if empowermentFrame.SetHeight and gridContainer.SetHeight then
        local totalIcons = existingCount + #rows
        local totalRows = math.ceil(totalIcons / columns)
        local gridBottom = math.abs(startY) + (totalRows * (iconSize + verticalSpacing))
        empowermentFrame:SetHeight(math.max(200, 20 + 15 + 10 + gridBottom + 24 + 15))
        gridContainer:SetHeight(math.max(100, gridBottom + 20))
    end
end

overlay.ApplyGrantedPerkPayloadFallback = function(body)
    local project = _G and _G.ProjectEbonhold
    local service = project and project.PerkService
    if not service or type(service.GetGrantedPerks) ~= "function" then
        return false
    end

    if not body or body == "" then
        overlay.grantedPerkFallbacks = {}
        overlay.ScheduleGrantedPerkDisplayRefresh()
        return false
    end

    local grantedPerks = service.GetGrantedPerks() or {}
    local fallbackPerks = {}
    local parts = {}
    for part in string.gmatch(body, "([^;]+)") do
        parts[#parts + 1] = part
    end

    local addedMissingSpell = false
    for index = 2, #parts do
        local spellIdText, stackText, maxStackText, qualityText, lockedText =
            parts[index]:match("^([^,]+),([^,]+),([^,]+),([^,]+),([^,]+)$")
        if not spellIdText then
            spellIdText, stackText, maxStackText = parts[index]:match("^([^,]+),([^,]+),([^,]+)$")
        end

        local spellId = tonumber(spellIdText)
        local stack = tonumber(stackText)
        local maxStack = tonumber(maxStackText)
        local quality = qualityText and tonumber(qualityText) or 0
        local isLocked = lockedText and tonumber(lockedText) == 1 or false
        if spellId and stack and maxStack and not isLocked then
            local spellName = GetSpellInfo and GetSpellInfo(spellId)
            local key = spellName or ("__id:" .. tostring(spellId))
            if not overlay.ServerGrantedPerksContainSpell(grantedPerks, spellId, spellName) then
                fallbackPerks[key] = fallbackPerks[key] or {}
                for _ = 1, stack do
                    fallbackPerks[key][#fallbackPerks[key] + 1] = {
                        spellId = spellId,
                        stack = 1,
                        maxStack = maxStack,
                        quality = quality,
                    }
                end
                addedMissingSpell = true
            end
        end
    end

    overlay.grantedPerkFallbacks = fallbackPerks
    if addedMissingSpell then
        overlay.ScheduleGrantedPerkDisplayRefresh()
    else
        overlay.ClearGrantedPerkFallbackVisuals(_G and _G.ProjectEbonholdEmpowermentFrame)
        overlay.ScheduleGrantedPerkDisplayRefresh()
    end

    return addedMissingSpell
end

overlay.ScheduleGrantedPerkPayloadFallback = function(body)
    if C_Timer and C_Timer.After then
        C_Timer.After(0.01, function()
            overlay.ApplyGrantedPerkPayloadFallback(body)
        end)
        return
    end

    overlay.ApplyGrantedPerkPayloadFallback(body)
end

overlay.EnsureGrantedPerkPayloadListener = function()
    if overlay.grantedPerkPayloadFrame or not CreateFrame then
        return
    end

    local eventFrame = CreateFrame("Frame")
    eventFrame:RegisterEvent("CHAT_MSG_ADDON")
    eventFrame:SetScript("OnEvent", function(_, _, prefix, payload)
        if prefix ~= "AAM0x9" or not payload or payload == "" then
            return
        end

        local eventText, body = payload:match("^(%d+)\t(.*)$")
        local eventId = tonumber(eventText)
        local project = _G and _G.ProjectEbonhold
        local grantedEventId = project and project.SS and project.SS.SEND_PLAYER_PERK_GRANTED or 18
        if eventId ~= grantedEventId or not body then
            return
        end

        local messageId, chunkIndex, chunkTotal, chunkBody =
            body:match("^@([0-9A-Fa-f][0-9A-Fa-f][0-9A-Fa-f][0-9A-Fa-f])" ..
                "\t([0-9A-Fa-f][0-9A-Fa-f][0-9A-Fa-f])/" ..
                "([0-9A-Fa-f][0-9A-Fa-f][0-9A-Fa-f])\t(.*)$")
        if not messageId then
            overlay.ScheduleGrantedPerkPayloadFallback(body)
            return
        end

        overlay.grantedPerkPayloadChunks = overlay.grantedPerkPayloadChunks or {}
        local key = tostring(eventId) .. ":" .. messageId
        local record = overlay.grantedPerkPayloadChunks[key]
        if not record then
            record = { total = tonumber(chunkTotal, 16) or 0, count = 0, parts = {} }
            overlay.grantedPerkPayloadChunks[key] = record
        end

        local index = tonumber(chunkIndex, 16)
        if index and index >= 1 and index <= record.total and not record.parts[index] then
            record.parts[index] = chunkBody
            record.count = record.count + 1
        end

        if record.total > 0 and record.count == record.total then
            overlay.grantedPerkPayloadChunks[key] = nil
            overlay.ScheduleGrantedPerkPayloadFallback(table.concat(record.parts, "", 1, record.total))
        end
    end)

    overlay.grantedPerkPayloadFrame = eventFrame
end

overlay.CreatePlayerRunCompactShortcut = function(compactFrame, label, onClick, tooltipTitle, tooltipBody)
    local button = CreateFrame("Button", nil, compactFrame)
    SetFrameSize(button, 28, 14)
    local text = overlay.CreatePlayerRunCompactText(button, 10, "OUTLINE")
    text:SetPoint("CENTER", button, "CENTER", 0, 0)
    text:SetText("|cffbbbbbb[" .. label .. "]|r")
    button:SetScript("OnEnter", function(self)
        text:SetText("|cff3FC7EB[" .. label .. "]|r")
        if GameTooltip and tooltipTitle then
            GameTooltip:SetOwner(self, "ANCHOR_LEFT")
            GameTooltip:SetText(tooltipTitle, 1, 1, 1)
            if tooltipBody then
                GameTooltip:AddLine(" ")
                GameTooltip:AddLine(tooltipBody, 0.8, 0.8, 0.8, true)
            end
            GameTooltip:Show()
        end
    end)
    button:SetScript("OnLeave", function()
        text:SetText("|cffbbbbbb[" .. label .. "]|r")
        if GameTooltip then
            GameTooltip:Hide()
        end
    end)
    button:SetScript("OnClick", onClick)
    return button
end

overlay.EnsurePlayerRunCompactFrame = function(playerRunFrame)
    if not playerRunFrame or playerRunFrame.peeCompactReady or not CreateFrame or not UIParent then
        return
    end

    if playerRunFrame.compactFrame and not playerRunFrame.compactFrame._peeOwned then
        SetDarkBackdrop(playerRunFrame.compactFrame, 4, 4)
        return
    end

    local compactFrame = CreateFrame("Frame", "PEEPlayerRunCompactFrame", UIParent)
    compactFrame._peeOwned = true
    SetFrameSize(compactFrame, 170, 110)
    compactFrame:SetPoint("TOPRIGHT", UIParent, "TOPRIGHT", -90, -200)
    compactFrame:SetFrameStrata("MEDIUM")
    compactFrame:SetMovable(true)
    compactFrame:EnableMouse(true)
    compactFrame:SetClampedToScreen(true)
    compactFrame:RegisterForDrag("LeftButton")
    SetDarkBackdrop(compactFrame, 4, 4)
    compactFrame:Hide()
    compactFrame:SetScript("OnDragStart", function(self)
        self:StartMoving()
    end)
    compactFrame:SetScript("OnDragStop", function(self)
        self:StopMovingOrSizing()
        local point, _, relativePoint, xOffset, yOffset = self:GetPoint()
        overlay.GetPlayerRunCompactStore().position = {
            point = point,
            relativePoint = relativePoint,
            x = xOffset,
            y = yOffset
        }
    end)

    local store = overlay.GetPlayerRunCompactStore()
    if type(store.position) == "table" then
        compactFrame:ClearAllPoints()
        compactFrame:SetPoint(
            store.position.point or "CENTER",
            UIParent,
            store.position.relativePoint or "CENTER",
            store.position.x or 0,
            store.position.y or 0
        )
    end

    playerRunFrame.compactFrame = compactFrame

    local restoreButton = CreateFrame("Button", nil, compactFrame)
    SetFrameSize(restoreButton, 16, 16)
    restoreButton:SetPoint("TOPRIGHT", compactFrame, "TOPRIGHT", -4, -4)
    restoreButton:SetFrameLevel(compactFrame:GetFrameLevel() + 5)
    local restoreText = overlay.CreatePlayerRunCompactText(restoreButton, 12, "OUTLINE")
    restoreText:SetPoint("CENTER", restoreButton, "CENTER", 0, 1)
    restoreText:SetText("|cffbbbbbb+|r")
    restoreButton:SetScript("OnEnter", function()
        restoreText:SetText("|cffffffff+|r")
    end)
    restoreButton:SetScript("OnLeave", function()
        restoreText:SetText("|cffbbbbbb+|r")
    end)
    restoreButton:SetScript("OnClick", function()
        overlay.SetPlayerRunMinimized(playerRunFrame, false)
    end)
    compactFrame.restoreButton = restoreButton

    local hardmodeButton = CreateFrame("Button", "PEEPlayerRunCompactHardmodeButton", compactFrame)
    SetFrameSize(hardmodeButton, 80, 16)
    hardmodeButton:SetPoint("TOPLEFT", compactFrame, "TOPLEFT", 8, -8)
    if hardmodeButton.EnableMouse then
        hardmodeButton:EnableMouse(true)
    end
    if hardmodeButton.RegisterForClicks then
        hardmodeButton:RegisterForClicks("LeftButtonUp")
    end
    if hardmodeButton.SetFrameLevel and compactFrame.GetFrameLevel then
        hardmodeButton:SetFrameLevel(compactFrame:GetFrameLevel() + 55)
    end
    local hardmodeSkull = hardmodeButton:CreateTexture(nil, "ARTWORK")
    SetFrameSize(hardmodeSkull, 14, 14)
    hardmodeSkull:SetPoint("LEFT", hardmodeButton, "LEFT", 0, 0)
    hardmodeSkull:SetTexture("Interface\\TargetingFrame\\UI-TargetingFrame-Skull")
    local hardmodeText = overlay.CreatePlayerRunCompactText(hardmodeButton, 10, "OUTLINE")
    hardmodeText:SetPoint("LEFT", hardmodeSkull, "RIGHT", 3, 0)
    hardmodeText:SetText(overlay.GetPlayerRunHardmodeText(playerRunFrame, false))
    compactFrame.hardmodeText = hardmodeText
    hardmodeButton:SetScript("OnClick", function()
        if overlay.ToggleHardmodeFrameFromPEE then
            overlay.ToggleHardmodeFrameFromPEE()
        end
    end)
    compactFrame.hardmodeButton = hardmodeButton

    local reaperIcon = compactFrame:CreateTexture(nil, "OVERLAY")
    SetFrameSize(reaperIcon, 18, 18)
    reaperIcon:SetTexture("Interface\\AddOns\\ProjectEbonholdEnhanced\\assets\\texture_ui")
    reaperIcon:SetTexCoord(0.121094, 0.214844, 0.898438, 0.996094)
    reaperIcon:SetPoint("TOPRIGHT", restoreButton, "TOPLEFT", -4, -2)
    compactFrame.reaperIcon = reaperIcon
    local reaperHitbox = CreateFrame("Button", nil, compactFrame)
    reaperHitbox:SetPoint("CENTER", reaperIcon, "CENTER", 0, 0)
    SetFrameSize(reaperHitbox, 20, 20)
    reaperHitbox:SetScript("OnEnter", function(self)
        if GameTooltip then
            GameTooltip:SetOwner(self, "ANCHOR_LEFT")
            GameTooltip:SetText("Reaper", 1, 0.5, 0.5)
            GameTooltip:AddLine("Shows current Reaper status from the server run data.", 0.8, 0.8, 0.8, true)
            GameTooltip:Show()
        end
    end)
    reaperHitbox:SetScript("OnLeave", function()
        if GameTooltip then
            GameTooltip:Hide()
        end
    end)

    local hearthIcon = compactFrame:CreateTexture(nil, "OVERLAY")
    SetFrameSize(hearthIcon, 18, 18)
    hearthIcon:SetTexture("Interface\\AddOns\\ProjectEbonholdEnhanced\\assets\\texture_ui")
    hearthIcon:SetTexCoord(0.316406, 0.398438, 0.898438, 0.988281)
    hearthIcon:SetPoint("TOPRIGHT", reaperIcon, "TOPLEFT", -4, 0)
    local hearthHitbox = CreateFrame("Button", nil, compactFrame)
    hearthHitbox:SetPoint("CENTER", hearthIcon, "CENTER", 0, 0)
    SetFrameSize(hearthHitbox, 20, 20)
    hearthHitbox:SetScript("OnEnter", function(self)
        if GameTooltip then
            local data = playerRunFrame.currentData or {}
            GameTooltip:SetOwner(self, "ANCHOR_LEFT")
            GameTooltip:SetText("Survival", 1, 1, 0.5)
            GameTooltip:AddLine("Player resurrections: " .. (data.countCanAcceptedRezs or 0), 1, 1, 1)
            GameTooltip:AddLine("Free resurrections: " .. (data.countCanSelfRezs or 0), 1, 1, 1)
            GameTooltip:AddLine("Class resurrections: " .. (data.countCanClassRezs or 0), 1, 1, 1)
            GameTooltip:Show()
        end
    end)
    hearthHitbox:SetScript("OnLeave", function()
        if GameTooltip then
            GameTooltip:Hide()
        end
    end)

    local ashIcon = compactFrame:CreateTexture(nil, "OVERLAY")
    SetFrameSize(ashIcon, 14, 14)
    ashIcon:SetTexture("Interface\\Icons\\inv_soulash")
    ashIcon:SetPoint("TOPLEFT", compactFrame, "TOPLEFT", 8, -30)
    local ashCount = overlay.CreatePlayerRunCompactText(compactFrame, 11, "OUTLINE")
    ashCount:SetPoint("LEFT", ashIcon, "RIGHT", 4, 0)
    ashCount:SetText("0")
    compactFrame.ashCount = ashCount
    local multiplier = overlay.CreatePlayerRunCompactText(compactFrame, 10, "OUTLINE")
    multiplier:SetPoint("LEFT", ashCount, "RIGHT", 6, 0)
    multiplier:SetText("|cff00ff00+0%|r")
    compactFrame.multiplier = multiplier

    local timerText = overlay.CreatePlayerRunCompactText(compactFrame, 10, nil)
    timerText:SetTextColor(0.5, 0.5, 0.5, 1)
    timerText:SetJustifyH("RIGHT")
    if timerText.SetWidth then
        timerText:SetWidth(48)
    end
    timerText:SetPoint("TOPRIGHT", compactFrame, "TOPRIGHT", -8, -46)
    timerText:SetText("")
    compactFrame.timerText = timerText

    local ashRate = overlay.CreatePlayerRunCompactText(compactFrame, 10, nil)
    ashRate:SetPoint("TOPLEFT", compactFrame, "TOPLEFT", 8, -46)
    ashRate:SetText("|cff888888tracking...|r")
    compactFrame.ashRate = ashRate
    local ashReset = CreateFrame("Button", nil, compactFrame)
    SetFrameSize(ashReset, 14, 14)
    ashReset:SetPoint("LEFT", ashRate, "RIGHT", 4, 0)
    local ashResetText = overlay.CreatePlayerRunCompactText(ashReset, 10, "OUTLINE")
    ashResetText:SetPoint("CENTER", ashReset, "CENTER", 0, 0)
    ashResetText:SetText("|cff888888x|r")
    ashReset:SetScript("OnEnter", function()
        ashResetText:SetText("|cff3FC7EBx|r")
    end)
    ashReset:SetScript("OnLeave", function()
        ashResetText:SetText("|cff888888x|r")
    end)
    ashReset:SetScript("OnClick", function()
        overlay.ResetPlayerRunAshTracker(playerRunFrame)
        overlay.RefreshPlayerRunCompact(playerRunFrame)
    end)
    compactFrame.ashResetButton = ashReset

    local goldRate = overlay.CreatePlayerRunCompactText(compactFrame, 10, nil)
    goldRate:SetPoint("TOPLEFT", ashRate, "BOTTOMLEFT", 0, -4)
    goldRate:SetText("|cff888888tracking...|r")
    compactFrame.goldRate = goldRate
    local goldReset = CreateFrame("Button", nil, compactFrame)
    SetFrameSize(goldReset, 14, 14)
    goldReset:SetPoint("LEFT", goldRate, "RIGHT", 4, 0)
    local goldResetText = overlay.CreatePlayerRunCompactText(goldReset, 10, "OUTLINE")
    goldResetText:SetPoint("CENTER", goldReset, "CENTER", 0, 0)
    goldResetText:SetText("|cff888888x|r")
    goldReset:SetScript("OnEnter", function()
        goldResetText:SetText("|cff3FC7EBx|r")
    end)
    goldReset:SetScript("OnLeave", function()
        goldResetText:SetText("|cff888888x|r")
    end)
    goldReset:SetScript("OnClick", function()
        overlay.ResetPlayerRunGoldTracker(playerRunFrame)
        overlay.RefreshPlayerRunCompact(playerRunFrame)
    end)
    compactFrame.goldResetButton = goldReset

    local intensityText = overlay.CreatePlayerRunCompactText(compactFrame, 10, nil)
    intensityText:SetPoint("TOPLEFT", goldRate, "BOTTOMLEFT", 0, -4)
    intensityText:SetText("|cff888888Intensity: 0|r")
    compactFrame.intensityText = intensityText

    local shortcutRow = CreateFrame("Frame", nil, compactFrame)
    SetFrameSize(shortcutRow, 84, 14)
    shortcutRow:SetPoint("BOTTOM", compactFrame, "BOTTOM", 0, 8)
    compactFrame.shortcutRow = shortcutRow

    local echoesButton = overlay.CreatePlayerRunCompactShortcut(compactFrame, "E", function()
        local project = _G and _G.ProjectEbonhold
        local playerRunUI = project and project.PlayerRunUI
        if playerRunUI and playerRunUI.ToggleEmpowerment then
            playerRunUI.ToggleEmpowerment()
        end
    end, "Echoes", "Open the Echoes panel.")
    echoesButton:ClearAllPoints()
    echoesButton:SetPoint("LEFT", shortcutRow, "LEFT", 0, 0)
    compactFrame.echoesButton = echoesButton

    local browserButton = overlay.CreatePlayerRunCompactShortcut(compactFrame, "EB", function()
        local project = _G and _G.ProjectEbonhold
        local perkBrowser = project and project.PerkBrowser
        if perkBrowser and perkBrowser.Toggle then
            perkBrowser.Toggle()
        end
    end, "Echo Browser", "Open the Echo Browser.")
    browserButton:ClearAllPoints()
    browserButton:SetPoint("LEFT", echoesButton, "RIGHT", 28, 0)
    compactFrame.browserButton = browserButton

    local minimizeButton = CreateFrame("Button", nil, playerRunFrame)
    SetFrameSize(minimizeButton, 34, 14)
    minimizeButton:SetPoint("TOPRIGHT", playerRunFrame, "TOPRIGHT", -4, -4)
    minimizeButton:SetFrameLevel(playerRunFrame:GetFrameLevel() + 25)
    if minimizeButton.SetBackdrop then
        minimizeButton:SetBackdrop(nil)
    end
    local minimizeText = overlay.CreatePlayerRunCompactText(minimizeButton, 8, "OUTLINE")
    minimizeText:SetPoint("CENTER", minimizeButton, "CENTER", 0, 0)
    minimizeText:SetText("|cffbbbbbb[Mini]|r")
    minimizeButton:SetScript("OnEnter", function()
        minimizeText:SetText(playerRunFrame._peeMinimized and "|cffffffff[Show]|r" or "|cffffffff[Mini]|r")
    end)
    minimizeButton:SetScript("OnLeave", function()
        minimizeText:SetText(playerRunFrame._peeMinimized and "|cffbbbbbb[Show]|r" or "|cffbbbbbb[Mini]|r")
    end)
    minimizeButton:SetScript("OnClick", function()
        overlay.SetPlayerRunMinimized(playerRunFrame, not playerRunFrame._peeMinimized)
    end)
    playerRunFrame.peeMinimizeButton = minimizeButton
    playerRunFrame.peeMinimizeText = minimizeText

    playerRunFrame.RefreshCompact = function()
        overlay.RefreshPlayerRunCompact(playerRunFrame)
    end
    playerRunFrame.SetMinimized = function(minimized)
        overlay.SetPlayerRunMinimized(playerRunFrame, minimized)
    end
    playerRunFrame.peeCompactReady = true

    if C_Timer and C_Timer.After then
        C_Timer.After(0.5, function()
            if overlay.GetPlayerRunCompactStore().minimized then
                overlay.SetPlayerRunMinimized(playerRunFrame, true)
            end
        end)
    elseif store.minimized then
        overlay.SetPlayerRunMinimized(playerRunFrame, true)
    end
end

overlay.LayoutPlayerRunHeader = function(playerRunFrame)
    if not playerRunFrame then
        return
    end

    local headerFrame = playerRunFrame.headerFrame
    if not headerFrame and playerRunFrame.timerText and playerRunFrame.timerText.GetParent then
        headerFrame = playerRunFrame.timerText:GetParent()
    end
    if not headerFrame then
        return
    end

    if playerRunFrame.peeMinimizeButton then
        SetFrameSize(playerRunFrame.peeMinimizeButton, 34, 14)
        if playerRunFrame.peeMinimizeButton.ClearAllPoints then
            playerRunFrame.peeMinimizeButton:ClearAllPoints()
        end
        if playerRunFrame.peeMinimizeButton.SetPoint then
            playerRunFrame.peeMinimizeButton:SetPoint("TOPRIGHT", headerFrame, "TOPRIGHT", 0, 4)
        end
    end

    local hardmodeButton = playerRunFrame.hardmodeButton
    if not hardmodeButton and playerRunFrame.hardmodeTierText and playerRunFrame.hardmodeTierText.GetParent then
        hardmodeButton = playerRunFrame.hardmodeTierText:GetParent()
    end
    if hardmodeButton then
        SetFrameSize(hardmodeButton, 120, 16)
        if hardmodeButton.ClearAllPoints then
            hardmodeButton:ClearAllPoints()
        end
        if hardmodeButton.SetPoint then
            hardmodeButton:SetPoint("TOPLEFT", headerFrame, "TOPLEFT", 0, 4)
        end
    elseif playerRunFrame.hardmodeTierText then
        if playerRunFrame.hardmodeTierText.ClearAllPoints then
            playerRunFrame.hardmodeTierText:ClearAllPoints()
        end
        if playerRunFrame.hardmodeTierText.SetPoint then
            playerRunFrame.hardmodeTierText:SetPoint("TOPLEFT", headerFrame, "TOPLEFT", 18, 2)
        end
    end

    if playerRunFrame.soulAshIcon then
        SetFrameSize(playerRunFrame.soulAshIcon, 16, 16)
        if playerRunFrame.soulAshIcon.ClearAllPoints then
            playerRunFrame.soulAshIcon:ClearAllPoints()
        end
        if playerRunFrame.soulAshIcon.SetPoint then
            playerRunFrame.soulAshIcon:SetPoint("TOPLEFT", headerFrame, "TOPLEFT", 0, -18)
        end
    end

    if playerRunFrame.soulPointsText and playerRunFrame.soulAshIcon then
        if playerRunFrame.soulPointsText.ClearAllPoints then
            playerRunFrame.soulPointsText:ClearAllPoints()
        end
        if playerRunFrame.soulPointsText.SetPoint then
            playerRunFrame.soulPointsText:SetPoint("LEFT", playerRunFrame.soulAshIcon, "RIGHT", 8, 0)
        end
    end

    if playerRunFrame.multiplierText and playerRunFrame.soulPointsText then
        if playerRunFrame.multiplierText.ClearAllPoints then
            playerRunFrame.multiplierText:ClearAllPoints()
        end
        if playerRunFrame.multiplierText.SetPoint then
            playerRunFrame.multiplierText:SetPoint("LEFT", playerRunFrame.soulPointsText, "RIGHT", 14, 0)
        end
    end

    if playerRunFrame.catchupText and playerRunFrame.multiplierText then
        if playerRunFrame.catchupText.ClearAllPoints then
            playerRunFrame.catchupText:ClearAllPoints()
        end
        if playerRunFrame.catchupText.SetPoint then
            playerRunFrame.catchupText:SetPoint("LEFT", playerRunFrame.multiplierText, "RIGHT", 6, 0)
        end
    end

    if playerRunFrame.reaperIcon then
        SetFrameSize(playerRunFrame.reaperIcon, 18, 18)
        if playerRunFrame.reaperIcon.ClearAllPoints then
            playerRunFrame.reaperIcon:ClearAllPoints()
        end
        if playerRunFrame.reaperIcon.SetPoint then
            playerRunFrame.reaperIcon:SetPoint("TOPRIGHT", headerFrame, "TOPRIGHT", 0, -18)
        end
    end

    if playerRunFrame.hearthIcon then
        SetFrameSize(playerRunFrame.hearthIcon, 18, 18)
        if playerRunFrame.hearthIcon.ClearAllPoints then
            playerRunFrame.hearthIcon:ClearAllPoints()
        end
        if playerRunFrame.hearthIcon.SetPoint then
            if playerRunFrame.reaperIcon then
                playerRunFrame.hearthIcon:SetPoint("RIGHT", playerRunFrame.reaperIcon, "LEFT", -4, 0)
            else
                playerRunFrame.hearthIcon:SetPoint("TOPRIGHT", headerFrame, "TOPRIGHT", -44, 0)
            end
        end
    end

    if playerRunFrame.timerText then
        if playerRunFrame.timerText.ClearAllPoints then
            playerRunFrame.timerText:ClearAllPoints()
        end
        if playerRunFrame.timerText.SetWidth then
            playerRunFrame.timerText:SetWidth(48)
        end
        if playerRunFrame.timerText.SetJustifyH then
            playerRunFrame.timerText:SetJustifyH("RIGHT")
        end
        if playerRunFrame.timerText.SetPoint then
            playerRunFrame.timerText:SetPoint("TOPRIGHT", headerFrame, "TOPRIGHT", -2, -36)
        end
    end

    if playerRunFrame.ashRateText then
        if playerRunFrame.ashRateText.ClearAllPoints then
            playerRunFrame.ashRateText:ClearAllPoints()
        end
        if playerRunFrame.ashRateText.SetPoint then
            playerRunFrame.ashRateText:SetPoint("TOPLEFT", headerFrame, "TOPLEFT", 0, -36)
        end
    end

    if playerRunFrame.ashResetBtn and playerRunFrame.ashRateText then
        if playerRunFrame.ashResetBtn.ClearAllPoints then
            playerRunFrame.ashResetBtn:ClearAllPoints()
        end
        if playerRunFrame.ashResetBtn.SetPoint then
            playerRunFrame.ashResetBtn:SetPoint("LEFT", playerRunFrame.ashRateText, "RIGHT", 4, 0)
        end
    end

    if playerRunFrame.reaperHitbox and playerRunFrame.reaperIcon then
        SetFrameSize(playerRunFrame.reaperHitbox, 20, 20)
        if playerRunFrame.reaperHitbox.ClearAllPoints then
            playerRunFrame.reaperHitbox:ClearAllPoints()
        end
        if playerRunFrame.reaperHitbox.SetPoint then
            playerRunFrame.reaperHitbox:SetPoint("CENTER", playerRunFrame.reaperIcon, "CENTER", 0, 0)
        end
    end

    if playerRunFrame.hearthHitbox and playerRunFrame.hearthIcon then
        SetFrameSize(playerRunFrame.hearthHitbox, 20, 20)
        if playerRunFrame.hearthHitbox.ClearAllPoints then
            playerRunFrame.hearthHitbox:ClearAllPoints()
        end
        if playerRunFrame.hearthHitbox.SetPoint then
            playerRunFrame.hearthHitbox:SetPoint("CENTER", playerRunFrame.hearthIcon, "CENTER", 0, 0)
        end
    end
end

local function ApplyPlayerRunTheme()
    if not overlay.enabled or overlay.isPTR then
        return
    end

    local playerRunFrame = _G and _G.ProjectEbonholdPlayerRunFrame
    if playerRunFrame then
        SetDarkBackdrop(playerRunFrame, 4, 4)

        local collapseButton = playerRunFrame.collapseBtn
        if collapseButton then
            SetFrameBackdrop(collapseButton, 2, 2)
            if collapseButton.SetBackdropColor then
                collapseButton:SetBackdropColor(0.2, 0.5, 0.2, GetBackdropOpacity())
            end
            if collapseButton.SetBackdropBorderColor then
                collapseButton:SetBackdropBorderColor(BLACK[1], BLACK[2], BLACK[3], 1)
            end
        end

        local empowermentHeader = playerRunFrame.empowermentHeader
        if empowermentHeader then
            SetDarkBackdrop(empowermentHeader, 4, 4)
            if playerRunFrame.empowermentText then
                playerRunFrame.empowermentText:SetTextColor(1, 1, 1, 1)
            end
            empowermentHeader:SetScript("OnEnter", function(self)
                if self.SetBackdropColor then
                    self:SetBackdropColor(
                        HOVER_BLUE_BACKDROP[1],
                        HOVER_BLUE_BACKDROP[2],
                        HOVER_BLUE_BACKDROP[3],
                        GetBackdropOpacity()
                    )
                end
                if self.SetBackdropBorderColor then
                    self:SetBackdropBorderColor(HOVER_BLUE[1], HOVER_BLUE[2], HOVER_BLUE[3], 1)
                end

                if playerRunFrame.empowermentText then
                    playerRunFrame.empowermentText:SetTextColor(1, 1, 1, 1)
                end
            end)
            empowermentHeader:SetScript("OnLeave", function(self)
                if self.SetBackdropColor then
                    self:SetBackdropColor(DARK[1], DARK[2], DARK[3], GetBackdropOpacity())
                end
                if self.SetBackdropBorderColor then
                    self:SetBackdropBorderColor(BLACK[1], BLACK[2], BLACK[3], 1)
                end

                if playerRunFrame.empowermentText then
                    playerRunFrame.empowermentText:SetTextColor(1, 1, 1, 1)
                end
            end)
        end

        local compactFrame = playerRunFrame.compactFrame or (_G and _G.ProjectEbonholdPlayerRunCompactFrame)
        if compactFrame then
            SetDarkBackdrop(compactFrame, 4, 4)
            if overlay.ApplyCompactTooltipExtras then
                overlay.ApplyCompactTooltipExtras(playerRunFrame)
            end
        end

        overlay.EnsurePlayerRunTrackers(playerRunFrame)
        overlay.EnsurePlayerRunCompactFrame(playerRunFrame)
        if overlay.ApplyCompactTooltipExtras then
            overlay.ApplyCompactTooltipExtras(playerRunFrame)
        end
        overlay.LayoutPlayerRunHeader(playerRunFrame)
        overlay.SyncPlayerRunHardmodeLabels(playerRunFrame, false)
        overlay.UpdatePlayerRunTrackerText(playerRunFrame)
    end

    local empowermentFrame = _G and _G.ProjectEbonholdEmpowermentFrame
    if empowermentFrame then
        SetDarkBackdrop(empowermentFrame, 4, 4)

        if empowermentFrame.searchFrame then
            SetDarkBackdrop(empowermentFrame.searchFrame, 2, 2)
        end

        overlay.EnsureEchoExportButton(empowermentFrame)

        local iconCount = type(empowermentFrame.perkIcons) == "table" and #empowermentFrame.perkIcons or 0
        if iconCount > 0 then
            empowermentFrame._peeEmptyEchoRefreshAt = nil
        elseif empowermentFrame.IsShown and empowermentFrame:IsShown() then
            overlay.RefreshGrantedPerksForEmpowerment(empowermentFrame)
        end
        overlay.ApplyGrantedPerkFallbackVisuals(empowermentFrame)
    end

    overlay.ApplyPermanentEchoSelectorSearch()
end

overlay.ApplyPlayerRunTheme = ApplyPlayerRunTheme

local function RefreshPlayerRunTheme()
    if overlay.ApplyPlayerRunTheme then
        overlay.ApplyPlayerRunTheme()
    else
        ApplyPlayerRunTheme()
    end
end

local function WrapPlayerRunFunction(playerRunUI, functionName)
    local original = playerRunUI and playerRunUI[functionName]
    if type(original) ~= "function" or playerRunUI["_peeWrapped" .. functionName] then
        return
    end

    playerRunUI["_peeWrapped" .. functionName] = true
    playerRunUI[functionName] = function(...)
        local a, b, c = original(...)
        RefreshPlayerRunTheme()
        return a, b, c
    end
end

local function InstallPlayerRunThemeHooks()
    if not overlay.enabled or overlay.isPTR then
        return
    end

    local playerRunUI = _G and _G.ProjectEbonhold and _G.ProjectEbonhold.PlayerRunUI
    if not playerRunUI then
        return
    end

    WrapPlayerRunFunction(playerRunUI, "UpdateData")
    WrapPlayerRunFunction(playerRunUI, "Toggle")
    WrapPlayerRunFunction(playerRunUI, "ToggleEmpowerment")
    WrapPlayerRunFunction(playerRunUI, "UpdateGrantedPerks")
    WrapPlayerRunFunction(playerRunUI, "UpdateIntensity")
    WrapPlayerRunFunction(playerRunUI, "UpdateHardmodeText")

    if overlay.EnsurePermanentEchoSelectorWatcher then
        overlay.EnsurePermanentEchoSelectorWatcher()
    end
    RefreshPlayerRunTheme()
end

overlay.InstallPlayerRunThemeHooks = InstallPlayerRunThemeHooks

local BROWSER_QUALITY_COLORS = {
    [-1] = {1.0, 1.0, 1.0},
    [0] = {1.0, 1.0, 1.0},
    [1] = {0.1, 1.0, 0.1},
    [2] = {0.0, 0.4, 1.0},
    [3] = {0.8, 0.4, 1.0},
    [4] = {1.0, 0.5, 0.0},
}

overlay.ClampColorComponent = function(value)
    if value < 0 then
        return 0
    end
    if value > 1 then
        return 1
    end
    return math.floor(value * 1000 + 0.5) / 1000
end

overlay.ScaleColor = function(color, scale, floor)
    return {
        overlay.ClampColorComponent((color[1] or 0) * scale + (floor or 0)),
        overlay.ClampColorComponent((color[2] or 0) * scale + (floor or 0)),
        overlay.ClampColorComponent((color[3] or 0) * scale + (floor or 0))
    }
end

overlay.GetQualityColor = function(quality)
    return BROWSER_QUALITY_COLORS[quality] or BROWSER_QUALITY_COLORS[0]
end

local function ConfigurePerkBrowserText(fontString, size, color, width, justifyH)
    if not fontString then
        return
    end

    if fontString.SetFont then
        fontString:SetFont("Fonts\\FRIZQT__.TTF", ScaledFontSize(size), "OUTLINE")
    end

    if width and fontString.SetWidth then
        fontString:SetWidth(width)
    end

    if fontString.SetWordWrap then
        fontString:SetWordWrap(true)
    end

    if fontString.SetNonSpaceWrap then
        fontString:SetNonSpaceWrap(false)
    end

    if justifyH and fontString.SetJustifyH then
        fontString:SetJustifyH(justifyH)
    end

    if color and fontString.SetTextColor then
        fontString:SetTextColor(color[1], color[2], color[3], 1)
    end
end

local function GetPerkBrowserText(fontString)
    if not fontString then
        return nil
    end

    if fontString.GetText then
        return fontString:GetText()
    end

    return fontString.text
end

local function ForEachChildFrame(frame, callback)
    if not frame or not frame.GetChildren then
        return
    end

    local children = { frame:GetChildren() }
    for _, child in ipairs(children) do
        callback(child)
        ForEachChildFrame(child, callback)
    end
end

local function ForEachDirectChildFrame(frame, callback)
    if not frame or not frame.GetChildren then
        return
    end

    local children = { frame:GetChildren() }
    for _, child in ipairs(children) do
        callback(child)
    end
end

local function ForEachFrameRegion(frame, callback)
    if not frame or not frame.GetRegions then
        return
    end

    local regions = { frame:GetRegions() }
    for _, region in ipairs(regions) do
        callback(region)
    end
end

local function IsLikelyEditBox(frame)
    return frame and (
        type(frame.SetAutoFocus) == "function" or
        type(frame.SetMaxLetters) == "function" or
        type(frame.ClearFocus) == "function"
    )
end

local function FindEditBoxChild(frame)
    if not frame or not frame.GetChildren then
        return nil
    end

    local children = { frame:GetChildren() }
    for _, child in ipairs(children) do
        if IsLikelyEditBox(child) then
            return child
        end
    end

    return nil
end

overlay.UpdatePerkBrowserSearchClearButton = function(editBox)
    local clearButton = editBox and editBox._peeBrowserSearchClearButton
    if not clearButton then
        return
    end

    local text = editBox.GetText and editBox:GetText() or ""
    if text == "" then
        clearButton:Hide()
    else
        clearButton:Show()
    end
end

overlay.NormalizePerkBrowserSearch = function(value)
    return tostring(value or ""):lower():gsub("^%s+", ""):gsub("%s+$", "")
end

overlay.PerkBrowserSearchMatchesCard = function(card)
    local searchText = overlay.NormalizePerkBrowserSearch(overlay.perkBrowserSearchText)
    if searchText == "" then
        return true
    end

    if not card or not card.spellId then
        return false
    end

    if card._peeSearchSpellId ~= card.spellId then
        local spellName = GetSpellInfo and GetSpellInfo(card.spellId)
        card._peeSearchSpellId = card.spellId
        card._peeSearchName = spellName and spellName:lower() or ""
        card._peeSearchDescription = nil
    end

    if card._peeSearchName and card._peeSearchName:find(searchText, 1, true) then
        return true
    end

    local perkData = card.perkData
    if perkData and perkData.comment and tostring(perkData.comment):lower():find(searchText, 1, true) then
        return true
    end

    local utilsTable = _G and _G.utils
    if #searchText >= 3 and utilsTable and utilsTable.GetSpellDescription then
        if not card._peeSearchDescription then
            local ok, description = pcall(utilsTable.GetSpellDescription, card.spellId, 500,
                (perkData and perkData.maxStack) or 1)
            card._peeSearchDescription = ok and description and tostring(description):lower() or ""
        end
        if card._peeSearchDescription:find(searchText, 1, true) then
            return true
        end
    end

    return false
end

overlay.EnsurePerkBrowserSearchClearButton = function(editBox)
    local createFrame = _G and _G.CreateFrame
    if not editBox or not createFrame then
        return
    end

    if not editBox._peeBrowserSearchClearButton then
        local clearButton = createFrame("Button", nil, editBox)
        SetFrameSize(clearButton, 14, 14)
        clearButton:SetPoint("RIGHT", editBox, "RIGHT", -4, 0)
        if clearButton.SetFrameLevel and editBox.GetFrameLevel then
            clearButton:SetFrameLevel((editBox:GetFrameLevel() or 1) + 1)
        end

        clearButton.text = clearButton:CreateFontString(nil, "OVERLAY")
        clearButton.text:SetFont("Fonts\\FRIZQT__.TTF", ScaledFontSize(12), "OUTLINE")
        clearButton.text:SetPoint("CENTER", clearButton, "CENTER", 0, 0)
        clearButton.text:SetText("X")
        clearButton.text:SetTextColor(0.7, 0.7, 0.7, 1)

        clearButton:SetScript("OnEnter", function(self)
            self.text:SetTextColor(1, 0.4, 0.4, 1)
        end)
        clearButton:SetScript("OnLeave", function(self)
            self.text:SetTextColor(0.7, 0.7, 0.7, 1)
        end)
        clearButton:SetScript("OnClick", function()
            if editBox.SetText then
                editBox:SetText("")
            end
            if editBox.ClearFocus then
                editBox:ClearFocus()
            end

            local onTextChanged = editBox.GetScript and editBox:GetScript("OnTextChanged")
            if type(onTextChanged) == "function" then
                onTextChanged(editBox)
            end
            overlay.UpdatePerkBrowserSearchClearButton(editBox)
        end)

        editBox._peeBrowserSearchClearButton = clearButton
    end

    if editBox.GetScript and editBox.SetScript and not editBox._peeBrowserSearchClearWrapper then
        editBox._peeBrowserSearchClearWrapper = function(self)
            local searchText = self.GetText and self:GetText() or ""
            overlay.perkBrowserSearchText = searchText
            overlay.UpdatePerkBrowserSearchClearButton(self)

            self._peeBrowserSearchToken = (self._peeBrowserSearchToken or 0) + 1
            local token = self._peeBrowserSearchToken

            local function refreshBrowserSearch()
                if token ~= self._peeBrowserSearchToken then
                    return
                end

                local normalized = overlay.NormalizePerkBrowserSearch(searchText)
                if normalized == "" and type(self._peeOriginalBrowserSearchChanged) == "function" then
                    self._peeOriginalBrowserSearchChanged(self)
                end
                overlay.ApplyPerkBrowserFamilyFilter(normalized == "")
                overlay.UpdatePerkBrowserSearchClearButton(self)
            end

            if searchText ~= "" and C_Timer and C_Timer.After then
                C_Timer.After(0.18, refreshBrowserSearch)
            else
                refreshBrowserSearch()
            end
        end
    end

    if editBox.GetScript and editBox.SetScript then
        local currentSearch = editBox:GetScript("OnTextChanged")
        if currentSearch ~= editBox._peeBrowserSearchClearWrapper then
            editBox._peeOriginalBrowserSearchChanged = currentSearch
            editBox:SetScript("OnTextChanged", editBox._peeBrowserSearchClearWrapper)
        end
    end

    overlay.UpdatePerkBrowserSearchClearButton(editBox)
end

local function SkinPerkBrowserSearchFrame(searchFrame, editBox)
    if not searchFrame then
        return
    end

    SetFrameBackdrop(searchFrame, 2, 2)
    if searchFrame.SetBackdropColor then
        searchFrame:SetBackdropColor(DARK[1], DARK[2], DARK[3], GetBackdropOpacity())
    end
    if searchFrame.SetBackdropBorderColor then
        searchFrame:SetBackdropBorderColor(BLACK[1], BLACK[2], BLACK[3], 1)
    end

    if editBox then
        if editBox.SetTextColor then
            editBox:SetTextColor(CREAM[1], CREAM[2], CREAM[3], 1)
        end
        if editBox.SetFont then
            editBox:SetFont("Fonts\\FRIZQT__.TTF", ScaledFontSize(11), "OUTLINE")
        end
        overlay.EnsurePerkBrowserSearchClearButton(editBox)
        if editBox._peeBrowserSearchHooks then
            return
        end

        local function onFocusGained()
            if searchFrame.SetBackdropBorderColor then
                searchFrame:SetBackdropBorderColor(HOVER_BLUE[1], HOVER_BLUE[2], HOVER_BLUE[3], 1)
            end
        end

        local function onFocusLost()
            if searchFrame.SetBackdropBorderColor then
                searchFrame:SetBackdropBorderColor(BLACK[1], BLACK[2], BLACK[3], 1)
            end
        end

        if editBox.HookScript then
            editBox:HookScript("OnEditFocusGained", onFocusGained)
            editBox:HookScript("OnEditFocusLost", onFocusLost)
            editBox._peeBrowserSearchHooks = true
        end
    end
end

overlay.browserDragCullingMetrics = {
    perksPerRow = 8,
    buttonSize = 38,
    buttonSpacing = 12,
    nameHeight = 18
}

overlay.perkBrowserFamilyLayout = {
    rowLeft = 30,
    rowRight = 30,
    noteTop = -90,
    rowTop = -104,
    iconTop = 0,
    iconSize = 28,
    qualityTop = -152,
    scrollTop = -187,
    scrollRight = -42,
    scrollBottom = 15
}

overlay.perkBrowserFamilyAsset = "Interface\\AddOns\\ProjectEbonholdEnhanced\\assets\\perk_families\\"

overlay.perkBrowserFamilyDefinitions = {
    { key = "Tank", label = "Tank", icon = overlay.perkBrowserFamilyAsset .. "tank", color = { 0.30, 0.60, 1.00 } },
    { key = "Healer", label = "Healer", icon = overlay.perkBrowserFamilyAsset .. "healer",
        color = { 0.40, 1.00, 0.40 } },
    { key = "Melee DPS", label = "Melee DPS", color = { 1.00, 0.40, 0.20 },
        icon = overlay.perkBrowserFamilyAsset .. "melee_dps" },
    { key = "Ranged DPS", label = "Ranged DPS", color = { 1.00, 0.70, 0.20 },
        icon = overlay.perkBrowserFamilyAsset .. "ranged_dps" },
    { key = "Caster DPS", label = "Caster DPS", color = { 0.80, 0.50, 1.00 },
        icon = overlay.perkBrowserFamilyAsset .. "caster_dps" },
    { key = "Survivability", label = "Survivability", color = { 0.60, 0.90, 0.50 },
        icon = overlay.perkBrowserFamilyAsset .. "survivability" },
    { key = "__unassigned", label = "Other (no role assigned)", icon = "Interface\\Icons\\INV_Misc_QuestionMark",
        color = { 0.75, 0.75, 0.75 } }
}

overlay.perkBrowserFamilyFilters = overlay.perkBrowserFamilyFilters or {}

overlay.EnsurePerkBrowserFamilyFilterDefaults = function()
    local filters = overlay.GetPerkBrowserFamilyFilters()
    if filters._initialized then
        return filters
    end

    local hasSavedValue = false
    for _, definition in ipairs(overlay.perkBrowserFamilyDefinitions) do
        if filters[definition.key] ~= nil then
            hasSavedValue = true
            break
        end
    end

    if not hasSavedValue then
        for _, definition in ipairs(overlay.perkBrowserFamilyDefinitions) do
            filters[definition.key] = true
        end
    end

    filters._initialized = true
    return filters
end

overlay.GetPerkBrowserFamilyFilters = function()
    if type(overlay.perkBrowserFamilyFilters) ~= "table" then
        overlay.perkBrowserFamilyFilters = {}
    end

    return overlay.perkBrowserFamilyFilters
end

overlay.GetPerkBrowserCardFamilies = function(card)
    local families = card and card.perkData and card.perkData.families
    if type(families) == "string" and families ~= "" then
        return { families }
    end

    if type(families) == "table" then
        local normalized = {}
        for _, family in ipairs(families) do
            if type(family) == "string" and family ~= "" then
                normalized[#normalized + 1] = family
            end
        end
        return normalized
    end

    return {}
end

overlay.PerkBrowserHasActiveFamilyFilters = function()
    local filters = overlay.EnsurePerkBrowserFamilyFilterDefaults()
    for _, definition in ipairs(overlay.perkBrowserFamilyDefinitions) do
        if filters[definition.key] then
            return true
        end
    end

    return false
end

overlay.PerkBrowserCardMatchesFamilyFilters = function(card)
    local filters = overlay.EnsurePerkBrowserFamilyFilterDefaults()
    local families = overlay.GetPerkBrowserCardFamilies(card)
    if #families == 0 then
        return filters.__unassigned == true
    end

    for _, family in ipairs(families) do
        if filters[family] then
            return true
        end
    end

    return false
end

overlay.GetPerkBrowserPlayerClassMask = function()
    local classToMask = {
        WARRIOR = 1,
        PALADIN = 2,
        HUNTER = 4,
        ROGUE = 8,
        PRIEST = 16,
        DEATHKNIGHT = 32,
        SHAMAN = 64,
        MAGE = 128,
        WARLOCK = 256,
        DRUID = 1024
    }

    local classToken
    if UnitClass then
        local _, token = UnitClass("player")
        classToken = token
    end
    return classToMask[classToken] or 0
end

overlay.BitAnd = function(left, right)
    local result = 0
    local bit = 1
    left = left or 0
    right = right or 0

    while left > 0 and right > 0 do
        local leftBit = left % 2
        local rightBit = right % 2
        if leftBit == 1 and rightBit == 1 then
            result = result + bit
        end
        left = (left - leftBit) / 2
        right = (right - rightBit) / 2
        bit = bit * 2
    end

    return result
end

overlay.PopCount = function(mask)
    local count = 0
    mask = mask or 0
    while mask > 0 do
        if mask % 2 == 1 then
            count = count + 1
        end
        mask = (mask - (mask % 2)) / 2
    end
    return count
end

overlay.BuildPerkBrowserGroupWinners = function(cards)
    local playerClassMask = overlay.GetPerkBrowserPlayerClassMask()
    local winners = {}

    for _, card in ipairs(cards) do
        if card and card._peeBrowserServerVisible ~= false and card.spellId and card.perkData then
            local groupId = card.perkData.groupId
            if groupId then
                local key = tostring(groupId) .. ":" .. tostring(card.perkData.quality or 0)
                local current = winners[key]
                local replace = false
                if not current then
                    replace = true
                else
                    local newIsPlayer = playerClassMask > 0 and
                        overlay.BitAnd(card.perkData.classMask or 0, playerClassMask) > 0
                    local oldIsPlayer = playerClassMask > 0 and
                        overlay.BitAnd(current.perkData.classMask or 0, playerClassMask) > 0
                    if newIsPlayer and not oldIsPlayer then
                        replace = true
                    elseif newIsPlayer == oldIsPlayer then
                        local newCoverage = overlay.PopCount(card.perkData.classMask or 0)
                        local oldCoverage = overlay.PopCount(current.perkData.classMask or 0)
                        if newCoverage > oldCoverage then
                            replace = true
                        elseif newCoverage == oldCoverage and (card.spellId or 0) < (current.spellId or 0) then
                            replace = true
                        end
                    end
                end

                if replace then
                    winners[key] = card
                end
            end
        end
    end

    return winners
end

overlay.BuildGroupedPerkBrowserDatabase = function(database)
    local playerClassMask = overlay.GetPerkBrowserPlayerClassMask()
    local buckets = {}
    local grouped = {}

    if type(database) ~= "table" then
        return grouped
    end

    for spellId, data in pairs(database) do
        if type(data) == "table" then
            local groupId = data.groupId
            if groupId then
                local key = tostring(groupId) .. ":" .. tostring(data.quality or 0)
                local current = buckets[key]
                local replace = false
                if not current then
                    replace = true
                else
                    local newIsPlayer = playerClassMask > 0 and overlay.BitAnd(data.classMask or 0, playerClassMask) > 0
                    local oldIsPlayer = playerClassMask > 0 and
                        overlay.BitAnd(current.data.classMask or 0, playerClassMask) > 0
                    if newIsPlayer and not oldIsPlayer then
                        replace = true
                    elseif newIsPlayer == oldIsPlayer then
                        local newCoverage = overlay.PopCount(data.classMask or 0)
                        local oldCoverage = overlay.PopCount(current.data.classMask or 0)
                        if newCoverage > oldCoverage then
                            replace = true
                        elseif newCoverage == oldCoverage and spellId < current.spellId then
                            replace = true
                        end
                    end
                end

                if replace then
                    buckets[key] = { spellId = spellId, data = data }
                end
            else
                grouped[spellId] = data
            end
        end
    end

    for _, entry in pairs(buckets) do
        grouped[entry.spellId] = entry.data
    end

    return grouped
end

overlay.ActivatePerkBrowserGroupedDatabase = function()
    local project = _G and _G.ProjectEbonhold
    local database = project and project.PerkDatabase
    if type(database) ~= "table" then
        return
    end

    if overlay._perkBrowserFullDatabase and database == overlay._perkBrowserGroupedDatabase then
        return
    end

    overlay._perkBrowserFullDatabase = database
    overlay._perkBrowserGroupedDatabase = overlay.BuildGroupedPerkBrowserDatabase(database)
    project.PerkDatabase = overlay._perkBrowserGroupedDatabase
end

overlay.RestorePerkBrowserDatabase = function()
    local project = _G and _G.ProjectEbonhold
    if not project or not overlay._perkBrowserFullDatabase then
        return
    end

    if project.PerkDatabase == overlay._perkBrowserGroupedDatabase then
        project.PerkDatabase = overlay._perkBrowserFullDatabase
    end

    overlay._perkBrowserFullDatabase = nil
    overlay._perkBrowserGroupedDatabase = nil
end

overlay.RefreshPerkBrowserFamilyButtonState = function(browserFrame)
    local row = browserFrame and browserFrame.peeFamilyFilterRow
    if not row or type(row.buttons) ~= "table" then
        return
    end

    local filters = overlay.EnsurePerkBrowserFamilyFilterDefaults()
    for _, button in ipairs(row.buttons) do
        local active = filters[button.familyKey] == true
        if button.SetBackdropColor then
            button:SetBackdropColor(0, 0, 0, 0)
        end
        if button.SetBackdropBorderColor then
            button:SetBackdropBorderColor(0, 0, 0, 0)
        end
        if button.SetAlpha then
            button:SetAlpha(active and 1 or 0.35)
        end
        if button.icon and button.icon.SetVertexColor then
            button.icon:SetVertexColor(1, 1, 1, 1)
        end
        if button.icon and button.icon.SetDesaturated then
            button.icon:SetDesaturated(not active)
        end
    end
end

local function EnsurePerkBrowserFamilyNote(browserFrame)
    if not browserFrame or not browserFrame.CreateFontString then
        return
    end

    local layout = overlay.perkBrowserFamilyLayout
    if not browserFrame.peeFamilyFilterNote then
        local note = browserFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        note:SetPoint("TOPLEFT", browserFrame, "TOPLEFT", layout.rowLeft, layout.noteTop)
        if note.SetWidth then
            note:SetWidth((browserFrame.GetWidth and browserFrame:GetWidth() or 470) - layout.rowLeft - layout.rowRight)
        end
        note:SetText("The filters show all class echoes. Check \"My Class Only\" to remove.")
        browserFrame.peeFamilyFilterNote = note
    end

    ConfigurePerkBrowserText(browserFrame.peeFamilyFilterNote, 11, {1, 0.82, 0},
        (browserFrame.GetWidth and browserFrame:GetWidth() or 470) - layout.rowLeft - layout.rowRight, "LEFT")
end

overlay.LayoutPerkBrowserFamilyFilters = function(browserFrame)
    if not browserFrame then
        return
    end

    local scrollFrame = _G and _G.PerkBrowserScrollFrame
    if not scrollFrame or not scrollFrame.SetPoint then
        return
    end

    local layout = overlay.perkBrowserFamilyLayout
    if scrollFrame.ClearAllPoints then
        scrollFrame:ClearAllPoints()
    end
    scrollFrame:SetPoint("TOPLEFT", browserFrame, "TOPLEFT", 25, layout.scrollTop)
    scrollFrame:SetPoint("BOTTOMRIGHT", browserFrame, "BOTTOMRIGHT", layout.scrollRight, layout.scrollBottom)
    scrollFrame._peeBrowserLayout = {
        top = layout.scrollTop,
        right = layout.scrollRight,
        bottom = layout.scrollBottom
    }
end

overlay.EnsurePerkBrowserFamilyFilterRow = function(browserFrame)
    local createFrame = _G and _G.CreateFrame
    if not browserFrame or not createFrame then
        return
    end

    EnsurePerkBrowserFamilyNote(browserFrame)

    if browserFrame.peeFamilyFilterRow then
        overlay.RefreshPerkBrowserFamilyButtonState(browserFrame)
        return
    end

    local layout = overlay.perkBrowserFamilyLayout
    local browserWidth = browserFrame.GetWidth and browserFrame:GetWidth() or 470
    local rowWidth = browserWidth - layout.rowLeft - layout.rowRight
    local definitions = overlay.perkBrowserFamilyDefinitions
    local iconCount = #definitions
    local iconSize = layout.iconSize
    local iconGap = 0
    if iconCount > 1 then
        iconGap = (rowWidth - (iconCount * iconSize)) / (iconCount - 1)
    end

    local row = createFrame("Frame", "PEEPerkBrowserFamilyFilters", browserFrame)
    SetFrameSize(row, rowWidth, layout.iconSize)
    row:SetPoint("TOPLEFT", browserFrame, "TOPLEFT", layout.rowLeft, layout.rowTop)
    row.buttons = {}

    for index, definition in ipairs(definitions) do
        local button = createFrame("Button", nil, row)
        SetFrameSize(button, iconSize, iconSize)
        button.familyKey = definition.key
        button.familyLabel = definition.label
        button.familyColor = definition.color or { 0.75, 0.75, 0.75 }
        local xOffset = math.floor((index - 1) * (iconSize + iconGap) + 0.5)
        button:SetPoint("TOPLEFT", row, "TOPLEFT", xOffset, layout.iconTop)
        SetFrameBackdrop(button, 1, 0)
        if button.SetBackdropColor then
            button:SetBackdropColor(0, 0, 0, 0)
        end
        if button.SetBackdropBorderColor then
            button:SetBackdropBorderColor(0, 0, 0, 0)
        end

        button.icon = button:CreateTexture(nil, "ARTWORK")
        button.icon:SetTexture(definition.icon)
        button.icon:SetTexCoord(0.07, 0.93, 0.07, 0.93)
        button.icon:SetPoint("TOPLEFT", button, "TOPLEFT", 2, -2)
        button.icon:SetPoint("BOTTOMRIGHT", button, "BOTTOMRIGHT", -2, 2)
        if button.icon.SetVertexColor then
            button.icon:SetVertexColor(1, 1, 1, 1)
        end

        local highlight = button:CreateTexture(nil, "HIGHLIGHT")
        highlight:SetAllPoints(button.icon)
        highlight:SetTexture("Interface\\Buttons\\ButtonHilight-Square")
        if highlight.SetBlendMode then
            highlight:SetBlendMode("ADD")
        end

        button:SetScript("OnClick", function(self)
            local filters = overlay.EnsurePerkBrowserFamilyFilterDefaults()
            filters[self.familyKey] = filters[self.familyKey] ~= true
            overlay.RefreshPerkBrowserFamilyButtonState(browserFrame)
            overlay.ApplyPerkBrowserFamilyFilter(false)
        end)
        button:SetScript("OnEnter", function(self)
            if self.SetAlpha then
                self:SetAlpha(1)
            end
            if GameTooltip then
                GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
                local familyColor = self.familyColor or WHITE
                GameTooltip:AddLine(self.familyLabel or "Role", familyColor[1], familyColor[2], familyColor[3])
                GameTooltip:AddLine("Click to toggle this role filter.", 0.8, 0.8, 0.8, true)
                GameTooltip:Show()
            end
        end)
        button:SetScript("OnLeave", function()
            overlay.RefreshPerkBrowserFamilyButtonState(browserFrame)
            if GameTooltip and GameTooltip.Hide then
                GameTooltip:Hide()
            end
        end)

        row.buttons[#row.buttons + 1] = button
    end

    browserFrame.peeFamilyFilterRow = row
    browserFrame._peeFamilyLayoutMath = {
        width = rowWidth,
        iconSize = iconSize,
        iconGap = iconGap,
        rowTop = layout.rowTop,
        iconTop = layout.iconTop,
        scrollTop = layout.scrollTop
    }
    overlay.RefreshPerkBrowserFamilyButtonState(browserFrame)
end

overlay.IsPerkBrowserCard = function(frame)
    return frame and (frame.spellId or frame.nameText or frame.borderFrame or frame.borderTex)
end

overlay.GetPerkBrowserCards = function()
    local scrollChild = _G and _G.PerkBrowserScrollChild
    if not scrollChild or not scrollChild.GetChildren then
        return {}
    end

    local cards = {}
    local children = { scrollChild:GetChildren() }
    for _, child in ipairs(children) do
        if overlay.IsPerkBrowserCard(child) then
            cards[#cards + 1] = child
        end
    end

    return cards
end

overlay.ApplyPerkBrowserFamilyFilter = function(serverRefreshed)
    local browserFrame = _G and _G.PerkBrowserFrame
    local scrollChild = _G and _G.PerkBrowserScrollChild
    if not browserFrame or not scrollChild then
        return
    end

    overlay.LayoutPerkBrowserFamilyFilters(browserFrame)

    local metrics = overlay.browserDragCullingMetrics
    local rowHeight = metrics.buttonSize + metrics.nameHeight + metrics.buttonSpacing
    local visibleIndex = 0
    local cards = overlay.GetPerkBrowserCards()
    local groupWinners = overlay.BuildPerkBrowserGroupWinners(cards)

    for _, card in ipairs(cards) do
        local shownByServer = not card.IsShown or card:IsShown()
        if serverRefreshed or card._peeBrowserServerVisible == nil then
            card._peeBrowserServerVisible = shownByServer
        end

        local eligible = card._peeBrowserServerVisible ~= false
        if eligible and card.perkData and card.perkData.groupId then
            local groupKey = tostring(card.perkData.groupId) .. ":" .. tostring(card.perkData.quality or 0)
            eligible = groupWinners[groupKey] == card
        end
        local matches = eligible and card.spellId ~= nil and
            overlay.PerkBrowserCardMatchesFamilyFilters(card) and overlay.PerkBrowserSearchMatchesCard(card)
        if matches then
            visibleIndex = visibleIndex + 1
            local row = math.floor((visibleIndex - 1) / metrics.perksPerRow)
            local column = (visibleIndex - 1) - (row * metrics.perksPerRow)
            if card.ClearAllPoints then
                card:ClearAllPoints()
            end
            if card.SetPoint then
                card:SetPoint(
                    "TOPLEFT",
                    scrollChild,
                    "TOPLEFT",
                    10 + column * (metrics.buttonSize + metrics.buttonSpacing),
                    -10 - row * rowHeight
                )
            end
            if card.Show then
                card:Show()
            end
            card._peeBrowserFamilyHidden = false
            card._peeBrowserVisibleIndex = visibleIndex
        else
            if card.Hide then
                card:Hide()
            end
            card._peeBrowserFamilyHidden = true
            card._peeBrowserVisibleIndex = nil
        end
    end

    if scrollChild.SetHeight then
        if visibleIndex == 0 then
            scrollChild:SetHeight(1)
        else
            local rowCount = math.ceil(visibleIndex / metrics.perksPerRow)
            scrollChild:SetHeight(rowCount * rowHeight + 35)
        end
    end
end

overlay.SetPerkBrowserDragCulling = function(active)
    local cards = overlay.GetPerkBrowserCards()

    if active then
        local scrollFrame = _G and _G.PerkBrowserScrollFrame
        if not scrollFrame then
            return
        end

        local scrollY = scrollFrame.GetVerticalScroll and scrollFrame:GetVerticalScroll() or 0
        local viewHeight = scrollFrame.GetHeight and scrollFrame:GetHeight() or 450
        local metrics = overlay.browserDragCullingMetrics
        local rowHeight = metrics.buttonSize + metrics.nameHeight + metrics.buttonSpacing
        local firstRow = math.max(0, math.floor(scrollY / rowHeight) - 1)
        local lastRow = math.ceil((scrollY + viewHeight) / rowHeight) + 1

        local visibleIndex = 0
        for _, card in ipairs(cards) do
            if not card._peeBrowserFamilyHidden and card.IsShown and card:IsShown() then
                visibleIndex = card._peeBrowserVisibleIndex or (visibleIndex + 1)
                local row = math.floor((visibleIndex - 1) / metrics.perksPerRow)
                if row < firstRow or row > lastRow then
                    card:Hide()
                    card._peeCulledByDrag = true
                end
            end
        end

        return
    end

    for _, card in ipairs(cards) do
        if card._peeCulledByDrag then
            if not card._peeBrowserFamilyHidden then
                card:Show()
            end
            card._peeCulledByDrag = nil
        end
    end
end

overlay.WrapPerkBrowserServerFilterControl = function(control)
    if not control or not control.GetScript or not control.SetScript or control._peeBrowserServerFilterWrapper then
        return
    end

    local isServerFilterControl = control.quality ~= nil or control.GetChecked or control.SetChecked
    if not isServerFilterControl then
        return
    end

    local originalClick = control:GetScript("OnClick")
    if type(originalClick) ~= "function" then
        return
    end

    control:SetScript("OnClick", function(self, ...)
        local firstResult, secondResult, thirdResult = originalClick(self, ...)
        if overlay.RestylePerkBrowserFilterControls then
            overlay.RestylePerkBrowserFilterControls()
        end
        overlay.ApplyPerkBrowserFamilyFilter(true)
        return firstResult, secondResult, thirdResult
    end)
    control._peeBrowserServerFilterWrapper = true
end

overlay.EnsurePerkBrowserDragCulling = function(browserFrame)
    if not browserFrame or browserFrame._peeBrowserDragCullingReady or not browserFrame.SetScript then
        return
    end

    local originalDragStart = browserFrame.GetScript and browserFrame:GetScript("OnDragStart")
    local originalDragStop = browserFrame.GetScript and browserFrame:GetScript("OnDragStop")

    browserFrame:SetScript("OnDragStart", function(self)
        local perkBrowser = _G and _G.ProjectEbonhold and _G.ProjectEbonhold.PerkBrowser
        if perkBrowser then
            perkBrowser._isDragging = true
        end
        if GameTooltip and GameTooltip.IsShown and GameTooltip:IsShown() and GameTooltip.Hide then
            GameTooltip:Hide()
        end
        overlay.SetPerkBrowserDragCulling(true)

        if type(originalDragStart) == "function" then
            originalDragStart(self)
        elseif self.StartMoving then
            self:StartMoving()
        end
    end)

    browserFrame:SetScript("OnDragStop", function(self)
        if type(originalDragStop) == "function" then
            originalDragStop(self)
        elseif self.StopMovingOrSizing then
            self:StopMovingOrSizing()
        end

        overlay.SetPerkBrowserDragCulling(false)

        local perkBrowser = _G and _G.ProjectEbonhold and _G.ProjectEbonhold.PerkBrowser
        if perkBrowser then
            perkBrowser._isDragging = false
        end
    end)

    browserFrame._peeBrowserDragCullingReady = true
end

local function SkinPerkBrowserFilterButton(button)
    if not button or button.quality == nil then
        return
    end

    local qualityColor = overlay.GetQualityColor(button.quality)
    local restingBackdrop = overlay.ScaleColor(qualityColor, 0.42, 0.03)
    local hoverBackdrop = overlay.ScaleColor(qualityColor, 0.72, 0.06)
    local hoverBorder = overlay.ScaleColor(qualityColor, 1.35, 0.12)
    if button.quality == -1 then
        restingBackdrop = HOVER_BLUE_BACKDROP
        hoverBackdrop = HOVER_BLUE_BACKDROP
        hoverBorder = HOVER_BLUE
    end

    SuppressExistingButtonTextureRegions(button, "_peeBrowserFilterRegionsSuppressed")
    SkinRuntimeButton(button, restingBackdrop, WHITE, BLACK, hoverBackdrop, hoverBorder)
    if button.SetSize then
        button:SetSize(80, 25)
    else
        if button.SetWidth then button:SetWidth(80) end
        if button.SetHeight then button:SetHeight(25) end
    end

    local browserFrame = _G and _G.PerkBrowserFrame
    if browserFrame and button.ClearAllPoints and button.SetPoint then
        button:ClearAllPoints()
        button:SetPoint("TOPLEFT", browserFrame, "TOPLEFT", 20 + ((button.quality + 1) * 85),
            overlay.perkBrowserFamilyLayout.qualityTop)
    end
    SetButtonBackdrop(button, restingBackdrop, BLACK)
    if button.SetAlpha then
        button:SetAlpha(1)
    end
    ConfigurePerkBrowserText(button.text, 10, nil, nil, "CENTER")
    overlay.SetRuntimeButtonTextColor(button.text, WHITE)
    if button.text and button.text.SetDrawLayer then
        button.text:SetDrawLayer("OVERLAY", 7)
    end

    overlay.WrapPerkBrowserServerFilterControl(button)
end

overlay.RestylePerkBrowserFilterControls = function()
    local browserFrame = _G and _G.PerkBrowserFrame
    if not browserFrame then
        return
    end

    ForEachChildFrame(browserFrame, function(child)
        SkinPerkBrowserFilterButton(child)
    end)
end

local function GetBrowserPerkQualityColor(button)
    local quality = button and button.perkData and button.perkData.quality
    return BROWSER_QUALITY_COLORS[quality] or BLACK
end

function overlay.HideBrowserBackdropBorder(button)
    local borderFrame = button and button.borderFrame
    if not borderFrame or borderFrame._peeBrowserBackdropBorderHidden then
        return
    end

    if borderFrame.Hide then
        borderFrame:Hide()
    end
    if borderFrame.SetAlpha then
        borderFrame:SetAlpha(0)
    end
    if borderFrame.EnableMouse then
        borderFrame:EnableMouse(false)
    end
    borderFrame._peeBrowserBackdropBorderHidden = true
end

function overlay.EnsureBrowserTextureBorder(button)
    if not button then
        return nil
    end

    overlay.HideBrowserBackdropBorder(button)

    if not button.borderTex and button.CreateTexture then
        button.borderTex = button:CreateTexture(nil, "BORDER")
        button.borderTex._peeBrowserOwnedBorder = true
    end

    local borderTex = button.borderTex
    if not borderTex then
        return nil
    end

    local borderSize = overlay.browserDragCullingMetrics.buttonSize + 4
    local geometryKey = tostring(borderSize) .. ":" .. tostring(overlay.browserDragCullingMetrics.buttonSize)
    if borderTex._peeBrowserGeometryKey ~= geometryKey then
        if borderTex.SetSize then
            borderTex:SetSize(borderSize, borderSize)
        end
        if borderTex.ClearAllPoints then
            borderTex:ClearAllPoints()
        end
        if borderTex.SetPoint then
            borderTex:SetPoint("TOP", button, "TOP", 0, -2)
        end
        if borderTex.SetTexture then
            borderTex:SetTexture("Interface\\Buttons\\WHITE8x8")
        end
        borderTex._peeBrowserGeometryKey = geometryKey
    end

    if borderTex.Show then
        borderTex:Show()
    end
    if borderTex.SetAlpha then
        borderTex:SetAlpha(1)
    end

    return borderTex
end

function overlay.AnchorBrowserCardIcon(button, borderTex)
    if not button or not button.icon then
        return
    end

    local anchor = borderTex or button
    local geometryKey = tostring(overlay.browserDragCullingMetrics.buttonSize) .. ":" .. tostring(anchor)
    if button.icon._peeBrowserGeometryKey == geometryKey then
        return
    end

    if button.icon.SetSize then
        button.icon:SetSize(overlay.browserDragCullingMetrics.buttonSize, overlay.browserDragCullingMetrics.buttonSize)
    end
    if button.icon.ClearAllPoints then
        button.icon:ClearAllPoints()
    end
    if button.icon.SetPoint then
        button.icon:SetPoint("CENTER", anchor, "CENTER", 0, 0)
    end
    button.icon._peeBrowserGeometryKey = geometryKey
end

local function SetBrowserCardBorder(button, color)
    if not button then
        return
    end

    local borderColor = color or GetBrowserPerkQualityColor(button)
    local borderTex = overlay.EnsureBrowserTextureBorder(button)
    if borderTex and borderTex.SetVertexColor then
        borderTex:SetVertexColor(borderColor[1], borderColor[2], borderColor[3], 1)
    end

    overlay.AnchorBrowserCardIcon(button, borderTex)
end

local function SkinPerkBrowserCard(button)
    local hasCardSurface = button and (button.spellId or button.nameText or button.borderFrame or button.borderTex)
    if not hasCardSurface then
        return
    end

    if button.SetSize then
        button:SetSize(overlay.browserDragCullingMetrics.buttonSize,
            overlay.browserDragCullingMetrics.buttonSize + overlay.browserDragCullingMetrics.nameHeight)
    end
    ConfigurePerkBrowserText(button.nameText, 7, nil, overlay.browserDragCullingMetrics.buttonSize + 10, "CENTER")
    if button.nameText and button.nameText.SetHeight then
        button.nameText:SetHeight(overlay.browserDragCullingMetrics.nameHeight)
    end
    if button.nameText and button.nameText.ClearAllPoints then
        button.nameText:ClearAllPoints()
    end
    if button.nameText and button.nameText.SetPoint then
        button.nameText:SetPoint("TOP", button.icon or button, "BOTTOM", 0, -3)
    end
    if button.nameText and button.nameText.SetJustifyV then
        button.nameText:SetJustifyV("TOP")
    end
    if button.nameText and button.nameText.SetDrawLayer then
        button.nameText:SetDrawLayer("OVERLAY", 7)
    end
    ConfigurePerkBrowserText(button.stackText, 9, CREAM, nil, "RIGHT")
    if button.stackText and button.stackText.ClearAllPoints then
        button.stackText:ClearAllPoints()
    end
    if button.stackText and button.stackText.SetPoint then
        button.stackText:SetPoint("BOTTOMRIGHT", button.icon or button, "BOTTOMRIGHT", -1, 1)
    end

    SetBrowserCardBorder(button, GetBrowserPerkQualityColor(button))

    if button._peeBrowserCardHooks then
        return
    end

    local function onEnter(self)
        SetBrowserCardBorder(self, HOVER_BLUE)
    end

    local function onLeave(self)
        SetBrowserCardBorder(self, GetBrowserPerkQualityColor(self))
    end

    if button.HookScript then
        button:HookScript("OnEnter", onEnter)
        button:HookScript("OnLeave", onLeave)
        button._peeBrowserCardHooks = true
    end
end

local function ApplyPerkBrowserTheme()
    if not overlay.enabled or overlay.isPTR then
        return
    end

    local browserFrame = _G and _G.PerkBrowserFrame
    if not browserFrame then
        return
    end

    SetDarkBackdrop(browserFrame, 4, 4)
    overlay.EnsurePerkBrowserDragCulling(browserFrame)
    if browserFrame.HookScript and not browserFrame._peeBrowserRestoreDatabaseHook then
        browserFrame:HookScript("OnHide", function()
            overlay.RestorePerkBrowserDatabase()
        end)
        browserFrame._peeBrowserRestoreDatabaseHook = true
    end

    ForEachFrameRegion(browserFrame, function(region)
        local text = GetPerkBrowserText(region)
        if text == "Echoes Browser" then
            ConfigurePerkBrowserText(region, 16, MAGE_BLUE, nil, "CENTER")
        elseif text == "Search:" or text == "My Class Only" then
            ConfigurePerkBrowserText(region, 11, CREAM, nil, "LEFT")
        end
    end)

    ForEachDirectChildFrame(browserFrame, function(child)
        local editBox = FindEditBoxChild(child)
        if editBox then
            SkinPerkBrowserSearchFrame(child, editBox)
        end

        SkinPerkBrowserFilterButton(child)
        overlay.WrapPerkBrowserServerFilterControl(child)
    end)

    overlay.EnsurePerkBrowserFamilyFilterRow(browserFrame)
    overlay.ApplyPerkBrowserFamilyFilter(true)

    overlay.HidePerkRecoveryButtons(_G and _G.ProjectEbonholdPerkFrame)

    local scrollChild = _G and _G.PerkBrowserScrollChild
    if scrollChild then
        local children = { scrollChild:GetChildren() }
        for _, child in ipairs(children) do
            SkinPerkBrowserCard(child)
        end
    end
end

overlay.ApplyPerkBrowserTheme = ApplyPerkBrowserTheme

local function WrapPerkBrowserFunction(perkBrowser, functionName)
    local original = perkBrowser and perkBrowser[functionName]
    if type(original) ~= "function" or perkBrowser["_peeWrapped" .. functionName] then
        return
    end

    perkBrowser["_peeWrapped" .. functionName] = true
    perkBrowser[functionName] = function(...)
        local shouldRestoreDatabase = false
        if functionName == "Show" then
            overlay.ActivatePerkBrowserGroupedDatabase()
            shouldRestoreDatabase = true
        end
        local a, b, c = original(...)
        if shouldRestoreDatabase or functionName == "Hide" then
            overlay.RestorePerkBrowserDatabase()
        end
        if functionName == "Hide" then
            return a, b, c
        end
        ApplyPerkBrowserTheme()
        return a, b, c
    end
end

local function InstallPerkBrowserThemeHooks()
    if not overlay.enabled or overlay.isPTR then
        return
    end

    local perkBrowser = _G and _G.ProjectEbonhold and _G.ProjectEbonhold.PerkBrowser
    if not perkBrowser then
        return
    end

    WrapPerkBrowserFunction(perkBrowser, "Show")
    WrapPerkBrowserFunction(perkBrowser, "Hide")

    ApplyPerkBrowserTheme()
end

overlay.InstallPerkBrowserThemeHooks = InstallPerkBrowserThemeHooks

local function ConfigurePerkChoiceText(fontString, size, color, width, justifyH)
    if not fontString then
        return
    end

    if fontString.SetFont then
        fontString:SetFont("Fonts\\FRIZQT__.TTF", ScaledFontSize(size), "OUTLINE")
    end

    if width and fontString.SetWidth then
        fontString:SetWidth(width)
    end

    if fontString.SetWordWrap then
        fontString:SetWordWrap(true)
    end

    if fontString.SetNonSpaceWrap then
        fontString:SetNonSpaceWrap(false)
    end

    if justifyH and fontString.SetJustifyH then
        fontString:SetJustifyH(justifyH)
    end

    if color and fontString.SetTextColor then
        fontString:SetTextColor(color[1], color[2], color[3], 1)
    end
end

overlay.GetPerkChoiceFullDescription = function(frame)
    if not frame then
        return nil
    end

    local utils = _G and _G.utils
    if utils and utils.GetSpellDescription and frame._spellId then
        return utils.GetSpellDescription(frame._spellId, 500, frame._stacks or 1)
    end

    if frame._peeFullDescription then
        return frame._peeFullDescription
    end

    if frame.descText and frame.descText.GetText then
        return frame.descText:GetText()
    end

    return frame.descText and frame.descText.text
end

overlay.GetPerkChoiceShortDescription = function(frame)
    local utils = _G and _G.utils
    if utils and utils.GetSpellDescription and frame and frame._spellId then
        return utils.GetSpellDescription(frame._spellId, 80, frame._stacks or 1)
    end

    return overlay.GetPerkChoiceFullDescription(frame)
end

overlay.GetPendingPerkSelectCount = function()
    local project = _G and _G.ProjectEbonhold
    local service = project and project.PerkService
    if service and service.GetPendingRollsCount then
        local count = tonumber(service.GetPendingRollsCount())
        if count then
            return count
        end
    end

    return nil
end

overlay.GetCurrentPerkChoices = function()
    local project = _G and _G.ProjectEbonhold
    local service = project and project.PerkService
    if service and service.GetCurrentChoice then
        return service.GetCurrentChoice()
    end

    return project and project.Perks and project.Perks.currentChoice
end

overlay.HasActivePerkChoiceFrame = function()
    for index = 1, 3 do
        local frame = _G and _G["PerkChoice" .. index]
        if frame and (frame.inUse == true or frame._spellId or frame._perkData) then
            return true
        end
    end

    return false
end

overlay.HasPendingPerkChoices = function()
    local count = overlay.GetPendingPerkSelectCount()
    if count ~= nil then
        return count > 0
    end

    local choices = overlay.GetCurrentPerkChoices()
    if choices and #choices > 0 then
        return true
    end

    return overlay.HasActivePerkChoiceFrame()
end

overlay.GetPerkSelectLabel = function()
    local count = overlay.GetPendingPerkSelectCount()
    if count then
        return "Select (" .. count .. ")"
    end

    return "Select"
end

overlay.HasNoPendingPerkChoices = function()
    return not overlay.HasPendingPerkChoices()
end

overlay.GetCurrentPlayerRunData = function()
    local project = _G and _G.ProjectEbonhold
    local service = project and project.PlayerRunService
    if service and type(service.GetCurrentData) == "function" then
        return service.GetCurrentData() or {}
    end

    return _G and _G.EbonholdPlayerRunData or {}
end

overlay.GetRemainingPerkBanishes = function()
    local project = _G and _G.ProjectEbonhold
    local constants = project and project.Constants
    if constants and constants.ENABLE_BANISH_SYSTEM == false then
        return nil
    end

    local runData = overlay.GetCurrentPlayerRunData()
    local remainingBanishes = tonumber(runData and runData.remainingBanishes)
    return remainingBanishes
end

overlay.GetAvailablePerkRerolls = function()
    local runData = overlay.GetCurrentPlayerRunData()
    local usedRerolls = tonumber(runData and runData.usedRerolls) or 0
    local totalRerolls = tonumber(runData and runData.totalRerolls)
    if not totalRerolls then
        return nil
    end

    return math.max(0, totalRerolls - usedRerolls)
end

overlay.RequestPerkRerollDirect = function()
    if overlay.HasNoPendingPerkChoices() then
        return true
    end

    local availableRerolls = overlay.GetAvailablePerkRerolls()
    if availableRerolls and availableRerolls <= 0 then
        PrintMessage("No rerolls remaining.")
        return true
    end

    local project = _G and _G.ProjectEbonhold
    local service = project and project.PerkService
    if not service or type(service.RequestReroll) ~= "function" then
        return false
    end

    overlay.perkChoiceForceShown = true
    overlay._peeRerollAutoRepopulate = true
    service.RequestReroll()
    if overlay.RefreshPerkChoiceTheme then
        overlay.RefreshPerkChoiceTheme(true)
    end
    return true
end

overlay.RefreshPerkChoiceActionCounts = function(perkFrame)
    local project = _G and _G.ProjectEbonhold
    local perkUI = project and project.PerkUI
    if perkUI and type(perkUI.RefreshBanishText) == "function" then
        perkUI.RefreshBanishText()
    end

    local remainingBanishes = overlay.GetRemainingPerkBanishes()
    if remainingBanishes then
        for index = 1, 3 do
            local frame = overlay.GetPerkChoiceCardFrame(index, true)
            local button = frame and frame.banishCardButton
            local text = overlay.GetPerkButtonTextFrame(button)
            if button and text and not overlay.IsPerkChoiceFrozen(frame) then
                if text.SetText then
                    text:SetText("Banish (" .. tostring(remainingBanishes) .. ")")
                end
                if remainingBanishes > 0 then
                    if button.Enable then
                        button:Enable()
                    end
                    if button.EnableMouse then
                        button:EnableMouse(true)
                    end
                    if text.SetTextColor then
                        text:SetTextColor(CREAM[1], CREAM[2], CREAM[3], 1)
                    end
                else
                    if button.Disable then
                        button:Disable()
                    end
                    if text.SetTextColor then
                        text:SetTextColor(MUTED[1], MUTED[2], MUTED[3], 1)
                    end
                end
            end
        end
    end

    local availableRerolls = overlay.GetAvailablePerkRerolls()
    local rerollButton = overlay.FindPerkRerollButton and overlay.FindPerkRerollButton(perkFrame)
    if overlay.HasNoPendingPerkChoices() then
        if rerollButton and rerollButton.Hide then
            rerollButton:Hide()
        end
        return
    end

    local rerollText = overlay.GetPerkButtonTextFrame(rerollButton)
    if availableRerolls and rerollText then
        if rerollText.SetText then
            rerollText:SetText("Reroll (" .. tostring(availableRerolls) .. ")")
        end
        if availableRerolls > 0 then
            if rerollButton.Enable then
                rerollButton:Enable()
            end
            if rerollButton.Show then
                rerollButton:Show()
            end
        elseif rerollButton.Disable then
            rerollButton:Disable()
        end
    end
end

overlay.IsPerkChoiceFrozen = function(frame)
    if not frame then
        return false
    end
    if frame._locallyFrozen then
        return true
    end

    local perkData = frame._perkData
    return perkData and (perkData.isFrozen or perkData.isCarried or perkData.justFrozen) and true or false
end

overlay.RefreshPerkChoiceSelectText = function(button)
    if not button then
        return
    end

    local fontString = button.text
    if button.GetFontString then
        fontString = button:GetFontString() or fontString
    end

    if fontString and fontString.SetText then
        fontString:SetText(overlay.GetPerkSelectLabel())
    end
end

local function ApplySinglePerkChoiceTheme(frame)
    if not frame then
        return
    end

    local cardBody = frame.backdropFrame or frame
    local perkFrame = _G and _G.ProjectEbonholdPerkFrame
    local frameShown = not frame.IsShown or frame:IsShown()
    local showActionButtons = frameShown and overlay.ShouldShowPerkChoiceControls(perkFrame)
    local frozen = overlay.IsPerkChoiceFrozen(frame)
    local freezeBackdrop = frozen and DARK or FREEZE_BACKDROP
    local freezeHoverBackdrop = frozen and DARK or FREEZE_HOVER_BACKDROP
    local freezeHoverBorder = frozen and BLACK or overlay.buttonBorders.freezeHover

    if overlay.IsPerkFadeAnimationDisabled() and frame.SetAlpha then
        frame:SetAlpha(1)
    end

    if frame.backdropFrame then
        SetDarkBackdrop(frame.backdropFrame, 2, 2)
        if overlay.IsPerkFadeAnimationDisabled() and frame.backdropFrame.SetAlpha then
            frame.backdropFrame:SetAlpha(1)
        end
    end

    if frame.iconFrame then
        SetFrameSize(frame.iconFrame, 24, 24)
        if frame.iconFrame.ClearAllPoints then
            frame.iconFrame:ClearAllPoints()
        end
        frame.iconFrame:SetPoint("TOP", cardBody, "TOP", -5, -84)
    end

    if frame.iconBase then
        SetFrameSize(frame.iconBase, 104, 104)
        if frame.iconBase.ClearAllPoints then
            frame.iconBase:ClearAllPoints()
        end
        frame.iconBase:SetPoint("CENTER", frame.iconFrame or frame, "CENTER", 0, 0)
    end

    if frame.icon then
        SetFrameSize(frame.icon, 24, 24)
        if frame.icon.ClearAllPoints then
            frame.icon:ClearAllPoints()
        end
        frame.icon:SetPoint("CENTER", frame.iconFrame or frame, "CENTER", 0, -3)
    end

    if frame.border then
        SetFrameSize(frame.border, 104, 104)
        if frame.border.ClearAllPoints then
            frame.border:ClearAllPoints()
        end
        frame.border:SetPoint("CENTER", frame.iconFrame or frame, "CENTER", 0, 0)
    end

    ConfigurePerkChoiceText(frame.nameText, 14, nil, 170, "CENTER")
    if frame.nameText and frame.nameText.ClearAllPoints then
        frame.nameText:ClearAllPoints()
    end
    if frame.nameText then
        frame.nameText:SetPoint("TOP", cardBody, "TOP", -5, -16)
    end

    if frame.peeFamilyText then
        if frame.peeFamilyText.SetText then
            frame.peeFamilyText:SetText("")
        end
        if frame.peeFamilyText.Hide then
            frame.peeFamilyText:Hide()
        end
    end

    if frame.ownedCountFrame then
        SetFrameSize(frame.ownedCountFrame, 50, 18)
        if frame.ownedCountFrame.ClearAllPoints then
            frame.ownedCountFrame:ClearAllPoints()
        end
        if frame.nameText then
            frame.ownedCountFrame:SetPoint("TOP", frame.iconFrame or frame, frame.iconFrame and "BOTTOM" or "TOP", 0,
                frame.iconFrame and 1 or -124)
        end
    end

    ConfigurePerkChoiceText(frame.descText, 12, CREAM, 170, "CENTER")
    if frame.descText and frame.descText.ClearAllPoints then
        frame.descText:ClearAllPoints()
    end
    if frame.descText then
        frame._peeFullDescription = overlay.GetPerkChoiceFullDescription(frame)
        frame.descText:SetText(overlay.GetPerkChoiceShortDescription(frame))
        frame.descText:SetPoint("TOP", cardBody, "TOP", -5, -136)
        if frame.descText.SetHeight then
            frame.descText:SetHeight(52)
        end
        if frame.descText.SetJustifyV then
            frame.descText:SetJustifyV("TOP")
        end
    end

    ConfigurePerkChoiceText(frame.ownedCountText, 12, MAGE_BLUE, nil, "CENTER")
    if frame.ownedCountText and frame.ownedCountText.ClearAllPoints then
        frame.ownedCountText:ClearAllPoints()
    end
    if frame.ownedCountText and frame.ownedCountFrame then
        frame.ownedCountText:SetPoint("CENTER", frame.ownedCountFrame, "CENTER", 0, 0)
    end

    if frame.familyIconSlots then
        for _, slot in ipairs(frame.familyIconSlots) do
            if slot.Hide then
                slot:Hide()
            end
        end
    end

    if frame.selectButton then
        if frame.selectButton.SetParent then
            frame.selectButton:SetParent(frame)
        end
        SetFrameSize(frame.selectButton, 130, 32)
        if frame.selectButton.ClearAllPoints then
            frame.selectButton:ClearAllPoints()
        end
        frame.selectButton:SetPoint("BOTTOM", cardBody, "BOTTOM", 0, 88)
        overlay.RefreshPerkChoiceSelectText(frame.selectButton)
        if showActionButtons then
            if frame.EnableMouse then
                frame:EnableMouse(true)
            end
            if frame.selectButton.Enable then
                frame.selectButton:Enable()
            end
            if frame.selectButton.EnableMouse then
                frame.selectButton:EnableMouse(true)
            end
            if frame.selectButton.Show then
                frame.selectButton:Show()
            end
        end
    end

    if frame.freezeCardButton then
        if frame.freezeCardButton.SetParent then
            frame.freezeCardButton:SetParent(frame)
        end
        SetFrameSize(frame.freezeCardButton, 130, 32)
        if frame.freezeCardButton.ClearAllPoints then
            frame.freezeCardButton:ClearAllPoints()
        end
        frame.freezeCardButton:SetPoint(
            "TOP",
            frame.selectButton or frame,
            frame.selectButton and "BOTTOM" or "BOTTOM",
            0,
            frame.selectButton and -8 or 70
        )
        if showActionButtons and frame.freezeCardButton.Show then
            frame.freezeCardButton:Show()
        end
    end

    if frame.banishCardButton then
        if frame.banishCardButton.SetParent then
            frame.banishCardButton:SetParent(frame)
        end
        SetFrameSize(frame.banishCardButton, 130, 32)
        if frame.banishCardButton.ClearAllPoints then
            frame.banishCardButton:ClearAllPoints()
        end
        frame.banishCardButton:SetPoint(
            "TOP",
            frame.freezeCardButton or frame,
            frame.freezeCardButton and "BOTTOM" or "BOTTOM",
            0,
            frame.freezeCardButton and -8 or 30
        )
        if showActionButtons and frame.banishCardButton.Show then
            frame.banishCardButton:Show()
        end
    end

    SkinRuntimeButton(frame.selectButton, SELECT_BACKDROP, CREAM, BLACK, SELECT_HOVER_BACKDROP,
        SELECT_HOVER_BORDER)
    SkinRuntimeButton(frame.freezeCardButton, freezeBackdrop, CREAM, BLACK,
        freezeHoverBackdrop, freezeHoverBorder)

    SkinRuntimeButton(frame.banishCardButton, BANISH_BACKDROP, CREAM,
        BLACK, BANISH_HOVER_BACKDROP,
        overlay.buttonBorders.banishHover)
end

local function ApplyPerkFamilyHintTheme()
    local hintFrame = _G and _G.PerkFamilyHintFrame
    if not hintFrame then
        return
    end

    SetFrameSize(hintFrame, 260, 110)
    if hintFrame.SetFrameStrata then
        hintFrame:SetFrameStrata("DIALOG")
    end
    if hintFrame.SetFrameLevel then
        hintFrame:SetFrameLevel(200)
    end
    if hintFrame.EnableMouse then
        hintFrame:EnableMouse(true)
    end
    SetDarkBackdrop(hintFrame, 2, 2)

    if hintFrame.GetRegions then
        local regions = { hintFrame:GetRegions() }
        for _, region in ipairs(regions) do
            if region and region.GetTexture and region.Hide then
                region:Hide()
            end
        end
    end

    if not hintFrame.peeTitle and hintFrame.CreateFontString then
        local title = hintFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        title:SetPoint("TOP", hintFrame, "TOP", 0, -12)
        title:SetText("|cffffcc00Echo Families|r")
        hintFrame.peeTitle = title
    end

    if hintFrame.peeTitle then
        if hintFrame.peeTitle.ClearAllPoints then
            hintFrame.peeTitle:ClearAllPoints()
        end
        hintFrame.peeTitle:SetPoint("TOP", hintFrame, "TOP", 0, -12)
    end
    ConfigurePerkChoiceText(hintFrame.peeTitle, 11, nil, nil, "CENTER")

    if hintFrame.hintText then
        if hintFrame.hintText.ClearAllPoints then
            hintFrame.hintText:ClearAllPoints()
        end
        if hintFrame.hintText.SetJustifyV then
            hintFrame.hintText:SetJustifyV("TOP")
        end
        if hintFrame.hintText.SetSize then
            hintFrame.hintText:SetSize(230, 0)
        end
        hintFrame.hintText:SetPoint("TOPLEFT", hintFrame, "TOPLEFT", 14, -32)
        hintFrame.hintText:SetText("Picking an echo from a family boosts chances of more from that same family.")
    end
    ConfigurePerkChoiceText(hintFrame.hintText, 11, {0.9, 0.9, 0.9}, 230, "LEFT")

    ForEachChildFrame(hintFrame, function(child)
        if child and child.GetObjectType and child:GetObjectType() == "Button" and child.SetPoint then
            SetFrameSize(child, 16, 16)
            if child.ClearAllPoints then
                child:ClearAllPoints()
            end
            child:SetPoint("TOPRIGHT", hintFrame, "TOPRIGHT", -4, -4)
            HideButtonTextures(child)
            if not child.peeText and child.CreateFontString then
                local text = child:CreateFontString(nil, "OVERLAY", "GameFontNormal")
                text:SetPoint("CENTER", child, "CENTER", 0, 1)
                child.peeText = text
            end
            if child.peeText then
                child.peeText:SetText("|cffbbbbbb-|r")
            end
            if not child._peeFamilyCloseHover and child.SetScript then
                child:SetScript("OnEnter", function(self)
                    if self.peeText then
                        self.peeText:SetText("|cffffffff-|r")
                    end
                end)
                child:SetScript("OnLeave", function(self)
                    if self.peeText then
                        self.peeText:SetText("|cffbbbbbb-|r")
                    end
                end)
                child._peeFamilyCloseHover = true
            end
        end
    end)

    local firstCard = overlay.GetPerkChoiceCardFrame and overlay.GetPerkChoiceCardFrame(1)
    local anchor = firstCard and (firstCard.backdropFrame or firstCard)
    if anchor and hintFrame.ClearAllPoints and hintFrame.SetPoint then
        hintFrame:ClearAllPoints()
        hintFrame:SetPoint("BOTTOMRIGHT", anchor, "TOPLEFT", 40, 10)
    end
end

overlay.GetPerkButtonTextFrame = function(button)
    local fontString = button and button.text
    if button and button.GetFontString then
        fontString = button:GetFontString() or fontString
    end
    return fontString
end

overlay.GetPerkButtonText = function(button)
    local fontString = overlay.GetPerkButtonTextFrame(button)
    if fontString and fontString.GetText then
        return fontString:GetText()
    end

    if fontString and fontString.text then
        return fontString.text
    end

    return button and button.label
end

overlay.NormalizePerkButtonText = function(text)
    if text == nil then
        return ""
    end

    text = tostring(text)
    text = text:gsub("|c%x%x%x%x%x%x%x%x", "")
    text = text:gsub("|r", "")
    return text:match("^%s*(.-)%s*$") or text
end

overlay.IsPerkRecoveryShowButton = function(button)
    if not button or button._peePerkButtonKey ~= "hide" then
        return false
    end

    if button._peeRecoveryShow then
        return true
    end

    if overlay.NormalizePerkButtonText(overlay.GetPerkButtonText(button)) == "Show" then
        return true
    end

    local perkFrame = button._peePerkFrame or (_G and _G.ProjectEbonholdPerkFrame)
    return overlay.IsPerkChoiceHidden and overlay.IsPerkChoiceHidden(perkFrame) or false
end

overlay.GetPerkButtonStore = function()
    EnsureSavedVariables()
    if type(overlay.db.perkButtons) ~= "table" then
        overlay.db.perkButtons = {}
    end

    return overlay.db.perkButtons
end

overlay.GetPerkFrameStore = function()
    EnsureSavedVariables()
    if type(overlay.db.perkFrame) ~= "table" then
        overlay.db.perkFrame = {}
    end

    return overlay.db.perkFrame
end

overlay.EnsurePerkButtonLayoutVersion = function()
    EnsureSavedVariables()
    if overlay.db.perkButtonLayoutVersion == overlay.perkButtonLayoutVersion then
        return
    end

    if type(overlay.db.perkButtons) ~= "table" then
        overlay.db.perkButtons = {}
    end

    overlay.db.perkButtons.reroll = nil
    overlay.db.perkButtons.hide = nil
    overlay.db.perkButtonLayoutVersion = overlay.perkButtonLayoutVersion
end

overlay.GetPerkChoiceCardFrame = function(cardIndex, includeHidden)
    local frame = _G and _G["PerkChoice" .. tostring(cardIndex)]
    if frame and (includeHidden or not frame.IsShown or frame:IsShown()) then
        return frame
    end

    return nil
end

overlay.GetPerkSnapFrame = function(cardFrame)
    return cardFrame and (cardFrame.backdropFrame or cardFrame) or nil
end

overlay.GetPerkChoiceGroupAnchorFrame = function(includeHidden)
    local cards = {}
    for index = 1, 3 do
        local frame = overlay.GetPerkChoiceCardFrame(index, includeHidden)
        if frame then
            cards[#cards + 1] = frame
        end
    end

    local anchorIndex = math.min(2, #cards)
    return overlay.GetPerkSnapFrame(cards[anchorIndex])
end

overlay.IsPerkChoiceHidden = function(perkFrame)
    return perkFrame and perkFrame.perksHidden == true
end

overlay.IsPerkBrowserShown = function()
    local browserFrame = _G and _G.PerkBrowserFrame
    return browserFrame and (not browserFrame.IsShown or browserFrame:IsShown()) == true
end

overlay.IsPlayerRunMinimized = function()
    local playerRunFrame = _G and _G.ProjectEbonholdPlayerRunFrame
    return playerRunFrame and playerRunFrame._peeMinimized == true
end

overlay.HasShownPerkChoiceCard = function()
    for index = 1, 3 do
        local frame = _G and _G["PerkChoice" .. index]
        if frame and (not frame.IsShown or frame:IsShown()) then
            return true
        end
    end

    return false
end

overlay.ShouldShowPerkChoiceControls = function(perkFrame)
    if overlay.HasNoPendingPerkChoices() then
        return false
    end

    if not overlay.HasShownPerkChoiceCard() then
        return false
    end

    if overlay.IsPlayerRunMinimized() and not overlay.perkChoiceForceShown then
        return false
    end

    if overlay.IsPerkChoiceHidden(perkFrame) and not overlay.HasShownPerkChoiceCard() then
        return false
    end

    return true
end

overlay.SetPerkChoiceFrameMouse = function(frame, enabled)
    if frame and frame.EnableMouse then
        frame:EnableMouse(enabled)
    end

    if enabled and frame and frame.selectButton and frame.selectButton.Enable then
        frame.selectButton:Enable()
    end

    if frame and frame.selectButton and frame.selectButton.EnableMouse then
        frame.selectButton:EnableMouse(enabled)
    end

    if frame and frame.freezeCardButton and frame.freezeCardButton.EnableMouse then
        frame.freezeCardButton:EnableMouse(enabled)
    end

    if frame and frame.banishCardButton and frame.banishCardButton.EnableMouse then
        frame.banishCardButton:EnableMouse(enabled)
    end
end

overlay.SetPerkChoiceHitboxesEnabled = function(enabled)
    local perkFrame = _G and _G.ProjectEbonholdPerkFrame
    if perkFrame and perkFrame.EnableMouse then
        perkFrame:EnableMouse(enabled)
    end

    for index = 1, 3 do
        overlay.SetPerkChoiceFrameMouse(_G and _G["PerkChoice" .. index], enabled)
    end
end

overlay.FindPerkHideButtons = function(perkFrame)
    local buttons = {}
    local seen = {}

    local function isRecoverySized(button)
        local width = button and button.GetWidth and button:GetWidth()
        local height = button and button.GetHeight and button:GetHeight()
        local widthMatches = not width or (width >= 90 and width <= 170)
        local heightMatches = not height or (height >= 18 and height <= 45)
        return widthMatches and heightMatches
    end

    local function add(button)
        if not button or seen[button] then
            return
        end

        local text = overlay.GetPerkButtonText(button) or ""
        local name = button.GetName and button:GetName()
        if button == (_G and _G.PerkHideButton) or name == "PerkHideButton" or
            button._peePerkButtonKey == "hide" or text == "Show" or text == "Hide" then
            seen[button] = true
            buttons[#buttons + 1] = button
        end
    end

    add(_G and _G.PerkHideButton)
    ForEachChildFrame(perkFrame, add)
    ForEachChildFrame(_G and _G.UIParent, function(child)
        local text = overlay.GetPerkButtonText(child) or ""
        if child and (child._peePerkButtonKey == "hide" or
            ((text == "Show" or text == "Hide") and isRecoverySized(child))) then
            add(child)
        end
    end)

    return buttons
end

overlay.HidePerkRecoveryButtons = function(perkFrame)
    for _, button in ipairs(overlay.FindPerkHideButtons(perkFrame)) do
        if button.EnableMouse then
            button:EnableMouse(false)
        end
        if button.Hide then
            button:Hide()
        end
    end
end

overlay.ShowPerkRecoveryButton = function(perkFrame)
    local hideButton = _G and _G.PerkHideButton
    if not hideButton then
        return
    end

    if overlay.IsPerkBrowserShown and overlay.IsPerkBrowserShown() then
        overlay.HidePerkRecoveryButtons(perkFrame)
        return
    end

    if overlay.HasNoPendingPerkChoices() then
        if overlay.HidePerkChoiceSurfaces then
            overlay.HidePerkChoiceSurfaces(false)
        else
            overlay.HidePerkRecoveryButtons(perkFrame)
            if perkFrame and perkFrame.Hide then
                perkFrame:Hide()
            end
        end
        return
    end

    overlay.SetPerkChoiceHitboxesEnabled(false)
    if perkFrame and perkFrame.Show then
        perkFrame:Show()
    end
    if perkFrame and perkFrame.EnableMouse then
        perkFrame:EnableMouse(false)
    end
    overlay.ReanchorPerkChoiceCards(perkFrame, true)

    SetFrameSize(hideButton, 120, 25)
    SkinRuntimeButton(hideButton, DARK, MUTED, BLACK, HOVER_BLUE_BACKDROP, HOVER_BLUE)
    if not overlay.RestorePerkButtonPosition(hideButton, "hide", perkFrame) then
        local anchor = overlay.GetPerkChoiceGroupAnchorFrame(true) or
            (_G and _G.UIParent)
        if hideButton.ClearAllPoints then
            hideButton:ClearAllPoints()
        end
        if hideButton.SetPoint and anchor then
            hideButton:SetPoint("TOP", anchor, "BOTTOM", 0, -20)
        end
    end
    overlay.EnsurePerkButtonDrag(hideButton, "hide", perkFrame)

    local text = overlay.GetPerkButtonTextFrame(hideButton)
    if text and text.SetText then
        text:SetText("Show")
    end
    hideButton._peeRecoveryShow = true

    if hideButton.EnableMouse then
        hideButton:EnableMouse(true)
    end
    if hideButton.Show then
        hideButton:Show()
    end
end

overlay.ShowPerkChoiceFromRecovery = function()
    local perkFrame = _G and _G.ProjectEbonholdPerkFrame
    local restoredCards = false

    if overlay.HasNoPendingPerkChoices() then
        overlay.perkChoiceForceShown = false
        overlay.HidePerkChoiceSurfaces(false)
        return false
    end

    overlay.perkChoiceForceShown = true

    if perkFrame then
        perkFrame.perksHidden = false
        if perkFrame.Show then
            perkFrame:Show()
        end
    end

    for index = 1, 3 do
        local frame = overlay.GetPerkChoiceCardFrame(index, true)
        if frame and frame.inUse ~= false then
            restoredCards = true
            if frame.SetAlpha then
                frame:SetAlpha(1)
            end
            if frame.Show then
                frame:Show()
            end
            overlay.SetPerkChoiceFrameMouse(frame, true)
            if frame.selectButton and frame.selectButton.Show then
                frame.selectButton:Show()
            end
            if frame.freezeCardButton and frame.freezeCardButton.Show then
                frame.freezeCardButton:Show()
            end
            if frame.banishCardButton and frame.banishCardButton.Show then
                frame.banishCardButton:Show()
            end
            ApplySinglePerkChoiceTheme(frame)
        end
    end

    if restoredCards then
        local hideButton = _G and _G.PerkHideButton
        local hideText = overlay.GetPerkButtonTextFrame(hideButton)
        if hideText and hideText.SetText then
            hideText:SetText("Hide")
        end
        if hideButton then
            hideButton._peeRecoveryShow = nil
        end
        if hideButton and hideButton.EnableMouse then
            hideButton:EnableMouse(true)
        end
        if hideButton and hideButton.Show then
            hideButton:Show()
        end
        overlay.RefreshPerkChoiceActionCounts(perkFrame)
        overlay.SetPerkChoiceHitboxesEnabled(true)
        overlay.HidePerkChooseButtons(perkFrame)
        overlay.SkinPerkRerollButton(perkFrame)
        overlay.AnchorPerkAutoShowCheckbox()
        if overlay.RefreshPerkChoiceTheme then
            overlay.RefreshPerkChoiceTheme(true)
        end
        return true
    end

    local project = _G and _G.ProjectEbonhold
    local perkUI = project and project.PerkUI
    local choices = overlay.GetCurrentPerkChoices()
    if choices and #choices > 0 and perkUI and type(perkUI.Show) == "function" then
        perkUI.Show(choices)
        local chooseButton = _G and _G.PerkChooseButton
        local chooseClick = chooseButton and chooseButton.GetScript and chooseButton:GetScript("OnClick")
        if type(chooseClick) == "function" then
            chooseClick(chooseButton)
        elseif chooseButton and chooseButton.Click then
            chooseButton:Click()
        end
        overlay.RefreshPerkChoiceActionCounts(perkFrame)
        if overlay.RefreshPerkChoiceTheme then
            overlay.RefreshPerkChoiceTheme(true)
        elseif overlay.ApplyPerkChoiceTheme then
            overlay.ApplyPerkChoiceTheme()
        end
        return overlay.HasShownPerkChoiceCard()
    end

    local chooseButton = _G and _G.PerkChooseButton
    local chooseClick = chooseButton and chooseButton.GetScript and chooseButton:GetScript("OnClick")
    if type(chooseClick) == "function" then
        chooseClick(chooseButton)
        overlay.RefreshPerkChoiceActionCounts(perkFrame)
        if overlay.RefreshPerkChoiceTheme then
            overlay.RefreshPerkChoiceTheme(true)
        end
        if overlay.HasShownPerkChoiceCard() then
            return true
        end
    end
    if chooseButton and chooseButton.Click then
        chooseButton:Click()
        overlay.RefreshPerkChoiceActionCounts(perkFrame)
        if overlay.RefreshPerkChoiceTheme then
            overlay.RefreshPerkChoiceTheme(true)
        end
        if overlay.HasShownPerkChoiceCard() then
            return true
        end
    end

    if perkUI and type(perkUI.Show) == "function" then
        perkUI.Show()
        if overlay.RefreshPerkChoiceTheme then
            overlay.RefreshPerkChoiceTheme(true)
        elseif overlay.ApplyPerkChoiceTheme then
            overlay.ApplyPerkChoiceTheme()
        end
        return true
    end

    if overlay.RefreshPerkChoiceTheme then
        overlay.RefreshPerkChoiceTheme(true)
    elseif overlay.ApplyPerkChoiceTheme then
        overlay.ApplyPerkChoiceTheme()
    end
    overlay.perkChoiceForceShown = false
    return false
end

overlay.GetVisiblePerkChoiceCards = function(includeHidden)
    local cards = {}
    for index = 1, 3 do
        local frame = overlay.GetPerkChoiceCardFrame(index, includeHidden)
        if frame then
            cards[#cards + 1] = frame
        end
    end
    return cards
end

overlay.ReanchorPerkChoiceCards = function(perkFrame, includeHidden)
    local cards = overlay.GetVisiblePerkChoiceCards(includeHidden)
    local count = #cards
    local parent = perkFrame or (_G and _G.ProjectEbonholdPerkFrame)
    if count == 0 or not parent then
        return
    end

    for index, frame in ipairs(cards) do
        if frame.ClearAllPoints then
            frame:ClearAllPoints()
        end
        if frame.SetPoint then
            local xOffset = ((index - 1) - ((count - 1) / 2)) * 202
            frame:SetPoint("CENTER", parent, "CENTER", xOffset, 0)
        end
    end
end

overlay.GetPerkCardSnapEdge = function(cardIndex, edgeIndex)
    if edgeIndex == 1 then
        return "TOP"
    end

    if edgeIndex == 2 and cardIndex == 1 then
        return "LEFT"
    end

    if edgeIndex == 2 and cardIndex == 3 then
        return "RIGHT"
    end

    if edgeIndex == 2 and cardIndex == 2 then
        return "BOTTOM"
    end

    if edgeIndex == 3 and (cardIndex == 1 or cardIndex == 3) then
        return "BOTTOM"
    end

    return nil
end

overlay.DistanceToHorizontalSegment = function(pointX, pointY, left, right, yPosition)
    if pointX < left then
        return math.sqrt((pointX - left) ^ 2 + (pointY - yPosition) ^ 2)
    end

    if pointX > right then
        return math.sqrt((pointX - right) ^ 2 + (pointY - yPosition) ^ 2)
    end

    return math.abs(pointY - yPosition)
end

overlay.DistanceToVerticalSegment = function(pointX, pointY, xPosition, bottom, top)
    if pointY < bottom then
        return math.sqrt((pointX - xPosition) ^ 2 + (pointY - bottom) ^ 2)
    end

    if pointY > top then
        return math.sqrt((pointX - xPosition) ^ 2 + (pointY - top) ^ 2)
    end

    return math.abs(pointX - xPosition)
end

overlay.ButtonOverlapsPerkCard = function(button, cardFrame)
    if not button or not cardFrame then
        return false
    end

    if cardFrame.IsShown and not cardFrame:IsShown() then
        return false
    end

    local snapFrame = overlay.GetPerkSnapFrame(cardFrame)
    if not snapFrame then
        return false
    end

    local buttonLeft = button.GetLeft and button:GetLeft()
    local buttonRight = button.GetRight and button:GetRight()
    local buttonBottom = button.GetBottom and button:GetBottom()
    local buttonTop = button.GetTop and button:GetTop()
    local cardLeft = snapFrame.GetLeft and snapFrame:GetLeft()
    local cardRight = snapFrame.GetRight and snapFrame:GetRight()
    local cardBottom = snapFrame.GetBottom and snapFrame:GetBottom()
    local cardTop = snapFrame.GetTop and snapFrame:GetTop()

    if not buttonLeft or not buttonRight or not buttonBottom or not buttonTop or not cardLeft or not cardRight or
        not cardBottom or not cardTop then
        return false
    end

    return not (buttonRight < cardLeft or buttonLeft > cardRight or buttonTop < cardBottom or buttonBottom > cardTop)
end

overlay.PerkButtonOverlapsAnyCard = function(button)
    for cardIndex = 1, 3 do
        if overlay.ButtonOverlapsPerkCard(button, overlay.GetPerkChoiceCardFrame(cardIndex)) then
            return true
        end
    end

    return false
end

overlay.GetPerkFrameScale = function(perkFrame)
    if perkFrame and perkFrame.GetEffectiveScale then
        return perkFrame:GetEffectiveScale() or 1
    end

    return 1
end

overlay.ApplyPerkUIScale = function()
    local scale = overlay.GetPerkUIScale()
    local perkFrame = _G and _G.ProjectEbonholdPerkFrame
    local chooseButton = _G and _G.PerkChooseButton

    if perkFrame and perkFrame.SetScale then
        perkFrame:SetScale(scale)
    end

    if chooseButton and chooseButton.SetScale then
        chooseButton:SetScale(scale)
    end

    local function scaleIfStandalone(button)
        if not button or not button.SetScale then
            return
        end

        local parent = button.GetParent and button:GetParent() or button.parent
        if parent ~= perkFrame then
            button:SetScale(scale)
        end
    end

    scaleIfStandalone(_G and _G.PerkHideButton)
    scaleIfStandalone(overlay.FindPerkRerollButton and overlay.FindPerkRerollButton(perkFrame))
    scaleIfStandalone(_G and _G.EbonholdAutoShowCheck)

    return scale
end

overlay.SavePerkButtonPosition = function(button, key, perkFrame)
    if not button or not key then
        return
    end

    local store = overlay.GetPerkButtonStore()
    if key ~= "choose" and button._peeLastSnapCardIndex and button.GetPoint then
        local point, _, relativePoint, xOffset, yOffset = button:GetPoint(1)
        store[key] = {
            point = point,
            relativePoint = relativePoint,
            x = xOffset,
            y = yOffset,
            cardIndex = button._peeLastSnapCardIndex
        }
        return
    end

    if key ~= "choose" and UIParent and UIParent.GetCenter and button.GetCenter then
        local uiCenterX, uiCenterY = UIParent:GetCenter()
        local buttonCenterX, buttonCenterY = button:GetCenter()
        if uiCenterX and uiCenterY and buttonCenterX and buttonCenterY then
            store[key] = {
                useUIParent = true,
                offsetX = buttonCenterX - uiCenterX,
                offsetY = buttonCenterY - uiCenterY,
                scale = overlay.GetPerkFrameScale(perkFrame)
            }
            return
        end
    end

    if button.GetPoint then
        local point, _, relativePoint, xOffset, yOffset = button:GetPoint(1)
        store[key] = {
            point = point,
            relativePoint = relativePoint,
            x = xOffset,
            y = yOffset
        }
    end
end

overlay.RestorePerkButtonPosition = function(button, key, perkFrame)
    if not button or not key then
        return false
    end

    local position = overlay.GetPerkButtonStore()[key]
    if type(position) ~= "table" then
        return false
    end

    if key ~= "choose" and position.cardIndex then
        local cardFrame = overlay.GetPerkChoiceCardFrame(position.cardIndex)
        local snapFrame = overlay.GetPerkSnapFrame(cardFrame)
        if snapFrame and button.SetPoint then
            if button.ClearAllPoints then
                button:ClearAllPoints()
            end
            if button.SetParent and perkFrame then
                button:SetParent(perkFrame)
            end
            button:SetPoint(position.point or "CENTER", snapFrame, position.relativePoint or "CENTER",
                position.x or 0, position.y or 0)
            button._peeLastSnapCardIndex = position.cardIndex
            return true
        end
    end

    if key ~= "choose" and position.useUIParent and UIParent and button.SetPoint then
        if button.ClearAllPoints then
            button:ClearAllPoints()
        end
        local scale = overlay.GetPerkFrameScale(perkFrame)
        local savedScale = position.scale or scale
        local ratio = savedScale / scale
        button:SetPoint("CENTER", UIParent, "CENTER", (position.offsetX or 0) * ratio, (position.offsetY or 0) * ratio)
        button._peeLastSnapCardIndex = nil
        return true
    end

    if position.point and UIParent and button.SetPoint then
        if button.ClearAllPoints then
            button:ClearAllPoints()
        end
        button:SetPoint(position.point, UIParent, position.relativePoint or "CENTER", position.x or 0, position.y or 0)
        button._peeLastSnapCardIndex = nil
        return true
    end

    return false
end

overlay.SavePerkFramePosition = function(perkFrame)
    if not perkFrame or not UIParent or not perkFrame.GetLeft or not perkFrame.GetTop then
        return
    end

    local left = perkFrame:GetLeft()
    local top = perkFrame:GetTop()
    if type(left) ~= "number" or type(top) ~= "number" then
        return
    end

    local store = overlay.GetPerkFrameStore()
    store.left = left
    store.top = top
end

overlay.RestorePerkFramePosition = function(perkFrame)
    if not perkFrame or perkFrame._peePositionRestored or not UIParent then
        return
    end

    local store = overlay.GetPerkFrameStore()
    if type(store.left) == "number" and type(store.top) == "number" and perkFrame.SetPoint then
        if perkFrame.ClearAllPoints then
            perkFrame:ClearAllPoints()
        end
        perkFrame:SetPoint("TOPLEFT", UIParent, "BOTTOMLEFT", store.left, store.top)
    end

    perkFrame._peePositionRestored = true
end

overlay.StartPerkFrameDrag = function(perkFrame)
    if not perkFrame or not IsControlKeyDown or not IsControlKeyDown() then
        return false
    end
    if perkFrame.StartMoving then
        perkFrame._peeFrameDragging = true
        perkFrame:StartMoving()
        return true
    end
    return false
end

overlay.StopPerkFrameDrag = function(perkFrame)
    if not perkFrame or not perkFrame._peeFrameDragging then
        return false
    end
    perkFrame._peeFrameDragging = nil
    if perkFrame.StopMovingOrSizing then
        perkFrame:StopMovingOrSizing()
    end
    overlay.SavePerkFramePosition(perkFrame)
    return true
end

overlay.EnsurePerkFrameDrag = function(perkFrame)
    if not perkFrame or perkFrame._peeFrameDragReady then
        return
    end

    if perkFrame.SetMovable then
        perkFrame:SetMovable(true)
    end
    if perkFrame.SetClampedToScreen then
        perkFrame:SetClampedToScreen(true)
    end
    if perkFrame.EnableMouse then
        perkFrame:EnableMouse(true)
    end

    local function onMouseDown(self, pressedButton)
        if pressedButton == "LeftButton" then
            overlay.StartPerkFrameDrag(self)
        end
    end

    local function onMouseUp(self, pressedButton)
        if pressedButton == "LeftButton" then
            overlay.StopPerkFrameDrag(self)
        end
    end

    if perkFrame.HookScript then
        perkFrame:HookScript("OnMouseDown", onMouseDown)
        perkFrame:HookScript("OnMouseUp", onMouseUp)
    elseif perkFrame.SetScript and perkFrame.GetScript then
        local originalDown = perkFrame:GetScript("OnMouseDown")
        local originalUp = perkFrame:GetScript("OnMouseUp")
        perkFrame:SetScript("OnMouseDown", function(self, ...)
            if originalDown then
                originalDown(self, ...)
            end
            onMouseDown(self, ...)
        end)
        perkFrame:SetScript("OnMouseUp", function(self, ...)
            if originalUp then
                originalUp(self, ...)
            end
            onMouseUp(self, ...)
        end)
    end

    perkFrame._peeFrameDragReady = true
    overlay.RestorePerkFramePosition(perkFrame)
end

overlay.EnsurePerkChoiceCardFrameDrag = function(cardFrame, perkFrame)
    if not cardFrame or not perkFrame or cardFrame._peeFrameDragReady then
        return
    end

    if cardFrame.EnableMouse then
        cardFrame:EnableMouse(true)
    end

    local function onMouseDown(_, pressedButton)
        if pressedButton == "LeftButton" then
            overlay.StartPerkFrameDrag(perkFrame)
        end
    end

    local function onMouseUp(_, pressedButton)
        if pressedButton == "LeftButton" then
            overlay.StopPerkFrameDrag(perkFrame)
        end
    end

    if cardFrame.HookScript then
        cardFrame:HookScript("OnMouseDown", onMouseDown)
        cardFrame:HookScript("OnMouseUp", onMouseUp)
    elseif cardFrame.SetScript and cardFrame.GetScript then
        local originalDown = cardFrame:GetScript("OnMouseDown")
        local originalUp = cardFrame:GetScript("OnMouseUp")
        cardFrame:SetScript("OnMouseDown", function(self, ...)
            if originalDown then
                originalDown(self, ...)
            end
            onMouseDown(self, ...)
        end)
        cardFrame:SetScript("OnMouseUp", function(self, ...)
            if originalUp then
                originalUp(self, ...)
            end
            onMouseUp(self, ...)
        end)
    end

    cardFrame._peeFrameDragReady = true
end

overlay.SnapPerkButtonToCard = function(button, key, perkFrame, force)
    if not button or not button.GetCenter then
        overlay.SavePerkButtonPosition(button, key, perkFrame)
        return false
    end

    local buttonCenterX, buttonCenterY = button:GetCenter()
    if not buttonCenterX or not buttonCenterY then
        overlay.SavePerkButtonPosition(button, key, perkFrame)
        return false
    end

    local bestDistance = math.huge
    local bestFrame
    local bestCardIndex
    local bestPoint
    local bestRelativePoint
    local bestXOffset = 0
    local bestYOffset = 0
    local gap = 8

    for cardIndex = 1, 3 do
        local cardFrame = overlay.GetPerkChoiceCardFrame(cardIndex)
        local snapFrame = overlay.GetPerkSnapFrame(cardFrame)
        local left = snapFrame and snapFrame.GetLeft and snapFrame:GetLeft()
        local right = snapFrame and snapFrame.GetRight and snapFrame:GetRight()
        local bottom = snapFrame and snapFrame.GetBottom and snapFrame:GetBottom()
        local top = snapFrame and snapFrame.GetTop and snapFrame:GetTop()

        if left and right and bottom and top then
            for edgeIndex = 1, 3 do
                local edge = overlay.GetPerkCardSnapEdge(cardIndex, edgeIndex)
                local distance
                local point
                local relativePoint
                local xOffset
                local yOffset
                local threshold = (edge == "LEFT" or edge == "RIGHT") and 40 or 25

                if edge == "TOP" then
                    distance = overlay.DistanceToHorizontalSegment(buttonCenterX, buttonCenterY, left, right, top + gap)
                    point, relativePoint, xOffset, yOffset = "BOTTOM", "TOP", 0, gap
                elseif edge == "BOTTOM" then
                    distance = overlay.DistanceToHorizontalSegment(buttonCenterX, buttonCenterY, left, right,
                        bottom - gap)
                    point, relativePoint, xOffset, yOffset = "TOP", "BOTTOM", 0, -gap
                elseif edge == "LEFT" then
                    distance = overlay.DistanceToVerticalSegment(buttonCenterX, buttonCenterY, left - gap, bottom, top)
                    point, relativePoint, xOffset, yOffset = "RIGHT", "LEFT", -gap, 0
                elseif edge == "RIGHT" then
                    distance = overlay.DistanceToVerticalSegment(buttonCenterX, buttonCenterY, right + gap, bottom, top)
                    point, relativePoint, xOffset, yOffset = "LEFT", "RIGHT", gap, 0
                end

                if distance and distance < bestDistance and (force or distance <= threshold) then
                    bestDistance = distance
                    bestFrame = snapFrame
                    bestCardIndex = cardIndex
                    bestPoint = point
                    bestRelativePoint = relativePoint
                    bestXOffset = xOffset
                    bestYOffset = yOffset
                end
            end
        end
    end

    if bestFrame and button.ClearAllPoints and button.SetPoint then
        button:ClearAllPoints()
        if button.SetParent and perkFrame then
            button:SetParent(perkFrame)
        end
        button:SetPoint(bestPoint, bestFrame, bestRelativePoint, bestXOffset, bestYOffset)
        button._peeLastSnapCardIndex = bestCardIndex
    else
        button._peeLastSnapCardIndex = nil
    end

    overlay.SavePerkButtonPosition(button, key, perkFrame)
    return bestFrame ~= nil
end

overlay.FinishPerkButtonDrag = function(button, key, perkFrame)
    if not button then
        return
    end

    if button.StopMovingOrSizing then
        button:StopMovingOrSizing()
    end

    if key == "choose" then
        overlay.SavePerkButtonPosition(button, key, perkFrame)
    elseif overlay.PerkButtonOverlapsAnyCard(button) then
        overlay.SnapPerkButtonToCard(button, key, perkFrame, true)
    else
        overlay.SnapPerkButtonToCard(button, key, perkFrame, false)
    end

    button._peePerkButtonJustDragged = true
end

overlay.EnsurePerkButtonDrag = function(button, key, perkFrame)
    if not button or not key or not button.SetScript or not button.GetScript then
        return
    end

    if button.SetMovable then
        button:SetMovable(true)
    end
    if button.SetClampedToScreen then
        button:SetClampedToScreen(true)
    end
    if button.EnableMouse then
        button:EnableMouse(true)
    end

    button._peePerkButtonKey = key
    button._peePerkFrame = perkFrame

    if not button._peePerkMouseDownWrapper then
        button._peePerkMouseDownWrapper = function(self, pressedButton, ...)
            if pressedButton == "LeftButton" and IsControlKeyDown and IsControlKeyDown() then
                self._peePerkButtonDragging = true
                if self.StartMoving then
                    self:StartMoving()
                end
                return
            end

            if type(self._peeOriginalMouseDown) == "function" then
                return self._peeOriginalMouseDown(self, pressedButton, ...)
            end
        end
    end

    if not button._peePerkMouseUpWrapper then
        button._peePerkMouseUpWrapper = function(self, pressedButton, ...)
            if pressedButton == "LeftButton" and self._peePerkButtonDragging then
                self._peePerkButtonDragging = nil
                overlay.FinishPerkButtonDrag(self, self._peePerkButtonKey, self._peePerkFrame)
                return
            end

            if type(self._peeOriginalMouseUp) == "function" then
                return self._peeOriginalMouseUp(self, pressedButton, ...)
            end
        end
    end

    if not button._peePerkClickWrapper then
        button._peePerkClickWrapper = function(self, ...)
            if self._peePerkButtonJustDragged then
                self._peePerkButtonJustDragged = nil
                return
            end

            if overlay.IsPerkRecoveryShowButton and overlay.IsPerkRecoveryShowButton(self) then
                if overlay.ShowPerkChoiceFromRecovery then
                    overlay.ShowPerkChoiceFromRecovery()
                end
                return
            end

            if self._peePerkButtonKey == "reroll" and overlay.IsRerollConfirmationRemoved() and
                overlay.RequestPerkRerollDirect and overlay.RequestPerkRerollDirect() then
                return
            end

            if type(self._peeOriginalClick) == "function" then
                local a, b, c = self._peeOriginalClick(self, ...)
                if self._peePerkButtonKey == "hide" then
                    overlay.perkChoiceForceShown = false
                    if overlay.RefreshPerkChoiceTheme then
                        overlay.RefreshPerkChoiceTheme(true)
                    end
                end
                return a, b, c
            end
        end
    end

    local currentMouseDown = button:GetScript("OnMouseDown")
    if currentMouseDown ~= button._peePerkMouseDownWrapper then
        button._peeOriginalMouseDown = currentMouseDown
        button:SetScript("OnMouseDown", button._peePerkMouseDownWrapper)
    end

    local currentMouseUp = button:GetScript("OnMouseUp")
    if currentMouseUp ~= button._peePerkMouseUpWrapper then
        button._peeOriginalMouseUp = currentMouseUp
        button:SetScript("OnMouseUp", button._peePerkMouseUpWrapper)
    end

    local currentClick = button:GetScript("OnClick")
    if currentClick ~= button._peePerkClickWrapper then
        button._peeOriginalClick = currentClick
        button:SetScript("OnClick", button._peePerkClickWrapper)
    end

    overlay.RestorePerkButtonPosition(button, key, perkFrame)
end

overlay.ApplyPerkChooseButtonState = function(button, isHovered)
    if not button then
        return
    end

    if button.SetBackdropColor then
        button:SetBackdropColor(DARK[1], DARK[2], DARK[3], GetBackdropOpacity())
    end

    if button.SetBackdropBorderColor then
        local borderColor = isHovered and CHOOSE_HOVER_BORDER or BLACK
        button:SetBackdropBorderColor(borderColor[1], borderColor[2], borderColor[3], 1)
    end

    local fontString = overlay.GetPerkButtonTextFrame(button)
    if fontString and fontString.SetTextColor then
        local textColor = isHovered and WHITE or SOFT_WHITE
        SetTextColor(fontString, textColor)
    end
end

overlay.SkinPerkChooseButton = function(button)
    if not button then
        return
    end

    SetFrameSize(button, 140, 25)
    HideButtonTextures(button, true)
    SetFrameBackdrop(button, 2, 2)

    local fontString = overlay.GetPerkButtonTextFrame(button)
    if fontString then
        if fontString.ClearAllPoints then
            fontString:ClearAllPoints()
        end
        if fontString.SetPoint then
            fontString:SetPoint("CENTER", button, "CENTER", 0, 0)
        end
        if fontString.SetText then
            fontString:SetText("Select an Echo")
        end
    end

    if not button._peeChooseButtonHooks then
        local function onEnter(self)
            self._peeChooseButtonHovered = true
            overlay.ApplyPerkChooseButtonState(self, true)
        end

        local function onLeave(self)
            self._peeChooseButtonHovered = false
            overlay.ApplyPerkChooseButtonState(self, false)
        end

        if button.HookScript then
            button:HookScript("OnEnter", onEnter)
            button:HookScript("OnLeave", onLeave)
        elseif button.SetScript and button.GetScript then
            local originalEnter = button:GetScript("OnEnter")
            local originalLeave = button:GetScript("OnLeave")
            button:SetScript("OnEnter", function(self, ...)
                if originalEnter then
                    originalEnter(self, ...)
                end
                onEnter(self)
            end)
            button:SetScript("OnLeave", function(self, ...)
                if originalLeave then
                    originalLeave(self, ...)
                end
                onLeave(self)
            end)
        elseif button.SetScript then
            button:SetScript("OnEnter", onEnter)
            button:SetScript("OnLeave", onLeave)
        end

        button._peeChooseButtonHooks = true
    end

    overlay.ApplyPerkChooseButtonState(button, button._peeChooseButtonHovered and ButtonIsEnabled(button))
    overlay.EnsurePerkButtonDrag(button, "choose", _G and _G.ProjectEbonholdPerkFrame)
end

overlay.FindPerkChooseButtons = function(perkFrame)
    local buttons = {}
    local seen = {}

    local function add(button)
        if not button or seen[button] then
            return
        end

        local text = overlay.GetPerkButtonText(button) or ""
        local name = button.GetName and button:GetName()
        if button == (_G and _G.PerkChooseButton) or name == "PerkChooseButton" or
            text:find("Select an Echo", 1, true) then
            seen[button] = true
            buttons[#buttons + 1] = button
        end
    end

    add(_G and _G.PerkChooseButton)
    ForEachChildFrame(perkFrame, add)

    return buttons
end

overlay.HidePerkChooseButtons = function(perkFrame)
    for _, button in ipairs(overlay.FindPerkChooseButtons(perkFrame)) do
        if button.EnableMouse then
            button:EnableMouse(false)
        end
        if button.Hide then
            button:Hide()
        end
    end
end

overlay.ApplyPerkRerollButtonState = function(button, isHovered)
    if not button then
        return
    end

    if button.SetBackdropColor then
        local backdropColor = isHovered and REROLL_HOVER_BACKDROP or REROLL_BACKDROP
        button:SetBackdropColor(backdropColor[1], backdropColor[2], backdropColor[3], GetBackdropOpacity())
    end

    if button.SetBackdropBorderColor then
        local borderColor = isHovered and REROLL_HOVER_BORDER or BLACK
        button:SetBackdropBorderColor(borderColor[1], borderColor[2], borderColor[3], 1)
    end

    if button._rerollGlow then
        if isHovered and button._rerollGlow.Show then
            button._rerollGlow:Show()
        elseif not isHovered and button._rerollGlow.Hide then
            button._rerollGlow:Hide()
        end
    end
end

local function FindRerollButtonInParent(parent)
    if not parent or not parent.GetChildren then
        return nil
    end

    local children = { parent:GetChildren() }
    for _, childFrame in ipairs(children) do
        local text = overlay.GetPerkButtonText(childFrame)
        if text and text:find("Reroll", 1, true) == 1 then
            return childFrame
        end
    end

    return nil
end

overlay.FindPerkRerollButton = function(perkFrame)
    return FindRerollButtonInParent(perkFrame) or FindRerollButtonInParent(_G and _G.UIParent)
end

overlay.SkinPerkRerollButton = function(perkFrame)
    local button = overlay.FindPerkRerollButton(perkFrame)
    if not button then
        return
    end

    local rerollCount = tonumber((overlay.GetPerkButtonText(button) or ""):match("Reroll%s*%((%d+)%)"))
    if rerollCount == 0 or not overlay.HasShownPerkChoiceCard() or overlay.HasNoPendingPerkChoices() or
        overlay.IsPerkChoiceHidden(perkFrame) or
        (overlay.IsPlayerRunMinimized() and not overlay.perkChoiceForceShown) then
        if button.Hide then
            button:Hide()
        end
        return
    elseif button.Show then
        button:Show()
    end

    SetFrameSize(button, 120, 25)
    if button.ClearAllPoints then
        button:ClearAllPoints()
    end
    local rerollAnchor = overlay.GetPerkChoiceGroupAnchorFrame() or perkFrame
    if button.SetPoint then
        button:SetPoint("BOTTOM", rerollAnchor, "TOP", 0, 20)
    end
    if button.SetFrameStrata then
        button:SetFrameStrata("DIALOG")
    end
    if button.SetFrameLevel and perkFrame and perkFrame.GetFrameLevel then
        button:SetFrameLevel(perkFrame:GetFrameLevel() + 20)
    end

    HideButtonTextures(button, true)
    SetFrameBackdrop(button, 2, 2)

    if not button._rerollGlow and button.CreateTexture then
        local rerollGlow = button:CreateTexture(nil, "OVERLAY")
        rerollGlow._peeAllowRuntimeVisual = true
        rerollGlow:SetAllPoints(button)
        rerollGlow:SetTexture("Interface\\Tooltips\\UI-Tooltip-Background")
        if rerollGlow.SetBlendMode then
            rerollGlow:SetBlendMode("ADD")
        end
        rerollGlow:SetVertexColor(0.5, 0.14, 0.14, 0.4)
        rerollGlow:Hide()
        button._rerollGlow = rerollGlow
    end

    if not button._peeRerollButtonHooks then
        local function onEnter(self)
            self._peeRerollButtonHovered = true
            overlay.ApplyPerkRerollButtonState(self, ButtonIsEnabled(self))
        end

        local function onLeave(self)
            self._peeRerollButtonHovered = false
            overlay.ApplyPerkRerollButtonState(self, false)
        end

        if button.HookScript then
            button:HookScript("OnEnter", onEnter)
            button:HookScript("OnLeave", onLeave)
        elseif button.SetScript and button.GetScript then
            local originalEnter = button:GetScript("OnEnter")
            local originalLeave = button:GetScript("OnLeave")
            button:SetScript("OnEnter", function(self, ...)
                if originalEnter then
                    originalEnter(self, ...)
                end
                onEnter(self)
            end)
            button:SetScript("OnLeave", function(self, ...)
                if originalLeave then
                    originalLeave(self, ...)
                end
                onLeave(self)
            end)
        elseif button.SetScript then
            button:SetScript("OnEnter", onEnter)
            button:SetScript("OnLeave", onLeave)
        end

        button._peeRerollButtonHooks = true
    end

    overlay.ApplyPerkRerollButtonState(button, button._peeRerollButtonHovered and ButtonIsEnabled(button))
    overlay.EnsurePerkButtonDrag(button, "reroll", perkFrame)
end

overlay.CountOwnedPerkInstances = function(spellId)
    local project = _G and _G.ProjectEbonhold
    local perkService = project and project.PerkService
    local granted = perkService and perkService.GetGrantedPerks and perkService.GetGrantedPerks() or {}
    local locked = perkService and perkService.GetLockedPerks and perkService.GetLockedPerks() or {}
    local spellName = _G and _G.GetSpellInfo and _G.GetSpellInfo(spellId)
    local count = 0
    local qualityCounts = { [0] = 0, [1] = 0, [2] = 0, [3] = 0, [4] = 0 }
    granted = overlay.GetMergedGrantedPerksForOverlay and overlay.GetMergedGrantedPerksForOverlay(granted) or granted

    local function addInstances(instances, useStack)
        for _, instance in ipairs(instances or {}) do
            local quality = instance.quality or 0
            local stacks = useStack and (instance.stack or 1) or 1
            qualityCounts[quality] = (qualityCounts[quality] or 0) + stacks
            count = count + stacks
        end
    end

    if spellName and granted[spellName] then
        addInstances(granted[spellName], false)
    end

    if count == 0 and spellId and granted then
        for _, instances in pairs(granted) do
            if instances and #instances > 0 and instances[1].spellId == spellId then
                addInstances(instances, false)
                break
            end
        end
    end

    if count == 0 and project and project.PerkDatabase and project.PerkDatabase[spellId] then
        local cardGroupId = project.PerkDatabase[spellId].groupId
        if cardGroupId then
            for _, instances in pairs(granted or {}) do
                if instances and #instances > 0 then
                    local entryDbInfo = project.PerkDatabase[instances[1].spellId]
                    if entryDbInfo and entryDbInfo.groupId == cardGroupId then
                        addInstances(instances, false)
                    end
                end
            end
        end
    end

    for _, instance in ipairs(locked or {}) do
        local lockedName = _G and _G.GetSpellInfo and _G.GetSpellInfo(instance.spellId)
        if instance.spellId == spellId or (lockedName and lockedName == spellName) then
            addInstances({ instance }, true)
        end
    end

    return count, qualityCounts
end

overlay.RefreshVisiblePerkOwnedCounts = function()
    for index = 1, 3 do
        local frame = _G and _G["PerkChoice" .. index]
        if frame and frame._spellId and (not frame.IsShown or frame:IsShown()) then
            local count, qualityCounts = overlay.CountOwnedPerkInstances(frame._spellId)
            frame._ownedCount = count
            frame._ownedQualities = qualityCounts
            if frame.ownedCountFrame and frame.ownedCountText then
                if count >= 1 then
                    frame.ownedCountText:SetText("x" .. tostring(count))
                    frame.ownedCountFrame:Show()
                else
                    frame.ownedCountFrame:Hide()
                end
            end
        end
    end
end

overlay.AnchorPerkAutoShowCheckbox = function()
    local checkbox = _G and _G.EbonholdAutoShowCheck
    local text = _G and _G.EbonholdAutoShowCheckText
    local cards = overlay.GetVisiblePerkChoiceCards()
    local lastCard = overlay.GetPerkChoiceCardFrame(3, true) or cards[#cards]
    local perkFrame = _G and _G.ProjectEbonholdPerkFrame

    local anchor = lastCard and (lastCard.backdropFrame or lastCard)
    local parent = perkFrame or (_G and _G.UIParent) or anchor
    if not text and checkbox and checkbox.CreateFontString then
        checkbox.peeAutoShowText = checkbox.peeAutoShowText or
            checkbox:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        text = checkbox.peeAutoShowText
    end

    if checkbox and anchor then
        if checkbox.SetChecked then
            checkbox:SetChecked(overlay.IsAutoShowEchoChoicesEnabled())
        end
        if checkbox.SetScript and not checkbox._peeAutoShowOwned then
            checkbox:SetScript("OnClick", function(self)
                SetSetting("autoShowEchoChoices", self:GetChecked() == 1 or self:GetChecked() == true)
                overlay.perkChoiceForceShown = overlay.IsAutoShowEchoChoicesEnabled()
                if overlay.RefreshPerkChoiceTheme then
                    overlay.RefreshPerkChoiceTheme(true)
                end
            end)
            checkbox._peeAutoShowOwned = true
        end
        if checkbox.ClearAllPoints then
            checkbox:ClearAllPoints()
        end
        if checkbox.SetParent and parent then
            checkbox:SetParent(parent)
        end
        if checkbox.SetFrameLevel and parent and parent.GetFrameLevel then
            checkbox:SetFrameLevel(parent:GetFrameLevel() + 20)
        end
        if checkbox.SetPoint then
            checkbox:SetPoint("TOPRIGHT", anchor, "BOTTOMRIGHT", 0, -12)
        end
        if checkbox.Show then
            checkbox:Show()
        end
    end

    if text and anchor then
        if text.SetParent and parent then
            text:SetParent(parent)
        end
        ConfigurePerkChoiceText(text, 12, CREAM, 130, "RIGHT")
        if text.SetText then
            text:SetText("Auto Show Echoes")
        end
        if text.ClearAllPoints then
            text:ClearAllPoints()
        end
        if text.SetPoint then
            if checkbox then
                text:SetPoint("RIGHT", checkbox, "LEFT", -4, 0)
            else
                text:SetPoint("TOPRIGHT", anchor, "BOTTOMRIGHT", 0, -12)
            end
        end
        if text.SetJustifyH then
            text:SetJustifyH("RIGHT")
        end
        if text.Show then
            text:Show()
        end
    end
end

overlay.HidePerkAutoShowCheckbox = function()
    local checkbox = _G and _G.EbonholdAutoShowCheck
    if checkbox and checkbox.Hide then
        checkbox:Hide()
    end

    local text = _G and _G.EbonholdAutoShowCheckText
    if text and text.Hide then
        text:Hide()
    end
    if checkbox and checkbox.peeAutoShowText and checkbox.peeAutoShowText.Hide then
        checkbox.peeAutoShowText:Hide()
    end
end

overlay.HidePerkChoiceSurfaces = function(keepRecoveryButton)
    local perkFrame = _G and _G.ProjectEbonholdPerkFrame
    overlay.SetPerkChoiceHitboxesEnabled(false)
    if perkFrame and perkFrame.SetAlpha then
        perkFrame:SetAlpha(1)
    end
    if not keepRecoveryButton and perkFrame and perkFrame.Hide then
        perkFrame:Hide()
    end

    for index = 1, 3 do
        local frame = _G and _G["PerkChoice" .. index]
        if frame and frame.Hide then
            frame:Hide()
        end
    end

    local rerollButton = overlay.FindPerkRerollButton and overlay.FindPerkRerollButton(perkFrame)
    if rerollButton and rerollButton.Hide then
        rerollButton:Hide()
    end

    local hideButton = _G and _G.PerkHideButton
    if keepRecoveryButton then
        overlay.ShowPerkRecoveryButton(perkFrame)
    elseif hideButton and hideButton.Hide then
        hideButton:Hide()
    end

    overlay.HidePerkChooseButtons(perkFrame)

    local hintFrame = _G and _G.PerkFamilyHintFrame
    if hintFrame and hintFrame.Hide then
        hintFrame:Hide()
    end

    overlay.HidePerkAutoShowCheckbox()
end

local function ApplyPerkChoiceTheme()
    if not overlay.enabled or overlay.isPTR then
        return
    end

    overlay.EnsurePerkButtonLayoutVersion()
    overlay.ApplyPerkUIScale()

    if overlay.HasNoPendingPerkChoices() then
        overlay.perkChoiceForceShown = false
        overlay.HidePerkChoiceSurfaces(false)
        return
    end

    if overlay.IsPlayerRunMinimized() and not overlay.perkChoiceForceShown then
        overlay.HidePerkChoiceSurfaces(true)
        return
    end

    for index = 1, 3 do
        ApplySinglePerkChoiceTheme(_G and _G["PerkChoice" .. index])
    end

    local perkFrame = _G and _G.ProjectEbonholdPerkFrame
    local hasShownCard = overlay.HasShownPerkChoiceCard()
    local perksHidden = overlay.IsPerkChoiceHidden(perkFrame) and not hasShownCard
    if not hasShownCard and not perksHidden then
        overlay.perkChoiceForceShown = false
        overlay.HidePerkChoiceSurfaces(false)
        return
    end
    overlay.SetPerkChoiceHitboxesEnabled(not perksHidden)
    if perkFrame and perkFrame.SetAlpha then
        perkFrame:SetAlpha(1)
    end
    overlay.EnsurePerkFrameDrag(perkFrame)
    for index = 1, 3 do
        overlay.EnsurePerkChoiceCardFrameDrag(_G and _G["PerkChoice" .. index], perkFrame)
    end
    overlay.SetPerkChoiceHitboxesEnabled(not perksHidden)
    if not perksHidden then
        overlay.ReanchorPerkChoiceCards(perkFrame)
    end
    local hideButton = _G and _G.PerkHideButton
    if hideButton then
        SetFrameSize(hideButton, 120, 25)
        if not perksHidden then
            if hideButton.ClearAllPoints then
                hideButton:ClearAllPoints()
            end
            local hideAnchor = overlay.GetPerkChoiceGroupAnchorFrame() or perkFrame
            if hideButton.SetPoint and hideAnchor then
                hideButton:SetPoint("TOP", hideAnchor, "BOTTOM", 0, -20)
            end
        end
    end
    SkinRuntimeButton(hideButton, DARK, MUTED, BLACK, HOVER_BLUE_BACKDROP, HOVER_BLUE)
    overlay.EnsurePerkButtonDrag(hideButton, "hide", perkFrame)
    if perksHidden then
        overlay.ShowPerkRecoveryButton(perkFrame)
    elseif hideButton and hideButton.EnableMouse then
        hideButton:EnableMouse(true)
    end
    local chooseButton = _G and _G.PerkChooseButton
    overlay.SkinPerkChooseButton(chooseButton)
    if perksHidden then
        overlay.HidePerkChooseButtons(perkFrame)
    else
        for _, button in ipairs(overlay.FindPerkChooseButtons(perkFrame)) do
            if button ~= chooseButton and button.Hide then
                button:Hide()
            end
        end
    end
    overlay.SkinPerkRerollButton(perkFrame)

    local autoShowText = _G and _G.EbonholdAutoShowCheckText
    if autoShowText and autoShowText.SetTextColor then
        autoShowText:SetTextColor(CREAM[1], CREAM[2], CREAM[3], 1)
    end
    if perksHidden then
        overlay.HidePerkAutoShowCheckbox()
    else
        overlay.AnchorPerkAutoShowCheckbox()
    end

    ApplyPerkFamilyHintTheme()
    overlay.RefreshVisiblePerkOwnedCounts()

    if overlay.ApplyPerkChoiceExtras then
        overlay.ApplyPerkChoiceExtras()
    end
end

overlay.ApplyPerkChoiceTheme = ApplyPerkChoiceTheme

function overlay.PerkChoiceFrameShownSignature(frame)
    if not frame then
        return "missing"
    end

    if frame.IsShown and not frame:IsShown() then
        return "hidden"
    end

    return "shown"
end

function overlay.PerkChoiceButtonSignature(button)
    if not button then
        return "missing"
    end

    local shown = overlay.PerkChoiceFrameShownSignature(button)
    local enabled = ButtonIsEnabled(button) and "enabled" or "disabled"
    local text = overlay.GetPerkButtonText and overlay.GetPerkButtonText(button) or ""
    return shown .. ":" .. enabled .. ":" .. tostring(text or "")
end

function overlay.PerkChoiceCardSignature(frame)
    if not frame then
        return "missing"
    end

    return table.concat({
        overlay.PerkChoiceFrameShownSignature(frame),
        overlay.PerkChoiceFrameShownSignature(frame.backdropFrame),
        tostring(frame._spellId or ""),
        tostring(frame._stacks or ""),
        overlay.IsPerkChoiceFrozen(frame) and "frozen" or "normal",
        overlay.PerkChoiceButtonSignature(frame.selectButton),
        overlay.PerkChoiceButtonSignature(frame.freezeCardButton),
        overlay.PerkChoiceButtonSignature(frame.banishCardButton)
    }, "/")
end

overlay.GetPerkChoiceThemeSignature = function()
    local perkFrame = _G and _G.ProjectEbonholdPerkFrame
    local autoShowCheck = _G and _G.EbonholdAutoShowCheck
    local parts = {
        overlay.PerkChoiceFrameShownSignature(perkFrame),
        overlay.IsPerkChoiceHidden(perkFrame) and "hidden" or "visible",
        overlay.IsPlayerRunMinimized() and "minimized" or "normal",
        tostring(overlay.GetPerkUIScale()),
        overlay.IsAutoShowEchoChoicesEnabled() and "auto" or "manual",
        tostring(overlay.GetPendingPerkSelectCount and overlay.GetPendingPerkSelectCount() or ""),
        overlay.PerkChoiceButtonSignature(_G and _G.PerkHideButton),
        overlay.PerkChoiceButtonSignature(_G and _G.PerkChooseButton),
        overlay.PerkChoiceButtonSignature(overlay.FindPerkRerollButton and overlay.FindPerkRerollButton(perkFrame)),
        overlay.PerkChoiceFrameShownSignature(autoShowCheck),
        overlay.PerkChoiceFrameShownSignature(_G and _G.EbonholdAutoShowCheckText),
        overlay.PerkChoiceFrameShownSignature(autoShowCheck and autoShowCheck.peeAutoShowText)
    }

    for index = 1, 3 do
        parts[#parts + 1] = overlay.PerkChoiceCardSignature(_G and _G["PerkChoice" .. index])
    end

    return table.concat(parts, "|")
end

function overlay.RefreshPerkChoiceTheme(force)
    local signature = overlay.GetPerkChoiceThemeSignature()
    if not force and signature == overlay._perkChoiceThemeSignature then
        return
    end

    ApplyPerkChoiceTheme()
    overlay._perkChoiceThemeSignature = overlay.GetPerkChoiceThemeSignature()
end

local function WrapPerkUIFunction(perkUI, functionName)
    local original = perkUI and perkUI[functionName]
    if type(original) ~= "function" or perkUI["_peeWrapped" .. functionName] then
        return
    end

    perkUI["_peeWrapped" .. functionName] = true
    perkUI[functionName] = function(...)
        local autoShowStore = _G and _G.EbonholdAutoShowDB
        local shouldRestoreAutoShow = false
        local previousAutoShow
        if functionName == "Show" and type(autoShowStore) == "table" then
            shouldRestoreAutoShow = true
            previousAutoShow = autoShowStore.enabled
            autoShowStore.enabled = overlay.IsAutoShowEchoChoicesEnabled()
        end

        local ok, a, b, c = pcall(original, ...)
        if shouldRestoreAutoShow then
            autoShowStore.enabled = previousAutoShow
        end
        if not ok then
            error(a)
        end

        overlay.RefreshPerkChoiceTheme(true)
        if functionName == "Show" and not overlay._peeAutoOpeningPerkChoices and
            (overlay._peeRerollAutoRepopulate or overlay.IsAutoShowEchoChoicesEnabled()) then
            overlay._peeRerollAutoRepopulate = nil
            overlay._peeAutoOpeningPerkChoices = true
            if overlay.ShowPerkChoiceFromRecovery then
                overlay.ShowPerkChoiceFromRecovery()
            end
            overlay._peeAutoOpeningPerkChoices = nil
        end
        return a, b, c
    end
end

local function EnsurePerkChoiceThemeWatcher()
    if overlay.perkChoiceThemeWatcher then
        return
    end

    local watcher = CreateFrame("Frame")
    watcher.elapsed = 0
    watcher:SetScript("OnUpdate", function(self, elapsed)
        if not overlay.enabled or overlay.isPTR then
            return
        end

        local perkFrame = _G and _G.ProjectEbonholdPerkFrame
        if not perkFrame or (perkFrame.IsShown and not perkFrame:IsShown()) then
            return
        end

        self.elapsed = (self.elapsed or 0) + elapsed
        if self.elapsed < 0.1 then
            return
        end

        self.elapsed = 0
        overlay.RefreshPerkChoiceTheme(false)
    end)

    overlay.perkChoiceThemeWatcher = watcher
end

local function InstallPerkChoiceThemeHooks()
    if not overlay.enabled or overlay.isPTR then
        return
    end

    local perkUI = _G and _G.ProjectEbonhold and _G.ProjectEbonhold.PerkUI
    if not perkUI then
        return
    end

    WrapPerkUIFunction(perkUI, "Show")
    WrapPerkUIFunction(perkUI, "UpdateSinglePerk")
    WrapPerkUIFunction(perkUI, "ApplyScale")
    WrapPerkUIFunction(perkUI, "ResetSelection")
    WrapPerkUIFunction(perkUI, "RefreshBanishText")
    if type(perkUI.RefreshOwnedCounts) ~= "function" then
        perkUI.RefreshOwnedCounts = function()
            overlay.RefreshVisiblePerkOwnedCounts()
        end
    end
    WrapPerkUIFunction(perkUI, "RefreshOwnedCounts")

    EnsurePerkChoiceThemeWatcher()
    overlay.RefreshPerkChoiceTheme(true)
end

overlay.InstallPerkChoiceThemeHooks = InstallPerkChoiceThemeHooks

local function SetExtractionBackdrop(frame, edgeSize, inset, alpha, borderColor)
    if not frame then
        return
    end

    SetFrameBackdrop(frame, edgeSize, inset)

    if frame.SetBackdropColor then
        local backdropAlpha = alpha
        if backdropAlpha == nil then
            backdropAlpha = GetBackdropOpacity()
        end
        frame:SetBackdropColor(DARK[1], DARK[2], DARK[3], backdropAlpha)
    end

    if frame.SetBackdropBorderColor then
        local color = borderColor or BLACK
        frame:SetBackdropBorderColor(color[1], color[2], color[3], 1)
    end
end

local function ConfigureExtractionText(fontString, size, color, width, justifyH)
    if not fontString then
        return
    end

    if fontString.SetFont then
        fontString:SetFont("Fonts\\FRIZQT__.TTF", ScaledFontSize(size), "OUTLINE")
    end

    if width and fontString.SetWidth then
        fontString:SetWidth(width)
    end

    if fontString.SetWordWrap then
        fontString:SetWordWrap(true)
    end

    if fontString.SetNonSpaceWrap then
        fontString:SetNonSpaceWrap(false)
    end

    if justifyH and fontString.SetJustifyH then
        fontString:SetJustifyH(justifyH)
    end

    if color and fontString.SetTextColor then
        fontString:SetTextColor(color[1], color[2], color[3], 1)
    end
end

local function GetFontStringText(fontString)
    if not fontString then
        return nil
    end

    if fontString.GetText then
        return fontString:GetText()
    end

    return fontString.text
end

overlay.LayoutExtractionActionButton = function(button, extractionFrame, side)
    if not button or not extractionFrame then
        return
    end

    local frameWidth = (extractionFrame.GetWidth and extractionFrame:GetWidth()) or 300
    if frameWidth <= 0 then
        frameWidth = 300
    end

    local gap = 10
    local minimumMargin = 15
    local buttonWidth = math.floor((frameWidth - (minimumMargin * 2) - gap) / 2)
    if buttonWidth > 150 then
        buttonWidth = 150
    elseif buttonWidth < 100 then
        buttonWidth = 100
    end

    local margin = math.floor((frameWidth - (buttonWidth * 2) - gap) / 2)
    if margin < minimumMargin then
        margin = minimumMargin
    end

    SetFrameSize(button, buttonWidth, 34)
    if button.ClearAllPoints then
        button:ClearAllPoints()
    end
    if not button.SetPoint then
        return
    end

    if side == "left" then
        button:SetPoint("BOTTOMLEFT", extractionFrame, "BOTTOMLEFT",
            margin, 44)
        return
    end

    button:SetPoint("BOTTOMRIGHT", extractionFrame, "BOTTOMRIGHT",
        -margin, 44)
end

overlay.ShowAffixBook = function()
    if overlay.isPTR or not overlay.enabled then
        PrintMessage("Inactive on PTR.")
        return false
    end

    local extractionUI = _G and _G.ExtractionUI
    if not extractionUI or type(extractionUI.ShowSidePanel) ~= "function" then
        PrintMessage("Affix Book is not available yet.")
        return false
    end

    local extractionFrame = _G and _G.EbonholdExtractionFrame
    if extractionFrame and extractionFrame.Show then
        extractionFrame:Show()
    end

    extractionUI.ShowSidePanel()

    if overlay.ApplyExtractionTheme then
        overlay.ApplyExtractionTheme()
    end

    return true
end

overlay.ShowExtractionFrame = function(showAffixBook)
    if overlay.isPTR or not overlay.enabled then
        PrintMessage("Inactive on PTR.")
        return false
    end

    local extractionUI = _G and _G.ExtractionUI
    local extractionFrame = _G and _G.EbonholdExtractionFrame
    if extractionFrame and extractionFrame.Show then
        extractionFrame:Show()
        if showAffixBook and extractionUI and type(extractionUI.ShowSidePanel) == "function" then
            extractionUI.ShowSidePanel()
        end
        if overlay.ApplyExtractionTheme then
            overlay.ApplyExtractionTheme()
        end
        return true
    end

    if extractionUI and type(extractionUI.Toggle) == "function" then
        extractionUI.Toggle()
        if showAffixBook and type(extractionUI.ShowSidePanel) == "function" then
            extractionUI.ShowSidePanel()
        end
        if overlay.ApplyExtractionTheme then
            overlay.ApplyExtractionTheme()
        end
        return true
    end

    PrintMessage("Extraction is not available yet.")
    return false
end

overlay.EnsureExtractionAffixButton = function(extractionFrame)
    local createFrame = _G and _G.CreateFrame
    if not extractionFrame or not createFrame then
        return
    end

    if not extractionFrame.peeAffixButton then
        local button = createFrame("Button", "PEEExtractionAffixButton", extractionFrame)
        if button.SetFrameLevel and extractionFrame.GetFrameLevel then
            button:SetFrameLevel((extractionFrame:GetFrameLevel() or 1) + 20)
        end

        button.text = button:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        button.text:SetPoint("CENTER", button, "CENTER", 0, 0)
        button.text:SetText("Affixes")
        ConfigureExtractionText(button.text, 10, WHITE, nil, "CENTER")
        button:SetScript("OnClick", function()
            overlay.ShowAffixBook()
        end)

        extractionFrame.peeAffixButton = button
    end

    overlay.LayoutExtractionActionButton(extractionFrame.peeAffixButton, extractionFrame, "right")
    if extractionFrame.peeAffixButton.Show then
        extractionFrame.peeAffixButton:Show()
    end
    if extractionFrame.peeAffixButton.Enable then
        extractionFrame.peeAffixButton:Enable()
    end
    if extractionFrame.peeAffixButton.SetAlpha then
        extractionFrame.peeAffixButton:SetAlpha(1)
    end

    SkinRuntimeButton(extractionFrame.peeAffixButton, BANISH_BACKDROP, WHITE, BLACK,
        BANISH_HOVER_BACKDROP, overlay.buttonBorders.banishHover)
end

local function ButtonTextMatches(button, labels)
    local fontString = button and button.text
    if button and button.GetFontString then
        fontString = button:GetFontString() or fontString
    end

    local text = GetFontStringText(fontString)
    if not text then
        return false
    end

    for _, label in ipairs(labels) do
        if text:find(label, 1, true) then
            return true
        end
    end

    return false
end

local function SkinMatchingButtons(parent, labels)
    if not parent or not parent.GetChildren then
        return
    end

    local children = { parent:GetChildren() }
    for _, child in ipairs(children) do
        if ButtonTextMatches(child, labels) then
            SkinRuntimeButton(child, BANISH_BACKDROP, WHITE, BLACK, BANISH_HOVER_BACKDROP,
                overlay.buttonBorders.banishHover)
        end

        SkinMatchingButtons(child, labels)
    end
end

overlay.RefreshExtractionActionButtons = function(extractionFrame)
    if not extractionFrame then
        return
    end

    local extractButton = extractionFrame.peeExtractButton
    local applyButton = extractionFrame.peeServerApplyButton

    local function scan(parent)
        if not parent or not parent.GetChildren then
            return
        end

        for _, child in ipairs({ parent:GetChildren() }) do
            if child ~= extractionFrame.peeAffixButton then
                if not extractButton and ButtonTextMatches(child, { "Extract" }) then
                    extractButton = child
                elseif not applyButton and
                    ButtonTextMatches(child, {
                        "Choose an Affix",
                        "Change the Affix",
                        "Apply Affix",
                        "Change Affix",
                    }) then
                    applyButton = child
                end
            end
            scan(child)
        end
    end

    scan(extractionFrame)
    extractionFrame.peeExtractButton = extractButton
    extractionFrame.peeServerApplyButton = applyButton

    if applyButton then
        if applyButton.Disable then
            applyButton:Disable()
        end
        if applyButton.Hide then
            applyButton:Hide()
        end
        if applyButton.SetAlpha then
            applyButton:SetAlpha(0)
        end
    end

    if extractButton then
        local extractionUI = _G and _G.ExtractionUI
        local hasItem = extractionUI and extractionUI.pendingLink
        local serverVisible = not extractButton.IsShown or extractButton:IsShown()
        local serverEnabled = ButtonIsEnabled(extractButton)
        local canExtract = hasItem and serverVisible and serverEnabled

        overlay.LayoutExtractionActionButton(extractButton, extractionFrame, "left")
        if extractButton.Show then
            extractButton:Show()
        end
        if canExtract and extractButton.Enable then
            extractButton:Enable()
        elseif extractButton.Disable then
            extractButton:Disable()
        end
        if extractButton.SetAlpha then
            extractButton:SetAlpha(1)
        end

        SkinRuntimeButton(extractButton, canExtract and BANISH_BACKDROP or {0.12, 0.12, 0.12},
            canExtract and WHITE or MUTED, BLACK, BANISH_HOVER_BACKDROP, overlay.buttonBorders.banishHover)
    end

    overlay.EnsureExtractionAffixButton(extractionFrame)
end

local function SkinAffixRows(panel)
    local function skinRows(rows)
        if type(rows) == "table" then
            for _, row in ipairs(rows) do
                if row then
                    ConfigureExtractionText(row.text or row.nameText, 11, CREAM, nil, "LEFT")

                    if row.hoverTex and row.hoverTex.SetVertexColor then
                        row.hoverTex:SetVertexColor(HOVER_BLUE[1], HOVER_BLUE[2], HOVER_BLUE[3], 0.35)
                    end

                    if row.selectedTex and row.selectedTex.SetVertexColor then
                        row.selectedTex:SetVertexColor(HOVER_BLUE_BACKDROP[1], HOVER_BLUE_BACKDROP[2],
                            HOVER_BLUE_BACKDROP[3], 0.85)
                    end

                    if overlay.WrapAffixBookRowClick then
                        overlay.WrapAffixBookRowClick(panel, row)
                    end
                end
            end
        end
    end

    skinRows(panel and panel.affixRows)
    skinRows(panel and panel.affixListRows)
end

overlay.affixTierLayout = {
    iconSize = 28,
    gap = 8,
    bottom = 58,
    scrollBottom = 94
}

overlay.affixTierRomans = {"I", "II", "III", "IV", "V"}
overlay.affixTierRomanValues = {
    I = 1,
    II = 2,
    III = 3,
    IV = 4,
    V = 5
}

overlay.GetAffixRowText = function(row)
    return GetFontStringText(row and (row.nameText or row.text or row.lastFontString)) or ""
end

overlay.ParseAffixNameAndTier = function(text)
    text = tostring(text or "")
    text = text:gsub("|c%x%x%x%x%x%x%x%x", ""):gsub("|r", "")
    text = text:gsub("%s+%([xX]?%d+%)", ""):gsub("^%s+", ""):gsub("%s+$", "")

    local baseName, roman = text:match("^(.-)%s+([IVX]+)$")
    local tier = overlay.affixTierRomanValues[roman or ""]
    if baseName and tier then
        return baseName:gsub("%s+$", ""), tier
    end

    return text, 1
end

overlay.GetAffixBookRows = function(panel)
    local rows = {}
    local seen = {}
    local function append(source)
        if type(source) ~= "table" then
            return
        end

        for _, row in ipairs(source) do
            if row and not seen[row] then
                rows[#rows + 1] = row
                seen[row] = true
            end
        end
    end

    append(panel and panel.affixRows)
    append(panel and panel.affixListRows)
    return rows
end

overlay.GetAffixTierState = function(panel)
    local state = {
        families = {},
        order = {}
    }

    for _, row in ipairs(overlay.GetAffixBookRows(panel)) do
        local isShown = not row.IsShown or row:IsShown()
        if isShown then
            local baseName, tier = overlay.ParseAffixNameAndTier(overlay.GetAffixRowText(row))
            if baseName and baseName ~= "" then
                if not state.families[baseName] then
                    state.families[baseName] = { tiers = {} }
                    state.order[#state.order + 1] = baseName
                end
                state.families[baseName].tiers[tier] = row
            end
        end
    end

    return state
end

overlay.ClickAffixBookRow = function(row)
    if not row then
        return
    end

    local onClick = row.GetScript and row:GetScript("OnClick")
    if type(onClick) == "function" then
        onClick(row)
    elseif row.Click then
        row:Click()
    end
end

overlay.WrapAffixBookRowClick = function(panel, row)
    if not panel or not row or not row.GetScript or not row.SetScript or row._peeAffixRowClickWrapped then
        return
    end

    local originalClick = row:GetScript("OnClick")
    if type(originalClick) ~= "function" then
        return
    end

    row:SetScript("OnClick", function(self, ...)
        local firstResult, secondResult, thirdResult = originalClick(self, ...)
        local baseName, tier = overlay.ParseAffixNameAndTier(overlay.GetAffixRowText(self))
        panel._peeSelectedAffixBase = baseName
        panel._peeSelectedAffixTier = tier
        overlay.RefreshAffixTierSelector(panel)
        return firstResult, secondResult, thirdResult
    end)
    row._peeAffixRowClickWrapped = true
end

overlay.NormalizeAffixConfirmButton = function(panel)
    local button = panel and panel.confirmBtn
    if not button and panel and panel.GetChildren then
        local children = { panel:GetChildren() }
        for _, child in ipairs(children) do
            if ButtonTextMatches(child, { "Confirm" }) then
                button = child
                break
            end
        end
    end

    local fontString = button and (button.text or (button.GetFontString and button:GetFontString()))
    local text = GetFontStringText(fontString)
    if not button or not text or not text:find("Confirm Apply", 1, true) then
        return
    end

    local suffix = text:match("^Confirm Apply%s+(.+)$")
    local replacement = suffix and ("Confirm  " .. suffix) or "Confirm"
    if button.SetText then
        button:SetText(replacement)
    elseif fontString and fontString.SetText then
        fontString:SetText(replacement)
    end
end

overlay.RefreshAffixTierSelector = function(panel)
    local selector = panel and panel.peeTierSelector
    if not selector or type(selector.buttons) ~= "table" then
        return
    end

    local state = overlay.GetAffixTierState(panel)
    local selectedBase = panel._peeSelectedAffixBase
    if not selectedBase or not state.families[selectedBase] then
        selectedBase = state.order[1]
        panel._peeSelectedAffixBase = selectedBase
    end

    local selectedTier = panel._peeSelectedAffixTier
    for tier, button in ipairs(selector.buttons) do
        local hasTier = selectedBase and state.families[selectedBase] and state.families[selectedBase].tiers[tier]
        local active = hasTier and selectedTier == tier
        SetButtonBackdrop(button, active and HOVER_BLUE_BACKDROP or DARK, BLACK)
        if button.SetAlpha then
            button:SetAlpha(hasTier and 1 or 0.35)
        end
        if hasTier and button.Enable then
            button:Enable()
        elseif not hasTier and button.Disable then
            button:Disable()
        end
        ConfigureExtractionText(button.text, 10, hasTier and WHITE or MUTED, nil, "CENTER")
    end
end

overlay.SelectAffixTier = function(panel, tier)
    local state = overlay.GetAffixTierState(panel)
    local selectedBase = panel and panel._peeSelectedAffixBase
    if not selectedBase or not state.families[selectedBase] then
        selectedBase = state.order[1]
    end

    local row = selectedBase and state.families[selectedBase] and state.families[selectedBase].tiers[tier]
    if not row then
        overlay.RefreshAffixTierSelector(panel)
        return
    end

    panel._peeSelectedAffixBase = selectedBase
    panel._peeSelectedAffixTier = tier
    overlay.ClickAffixBookRow(row)
    overlay.RefreshAffixTierSelector(panel)
end

overlay.SelectAffixBookRow = function(panel, row)
    local baseName, tier = overlay.ParseAffixNameAndTier(overlay.GetAffixRowText(row))
    panel._peeSelectedAffixBase = baseName
    panel._peeSelectedAffixTier = tier
    overlay.ClickAffixBookRow(row)
    overlay.RefreshAffixTierSelector(panel)
end

overlay.WrapAffixBookSearchBox = function(panel)
    local searchBox = panel and (panel.searchBox or (_G and _G.EbonholdAffixSearchBox))
    if not searchBox or not searchBox.GetScript or not searchBox.SetScript or searchBox._peeAffixEnterWrapped then
        return
    end

    local originalEnter = searchBox:GetScript("OnEnterPressed")
    searchBox:SetScript("OnEnterPressed", function(self, ...)
        local searchText = self.GetText and self:GetText() or ""
        searchText = string.lower(searchText:gsub("^%s+", ""):gsub("%s+$", ""))

        if searchText ~= "" then
            for _, row in ipairs(overlay.GetAffixBookRows(panel)) do
                local rowText = string.lower(overlay.GetAffixRowText(row))
                if rowText:find(searchText, 1, true) then
                    overlay.SelectAffixBookRow(panel, row)
                    if self.ClearFocus then
                        self:ClearFocus()
                    end
                    return
                end
            end
        end

        if type(originalEnter) == "function" then
            originalEnter(self, ...)
        end
    end)
    searchBox._peeAffixEnterWrapped = true
end

overlay.EnsureAffixTierSelector = function(panel)
    local createFrame = _G and _G.CreateFrame
    if not panel or not createFrame then
        return
    end

    local layout = overlay.affixTierLayout
    local totalWidth = (#overlay.affixTierRomans * layout.iconSize) + ((#overlay.affixTierRomans - 1) * layout.gap)

    if not panel.peeTierSelector then
        local selector = createFrame("Frame", "PEEAffixTierSelector", panel)
        SetFrameSize(selector, totalWidth, layout.iconSize)
        selector:SetPoint("BOTTOM", panel, "BOTTOM", 0, layout.bottom)
        selector.buttons = {}

        local startX = -(totalWidth / 2) + (layout.iconSize / 2)
        for tier, roman in ipairs(overlay.affixTierRomans) do
            local button = createFrame("Button", nil, selector)
            SetFrameSize(button, layout.iconSize, layout.iconSize)
            button:SetPoint("CENTER", selector, "CENTER", startX + ((tier - 1) * (layout.iconSize + layout.gap)), 0)
            button.tier = tier
            SetFrameBackdrop(button, 2, 1)
            SetButtonBackdrop(button, DARK, BLACK)
            button.text = button:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
            button.text:SetPoint("CENTER", button, "CENTER", 0, 0)
            button.text:SetText(roman)
            ConfigureExtractionText(button.text, 10, WHITE, nil, "CENTER")
            button:SetScript("OnClick", function(self)
                overlay.SelectAffixTier(panel, self.tier)
            end)
            button:SetScript("OnEnter", function(self)
                SetButtonBackdrop(self, HOVER_BLUE_BACKDROP, HOVER_BLUE)
            end)
            button:SetScript("OnLeave", function()
                overlay.RefreshAffixTierSelector(panel)
            end)
            selector.buttons[#selector.buttons + 1] = button
        end

        panel.peeTierSelector = selector
        panel._peeAffixLayoutMath = {
            totalWidth = totalWidth,
            iconSize = layout.iconSize,
            gap = layout.gap,
            bottom = layout.bottom,
            scrollBottom = layout.scrollBottom,
            startX = startX
        }
    end

    local scrollFrame = panel.scrollFrame or (_G and _G.EbonholdAffixBookScroll)
    if scrollFrame and scrollFrame.SetPoint then
        scrollFrame:SetPoint("BOTTOMRIGHT", panel, "BOTTOMRIGHT", -36, layout.scrollBottom)
        scrollFrame._peeAffixLayout = { bottom = layout.scrollBottom }
    end

    overlay.RefreshAffixTierSelector(panel)
end

local function ApplyAffixBookPanelTheme()
    local panel = _G and _G.EbonholdAffixBookPanel
    if not panel then
        return
    end

    SetExtractionBackdrop(panel, 4, 4, nil, BLACK)

    if panel.bgTexture and panel.bgTexture.Hide then
        panel.bgTexture:Hide()
    end

    ConfigureExtractionText(panel.title, 12, MAGE_BLUE, nil, "CENTER")
    ConfigureExtractionText(panel.listEmptyText, 11, MUTED, nil, "CENTER")
    ConfigureExtractionText(panel.emptyText, 11, MUTED, nil, "CENTER")
    ConfigureExtractionText(panel.descriptionText, 11, MUTED, 236, "LEFT")

    local searchBox = panel.searchBox or (_G and _G.EbonholdAffixSearchBox)
    if searchBox then
        SetFrameBackdrop(searchBox, 1, 1)
        if searchBox.SetBackdropColor then
            searchBox:SetBackdropColor(0.02, 0.02, 0.02, 1)
        end
        if searchBox.SetBackdropBorderColor then
            searchBox:SetBackdropBorderColor(BLACK[1], BLACK[2], BLACK[3], 1)
        end
        ConfigureExtractionText(searchBox.placeholder, 11, MUTED, nil, "LEFT")
    end

    local listBox = panel.listBox or (_G and _G.EbonholdAffixBookListBox)
    if listBox then
        SetFrameBackdrop(listBox, 1, 1)
        if listBox.SetBackdropColor then
            listBox:SetBackdropColor(0.018, 0.018, 0.018, 1)
        end
        if listBox.SetBackdropBorderColor then
            listBox:SetBackdropBorderColor(0, 0, 0, 1)
        end
    end

    local learnedText = _G and _G.EbonholdAffixLearnedCheckText
    if learnedText and learnedText.SetTextColor then
        learnedText:SetTextColor(CREAM[1], CREAM[2], CREAM[3], 1)
    end

    SkinMatchingButtons(panel, { "Confirm" })
    SkinAffixRows(panel)
    overlay.NormalizeAffixConfirmButton(panel)
    overlay.WrapAffixBookSearchBox(panel)
    overlay.EnsureAffixTierSelector(panel)
end

local function ApplyExtractionTheme()
    if not overlay.enabled or overlay.isPTR then
        return
    end

    local extractionFrame = _G and _G.EbonholdExtractionFrame
    if extractionFrame then
        SetExtractionBackdrop(extractionFrame, 4, 4, nil, BLACK)

        if extractionFrame.bgForge and extractionFrame.bgForge.Hide then
            extractionFrame.bgForge:Hide()
        end
        if extractionFrame.bgBlack and extractionFrame.bgBlack.Hide then
            extractionFrame.bgBlack:Hide()
        end
        if extractionFrame.titleBar and extractionFrame.titleBar.Hide then
            extractionFrame.titleBar:Hide()
        end
        if extractionFrame.bottomBar and extractionFrame.bottomBar.Hide then
            extractionFrame.bottomBar:Hide()
        end
        HideTextureRegion(extractionFrame, "Interface\\DialogFrame\\UI-DialogBox-Background")
        HideTextureRegion(extractionFrame, "Interface\\AddOns\\ProjectEbonhold\\assets\\UI-Background-Rock")
        HideTextureRegion(extractionFrame, "Interface\\AddOns\\ProjectEbonhold\\assets\\background-torment")

        ConfigureExtractionText(extractionFrame.title, 12, MAGE_BLUE, nil, "CENTER")
        ConfigureExtractionText(extractionFrame.hintText, 11, MUTED, 260, "CENTER")
        ConfigureExtractionText(extractionFrame.statusText, 12, CREAM, 270, "CENTER")
        SkinMatchingButtons(extractionFrame, { "Extract", "Choose an Affix", "Change the Affix", "Apply Affix",
            "Already learned" })
        overlay.RefreshExtractionActionButtons(extractionFrame)
    end

    local slot = _G and _G.EbonholdExtractionSlot
    if slot then
        SetExtractionBackdrop(slot, 4, 4, nil, BLACK)
        if slot.icon and slot.icon.SetPoint then
            if slot.icon.ClearAllPoints then
                slot.icon:ClearAllPoints()
            end
            slot.icon:SetPoint("TOPLEFT", slot, "TOPLEFT", 3, -3)
            slot.icon:SetPoint("BOTTOMRIGHT", slot, "BOTTOMRIGHT", -3, 3)
            if slot.icon.SetTexCoord then
                slot.icon:SetTexCoord(0.07, 0.93, 0.07, 0.93)
            end
        end
    end

    ApplyAffixBookPanelTheme()
end

overlay.ApplyExtractionTheme = ApplyExtractionTheme

local function WrapExtractionFunction(extractionUI, functionName)
    local original = extractionUI and extractionUI[functionName]
    if type(original) ~= "function" or extractionUI["_peeWrapped" .. functionName] then
        return
    end

    extractionUI["_peeWrapped" .. functionName] = true
    extractionUI[functionName] = function(...)
        local a, b, c = original(...)
        ApplyExtractionTheme()
        return a, b, c
    end
end

local function EnsureExtractionThemeWatcher()
    if overlay.extractionThemeWatcher then
        return
    end

    local watcher = CreateFrame("Frame")
    watcher.elapsed = 0
    watcher:SetScript("OnUpdate", function(self, elapsed)
        if not overlay.enabled or overlay.isPTR then
            return
        end

        local extractionFrame = _G and _G.EbonholdExtractionFrame
        local affixBookPanel = _G and _G.EbonholdAffixBookPanel
        local extractionVisible = extractionFrame and extractionFrame.IsShown and extractionFrame:IsShown()
        local panelVisible = affixBookPanel and affixBookPanel.IsShown and affixBookPanel:IsShown()
        if not extractionVisible and not panelVisible then
            return
        end

        self.elapsed = (self.elapsed or 0) + elapsed
        if self.elapsed < 0.25 then
            return
        end

        self.elapsed = 0
        ApplyExtractionTheme()
    end)

    overlay.extractionThemeWatcher = watcher
end

local function InstallExtractionThemeHooks()
    if not overlay.enabled or overlay.isPTR then
        return
    end

    local extractionUI = _G and _G.ExtractionUI
    if extractionUI then
        WrapExtractionFunction(extractionUI, "Toggle")
        WrapExtractionFunction(extractionUI, "ShowSidePanel")
        WrapExtractionFunction(extractionUI, "PopulateSidePanel")
        WrapExtractionFunction(extractionUI, "OnCostReceived")
        WrapExtractionFunction(extractionUI, "OnLearnedAffixesReceived")
        WrapExtractionFunction(extractionUI, "OnApplyCostReceived")
    end

    EnsureExtractionThemeWatcher()
    ApplyExtractionTheme()
end

overlay.InstallExtractionThemeHooks = InstallExtractionThemeHooks

local PATCH_POPUP_DISCORD_URL = "https://discord.com/channels/1429854156444794884/1510027919894908968"

local function ConfigurePatchPopupText(fontString, width, color, justifyH, size)
    if not fontString then
        return
    end

    if fontString.SetFont then
        fontString:SetFont("Fonts\\FRIZQT__.TTF", ScaledFontSize(size or 12), "OUTLINE")
    end

    if width and fontString.SetWidth then
        fontString:SetWidth(width)
    end

    if fontString.SetWordWrap then
        fontString:SetWordWrap(true)
    end

    if fontString.SetNonSpaceWrap then
        fontString:SetNonSpaceWrap(false)
    end

    if justifyH and fontString.SetJustifyH then
        fontString:SetJustifyH(justifyH)
    end

    if color and fontString.SetTextColor then
        fontString:SetTextColor(color[1], color[2], color[3], 1)
    end
end

local function SetPatchPopupText(fontString, text)
    if fontString and fontString.SetText then
        fontString:SetText(text)
    end
end

local function SetPatchPopupCustomBackdrop(frame, backdropColor, alpha, borderColor, edgeSize)
    if not frame then
        return
    end

    SetFrameBackdrop(frame, edgeSize or 2, edgeSize or 2)

    if frame.SetBackdropColor then
        frame:SetBackdropColor(backdropColor[1], backdropColor[2], backdropColor[3], alpha)
    end

    if frame.SetBackdropBorderColor then
        frame:SetBackdropBorderColor(borderColor[1], borderColor[2], borderColor[3], 1)
    end
end

local function SetPatchPopupEditBoxText(editBox, text)
    if not editBox then
        return
    end

    if editBox.SetText then
        editBox:SetText(text)
    end
    if editBox.SetCursorPosition then
        editBox:SetCursorPosition(0)
    end
end

local function SelectPatchPopupDiscordLink(editBox)
    if not editBox then
        return
    end

    SetPatchPopupEditBoxText(editBox, PATCH_POPUP_DISCORD_URL)
    if editBox.SetFocus then
        editBox:SetFocus()
    end
    if editBox.HighlightText then
        editBox:HighlightText()
    end
end

local function EnsurePatchPopupEnhancedControls(patchPopup)
    if not patchPopup or patchPopup._peeEnhancedControls then
        return
    end

    SetFrameSize(patchPopup, 540, 480)

    patchPopup.bodyText = patchPopup:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    patchPopup.bodyText:SetPoint("TOPLEFT", patchPopup, "TOPLEFT", 28, -92)
    ConfigurePatchPopupText(patchPopup.bodyText, 484, WHITE, "LEFT")
    patchPopup.bodyText:SetJustifyV("TOP")

    patchPopup.stepsBox = CreateFrame("Frame", nil, patchPopup)
    SetFrameSize(patchPopup.stepsBox, 468, 88)
    patchPopup.stepsBox:SetPoint("TOPLEFT", patchPopup, "TOPLEFT", 36, -160)

    patchPopup.stepsHeader = patchPopup.stepsBox:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    patchPopup.stepsHeader:SetPoint("TOPLEFT", patchPopup.stepsBox, "TOPLEFT", 0, 0)
    ConfigurePatchPopupText(patchPopup.stepsHeader, 468, MAGE_BLUE, "LEFT")

    patchPopup.stepsText = patchPopup.stepsBox:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    patchPopup.stepsText:SetPoint("TOPLEFT", patchPopup.stepsHeader, "BOTTOMLEFT", 0, -7)
    ConfigurePatchPopupText(patchPopup.stepsText, 468, WHITE, "LEFT")
    patchPopup.stepsText:SetJustifyV("TOP")

    patchPopup.warningBox = CreateFrame("Frame", nil, patchPopup)
    SetFrameSize(patchPopup.warningBox, 484, 58)
    patchPopup.warningBox:SetPoint("TOPLEFT", patchPopup, "TOPLEFT", 28, -258)
    SetPatchPopupCustomBackdrop(patchPopup.warningBox, {0.14, 0.015, 0.015}, 0.92, {0.8, 0, 0}, 2)

    patchPopup.warningStrip = patchPopup.warningBox:CreateTexture(nil, "ARTWORK")
    patchPopup.warningStrip:SetTexture("Interface\\Buttons\\WHITE8x8")
    patchPopup.warningStrip:SetVertexColor(0.85, 0, 0, 1)
    patchPopup.warningStrip:SetPoint("TOPLEFT", patchPopup.warningBox, "TOPLEFT", 2, -2)
    patchPopup.warningStrip:SetPoint("BOTTOMLEFT", patchPopup.warningBox, "BOTTOMLEFT", 2, 2)
    patchPopup.warningStrip:SetWidth(5)

    patchPopup.warningTitle = patchPopup.warningBox:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    patchPopup.warningTitle:SetPoint("TOPLEFT", patchPopup.warningBox, "TOPLEFT", 18, -9)
    ConfigurePatchPopupText(patchPopup.warningTitle, 450, {1, 0.22, 0.22}, "LEFT")

    patchPopup.warningText = patchPopup.warningBox:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    patchPopup.warningText:SetPoint("TOPLEFT", patchPopup.warningTitle, "BOTTOMLEFT", 0, -5)
    ConfigurePatchPopupText(patchPopup.warningText, 450, WHITE, "LEFT")

    patchPopup.footerText = patchPopup:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    patchPopup.footerText:SetPoint("TOPLEFT", patchPopup, "TOPLEFT", 28, -330)
    ConfigurePatchPopupText(patchPopup.footerText, 484, MUTED, "LEFT")

    patchPopup.discordRow = CreateFrame("Frame", nil, patchPopup)
    patchPopup.discordRow:SetPoint("BOTTOMLEFT", patchPopup, "BOTTOMLEFT", 28, 76)
    patchPopup.discordRow:SetPoint("BOTTOMRIGHT", patchPopup, "BOTTOMRIGHT", -28, 76)
    patchPopup.discordRow:SetHeight(24)

    patchPopup.discordLabel = patchPopup.discordRow:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    patchPopup.discordLabel:SetPoint("LEFT", patchPopup.discordRow, "LEFT", 0, 0)
    ConfigurePatchPopupText(patchPopup.discordLabel, 60, MAGE_BLUE, "LEFT")
    patchPopup.discordLabel:SetText("Discord:")

    patchPopup.discordCopyButton = CreateFlatButton(patchPopup.discordRow, "Copy", 58, 24)
    patchPopup.discordCopyButton:SetPoint("RIGHT", patchPopup.discordRow, "RIGHT", 0, 0)

    patchPopup.discordEditBox = CreateFrame("EditBox", nil, patchPopup.discordRow, "InputBoxTemplate")
    patchPopup.discordEditBox:SetPoint("LEFT", patchPopup.discordLabel, "RIGHT", 8, 0)
    patchPopup.discordEditBox:SetPoint("RIGHT", patchPopup.discordCopyButton, "LEFT", -8, 0)
    patchPopup.discordEditBox:SetHeight(24)
    if patchPopup.discordEditBox.SetAutoFocus then
        patchPopup.discordEditBox:SetAutoFocus(false)
    end
    if patchPopup.discordEditBox.SetFont then
        patchPopup.discordEditBox:SetFont("Fonts\\FRIZQT__.TTF", ScaledFontSize(11))
    end
    if patchPopup.discordEditBox.SetTextColor then
        patchPopup.discordEditBox:SetTextColor(WHITE[1], WHITE[2], WHITE[3], 1)
    end
    SetPatchPopupEditBoxText(patchPopup.discordEditBox, PATCH_POPUP_DISCORD_URL)

    patchPopup.discordEditBox:SetScript("OnEscapePressed", function(self)
        if self.ClearFocus then
            self:ClearFocus()
        end
    end)
    patchPopup.discordEditBox:SetScript("OnEditFocusGained", function(self)
        SelectPatchPopupDiscordLink(self)
    end)
    patchPopup.discordEditBox:SetScript("OnMouseUp", function(self)
        SelectPatchPopupDiscordLink(self)
    end)
    patchPopup.discordEditBox:SetScript("OnEnterPressed", function(self)
        SelectPatchPopupDiscordLink(self)
    end)
    patchPopup.discordEditBox:SetScript("OnTextChanged", function(self)
        local currentText = self.GetText and self:GetText() or PATCH_POPUP_DISCORD_URL
        if currentText ~= PATCH_POPUP_DISCORD_URL then
            SetPatchPopupEditBoxText(self, PATCH_POPUP_DISCORD_URL)
            if self.HighlightText then
                self:HighlightText()
            end
        end
    end)

    patchPopup.discordCopyButton:SetScript("OnClick", function()
        SelectPatchPopupDiscordLink(patchPopup.discordEditBox)
    end)

    patchPopup.dismissWarning = CreateFrame("Frame", nil, UIParent)
    SetFrameSize(patchPopup.dismissWarning, 540, 360)
    patchPopup.dismissWarning:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
    patchPopup.dismissWarning:SetFrameStrata("FULLSCREEN_DIALOG")
    patchPopup.dismissWarning:SetFrameLevel(120)
    patchPopup.dismissWarning:Hide()
    SetPatchPopupCustomBackdrop(patchPopup.dismissWarning, DARK, 1, {1, 0, 0}, 5)

    patchPopup.dismissWarning.banner = patchPopup.dismissWarning:CreateTexture(nil, "BACKGROUND")
    patchPopup.dismissWarning.banner:SetTexture("Interface\\Buttons\\WHITE8x8")
    patchPopup.dismissWarning.banner:SetVertexColor(0.6, 0, 0, 0.95)
    patchPopup.dismissWarning.banner:SetPoint("TOPLEFT", patchPopup.dismissWarning, "TOPLEFT", 5, -5)
    patchPopup.dismissWarning.banner:SetPoint("TOPRIGHT", patchPopup.dismissWarning, "TOPRIGHT", -5, -5)
    patchPopup.dismissWarning.banner:SetHeight(64)

    patchPopup.dismissWarning.title = patchPopup.dismissWarning:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    patchPopup.dismissWarning.title:SetPoint("TOP", patchPopup.dismissWarning, "TOP", 0, -20)
    ConfigurePatchPopupText(patchPopup.dismissWarning.title, nil, WHITE, "CENTER", 26)
    patchPopup.dismissWarning.title:SetText("WARNING!!")

    patchPopup.dismissWarning.message = patchPopup.dismissWarning:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    patchPopup.dismissWarning.message:SetPoint("TOP", patchPopup.dismissWarning.title, "BOTTOM", 0, -32)
    ConfigurePatchPopupText(patchPopup.dismissWarning.message, 480, CREAM, "CENTER")
    patchPopup.dismissWarning.message:SetText(
        "Dismissing this is a temporary workaround.\n\n" ..
        "|cffff0000THIS CAN BREAK YOUR ADDON.|r\n\n" ..
        "Your computer probably will not blow up, but this addon can break until it is updated.\n\n" ..
        "|cffffcc00If you run into issues, DELETE THE ADDON AND USE THE SERVER'S VERSION!|r")

    patchPopup.dismissWarning.acceptButton = CreateFlatButton(patchPopup.dismissWarning, "Dismiss Anyway", 180, 50)
    patchPopup.dismissWarning.acceptButton:SetPoint("BOTTOM", patchPopup.dismissWarning, "BOTTOM", -95, 24)
    patchPopup.dismissWarning.acceptButton:SetScript("OnClick", function()
        patchPopup._peeSessionDismissed = true
        patchPopup.sessionDismissed = true
        patchPopup.isPersistent = false
        patchPopup.dismissWarning:Hide()
        patchPopup:Hide()
    end)

    patchPopup.dismissWarning.cancelButton = CreateFlatButton(patchPopup.dismissWarning, "Cancel", 180, 50)
    patchPopup.dismissWarning.cancelButton:SetPoint("BOTTOM", patchPopup.dismissWarning, "BOTTOM", 95, 24)
    patchPopup.dismissWarning.cancelButton:SetScript("OnClick", function()
        patchPopup.dismissWarning:Hide()
    end)

    patchPopup.dismissButton = CreateFlatButton(patchPopup, "Dismiss", 180, 50)
    patchPopup.dismissButton:SetPoint("BOTTOM", patchPopup, "BOTTOM", 95, 20)
    patchPopup.dismissButton:SetScript("OnClick", function()
        patchPopup.dismissWarning:Show()
    end)

    patchPopup._peeEnhancedControls = true
end

local function ApplyPatchPopupEnhancedContent(patchPopup)
    EnsurePatchPopupEnhancedControls(patchPopup)

    if not patchPopup or not patchPopup._peeEnhancedControls then
        return
    end

    SetFrameSize(patchPopup, 540, 480)

    if patchPopup.title then
        ConfigurePatchPopupText(patchPopup.title, nil, {1, 0.22, 0.22}, "CENTER", 16)
        SetPatchPopupText(patchPopup.title, "Update Required")
    end

    if patchPopup.message then
        patchPopup.message:SetPoint("TOP", patchPopup, "TOP", 0, -56)
        ConfigurePatchPopupText(patchPopup.message, 484, {1, 0.82, 0}, "CENTER")
        SetPatchPopupText(patchPopup.message, "Project Ebonhold Enhanced is out of date because the server updated.")
    end

    SetPatchPopupText(patchPopup.bodyText,
        "You can dismiss this warning and keep playing, but the game may not work the way the " ..
        "Ebonhold Team intended. " ..
        "|cffff5544Some features may be missing or broken.|r")
    SetPatchPopupText(patchPopup.stepsHeader, "To use the server's version:")
    SetPatchPopupText(patchPopup.stepsText,
        "1. Exit WoW completely.\n" ..
        "2. Open your Interface/AddOns folder.\n" ..
        "3. Delete the ProjectEbonhold folder.\n" ..
        "4. Start WoW again.")
    SetPatchPopupText(patchPopup.warningTitle, "Do not just disable the addon.")
    SetPatchPopupText(patchPopup.warningText, "The server needs ProjectEbonhold loaded.")
    SetPatchPopupText(patchPopup.footerText,
        "Deleting the ProjectEbonhold folder is safe.\n" ..
        "The server has its own version built in.\n" ..
        "Use the server's version until the next Enhanced update is ready.")

    SetPatchPopupEditBoxText(patchPopup.discordEditBox, PATCH_POPUP_DISCORD_URL)

    SetPatchPopupText(patchPopup.requiredVersion, "")
    SetPatchPopupText(patchPopup.instructions, "")

    if patchPopup.closeButton and patchPopup.closeButton.Hide then
        patchPopup.closeButton:Hide()
    end

    if patchPopup.quitButton then
        patchPopup.quitButton:ClearAllPoints()
        patchPopup.quitButton:SetPoint("BOTTOM", patchPopup, "BOTTOM", -95, 20)
    end
end

local function ApplyPatchPopupTheme()
    if not overlay.enabled or overlay.isPTR then
        return
    end

    local patchPopup = _G and (_G.PatchPopup or _G.PatchPopupFrame)
    if not patchPopup then
        return
    end

    SetDarkBackdrop(patchPopup, 4, 4)

    if patchPopup.bg and patchPopup.bg.Hide then
        patchPopup.bg:Hide()
    end

    if patchPopup.border and patchPopup.border.Hide then
        patchPopup.border:Hide()
    end

    ConfigurePatchPopupText(patchPopup.title, nil, nil, "CENTER")
    ConfigurePatchPopupText(patchPopup.message, 360, CREAM, "CENTER")
    ConfigurePatchPopupText(patchPopup.requiredVersion, 360, MAGE_BLUE, "CENTER")
    ConfigurePatchPopupText(patchPopup.instructions, 360, CREAM, "CENTER")

    SkinFlatButton(patchPopup.quitButton)
    ApplyPatchPopupEnhancedContent(patchPopup)
end

overlay.ApplyPatchPopupTheme = ApplyPatchPopupTheme

local function InstallPatchPopupThemeHooks()
    if not overlay.enabled or overlay.isPTR then
        return
    end

    local patchPopup = _G and _G.PatchPopup
    if patchPopup and type(patchPopup.ShowPatchError) == "function" and not patchPopup._peeWrappedShowPatchError then
        local original = patchPopup.ShowPatchError
        patchPopup._peeWrappedShowPatchError = true
        patchPopup.ShowPatchError = function(self, requiredPatch, forceShow)
            local popupFrame = type(self) == "table" and self or patchPopup
            local patchVersion = type(self) == "table" and requiredPatch or self
            local shouldForceShow = (type(self) == "table" and forceShow == true) or
                (type(self) ~= "table" and requiredPatch == true)

            if popupFrame._peeSessionDismissed and not shouldForceShow then
                return nil
            end
            if shouldForceShow then
                popupFrame._peeSessionDismissed = false
            end

            local a, b, c = original(popupFrame, patchVersion)
            ApplyPatchPopupTheme()
            return a, b, c
        end
    end

    ApplyPatchPopupTheme()
end

overlay.InstallPatchPopupThemeHooks = InstallPatchPopupThemeHooks

local function ConfigureHardmodeText(fontString, size, color, width, justifyH)
    if not fontString then
        return
    end

    if fontString.SetFont then
        fontString:SetFont("Fonts\\FRIZQT__.TTF", ScaledFontSize(size), "OUTLINE")
    end

    if width and fontString.SetWidth then
        fontString:SetWidth(width)
    end

    if fontString.SetWordWrap then
        fontString:SetWordWrap(true)
    end

    if fontString.SetNonSpaceWrap then
        fontString:SetNonSpaceWrap(false)
    end

    if justifyH and fontString.SetJustifyH then
        fontString:SetJustifyH(justifyH)
    end

    if color and fontString.SetTextColor then
        fontString:SetTextColor(color[1], color[2], color[3], 1)
    end
end

local function EnsureHardmodeTitle(frame)
    if not frame then
        return
    end

    local title = frame.title or frame.peeTitle
    if not title and frame.CreateFontString then
        title = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        title:SetPoint("TOP", frame, "TOP", 0, -12)
        title:SetText("Hardcore")
        frame.peeTitle = title
    end

    if title then
        ConfigureHardmodeText(title, 14, {1, 0.82, 0}, nil, "CENTER")
    end
end

local function ApplyHardmodeConfirmTheme()
    if not overlay.enabled or overlay.isPTR then
        return
    end

    local popup = _G and _G.HardmodeConfirmPopup
    if not popup then
        return
    end

    SetDarkBackdrop(popup, 4, 4)
    HideTextureRegion(popup, "Interface\\AddOns\\ProjectEbonhold\\assets\\UI-Background-Rock")

    local blockFrame = (_G and _G.HardmodeBlockFrame) or popup.blockFrame
    if popup.overlay and blockFrame then
        if popup.overlay.SetParent then
            popup.overlay:SetParent(blockFrame)
        end
        if popup.overlay.ClearAllPoints then
            popup.overlay:ClearAllPoints()
        end
        if popup.overlay.SetAllPoints then
            popup.overlay:SetAllPoints(blockFrame)
        end
    end

    ConfigureHardmodeText(popup.title, 18, MAGE_BLUE, nil, "CENTER")
    ConfigureHardmodeText(popup.desc, 12, CREAM, 340, "CENTER")
    SkinFlatButton(popup.acceptBtn)
    SkinFlatButton(popup.cancelBtn)
end

overlay.ApplyHardmodeConfirmTheme = ApplyHardmodeConfirmTheme

local function WrapHardmodeApplyButton(frame)
    local button = frame and frame.applyBtn
    if not button then
        return
    end

    SkinRuntimeButton(button, BANISH_BACKDROP, CREAM, BLACK, BANISH_HOVER_BACKDROP,
        overlay.buttonBorders.banishHover)

    if button._peeWrappedHardmodeApply then
        return
    end

    if button.HookScript then
        button:HookScript("OnClick", ApplyHardmodeConfirmTheme)
        button._peeWrappedHardmodeApply = true
        return
    end

    if button.GetScript and button.SetScript then
        local original = button:GetScript("OnClick")
        if type(original) == "function" then
            button:SetScript("OnClick", function(...)
                local firstResult, secondResult, thirdResult = original(...)
                ApplyHardmodeConfirmTheme()
                return firstResult, secondResult, thirdResult
            end)
            button._peeWrappedHardmodeApply = true
        end
    end
end

local function ApplyHardmodeTheme()
    if not overlay.enabled or overlay.isPTR then
        return
    end

    local hardmodeFrame = _G and _G.HardmodeFrame
    if hardmodeFrame then
        if hardmodeFrame.SetMovable then
            hardmodeFrame:SetMovable(true)
        end
        if hardmodeFrame.EnableMouse then
            hardmodeFrame:EnableMouse(true)
        end
        if hardmodeFrame.RegisterForDrag then
            hardmodeFrame:RegisterForDrag("LeftButton")
        end
        if hardmodeFrame.SetScript and not hardmodeFrame._peeDragReady then
            hardmodeFrame:SetScript("OnDragStart", hardmodeFrame.StartMoving)
            hardmodeFrame:SetScript("OnDragStop", hardmodeFrame.StopMovingOrSizing)
            hardmodeFrame._peeDragReady = true
        end
        SetDarkBackdrop(hardmodeFrame, 2, 2)
        HideTextureRegion(hardmodeFrame, "Interface\\AddOns\\ProjectEbonhold\\assets\\background-torment")
        EnsureHardmodeTitle(hardmodeFrame)
        WrapHardmodeApplyButton(hardmodeFrame)
    end

    local lockOverlay = (_G and _G.HardmodeLockOverlay) or (hardmodeFrame and hardmodeFrame.lockOverlay)
    if lockOverlay then
        SetDarkBackdrop(lockOverlay, 4, 4)
        if lockOverlay.SetBackdropColor then
            lockOverlay:SetBackdropColor(0, 0, 0, GetBackdropOpacity())
        end
    end

    ApplyHardmodeConfirmTheme()
end

overlay.ApplyHardmodeTheme = ApplyHardmodeTheme

overlay.GetDeathConfirmationTextRegions = function(popup)
    if not popup or not popup.GetRegions then
        return nil, nil
    end

    local titleText = nil
    local messageText = nil
    local regions = { popup:GetRegions() }
    for _, region in ipairs(regions) do
        if region and region.SetFont and region.SetTextColor then
            if not titleText then
                titleText = region
            elseif not messageText then
                messageText = region
                break
            end
        end
    end

    return titleText, messageText
end

overlay.ApplyDeathConfirmationTheme = function()
    if not overlay.enabled or overlay.isPTR then
        return
    end

    local popup = _G and _G.ProjectEbonholdConfirmPopup
    if not popup then
        return
    end

    SetDarkBackdrop(popup, 4, 4)

    local titleText, messageText = overlay.GetDeathConfirmationTextRegions(popup)
    if titleText then
        titleText:SetFont("Fonts\\FRIZQT__.TTF", ScaledFontSize(18), "OUTLINE")
        titleText:SetTextColor(1, 0.82, 0, 1)
        if titleText.SetJustifyH then
            titleText:SetJustifyH("CENTER")
        end
    end

    local messageHeight = 30
    if messageText then
        messageText:SetFont("Fonts\\FRIZQT__.TTF", ScaledFontSize(12), "OUTLINE")
        messageText:SetTextColor(1, 1, 1, 1)
        if messageText.SetWidth then
            messageText:SetWidth(350)
        end
        if messageText.SetWordWrap then
            messageText:SetWordWrap(true)
        end
        if messageText.SetNonSpaceWrap then
            messageText:SetNonSpaceWrap(false)
        end
        if messageText.SetJustifyH then
            messageText:SetJustifyH("CENTER")
        end
        if messageText.GetStringHeight then
            messageHeight = messageText:GetStringHeight() or messageHeight
        end
    end

    local computedHeight = 20 + 22 + 15 + messageHeight + 20 + 30 + 25
    if computedHeight < 160 then
        computedHeight = 160
    end
    SetFrameSize(popup, 400, computedHeight)

    if popup.GetChildren then
        local children = { popup:GetChildren() }
        for _, child in ipairs(children) do
            SkinRuntimeButton(child, BANISH_BACKDROP, CREAM, BLACK, BANISH_HOVER_BACKDROP,
                overlay.buttonBorders.banishHover)
        end
    end
end

overlay.EnsureDeathConfirmationWatcher = function()
    if overlay.deathConfirmationWatcher or not CreateFrame then
        return
    end

    local watcher = CreateFrame("Frame")
    local elapsedSinceCheck = 0
    watcher:SetScript("OnUpdate", function(_, elapsed)
        elapsedSinceCheck = elapsedSinceCheck + (elapsed or 0)
        if elapsedSinceCheck < 0.05 then
            return
        end

        elapsedSinceCheck = 0
        local popup = _G and _G.ProjectEbonholdConfirmPopup
        if popup and (not popup.IsShown or popup:IsShown()) then
            if popup.HookScript and not popup._peeDeathPopupShowHook then
                popup:HookScript("OnShow", overlay.ApplyDeathConfirmationTheme)
                popup._peeDeathPopupShowHook = true
            end
            overlay.ApplyDeathConfirmationTheme()
        end
    end)

    overlay.deathConfirmationWatcher = watcher
end

overlay.ApplySkillTreeDataPatches = function()
    if not overlay.enabled or overlay.isPTR then
        return
    end

    local treeDatabase = _G and _G.TalentDatabase
    local defaultTree = treeDatabase and treeDatabase[0]
    local nodes = defaultTree and defaultTree.nodes
    if type(nodes) ~= "table" then
        return
    end

    for _, node in ipairs(nodes) do
        if node and (node.id == 407 or (node.spells and node.spells[1] == 101250)) then
            node.permanent = true
            return
        end
    end
end

local function WrapHardmodeUIFunction(hardmodeUI, functionName)
    local original = hardmodeUI and hardmodeUI[functionName]
    if type(original) ~= "function" or hardmodeUI["_peeWrapped" .. functionName] then
        return
    end

    hardmodeUI["_peeWrapped" .. functionName] = true
    hardmodeUI[functionName] = function(...)
        local firstResult, secondResult, thirdResult = original(...)
        overlay.SyncPlayerRunHardmodeLabels(_G and _G.ProjectEbonholdPlayerRunFrame, true)
        ApplyHardmodeTheme()
        return firstResult, secondResult, thirdResult
    end
end

local function EnsureHardmodeThemeWatcher()
    if overlay.hardmodeThemeWatcher then
        return
    end

    local watcher = CreateFrame("Frame")
    local elapsedSinceCheck = 0
    watcher:SetScript("OnUpdate", function(_, elapsed)
        elapsedSinceCheck = elapsedSinceCheck + (elapsed or 0)
        if elapsedSinceCheck < 0.25 then
            return
        end

        elapsedSinceCheck = 0
        ApplyHardmodeTheme()
    end)

    overlay.hardmodeThemeWatcher = watcher
end

local function GetHardcoreTierText(tier)
    return overlay.GetHardcoreTierText((tonumber(tier) or 1) - 1)
end

local function CreateHardcoreReminderFrame()
    if overlay.hardcoreReminderFrame then
        return overlay.hardcoreReminderFrame
    end

    if _G and _G.EbonholdHCReminderFrame then
        return nil
    end

    local reminderFrame = CreateFrame("Frame", "PEEHardcoreReminderFrame", UIParent)
    SetFrameSize(reminderFrame, 420, 70)
    reminderFrame:SetPoint("TOP", UIParent, "TOP", 0, -180)
    reminderFrame:SetFrameStrata("HIGH")
    reminderFrame:Hide()
    SetDarkBackdrop(reminderFrame, 2, 2)
    if reminderFrame.SetBackdropBorderColor then
        reminderFrame:SetBackdropBorderColor(0.6, 0.1, 0.1, 1)
    end

    local title = reminderFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    title:SetPoint("TOP", reminderFrame, "TOP", 0, -10)
    title:SetFont("Fonts\\FRIZQT__.TTF", ScaledFontSize(16), "OUTLINE")
    title:SetText("|cffff3030HARDCORE MODE ACTIVE|r")

    local subtitle = reminderFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    subtitle:SetPoint("TOP", title, "BOTTOM", 0, -6)
    subtitle:SetFont("Fonts\\FRIZQT__.TTF", ScaledFontSize(12), "OUTLINE")
    subtitle:SetTextColor(CREAM[1], CREAM[2], CREAM[3], 1)
    subtitle:SetText("")

    local fadeState = { phase = "idle", elapsed = 0 }
    reminderFrame:SetScript("OnUpdate", function(self, elapsed)
        if fadeState.phase == "idle" then
            return
        end

        fadeState.elapsed = fadeState.elapsed + (elapsed or 0)
        if fadeState.phase == "hold" then
            if fadeState.elapsed >= 4.0 then
                fadeState.phase = "fade"
                fadeState.elapsed = 0
            end
            return
        end

        local alpha = 1 - (fadeState.elapsed / 1.5)
        if alpha <= 0 then
            self:Hide()
            if self.SetAlpha then
                self:SetAlpha(1)
            end
            fadeState.phase = "idle"
        elseif self.SetAlpha then
            self:SetAlpha(alpha)
        end
    end)

    reminderFrame.subtitle = subtitle
    reminderFrame.fadeState = fadeState
    overlay.hardcoreReminderFrame = reminderFrame

    return reminderFrame
end

local function ShowHardcoreReminder(tier, instanceTypeText)
    if not overlay.enabled or overlay.isPTR then
        return
    end

    local reminderFrame = CreateHardcoreReminderFrame()
    if not reminderFrame then
        return
    end

    reminderFrame.subtitle:SetText(
        "Tier " .. GetHardcoreTierText(tier) .. " - You're entering a " .. instanceTypeText .. " in hardcore mode."
    )

    if reminderFrame.SetBackdropBorderColor then
        local progress = math.max(0, math.min(1, ((tier or 2) - 2) / 3))
        reminderFrame:SetBackdropBorderColor(0.6 + progress * 0.4, 0.1, 0.1, 1)
    end

    if reminderFrame.SetAlpha then
        reminderFrame:SetAlpha(1)
    end
    reminderFrame:Show()
    reminderFrame.fadeState.phase = "hold"
    reminderFrame.fadeState.elapsed = 0
end

overlay.ShowHardcoreReminder = ShowHardcoreReminder

local function CheckHardcoreInstanceReminder()
    if not overlay.enabled or overlay.isPTR or not IsInInstance then
        return
    end

    local inInstance, instanceType = IsInInstance()
    local isInstanceNow = inInstance and (instanceType == "raid" or instanceType == "party")
    if isInstanceNow and not overlay.hardcoreLastInstanceState then
        local service = _G and _G.ProjectEbonhold and _G.ProjectEbonhold.HardmodeService
        if service and service.IsHardmodeActive and service.IsHardmodeActive() then
            local tier = service.GetCurrentDifficulty and service.GetCurrentDifficulty() or 2
            local label = instanceType == "raid" and "raid" or "dungeon"
            ShowHardcoreReminder(tier, label)
        end
    end

    overlay.hardcoreLastInstanceState = isInstanceNow
end

local function EnsureHardcoreReminderWatcher()
    if overlay.hardcoreReminderWatcher then
        return
    end

    local watcher = CreateFrame("Frame")
    watcher:RegisterEvent("PLAYER_ENTERING_WORLD")
    watcher:RegisterEvent("ZONE_CHANGED_NEW_AREA")
    watcher:SetScript("OnEvent", function()
        if C_Timer and C_Timer.After then
            C_Timer.After(1.0, CheckHardcoreInstanceReminder)
        else
            CheckHardcoreInstanceReminder()
        end
    end)

    overlay.hardcoreReminderWatcher = watcher
end

local function InstallHardmodeThemeHooks()
    if not overlay.enabled or overlay.isPTR then
        return
    end

    local hardmodeUI = _G and _G.ProjectEbonhold and _G.ProjectEbonhold.HardmodeUI
    if hardmodeUI then
        WrapHardmodeUIFunction(hardmodeUI, "Refresh")
    end

    EnsureHardmodeThemeWatcher()
    EnsureHardcoreReminderWatcher()
    ApplyHardmodeTheme()
end

overlay.InstallHardmodeThemeHooks = InstallHardmodeThemeHooks

overlay.GetTargetFrameIntensityThreshold = function()
    local constants = _G and _G.ProjectEbonhold and _G.ProjectEbonhold.Constants
    return constants and constants.INTENSITY_LEVEL_3 or 3
end

overlay.GetCurrentIntensityLevel = function()
    local intensityData = _G and _G.EbonholdIntensityData
    return intensityData and intensityData.intensity or 0
end

overlay.ApplyEliteTargetFrameTexture = function(targetFrame)
    if not targetFrame then
        return
    end

    if targetFrame.borderTexture and targetFrame.borderTexture.SetTexture then
        targetFrame.borderTexture:SetTexture("Interface\\TargetingFrame\\UI-TargetingFrame-Elite")
    end
    targetFrame.haveElite = true

    local threatIndicator = targetFrame.threatIndicator
    if threatIndicator then
        if threatIndicator.SetTexCoord then
            threatIndicator:SetTexCoord(0, 0.9453125, 0.181640625, 0.400390625)
        end
        if threatIndicator.SetWidth then
            threatIndicator:SetWidth(242)
        end
        if threatIndicator.SetHeight then
            threatIndicator:SetHeight(112)
        end
        if threatIndicator.SetPoint then
            threatIndicator:SetPoint("TOPLEFT", targetFrame, "TOPLEFT", -22, 9)
        end
    end
end

overlay.InstallTargetFrameIntensityCue = function()
    if overlay.isPTR or overlay.targetFrameIntensityCueInstalled or not _G then
        return
    end

    local original = _G.TargetFrame_CheckClassification
    if type(original) ~= "function" then
        return
    end

    _G.TargetFrame_CheckClassification = function(targetFrame, forceNormalTexture)
        original(targetFrame, forceNormalTexture)

        if forceNormalTexture or overlay.GetCurrentIntensityLevel() < overlay.GetTargetFrameIntensityThreshold() then
            return
        end

        local unit = targetFrame and targetFrame.unit
        local classification = _G.UnitClassification and _G.UnitClassification(unit) or nil
        if classification ~= "rare" and classification ~= "rareelite" then
            overlay.ApplyEliteTargetFrameTexture(targetFrame)
        end
    end

    overlay.targetFrameIntensityCueInstalled = true
end

local SKILL_TREE_GRAY = {0.45, 0.45, 0.45}
local SKILL_TREE_GREEN = {0.10, 1.00, 0.10}
local SKILL_TREE_ORANGE = {1.00, 0.70, 0.20}
local SKILL_TREE_GOLD = {1.00, 0.82, 0.00}
local SKILL_TREE_APEX = {1.00, 0.20, 1.00}
local SKILL_TREE_WHITE = {1.00, 1.00, 1.00}
local SKILL_TREE_CHOICE_GRAY = {0.30, 0.30, 0.30}
local SKILL_TREE_CHOICE_GREEN = {0.00, 1.00, 0.00}

local function ConfigureSkillTreeText(fontString, size, color, width, justifyH)
    if not fontString then
        return
    end

    if fontString.SetFont then
        fontString:SetFont("Fonts\\FRIZQT__.TTF", ScaledFontSize(size), "OUTLINE")
    end

    if width and fontString.SetWidth then
        fontString:SetWidth(width)
    end

    if fontString.SetWordWrap then
        fontString:SetWordWrap(true)
    end

    if fontString.SetNonSpaceWrap then
        fontString:SetNonSpaceWrap(false)
    end

    if justifyH and fontString.SetJustifyH then
        fontString:SetJustifyH(justifyH)
    end

    if color and fontString.SetTextColor then
        fontString:SetTextColor(color[1], color[2], color[3], 1)
    end
end

local function ParseRankText(fontString)
    local text = GetFontStringText(fontString)
    if not text then
        return nil, nil
    end

    local currentRank, maxRank = text:match("(%d+)%s*/%s*(%d+)")
    return tonumber(currentRank), tonumber(maxRank)
end

overlay.SKILL_TREE_SEARCH_ALIASES = {
    health = {"heal", "health", "regenerat", "absorb", "life"},
    heal = {"heal", "health", "regenerat", "absorb"},
    speed = {"speed", "movement", "haste", "slow", "swift"},
    damage = {"damage", "deal", "strike", "attack", "hit"},
    fire = {"fire", "flame", "burn", "ignite", "ember"},
    nature = {"nature", "poison", "bleed", "thorn"},
    frost = {"frost", "freeze", "chill", "ice"},
    shadow = {"shadow", "dark", "void", "curse"},
    holy = {"holy", "divine", "light", "sacred"},
    armor = {"armor", "defence", "shield", "absorb"},
    crit = {"critical", "crit"},
    mana = {"mana", "energy", "resource", "cost"},
    cooldown = {"cooldown", "recharge"},
    aoe = {"area", "nearby", "surround", "splash"},
    stamina = {"stamina", "health", "endur"},
    dash = {"dash", "sprint", "rush"},
    vanish = {"vanish", "stealth", "invis"}
}

overlay.skillTreeDescriptionCache = overlay.skillTreeDescriptionCache or {}

overlay.GetSkillTreeSearchTerms = function(searchText)
    local lowerSearch = string.lower(searchText or ""):gsub("^%s+", ""):gsub("%s+$", "")
    if lowerSearch == "" or lowerSearch == "missing" then
        return lowerSearch, {}
    end

    local terms = {lowerSearch}
    local aliases = overlay.SKILL_TREE_SEARCH_ALIASES[lowerSearch]
    if aliases then
        for _, alias in ipairs(aliases) do
            terms[#terms + 1] = alias
        end
    end

    return lowerSearch, terms
end

overlay.GetSkillTreeSpellDescription = function(spellId)
    if not spellId then
        return ""
    end

    local cache = overlay.skillTreeDescriptionCache
    if cache[spellId] ~= nil then
        return cache[spellId]
    end

    local description = ""
    local spellUtils = _G and _G.utils
    if spellUtils and spellUtils.GetSpellDescription then
        local ok, result = pcall(spellUtils.GetSpellDescription, spellId, 500, 1)
        if ok and result then
            description = string.lower(tostring(result))
        end
    end

    cache[spellId] = description
    return description
end

overlay.SkillTreeNodeMatchesSearch = function(button, terms, searchMissingNodes)
    if searchMissingNodes then
        local currentRank = ParseRankText(button and button.rankText)
        return (currentRank or 0) == 0
    end

    if not button or type(button.spells) ~= "table" then
        return false
    end

    for _, spellId in ipairs(button.spells) do
        local getSpellInfo = _G and _G.GetSpellInfo
        local spellName = getSpellInfo and getSpellInfo(spellId) or nil
        local nameLower = spellName and string.lower(spellName) or ""
        local description = overlay.GetSkillTreeSpellDescription(spellId)

        for _, term in ipairs(terms) do
            if string.find(nameLower, term, 1, true) or string.find(description, term, 1, true) then
                return true
            end
        end
    end

    return false
end

overlay.GetSkillTreeNodeButtons = function()
    local canvas = _G and _G.skillTreeCanvas
    if not canvas or not canvas.GetChildren then
        return {}
    end

    local childCount = select("#", canvas:GetChildren())
    local cache = overlay._skillTreeNodeButtonCache
    if cache and cache.canvas == canvas and cache.childCount == childCount then
        return cache.nodes
    end

    local nodes = {}
    local children = {canvas:GetChildren()}
    for _, child in ipairs(children) do
        if child and child.id then
            nodes[#nodes + 1] = child
        end
    end

    overlay._skillTreeNodeButtonCache = {
        canvas = canvas,
        childCount = childCount,
        nodes = nodes
    }
    return nodes
end

overlay.skillTreeSearchResultsLayout = {
    width = 220,
    rowHeight = 24,
    rowCount = 8,
    top = -72,
    right = -20,
    headerHeight = 24,
    padding = 8
}

overlay.GetSkillTreeNodeLabel = function(button)
    if not button then
        return "Unknown Node"
    end

    local directName = button.nodeName or button.label
    if type(directName) == "string" and directName ~= "" then
        return directName
    end

    local text = GetFontStringText(button.nameText or button.titleText or button.labelText)
    if text and text ~= "" then
        return text
    end

    if type(button.spells) == "table" and button.spells[1] and _G and _G.GetSpellInfo then
        local spellName = _G.GetSpellInfo(button.spells[1])
        if spellName and spellName ~= "" then
            return spellName
        end
    end

    return "Node " .. tostring(button.id or "?")
end

overlay.GetSkillTreeSearchResultFrames = function()
    local frames = {}
    if _G and _G.PEESkillTreeSearchResults then
        frames[#frames + 1] = _G.PEESkillTreeSearchResults
    end
    if _G and _G.skillTreeSearchResults and _G.skillTreeSearchResults ~= _G.PEESkillTreeSearchResults then
        frames[#frames + 1] = _G.skillTreeSearchResults
    end

    return frames
end

overlay.ClickSkillTreeNode = function(button)
    if not button then
        return
    end

    local onClick = button.GetScript and button:GetScript("OnClick")
    if type(onClick) == "function" then
        onClick(button, "LeftButton")
    elseif button.Click then
        button:Click()
    end
end

overlay.ClickSkillTreeSearchNode = function(button)
    if not button then
        return
    end

    local currentRank = overlay.GetSkillTreeNodeRank and overlay.GetSkillTreeNodeRank(button) or 0
    local maxRank = 1
    if type(button.spells) == "table" then
        maxRank = #button.spells
    elseif type(button.maxRank) == "number" then
        maxRank = button.maxRank
    end

    local clickButton = currentRank >= maxRank and currentRank > 0 and not button.permanent and "RightButton" or
        "LeftButton"
    local onClick = button.GetScript and button:GetScript("OnClick")
    if type(onClick) == "function" then
        onClick(button, clickButton)
    elseif button.Click then
        button:Click()
    end
end

overlay.EnsureSkillTreeSearchResults = function()
    local skillTreeFrame = _G and _G.skillTreeFrame
    local createFrame = _G and _G.CreateFrame
    if not skillTreeFrame or not createFrame then
        return nil
    end

    if skillTreeFrame.peeSearchResults then
        return skillTreeFrame.peeSearchResults
    end

    local layout = overlay.skillTreeSearchResultsLayout
    local frame = createFrame("Frame", "PEESkillTreeSearchResults", skillTreeFrame)
    SetFrameSize(frame, layout.width, layout.headerHeight + (layout.rowCount * layout.rowHeight) + layout.padding)
    frame:SetPoint("TOPRIGHT", skillTreeFrame, "TOPRIGHT", layout.right, layout.top)
    SetDarkBackdrop(frame, 4, 4)
    frame.rows = {}

    frame.title = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    frame.title:SetPoint("TOPLEFT", frame, "TOPLEFT", layout.padding, -6)
    ConfigureSkillTreeText(frame.title, 10, MAGE_BLUE, layout.width - (layout.padding * 2), "LEFT")
    frame.title:SetText("Search Results")

    frame.emptyText = frame:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
    frame.emptyText:SetPoint("TOPLEFT", frame, "TOPLEFT", layout.padding, -(layout.headerHeight + 4))
    ConfigureSkillTreeText(frame.emptyText, 10, MUTED, layout.width - (layout.padding * 2), "LEFT")
    frame.emptyText:SetText("No matches")

    for index = 1, layout.rowCount do
        local row = createFrame("Button", nil, frame)
        SetFrameSize(row, layout.width - (layout.padding * 2), layout.rowHeight)
        row:SetPoint(
            "TOPLEFT",
            frame,
            "TOPLEFT",
            layout.padding,
            -(layout.headerHeight + ((index - 1) * layout.rowHeight))
        )
        SetButtonBackdrop(row, DARK, BLACK)
        row.text = row:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        row.text:SetPoint("LEFT", row, "LEFT", 6, 0)
        ConfigureSkillTreeText(row.text, 10, CREAM, layout.width - (layout.padding * 2) - 12, "LEFT")
        row:SetScript("OnClick", function(self)
            overlay.ClickSkillTreeNode(self.node)
        end)
        row:Hide()
        frame.rows[index] = row
    end

    skillTreeFrame.peeSearchResults = frame
    _G.PEESkillTreeSearchResults = frame
    frame._peeSearchLayout = {
        width = layout.width,
        rowHeight = layout.rowHeight,
        rowCount = layout.rowCount,
        top = layout.top,
        right = layout.right
    }
    frame:Hide()
    return frame
end

overlay.RefreshSkillTreeSearchResults = function(matches, searchText)
    local frame = overlay.EnsureSkillTreeSearchResults()
    if not frame then
        return
    end

    searchText = tostring(searchText or ""):gsub("^%s+", ""):gsub("%s+$", "")
    if searchText == "" then
        frame:Hide()
        return
    end

    local matchCount = type(matches) == "table" and #matches or 0
    if frame.emptyText then
        if matchCount == 0 then
            frame.emptyText:Show()
        else
            frame.emptyText:Hide()
        end
    end

    for index, row in ipairs(frame.rows) do
        local node = matches and matches[index]
        if node then
            row.node = node
            row.text:SetText(overlay.GetSkillTreeNodeLabel(node))
            row:Show()
        else
            row.node = nil
            row:Hide()
        end
    end

    frame:Show()
end

overlay.ApplySkillTreeSearchFilter = function(searchText)
    local lowerSearch, terms = overlay.GetSkillTreeSearchTerms(searchText)
    local isEmpty = lowerSearch == ""
    local searchMissingNodes = lowerSearch == "missing"
    local matches = {}

    if isEmpty then
        if overlay._skillTreeSearchHadFilter then
            for _, button in ipairs(overlay.GetSkillTreeNodeButtons()) do
                if button.SetAlpha then
                    button:SetAlpha(1.0)
                end
            end
        end
        overlay._skillTreeSearchHadFilter = nil
        overlay.RefreshSkillTreeSearchResults(matches, lowerSearch)
        return matches
    end

    overlay._skillTreeSearchHadFilter = true
    for _, button in ipairs(overlay.GetSkillTreeNodeButtons()) do
        local nodeMatches = overlay.SkillTreeNodeMatchesSearch(button, terms, searchMissingNodes)
        if button.SetAlpha then
            button:SetAlpha(nodeMatches and 1.0 or 0.15)
        end
        if nodeMatches then
            matches[#matches + 1] = button
        end
    end

    overlay.RefreshSkillTreeSearchResults(matches, lowerSearch)
    return matches
end

overlay.UpdateSkillTreeSearchClearButton = function(searchBox)
    local clearButton = searchBox and searchBox._peeSkillTreeSearchClearButton
    if not clearButton then
        return
    end

    local text = searchBox.GetText and searchBox:GetText() or ""
    if text == "" then
        clearButton:Hide()
    else
        clearButton:Show()
    end
end

overlay.EnsureSkillTreeSearchClearButton = function(searchBox)
    local createFrame = _G and _G.CreateFrame
    if not searchBox or not createFrame then
        return
    end

    if searchBox.SetTextInsets then
        searchBox:SetTextInsets(0, 16, 0, 0)
    end

    if not searchBox._peeSkillTreeSearchClearButton then
        local clearButton = createFrame("Button", nil, searchBox)
        SetFrameSize(clearButton, 14, 14)
        clearButton:SetPoint("RIGHT", searchBox, "RIGHT", -4, 0)
        if clearButton.SetFrameLevel and searchBox.GetFrameLevel then
            clearButton:SetFrameLevel((searchBox:GetFrameLevel() or 1) + 1)
        end

        clearButton.text = clearButton:CreateFontString(nil, "OVERLAY")
        clearButton.text:SetFont("Fonts\\FRIZQT__.TTF", ScaledFontSize(12), "OUTLINE")
        clearButton.text:SetPoint("CENTER", clearButton, "CENTER", 0, 0)
        clearButton.text:SetText("X")
        clearButton.text:SetTextColor(0.7, 0.7, 0.7, 1)

        clearButton:SetScript("OnEnter", function(self)
            self.text:SetTextColor(1, 0.4, 0.4, 1)
        end)
        clearButton:SetScript("OnLeave", function(self)
            self.text:SetTextColor(0.7, 0.7, 0.7, 1)
        end)
        clearButton:SetScript("OnClick", function()
            if searchBox.SetText then
                searchBox:SetText("")
            end
            if searchBox.ClearFocus then
                searchBox:ClearFocus()
            end

            local onTextChanged = searchBox.GetScript and searchBox:GetScript("OnTextChanged")
            if type(onTextChanged) == "function" then
                onTextChanged(searchBox)
            else
                overlay.ApplySkillTreeSearchFilter("")
            end
            overlay.UpdateSkillTreeSearchClearButton(searchBox)
        end)

        searchBox._peeSkillTreeSearchClearButton = clearButton
    end

    overlay.UpdateSkillTreeSearchClearButton(searchBox)
end

overlay.WrapSkillTreeSearchBox = function(searchBox)
    if not searchBox or not searchBox.GetScript or not searchBox.SetScript then
        return
    end

    if not searchBox._peeSkillTreeSearchWrapper then
        searchBox._peeSkillTreeSearchWrapper = function(self, ...)
            if type(self._peeOriginalSkillTreeSearch) == "function" then
                self._peeOriginalSkillTreeSearch(self, ...)
            end

            local searchText = self.GetText and self:GetText() or ""
            overlay.ApplySkillTreeSearchFilter(searchText)
            overlay.UpdateSkillTreeSearchClearButton(self)
        end
    end

    local currentSearch = searchBox:GetScript("OnTextChanged")
    if currentSearch ~= searchBox._peeSkillTreeSearchWrapper then
        searchBox._peeOriginalSkillTreeSearch = currentSearch
        searchBox:SetScript("OnTextChanged", searchBox._peeSkillTreeSearchWrapper)
    end

    overlay.EnsureSkillTreeSearchClearButton(searchBox)
end

local function GetSkillTreeNodeColor(button)
    if not button then
        return SKILL_TREE_GRAY
    end

    if button.isApex then
        return SKILL_TREE_APEX
    end

    if button.state == "active" then
        local currentRank, maxRank = ParseRankText(button.rankText)
        if currentRank and maxRank and currentRank >= maxRank then
            return SKILL_TREE_ORANGE
        end

        return SKILL_TREE_GREEN
    end

    if button.state == "ready" then
        return SKILL_TREE_GREEN
    end

    if button.state == "nopoints" then
        return SKILL_TREE_GOLD
    end

    return SKILL_TREE_GRAY
end

local function SetFrameBorderColor(frame, color)
    if frame and frame.SetBackdropBorderColor then
        frame:SetBackdropBorderColor(color[1], color[2], color[3], 1)
    end
end

local function SetTextureBorderColor(texture, color)
    if texture and texture.SetVertexColor then
        texture:SetVertexColor(color[1], color[2], color[3], 1)
    end
end

function overlay.SkillTreeCanvas()
    return _G and _G.skillTreeCanvas
end

function overlay.MarkSkillTreeNodeBorderDirty(canvas)
    overlay._peeSkillTreeNodeBorderDirty = true
    canvas = canvas or overlay.SkillTreeCanvas()
    if canvas then
        canvas._peeSkillTreeNodeBorderDirty = true
    end
end

function overlay.CancelSkillTreeNodeStyleBatch(canvas)
    canvas = canvas or overlay.SkillTreeCanvas()
    if canvas then
        canvas._peeSkillTreeStyleToken = (canvas._peeSkillTreeStyleToken or 0) + 1
    end
end

function overlay.IsSkillTreeNodeBorderFrozen()
    return overlay._peeSkillTreeNodeBorderFrozen == true
end

overlay.SetSkillTreeNodeBorderFreeze = function(active, source)
    source = source or "default"
    overlay._peeSkillTreeNodeBorderFreezeSources = overlay._peeSkillTreeNodeBorderFreezeSources or {}

    if active then
        overlay._peeSkillTreeNodeBorderFreezeSources[source] = true
        overlay._peeSkillTreeNodeBorderFrozen = true
        overlay.MarkSkillTreeNodeBorderDirty()
        overlay.CancelSkillTreeNodeStyleBatch()
    else
        overlay._peeSkillTreeNodeBorderFreezeSources[source] = nil
        if next(overlay._peeSkillTreeNodeBorderFreezeSources) then
            return
        end

        overlay._peeSkillTreeNodeBorderFreezeSources = nil
        overlay._peeSkillTreeNodeBorderFrozen = nil
    end

    if overlay.GetSkillTreeNodeButtons then
        for _, node in ipairs(overlay.GetSkillTreeNodeButtons()) do
            if node then
                if node.borderFrame then
                    node.borderFrame._peeSkillTreeZoomFrozen = active or nil
                end
                if node.borderTex then
                    node.borderTex._peeSkillTreeZoomFrozen = active or nil
                end
            end
        end
    end

    if not active then
        local canvas = overlay.SkillTreeCanvas()
        local dirty = overlay._peeSkillTreeNodeBorderDirty or (canvas and canvas._peeSkillTreeNodeBorderDirty)
        overlay._peeSkillTreeNodeBorderDirty = nil
        if canvas then
            canvas._peeSkillTreeNodeBorderDirty = nil
        end
        if dirty and canvas and overlay.QueueSkillTreeNodeStyling then
            overlay.QueueSkillTreeNodeStyling(canvas, true)
        end
    end
end

local function SkinSkillTreeNodeBorder(button, color)
    if not button then
        return
    end

    if overlay.IsSkillTreeNodeBorderFrozen() or
        (button.borderFrame and button.borderFrame._peeSkillTreeZoomFrozen) or
        (button.borderTex and button.borderTex._peeSkillTreeZoomFrozen) then
        overlay.MarkSkillTreeNodeBorderDirty()
        return
    end

    local borderColor = color or GetSkillTreeNodeColor(button)

    if button.borderFrame then
        SetFrameBackdrop(button.borderFrame, 1, 1)
        if button.borderFrame.SetBackdropColor then
            button.borderFrame:SetBackdropColor(0, 0, 0, 0)
        end
        SetFrameBorderColor(button.borderFrame, borderColor)
    end

    if button.borderTex then
        if button.borderTex.SetTexture then
            button.borderTex:SetTexture("Interface\\Buttons\\WHITE8x8")
        end
        SetTextureBorderColor(button.borderTex, borderColor)
    end
end

local function GetSkillTreeChoiceColor(parentButton, choiceIndex)
    if not parentButton or parentButton.state == "locked" then
        return SKILL_TREE_CHOICE_GRAY
    end

    if parentButton.selectedSpell == choiceIndex then
        return SKILL_TREE_CHOICE_GREEN
    end

    return SKILL_TREE_WHITE
end

overlay.ScheduleSkillTreeChromeRefresh = function()
    local function refresh()
        if overlay.QueueSkillTreeNodeStyling then
            overlay.QueueSkillTreeNodeStyling(_G and _G.skillTreeCanvas, true)
        end
        if overlay.ApplySkillTreeChrome then
            overlay.ApplySkillTreeChrome()
        end
    end

    if C_Timer and C_Timer.After then
        C_Timer.After(0, refresh)
    else
        refresh()
    end
end

overlay.HookSkillTreeChromeRefresh = function(button)
    if not button or button._peeSkillTreeChromeRefreshHook or not button.HookScript then
        return
    end

    button:HookScript("OnClick", overlay.ScheduleSkillTreeChromeRefresh)
    button._peeSkillTreeChromeRefreshHook = true
end

local function SkinSkillTreeChoiceButton(button, parentButton, choiceIndex)
    if not button then
        return
    end

    SkinSkillTreeNodeBorder(button, GetSkillTreeChoiceColor(parentButton, choiceIndex))
    overlay.HookSkillTreeChromeRefresh(button)
end

local function SkinSkillTreeNode(button)
    if not button or not button.id then
        return
    end

    SkinSkillTreeNodeBorder(button)
    ConfigureSkillTreeText(button.rankText, 9, nil, nil, "RIGHT")
    overlay.HookSkillTreeChromeRefresh(button)

    if type(button.choiceButtons) == "table" then
        for index, choiceButton in ipairs(button.choiceButtons) do
            SkinSkillTreeChoiceButton(choiceButton, button, index)
        end
    end
end

local function SkinSkillTreeSearchBox(searchBox)
    if not searchBox then
        return
    end

    SetFrameBackdrop(searchBox, 1, 1)

    if searchBox.SetBackdropColor then
        searchBox:SetBackdropColor(0.02, 0.02, 0.02, 1)
    end

    if searchBox.SetBackdropBorderColor then
        searchBox:SetBackdropBorderColor(BLACK[1], BLACK[2], BLACK[3], 1)
    end

    if searchBox.SetTextColor then
        searchBox:SetTextColor(CREAM[1], CREAM[2], CREAM[3], 1)
    end

    if searchBox.SetFont then
        searchBox:SetFont("Fonts\\FRIZQT__.TTF", ScaledFontSize(11), "OUTLINE")
    end

    overlay.WrapSkillTreeSearchBox(searchBox)

    if searchBox._peeSkillTreeSearchHooks then
        return
    end

    local function onFocusGained()
        if searchBox.SetBackdropBorderColor then
            searchBox:SetBackdropBorderColor(HOVER_BLUE[1], HOVER_BLUE[2], HOVER_BLUE[3], 1)
        end
        if searchBox._peeSkillTreeSearchBackdrop and searchBox._peeSkillTreeSearchBackdrop.SetBackdropBorderColor then
            searchBox._peeSkillTreeSearchBackdrop:SetBackdropBorderColor(HOVER_BLUE[1], HOVER_BLUE[2], HOVER_BLUE[3], 1)
        end
    end

    local function onFocusLost()
        if searchBox.SetBackdropBorderColor then
            searchBox:SetBackdropBorderColor(BLACK[1], BLACK[2], BLACK[3], 1)
        end
        if searchBox._peeSkillTreeSearchBackdrop and searchBox._peeSkillTreeSearchBackdrop.SetBackdropBorderColor then
            searchBox._peeSkillTreeSearchBackdrop:SetBackdropBorderColor(BLACK[1], BLACK[2], BLACK[3], 1)
        end
    end

    if searchBox.HookScript then
        searchBox:HookScript("OnEditFocusGained", onFocusGained)
        searchBox:HookScript("OnEditFocusLost", onFocusLost)
        searchBox._peeSkillTreeSearchHooks = true
    end
end

overlay.GetSkillTreeProfilePopupText = function(popup)
    if not popup then
        return nil
    end

    if popup.text then
        return popup.text
    end

    local popupName = popup.GetName and popup:GetName()
    if popupName and _G then
        return _G[popupName .. "Text"]
    end

    return nil
end

overlay.GetSkillTreeProfilePopupEditBox = function(popup)
    if not popup then
        return nil
    end

    if popup.editBox then
        return popup.editBox
    end

    local popupName = popup.GetName and popup:GetName()
    if popupName and _G then
        return _G[popupName .. "EditBox"]
    end

    return nil
end

overlay.GetSkillTreeProfilePopupButton = function(popup, index)
    if not popup then
        return nil
    end

    local button = popup["button" .. tostring(index)]
    if button then
        return button
    end

    local popupName = popup.GetName and popup:GetName()
    if popupName and _G then
        return _G[popupName .. "Button" .. tostring(index)]
    end

    return nil
end

overlay.IsSkillTreeProfilePopup = function(which, popup)
    if which == "SKILLTREE_NEW_BUILD" then
        return true
    end

    local dialog = _G and _G.StaticPopupDialogs and which and _G.StaticPopupDialogs[which]
    if dialog and dialog.text == "Enter build name:" then
        return true
    end

    local text = overlay.GetSkillTreeProfilePopupText(popup)
    local value = text and text.GetText and text:GetText()
    return value == "Enter build name:"
end

overlay.SuppressSkillTreeProfilePopupArt = function(popup)
    if not popup or popup._peeSkillTreeProfileArtSuppressed or not popup.GetRegions then
        return
    end

    local ok, regions = pcall(function()
        return { popup:GetRegions() }
    end)
    if ok then
        for _, region in ipairs(regions) do
            if region and region.SetTexture then
                overlay.SuppressTextureRegion(region)
            end
        end
    end

    popup._peeSkillTreeProfileArtSuppressed = true
end

overlay.SkinSkillTreeProfilePopup = function(popup)
    if not popup then
        return
    end

    overlay.SuppressSkillTreeProfilePopupArt(popup)
    SetDarkBackdrop(popup, 4, 4)

    local text = overlay.GetSkillTreeProfilePopupText(popup)
    ConfigureSkillTreeText(text, 14, CREAM, nil, "CENTER")

    local editBox = overlay.GetSkillTreeProfilePopupEditBox(popup)
    if editBox then
        SetFrameBackdrop(editBox, 2, 1)
        if editBox.SetBackdropColor then
            editBox:SetBackdropColor(0.02, 0.02, 0.02, 1)
        end
        if editBox.SetBackdropBorderColor then
            editBox:SetBackdropBorderColor(BLACK[1], BLACK[2], BLACK[3], 1)
        end
        if editBox.SetTextColor then
            editBox:SetTextColor(CREAM[1], CREAM[2], CREAM[3], 1)
        end
        if editBox.SetFont then
            editBox:SetFont("Fonts\\FRIZQT__.TTF", ScaledFontSize(12), "OUTLINE")
        end
        if editBox.SetTextInsets then
            editBox:SetTextInsets(6, 6, 0, 0)
        end
        if editBox.HookScript and not editBox._peeSkillTreeProfileHooks then
            editBox:HookScript("OnEditFocusGained", function(self)
                if self.SetBackdropBorderColor then
                    self:SetBackdropBorderColor(HOVER_BLUE[1], HOVER_BLUE[2], HOVER_BLUE[3], 1)
                end
            end)
            editBox:HookScript("OnEditFocusLost", function(self)
                if self.SetBackdropBorderColor then
                    self:SetBackdropBorderColor(BLACK[1], BLACK[2], BLACK[3], 1)
                end
            end)
            editBox._peeSkillTreeProfileHooks = true
        end
    end

    for index = 1, 2 do
        SkinRuntimeButton(
            overlay.GetSkillTreeProfilePopupButton(popup, index),
            BANISH_BACKDROP,
            WHITE,
            BLACK,
            BANISH_HOVER_BACKDROP,
            overlay.buttonBorders.banishHover
        )
    end

    popup._peeSkillTreeProfilePopupSkinned = true
end

overlay.SkinVisibleSkillTreeProfilePopups = function(which, popup)
    if not overlay.enabled or overlay.isPTR then
        return
    end

    if popup and overlay.IsSkillTreeProfilePopup(which, popup) then
        overlay.SkinSkillTreeProfilePopup(popup)
        return
    end

    if not _G then
        return
    end

    for index = 1, 4 do
        local frame = _G["StaticPopup" .. tostring(index)]
        if frame and (not frame.IsShown or frame:IsShown()) and overlay.IsSkillTreeProfilePopup(which, frame) then
            overlay.SkinSkillTreeProfilePopup(frame)
        end
    end
end

overlay.EnsureSkillTreeProfilePopupHook = function()
    if overlay._peeSkillTreeProfilePopupHooked or not _G or type(_G.StaticPopup_Show) ~= "function" then
        return
    end

    overlay._peeOriginalStaticPopupShow = _G.StaticPopup_Show
    _G.StaticPopup_Show = function(which, ...)
        local popup = overlay._peeOriginalStaticPopupShow(which, ...)
        overlay.SkinVisibleSkillTreeProfilePopups(which, popup)
        return popup
    end
    overlay._peeSkillTreeProfilePopupHooked = true
end

overlay.QueueSkillTreeNodeStyling = function(canvas, force)
    if not canvas or not canvas.GetChildren then
        return
    end

    if overlay.IsSkillTreeNodeBorderFrozen() then
        overlay.MarkSkillTreeNodeBorderDirty(canvas)
        overlay.CancelSkillTreeNodeStyleBatch(canvas)
        return
    end

    local childCount = select("#", canvas:GetChildren())
    if not force and canvas._peeStyledSkillTreeChildCount == childCount and canvas._peeSkillTreeStyleComplete then
        return
    end

    local children = { canvas:GetChildren() }
    canvas._peeSkillTreeStyleToken = (canvas._peeSkillTreeStyleToken or 0) + 1
    local token = canvas._peeSkillTreeStyleToken
    local index = 1
    local batchSize = 24
    canvas._peeStyledSkillTreeChildCount = childCount
    canvas._peeSkillTreeStyleComplete = false

    if overlay.InvalidateSkillTreeLineCache then
        overlay.InvalidateSkillTreeLineCache()
    end

    local function runBatch()
        if canvas._peeSkillTreeStyleToken ~= token then
            return
        end
        if overlay.IsSkillTreeNodeBorderFrozen() then
            overlay.MarkSkillTreeNodeBorderDirty(canvas)
            overlay.CancelSkillTreeNodeStyleBatch(canvas)
            return
        end

        local stopIndex = math.min(#children, index + batchSize - 1)
        while index <= stopIndex do
            SkinSkillTreeNode(children[index])
            index = index + 1
        end

        if index <= #children then
            if C_Timer and C_Timer.After then
                C_Timer.After(0, runBatch)
            else
                runBatch()
            end
            return
        end

        canvas._peeSkillTreeStyleComplete = true
    end

    if C_Timer and C_Timer.After then
        C_Timer.After(0, runBatch)
    else
        runBatch()
    end
end

overlay.GetSkillTreeNodeRank = function(button)
    if not button then
        return 0
    end

    if type(button.rank) == "number" then
        return button.rank
    end
    if type(button.currentRank) == "number" then
        return button.currentRank
    end

    local rankText = GetFontStringText(button.rankText)
    if type(rankText) == "string" then
        local rank = tonumber(rankText:match("^(%d+)"))
        if rank then
            return rank
        end
        if rankText ~= "" and rankText ~= "0" then
            return 1
        end
    end

    if button.state == "active" or button.selectedSpell then
        return 1
    end

    return 0
end

overlay.EnsureSkillTreeNodeStatsText = function(skillTreeFrame)
    if not skillTreeFrame or skillTreeFrame.nodeStatsText or not CreateFrame then
        return
    end

    local nodeStatsFrame = CreateFrame("Frame", nil, skillTreeFrame)
    SetFrameSize(nodeStatsFrame, 240, 40)
    nodeStatsFrame:SetPoint("TOPLEFT", skillTreeFrame, "TOPLEFT", 12, -8)
    if nodeStatsFrame.SetFrameLevel and skillTreeFrame.GetFrameLevel then
        nodeStatsFrame:SetFrameLevel((skillTreeFrame:GetFrameLevel() or 1) + 10)
    end

    local nodeStatsText = nodeStatsFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    nodeStatsText:SetPoint("TOPLEFT", nodeStatsFrame, "TOPLEFT", 0, 0)
    nodeStatsText:SetJustifyH("LEFT")
    nodeStatsText:SetText("")
    skillTreeFrame.peeNodeStatsFrame = nodeStatsFrame
    skillTreeFrame.nodeStatsText = nodeStatsText
end

overlay.RefreshSkillTreeNodeStatsText = function(skillTreeFrame)
    if not skillTreeFrame or not skillTreeFrame.nodeStatsText then
        return
    end

    local canvas = _G and _G.skillTreeCanvas
    if not canvas or not canvas.GetChildren then
        return
    end

    local totalNodes = 0
    local usedNodes = 0
    local permanentTotal = 0
    local permanentUsed = 0
    for _, button in ipairs({ canvas:GetChildren() }) do
        if button and (button.id or button.spells or button.rankText) then
            totalNodes = totalNodes + 1
            local rank = overlay.GetSkillTreeNodeRank(button)
            if rank > 0 then
                usedNodes = usedNodes + 1
            end
            if button.permanent then
                permanentTotal = permanentTotal + 1
                if rank > 0 then
                    permanentUsed = permanentUsed + 1
                end
            end
        end
    end

    local freePoints = TALENT_POINTS_TOTAL
    if freePoints == nil and skillTreeFrame.pointsText then
        local text = GetFontStringText(skillTreeFrame.pointsText) or ""
        freePoints = text:match("(%d+)%D*$")
    end

    skillTreeFrame.peeSkillTreeStats = {
        nodesUsed = usedNodes - permanentUsed,
        nodesTotal = totalNodes - permanentTotal,
        permanentUsed = permanentUsed,
        permanentTotal = permanentTotal,
        freePoints = freePoints or 0
    }

    skillTreeFrame.nodeStatsText:SetText(
        "|cffbbbbbbNodes:|r " .. tostring(usedNodes - permanentUsed) .. "/" ..
        tostring(totalNodes - permanentTotal) .. "  |cffbbbbbbPerm:|r " ..
        tostring(permanentUsed) .. "/" .. tostring(permanentTotal) ..
        "  |cffbbbbbbFree Pts:|r " .. tostring(freePoints or 0)
    )
end

overlay.EnsureSkillTreeLegacyButtons = function(bottomBar)
    if not bottomBar or bottomBar._peeLegacySkillButtonsReady or not CreateFrame then
        return
    end

    local anchor = _G and _G.skillTreeApplyButton
    if not _G.PEESkillTreeResetButton then
        local resetButton = CreateFrame("Button", "PEESkillTreeResetButton", bottomBar, "UIPanelButtonTemplate")
        SetFrameSize(resetButton, 60, 22)
        if anchor and anchor.SetPoint then
            resetButton:SetPoint("LEFT", anchor, "RIGHT", 8, 0)
        else
            resetButton:SetPoint("LEFT", bottomBar, "LEFT", 180, 0)
        end
        resetButton:SetText("Reset")
        resetButton:SetScript("OnClick", function()
            StaticPopupDialogs["PEE_SKILLTREE_CONFIRM_RESET"] = {
                text = "Reset all non-permanent skill nodes?\n\nPermanent nodes will be kept. " ..
                    "You must click Apply Changes to save.",
                button1 = "Reset",
                button2 = "Cancel",
                OnAccept = function()
                    if type(_G.resetNonPermanentNodes) == "function" then
                        _G.resetNonPermanentNodes()
                    elseif overlay.StartSkillTreeVisibleReset then
                        overlay.StartSkillTreeVisibleReset()
                    end
                end,
                timeout = 0,
                whileDead = true,
                hideOnEscape = true,
                preferredIndex = 3
            }
            StaticPopup_Show("PEE_SKILLTREE_CONFIRM_RESET")
        end)
        resetButton:SetScript("OnEnter", function(self)
            GameTooltip:SetOwner(self, "ANCHOR_TOP")
            GameTooltip:SetText("Reset Skills", 1, 0.3, 0.3)
            GameTooltip:AddLine("Remove all non-permanent skill nodes.", 0.8, 0.8, 0.8, true)
            GameTooltip:AddLine(" ")
            GameTooltip:AddLine("Permanent nodes cannot be reset.", 1, 0.5, 0.5, true)
            GameTooltip:Show()
        end)
        resetButton:SetScript("OnLeave", function() GameTooltip:Hide() end)
        SkinRuntimeButton(resetButton, DARK, CREAM)
        anchor = resetButton
    end

    if not _G.PEESkillTreeProfilesButton then
        local profilesButton = CreateFrame("Button", "PEESkillTreeProfilesButton", bottomBar, "UIPanelButtonTemplate")
        SetFrameSize(profilesButton, 70, 22)
        if anchor and anchor.SetPoint then
            profilesButton:SetPoint("LEFT", anchor, "RIGHT", 4, 0)
        else
            profilesButton:SetPoint("LEFT", bottomBar, "LEFT", 244, 0)
        end
        profilesButton:SetText("Profiles")
        profilesButton:SetScript("OnClick", function()
            if overlay.EnsureSkillTreeProfilePopupHook then
                overlay.EnsureSkillTreeProfilePopupHook()
            end
            if type(_G.ToggleProfileFrame) == "function" then
                _G.ToggleProfileFrame()
            elseif _G.skillTreeLoadoutDropdown and ToggleDropDownMenu then
                ToggleDropDownMenu(1, nil, _G.skillTreeLoadoutDropdown, profilesButton, 0, 0)
            end
        end)
        profilesButton:SetScript("OnEnter", function(self)
            GameTooltip:SetOwner(self, "ANCHOR_TOP")
            GameTooltip:SetText("Profiles", 1, 0.82, 0)
            GameTooltip:AddLine("Save and load skill tree builds.", 0.8, 0.8, 0.8, true)
            GameTooltip:Show()
        end)
        profilesButton:SetScript("OnLeave", function() GameTooltip:Hide() end)
        SkinRuntimeButton(profilesButton, DARK, CREAM)
    end

    bottomBar._peeLegacySkillButtonsReady = true
end

overlay.StartSkillTreeVisibleReset = function()
    if overlay.skillTreeResetRunner then
        return
    end

    if UnitAffectingCombat and UnitAffectingCombat("player") then
        PrintMessage("You cannot reset skill nodes while in combat.")
        return
    end

    local nodes = overlay.GetSkillTreeNodeButtons and overlay.GetSkillTreeNodeButtons() or {}
    local runner = CreateFrame("Frame")
    local index = 1
    local idlePasses = 0
    local resetCount = 0

    local function finish(message)
        runner:SetScript("OnUpdate", nil)
        overlay.skillTreeResetRunner = nil
        if message then
            PrintMessage(message)
        else
            PrintMessage("Reset " .. tostring(resetCount) .. " skill rank" .. (resetCount == 1 and "" or "s") ..
                ". Click Apply Changes to save.")
        end
        if overlay.ApplySkillTreeTheme then
            overlay.ApplySkillTreeTheme()
        end
    end

    runner.elapsed = 0
    runner:SetScript("OnUpdate", function(self, elapsed)
        self.elapsed = (self.elapsed or 0) + (elapsed or 0)
        if self.elapsed < 0.45 then
            return
        end
        self.elapsed = 0

        if index > #nodes then
            index = 1
            idlePasses = idlePasses + 1
            if idlePasses >= 2 then
                finish()
            end
            return
        end

        local node = nodes[index]
        index = index + 1
        if not node or node.permanent or node.isMultipleChoice then
            return
        end

        local beforeRank = overlay.GetSkillTreeNodeRank and overlay.GetSkillTreeNodeRank(node) or 0
        if beforeRank <= 0 then
            return
        end

        local onClick = node.GetScript and node:GetScript("OnClick")
        if type(onClick) == "function" then
            onClick(node, "RightButton")
        end

        local afterRank = overlay.GetSkillTreeNodeRank and overlay.GetSkillTreeNodeRank(node) or 0
        if afterRank < beforeRank then
            resetCount = resetCount + (beforeRank - afterRank)
            idlePasses = 0
        end
    end)

    overlay.skillTreeResetRunner = runner
end

local function SkinSkillTreeBottomBar(bottomBar)
    if not bottomBar then
        return
    end

    SetDarkBackdrop(bottomBar, 4, 4)
    HideTextureRegion(bottomBar, "Interface\\AddOns\\ProjectEbonhold\\assets\\texture_bottom")

    ForEachFrameRegion(bottomBar, function(region)
        if GetFontStringText(region) == "Search:" then
            ConfigureSkillTreeText(region, 11, CREAM, nil, "LEFT")
        end
    end)

    if bottomBar.levelRestrictionFrame then
        SetDarkBackdrop(bottomBar.levelRestrictionFrame, 4, 4)
        if bottomBar.levelRestrictionFrame.SetBackdropColor then
            bottomBar.levelRestrictionFrame:SetBackdropColor(0, 0, 0, GetBackdropOpacity())
        end
    end

    overlay.EnsureSkillTreeLegacyButtons(bottomBar)
end

local function GetSkillTreeFrameStore()
    EnsureSavedVariables()
    if type(overlay.db.skillTreeFrame) ~= "table" then
        overlay.db.skillTreeFrame = {}
    end

    return overlay.db.skillTreeFrame
end

local function SaveSkillTreePlacement(skillTreeFrame)
    local store = GetSkillTreeFrameStore()

    if skillTreeFrame.GetPoint then
        local point, _, relativePoint, xOffset, yOffset = skillTreeFrame:GetPoint(1)
        store.position = {
            point = point,
            relativePoint = relativePoint,
            x = xOffset,
            y = yOffset
        }
    end

    if skillTreeFrame.GetWidth and skillTreeFrame.GetHeight then
        store.size = {
            width = skillTreeFrame:GetWidth(),
            height = skillTreeFrame:GetHeight()
        }
    end
end

local function RestoreSkillTreePlacement(skillTreeFrame)
    local store = GetSkillTreeFrameStore()

    if type(store.size) == "table" and store.size.width and store.size.height then
        if skillTreeFrame.SetSize then
            skillTreeFrame:SetSize(math.max(store.size.width, 900), math.max(store.size.height, 400))
        else
            SetFrameSize(skillTreeFrame, math.max(store.size.width, 900), math.max(store.size.height, 400))
        end
    end

    if type(store.position) == "table" and store.position.point and skillTreeFrame.SetPoint then
        if skillTreeFrame.ClearAllPoints then
            skillTreeFrame:ClearAllPoints()
        end
        skillTreeFrame:SetPoint(
            store.position.point,
            UIParent,
            store.position.relativePoint or "CENTER",
            store.position.x or 0,
            store.position.y or 0
        )
    end
end

overlay.StartSkillTreeFrameDrag = function(skillTreeFrame)
    if not skillTreeFrame then
        return
    end

    overlay._peeSkillTreeFrameInteracting = true
    local scrollFrame = _G and _G.skillTreeScroll
    if scrollFrame then
        overlay._peeSkillTreeDragHiddenScrollFrame = scrollFrame
        overlay._peeSkillTreeDragScrollWasShown = not scrollFrame.IsShown or scrollFrame:IsShown()
        if scrollFrame.Hide then
            scrollFrame:Hide()
        end
    end
    if overlay.SetSkillTreeNodeBorderFreeze then
        overlay.SetSkillTreeNodeBorderFreeze(true, "frame-drag")
    end

    if skillTreeFrame.StartMoving then
        skillTreeFrame:StartMoving()
    end
end

overlay.StopSkillTreeFrameDrag = function(skillTreeFrame)
    if not skillTreeFrame then
        return
    end

    if skillTreeFrame.StopMovingOrSizing then
        skillTreeFrame:StopMovingOrSizing()
    end

    SaveSkillTreePlacement(skillTreeFrame)
    local scrollFrame = overlay._peeSkillTreeDragHiddenScrollFrame or (_G and _G.skillTreeScroll)
    if scrollFrame and overlay._peeSkillTreeDragScrollWasShown ~= false and scrollFrame.Show then
        scrollFrame:Show()
    end
    overlay._peeSkillTreeDragHiddenScrollFrame = nil
    overlay._peeSkillTreeDragScrollWasShown = nil
    if overlay.ScheduleSkillTreeFitAndCenter then
        overlay.ScheduleSkillTreeFitAndCenter(true)
    end
    overlay._peeSkillTreeFrameInteracting = nil
    if overlay.SetSkillTreeNodeBorderFreeze then
        overlay.SetSkillTreeNodeBorderFreeze(false, "frame-drag")
    end
end

local function EnsureSkillTreeMoveResize(skillTreeFrame)
    if not skillTreeFrame or not UIParent then
        return
    end
    if skillTreeFrame._peeMoveResizeReady then
        if overlay.InstallSkillTreeOwnedFitHandlers then
            overlay.InstallSkillTreeOwnedFitHandlers(skillTreeFrame)
        end
        return
    end

    if skillTreeFrame.SetMovable then
        skillTreeFrame:SetMovable(true)
    end
    if skillTreeFrame.EnableMouse then
        skillTreeFrame:EnableMouse(true)
    end
    if skillTreeFrame.SetClampedToScreen then
        skillTreeFrame:SetClampedToScreen(true)
    end
    if skillTreeFrame.RegisterForDrag then
        skillTreeFrame:RegisterForDrag("LeftButton")
    end
    if skillTreeFrame.SetResizable then
        skillTreeFrame:SetResizable(true)
    end
    if skillTreeFrame.SetMinResize then
        skillTreeFrame:SetMinResize(900, 400)
    end
    if skillTreeFrame.SetMaxResize then
        skillTreeFrame:SetMaxResize(2400, 1600)
    end

    if skillTreeFrame.SetScript then
        local originalDragStart = skillTreeFrame.GetScript and skillTreeFrame:GetScript("OnDragStart")
        local originalDragStop = skillTreeFrame.GetScript and skillTreeFrame:GetScript("OnDragStop")
        skillTreeFrame._peeOriginalSkillTreeDragStart = originalDragStart
        skillTreeFrame._peeOriginalSkillTreeDragStop = originalDragStop

        skillTreeFrame:SetScript("OnDragStart", function(self)
            overlay.StartSkillTreeFrameDrag(self, originalDragStart)
        end)
        skillTreeFrame:SetScript("OnDragStop", function(self)
            overlay.StopSkillTreeFrameDrag(self, originalDragStop)
        end)
    end

    if CreateFrame and not skillTreeFrame.peeResizeHandle then
        local resizeHandle = CreateFrame("Frame", nil, skillTreeFrame)
        SetFrameSize(resizeHandle, 18, 18)
        resizeHandle:SetPoint("BOTTOMRIGHT", skillTreeFrame, "BOTTOMRIGHT", -2, 2)
        local skillTreeFrameLevel = skillTreeFrame.GetFrameLevel and skillTreeFrame:GetFrameLevel() or 1
        resizeHandle:SetFrameLevel(skillTreeFrameLevel + 90)
        resizeHandle:EnableMouse(true)

        local gripTexture = resizeHandle:CreateTexture(nil, "OVERLAY")
        gripTexture:SetTexture("Interface\\AddOns\\ProjectEbonholdEnhanced\\assets\\resize_grip")
        gripTexture:SetSize(18, 18)
        gripTexture:SetPoint("BOTTOMRIGHT", resizeHandle, "BOTTOMRIGHT", 0, 0)

        local function setGripColor(red, green, blue, alpha)
            gripTexture:SetVertexColor(red, green, blue, alpha or 1)
        end

        setGripColor(1, 0.62, 0, 1)
        resizeHandle:SetScript("OnEnter", function()
            setGripColor(1, 0.82, 0, 1)
        end)
        resizeHandle:SetScript("OnLeave", function()
            setGripColor(1, 0.62, 0, 1)
        end)
        resizeHandle:SetScript("OnMouseDown", function()
            setGripColor(1, 0.82, 0, 1)
            overlay._peeSkillTreeFrameInteracting = true
            overlay._peeSkillTreeFitDirty = nil
            if overlay.SetSkillTreeNodeBorderFreeze then
                overlay.SetSkillTreeNodeBorderFreeze(true, "frame-resize")
            end
            if skillTreeFrame.StartSizing then
                skillTreeFrame:StartSizing("BOTTOMRIGHT")
            end
        end)
        resizeHandle:SetScript("OnMouseUp", function()
            setGripColor(1, 0.82, 0, 1)
            if skillTreeFrame.StopMovingOrSizing then
                skillTreeFrame:StopMovingOrSizing()
            end
            SaveSkillTreePlacement(skillTreeFrame)
            local needsFit = overlay._peeSkillTreeFitDirty
            overlay._peeSkillTreeFrameInteracting = nil
            overlay._peeSkillTreeFitDirty = nil
            if overlay.ScheduleSkillTreeFitAndCenter then
                overlay.ScheduleSkillTreeFitAndCenter(true)
            elseif needsFit then
                overlay._peeSkillTreeFitDirty = nil
            end
            if overlay.SetSkillTreeNodeBorderFreeze then
                overlay.SetSkillTreeNodeBorderFreeze(false, "frame-resize")
            end
        end)

        skillTreeFrame.peeResizeHandle = resizeHandle
    end

    RestoreSkillTreePlacement(skillTreeFrame)
    if overlay.InstallSkillTreeOwnedFitHandlers then
        overlay.InstallSkillTreeOwnedFitHandlers(skillTreeFrame)
    end
    skillTreeFrame._peeMoveResizeReady = true
end

local function ApplySkillTreeTheme()
    if not overlay.enabled or overlay.isPTR then
        return
    end

    local skillTreeFrame = _G and _G.skillTreeFrame
    if not skillTreeFrame then
        return
    end

    EnsureSkillTreeMoveResize(skillTreeFrame)
    SetDarkBackdrop(skillTreeFrame, 4, 4)
    HideTextureRegion(skillTreeFrame, "Interface\\AddOns\\ProjectEbonhold\\assets\\UI-Background-Rock")

    overlay.EnsureSkillTreeNodeStatsText(skillTreeFrame)
    overlay.RefreshSkillTreeNodeStatsText(skillTreeFrame)
    ConfigureSkillTreeText(skillTreeFrame.pointsText, 11, nil, nil, "LEFT")
    ConfigureSkillTreeText(skillTreeFrame.zoomText, 11, MAGE_BLUE, nil, "LEFT")
    ConfigureSkillTreeText(skillTreeFrame.nodeStatsText, 9, CREAM, nil, "LEFT")

    if skillTreeFrame.progressBar then
        ConfigureSkillTreeText(skillTreeFrame.progressBar.progressText, 11, CREAM, nil, "CENTER")
    end

    SkinSkillTreeBottomBar(_G.skillTreeBottomBar)
    SkinSkillTreeSearchBox(_G.skillTreeSearchBox)
    if overlay.EnsureSkillTreeProfilePopupHook then
        overlay.EnsureSkillTreeProfilePopupHook()
    end
    if overlay.EnsureSkillTreeInteractionCulling then
        overlay.EnsureSkillTreeInteractionCulling()
    end

    SkinRuntimeButton(_G.skillTreeApplyButton, BANISH_BACKDROP, CREAM, BLACK,
        BANISH_HOVER_BACKDROP, overlay.buttonBorders.banishHover)
    SkinRuntimeButton(_G.skillTreeExportButton, DARK, nil)
    SkinRuntimeButton(_G.skillTreeImportButton, DARK, nil)

    local canvas = _G.skillTreeCanvas
    if canvas and canvas.GetChildren then
        overlay.QueueSkillTreeNodeStyling(canvas)
    end

    local searchText = _G.skillTreeSearchBox and _G.skillTreeSearchBox.GetText and _G.skillTreeSearchBox:GetText() or ""
    if searchText ~= "" or overlay._skillTreeSearchHadFilter then
        overlay.ApplySkillTreeSearchFilter(searchText)
    end
end

overlay.ApplySkillTreeTheme = ApplySkillTreeTheme

local function WrapSkillTreeFunction(skillTree, functionName)
    local original = skillTree and skillTree[functionName]
    if type(original) ~= "function" or skillTree["_peeWrapped" .. functionName] then
        return
    end

    skillTree["_peeWrapped" .. functionName] = true
    skillTree[functionName] = function(...)
        local firstResult, secondResult, thirdResult = original(...)
        if overlay.ApplySkillTreeTheme then
            overlay.ApplySkillTreeTheme()
        else
            ApplySkillTreeTheme()
        end
        return firstResult, secondResult, thirdResult
    end
end

local function EnsureSkillTreeThemeWatcher()
    if overlay.skillTreeThemeWatcher then
        return
    end

    overlay.skillTreeThemeWatcher = true
end

local function InstallSkillTreeThemeHooks()
    if not overlay.enabled or overlay.isPTR then
        return
    end

    local skillTreeFrame = _G and _G.skillTreeFrame
    if skillTreeFrame and skillTreeFrame.HookScript and not skillTreeFrame._peeSkillTreeShowHook then
        skillTreeFrame:HookScript("OnShow", function()
            if overlay.ApplySkillTreeTheme then
                overlay.ApplySkillTreeTheme()
            else
                ApplySkillTreeTheme()
            end
        end)
        skillTreeFrame._peeSkillTreeShowHook = true
    end

    local skillTree = _G and _G.ProjectEbonhold and _G.ProjectEbonhold.SkillTree
    if skillTree then
        WrapSkillTreeFunction(skillTree, "OnApplyChangesResult")
        WrapSkillTreeFunction(skillTree, "UpdateTotalSoulPoints")
    end

    EnsureSkillTreeThemeWatcher()
    if overlay.ApplySkillTreeTheme then
        overlay.ApplySkillTreeTheme()
    else
        ApplySkillTreeTheme()
    end
end

overlay.InstallSkillTreeThemeHooks = InstallSkillTreeThemeHooks

local TALENT_PROFILE_BAR_HEIGHT = 54
local TALENT_PROFILE_BAR_INSET_LEFT = 12
local TALENT_PROFILE_BAR_INSET_RIGHT = 52
local TALENT_PROFILE_BAR_INSET_TOP = 28
local TALENT_PROFILE_BAR_PADDING = 6
local TALENT_PROFILE_ROW_ONE_Y = -2
local TALENT_PROFILE_ROW_TWO_Y = -26

local talentProfileBar = nil
local talentProfileDropdown = nil
local talentProfileUIReady = false
local talentProfileTabHooksInstalled = false

local function PrintTalentMessage(message)
    if DEFAULT_CHAT_FRAME and DEFAULT_CHAT_FRAME.AddMessage then
        DEFAULT_CHAT_FRAME:AddMessage(message)
    else
        PrintMessage(message)
    end
end

local function DeepCopyTable(value)
    if type(value) ~= "table" then
        return value
    end

    local copy = {}
    for key, childValue in pairs(value) do
        copy[key] = DeepCopyTable(childValue)
    end
    return copy
end

local function GetPlayerClassToken()
    if UnitClass then
        local _, classToken = UnitClass("player")
        return classToken
    end

    return nil
end

local function TalentProfileMatchesClass(profile, classToken)
    return type(profile) == "table" and classToken and profile.class == classToken
end

local function MigrateTalentProfilesOnce()
    EnsureSavedVariables()

    if overlay.charDB.talentProfilesSeeded then
        return
    end

    overlay.charDB.talentProfiles = overlay.charDB.talentProfiles or {}

    local classToken = GetPlayerClassToken()
    local copied = 0
    local sources = {}

    if _G and type(_G.ProjectEbonholdCharDB) == "table" and
        type(_G.ProjectEbonholdCharDB.talentProfiles) == "table" then
        sources[#sources + 1] = _G.ProjectEbonholdCharDB.talentProfiles
    end

    if _G and type(_G.ProjectEbonholdDB) == "table" and
        type(_G.ProjectEbonholdDB.talentProfiles) == "table" then
        sources[#sources + 1] = _G.ProjectEbonholdDB.talentProfiles
    end

    for _, source in ipairs(sources) do
        for key, profile in pairs(source) do
            if overlay.charDB.talentProfiles[key] == nil and TalentProfileMatchesClass(profile, classToken) then
                overlay.charDB.talentProfiles[key] = DeepCopyTable(profile)
                copied = copied + 1
            end
        end
    end

    local oldActiveKey = nil
    if _G and type(_G.ProjectEbonholdCharDB) == "table" then
        oldActiveKey = _G.ProjectEbonholdCharDB.activeTalentProfile
    end
    if not oldActiveKey and _G and type(_G.ProjectEbonholdDB) == "table" then
        oldActiveKey = _G.ProjectEbonholdDB.activeTalentProfile
    end
    if oldActiveKey and overlay.charDB.talentProfiles[oldActiveKey] then
        overlay.charDB.activeTalentProfile = oldActiveKey
    end

    overlay.charDB.talentProfilesSeeded = true

    if copied > 0 then
        PrintTalentMessage("|cff00ff00[Talents]|r Imported " .. copied ..
            " profile(s) from the old Enhanced profile list for this character.")
    end
end

local function GetTalentProfileDB()
    EnsureSavedVariables()
    MigrateTalentProfilesOnce()
    overlay.charDB.talentProfiles = overlay.charDB.talentProfiles or {}
    return overlay.charDB.talentProfiles
end

local function GetActiveTalentProfileKey()
    EnsureSavedVariables()
    MigrateTalentProfilesOnce()
    return overlay.charDB.activeTalentProfile
end

local function SetActiveTalentProfileKey(key)
    EnsureSavedVariables()
    MigrateTalentProfilesOnce()
    overlay.charDB.activeTalentProfile = key
end

local function TalentProfileKey(name)
    return (name or ""):lower():gsub("^%s+", ""):gsub("%s+$", "")
end

local function CaptureCurrentTalents()
    local profile = { talents = {}, tabNames = {}, totalPoints = 0, version = 1 }

    if not GetNumTalentTabs or not GetTalentTabInfo or not GetNumTalents or not GetTalentInfo then
        return profile
    end

    for tabIndex = 1, GetNumTalentTabs() do
        profile.talents[tabIndex] = {}
        local tabName = GetTalentTabInfo(tabIndex)
        profile.tabNames[tabIndex] = tabName or ("Tab " .. tabIndex)

        for talentIndex = 1, GetNumTalents(tabIndex) do
            local talentName, _, tier, _, rank = GetTalentInfo(tabIndex, talentIndex)
            profile.talents[tabIndex][talentIndex] = {
                rank = rank or 0,
                tier = tier or 0,
                name = talentName or ""
            }
            profile.totalPoints = profile.totalPoints + (rank or 0)
        end
    end

    profile.class = GetPlayerClassToken()
    profile.savedAt = time and time() or 0
    profile.savedLevel = UnitLevel and UnitLevel("player") or 0

    return profile
end

local function GetTalentProfileSummary(profile)
    if not profile or type(profile.talents) ~= "table" then
        return "?"
    end

    local parts = {}
    for tabIndex = 1, 3 do
        local total = 0
        if type(profile.talents[tabIndex]) == "table" then
            for _, talentInfo in pairs(profile.talents[tabIndex]) do
                if type(talentInfo) == "table" then
                    total = total + (talentInfo.rank or 0)
                end
            end
        end
        parts[#parts + 1] = tostring(total)
    end

    return table.concat(parts, "/")
end

local function ApplyTalentProfile(profile, silent)
    if type(profile) ~= "table" or type(profile.talents) ~= "table" then
        if not silent then
            PrintTalentMessage("|cffff4444[Talents]|r Invalid profile.")
        end
        return
    end

    if not ResetGroupPreviewTalentPoints or not GetUnspentTalentPoints or
        not GetTalentInfo or not AddPreviewTalentPoints or not LearnPreviewTalents then
        if not silent then
            PrintTalentMessage("|cffff4444[Talents]|r Talent preview API is not available.")
        end
        return
    end

    ResetGroupPreviewTalentPoints(false)

    local unspentPoints = GetUnspentTalentPoints(false, false)
    if not unspentPoints or unspentPoints <= 0 then
        if not silent then
            PrintTalentMessage("|cff888888[Talents]|r No unspent talent points available.")
        end
        return
    end

    local talentsToLearn = {}
    for tabIndex = 1, 3 do
        if type(profile.talents[tabIndex]) == "table" then
            for talentIndex, talentInfo in pairs(profile.talents[tabIndex]) do
                local targetRank = type(talentInfo) == "table" and talentInfo.rank or 0
                local tier = type(talentInfo) == "table" and talentInfo.tier or 0
                if targetRank > 0 then
                    talentsToLearn[#talentsToLearn + 1] = {
                        tab = tabIndex,
                        index = talentIndex,
                        targetRank = targetRank,
                        tier = tier
                    }
                end
            end
        end
    end

    table.sort(talentsToLearn, function(left, right)
        if left.tier ~= right.tier then
            return left.tier < right.tier
        end
        if left.tab ~= right.tab then
            return left.tab < right.tab
        end
        return left.index < right.index
    end)

    local learnedPoints = 0
    local remainingPoints = unspentPoints
    for _, entry in ipairs(talentsToLearn) do
        if remainingPoints <= 0 then
            break
        end

        local _, _, _, _, currentRank = GetTalentInfo(entry.tab, entry.index)
        currentRank = currentRank or 0

        local needed = entry.targetRank - currentRank
        if needed > 0 then
            local pointsToAdd = math.min(needed, remainingPoints)
            AddPreviewTalentPoints(entry.tab, entry.index, pointsToAdd, false)
            learnedPoints = learnedPoints + pointsToAdd
            remainingPoints = remainingPoints - pointsToAdd
        end
    end

    if learnedPoints > 0 then
        LearnPreviewTalents(false)
        if not silent then
            PrintTalentMessage("|cff00ff00[Talents]|r Applied " .. learnedPoints .. " talent points.")
        end
    elseif not silent then
        PrintTalentMessage("|cff888888[Talents]|r No talent points to apply.")
    end
end

local function GetSortedTalentProfileKeys()
    local profileDB = GetTalentProfileDB()
    local keys = {}

    for key in pairs(profileDB) do
        keys[#keys + 1] = key
    end

    table.sort(keys, function(leftKey, rightKey)
        local leftProfile = profileDB[leftKey]
        local rightProfile = profileDB[rightKey]
        return ((leftProfile and leftProfile.displayName) or leftKey):lower() <
            ((rightProfile and rightProfile.displayName) or rightKey):lower()
    end)

    return keys
end

local function SkinTalentDropdown(dropdown, width)
    if not dropdown then
        return
    end

    if UIDropDownMenu_SetWidth and width then
        UIDropDownMenu_SetWidth(dropdown, width)
    end

    local name = dropdown.GetName and dropdown:GetName()
    if name then
        for _, suffix in ipairs({ "Left", "Middle", "Right" }) do
            local texture = _G and _G[name .. suffix]
            if texture and texture.SetTexture then
                texture:SetTexture(nil)
            elseif texture and texture.SetAlpha then
                texture:SetAlpha(0)
            end
        end
    end

    if not dropdown.peeBackdrop then
        dropdown.peeBackdrop = CreateFrame("Frame", nil, dropdown)
        if dropdown.peeBackdrop.SetFrameLevel and dropdown.GetFrameLevel then
            dropdown.peeBackdrop:SetFrameLevel(math.max(0, dropdown:GetFrameLevel() - 1))
        end
        dropdown.peeBackdrop:SetPoint("TOPLEFT", dropdown, "TOPLEFT", 18, -4)
        dropdown.peeBackdrop:SetPoint("BOTTOMRIGHT", dropdown, "BOTTOMRIGHT", -18, 8)
    end

    SetDarkBackdrop(dropdown.peeBackdrop, 1, 1)

    local dropdownButton = name and _G and _G[name .. "Button"]
    if dropdownButton then
        SetFrameSize(dropdownButton, 18, 18)
        if dropdownButton.ClearAllPoints then
            dropdownButton:ClearAllPoints()
        end
        if dropdownButton.SetPoint then
            dropdownButton:SetPoint("TOPRIGHT", dropdown, "TOPRIGHT", -4, -6)
        end
    end
end

local function EnsureTalentProfileBar()
    if talentProfileBar then
        if PlayerTalentFrame and talentProfileBar.SetFrameLevel and PlayerTalentFrame.GetFrameLevel then
            talentProfileBar:SetFrameLevel(PlayerTalentFrame:GetFrameLevel() + 5)
        end
        return talentProfileBar
    end

    if not PlayerTalentFrame then
        return nil
    end

    local bar = CreateFrame("Frame", "PEETalentProfileBar", PlayerTalentFrame)
    bar:SetHeight(TALENT_PROFILE_BAR_HEIGHT)
    bar:SetPoint("TOPLEFT", PlayerTalentFrame, "TOPLEFT", TALENT_PROFILE_BAR_INSET_LEFT,
        -TALENT_PROFILE_BAR_INSET_TOP)
    bar:SetPoint("TOPRIGHT", PlayerTalentFrame, "TOPRIGHT", -TALENT_PROFILE_BAR_INSET_RIGHT,
        -TALENT_PROFILE_BAR_INSET_TOP)
    if bar.SetFrameLevel and PlayerTalentFrame.GetFrameLevel then
        bar:SetFrameLevel(PlayerTalentFrame:GetFrameLevel() + 5)
    end

    talentProfileBar = bar
    return talentProfileBar
end

local function IsTalentGlyphsTab()
    if not PlayerTalentFrame then
        return false
    end

    local selectedTab = PlayerTalentFrame.selectedTab
    if not selectedTab and PanelTemplates_GetSelectedTab then
        selectedTab = PanelTemplates_GetSelectedTab(PlayerTalentFrame)
    end

    return selectedTab == 4
end

local function UpdateTalentProfileBarVisibility()
    if not talentProfileBar then
        return
    end

    if IsTalentGlyphsTab() then
        talentProfileBar:Hide()
    else
        talentProfileBar:Show()
    end
end

local function InstallTalentProfileTabHooks()
    if talentProfileTabHooksInstalled or not PlayerTalentFrame then
        return
    end

    local installedCount = 0
    for tabIndex = 1, 4 do
        local tab = _G and _G["PlayerTalentFrameTab" .. tabIndex]
        if tab and tab.HookScript then
            tab:HookScript("OnClick", UpdateTalentProfileBarVisibility)
            installedCount = installedCount + 1
        end
    end

    if installedCount > 0 then
        talentProfileTabHooksInstalled = true
    end
end

local function SkinServerTalentControls()
    local bar = EnsureTalentProfileBar()
    if not bar then
        return
    end

    local specDropdown = _G and _G.SpecDropdownFrame
    if specDropdown then
        if specDropdown.SetParent then
            specDropdown:SetParent(bar)
        end
        if specDropdown.ClearAllPoints then
            specDropdown:ClearAllPoints()
        end
        if specDropdown.SetPoint then
            specDropdown:SetPoint("TOPLEFT", bar, "TOPLEFT", TALENT_PROFILE_BAR_PADDING - 16,
                TALENT_PROFILE_ROW_ONE_Y)
        end
        SkinTalentDropdown(specDropdown, 145)
    end

    local resetButton = _G and _G.ResetTalentsButton
    if resetButton then
        if resetButton.SetParent then
            resetButton:SetParent(bar)
        end
        SetFrameSize(resetButton, 90, 22)
        if resetButton.ClearAllPoints then
            resetButton:ClearAllPoints()
        end
        if resetButton.SetPoint then
            resetButton:SetPoint("TOPRIGHT", bar, "TOPRIGHT", -TALENT_PROFILE_BAR_PADDING,
                TALENT_PROFILE_ROW_ONE_Y)
        end
        SkinRuntimeButton(resetButton, DARK, CREAM)
    end
end

local function RefreshTalentProfileDropdown()
    if not talentProfileDropdown then
        return
    end

    local activeKey = GetActiveTalentProfileKey()
    local profileDB = GetTalentProfileDB()

    if activeKey and profileDB[activeKey] then
        local profile = profileDB[activeKey]
        UIDropDownMenu_SetText(talentProfileDropdown, profile.displayName or activeKey)
    else
        UIDropDownMenu_SetText(talentProfileDropdown, "No profile selected")
    end
end

local function CreateTalentProfileUI()
    if talentProfileUIReady then
        return
    end

    local bar = EnsureTalentProfileBar()
    if not bar then
        return
    end

    talentProfileUIReady = true

    local dropdown = CreateFrame("Frame", "PEETalentProfileDropdown", bar, "UIDropDownMenuTemplate")
    dropdown:SetPoint("TOPLEFT", bar, "TOPLEFT", TALENT_PROFILE_BAR_PADDING - 16, TALENT_PROFILE_ROW_TWO_Y)
    SkinTalentDropdown(dropdown, 145)
    talentProfileDropdown = dropdown

    if UIDropDownMenu_Initialize then
        UIDropDownMenu_Initialize(dropdown, function(_, level)
            if level and level ~= 1 then
                return
            end

            local profileDB = GetTalentProfileDB()
            local keys = GetSortedTalentProfileKeys()
            local activeKey = GetActiveTalentProfileKey()

            if #keys == 0 then
                local info = UIDropDownMenu_CreateInfo()
                info.text = "|cff888888No saved profiles|r"
                info.disabled = true
                info.notCheckable = true
                UIDropDownMenu_AddButton(info)
                return
            end

            for _, key in ipairs(keys) do
                local profile = profileDB[key]
                local info = UIDropDownMenu_CreateInfo()
                info.text = (profile.displayName or key) .. "  |cff888888" ..
                    GetTalentProfileSummary(profile) .. "|r"
                info.checked = activeKey == key
                info.func = function()
                    SetActiveTalentProfileKey(key)
                    RefreshTalentProfileDropdown()
                    PrintTalentMessage("|cff00ff00[Talents]|r Active profile: " ..
                        (profile.displayName or key))
                end
                UIDropDownMenu_AddButton(info)
            end
        end)
    end

    local deleteButton = CreateFrame("Button", nil, bar, "UIPanelButtonTemplate")
    deleteButton:SetSize(22, 22)
    deleteButton:SetPoint("TOPRIGHT", bar, "TOPRIGHT", -TALENT_PROFILE_BAR_PADDING, TALENT_PROFILE_ROW_TWO_Y)
    deleteButton:SetText("x")

    local applyButton = CreateFrame("Button", nil, bar, "UIPanelButtonTemplate")
    applyButton:SetSize(50, 22)
    applyButton:SetPoint("TOPRIGHT", deleteButton, "TOPLEFT", -2, 0)
    applyButton:SetText("Apply")

    local saveButton = CreateFrame("Button", nil, bar, "UIPanelButtonTemplate")
    saveButton:SetSize(45, 22)
    saveButton:SetPoint("TOPRIGHT", applyButton, "TOPLEFT", -2, 0)
    saveButton:SetText("Save")

    SkinRuntimeButton(saveButton, DARK, CREAM)
    SkinRuntimeButton(applyButton, DARK, CREAM)
    SkinRuntimeButton(deleteButton, DARK, CREAM)

    saveButton:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_TOP")
        GameTooltip:SetText("Save Profile", 1, 0.82, 0)
        GameTooltip:AddLine("Save your current talent setup.", 0.8, 0.8, 0.8, true)
        GameTooltip:Show()
    end)
    saveButton:SetScript("OnLeave", function() GameTooltip:Hide() end)

    applyButton:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_TOP")
        GameTooltip:SetText("Apply Profile", 1, 0.82, 0)
        GameTooltip:AddLine("Apply the selected saved talent setup.", 0.8, 0.8, 0.8, true)
        GameTooltip:Show()
    end)
    applyButton:SetScript("OnLeave", function() GameTooltip:Hide() end)

    deleteButton:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_TOP")
        GameTooltip:SetText("Delete Profile", 1, 0.3, 0.3)
        GameTooltip:AddLine("Delete the selected saved talent setup.", 0.8, 0.8, 0.8, true)
        GameTooltip:Show()
    end)
    deleteButton:SetScript("OnLeave", function() GameTooltip:Hide() end)

    saveButton:SetScript("OnClick", function()
        StaticPopupDialogs["PEE_SAVE_TALENT_PROFILE"] = {
            text = "Save current talents as profile:",
            button1 = "Save",
            button2 = "Cancel",
            hasEditBox = true,
            timeout = 0,
            whileDead = true,
            hideOnEscape = true,
            OnShow = function(self)
                local activeKey = GetActiveTalentProfileKey()
                local profileDB = GetTalentProfileDB()
                if activeKey and profileDB[activeKey] then
                    self.editBox:SetText(profileDB[activeKey].displayName or activeKey)
                else
                    self.editBox:SetText("")
                end
                self.editBox:SetFocus()
            end,
            OnAccept = function(self)
                local name = self.editBox:GetText()
                if not name or name:gsub("%s", "") == "" then
                    PrintTalentMessage("|cffff4444[Talents]|r Name required.")
                    return
                end

                local key = TalentProfileKey(name)
                local profileDB = GetTalentProfileDB()
                local profile = CaptureCurrentTalents()
                profile.displayName = name
                profileDB[key] = profile
                SetActiveTalentProfileKey(key)
                RefreshTalentProfileDropdown()
                PrintTalentMessage("|cff00ff00[Talents]|r Saved profile '" .. name .. "' (" ..
                    GetTalentProfileSummary(profile) .. ", " .. (profile.totalPoints or 0) .. " points)")
            end,
            EditBoxOnEnterPressed = function(self)
                local parent = self:GetParent()
                if parent and parent.button1 and parent.button1.Click then
                    parent.button1:Click()
                end
            end,
            EditBoxOnEscapePressed = function(self)
                self:GetParent():Hide()
            end,
            preferredIndex = 3
        }
        StaticPopup_Show("PEE_SAVE_TALENT_PROFILE")
    end)

    applyButton:SetScript("OnClick", function()
        local activeKey = GetActiveTalentProfileKey()
        local profileDB = GetTalentProfileDB()
        local profile = activeKey and profileDB[activeKey]
        if not profile then
            PrintTalentMessage("|cffff4444[Talents]|r No profile selected.")
            return
        end

        PrintTalentMessage("|cfff0d440[Talents]|r Applying profile '" .. (profile.displayName or activeKey) .. "'...")
        ApplyTalentProfile(profile, false)
    end)

    deleteButton:SetScript("OnClick", function()
        local activeKey = GetActiveTalentProfileKey()
        local profileDB = GetTalentProfileDB()
        local profile = activeKey and profileDB[activeKey]
        if not profile then
            PrintTalentMessage("|cffff4444[Talents]|r No profile selected.")
            return
        end

        local profileName = profile.displayName or activeKey
        StaticPopupDialogs["PEE_DELETE_TALENT_PROFILE"] = {
            text = "Delete talent profile '" .. profileName .. "'?",
            button1 = "Delete",
            button2 = "Cancel",
            timeout = 0,
            whileDead = true,
            hideOnEscape = true,
            OnAccept = function()
                profileDB[activeKey] = nil
                SetActiveTalentProfileKey(nil)
                RefreshTalentProfileDropdown()
                PrintTalentMessage("|cffff4444[Talents]|r Deleted profile '" .. profileName .. "'")
            end,
            preferredIndex = 3
        }
        StaticPopup_Show("PEE_DELETE_TALENT_PROFILE")
    end)

    RefreshTalentProfileDropdown()
end

local function RefreshTalentProfileOverlay()
    if not overlay.enabled or overlay.isPTR then
        return
    end

    CreateTalentProfileUI()
    SkinServerTalentControls()
    RefreshTalentProfileDropdown()
    InstallTalentProfileTabHooks()
    UpdateTalentProfileBarVisibility()
end

overlay.RefreshTalentProfileOverlay = RefreshTalentProfileOverlay

local function EnsureTalentProfileWatcher()
    if overlay.talentProfileWatcher then
        return
    end

    local watcher = CreateFrame("Frame")
    watcher.elapsed = 0
    watcher:SetScript("OnUpdate", function(self, elapsed)
        if not overlay.enabled or overlay.isPTR then
            return
        end

        if not PlayerTalentFrame then
            return
        end

        if not self.hookedTalentFrame and PlayerTalentFrame.HookScript then
            PlayerTalentFrame:HookScript("OnShow", RefreshTalentProfileOverlay)
            self.hookedTalentFrame = true
        end

        self.elapsed = (self.elapsed or 0) + (elapsed or 0)
        if self.elapsed < 0.5 then
            return
        end

        self.elapsed = 0
        RefreshTalentProfileOverlay()
    end)

    overlay.talentProfileWatcher = watcher
end

local function InstallTalentProfileHooks()
    if not overlay.enabled or overlay.isPTR then
        return
    end

    EnsureTalentProfileWatcher()
    RefreshTalentProfileOverlay()
end

overlay.InstallTalentProfileHooks = InstallTalentProfileHooks

local function SetOverlayState()
    EnsureSavedVariables()
    overlay.isPTR = IsPTRRealm()
    overlay.enabled = not overlay.isPTR

    if overlay.statusPanel then
        UpdateStatusPanel()
    end

    if overlay.isPTR then
        PrintMessage("Overlay inactive on PTR. Server ProjectEbonhold stays in control.")
        return
    end

    if overlay.CreateOptionsPanel then
        overlay.CreateOptionsPanel()
    end
    overlay.InstallServerOptionReadOverrides()
    InstallPlayerRunThemeHooks()
    InstallPerkBrowserThemeHooks()
    InstallPerkChoiceThemeHooks()
    InstallExtractionThemeHooks()
    InstallPatchPopupThemeHooks()
    InstallHardmodeThemeHooks()
    overlay.EnsureGrantedPerkPayloadListener()
    overlay.EnsureDeathConfirmationWatcher()
    overlay.InstallTargetFrameIntensityCue()
    overlay.ApplySkillTreeDataPatches()
    if overlay.InstallOwnedSoulAsheTree then
        overlay.InstallOwnedSoulAsheTree()
    elseif not (overlay.UsesOwnedSoulAsheTree and overlay.UsesOwnedSoulAsheTree()) then
        InstallSkillTreeThemeHooks()
    end
    InstallTalentProfileHooks()
    if overlay.ScheduleSkillTreePrewarm and not (overlay.UsesOwnedSoulAsheTree and overlay.UsesOwnedSoulAsheTree()) then
        overlay.ScheduleSkillTreePrewarm()
    end

    PrintMessage("Overlay loaded. Type /pee to open the status panel.")

    if not overlay.db.statusPanelSeen then
        overlay.db.statusPanelSeen = true
        ShowStatusPanel()
    end
end

overlay.eventFrame = CreateFrame("Frame")
overlay.eventFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
overlay.eventFrame:SetScript("OnEvent", SetOverlayState)

SLASH_PROJECTEBONHOLDENHANCED1 = "/pee"
SlashCmdList["PROJECTEBONHOLDENHANCED"] = function(message)
    local command = string.lower((message or ""):match("^%s*(.-)%s*$"))

    if overlay.isPTR then
        PrintMessage("Inactive on PTR.")
        return
    end

    if command == "version" then
        PrintMessage("Version " .. overlay.version)
        return
    end

    if command == "notice" then
        local patchPopup = _G and (_G.PatchPopup or _G.PatchPopupFrame)
        if patchPopup and patchPopup.ShowPatchError then
            patchPopup:ShowPatchError(nil, true)
            ApplyPatchPopupTheme()
        else
            PrintMessage("Update notice is not available yet.")
        end
        return
    end

    if command == "ashe start" then
        if overlay.StartAsheProgressSimulation then
            local _, resultMessage = overlay.StartAsheProgressSimulation()
            PrintMessage(resultMessage or "Soul Ashe progression test started.")
        else
            PrintMessage("Soul Ashe progression test is not available yet.")
        end
        return
    end

    if command == "ashe stop" then
        if overlay.StopAsheProgressSimulation then
            local _, resultMessage = overlay.StopAsheProgressSimulation()
            PrintMessage(resultMessage or "Soul Ashe progression test stopped.")
        else
            PrintMessage("Soul Ashe progression test is not available yet.")
        end
        return
    end

    if command == "ashe" then
        PrintMessage("Use /pee ashe start or /pee ashe stop.")
        return
    end

    if command ~= "" then
        PrintMessage("Commands: /pee, /pee version, /pee notice, /pee ashe start, /pee ashe stop")
        PrintMessage("Use /affix for the Affix Book and /anvil for the Enchanted Anvil.")
        return
    end

    ToggleStatusPanel()
end

SLASH_PROJECTEBONHOLDENHANCEDAFFIX1 = "/affix"
SlashCmdList["PROJECTEBONHOLDENHANCEDAFFIX"] = function()
    if overlay.isPTR then
        PrintMessage("Inactive on PTR.")
        return
    end
    overlay.ShowAffixBook()
end

SLASH_PROJECTEBONHOLDENHANCEDEXTRACTION1 = "/anvil"
SlashCmdList["PROJECTEBONHOLDENHANCEDEXTRACTION"] = function()
    if overlay.isPTR then
        PrintMessage("Inactive on PTR.")
        return
    end
    overlay.ShowExtractionFrame()
end
