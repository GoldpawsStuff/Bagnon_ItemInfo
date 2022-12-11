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
local Module = Bagnon:NewModule("Bagnon_Uncollected")
local cache = {}

-- Speed!
local _G = _G
local string_find = string.find

-- WoW API
local PlayerHasTransmog = C_TransmogCollection.PlayerHasTransmog

local tooltip = Private.tooltip
local tooltipName = Private.tooltipName

-- Search patterns
local s_transmog1 = TRANSMOGRIFY_STYLE_UNCOLLECTED
local s_transmog2 = TRANSMOGRIFY_TOOLTIP_APPEARANCE_UNKNOWN

Private.cache[Module] = cache
Private.AddUpdater(Module, function(self)

	local show

	if (self.hasItem and BagnonItemInfo_DB.enableUncollected) then

		local quality, id = self.info.quality, self.info.id

		if (quality and quality > 1 and not PlayerHasTransmog(id --[[, itemAppearanceModID ]])) then

			if (not tooltip.owner or not tooltip.bag or not tooltip.slot) then
				tooltip.owner, tooltip.bag,tooltip.slot = self, self:GetBag(), self:GetID()
				tooltip:SetOwner(tooltip.owner, "ANCHOR_NONE")
				tooltip:SetBagItem(tooltip.bag, tooltip.slot)
			end

			for i = tooltip:NumLines(),2,-1 do
				local line = _G[tooltipName.."TextLeft"..i]
				if (not line) then
					break
				end

				local msg = line:GetText() or ""
				if (string_find(msg, s_transmog1) or string_find(msg, s_transmog2)) then
					show = true
					break
				end
			end

		end

	end

	if (show) then

		local overlay = cache[self]
		if (not overlay) then
			overlay = self:CreateTexture()
			overlay.icon = self.icon or _G[self:GetName().."IconTexture"]
			overlay:Hide()
			overlay:SetDrawLayer("OVERLAY")
			overlay:SetPoint("CENTER", 0, 0)
			overlay:SetSize(24, 24)
			overlay:SetTexture([[Interface\Transmogrify\Transmogrify]])
			overlay:SetTexCoord(.804688, .875, .171875, .230469)
			cache[self] = overlay
		end

		overlay:Show()

	else
		local overlay = cache[self]
		if (overlay) then
			overlay:Hide()
		end
	end

end)
