--[[

	The MIT License (MIT)

	Copyright (c) 2025 Lars Norberg

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

-- WoW 11.0.x
local IsAddOnLoaded = IsAddOnLoaded or C_AddOns.IsAddOnLoaded
local LoadAddOn = LoadAddOn or C_AddOns.LoadAddOn

-- Addon default settings
local defaults = {
	enableItemLevel = true,
	minimumItemLevel = 11,
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
		enableItemLevel = {
			order = 10,
			name = L["Show item levels"],
			desc = L["Toggle labels showing the item level of the item and the number of slots on containers."],
			width = "full",
			type = "toggle",
			set = setter,
			get = getter
		},
		minimumItemLevel = {
			order = 11,
			name = L["Minimum item level"],
			desc = L["Set the minimum item level to display."],
			width = "full",
			type = "range", min = 1, max = 60, step = 1,
			hidden = function(info) return not BagnonItemInfo_DB.enableItemLevel end,
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
		}--[[,
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
		}--]]
	}
}

local GenerateOptionsMenu = function()

	-- Bagnon doesn't create its menu until opening it,
	-- and we want our menu entry lister after theirs.
	-- To my knowledge we can't safely resort the blizz menu.
	if (not C_AddOns.IsAddOnLoaded("Bagnon_Config")) then
		C_AddOns.LoadAddOn("Bagnon_Config")
	end

	-- Menu category listing display name
	local name = [[|TInterface\Addons\BagBrother\Art\Bagnon-Plugin:16:16|t Bagnon |cffffffffilvl+|r]]

	-- Menu category header
	local appName = [[|TInterface\Addons\BagBrother\Art\Bagnon-Plugin:16:16|t Bagnon |cfffafafaItemLevel +|r]]

	AceConfigRegistry:RegisterOptionsTable(appName, optionDB)

	-- Add the options table to
	-- the interface addons options.
	local frame, category = AceConfigDialog:AddToBlizOptions(appName, name)

	-- Register a slash command that
	-- opens to a separate window.
	local ADDON = string.upper(Addon)

	_G["SLASH_"..ADDON.."1"] = "/bil" -- same command used by Bagnon ItemLevel
	_G["SLASH_"..ADDON.."2"] = "/bif" -- the old command, keeping it for compatibiliy

	-- Just open the options window,
	-- don't allow configration through commands.
	SlashCmdList[ADDON] = function(msg)
		if (InterfaceOptionsFrame) then
			InterfaceOptionsFrame:Show()
			InterfaceOptionsFrame_OpenToCategory(category)
		else
			SettingsPanel:Show()
			SettingsPanel:OpenToCategory(category)
		end
	end
end

-- Don't load the menu until first time entering the world.
-- We might need to forcefully load an addon,
-- so it's important to wait until that point.
local loader = CreateFrame("Frame")
loader:RegisterEvent("PLAYER_ENTERING_WORLD")
loader:SetScript("OnEvent", function(self)

	self:UnregisterAllEvents()
	self:Hide()

	GenerateOptionsMenu()

end)
