
-- Using the Bagnon way to retrieve names, namespaces and stuff
local MODULE =  ...
local ADDON, Addon = MODULE:match("[^_]+"), _G[MODULE:match("[^_]+")]
local Module = Bagnon:NewModule("ItemInfo", Addon)

-- Tooltip used for scanning
local ScannerTip = _G.BagnonItemInfoScannerTooltip or CreateFrame("GameTooltip", "BagnonItemInfoScannerTooltip", WorldFrame, "GameTooltipTemplate")
local ScannerTipName = ScannerTip:GetName()

-- Lua API
local _G = _G
local select = select
local string_find = string.find
local string_gsub = string.gsub
local string_match = string.match
local tonumber = tonumber

-- WoW API
local CreateFrame = _G.CreateFrame
local GetContainerItemInfo = _G.GetContainerItemInfo
local GetDetailedItemLevelInfo = _G.GetDetailedItemLevelInfo 
local GetItemInfo = _G.GetItemInfo
local GetItemQualityColor = _G.GetItemQualityColor
local IsArtifactRelicItem = _G.IsArtifactRelicItem 

-- WoW Strings
local S_ITEM_BOUND1 = _G.ITEM_SOULBOUND
local S_ITEM_BOUND2 = _G.ITEM_ACCOUNTBOUND
local S_ITEM_BOUND3 = _G.ITEM_BNETACCOUNTBOUND
local S_ITEM_LEVEL = "^" .. string_gsub(_G.ITEM_LEVEL, "%%d", "(%%d+)")
local S_CONTAINER_SLOTS = "^" .. string_gsub(string_gsub(_G.CONTAINER_SLOTS, "%%d", "(%%d+)"), "%%s", "(%.+)")

-- Localization. 
-- *Just enUS so far. 
local L = {
	["BoE"] = "BoE", -- Bind on Equip 
	["BoU"] = "BoU"  -- Bind on Use
}

-- FontString Caches
local Cache_ItemBind = {}
local Cache_ItemGarbage = {}
local Cache_ItemLevel = {}

-- Flag tracking merchant frame visibility
local MERCHANT_VISIBLE

-- Just keep this running, regardless of other stuff (?)
-- *might be conflicts with the standard Update function here. 
local MerchantTracker = CreateFrame("Frame")
MerchantTracker:RegisterEvent("MERCHANT_SHOW")
MerchantTracker:RegisterEvent("MERCHANT_CLOSED")
MerchantTracker:SetScript("OnEvent", function(self, event, ...) 
	if (event == "MERCHANT_SHOW") then
		MERCHANT_VISIBLE = true
	elseif (event == "MERCHANT_CLOSED") then 
		MERCHANT_VISIBLE = false
	end
	for button,ItemGarbage in pairs(Cache_ItemGarbage) do
		local JunkIcon = button.JunkIcon
		if JunkIcon then
			if (MERCHANT_VISIBLE and ItemGarbage.showJunk) then 
				JunkIcon:Show()
			else 
				JunkIcon:Hide()
			end
		end
	end
end)

-----------------------------------------------------------
-- Utility Functions
-----------------------------------------------------------
-- Update our secret scanner tooltip with the current button
local RefreshScanner = function(button)
	local bag, slot = button:GetBag(), button:GetID()
	ScannerTip.owner = button
	ScannerTip.bag = bag
	ScannerTip.slot = slot
	ScannerTip:SetOwner(button, "ANCHOR_NONE")
	ScannerTip:SetBagItem(button:GetBag(), button:GetID())
end

local IsItemBound = function(button)
	-- Refresh the scanner item
	RefreshScanner(button)

	-- We're trying line 2 to 6 for the bind texts, 
	-- I don't think they're ever further down.
	for i = 2,6 do 
		local line = _G[ScannerTipName.."TextLeft"..i]
		if (not line) then
			break
		end
		local msg = line:GetText()
		if msg and (string_find(msg, S_ITEM_BOUND1) or string_find(msg, S_ITEM_BOUND2) or string_find(msg, S_ITEM_BOUND3)) then 
			return true
		end
	end
end

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
	local ItemLevel = GetPluginContainter(button):CreateFontString()
	ItemLevel:SetDrawLayer("ARTWORK", 1)
	ItemLevel:SetPoint("TOPLEFT", 2, -2)
	ItemLevel:SetFontObject(_G.NumberFont_Outline_Med or _G.NumberFontNormal) 
	ItemLevel:SetShadowOffset(1, -1)
	ItemLevel:SetShadowColor(0, 0, 0, .5)

	-- Move Pawn out of the way
	local UpgradeIcon = button.UpgradeIcon
	if UpgradeIcon then
		UpgradeIcon:ClearAllPoints()
		UpgradeIcon:SetPoint("BOTTOMRIGHT", 2, 0)
	end

	-- Store the reference for the next time
	Cache_ItemLevel[button] = ItemLevel

	return ItemLevel
