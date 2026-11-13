--------------------------------------------------------
-- Classes - Range
--------------------------------------------------------

--[[
    Copyright (C) 2026 cuhHub - All Rights Reserved
    - Unauthorized copying of this file, via any medium is strictly prohibited
    - Proprietary and confidential
]]

-------------------------------
-- // Main
-------------------------------

--[[
    A range between two numbers.
]]
---@class Range: NoirClass
---@field New fun(self: Range, from: number, to: number): Range
Addon.Classes.Range = Noir.Class("Range")

--[[
    Initializes new `Range` instances.
]]
---@param from number The start of the range
---@param to number The end of the range
function Addon.Classes.Range:Init(from, to)
    --[[
        The start of the range.
    ]]
    self.From = from

    --[[
        The end of the range.
    ]]
    self.To = to
end

--[[
    Returns the start of the range.
]]
---@return number
function Addon.Classes.Range:GetFrom()
    return self.From
end

--[[
    Returns the end of the range.
]]
---@return number
function Addon.Classes.Range:GetTo()
    return self.To
end

--[[
    Returns a random number (float) between the range.
]]
---@return number
function Addon.Classes.Range:GetRandom()
    return Addon.Libs.Math:RandomFloat(self:GetFrom(), self:GetTo())
end

--[[
    Returns if a number is within the range.
]]
---@param number number The number to check
---@return boolean
function Addon.Classes.Range:Fits(number)
    return number >= self:GetFrom() and number <= self:GetTo()
end