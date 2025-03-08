--[[

	The MIT License (MIT)

	Copyright (c) 2024 Lars Norberg

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
local _, Private =  ...

Private.cache = {}

Private.updates = BAGNON_ITEMINFO_UPDATES or {}
Private.updatesByModule = BAGNON_ITEMINFO_UPDATES_BY_MODULE or {}
Private.tooltip = BAGNON_ITEMINFO_SCANNERTOOLTIP or CreateFrame("GameTooltip", "BAGNON_ITEMINFO_SCANNERTOOLTIP", WorldFrame, "GameTooltipTemplate")
Private.tooltipName = Private.tooltip:GetName()

Private.ClientMajor = tonumber((string.split(".", (GetBuildInfo()))))
Private.IsRetail = (WOW_PROJECT_ID == WOW_PROJECT_MAINLINE)
Private.IsClassic = (WOW_PROJECT_ID == WOW_PROJECT_CLASSIC)
Private.IsTBC = (WOW_PROJECT_ID == WOW_PROJECT_BURNING_CRUSADE_CLASSIC)
Private.IsWrath = (WOW_PROJECT_ID == WOW_PROJECT_WRATH_CLASSIC)
Private.IsShadowlands = Private.ClientMajor == 9
Private.IsDragonflight = Private.ClientMajor == 10

-- Speed!
local next, table_insert = next, table.insert
local tooltip, updates = Private.tooltip, Private.updates

-- Add a module update to the global cache
Private.AddUpdater = function(module, func)
	table_insert(Private.updates, func)
	Private.updatesByModule[module] = func
end

-- Forcefully update all module buttons.
Private.Forceupdate = function(module)
	for module,cache in next,Private.cache do
		local func = Private.updatesByModule[module]
		for item in next,cache do
			func(item)
		end
	end
end

-- Call all updates from all my plugins, then reset the tooltip.
-- The idea is to minimize scanner tooltip changes for performance.
Private.Dispatcher = BAGNON_ITEMINFO_DISPATCHER or function(item)
	for _,update in next,Private.updates do
		update(item)
	end
	tooltip.owner, tooltip.bag, tooltip.slot = nil, nil, nil
end

-- Hook the updater
if (not BAGNON_ITEMINFO_DISPATCHER) then
	local item = Bagnon.ItemSlot or Bagnon.Item
	local method = item.UpdatePrimary and "UpdatePrimary" or item.Update and "Update"
	hooksecurefunc(item, method, Private.Dispatcher)
end

-- (Re)assign globals
BAGNON_ITEMINFO_DISPATCHER = Private.Dispatcher
BAGNON_ITEMINFO_UPDATES = Private.updates
BAGNON_ITEMINFO_UPDATES_BY_MODULE = Private.updatesByModule
BAGNON_ITEMINFO_SCANNERTOOLTIP = Private.tooltip
