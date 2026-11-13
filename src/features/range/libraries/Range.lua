--------------------------------------------------------
-- Libraries - Range
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
    A library for creating Range instances.
]]
---@class Range: NoirLibrary
Addon.Libs.Range = Noir.Libraries:Create(
    "Range",
    "A library for creating Range instances.",
    "A library for creating Range instances.",
    {"Cuh4"}
)

--[[
    Creates a new `Range` instance.
]]
---@param from number The start of the range
---@param to number The end of the range
---@return Range
function Addon.Libs.Range:CreateRange(from, to)
    return Addon.Classes.Range:New(from, to)
end