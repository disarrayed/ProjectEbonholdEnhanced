local overlay = ProjectEbonholdEnhanced

if not overlay then
    return
end

local MAGE_BLUE = {0.247, 0.78, 0.922}
local CREAM = {1, 0.92, 0.82}
local OPTIONS_WIDTH = 360
local OPTIONS_CONTENT_WIDTH = 500
local OPTIONS_CONTENT_HEIGHT = 620
local SLIDER_WIDTH = 320

local function SetTextColor(fontString, color)
    if fontString and fontString.SetTextColor then
        fontString:SetTextColor(color[1], color[2], color[3], 1)
    end
end

local function SetGlobalText(globalName, text)
    local fontString = _G and _G[globalName]
    if fontString and fontString.SetText then
        fontString:SetText(text)
    end
end

local function ConfigureText(fontString, width)
    if not fontString then
        return
    end

    if fontString.SetFont then
        fontString:SetFont("Fonts\\FRIZQT__.TTF", overlay.ScaledFontSize and overlay.ScaledFontSize(12) or 12,
            "OUTLINE")
    end
    if fontString.SetWidth then
        fontString:SetWidth(width)
    end
    if fontString.SetWordWrap then
        fontString:SetWordWrap(true)
    end
    if fontString.SetNonSpaceWrap then
        fontString:SetNonSpaceWrap(false)
    end
    if fontString.SetJustifyH then
        fontString:SetJustifyH("LEFT")
    end
end

local function ClampNumber(value, minimum, maximum)
    value = tonumber(value)
    if not value then
        return nil
    end
    if value < minimum then
        return minimum
    end
    if value > maximum then
        return maximum
    end
    return value
end

local function RefreshVisibleTheme()
    if overlay.RefreshVisibleTheme then
        overlay.RefreshVisibleTheme()
    end
end

local function PrintMessage(message)
    if overlay.PrintMessage then
        overlay.PrintMessage(message)
    end
end

