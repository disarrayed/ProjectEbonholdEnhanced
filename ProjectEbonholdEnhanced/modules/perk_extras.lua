local overlay = ProjectEbonholdEnhanced

if not overlay then
    return
end

local DARK = {0.039, 0.039, 0.039}
local BLACK = {0, 0, 0}
local WHITE = {1, 1, 1}
local MAGE_BLUE = {0.247, 0.78, 0.922}
local MUTED = {0.72, 0.72, 0.72}
local QUALITY_COLORS = {
    [0] = {1, 1, 1},
    [1] = {0.1, 1.0, 0.1},
    [2] = {0.0, 0.4, 1.0},
    [3] = {0.6, 0.2, 1.0},
    [4] = {1.0, 0.5, 0.0}
}

local FAMILY_ICONS = {
    ["Tank"] = "Interface\\AddOns\\ProjectEbonholdEnhanced\\assets\\perk_families\\tank",
    ["Survivability"] = "Interface\\AddOns\\ProjectEbonholdEnhanced\\assets\\perk_families\\survivability",
    ["Healer"] = "Interface\\AddOns\\ProjectEbonholdEnhanced\\assets\\perk_families\\healer",
    ["Caster"] = "Interface\\AddOns\\ProjectEbonholdEnhanced\\assets\\perk_families\\caster_dps",
    ["Caster DPS"] = "Interface\\AddOns\\ProjectEbonholdEnhanced\\assets\\perk_families\\caster_dps",
    ["Melee"] = "Interface\\AddOns\\ProjectEbonholdEnhanced\\assets\\perk_families\\melee_dps",
    ["Melee DPS"] = "Interface\\AddOns\\ProjectEbonholdEnhanced\\assets\\perk_families\\melee_dps",
    ["Ranged"] = "Interface\\AddOns\\ProjectEbonholdEnhanced\\assets\\perk_families\\ranged_dps",
    ["Ranged DPS"] = "Interface\\AddOns\\ProjectEbonholdEnhanced\\assets\\perk_families\\ranged_dps",
}

local function Opacity()
    return overlay.GetBackdropOpacity and overlay.GetBackdropOpacity() or 0.8
end

local function SetSize(frame, width, height)
    if frame.SetSize then
        frame:SetSize(width, height)
    else
        if frame.SetWidth then frame:SetWidth(width) end
        if frame.SetHeight then frame:SetHeight(height) end
    end
end

local function SetBackdrop(frame, color, border)
    if not frame then
        return
    end

    frame._peeApplyingBackdrop = true
    local setBackdropColor = frame._peeRawSetBackdropColor or frame.SetBackdropColor
    if setBackdropColor then
        setBackdropColor(frame, color[1], color[2], color[3], Opacity())
    end

    local setBackdropBorderColor = frame._peeRawSetBackdropBorderColor or frame.SetBackdropBorderColor
    if setBackdropBorderColor then
        setBackdropBorderColor(frame, border[1], border[2], border[3], 1)
    end
    frame._peeApplyingBackdrop = false
end

local function LockBackdrop(frame)
    if not frame or frame._peeBackdropLocked then
        return
    end

    if frame.SetBackdropColor then
        frame._peeRawSetBackdropColor = frame.SetBackdropColor
        frame.SetBackdropColor = function(self, red, green, blue, alpha)
            if self._peeBackdropLocked and not self._peeApplyingBackdrop then
                return
            end
            return self._peeRawSetBackdropColor(self, red, green, blue, alpha)
        end
    end

    if frame.SetBackdropBorderColor then
        frame._peeRawSetBackdropBorderColor = frame.SetBackdropBorderColor
        frame.SetBackdropBorderColor = function(self, red, green, blue, alpha)
            if self._peeBackdropLocked and not self._peeApplyingBackdrop then
                return
            end
            return self._peeRawSetBackdropBorderColor(self, red, green, blue, alpha)
        end
    end

    frame._peeBackdropLocked = true
