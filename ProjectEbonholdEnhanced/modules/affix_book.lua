local overlay = ProjectEbonholdEnhanced

if not overlay then
    return
end

local MAGE_BLUE = {0.247, 0.78, 0.922}
local HOVER_BLUE = {0.16, 0.88, 1.0}
local HOVER_BLUE_BACKDROP = {0.02, 0.22, 0.36}
local DARK = {0.039, 0.039, 0.039}
local BLACK = {0, 0, 0}
local WHITE = {1, 1, 1}
local CREAM = {1, 0.92, 0.82}
local MUTED = {0.72, 0.72, 0.72}
local RED_BACKDROP = {0.32, 0.1, 0.1}
local RED_HOVER = {0.48, 0.16, 0.14}
local RED_HOVER_BORDER = {1.0, 0.28, 0.24}
local AFFIX_PURPLE = {0.69, 0.28, 0.97}
local LEGENDARY = {1.0, 0.5, 0.0}
local SIDE_PANEL_WIDTH = 260
local SIDE_PANEL_HEIGHT = 430
local ROW_HEIGHT = 20
local VISIBLE_ROWS = 9
local LIST_PAD = 4
local TIER_ICON_SIZE = 40
local TIER_GAP = 8
local TIER_ROMANS = {"I", "II", "III", "IV", "V"}
local ROMAN_TO_TIER = {i = 1, ii = 2, iii = 3, iv = 4, v = 5}
local TIER_COLORS = {
    {1, 1, 1},
    {0.1, 1.0, 0.1},
    {0.0, 0.4, 1.0},
    {0.6, 0.2, 1.0},
    {1.0, 0.5, 0.0}
}

local AFFIX_ALIASES = {
    ["cold"] = "precision",
    ["enduring flesh"] = "ironhide",
    ["feral grace"] = "swift footwork",
    ["keen strikes"] = "keen strike",
    ["shield block"] = "block",
    ["spirit surge"] = "inner light",
}

local UNIQUE_AFFIXES = {
    ["spell mastery"] = true,
    ["temporal flux"] = true,
}

local UNAVAILABLE_AFFIX_TIERS = {
    ["spell mastery"] = {
        [5] = "Spell Mastery V is not available in-game.",
    },
}

local function BackdropOpacity()
    if overlay.GetBackdropOpacity then
        return overlay.GetBackdropOpacity()
    end

    return 0.8
end

local function ScaledFontSize(size)
    if overlay.ScaledFontSize then
        return overlay.ScaledFontSize(size)
    end

    return size
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

local function SetBackdrop(frame, edgeSize, inset, backdropColor, borderColor, alpha)
    if not frame or not frame.SetBackdrop then
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
    if frame.SetBackdropColor then
        frame:SetBackdropColor(backdropColor[1], backdropColor[2], backdropColor[3], alpha or BackdropOpacity())
    end
    if frame.SetBackdropBorderColor then
        frame:SetBackdropBorderColor(borderColor[1], borderColor[2], borderColor[3], 1)
    end
end

local function SetFont(fontString, size, color, width, justify)
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
    if fontString.SetJustifyH then
        fontString:SetJustifyH(justify or "LEFT")
    end
    if fontString.SetTextColor then
        fontString:SetTextColor(color[1], color[2], color[3], 1)
    end
end

local function SetButtonBackdrop(button, backdrop, border)
    if button.SetBackdropColor then
        button:SetBackdropColor(backdrop[1], backdrop[2], backdrop[3], BackdropOpacity())
    end
    if button.SetBackdropBorderColor then
        button:SetBackdropBorderColor(border[1], border[2], border[3], 1)
    end
end

local function SkinRedButton(button)
    if not button then
        return
    end

    SetBackdrop(button, 2, 1, RED_BACKDROP, BLACK)
    SetButtonBackdrop(button, RED_BACKDROP, BLACK)
    SetFont(button.text or (button.GetFontString and button:GetFontString()), 11, WHITE, nil, "CENTER")
    if button.SetScript then
        button:SetScript("OnEnter", function(self)
            if self.IsEnabled and not self:IsEnabled() then
                return
            end
            SetButtonBackdrop(self, RED_HOVER, RED_HOVER_BORDER)
        end)
        button:SetScript("OnLeave", function(self)
            SetButtonBackdrop(self, RED_BACKDROP, BLACK)
        end)
    end
end

local function EnsureDB()
    ProjectEbonholdEnhancedDB = ProjectEbonholdEnhancedDB or {}
    ProjectEbonholdEnhancedDB.affixFilters = ProjectEbonholdEnhancedDB.affixFilters or {
        armor = true,
        hands = true,
        learned = true
    }
    return ProjectEbonholdEnhancedDB.affixFilters
end

local function Normalize(text)
    text = tostring(text or ""):lower()
    text = text:gsub("|c%x%x%x%x%x%x%x%x", ""):gsub("|r", "")
    text = text:gsub("^%s+", ""):gsub("%s+$", "")
    return text
end

local function ParseAffixName(name)
    local normalized = Normalize(name)
    local base, roman = normalized:match("^(.-)%s+([iv]+)$")
    if base and ROMAN_TO_TIER[roman] then
        return base:gsub("%s+$", ""), ROMAN_TO_TIER[roman]
    end
    return normalized, 1
end

local function PrettyName(baseName)
    return tostring(baseName or ""):gsub("(%a)([%w']*)", function(first, rest)
        return first:upper() .. rest
    end)
end

