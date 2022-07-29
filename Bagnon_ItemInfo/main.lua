if (not Bagnon) then
	return
end

-- Using the Bagnon way to retrieve names, namespaces and stuff
local MODULE =  ...
local ADDON, Addon = MODULE:match("[^_]+"), _G[MODULE:match("[^_]+")]
local Module = Bagnon:NewModule("ItemInfo", Addon)

-- Tooltip used for scanning
local sTipName = "BagnonItemInfoScannerTooltip"
local sTip = _G[sTipName] or CreateFrame("GameTooltip", sTipName, WorldFrame, "GameTooltipTemplate")

-- Lua API
local _G = _G
local ipairs = ipairs
local select = select
local string_find = string.find
local string_gsub = string.gsub
local string_lower = string.lower
local string_match = string.match
local string_split = string.split
local string_upper = string.upper
local tonumber = tonumber

-- WoW API
local C_TransmogCollection = _G.C_TransmogCollection
local CreateFrame = _G.CreateFrame
local GetContainerItemInfo = _G.GetContainerItemInfo
local GetDetailedItemLevelInfo = _G.GetDetailedItemLevelInfo
local GetItemInfo = _G.GetItemInfo
local IsArtifactRelicItem = _G.IsArtifactRelicItem

-- WoW Strings
local S_BOUND1 = _G.ITEM_SOULBOUND
local S_BOUND2 = _G.ITEM_ACCOUNTBOUND
local S_BOUND3 = _G.ITEM_BNETACCOUNTBOUND

-- Transmogrification strings
local S_UNCOLLECTED = _G.TRANSMOGRIFY_STYLE_UNCOLLECTED
local S_UNKNOWN = _G.TRANSMOGRIFY_TOOLTIP_APPEARANCE_UNKNOWN

-- Tooltip and scanning by Phanx
-- Source: http://www.wowinterface.com/forums/showthread.php?p=271406
local S_ILVL = "^" .. string_gsub(_G.ITEM_LEVEL, "%%d", "(%%d+)")

-- Redoing this to take other locales into consideration,
-- and to make sure we're capturing the slot count, and not the bag type.
local S_SLOTS = "^" .. (string.gsub(string.gsub(CONTAINER_SLOTS, "%%([%d%$]-)d", "(%%d+)"), "%%([%d%$]-)s", "%.+"))

-- WoW Client versions
local currentClientPatch, currentClientBuild = GetBuildInfo()
currentClientBuild = tonumber(currentClientBuild)

local MAJOR,MINOR,PATCH = string.split(".", currentClientPatch)
MAJOR = tonumber(MAJOR)

local WoWClassic = MAJOR == 1
local WoWBCC = MAJOR == 2
local WoWWotLK = MAJOR == 3

-- Localization.
-- *Just enUS so far.
local L = {
	["BoE"] = "BoE", -- Bind on Equip
	["BoU"] = "BoU"  -- Bind on Use
}

-- Quality colors for faster lookups
local Colors = {
	[0] = { 157/255, 157/255, 157/255 }, -- Poor
	[1] = { 240/255, 240/255, 240/255 }, -- Common
	[2] = { 30/255, 178/255, 0/255 }, -- Uncommon
	[3] = { 0/255, 112/255, 221/255 }, -- Rare
	[4] = { 163/255, 53/255, 238/255 }, -- Epic
	[5] = { 225/255, 96/255, 0/255 }, -- Legendary
	[6] = { 229/255, 204/255, 127/255 }, -- Artifact
	[7] = { 79/255, 196/255, 225/255 }, -- Heirloom
	[8] = { 79/255, 196/255, 225/255 } -- Blizzard
}

-- FontString & Texture Caches
local Cache_ItemBind = {}
local Cache_ItemGarbage = {}
local Cache_ItemLevel = {}
local Cache_Uncollected = {}

-- Saved settings
_G.BagnonItemInfo_DB = {
	enableItemLevel = true,
	enableItemBind = true,
	enableGarbage = true,
	enableUncollected = true,
	enableRarityColoring = true
}

