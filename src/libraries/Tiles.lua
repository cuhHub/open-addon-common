--------------------------------------------------------
-- Libraries - Tiles
--------------------------------------------------------

--[[
    Copyright (C) 2026 cuhHub

    Licensed under the Apache License, Version 2.0 (the "License");
    you may not use this file except in compliance with the License.
    You may obtain a copy of the License at

        http://www.apache.org/licenses/LICENSE-2.0

    Unless required by applicable law or agreed to in writing, software
    distributed under the License is distributed on an "AS IS" BASIS,
    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
    See the License for the specific language governing permissions and
    limitations under the License.
]]

-------------------------------
-- // Main
-------------------------------

--[[
    A library for interacting with Stormworks tiles.
]]
---@class Tiles: NoirLibrary
Addon.Libs.Tiles = Noir.Libraries:Create(
    "Tiles",
    "A library for interacting with Stormworks tiles.",
    "A library for interacting with Stormworks tiles.",
    {"Cuh4"}
)

--[[
    Returns if the tile at the position is ocean or not.
]]
---@param position SWMatrix The position to check
---@return boolean
function Addon.Libs.Tiles:IsOcean(position)
    local tile, success = server.getTile(position)

    if success and tile.name ~= "" then
        return false
    end

    return true
end