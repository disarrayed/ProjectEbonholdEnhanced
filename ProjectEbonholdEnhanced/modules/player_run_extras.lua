local overlay = ProjectEbonholdEnhanced

if not overlay then
    return
end

local DARK = {0.039, 0.039, 0.039}
local BLACK = {0, 0, 0}
local HOVER_BLUE = {0.16, 0.88, 1.0}
local SNAP_GAP = 6
local SNAP_THRESHOLD = 25
local LOCKED_ECHO_SIZE = 40
local LOCKED_ECHO_SPACING = 6
local LOCKED_ECHO_MIN_SPACING = 4
local LOCKED_ECHO_TOP_OFFSET = -8
local GRANTED_ECHO_SIZE = 32
local GRANTED_ECHO_SPACING_X = 12
local GRANTED_ECHO_SPACING_Y = 14
local GRANTED_ECHO_COLUMNS = 6
local ECHOES_TOP_PAD = 15
local ECHOES_TITLE_HEIGHT = 20
local ECHOES_TITLE_GAP = 10
local ECHOES_CONTENT_SEARCH_GAP = 12
local ECHOES_SEARCH_HEIGHT = 24
local ECHOES_SEARCH_BOTTOM_PAD = 10
local ECHOES_MIN_HEIGHT = 160
local QUALITY_COLORS = {
    [0] = {1, 1, 1},
    [1] = {0.1, 1.0, 0.1},
    [2] = {0.0, 0.4, 1.0},
    [3] = {0.6, 0.2, 1.0},
    [4] = {1.0, 0.5, 0.0}
}

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

local function SetDarkBackdrop(frame, edgeSize)
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
        frame:SetBackdropColor(DARK[1], DARK[2], DARK[3], Opacity())
    end
    if frame.SetBackdropBorderColor then
        frame:SetBackdropBorderColor(BLACK[1], BLACK[2], BLACK[3], 1)
    end
end

local function FrameWidth(frame, fallback)
    local width = frame and frame.GetWidth and frame:GetWidth()
    if type(width) == "number" and width > 1 then
        return width
    end
    return fallback
end

local function ResizeRegion(region, width, height)
    if region and region.SetSize then
        region:SetSize(width, height or width)
    end
end

local function ResizeEchoArtwork(frame, size, locked)
    if not frame then
        return
    end

    SetSize(frame, size, size)
    ResizeRegion(frame._iconBase, size * 1.2)
    ResizeRegion(frame._icon, size * 0.8)
    ResizeRegion(frame._border, 110 * size / 32, 110 * size / 32)

    if locked then
        ResizeRegion(frame._swirl, size * 2.0)
        ResizeRegion(frame._rotatingTex, size * 1.9)
        if frame.GetRegions then
            local regions = { frame:GetRegions() }
            for _, region in ipairs(regions) do
                if region ~= frame._iconBase and region ~= frame._icon and region ~= frame._border and
                    region ~= frame._swirl and region ~= frame._rotatingTex then
                    ResizeRegion(region, size * 1.6)
                end
            end
        end
    end
end