-- Slash Command & Options Handling
local slashHandler = function(msg, editBox)
	local action, element

	-- Remove spaces at the start and end
	msg = string_gsub(msg, "^%s+", "")
	msg = string_gsub(msg, "%s+$", "")

	-- Replace all space characters with single spaces
	msg = string_gsub(msg, "%s+", " ")

	-- Extract the arguments
	if (string_find(msg, "%s")) then
		action, element = string_split(" ", msg)
	else
		action = msg
	end

	if (action == "enable") then
		if (element == "itemlevel" or element == "ilvl") then
			BagnonItemInfo_DB.enableItemLevel = true
		elseif (element == "boe" or element == "bind") then
			BagnonItemInfo_DB.enableItemBind = true
		elseif (element == "junk" or element == "trash" or element == "garbage") then
			BagnonItemInfo_DB.enableGarbage = true
		elseif (element == "eye" or element == "transmog" or element == "uncollected") then
			BagnonItemInfo_DB.enableUncollected = true
		elseif (element == "color") then
			BagnonItemInfo_DB.enableRarityColoring = true
		end

	elseif (action == "disable") then
		if (element == "itemlevel" or element == "ilvl") then
			BagnonItemInfo_DB.enableItemLevel = false
		elseif (element == "boe" or element == "bind") then
			BagnonItemInfo_DB.enableItemBind = false
		elseif (element == "junk" or element == "trash" or element == "garbage") then
			BagnonItemInfo_DB.enableGarbage = false
		elseif (element == "eye" or element == "transmog" or element == "uncollected") then
			BagnonItemInfo_DB.enableUncollected = false
		elseif (element == "color") then
			BagnonItemInfo_DB.enableRarityColoring = false
		end
	end
end


-----------------------------------------------------------
-- Utility Functions
-----------------------------------------------------------

-- Check if it's a caged battle pet
local GetBattlePetInfo = function(itemLink)
	if (string_find(itemLink, "battlepet")) then
		local data, name = string_match(itemLink, "|H(.-)|h(.-)|h")
		local  _, _, level, rarity = string_match(data, "(%w+):(%d+):(%d+):(%d+)")
		return true, level or 1, tonumber(rarity) or 0
	end
end

-----------------------------------------------------------
-- Cache & Creation
-----------------------------------------------------------
-- Retrieve a button's plugin container
local GetPluginContainter = function(button)
	local name = button:GetName() .. "ExtraInfoFrame"
	local frame = _G[name]
	if (not frame) then
		frame = CreateFrame("Frame", name, button)
		frame:SetAllPoints()
	end
	return frame
end

local Cache_GetItemLevel = function(button)
	if (not Cache_ItemLevel[button]) then
		local ItemLevel = GetPluginContainter(button):CreateFontString()
		ItemLevel:SetDrawLayer("ARTWORK", 1)
		ItemLevel:SetPoint("TOPLEFT", 2, -2)
		ItemLevel:SetFontObject(_G.NumberFont_Outline_Med or _G.NumberFontNormal)
		ItemLevel:SetShadowOffset(1, -1)
		ItemLevel:SetShadowColor(0, 0, 0, .5)
		local UpgradeIcon = button.UpgradeIcon
		if UpgradeIcon then
			UpgradeIcon:ClearAllPoints()
			UpgradeIcon:SetPoint("BOTTOMRIGHT", 2, 0)
		end
		Cache_ItemLevel[button] = ItemLevel
	end
	return Cache_ItemLevel[button]
end

local Cache_GetItemBind = function(button)
	if (not Cache_ItemBind[button]) then
		local ItemBind = GetPluginContainter(button):CreateFontString()
		ItemBind:SetDrawLayer("ARTWORK")
		ItemBind:SetPoint("BOTTOMLEFT", 2, 2)
		ItemBind:SetFontObject(_G.NumberFont_Outline_Med or _G.NumberFontNormal)
		ItemBind:SetFont(ItemBind:GetFont(), 12, "OUTLINE")
		ItemBind:SetShadowOffset(1, -1)
		ItemBind:SetShadowColor(0, 0, 0, .5)
		local UpgradeIcon = button.UpgradeIcon
		if UpgradeIcon then
			UpgradeIcon:ClearAllPoints()
			UpgradeIcon:SetPoint("BOTTOMRIGHT", 2, 0)
		end
		Cache_ItemBind[button] = ItemBind
	end
	return Cache_ItemBind[button]
end

