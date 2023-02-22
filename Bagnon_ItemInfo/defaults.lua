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

BagnonItemInfo_DB = {
	enableItemLevel = true,
	enableItemBind = true,
	enableGarbage = true,
	enableUncollected = true,
	enableRarityColoring = true
}

local function PrintHelp()
	print("Bagnon ItemInfo")
	print("Adjust configurations with the following commands:")
	print("/bif enable itemlevel - Enable the itemlevel display.")
	print("/bif disable itemlevel - Disable the itemlevel display.")
	print("/bif enable boe - Enable the BoE/BoU display.")
	print("/bif disable boe - Disable the BoE/BoU display.")
	print("/bif enable garbage - Enable the garbage desaturation.")
	print("/bif disable garbage - Disable the garbage desaturation.")
	print("/bif enable uncollected - Enable the uncollected appearance eye.")
	print("/bif disable uncollected - Disable the uncollected appearance eye.")
	print("/bif enable color - Enable rarity coloring of text.")
	print("/bif disable color - Disable rarity coloring of text.")
end

--
-- Sets configuration for the provided configuration key
--
local function SetConfiguration(configName, configKey, effect)
	local db = BagnonItemInfo_DB

	if ( effect == "toggle" ) then
		local initialValue = db[configKey]
		if ( initialValue ) then
			db[configKey] = false
		else
			db[configKey] = true
		end
	else
		db[configKey] = effect
	end

	if ( db[configKey] ) then
		print("Bagnon ItemInfo:", configName, "enabled")
	else
		print("Bagnon ItemInfo:", configName, "disabled")
	end
end

local function InvalidCommand(command)
	if ( command  and command ~= "" ) then
		print(command, "is not a valid command.")
	end
	PrintHelp()
	return
end

SLASH_BAGNON_ITEMLEVEL1 = "/bif"
SlashCmdList["BAGNON_ITEMLEVEL"] = function(msg)
	if (not msg) then
		return InvalidCommand(msg)
	end

	msg = string.gsub(msg, "^%s+", "")
	msg = string.gsub(msg, "%s+$", "")
	msg = string.gsub(msg, "%s+", " ")

	local arg1, arg2 = string.split(" ", msg)

	local action = "toggle"
	local element = ""

	if ( arg1 == "enable" or arg1 == "disable" ) then
		action = arg1
		element = arg2
	elseif ( arg2 == "enable" or arg2 == "disable" ) then
		action = arg2
		element = arg1
	elseif ( arg1 ~= "" and not arg2 ) then
		element = arg1
	else
		return InvalidCommand(msg)
	end

	local effect = "toggle"
	if ( action == "enable" ) then
		effect = true
	elseif ( action == "disable" ) then
		effect = false
	end

	local configKey
	local configName

	if (element == "itemlevel" or element == "ilvl") then
		configKey = "enableItemLevel"
		configName = "Item Level"
	elseif (element == "boe" or element == "bind") then
		configKey = "enableItemBind"
		configName = "BoE Display"
	elseif (element == "junk" or element == "trash" or element == "garbage") then
		configKey = "enableGarbage"
		configName = "Garbage Desaturator"
	elseif (element == "eye" or element == "transmog" or element == "uncollected") then
		configKey = "enableUncollected"
		configName = "Uncollected Icon"
	elseif (element == "color") then
		configKey = "enableRarityColoring"
		configName = "Rarity Text Color"
	else
		return InvalidCommand(msg)
	end

	SetConfiguration(configName, configKey, effect)

	if (Private.Forceupdate) then
		Private.Forceupdate()
	end

end