function overlay.CreateOptionsPanel()
    if overlay.optionsPanel or not InterfaceOptions_AddCategory then
        return overlay.optionsPanel
    end

    local panel = CreateFrame("Frame", "PEEOptionsPanel", UIParent)
    panel.name = "Project Ebonhold Enhanced"

    local scrollFrame = CreateFrame("ScrollFrame", "PEEOptionsScrollFrame", panel, "UIPanelScrollFrameTemplate")
    scrollFrame:SetPoint("TOPLEFT", panel, "TOPLEFT", 8, -8)
    scrollFrame:SetPoint("BOTTOMRIGHT", panel, "BOTTOMRIGHT", -28, 8)
    if scrollFrame.EnableMouseWheel then
        scrollFrame:EnableMouseWheel(true)
    end
    panel.scrollFrame = scrollFrame

    local content = CreateFrame("Frame", "PEEOptionsScrollContent", scrollFrame)
    content:SetSize(OPTIONS_CONTENT_WIDTH, OPTIONS_CONTENT_HEIGHT)
    scrollFrame:SetScrollChild(content)
    panel.optionsContent = content

    local title = content:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
    title:SetPoint("TOPLEFT", content, "TOPLEFT", 16, -16)
    title:SetFont("Fonts\\FRIZQT__.TTF", overlay.ScaledFontSize and overlay.ScaledFontSize(16) or 16, "OUTLINE")
    title:SetText("Project Ebonhold Enhanced")
    SetTextColor(title, MAGE_BLUE)
    panel.title = title

    local summary = content:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
    summary:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 0, -12)
    ConfigureText(summary, OPTIONS_WIDTH)
    SetTextColor(summary, CREAM)
    panel.summary = summary

    local transparent = CreateFrame("CheckButton", "PEEOptionsTransparentDesign", content,
        "InterfaceOptionsCheckButtonTemplate")
    transparent:SetPoint("TOPLEFT", summary, "BOTTOMLEFT", 0, -18)
    SetGlobalText("PEEOptionsTransparentDesignText", "Transparent design")
    transparent:SetScript("OnClick", function(self)
        overlay.SetSetting("transparentDesign", self:GetChecked() == 1 or self:GetChecked() == true)
        RefreshVisibleTheme()
        overlay.ShowReloadPopup()
        panel:Refresh()
    end)
    panel.transparent = transparent

    local fadeAnimation = CreateFrame("CheckButton", "PEEOptionsDisablePerkFade", content,
        "InterfaceOptionsCheckButtonTemplate")
    fadeAnimation:SetPoint("TOPLEFT", transparent, "BOTTOMLEFT", 0, -8)
    SetGlobalText("PEEOptionsDisablePerkFadeText", "Disable Echo/Banish fade animation")
    fadeAnimation:SetScript("OnClick", function(self)
        overlay.SetSetting("disablePerkFadeAnimations", self:GetChecked() == 1 or self:GetChecked() == true)
        RefreshVisibleTheme()
        overlay.ShowReloadPopup()
        panel:Refresh()
    end)
    panel.fadeAnimation = fadeAnimation

    local rerollConfirm = CreateFrame("CheckButton", "PEEOptionsRemoveRerollConfirm", content,
        "InterfaceOptionsCheckButtonTemplate")
    rerollConfirm:SetPoint("TOPLEFT", fadeAnimation, "BOTTOMLEFT", 0, -8)
    SetGlobalText("PEEOptionsRemoveRerollConfirmText", "Remove Reroll confirmation prompt")
    rerollConfirm:SetScript("OnClick", function(self)
        overlay.SetSetting("removeRerollConfirm", self:GetChecked() == 1 or self:GetChecked() == true)
        panel:Refresh()
    end)
    panel.rerollConfirm = rerollConfirm

    local autoShowEchoes = CreateFrame("CheckButton", "PEEOptionsAutoShowEchoes", content,
        "InterfaceOptionsCheckButtonTemplate")
    autoShowEchoes:SetPoint("TOPLEFT", rerollConfirm, "BOTTOMLEFT", 0, -8)
    SetGlobalText("PEEOptionsAutoShowEchoesText", "Auto Show Echo choices")
    autoShowEchoes:SetScript("OnClick", function(self)
        overlay.SetSetting("autoShowEchoChoices", self:GetChecked() == 1 or self:GetChecked() == true)
        if overlay.RefreshPerkChoiceTheme then
            overlay.RefreshPerkChoiceTheme(true)
        end
        panel:Refresh()
    end)
    panel.autoShowEchoes = autoShowEchoes

    local keepEchoesVisible = CreateFrame("CheckButton", "PEEOptionsKeepEchoesVisible", content,
        "InterfaceOptionsCheckButtonTemplate")
    keepEchoesVisible:SetPoint("TOPLEFT", autoShowEchoes, "BOTTOMLEFT", 0, -8)
    SetGlobalText("PEEOptionsKeepEchoesVisibleText", "Keep Echoes visible when leveling up")
    keepEchoesVisible:SetScript("OnClick", function(self)
        overlay.SetSetting("keepEchoesVisibleOnLevelUp", self:GetChecked() == 1 or self:GetChecked() == true)
        panel:Refresh()
    end)
    panel.keepEchoesVisible = keepEchoesVisible

    local fontLabel = content:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    fontLabel:SetPoint("TOPLEFT", keepEchoesVisible, "BOTTOMLEFT", 0, -22)
    fontLabel:SetText("Font Scale: 100%")
    SetTextColor(fontLabel, MAGE_BLUE)
    panel.fontLabel = fontLabel

    local fontSlider = CreateFrame("Slider", "PEEOptionsFontScaleSlider", content, "OptionsSliderTemplate")
    fontSlider:SetPoint("TOPLEFT", fontLabel, "BOTTOMLEFT", 0, -10)
    fontSlider:SetWidth(SLIDER_WIDTH)
    fontSlider:SetMinMaxValues(50, 150)
    fontSlider:SetValueStep(5)
    SetGlobalText("PEEOptionsFontScaleSliderLow", "50%")
    SetGlobalText("PEEOptionsFontScaleSliderHigh", "150%")
    SetGlobalText("PEEOptionsFontScaleSliderText", "")
    fontSlider:SetScript("OnValueChanged", function(_, value)
        local percent = math.floor(value / 5 + 0.5) * 5
        panel.fontLabel:SetText("Font Scale: " .. percent .. "%")
        if not panel.refreshing then
            overlay.SetSetting("fontScale", percent / 100)
            RefreshVisibleTheme()
            overlay.ShowReloadPopup()
        end
    end)
    panel.fontSlider = fontSlider

    local opacityLabel = content:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    opacityLabel:SetPoint("TOPLEFT", fontSlider, "BOTTOMLEFT", 0, -24)
    opacityLabel:SetText("Backdrop Opacity: 80%")
    SetTextColor(opacityLabel, MAGE_BLUE)
    panel.opacityLabel = opacityLabel

    local opacitySlider = CreateFrame("Slider", "PEEOptionsOpacitySlider", content, "OptionsSliderTemplate")
    opacitySlider:SetPoint("TOPLEFT", opacityLabel, "BOTTOMLEFT", 0, -10)
    opacitySlider:SetWidth(SLIDER_WIDTH)
    opacitySlider:SetMinMaxValues(70, 100)
    opacitySlider:SetValueStep(1)
    SetGlobalText("PEEOptionsOpacitySliderLow", "70%")
    SetGlobalText("PEEOptionsOpacitySliderHigh", "100%")
    SetGlobalText("PEEOptionsOpacitySliderText", "")
    opacitySlider:SetScript("OnValueChanged", function(_, value)
        local percent = math.floor(value + 0.5)
        panel.opacityLabel:SetText("Backdrop Opacity: " .. percent .. "%")
        if not panel.refreshing then
            overlay.SetSetting("backdropOpacity", percent / 100)
            RefreshVisibleTheme()
            overlay.ShowReloadPopup()
        end
    end)
    panel.opacitySlider = opacitySlider

    local perkScaleLabel = content:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    perkScaleLabel:SetPoint("TOPLEFT", opacitySlider, "BOTTOMLEFT", 0, -24)
    perkScaleLabel:SetText("Perk UI Scale: 100%")
    SetTextColor(perkScaleLabel, MAGE_BLUE)
    panel.perkScaleLabel = perkScaleLabel

    local perkScaleSlider = CreateFrame("Slider", "PEEOptionsPerkScaleSlider", content, "OptionsSliderTemplate")
    perkScaleSlider:SetPoint("TOPLEFT", perkScaleLabel, "BOTTOMLEFT", 0, -10)
    perkScaleSlider:SetWidth(SLIDER_WIDTH)
    perkScaleSlider:SetMinMaxValues(50, 300)
    perkScaleSlider:SetValueStep(5)
    SetGlobalText("PEEOptionsPerkScaleSliderLow", "50%")
    SetGlobalText("PEEOptionsPerkScaleSliderHigh", "300%")
    SetGlobalText("PEEOptionsPerkScaleSliderText", "")
    perkScaleSlider:SetScript("OnValueChanged", function(_, value)
        local percent = math.floor(value / 5 + 0.5) * 5
        panel.perkScaleLabel:SetText("Perk UI Scale: " .. percent .. "%")
        if not panel.refreshing then
            overlay.SetSetting("perkUIScale", percent / 100)
            overlay.ApplyPerkUIScale()
            if overlay.RefreshPerkChoiceTheme then
                overlay.RefreshPerkChoiceTheme(true)
            end
        end
    end)
    panel.perkScaleSlider = perkScaleSlider

    function panel:Refresh()
        self.refreshing = true
        self.summary:SetText(overlay.GetThemeSummary())
        self.transparent:SetChecked(overlay.IsTransparentDesignEnabled())
        self.fadeAnimation:SetChecked(overlay.IsPerkFadeAnimationDisabled())
        self.rerollConfirm:SetChecked(overlay.IsRerollConfirmationRemoved())
        self.autoShowEchoes:SetChecked(overlay.IsAutoShowEchoChoicesEnabled())
        self.keepEchoesVisible:SetChecked(overlay.IsKeepEchoesVisibleOnLevelUpEnabled())
        self.fontSlider:SetValue(math.floor((overlay.GetSetting("fontScale") or 1) * 100 + 0.5))
        self.opacitySlider:SetValue(math.floor((overlay.GetBackdropOpacity() or 0.8) * 100 + 0.5))
        self.perkScaleSlider:SetValue(math.floor(overlay.GetPerkUIScale() * 100 + 0.5))
        self.refreshing = false
    end

    InterfaceOptions_AddCategory(panel)
    panel:Refresh()
    overlay.optionsPanel = panel

    if overlay.ApplyOptionsExtras then
        overlay.ApplyOptionsExtras()
    end

    return panel