local Cache_GetItemGarbage = function(button)
	if (not Cache_ItemGarbage[button]) then
		local Icon = button.icon or _G[button:GetName().."IconTexture"]
		local ItemGarbage = button:CreateTexture()
		ItemGarbage:Hide()
		ItemGarbage:SetDrawLayer("ARTWORK")
		ItemGarbage:SetAllPoints(Icon)
		ItemGarbage:SetColorTexture(51/255 * 1/5,  17/255 * 1/5,   6/255 * 1/5, .6)
		ItemGarbage.owner = button

		hooksecurefunc(Icon, "SetDesaturated", function()
			if (ItemGarbage.tempLocked) or (not BagnonItemInfo_DB.enableGarbage) then
				return
			end

			ItemGarbage.tempLocked = true

			local itemLink = button:GetItem()
			if (itemLink) then
				local itemRarity
				local _, _, locked, quality, _, _, _, _, noValue = GetContainerItemInfo(button:GetBag(),button:GetID())
				if (string_find(itemLink, "battlepet")) then
					local data = string_match(itemLink, "|H(.-)|h(.-)|h")
					local  _, _, _, rarity = string_match(data, "(%w+):(%d+):(%d+):(%d+)")
					itemRarity = tonumber(rarity) or 0
				else
					_, _, itemRarity = GetItemInfo(itemLink)
				end
				if not(((quality and (quality > 0)) or (itemRarity and (itemRarity > 0))) and (not locked)) then
					Icon:SetDesaturated(true)
				end
			end

			ItemGarbage.tempLocked = false
		end)

		Cache_ItemGarbage[button] = ItemGarbage
	end
	return Cache_ItemGarbage[button]
end

local Cache_GetUncollected = function(button)
	if (not Cache_Uncollected[button]) then
		local Uncollected = GetPluginContainter(button):CreateTexture()
		Uncollected:SetDrawLayer("OVERLAY")
		Uncollected:SetPoint("CENTER", 0, 0)
		Uncollected:SetSize(24,24)
		Uncollected:SetTexture([[Interface\Transmogrify\Transmogrify]])
		Uncollected:SetTexCoord(0.804688, 0.875, 0.171875, 0.230469)
		Uncollected:Hide()
		local UpgradeIcon = button.UpgradeIcon
		if UpgradeIcon then
			UpgradeIcon:ClearAllPoints()
			UpgradeIcon:SetPoint("BOTTOMRIGHT", 2, 0)
		end
		Cache_Uncollected[button] = Uncollected
	end
	return Cache_Uncollected[button]
end