local function SearchNames(name)
    local normalized = Normalize(name)
    local base, tier = normalized:match("^(.-)(%s+[iv]+)$")
    local names = { normalized }
    base = base or normalized
    tier = tier or ""
    if AFFIX_ALIASES[base] then
        names[#names + 1] = AFFIX_ALIASES[base] .. tier
    end
    return names
end

local function CountEquippedAffixes(affixes)
    local counts = {}
    local itemsByAffix = {}
    if not affixes or #affixes == 0 or not GetInventoryItemLink or not GetItemInfo or not GameTooltip then
        return counts, itemsByAffix
    end

    local affixList = {}
    for _, affix in ipairs(affixes) do
        if affix.id then
            counts[affix.id] = 0
            itemsByAffix[affix.id] = {}
            if affix.name then
                affixList[#affixList + 1] = {
                    id = affix.id,
                    names = SearchNames(affix.name)
                }
            end
        end
    end
    table.sort(affixList, function(a, b)
        return #(a.names[1] or "") > #(b.names[1] or "")
    end)

    if #affixList == 0 then
        return counts, itemsByAffix
    end

    local tooltip = overlay.affixBookScanTooltip
    if not tooltip and CreateFrame then
        tooltip = CreateFrame("GameTooltip", "PEEAffixBookScanTooltip", UIParent, "GameTooltipTemplate")
        tooltip:SetOwner(UIParent, "ANCHOR_NONE")
        overlay.affixBookScanTooltip = tooltip
    end
    if not tooltip then
        return counts, itemsByAffix
    end

    local slotNames = {
        [1] = "Head", [2] = "Neck", [3] = "Shoulders", [4] = "Shirt",
        [5] = "Chest", [6] = "Waist", [7] = "Legs", [8] = "Feet",
        [9] = "Wrists", [10] = "Hands", [11] = "Ring 1", [12] = "Ring 2",
        [13] = "Trinket 1", [14] = "Trinket 2", [15] = "Back",
        [16] = "Main Hand", [17] = "Off Hand", [18] = "Ranged", [19] = "Tabard"
    }

    for slot = 1, 19 do
        local link = GetInventoryItemLink("player", slot)
        if link then
            local itemName = GetItemInfo(link) or ("Slot " .. slot)
            tooltip:ClearLines()
            if tooltip.SetInventoryItem then
                tooltip:SetInventoryItem("player", slot)
            end
            local matched = {}
            local lineCount = tooltip.NumLines and tooltip:NumLines() or 0
            for lineIndex = 1, lineCount do
                local line = _G["PEEAffixBookScanTooltipTextLeft" .. lineIndex]
                local text = line and line.GetText and line:GetText()
                if text then
                    local lower = text:lower()
                    for _, entry in ipairs(affixList) do
                        if not matched[entry.id] then
                            for _, searchName in ipairs(entry.names) do
                                local startPos, endPos = lower:find(searchName, 1, true)
                                if startPos then
                                    local before = startPos > 1 and lower:sub(startPos - 1, startPos - 1) or ""
                                    local after = lower:sub(endPos + 1, endPos + 1)
                                    if (before == "" or not before:match("%w")) and
                                        (after == "" or not after:match("%w")) then
                                        counts[entry.id] = (counts[entry.id] or 0) + 1
                                        matched[entry.id] = true
                                        local slotLabel = slotNames[slot] or ("Slot " .. slot)
                                        itemsByAffix[entry.id][#itemsByAffix[entry.id] + 1] =
                                            slotLabel .. ": " .. itemName
                                        break
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
    end

    return counts, itemsByAffix
end

local function ColorCode(color)
    return string.format("|cff%02x%02x%02x", color[1] * 255, color[2] * 255, color[3] * 255)
end

local function FormatCopper(copper)
    if GetCoinTextureString then
        return GetCoinTextureString(copper or 0, 10)
    end

    return tostring(copper or 0)
end

local function GetSpellDescription(spellId)
    if not spellId or not GameTooltip or not CreateFrame then
        return ""
    end

    if not overlay.affixBookScanTooltip then
        overlay.affixBookScanTooltip = CreateFrame("GameTooltip", "PEEAffixBookScanTooltip", UIParent,
            "GameTooltipTemplate")
        if overlay.affixBookScanTooltip.SetOwner then
            overlay.affixBookScanTooltip:SetOwner(UIParent, "ANCHOR_NONE")
        end
    end

    local tooltip = overlay.affixBookScanTooltip
    if not tooltip or not tooltip.ClearLines then
        return ""
    end

    tooltip:ClearLines()
    if tooltip.SetHyperlink then
        tooltip:SetHyperlink("spell:" .. spellId)
    elseif tooltip.SetSpellByID then
        tooltip:SetSpellByID(spellId)
    end

    local lines = {}
    local count = tooltip.NumLines and tooltip:NumLines() or 0
    for index = 2, count do
        local line = _G["PEEAffixBookScanTooltipTextLeft" .. index]
        local text = line and line.GetText and line:GetText()
        if text and text ~= "" then
            lines[#lines + 1] = text
        end
    end
    return table.concat(lines, "\n")
end

local function BuildFamilies()
    local service = _G.ExtractionService
    local affixes = service and service.learnedAffixes or {}
    local families = {}
    local order = {}

    for _, affix in ipairs(affixes) do
        local baseName, tier = ParseAffixName(affix.name or ("Affix " .. tostring(affix.id)))
        if not families[baseName] then
            families[baseName] = {
                baseName = baseName,
                prettyName = PrettyName(baseName),
                tiers = {},
                weaponOnly = false,
                isUnique = UNIQUE_AFFIXES[baseName] == true
            }
            order[#order + 1] = baseName
        end
        families[baseName].tiers[tier] = affix
        if affix.weaponOnly then
            families[baseName].weaponOnly = true
        end
    end

    local equippedCounts, equippedItems = CountEquippedAffixes(affixes)
    for _, affix in ipairs(affixes) do
        if affix.id and affix.appliedCount ~= nil then
            equippedCounts[affix.id] = affix.appliedCount
        end
    end

    for _, family in pairs(families) do
        local equippedTotal = 0
        for tier = 1, #TIER_ROMANS do
            local affix = family.tiers[tier]
            if affix and affix.id then
                equippedTotal = equippedTotal + (equippedCounts[affix.id] or 0)
            end
        end
        family.equippedCount = equippedTotal
    end

    table.sort(order)
    return families, order, equippedCounts, equippedItems
end

local function FamilyLearned(family)
    for tier = 1, #TIER_ROMANS do
        local affix = family.tiers[tier]
        if affix and affix.learned then
            return true
        end
    end
    return false
end

local function FamilyMatches(family, needle)
    if needle == "" then
        return true
    end
    if Normalize(family.prettyName):find(needle, 1, true) or Normalize(family.baseName):find(needle, 1, true) then
        return true
    end
    for tier = 1, #TIER_ROMANS do
        local affix = family.tiers[tier]
        if affix and affix.name then
            for _, name in ipairs(SearchNames(affix.name)) do
                if name:find(needle, 1, true) then
                    return true
                end
            end
        end
    end
    return false
end

local function DisplayName(family)
    local color = FamilyLearned(family) and WHITE or MUTED
    if FamilyLearned(family) and family.isUnique then
        color = LEGENDARY
    end

    local text = ColorCode(color) .. family.prettyName .. "|r"
    if family.weaponOnly then
        text = text .. (FamilyLearned(family) and " |cffb048f8(H)|r" or " |cff999999(H)|r")
    end
    if (family.equippedCount or 0) > 0 then
        text = text .. " |cff00ff00(" .. tostring(family.equippedCount) .. ")|r"
    end
    return text
end

local function FamilyTierMatches(family, tier, needle, exactOnly)
    if not family or needle == "" then
        return false
    end

    local tierText = Normalize(TIER_ROMANS[tier] or tostring(tier))
    local prettyTierName = Normalize((family.prettyName or family.baseName or "") .. " " .. tierText)
    local baseTierName = Normalize((family.baseName or "") .. " " .. tierText)
    if exactOnly then
        return prettyTierName == needle or baseTierName == needle
    end

    if prettyTierName:find(needle, 1, true) or baseTierName:find(needle, 1, true) then
        return true
    end

    local affix = family.tiers and family.tiers[tier]
    if affix and affix.name then
        for _, name in ipairs(SearchNames(affix.name)) do
            if exactOnly then
                if name == needle then
                    return true
                end
            elseif name:find(needle, 1, true) then
                return true
            end
        end
    end

    return false
end

local function FamilyNameMatches(family, needle, exactOnly)
    if not family or needle == "" then
        return false
    end

    local prettyName = Normalize(family.prettyName)
    local baseName = Normalize(family.baseName)
    if exactOnly then
        return prettyName == needle or baseName == needle
    end

    return prettyName:find(needle, 1, true) ~= nil or baseName:find(needle, 1, true) ~= nil
end

local function FindSearchSelection(panel, exactOnly)
    local needle = Normalize(panel.searchBox and panel.searchBox.GetText and panel.searchBox:GetText())
    if needle == "" then
        return nil, nil
    end

    for _, baseName in ipairs(panel.visibleOrder or {}) do
        local family = panel.families and panel.families[baseName]
        if FamilyNameMatches(family, needle, exactOnly) then
            return baseName, nil
        end
        for tier = 1, #TIER_ROMANS do
            if FamilyTierMatches(family, tier, needle, exactOnly) then
                return baseName, tier
            end
        end
    end

    return nil, nil
end

local function ScrollFamilyIntoView(panel, baseName)
    if not panel or not baseName then
        return
    end

    for index, name in ipairs(panel.visibleOrder or {}) do
        if name == baseName then
            local offset = math.max(0, index - 1)
            panel.scrollOffset = math.min(offset, panel.maxScrollOffset or offset)
            return
        end
    end
end

local function CreateCheckbox(panel, label, key, xOffset)
    local check = CreateFrame("CheckButton", nil, panel, "UICheckButtonTemplate")
    SetFrameSize(check, 18, 18)
    check:SetPoint("TOPLEFT", panel, "TOPLEFT", 12 + xOffset, -30)
    check:SetChecked(EnsureDB()[key])
    check.text = check:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    check.text:SetPoint("LEFT", check, "RIGHT", 2, 0)
    check.text:SetText(label)
    SetFont(check.text, 10, CREAM)
    check:SetScript("OnClick", function(self)
        EnsureDB()[key] = self:GetChecked() == 1 or self:GetChecked() == true
        overlay.RefreshEnhancedAffixBook(panel)
    end)
    return check
end

local function CreateTierButton(parent, tier)
    local button = CreateFrame("Button", nil, parent)
    SetFrameSize(button, TIER_ICON_SIZE, TIER_ICON_SIZE)
    button.tier = tier
    SetBackdrop(button, 2, 1, {0.06, 0.06, 0.06}, BLACK, 1)

    button.icon = button:CreateTexture(nil, "ARTWORK")
    button.icon:SetPoint("TOPLEFT", button, "TOPLEFT", 3, -3)
    button.icon:SetPoint("BOTTOMRIGHT", button, "BOTTOMRIGHT", -3, 3)
    if button.icon.SetTexCoord then
        button.icon:SetTexCoord(0.07, 0.93, 0.07, 0.93)
    end

    button.lockOverlay = button:CreateTexture(nil, "OVERLAY")
    button.lockOverlay:SetAllPoints(button)
    button.lockOverlay:SetTexture("Interface\\Buttons\\WHITE8x8")
    button.lockOverlay:SetVertexColor(0, 0, 0, 0.65)
    button.lockOverlay:Hide()

    button.lockText = button:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    button.lockText:SetPoint("CENTER", button, "CENTER", 0, 0)
    button.lockText:SetText("X")
    SetFont(button.lockText, 14, MUTED, nil, "CENTER")
    button.lockText:Hide()

    button.tierLabel = button:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    button.tierLabel:SetPoint("BOTTOM", button, "BOTTOM", 0, -14)
    button.tierLabel:SetText(TIER_ROMANS[tier])
    SetFont(button.tierLabel, 10, TIER_COLORS[tier], nil, "CENTER")
    return button
end

local function CreatePanel()
    local parent = _G.EbonholdExtractionFrame or UIParent
    local panel = CreateFrame("Frame", "PEEEnhancedAffixBookPanel", parent)
    SetFrameSize(panel, SIDE_PANEL_WIDTH, SIDE_PANEL_HEIGHT)
    panel:SetPoint("TOPLEFT", parent, "TOPRIGHT", -2, 0)
    panel:SetFrameStrata("HIGH")
    if panel.SetToplevel then
        panel:SetToplevel(true)
    end
    if panel.SetFrameLevel and parent.GetFrameLevel then
        panel:SetFrameLevel((parent:GetFrameLevel() or 1) + 20)
    end
    panel:EnableMouse(true)
    panel:SetMovable(true)
    panel:RegisterForDrag("LeftButton")
    panel:SetScript("OnDragStart", panel.StartMoving)
    panel:SetScript("OnDragStop", panel.StopMovingOrSizing)
    SetBackdrop(panel, 4, 4, DARK, BLACK, BackdropOpacity())

    panel.title = panel:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    panel.title:SetPoint("TOP", panel, "TOP", 0, -9)
    panel.title:SetText("Affix Book")
    SetFont(panel.title, 12, MAGE_BLUE, nil, "CENTER")

    panel.cbArmor = CreateCheckbox(panel, "Armor", "armor", 0)
    panel.cbHands = CreateCheckbox(panel, "Weapon", "hands", 74)
    panel.cbLearned = CreateCheckbox(panel, "Learned", "learned", 156)

    panel.searchBox = CreateFrame("EditBox", "PEEEnhancedAffixSearchBox", panel)
    SetFrameSize(panel.searchBox, SIDE_PANEL_WIDTH - 24, 22)
    panel.searchBox:SetPoint("TOPLEFT", panel, "TOPLEFT", 12, -52)
    panel.searchBox:SetAutoFocus(false)
    if panel.searchBox.SetTextInsets then
        panel.searchBox:SetTextInsets(6, 6, 0, 0)
    end
    SetBackdrop(panel.searchBox, 1, 1, {0.02, 0.02, 0.02}, BLACK, 1)
    SetFont(panel.searchBox, 11, WHITE)

    panel.placeholder = panel.searchBox:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
    panel.placeholder:SetPoint("LEFT", panel.searchBox, "LEFT", 8, 0)
    panel.placeholder:SetText("Search affixes...")
    SetFont(panel.placeholder, 10, MUTED)
    panel.searchBox:SetScript("OnEditFocusGained", function(self)
        if self.SetBackdropBorderColor then
            self:SetBackdropBorderColor(HOVER_BLUE[1], HOVER_BLUE[2], HOVER_BLUE[3], 1)
        end
        panel.placeholder:Hide()
    end)
    panel.searchBox:SetScript("OnEditFocusLost", function(self)
        if self.SetBackdropBorderColor then
            self:SetBackdropBorderColor(BLACK[1], BLACK[2], BLACK[3], 1)
        end
        if self:GetText() == "" then
            panel.placeholder:Show()
        end
    end)
    panel.searchBox:SetScript("OnEscapePressed", function(self)
        self:ClearFocus()
    end)
    panel.searchBox:SetScript("OnEnterPressed", function(self)
        if panel.SelectSearchResult then
            panel:SelectSearchResult()
        end
        self:ClearFocus()
    end)
    panel.searchBox:SetScript("OnTextChanged", function(self)
        if self:GetText() == "" then
            panel.placeholder:Show()
        else
            panel.placeholder:Hide()
        end
        overlay.RefreshEnhancedAffixBook(panel)
    end)

    panel.listBox = CreateFrame("Frame", nil, panel)
    panel.listBox:SetPoint("TOPLEFT", panel.searchBox, "BOTTOMLEFT", 0, -6)
    panel.listBox:SetPoint("RIGHT", panel.searchBox, "RIGHT", 0, 0)
    SetFrameSize(panel.listBox, SIDE_PANEL_WIDTH - 24, ROW_HEIGHT * VISIBLE_ROWS + LIST_PAD * 2)
    panel.listBox:EnableMouse(true)
    panel.listBox:EnableMouseWheel(true)
    SetBackdrop(panel.listBox, 1, 1, {0.018, 0.018, 0.018}, {0.16, 0.16, 0.16}, 1)

    panel.listEmptyText = panel.listBox:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
    panel.listEmptyText:SetPoint("CENTER", panel.listBox, "CENTER", 0, 0)
    panel.listEmptyText:SetText("No matching affixes")
    SetFont(panel.listEmptyText, 10, MUTED, nil, "CENTER")

    panel.descriptionText = panel:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
    panel.descriptionText:SetPoint("TOPLEFT", panel.listBox, "BOTTOMLEFT", 0, -6)
    SetFont(panel.descriptionText, 10, MUTED, SIDE_PANEL_WIDTH - 24)
    if panel.descriptionText.SetHeight then
        panel.descriptionText:SetHeight(34)
    end
    panel.descriptionText:SetText("")

    panel.tierFrame = CreateFrame("Frame", nil, panel)
    SetFrameSize(panel.tierFrame, SIDE_PANEL_WIDTH - 16, 70)
    panel.tierFrame:SetPoint("TOP", panel.descriptionText, "BOTTOM", 0, -6)
    panel.tierIcons = {}
    local totalWidth = TIER_ICON_SIZE * #TIER_ROMANS + TIER_GAP * (#TIER_ROMANS - 1)
    local startX = -(totalWidth / 2) + TIER_ICON_SIZE / 2
    for tier = 1, #TIER_ROMANS do
        local button = CreateTierButton(panel.tierFrame, tier)
        button:SetPoint("CENTER", panel.tierFrame, "CENTER", startX + (tier - 1) * (TIER_ICON_SIZE + TIER_GAP), 0)
        panel.tierIcons[tier] = button
    end

    panel.confirmBtn = CreateFrame("Button", nil, panel)
    SetFrameSize(panel.confirmBtn, 190, 30)
    panel.confirmBtn:SetPoint("BOTTOM", panel, "BOTTOM", 0, 8)
    panel.confirmBtn.text = panel.confirmBtn:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    panel.confirmBtn.text:SetPoint("CENTER", panel.confirmBtn, "CENTER", 0, 0)
    panel.confirmBtn.text:SetText("Confirm")
    SkinRedButton(panel.confirmBtn)
    panel.confirmBtn:SetScript("OnClick", function()
        if _G.ExtractionUI and ExtractionUI.pendingBag and ExtractionUI.pendingSlot and
            ExtractionUI.selectedAffixId then
            StaticPopup_Show("EBONHOLD_CONFIRM_APPLY_AFFIX")
        end
    end)
    if panel.confirmBtn.Disable then
        panel.confirmBtn:Disable()
    end

    panel.rows = {}
    for index = 1, VISIBLE_ROWS do
        local row = CreateFrame("Button", nil, panel.listBox)
        SetFrameSize(row, SIDE_PANEL_WIDTH - 40, ROW_HEIGHT)
        row:SetPoint("TOPLEFT", panel.listBox, "TOPLEFT", LIST_PAD, -(LIST_PAD + (index - 1) * ROW_HEIGHT))
        row.hoverTex = row:CreateTexture(nil, "BACKGROUND")
        row.hoverTex:SetAllPoints(row)
        row.hoverTex:SetTexture("Interface\\Buttons\\WHITE8x8")
        row.hoverTex:SetVertexColor(HOVER_BLUE[1], HOVER_BLUE[2], HOVER_BLUE[3], 0.35)
        row.hoverTex:Hide()
        row.selectedTex = row:CreateTexture(nil, "BACKGROUND")
        row.selectedTex:SetAllPoints(row)
        row.selectedTex:SetTexture("Interface\\Buttons\\WHITE8x8")
        row.selectedTex:SetVertexColor(HOVER_BLUE_BACKDROP[1], HOVER_BLUE_BACKDROP[2], HOVER_BLUE_BACKDROP[3], 0.85)
        row.selectedTex:Hide()
        row.text = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
        row.text:SetPoint("LEFT", row, "LEFT", 4, 0)
        row.text:SetPoint("RIGHT", row, "RIGHT", -2, 0)
        SetFont(row.text, 10, CREAM)
        row:SetScript("OnEnter", function(self)
            if self.hoverTex then
                self.hoverTex:Show()
            end
            if self.family and GameTooltip then
                GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
                GameTooltip:SetText(self.family.prettyName, MAGE_BLUE[1], MAGE_BLUE[2], MAGE_BLUE[3])
                GameTooltip:AddLine(self.family.weaponOnly and "Weapon affix" or "Armor affix", CREAM[1], CREAM[2],
                    CREAM[3])
                if self.description and self.description ~= "" then
                    GameTooltip:AddLine(self.description, 1, 1, 1, true)
                end
                GameTooltip:Show()
            end
        end)
        row:SetScript("OnLeave", function(self)
            if self.hoverTex then
                self.hoverTex:Hide()
            end
            if GameTooltip then
                GameTooltip:Hide()
            end
        end)
        row:SetScript("OnClick", function(self)
            if self.baseName then
                overlay.SelectEnhancedAffixFamily(panel, self.baseName)
            end
        end)
        row:SetScript("OnMouseWheel", function(_, delta)
            overlay.ScrollEnhancedAffixBook(panel, delta)
        end)
        panel.rows[index] = row
    end

    panel.scrollbar = CreateFrame("Frame", nil, panel.listBox)
    panel.scrollbar:SetPoint("TOPRIGHT", panel.listBox, "TOPRIGHT", -4, -LIST_PAD)
    panel.scrollbar:SetPoint("BOTTOMRIGHT", panel.listBox, "BOTTOMRIGHT", -4, LIST_PAD)
    panel.scrollbar:SetWidth(8)
    panel.scrollbar.thumb = panel.scrollbar:CreateTexture(nil, "OVERLAY")
    panel.scrollbar.thumb:SetTexture("Interface\\Buttons\\WHITE8x8")
    panel.scrollbar.thumb:SetVertexColor(0.16, 0.42, 0.48, 1)
    panel.scrollbar.thumb:SetWidth(8)

    panel.listBox:SetScript("OnMouseWheel", function(_, delta)
        overlay.ScrollEnhancedAffixBook(panel, delta)
    end)
    function panel:SelectSearchResult()
        overlay.RefreshEnhancedAffixBook(self)
        local baseName, tier = FindSearchSelection(self, true)
        if not baseName then
            baseName, tier = FindSearchSelection(self, false)
        end
        if not baseName and self.selectedFamily then
            for _, name in ipairs(self.visibleOrder or {}) do
                if name == self.selectedFamily then
                    baseName = name
                    break
                end
            end
        end
        if not baseName and self.visibleOrder and self.visibleOrder[1] then
            baseName = self.visibleOrder[1]
        end
        if baseName then
            ScrollFamilyIntoView(self, baseName)
            return overlay.SelectEnhancedAffixFamily(self, baseName, tier)
        end
        return false
    end
    panel:Hide()
    return panel
end

local function EnsurePanel()
    if overlay.enhancedAffixBookPanel then
        return overlay.enhancedAffixBookPanel
    end
    if not CreateFrame then
        return nil
    end

    overlay.enhancedAffixBookPanel = CreatePanel()
    return overlay.enhancedAffixBookPanel
end

function overlay.SelectEnhancedAffixTier(panel, tier)
    local family = panel and panel.families and panel.selectedFamily and panel.families[panel.selectedFamily]
    local affix = family and family.tiers[tier]
    if not affix then
        return
    end

    panel.selectedTier = tier
    if _G.ExtractionUI then
        ExtractionUI.selectedAffixId = affix.id
        ExtractionUI.rememberedFamily = family.baseName
        ExtractionUI.rememberedTier = tier
    end
    if _G.ExtractionService then
        ExtractionService.applyCost = affix.applyCost
    end
    if affix.learned and panel.confirmBtn.Enable then
        panel.confirmBtn:Enable()
    elseif panel.confirmBtn.Disable then
        panel.confirmBtn:Disable()
    end
    if panel.confirmBtn.text then
        panel.confirmBtn.text:SetText("Confirm  " .. FormatCopper(affix.applyCost))
    elseif panel.confirmBtn.SetText then
        panel.confirmBtn:SetText("Confirm  " .. FormatCopper(affix.applyCost))
    end
    if panel.descriptionText then
        panel.descriptionText:SetText(GetSpellDescription(affix.id))
    end
    overlay.UpdateEnhancedAffixTiers(panel)
end

function overlay.UpdateEnhancedAffixTiers(panel)
    local family = panel and panel.families and panel.selectedFamily and panel.families[panel.selectedFamily]
    if not family then
        return
    end
    local unavailable = UNAVAILABLE_AFFIX_TIERS[family.baseName] or {}
    local totalWidth = TIER_ICON_SIZE * #TIER_ROMANS + TIER_GAP * (#TIER_ROMANS - 1)
    local startX = -(totalWidth / 2) + TIER_ICON_SIZE / 2

    for tier, button in ipairs(panel.tierIcons) do
        local affix = family.tiers[tier]
        local active = panel.selectedTier == tier
        button:ClearAllPoints()
        if family.weaponOnly then
            if tier == 1 then
                button:SetPoint("CENTER", panel.tierFrame, "CENTER", 0, 0)
                button:Show()
                if button.tierLabel then
                    button.tierLabel:Hide()
                end
            else
                button:Hide()
                if button.tierLabel then
                    button.tierLabel:Hide()
                end
            end
        else
            button:SetPoint("CENTER", panel.tierFrame, "CENTER", startX + (tier - 1) * (TIER_ICON_SIZE + TIER_GAP), 0)
            button:Show()
            if button.tierLabel then
                button.tierLabel:Show()
            end
        end

        SetButtonBackdrop(button, active and HOVER_BLUE_BACKDROP or {0.06, 0.06, 0.06}, BLACK)
        if affix and affix.icon and button.icon.SetTexture then
            button.icon:SetTexture(affix.icon)
        elseif button.icon.SetTexture then
            button.icon:SetTexture("Interface\\Icons\\INV_Misc_QuestionMark")
        end
        if button.icon.SetDesaturated then
            button.icon:SetDesaturated(not (affix and affix.learned))
        end
        if affix then
            button.icon:Show()
            if affix.learned then
                button.lockOverlay:Hide()
                button.lockText:Hide()
            else
                button.lockOverlay:Show()
                button.lockText:Show()
            end
            if button.Enable then
                button:Enable()
            end
            button:SetScript("OnClick", function()
                overlay.SelectEnhancedAffixTier(panel, tier)
            end)
            button:SetScript("OnEnter", function(self)
                SetButtonBackdrop(self, active and HOVER_BLUE_BACKDROP or {0.06, 0.06, 0.06},
                    active and AFFIX_PURPLE or TIER_COLORS[tier])
                if GameTooltip then
                    GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
                    if GameTooltip.SetSpellByID then
                        GameTooltip:SetSpellByID(affix.id)
                    else
                        GameTooltip:SetText(affix.name or ("Tier " .. TIER_ROMANS[tier]), 1, 1, 1)
                    end
                    if not affix.learned then
                        GameTooltip:AddLine(" ")
                        GameTooltip:AddLine("Not yet learned", MUTED[1], MUTED[2], MUTED[3])
                        GameTooltip:AddLine("Extract from gear to learn this tier.", 0.5, 0.5, 0.5, true)
                    else
                        local equippedCount = panel.equippedCounts and (panel.equippedCounts[affix.id] or 0) or 0
                        local equippedItems = panel.equippedItems and panel.equippedItems[affix.id] or {}
                        if equippedCount > 0 then
                            GameTooltip:AddLine(" ")
                            if equippedCount > 1 then
                                GameTooltip:AddLine("Equipped on " .. equippedCount ..
                                    " items (does not stack!):", 1, 0.3, 0.3)
                            else
                                GameTooltip:AddLine("Equipped on:", 0.3, 1, 0.3)
                            end
                            for _, item in ipairs(equippedItems) do
                                GameTooltip:AddLine("  " .. item, 1, 1, 1)
                            end
                        end
                    end
                    GameTooltip:Show()
                end
            end)
            button:SetScript("OnLeave", function()
                SetButtonBackdrop(button, active and HOVER_BLUE_BACKDROP or {0.06, 0.06, 0.06}, BLACK)
                if GameTooltip then
                    GameTooltip:Hide()
                end
            end)
        else
            button.icon:SetTexture("Interface\\Icons\\INV_Misc_QuestionMark")
            button.lockOverlay:Show()
            button.lockText:Show()
            if button.icon.SetDesaturated then
                button.icon:SetDesaturated(true)
            end
            if unavailable[tier] and button.Enable then
                button:Enable()
            elseif button.Disable then
                button:Disable()
            end
            button:SetScript("OnEnter", function(self)
                SetButtonBackdrop(self, active and HOVER_BLUE_BACKDROP or {0.06, 0.06, 0.06},
                    active and AFFIX_PURPLE or TIER_COLORS[tier])
                if GameTooltip then
                    GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
                    if unavailable[tier] then
                        GameTooltip:SetText("Tier " .. (TIER_ROMANS[tier] or tier), MUTED[1], MUTED[2], MUTED[3])
                        GameTooltip:AddLine(unavailable[tier], 0.8, 0.55, 1, true)
                    else
                        GameTooltip:SetText("Tier " .. (TIER_ROMANS[tier] or tier) .. " not learned", MUTED[1],
                            MUTED[2], MUTED[3])
                        GameTooltip:AddLine("Extract from gear to learn this tier.", 0.5, 0.5, 0.5, true)
                    end
                    GameTooltip:Show()
                end
            end)
            button:SetScript("OnLeave", function()
                SetButtonBackdrop(button, active and HOVER_BLUE_BACKDROP or {0.06, 0.06, 0.06}, BLACK)
                if GameTooltip then
                    GameTooltip:Hide()
                end
            end)
            button:SetScript("OnClick", nil)
        end

        if affix and affix.learned and panel.equippedCounts and (panel.equippedCounts[affix.id] or 0) > 0 then
            SetButtonBackdrop(button, active and HOVER_BLUE_BACKDROP or {0.06, 0.06, 0.06}, BLACK)
        end
    end
end

function overlay.SelectEnhancedAffixFamily(panel, baseName, tier)
    if not panel or not panel.families or not panel.families[baseName] then
        return false
    end

    panel.selectedFamily = baseName
    panel.selectedTier = nil
    if _G.ExtractionUI then
        ExtractionUI.rememberedFamily = baseName
        ExtractionUI.rememberedTier = nil
        ExtractionUI.selectedAffixId = nil
    end
    if panel.confirmBtn.Disable then
        panel.confirmBtn:Disable()
    end
    if panel.confirmBtn.text then
        panel.confirmBtn.text:SetText("Confirm")
    end

    local family = panel.families[baseName]
    if panel.descriptionText then
        local description = ""
        for index = #TIER_ROMANS, 1, -1 do
            local affix = family.tiers[index]
            if affix and affix.id then
                description = GetSpellDescription(affix.id)
                if description ~= "" then
                    break
                end
            end
        end
        panel.descriptionText:SetText(description)
    end
    overlay.UpdateEnhancedAffixTiers(panel)
    if tier then
        overlay.SelectEnhancedAffixTier(panel, tier)
    elseif family.weaponOnly and family.tiers[1] then
        overlay.SelectEnhancedAffixTier(panel, 1)
    end
    overlay.UpdateEnhancedAffixRows(panel)
    return true
end

function overlay.ScrollEnhancedAffixBook(panel, delta)
    panel.scrollOffset = math.max(0, math.min(panel.maxScrollOffset or 0, (panel.scrollOffset or 0) - (delta or 0)))
    overlay.UpdateEnhancedAffixRows(panel)
end

function overlay.UpdateEnhancedAffixRows(panel)
    local total = panel.visibleOrder and #panel.visibleOrder or 0
    panel.maxScrollOffset = math.max(0, total - VISIBLE_ROWS)
    panel.scrollOffset = math.max(0, math.min(panel.scrollOffset or 0, panel.maxScrollOffset))

    if total == 0 then
        panel.listEmptyText:Show()
    else
        panel.listEmptyText:Hide()
    end

    for index, row in ipairs(panel.rows) do
        local baseName = panel.visibleOrder and panel.visibleOrder[(panel.scrollOffset or 0) + index]
        local family = baseName and panel.families[baseName]
        if family then
            row.baseName = baseName
            row.family = family
            row.description = ""
            row.text:SetText(DisplayName(family))
            if row.selectedTex then
                if baseName == panel.selectedFamily then
                    row.selectedTex:Show()
                else
                    row.selectedTex:Hide()
                end
            end
            for tier = #TIER_ROMANS, 1, -1 do
                local affix = family.tiers[tier]
                if affix then
                    row.description = GetSpellDescription(affix.id)
                    break
                end
            end
            row:Show()
        else
            row.baseName = nil
            row.family = nil
            if row.selectedTex then
                row.selectedTex:Hide()
            end
            row:Hide()
        end
    end

    if panel.scrollbar and panel.scrollbar.thumb then
        if total <= VISIBLE_ROWS then
            panel.scrollbar.thumb:Hide()
        else
            panel.scrollbar.thumb:Show()
            local trackHeight = panel.scrollbar.GetHeight and panel.scrollbar:GetHeight() or 170
            local thumbHeight = math.max(16, trackHeight * (VISIBLE_ROWS / total))
            panel.scrollbar.thumb:SetHeight(thumbHeight)
            panel.scrollbar.thumb:ClearAllPoints()
            panel.scrollbar.thumb:SetPoint("TOP", panel.scrollbar, "TOP", 0,
                -((panel.scrollOffset or 0) / panel.maxScrollOffset) * (trackHeight - thumbHeight))
        end
    end
end

function overlay.RefreshEnhancedAffixBook(panel)
    panel = panel or EnsurePanel()
    if not panel then
        return
    end

    local filters = EnsureDB()
    local families, order, equippedCounts, equippedItems = BuildFamilies()
    local needle = Normalize(panel.searchBox and panel.searchBox:GetText() or "")
    panel.families = families
    panel.equippedCounts = equippedCounts
    panel.equippedItems = equippedItems
    panel.visibleOrder = {}

    for _, baseName in ipairs(order) do
        local family = families[baseName]
        local include = family.weaponOnly and filters.hands or filters.armor
        if include and filters.learned then
            include = FamilyLearned(family)
        end
        if include and needle ~= "" then
            include = FamilyMatches(family, needle)
        end
        if include then
            panel.visibleOrder[#panel.visibleOrder + 1] = baseName
        end
    end

    local selectedVisible = false
    for _, baseName in ipairs(panel.visibleOrder) do
        if baseName == panel.selectedFamily then
            selectedVisible = true
            break
        end
    end

    if panel.selectedFamily and (not families[panel.selectedFamily] or not selectedVisible) then
        panel.selectedFamily = nil
    end
    if not panel.selectedFamily then
        panel.selectedFamily = _G.ExtractionUI and ExtractionUI.rememberedFamily or nil
    end
    if not panel.selectedFamily or not families[panel.selectedFamily] then
        panel.selectedFamily = panel.visibleOrder[1]
    end

    panel.scrollOffset = 0
    if panel.selectedFamily then
        overlay.SelectEnhancedAffixFamily(panel, panel.selectedFamily,
            _G.ExtractionUI and ExtractionUI.rememberedTier or nil)
    else
        overlay.UpdateEnhancedAffixRows(panel)
    end
end

function overlay.ShowEnhancedAffixBook()
    if overlay.isPTR or not overlay.enabled then
        if DEFAULT_CHAT_FRAME and DEFAULT_CHAT_FRAME.AddMessage then
            DEFAULT_CHAT_FRAME:AddMessage("|cff3FC7EB[PEE]|r Inactive on PTR.")
        end
        return false
    end

    local extractionFrame = _G.EbonholdExtractionFrame
    if extractionFrame and extractionFrame.Show then
        extractionFrame:Show()
    end
    if _G.ExtractionService and ExtractionService.RequestLearnedAffixes then
        ExtractionService.RequestLearnedAffixes()
    end

    local panel = EnsurePanel()
    if not panel then
        return false
    end
    local serverPanel = _G.EbonholdAffixBookPanel
    if serverPanel and serverPanel ~= panel and serverPanel.Hide then
        serverPanel:Hide()
    end
    overlay.RefreshEnhancedAffixBook(panel)
    panel:Show()
    if overlay.ApplyExtractionTheme then
        overlay.ApplyExtractionTheme()
    end
    return true
end

overlay.ShowAffixBook = overlay.ShowEnhancedAffixBook

local function Install()
    if overlay.enhancedAffixBookInstalled or not _G.ExtractionUI then
        return
    end

    overlay.enhancedAffixBookInstalled = true
    overlay.serverShowSidePanel = ExtractionUI.ShowSidePanel
    ExtractionUI.ShowSidePanel = function(...)
        if overlay.enabled and not overlay.isPTR and overlay.ShowEnhancedAffixBook then
            return overlay.ShowEnhancedAffixBook()
        end
        if type(overlay.serverShowSidePanel) == "function" then
            return overlay.serverShowSidePanel(...)
        end
    end
end

overlay.InstallEnhancedAffixBook = Install

local eventFrame = CreateFrame and CreateFrame("Frame")
if eventFrame then
    eventFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
    eventFrame:SetScript("OnEvent", Install)
end
Install()
