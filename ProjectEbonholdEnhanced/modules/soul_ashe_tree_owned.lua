local _, Addon = ...
local overlay = ProjectEbonholdEnhanced

if not overlay then
    return
end

-- luacheck: ignore 122 211 212 213 231 311 431 432 542 631
local peeOwnedSkillTreeFrame
local loadoutDropdown
local currentClass
local ValidateAndSendLoadout
local OnApplyChangesResult
local RefreshLoadoutDropdown
local refreshAccessibility
local updateTalentPoints
local ShowChoiceButtons
local HideChoiceButtons
local NextRankTooltip
local CurrentRankTooltip
local InfoTooltip

local function CountTableEntries(tableValue)
    local count = 0
    for _ in pairs(tableValue or {}) do
        count = count + 1
    end
    return count
end

local function GetThemeBackdropOpacity()
    if overlay and overlay.GetBackdropOpacity then
        return overlay.GetBackdropOpacity()
    end
    if utils and utils.GetBackdropOpacity then
        return utils.GetBackdropOpacity()
    end
    return 0.8
end

overlay.OwnedSoulAsheChrome = overlay.OwnedSoulAsheChrome or {
    DARK = {0.039, 0.039, 0.039},
    BLACK = {0, 0, 0},
    CREAM = {1, 0.92, 0.82},
    GOLD = {1, 0.82, 0},
    MAGE_BLUE = {0.247, 0.78, 0.922},
    RED = {0.32, 0.1, 0.1},
    RED_HOVER = {0.48, 0.16, 0.14},
    RED_HOVER_BORDER = {1.0, 0.28, 0.24},
    HOVER_BLUE = {0.16, 0.88, 1.0},
    HOVER_BLUE_BACKDROP = {0.03, 0.14, 0.18},
    TOP_BAR_HEIGHT = 32,
    STATUS_BAR_HEIGHT = 38,
    STATUS_BUTTON_HEIGHT = 24,
    STATUS_SEARCH_WIDTH = 250,
}

local Chrome = overlay.OwnedSoulAsheChrome

function Chrome.SetFrameSize(frame, width, height)
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

function Chrome.SetFont(fontString, size, color, width, justify)
    if not fontString then
        return
    end
    if fontString.SetFont then
        fontString:SetFont("Fonts\\FRIZQT__.TTF", overlay.ScaledFontSize and overlay.ScaledFontSize(size) or size,
            "OUTLINE")
    end
    if fontString.SetTextColor and color then
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

function Chrome.SetPlainBarBackdrop(frame, alpha)
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
        frame:SetBackdropColor(Chrome.DARK[1], Chrome.DARK[2], Chrome.DARK[3], alpha or 0.96)
    end
end

function Chrome.SetDarkBackdrop(frame, edgeSize, alpha)
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
        frame:SetBackdropColor(Chrome.DARK[1], Chrome.DARK[2], Chrome.DARK[3], alpha or GetThemeBackdropOpacity())
    end
    if frame.SetBackdropBorderColor then
        frame:SetBackdropBorderColor(Chrome.BLACK[1], Chrome.BLACK[2], Chrome.BLACK[3], 1)
    end
end

function Chrome.SetBackdropColor(frame, color, alpha)
    if frame and frame.SetBackdropColor then
        frame:SetBackdropColor(color[1], color[2], color[3], alpha or GetThemeBackdropOpacity())
    end
end

function Chrome.SetBorderColor(frame, color)
    if frame and frame.SetBackdropBorderColor then
        frame:SetBackdropBorderColor(color[1], color[2], color[3], 1)
    end
end

function Chrome.HideRegion(region)
    if not region then
        return
    end
    if overlay and overlay.SuppressTextureRegion then
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

function Chrome.HideButtonArt(button)
    if not button then
        return
    end
    if overlay and overlay.HideButtonTextures then
        overlay.HideButtonTextures(button)
    end
    if overlay and overlay.LockButtonTextureSetters then
        overlay.LockButtonTextureSetters(button)
    end
    if button.GetRegions then
        for _, region in ipairs({ button:GetRegions() }) do
            if region and region.SetTexture then
                Chrome.HideRegion(region)
            end
        end
    end
end

function Chrome.ButtonFontString(button)
    local fontString
    if button and button.GetFontString then
        fontString = button:GetFontString()
    end
    return fontString or (button and button.text)
end

function Chrome.ClearAndPoint(frame, point, relativeTo, relativePoint, xOffset, yOffset)
    if not frame or not frame.SetPoint then
        return
    end
    if frame.ClearAllPoints then
        frame:ClearAllPoints()
    end
    frame:SetPoint(point, relativeTo, relativePoint, xOffset or 0, yOffset or 0)
end

function Chrome.SkinStatusButton(button, restingColor, width)
    if not button then
        return
    end
    Chrome.HideButtonArt(button)
    Chrome.SetFrameSize(button, width or 88, Chrome.STATUS_BUTTON_HEIGHT)
    Chrome.SetDarkBackdrop(button, 2, 0.92)
    Chrome.SetBackdropColor(button, restingColor or Chrome.DARK, 0.92)
    Chrome.SetBorderColor(button, Chrome.BLACK)
    if button.SetAlpha then
        button:SetAlpha(1)
    end

    local fontString = Chrome.ButtonFontString(button)
    Chrome.SetFont(fontString, 12, Chrome.CREAM, width or 88, "CENTER")

    button._peeOwnedSkillTreeRestingColor = restingColor or Chrome.DARK
    if button._peeOwnedSkillTreeChromeHooks then
        return
    end

    local function onEnter(self)
        if self._peeOwnedSkillTreeRestingColor == Chrome.RED then
            Chrome.SetBackdropColor(self, Chrome.RED_HOVER, 0.96)
            Chrome.SetBorderColor(self, Chrome.RED_HOVER_BORDER)
            return
        end
        Chrome.SetBackdropColor(self, Chrome.HOVER_BLUE_BACKDROP, 0.96)
        Chrome.SetBorderColor(self, Chrome.HOVER_BLUE)
    end
    local function onLeave(self)
        Chrome.SetBackdropColor(self, self._peeOwnedSkillTreeRestingColor or Chrome.DARK, 0.92)
        Chrome.SetBorderColor(self, Chrome.BLACK)
    end

    if button.HookScript then
        button:HookScript("OnEnter", onEnter)
        button:HookScript("OnLeave", onLeave)
    elseif button.SetScript then
        button:SetScript("OnEnter", onEnter)
        button:SetScript("OnLeave", onLeave)
    end
    button._peeOwnedSkillTreeChromeHooks = true
end


local COLOR_GRAY = { 0.45, 0.45, 0.45 }
local COLOR_GREEN = { 0.10, 1.00, 0.10 }
local COLOR_ORANGE = { 1.00, 0.70, 0.20 }


local isWaitingForValidation = false
local applyButton = nil
local isGlowEnabled = true
local COLOR_APEX = { 1.00, 0.20, 1.00 }


local DebugPrint = function() end -- skillTree_Debug.DebugPrint


local VIEW_W, VIEW_H = 900, 600



local TALENT_POINTS_TOTAL = 0
local TALENT_POINT_TOTAL_BASE = 0


local savedLoadouts = {}
local currentLoadoutName = ""


local hasUnsavedChanges = false


local lastValidatedState = {}
local revertBtn = nil




local validateBtn = nil


local nodesById = {}
local treeSearchBox = nil
local asheProgressSimulation = {
    active = false,
    duration = 10,
}
local lines = {}
local neighbors = {}
local parentsOf = {}
local nodeChoices = {}
local nodeRanks = {}
local activeApexNodeId = nil

local TREE_SEARCH_ALIASES = {
    ["health"]   = {"heal", "health", "regenerat", "absorb", "life"},
    ["heal"]     = {"heal", "health", "regenerat", "absorb"},
    ["speed"]    = {"speed", "movement", "haste", "slow", "swift"},
    ["damage"]   = {"damage", "deal", "strike", "attack", "hit"},
    ["fire"]     = {"fire", "flame", "burn", "ignite", "ember"},
    ["nature"]   = {"nature", "poison", "bleed", "thorn"},
    ["frost"]    = {"frost", "freeze", "chill", "ice"},
    ["shadow"]   = {"shadow", "dark", "void", "curse"},
    ["holy"]     = {"holy", "divine", "light", "sacred"},
    ["armor"]    = {"armor", "defence", "shield", "absorb"},
    ["crit"]     = {"critical", "crit"},
    ["mana"]     = {"mana", "energy", "resource", "cost"},
    ["cooldown"] = {"cooldown", "recharge"},
    ["aoe"]      = {"area", "nearby", "surround", "splash"},
    ["stamina"]  = {"stamina", "health", "endur"},
    ["dash"]     = {"dash", "sprint", "rush"},
    ["vanish"]   = {"vanish", "stealth", "invis"},
}
local treeDescCache = {}

local function CreateWhiteTexture(parent, key, layer)
    if not parent or not parent.CreateTexture then
        return nil
    end
    if not parent[key] then
        parent[key] = parent:CreateTexture(nil, layer or "OVERLAY")
        parent[key]:SetTexture("Interface\\Buttons\\WHITE8x8")
    end
    return parent[key]
end

local function GetOwnedAsheProgressCap()
    local serverAddon = _G and _G.ProjectEbonhold
    local constants = serverAddon and serverAddon.Constants
    local maxSoulAshes = constants and tonumber(constants.MAX_SOUL_ASHES)
    if maxSoulAshes and maxSoulAshes > 0 then
        return maxSoulAshes
    end

    local cap = 0
    local milestoneData = serverAddon and serverAddon.SoulAshesMilestones
    for _, data in ipairs(milestoneData or {}) do
        local value = type(data) == "table" and tonumber(data.soulAshes) or tonumber(data)
        if value and value > cap then
            cap = value
        end
    end

    if cap > 0 then
        return cap
    end

    return 100
end

local function GetAsheProgressSimulationValue()
    if not asheProgressSimulation.active then
        return nil
    end

    local getTime = _G and _G.GetTime
    local now = getTime and getTime() or 0
    local startedAt = asheProgressSimulation.startedAt or now
    local duration = asheProgressSimulation.duration or 10
    local cap = asheProgressSimulation.cap or GetOwnedAsheProgressCap()
    local ratio = 1
    if duration > 0 then
        ratio = math.max(0, math.min(1, (now - startedAt) / duration))
    end
    local current = math.floor(1 + ((cap - 1) * ratio) + 0.5)
    return current, cap, ratio
end

Chrome.PERMANENT_ECHO_SLOT_ROMANS = Chrome.PERMANENT_ECHO_SLOT_ROMANS or { "I", "II", "III", "IV", "V" }
Chrome.PERMANENT_ECHO_QUALITY = Chrome.PERMANENT_ECHO_QUALITY or {
    [-1] = { name = "Unknown", color = {0.62, 0.62, 0.62} },
    [0] = { name = "Common", color = {1, 1, 1} },
    [1] = { name = "Uncommon", color = {0.1, 1, 0.1} },
    [2] = { name = "Rare", color = {0, 0.44, 0.87} },
    [3] = { name = "Epic", color = {0.64, 0.21, 0.93} },
    [4] = { name = "Legendary", color = {1, 0.5, 0} },
}

function Chrome.FormatOwnedSoulAshValue(value)
    value = tonumber(value) or 0
    if value >= 1000000 then
        local millions = value / 1000000
        if millions == math.floor(millions) then
            return tostring(millions) .. "M"
        end
        return string.format("%.1fM", millions)
    end
    if value >= 1000 then
        local thousands = value / 1000
        if thousands == math.floor(thousands) then
            return tostring(thousands) .. "K"
        end
        return string.format("%.1fK", thousands)
    end
    return tostring(value)
end

