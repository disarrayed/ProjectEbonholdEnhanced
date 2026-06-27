local overlay = ProjectEbonholdEnhanced

if not overlay then
    return
end

local DARK = {0.039, 0.039, 0.039}
local BLACK = {0, 0, 0}
local CREAM = {1, 0.92, 0.82}
local GOLD = {1, 0.82, 0}
local MAGE_BLUE = {0.247, 0.78, 0.922}
local MUTED = {0.65, 0.65, 0.65}
local RED = {0.32, 0.1, 0.1}
local RED_HOVER = {0.48, 0.16, 0.14}
local RED_HOVER_BORDER = {1.0, 0.28, 0.24}
local HOVER_BLUE = {0.16, 0.88, 1.0}
local HOVER_BLUE_BACKDROP = {0.03, 0.14, 0.18}
local PANEL_WIDTH = 260
local ROW_HEIGHT = 28
local PANEL_GAP = 6
local PANEL_PADDING = 8
local HEADER_HEIGHT = 48
local TOP_BAR_HEIGHT = 32
local STATUS_BAR_HEIGHT = 38
local STATUS_BUTTON_HEIGHT = 24
local STATUS_SEARCH_WIDTH = 250
local SOUL_ICON_TEXTURE = "Interface\\AddOns\\ProjectEbonhold\\assets\\inv_soulash"
local BOTTOM_TEXTURE = "Interface\\AddOns\\ProjectEbonhold\\assets\\texture_bottom"
local LINE_TEXTURE = "Interface\\Buttons\\WHITE8x8"
local MIN_ZOOM = 0.3
local MAX_ZOOM = 2.0
local ZOOM_STEP = 0.1
local SERVER_RESIZE_TEXTURE_PREFIX = "Interface\\ChatFrame\\UI-ChatIM-SizeGrabber"

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

local function SetFont(fontString, size, color, width, justify)
    if not fontString then
        return
    end
    if fontString.SetFont then
        fontString:SetFont("Fonts\\FRIZQT__.TTF", overlay.ScaledFontSize and overlay.ScaledFontSize(size) or size,
            "OUTLINE")
    end
    if fontString.SetTextColor then
        fontString:SetTextColor(color[1], color[2], color[3], 1)
    end
    if width and fontString.SetWidth then
        fontString:SetWidth(width)
    end
    if fontString.SetWordWrap then
        fontString:SetWordWrap(false)
    end
    if fontString.SetNonSpaceWrap then
        fontString:SetNonSpaceWrap(false)
    end
    if justify and fontString.SetJustifyH then
        fontString:SetJustifyH(justify)
    end
end

local function SetDarkBackdrop(frame, edgeSize, alpha)
    if not frame or not frame.SetBackdrop then
        return
    end
    edgeSize = edgeSize or 4
    frame:SetBackdrop({
        bgFile = "Interface\\Buttons\\WHITE8x8",
        edgeFile = "Interface\\Buttons\\WHITE8x8",
        tile = true,
        tileSize = 16,
        edgeSize = edgeSize,
        insets = { left = edgeSize, right = edgeSize, top = edgeSize, bottom = edgeSize },
    })
    if frame.SetBackdropColor then
        frame:SetBackdropColor(DARK[1], DARK[2], DARK[3], alpha or Opacity())
    end
    if frame.SetBackdropBorderColor then
        frame:SetBackdropBorderColor(BLACK[1], BLACK[2], BLACK[3], 1)
    end
end

local function SetPlainBarBackdrop(frame, alpha)
    if not frame or not frame.SetBackdrop then
        return
    end

    frame:SetBackdrop({
        bgFile = "Interface\\Buttons\\WHITE8x8",
        tile = true,
        tileSize = 16,
        insets = { left = 0, right = 0, top = 0, bottom = 0 },
    })
    if frame.SetBackdropColor then
        frame:SetBackdropColor(DARK[1], DARK[2], DARK[3], alpha or 0.94)
    end
end

local function SetSearchBackdrop(frame)
    SetDarkBackdrop(frame, 2, 0.96)
    if frame and frame.SetBackdropColor then
        frame:SetBackdropColor(0.01, 0.01, 0.01, 0.96)
    end
    if frame and frame.SetBackdropBorderColor then
        frame:SetBackdropBorderColor(BLACK[1], BLACK[2], BLACK[3], 1)
    end

    local parent = frame and frame.GetParent and frame:GetParent()
    if not parent or not CreateFrame then
        return
    end

    local borderFrame = frame._peeSkillTreeSearchBackdrop
    if not borderFrame then
        borderFrame = CreateFrame("Frame", nil, parent)
        frame._peeSkillTreeSearchBackdrop = borderFrame
    end

    SetSize(borderFrame, (frame.GetWidth and frame:GetWidth()) or STATUS_SEARCH_WIDTH,
        (frame.GetHeight and frame:GetHeight()) or 24)
    if borderFrame.ClearAllPoints then
        borderFrame:ClearAllPoints()
    end
    borderFrame:SetPoint("TOPLEFT", frame, "TOPLEFT", -1, 1)
    borderFrame:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", 1, -1)
    if borderFrame.SetFrameLevel and frame.GetFrameLevel then
        borderFrame:SetFrameLevel(math.max(0, (frame:GetFrameLevel() or 1) - 1))
    end
    SetDarkBackdrop(borderFrame, 2, 0.96)
    if borderFrame.SetBackdropColor then
        borderFrame:SetBackdropColor(0.01, 0.01, 0.01, 0.96)
    end
    if borderFrame.SetBackdropBorderColor then
        borderFrame:SetBackdropBorderColor(BLACK[1], BLACK[2], BLACK[3], 1)
    end
    if borderFrame.Show then
        borderFrame:Show()
    end
    if frame.SetFrameLevel and borderFrame.GetFrameLevel then
        frame:SetFrameLevel((borderFrame:GetFrameLevel() or 1) + 1)
    end
end

local function SetBackdropColor(frame, color, alpha)
    if frame and frame.SetBackdropColor then
        local wasApplying = frame._peeApplyingBackdrop
        frame._peeApplyingBackdrop = true
        frame:SetBackdropColor(color[1], color[2], color[3], alpha or Opacity())
        frame._peeApplyingBackdrop = wasApplying
    end
end

local function SetBorderColor(frame, color)
    if frame and frame.SetBackdropBorderColor then
        local wasApplying = frame._peeApplyingBackdrop
        frame._peeApplyingBackdrop = true
        frame:SetBackdropBorderColor(color[1], color[2], color[3], 1)
        frame._peeApplyingBackdrop = wasApplying
    end
end

local function HideRegion(region)
    if not region then
        return
    end
    if overlay.SuppressTextureRegion then
        overlay.SuppressTextureRegion(region)
        return
    end
    if region.Hide then
        region:Hide()
    end
    if region.SetAlpha then
        region:SetAlpha(0)
    end
end

local function HideButtonArt(button)
    if not button then
        return
    end
    if overlay.HideButtonTextures then
        overlay.HideButtonTextures(button)
    end
    if overlay.LockButtonTextureSetters then
        overlay.LockButtonTextureSetters(button)
    end
    if button.GetRegions then
        for _, region in ipairs({ button:GetRegions() }) do
            if region and region.SetTexture then
                HideRegion(region)
            end
        end
    end
end

local function HideControlFrame(frame)
    if not frame then
        return
    end
    HideButtonArt(frame)
    if frame.Hide then
        frame:Hide()
    end
    if frame.SetAlpha then
        frame:SetAlpha(0)
    end
    if frame.EnableMouse then
        frame:EnableMouse(false)
    end
    if frame.Show and not frame._peeForceHiddenShowWrapped then
        frame._peeRawShow = frame.Show
        frame.Show = function(self, ...)
            if self._peeForceHidden then
                if self._peeRawHide then
                    self._peeRawHide(self)
                elseif self.Hide then
                    self:Hide()
                end
                if self.SetAlpha then
                    self:SetAlpha(0)
                end
                return
            end
            return self._peeRawShow(self, ...)
        end
        frame._peeRawHide = frame.Hide
        frame._peeForceHiddenShowWrapped = true
    end
    frame._peeForceHidden = true