local function ActiveFrames(frames)
    local active = {}
    for _, frame in ipairs(frames or {}) do
        if frame and ((not frame.IsShown) or frame:IsShown()) then
            active[#active + 1] = frame
        end
    end
    return active
end

local function RowMetrics(width, columns, iconSize, spacing)
    local totalWidth = (columns * iconSize) + ((columns - 1) * spacing)
    if totalWidth > width and columns > 1 then
        spacing = math.max(4, math.floor((width - (columns * iconSize)) / (columns - 1)))
        totalWidth = (columns * iconSize) + ((columns - 1) * spacing)
    end
    return math.max(0, math.floor((width - totalWidth) / 2)), spacing, totalWidth
end

local function GrantedEchoRowMetrics(width)
    return RowMetrics(width, GRANTED_ECHO_COLUMNS, GRANTED_ECHO_SIZE, GRANTED_ECHO_SPACING_X)
end

local function LockedEchoRowMetrics(width, slotCount)
    local _, _, targetWidth = GrantedEchoRowMetrics(width)
    local spacing = LOCKED_ECHO_SPACING
    if slotCount > 1 then
        spacing = math.floor((targetWidth - (slotCount * LOCKED_ECHO_SIZE)) / (slotCount - 1))
        spacing = math.max(LOCKED_ECHO_MIN_SPACING, spacing)
    end

    local totalWidth = (slotCount * LOCKED_ECHO_SIZE) + ((slotCount - 1) * spacing)
    if totalWidth > width and slotCount > 1 then
        spacing = math.max(0, math.floor((width - (slotCount * LOCKED_ECHO_SIZE)) / (slotCount - 1)))
        totalWidth = (slotCount * LOCKED_ECHO_SIZE) + ((slotCount - 1) * spacing)
    end

    return math.max(0, math.floor((width - totalWidth) / 2)), spacing
end

local function LayoutPermanentEchoSlots(empowermentFrame)
    local slots = ActiveFrames(empowermentFrame and empowermentFrame.permanentSlots)
    if #slots == 0 then
        return 0
    end

    local parent = empowermentFrame.permanentSlotsFrame or empowermentFrame.gridContainer or empowermentFrame
    local width = FrameWidth(parent, FrameWidth(empowermentFrame, 240) - 30)
    local startX, spacing = LockedEchoRowMetrics(width, #slots)
    local startY = LOCKED_ECHO_TOP_OFFSET

    for index, slotFrame in ipairs(slots) do
        if slotFrame.SetParent then
            slotFrame:SetParent(parent)
        end
        ResizeEchoArtwork(slotFrame, LOCKED_ECHO_SIZE, true)
        if slotFrame.ClearAllPoints then
            slotFrame:ClearAllPoints()
        end
        if slotFrame.SetPoint then
            slotFrame:SetPoint("TOPLEFT", parent, "TOPLEFT",
                startX + ((index - 1) * (LOCKED_ECHO_SIZE + spacing)),
                startY)
        end
    end

    if empowermentFrame.permanentSlotsFrame and empowermentFrame.permanentSlotsFrame.SetHeight then
        empowermentFrame.permanentSlotsFrame:SetHeight(LOCKED_ECHO_SIZE + 10)
    end

    return LOCKED_ECHO_SIZE + 18, math.abs(startY) + LOCKED_ECHO_SIZE
end

local function LayoutGrantedEchoIcons(empowermentFrame, lockedOffset)
    local icons = ActiveFrames(empowermentFrame and empowermentFrame.perkIcons)
    local gridContainer = empowermentFrame and empowermentFrame.gridContainer
    if #icons == 0 or not gridContainer then
        return 0
    end

    local width = FrameWidth(gridContainer, FrameWidth(empowermentFrame, 240) - 48)
    local columns = GRANTED_ECHO_COLUMNS
    local startX, spacingX = GrantedEchoRowMetrics(width)
    local startY = empowermentFrame.permanentSlotsFrame and -8 or -(lockedOffset or 0)
    if startY == 0 then
        startY = -8
    end

    for index, iconFrame in ipairs(icons) do
        local row = math.floor((index - 1) / columns)
        local column = (index - 1) % columns
        ResizeEchoArtwork(iconFrame, GRANTED_ECHO_SIZE, false)
        if iconFrame.ClearAllPoints then
            iconFrame:ClearAllPoints()
        end
        if iconFrame.SetPoint then
            iconFrame:SetPoint("TOPLEFT", gridContainer, "TOPLEFT",
                startX + (column * (GRANTED_ECHO_SIZE + spacingX)),
                startY - (row * (GRANTED_ECHO_SIZE + GRANTED_ECHO_SPACING_Y)))
        end
    end

    if gridContainer.SetHeight then
        local rows = math.ceil(#icons / columns)
        local contentBottom = math.abs(startY) + ((rows - 1) * (GRANTED_ECHO_SIZE + GRANTED_ECHO_SPACING_Y)) +
            GRANTED_ECHO_SIZE
        gridContainer:SetHeight(math.max(20, contentBottom + ECHOES_CONTENT_SEARCH_GAP))
        return contentBottom
    end

    local rows = math.ceil(#icons / columns)
    return math.abs(startY) + ((rows - 1) * (GRANTED_ECHO_SIZE + GRANTED_ECHO_SPACING_Y)) + GRANTED_ECHO_SIZE
end

local function ResizeEmpowermentFrameToContent(empowermentFrame, contentBottom)
    if not empowermentFrame or not empowermentFrame.SetHeight then
        return
    end

    local height = ECHOES_TOP_PAD + ECHOES_TITLE_HEIGHT + ECHOES_TITLE_GAP + math.max(0, contentBottom or 0) +
        ECHOES_CONTENT_SEARCH_GAP + ECHOES_SEARCH_HEIGHT + ECHOES_SEARCH_BOTTOM_PAD
    empowermentFrame:SetHeight(math.max(ECHOES_MIN_HEIGHT, height))
end

local function EnsureDB()
    ProjectEbonholdEnhancedDB = ProjectEbonholdEnhancedDB or {}
    ProjectEbonholdEnhancedDB.playerRunFrame = ProjectEbonholdEnhancedDB.playerRunFrame or {}
    ProjectEbonholdEnhancedDB.empowermentFrame = ProjectEbonholdEnhancedDB.empowermentFrame or {}
    return ProjectEbonholdEnhancedDB
end

local function SaveFramePosition(frame, key)
    if not frame or not frame.GetLeft or not frame.GetTop then
        return
    end
    local left = frame:GetLeft()
    local top = frame:GetTop()
    if type(left) ~= "number" or type(top) ~= "number" then
        return
    end
    local db = EnsureDB()
    db[key].position = { left = left, top = top }
end

local function RestoreFramePosition(frame, key)
    if not frame or frame._peePositionRestored or not UIParent then
        return
    end
    local store = EnsureDB()[key]
    local position = store and store.position
    if type(position) ~= "table" or type(position.left) ~= "number" or type(position.top) ~= "number" then
        frame._peePositionRestored = true
        return
    end
    if frame.ClearAllPoints then
        frame:ClearAllPoints()
    end
    if frame.SetPoint then
        frame:SetPoint("TOPLEFT", UIParent, "BOTTOMLEFT", position.left, position.top)
    end
    frame._peePositionRestored = true
end

local function IsShown(frame)
    return frame and ((not frame.IsShown) or frame:IsShown())
end

local function GetSnapSide(mainFrame, empowermentFrame)
    if not IsShown(mainFrame) or not empowermentFrame then
        return nil
    end
    if not mainFrame.GetLeft or not mainFrame.GetRight or not empowermentFrame.GetLeft or
        not empowermentFrame.GetRight then
        return nil
    end
    local mainLeft = mainFrame:GetLeft()
    local mainRight = mainFrame:GetRight()
    local echoesLeft = empowermentFrame:GetLeft()
    local echoesRight = empowermentFrame:GetRight()
    if not mainLeft or not mainRight or not echoesLeft or not echoesRight then
        return nil
    end
    if math.abs(echoesRight - mainLeft) <= SNAP_THRESHOLD then
        return "left"
    end
    if math.abs(echoesLeft - mainRight) <= SNAP_THRESHOLD then
        return "right"
    end
    return nil
end

local function RepositionEchoesWithMain(mainFrame, empowermentFrame, sideOverride)
    if not mainFrame or not empowermentFrame or not UIParent then
        return
    end
    local side = sideOverride or GetSnapSide(mainFrame, empowermentFrame)
    if not side or not mainFrame.GetLeft or not mainFrame.GetRight or not empowermentFrame.GetTop then
        return
    end
    local mainLeft = mainFrame:GetLeft()
    local mainRight = mainFrame:GetRight()
    local echoesTop = empowermentFrame:GetTop()
    if not mainLeft or not mainRight or not echoesTop then
        return
    end
    if empowermentFrame.ClearAllPoints then
        empowermentFrame:ClearAllPoints()
    end
    if side == "left" and empowermentFrame.SetPoint then
        empowermentFrame:SetPoint("TOPRIGHT", UIParent, "BOTTOMLEFT", mainLeft - SNAP_GAP, echoesTop)
    elseif side == "right" and empowermentFrame.SetPoint then
        empowermentFrame:SetPoint("TOPLEFT", UIParent, "BOTTOMLEFT", mainRight + SNAP_GAP, echoesTop)
    end
    SaveFramePosition(empowermentFrame, "empowermentFrame")
end

local function TrySnapFrames(mainFrame, empowermentFrame, draggedFrame)
    if not IsShown(mainFrame) or not empowermentFrame or not UIParent then
        return
    end
    if not mainFrame.GetLeft or not mainFrame.GetRight or not empowermentFrame.GetLeft or
        not empowermentFrame.GetRight then
        return
    end
    local mainLeft = mainFrame:GetLeft()
    local mainRight = mainFrame:GetRight()
    local echoesLeft = empowermentFrame:GetLeft()
    local echoesRight = empowermentFrame:GetRight()
    if not mainLeft or not mainRight or not echoesLeft or not echoesRight then
        return
    end

    if draggedFrame == mainFrame then
        local mainTop = mainFrame.GetTop and mainFrame:GetTop()
        if not mainTop then
            return
        end
        if math.abs(mainLeft - echoesRight) <= SNAP_THRESHOLD then
            mainFrame:ClearAllPoints()
            mainFrame:SetPoint("TOPLEFT", UIParent, "BOTTOMLEFT", echoesRight + SNAP_GAP, mainTop)
            SaveFramePosition(mainFrame, "playerRunFrame")
        elseif math.abs(mainRight - echoesLeft) <= SNAP_THRESHOLD then
            mainFrame:ClearAllPoints()
            mainFrame:SetPoint("TOPRIGHT", UIParent, "BOTTOMLEFT", echoesLeft - SNAP_GAP, mainTop)
            SaveFramePosition(mainFrame, "playerRunFrame")
        end
    else
        local echoesTop = empowermentFrame.GetTop and empowermentFrame:GetTop()
        if not echoesTop then
            return
        end
        if math.abs(echoesRight - mainLeft) <= SNAP_THRESHOLD then
            empowermentFrame:ClearAllPoints()
            empowermentFrame:SetPoint("TOPRIGHT", UIParent, "BOTTOMLEFT", mainLeft - SNAP_GAP, echoesTop)
            SaveFramePosition(empowermentFrame, "empowermentFrame")
        elseif math.abs(echoesLeft - mainRight) <= SNAP_THRESHOLD then
            empowermentFrame:ClearAllPoints()
            empowermentFrame:SetPoint("TOPLEFT", UIParent, "BOTTOMLEFT", mainRight + SNAP_GAP, echoesTop)
            SaveFramePosition(empowermentFrame, "empowermentFrame")
        end
    end
end

local function PrepareMovableFrame(frame)
    if not frame then
        return
    end
    if frame.SetMovable then frame:SetMovable(true) end
    if frame.EnableMouse then frame:EnableMouse(true) end
    if frame.SetClampedToScreen then frame:SetClampedToScreen(true) end
    if frame.RegisterForDrag then frame:RegisterForDrag("LeftButton") end
end

function overlay.ApplyPlayerRunDocking()
    if overlay.isPTR or not overlay.enabled then
        return
    end

    local mainFrame = _G and _G.ProjectEbonholdPlayerRunFrame
    local empowermentFrame = _G and _G.ProjectEbonholdEmpowermentFrame
    if not mainFrame or not empowermentFrame then
        return
    end

    PrepareMovableFrame(mainFrame)
    PrepareMovableFrame(empowermentFrame)
    RestoreFramePosition(mainFrame, "playerRunFrame")
    RestoreFramePosition(empowermentFrame, "empowermentFrame")

    if not mainFrame._peeDockingWrapped and mainFrame.SetScript then
        mainFrame._peeDockingWrapped = true
        mainFrame:SetScript("OnDragStart", function(self)
            self._peeEchoesSnapSide = GetSnapSide(mainFrame, empowermentFrame)
            self._peeOriginalOnUpdateDuringDrag = self.GetScript and self:GetScript("OnUpdate")
            if self._peeEchoesSnapSide then
                self:SetScript("OnUpdate", function(frame, elapsed)
                    if frame._peeOriginalOnUpdateDuringDrag then
                        frame._peeOriginalOnUpdateDuringDrag(frame, elapsed)
                    end
                    RepositionEchoesWithMain(mainFrame, empowermentFrame, frame._peeEchoesSnapSide)
                end)
            end
            if self.StartMoving then
                self:StartMoving()
            end
        end)
        mainFrame:SetScript("OnDragStop", function(self)
            if self.SetScript and self._peeOriginalOnUpdateDuringDrag then
                self:SetScript("OnUpdate", self._peeOriginalOnUpdateDuringDrag)
            elseif self.SetScript and self._peeEchoesSnapSide then
                self:SetScript("OnUpdate", nil)
            end
            if self.StopMovingOrSizing then
                self:StopMovingOrSizing()
            end
            TrySnapFrames(mainFrame, empowermentFrame, mainFrame)
            SaveFramePosition(mainFrame, "playerRunFrame")
            if self._peeEchoesSnapSide then
                RepositionEchoesWithMain(mainFrame, empowermentFrame, self._peeEchoesSnapSide)
            end
            self._peeEchoesSnapSide = nil
            self._peeOriginalOnUpdateDuringDrag = nil
        end)
    end

    if not empowermentFrame._peeDockingWrapped and empowermentFrame.SetScript then
        empowermentFrame._peeDockingWrapped = true
        empowermentFrame:SetScript("OnDragStart", function(self)
            if self.StartMoving then
                self:StartMoving()
            end
        end)
        empowermentFrame:SetScript("OnDragStop", function(self)
            if self.StopMovingOrSizing then
                self:StopMovingOrSizing()
            end
            TrySnapFrames(mainFrame, empowermentFrame, empowermentFrame)
            SaveFramePosition(empowermentFrame, "empowermentFrame")
        end)
    end
end

local function FindSearchBox(empowermentFrame)
    if not empowermentFrame then
        return nil, nil
    end
    if empowermentFrame.searchBox then
        return empowermentFrame.searchFrame or empowermentFrame.searchBox.parent, empowermentFrame.searchBox
    end
    local searchFrame = empowermentFrame.searchFrame
    if not searchFrame then
        return nil, nil
    end
    if searchFrame.editBox then
        return searchFrame, searchFrame.editBox
    end
    if searchFrame.GetChildren then
        local children = { searchFrame:GetChildren() }
        for _, child in ipairs(children) do
            if child and child.GetText and child.SetText then
                return searchFrame, child
            end
        end
    end
    return searchFrame, nil
end

local function UpdateSearchAffordances(searchFrame, searchBox)
    if not searchFrame or not searchBox then
        return
    end
    local text = searchBox.GetText and searchBox:GetText() or ""
    local hasText = text ~= nil and text ~= ""
    if searchFrame.peeSearchPlaceholder then
        if hasText then
            searchFrame.peeSearchPlaceholder:Hide()
        else
            searchFrame.peeSearchPlaceholder:Show()
        end
    end
    if searchFrame.peeSearchClearButton then
        if hasText then
            searchFrame.peeSearchClearButton:Show()
        else
            searchFrame.peeSearchClearButton:Hide()
        end
    end
end

function overlay.EnsureEmpowermentSearchAffordances(empowermentFrame)
    local searchFrame, searchBox = FindSearchBox(empowermentFrame)
    if not searchFrame or not searchBox or not CreateFrame then
        return
    end

    SetDarkBackdrop(searchFrame, 2)
    if searchBox.SetTextInsets then
        searchBox:SetTextInsets(4, 22, 0, 0)
    end

    if not searchFrame.peeSearchPlaceholder and searchFrame.CreateFontString then
        local placeholder = searchFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        placeholder:SetPoint("LEFT", searchFrame, "LEFT", 6, 0)
        placeholder:SetText("Search echoes...")
        if placeholder.SetTextColor then
            placeholder:SetTextColor(0.4, 0.4, 0.4, 1)
        end
        searchFrame.peeSearchPlaceholder = placeholder
        empowermentFrame.searchPlaceholder = placeholder
    end

    if not searchFrame.peeSearchClearButton then
        local clearButton = CreateFrame("Button", nil, searchFrame)
        SetSize(clearButton, 16, 16)
        clearButton:SetPoint("RIGHT", searchFrame, "RIGHT", -3, 0)
        local texture = clearButton:CreateTexture(nil, "ARTWORK")
        texture:SetAllPoints(clearButton)
        texture:SetTexture("Interface\\Buttons\\UI-StopButton")
        texture:SetVertexColor(0.6, 0.6, 0.6, 1)
        clearButton.texture = texture
        clearButton:SetScript("OnEnter", function()
            texture:SetVertexColor(1, 0.4, 0.4, 1)
        end)
        clearButton:SetScript("OnLeave", function()
            texture:SetVertexColor(0.6, 0.6, 0.6, 1)
        end)
        clearButton:SetScript("OnClick", function()
            if searchBox.SetText then
                searchBox:SetText("")
            end
            if searchBox.ClearFocus then
                searchBox:ClearFocus()
            end
            local onTextChanged = searchBox.GetScript and searchBox:GetScript("OnTextChanged")
            if onTextChanged then
                onTextChanged(searchBox)
            else
                UpdateSearchAffordances(searchFrame, searchBox)
            end
        end)
        searchFrame.peeSearchClearButton = clearButton
        empowermentFrame.searchClearButton = clearButton
    end

    if not searchBox._peeSearchAffordancesWrapped and searchBox.SetScript then
        local originalChanged = searchBox.GetScript and searchBox:GetScript("OnTextChanged")
        local originalEscape = searchBox.GetScript and searchBox:GetScript("OnEscapePressed")
        local originalFocus = searchBox.GetScript and searchBox:GetScript("OnEditFocusGained")
        local originalBlur = searchBox.GetScript and searchBox:GetScript("OnEditFocusLost")

        searchBox:SetScript("OnTextChanged", function(self, ...)
            if originalChanged then
                originalChanged(self, ...)
            end
            UpdateSearchAffordances(searchFrame, self)
            overlay.ApplyEmpowermentLayoutExtras(empowermentFrame)
        end)
        searchBox:SetScript("OnEscapePressed", function(self, ...)
            if self.SetText then
                self:SetText("")
            end
            if self.ClearFocus then
                self:ClearFocus()
            end
            if originalEscape then
                originalEscape(self, ...)
            end
            UpdateSearchAffordances(searchFrame, self)
        end)
        searchBox:SetScript("OnEditFocusGained", function(self, ...)
            if searchFrame.SetBackdropBorderColor then
                searchFrame:SetBackdropBorderColor(HOVER_BLUE[1], HOVER_BLUE[2], HOVER_BLUE[3], 1)
            end
            if originalFocus then
                originalFocus(self, ...)
            end
        end)
        searchBox:SetScript("OnEditFocusLost", function(self, ...)
            if searchFrame.SetBackdropBorderColor then
                searchFrame:SetBackdropBorderColor(BLACK[1], BLACK[2], BLACK[3], 1)
            end
            if originalBlur then
                originalBlur(self, ...)
            end
        end)
        searchBox._peeSearchAffordancesWrapped = true
    end

    UpdateSearchAffordances(searchFrame, searchBox)
end

local function Texts()
    local project = _G and _G.ProjectEbonhold
    local texts = project and project.UITexts
    if texts and texts.tooltips then
        return texts
    end
    return {
        tooltips = {
            reaper = {
                title = "Reaper",
                spawned = function(areaName) return "The Reaper has spawned in " .. tostring(areaName) .. "." end,
                notSpawned = "The Reaper has not spawned yet.",
            },
            survival = {
                title = "Survival",
                playerRezs = "Player resurrections: ",
                freeRezs = "Free resurrections: ",
                classRezs = "Class resurrections: ",
                cheatDeath = "Cheat deaths: ",
                nextRezCost = "Next resurrection cost: ",
                nextCost = " Soul Ash",
            },
            intensity = {
                title = function(intensity) return "Intensity: " .. tostring(intensity or 0) end,
                description1 = "Higher intensity adds danger and rewards.",
            },
            soulPoints = {
                title = function(points) return "Soul Ash: " .. tostring(points or 0) end,
                line = "Soul Ash can be spent in the Skill Tree.",
            },
            multiplier = {
                title = function(multiplier)
                    return "Soul Ash Bonus: +" .. tostring(math.floor((multiplier or 0) * 100 + 0.5)) .. "%"
                end,
                line = "Bonus applied to Soul Ash gained during this run.",
            },
        },
    }
end

local function TooltipLine(text, red, green, blue, wrap)
    if GameTooltip and GameTooltip.AddLine then
        GameTooltip:AddLine(text, red, green, blue, wrap)
    end
end

local function EnsureCountBadge(frame, key)
    if not frame or not CreateFrame then
        return nil
    end
    if frame[key] then
        local existing = frame[key]
        if not existing._txt and existing.CreateFontString then
            local text = existing:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
            text:SetSize(26, 26)
            text:SetPoint("CENTER", existing, "CENTER", 0, 0)
            text:SetJustifyH("CENTER")
            text:SetJustifyV("MIDDLE")
            if text.SetNonSpaceWrap then
                text:SetNonSpaceWrap(false)
            end
            text:SetFont("Fonts\\FRIZQT__.TTF", 10, "OUTLINE")
            existing._txt = text
        end
        return frame[key]
    end

    local parent = frame.GetParent and frame:GetParent() or frame
    local badge = CreateFrame("Frame", nil, parent)
    SetSize(badge, 26, 26)
    if badge.EnableMouse then
        badge:EnableMouse(false)
    end

    local background = badge:CreateTexture(nil, "BACKGROUND")
    background:SetAllPoints(badge)
    background:SetTexture("Interface\\AddOns\\ProjectEbonhold\\assets\\background_count")
    badge._bg = background

    local text = badge:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    text:SetSize(26, 26)
    text:SetPoint("CENTER", badge, "CENTER", 0, 0)
    text:SetJustifyH("CENTER")
    text:SetJustifyV("MIDDLE")
    if text.SetNonSpaceWrap then
        text:SetNonSpaceWrap(false)
    end
    text:SetFont("Fonts\\FRIZQT__.TTF", 10, "OUTLINE")
    badge._txt = text
    badge:Hide()

    frame[key] = badge
    return badge
end

local function AddQualityCount(counts, quality, stacks)
    quality = quality or 0
    stacks = stacks or 1
    counts[quality] = (counts[quality] or 0) + stacks
end

local function CountInstancesForPerkData(perkData)
    local counts = {}
    if not perkData then
        return counts
    end

    if type(perkData.instances) == "table" then
        for _, instance in ipairs(perkData.instances) do
            AddQualityCount(counts, instance.quality, instance.stack)
        end
    elseif perkData.spellId and overlay.CountOwnedPerkInstances then
        local _, qualityCounts = overlay.CountOwnedPerkInstances(perkData.spellId)
        if type(qualityCounts) == "table" then
            for quality, count in pairs(qualityCounts) do
                counts[quality] = count
            end
        end
    end

    return counts
end

local function HighestCountAndColor(counts)
    for quality = 4, 0, -1 do
        if counts[quality] and counts[quality] > 0 then
            local color = QUALITY_COLORS[quality] or QUALITY_COLORS[0]
            return counts[quality], color
        end
    end
    return nil, nil
end

local function ApplyBadgeToFrame(frame, counts, key)
    local count, color = HighestCountAndColor(counts)
    local badge = EnsureCountBadge(frame, key)
    if not badge then
        return
    end
    if count then
        if badge.SetParent and frame.GetParent then
            badge:SetParent(frame:GetParent() or frame)
        end
        if badge.ClearAllPoints then
            badge:ClearAllPoints()
        end
        badge:SetPoint("TOP", frame, "TOP", 0, 10)
        if badge.SetFrameLevel and frame.GetFrameLevel then
            badge:SetFrameLevel((frame:GetFrameLevel() or 1) + 5)
        end
        badge._txt:SetText(tostring(count))
        badge._txt:SetTextColor(color[1], color[2], color[3], 1)
        badge:Show()
    else
        badge:Hide()
        if badge.ClearAllPoints then
            badge:ClearAllPoints()
        end
    end
end

local function ShowHardmodeTooltip(button)
    if not GameTooltip then
        return
    end
    GameTooltip:SetOwner(button, "ANCHOR_TOP")
    local playerRunFrame = _G and _G.ProjectEbonholdPlayerRunFrame
    local difficulty = overlay.GetPlayerRunHardmodeDifficulty and
        overlay.GetPlayerRunHardmodeDifficulty(playerRunFrame, false)
    if difficulty then
        if difficulty > 1 then
            local tierText = overlay.GetHardcoreTierText and
                overlay.GetHardcoreTierText(difficulty - 1) or tostring(difficulty - 1)
            GameTooltip:SetText("Hardcore Mode " .. tierText, 1, 0.3, 0.3)
            TooltipLine("Increased difficulty and rewards.", 1, 1, 1, true)
        else
            GameTooltip:SetText("Normal Mode", 0.7, 0.7, 0.7)
            TooltipLine("No hardcore modifiers active.", 1, 1, 1, true)
        end
    else
        GameTooltip:SetText("Normal Mode", 0.7, 0.7, 0.7)
    end
    GameTooltip:Show()
end

local function ToggleHardmodeFrame()
    local now = GetTime and GetTime() or nil
    if now and overlay._peeLastCompactHardmodeToggleAt and
        now - overlay._peeLastCompactHardmodeToggleAt < 0.08 then
        return
    end
    overlay._peeLastCompactHardmodeToggleAt = now

    if overlay.ToggleHardmodeFrameFromPEE and overlay.ToggleHardmodeFrameFromPEE() then
        return
    end

    local project = _G and _G.ProjectEbonhold
    if project and type(project.ToggleHardmodeFrame) == "function" then
        project.ToggleHardmodeFrame()
        return
    end
    if project and type(project.ToggleTormentFrame) == "function" then
        project.ToggleTormentFrame()
        return
    end

    local playerRunFrame = _G and _G.ProjectEbonholdPlayerRunFrame
    local hardmodeButton = playerRunFrame and playerRunFrame.hardmodeButton
    if not hardmodeButton and playerRunFrame and playerRunFrame.hardmodeTierText and
        playerRunFrame.hardmodeTierText.GetParent then
        hardmodeButton = playerRunFrame.hardmodeTierText:GetParent()
    end
    local hardmodeClick = hardmodeButton and hardmodeButton.GetScript and hardmodeButton:GetScript("OnClick")
    if type(hardmodeClick) == "function" and hardmodeButton ~= overlay._peeCompactHardmodeClickSource then
        overlay._peeCompactHardmodeClickSource = hardmodeButton
        hardmodeClick(hardmodeButton, "LeftButton")
        overlay._peeCompactHardmodeClickSource = nil
        return
    end

    local hardmodeFrame = _G and _G.HardmodeFrame
    if hardmodeFrame then
        if hardmodeFrame.IsShown and hardmodeFrame:IsShown() then
            hardmodeFrame:Hide()
        else
            hardmodeFrame:Show()
            if project and project.HardmodeUI and project.HardmodeUI.Refresh then
                project.HardmodeUI.Refresh()
            end
        end
    end
end

local function ToggleHardmodeFrameOnMouseUp(_, mouseButton)
    if mouseButton == "LeftButton" then
        ToggleHardmodeFrame()
    end
end

local function GetCompactHardmodeButton(compactFrame)
    if compactFrame and compactFrame.hardmodeButton then
        return compactFrame.hardmodeButton
    end
    if compactFrame and compactFrame.hardmodeText and compactFrame.hardmodeText.GetParent then
        return compactFrame.hardmodeText:GetParent()
    end
    return nil
end

local function EnsureCompactHardmodeClickOverlay(compactFrame)
    if not compactFrame or not CreateFrame then
        return nil
    end
    if not compactFrame.peeHardmodeClickOverlay then
        local button = CreateFrame("Button", "PEECompactHardmodeClickOverlay", compactFrame)
        compactFrame.peeHardmodeClickOverlay = button
    end

    local button = compactFrame.peeHardmodeClickOverlay
    SetSize(button, 100, 20)
    if button.ClearAllPoints then
        button:ClearAllPoints()
    end
    if compactFrame.hardmodeText and button.SetPoint then
        button:SetPoint("LEFT", compactFrame.hardmodeText, "LEFT", -18, 0)
    elseif button.SetPoint then
        button:SetPoint("TOPLEFT", compactFrame, "TOPLEFT", 6, -6)
    end
    if button.EnableMouse then
        button:EnableMouse(true)
    end
    if button.RegisterForClicks then
        button:RegisterForClicks("LeftButtonUp")
    end
    if button.SetFrameLevel and compactFrame.GetFrameLevel then
        button:SetFrameLevel(compactFrame:GetFrameLevel() + 60)
    end
    button:SetScript("OnClick", ToggleHardmodeFrame)
    button:SetScript("OnMouseUp", ToggleHardmodeFrameOnMouseUp)
    button:SetScript("OnEnter", ShowHardmodeTooltip)
    button:SetScript("OnLeave", function()
        if GameTooltip then GameTooltip:Hide() end
    end)
    if button.Show then
        button:Show()
    end
    return button
end

local function ShowReaperTooltip(button)
    if not GameTooltip then
        return
    end
    local project = _G and _G.ProjectEbonhold
    local service = project and project.PlayerRunService
    local texts = Texts()
    local data = service and service.GetIntensityData and service.GetIntensityData() or {}
    local areaName = data.areaNameReaper or data.currentArea or "0"
    GameTooltip:SetOwner(button, "ANCHOR_LEFT")
    GameTooltip:SetText(texts.tooltips.reaper.title, 1, 0.5, 0.5)
    TooltipLine(" ")
    if areaName and areaName ~= "0" then
        TooltipLine(texts.tooltips.reaper.spawned(areaName), 1, 1, 1, true)
    else
        TooltipLine(texts.tooltips.reaper.notSpawned, 0.7, 0.7, 0.7, true)
    end
    GameTooltip:Show()
end

local function ShowSurvivalTooltip(button, playerRunFrame)
    if not GameTooltip then
        return
    end
    local texts = Texts()
    local data = playerRunFrame and playerRunFrame.currentData or {}
    local playerLevel = UnitLevel and UnitLevel("player") or 1
    GameTooltip:SetOwner(button, "ANCHOR_LEFT")
    GameTooltip:SetText(texts.tooltips.survival.title, 1, 1, 0.5)
    TooltipLine(" ")
    TooltipLine(texts.tooltips.survival.playerRezs .. tostring(data.countCanAcceptedRezs or 0), 1, 1, 1)
    TooltipLine(texts.tooltips.survival.freeRezs .. tostring(data.countCanSelfRezs or 0), 1, 1, 1)
    TooltipLine(texts.tooltips.survival.classRezs .. tostring(data.countCanClassRezs or 0), 1, 1, 1)
    TooltipLine(texts.tooltips.survival.cheatDeath .. tostring(data.countCanAvoidFatalAttacks or 0), 1, 1, 1)
    TooltipLine(
        texts.tooltips.survival.nextRezCost ..
        tostring(math.max(playerLevel, data.costNextReset or 0)) ..
        texts.tooltips.survival.nextCost,
        1,
        1,
        1
    )
    GameTooltip:Show()
end

local function IntensityLevelIndex(project, intensity)
    local constants = project and project.Constants or {}
    if constants.INTENSITY_LEVEL_5 and intensity >= constants.INTENSITY_LEVEL_5 then return 5 end
    if constants.INTENSITY_LEVEL_4 and intensity >= constants.INTENSITY_LEVEL_4 then return 4 end
    if constants.INTENSITY_LEVEL_3 and intensity >= constants.INTENSITY_LEVEL_3 then return 3 end
    if constants.INTENSITY_LEVEL_2 and intensity >= constants.INTENSITY_LEVEL_2 then return 2 end
    if constants.INTENSITY_LEVEL_1 and intensity >= constants.INTENSITY_LEVEL_1 then return 1 end
    return 0
end

local function ShowIntensityTooltip(button)
    if not GameTooltip then
        return
    end
    local project = _G and _G.ProjectEbonhold
    local service = project and project.PlayerRunService
    local data = service and service.GetIntensityData and service.GetIntensityData() or {}
    local intensity = data.intensity or 0
    local effects = project and project.IntensityEffects or {}
    local effect = effects[IntensityLevelIndex(project, intensity)]
    local texts = Texts()
    GameTooltip:SetOwner(button, "ANCHOR_LEFT")
    if effect then
        GameTooltip:SetText(effect.name, 1, 0.2, 0.2)
        TooltipLine(" ")
        TooltipLine(effect.description, 1, 1, 1, true)
    else
        GameTooltip:SetText(texts.tooltips.intensity.title(intensity), 1, 1, 1)
        TooltipLine(" ")
        TooltipLine(texts.tooltips.intensity.description1, 0.8, 0.8, 0.8, true)
    end
    GameTooltip:Show()
end

local function ShowSoulPointsTooltip(button, playerRunFrame)
    if not GameTooltip then
        return
    end
    local texts = Texts()
    local data = playerRunFrame and playerRunFrame.currentData or {}
    local points = playerRunFrame and (playerRunFrame.currentSoulPoints or data.soulPoints) or 0
    GameTooltip:SetOwner(button, "ANCHOR_LEFT")
    GameTooltip:SetText(texts.tooltips.soulPoints.title(points or 0), 1, 1, 1)
    TooltipLine(" ")
    TooltipLine(texts.tooltips.soulPoints.line, 0.8, 0.8, 0.8, true)
    GameTooltip:Show()
end

local function ShowMultiplierTooltip(button, playerRunFrame)
    if not GameTooltip then
        return
    end
    local texts = Texts()
    local data = playerRunFrame and playerRunFrame.currentData or {}
    local multiplier = playerRunFrame and (playerRunFrame.currentMultiplier or data.soulPointsMultiplier) or 0
    GameTooltip:SetOwner(button, "ANCHOR_LEFT")
    GameTooltip:SetText(texts.tooltips.multiplier.title(multiplier or 0), 0, 1, 0)
    TooltipLine(" ")
    TooltipLine(texts.tooltips.multiplier.line, 0.8, 0.8, 0.8, true)
    GameTooltip:Show()
end

local function EnsureTooltipHitbox(compactFrame, key, width, height)
    if compactFrame[key] then
        return compactFrame[key]
    end
    if not CreateFrame then
        return nil
    end
    local button = CreateFrame("Button", nil, compactFrame)
    SetSize(button, width, height)
    if button.SetFrameLevel and compactFrame.GetFrameLevel then
        button:SetFrameLevel(compactFrame:GetFrameLevel() + 20)
    end
    compactFrame[key] = button
    return button
end

function overlay.ApplyCompactTooltipExtras(playerRunFrame)
    local compactFrame = playerRunFrame and playerRunFrame.compactFrame
    if not compactFrame then
        return
    end

    local hardmodeButton = GetCompactHardmodeButton(compactFrame)
    if hardmodeButton and hardmodeButton.SetScript then
        compactFrame.hardmodeButton = hardmodeButton
        SetSize(hardmodeButton, 92, 18)
        if hardmodeButton.EnableMouse then
            hardmodeButton:EnableMouse(true)
        end
        if hardmodeButton.RegisterForClicks then
            hardmodeButton:RegisterForClicks("LeftButtonUp")
        end
        if hardmodeButton.SetFrameLevel and compactFrame.GetFrameLevel then
            hardmodeButton:SetFrameLevel(compactFrame:GetFrameLevel() + 25)
        end
        hardmodeButton:SetScript("OnClick", ToggleHardmodeFrame)
        hardmodeButton:SetScript("OnMouseUp", ToggleHardmodeFrameOnMouseUp)
        hardmodeButton:SetScript("OnEnter", ShowHardmodeTooltip)
        hardmodeButton:SetScript("OnLeave", function()
            if GameTooltip then GameTooltip:Hide() end
        end)
    end
    EnsureCompactHardmodeClickOverlay(compactFrame)

    if compactFrame.restoreButton then
        local reaperHitbox = EnsureTooltipHitbox(compactFrame, "peeReaperHitbox", 22, 22)
        if reaperHitbox then
            reaperHitbox:ClearAllPoints()
            reaperHitbox:SetPoint("TOPRIGHT", compactFrame.restoreButton, "TOPLEFT", -1, 0)
            reaperHitbox:SetScript("OnEnter", ShowReaperTooltip)
            reaperHitbox:SetScript("OnLeave", function()
                if GameTooltip then GameTooltip:Hide() end
            end)
        end

        local survivalHitbox = EnsureTooltipHitbox(compactFrame, "peeSurvivalHitbox", 22, 22)
        if survivalHitbox then
            survivalHitbox:ClearAllPoints()
            survivalHitbox:SetPoint("TOPRIGHT", reaperHitbox or compactFrame.restoreButton, "TOPLEFT", -4, 0)
            survivalHitbox:SetScript("OnEnter", function(self)
                ShowSurvivalTooltip(self, playerRunFrame)
            end)
            survivalHitbox:SetScript("OnLeave", function()
                if GameTooltip then GameTooltip:Hide() end
            end)
        end
    end

    if compactFrame.ashCount then
        local ashHitbox = EnsureTooltipHitbox(compactFrame, "peeSoulAshHitbox", 80, 18)
        if ashHitbox then
            ashHitbox:ClearAllPoints()
            ashHitbox:SetPoint("LEFT", compactFrame.ashCount, "LEFT", -18, 0)
            ashHitbox:SetPoint("RIGHT", compactFrame.ashCount, "RIGHT", 6, 0)
            ashHitbox:SetScript("OnEnter", function(self)
                ShowSoulPointsTooltip(self, playerRunFrame)
            end)
            ashHitbox:SetScript("OnLeave", function()
                if GameTooltip then GameTooltip:Hide() end
            end)
        end
    end

    if compactFrame.multiplier then
        local multiplierHitbox = EnsureTooltipHitbox(compactFrame, "peeMultiplierHitbox", 70, 18)
        if multiplierHitbox then
            multiplierHitbox:ClearAllPoints()
            multiplierHitbox:SetPoint("LEFT", compactFrame.multiplier, "LEFT", -4, 0)
            multiplierHitbox:SetPoint("RIGHT", compactFrame.multiplier, "RIGHT", 4, 0)
            multiplierHitbox:SetScript("OnEnter", function(self)
                ShowMultiplierTooltip(self, playerRunFrame)
            end)
            multiplierHitbox:SetScript("OnLeave", function()
                if GameTooltip then GameTooltip:Hide() end
            end)
        end
    end

    if compactFrame.intensityText then
        local intensityHitbox = EnsureTooltipHitbox(compactFrame, "peeIntensityHitbox", 120, 18)
        if intensityHitbox then
            intensityHitbox:ClearAllPoints()
            intensityHitbox:SetPoint("TOPLEFT", compactFrame.intensityText, "TOPLEFT", -3, 2)
            intensityHitbox:SetPoint("BOTTOMRIGHT", compactFrame.intensityText, "BOTTOMRIGHT", 3, -2)
            intensityHitbox:SetScript("OnEnter", ShowIntensityTooltip)
            intensityHitbox:SetScript("OnLeave", function()
                if GameTooltip then GameTooltip:Hide() end
            end)
        end
    end
end

function overlay.ApplyEmpowermentBadgeExtras(empowermentFrame)
    if not empowermentFrame then
        return
    end

    for _, iconFrame in ipairs(empowermentFrame.perkIcons or {}) do
        ApplyBadgeToFrame(iconFrame, CountInstancesForPerkData(iconFrame._perkData), "_badge")
    end

    for _, slotFrame in ipairs(empowermentFrame.permanentSlots or {}) do
        local counts = CountInstancesForPerkData(slotFrame.lockedPerkData)
        ApplyBadgeToFrame(slotFrame, counts, "_lockedBadge")
    end
end

function overlay.ApplyEmpowermentLayoutExtras(empowermentFrame)
    if not empowermentFrame then
        return
    end

    local lockedOffset, lockedBottom = LayoutPermanentEchoSlots(empowermentFrame)
    local grantedBottom = LayoutGrantedEchoIcons(empowermentFrame, lockedOffset)
    ResizeEmpowermentFrameToContent(empowermentFrame, math.max(lockedBottom or 0, grantedBottom or 0))
end

function overlay.ApplyPlayerRunExtras()
    if overlay.isPTR or not overlay.enabled then
        return
    end
    local mainFrame = _G and _G.ProjectEbonholdPlayerRunFrame
    local empowermentFrame = _G and _G.ProjectEbonholdEmpowermentFrame
    if mainFrame then
        overlay.ApplyCompactTooltipExtras(mainFrame)
    end
    if mainFrame and empowermentFrame then
        overlay.ApplyPlayerRunDocking()
    end
    if empowermentFrame then
        overlay.EnsureEmpowermentSearchAffordances(empowermentFrame)
        overlay.ApplyEmpowermentLayoutExtras(empowermentFrame)
        overlay.ApplyEmpowermentBadgeExtras(empowermentFrame)
    end
end

local function WrapOverlayFunction(name, afterFunc)
    local original = overlay[name]
    if type(original) ~= "function" or overlay["_peePlayerRunExtrasWrapped" .. name] then
        return
    end
    overlay["_peePlayerRunExtrasWrapped" .. name] = true
    overlay[name] = function(...)
        local first, second, third = original(...)
        afterFunc()
        return first, second, third
    end
end

local function Install()
    WrapOverlayFunction("ApplyPlayerRunTheme", overlay.ApplyPlayerRunExtras)
end

overlay.InstallPlayerRunExtras = Install

local eventFrame = CreateFrame and CreateFrame("Frame")
if eventFrame then
    eventFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
    eventFrame:SetScript("OnEvent", function()
        Install()
        overlay.ApplyPlayerRunExtras()
    end)
end
Install()
