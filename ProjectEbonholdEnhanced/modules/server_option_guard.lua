-- luacheck: globals ProjectEbonholdEnhanced

local overlay = ProjectEbonholdEnhanced

if not overlay then
    return
end

local ADDON_NAME = "ProjectEbonholdEnhanced"
local SERVER_RELOAD_POPUP = "PROJECTEBONHOLD_RELOAD_REQUIRED"
local PEE_DISABLE_POPUP = "PEE_DISABLE_FOR_SERVER_THEME"

local function GetOverlaySetting(key)
    return overlay.GetSetting and overlay.GetSetting(key) or nil
end

local SERVER_OPTION_OVERRIDES = {
    noPerkFadeAnimations = function()
        return overlay.IsPerkFadeAnimationDisabled and overlay.IsPerkFadeAnimationDisabled() or true
    end,
    noRerollConfirm = function()
        return overlay.IsRerollConfirmationRemoved and overlay.IsRerollConfirmationRemoved() or true
    end,
    rerollAutoRepopulate = function()
        return true
    end,
    echoesVisibleOnLevelUp = function()
        return overlay.IsKeepEchoesVisibleOnLevelUpEnabled and overlay.IsKeepEchoesVisibleOnLevelUpEnabled() or true
    end,
    autoShowEchoes = function()
        return overlay.IsAutoShowEchoChoicesEnabled and overlay.IsAutoShowEchoChoicesEnabled() or false
    end,
    perkDirectBanish = function()
        return true
    end,
    perkShowSelectCount = function()
        return true
    end,
    perkUIScale = function()
        return overlay.GetPerkUIScale and overlay.GetPerkUIScale() or 1.0
    end,
    transparentDesign = function()
        return true
    end,
    fontScale = function()
        return GetOverlaySetting("fontScale") or 1.0
    end,
    backdropOpacity = function()
        return overlay.GetBackdropOpacity and overlay.GetBackdropOpacity() or 0.8
    end,
}

local SERVER_VISUAL_OPTION_KEYS = {
    transparentDesign = true,
    fontScale = true,
    backdropOpacity = true,
    perkUIScale = true,
}

local function PrintMessage(message)
    if overlay.PrintMessage then
        overlay.PrintMessage(message)
    end
end

local function GetServerOptionOverride(key)
    local provider = SERVER_OPTION_OVERRIDES[key]
    if not provider then
        return nil, false
    end

    return provider(), true
end

local function RunAfterServerOptionHandler(callback)
    local timer = _G and _G.C_Timer
    if timer and type(timer.After) == "function" then
        timer.After(0, callback)
        return
    end

    callback()
end

local function RefreshServerVisualOptionControls()
    local frame = _G and _G.ProjectEbonholdOptionsPanel
    local service = _G and _G.ProjectEbonholdOptionsService
    if not frame or not service or type(service.GetSetting) ~= "function" then
        return
    end

    if frame.TransparentDesignCheckbox and frame.TransparentDesignCheckbox.SetChecked then
        frame.TransparentDesignCheckbox:SetChecked(service:GetSetting("transparentDesign"))
    end

    if frame.perkUIScaleSlider and frame.perkUIScaleSlider.SetValue then
        local percent = math.floor((service:GetSetting("perkUIScale") or 1.0) * 100 + 0.5)
        frame.perkUIScaleSlider:SetValue(percent)
        if frame.perkUIScaleLabel and frame.perkUIScaleLabel.SetText then
            frame.perkUIScaleLabel:SetText("Perk UI Scale: " .. percent .. "%")
        end
    end

    if frame.fontScaleSlider and frame.fontScaleSlider.SetValue then
        local percent = math.floor((service:GetSetting("fontScale") or 1.0) * 100 + 0.5)
        local wasInitialized = frame.fontScaleSlider._initialized
        frame.fontScaleSlider._initialized = false
        frame.fontScaleSlider:SetValue(percent)
        frame.fontScaleSlider._initialized = wasInitialized
        if frame.fontScaleLabel and frame.fontScaleLabel.SetText then
            frame.fontScaleLabel:SetText("Affix Book Font Scale: " .. percent .. "%")
        end
    end

    if frame.opacitySlider and frame.opacitySlider.SetValue then
        local percent = math.floor((service:GetSetting("backdropOpacity") or 0.8) * 100 + 0.5)
        local wasInitialized = frame.opacitySlider._initialized
        frame.opacitySlider._initialized = false
        frame.opacitySlider:SetValue(percent)
        frame.opacitySlider._initialized = wasInitialized
        if frame.opacityLabel and frame.opacityLabel.SetText then
            frame.opacityLabel:SetText("Backdrop Opacity: " .. percent .. "%")
        end
    end