end

local function ClearAndPoint(frame, point, relativeTo, relativePoint, xOffset, yOffset)
    if not frame or not frame.SetPoint then
        return
    end
    if frame.ClearAllPoints then
        frame:ClearAllPoints()
    end
    frame:SetPoint(point, relativeTo, relativePoint, xOffset or 0, yOffset or 0)
end

local function GetText(fontString)
    if fontString and fontString.GetText then
        return fontString:GetText()
    end
    return fontString and fontString.text
end

local function ReadProgressBarText(progressBar)
    local progressText = GetText(progressBar and progressBar.progressText)
    if progressText and progressText ~= "" then
        return progressText
    end
    if progressBar and progressBar.currentTotal and progressBar.nextMilestone then
        return tostring(progressBar.currentTotal) .. "/" .. tostring(progressBar.nextMilestone)
    end
    return nil
end

local function ReadProgressValues(progressBar)
    if not progressBar then
        return nil, nil
    end

    local current = tonumber(progressBar.currentTotal)
    local target = tonumber(progressBar.nextMilestone)
    if current and target and target > 0 then
        return current, target
    end

    local progressText = ReadProgressBarText(progressBar)
    if progressText then
        local textCurrent, textTarget = progressText:match("(%d+)%s*/%s*(%d+)")
        textCurrent = tonumber(textCurrent)
        textTarget = tonumber(textTarget)
        if textCurrent and textTarget and textTarget > 0 then
            return textCurrent, textTarget
        end
    end

    return nil, nil
end

function overlay.CaptureSkillTreeProgressBar(progressBar)
    local progressText = ReadProgressBarText(progressBar)
    local current, target = ReadProgressValues(progressBar)
    if current and target then
        overlay.skillTreeProgressValue = {
            current = current,
            target = target
        }
    end
    if progressText and progressText ~= "" then
        overlay.skillTreeProgressText = progressText
        return progressText
    end
    return overlay.skillTreeProgressText
end

local function WriteTopBarProgress(skillTreeFrame, progressText)
    local topBar = skillTreeFrame and skillTreeFrame.peeSkillTreeTopBar
    local progressBox = topBar and topBar.progressBox
    local value = progressBox and progressBox.value
    if value and progressText and progressText ~= "" then
        value:SetText(progressText)
    end
    if progressBox and progressBox.fill then
        local captured = overlay.skillTreeProgressValue
        local current = captured and captured.current
        local target = captured and captured.target
        local ratio = 0
        if current and target and target > 0 then
            ratio = math.max(0, math.min(1, current / target))
        end
        local width = progressBox._peeProgressWidth or (progressBox.GetWidth and progressBox:GetWidth()) or 300
        progressBox.fill:SetWidth(math.max(1, math.floor(width * ratio)))
    end
end

local function EnsureProgressBarHook(skillTreeFrame)
    local progressBar = skillTreeFrame and skillTreeFrame.progressBar
    if not progressBar or progressBar._peeProgressUpdateWrapped then
        return
    end

    local originalUpdate = progressBar.UpdateProgressBar
    if type(originalUpdate) ~= "function" then
        return
    end

    progressBar._peeRawUpdateProgressBar = originalUpdate
    progressBar.UpdateProgressBar = function(...)
        local firstResult, secondResult, thirdResult = progressBar._peeRawUpdateProgressBar(...)
        local progressText = overlay.CaptureSkillTreeProgressBar(progressBar)
        if not progressBar._peeProgressRefreshing then
            WriteTopBarProgress(_G and _G.skillTreeFrame, progressText)
        end
        return firstResult, secondResult, thirdResult
    end
    progressBar._peeProgressUpdateWrapped = true
end

local function EnsureText(parent, key, size, color, width, justify)
    if not parent or not parent.CreateFontString then
        return nil
    end
    if not parent[key] then
        parent[key] = parent:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    end
    SetFont(parent[key], size, color, width, justify)
    return parent[key]
end

local function FindTextureRegion(frame, texturePath)
    if not frame or not frame.GetRegions then
        return nil
    end
    for _, region in ipairs({ frame:GetRegions() }) do
        if region and region.GetTexture and region:GetTexture() == texturePath then
            return region
        end
    end
    return nil
end

local function HideTextureRegions(frame, texturePath)
    if not frame or not frame.GetRegions then
        return
    end
    for _, region in ipairs({ frame:GetRegions() }) do
        if region and region.GetTexture and region:GetTexture() == texturePath then
            if region.Hide then
                region:Hide()
            end
            if region.SetAlpha then
                region:SetAlpha(0)
            end
        end
    end
end

local function ButtonFontString(button)
    local fontString
    if button and button.GetFontString then
        fontString = button:GetFontString()
    end
    return fontString or (button and button.text)
end

local function SkinStatusButton(button, restingColor, width)
    if not button then
        return
    end
    HideButtonArt(button)
    SetSize(button, width or 88, STATUS_BUTTON_HEIGHT)
    SetDarkBackdrop(button, 2, 0.92)
    SetBackdropColor(button, restingColor or DARK, 0.92)
    SetBorderColor(button, BLACK)
    if button.SetAlpha then
        button:SetAlpha(1)
    end

    local fontString = ButtonFontString(button)
    SetFont(fontString, 12, CREAM, width or 88, "CENTER")
    if fontString and fontString.SetTextColor then
        if overlay.LockRuntimeButtonTextColor then
            overlay.LockRuntimeButtonTextColor(fontString)
        end
        if overlay.SetRuntimeButtonTextColor then
            overlay.SetRuntimeButtonTextColor(fontString, CREAM)
        end
    end

    button._peeSkillTreeRestingColor = restingColor or DARK

    local function onEnter(self)
        if self._peeSkillTreeRestingColor == RED then
            SetBackdropColor(self, RED_HOVER, 0.96)
            SetBorderColor(self, RED_HOVER_BORDER)
            return
        end
        SetBackdropColor(self, HOVER_BLUE_BACKDROP, 0.96)
        SetBorderColor(self, HOVER_BLUE)
    end
    local function onLeave(self)
        SetBackdropColor(self, self._peeSkillTreeRestingColor or DARK, 0.92)
        SetBorderColor(self, BLACK)
    end

    if button._peeSkillTreeChromeHooks then
        return
    end

    if button.HookScript then
        button:HookScript("OnEnter", onEnter)
        button:HookScript("OnLeave", onLeave)
    elseif button.SetScript then
        button:SetScript("OnEnter", onEnter)
        button:SetScript("OnLeave", onLeave)
    end
    button._peeSkillTreeChromeHooks = true
end

local function ProgressText(skillTreeFrame)
    local progressBar = skillTreeFrame and skillTreeFrame.progressBar
    EnsureProgressBarHook(skillTreeFrame)
    if progressBar and progressBar.UpdateProgressBar and not progressBar._peeProgressRefreshing then
        progressBar._peeProgressRefreshing = true
        pcall(progressBar.UpdateProgressBar, progressBar)
        progressBar._peeProgressRefreshing = nil
    end

    return overlay.CaptureSkillTreeProgressBar(progressBar) or "No milestone data"
end

local function HideFrameVisuals(frame)
    if not frame then
        return
    end

    if frame.Hide then
        frame:Hide()
    end
    if frame.SetAlpha then
        frame:SetAlpha(0)
    end
    if frame.EnableMouse then
        frame:EnableMouse(false)
    end
    if frame.GetRegions then
        for _, region in ipairs({ frame:GetRegions() }) do
            if region.Hide then
                region:Hide()
            end
            if region.SetAlpha then
                region:SetAlpha(0)
            end
        end
    end
    if frame.GetChildren then
        for _, child in ipairs({ frame:GetChildren() }) do
            HideFrameVisuals(child)
        end
    end
