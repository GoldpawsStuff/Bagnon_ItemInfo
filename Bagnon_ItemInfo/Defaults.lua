--[[

	The MIT License (MIT)

	Copyright (c) 2023 Lars Norberg

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
if (Private.Incompatible) then
	return
end

-- Addon Localization
local L = LibStub("AceLocale-3.0"):GetLocale((...))

-- Libraries
local AceConfigDialog = LibStub("AceConfigDialog-3.0")
local AceConfigRegistry = LibStub("AceConfigRegistry-3.0")

local defaults = {
	enableItemLevel = true,
	enableItemBind = true,
	enableGarbage = true,
	garbageDesaturation = true,
	garbageOverlay = true,
	garbageOverlayAlpha = 1,
	enableUncollected = true,
	enableRarityColoring = true
}

BagnonItemInfo_DB = CopyTable(defaults)

-- Blizzard overwrites the entire table with the saved table,
-- so newly added options will all be set to nil.
-- We need to manually validate the saved settings
-- to make sure new values are set to their defaults.
local validator = CreateFrame("Frame")
validator:RegisterEvent("ADDON_LOADED")
validator:SetScript("OnEvent", function(self, event, addon)
	if (addon ~= Addon) then return end
	self:UnregisterAllEvents()
	for k,v in next,defaults do
		if (BagnonItemInfo_DB[k] == nil) then
			BagnonItemInfo_DB[k] = v
		end
	end
end)

local setter = function(info,val)
	BagnonItemInfo_DB[info[#info]] = val
	if (Private.Forceupdate) then
		Private.Forceupdate()
	end
end

local getter = function(info)
	return BagnonItemInfo_DB[info[#info]]
end

local optionDB = {
	type = "group",
	args = {
		--header = {
		--	order = 1,
		--	type = "header",
		--	name = ""
		--},
		enableItemLevel = {
			order = 10,
			name = L["Show item levels"],
			desc = L["Toggle labels showing the item level of the item and the number of slots on containers."],
			width = "full",
			type = "toggle",
			set = setter,
			get = getter
		},
		enableItemBind = {
			order = 20,
			name = L["Show unbound items"],
			desc = L["Toggle labels on items that are not yet bound to you."],
			width = "full",
			type = "toggle",
			set = setter,
			get = getter
		},
		enableRarityColoring = {
			order = 30,
			name = L["Colorize item labels by Rarity"],
			desc = L["Colorize the item level and item bind labels in the item's rarity."],
			width = "full",
			type = "toggle",
			disabled = function(info) return not BagnonItemInfo_DB.enableItemLevel and not BagnonItemInfo_DB.enableItemBind end,
			set = setter,
			get = getter
		},
		enableGarbage = {
			order = 40,
			name = L["Desaturate and tone down garbage items"],
			desc = L["Desaturate and tone down the brightness of garbage items."],
			width = "full",
			type = "toggle",
			set = setter,
			get = getter
		},
		garbageDesaturation = {
			order = 41,
			name = L["Desaturate"],
			desc = L["Desaturate garbage items"],
			width = "full",
			type = "toggle",
			hidden = function(info) return not BagnonItemInfo_DB.enableGarbage end,
			set = setter,
			get = getter
		},
		garbageOverlay = {
			order = 42,
			name = L["Darken"],
			desc = L["Tone down the brightness of garbage items."],
			width = "full",
			type = "toggle",
			hidden = function(info) return not BagnonItemInfo_DB.enableGarbage end,
			set = setter,
			get = getter
		},
		garbageOverlayAlpha = {
			order = 43,
			name = L["Level of darkening"],
			desc = L["Set the opacity of the darkening layer."],
			width = "full",
			type = "range", min = .1, max = 1, step = .05,
			hidden = function(info) return not BagnonItemInfo_DB.enableGarbage or not BagnonItemInfo_DB.garbageOverlay end,
			set = setter,
			get = getter
		},
		enableUncollected = {
			order = 50,
			name = L["Show uncollected appearances"],
			desc = L["Put a purple eye on uncollected transmog appearances."],
			width = "full",
			type = "toggle",
			disabled = function(info) return not Private.IsRetail end,
			hidden = function(info) return not Private.IsRetail end,
			set = setter,
			get = getter
		}
	}
}

local addonName = string.gsub(Addon, "_", " ")

AceConfigRegistry:RegisterOptionsTable(addonName, optionDB)
AceConfigDialog:SetDefaultSize(addonName, 400, 300)

SLASH_BAGNON_ITEMLEVEL1 = "/bif"
SlashCmdList["BAGNON_ITEMLEVEL"] = function(msg)
	if (not msg) then
		return
	end

	msg = string.gsub(msg, "^%s+", "")
	msg = string.gsub(msg, "%s+$", "")
	msg = string.gsub(msg, "%s+", " ")

	local action, element = string.split(" ", msg)
	local db = BagnonItemInfo_DB

	if (not action or action == "") then
		if (AceConfigRegistry:GetOptionsTable(addonName)) then
			AceConfigDialog:Open(addonName)
			return
		end
	end

	if (action == "enable") then
		if (element == "itemlevel" or element == "ilvl") then
			db.enableItemLevel = true
		elseif (element == "boe" or element == "bind") then
			db.enableItemBind = true
		elseif (element == "junk" or element == "trash" or element == "garbage") then
			db.enableGarbage = true
		elseif (element == "eye" or element == "transmog" or element == "uncollected") then
			db.enableUncollected = true
		elseif (element == "color") then
			db.enableRarityColoring = true
		end

	elseif (action == "disable") then
		if (element == "itemlevel" or element == "ilvl") then
			db.enableItemLevel = false
		elseif (element == "boe" or element == "bind") then
			db.enableItemBind = false
		elseif (element == "junk" or element == "trash" or element == "garbage") then
			db.enableGarbage = false
		elseif (element == "eye" or element == "transmog" or element == "uncollected") then
			db.enableUncollected = false
		elseif (element == "color") then
			db.enableRarityColoring = false
		end
	end

	if (Private.Forceupdate) then
		Private.Forceupdate()
	end

end
