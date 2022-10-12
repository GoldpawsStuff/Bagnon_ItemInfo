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

SLASH_BAGNON_ITEMLEVEL1 = "/bil"
SlashCmdList["BAGNON_ITEMLEVEL"] = function(msg)
	if (not msg) then
		return
	end

	msg = string.gsub(msg, "^%s+", "")
	msg = string.gsub(msg, "%s+$", "")
	msg = string.gsub(msg, "%s+", " ")

	local action, element = string.split(" ", msg)
	local db = BagnonItemInfo_DB

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