end

local function HideServerProgressBar(skillTreeFrame)
    local progressBar = skillTreeFrame and skillTreeFrame.progressBar
    if not progressBar then
        return
    end

    if progressBar.Show and not progressBar._peeProgressShowWrapped then
        progressBar._peeRawShow = progressBar.Show
        progressBar.Show = function(self, ...)
            if self._peeForceHidden then
                HideFrameVisuals(self)
                return
            end
            return self._peeRawShow(self, ...)
        end
        progressBar._peeProgressShowWrapped = true
    end

    progressBar._peeForceHidden = true
    HideFrameVisuals(progressBar)
end

local function HideServerCloseButtons(skillTreeFrame, topBar)
    if not skillTreeFrame or not skillTreeFrame.GetChildren then
        return
    end
    for _, child in ipairs({ skillTreeFrame:GetChildren() }) do
        if child ~= topBar and child ~= (topBar and topBar.closeButton) and child ~= _G.skillTreeBottomBar and
            child ~= _G.skillTreeScroll and child ~= skillTreeFrame.progressBar then
            local normalTexture = child.GetNormalTexture and child:GetNormalTexture()
            local pushedTexture = child.GetPushedTexture and child:GetPushedTexture()
            if normalTexture or pushedTexture then
                if child.Hide then
                    child:Hide()
                end
                if child.SetAlpha then
                    child:SetAlpha(0)
                end
                if child.EnableMouse then
                    child:EnableMouse(false)
                end
            end
        end
    end
end

local function HideServerResizeGrips(skillTreeFrame)
    if not skillTreeFrame or not skillTreeFrame.GetChildren then
        return
    end

    for _, child in ipairs({ skillTreeFrame:GetChildren() }) do
        if child ~= skillTreeFrame.peeResizeHandle and child.GetRegions then
            for _, region in ipairs({ child:GetRegions() }) do
                local texture = region and region.GetTexture and region:GetTexture()
                if type(texture) == "string" and texture:find(SERVER_RESIZE_TEXTURE_PREFIX, 1, true) then
                    HideControlFrame(child)
                    break
                end
            end
        end
    end
end

local function EnsureSkillTreeTopBar(skillTreeFrame)
    if not skillTreeFrame or not CreateFrame then
        return nil
    end

    local topBar = skillTreeFrame.peeSkillTreeTopBar
    if not topBar then
        topBar = CreateFrame("Frame", nil, skillTreeFrame)
        skillTreeFrame.peeSkillTreeTopBar = topBar
    end

    SetSize(topBar, skillTreeFrame.GetWidth and (skillTreeFrame:GetWidth() - 8) or 892, TOP_BAR_HEIGHT)
    if topBar.ClearAllPoints then
        topBar:ClearAllPoints()
    end
    topBar:SetPoint("TOPLEFT", skillTreeFrame, "TOPLEFT", 2, -2)
    topBar:SetPoint("TOPRIGHT", skillTreeFrame, "TOPRIGHT", -2, -2)
    if topBar.SetFrameLevel and skillTreeFrame.GetFrameLevel then
        topBar:SetFrameLevel((skillTreeFrame:GetFrameLevel() or 1) + 30)
    end
    if topBar.EnableMouse then
        topBar:EnableMouse(true)
    end
    if topBar.RegisterForDrag then
        topBar:RegisterForDrag("LeftButton")
    end
    if topBar.SetScript then
        topBar:SetScript("OnDragStart", function()
            if overlay.StartSkillTreeFrameDrag then
                overlay.StartSkillTreeFrameDrag(skillTreeFrame, skillTreeFrame._peeOriginalSkillTreeDragStart)
            elseif skillTreeFrame.StartMoving then
                skillTreeFrame:StartMoving()
            end
        end)
        topBar:SetScript("OnDragStop", function()
            if overlay.StopSkillTreeFrameDrag then
                overlay.StopSkillTreeFrameDrag(skillTreeFrame, skillTreeFrame._peeOriginalSkillTreeDragStop)
            elseif skillTreeFrame.StopMovingOrSizing then
                skillTreeFrame:StopMovingOrSizing()
            end
        end)
    end
    SetPlainBarBackdrop(topBar, 0.96)

    local nodesText = EnsureText(topBar, "nodesText", 11, CREAM, 118, "LEFT")
    local permText = EnsureText(topBar, "permText", 11, CREAM, 96, "LEFT")
    ClearAndPoint(nodesText, "LEFT", topBar, "LEFT", 12, 0)
    ClearAndPoint(permText, "LEFT", nodesText, "RIGHT", 8, 0)
    if topBar.freeText then
        topBar.freeText:SetText("")
        if topBar.freeText.Hide then
            topBar.freeText:Hide()
        end
    end

    if not topBar.progressBox then
        topBar.progressBox = CreateFrame("Frame", nil, topBar)
    end
    local progressBox = topBar.progressBox
    local frameWidth = skillTreeFrame.GetWidth and skillTreeFrame:GetWidth() or 900
    local progressWidth = math.max(280, math.floor((frameWidth - 360) * 0.5))
    progressBox._peeProgressWidth = progressWidth
    SetSize(progressBox, progressWidth, 24)
    if progressBox.ClearAllPoints then
        progressBox:ClearAllPoints()
    end
    progressBox:SetPoint("CENTER", topBar, "CENTER", 0, 0)
    SetPlainBarBackdrop(progressBox, 0.92)
    if progressBox.SetBackdropColor then
        progressBox:SetBackdropColor(0.02, 0.02, 0.02, 0.92)
    end
    if not progressBox.fill then
        progressBox.fill = progressBox:CreateTexture(nil, "ARTWORK")
        progressBox.fill:SetTexture("Interface\\Buttons\\WHITE8x8")
        progressBox.fill:SetPoint("LEFT", progressBox, "LEFT", 1, 0)
        progressBox.fill:SetHeight(24)
    end
    progressBox.fill:SetVertexColor(MAGE_BLUE[1], MAGE_BLUE[2], MAGE_BLUE[3], 0.42)
    progressBox.fill:SetWidth(1)

    local progressLabel = EnsureText(progressBox, "label", 11, GOLD, 128, "LEFT")
    local progressValue = EnsureText(progressBox, "value", 11, CREAM, math.max(120, progressWidth - 150), "RIGHT")
    ClearAndPoint(progressLabel, "LEFT", progressBox, "LEFT", 10, 0)
    ClearAndPoint(progressValue, "RIGHT", progressBox, "RIGHT", -10, 0)
    progressLabel:SetText("Ashe Progression")

    if not topBar.closeButton then
        topBar.closeButton = CreateFrame("Button", nil, topBar)
        topBar.closeButton.text = topBar.closeButton:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        topBar.closeButton.text:SetPoint("CENTER", topBar.closeButton, "CENTER", 0, 0)
        topBar.closeButton.text:SetText("X")
        topBar.closeButton:SetScript("OnClick", function()
            if skillTreeFrame.Hide then
                skillTreeFrame:Hide()
            end
        end)
    end
    SetSize(topBar.closeButton, 24, 24)
    ClearAndPoint(topBar.closeButton, "RIGHT", topBar, "RIGHT", -6, 0)
    SkinStatusButton(topBar.closeButton, RED, 24)
    topBar.closeButton._peeSkillTreeRestingColor = RED
    SetFont(topBar.closeButton.text, 12, CREAM, 24, "CENTER")

    return topBar
end