end

local Cache_GetItemBind = function(button)
	local ItemBind = GetPluginContainter(button):CreateFontString()
	ItemBind:SetDrawLayer("ARTWORK")
	ItemBind:SetPoint("BOTTOMLEFT", 2, 2)
	ItemBind:SetFontObject(_G.NumberFont_Outline_Med or _G.NumberFontNormal) 
	ItemBind:SetFont(ItemBind:GetFont(), 11, "OUTLINE")
	ItemBind:SetShadowOffset(1, -1)
	ItemBind:SetShadowColor(0, 0, 0, .5)

	-- Move Pawn out of the way
	local UpgradeIcon = button.UpgradeIcon
	if UpgradeIcon then
		UpgradeIcon:ClearAllPoints()
		UpgradeIcon:SetPoint("BOTTOMRIGHT", 2, 0)
	end

	-- Store the reference for the next time
	Cache_ItemBind[button] = ItemBind

	return ItemBind
end

local Cache_GetItemGarbage = function(button)
	
	local Icon = button.icon or _G[button:GetName().."IconTexture"]

	local ItemGarbage = button:CreateTexture()
	ItemGarbage:Hide()
	ItemGarbage:SetDrawLayer("ARTWORK")
	ItemGarbage:SetAllPoints(Icon)
	ItemGarbage:SetColorTexture(51/255 * 1/5,  17/255 * 1/5,   6/255 * 1/5, .6)
	ItemGarbage.owner = button

	hooksecurefunc(Icon, "SetDesaturated", function() 
		if ItemGarbage.tempLocked then 
			return
		end

		ItemGarbage.tempLocked = true

		local itemLink = button:GetItem()
		if itemLink then 
			local _, _, itemRarity, iLevel, _, _, _, _, itemEquipLoc = GetItemInfo(itemLink)
			local texture, itemCount, locked, quality, readable, _, _, isFiltered, noValue, itemID = GetContainerItemInfo(button:GetBag(), button:GetID())
		
			local isBattlePet, battlePetLevel, battlePetRarity = GetBattlePetInfo(itemLink)
			if isBattlePet then 
				itemRarity = battlePetRarity
			end

			if not(((quality and (quality > 0)) or (itemRarity and (itemRarity > 0))) and (not locked)) then
				Icon:SetDesaturated(true)
			end 
		end

		ItemGarbage.tempLocked = false
	end)

	Cache_ItemGarbage[button] = ItemGarbage

	return ItemGarbage
end