-----------------------------------------------------------
-- Main Update
-----------------------------------------------------------
local Update = function(self)
	local itemLink = self:GetItem()
	if (itemLink) then

		-- Get some blizzard info about the current item
		local itemID = tonumber(string_match(itemLink, "item:(%d+)"))
		local _, _, itemRarity, itemLevel, _, _, _, _, itemEquipLoc, _, _, _, _, bindType = GetItemInfo(itemLink)

		-- Some more general info
		local bag,slot = self:GetBag(),self:GetID()
		local displayR, displayG, displayB, hasTip
		local isPet, petLevel, petRarity

		-- Only these two require rarity coloring
		if (BagnonItemInfo_DB.enableItemLevel or BagnonItemInfo_DB.enableItemBind) then

			if (string_find(itemLink, "battlepet")) then
				local data, name = string_match(itemLink, "|H(.-)|h(.-)|h")
				local  _, _, level, rarity = string_match(data, "(%w+):(%d+):(%d+):(%d+)")
				isPet, petLevel, petRarity = true, level or 1, tonumber(rarity) or 0
			end

			-- Check if we actually have a valid rarity before retrieving the color. Doh.
			if (petRarity) or (itemRarity and itemRarity > 1) and (BagnonItemInfo_DB.enableRarityColoring) then

				-- Use our own color table for faster lookups
				local col = Colors[petRarity or itemRarity]
				if (col) then
					displayR, displayG, displayB = col[1], col[2], col[3]
				end
			end
		end

		---------------------------------------------------
		-- Uncollected Appearance
		---------------------------------------------------
		if (BagnonItemInfo_DB.enableUncollected) and (itemRarity and itemRarity > 1) and (C_TransmogCollection and not C_TransmogCollection.PlayerHasTransmog(itemID)) then

			-- Avoid setting tooltip unless we have to
			if (not hasTip) then
				hasTip = true
				sTip.owner = self
				sTip.bag = bag
				sTip.slot = slot
				sTip:SetOwner(self, "ANCHOR_NONE")
				sTip:SetBagItem(bag,slot)
			end

			local unknown
			for i = sTip:NumLines(),2,-1 do
				local line = _G[sTipName.."TextLeft"..i]
				if (line) then
					local msg = line:GetText()
					if msg and (string_find(msg, S_UNCOLLECTED) or string_find(msg, S_UNKNOWN)) then
						unknown = true
						break
					end
				end
			end
			if (unknown) then
				local Uncollected = Cache_Uncollected[self] or Cache_GetUncollected(self)
				Uncollected:Show()
			else
				if (Cache_Uncollected[self]) then
					Cache_Uncollected[self]:Hide()
				end
			end
		else
			if (Cache_Uncollected[self]) then
				Cache_Uncollected[self]:Hide()
			end
		end

		---------------------------------------------------
		-- ItemBind (BoE, BoU)
		---------------------------------------------------
		if (BagnonItemInfo_DB.enableItemBind) and (itemRarity and (itemRarity > 1)) and ((bindType == 2) or (bindType == 3)) then

			local showStatus = true
			local _, _, _, _, _, _, _, _, _, _, isBound = GetContainerItemInfo(bag, slot)
			if (isBound) then
				showStatus = nil
			end

			-- Bagnon_BoE bug report #6 indicates that GetContainerItemInfo isn't returning 'isBound' in the classics.
			if (showStatus) and (WoWBCC or WoWClassic or WoWWotLK) then

				-- Avoid setting tooltip unless we have to
				if (not hasTip) then
					hasTip = true
					sTip.owner = self
					sTip.bag = bag
					sTip.slot = slot
					sTip:SetOwner(self, "ANCHOR_NONE")
					sTip:SetBagItem(bag,slot)
				end

				for i = 2,6 do
					local line = _G[sTipName.."TextLeft"..i]
					if (not line) then
						break
					end
					local msg = line:GetText()
					if (msg) then
						if (string_find(msg, S_BOUND1) or string_find(msg, S_BOUND2) or string_find(msg, S_BOUND3)) then
							showStatus = nil
							break
						end
					end
				end
			end

			if (showStatus) then
				local ItemBind = Cache_ItemBind[self] or Cache_GetItemBind(self)
				if (BagnonItemInfo_DB.enableRarityColoring) and (displayR) and (displayG) and (displayB) then
					local m = (itemRarity == 3 or itemRarity == 4) and 1 or 2/3
					ItemBind:SetTextColor(displayR * m, displayG * m, displayB * m)
				else
					ItemBind:SetTextColor(240/255, 240/255, 240/255)
				end
				ItemBind:SetText((bindType == 3) and L["BoU"] or L["BoE"])
			else
				if (Cache_ItemBind[self]) then
					Cache_ItemBind[self]:SetText("")
				end
			end

		else
			if (Cache_ItemBind[self]) then
				Cache_ItemBind[self]:SetText("")
			end
		end

		---------------------------------------------------
		-- ItemLevel
		---------------------------------------------------
		if (BagnonItemInfo_DB.enableItemLevel) then
			local displayMsg

			if (itemEquipLoc == "INVTYPE_BAG") then

				-- Avoid setting tooltip unless we have to
				if (not hasTip) then
					hasTip = true
					sTip.owner = self
					sTip.bag = bag
					sTip.slot = slot
					sTip:SetOwner(self, "ANCHOR_NONE")
					sTip:SetBagItem(bag,slot)
				end

				local line = _G[sTipName.."TextLeft3"]
				if (line) then
					local msg = line:GetText()
					if (msg) and (string_find(msg, S_SLOTS)) then
						local bagSlots = string_match(msg, S_SLOTS)
						if (bagSlots) and (tonumber(bagSlots) > 0) then
							displayMsg = bagSlots
						end
					else
						line = _G[sTipName.."TextLeft4"]
						if (line) then
							local msg = line:GetText()
							if (msg) and (string_find(msg, S_SLOTS)) then
								local bagSlots = string_match(msg, S_SLOTS)
								if (bagSlots) and (tonumber(bagSlots) > 0) then
									displayMsg = bagSlots
								end
							end
						end
					end
				end

			-- Display item level of equippable gear and artifact relics, and battle pet level
			elseif ((itemRarity and (itemRarity > 0)) and ((itemEquipLoc and _G[itemEquipLoc]) or (itemID and IsArtifactRelicItem and IsArtifactRelicItem(itemID)))) or (isPet) then

				local scannedLevel
				if (not isPet) then

					-- Avoid setting tooltip unless we have to
					if (not hasTip) then
						hasTip = true
						sTip.owner = self
						sTip.bag = bag
						sTip.slot = slot
						sTip:SetOwner(self, "ANCHOR_NONE")
						sTip:SetBagItem(bag,slot)
					end

					local line = _G[sTipName.."TextLeft2"]
					if (line) then
						local msg = line:GetText()
						if (msg) and (string_find(msg, S_ILVL)) then
							local ilvl = (string_match(msg, S_ILVL))
							if (ilvl) and (tonumber(ilvl) > 0) then
								scannedLevel = ilvl
							end
						else
							-- Check line 3, some artifacts have the ilevel there
							line = _G[sTipName.."TextLeft3"]
							if line then
								local msg = line:GetText()
								if (msg) and (string_find(msg, S_ILVL)) then
									local ilvl = (string_match(msg, S_ILVL))
									if (ilvl) and (tonumber(ilvl) > 0) then
										scannedLevel = ilvl
									end
								end
							end
						end
					end
				end
				displayMsg = scannedLevel or petLevel or GetDetailedItemLevelInfo(itemLink) or itemLevel or ""
			end

			if (displayMsg) then
				local ItemLevel = Cache_ItemLevel[self] or Cache_GetItemLevel(self)
				if (BagnonItemInfo_DB.enableRarityColoring) and (displayR) and (displayG) and (displayB) then
					ItemLevel:SetTextColor(displayR, displayG, displayB)
				else
					ItemLevel:SetTextColor(240/255, 240/255, 240/255)
				end
				ItemLevel:SetText(displayMsg)

			elseif (Cache_ItemLevel[self]) then
				Cache_ItemLevel[self]:SetText("")
			end

		elseif (Cache_ItemLevel[self]) then
			Cache_ItemLevel[self]:SetText("")
		end


		---------------------------------------------------
		-- ItemGarbage
		---------------------------------------------------
		local Icon = self.icon or _G[self:GetName().."IconTexture"]
		local showJunk = false

		if (BagnonItemInfo_DB.enableGarbage) and Icon then
			local _, _, locked, quality, _, _, _, _, noValue = GetContainerItemInfo(bag,slot)

			local notGarbage = ((quality and (quality > 0)) or (itemRarity and (itemRarity > 0))) and (not locked)
			if (notGarbage) then
				if (not locked) then
					Icon:SetDesaturated(false)
				end
				if (Cache_ItemGarbage[self]) then
					Cache_ItemGarbage[self]:Hide()
				end
			else
				Icon:SetDesaturated(true)
				local ItemGarbage = Cache_ItemGarbage[self] or Cache_GetItemGarbage(self)
				ItemGarbage:Show()
				showJunk = (quality == 0) and (not noValue)
			end
		else
			if (Cache_ItemGarbage[self]) then
				Cache_ItemGarbage[self]:Hide()
			end
		end

	else
		if (Cache_Uncollected[self]) then
			Cache_Uncollected[self]:Hide()
		end
		if (Cache_ItemLevel[self]) then
			Cache_ItemLevel[self]:SetText("")
		end
		if (Cache_ItemBind[self]) then
			Cache_ItemBind[self]:SetText("")
		end
		if (Cache_ItemGarbage[self]) then
			Cache_ItemGarbage[self]:Hide()
		end
	end
end

local item = Bagnon.ItemSlot or Bagnon.Item
if (item) and (item.Update) then

	-- Hook our update to Bagnon
	hooksecurefunc(item, "Update", Update)

	-- Register the chat command(s)
	-- *keep hash upper case, value lowercase
	for i,command in ipairs({ "bagnoniteminfo", "biteminfo", "binfo", "bif" }) do
		local name = "AZERITE_TEAM_PLUGIN_"..string_upper(command)
		_G["SLASH_"..name.."1"] = "/"..string_lower(command)
		_G.SlashCmdList[name] = slashHandler
	end

end
