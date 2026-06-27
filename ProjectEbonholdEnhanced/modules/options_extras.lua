local overlay = ProjectEbonholdEnhanced

if not overlay then
    return
end

local BANISH_BACKDROP = {0.32, 0.1, 0.1}
local BANISH_HOVER_BACKDROP = {0.48, 0.16, 0.14}
local BANISH_HOVER_BORDER = {1.0, 0.28, 0.24}
local BLACK = {0, 0, 0}
local CREAM = {1, 0.92, 0.82}

local function Opacity()
    return overlay.GetBackdropOpacity and overlay.GetBackdropOpacity() or 0.8
end

local function SetSize(frame, width, height)
    if not frame then
        return
    end
    if frame.SetSize then
        frame:SetSize(width, height)
    else
        if frame.SetWidth then frame:SetWidth(width) end
        if frame.SetHeight then frame:SetHeight(height) end
    end
end

local function SkinButton(button)
    if not button then
        return
    end

    if overlay.HideButtonTextures then
        overlay.HideButtonTextures(button)
    end
    if overlay.LockButtonTextureSetters then
        overlay.LockButtonTextureSetters(button)
    end

    if button.SetBackdrop then
        button:SetBackdrop({
            bgFile = "Interface\\Buttons\\WHITE8x8",
            edgeFile = "Interface\\Buttons\\WHITE8x8",
            tile = true,
            tileSize = 16,
            edgeSize = 2,
            insets = { left = 1, right = 1, top = 1, bottom = 1 },
        })
    end
    if button.SetBackdropColor then
        button:SetBackdropColor(BANISH_BACKDROP[1], BANISH_BACKDROP[2], BANISH_BACKDROP[3], Opacity())
    end
    if button.SetBackdropBorderColor then
        button:SetBackdropBorderColor(BLACK[1], BLACK[2], BLACK[3], 1)
    end
    local text = button.GetFontString and button:GetFontString()
    if text and text.SetTextColor then
        text:SetTextColor(CREAM[1], CREAM[2], CREAM[3], 1)
    end
    button:SetScript("OnEnter", function(self)
        if self.SetBackdropColor then
            self:SetBackdropColor(
                BANISH_HOVER_BACKDROP[1], BANISH_HOVER_BACKDROP[2], BANISH_HOVER_BACKDROP[3], Opacity())
        end
        if self.SetBackdropBorderColor then
            self:SetBackdropBorderColor(
                BANISH_HOVER_BORDER[1], BANISH_HOVER_BORDER[2], BANISH_HOVER_BORDER[3], 1)
        end
    end)
    button:SetScript("OnLeave", function(self)
        if self.SetBackdropColor then
            self:SetBackdropColor(BANISH_BACKDROP[1], BANISH_BACKDROP[2], BANISH_BACKDROP[3], Opacity())
        end
        if self.SetBackdropBorderColor then
            self:SetBackdropBorderColor(BLACK[1], BLACK[2], BLACK[3], 1)
        end
    end)
end

local function ClearOverlayState()
    ProjectEbonholdEnhancedDB = ProjectEbonholdEnhancedDB or {}
    ProjectEbonholdEnhancedDB.settings = {
        transparentDesign = true,
        fontScale = 1.0,
        backdropOpacity = 0.8,
        disablePerkFadeAnimations = true,
        removeRerollConfirm = true,
        autoShowEchoChoices = false,
        keepEchoesVisibleOnLevelUp = true,
        perkUIScale = 1.0,
    }
    ProjectEbonholdEnhancedDB.statusPanel = {}
    ProjectEbonholdEnhancedDB.playerRunCompact = {}
    ProjectEbonholdEnhancedDB.playerRunFrame = {}
    ProjectEbonholdEnhancedDB.empowermentFrame = {}
    ProjectEbonholdEnhancedDB.skillTreeFrame = {}
    ProjectEbonholdEnhancedDB.perkFrame = {}
    ProjectEbonholdEnhancedDB.perkButtons = {}
    ProjectEbonholdEnhancedDB.affixFilters = {
        armor = true,
        hands = true,
        learned = true,
    }
    if overlay.db then
        overlay.db = ProjectEbonholdEnhancedDB
    end
    if overlay.RefreshVisibleTheme then
        overlay.RefreshVisibleTheme()
    end
    if overlay.optionsPanel and overlay.optionsPanel.Refresh then
        overlay.optionsPanel:Refresh()
    end
end

function overlay.ApplyOptionsExtras()
    if overlay.isPTR or not overlay.enabled then
        return
    end
    local panel = overlay.optionsPanel
    if not panel or panel.peeResetButton or not CreateFrame then
        return
    end

    local content = panel.optionsContent or panel

    local resetButton = CreateFrame("Button", "PEEOptionsResetButton", content, "UIPanelButtonTemplate")
    SetSize(resetButton, 160, 24)
    resetButton:SetPoint("TOPLEFT", panel.perkScaleSlider or panel.keepEchoesVisible or panel, "BOTTOMLEFT", 0, -26)
    resetButton:SetText("Reset PEE UI")
    SkinButton(resetButton)
    resetButton:SetScript("OnClick", function()
        ClearOverlayState()
    end)
    panel.peeResetButton = resetButton

    local note = content:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
    note:SetPoint("TOPLEFT", resetButton, "BOTTOMLEFT", 0, -8)
    if note.SetFont then
        note:SetFont("Fonts\\FRIZQT__.TTF", overlay.ScaledFontSize and overlay.ScaledFontSize(10) or 10, "OUTLINE")
    end
    if note.SetTextColor then
        note:SetTextColor(CREAM[1], CREAM[2], CREAM[3], 1)
    end
    if note.SetWidth then
        note:SetWidth(320)
    end
    if note.SetWordWrap then
        note:SetWordWrap(true)
    end
    if note.SetNonSpaceWrap then
        note:SetNonSpaceWrap(false)
    end
    note:SetText("Resets only Project Ebonhold Enhanced UI settings and positions.")
    panel.peeResetNote = note
end

local function WrapSlash()
    if not SlashCmdList or type(SlashCmdList.PROJECTEBONHOLDENHANCED) ~= "function" or
        overlay._peeOptionsSlashWrapped then
        return
    end
    local original = SlashCmdList.PROJECTEBONHOLDENHANCED
    overlay._peeOptionsSlashWrapped = true
    SlashCmdList.PROJECTEBONHOLDENHANCED = function(...)
        local first, second, third = original(...)
        overlay.ApplyOptionsExtras()
        return first, second, third
    end
end

local function Install()
    WrapSlash()
    overlay.ApplyOptionsExtras()
end

overlay.InstallOptionsExtras = Install

local eventFrame = CreateFrame and CreateFrame("Frame")
if eventFrame then
    eventFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
    eventFrame:SetScript("OnEvent", function()
        Install()
    end)
end
Install()