-----------------------------------------------------------
-- Main Update
-----------------------------------------------------------
local Update = function(self)
	local itemLink = self:GetItem() 
	if itemLink then

		-- Get some blizzard info about the current item
		local itemName, _itemLink, itemRarity, itemLevel, itemMinLevel, itemType, itemSubType, itemStackCount, itemEquipLoc, iconFileDataID, itemSellPrice, itemClassID, itemSubClassID, bindType, expacID, itemSetID, isCraftingReagent = GetItemInfo(itemLink)
		local effectiveLevel, previewLevel, origLevel = GetDetailedItemLevelInfo(itemLink)
		local isBattlePet, battlePetLevel, battlePetRarity = GetBattlePetInfo(itemLink)

		-- Retrieve the itemID from the itemLink
		local itemID = tonumber(string_match(itemLink, "item:(%d+)"))

		---------------------------------------------------
		-- ItemBind
		---------------------------------------------------
		if (itemRarity and (itemRarity > 1)) and ((bindType == 2) or (bindType == 3)) and (not IsItemBound(self)) then
			local ItemBind = Cache_ItemBind[self] or Cache_GetItemBind(self)
			local r, g, b = GetItemQualityColor(itemRarity)
			ItemBind:SetTextColor(r * 2/3, g * 2/3, b * 2/3)
			ItemBind:SetText((bindType == 3) and L["BoU"] or L["BoE"])
		else 
			if Cache_ItemBind[self] then 
				Cache_ItemBind[self]:SetText("")
			end	
		end

		---------------------------------------------------
		-- ItemLevel
		---------------------------------------------------
		if (itemEquipLoc == "INVTYPE_BAG") then 
			RefreshScanner(self)

			local scannedSlots
			local line = _G[ScannerTipName.."TextLeft3"]
			if line then
				local msg = line:GetText()
				if msg and string_find(msg, S_CONTAINER_SLOTS) then
					local bagSlots = string_match(msg, S_CONTAINER_SLOTS)
					if bagSlots and (tonumber(bagSlots) > 0) then
						scannedSlots = bagSlots
					end
				else
					line = _G[ScannerTipName.."TextLeft4"]
					if line then
						local msg = line:GetText()
						if msg and string_find(msg, S_CONTAINER_SLOTS) then
							local bagSlots = string_match(msg, S_CONTAINER_SLOTS)
							if bagSlots and (tonumber(bagSlots) > 0) then
								scannedSlots = bagSlots
							end
						end
					end
				end
			end

			if scannedSlots then 
				local ItemLevel = Cache_ItemLevel[self] or Cache_GetItemLevel(self)
				ItemLevel:SetTextColor(240/255, 240/255, 240/255)
				ItemLevel:SetText(scannedSlots)
			else 
				if Cache_ItemLevel[self] then 
					Cache_ItemLevel[self]:SetText("")
				end
			end 

		-- Display item level of equippable gear and artifact relics
		elseif ((itemRarity and (itemRarity > 0)) and ((itemEquipLoc and _G[itemEquipLoc]) or (itemID and IsArtifactRelicItem(itemID)))) or (isBattlePet) then

			local scannedLevel
			if (not isBattlePet) then
				RefreshScanner(self)

				local line = _G[ScannerTipName.."TextLeft2"]
				if line then
					local msg = line:GetText()
					if msg and string_find(msg, S_ITEM_LEVEL) then
						local ItemLevel = string_match(msg, S_ITEM_LEVEL)
						if ItemLevel and (tonumber(ItemLevel) > 0) then
							scannedLevel = ItemLevel
						end
					else
						-- Check line 3, some artifacts have the ilevel there
						line = _G[ScannerTipName.."TextLeft3"]
						if line then
							local msg = line:GetText()
							if msg and string_find(msg, S_ITEM_LEVEL) then
								local ItemLevel = string_match(msg, S_ITEM_LEVEL)
								if ItemLevel and (tonumber(ItemLevel) > 0) then
									scannedLevel = ItemLevel
								end
							end
						end
					end
				end
			end

			local r, g, b = GetItemQualityColor(battlePetRarity or itemRarity)
			local ItemLevel = Cache_ItemLevel[self] or Cache_GetItemLevel(self)
			ItemLevel:SetTextColor(r, g, b)
			ItemLevel:SetText(scannedLevel or battlePetLevel or effectiveLevel or itemLevel or "")

		else
			if Cache_ItemLevel[self] then 
				Cache_ItemLevel[self]:SetText("")
			end
		end

		---------------------------------------------------
		-- ItemGarbage
		---------------------------------------------------
		local Icon = self.icon or _G[self:GetName().."IconTexture"]
		local showJunk = false

		if Icon then 
			local texture, itemCount, locked, quality, readable, _, _, isFiltered, noValue, itemID = GetContainerItemInfo(self:GetBag(), self:GetID())

			local notGarbage = ((quality and (quality > 0)) or (itemRarity and (itemRarity > 0))) and (not locked) 
			if notGarbage then
				if (not locked) then 
					Icon:SetDesaturated(false)
				end
				if Cache_ItemGarbage[self] then 
					Cache_ItemGarbage[self]:Hide()
				end 
			else
				Icon:SetDesaturated(true)
				local ItemGarbage = Cache_ItemGarbage[self] or Cache_GetItemGarbage(self)
				ItemGarbage:Show()
				showJunk = (quality == 0) and (not noValue)
			end 
		else 
			if Cache_ItemGarbage[self] then 
				Cache_ItemGarbage[self]:Hide()
			end
		end

		local JunkIcon = self.JunkIcon
		if JunkIcon then 
			local ItemGarbage = Cache_ItemGarbage[self] 
			if ItemGarbage then 
				ItemGarbage.showJunk = showJunk
			end 
			if (MERCHANT_VISIBLE and showJunk) then 
				JunkIcon:Show()
			else
				JunkIcon:Hide()
			end
		end

	else
		if Cache_ItemLevel[self] then
			Cache_ItemLevel[self]:SetText("")
		end
		if Cache_ItemBind[self] then 
			Cache_ItemBind[self]:SetText("")
		end	
		if Cache_ItemGarbage[self] then 
			Cache_ItemGarbage[self]:Hide()
			Cache_ItemGarbage[self].showJunk = nil
		end
		local JunkIcon = self.JunkIcon
		if JunkIcon then 
			if (MERCHANT_VISIBLE and showJunk) then 
				JunkIcon:Show()
			else
				JunkIcon:Hide()
			end
		end
	end	
end 

Module.OnEnable = function(self)
	hooksecurefunc(Bagnon.ItemSlot, "Update", Update)
end 