end

local function GetPendingRollCount()
    local service = _G.ProjectEbonhold and ProjectEbonhold.PerkService
    if service and service.GetPendingRollsCount then
        return service.GetPendingRollsCount()
    end
    return nil
end

local function GetFamilies(frame)
    local families = frame and frame._perkData and frame._perkData.families
    if (not families or #families == 0) and frame and frame._spellId then
        local db = _G.ProjectEbonhold and ProjectEbonhold.PerkDatabase
        families = db and db[frame._spellId] and db[frame._spellId].families
    end
    if type(families) == "string" then
        local list = {}
        for value in families:gmatch("[^,]+") do
            value = value:gsub("^%s+", ""):gsub("%s+$", "")
            if value ~= "" then
                list[#list + 1] = value
            end
        end
        return list
    end
    return type(families) == "table" and families or {}
end

local function EnsureFamilyIconSlots(frame)
    if not frame or not frame.CreateTexture then
        return nil
    end
    if not frame.familyIconSlots then
        frame.familyIconSlots = {}
    end
    for index = 1, 5 do
        if not frame.familyIconSlots[index] then
            local texture = frame:CreateTexture(nil, "OVERLAY")
            SetSize(texture, 18, 18)
            if texture.SetTexCoord then
                texture:SetTexCoord(0.07, 0.93, 0.07, 0.93)
            end
            frame.familyIconSlots[index] = texture
        end
    end
    return frame.familyIconSlots
end

local function ApplyFamilyIcons(frame)
    local slots = EnsureFamilyIconSlots(frame)
    if not slots then
        return
    end
    local families = GetFamilies(frame)
    local visibleCount = 0

    for _, slot in ipairs(slots) do
        if slot.Hide then
            slot:Hide()
        end
    end

    for _, family in ipairs(families) do
        local texture = FAMILY_ICONS[family]
        if texture and visibleCount < #slots then
            visibleCount = visibleCount + 1
            local slot = slots[visibleCount]
            if slot.SetTexture then
                slot:SetTexture(texture)
            end
            if slot.ClearAllPoints then
                slot:ClearAllPoints()
            end
            local xOffset = (visibleCount - ((math.min(#families, #slots) + 1) / 2)) * 22
            slot:SetPoint("TOP", frame.nameText or frame.backdropFrame or frame, "BOTTOM", xOffset, -6)
            if slot.Show then
                slot:Show()
            end
        end
    end
end

local function ForceTextureHidden(texture)
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

local function SuppressTexture(texture)
    if not texture then
        return
    end

    if not texture._peeSuppressionWrapped then
        if texture.SetTexture then
            texture._peeRawSetTexture = texture.SetTexture
            texture.SetTexture = function(self, ...)
                if self._peeSuppressVisual then
                    self._peeRawSetTexture(self, nil)
                    ForceTextureHidden(self)
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
                    ForceTextureHidden(self)
                    return
                end
                return self._peeRawShow(self, ...)
            end
        end

        if texture.Hide then
            texture._peeRawHide = texture.Hide
        end

        texture._peeSuppressionWrapped = true
    end

    texture._peeSuppressVisual = true
    texture._peeFreezeFading = false
    if texture.SetTexture then
        texture:SetTexture(nil)
    end
    ForceTextureHidden(texture)
end

local function ApplyFrozenVisual(frame)
    if not frame then
        return
    end
    if not frame.peeFreezeOverlay and frame.CreateTexture then
        frame.peeFreezeOverlay = frame:CreateTexture(nil, "BACKGROUND")
        frame.peeFreezeOverlay:SetAllPoints(frame.backdropFrame or frame)
        frame.peeFreezeOverlay:Hide()
    end
    if not frame.peeFreezeFadeDriver and CreateFrame then
        frame.peeFreezeFadeDriver = CreateFrame("Frame", nil, frame)
        frame.peeFreezeFadeDriver:Hide()
    end

    LockBackdrop(frame.backdropFrame)
    SetBackdrop(frame.backdropFrame, DARK, BLACK)
    frame._peeFrozenVisualActive = false
    if not overlay.IsPerkFadeAnimationDisabled or overlay.IsPerkFadeAnimationDisabled() then
        SuppressTexture(frame.bg)
        SuppressTexture(frame.freezeOverlay)
        SuppressTexture(frame.peeFreezeOverlay)
        if frame.peeFreezeFadeDriver then
            frame.peeFreezeFadeDriver:SetScript("OnUpdate", nil)
            frame.peeFreezeFadeDriver:Hide()
        end
    end
    if frame.freezeCardButton and not frame.freezeCardButton._peeFreezeVisualCleanupHook and
        frame.freezeCardButton.HookScript then
        frame.freezeCardButton:HookScript("OnClick", function()
            ApplyFrozenVisual(frame)
            if overlay.RefreshPerkChoiceTheme then
                overlay.RefreshPerkChoiceTheme(true)
            end
        end)
        frame.freezeCardButton._peeFreezeVisualCleanupHook = true
    end
end

local function ApplySelectLabels()
    local count = GetPendingRollCount()
    if not count then
        return
    end
    local label = "Select (" .. tostring(count) .. ")"
    for index = 1, 3 do
        local frame = _G["PerkChoice" .. index]
        local text = frame and frame.selectButton and frame.selectButton.text
        if text and text.SetText then
            text:SetText(label)
        elseif frame and frame.selectButton and frame.selectButton.SetText then
            frame.selectButton:SetText(label)
        end
    end
end

function overlay.ApplyPerkChoiceExtras()
    if overlay.isPTR or not overlay.enabled then
        return
    end
    for index = 1, 3 do
        local frame = _G["PerkChoice" .. index]
        if frame then
            ApplyFamilyIcons(frame)
            ApplyFrozenVisual(frame)
        end
    end
    ApplySelectLabels()
end

local function PlayerOwnsEcho(card)
    if not card or not card.spellId or not overlay.CountOwnedPerkInstances then
        return false
    end
    local count = overlay.CountOwnedPerkInstances(card.spellId)
    return (count or 0) > 0
end

local function EnsureCardBadge(card, key, texturePath, point, xOffset, yOffset)
    if not card or card[key] or not card.CreateTexture then
        return card and card[key]
    end
    local badge = card:CreateTexture(nil, "OVERLAY")
    badge:SetTexture(texturePath)
    SetSize(badge, 18, 18)
    badge:SetPoint(point, card.icon or card, point, xOffset or 0, yOffset or 0)
    card[key] = badge
    return badge
end

local function WrapBrowserCardTooltip(card)
    if not card or card._peeBrowserExtrasWrapped or not card.SetScript then
        return
    end
    local originalEnter = card.GetScript and card:GetScript("OnEnter")
    local originalClick = card.GetScript and card:GetScript("OnClick")

    card:SetScript("OnEnter", function(self, ...)
        if originalEnter then
            originalEnter(self, ...)
        end
        if GameTooltip and self.spellId and self.perkData then
            local color = QUALITY_COLORS[self.perkData.quality or 0] or WHITE
            if GameTooltip.AddLine then
                GameTooltip:AddLine(" ")
                GameTooltip:AddLine("Max Stacks: " .. tostring(self.perkData.maxStack or "?"), MUTED[1], MUTED[2],
                    MUTED[3])
                if type(self.perkData.families) == "table" and #self.perkData.families > 0 then
                    GameTooltip:AddLine("Family: " .. table.concat(self.perkData.families, ", "), MAGE_BLUE[1],
                        MAGE_BLUE[2], MAGE_BLUE[3], true)
                end
                local project = _G and _G.ProjectEbonhold
                local dropSource = project and project.PerkDropSources and project.PerkDropSources[self.spellId]
                if not dropSource and project and self.perkData.groupId and project.PerkDropSourceByGroup then
                    dropSource = project.PerkDropSourceByGroup[self.perkData.groupId]
                end
                if dropSource then
                    GameTooltip:AddLine(" ")
                    GameTooltip:AddLine(dropSource, 0.5, 0.5, 0.5, true)
                end
                if self.perkData.requiredSpell and self.perkData.requiredSpell ~= 0 then
                    GameTooltip:AddLine("Requires Tome to unlock", 1, 0.82, 0)
                end
                GameTooltip:AddLine("Shift-click to link in chat", color[1], color[2], color[3])
            end
            if GameTooltip.Show then
                GameTooltip:Show()
            end
        end
    end)

    card:SetScript("OnClick", function(self, mouseButton, ...)
        if IsShiftKeyDown and IsShiftKeyDown() and mouseButton == "LeftButton" and self.spellId and self.perkData then
            local marker = "{echo:" .. tostring(self.spellId) .. ":" .. tostring(self.perkData.quality or 0) .. "}"
            local editBox = ChatFrameEditBox
            if (not editBox or (editBox.IsShown and not editBox:IsShown())) and ChatFrame1EditBox then
                editBox = ChatFrame1EditBox
            end
            if editBox and editBox.Insert and (not editBox.IsShown or editBox:IsShown()) then
                editBox:Insert(marker)
                return
            end
            if ChatFrame_OpenChat then
                ChatFrame_OpenChat("")
            end
            if C_Timer and C_Timer.After then
                C_Timer.After(0.1, function()
                    if ChatFrame1EditBox and ChatFrame1EditBox.Insert then
                        ChatFrame1EditBox:Insert(marker)
                    end
                end)
            end
            return
        end
        if originalClick then
            return originalClick(self, mouseButton, ...)
        end
    end)
    if card.RegisterForClicks then
        card:RegisterForClicks("LeftButtonUp", "RightButtonUp")
    end
    card._peeBrowserExtrasWrapped = true
end

function overlay.ApplyPerkBrowserExtras()
    if overlay.isPTR or not overlay.enabled or not overlay.GetPerkBrowserCards then
        return
    end
    for _, card in ipairs(overlay.GetPerkBrowserCards()) do
        local tome = EnsureCardBadge(card, "peeTomeIcon", "Interface\\Icons\\INV_Misc_Book_11", "TOPLEFT", 1, -1)
        local owned = EnsureCardBadge(card, "peeOwnedIcon", "Interface\\Buttons\\UI-CheckBox-Check", "BOTTOMLEFT", 2, 2)
        if tome then
            if card.perkData and card.perkData.requiredSpell and card.perkData.requiredSpell ~= 0 then
                tome:Show()
            else
                tome:Hide()
            end
        end
        if owned then
            if owned.SetVertexColor then
                owned:SetVertexColor(0, 1, 0, 1)
            end
            if PlayerOwnsEcho(card) then
                owned:Show()
            else
                owned:Hide()
            end
        end
        WrapBrowserCardTooltip(card)
    end
end

local function WrapOverlayFunction(name, afterFunc)
    local original = overlay[name]
    if type(original) ~= "function" or overlay["_peeExtrasWrapped" .. name] then
        return
    end
    overlay["_peeExtrasWrapped" .. name] = true
    overlay[name] = function(...)
        local first, second, third = original(...)
        afterFunc()
        return first, second, third
    end
end

local function Install()
    WrapOverlayFunction("ApplyPerkChoiceTheme", overlay.ApplyPerkChoiceExtras)
    WrapOverlayFunction("ApplyPerkBrowserTheme", overlay.ApplyPerkBrowserExtras)
end

overlay.InstallPerkExtras = Install

local eventFrame = CreateFrame and CreateFrame("Frame")
if eventFrame then
    eventFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
    eventFrame:SetScript("OnEvent", function()
        Install()
        overlay.ApplyPerkChoiceExtras()
        overlay.ApplyPerkBrowserExtras()
    end)
end
Install()