end

function overlay.OpenOptionsPanel()
    local panel = overlay.CreateOptionsPanel()
    if panel and panel.Refresh then
        panel:Refresh()
    end

    if InterfaceOptionsFrame_OpenToCategory and panel then
        InterfaceOptionsFrame_OpenToCategory(panel)
    elseif overlay.ShowStatusPanel then
        overlay.ShowStatusPanel()
    end
end

function overlay.HandleThemeCommand(action, value)
    if action == "theme" then
        PrintMessage(overlay.GetThemeSummary())
        return true
    end

    if action == "opacity" then
        local percent = ClampNumber(value, 70, 100)
        if not percent then
            PrintMessage("Usage: /pee opacity 70-100")
            return true
        end

        overlay.SetSetting("backdropOpacity", percent / 100)
        RefreshVisibleTheme()
        overlay.ShowReloadPopup()
        PrintMessage("Backdrop opacity set to " .. percent .. "%.")
        return true
    end

    if action == "font" or action == "fontscale" then
        local percent = ClampNumber(value, 50, 150)
        if not percent then
            PrintMessage("Usage: /pee font 50-150")
            return true
        end

        overlay.SetSetting("fontScale", percent / 100)
        RefreshVisibleTheme()
        overlay.ShowReloadPopup()
        PrintMessage("Font scale set to " .. percent .. "%.")
        return true
    end

    if action == "perkscale" or action == "perkuiscale" then
        local percent = ClampNumber(value, 50, 300)
        if not percent then
            PrintMessage("Usage: /pee perkscale 50-300")
            return true
        end

        overlay.SetSetting("perkUIScale", percent / 100)
        overlay.ApplyPerkUIScale()
        if overlay.RefreshPerkChoiceTheme then
            overlay.RefreshPerkChoiceTheme(true)
        end
        PrintMessage("Perk UI scale set to " .. percent .. "%.")
        return true
    end

    if action == "transparent" then
        if value == "on" or value == "1" or value == "true" then
            overlay.SetSetting("transparentDesign", true)
        elseif value == "off" or value == "0" or value == "false" then
            overlay.SetSetting("transparentDesign", false)
        else
            PrintMessage("Usage: /pee transparent on or /pee transparent off")
            return true
        end

        RefreshVisibleTheme()
        overlay.ShowReloadPopup()
        PrintMessage(overlay.GetThemeSummary() .. ".")
        return true
    end

    if action == "options" then
        overlay.OpenOptionsPanel()
        return true
    end

    return false
end
