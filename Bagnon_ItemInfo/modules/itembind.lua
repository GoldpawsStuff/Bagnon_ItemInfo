--[[

	The MIT License (MIT)

	Copyright (c) 2022 Lars Norberg

	Permission is hereby granted, free of charge, to any person obtaining a copy
	of this software and associated documentation files (the "Software"), to deal
	in the Software without restriction, including without limitation the rights
	to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
	copies of the Software, and to permit persons to whom the Software is
	furnished to do so, subject to the following conditions:

	The above copyright notice and this permission notice shall be included in all
	copies or substantial portions of the Software.

	THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
	IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
	FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
	AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
	LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
	OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
	SOFTWARE.

--]]
local Addon, Private =  ...
local Module = Bagnon:NewModule("Bagnon_BoE")
local cache = {}

-- Speed!
local _G = _G
local ipairs = ipairs
local string_find = string.find

-- WoW API
local GetContainerItemInfo = GetContainerItemInfo

-- WoW10 API
local C_Container_GetContainerItemInfo = C_Container and C_Container.GetContainerItemInfo

local retail = Private.IsRetail
local tooltip = Private.tooltip
local tooltipName = Private.tooltipName

-- Font object
local font_object = NumberFont_Outline_Med or NumberFontNormal

-- Search patterns
local s_item_bound1 = ITEM_SOULBOUND
local s_item_bound2 = ITEM_ACCOUNTBOUND
local s_item_bound3 = ITEM_BNETACCOUNTBOUND

-- Localization.
-- *Just enUS so far.
local L = {
	["BoE"] = "BoE", -- Bind on Equip
	["BoU"] = "BoU"  -- Bind on Use
}

-- Custom color cache
-- Allows us control, gives us speed.
local colors = {
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

Private.cache[Module] = cache
Private.AddUpdater(Module, function(self)

	local message, color, mult

	if (self.hasItem and BagnonItemInfo_DB.enableItemBind) then

		local quality, bind = self.info.quality, self.info.bind

		-- Item is BoE or BoU, has it been bound to the player yet?
		if (quality and quality > 1) and (bind == 2 or bind == 3) then

			local show = true

			-- Only retail returns this info, and not always accurately
			if (retail) then
				local bag, slot = self:GetBag(), self:GetID()
				if (C_Container_GetContainerItemInfo) then
					local containerInfo = C_Container_GetContainerItemInfo(bag,slot)
					if (containerInfo) then
						bound = containerInfo.isBound
					end
				else
					_, _, _, _, _, _, _, _, _, _, bound = GetContainerItemInfo(bag, slot)
				end
				if (bound) then
					show = nil
				end
			end

			-- Scan the tooltip to see if the item is bound.
			if (show) then

				if (retail) then

					local tooltipData = C_TooltipInfo.GetBagItem(self:GetBag(), self:GetID())

					-- Assign data to 'type' and 'guid' fields.
					TooltipUtil.SurfaceArgs(tooltipData)

					-- Assign data to 'leftText' fields.
					for _, line in ipairs(tooltipData.lines) do
						TooltipUtil.SurfaceArgs(line)
					end

					for i = 2,6 do
						local msg = tooltipData.lines[i] and tooltipData.lines[i].leftText
						if (not msg) then break end

						if (string_find(msg, s_item_bound1) or string_find(msg, s_item_bound2) or string_find(msg, s_item_bound3)) then
							show = nil
							break
						end
					end

				else

					if (not tooltip.owner or not tooltip.bag or not tooltip.slot) then
						tooltip.owner, tooltip.bag,tooltip.slot = self, self:GetBag(), self:GetID()
						tooltip:SetOwner(tooltip.owner, "ANCHOR_NONE")
						tooltip:SetBagItem(tooltip.bag, tooltip.slot)
					end

					for i = 2,6 do
						local line = _G[tooltipName.."TextLeft"..i]
						if (not line) then
							break
						end

						local msg = line:GetText() or ""
						if (string_find(msg, s_item_bound1) or string_find(msg, s_item_bound2) or string_find(msg, s_item_bound3)) then
							show = nil
							break
						end
					end

				end

			end

			-- Item isn't bound, decide the label
			if (show) then

				message = bind == 3 and L["BoU"] or L["BoE"]

				if (BagnonItemInfo_DB.enableRarityColoring) then
					color = quality and colors[quality]
					mult = (quality ~= 3 and quality ~= 4) and .7
				end
			end

		end
	end

	if (message) then

		local label = cache[self]
		if (not label) then

			-- Only one container per item.
			local name = self:GetName().."ExtraInfoFrame"
			local container = _G[name]
			if (not container) then
				container = CreateFrame("Frame", name, self)
				container:SetAllPoints()
			end

			-- Always move this to the same place.
			local upgrade = self.UpgradeIcon
			if (upgrade) then
				upgrade:ClearAllPoints()
				upgrade:SetPoint("BOTTOMRIGHT", 2, 0)
			end

			-- This is specific to this plugin.
			label = container:CreateFontString()
			label:SetDrawLayer("ARTWORK", 1)
			label:SetPoint("BOTTOMLEFT", 2, 2)
			label:SetFontObject(font_object)
			label:SetFont(label:GetFont(), 12, "OUTLINE")
			label:SetShadowOffset(1, -1)
			label:SetShadowColor(0, 0, 0, .5)

			cache[self] = label
		end

		label:SetText(message)

		if (color) then
			if (mult) then
				label:SetTextColor(color[1] * mult, color[2] * mult, color[3] * mult)
			else
				label:SetTextColor(color[1], color[2], color[3])
			end
		else
			label:SetTextColor(.94, .94, .94)
		end

	elseif (cache[self]) then
		cache[self]:SetText("")
	end

end)