function Chrome.GetOwnedPermanentEchoSlotMilestones()
    local serverAddon = _G and _G.ProjectEbonhold
    local milestoneData = serverAddon and serverAddon.SoulAshesMilestones
    local milestones = {}
    if not milestoneData or #milestoneData == 0 then
        return milestones
    end

    milestones[1] = { index = 1, soulAshes = 0 }
    for _, data in ipairs(milestoneData) do
        local soulAshes
        local spellId
        if type(data) == "table" then
            soulAshes = tonumber(data.soulAshes)
            spellId = tonumber(data.spellID or data.spellId)
        else
            soulAshes = tonumber(data)
        end
        if soulAshes then
            milestones[#milestones + 1] = { index = 0, soulAshes = soulAshes, spellId = spellId }
        end
    end

    table.sort(milestones, function(left, right)
        return (left.soulAshes or 0) < (right.soulAshes or 0)
    end)
    for index, milestone in ipairs(milestones) do
        milestone.index = index
    end
    return milestones
end

function Chrome.GetOwnedPermanentEchoUnlockedSlotCount(currentTotal)
    local unlockedSlots = 0
    for _, milestone in ipairs(Chrome.GetOwnedPermanentEchoSlotMilestones()) do
        if (tonumber(currentTotal) or 0) >= (milestone.soulAshes or 0) then
            unlockedSlots = unlockedSlots + 1
        end
    end

    local perkService = _G and _G.ProjectEbonhold and _G.ProjectEbonhold.PerkService
    local serverSlotCount = perkService and perkService.GetMaximumPermanentEchoes and
        tonumber(perkService.GetMaximumPermanentEchoes())
    if serverSlotCount and serverSlotCount > unlockedSlots then
        unlockedSlots = serverSlotCount
    end
    return unlockedSlots
end

function Chrome.GetOwnedLockedPerkList()
    local perkService = _G and _G.ProjectEbonhold and _G.ProjectEbonhold.PerkService
    local lockedPerks = perkService and perkService.GetLockedPerks and perkService.GetLockedPerks() or {}
    local list = {}

    for key, perkData in pairs(lockedPerks) do
        if type(perkData) == "table" then
            local spellId = tonumber(perkData.spellId or perkData.spellID or key)
            if spellId then
                local spellName = perkData.name or perkData.spellName or (_G.GetSpellInfo and _G.GetSpellInfo(spellId))
                list[#list + 1] = {
                    spellId = spellId,
                    quality = tonumber(perkData.quality) or -1,
                    count = tonumber(perkData.count or perkData.stack or perkData.stacks) or 1,
                    name = spellName or ("Spell " .. tostring(spellId)),
                }
            end
        end
    end

    table.sort(list, function(left, right)
        if (left.quality or -1) ~= (right.quality or -1) then
            return (left.quality or -1) > (right.quality or -1)
        end
        if (left.name or "") ~= (right.name or "") then
            return (left.name or "") < (right.name or "")
        end
        return (left.spellId or 0) < (right.spellId or 0)
    end)
    return list
end

function Chrome.GetOwnedSpellNameAndIcon(spellId)
    if not spellId then
        return "Permanent Echo Slot", "Interface\\Icons\\INV_Misc_QuestionMark"
    end
    local spellName, _, spellIcon = _G.GetSpellInfo and _G.GetSpellInfo(spellId)
    return spellName or ("Spell " .. tostring(spellId)), spellIcon or "Interface\\Icons\\INV_Misc_QuestionMark"
end

function Chrome.GetOwnedEchoQuality(quality)
    if quality == nil then
        quality = -1
    end
    return Chrome.PERMANENT_ECHO_QUALITY[quality] or Chrome.PERMANENT_ECHO_QUALITY[-1]
end

function Chrome.GetOwnedEchoDescription(spellId, count)
    local spellUtils = _G and _G.utils
    if spellUtils and spellUtils.GetSpellDescription and spellId then
        local ok, description = pcall(spellUtils.GetSpellDescription, spellId, 500, count or 1)
        if ok then
            return description
        end
    end
    return nil
end

function Chrome.HideOwnedTooltip()
    if InfoTooltip and InfoTooltip.Hide then
        InfoTooltip:Hide()
    end
    if _G.GameTooltip and _G.GameTooltip.Hide then
        _G.GameTooltip:Hide()
    end
end

function Chrome.ProxyOwnedSkillTreeDragStart()
    if not peeOwnedSkillTreeFrame then
        return
    end
    local dragStart = peeOwnedSkillTreeFrame.GetScript and peeOwnedSkillTreeFrame:GetScript("OnDragStart")
    if dragStart then
        dragStart(peeOwnedSkillTreeFrame)
    elseif peeOwnedSkillTreeFrame.StartMoving then
        peeOwnedSkillTreeFrame:StartMoving()
    end
end

function Chrome.ProxyOwnedSkillTreeDragStop()
    if not peeOwnedSkillTreeFrame then
        return
    end
    local dragStop = peeOwnedSkillTreeFrame.GetScript and peeOwnedSkillTreeFrame:GetScript("OnDragStop")
    if dragStop then
        dragStop(peeOwnedSkillTreeFrame)
    elseif peeOwnedSkillTreeFrame.StopMovingOrSizing then
        peeOwnedSkillTreeFrame:StopMovingOrSizing()
    end
end

local PopulateSearchResults
local HideSearchResults

local function GetSearchResultCost(btn)
    if not btn or not btn.soulPointsCosts then return 0 end
    local costs = btn.soulPointsCosts
    local nextRank = (nodeRanks[btn.id] or 0) + 1
    if nextRank > #costs then nextRank = #costs end
    return costs[nextRank] or costs[#costs] or 0
end

local function FilterTreeNodes(searchText)
    local lowerSearch = string.lower(searchText or ""):gsub("^%s+", ""):gsub("%s+$", "")
    local isEmpty = (lowerSearch == "")
    local searchMissingNodes = (lowerSearch == "missing")
    local searchPermanentNodes = (lowerSearch == "perm" or lowerSearch == "permanent")

    local terms = {}
    if not isEmpty and not searchMissingNodes and not searchPermanentNodes then
        terms[#terms + 1] = lowerSearch
        if TREE_SEARCH_ALIASES[lowerSearch] then
            for _, alias in ipairs(TREE_SEARCH_ALIASES[lowerSearch]) do
                terms[#terms + 1] = alias
            end
        end
    end

    local matchedBtns = {}

    for _, btn in pairs(nodesById) do
        if isEmpty then
            btn:SetAlpha(1.0)
        else
            local matches = false
            if searchMissingNodes then
                matches = (nodeRanks[btn.id] or 0) == 0
            elseif searchPermanentNodes then
                matches = btn.permanent and true or false
            elseif btn.spells then
                for _, spellId in ipairs(btn.spells) do
                    local name = GetSpellInfo(spellId)
                    local nameLower = name and string.lower(name) or ""

                    if not treeDescCache[spellId] then
                        if utils and utils.GetSpellDescription then
                            local ok, d = pcall(utils.GetSpellDescription, spellId, 500, 1)
                            treeDescCache[spellId] = (ok and d) and d:lower() or ""
                        else
                            treeDescCache[spellId] = ""
                        end
                    end
                    local desc = treeDescCache[spellId]

                    for _, term in ipairs(terms) do
                        if string.find(nameLower, term, 1, true)
                            or string.find(desc, term, 1, true) then
                            matches = true
                            break
                        end
                    end
                    if matches then break end
                end
            end
            btn:SetAlpha(matches and 1.0 or 0.15)
            if matches then
                matchedBtns[#matchedBtns + 1] = btn
            end
        end
    end

    if isEmpty then
        if HideSearchResults then HideSearchResults() end
    else
        table.sort(matchedBtns, function(a, b)
            local costA = GetSearchResultCost(a)
            local costB = GetSearchResultCost(b)
            if costA ~= costB then return costA < costB end
            local nameA = (a.spells and a.spells[1] and GetSpellInfo(a.spells[1])) or ""
            local nameB = (b.spells and b.spells[1] and GetSpellInfo(b.spells[1])) or ""
            if nameA ~= nameB then return nameA < nameB end
            return (a.id or 0) < (b.id or 0)
        end)
        if PopulateSearchResults then PopulateSearchResults(matchedBtns) end
    end
end


local lastNodeClickTime = 0
local NODE_CLICK_COOLDOWN = 0.1
local rapidClickCount = 0
local rapidClickResetTime = 0
local RAPID_CLICK_THRESHOLD = 5
local RAPID_CLICK_WINDOW = 2

local function HasRealChanges()
    if not lastValidatedState or not lastValidatedState.nodeRanks then
        return next(nodeRanks) ~= nil or next(nodeChoices) ~= nil
    end


    for nodeId, rank in pairs(nodeRanks) do
        if (lastValidatedState.nodeRanks[nodeId] or 0) ~= rank then
            return true
        end
    end
    for nodeId, rank in pairs(lastValidatedState.nodeRanks) do
        if (nodeRanks[nodeId] or 0) ~= rank then
            return true
        end
    end


    if lastValidatedState.nodeChoices then
        for nodeId, choice in pairs(nodeChoices) do
            if (lastValidatedState.nodeChoices[nodeId] or 0) ~= choice then
                return true
            end
        end
        for nodeId, choice in pairs(lastValidatedState.nodeChoices) do
            if (nodeChoices[nodeId] or 0) ~= choice then
                return true
            end
        end
    elseif next(nodeChoices) ~= nil then
        return true
    end

    return false
end


local function getNodeRank(nodeId) return nodeRanks[nodeId] or 0 end

local function getMaxRank(nodeId)
    local btn = nodesById[nodeId]
    if not btn or not btn.spells then return 0 end
    return #btn.spells
end


local function isNodeActive(nodeId)
    local btn = nodesById[nodeId]
    if not btn then return false end

    if btn.isMultipleChoice then
        return (nodeChoices[nodeId] or 0) ~= 0
    else
        return getNodeRank(nodeId) > 0
    end
end


local function getSpellIconSafe(spellID)
    local _, _, iconTex = GetSpellInfo(spellID)
    return iconTex or "Interface\\Icons\\INV_Misc_QuestionMark"
end


local function updateNodeIcon(btn)
    if not btn or not btn.spells or not btn.icon or not btn.id then return end

    local nodeId = btn.id
    local spellID
    if btn.isMultipleChoice then
        local selectedChoice = nodeChoices[nodeId] or 1
        spellID = btn.spells[selectedChoice]
    else
        local currentRank = getNodeRank(nodeId)
        spellID = btn.spells[math.max(1, currentRank)]
    end

    if spellID then
        btn.icon:SetTexture(getSpellIconSafe(spellID))
    end
end


local function updateAllNodeVisuals()
    for _, btn in pairs(nodesById) do
        if btn.choiceButtons then
            for _, choiceBtn in ipairs(btn.choiceButtons) do
                choiceBtn:Hide()
            end
            btn.choiceButtons = {}
        end


        updateNodeIcon(btn)
    end
    if peeOwnedSkillTreeFrame and peeOwnedSkillTreeFrame.nodeStatsText then
        local totalNodes, usedNodes, permanentTotal, permanentUsed = 0, 0, 0, 0
        for nodeId, btn in pairs(nodesById) do
            totalNodes = totalNodes + 1
            local rank = nodeRanks[nodeId] or 0
            if rank > 0 then usedNodes = usedNodes + 1 end
            if btn.permanent then
                permanentTotal = permanentTotal + 1
                if rank > 0 then permanentUsed = permanentUsed + 1 end
            end
        end
        local nonPermUsed = usedNodes - permanentUsed
        local nonPermTotal = totalNodes - permanentTotal
        peeOwnedSkillTreeFrame.nodeStatsText:SetText(
            "|cffbbbbbbNodes:|r " .. nonPermUsed .. "/" .. nonPermTotal ..
            "  |cffbbbbbbPerm:|r " .. permanentUsed .. "/" .. permanentTotal ..
            "  |cffbbbbbbFree Pts:|r " .. (TALENT_POINTS_TOTAL or 0))
    end
    if Chrome.RefreshOwnedSkillTreeChrome then
        Chrome.RefreshOwnedSkillTreeChrome()
    end
end


local function getNodeCost(btn, rank)
    if not btn or not btn.soulPointsCosts then return 0 end
    local costs = btn.soulPointsCosts
    return costs[rank] or costs[#costs] or 0
end


local function addCostToTooltip(tooltip, label, cost, canAfford)
    local costColor = canAfford and "|cff00FF00" or "|cffFF0000"
    local soulIcon = "|TInterface\\AddOns\\ProjectEbonhold\\assets\\inv_soulash:16|t"
    tooltip:AddLine(costColor .. label .. soulIcon .. " " .. cost .. " Soul Ashes|r", 1, 1, 1)
end


local function resetAllNodeRanks()
    for nodeId, _ in pairs(nodesById) do
        nodeRanks[nodeId] = 0
    end
end


local getConnectedNodes, isStartingNode



local function hasPrerequisites(nodeId)
    if isStartingNode(nodeId) then
        return true
    end


    local parents = parentsOf[nodeId]
    if not parents or #parents == 0 then
        return false
    end

    for _, parentId in ipairs(parents) do
        local parentBtn = nodesById[parentId]
        local parentRank = getNodeRank(parentId)
        local parentMaxRank = getMaxRank(parentId)


        if not parentBtn or not isNodeActive(parentId) or parentRank < parentMaxRank then
            return false
        end
    end

    return true
end


local function GetRemainingTalentPoints()
    return TALENT_POINTS_TOTAL
end


local function HasAnyTalents()
    for nodeId, rank in pairs(nodeRanks) do if rank > 0 then return true end end
    for nodeId, choice in pairs(nodeChoices) do
        if choice > 0 then return true end
    end
    return false
end


local function CopyCurrentBuildToLoadout(loadout)
    loadout.nodeRanks = {}
    loadout.nodeChoices = {}


    for nodeId, rank in pairs(nodeRanks) do
        if rank > 0 then loadout.nodeRanks[nodeId] = rank end
    end


    for nodeId, choice in pairs(nodeChoices) do
        if choice ~= 0 then loadout.nodeChoices[nodeId] = choice end
    end


    loadout.spendablePoints = TALENT_POINTS_TOTAL
end


local function UpdateGlowEffect()
    if validateBtn and validateBtn.glowTexture and hasUnsavedChanges and
        isGlowEnabled then
        local remainingPoints = GetRemainingTalentPoints()

        if remainingPoints >= 0 then
            validateBtn.glowTimer = validateBtn.glowTimer + 0.05
            local alpha = (math.sin(validateBtn.glowTimer * 1.5) + 1) * 0.4
            validateBtn.glowTexture:SetAlpha(alpha)
        else
            validateBtn.glowTexture:SetAlpha(0)
        end
    elseif validateBtn and validateBtn.glowTexture then
        validateBtn.glowTexture:SetAlpha(0)
    end
end


local function MarkUnsavedChanges()
    if not HasRealChanges() then
        hasUnsavedChanges = false
        if validateBtn then
            validateBtn:Disable()
            validateBtn:GetFontString():SetTextColor(0.5, 0.5, 0.5)
            if validateBtn.glowTexture then
                validateBtn.glowTexture:SetAlpha(0)
            end
        end
        DebugPrint("No real changes detected - Apply Changes disabled")
        return
    end

    hasUnsavedChanges = true

    DebugPrint("MarkUnsavedChanges called")
    DebugPrint("validateBtn exists: %s", tostring(validateBtn ~= nil))


    local remainingPoints = GetRemainingTalentPoints()



    if validateBtn then
        if not hasUnsavedChanges then
            validateBtn:Disable()
            validateBtn:GetFontString():SetTextColor(0.5, 0.5, 0.5)
            if validateBtn.glowTexture then
                validateBtn.glowTexture:SetAlpha(0)
            end
            DebugPrint("validateBtn disabled - no unsaved changes")
        else
            if remainingPoints < 0 then
                validateBtn:Disable()
                validateBtn:GetFontString():SetTextColor(0.5, 0.5, 0.5)
                if validateBtn.glowTexture then
                    validateBtn.glowTexture:SetAlpha(0)
                end
                DebugPrint("validateBtn disabled - overspent by %d",
                    -remainingPoints)
            else
                validateBtn:Enable()
                validateBtn:GetFontString():SetTextColor(1, 1, 1)
                if validateBtn.glowTexture then
                    validateBtn.glowTimer = 0
                end
                DebugPrint("Enabled validateBtn (build affordable)")
            end
        end
    else
        DebugPrint("Could not enable validateBtn - element missing")
    end


    if revertBtn and lastValidatedState and lastValidatedState.nodeRanks then
        revertBtn:Enable()

        if revertBtn.icon then
            revertBtn.icon:SetDesaturated(false)
            revertBtn.icon:SetAlpha(1.0)
        end
        DebugPrint("Enabled revertBtn")
    end

    DebugPrint("Marked as needing validation")
end


local function MarkAsValidated()
    hasUnsavedChanges = false


    if validateBtn then
        validateBtn:Disable()
        validateBtn:GetFontString():SetTextColor(0.5, 0.5, 0.5)

        if validateBtn.glowTexture then
            validateBtn.glowTexture:SetAlpha(0)
        end
    end


    if revertBtn then
        revertBtn:Disable()

        if revertBtn.icon then
            revertBtn.icon:SetDesaturated(true)
            revertBtn.icon:SetAlpha(0.5)
        end
    end


    lastValidatedState = {
        nodeRanks = {},
        nodeChoices = {},
        class = currentClass
    }


    for nodeId, rank in pairs(nodeRanks) do
        lastValidatedState.nodeRanks[nodeId] = rank
    end


    for nodeId, choice in pairs(nodeChoices) do
        lastValidatedState.nodeChoices[nodeId] = choice
    end

    DebugPrint("Validated state saved with %d node ranks and %d choices",
        CountTableEntries(lastValidatedState.nodeRanks),
        CountTableEntries(lastValidatedState.nodeChoices))
end


local function RevertToValidatedState()
    if not lastValidatedState or not lastValidatedState.nodeRanks then
        DebugPrint("|cffFF0000No validated state to revert to!|r")
        return false
    end


    if lastValidatedState.class and lastValidatedState.class ~= currentClass then
        DebugPrint(
            "|cffFFFF00Warning: Validated state is for a different class!|r")
    end


    nodeRanks = {}
    resetAllNodeRanks()
    for nodeId, rank in pairs(lastValidatedState.nodeRanks) do
        nodeRanks[nodeId] = rank
    end


    nodeChoices = {}
    for nodeId, choice in pairs(lastValidatedState.nodeChoices) do
        nodeChoices[nodeId] = choice
    end


    for _, btn in pairs(nodesById) do
        local nodeId = btn.id


        updateNodeIcon(btn)


        if btn.isMultipleChoice then
            local selectedChoice = nodeChoices[nodeId]
            if selectedChoice and selectedChoice ~= 0 then
                btn.selectedSpell = selectedChoice
            else
                btn.selectedSpell = nil
            end
        end
    end


    MarkAsValidated()


    refreshAccessibility()

    DebugPrint("|cff00FF00Reverted to last validated state!|r")
    return true
end


local resetNonPermanentNodes
local profileFrame = nil
local GetProfileDB, SaveProfile, LoadProfile, DeleteProfile, GetProfileList
local RefreshProfileFrame, ToggleProfileFrame




local TreeNodes = {}
local Links = {}
currentClass = "Mage"


local function DetectPlayerClass()
    local _, playerClass = UnitClass("player")


    local classMapping = {
        ["WARRIOR"] = "Warrior",
        ["PALADIN"] = "Paladin",
        ["HUNTER"] = "Hunter",
        ["ROGUE"] = "Rogue",
        ["PRIEST"] = "Priest",
        ["DEATHKNIGHT"] = "Death Knight",
        ["SHAMAN"] = "Shaman",
        ["MAGE"] = "Mage",
        ["WARLOCK"] = "Warlock",
        ["DRUID"] = "Druid"
    }
    local detectedClass = classMapping[playerClass] or "Mage"
    DebugPrint("Player class detected: %s (API: %s)", detectedClass,
        playerClass or "unknown")
    return detectedClass
end


nodeChoices = {}
nodeRanks = {}



function getConnectedNodes(nodeId)
    return neighbors[nodeId] or {}
end

function isStartingNode(nodeId)
    local btn = nodesById[nodeId]
    if btn then return btn.isStart == true end


    for _, node in ipairs(TreeNodes) do
        if node.id == nodeId then return node.isStart == true end
    end

    return false
end

NextRankTooltip = nil
CurrentRankTooltip = nil
InfoTooltip = nil


local function SendCreateLoadoutToServer(name, nodeRanks)
    if not ProjectEbonhold or not ProjectEbonhold.sendToServer then
        DebugPrint(
            "|cffFF0000Cannot send create loadout request: ProjectEbonhold not available|r")
        return false
    end


    local nodeParts = {}
    for nodeId, rank in pairs(nodeRanks) do
        if rank > 0 then table.insert(nodeParts, nodeId .. ":" .. rank) end
    end


    local spendablePoints = TALENT_POINTS_TOTAL

    local nodesString = table.concat(nodeParts, ",")

    local dataString = name .. "," .. spendablePoints .. "," .. nodesString

    DebugPrint("|cff00FF00Sending CREATE_LOADOUT request to server...|r")
    DebugPrint("|cffFFFF00Name: " .. name .. ", Available Points: " ..
        spendablePoints .. ", Nodes: " .. #nodeParts .. "|r")

    ProjectEbonhold.sendToServer(ProjectEbonhold.CS.REQUEST_CREATE_LOADOUT,
        dataString)
    return true
end


local function saveCurrentLoadout(name)
    local loadout = {
        nodeRanks = {},
        nodeChoices = {},
        id = 0,
        spendablePoints = 0,
        class = currentClass
    }


    CopyCurrentBuildToLoadout(loadout)

    savedLoadouts[name] = loadout
    currentLoadoutName = name


    SendCreateLoadoutToServer(name, loadout.nodeRanks)

    DebugPrint("|cff00FF00Loadout saved locally: " .. name .. " (" ..
        TALENT_POINTS_TOTAL .. " Soul Ashes available)|r")
end

local function loadLoadout(name, forceReload)
    if currentLoadoutName == name and not forceReload then
        DebugPrint("|cffFFFF00Loadout already loaded: " .. name .. "|r")
        return
    end

    local loadout = savedLoadouts[name]
    if not loadout then
        DebugPrint("|cffFF0000Loadout not found: " .. name .. "|r")
        return
    end

    DebugPrint("|cff00FF00Loading loadout: " .. name .. "...|r")


    nodeRanks = {}
    nodeChoices = {}


    resetAllNodeRanks()
    for nodeId, _ in pairs(nodesById) do
        nodeChoices[nodeId] = 0
    end


    if loadout.nodeRanks then
        for id, rank in pairs(loadout.nodeRanks) do nodeRanks[id] = rank end
    end


    if loadout.nodeChoices then
        for id, choice in pairs(loadout.nodeChoices) do
            nodeChoices[id] = choice
        end
    end


    updateAllNodeVisuals()

    currentLoadoutName = name
    refreshAccessibility()
    DebugPrint("|cff00FF00Loadout loaded: " .. name .. " (nodes applied)|r")
end

local function clearCurrentBuild()
    resetAllNodeRanks()


    nodeChoices = {}


    activeApexNodeId = nil


    updateAllNodeVisuals()

    currentLoadoutName = ""
    refreshAccessibility()
    MarkUnsavedChanges()
    DebugPrint("|cff00FF00All talents cleared!|r")
end

local function getLoadoutsList()
    local list = {}
    for name, _ in pairs(savedLoadouts) do table.insert(list, name) end
    table.sort(list)
    return list
end


local function CreateLoadoutPackage()
    local loadoutId = 0
    local loadoutName = currentLoadoutName or "Unnamed"

    if currentLoadoutName and currentLoadoutName ~= "" and
        savedLoadouts[currentLoadoutName] then
        loadoutId = savedLoadouts[currentLoadoutName].id or 0
    end

    local package = { id = loadoutId, name = loadoutName, nodeRanks = {} }


    DebugPrint("=== Creating Loadout Package ===")
    local totalNodes = 0
    for nodeId, rank in pairs(nodeRanks) do
        DebugPrint("Node %d: rank = %d", nodeId, rank)
        if rank > 0 then
            package.nodeRanks[nodeId] = rank
            totalNodes = totalNodes + 1
        end
    end
    DebugPrint("Total nodes with rank > 0: %d", totalNodes)

    return package
end


local function SendLoadoutToServer(loadoutData)
    DebugPrint("=== SENDING LOADOUT TO SERVER ===")
    DebugPrint("Loadout ID: %s, Name: %s", tostring(loadoutData.id),
        loadoutData.name)

    local nodeCount = 0
    for _ in pairs(loadoutData.nodeRanks) do nodeCount = nodeCount + 1 end
    DebugPrint("Total Nodes: %d", nodeCount)


    if ProjectEbonhold and ProjectEbonhold.SendLoadoutToServer then
        return ProjectEbonhold.SendLoadoutToServer(loadoutData)
    end

    return false
end




local function ExportLoadoutToCode()
    local buffer = {}


    local activeNodes = {}
    for nodeId, rank in pairs(nodeRanks) do
        if rank > 0 then
            table.insert(activeNodes, { id = nodeId, rank = rank })
        end
    end


    for nodeId, choice in pairs(nodeChoices) do
        if choice > 0 then
            local found = false
            for _, node in ipairs(activeNodes) do
                if node.id == nodeId then
                    found = true
                    break
                end
            end
            if not found then
                table.insert(activeNodes, { id = nodeId, rank = 1 })
            end
        end
    end


    table.sort(activeNodes, function(a, b) return a.id < b.id end)


    for _, byte in ipairs(utils.EncodeVarInt(#activeNodes)) do
        table.insert(buffer, byte)
    end


    for _, node in ipairs(activeNodes) do
        for _, byte in ipairs(utils.EncodeVarInt(node.id)) do
            table.insert(buffer, byte)
        end

        table.insert(buffer, node.rank)
    end

    return utils.Base64Encode(buffer)
end


local function ImportLoadoutFromCode(encodedData)
    local buffer = utils.Base64Decode(encodedData)
    if not buffer or #buffer == 0 then return nil, "Invalid Base64 data" end

    local pos = 1


    local nodeCount
    nodeCount, pos = utils.DecodeVarInt(buffer, pos)
    if not nodeCount then return nil, "Failed to decode node count" end


    local nodes = {}
    for i = 1, nodeCount do
        local nodeId
        nodeId, pos = utils.DecodeVarInt(buffer, pos)
        if not nodeId then return nil, "Failed to decode node ID" end

        if pos > #buffer then
            return nil, "Missing rank for node " .. nodeId
        end
        local rank = buffer[pos]
        pos = pos + 1

        table.insert(nodes, { id = nodeId, rank = rank })
    end

    return nodes
end


local function ApplyImportedLoadout(nodes)
    if not nodes then return false end


    local totalPointsRequired = 0
    for _, node in ipairs(nodes) do
        local btn = nodesById[node.id]
        if btn then
            if btn.isMultipleChoice then
                totalPointsRequired = totalPointsRequired + 1
            else
                totalPointsRequired = totalPointsRequired + node.rank
            end
        end
    end


    if totalPointsRequired > TALENT_POINTS_TOTAL then
        return false,
            "You tried to import a build without enough Soul Ashes (Required: " ..
            totalPointsRequired .. ", Available: " .. TALENT_POINTS_TOTAL ..
            ")"
    end


    clearCurrentBuild()


    for _, node in ipairs(nodes) do
        local btn = nodesById[node.id]
        if btn then
            if btn.isMultipleChoice then
                nodeChoices[node.id] = 1
                nodeRanks[node.id] = 1
                btn.selectedSpell = 1
                updateNodeIcon(btn)
            else
                nodeRanks[node.id] = node.rank
            end
        end
    end


    updateAllNodeVisuals()
    refreshAccessibility()
    MarkUnsavedChanges()

    return true
end


ValidateAndSendLoadout = function()
    DebugPrint("Validating current loadout...")


    if not HasAnyTalents() then
        DebugPrint("|cffFF0000Validation failed: No talents selected|r")
        return false
    end


    if currentLoadoutName and savedLoadouts[currentLoadoutName] then
        local loadout = savedLoadouts[currentLoadoutName]
        CopyCurrentBuildToLoadout(loadout)
        DebugPrint("|cff00FF00Saved current state to loadout: " ..
            currentLoadoutName .. "|r")
    end


    local loadoutData = CreateLoadoutPackage()


    if SendLoadoutToServer(loadoutData) then
        DebugPrint("|cffFFFF00Loadout sent to server...|r")
        return true
    else
        DebugPrint("|cffFF0000Failed to send loadout to server|r")
        return false
    end
end

OnApplyChangesResult = function(spellId, success)
    isWaitingForValidation = false

    if success then
        MarkAsValidated()
        DebugPrint("|cff00FF00Skill tree changes applied successfully!|r")

        if applyButton then
            applyButton:SetText("Apply Changes")


            isGlowEnabled = false
            if applyButton.glowTexture then
                applyButton.glowTexture:SetAlpha(0)
            end
        end
    else
        DebugPrint("|cffFF0000Skill tree validation failed!|r")

        if spellId then
        else
        end


        RevertToValidatedState()
        hasUnsavedChanges = false

    end
end

local function LoadClassData(className)
    local treeData = TalentDatabase[0]

    if not treeData then
        DebugPrint(
            "|cffFF0000Error: Default tree 0 not found in TalentDatabase!|r")
        return false
    end

    currentClass = className or DetectPlayerClass()
    DebugPrint("Loading default soul tree 0 for class: %s", currentClass)


    TreeNodes = {}
    Links = {}

    for i, node in ipairs(treeData.nodes) do
        TreeNodes[i] = {}
        for key, value in pairs(node) do TreeNodes[i][key] = value end
    end

    for i, link in ipairs(treeData.links) do Links[i] = { link[1], link[2] } end


    nodeRanks = {}
    for _, node in ipairs(TreeNodes) do
        nodeRanks[node.id] = 0
    end

    return true
end


LoadClassData()


function Addon.ApplyLoadoutsFromServer(parsedData)
    if not parsedData then
        DebugPrint("|cffFF0000Invalid loadout data received from server|r")
        return false
    end


    TALENT_POINTS_TOTAL = parsedData.spendableSoulPoints or 0
    TALENT_POINT_TOTAL_BASE = parsedData.totalCommitedSoulPoints or 0


    if peeOwnedSkillTreeFrame and peeOwnedSkillTreeFrame.progressBar and peeOwnedSkillTreeFrame.progressBar.UpdateProgressBar then
        peeOwnedSkillTreeFrame.progressBar.UpdateProgressBar()
    end


    savedLoadouts = {}


    for _, loadout in ipairs(parsedData.loadouts) do
        savedLoadouts[loadout.name] = {
            nodeRanks = loadout.nodeRanks,
            nodeChoices = {},
            class = currentClass,
            spendablePoints = loadout.spendablePoints,
            id = loadout.id
        }
    end


    local selectedLoadout = nil
    if parsedData.selectedLoadoutId then
        for _, loadout in ipairs(parsedData.loadouts) do
            if loadout.id == parsedData.selectedLoadoutId then
                selectedLoadout = loadout
                break
            end
        end
    end


    if not selectedLoadout then
        for _, loadout in ipairs(parsedData.loadouts) do
            if loadout.id == 0 then
                selectedLoadout = loadout
                DebugPrint("|cffFFD700Loading default loadout 0 (tree 0)|r")
                break
            end
        end
    end


    if selectedLoadout then
        resetAllNodeRanks()
        nodeChoices = {}


        for nodeId, rank in pairs(selectedLoadout.nodeRanks) do
            nodeRanks[nodeId] = rank
        end

        currentLoadoutName = selectedLoadout.name


        updateAllNodeVisuals()
    else
        resetAllNodeRanks()
        nodeChoices = {}
        currentLoadoutName = ""
    end


    MarkAsValidated()
    refreshAccessibility()



    local driver = CreateFrame("Frame")
    driver:SetScript("OnUpdate", function(self, elapsed)
        self:SetScript("OnUpdate", nil)
        RefreshLoadoutDropdown()
    end)

    DebugPrint("|cff00FF00Loadouts received from server!|r")
    DebugPrint("|cffFFFF00Total spendable points: " .. TALENT_POINTS_TOTAL ..
        "|r")
    DebugPrint("|cffFFFF00Loaded " .. #parsedData.loadouts .. " loadout(s)|r")
    if selectedLoadout then
        DebugPrint("|cff00FF00Selected loadout: " .. selectedLoadout.name ..
            "|r")
    end

    return true
end

RefreshLoadoutDropdown = function()
    if not loadoutDropdown then
        DebugPrint(
            "|cffFFFF00RefreshLoadoutDropdown: dropdown not initialized yet, will update on creation|r")
        return
    end

    DebugPrint("|cff00FF00Refreshing loadout dropdown...|r")
    DebugPrint("|cffFFFF00Current loadout name: " ..
        (currentLoadoutName or "nil") .. "|r")


    if currentLoadoutName and currentLoadoutName ~= "" then
        UIDropDownMenu_SetText(loadoutDropdown, currentLoadoutName)
        DebugPrint("|cff00FF00Dropdown text set to: " .. currentLoadoutName ..
            "|r")
    else
        UIDropDownMenu_SetText(loadoutDropdown, "Select Build")
        DebugPrint("|cffFFFF00Dropdown text set to: Select Build|r")
    end
end

function Addon.ApplyLoadoutFromServer(loadoutData)
    DebugPrint(
        "|cffFFFF00Warning: Using deprecated ApplyLoadoutFromServer function|r")
    return false
end

local function CheckInitialState()
    local hasAnyTalents = false
    for nodeId, rank in pairs(nodeRanks) do
        if rank > 0 then
            hasAnyTalents = true
            break
        end
    end

    if hasAnyTalents then
        MarkUnsavedChanges()
    else
        MarkAsValidated()
    end
end




peeOwnedSkillTreeFrame = CreateFrame("Frame", "peeOwnedSkillTreeFrame", UIParent)
peeOwnedSkillTreeFrame:SetSize(VIEW_W, VIEW_H)
peeOwnedSkillTreeFrame:SetPoint("CENTER", 0, 50)
peeOwnedSkillTreeFrame:SetFrameStrata("FULLSCREEN_DIALOG", true)

peeOwnedSkillTreeFrame:SetResizable(true)
peeOwnedSkillTreeFrame:SetMinResize(600, 400)
peeOwnedSkillTreeFrame:SetMaxResize(2400, 1600)

peeOwnedSkillTreeFrame:SetMovable(true)
peeOwnedSkillTreeFrame:EnableMouse(true)
peeOwnedSkillTreeFrame:SetClampedToScreen(true)
peeOwnedSkillTreeFrame:RegisterForDrag("LeftButton")

local function _setViewportCulling(active)
    local Scroll = _G.peeOwnedSkillTreeScroll
    local Canvas = _G.peeOwnedSkillTreeCanvas
    if not Scroll or not Canvas then return end
    if active then
        local viewLeft   = Scroll:GetHorizontalScroll() or 0
        local viewTop    = Scroll:GetVerticalScroll() or 0
        local zoom       = Canvas:GetScale() or 1
        local viewW      = Scroll:GetWidth()  / zoom
        local viewH      = Scroll:GetHeight() / zoom
        local viewRight  = viewLeft + viewW
        local viewBottom = viewTop  + viewH
        local pad        = 40  -- canvas-pixel buffer so edges don't pop

        for _, btn in pairs(nodesById) do
            local cx = (btn._cx or 0)
            local cy = (btn._cy or 0)
            if cx + 28 < viewLeft - pad or cx > viewRight + pad
               or cy + 28 < viewTop - pad or cy > viewBottom + pad then
                if btn:IsShown() then
                    btn:Hide()
                    btn._culledByDrag = true
                end
            end
        end

        for _, L in ipairs(lines) do
            local a, b = L.a, L.b
            if a and b then
                local aCulled = a._culledByDrag
                local bCulled = b._culledByDrag
                if aCulled and bCulled then
                    if L.tex and L.tex:IsShown() then
                        L.tex:Hide()
                        L._culledByDrag = true
                    end
                    if L.segments then
                        for _, seg in ipairs(L.segments) do
                            if seg:IsShown() then
                                seg:Hide()
                                L._segmentsCulled = true
                            end
                        end
                    end
                end
            end
        end
    else
        for _, btn in pairs(nodesById) do
            if btn._culledByDrag then
                btn:Show()
                btn._culledByDrag = nil
            end
        end
        for _, L in ipairs(lines) do
            if L._culledByDrag and L.tex then
                L.tex:Show()
                L._culledByDrag = nil
            end
            if L._segmentsCulled and L.segments then
                for _, seg in ipairs(L.segments) do seg:Show() end
                L._segmentsCulled = nil
            end
        end
    end
end

peeOwnedSkillTreeFrame:SetScript("OnDragStart", function(self)
    _setViewportCulling(true)
    self:StartMoving()
    local srf = _G.peeOwnedSkillTreeSearchResults
    if srf and srf:IsShown() then
        srf._wasShownPreDrag = true
        srf:Hide()
    end
end)
peeOwnedSkillTreeFrame:SetScript("OnDragStop", function(self)
    self:StopMovingOrSizing()
    _setViewportCulling(false)
    local srf = _G.peeOwnedSkillTreeSearchResults
    if srf and srf._wasShownPreDrag then
        srf:Show()
        srf._wasShownPreDrag = nil
    end
    ProjectEbonholdEnhancedDB = ProjectEbonholdEnhancedDB or {}
    local point, _, relPoint, x, y = self:GetPoint(1)
    ProjectEbonholdEnhancedDB.ownedSoulAsheTreePos = { point = point, relPoint = relPoint, x = x, y = y }
end)

local resizeHandle = CreateFrame("Frame", nil, peeOwnedSkillTreeFrame)
resizeHandle:SetSize(18, 18)
resizeHandle:SetPoint("BOTTOMRIGHT", peeOwnedSkillTreeFrame, "BOTTOMRIGHT", -2, 2)
resizeHandle:SetFrameLevel(peeOwnedSkillTreeFrame:GetFrameLevel() + 90)
resizeHandle:EnableMouse(true)
peeOwnedSkillTreeFrame.peeResizeHandle = resizeHandle

local resizeTex = resizeHandle:CreateTexture(nil, "OVERLAY")
resizeTex:SetSize(18, 18)
resizeTex:SetPoint("BOTTOMRIGHT", resizeHandle, "BOTTOMRIGHT", 0, 0)
resizeTex:SetTexture("Interface\\AddOns\\ProjectEbonholdEnhanced\\assets\\resize_grip")
resizeTex:SetVertexColor(1, 0.62, 0, 1)
resizeHandle:SetScript("OnEnter", function(self)
    resizeTex:SetVertexColor(1, 0.82, 0, 1)
    local tooltip = InfoTooltip or _G.GameTooltip
    if tooltip then
        if tooltip.ClearLines then tooltip:ClearLines() end
        tooltip:SetOwner(self, "ANCHOR_TOP")
        tooltip:SetText("Resize Soul Ashe Tree", 1, 0.82, 0)
        tooltip:AddLine("Drag this corner to resize the tree window.", 0.8, 0.8, 0.8, true)
        tooltip:Show()
    end
end)
resizeHandle:SetScript("OnLeave", function(self)
    resizeTex:SetVertexColor(1, 0.62, 0, 1)
    Chrome.HideOwnedTooltip()
end)
resizeHandle:SetScript("OnMouseDown", function(self)
    resizeTex:SetVertexColor(1, 0.82, 0, 1)
    Chrome.HideOwnedTooltip()
    local scrollFrame = _G.peeOwnedSkillTreeScroll
    if scrollFrame then scrollFrame:Hide() end
    local srf = _G.peeOwnedSkillTreeSearchResults
    if srf and srf:IsShown() then
        srf._wasShownPreResize = true
        srf:Hide()
    end
    peeOwnedSkillTreeFrame:StartSizing("BOTTOMRIGHT")
end)
resizeHandle:SetScript("OnMouseUp", function(self)
    resizeTex:SetVertexColor(1, 0.82, 0, 1)
    peeOwnedSkillTreeFrame:StopMovingOrSizing()
    local scrollFrame = _G.peeOwnedSkillTreeScroll
    if scrollFrame then scrollFrame:Show() end
    local srf = _G.peeOwnedSkillTreeSearchResults
    if srf and srf._wasShownPreResize then
        srf:Show()
        srf._wasShownPreResize = nil
    end
    ProjectEbonholdEnhancedDB = ProjectEbonholdEnhancedDB or {}
    ProjectEbonholdEnhancedDB.ownedSoulAsheTreeSize = { w = peeOwnedSkillTreeFrame:GetWidth(), h = peeOwnedSkillTreeFrame:GetHeight() }
    if Chrome.RefreshOwnedSkillTreeChrome then
        Chrome.RefreshOwnedSkillTreeChrome()
    end
end)

local function RestoreSkillTreeSize()
    ProjectEbonholdEnhancedDB = ProjectEbonholdEnhancedDB or {}
    local saved = ProjectEbonholdEnhancedDB.ownedSoulAsheTreeSize
    if saved and saved.w and saved.h then
        peeOwnedSkillTreeFrame:SetSize(saved.w, saved.h)
    end
    local pos = ProjectEbonholdEnhancedDB.ownedSoulAsheTreePos
    if pos and pos.point then
        peeOwnedSkillTreeFrame:ClearAllPoints()
        peeOwnedSkillTreeFrame:SetPoint(pos.point, UIParent, pos.relPoint or "CENTER", pos.x or 0, pos.y or 0)
    end
end
RestoreSkillTreeSize()


local glowUpdateTimer = 0
local GLOW_UPDATE_INTERVAL = 0.05
peeOwnedSkillTreeFrame:SetScript("OnUpdate",
    function(self, elapsed)
        if ProjectEbonhold_IsClosing then return end
        if not UIParent:IsShown() then return end
        elapsed = math.min(elapsed, 0.1) -- Cap elapsed to prevent freeze after alt-tab
        glowUpdateTimer = glowUpdateTimer + elapsed
        if glowUpdateTimer >= GLOW_UPDATE_INTERVAL then
            UpdateGlowEffect()
            glowUpdateTimer = 0
        end
    end)


if peeOwnedSkillTreeFrame.SetBackdrop then
    peeOwnedSkillTreeFrame:SetBackdrop({
        bgFile = "Interface\\Buttons\\WHITE8x8",
        edgeFile = "Interface\\Buttons\\WHITE8x8",
        tile = true, tileSize = 16, edgeSize = 4,
        insets = { left = 4, right = 4, top = 4, bottom = 4 }
    })
    peeOwnedSkillTreeFrame:SetBackdropColor(0.039, 0.039, 0.039, GetThemeBackdropOpacity())
    peeOwnedSkillTreeFrame:SetBackdropBorderColor(0, 0, 0, 1)
end


peeOwnedSkillTreeFrame:SetScript("OnHide", function()
    if treeSearchBox then
        treeSearchBox:SetText("")
        treeSearchBox:ClearFocus()
        FilterTreeNodes("")
    end
end)


table.insert(UISpecialFrames, "peeOwnedSkillTreeFrame")

local closeBtn = CreateFrame("Button", nil, peeOwnedSkillTreeFrame)
closeBtn:SetSize(16, 16)
closeBtn:SetPoint("TOPRIGHT", peeOwnedSkillTreeFrame, "TOPRIGHT", -4, -4)
closeBtn:SetFrameLevel(peeOwnedSkillTreeFrame:GetFrameLevel() + 10)
closeBtn:SetNormalTexture("Interface\\Buttons\\UI-Panel-MinimizeButton-Up")
closeBtn:SetPushedTexture("Interface\\Buttons\\UI-Panel-MinimizeButton-Down")
closeBtn:SetHighlightTexture("Interface\\Buttons\\UI-Panel-MinimizeButton-Highlight")
closeBtn:SetScript("OnClick", function() peeOwnedSkillTreeFrame:Hide() end)
closeBtn:Hide()
closeBtn:EnableMouse(false)
peeOwnedSkillTreeFrame.oldCloseButton = closeBtn

local nodeStatsFrame = CreateFrame("Frame", nil, peeOwnedSkillTreeFrame)
nodeStatsFrame:SetSize(200, 40)
nodeStatsFrame:SetPoint("TOPLEFT", peeOwnedSkillTreeFrame, "TOPLEFT", 12, -8)
nodeStatsFrame:SetFrameLevel(peeOwnedSkillTreeFrame:GetFrameLevel() + 10)
nodeStatsFrame:Hide()
nodeStatsFrame:EnableMouse(false)

local nodeStatsText = nodeStatsFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
nodeStatsText:SetPoint("TOPLEFT", nodeStatsFrame, "TOPLEFT", 0, 0)
nodeStatsText:SetFont("Fonts\\FRIZQT__.TTF", 9, "OUTLINE")
nodeStatsText:SetJustifyH("LEFT")
nodeStatsText:SetText("")
peeOwnedSkillTreeFrame.nodeStatsText = nodeStatsText

function Chrome.CollectOwnedSkillTreeStats()
    local totalNodes, usedNodes, permanentTotal, permanentUsed = 0, 0, 0, 0
    for nodeId, btn in pairs(nodesById) do
        totalNodes = totalNodes + 1
        local rank = nodeRanks[nodeId] or 0
        if rank > 0 then
            usedNodes = usedNodes + 1
        end
        if btn.permanent then
            permanentTotal = permanentTotal + 1
            if rank > 0 then
                permanentUsed = permanentUsed + 1
            end
        end
    end

    return {
        nodesUsed = usedNodes - permanentUsed,
        nodesTotal = totalNodes - permanentTotal,
        permanentUsed = permanentUsed,
        permanentTotal = permanentTotal,
    }
end

function Chrome.OwnedProgressValues()
    local simulationCurrent, simulationTarget = GetAsheProgressSimulationValue()
    if simulationCurrent and simulationTarget then
        return simulationCurrent, simulationTarget, tostring(simulationCurrent) .. "/" .. tostring(simulationTarget)
    end

    local progressFrame = peeOwnedSkillTreeFrame and peeOwnedSkillTreeFrame.progressBar
    local current = progressFrame and tonumber(progressFrame.currentTotal)
    local target = progressFrame and tonumber(progressFrame.nextMilestone)
    local progressText = progressFrame and progressFrame.progressText and
        progressFrame.progressText.GetText and progressFrame.progressText:GetText()
    if progressText and progressText ~= "" then
        return current, target, progressText
    end
    if current and target then
        return current, target, tostring(current) .. "/" .. tostring(target)
    end
    return nil, nil, "No milestone data"
end

function Chrome.OwnedProgressText()
    local _, _, progressText = Chrome.OwnedProgressValues()
    return progressText
end

function Chrome.UpdateOwnedProgressDecor(progressBox, width, fillWidth, ratio)
    if not progressBox then
        return
    end

    local trackTopLine = CreateWhiteTexture(progressBox, "trackTopLine", "OVERLAY")
    local trackBottomLine = CreateWhiteTexture(progressBox, "trackBottomLine", "OVERLAY")
    if progressBox.trackSheen and progressBox.trackSheen.Hide then progressBox.trackSheen:Hide() end
    if progressBox.trackMidLine and progressBox.trackMidLine.Hide then progressBox.trackMidLine:Hide() end

    if trackTopLine then
        if trackTopLine.ClearAllPoints then trackTopLine:ClearAllPoints() end
        trackTopLine:SetPoint("TOPLEFT", progressBox, "TOPLEFT", 3, -3)
        trackTopLine:SetPoint("TOPRIGHT", progressBox, "TOPRIGHT", -3, -3)
        trackTopLine:SetHeight(1)
        trackTopLine:SetVertexColor(1, 1, 1, 0.44)
    end

    if trackBottomLine then
        if trackBottomLine.ClearAllPoints then trackBottomLine:ClearAllPoints() end
        trackBottomLine:SetPoint("BOTTOMLEFT", progressBox, "BOTTOMLEFT", 3, 3)
        trackBottomLine:SetPoint("BOTTOMRIGHT", progressBox, "BOTTOMRIGHT", -3, 3)
        trackBottomLine:SetHeight(1)
        trackBottomLine:SetVertexColor(1, 1, 1, 0.18)
    end

    local showEnd = ratio and ratio > 0 and fillWidth and fillWidth > 0
    local markerX = math.max(4, math.min((width or 0) - 4, 3 + (fillWidth or 0)))
    local fillSheen = CreateWhiteTexture(progressBox, "fillSheen", "ARTWORK")
    local endMarker = CreateWhiteTexture(progressBox, "endMarker", "OVERLAY")
    local endShadow = CreateWhiteTexture(progressBox, "endMarkerShadow", "OVERLAY")
    if showEnd then
        if fillSheen then
            if fillSheen.ClearAllPoints then fillSheen:ClearAllPoints() end
            fillSheen:SetPoint("LEFT", progressBox, "LEFT", 3, 3)
            Chrome.SetFrameSize(fillSheen, fillWidth, 7)
            fillSheen:SetVertexColor(1, 1, 1, 0.16)
            fillSheen:Show()
        end
        if endShadow then
            if endShadow.ClearAllPoints then endShadow:ClearAllPoints() end
            Chrome.SetFrameSize(endShadow, 5, 18)
            endShadow:SetPoint("CENTER", progressBox, "LEFT", markerX, 0)
            endShadow:SetVertexColor(0, 0, 0, 0.68)
            endShadow:Show()
        end
        if endMarker then
            if endMarker.ClearAllPoints then endMarker:ClearAllPoints() end
            Chrome.SetFrameSize(endMarker, 2, 20)
            endMarker:SetPoint("CENTER", progressBox, "LEFT", markerX, 0)
            endMarker:SetVertexColor(1, 1, 1, 0.96)
            endMarker:Show()
        end
    else
        if fillSheen and fillSheen.Hide then fillSheen:Hide() end
        if endShadow and endShadow.Hide then endShadow:Hide() end
        if endMarker and endMarker.Hide then endMarker:Hide() end
    end
end

function Chrome.ShowOwnedProgressTooltip(owner)
    local tooltip = InfoTooltip or _G.GameTooltip
    if not tooltip then
        return
    end
    if tooltip.ClearLines then
        tooltip:ClearLines()
    end

    local current, target, progressText = Chrome.OwnedProgressValues()
    local milestones = Chrome.GetOwnedPermanentEchoSlotMilestones()
    local unlockedSlots = Chrome.GetOwnedPermanentEchoUnlockedSlotCount(current or 0)

    tooltip:SetOwner(owner, "ANCHOR_TOP")
    tooltip:SetText("Soul Ashes Progression", 1, 0.82, 0)
    tooltip:AddLine("Progress: " .. tostring(progressText or "No milestone data"), 1, 1, 1)
    if target and target > 0 then
        tooltip:AddLine("Next milestone: " .. Chrome.FormatOwnedSoulAshValue(target) .. " Soul Ashes", 0.8, 0.8, 0.8, true)
    end
    if #milestones > 0 then
        tooltip:AddLine("Permanent Echo slots: " .. tostring(unlockedSlots) .. "/" .. tostring(#milestones), 0.4, 0.8, 1.0, true)
    end
    tooltip:AddLine("Earn Soul Ashes to unlock permanent Echo slots and raise your progression cap.", 0.8, 0.8, 0.8, true)
    tooltip:Show()
end

function Chrome.ShowOwnedLockedEchoSlotTooltip(button)
    local slotData = button and button._peeOwnedEchoSlotData
    local tooltip = InfoTooltip or GameTooltip
    if not slotData or not tooltip then
        return
    end
    if tooltip.ClearLines then
        tooltip:ClearLines()
    end

    local roman = Chrome.PERMANENT_ECHO_SLOT_ROMANS[slotData.index] or tostring(slotData.index)
    tooltip:SetOwner(button, "ANCHOR_TOP")
    tooltip:SetText("Permanent Echo Slot " .. roman, 1, 0.82, 0)

    if slotData.unlocked then
        tooltip:AddLine("Unlocked", 0.1, 1, 0.1, true)
    else
        tooltip:AddLine("Locked", 1, 0.3, 0.3, true)
        tooltip:AddLine("Unlocks at " .. Chrome.FormatOwnedSoulAshValue(slotData.soulAshes) .. " Soul Ashes.", 0.8, 0.8, 0.8, true)
    end

    if slotData.perkData then
        local qualityData = Chrome.GetOwnedEchoQuality(slotData.perkData.quality)
        local qualityColor = qualityData.color
        tooltip:AddLine(" ")
        tooltip:AddLine(slotData.perkData.name, qualityColor[1], qualityColor[2], qualityColor[3], true)
        tooltip:AddLine(qualityData.name, 0.62, 0.62, 0.62, true)
        local description = Chrome.GetOwnedEchoDescription(slotData.perkData.spellId, slotData.perkData.count)
        if description and description ~= "" then
            tooltip:AddLine(" ")
            tooltip:AddLine(description, 1, 0.82, 0, true)
        end
    elseif slotData.unlocked then
        tooltip:AddLine("No permanent Echo is locked in this slot.", 0.8, 0.8, 0.8, true)
    else
        local spellName = slotData.spellId and _G.GetSpellInfo and _G.GetSpellInfo(slotData.spellId)
        if spellName then
            tooltip:AddLine(" ")
            tooltip:AddLine(spellName, 0.4, 0.8, 1.0, true)
        end
    end

    tooltip:Show()
end

function Chrome.ApplyOwnedLockedEchoSlotButton(button, slotData)
    if not button or not slotData then
        return
    end

    local icon = button.icon
    local spellId = slotData.perkData and slotData.perkData.spellId or slotData.spellId
    local _, spellIcon = Chrome.GetOwnedSpellNameAndIcon(spellId)
    if icon then
        icon:SetTexture(spellIcon)
        icon:SetAlpha(slotData.unlocked and 1 or 0.35)
        if icon.SetDesaturated then
            icon:SetDesaturated(not slotData.unlocked)
        end
    end

    if button.indexText then
        button.indexText:SetText(Chrome.PERMANENT_ECHO_SLOT_ROMANS[slotData.index] or tostring(slotData.index))
        if slotData.unlocked then
            button.indexText:SetTextColor(0.1, 1, 0.1, 1)
        else
            button.indexText:SetTextColor(0.62, 0.62, 0.62, 1)
        end
    end

    Chrome.SetBackdropColor(button, slotData.unlocked and Chrome.HOVER_BLUE_BACKDROP or Chrome.DARK, 0.92)
    Chrome.SetBorderColor(button, slotData.perkData and Chrome.GOLD or Chrome.BLACK)
    button._peeOwnedEchoSlotData = slotData
end

function Chrome.RefreshOwnedLockedEchoSlots(topBar, currentTotal)
    local slotFrame = topBar and topBar.lockedEchoSlotsFrame
    if not slotFrame then
        return
    end

    local milestones = Chrome.GetOwnedPermanentEchoSlotMilestones()
    if #milestones == 0 then
        slotFrame:Hide()
        return
    end

    local lockedPerks = Chrome.GetOwnedLockedPerkList()
    local unlockedSlots = Chrome.GetOwnedPermanentEchoUnlockedSlotCount(currentTotal or 0)
    slotFrame:Show()

    for index, milestone in ipairs(milestones) do
        local button = slotFrame.buttons and slotFrame.buttons[index]
        if button then
            local perkData = lockedPerks[index]
            local slotData = {
                index = index,
                soulAshes = milestone.soulAshes,
                spellId = milestone.spellId,
                unlocked = index <= unlockedSlots,
                perkData = perkData,
            }
            Chrome.ApplyOwnedLockedEchoSlotButton(button, slotData)
            button:Show()
        end
    end

    for index = #milestones + 1, #(slotFrame.buttons or {}) do
        if slotFrame.buttons[index] then
            slotFrame.buttons[index]:Hide()
        end
    end
end

function Chrome.WriteOwnedTopBarProgress(topBar)
    local progressBox = topBar and topBar.progressBox
    if not progressBox then
        return
    end

    local current, target, progressText = Chrome.OwnedProgressValues()
    progressBox.value:SetText(progressText)

    local ratio = 0
    if current and target and target > 0 then
        ratio = math.max(0, math.min(1, current / target))
    end

    local width = progressBox._peeProgressWidth or (progressBox.GetWidth and progressBox:GetWidth()) or 300
    local innerWidth = math.max(1, width - 6)
    local fillWidth = math.floor(innerWidth * ratio)
    if ratio > 0 and fillWidth < 2 then
        fillWidth = 2
    end
    if fillWidth > 0 then
        progressBox.fill:SetWidth(fillWidth)
        progressBox.fill:Show()
    else
        progressBox.fill:Hide()
    end
    Chrome.UpdateOwnedProgressDecor(progressBox, width, fillWidth, ratio)
    Chrome.RefreshOwnedLockedEchoSlots(topBar, current or 0)
end

function Chrome.EnsureOwnedSkillTreeTopBar()
    if not CreateFrame then
        return nil
    end

    local topBar = peeOwnedSkillTreeFrame.peeSkillTreeTopBar
    if not topBar then
        topBar = CreateFrame("Frame", nil, peeOwnedSkillTreeFrame)
        peeOwnedSkillTreeFrame.peeSkillTreeTopBar = topBar
    end

    local frameWidth = peeOwnedSkillTreeFrame.GetWidth and peeOwnedSkillTreeFrame:GetWidth() or VIEW_W
    Chrome.SetFrameSize(topBar, frameWidth - 4, Chrome.TOP_BAR_HEIGHT)
    Chrome.ClearAndPoint(topBar, "TOPLEFT", peeOwnedSkillTreeFrame, "TOPLEFT", 2, -2)
    topBar:SetPoint("TOPRIGHT", peeOwnedSkillTreeFrame, "TOPRIGHT", -2, -2)
    topBar:SetFrameLevel((peeOwnedSkillTreeFrame:GetFrameLevel() or 1) + 30)
    topBar:EnableMouse(true)
    topBar:RegisterForDrag("LeftButton")
    topBar:SetScript("OnDragStart", function()
        Chrome.ProxyOwnedSkillTreeDragStart()
    end)
    topBar:SetScript("OnDragStop", function()
        Chrome.ProxyOwnedSkillTreeDragStop()
    end)
    Chrome.SetPlainBarBackdrop(topBar, 0.96)

    if not topBar.nodesText then
        topBar.nodesText = topBar:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    end
    if not topBar.permText then
        topBar.permText = topBar:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    end
    Chrome.SetFont(topBar.nodesText, 11, Chrome.CREAM, 118, "LEFT")
    Chrome.SetFont(topBar.permText, 11, Chrome.CREAM, 96, "LEFT")
    Chrome.ClearAndPoint(topBar.nodesText, "LEFT", topBar, "LEFT", 12, 0)
    Chrome.ClearAndPoint(topBar.permText, "LEFT", topBar.nodesText, "RIGHT", 8, 0)

    if not topBar.progressBox then
        topBar.progressBox = CreateFrame("Frame", nil, topBar)
    end
    local progressBox = topBar.progressBox
    local maxProgressWidth = math.max(360, frameWidth - 330)
    local desiredProgressWidth = math.floor(frameWidth * 0.48)
    local progressWidth = math.max(420, math.min(maxProgressWidth, desiredProgressWidth))
    progressBox._peeProgressWidth = progressWidth
    Chrome.SetFrameSize(progressBox, progressWidth, 24)
    Chrome.ClearAndPoint(progressBox, "CENTER", topBar, "CENTER", 0, 0)
    Chrome.SetDarkBackdrop(progressBox, 2, 0.96)
    Chrome.SetBackdropColor(progressBox, {0.008, 0.008, 0.008}, 0.96)
    Chrome.SetBorderColor(progressBox, Chrome.BLACK)

    if not progressBox.fill then
        progressBox.fill = progressBox:CreateTexture(nil, "ARTWORK")
        progressBox.fill:SetTexture("Interface\\Buttons\\WHITE8x8")
    end
    if progressBox.fill.ClearAllPoints then
        progressBox.fill:ClearAllPoints()
    end
    progressBox.fill:SetPoint("LEFT", progressBox, "LEFT", 3, 0)
    progressBox.fill:SetHeight(18)
    progressBox.fill:SetVertexColor(Chrome.MAGE_BLUE[1], Chrome.MAGE_BLUE[2], Chrome.MAGE_BLUE[3], 0.58)

    if not progressBox.label then
        progressBox.label = progressBox:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    end
    if not progressBox.value then
        progressBox.value = progressBox:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    end
    Chrome.SetFont(progressBox.label, 11, Chrome.CREAM, 118, "LEFT")
    Chrome.SetFont(progressBox.value, 10, Chrome.CREAM, math.max(260, progressWidth - 140), "RIGHT")
    Chrome.ClearAndPoint(progressBox.label, "LEFT", progressBox, "LEFT", 10, 0)
    Chrome.ClearAndPoint(progressBox.value, "RIGHT", progressBox, "RIGHT", -12, 0)
    progressBox.label:SetText("Ashe Progression")

    if not progressBox._peeOwnedProgressTooltipHooks then
        progressBox:EnableMouse(true)
        progressBox:RegisterForDrag("LeftButton")
        progressBox:SetScript("OnEnter", function(self)
            Chrome.ShowOwnedProgressTooltip(self)
        end)
        progressBox:SetScript("OnLeave", function()
            Chrome.HideOwnedTooltip()
        end)
        progressBox:SetScript("OnDragStart", function()
            Chrome.ProxyOwnedSkillTreeDragStart()
        end)
        progressBox:SetScript("OnDragStop", function()
            Chrome.ProxyOwnedSkillTreeDragStop()
        end)
        progressBox._peeOwnedProgressTooltipHooks = true
    end

    local slotMilestones = Chrome.GetOwnedPermanentEchoSlotMilestones()
    if not topBar.lockedEchoSlotsFrame then
        topBar.lockedEchoSlotsFrame = CreateFrame("Frame", nil, topBar)
        topBar.lockedEchoSlotsFrame.buttons = {}
    end
    local slotFrame = topBar.lockedEchoSlotsFrame
    local slotSize = 20
    local slotSpacing = 4
    local slotFrameWidth = #slotMilestones > 0 and
        ((#slotMilestones * slotSize) + ((#slotMilestones - 1) * slotSpacing)) or 1
    Chrome.SetFrameSize(slotFrame, slotFrameWidth, 24)
    Chrome.ClearAndPoint(slotFrame, "LEFT", progressBox, "RIGHT", 8, 0)
    slotFrame:SetFrameLevel((topBar:GetFrameLevel() or 1) + 2)

    for index = 1, #slotMilestones do
        local button = slotFrame.buttons[index]
        if not button then
            button = CreateFrame("Button", nil, slotFrame)
            slotFrame.buttons[index] = button
            button.icon = button:CreateTexture(nil, "ARTWORK")
            button.indexText = button:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
            button.icon:SetPoint("TOPLEFT", button, "TOPLEFT", 3, -3)
            button.icon:SetPoint("BOTTOMRIGHT", button, "BOTTOMRIGHT", -3, 3)
            button.indexText:SetPoint("BOTTOM", button, "BOTTOM", 0, -1)
            Chrome.SetFont(button.indexText, 8, Chrome.CREAM, slotSize, "CENTER")
            button:EnableMouse(true)
            button:SetScript("OnEnter", function(self)
                Chrome.SetBorderColor(self, self._peeOwnedEchoSlotData and self._peeOwnedEchoSlotData.unlocked and
                    Chrome.HOVER_BLUE or Chrome.RED_HOVER_BORDER)
                Chrome.ShowOwnedLockedEchoSlotTooltip(self)
            end)
            button:SetScript("OnLeave", function(self)
                Chrome.ApplyOwnedLockedEchoSlotButton(self, self._peeOwnedEchoSlotData)
                Chrome.HideOwnedTooltip()
            end)
        end
        Chrome.SetFrameSize(button, slotSize, slotSize)
        Chrome.ClearAndPoint(button, "LEFT", slotFrame, "LEFT", (index - 1) * (slotSize + slotSpacing), 0)
        button:SetFrameLevel((slotFrame:GetFrameLevel() or 1) + 1)
        Chrome.SetDarkBackdrop(button, 2, 0.92)
    end

    for index = #slotMilestones + 1, #(slotFrame.buttons or {}) do
        if slotFrame.buttons[index] then
            slotFrame.buttons[index]:Hide()
        end
    end

    if not topBar.closeButton then
        topBar.closeButton = CreateFrame("Button", nil, topBar)
        topBar.closeButton.text = topBar.closeButton:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        topBar.closeButton.text:SetPoint("CENTER", topBar.closeButton, "CENTER", 0, 0)
        topBar.closeButton.text:SetText("X")
        topBar.closeButton:SetScript("OnClick", function()
            peeOwnedSkillTreeFrame:Hide()
        end)
    end
    Chrome.SetFrameSize(topBar.closeButton, 24, 24)
    Chrome.ClearAndPoint(topBar.closeButton, "RIGHT", topBar, "RIGHT", -6, 0)
    Chrome.SkinStatusButton(topBar.closeButton, Chrome.RED, 24)
    Chrome.SetFont(topBar.closeButton.text, 12, Chrome.CREAM, 24, "CENTER")

    return topBar
end

function Chrome.RefreshOwnedSkillTreeTopBar()
    local topBar = Chrome.EnsureOwnedSkillTreeTopBar()
    if not topBar then
        return
    end

    local stats = Chrome.CollectOwnedSkillTreeStats()
    topBar.nodesText:SetText("|cffbbbbbbNodes:|r " .. tostring(stats.nodesUsed) .. "/" .. tostring(stats.nodesTotal))
    topBar.permText:SetText("|cffbbbbbbPerm:|r " .. tostring(stats.permanentUsed) .. "/" ..
        tostring(stats.permanentTotal))
    Chrome.WriteOwnedTopBarProgress(topBar)
end

function Chrome.RefreshSearchBoxState(searchBox)
    if not searchBox then
        return
    end

    local text = searchBox.GetText and searchBox:GetText() or ""
    local hasText = text ~= ""
    if searchBox._peeOwnedSearchFocused then
        Chrome.SetBackdropColor(searchBox, Chrome.HOVER_BLUE_BACKDROP, 0.96)
        Chrome.SetBorderColor(searchBox, Chrome.HOVER_BLUE)
    else
        Chrome.SetBackdropColor(searchBox, {0.01, 0.01, 0.01}, 0.96)
        Chrome.SetBorderColor(searchBox, Chrome.BLACK)
    end

    if searchBox.placeholder then
        if hasText then
            searchBox.placeholder:Hide()
        else
            searchBox.placeholder:Show()
        end
    end
end

function Chrome.GetRegionSearchToken(region)
    if not region then
        return ""
    end

    local name = region.GetName and region:GetName() or ""
    local texture = region.GetTexture and region:GetTexture() or ""
    return string.lower(tostring(name) .. " " .. tostring(texture))
end

function Chrome.IsSearchCursorRegion(region)
    local token = Chrome.GetRegionSearchToken(region)
    return token:find("cursor", 1, true) ~= nil or token:find("caret", 1, true) ~= nil
end

function Chrome.IsSearchTemplateRegion(searchBox, region)
    if not region or not region.SetTexture or Chrome.IsSearchCursorRegion(region) then
        return false
    end

    local token = Chrome.GetRegionSearchToken(region)
    if token == "" then
        return false
    end

    if token:find("inputbox", 1, true) or token:find("editbox", 1, true) or
        token:find("common-input", 1, true) then
        return true
    end

    local searchName = searchBox and searchBox.GetName and searchBox:GetName()
    local searchToken = searchName and string.lower(tostring(searchName)) or ""
    if searchToken ~= "" and token:find(searchToken, 1, true) then
        return token:find("left", 1, true) ~= nil or token:find("middle", 1, true) ~= nil or
            token:find("mid", 1, true) ~= nil or token:find("right", 1, true) ~= nil
    end

    return false
end

function Chrome.HideSearchBoxTemplateArt(searchBox)
    if not searchBox or not searchBox.GetRegions then
        return
    end

    for _, region in ipairs({ searchBox:GetRegions() }) do
        if Chrome.IsSearchTemplateRegion(searchBox, region) then
            Chrome.HideRegion(region)
        end
    end
end

function Chrome.SetSearchBoxBackdrop(searchBox)
    if not searchBox then
        return
    end
    Chrome.HideSearchBoxTemplateArt(searchBox)
    Chrome.SetDarkBackdrop(searchBox, 2, 0.96)
    if searchBox.SetTextColor then
        searchBox:SetTextColor(Chrome.CREAM[1], Chrome.CREAM[2], Chrome.CREAM[3], 1)
    end
    if searchBox.SetFont then
        searchBox:SetFont("Fonts\\FRIZQT__.TTF", overlay.ScaledFontSize and overlay.ScaledFontSize(11) or 11,
            "OUTLINE")
    end
    if not searchBox.placeholder and searchBox.CreateFontString then
        searchBox.placeholder = searchBox:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        Chrome.SetFont(searchBox.placeholder, 10, {0.55, 0.55, 0.55}, Chrome.STATUS_SEARCH_WIDTH - 28, "LEFT")
        searchBox.placeholder:SetPoint("LEFT", searchBox, "LEFT", 8, 0)
        searchBox.placeholder:SetText("Search...")
    end
    if searchBox._peeOwnedSearchHooks then
        Chrome.RefreshSearchBoxState(searchBox)
        return
    end
    if searchBox.HookScript then
        searchBox:HookScript("OnEditFocusGained", function(self)
            self._peeOwnedSearchFocused = true
            Chrome.RefreshSearchBoxState(self)
        end)
        searchBox:HookScript("OnEditFocusLost", function(self)
            self._peeOwnedSearchFocused = false
            Chrome.RefreshSearchBoxState(self)
        end)
        searchBox:HookScript("OnTextChanged", function(self)
            Chrome.RefreshSearchBoxState(self)
        end)
    end
    searchBox._peeOwnedSearchHooks = true
    Chrome.RefreshSearchBoxState(searchBox)
end

function Chrome.LayoutOwnedSkillTreeStatusBar(bottomBar)
    if not bottomBar then
        return
    end

    Chrome.ClearAndPoint(bottomBar, "BOTTOMLEFT", peeOwnedSkillTreeFrame, "BOTTOMLEFT", 2, 2)
    bottomBar:SetPoint("BOTTOMRIGHT", peeOwnedSkillTreeFrame, "BOTTOMRIGHT", -2, 2)
    bottomBar:SetHeight(Chrome.STATUS_BAR_HEIGHT)
    bottomBar:SetFrameLevel((peeOwnedSkillTreeFrame:GetFrameLevel() or 1) + 25)
    Chrome.SetPlainBarBackdrop(bottomBar, 0.96)
    Chrome.SetBackdropColor(bottomBar, Chrome.BLACK, 0.96)

    if bottomBar.soulIcon then
        Chrome.SetFrameSize(bottomBar.soulIcon, 18, 18)
        Chrome.ClearAndPoint(bottomBar.soulIcon, "LEFT", bottomBar, "LEFT", 14, 0)
        bottomBar.soulIcon:Show()
        if bottomBar.soulIcon.SetAlpha then
            bottomBar.soulIcon:SetAlpha(1)
        end
    end

    if peeOwnedSkillTreeFrame.pointsText then
        peeOwnedSkillTreeFrame.pointsText:SetText("|cffFFD700Available Soul Ashes:|r " ..
            tostring(GetRemainingTalentPoints()))
        Chrome.SetFont(peeOwnedSkillTreeFrame.pointsText, 11, Chrome.CREAM, 230, "LEFT")
        Chrome.ClearAndPoint(peeOwnedSkillTreeFrame.pointsText, "LEFT", bottomBar.soulIcon or bottomBar,
            bottomBar.soulIcon and "RIGHT" or "LEFT", bottomBar.soulIcon and 6 or 12, 0)
    end

    Chrome.SkinStatusButton(applyButton, Chrome.RED, 132)
    if applyButton and not applyButton:IsEnabled() then
        local fontString = Chrome.ButtonFontString(applyButton)
        if fontString and fontString.SetTextColor then
            fontString:SetTextColor(0.5, 0.5, 0.5, 1)
        end
    end
    Chrome.SkinStatusButton(bottomBar.resetButton, Chrome.DARK, 72)
    Chrome.SkinStatusButton(bottomBar.profileButton, Chrome.DARK, 82)

    if applyButton then
        Chrome.ClearAndPoint(applyButton, "LEFT", peeOwnedSkillTreeFrame.pointsText or bottomBar,
            peeOwnedSkillTreeFrame.pointsText and "RIGHT" or "LEFT", peeOwnedSkillTreeFrame.pointsText and 10 or 210, 0)
    end
    if bottomBar.resetButton then
        Chrome.ClearAndPoint(bottomBar.resetButton, "LEFT", applyButton or bottomBar,
            applyButton and "RIGHT" or "LEFT", applyButton and 8 or 350, 0)
    end
    if bottomBar.profileButton then
        Chrome.ClearAndPoint(bottomBar.profileButton, "LEFT", bottomBar.resetButton or applyButton or bottomBar,
            (bottomBar.resetButton or applyButton) and "RIGHT" or "LEFT",
            (bottomBar.resetButton or applyButton) and 8 or 430, 0)
    end

    if loadoutDropdown then
        loadoutDropdown:Hide()
    end
    if bottomBar.exportButton then
        bottomBar.exportButton:Hide()
    end
    if bottomBar.importButton then
        bottomBar.importButton:Hide()
    end
    if revertBtn then
        revertBtn:Hide()
        revertBtn:EnableMouse(false)
    end

    if treeSearchBox then
        Chrome.SetFrameSize(treeSearchBox, Chrome.STATUS_SEARCH_WIDTH, 24)
        Chrome.SetSearchBoxBackdrop(treeSearchBox)
        Chrome.ClearAndPoint(treeSearchBox, "RIGHT", bottomBar, "RIGHT", -46, 0)
    end
    if bottomBar.searchLabel then
        bottomBar.searchLabel:SetText("")
        if bottomBar.searchLabel.Hide then
            bottomBar.searchLabel:Hide()
        end
    end

    if bottomBar.levelRestrictionFrame then
        Chrome.ClearAndPoint(bottomBar.levelRestrictionFrame, "TOPLEFT", bottomBar, "TOPLEFT", 0, 0)
        bottomBar.levelRestrictionFrame:SetPoint("BOTTOMRIGHT", bottomBar, "BOTTOMRIGHT", 0, 0)
        Chrome.SetPlainBarBackdrop(bottomBar.levelRestrictionFrame, 0.96)
        Chrome.SetBackdropColor(bottomBar.levelRestrictionFrame, Chrome.BLACK, 0.96)
        bottomBar.levelRestrictionFrame:SetFrameLevel((bottomBar:GetFrameLevel() or 1) + 20)
    end

    if peeOwnedSkillTreeFrame.peeResizeHandle then
        Chrome.ClearAndPoint(peeOwnedSkillTreeFrame.peeResizeHandle, "BOTTOMRIGHT", peeOwnedSkillTreeFrame, "BOTTOMRIGHT",
            -2, 2)
        peeOwnedSkillTreeFrame.peeResizeHandle:SetFrameLevel((peeOwnedSkillTreeFrame:GetFrameLevel() or 1) + 90)
    end
end

function Chrome.RefreshOwnedSkillTreeChrome()
    if not peeOwnedSkillTreeFrame then
        return
    end
    Chrome.RefreshOwnedSkillTreeTopBar()
    Chrome.LayoutOwnedSkillTreeStatusBar(_G.peeOwnedSkillTreeBottomBar)
end


NextRankTooltip = CreateFrame("GameTooltip", "peeOwnedSkillTreeNextRankTooltip", nil,
    "GameTooltipTemplate")
NextRankTooltip:SetOwner(peeOwnedSkillTreeFrame, "ANCHOR_NONE")


CurrentRankTooltip = CreateFrame("GameTooltip", "peeOwnedSkillTreeCurrentRankTooltip",
    nil, "GameTooltipTemplate")
CurrentRankTooltip:SetOwner(peeOwnedSkillTreeFrame, "ANCHOR_NONE")


InfoTooltip = CreateFrame("GameTooltip", "peeOwnedSkillTreeInfoTooltip", nil,
    "GameTooltipTemplate")
InfoTooltip:SetOwner(peeOwnedSkillTreeFrame, "ANCHOR_NONE")
peeOwnedSkillTreeFrame:EnableMouse(true)
peeOwnedSkillTreeFrame:Hide()


loadoutDropdown = nil


local function CreateBottomBar()
    local bottomBar = CreateFrame("Frame", "peeOwnedSkillTreeBottomBar", peeOwnedSkillTreeFrame)
    bottomBar:SetPoint("BOTTOMLEFT", peeOwnedSkillTreeFrame, "BOTTOMLEFT", 8, 5)
    bottomBar:SetPoint("BOTTOMRIGHT", peeOwnedSkillTreeFrame, "BOTTOMRIGHT", -8, 5)
    bottomBar:SetHeight(35)
    bottomBar:SetFrameLevel(peeOwnedSkillTreeFrame:GetFrameLevel() + 10)

    if bottomBar.SetBackdrop then
        bottomBar:SetBackdrop({
            bgFile = "Interface\\Buttons\\WHITE8x8",
            edgeFile = "Interface\\Buttons\\WHITE8x8",
            tile = true, tileSize = 16, edgeSize = 4,
            insets = { left = 4, right = 4, top = 4, bottom = 4 }
        })
        bottomBar:SetBackdropColor(0.039, 0.039, 0.039, GetThemeBackdropOpacity())
        bottomBar:SetBackdropBorderColor(0, 0, 0, 1)
    end


    local soulIcon = bottomBar:CreateTexture(nil, "OVERLAY")
    soulIcon:SetTexture("Interface\\AddOns\\ProjectEbonhold\\assets\\inv_soulash")
    soulIcon:SetSize(16, 16)
    soulIcon:SetPoint("LEFT", bottomBar, "LEFT", 10, 0)
    bottomBar.soulIcon = soulIcon

    local pointsText = bottomBar:CreateFontString(nil, "OVERLAY",
        "GameFontNormal")
    pointsText:SetPoint("LEFT", soulIcon, "RIGHT", 5, 0)
    pointsText:SetText("|cffFFD700Soul Ashes: |r|cffFFFFFF" ..
        GetRemainingTalentPoints() .. "|r")
    peeOwnedSkillTreeFrame.pointsText = pointsText


    local dropdown = CreateFrame("Frame", "peeOwnedSkillTreeLoadoutDropdown", bottomBar,
        "UIDropDownMenuTemplate")
    dropdown:SetPoint("LEFT", pointsText, "RIGHT", 20, -2)
    UIDropDownMenu_SetWidth(dropdown, 150)
    dropdown:Hide()


    UIDropDownMenu_Initialize(dropdown, function(self, level)
        local info = UIDropDownMenu_CreateInfo()


        info.text = "|cff00FF00+ New Build...|r"
        info.func = function()
            StaticPopupDialogs["PEE_SKILLTREE_NEW_BUILD"] = {
                text = "Enter build name:",
                button1 = "Create",
                button2 = "Cancel",
                hasEditBox = true,
                timeout = 0,
                whileDead = true,
                hideOnEscape = true,
                OnAccept = function(self)
                    local name = self.editBox:GetText()
                    if name and name ~= "" then
                        saveCurrentLoadout(name)
                        UIDropDownMenu_SetText(dropdown, name)
                    end
                end,
                EditBoxOnEnterPressed = function(self)
                    local name = self:GetText()
                    if name and name ~= "" then
                        saveCurrentLoadout(name)
                        UIDropDownMenu_SetText(dropdown, name)
                    end
                    self:GetParent():Hide()
                end,
                EditBoxOnEscapePressed = function(self)
                    self:GetParent():Hide()
                end
            }
            StaticPopup_Show("PEE_SKILLTREE_NEW_BUILD")
        end
        UIDropDownMenu_AddButton(info)


        info = UIDropDownMenu_CreateInfo()
        info.text = ""
        info.disabled = true
        info.notCheckable = true
        UIDropDownMenu_AddButton(info)


        local loadouts = getLoadoutsList()
        if #loadouts > 0 then
            for _, name in ipairs(loadouts) do
                info = UIDropDownMenu_CreateInfo()
                info.text = name
                info.func = function()
                    loadLoadout(name, true)
                    UIDropDownMenu_SetText(dropdown, name)
                end
                info.checked = (currentLoadoutName == name)
                UIDropDownMenu_AddButton(info)
            end
        else
            info = UIDropDownMenu_CreateInfo()
            info.text = "|cff888888No saved builds|r"
            info.disabled = true
            info.notCheckable = true
            UIDropDownMenu_AddButton(info)
        end
    end)


    if currentLoadoutName and currentLoadoutName ~= "" then
        UIDropDownMenu_SetText(dropdown, currentLoadoutName)
        DebugPrint("|cff00FF00Dropdown initialized with loadout: " ..
            currentLoadoutName .. "|r")
    else
        UIDropDownMenu_SetText(dropdown, "Select Build")
    end

    loadoutDropdown = dropdown


    applyButton = CreateFrame("Button", "peeOwnedSkillTreeApplyButton", bottomBar,
        "UIPanelButtonTemplate2")
    applyButton:SetSize(130, 22)
    applyButton:SetPoint("LEFT", pointsText, "RIGHT", 22, 2)
    applyButton:SetText("Apply Changes")
    applyButton:SetScript("OnClick", function() ValidateAndSendLoadout() end)
    applyButton:Disable()
    applyButton:GetFontString():SetTextColor(0.5, 0.5, 0.5)


    applyButton.glowTexture = applyButton:CreateTexture(nil, "OVERLAY")
    applyButton.glowTexture:SetTexture(
        "Interface\\Buttons\\UI-Panel-Button-Glow")
    applyButton.glowTexture:SetPoint("CENTER", applyButton, "CENTER", 25, -10)
    applyButton.glowTexture:SetSize(200, 50)
    applyButton.glowTexture:SetAlpha(0)
    applyButton.glowTexture:SetBlendMode("ADD")
    applyButton.glowTexture:SetVertexColor(1, 1, 0.5)


    applyButton.glowTimer = 0
    applyButton.glowDirection = 1



    validateBtn = applyButton


    local progressBarWidth = 550
    local progressBarHeight = 42
    local progressFrame = CreateFrame("Frame", nil, peeOwnedSkillTreeFrame)
    progressFrame:SetSize(progressBarWidth, progressBarHeight)
    progressFrame:SetPoint("TOP", peeOwnedSkillTreeFrame, "TOP", 0, -15)
    progressFrame:SetFrameLevel(peeOwnedSkillTreeFrame:GetFrameLevel() + 15)


    local milestoneData = ProjectEbonhold.SoulAshesMilestones or {}


    local milestones = {}
    local milestoneSpellIDs = {}
    for i, data in ipairs(milestoneData) do
        if type(data) == "table" then
            milestones[i] = data.soulAshes
            milestoneSpellIDs[i] = data.spellID
        elseif type(data) == "number" then
            milestones[i] = data
        end
    end


    local barTexWidth = 512 * (0.978516 - 0.015625)
    local barTexHeight = 512 * (0.113281 - 0.031250)


    local barBg = progressFrame:CreateTexture(nil, "BACKGROUND")
    barBg:SetTexture("Interface\\AddOns\\ProjectEbonhold\\assets\\progression_bar")
    barBg:SetTexCoord(0.015625, 0.978516, 0.031250, 0.113281)
    barBg:SetSize(progressBarWidth, barTexHeight)
    barBg:SetPoint("CENTER", progressFrame, "CENTER", 0, 0)

    local fillInsetLeft = 18
    local fillInsetRight = 38
    local maxFillWidth = progressBarWidth - fillInsetLeft - fillInsetRight

    local fillBar = progressFrame:CreateTexture(nil, "ARTWORK")
    fillBar:SetTexture("Interface\\AddOns\\ProjectEbonhold\\assets\\progression_bar")
    fillBar:SetTexCoord(0.021484, 0.435547, 0.201172, 0.230469)
    fillBar:SetPoint("LEFT", barBg, "LEFT", fillInsetLeft, 2)
    fillBar:SetHeight(barTexHeight - 25)
    progressFrame.fillBar = fillBar


    local progressText = progressFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    progressText:SetPoint("CENTER", progressFrame, "CENTER", 0, 0)
    progressText:SetTextColor(1, 1, 1)
    progressFrame.progressText = progressText


    local iconSize = 28
    local spellButton = CreateFrame("Button", nil, progressFrame)
    spellButton:SetSize(iconSize, iconSize)
    spellButton:SetPoint("LEFT", progressFrame, "RIGHT", -40, 0)


    local spellIcon = spellButton:CreateTexture(nil, "BACKGROUND")
    spellIcon:SetAllPoints(spellButton)
    progressFrame.spellIcon = spellIcon


    local lightTexture = spellButton:CreateTexture(nil, "ARTWORK")
    lightTexture:SetTexture("Interface\\AddOns\\ProjectEbonhold\\assets\\progression_bar")
    lightTexture:SetTexCoord(0.023438, 0.210938, 0.283203, 0.478516)
    lightTexture:SetSize(iconSize + 32, iconSize + 32)
    lightTexture:SetPoint("CENTER", spellButton, "CENTER", 0, 0)
    lightTexture:SetBlendMode("ADD")


    local borderRound = spellButton:CreateTexture(nil, "OVERLAY")
    borderRound:SetTexture("Interface\\AddOns\\ProjectEbonhold\\assets\\progression_bar")
    borderRound:SetTexCoord(0.214844, 0.322266, 0.314453, 0.427734)
    borderRound:SetSize(iconSize + 16, iconSize + 16)
    borderRound:SetPoint("CENTER", spellButton, "CENTER", 0, 0)


    local animGroup = lightTexture:CreateAnimationGroup()
    local rotation = animGroup:CreateAnimation("Rotation")
    rotation:SetDegrees(360)
    rotation:SetDuration(8)
    animGroup:SetLooping("REPEAT")
    animGroup:Play()


    progressFrame.currentSpellID = 71


    spellButton:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:SetHyperlink('spell:' .. progressFrame.currentSpellID)
        GameTooltip:Show()
    end)

    spellButton:SetScript("OnLeave", function(self)
        GameTooltip:Hide()
    end)


    local function UpdateProgressBar()
        local currentTotal = TALENT_POINT_TOTAL_BASE
        local currentMilestoneIndex = 0
        local previousMilestone = 0
        local nextMilestone = milestones[1] or ProjectEbonhold.Constants.MAX_SOUL_ASHES
        local hasReachedLastMilestone = false


        for i, milestone in ipairs(milestones) do
            if currentTotal >= milestone then
                currentMilestoneIndex = i
                previousMilestone = milestone
                if milestones[i + 1] then
                    nextMilestone = milestones[i + 1]
                else
                    nextMilestone = ProjectEbonhold.Constants.MAX_SOUL_ASHES
                    hasReachedLastMilestone = true
                end
            else
                break
            end
        end





        local spellIDIndex = currentMilestoneIndex + 1
        if spellIDIndex > #milestoneSpellIDs then
            spellIDIndex = #milestoneSpellIDs
        end
        local currentSpellID = milestoneSpellIDs[spellIDIndex] or 71
        progressFrame.currentSpellID = currentSpellID


        if hasReachedLastMilestone then
            spellButton:Hide()
        else
            spellButton:Show()
            local _, _, iconTexture = GetSpellInfo(currentSpellID)
            spellIcon:SetTexture(iconTexture or "Interface\\Icons\\INV_Misc_QuestionMark")
        end


        local milestoneProgress = 0
        if hasReachedLastMilestone then
            milestoneProgress = currentTotal / ProjectEbonhold.Constants.MAX_SOUL_ASHES
        elseif nextMilestone > previousMilestone then
            milestoneProgress = (currentTotal - previousMilestone) / (nextMilestone - previousMilestone)
        end



        local fillWidth = maxFillWidth * math.min(milestoneProgress, 1)



        if fillWidth > 0 then
            fillBar:SetWidth(fillWidth)
            fillBar:Show()
        else
            fillBar:Hide()
        end


        progressText:SetText(currentTotal .. "/" .. nextMilestone)


        progressFrame.currentMilestoneIndex = currentMilestoneIndex
        progressFrame.nextMilestone = nextMilestone
        progressFrame.currentTotal = currentTotal
        progressFrame.previousMilestone = previousMilestone
        if Chrome.RefreshOwnedSkillTreeChrome then
            Chrome.RefreshOwnedSkillTreeChrome()
        end
    end
    progressFrame.UpdateProgressBar = UpdateProgressBar


    progressFrame:EnableMouse(true)
    progressFrame:SetScript("OnEnter", function(self)
        local maxSoulAshes = ProjectEbonhold.Constants.MAX_SOUL_ASHES
        local currentTotal = self.currentTotal or TALENT_POINT_TOTAL_BASE
        local nextMilestone = self.nextMilestone or maxSoulAshes
        local previousMilestone = self.previousMilestone or 0
        local currentMilestoneIndex = self.currentMilestoneIndex or 0

        InfoTooltip:SetOwner(self, "ANCHOR_TOP")
        InfoTooltip:SetText("Soul Ashes Progression", 1, 0.82, 0)


        if currentMilestoneIndex < #milestones then
            InfoTooltip:AddLine("Earn Soul Ashes to advance toward your next milestone.", 0.9, 0.9, 0.9, true)
            InfoTooltip:AddLine(" ", 1, 1, 1)

            InfoTooltip:AddLine(
                "Current Milestone: " .. currentTotal .. " / " .. nextMilestone,
                1, 1, 1
            )
            InfoTooltip:AddLine(" ", 1, 1, 1)
        else
            InfoTooltip:AddLine("All milestones completed! Progress toward the maximum cap.", 0, 1, 0, true)
            InfoTooltip:AddLine(" ", 1, 1, 1)
        end


        InfoTooltip:AddLine(
            "Soul Ashes have an maximum cap (" .. currentTotal .. " / " .. maxSoulAshes ..
            "). Once the cap is reached, you will no longer be able to commit Soul Ashes in your Skill Tree.",
            0.7, 0.7, 0.7, true
        )

        InfoTooltip:Show()
    end)

    progressFrame:SetScript("OnLeave", function(self)
        InfoTooltip:Hide()
    end)


    UpdateProgressBar()


    peeOwnedSkillTreeFrame.progressBar = progressFrame
    progressFrame:Hide()
    progressFrame:SetAlpha(0)
    progressFrame:EnableMouse(false)


    local castMonitorFrame = CreateFrame("Frame")
    castMonitorFrame:RegisterEvent("UNIT_SPELLCAST_START")
    castMonitorFrame:RegisterEvent("UNIT_SPELLCAST_STOP")
    castMonitorFrame:RegisterEvent("UNIT_SPELLCAST_FAILED")
    castMonitorFrame:RegisterEvent("UNIT_SPELLCAST_INTERRUPTED")
    castMonitorFrame:RegisterEvent("UNIT_SPELLCAST_CHANNEL_START")
    castMonitorFrame:RegisterEvent("UNIT_SPELLCAST_CHANNEL_STOP")

    castMonitorFrame:SetScript("OnEvent", function(self, event, unit)
        if unit ~= "player" or not applyButton then return end

        local isCasting = UnitCastingInfo("player") or UnitChannelInfo("player")

        if isCasting then
            applyButton:Disable()
            applyButton:GetFontString():SetTextColor(0.5, 0.5, 0.5)
        else
            if hasUnsavedChanges and HasRealChanges() then
                local remainingPoints = GetRemainingTalentPoints()
                if remainingPoints >= 0 then
                    applyButton:Enable()
                    applyButton:GetFontString():SetTextColor(1, 1, 1)
                end
            end
        end
    end)


    local applyBtnTooltipFrame = CreateFrame("Frame", nil, applyButton)
    applyBtnTooltipFrame:SetAllPoints(applyButton)
    applyBtnTooltipFrame:SetFrameLevel(applyButton:GetFrameLevel() + 1)
    applyBtnTooltipFrame:EnableMouse(true)


    applyBtnTooltipFrame:SetScript("OnEnter", function(self)
        Chrome.SetBackdropColor(applyButton, Chrome.RED_HOVER, 0.96)
        Chrome.SetBorderColor(applyButton, Chrome.RED_HOVER_BORDER)
        local remainingPoints = GetRemainingTalentPoints()
        InfoTooltip:SetOwner(self, "ANCHOR_TOP")

        if remainingPoints < 0 then
            InfoTooltip:SetText("Apply Changes", 1, 1, 1)
            InfoTooltip:AddLine(
                "You don't have enough Soul Ashes to apply this build", 1, 0.3,
                0.3, true)
            InfoTooltip:AddLine("Overspent by: " .. math.abs(remainingPoints),
                0.8, 0.8, 0.8)
        else
            if hasUnsavedChanges then
                InfoTooltip:SetText("Apply Changes", 1, 1, 1)
                InfoTooltip:AddLine("Send your soul build to the server", 0.8,
                    0.8, 0.8, true)
                InfoTooltip:AddLine(
                    "Remaining Soul Ashes: " .. remainingPoints, 0.8, 0.8, 0.8)
            else
                InfoTooltip:SetText("Apply Changes", 0.5, 0.5, 0.5)
                InfoTooltip:AddLine("No changes to apply", 0.6, 0.6, 0.6, true)
            end
        end

        InfoTooltip:Show()
    end)

    applyBtnTooltipFrame:SetScript("OnLeave",
        function(self)
            Chrome.SetBackdropColor(applyButton, Chrome.RED, 0.92)
            Chrome.SetBorderColor(applyButton, Chrome.BLACK)
            InfoTooltip:Hide()
        end)


    applyBtnTooltipFrame:SetScript("OnMouseDown", function(self, button)
        if button == "LeftButton" and applyButton:IsEnabled() then
            applyButton:Click()
        end
    end)


    local exportBtn = CreateFrame("Button", "peeOwnedSkillTreeExportButton", bottomBar,
        "UIPanelButtonTemplate")
    exportBtn:SetSize(80, 25)
    exportBtn:SetPoint("LEFT", applyButton, "RIGHT", 5, 0)
    exportBtn:SetText("Export")
    exportBtn:Hide()
    bottomBar.exportButton = exportBtn
    exportBtn:SetScript("OnClick", function()
        if not HasAnyTalents() then
            StaticPopupDialogs["PEE_SKILLTREE_EXPORT_EMPTY"] = {
                text = "No talents selected to export!",
                button1 = "OK",
                timeout = 0,
                whileDead = true,
                hideOnEscape = true
            }
            StaticPopup_Show("PEE_SKILLTREE_EXPORT_EMPTY")
            return
        end


        local exportCode = ExportLoadoutToCode()


        StaticPopupDialogs["PEE_SKILLTREE_EXPORT_CODE"] = {
            text = "Build Export Code:\n\n|cffFFD700Copy the code below:|r",
            button1 = "Close",
            hasEditBox = true,
            timeout = 0,
            whileDead = true,
            hideOnEscape = true,
            editBoxWidth = 350,
            OnShow = function(self)
                self.editBox:SetText(exportCode)
                self.editBox:HighlightText()
                self.editBox:SetFocus()
            end,
            EditBoxOnEnterPressed = function(self)
                self:GetParent():Hide()
            end,
            EditBoxOnEscapePressed = function(self)
                self:GetParent():Hide()
            end
        }
        StaticPopup_Show("PEE_SKILLTREE_EXPORT_CODE")
    end)


    local importBtn = CreateFrame("Button", "peeOwnedSkillTreeImportButton", bottomBar,
        "UIPanelButtonTemplate")
    importBtn:SetSize(80, 25)
    importBtn:SetPoint("LEFT", exportBtn, "RIGHT", 5, 0)
    importBtn:SetText("Import")
    importBtn:Hide()
    bottomBar.importButton = importBtn
    importBtn:SetScript("OnClick", function()
        StaticPopupDialogs["PEE_SKILLTREE_IMPORT_CODE"] = {
            text = "Import Build Code:\n\n|cffFFD700Paste your build code below:|r",
            button1 = "Import",
            button2 = "Cancel",
            hasEditBox = true,
            timeout = 0,
            whileDead = true,
            hideOnEscape = true,
            editBoxWidth = 350,
            OnAccept = function(self)
                local code = self.editBox:GetText()
                if code and code ~= "" then
                    local nodes, error = ImportLoadoutFromCode(code)
                    if nodes then
                        local success, applyError = ApplyImportedLoadout(nodes)
                        if success then
                            DebugPrint(
                                "|cff00FF00Build imported successfully! (" ..
                                #nodes .. " talents)|r")
                        else
                            StaticPopupDialogs["PEE_SKILLTREE_IMPORT_ERROR"] = {
                                text = "Import failed:\n\n|cffFF0000" ..
                                    (applyError or "Failed to apply build") ..
                                    "|r",
                                button1 = "OK",
                                timeout = 0,
                                whileDead = true,
                                hideOnEscape = true
                            }
                            StaticPopup_Show("PEE_SKILLTREE_IMPORT_ERROR")
                        end
                    else
                        StaticPopupDialogs["PEE_SKILLTREE_IMPORT_ERROR"] = {
                            text = "Import failed:\n\n|cffFF0000" ..
                                (error or "Unknown error") .. "|r",
                            button1 = "OK",
                            timeout = 0,
                            whileDead = true,
                            hideOnEscape = true
                        }
                        StaticPopup_Show("PEE_SKILLTREE_IMPORT_ERROR")
                    end
                end
            end,
            EditBoxOnEnterPressed = function(self)
                local code = self:GetText()
                if code and code ~= "" then
                    local nodes, error = ImportLoadoutFromCode(code)
                    if nodes then
                        local success, applyError = ApplyImportedLoadout(nodes)
                        if success then
                            DebugPrint(
                                "|cff00FF00Build imported successfully! (" ..
                                #nodes .. " talents)|r")
                        else
                            StaticPopupDialogs["PEE_SKILLTREE_IMPORT_ERROR"] = {
                                text = "Import failed:\n\n|cffFF0000" ..
                                    (applyError or "Failed to apply build") ..
                                    "|r",
                                button1 = "OK",
                                timeout = 0,
                                whileDead = true,
                                hideOnEscape = true
                            }
                            StaticPopup_Show("PEE_SKILLTREE_IMPORT_ERROR")
                        end
                    else
                        StaticPopupDialogs["PEE_SKILLTREE_IMPORT_ERROR"] = {
                            text = "Import failed:\n\n|cffFF0000" ..
                                (error or "Unknown error") .. "|r",
                            button1 = "OK",
                            timeout = 0,
                            whileDead = true,
                            hideOnEscape = true
                        }
                        StaticPopup_Show("PEE_SKILLTREE_IMPORT_ERROR")
                    end
                end
                self:GetParent():Hide()
            end,
            EditBoxOnEscapePressed = function(self)
                self:GetParent():Hide()
            end
        }
        StaticPopup_Show("PEE_SKILLTREE_IMPORT_CODE")
    end)


    local revertBtn = CreateFrame("Button", nil, bottomBar)
    revertBtn:SetSize(25, 25)
    revertBtn:SetPoint("RIGHT", bottomBar, "RIGHT", -10, 0)
    revertBtn:SetScript("OnClick", function() RevertToValidatedState() end)


    local revertIcon = revertBtn:CreateTexture(nil, "ARTWORK")
    revertIcon:SetTexture("Interface\\Buttons\\UI-RefreshButton")
    revertIcon:SetSize(20, 20)
    revertIcon:SetPoint("CENTER", revertBtn, "CENTER", 0, 0)

    revertBtn:Disable()
    revertIcon:SetDesaturated(true)
    revertIcon:SetAlpha(0.5)


    revertBtn.icon = revertIcon


    revertBtn:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_TOP")
        GameTooltip:SetText("Revert Changes", 1, 1, 1)
        GameTooltip:AddLine("Undo all changes since last validation", 0.8, 0.8,
            0.8, true)
        GameTooltip:Show()
    end)
    revertBtn:SetScript("OnLeave", function() GameTooltip:Hide() end)


    _G.revertBtn = revertBtn


    StaticPopupDialogs["PEE_SKILLTREE_CONFIRM_RESET"] = {
        text = "Reset all non-permanent skill nodes?\n\nPermanent nodes will be kept. You must click Apply Changes to save.",
        button1 = "Reset",
        button2 = "Cancel",
        OnAccept = function()
            resetNonPermanentNodes()
        end,
        timeout = 0,
        whileDead = true,
        hideOnEscape = true,
        preferredIndex = 3,
    }

    local resetBtn = CreateFrame("Button", nil, bottomBar, "UIPanelButtonTemplate")
    resetBtn:SetSize(60, 22)
    resetBtn:SetPoint("LEFT", applyButton, "RIGHT", 8, 0)
    resetBtn:SetText("Reset")
    resetBtn:GetFontString():SetFont("Fonts\\FRIZQT__.TTF", 9, "OUTLINE")
    resetBtn:SetScript("OnClick", function()
        local popup = StaticPopup_Show("PEE_SKILLTREE_CONFIRM_RESET")
        if popup then popup:SetFrameStrata("TOOLTIP") end
    end)
    resetBtn:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_TOP")
        GameTooltip:SetText("Reset Skills", 1, 0.3, 0.3)
        GameTooltip:AddLine("Remove all non-permanent skill nodes.", 0.8, 0.8, 0.8, true)
        GameTooltip:AddLine(" ")
        GameTooltip:AddLine("Permanent nodes cannot be reset.", 1, 0.5, 0.5, true)
        GameTooltip:Show()
    end)
    resetBtn:SetScript("OnLeave", function() GameTooltip:Hide() end)
    bottomBar.resetButton = resetBtn


    local profileBtn = CreateFrame("Button", nil, bottomBar, "UIPanelButtonTemplate")
    profileBtn:SetSize(70, 22)
    profileBtn:SetPoint("LEFT", resetBtn, "RIGHT", 4, 0)
    profileBtn:SetText("Profiles")
    profileBtn:GetFontString():SetFont("Fonts\\FRIZQT__.TTF", 9, "OUTLINE")
    profileBtn:SetScript("OnClick", function()
        ToggleProfileFrame()
    end)
    profileBtn:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_TOP")
        GameTooltip:SetText("Profiles", 1, 0.82, 0)
        GameTooltip:AddLine("Save and load skill tree builds.", 0.8, 0.8, 0.8, true)
        GameTooltip:Show()
    end)
    profileBtn:SetScript("OnLeave", function() GameTooltip:Hide() end)
    bottomBar.profileButton = profileBtn


    local levelRestrictionFrame = CreateFrame("Frame", nil, bottomBar)
    levelRestrictionFrame:SetPoint("TOPLEFT", bottomBar, "TOPLEFT", 0, 0)
    levelRestrictionFrame:SetPoint("BOTTOMRIGHT", bottomBar, "BOTTOMRIGHT", 0, 0)
    levelRestrictionFrame:SetFrameLevel(bottomBar:GetFrameLevel() + 20)
    levelRestrictionFrame:SetBackdrop({
        bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
        tile = true,
        tileSize = 32,
        insets = { left = 0, right = 0, top = 0, bottom = 0 }
    })
    levelRestrictionFrame:SetBackdropColor(0.039, 0.039, 0.039, GetThemeBackdropOpacity())
    levelRestrictionFrame:EnableMouse(true)
    levelRestrictionFrame:Hide()

    local levelRestrictionText = levelRestrictionFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    levelRestrictionText:SetPoint("CENTER", levelRestrictionFrame, "CENTER", 0, 0)
    levelRestrictionText:SetText("|cffFF0000You cannot modify your skill tree while in combat|r")


    local function UpdateCombatRestriction()
        local inCombat = UnitAffectingCombat("player")

        if inCombat then
            levelRestrictionFrame:Show()
        else
            levelRestrictionFrame:Hide()
        end
    end


    local combatCheckFrame = CreateFrame("Frame")
    combatCheckFrame:RegisterEvent("PLAYER_REGEN_DISABLED")
    combatCheckFrame:RegisterEvent("PLAYER_REGEN_ENABLED")
    combatCheckFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
    combatCheckFrame:SetScript("OnEvent", function(self, event)
        UpdateCombatRestriction()
    end)


    bottomBar.levelRestrictionFrame = levelRestrictionFrame
    bottomBar.updateCombatRestriction = UpdateCombatRestriction

    if not treeSearchBox then
        local treeSearchLabel = bottomBar:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        treeSearchLabel:SetText("")
        treeSearchLabel:Hide()
        bottomBar.searchLabel = treeSearchLabel

        treeSearchBox = CreateFrame("EditBox", "peeOwnedSkillTreeSearchBox", bottomBar, "InputBoxTemplate")
        treeSearchBox:SetSize(Chrome.STATUS_SEARCH_WIDTH, 24)
        treeSearchBox:SetAutoFocus(false)
        treeSearchBox:SetMaxLetters(50)
        treeSearchBox:SetFrameLevel(bottomBar:GetFrameLevel() + 5)
        treeSearchBox:SetTextInsets(8, 18, 0, 0)

        local clearBtn = CreateFrame("Button", nil, treeSearchBox)
        clearBtn:SetSize(14, 14)
        clearBtn:SetPoint("RIGHT", treeSearchBox, "RIGHT", -4, 0)
        clearBtn:SetFrameLevel(treeSearchBox:GetFrameLevel() + 1)
        clearBtn.text = clearBtn:CreateFontString(nil, "OVERLAY")
        clearBtn.text:SetFont("Fonts\\FRIZQT__.TTF", 12, "OUTLINE")
        clearBtn.text:SetPoint("CENTER", clearBtn, "CENTER", 0, 0)
        clearBtn.text:SetText("X")
        clearBtn.text:SetTextColor(0.7, 0.7, 0.7)
        clearBtn:SetScript("OnEnter", function(self)
            self.text:SetTextColor(1, 0.4, 0.4)  -- red on hover
        end)
        clearBtn:SetScript("OnLeave", function(self)
            self.text:SetTextColor(0.7, 0.7, 0.7)
        end)
        clearBtn:SetScript("OnClick", function()
            treeSearchBox:SetText("")
            treeSearchBox:ClearFocus()
            FilterTreeNodes("")
        end)
        clearBtn:Hide()
        treeSearchBox.clearBtn = clearBtn

        treeSearchBox:SetScript("OnTextChanged", function(self)
            local txt = self:GetText()
            FilterTreeNodes(txt)
            if self.clearBtn then
                if txt == "" then self.clearBtn:Hide() else self.clearBtn:Show() end
            end
        end)
        treeSearchBox:SetScript("OnEscapePressed", function(self)
            self:SetText("")
            self:ClearFocus()
            FilterTreeNodes("")
        end)
    end

    Chrome.LayoutOwnedSkillTreeStatusBar(bottomBar)
    Chrome.RefreshOwnedSkillTreeTopBar()
    hasUnsavedChanges = false
end


local Scroll = CreateFrame("ScrollFrame", "peeOwnedSkillTreeScroll", peeOwnedSkillTreeFrame)
Scroll:SetPoint("TOPLEFT", 10, -40)
Scroll:SetPoint("BOTTOMRIGHT", -10, 42)
Scroll:EnableMouse(true)
Scroll:EnableMouseWheel(true)


local Canvas = CreateFrame("Frame", "peeOwnedSkillTreeCanvas", Scroll)
Scroll:SetScrollChild(Canvas)


local zoomLevel = 1.0
local MIN_ZOOM = 0.15
local MAX_ZOOM = 2.0

local ClampScrollToTreeBounds
local ZOOM_STEP = 0.1


local ComputeLayout


local function ApplyZoom(scale)
    zoomLevel = math.max(MIN_ZOOM, math.min(MAX_ZOOM, scale))
    Canvas:SetScale(zoomLevel)


    ComputeLayout()


    if not peeOwnedSkillTreeFrame.zoomText then
        peeOwnedSkillTreeFrame.zoomText = peeOwnedSkillTreeFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
        peeOwnedSkillTreeFrame.zoomText:SetPoint("TOPLEFT", nodeStatsFrame, "BOTTOMLEFT", 0, -2)
        peeOwnedSkillTreeFrame.zoomText:SetJustifyH("LEFT")
    end
    peeOwnedSkillTreeFrame.zoomText:SetText(string.format("Zoom: %d%%", zoomLevel * 100))


    local currentTime = GetTime()
    peeOwnedSkillTreeFrame.zoomTimestamp = currentTime
    C_Timer.After(1, function()
        if peeOwnedSkillTreeFrame.zoomText and peeOwnedSkillTreeFrame.zoomTimestamp == currentTime then
            peeOwnedSkillTreeFrame.zoomText:SetText("")
        end
    end)
end


local _pendingZoomDelta = 0
local _pendingZoomAnchor = nil
local _zoomFlushScheduled = false
local _zoomSettleToken = 0

local function FlushZoom()
    _zoomFlushScheduled = false
    if _pendingZoomDelta == 0 or not _pendingZoomAnchor then
        _pendingZoomDelta = 0
        _pendingZoomAnchor = nil
        return
    end
    local anchor = _pendingZoomAnchor
    local delta = _pendingZoomDelta
    _pendingZoomDelta = 0
    _pendingZoomAnchor = nil

    _setViewportCulling(true)

    local newZoom = anchor.preZoom + (delta * ZOOM_STEP)
    ApplyZoom(newZoom)

    local newScrollX = anchor.worldX - anchor.cursorRelX / zoomLevel
    local newScrollY = anchor.worldY - anchor.cursorRelY / zoomLevel
    local clampedX, clampedY = ClampScrollToTreeBounds(newScrollX, newScrollY)
    Scroll:SetHorizontalScroll(clampedX)
    Scroll:SetVerticalScroll(clampedY)

    _zoomSettleToken = _zoomSettleToken + 1
    local myToken = _zoomSettleToken
    C_Timer.After(0.15, function()
        if _zoomSettleToken ~= myToken then return end
        _setViewportCulling(false)
    end)
end

Scroll:SetScript("OnMouseWheel", function(self, delta)
    if not _pendingZoomAnchor then
        local cursorX, cursorY = GetCursorPosition()
        local effectiveScale = self:GetEffectiveScale()
        cursorX = cursorX / effectiveScale
        cursorY = cursorY / effectiveScale

        local scrollLeft = self:GetLeft() or 0
        local scrollTop = self:GetTop() or 0
        local cursorRelX = cursorX - scrollLeft
        local cursorRelY = scrollTop - cursorY  -- WoW Y axis flipped vs cursor

        local preScrollX = self:GetHorizontalScroll()
        local preScrollY = self:GetVerticalScroll()
        local preZoom = zoomLevel

        _pendingZoomAnchor = {
            cursorRelX = cursorRelX,
            cursorRelY = cursorRelY,
            preZoom = preZoom,
            worldX = preScrollX + cursorRelX / preZoom,
            worldY = preScrollY + cursorRelY / preZoom,
        }
    end
    _pendingZoomDelta = _pendingZoomDelta + delta

    if not _zoomFlushScheduled then
        _zoomFlushScheduled = true
        C_Timer.After(0, FlushZoom)
    end
end)




local _baseCanvasW, _baseCanvasH

local function LayoutNodePositions()
    local NODE_SIZE = 1

    local minX, maxX, minY, maxY
    for _, n in ipairs(TreeNodes) do
        if not minX or n.x < minX then minX = n.x end
        if not maxX or n.x > maxX then maxX = n.x end
        if not minY or n.y < minY then minY = n.y end
        if not maxY or n.y > maxY then maxY = n.y end
    end

    local margin = 2000
    local SPACING_SCALE = 0.8
    local scaledWidth = (maxX - minX) * SPACING_SCALE
    local scaledHeight = (maxY - minY) * SPACING_SCALE
    _baseCanvasW = scaledWidth + NODE_SIZE + margin * 2
    _baseCanvasH = scaledHeight + NODE_SIZE + margin * 2

    for _, n in ipairs(TreeNodes) do
        n._ox = margin + (n.x - minX) * SPACING_SCALE
        n._oy = -(margin + (maxY - n.y) * SPACING_SCALE)
    end
end

ComputeLayout = function()
    if not _baseCanvasW then
        LayoutNodePositions()
    end

    local zoomCompensation = 1 / zoomLevel
    Canvas:SetSize(_baseCanvasW * zoomCompensation, _baseCanvasH * zoomCompensation)

end

local function GetTreeBBox()
    local minX, maxX, minY, maxY
    for _, n in ipairs(TreeNodes) do
        local btn = nodesById[n.id]
        if btn and btn:IsShown() and n._ox and n._oy then
            local ox = n._ox
            local oy = n._oy
            local w = btn:GetWidth() or 28
            local h = btn:GetHeight() or 28
            local left, right = ox, ox + w
            local top, bottom = oy, oy - h
            if not minX or left < minX then minX = left end
            if not maxX or right > maxX then maxX = right end
            if not maxY or top > maxY then maxY = top end
            if not minY or bottom < minY then minY = bottom end
        end
    end
    return minX, maxX, minY, maxY
end


local PADDING_RATIO = 0.05  -- 5% padding on each side of the tree
local TOP_INSET = 0         -- Scroll now physically anchored below the progress bar; no overlay to compensate for

local PAN_SLACK_PX = 200

ClampScrollToTreeBounds = function(h, v)
    local minX, maxX, minY, maxY = GetTreeBBox()
    local zoom = (zoomLevel and zoomLevel > 0) and zoomLevel or 1
    local viewW = Scroll:GetWidth() or 0
    local viewH = Scroll:GetHeight() or 0

    if not minX or viewW <= 0 or viewH <= 0 then
        local cW = Canvas:GetWidth() or 0
        local cH = Canvas:GetHeight() or 0
        local lMaxH = math.max(0, cW - viewW / zoom)
        local lMaxV = math.max(0, cH - viewH / zoom)
        if h < 0 then h = 0 elseif h > lMaxH then h = lMaxH end
        if v < 0 then v = 0 elseif v > lMaxV then v = lMaxV end
        return h, v
    end

    local slack = PAN_SLACK_PX / zoom
    local treeW = maxX - minX
    local treeH = maxY - minY
    local viewWLogical = viewW / zoom
    local viewHLogical = viewH / zoom

    local minH, maxH, minV, maxV

    if treeW <= viewWLogical then
        local centerH = (minX + maxX) / 2 - viewW / (2 * zoom)
        minH, maxH = centerH - slack, centerH + slack
    else
        minH = minX - slack
        maxH = maxX - viewW / zoom + slack
    end

    if treeH <= viewHLogical then
        local centerV = -(minY + maxY) / 2 - (TOP_INSET + viewH) / (2 * zoom)
        minV, maxV = centerV - slack, centerV + slack
    else
        minV = -maxY - slack
        maxV = -minY - viewH / zoom + slack
    end

    if h < minH then h = minH elseif h > maxH then h = maxH end
    if v < minV then v = minV elseif v > maxV then v = maxV end
    return h, v
end

local function CenterScrollView()
    Scroll:UpdateScrollChildRect()

    local minX, maxX, minY, maxY = GetTreeBBox()
    if not minX then
        minX, maxX = 0, Canvas:GetWidth() or 0
        local h = Canvas:GetHeight() or 0
        minY, maxY = -h, 0
    end

    local treeCenterX = (minX + maxX) / 2
    local treeCenterY = (minY + maxY) / 2

    local viewportW = Scroll:GetWidth() or 0
    local viewportH = Scroll:GetHeight() or 0
    local zoom = zoomLevel
    if zoom <= 0 then zoom = 1 end

    local scrollH = treeCenterX - viewportW / (2 * zoom)

    local scrollV = -treeCenterY - (TOP_INSET + viewportH) / (2 * zoom)

    scrollH, scrollV = ClampScrollToTreeBounds(scrollH, scrollV)

    Scroll:SetHorizontalScroll(scrollH)
    Scroll:SetVerticalScroll(scrollV)
end

local function ComputeFitZoom()
    local minX, maxX, minY, maxY = GetTreeBBox()
    if not minX then return nil end
    local treeW = maxX - minX
    local treeH = maxY - minY
    if treeW <= 0 or treeH <= 0 then return nil end
    local viewW = Scroll:GetWidth() or 0
    local viewH = (Scroll:GetHeight() or 0) - TOP_INSET
    if viewW <= 0 or viewH <= 0 then return nil end
    local availW = viewW * (1 - 2 * PADDING_RATIO)
    local availH = viewH * (1 - 2 * PADDING_RATIO)
    local fitX = availW / treeW
    local fitY = availH / treeH
    return math.min(fitX, fitY)
end

local function FitAndCenterTree()
    if not nodesById or not next(nodesById) then return end
    Scroll:UpdateScrollChildRect()

    local fitZoom = ComputeFitZoom()
    if fitZoom then
        fitZoom = math.max(MIN_ZOOM, math.min(MAX_ZOOM, fitZoom))
        if math.abs(zoomLevel - fitZoom) > 0.001 then
            zoomLevel = fitZoom
            Canvas:SetScale(zoomLevel)
            local zoomCompensation = 1 / zoomLevel
            Canvas:SetSize(_baseCanvasW * zoomCompensation, _baseCanvasH * zoomCompensation)
            Scroll:UpdateScrollChildRect()
        end
    end

    CenterScrollView()
end

local function ScheduleFitAndCenterTree()
    FitAndCenterTree()
    C_Timer.After(0,     FitAndCenterTree)
    C_Timer.After(0.05,  FitAndCenterTree)
    C_Timer.After(0.15,  FitAndCenterTree)
    C_Timer.After(0.30,  FitAndCenterTree)
end

ProjectEbonhold.SkillTree = ProjectEbonhold.SkillTree or {}
ProjectEbonhold.SkillTree.FitAndCenterTree = FitAndCenterTree

Scroll:SetScript("OnShow", FitAndCenterTree)

local function applyNodeVisual(btn)
    if btn.isApex then
        if not btn.apexBorderTexture then
            btn.apexBorderTexture = btn:CreateTexture(nil, "OVERLAY")
            btn.apexBorderTexture:SetTexture(
                "Interface\\Buttons\\UI-ActionButton-Border")
            btn.apexBorderTexture:SetBlendMode("ADD")
            btn.apexBorderTexture:SetPoint("TOPLEFT", btn, "TOPLEFT", -16, 16)
            btn.apexBorderTexture:SetPoint("BOTTOMRIGHT", btn, "BOTTOMRIGHT",
                16, -16)
            btn.apexBorderTexture:SetVertexColor(1.0, 0.2, 1.0, 0.8)
        end


        btn.apexBorderTexture:Show()
        btn.borderTex:SetVertexColor(unpack(COLOR_APEX))
    end

    if btn.state == "active" then
        local currentRank = nodeRanks[btn.id] or 0
        local maxRank = #btn.spells or 0

        if currentRank >= maxRank then
            btn.borderTex:SetVertexColor(unpack(COLOR_ORANGE))
        else
            btn.borderTex:SetVertexColor(unpack(COLOR_GREEN))
        end
        btn.icon:SetDesaturated(false)
        btn.icon:SetAlpha(1.0)
    elseif btn.state == "ready" then
        btn.borderTex:SetVertexColor(unpack(COLOR_GREEN))
        btn.icon:SetDesaturated(false)
        btn.icon:SetAlpha(1.0)
    elseif btn.state == "nopoints" then
        btn.borderTex:SetVertexColor(1.0, 0.82, 0.0, 1.0)
        btn.icon:SetDesaturated(true)
        btn.icon:SetAlpha(0.85)
    else
        btn.borderTex:SetVertexColor(unpack(COLOR_GRAY))
        btn.icon:SetDesaturated(true)
        btn.icon:SetAlpha(0.7)
    end


    if not btn.rankText then
        btn.rankText = btn:CreateFontString(nil, "OVERLAY",
            "GameFontNormalSmall")
        btn.rankText:SetPoint("BOTTOMRIGHT", btn, "BOTTOMRIGHT", -2, 2)

        local fontName, fontSize = btn.rankText:GetFont()
        btn.rankText:SetFont(fontName, 9, "OUTLINE")
    end

    local currentRank = nodeRanks[btn.id] or 0


    if btn.state == "locked" then
        btn.rankText:Hide()
    else
        btn.rankText:Show()


        if btn.isMultipleChoice then
            if nodeChoices[btn.id] and nodeChoices[btn.id] ~= 0 then
                btn.rankText:SetText("*")
                btn.rankText:SetTextColor(unpack(COLOR_ORANGE))
            else
                btn.rankText:SetText("")
            end
        else
            local maxRank = #btn.spells or 0
            btn.rankText:SetText(currentRank .. "/" .. maxRank)

            if currentRank > 0 then
                if currentRank >= maxRank then
                    btn.rankText:SetTextColor(unpack(COLOR_ORANGE))
                else
                    btn.rankText:SetTextColor(unpack(COLOR_GREEN))
                end
            elseif btn.state == "nopoints" then
                btn.rankText:SetTextColor(1.0, 0.82, 0.0, 1.0)
            else
                btn.rankText:SetTextColor(unpack(COLOR_GREEN))
            end
        end
    end
end

local function NodeCenterOffsets(btn)
    local w, h = btn:GetWidth(), btn:GetHeight()
    local _, _, _, ox, oy = btn:GetPoint(1)
    return ox + w * 0.5, oy - h * 0.5
end

local function MakeAnimatedRotatingLine(x1, y1, x2, y2, thickness, duration)
    local dx, dy = x2 - x1, y2 - y1
    local dist = math.sqrt(dx * dx + dy * dy)
    if dist < 1 then return nil end

    local targetAngleDeg = math.deg(math.atan2(dy, dx))
    local animDuration = duration or 1

    local tex = Canvas:CreateTexture(nil, "BACKGROUND")
    tex:SetTexture("Interface\\Buttons\\WHITE8x8")
    tex:SetBlendMode("BLEND")
    tex:SetAlpha(0.55)
    tex:SetSize(dist, thickness or 2)

    local cx, cy = (x1 + x2) / 2, (y1 + y2) / 2
    tex:SetPoint("CENTER", Canvas, "TOPLEFT", cx, cy)

    local ag = tex:CreateAnimationGroup()
    local rot = ag:CreateAnimation("Rotation")
    rot:SetDegrees(targetAngleDeg)
    rot:SetDuration(0.001)
    rot:SetOrder(1)
    rot:SetOrigin("CENTER", 0, 0)
    rot:SetEndDelay(999999)
    ag:SetLooping("NONE")
    ag:Play()

    return tex, { tex }, nil, ag
end

local function BuildNeighborsAndParents()
    neighbors, parentsOf = {}, {}
    DebugPrint("|cff00FFFFBuilding neighbors from " .. #Links .. " links|r")
    for _, e in ipairs(Links) do
        local a, b = e[1], e[2]
        neighbors[a] = neighbors[a] or {}
        neighbors[b] = neighbors[b] or {}
        table.insert(neighbors[a], b)
        table.insert(neighbors[b], a)


        parentsOf[b] = parentsOf[b] or {}
        table.insert(parentsOf[b], a)
    end
    DebugPrint("|cff00FFFFNeighbors table built successfully|r")
end

local function displayTalentPoints()
    if peeOwnedSkillTreeFrame.pointsText then
        peeOwnedSkillTreeFrame.pointsText:SetText(
            "|cffFFD700Available Soul Ashes:|r " .. GetRemainingTalentPoints())
    end
    if Chrome.RefreshOwnedSkillTreeChrome then
        Chrome.RefreshOwnedSkillTreeChrome()
    end
end

updateTalentPoints = function()
    displayTalentPoints()
end

local function canAffordTalent(nodeId)
    local btn = nodesById[nodeId]
    if not btn then return false end

    local currentRank = getNodeRank(nodeId)
    local nextRank = currentRank + 1
    local nodeCost = getNodeCost(btn, nextRank)

    return GetRemainingTalentPoints() >= nodeCost
end

local function canUpgradeNode(nodeId)
    local btn = nodesById[nodeId]
    if not btn then return false end


    if not hasPrerequisites(nodeId) then
        DebugPrint("Node %d cannot be upgraded - prerequisites not met", nodeId)
        return false
    end


    if btn.isMultipleChoice then
        return (nodeChoices[nodeId] or 0) == 0 and canAffordTalent(nodeId)
    end


    local currentRank = getNodeRank(nodeId)
    local maxRank = getMaxRank(nodeId)
    return currentRank < maxRank and canAffordTalent(nodeId)
end

local function canDowngradeNode(nodeId)
    local btn = nodesById[nodeId]
    if not btn then return false end

    if btn.permanent and lastValidatedState and lastValidatedState.nodeRanks
        and (lastValidatedState.nodeRanks[nodeId] or 0) > 0 then
        return false
    end

    if btn.isMultipleChoice then
        local hasChoice = (nodeChoices[nodeId] or 0) ~= 0
        if not hasChoice then return false end
    else
        local currentRank = getNodeRank(nodeId)
        if currentRank <= 0 then return false end
    end

    local currentRank = getNodeRank(nodeId)
    local maxRank = getMaxRank(nodeId)
    if not btn.isMultipleChoice and currentRank >= maxRank then
        for otherId, otherBtn in pairs(nodesById) do
            if otherId ~= nodeId then
                local otherHasProgress = false

                if otherBtn.isMultipleChoice then
                    otherHasProgress = (nodeChoices[otherId] or 0) ~= 0
                else
                    otherHasProgress = getNodeRank(otherId) > 0
                end

                if otherHasProgress then
                    local parents = parentsOf[otherId]
                    if parents then
                        for _, parentId in ipairs(parents) do
                            if parentId == nodeId then
                                return false
                            end
                        end
                    end
                end
            end
        end
    end

    return true
end

local function upgradeNodeRank(nodeId)
    local btn = nodesById[nodeId]
    if not btn or not canUpgradeNode(nodeId) then return false end


    if btn.isApex then
        if activeApexNodeId and activeApexNodeId ~= nodeId then
            DebugPrint(
                "|cffFF0000You can only have one APEX talent active at a time!|r")
            DebugPrint("|cffFFFF00Deactivate your current APEX talent first.|r")
            return false
        end
        activeApexNodeId = nodeId
    end


    if btn.isMultipleChoice then
        if (nodeChoices[nodeId] or 0) == 0 then
            ShowChoiceButtons(btn)
            return false
        end
        return false
    end


    local currentRank = nodeRanks[nodeId] or 0
    local nextRank = currentRank + 1
    local nodeCost = getNodeCost(btn, nextRank)

    nodeRanks[nodeId] = nextRank
    TALENT_POINTS_TOTAL = TALENT_POINTS_TOTAL - nodeCost

    DebugPrint("Node %d upgraded to rank %d (cost: %d, remaining: %d)",
        nodeId, nextRank, nodeCost, TALENT_POINTS_TOTAL)
    MarkUnsavedChanges()
    return true
end

local function downgradeNodeRank(nodeId)
    local btn = nodesById[nodeId]
    if not btn or not canDowngradeNode(nodeId) then return false end


    if btn.isApex and activeApexNodeId == nodeId then activeApexNodeId = nil end


    if btn.isMultipleChoice then
        local refund = getNodeCost(btn, 1)
        TALENT_POINTS_TOTAL = TALENT_POINTS_TOTAL + refund

        nodeChoices[nodeId] = 0
        nodeRanks[nodeId] = 0
        btn.selectedSpell = nil


        if btn.spells and #btn.spells > 0 then
            btn.icon:SetTexture(getSpellIconSafe(btn.spells[1]))
        end

        DebugPrint("Node %d choice removed (refund: %d, remaining: %d)",
            nodeId, refund, TALENT_POINTS_TOTAL)
        MarkUnsavedChanges()
        return true
    end


    local currentRank = nodeRanks[nodeId] or 0
    if currentRank > 0 then
        local refund = getNodeCost(btn, currentRank)
        TALENT_POINTS_TOTAL = TALENT_POINTS_TOTAL + refund

        nodeRanks[nodeId] = currentRank - 1

        DebugPrint("Node %d downgraded to rank %d (refund: %d, remaining: %d)",
            nodeId, currentRank - 1, refund, TALENT_POINTS_TOTAL)
    end

    MarkUnsavedChanges()
    return true
end

local function updateLinkColors()
    for _, L in ipairs(lines) do
        local a, b = L.a, L.b
        local color
        if a.state == "active" and b.state == "active" then
            color = COLOR_ORANGE
        elseif (a.state == "active" and b.state == "ready") or
            (b.state == "active" and a.state == "ready") then
            color = COLOR_GREEN
        else
            color = COLOR_GRAY
        end


        if not L.lastColor or L.lastColor ~= color then
            L.lastColor = color

            if L.tex then L.tex:SetVertexColor(unpack(color)) end
        end
    end
end




ShowChoiceButtons = function(btn)
    if not btn.spells or #btn.spells <= 1 then return end
    if #btn.choiceButtons > 0 then return end


    local numChoices = #btn.spells

    for i, spellID in ipairs(btn.spells) do
        local offsetX, offsetY = 0, 0
        if numChoices == 2 then
            offsetX = (i == 1) and -18 or 18
            offsetY = 25
        else
            local angle = (i - 1) * (2 * math.pi / numChoices) - math.pi / 2
            offsetX = 35 * math.cos(angle)
            offsetY = 35 * math.sin(angle)
        end


        local choiceBtn = CreateFrame("Button", nil, Canvas)
        choiceBtn:SetSize(30, 30)
        choiceBtn:SetPoint("CENTER", btn, "CENTER", offsetX, offsetY)
        choiceBtn:SetFrameLevel(btn:GetFrameLevel() + 10)


        choiceBtn.borderTex = choiceBtn:CreateTexture(nil, "BORDER")
        choiceBtn.borderTex:SetTexture("Interface\\Buttons\\WHITE8x8")
        choiceBtn.borderTex:SetVertexColor(1, 1, 1, 1)
        choiceBtn.borderTex:SetPoint("TOPLEFT", choiceBtn, "TOPLEFT", -2, 2)
        choiceBtn.borderTex:SetPoint("BOTTOMRIGHT", choiceBtn, "BOTTOMRIGHT", 2, -2)


        local spellName, _, iconTex = GetSpellInfo(spellID)
        if not spellName then
            iconTex = "Interface\\Icons\\INV_Misc_QuestionMark"
            DebugPrint("Warning: Invalid spell ID %s in talent database",
                spellID)
        end
        local icon = choiceBtn:CreateTexture(nil, "ARTWORK")
        icon:SetAllPoints(choiceBtn)
        icon:SetTexCoord(0.07, 0.93, 0.07, 0.93)
        icon:SetTexture(iconTex or "Interface\\Icons\\INV_Misc_QuestionMark")
        choiceBtn.icon = icon


        if btn.state == "locked" then
            choiceBtn.borderTex:SetVertexColor(0.3, 0.3, 0.3, 1)
            choiceBtn:SetAlpha(0.5)
            choiceBtn.icon:SetDesaturated(true)
        elseif i == btn.selectedSpell then
            choiceBtn.borderTex:SetVertexColor(0, 1, 0, 1)
            choiceBtn:SetAlpha(1.0)
            choiceBtn.icon:SetDesaturated(false)
        else
            choiceBtn.borderTex:SetVertexColor(1, 1, 1, 1)
            choiceBtn:SetAlpha(0.8)
            choiceBtn.icon:SetDesaturated(false)
        end


        choiceBtn:SetScript("OnEnter", function()
            if btn.hideFrame then
                btn.hideFrame:SetScript("OnUpdate", nil)
                btn.hideFrame.timer = nil
            end

            GameTooltip:SetOwner(choiceBtn, "ANCHOR_RIGHT")
            GameTooltip:SetHyperlink('spell:' .. spellID)

            if btn.state == "locked" then
                GameTooltip:AddLine("|cffFF0000Node is locked|r", 1, 1, 1)
            elseif i == btn.selectedSpell then
                GameTooltip:AddLine("|cff00FF00Currently Selected|r", 1, 1, 1)
            else
                GameTooltip:AddLine("|cffFFFFFFClick to select this option|r",
                    1, 1, 1)
            end

            if i ~= btn.selectedSpell and (nodeChoices[btn.id] or 0) == 0 then
                local soulCost = getNodeCost(btn, 1)
                local canAfford = TALENT_POINTS_TOTAL >= soulCost
                local costColor = canAfford and "|cff00FF00" or "|cffFF0000"
                local soulIcon = "|TInterface\\AddOns\\ProjectEbonhold\\assets\\inv_soulash:16|t"
                GameTooltip:AddLine(costColor .. soulIcon .. " " .. soulCost .. " Soul Ashes|r", 1, 1, 1)
            end

            GameTooltip:Show()
        end)
        choiceBtn:SetScript("OnLeave", function()
            GameTooltip:Hide()
        end)


        choiceBtn:SetScript("OnClick", function()
            if btn.state ~= "locked" and canAffordTalent(btn.id) then
                local nodeCost = getNodeCost(btn, 1)
                TALENT_POINTS_TOTAL = TALENT_POINTS_TOTAL - nodeCost

                btn.selectedSpell = i
                nodeChoices[btn.id] = i
                nodeRanks[btn.id] = 1

                DebugPrint("Node %d choice %d selected (cost: %d, remaining: %d)",
                    btn.id, i, nodeCost, TALENT_POINTS_TOTAL)
                MarkUnsavedChanges()


                btn.icon:SetTexture(getSpellIconSafe(spellID))


                for j, otherBtn in ipairs(btn.choiceButtons) do
                    if btn.state == "locked" then
                        otherBtn.borderTex:SetVertexColor(0.3, 0.3, 0.3, 1)
                        otherBtn:SetAlpha(0.5)
                        otherBtn.icon:SetDesaturated(true)
                    elseif j == i then
                        otherBtn.borderTex:SetVertexColor(0, 1, 0, 1)
                        otherBtn:SetAlpha(1.0)
                        otherBtn.icon:SetDesaturated(false)
                    else
                        otherBtn.borderTex:SetVertexColor(1, 1, 1, 1)
                        otherBtn:SetAlpha(0.8)
                        otherBtn.icon:SetDesaturated(false)
                    end
                end


                refreshAccessibility()


                local spellName = GetSpellInfo(spellID)
                if not spellName then
                    spellName = "Invalid Spell (" .. spellID .. ")"
                end
                DebugPrint("|cff00FF00Choice selected: " ..
                    (spellName or "Unknown") .. "|r")


                HideChoiceButtons(btn)
            elseif btn.state == "locked" then
                DebugPrint(
                    "|cffFF0000Prerequisites not met! You cannot select this option yet.|r")
            elseif not canAffordTalent(btn.id) then
                DebugPrint("|cffFF0000Not enough Soul Ashes!|r")
            end
        end)

        choiceBtn.spellID = spellID
        table.insert(btn.choiceButtons, choiceBtn)
    end
end

HideChoiceButtons = function(btn)
    if btn.choiceButtons then
        for _, choiceBtn in ipairs(btn.choiceButtons) do
            choiceBtn:Hide()
            choiceBtn:SetParent(nil)
        end
    end
    btn.choiceButtons = {}
end

local function updateNodeDisplay(btn, nodeId)
    if not btn or not btn.spells then return end

    local currentRank = getNodeRank(nodeId)
    local maxRank = getMaxRank(nodeId)


    local currentSpellID
    if btn.isMultipleChoice then
        local selectedChoice = nodeChoices[nodeId] or 1
        currentSpellID = btn.spells[selectedChoice]
    elseif currentRank > 0 then
        currentSpellID = btn.spells[currentRank]
    else
        currentSpellID = btn.spells[1]
    end

    if currentSpellID then
        local _, _, iconTex = GetSpellInfo(currentSpellID)
        if not iconTex then
            iconTex = "Interface\\Icons\\INV_Misc_QuestionMark"
            DebugPrint("Warning: Invalid spell ID %s in updateNodeDisplay",
                currentSpellID)
        end
        btn.icon:SetTexture(iconTex or "Interface\\Icons\\INV_Misc_QuestionMark")
    end


    if not btn.rankText then
        btn.rankText = btn:CreateFontString(nil, "OVERLAY",
            "GameFontNormalSmall")
        btn.rankText:SetPoint("BOTTOMRIGHT", btn, "BOTTOMRIGHT", 2, -2)
        btn.rankText:SetTextColor(1, 1, 0)

        btn.rankText:SetShadowOffset(1, -1)
        btn.rankText:SetShadowColor(0, 0, 0, 1)
    end

    if btn.isMultipleChoice then
        btn.rankText:SetText(currentRank > 0 and "*" or "")
    else
        btn.rankText:SetText(currentRank .. "/" .. maxRank)
    end
end

refreshAccessibility = function()
    updateTalentPoints()


    for nid, btn in pairs(nodesById) do
        local hasProgress = isNodeActive(nid)

        if hasProgress then
            local currentRank = getNodeRank(nid)
            local maxRank = getMaxRank(nid)

            if currentRank >= maxRank then
                btn.state = "active"
            else
                if canAffordTalent(nid) then
                    btn.state = "ready"
                else
                    btn.state = "nopoints"
                end
            end
        elseif btn.isStart then
            if canAffordTalent(nid) then
                btn.state = "ready"
            else
                btn.state = "nopoints"
            end
        else
            local hasPrereqs = hasPrerequisites(nid)

            if hasPrereqs and canAffordTalent(nid) then
                btn.state = "ready"
            elseif hasPrereqs and not canAffordTalent(nid) then
                btn.state = "nopoints"
            else
                btn.state = "locked"
            end
        end
    end


    displayTalentPoints()


    for nid, btn in pairs(nodesById) do
        applyNodeVisual(btn)
        updateNodeDisplay(btn, nid)
    end
    updateLinkColors()

    if peeOwnedSkillTreeFrame and peeOwnedSkillTreeFrame.nodeStatsText then
        local totalNodes, usedNodes, permanentTotal, permanentUsed = 0, 0, 0, 0
        for nodeId, btn in pairs(nodesById) do
            totalNodes = totalNodes + 1
            local rank = nodeRanks[nodeId] or 0
            if rank > 0 then usedNodes = usedNodes + 1 end
            if btn.permanent then
                permanentTotal = permanentTotal + 1
                if rank > 0 then permanentUsed = permanentUsed + 1 end
            end
        end
        local nonPermUsed = usedNodes - permanentUsed
        local nonPermTotal = totalNodes - permanentTotal
        peeOwnedSkillTreeFrame.nodeStatsText:SetText(
            "|cffbbbbbbNodes:|r " .. nonPermUsed .. "/" .. nonPermTotal ..
            "  |cffbbbbbbPerm:|r " .. permanentUsed .. "/" .. permanentTotal ..
            "  |cffbbbbbbFree Pts:|r " .. (TALENT_POINTS_TOTAL or 0))
    end
    if Chrome.RefreshOwnedSkillTreeChrome then
        Chrome.RefreshOwnedSkillTreeChrome()
    end
end



local searchResultsFrame  -- lazy-created on first PopulateSearchResults call
local searchResultsScrollChild
local resultRowPool = {}

local SEARCH_PANEL_WIDTH = 250
local SEARCH_ROW_HEIGHT = 22

local STATE_COLOR_LOCKED = { 0.65, 0.65, 0.65 }
local STATE_COLOR_AVAIL = { 0.4, 1.0, 0.4 }
local STATE_COLOR_MAXED = { 1.0, 0.82, 0 }
local STATE_COLOR_PERM = { 0.69, 0.28, 0.97 }

local function GetRowState(btn)
    local nid = btn.id
    local cur = nodeRanks[nid] or 0
    local maxR = (btn.spells and #btn.spells) or 0
    if btn.permanent and lastValidatedState and lastValidatedState.nodeRanks
        and (lastValidatedState.nodeRanks[nid] or 0) > 0 then
        return "perm", cur, maxR
    end
    if maxR > 0 and cur >= maxR then return "maxed", cur, maxR end
    if cur > 0 or btn.isStart or hasPrerequisites(nid) then
        return "avail", cur, maxR
    end
    return "locked", cur, maxR
end

local function GetStateLabel(state)
    if state == "perm" then return "Perm", STATE_COLOR_PERM end
    if state == "maxed" then return "Maxed", STATE_COLOR_MAXED end
    if state == "avail" then return "Avail", STATE_COLOR_AVAIL end
    return "Locked", STATE_COLOR_LOCKED
end

local function MaxNodeRecursive(nodeId, results, seen)
    if seen[nodeId] then return end
    seen[nodeId] = true

    local parents = parentsOf[nodeId]
    if parents then
        for _, parentId in ipairs(parents) do
            local pBtn = nodesById[parentId]
            local pMax = (pBtn and pBtn.spells and #pBtn.spells) or 0
            if (nodeRanks[parentId] or 0) < pMax then
                MaxNodeRecursive(parentId, results, seen)
                if results.partial then return end
            end
        end
    end

    local btn = nodesById[nodeId]
    if not btn then return end
    if btn.isMultipleChoice then
        results.partial = true
        results.skippedChoiceCount = (results.skippedChoiceCount or 0) + 1
        return
    end
    local maxR = (btn.spells and #btn.spells) or 0
    while (nodeRanks[nodeId] or 0) < maxR do
        if canUpgradeNode(nodeId) and upgradeNodeRank(nodeId) then
            results.added = results.added + 1
        else
            results.partial = true
            return
        end
    end
end

local function AddRankToTarget(targetId, results)
    local seen = {}
    local parents = parentsOf[targetId]
    if parents then
        for _, parentId in ipairs(parents) do
            local pBtn = nodesById[parentId]
            local pMax = (pBtn and pBtn.spells and #pBtn.spells) or 0
            if (nodeRanks[parentId] or 0) < pMax then
                MaxNodeRecursive(parentId, results, seen)
                if results.partial then return false end
            end
        end
    end
    if not canUpgradeNode(targetId) then
        results.partial = true
        return false
    end
    if upgradeNodeRank(targetId) then
        results.added = results.added + 1
        return true
    end
    results.partial = true
    return false
end

local function FormatPathResult(results, targetName)
    local parts = {}
    if results.added > 0 then
        parts[#parts + 1] = "added " .. results.added .. " rank" ..
            (results.added == 1 and "" or "s")
    end
    if results.partial then
        parts[#parts + 1] = "partial path (not enough points)"
    end
    if results.skippedChoiceCount and results.skippedChoiceCount > 0 then
        parts[#parts + 1] = results.skippedChoiceCount ..
            " choice node" .. (results.skippedChoiceCount == 1 and "" or "s") ..
            " need manual pick"
    end
    if #parts == 0 then parts[#parts + 1] = "nothing changed" end
    return "[" .. targetName .. "] " .. table.concat(parts, ", ")
end

local function ShowRowTooltip(treeBtn, ownerFrame)
    if not treeBtn or not treeBtn.spells or not CurrentRankTooltip then return end
    if NextRankTooltip then NextRankTooltip:Hide() end

    local maxRank = #treeBtn.spells

    if treeBtn.isMultipleChoice then
        local firstSpell = treeBtn.spells[1]
        if firstSpell then
            CurrentRankTooltip:SetOwner(ownerFrame, "ANCHOR_LEFT")
            CurrentRankTooltip:SetHyperlink("spell:" .. firstSpell)
            CurrentRankTooltip:AddLine(
                "\n|cffFFFFFFChoice node (pick a choice in the tree)|r", 1, 1, 1)
            CurrentRankTooltip:Show()
        end
        return
    end

    local currentRank = nodeRanks[treeBtn.id] or 0
    local activeIdx = (currentRank > 0) and currentRank or 1
    local spellId = treeBtn.spells[activeIdx]
    if not spellId then return end

    CurrentRankTooltip:SetOwner(ownerFrame, "ANCHOR_LEFT")
    CurrentRankTooltip:SetHyperlink("spell:" .. spellId)

    if not treeBtn.permanent then
        local color = (currentRank > 0) and "|cff00FF00" or "|cffFFFFFF"
        CurrentRankTooltip:AddLine(
            "\n" .. color .. "Rank: " .. currentRank .. "/" .. maxRank .. "|r",
            1, 1, 1)
    end

    if currentRank < maxRank then
        local nextRank = currentRank + 1
        local soulCost = getNodeCost(treeBtn, nextRank)
        local canAfford = TALENT_POINTS_TOTAL >= soulCost
        local label
        if currentRank > 0 then
            label = "Next rank: "
        elseif treeBtn.permanent then
            label = ""
        elseif maxRank > 1 then
            label = "First rank: "
        else
            label = ""
        end
        addCostToTooltip(CurrentRankTooltip, label, soulCost, canAfford)
    end

    if treeBtn.permanent then
        if currentRank > 0 and lastValidatedState and lastValidatedState.nodeRanks
            and (lastValidatedState.nodeRanks[treeBtn.id] or 0) > 0 then
            CurrentRankTooltip:AddLine("|cffFF0000Permanent Skill (committed)|r",
                1, 1, 1, true)
        else
            CurrentRankTooltip:AddLine("|cffFF4444Permanent Skill|r",
                1, 1, 1, true)
        end
    end

    CurrentRankTooltip:Show()
end

local function HideRowTooltip()
    if CurrentRankTooltip then CurrentRankTooltip:Hide() end
    if NextRankTooltip then NextRankTooltip:Hide() end
end

local function OnResultRowClick(self)
    local treeBtn = self.treeBtn
    if not treeBtn then return end
    local nid = treeBtn.id
    local state, currentRank = GetRowState(treeBtn)

    if state == "perm" then
        DEFAULT_CHAT_FRAME:AddMessage(
            "|cffFF4444[Skill Tree]|r This talent is permanent and cannot be removed.")
        return
    end

    if state == "maxed" then
        if canDowngradeNode(nid) and downgradeNodeRank(nid) then
            updateAllNodeVisuals()
            refreshAccessibility()
            if searchResultsFrame and searchResultsFrame:IsShown() then
                PopulateSearchResults(searchResultsFrame._lastMatches or {})
            end
        else
            DEFAULT_CHAT_FRAME:AddMessage(
                "|cffFF4444[Skill Tree]|r Cannot remove (downstream talents depend on this).")
        end
        return
    end

    local function doAdd()
        local spellName = (treeBtn.spells and treeBtn.spells[1] and
            GetSpellInfo(treeBtn.spells[1])) or "Talent"
        local results = { added = 0, partial = false }
        AddRankToTarget(nid, results)
        updateAllNodeVisuals()
        refreshAccessibility()
        if searchResultsFrame and searchResultsFrame:IsShown() then
            PopulateSearchResults(searchResultsFrame._lastMatches or {})
        end
        DEFAULT_CHAT_FRAME:AddMessage(
            "|cff00ff00[Skill Tree]|r " .. FormatPathResult(results, spellName))
    end

    if treeBtn.permanent and currentRank == 0 then
        StaticPopupDialogs["PEE_SKILLTREE_PERMANENT_CONFIRM"] = {
            text =
            "|cffFF4444Warning: Permanent Skill|r\n\nThis Skill is |cffFF0000permanent|r and cannot be unlearned once the changes are applied.\n\nAre you sure you want to learn it?",
            button1 = "Yes, Learn It",
            button2 = "Cancel",
            timeout = 0,
            whileDead = true,
            hideOnEscape = true,
            showAlert = true,
            OnAccept = doAdd,
        }
        local popup = StaticPopup_Show("PEE_SKILLTREE_PERMANENT_CONFIRM")
        if popup then popup:SetFrameStrata("TOOLTIP") end
        return
    end

    doAdd()
end

local function AcquireResultRow(index)
    local row = resultRowPool[index]
    if row then row:Show() return row end

    row = CreateFrame("Button", nil, searchResultsScrollChild)
    row:SetHeight(SEARCH_ROW_HEIGHT)
    row:SetPoint("LEFT", searchResultsScrollChild, "LEFT", 4, 0)
    row:SetPoint("RIGHT", searchResultsScrollChild, "RIGHT", -4, 0)

    row.bg = row:CreateTexture(nil, "BACKGROUND")
    row.bg:SetAllPoints()
    row.bg:SetTexture(0.18, 0.18, 0.18, 0.5)
    row.bg:Hide()

    row.icon = row:CreateTexture(nil, "ARTWORK")
    row.icon:SetSize(16, 16)
    row.icon:SetPoint("LEFT", row, "LEFT", 2, 0)
    row.icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)

    row.name = row:CreateFontString(nil, "OVERLAY")
    row.name:SetFont("Fonts\\FRIZQT__.TTF", 11, "OUTLINE")
    row.name:SetPoint("LEFT", row.icon, "RIGHT", 6, 0)
    row.name:SetPoint("RIGHT", row, "RIGHT", -82, 0)
    row.name:SetJustifyH("LEFT")
    row.name:SetWordWrap(false)
    row.name:SetNonSpaceWrap(false)

    row.rank = row:CreateFontString(nil, "OVERLAY")
    row.rank:SetFont("Fonts\\FRIZQT__.TTF", 11, "OUTLINE")
    row.rank:SetPoint("RIGHT", row, "RIGHT", -46, 0)
    row.rank:SetJustifyH("RIGHT")
    row.rank:SetWidth(32)

    row.badge = row:CreateFontString(nil, "OVERLAY")
    row.badge:SetFont("Fonts\\FRIZQT__.TTF", 10, "OUTLINE")
    row.badge:SetPoint("RIGHT", row, "RIGHT", -2, 0)
    row.badge:SetJustifyH("RIGHT")
    row.badge:SetWidth(42)

    row:RegisterForClicks("LeftButtonUp")
    row:SetScript("OnEnter", function(self)
        self.bg:Show()
        if self.treeBtn then ShowRowTooltip(self.treeBtn, self) end
    end)
    row:SetScript("OnLeave", function(self)
        self.bg:Hide()
        HideRowTooltip()
    end)
    row:SetScript("OnClick", OnResultRowClick)

    resultRowPool[index] = row
    return row
end

local function CreateSearchResultsPanel()
    if searchResultsFrame then return end

    searchResultsFrame = CreateFrame("Frame", "peeOwnedSkillTreeSearchResults", peeOwnedSkillTreeFrame)
    searchResultsFrame:SetWidth(SEARCH_PANEL_WIDTH)
    searchResultsFrame:SetPoint("TOPLEFT", peeOwnedSkillTreeFrame, "TOPRIGHT", 6, 0)
    searchResultsFrame:SetPoint("BOTTOMLEFT", peeOwnedSkillTreeFrame, "BOTTOMRIGHT", 6, 0)
    searchResultsFrame:SetFrameStrata(peeOwnedSkillTreeFrame:GetFrameStrata())
    searchResultsFrame:SetFrameLevel(peeOwnedSkillTreeFrame:GetFrameLevel())
    searchResultsFrame:Hide()

    if searchResultsFrame.SetBackdrop then
        searchResultsFrame:SetBackdrop({
            bgFile = "Interface\\Buttons\\WHITE8x8",
            edgeFile = "Interface\\Buttons\\WHITE8x8",
            tile = true, tileSize = 16, edgeSize = 4,
            insets = { left = 4, right = 4, top = 4, bottom = 4 },
        })
        local opacity = GetThemeBackdropOpacity()
        searchResultsFrame:SetBackdropColor(0.039, 0.039, 0.039, opacity)
        searchResultsFrame:SetBackdropBorderColor(0, 0, 0, 1)
    end

    local title = searchResultsFrame:CreateFontString(nil, "OVERLAY")
    title:SetFont("Fonts\\FRIZQT__.TTF", 14, "OUTLINE")
    title:SetTextColor(1, 0.82, 0)
    title:SetPoint("TOP", searchResultsFrame, "TOP", 0, -10)
    title:SetText("Search Results")
    searchResultsFrame.title = title

    local hint = searchResultsFrame:CreateFontString(nil, "OVERLAY")
    hint:SetFont("Fonts\\FRIZQT__.TTF", 10, "OUTLINE")
    hint:SetTextColor(0.65, 0.65, 0.65)
    hint:SetPoint("TOP", title, "BOTTOM", 0, -4)
    hint:SetText("click to add  |  click maxed to remove")
    searchResultsFrame.hint = hint

    local scroll = CreateFrame("ScrollFrame", "peeOwnedSkillTreeSearchResultsScroll",
        searchResultsFrame, "UIPanelScrollFrameTemplate")
    scroll:SetPoint("TOPLEFT", searchResultsFrame, "TOPLEFT", 8, -44)
    scroll:SetPoint("BOTTOMRIGHT", searchResultsFrame, "BOTTOMRIGHT", -26, 8)

    local scrollChild = CreateFrame("Frame", nil, scroll)
    scrollChild:SetSize(SEARCH_PANEL_WIDTH - 36, 1)
    scroll:SetScrollChild(scrollChild)
    searchResultsScrollChild = scrollChild

    local emptyMsg = scrollChild:CreateFontString(nil, "OVERLAY")
    emptyMsg:SetFont("Fonts\\FRIZQT__.TTF", 11, "OUTLINE")
    emptyMsg:SetTextColor(0.65, 0.65, 0.65)
    emptyMsg:SetPoint("TOP", scrollChild, "TOP", 0, -20)
    emptyMsg:SetText("(no matches)")
    emptyMsg:Hide()
    searchResultsFrame.emptyMsg = emptyMsg
end

HideSearchResults = function()
    if searchResultsFrame then
        searchResultsFrame:Hide()
        searchResultsFrame._lastMatches = nil
    end
end

PopulateSearchResults = function(matches)
    CreateSearchResultsPanel()
    searchResultsFrame._lastMatches = matches
    searchResultsFrame:Show()

    for _, row in ipairs(resultRowPool) do row:Hide() end

    if not matches or #matches == 0 then
        searchResultsFrame.emptyMsg:Show()
        searchResultsScrollChild:SetHeight(40)
        return
    end
    searchResultsFrame.emptyMsg:Hide()

    for i, treeBtn in ipairs(matches) do
        local row = AcquireResultRow(i)
        row.treeBtn = treeBtn
        row:SetPoint("TOP", searchResultsScrollChild, "TOP", 0,
            -((i - 1) * (SEARCH_ROW_HEIGHT + 2)))

        local firstSpell = treeBtn.spells and treeBtn.spells[1]
        local spellName, iconTex
        if firstSpell then
            spellName = GetSpellInfo(firstSpell)
            iconTex = select(3, GetSpellInfo(firstSpell))
        end
        row.icon:SetTexture(iconTex or "Interface\\Icons\\INV_Misc_QuestionMark")
        row.name:SetText(spellName or "?")
        row.name:SetTextColor(1, 1, 1)

        local state, currentRank, maxR = GetRowState(treeBtn)
        row.rank:SetText(currentRank .. "/" .. maxR)
        row.rank:SetTextColor(1, 1, 1)
        local label, color = GetStateLabel(treeBtn.permanent and "perm" or state)
        row.badge:SetText(label)
        row.badge:SetTextColor(color[1], color[2], color[3])
    end

    searchResultsScrollChild:SetHeight(#matches * (SEARCH_ROW_HEIGHT + 2) + 8)
end


resetNonPermanentNodes = function()
    local protectedNodes = {}
    for nodeId, btn in pairs(nodesById) do
        if btn.permanent and lastValidatedState and lastValidatedState.nodeRanks
            and (lastValidatedState.nodeRanks[nodeId] or 0) > 0 then
            protectedNodes[nodeId] = true
        end
    end

    local function markAncestors(nodeId)
        local parents = parentsOf[nodeId]
        if not parents then return end
        for _, parentId in ipairs(parents) do
            if not protectedNodes[parentId] then
                protectedNodes[parentId] = true
                markAncestors(parentId)
            end
        end
    end
    for nodeId, _ in pairs(protectedNodes) do
        markAncestors(nodeId)
    end

    local resetCount = 0
    local changed = true
    while changed do
        changed = false
        for nodeId, btn in pairs(nodesById) do
            local currentRank = nodeRanks[nodeId] or 0
            if currentRank > 0 and not protectedNodes[nodeId] then
                if canDowngradeNode(nodeId) then
                    downgradeNodeRank(nodeId)
                    changed = true
                    resetCount = resetCount + 1
                end
            end
        end
    end

    updateAllNodeVisuals()
    refreshAccessibility()
    MarkUnsavedChanges()

    DEFAULT_CHAT_FRAME:AddMessage(
        "|cff00ff00[Skill Tree]|r Reset " .. resetCount ..
        " ranks. Click Apply Changes to save.")
end

GetProfileDB = function()
    ProjectEbonholdEnhancedDB = ProjectEbonholdEnhancedDB or {}
    ProjectEbonholdEnhancedDB.ownedSoulAsheTreeProfiles = ProjectEbonholdEnhancedDB.ownedSoulAsheTreeProfiles or {}
    return ProjectEbonholdEnhancedDB.ownedSoulAsheTreeProfiles
end

SaveProfile = function(name)
    if not name or name == "" then return end
    local profiles = GetProfileDB()
    local profile = { nodeRanks = {}, nodeChoices = {} }
    for nodeId, rank in pairs(nodeRanks) do
        if rank > 0 then profile.nodeRanks[nodeId] = rank end
    end
    for nodeId, choice in pairs(nodeChoices) do
        if choice ~= 0 then profile.nodeChoices[nodeId] = choice end
    end
    profiles[name] = profile
    DEFAULT_CHAT_FRAME:AddMessage("|cff00ff00[Skill Tree]|r Profile saved: " .. name)
end

LoadProfile = function(name)
    local profiles = GetProfileDB()
    local profile = profiles[name]
    if not profile then
        DEFAULT_CHAT_FRAME:AddMessage("|cffff0000[Skill Tree]|r Profile not found: " .. name)
        return
    end

    resetNonPermanentNodes()

    local nodeDepth = {}
    local function getDepth(nodeId, visited)
        if nodeDepth[nodeId] then return nodeDepth[nodeId] end
        if visited[nodeId] then return 0 end
        visited[nodeId] = true
        local maxParentDepth = 0
        local parents = parentsOf[nodeId]
        if parents then
            for _, parentId in ipairs(parents) do
                local pd = getDepth(parentId, visited)
                if pd + 1 > maxParentDepth then maxParentDepth = pd + 1 end
            end
        end
        nodeDepth[nodeId] = maxParentDepth
        return maxParentDepth
    end
    local sortedNodes = {}
    for nodeId, targetRank in pairs(profile.nodeRanks) do
        getDepth(nodeId, {})
        table.insert(sortedNodes, { nodeId = nodeId, targetRank = targetRank, depth = nodeDepth[nodeId] or 0 })
    end
    table.sort(sortedNodes, function(a, b) return a.depth < b.depth end)

    local appliedCount = 0
    local skippedCount = 0
    for _, entry in ipairs(sortedNodes) do
        local nodeId = entry.nodeId
        local targetRank = entry.targetRank
        local btn = nodesById[nodeId]
        if btn then
            if btn.permanent then
            else
                local currentRank = nodeRanks[nodeId] or 0
                for rank = currentRank + 1, targetRank do
                    local cost = getNodeCost(btn, rank)
                    if TALENT_POINTS_TOTAL >= cost then
                        nodeRanks[nodeId] = rank
                        TALENT_POINTS_TOTAL = TALENT_POINTS_TOTAL - cost
                        appliedCount = appliedCount + 1
                    else
                        skippedCount = skippedCount + (targetRank - rank + 1)
                        break
                    end
                end
            end
        end
    end

    if profile.nodeChoices then
        for nodeId, choice in pairs(profile.nodeChoices) do
            if choice ~= 0 and nodeRanks[nodeId] and nodeRanks[nodeId] > 0 then
                nodeChoices[nodeId] = choice
                local btn = nodesById[nodeId]
                if btn then btn.selectedSpell = choice end
            end
        end
    end

    updateAllNodeVisuals()
    refreshAccessibility()
    MarkUnsavedChanges()

    local msg = "|cff00ff00[Skill Tree]|r Profile loaded: " .. name ..
        " (" .. appliedCount .. " ranks applied"
    if skippedCount > 0 then
        msg = msg .. ", " .. skippedCount .. " skipped - not enough points"
    end
    msg = msg .. "). Click Apply Changes to save."
    DEFAULT_CHAT_FRAME:AddMessage(msg)
end

DeleteProfile = function(name)
    local profiles = GetProfileDB()
    if profiles[name] then
        profiles[name] = nil
        DEFAULT_CHAT_FRAME:AddMessage("|cff00ff00[Skill Tree]|r Profile deleted: " .. name)
    end
end

GetProfileList = function()
    local profiles = GetProfileDB()
    local list = {}
    for name, _ in pairs(profiles) do
        table.insert(list, name)
    end
    table.sort(list)
    return list
end

RefreshProfileFrame = function()
    if not profileFrame or not profileFrame:IsShown() then return end
    local content = profileFrame.content
    if not content then return end

    if profileFrame.rows then
        for _, row in ipairs(profileFrame.rows) do
            if row.text then row.text:Hide() end
            row:Hide()
            row:SetParent(nil)
        end
    end
    profileFrame.rows = {}

    local profiles = GetProfileList()
    local yOffset = 0
    local rowH = 22

    for _, name in ipairs(profiles) do
        local row = CreateFrame("Button", nil, content)
        row:SetSize(content:GetWidth(), rowH)
        row:SetPoint("TOPLEFT", content, "TOPLEFT", 0, -yOffset)

        local nameText = row:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        nameText:SetPoint("LEFT", row, "LEFT", 4, 0)
        nameText:SetFont("Fonts\\FRIZQT__.TTF", 10, "")
        nameText:SetText(name)
        nameText:SetTextColor(1, 1, 1)

        local delBtn = CreateFrame("Button", nil, row)
        delBtn:SetSize(14, 14)
        delBtn:SetPoint("RIGHT", row, "RIGHT", -4, 0)
        delBtn:SetNormalTexture("Interface\\Buttons\\UI-Panel-MinimizeButton-Up")
        delBtn:SetPushedTexture("Interface\\Buttons\\UI-Panel-MinimizeButton-Down")
        delBtn:SetHighlightTexture("Interface\\Buttons\\UI-Panel-MinimizeButton-Highlight")
        delBtn:SetScript("OnClick", function()
            DeleteProfile(name)
            RefreshProfileFrame()
        end)
        delBtn:SetScript("OnEnter", function(self)
            GameTooltip:SetOwner(self, "ANCHOR_TOP")
            GameTooltip:SetText("Delete Profile", 1, 0.3, 0.3)
            GameTooltip:Show()
        end)
        delBtn:SetScript("OnLeave", function() GameTooltip:Hide() end)

        row:SetHighlightTexture("Interface\\Buttons\\UI-Listbox-Highlight2")
        row:SetScript("OnClick", function()
            StaticPopupDialogs["PEE_SKILLTREE_LOAD_PROFILE"] = {
                text = "Load profile \"" .. name .. "\"?\n\nThis will reset non-permanent nodes and apply the saved build. Click Apply Changes to save.",
                button1 = "Load",
                button2 = "Cancel",
                OnAccept = function()
                    LoadProfile(name)
                    if profileFrame then profileFrame:Hide() end
                end,
                timeout = 0,
                whileDead = true,
                hideOnEscape = true,
                preferredIndex = 3,
            }
            local popup = StaticPopup_Show("PEE_SKILLTREE_LOAD_PROFILE")
            if popup then popup:SetFrameStrata("TOOLTIP") end
        end)
        row:SetScript("OnEnter", function(self)
            nameText:SetTextColor(1, 0.82, 0)
        end)
        row:SetScript("OnLeave", function(self)
            nameText:SetTextColor(1, 1, 1)
        end)

        table.insert(profileFrame.rows, row)
        yOffset = yOffset + rowH
    end

    if #profiles == 0 then
        local emptyText = content:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        emptyText:SetPoint("TOPLEFT", content, "TOPLEFT", 4, 0)
        emptyText:SetFont("Fonts\\FRIZQT__.TTF", 9, "")
        emptyText:SetText("No saved profiles")
        emptyText:SetTextColor(0.5, 0.5, 0.5)
        local holder = CreateFrame("Frame", nil, content)
        holder:SetSize(1, 1)
        holder.text = emptyText
        table.insert(profileFrame.rows, holder)
        yOffset = rowH
    end

    local totalH = yOffset + 60
    profileFrame:SetHeight(math.max(100, totalH))
end

ToggleProfileFrame = function()
    if profileFrame and profileFrame:IsShown() then
        profileFrame:Hide()
        return
    end

    if not profileFrame then
        profileFrame = CreateFrame("Frame", "PEEOwnedSkillTreeProfileFrame", UIParent)
        profileFrame:SetSize(200, 160)
        profileFrame:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
        profileFrame:SetFrameStrata("TOOLTIP")
        profileFrame:SetMovable(true)
        profileFrame:EnableMouse(true)
        profileFrame:RegisterForDrag("LeftButton")
        profileFrame:SetScript("OnDragStart", profileFrame.StartMoving)
        profileFrame:SetScript("OnDragStop", profileFrame.StopMovingOrSizing)

        if profileFrame.SetBackdrop then
            profileFrame:SetBackdrop({
                bgFile = "Interface\\Buttons\\WHITE8x8",
                edgeFile = "Interface\\Buttons\\WHITE8x8",
                tile = true, tileSize = 16, edgeSize = 4,
                insets = { left = 4, right = 4, top = 4, bottom = 4 }
            })
            profileFrame:SetBackdropColor(0.039, 0.039, 0.039, GetThemeBackdropOpacity())
            profileFrame:SetBackdropBorderColor(0, 0, 0, 1)
        end

        local title = profileFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        title:SetPoint("TOP", profileFrame, "TOP", 0, -8)
        title:SetFont("Fonts\\FRIZQT__.TTF", 11, "OUTLINE")
        title:SetText("Skill Tree Profiles")
        title:SetTextColor(1, 0.82, 0)

        local closeBtn = CreateFrame("Button", nil, profileFrame)
        closeBtn:SetSize(16, 16)
        closeBtn:SetPoint("TOPRIGHT", profileFrame, "TOPRIGHT", -4, -4)
        closeBtn:SetNormalTexture("Interface\\Buttons\\UI-Panel-MinimizeButton-Up")
        closeBtn:SetPushedTexture("Interface\\Buttons\\UI-Panel-MinimizeButton-Down")
        closeBtn:SetHighlightTexture("Interface\\Buttons\\UI-Panel-MinimizeButton-Highlight")
        closeBtn:SetScript("OnClick", function() profileFrame:Hide() end)

        local content = CreateFrame("Frame", nil, profileFrame)
        content:SetPoint("TOPLEFT", profileFrame, "TOPLEFT", 6, -26)
        content:SetPoint("RIGHT", profileFrame, "RIGHT", -6, 0)
        content:SetHeight(200)
        profileFrame.content = content

        local saveBtn = CreateFrame("Button", nil, profileFrame, "UIPanelButtonTemplate")
        saveBtn:SetSize(120, 22)
        saveBtn:SetPoint("BOTTOM", profileFrame, "BOTTOM", 0, 8)
        saveBtn:SetText("Save Current")
        saveBtn:SetScript("OnClick", function()
            StaticPopupDialogs["PEE_SKILLTREE_SAVE_PROFILE"] = {
                text = "Enter profile name:",
                button1 = "Save",
                button2 = "Cancel",
                hasEditBox = true,
                timeout = 0,
                whileDead = true,
                hideOnEscape = true,
                OnAccept = function(self)
                    local pName = self.editBox:GetText()
                    if pName and pName ~= "" then
                        SaveProfile(pName)
                        RefreshProfileFrame()
                    end
                end,
                EditBoxOnEnterPressed = function(self)
                    local pName = self:GetText()
                    if pName and pName ~= "" then
                        SaveProfile(pName)
                        RefreshProfileFrame()
                    end
                    self:GetParent():Hide()
                end,
                EditBoxOnEscapePressed = function(self)
                    self:GetParent():Hide()
                end,
            }
            local popup = StaticPopup_Show("PEE_SKILLTREE_SAVE_PROFILE")
            if popup then popup:SetFrameStrata("TOOLTIP") end
        end)

        profileFrame.rows = {}
        table.insert(UISpecialFrames, "PEEOwnedSkillTreeProfileFrame")
    end

    RefreshProfileFrame()
    profileFrame:Show()
end


local function CreateNodes()
    wipe(nodesById)
    for _, n in ipairs(TreeNodes) do
        local btn = CreateFrame("Button", "peeOwnedSkillTreeNode" .. n.id, Canvas)
        btn:SetSize(28, 28)
        btn:SetPoint("TOPLEFT", Canvas, "TOPLEFT", n._ox, n._oy)
        btn._cx = n._ox
        btn._cy = -n._oy
        btn.id = n.id
        btn.isStart = n.isStart and true or false
        btn.state = btn.isStart and "ready" or "locked"


        btn.choiceButtons = {}


        btn.borderTex = btn:CreateTexture(nil, "BORDER")
        btn.borderTex:SetTexture("Interface\\Buttons\\WHITE8x8")
        btn.borderTex:SetVertexColor(1, 1, 1, 1)
        btn.borderTex:SetAlpha(0.7)
        btn.borderTex:SetPoint("TOPLEFT", btn, "TOPLEFT", -2, 2)
        btn.borderTex:SetPoint("BOTTOMRIGHT", btn, "BOTTOMRIGHT", 2, -2)


        btn.spells = n.spells
        btn.isMultipleChoice = n.isMultipleChoice or false
        btn.isApex = n.isApex or false
        btn.permanent = n.permanent or false

        btn.soulPointsCosts = n.soulPointsCosts

        btn.soulPointsCost = btn.soulPointsCosts and btn.soulPointsCosts[1] or 0


        if btn.isMultipleChoice then
            btn.selectedSpell = nodeChoices[n.id] or 0
        end




        local currentSpellID
        if btn.isMultipleChoice and nodeChoices[n.id] then
            currentSpellID = btn.spells[nodeChoices[n.id]]
        elseif btn.spells then
            local currentRank = getNodeRank(n.id)
            currentSpellID = btn.spells[math.max(1, currentRank)]
        end

        if currentSpellID then
            local _, _, iconTex = GetSpellInfo(currentSpellID)
            if not iconTex then
                iconTex = "Interface\\Icons\\INV_Misc_QuestionMark"
                DebugPrint("Warning: Invalid spell ID %s in CreateNodes",
                    currentSpellID)
            end
            btn.icon = btn:CreateTexture(nil, "ARTWORK")
            btn.icon:SetAllPoints(btn)
            btn.icon:SetTexCoord(0.07, 0.93, 0.07, 0.93)
            btn.icon:SetTexture(iconTex or
                "Interface\\Icons\\INV_Misc_QuestionMark")
        end
        btn.borderTex:SetVertexColor(1, 1, 1, 1)

        local function refreshNodeTooltip(node)
            if not node:IsMouseOver() then return end


            if NextRankTooltip then NextRankTooltip:Hide() end
            if CurrentRankTooltip then CurrentRankTooltip:Hide() end


            if node.spells and not node.isMultipleChoice then
                local currentRank = nodeRanks[node.id] or 0
                local maxRank = #node.spells


                if currentRank > 0 then
                    local currentSpellID = node.spells[currentRank]
                    if currentSpellID then
                        local spellName, _, spellIcon, castTime, minRange,
                        maxRange, _, _, _ = GetSpellInfo(currentSpellID)
                        if spellName then
                            CurrentRankTooltip:SetOwner(node, "ANCHOR_RIGHT")
                            CurrentRankTooltip:SetHyperlink('spell:' ..
                                currentSpellID)

                            if not node.permanent then
                                CurrentRankTooltip:AddLine(
                                    "\n|cff00FF00Rank: " .. currentRank .. "/" ..
                                    maxRank .. "|r", 1, 1, 1)
                            end

                            if currentRank < maxRank then
                                local nextRank = currentRank + 1
                                local soulCost = getNodeCost(node, nextRank)
                                local canAfford = TALENT_POINTS_TOTAL >= soulCost
                                addCostToTooltip(CurrentRankTooltip, "Next rank: ", soulCost, canAfford)
                            end

                            CurrentRankTooltip:Show()
                        end
                    end
                else
                    local firstSpellID = node.spells[1]
                    if firstSpellID then
                        local spellName, _, spellIcon, castTime, minRange,
                        maxRange, _, _, _ = GetSpellInfo(firstSpellID)
                        if spellName then
                            CurrentRankTooltip:SetOwner(node, "ANCHOR_RIGHT")
                            CurrentRankTooltip:SetHyperlink('spell:' ..
                                firstSpellID)

                            if not node.permanent then
                                CurrentRankTooltip:AddLine(
                                    "\n|cffFFFFFFRank: 0/" .. maxRank .. "|r", 1, 1, 1)
                            end

                            local soulCost = getNodeCost(node, 1)
                            local canAfford = TALENT_POINTS_TOTAL >= soulCost
                            local label = node.permanent and "" or (maxRank > 1 and "First rank: " or "")
                            addCostToTooltip(CurrentRankTooltip, label, soulCost, canAfford)

                            CurrentRankTooltip:Show()
                        end
                    end
                end

                if not node.isMultipleChoice and maxRank > 1 and currentRank > 0 then
                    local nextRank = currentRank + 1
                    if nextRank <= maxRank and NextRankTooltip then
                        local nextSpellID = node.spells[nextRank]
                        if nextSpellID then
                            local nextSpellName, _, nextSpellIcon, castTime,
                            minRange, maxRange, _, _, _ = GetSpellInfo(
                                nextSpellID)
                            if nextSpellName then
                                NextRankTooltip:SetOwner(node, "ANCHOR_NONE")
                                NextRankTooltip:SetPoint("TOPLEFT",
                                    CurrentRankTooltip,
                                    "BOTTOMLEFT", 0, -5)
                                NextRankTooltip:SetHyperlink('spell:' ..
                                    nextSpellID)
                                NextRankTooltip:AddLine(
                                    "|cffFFFFFFNext Rank " .. nextRank .. ":|r",
                                    1, 1, 1)
                                local soulCost = getNodeCost(node, nextRank)
                                local canAfford = TALENT_POINTS_TOTAL >= soulCost
                                addCostToTooltip(NextRankTooltip, "Cost: ", soulCost, canAfford)
                                NextRankTooltip:Show()
                            end
                        end
                    end
                end


                if node.state == "active" then
                    if node.permanent and lastValidatedState and lastValidatedState.nodeRanks
                        and (lastValidatedState.nodeRanks[node.id] or 0) > 0 then
                        CurrentRankTooltip:AddLine(
                            "|cffFF0000Permanent Skill|r", 1, 1, 1, true)
                    else
                        CurrentRankTooltip:AddLine(
                            "|cffAAAAAARight-click to unlearn|r", 1, 1, 1, true)
                    end
                    CurrentRankTooltip:Show();
                elseif node.state == "ready" then
                    if node.permanent then
                        CurrentRankTooltip:AddLine(
                            "|cffFF0000Permanent Skill|r", 1, 1, 1, true)
                    end
                    CurrentRankTooltip:AddLine(
                        "|cff00FF00Left-click to learn|r", 1, 1, 1, true)
                    CurrentRankTooltip:Show();
                end
            end
        end
        btn:SetScript("OnEnter", function(self)
            if self.spells then
                if self.isMultipleChoice and #self.spells > 1 then
                    ShowChoiceButtons(self)
                else
                    local currentRank = nodeRanks[self.id] or 0
                    local maxRank = #self.spells


                    if currentRank > 0 then
                        local currentSpellID = self.spells[currentRank]
                        if currentSpellID then
                            local spellName, _, spellIcon, castTime, minRange,
                            maxRange, _, _, _ = GetSpellInfo(
                                currentSpellID)
                            if spellName then
                                CurrentRankTooltip:SetOwner(self, "ANCHOR_RIGHT")
                                CurrentRankTooltip:SetHyperlink('spell:' ..
                                    currentSpellID)

                                if not self.permanent then
                                    CurrentRankTooltip:AddLine(
                                        "\n|cff00FF00Rank: " .. currentRank ..
                                        "/" .. maxRank .. "|r", 1, 1, 1)
                                end

                                if currentRank < maxRank then
                                    local nextRank = currentRank + 1
                                    local soulCost = getNodeCost(self, nextRank)
                                    local canAfford = TALENT_POINTS_TOTAL >= soulCost
                                    addCostToTooltip(CurrentRankTooltip, "Next rank: ", soulCost, canAfford)
                                end

                                CurrentRankTooltip:Show()
                            end
                        end
                    else
                        local firstSpellID = self.spells[1]
                        if firstSpellID then
                            local spellName, _, spellIcon, castTime, minRange,
                            maxRange, _, _, _ = GetSpellInfo(firstSpellID)
                            if spellName then
                                CurrentRankTooltip:SetOwner(self, "ANCHOR_RIGHT")
                                CurrentRankTooltip:SetHyperlink('spell:' ..
                                    firstSpellID)

                                if not self.permanent then
                                    CurrentRankTooltip:AddLine(
                                        "\n|cffFFFFFFRank: 0/" .. maxRank .. "|r", 1,
                                        1, 1)
                                end

                                local soulCost = getNodeCost(self, 1)
                                local canAfford = TALENT_POINTS_TOTAL >= soulCost
                                if self.permanent then
                                    addCostToTooltip(CurrentRankTooltip, "", soulCost, canAfford)
                                elseif maxRank > 1 then
                                    addCostToTooltip(CurrentRankTooltip, "First rank: ", soulCost, canAfford)
                                else
                                    addCostToTooltip(CurrentRankTooltip, "", soulCost, canAfford)
                                end

                                CurrentRankTooltip:Show()
                            end
                        end
                    end




                    if not self.isMultipleChoice and maxRank > 1 and currentRank >
                        0 then
                        local nextRank = currentRank + 1
                        if nextRank <= maxRank then
                            local nextSpellID = self.spells[nextRank]
                            if nextSpellID then
                                local nextSpellName, _, nextSpellIcon, castTime,
                                minRange, maxRange, _, _, _ =
                                    GetSpellInfo(nextSpellID)
                                if nextSpellName then
                                    NextRankTooltip:SetOwner(self, "ANCHOR_NONE")
                                    NextRankTooltip:SetPoint("TOPLEFT",
                                        CurrentRankTooltip,
                                        "BOTTOMLEFT", 0, -5)
                                    NextRankTooltip:SetHyperlink('spell:' ..
                                        nextSpellID)
                                    NextRankTooltip:AddLine(
                                        "|cffFFFFFFNext Rank " .. nextRank ..
                                        ":|r", 1, 1, 1)
                                    local soulCost = getNodeCost(self, nextRank)
                                    local canAfford = TALENT_POINTS_TOTAL >= soulCost
                                    addCostToTooltip(NextRankTooltip, "Cost: ", soulCost, canAfford)
                                    NextRankTooltip:Show()
                                end
                            end
                        end
                    end


                    if self.state == "active" then
                        if self.permanent and lastValidatedState and lastValidatedState.nodeRanks
                            and (lastValidatedState.nodeRanks[self.id] or 0) > 0 then
                            CurrentRankTooltip:AddLine(
                                "|cffFF0000Permanent Skill|r", 1, 1, 1, true)
                        else
                            CurrentRankTooltip:AddLine(
                                "|cffAAAAAARight-click to unlearn|r", 1, 1, 1, true)
                        end
                        CurrentRankTooltip:Show();
                    elseif self.state == "ready" then
                        if self.permanent then
                            CurrentRankTooltip:AddLine(
                                "|cffFF0000Permanent Skill|r", 1, 1, 1, true)
                        end
                        CurrentRankTooltip:AddLine(
                            "|cff00FF00Left-click to learn|r", 1, 1, 1, true)
                        CurrentRankTooltip:Show();
                    end
                end

                if self.isApex then
                    CurrentRankTooltip:AddLine(
                        "|cffFFAAAAOnly one Apex Talent can be active at a time.|r",
                        1, 1, 1, true)
                    CurrentRankTooltip:Show()
                end
            end
        end)
        btn:SetScript("OnLeave", function(self)
            if not self.hideFrame then
                self.hideFrame = CreateFrame("Frame")
            end

            self.hideFrame:SetScript("OnUpdate", function(frame, elapsed)
                elapsed = math.min(elapsed, 0.1) -- Cap elapsed to prevent freeze after alt-tab
                frame.timer = (frame.timer or 0) + elapsed
                if frame.timer > 0.1 then
                    frame:SetScript("OnUpdate", nil)
                    frame.timer = nil


                    local mouseOverChoice = false
                    for _, choiceBtn in ipairs(self.choiceButtons) do
                        if choiceBtn:IsMouseOver() then
                            mouseOverChoice = true
                            break
                        end
                    end

                    if not self:IsMouseOver() and not mouseOverChoice then
                        HideChoiceButtons(self)
                    end
                end
            end)


            NextRankTooltip:Hide()
            CurrentRankTooltip:Hide()
        end)




        btn:RegisterForClicks("LeftButtonUp", "RightButtonUp")
        btn:SetScript("OnClick", function(self, button)
            local nodeId = self.id
            local currentTime = GetTime()


            if currentTime - lastNodeClickTime < NODE_CLICK_COOLDOWN then
                return
            end


            if currentTime - rapidClickResetTime > RAPID_CLICK_WINDOW then
                rapidClickCount = 0
                rapidClickResetTime = currentTime
            end

            rapidClickCount = rapidClickCount + 1

            if rapidClickCount > RAPID_CLICK_THRESHOLD then
                return
            end

            lastNodeClickTime = currentTime


            if UnitAffectingCombat("player") then
                DebugPrint("|cffFF0000You cannot modify your skill tree while in combat!|r")
                return
            end

            if button == "LeftButton" then
                if self.isMultipleChoice then
                    if #self.choiceButtons == 0 then
                        DebugPrint(
                            "|cffFFFF00Hover over this node to see available choices|r")
                    end
                    return
                end


                if canUpgradeNode(nodeId) then
                    if self.permanent then
                        local selfRef = self
                        StaticPopupDialogs["PEE_SKILLTREE_PERMANENT_CONFIRM"] = {
                            text =
                            "|cffFF4444Warning: Permanent SKill|r\n\nThis Skill is |cffFF0000permanent|r and cannot be unlearned once the changes are applied.\n\nAre you sure you want to learn it?",
                            button1 = "Yes, Learn It",
                            button2 = "Cancel",
                            timeout = 0,
                            whileDead = true,
                            hideOnEscape = true,
                            showAlert = true,
                            OnAccept = function()
                                local success = upgradeNodeRank(nodeId)
                                if success then
                                    refreshAccessibility()
                                    local currentRank = nodeRanks[nodeId] or 0
                                    local maxRank = #selfRef.spells or 0
                                    DebugPrint("|cff00FF00Permanent talent upgraded to rank " ..
                                        currentRank .. "/" .. maxRank .. "!|r")
                                    refreshNodeTooltip(selfRef)
                                end
                            end,
                        }
                        local popup = StaticPopup_Show("PEE_SKILLTREE_PERMANENT_CONFIRM")
                        if popup then
                            popup:SetFrameStrata("TOOLTIP")
                        end
                        return
                    end

                    local success = upgradeNodeRank(nodeId)
                    if success then
                        refreshAccessibility()
                        local currentRank = nodeRanks[nodeId] or 0
                        local maxRank = #self.spells or 0
                        DebugPrint("|cff00FF00Talent upgraded to rank " ..
                            currentRank .. "/" .. maxRank .. "!|r")

                        refreshNodeTooltip(self)
                    end
                else
                    local currentRank = nodeRanks[nodeId] or 0
                    local maxRank = #self.spells or 0

                    if currentRank >= maxRank then
                        DebugPrint(
                            "|cffFF0000Talent is already at maximum rank (" ..
                            maxRank .. ")!|r")
                    elseif not canAffordTalent(nodeId) then
                        DebugPrint("|cffFF0000Not enough Soul Ashes!|r")
                    elseif self.state == "locked" then
                        DebugPrint("|cffFF0000Prerequisites not met!|r")
                    end
                end
            elseif button == "RightButton" then
                if self.isMultipleChoice and #self.choiceButtons > 0 then
                    HideChoiceButtons(self)
                    return
                end


                if not self.isMultipleChoice then
                    if self.permanent and lastValidatedState and lastValidatedState.nodeRanks
                        and (lastValidatedState.nodeRanks[nodeId] or 0) > 0 then
                        DebugPrint("|cffFF0000This talent is permanent and cannot be unlearned!|r")
                        return
                    end

                    if canDowngradeNode(nodeId) then
                        local success = downgradeNodeRank(nodeId)
                        if success then
                            refreshAccessibility()
                            local currentRank = getNodeRank(nodeId)
                            local maxRank = getMaxRank(nodeId)
                            DebugPrint("|cffFFFF00Talent downgraded to rank " ..
                                currentRank .. "/" .. maxRank ..
                                ".|r")

                            refreshNodeTooltip(self)
                        end
                    else
                        local currentRank = getNodeRank(nodeId)
                        if currentRank <= 0 then
                            DebugPrint("|cffFF0000Talent is not learned yet!|r")
                        else
                            DebugPrint(
                                "|cffFF0000Cannot downgrade: Other talents depend on this one!|r")
                        end
                    end
                end
            end
        end)




        btn:SetScript("OnMouseDown", function(self, button)
            if (button == "LeftButton" and self.state == "ready") or
                (button == "RightButton" and self.state == "active") then
                return
            end


            if Scroll:GetScript("OnMouseDown") then
                Scroll:GetScript("OnMouseDown")(Scroll, button)
            end
        end)
        btn:SetScript("OnMouseUp", function(_, button)
            if Scroll:GetScript("OnMouseUp") then
                Scroll:GetScript("OnMouseUp")(Scroll, button)
            end
        end)

        nodesById[n.id] = btn
        applyNodeVisual(btn)
    end
end

local function CreateLinks()
    for _, L in ipairs(lines) do
        if L.animGroup then
            L.animGroup:Stop()
        end

        if L.driver then
            L.driver:SetScript("OnUpdate", nil)
            L.driver:Hide()
        end

        if L.tex then L.tex:Hide() end

        if L.segments then
            for _, segment in ipairs(L.segments) do segment:Hide() end
        end
    end
    wipe(lines)

    for _, e in ipairs(Links) do
        local a, b = nodesById[e[1]], nodesById[e[2]]
        if a and b then
            local ax, ay = NodeCenterOffsets(a)
            local bx, by = NodeCenterOffsets(b)


            local mainTex, allSegments, driver, animGroup =
                MakeAnimatedRotatingLine(ax, ay, bx, by, 3)
            if mainTex then
                lines[#lines + 1] = {
                    tex = mainTex,
                    segments = allSegments,
                    driver = driver,
                    animGroup = animGroup,
                    a = a,
                    b = b
                }
            end
        end
    end
    updateLinkColors()
end




local dragging = false
local startX, startY, startH, startV

local function GetCursorScaled()
    local x, y = GetCursorPosition()
    local s = UIParent:GetEffectiveScale()
    return x / s, y / s
end

Scroll:SetScript("OnMouseDown", function(self, button)
    if button == "LeftButton" or button == "RightButton" then
        dragging = true
        startX, startY = GetCursorScaled()
        startH = self:GetHorizontalScroll()
        startV = self:GetVerticalScroll()
    end
end)

Scroll:SetScript("OnMouseUp", function(self, button)
    if button == "LeftButton" or button == "RightButton" then
        dragging = false
    end
end)

local scrollUpdateTimer = 0
local SCROLL_UPDATE_INTERVAL = 0.016
Scroll:SetScript("OnUpdate", function(self, elapsed)
    if ProjectEbonhold_IsClosing then return end
    if not dragging or not UIParent:IsShown() then return end
    elapsed = math.min(elapsed, 0.1) -- Cap elapsed to prevent freeze after alt-tab

    scrollUpdateTimer = scrollUpdateTimer + elapsed
    if scrollUpdateTimer < SCROLL_UPDATE_INTERVAL then return end
    scrollUpdateTimer = 0

    local x, y = GetCursorScaled()
    local dx, dy = x - startX, y - startY


    if math.abs(dx) < 2 and math.abs(dy) < 2 then return end

    local newH, newV = ClampScrollToTreeBounds(startH - dx, startV + dy)

    self:SetHorizontalScroll(newH)
    self:SetVerticalScroll(newV)
end)


local isTreeInitialized = false




local function InitTree()
    if isTreeInitialized then
        DebugPrint("Tree already initialized, skipping...")
        return
    end

    DebugPrint("Initializing tree...", ProjectEbonhold)


    if ProjectEbonhold and ProjectEbonhold.RequestLoadoutFromServer then
        DebugPrint("Requesting loadout from server...")
        ProjectEbonhold.RequestLoadoutFromServer()
    end

    ComputeLayout()
    BuildNeighborsAndParents()
    CreateNodes()
    CreateLinks()
    CreateBottomBar()
    refreshAccessibility()
    CheckInitialState()
    RefreshLoadoutDropdown()
    isTreeInitialized = true
    DebugPrint("Tree initialization complete")
end

peeOwnedSkillTreeFrame:SetScript("OnShow", function()
    InitTree()

    refreshAccessibility()
    if Chrome.RefreshOwnedSkillTreeChrome then
        Chrome.RefreshOwnedSkillTreeChrome()
    end
    ScheduleFitAndCenterTree()
    C_Timer.After(0.1, function()
        if _G.peeOwnedSkillTreeBottomBar and _G.peeOwnedSkillTreeBottomBar.updateLevelRestriction then
            _G.peeOwnedSkillTreeBottomBar.updateLevelRestriction()
        end
    end)
end)

peeOwnedSkillTreeFrame:SetScript("OnSizeChanged", function(self)
    if not self:IsShown() then return end
    if Chrome.RefreshOwnedSkillTreeChrome then
        Chrome.RefreshOwnedSkillTreeChrome()
    end
    if not Scroll:IsShown() then return end
    FitAndCenterTree()
end)


ProjectEbonhold.SkillTree = ProjectEbonhold.SkillTree or {}
ProjectEbonhold.SkillTree.OnApplyChangesResult = OnApplyChangesResult


ProjectEbonhold.SkillTree.UpdateTotalSoulPoints =
    function(spendablePoints, committedPoints)
        TALENT_POINTS_TOTAL = spendablePoints
        TALENT_POINT_TOTAL_BASE = committedPoints

        if peeOwnedSkillTreeFrame and peeOwnedSkillTreeFrame.pointsText then
            peeOwnedSkillTreeFrame.pointsText:SetText(
                "|cffFFD700Available Soul Ashes:|r " .. GetRemainingTalentPoints())
        end
        if peeOwnedSkillTreeFrame and peeOwnedSkillTreeFrame.progressBar and peeOwnedSkillTreeFrame.progressBar.UpdateProgressBar then
            peeOwnedSkillTreeFrame.progressBar.UpdateProgressBar()
        end
        if Chrome.RefreshOwnedSkillTreeChrome then
            Chrome.RefreshOwnedSkillTreeChrome()
        end

        refreshAccessibility()
        DebugPrint(
            "|cff00FF00Soul Ashes updated - Spendable: %d, Committed: %d|r",
            TALENT_POINTS_TOTAL, TALENT_POINT_TOTAL_BASE)
    end

local PEE_SKILL_TREE_PREFIX = "AAM0x9"
local peeOwnedSkillTreeChunks = {}

local function ParseOwnedLoadoutData(dataString)
    if not dataString or dataString == "" then
        return nil
    end

    local globalPart, loadoutsPart = dataString:match("([^_]+)_?(.*)")
    if not globalPart then
        return nil
    end

    local selectedLoadoutId, spendableSoulPoints, totalCommitedSoulPoints, maximumPermanentEchoes = globalPart:match(
        "(%d+),(%d+),(%d+),(%d+)")
    spendableSoulPoints = tonumber(spendableSoulPoints)
    if not spendableSoulPoints then
        return nil
    end

    local result = {
        selectedLoadoutId = tonumber(selectedLoadoutId),
        spendableSoulPoints = spendableSoulPoints,
        totalCommitedSoulPoints = tonumber(totalCommitedSoulPoints) or 0,
        maximumPermanentEchoes = tonumber(maximumPermanentEchoes),
        loadouts = {},
    }

    if loadoutsPart and loadoutsPart ~= "" then
        for loadoutString in string.gmatch(loadoutsPart, "([^;]+)") do
            local parts = {}
            for part in string.gmatch(loadoutString, "([^,]+)") do
                table.insert(parts, part)
            end

            if #parts >= 3 then
                local loadout = {
                    id = tonumber(parts[1]),
                    name = parts[2],
                    spendablePoints = tonumber(parts[3]),
                    nodeRanks = {},
                    totalNodes = 0,
                    totalRanks = 0,
                }

                for index = 4, #parts do
                    local nodeId, rank = parts[index]:match("(%d+):(%d+)")
                    if nodeId and rank then
                        nodeId = tonumber(nodeId)
                        rank = tonumber(rank)
                        loadout.nodeRanks[nodeId] = rank
                        loadout.totalNodes = loadout.totalNodes + 1
                        loadout.totalRanks = loadout.totalRanks + rank
                    end
                end

                table.insert(result.loadouts, loadout)
            end
        end
    end

    return result
end

local function HandleOwnedSkillTreePayload(body)
    local parsedData = ParseOwnedLoadoutData(body)
    if parsedData and Addon.ApplyLoadoutsFromServer then
        Addon.ApplyLoadoutsFromServer(parsedData)
    end
end

local function InstallOwnedSkillTreeMessageListener()
    if overlay._peeOwnedSkillTreeMessageFrame or not CreateFrame then
        return
    end

    local frame = CreateFrame("Frame")
    frame:RegisterEvent("CHAT_MSG_ADDON")
    frame:SetScript("OnEvent", function(_, _, prefix, payload)
        if prefix ~= PEE_SKILL_TREE_PREFIX or not payload or payload == "" then
            return
        end

        local eventText, body = payload:match("^(%d+)\t(.*)$")
        local eventId = tonumber(eventText)
        local project = _G and _G.ProjectEbonhold
        local loadoutsEventId = project and project.SS and project.SS.SEND_LOADOUTS or 3
        if eventId ~= loadoutsEventId or not body then
            return
        end

        local messageId, chunkIndex, chunkTotal, chunkBody =
            body:match("^@([0-9A-Fa-f][0-9A-Fa-f][0-9A-Fa-f][0-9A-Fa-f])" ..
                "\t([0-9A-Fa-f][0-9A-Fa-f][0-9A-Fa-f])/" ..
                "([0-9A-Fa-f][0-9A-Fa-f][0-9A-Fa-f])\t(.*)$")
        if not messageId then
            HandleOwnedSkillTreePayload(body)
            return
        end

        local key = tostring(eventId) .. ":" .. messageId
        local record = peeOwnedSkillTreeChunks[key]
        if not record then
            record = { total = tonumber(chunkTotal, 16) or 0, count = 0, parts = {} }
            peeOwnedSkillTreeChunks[key] = record
        end

        local index = tonumber(chunkIndex, 16)
        if index and index >= 1 and index <= record.total and not record.parts[index] then
            record.parts[index] = chunkBody
            record.count = record.count + 1
        end

        if record.total > 0 and record.count == record.total then
            peeOwnedSkillTreeChunks[key] = nil
            HandleOwnedSkillTreePayload(table.concat(record.parts, "", 1, record.total))
        end
    end)

    overlay._peeOwnedSkillTreeMessageFrame = frame
end

local function HideServerSkillTreeFrame()
    local serverFrame = _G and _G.skillTreeFrame
    if serverFrame and serverFrame ~= peeOwnedSkillTreeFrame and serverFrame.Hide then
        serverFrame:Hide()
    end
end

local function RefreshAsheProgressSimulation()
    local topBar = peeOwnedSkillTreeFrame and peeOwnedSkillTreeFrame.peeSkillTreeTopBar
    if not topBar and Chrome.EnsureOwnedSkillTreeTopBar then
        topBar = Chrome.EnsureOwnedSkillTreeTopBar()
    end
    if topBar and Chrome.WriteOwnedTopBarProgress then
        Chrome.WriteOwnedTopBarProgress(topBar)
    end

    local _, _, ratio = GetAsheProgressSimulationValue()
    if ratio and ratio >= 1 and asheProgressSimulation.frame then
        asheProgressSimulation.frame:SetScript("OnUpdate", nil)
        asheProgressSimulation.complete = true
    end
end

overlay.StartAsheProgressSimulation = function()
    if not peeOwnedSkillTreeFrame then
        return false, "Soul Ashe Tree is not available yet."
    end
    local createFrame = _G and _G.CreateFrame
    if not createFrame then
        return false, "Soul Ashe progression test requires the WoW UI frame API."
    end

    if overlay.ShowOwnedSoulAsheTree then
        overlay.ShowOwnedSoulAsheTree()
    elseif peeOwnedSkillTreeFrame.Show then
        HideServerSkillTreeFrame()
        peeOwnedSkillTreeFrame:Show()
    end

    asheProgressSimulation.active = true
    asheProgressSimulation.complete = false
    asheProgressSimulation.duration = 10
    local getTime = _G and _G.GetTime
    asheProgressSimulation.startedAt = getTime and getTime() or 0
    asheProgressSimulation.cap = GetOwnedAsheProgressCap()

    if not asheProgressSimulation.frame then
        asheProgressSimulation.frame = createFrame("Frame")
    end
    asheProgressSimulation.frame:SetScript("OnUpdate", RefreshAsheProgressSimulation)
    RefreshAsheProgressSimulation()
    DebugPrint("Soul Ashe progression test started. Cap: %d", asheProgressSimulation.cap)
    return true, "Soul Ashe progression test started. It fills over 10 seconds. Use /pee ashe stop to restore real progress."
end

overlay.StopAsheProgressSimulation = function()
    local wasActive = asheProgressSimulation.active
    asheProgressSimulation.active = false
    asheProgressSimulation.complete = false
    asheProgressSimulation.startedAt = nil
    if asheProgressSimulation.frame then
        asheProgressSimulation.frame:SetScript("OnUpdate", nil)
    end
    if Chrome.RefreshOwnedSkillTreeTopBar then
        Chrome.RefreshOwnedSkillTreeTopBar()
    end
    DebugPrint("Soul Ashe progression test stopped.")
    if wasActive then
        return true, "Soul Ashe progression test stopped. Real progress restored."
    end
    return true, "Soul Ashe progression test was not running."
end

overlay.UsesOwnedSoulAsheTree = function()
    return true
end

overlay.GetOwnedSoulAsheTreeFrame = function()
    return peeOwnedSkillTreeFrame
end

overlay.ShowOwnedSoulAsheTree = function()
    HideServerSkillTreeFrame()
    peeOwnedSkillTreeFrame:Show()
    if ProjectEbonhold and ProjectEbonhold.RequestLoadoutFromServer then
        ProjectEbonhold.RequestLoadoutFromServer()
    end
    return true
end

overlay.HideOwnedSoulAsheTree = function()
    peeOwnedSkillTreeFrame:Hide()
end

overlay.ToggleOwnedSoulAsheTree = function()
    HideServerSkillTreeFrame()
    if peeOwnedSkillTreeFrame:IsShown() then
        peeOwnedSkillTreeFrame:Hide()
    else
        overlay.ShowOwnedSoulAsheTree()
    end
end

overlay.InstallOwnedSoulAsheTree = function()
    InstallOwnedSkillTreeMessageListener()
    HideServerSkillTreeFrame()

    if _G and _G.SkillTreeMicroButton and not _G.SkillTreeMicroButton._peeOwnedSoulAsheClick then
        _G.SkillTreeMicroButton:SetScript("OnClick", function(_, button)
            if button ~= "LeftButton" then
                return
            end
            if _G.SkillTreeMicroButton_StopFlashing then
                _G.SkillTreeMicroButton_StopFlashing()
            end
            if _G.SkillTreeMicroButton_HideAlert then
                _G.SkillTreeMicroButton_HideAlert()
            end
            overlay.ToggleOwnedSoulAsheTree()
        end)
        _G.SkillTreeMicroButton._peeOwnedSoulAsheClick = true
    end

    if _G and type(_G.UpdateMicroButtons) == "function" and not overlay._peeOwnedSoulAsheMicroHooked then
        hooksecurefunc("UpdateMicroButtons", function()
            if not _G.SkillTreeMicroButton or not peeOwnedSkillTreeFrame then
                return
            end
            if peeOwnedSkillTreeFrame:IsShown() then
                _G.SkillTreeMicroButton:SetButtonState("PUSHED", 1)
            else
                _G.SkillTreeMicroButton:SetButtonState("NORMAL")
            end
        end)
        overlay._peeOwnedSoulAsheMicroHooked = true
    end
end