local function RefreshSkillTreeTopBar(skillTreeFrame)
    local topBar = EnsureSkillTreeTopBar(skillTreeFrame)
    if not topBar then
        return
    end

    local stats = skillTreeFrame.peeSkillTreeStats or {}
    topBar.nodesText:SetText("|cffbbbbbbNodes:|r " .. tostring(stats.nodesUsed or 0) .. "/" ..
        tostring(stats.nodesTotal or 0))
    topBar.permText:SetText("|cffbbbbbbPerm:|r " .. tostring(stats.permanentUsed or 0) .. "/" ..
        tostring(stats.permanentTotal or 0))
    local progressText = ProgressText(skillTreeFrame)
    topBar.progressBox.value:SetText(progressText)
    WriteTopBarProgress(skillTreeFrame, progressText)

    if skillTreeFrame.peeNodeStatsFrame and skillTreeFrame.peeNodeStatsFrame.Hide then
        skillTreeFrame.peeNodeStatsFrame:Hide()
    end
    if skillTreeFrame.nodeStatsText and skillTreeFrame.nodeStatsText.Hide then
        skillTreeFrame.nodeStatsText:Hide()
    end
    HideServerProgressBar(skillTreeFrame)
    HideServerCloseButtons(skillTreeFrame, topBar)
    HideServerResizeGrips(skillTreeFrame)
end

local function LayoutSkillTreeStatusBar(skillTreeFrame, bottomBar)
    if not skillTreeFrame or not bottomBar then
        return
    end

    if bottomBar.ClearAllPoints then
        bottomBar:ClearAllPoints()
    end
    bottomBar:SetPoint("BOTTOMLEFT", skillTreeFrame, "BOTTOMLEFT", 2, 2)
    bottomBar:SetPoint("BOTTOMRIGHT", skillTreeFrame, "BOTTOMRIGHT", -2, 2)
    bottomBar:SetHeight(STATUS_BAR_HEIGHT)
    if bottomBar.SetFrameLevel and skillTreeFrame.GetFrameLevel then
        bottomBar:SetFrameLevel((skillTreeFrame:GetFrameLevel() or 1) + 25)
    end
    SetPlainBarBackdrop(bottomBar, 0.96)
    if bottomBar.SetBackdropColor then
        bottomBar:SetBackdropColor(BLACK[1], BLACK[2], BLACK[3], 0.96)
    end
    HideTextureRegions(bottomBar, BOTTOM_TEXTURE)

    local soulIcon = FindTextureRegion(bottomBar, SOUL_ICON_TEXTURE)
    if soulIcon then
        SetSize(soulIcon, 18, 18)
        ClearAndPoint(soulIcon, "LEFT", bottomBar, "LEFT", 14, 0)
        if soulIcon.Show then
            soulIcon:Show()
        end
        if soulIcon.SetAlpha then
            soulIcon:SetAlpha(1)
        end
    end

    local pointsText = skillTreeFrame.pointsText
    if pointsText then
        local currentText = GetText(pointsText) or ""
        local amount = currentText:match("(%d+)%D*$") or "0"
        pointsText:SetText("|cffFFD700Available Soul Ashes:|r " .. tostring(amount))
        SetFont(pointsText, 11, CREAM, 230, "LEFT")
        ClearAndPoint(pointsText, "LEFT", soulIcon or bottomBar, soulIcon and "RIGHT" or "LEFT",
            soulIcon and 6 or 12, 0)
    end

    local applyButton = _G.skillTreeApplyButton
    local resetButton = _G.PEESkillTreeResetButton
    local profilesButton = _G.PEESkillTreeProfilesButton
    SkinStatusButton(applyButton, RED, 132)
    SkinStatusButton(resetButton, DARK, 72)
    SkinStatusButton(profilesButton, DARK, 82)

    if applyButton then
        ClearAndPoint(applyButton, "LEFT", pointsText or bottomBar, pointsText and "RIGHT" or "LEFT",
            pointsText and 10 or 210, 0)
    end
    if resetButton then
        ClearAndPoint(resetButton, "LEFT", applyButton or bottomBar, applyButton and "RIGHT" or "LEFT",
            applyButton and 8 or 350, 0)
    end
    if profilesButton then
        ClearAndPoint(profilesButton, "LEFT", resetButton or applyButton or bottomBar,
            (resetButton or applyButton) and "RIGHT" or "LEFT", (resetButton or applyButton) and 8 or 430, 0)
    end

    HideControlFrame(_G.skillTreeExportButton)
    HideControlFrame(_G.skillTreeImportButton)

    local searchBox = _G.skillTreeSearchBox
    if searchBox then
        if searchBox.GetRegions then
            for _, region in ipairs({ searchBox:GetRegions() }) do
                if region and region.SetTexture then
                    HideRegion(region)
                end
            end
        end
        SetSize(searchBox, STATUS_SEARCH_WIDTH, 24)
        SetSearchBackdrop(searchBox)
        ClearAndPoint(searchBox, "RIGHT", bottomBar, "RIGHT", -46, 0)
    end

    if bottomBar.GetRegions then
        for _, region in ipairs({ bottomBar:GetRegions() }) do
            if GetText(region) == "Search:" then
                SetFont(region, 11, CREAM, 54, "RIGHT")
                ClearAndPoint(region, "RIGHT", searchBox or bottomBar, searchBox and "LEFT" or "RIGHT",
                    searchBox and -8 or -252, 0)
            end
        end
    end

    HideControlFrame(_G.revertBtn)

    if bottomBar.levelRestrictionFrame then
        SetPlainBarBackdrop(bottomBar.levelRestrictionFrame, 0.96)
        if bottomBar.levelRestrictionFrame.SetFrameLevel and bottomBar.GetFrameLevel then
            bottomBar.levelRestrictionFrame:SetFrameLevel((bottomBar:GetFrameLevel() or 1) + 20)
        end
    end
end

function overlay.ApplySkillTreeChrome()
    local skillTreeFrame = _G and _G.skillTreeFrame
    if not skillTreeFrame then
        return
    end

    RefreshSkillTreeTopBar(skillTreeFrame)
    LayoutSkillTreeStatusBar(skillTreeFrame, _G.skillTreeBottomBar)
end

local function ReadRankText(button)
    local text = button and button.rankText and button.rankText.GetText and button.rankText:GetText()
    if type(text) == "string" then
        local current, maximum = text:match("^(%d+)%s*/%s*(%d+)")
        if current and maximum then
            return tonumber(current) or 0, tonumber(maximum) or 0
        end
    end
    return tonumber(button and (button.currentRank or button.rank)) or 0,
        tonumber(button and (button.maxRank or button.maxRanks or button.maxR)) or 1
end

local function BadgeForNode(button)
    if button and button.permanent then
        return "Perm", GOLD
    end
    local currentRank, maxRank = ReadRankText(button)
    if maxRank > 0 and currentRank >= maxRank then
        return "Maxed", MUTED
    end
    if currentRank > 0 or (button and (button.isStart or button.available or
        (button.IsEnabled and button:IsEnabled()))) then
        return "Avail", MAGE_BLUE
    end
    return "Locked", CREAM
end