end

local function RefreshAfterServerVisualOptionAttempt()
    RunAfterServerOptionHandler(function()
        if _G and _G.StaticPopup_Hide then
            _G.StaticPopup_Hide(SERVER_RELOAD_POPUP)
        end
        RefreshServerVisualOptionControls()
        if overlay.ApplyPerkUIScale then
            overlay.ApplyPerkUIScale()
        end
        if overlay.RefreshPerkChoiceTheme then
            overlay.RefreshPerkChoiceTheme(true)
        end
        if overlay.RefreshVisibleTheme then
            overlay.RefreshVisibleTheme()
        end
    end)
end

local function DisableOverlayForServerTransparentTheme(originalSetSetting, service)
    if originalSetSetting then
        originalSetSetting(service, "transparentDesign", false)
    end

    if _G and _G.DisableAddOn then
        _G.DisableAddOn(ADDON_NAME)
    else
        PrintMessage("Disable Project Ebonhold Enhanced from the AddOns screen, then reload.")
        return
    end

    if _G.ReloadUI then
        _G.ReloadUI()
    else
        PrintMessage("Project Ebonhold Enhanced has been disabled. Reload the UI to finish.")
    end
end

local function ShowServerTransparentDisablePrompt(originalSetSetting, service)
    if not _G or not _G.StaticPopupDialogs or not _G.StaticPopup_Show then
        PrintMessage("Disable Project Ebonhold Enhanced to turn off the server transparent theme option.")
        RefreshAfterServerVisualOptionAttempt()
        return
    end

    _G.StaticPopupDialogs[PEE_DISABLE_POPUP] = {
        text = "Project Ebonhold Enhanced controls Project Ebonhold visual theme settings while it is enabled.\n\n" ..
            "To turn off the server Transparent design option, disable Project Ebonhold Enhanced " ..
            "and reload the UI.\n\n" ..
            "Disable Project Ebonhold Enhanced now?",
        button1 = "Yes",
        button2 = "No",
        OnAccept = function()
            DisableOverlayForServerTransparentTheme(originalSetSetting, service)
        end,
        OnCancel = RefreshAfterServerVisualOptionAttempt,
        timeout = 0,
        whileDead = true,
        hideOnEscape = true,
        preferredIndex = 3,
    }

    RunAfterServerOptionHandler(function()
        if _G.StaticPopup_Hide then
            _G.StaticPopup_Hide(SERVER_RELOAD_POPUP)
        end
        _G.StaticPopup_Show(PEE_DISABLE_POPUP)
        RefreshServerVisualOptionControls()
    end)
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

    if type(service.SetSetting) == "function" then
        local originalSetSetting = service.SetSetting
        service._peeOriginalSetSetting = originalSetSetting
        service.SetSetting = function(selfOrKey, maybeKey, maybeValue, ...)
            local dotCall = type(selfOrKey) == "string"
            local key = dotCall and selfOrKey or maybeKey
            local value = dotCall and maybeKey or maybeValue

            if overlay.enabled and not overlay.isPTR and SERVER_VISUAL_OPTION_KEYS[key] then
                if key == "transparentDesign" and value == false then
                    ShowServerTransparentDisablePrompt(originalSetSetting, service)
                else
                    RefreshAfterServerVisualOptionAttempt()
                end
                return
            end

            if dotCall then
                return originalSetSetting(service, selfOrKey, maybeKey, maybeValue, ...)
            end

            return originalSetSetting(selfOrKey, maybeKey, maybeValue, ...)
        end
    end

    service._peeOptionReadOverridesInstalled = true
end