local function SearchResultCost(button)
    local costs = button and button.soulPointsCosts
    if type(costs) ~= "table" then
        return 0
    end
    local currentRank = ReadRankText(button)
    local nextRank = (currentRank or 0) + 1
    if nextRank > #costs then
        nextRank = #costs
    end
    return costs[nextRank] or costs[#costs] or 0
end

local function ShowSearchRowTooltip(row)
    local button = row and row.node
    if not button or not GameTooltip then
        return
    end

    local spellId = button.spells and button.spells[1]
    if not spellId then
        return
    end

    GameTooltip:SetOwner(row, "ANCHOR_LEFT")
    GameTooltip:SetHyperlink("spell:" .. tostring(spellId))

    local currentRank, maxRank = ReadRankText(button)
    local color = currentRank > 0 and "|cff00FF00" or "|cffFFFFFF"
    if not button.permanent then
        GameTooltip:AddLine("\n" .. color .. "Rank: " .. tostring(currentRank) .. "/" .. tostring(maxRank) .. "|r",
            1, 1, 1)
    end

    if currentRank < maxRank then
        local cost = SearchResultCost(button)
        if cost and cost > 0 then
            GameTooltip:AddLine("|cffFFD700Soul Ash Cost:|r " .. tostring(cost), 1, 1, 1)
        end
    end

    if button.permanent then
        GameTooltip:AddLine("|cffFF4444Permanent Skill|r", 1, 1, 1, true)
    elseif currentRank >= maxRank and currentRank > 0 then
        GameTooltip:AddLine("|cffAAAAAALeft-click to remove one rank|r", 1, 1, 1, true)
    else
        GameTooltip:AddLine("|cff00FF00Left-click to learn|r", 1, 1, 1, true)
    end

    GameTooltip:Show()
end

local function SortSearchResults(matches)
    if type(matches) ~= "table" then
        return {}
    end
    table.sort(matches, function(left, right)
        local leftCost = SearchResultCost(left)
        local rightCost = SearchResultCost(right)
        if leftCost ~= rightCost then
            return leftCost < rightCost
        end
        local leftName = overlay.GetSkillTreeNodeLabel(left) or ""
        local rightName = overlay.GetSkillTreeNodeLabel(right) or ""
        if leftName ~= rightName then
            return leftName < rightName
        end
        return (left and left.id or 0) < (right and right.id or 0)
    end)
    return matches
end

local function NodeIcon(button)
    local firstSpell = button and button.spells and button.spells[1]
    if firstSpell and GetSpellInfo then
        local _, _, icon = GetSpellInfo(firstSpell)
        return icon or "Interface\\Icons\\INV_Misc_QuestionMark"
    end
    return "Interface\\Icons\\INV_Misc_QuestionMark"
end

function overlay.GetSkillTreeVisibleBounds()
    local minX, maxX, minY, maxY

    for _, node in ipairs(overlay.GetSkillTreeNodeButtons()) do
        local width = node.GetWidth and node:GetWidth() or 28
        local height = node.GetHeight and node:GetHeight() or 28
        local x = node._ox or node._cx
        local y = node._oy or (node._cy and -node._cy)
        if x and y then
            local left = x
            local right = x + width
            local top = y
            local bottom = y - height
            minX = minX and math.min(minX, left) or left
            maxX = maxX and math.max(maxX, right) or right
            minY = minY and math.min(minY, bottom) or bottom
            maxY = maxY and math.max(maxY, top) or top
        end
    end

    return minX, maxX, minY, maxY
end

function overlay.ClampSkillTreeScroll(value, maximum)
    maximum = maximum or 0
    if value < 0 then
        return 0
    end
    if value > maximum then
        return maximum
    end
    return value
end

function overlay.FitAndCenterVisibleSkillTree()
    local scrollFrame = _G and _G.skillTreeScroll
    local canvas = _G and _G.skillTreeCanvas
    if not scrollFrame or not canvas or not canvas.SetScale or not scrollFrame.SetHorizontalScroll or
        not scrollFrame.SetVerticalScroll then
        return
    end

    if overlay.RestoreSkillTreeFullVisibility then
        overlay.RestoreSkillTreeFullVisibility()
    end

    -- Prefer the server's proven fit-and-center (this IS the PEEv1 code path).
    -- It uses the canonical _baseCanvasW + ComputeFitZoom + CenterScrollView, so
    -- the tree stays symmetric instead of piling empty space bottom-right. We
    -- then resync PEE's zoom tracking + base-size cache to the server's result
    -- so the wheel-zoom keeps working from the correct level.
    local serverSkillTree = _G and _G.ProjectEbonhold and _G.ProjectEbonhold.SkillTree
    local serverFit = serverSkillTree and serverSkillTree.FitAndCenterTree
    if type(serverFit) == "function" then
        local ok = pcall(serverFit)
        if ok then
            scrollFrame._peeSkillTreeZoomLevel = canvas.GetScale and canvas:GetScale() or nil
            canvas._peeBaseWidth = nil
            canvas._peeBaseHeight = nil
            return
        end
    end

    local minX, maxX, minY, maxY = overlay.GetSkillTreeVisibleBounds()
    if not minX then
        return
    end

    local treeWidth = maxX - minX
    local treeHeight = maxY - minY
    local viewWidth = scrollFrame.GetWidth and scrollFrame:GetWidth() or 0
    local viewHeight = scrollFrame.GetHeight and scrollFrame:GetHeight() or 0
    if treeWidth <= 0 or treeHeight <= 0 or viewWidth <= 0 or viewHeight <= 0 then
        return
    end

    local fitZoom = math.min((viewWidth * 0.84) / treeWidth, (viewHeight * 0.78) / treeHeight)
    fitZoom = math.max(MIN_ZOOM, math.min(MAX_ZOOM, fitZoom))

    local baseWidth = maxX + math.max(100, minX)
    local baseHeight = -minY + math.max(100, -maxY)
    canvas._peeBaseWidth = baseWidth
    canvas._peeBaseHeight = baseHeight
    canvas:SetScale(fitZoom)
    scrollFrame._peeSkillTreeZoomLevel = fitZoom
    canvas:SetSize(canvas._peeBaseWidth / fitZoom, canvas._peeBaseHeight / fitZoom)
    if scrollFrame.UpdateScrollChildRect then
        scrollFrame:UpdateScrollChildRect()
    end

    local horizontalRange = scrollFrame.GetHorizontalScrollRange and scrollFrame:GetHorizontalScrollRange() or 0
    local verticalRange = scrollFrame.GetVerticalScrollRange and scrollFrame:GetVerticalScrollRange() or 0
    local centerX = (minX + maxX) / 2
    local centerY = (minY + maxY) / 2
    scrollFrame:SetHorizontalScroll(
        overlay.ClampSkillTreeScroll(centerX - (viewWidth / (2 * fitZoom)), horizontalRange))
    scrollFrame:SetVerticalScroll(overlay.ClampSkillTreeScroll(-centerY - (viewHeight / (2 * fitZoom)), verticalRange))
end

function overlay.ScheduleSkillTreeFitAndCenter(force)
    if overlay._skillTreeFitAndCenterDone and not force then
        return
    end

    overlay._skillTreeFitAndCenterToken = (overlay._skillTreeFitAndCenterToken or 0) + 1
    local token = overlay._skillTreeFitAndCenterToken
    local function run()
        if token == overlay._skillTreeFitAndCenterToken then
            overlay.FitAndCenterVisibleSkillTree()
            overlay._skillTreeFitAndCenterDone = true
        end
    end

    if C_Timer and C_Timer.After then
        C_Timer.After(0.05, run)
    else
        run()
    end
end

function overlay.InstallSkillTreeOwnedFitHandlers(skillTreeFrame)
    if skillTreeFrame and skillTreeFrame.SetScript then
        skillTreeFrame:SetScript("OnSizeChanged", function(self)
            if self.IsShown and not self:IsShown() then
                return
            end
            if overlay._peeSkillTreeFrameInteracting then
                overlay._peeSkillTreeFitDirty = true
                return
            end
            if overlay.ScheduleSkillTreeFitAndCenter then
                overlay.ScheduleSkillTreeFitAndCenter(true)
            end
        end)
        skillTreeFrame._peeFitAndCenterHooks = true
    end

    local scrollFrame = _G and _G.skillTreeScroll
    if scrollFrame and scrollFrame.SetScript then
        scrollFrame:SetScript("OnShow", function()
            if overlay.ScheduleSkillTreeFitAndCenter then
                overlay.ScheduleSkillTreeFitAndCenter(true)
            end
        end)
        scrollFrame._peeFitAndCenterShowOwned = true
    end
end

local function NodeCanvasPosition(node)
    if not node then
        return nil, nil
    end

    local x = node._ox or node._cx
    local y = node._oy and -node._oy or node._cy
    return x, y
end

local function RegionIsShown(region)
    if not region then
        return false
    end
    if region.IsShown then
        return region:IsShown()
    end
    return region.shown ~= false
end

local function SkillTreeLineRegions(canvas)
    if not canvas or not canvas.GetRegions then
        return {}
    end
    if canvas._peeSkillTreeLineRegions then
        return canvas._peeSkillTreeLineRegions
    end

    local regions = {}
    for _, region in ipairs({ canvas:GetRegions() }) do
        if region and region.GetTexture and region:GetTexture() == LINE_TEXTURE then
            regions[#regions + 1] = region
        end
    end
    canvas._peeSkillTreeLineRegions = regions
    return regions
end

local function SetSkillTreeLineCulling(canvas, active)
    for _, region in ipairs(SkillTreeLineRegions(canvas)) do
        if active then
            if RegionIsShown(region) then
                region._peeSkillTreeLineFrozen = true
            end
        else
            region._peeSkillTreeLineFrozen = nil
            region._peeSkillTreeLineCulledByInteraction = nil
        end
    end
end

local function SetSkillTreeBorderFreeze(active, source)
    if overlay.SetSkillTreeNodeBorderFreeze then
        overlay.SetSkillTreeNodeBorderFreeze(active, source or "zoom")
        return
    end
    if not overlay.GetSkillTreeNodeButtons then
        return
    end

    for _, node in ipairs(overlay.GetSkillTreeNodeButtons()) do
        local borderFrame = node and node.borderFrame
        if borderFrame then
            if active then
                borderFrame._peeSkillTreeZoomFrozen = true
            else
                borderFrame._peeSkillTreeZoomFrozen = nil
            end
        end
    end
end

local function SetSkillTreeZoomVisualCulling(active)
    local canvas = _G and _G.skillTreeCanvas
    if canvas then
        SetSkillTreeLineCulling(canvas, active)
    end
    SetSkillTreeBorderFreeze(active, "zoom")
end

function overlay.InvalidateSkillTreeLineCache()
    local canvas = _G and _G.skillTreeCanvas
    if canvas then
        canvas._peeSkillTreeLineRegions = nil
    end
end

function overlay.SetSkillTreeViewportCulling(active)
    local scrollFrame = _G and _G.skillTreeScroll
    local canvas = _G and _G.skillTreeCanvas
    if not scrollFrame or not canvas or not overlay.GetSkillTreeNodeButtons then
        return
    end

    local nodes = overlay.GetSkillTreeNodeButtons()
    if not active then
        for _, node in ipairs(nodes) do
            if node._peeSkillTreeCulledByInteraction then
                if node.Show then
                    node:Show()
                end
                node._peeSkillTreeCulledByInteraction = nil
            end
        end
        SetSkillTreeLineCulling(canvas, false)
        return
    end

    local zoom = canvas.GetScale and canvas:GetScale() or 1
    if zoom <= 0 then
        zoom = 1
    end

    local viewLeft = scrollFrame.GetHorizontalScroll and scrollFrame:GetHorizontalScroll() or 0
    local viewTop = scrollFrame.GetVerticalScroll and scrollFrame:GetVerticalScroll() or 0
    local viewWidth = ((scrollFrame.GetWidth and scrollFrame:GetWidth()) or 0) / zoom
    local viewHeight = ((scrollFrame.GetHeight and scrollFrame:GetHeight()) or 0) / zoom
    if viewWidth <= 0 or viewHeight <= 0 then
        return
    end

    local viewRight = viewLeft + viewWidth
    local viewBottom = viewTop + viewHeight
    local pad = 40

    for _, node in ipairs(nodes) do
        local x, y = NodeCanvasPosition(node)
        if x and y and node.IsShown and node:IsShown() then
            local width = node.GetWidth and node:GetWidth() or 28
            local height = node.GetHeight and node:GetHeight() or 28
            if x + width < viewLeft - pad or x > viewRight + pad or
                y + height < viewTop - pad or y > viewBottom + pad then
                if node.Hide then
                    node:Hide()
                    node._peeSkillTreeCulledByInteraction = true
                end
            end
        end
    end
    SetSkillTreeLineCulling(canvas, true)
end

function overlay.RestoreSkillTreeFullVisibility()
    local canvas = _G and _G.skillTreeCanvas
    if overlay.GetSkillTreeNodeButtons then
        for _, node in ipairs(overlay.GetSkillTreeNodeButtons()) do
            if node._peeSkillTreeCulledByInteraction or node._culledByDrag then
                if node.Show then
                    node:Show()
                end
                node._peeSkillTreeCulledByInteraction = nil
                node._culledByDrag = nil
            end
        end
    end

    if canvas then
        for _, region in ipairs(SkillTreeLineRegions(canvas)) do
            if region.Show then
                region:Show()
            end
            region._peeSkillTreeLineCulledByInteraction = nil
            region._peeSkillTreeLineFrozen = nil
            region._culledByDrag = nil
        end
    end
end

function overlay.ScheduleSkillTreeViewportCullingRestore()
    overlay._skillTreeViewportCullingToken = (overlay._skillTreeViewportCullingToken or 0) + 1
    local token = overlay._skillTreeViewportCullingToken
    if C_Timer and C_Timer.After then
        C_Timer.After(0.15, function()
            if token == overlay._skillTreeViewportCullingToken then
                overlay.SetSkillTreeViewportCulling(false)
            end
        end)
    else
        overlay.SetSkillTreeViewportCulling(false)
    end
end

local function ClampZoom(value)
    if value < MIN_ZOOM then
        return MIN_ZOOM
    end
    if value > MAX_ZOOM then
        return MAX_ZOOM
    end
    return value
end

local function RememberCanvasBaseSize(canvas, zoom)
    if not canvas then
        return nil, nil
    end

    zoom = zoom or (canvas.GetScale and canvas:GetScale()) or 1
    if zoom <= 0 then
        zoom = 1
    end

    if not canvas._peeBaseWidth and canvas.GetWidth then
        canvas._peeBaseWidth = (canvas:GetWidth() or 0) * zoom
    end
    if not canvas._peeBaseHeight and canvas.GetHeight then
        canvas._peeBaseHeight = (canvas:GetHeight() or 0) * zoom
    end

    return canvas._peeBaseWidth, canvas._peeBaseHeight
end

local function UpdateSkillTreeZoomText(zoom)
    local skillTreeFrame = _G and _G.skillTreeFrame
    if not skillTreeFrame or not skillTreeFrame.zoomText then
        return
    end

    skillTreeFrame.zoomText:SetText(string.format("Zoom: %d%%", zoom * 100))
    skillTreeFrame._peeZoomTextToken = (skillTreeFrame._peeZoomTextToken or 0) + 1
    local token = skillTreeFrame._peeZoomTextToken
    if C_Timer and C_Timer.After then
        C_Timer.After(1, function()
            if skillTreeFrame._peeZoomTextToken == token and skillTreeFrame.zoomText then
                skillTreeFrame.zoomText:SetText("")
            end
        end)
    end
end

local function CaptureZoomAnchor(scrollFrame, canvas)
    local zoom = scrollFrame._peeSkillTreeZoomLevel or (canvas.GetScale and canvas:GetScale()) or 1
    if zoom <= 0 then
        zoom = 1
    end

    local cursorRelX = (scrollFrame.GetWidth and scrollFrame:GetWidth() or 0) / 2
    local cursorRelY = (scrollFrame.GetHeight and scrollFrame:GetHeight() or 0) / 2
    if GetCursorPosition and scrollFrame.GetEffectiveScale and scrollFrame.GetLeft and scrollFrame.GetTop then
        local cursorX, cursorY = GetCursorPosition()
        local scale = scrollFrame:GetEffectiveScale() or 1
        if scale <= 0 then
            scale = 1
        end
        cursorX = cursorX / scale
        cursorY = cursorY / scale
        cursorRelX = cursorX - (scrollFrame:GetLeft() or 0)
        cursorRelY = (scrollFrame:GetTop() or 0) - cursorY
    end

    local preScrollX = scrollFrame.GetHorizontalScroll and scrollFrame:GetHorizontalScroll() or 0
    local preScrollY = scrollFrame.GetVerticalScroll and scrollFrame:GetVerticalScroll() or 0
    return {
        cursorRelX = cursorRelX,
        cursorRelY = cursorRelY,
        preZoom = zoom,
        worldX = preScrollX + (cursorRelX / zoom),
        worldY = preScrollY + (cursorRelY / zoom),
    }
end

local function FlushSkillTreeZoom(scrollFrame)
    scrollFrame._peeSkillTreeZoomFlushScheduled = nil

    local canvas = _G and _G.skillTreeCanvas
    local anchor = scrollFrame._peeSkillTreePendingZoomAnchor
    local delta = scrollFrame._peeSkillTreePendingZoomDelta or 0
    scrollFrame._peeSkillTreePendingZoomAnchor = nil
    scrollFrame._peeSkillTreePendingZoomDelta = 0
    if not canvas or delta == 0 or not anchor or not canvas.SetScale then
        return
    end

    SetSkillTreeZoomVisualCulling(true)

    local newZoom = ClampZoom(anchor.preZoom + (delta * ZOOM_STEP))
    scrollFrame._peeSkillTreeZoomLevel = newZoom
    canvas:SetScale(newZoom)

    local baseWidth, baseHeight = RememberCanvasBaseSize(canvas, anchor.preZoom)
    if baseWidth and baseHeight and canvas.SetSize then
        canvas:SetSize(baseWidth / newZoom, baseHeight / newZoom)
    end
    if scrollFrame.UpdateScrollChildRect then
        scrollFrame:UpdateScrollChildRect()
    end

    local maxX = scrollFrame.GetHorizontalScrollRange and scrollFrame:GetHorizontalScrollRange() or 0
    local maxY = scrollFrame.GetVerticalScrollRange and scrollFrame:GetVerticalScrollRange() or 0
    local horizontal = overlay.ClampSkillTreeScroll(anchor.worldX - (anchor.cursorRelX / newZoom), maxX)
    local vertical = overlay.ClampSkillTreeScroll(anchor.worldY - (anchor.cursorRelY / newZoom), maxY)
    if scrollFrame.SetHorizontalScroll then
        scrollFrame:SetHorizontalScroll(horizontal)
    end
    if scrollFrame.SetVerticalScroll then
        scrollFrame:SetVerticalScroll(vertical)
    end

    UpdateSkillTreeZoomText(newZoom)

    scrollFrame._peeSkillTreeZoomSettleToken = (scrollFrame._peeSkillTreeZoomSettleToken or 0) + 1
    local token = scrollFrame._peeSkillTreeZoomSettleToken
    if C_Timer and C_Timer.After then
        C_Timer.After(0.15, function()
            if scrollFrame._peeSkillTreeZoomSettleToken == token then
                SetSkillTreeZoomVisualCulling(false)
            end
        end)
    else
        SetSkillTreeZoomVisualCulling(false)
    end
end

function overlay.EnsureSkillTreeInteractionCulling()
    local scrollFrame = _G and _G.skillTreeScroll
    if not scrollFrame or not scrollFrame.GetScript or not scrollFrame.SetScript then
        return
    end

    local currentWheel = scrollFrame:GetScript("OnMouseWheel")
    if currentWheel == scrollFrame._peeSkillTreeWheelCullingWrapper then
        return
    end

    if type(currentWheel) ~= "function" then
        return
    end

    scrollFrame._peeSkillTreeOriginalWheel = currentWheel
    scrollFrame._peeSkillTreeWheelCullingWrapper = function(self, delta)
        local canvas = _G and _G.skillTreeCanvas
        if not canvas then
            return
        end
        if not self._peeSkillTreePendingZoomAnchor then
            self._peeSkillTreePendingZoomAnchor = CaptureZoomAnchor(self, canvas)
        end
        self._peeSkillTreePendingZoomDelta = (self._peeSkillTreePendingZoomDelta or 0) + (delta or 0)
        if self._peeSkillTreeZoomFlushScheduled then
            return
        end

        self._peeSkillTreeZoomFlushScheduled = true
        if C_Timer and C_Timer.After then
            C_Timer.After(0, function()
                FlushSkillTreeZoom(self)
            end)
        else
            FlushSkillTreeZoom(self)
        end
    end
    scrollFrame:SetScript("OnMouseWheel", scrollFrame._peeSkillTreeWheelCullingWrapper)
end

local function EnsureRow(frame, index)
    frame.rows = frame.rows or {}
    if frame.rows[index] then
        return frame.rows[index]
    end

    local row = CreateFrame("Button", nil, frame.scrollChild or frame)
    SetSize(row, PANEL_WIDTH - 36, ROW_HEIGHT)
    row:SetPoint("LEFT", frame.scrollChild or frame, "LEFT", 4, 0)
    row:SetPoint("RIGHT", frame.scrollChild or frame, "RIGHT", -4, 0)
    if row.RegisterForClicks then
        row:RegisterForClicks("LeftButtonUp")
    end

    row.bg = row:CreateTexture(nil, "BACKGROUND")
    row.bg:SetAllPoints(row)
    row.bg:SetTexture("Interface\\Buttons\\WHITE8x8")
    row.bg:SetVertexColor(0.18, 0.18, 0.18, 0.45)
    row.bg:Hide()

    row.icon = row:CreateTexture(nil, "ARTWORK")
    SetSize(row.icon, 18, 18)
    row.icon:SetPoint("LEFT", row, "LEFT", 2, 0)
    if row.icon.SetTexCoord then
        row.icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
    end

    row.text = row:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    row.text:SetPoint("LEFT", row.icon, "RIGHT", 6, 0)
    SetFont(row.text, 11, CREAM, PANEL_WIDTH - 130, "LEFT")

    row.rank = row:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    row.rank:SetPoint("RIGHT", row, "RIGHT", -46, 0)
    SetFont(row.rank, 10, CREAM, 34, "RIGHT")

    row.badge = row:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    row.badge:SetPoint("RIGHT", row, "RIGHT", -2, 0)
    SetFont(row.badge, 10, MUTED, 42, "RIGHT")

    row:SetScript("OnEnter", function(self)
        if self.bg then
            self.bg:Show()
        end
        ShowSearchRowTooltip(self)
    end)
    row:SetScript("OnLeave", function(self)
        if self.bg then
            self.bg:Hide()
        end
        if GameTooltip then
            GameTooltip:Hide()
        end
    end)
    row:SetScript("OnClick", function(self)
        if overlay.ClickSkillTreeSearchNode then
            overlay.ClickSkillTreeSearchNode(self.node)
        else
            overlay.ClickSkillTreeNode(self.node)
        end
    end)

    frame.rows[index] = row
    return row
end

local function PositionPanel(frame, skillTreeFrame)
    if frame.ClearAllPoints then
        frame:ClearAllPoints()
    end
    frame:SetPoint("TOPLEFT", skillTreeFrame, "TOPRIGHT", PANEL_GAP, 0)
    frame:SetPoint("BOTTOMLEFT", skillTreeFrame, "BOTTOMRIGHT", PANEL_GAP, 0)
    if skillTreeFrame.GetHeight then
        SetSize(frame, PANEL_WIDTH, skillTreeFrame:GetHeight())
    else
        frame:SetWidth(PANEL_WIDTH)
    end
end

function overlay.EnsureSkillTreeSearchResults()
    local skillTreeFrame = _G and _G.skillTreeFrame
    if not skillTreeFrame or not CreateFrame then
        return nil
    end

    local frame = skillTreeFrame.peeSearchResults or _G.PEESkillTreeSearchResults
    if not frame then
        frame = CreateFrame("Frame", "PEESkillTreeSearchResults", skillTreeFrame)
        frame.rows = {}
        skillTreeFrame.peeSearchResults = frame
        _G.PEESkillTreeSearchResults = frame
    end

    PositionPanel(frame, skillTreeFrame)
    SetDarkBackdrop(frame, 4)

    if not frame.title then
        frame.title = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        frame.title:SetPoint("TOP", frame, "TOP", 0, -10)
        SetFont(frame.title, 14, GOLD, PANEL_WIDTH - 16, "CENTER")
        frame.title:SetText("Search Results")
    end

    if not frame.hint then
        frame.hint = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        frame.hint:SetPoint("TOP", frame.title, "BOTTOM", 0, -4)
        SetFont(frame.hint, 10, MUTED, PANEL_WIDTH - 16, "CENTER")
        frame.hint:SetText("click to add  |  click maxed to remove")
    end

    if not frame.scrollFrame then
        local scrollFrame = CreateFrame("ScrollFrame", "PEESkillTreeSearchResultsScroll", frame,
            "UIPanelScrollFrameTemplate")
        scrollFrame:SetPoint("TOPLEFT", frame, "TOPLEFT", PANEL_PADDING, -HEADER_HEIGHT)
        scrollFrame:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -26, 8)
        local scrollChild = CreateFrame("Frame", nil, scrollFrame)
        scrollChild:SetSize(PANEL_WIDTH - 36, 1)
        scrollFrame:SetScrollChild(scrollChild)
        frame.scrollFrame = scrollFrame
        frame.scrollChild = scrollChild
    end

    if not frame.emptyText then
        frame.emptyText = frame.scrollChild:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        frame.emptyText:SetPoint("TOP", frame.scrollChild, "TOP", 0, -20)
        SetFont(frame.emptyText, 11, MUTED, PANEL_WIDTH - 36, "CENTER")
        frame.emptyText:SetText("(no matches)")
        frame.emptyText:Hide()
    end

    frame._peeSearchLayout = {
        width = PANEL_WIDTH,
        rowHeight = ROW_HEIGHT,
        top = 0,
        right = PANEL_GAP,
        fullHeight = true,
    }
    frame:Hide()
    return frame
end

function overlay.RefreshSkillTreeSearchResults(matches, searchText)
    local frame = overlay.EnsureSkillTreeSearchResults()
    if not frame then
        return
    end

    searchText = tostring(searchText or ""):gsub("^%s+", ""):gsub("%s+$", "")
    if searchText == "" then
        frame:Hide()
        return
    end

    matches = SortSearchResults(matches)
    local matchCount = type(matches) == "table" and #matches or 0
    if matchCount == 0 then
        frame.emptyText:Show()
    else
        frame.emptyText:Hide()
    end

    for index, row in ipairs(frame.rows or {}) do
        if not matches or not matches[index] then
            row.node = nil
            row:Hide()
        end
    end

    for index = 1, matchCount do
        local button = matches[index]
        local row = EnsureRow(frame, index)
        local currentRank, maxRank = ReadRankText(button)
        local badge, badgeColor = BadgeForNode(button)
        row.node = button
        row:ClearAllPoints()
        row:SetPoint("TOP", frame.scrollChild, "TOP", 0, -((index - 1) * (ROW_HEIGHT + 2)))
        row.icon:SetTexture(NodeIcon(button))
        row.text:SetText(overlay.GetSkillTreeNodeLabel(button))
        row.rank:SetText(tostring(currentRank) .. "/" .. tostring(maxRank))
        row.badge:SetText(badge)
        if row.badge.SetTextColor then
            row.badge:SetTextColor(badgeColor[1], badgeColor[2], badgeColor[3], 1)
        end
        row:Show()
    end

    if frame.scrollChild and frame.scrollChild.SetHeight then
        frame.scrollChild:SetHeight(math.max(40, (matchCount * (ROW_HEIGHT + 2)) + 8))
    end
    frame:Show()
end

function overlay.ApplySkillTreeExtras()
    if overlay.isPTR or not overlay.enabled then
        return
    end
    overlay.ApplySkillTreeChrome()
    overlay.EnsureSkillTreeInteractionCulling()
    local searchBox = _G and _G.skillTreeSearchBox
    if searchBox and searchBox.GetText and searchBox:GetText() ~= "" then
        overlay.ApplySkillTreeSearchFilter(searchBox:GetText())
    end
end

function overlay.TryPrewarmSkillTree(attempt)
    if overlay.isPTR or not overlay.enabled then
        return
    end
    if overlay.UsesOwnedSoulAsheTree and overlay.UsesOwnedSoulAsheTree() then
        return
    end

    attempt = attempt or 1
    local skillTreeFrame = _G and _G.skillTreeFrame
    local onShow = skillTreeFrame and skillTreeFrame.GetScript and skillTreeFrame:GetScript("OnShow")
    if type(onShow) ~= "function" then
        if attempt < 12 and C_Timer and C_Timer.After then
            C_Timer.After(0.5, function()
                overlay.TryPrewarmSkillTree(attempt + 1)
            end)
        end
        return
    end

    if skillTreeFrame._peeSkillTreePrewarmDone then
        return
    end

    skillTreeFrame._peeSkillTreePrewarming = true
    local ok = pcall(onShow, skillTreeFrame)
    skillTreeFrame._peeSkillTreePrewarming = nil
    if not ok then
        return
    end

    skillTreeFrame._peeSkillTreePrewarmDone = true
    if overlay.ApplySkillTreeTheme then
        overlay.ApplySkillTreeTheme()
    end
end

function overlay.ScheduleSkillTreePrewarm()
    if overlay.isPTR or not overlay.enabled or overlay._skillTreePrewarmScheduled then
        return
    end
    if overlay.UsesOwnedSoulAsheTree and overlay.UsesOwnedSoulAsheTree() then
        return
    end

    overlay._skillTreePrewarmScheduled = true
    if C_Timer and C_Timer.After then
        C_Timer.After(1.0, function()
            overlay.TryPrewarmSkillTree(1)
        end)
    else
        overlay.TryPrewarmSkillTree(1)
    end
end

local function WrapOverlayFunction(name, afterFunc)
    local original = overlay[name]
    if type(original) ~= "function" or overlay["_peeSkillTreeExtrasWrapped" .. name] then
        return
    end
    overlay["_peeSkillTreeExtrasWrapped" .. name] = true
    overlay[name] = function(...)
        local first, second, third = original(...)
        afterFunc()
        return first, second, third
    end
end

local function Install()
    if overlay.UsesOwnedSoulAsheTree and overlay.UsesOwnedSoulAsheTree() then
        return
    end
    WrapOverlayFunction("ApplySkillTreeTheme", overlay.ApplySkillTreeExtras)
end

overlay.InstallSkillTreeExtras = Install

local eventFrame = CreateFrame and CreateFrame("Frame")
if eventFrame then
    eventFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
    eventFrame:SetScript("OnEvent", function()
        if overlay.UsesOwnedSoulAsheTree and overlay.UsesOwnedSoulAsheTree() then
            return
        end
        Install()
        overlay.ApplySkillTreeExtras()
        overlay.ScheduleSkillTreePrewarm()
    end)
end
if not (overlay.UsesOwnedSoulAsheTree and overlay.UsesOwnedSoulAsheTree()) then
    Install()
end
