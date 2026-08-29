--------------------------------------------------------
-- Classes - Player Zone
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
    A zone for players.
]]
---@class PlayerZone: Zone<NoirPlayer>
---@field New fun(self: PlayerZone, ID: integer, radius: number, position: SWMatrix): PlayerZone
Addon.Classes.PlayerZone = Noir.Class("PlayerZone", Addon.Classes.Zone)

--[[
    Initializes new `PlayerZone` instances.
]]
---@param ID integer The ID of the zone.
---@param radius number The radius of the zone (meters).
---@param position SWMatrix The position of the zone.
function Addon.Classes.PlayerZone:Init(ID, radius, position)
    self:InitFrom(
        Addon.Classes.Zone,
        ID, radius, position
    )
end

--[[
    Returns all possible entities that can be in the zone.
]]
---@return table<integer, NoirPlayer>
function Addon.Classes.PlayerZone:FindAllEntities()
    return Noir.Services.PlayerService:GetPlayers(true)
end

--[[
    Returns the position of the given entity.
]]
---@param entity NoirPlayer The player to check
---@return SWMatrix
function Addon.Classes.PlayerZone:GetEntityPosition(entity)
    return entity:GetPosition()
end

--[[
    Returns if the given entity is still valid.
]]
---@param entity NoirPlayer The player to check
---@return boolean
function Addon.Classes.PlayerZone:CheckIsEntityValid(entity)
    return entity.InGame
end

--[[
    Returns the ID for the given entity.
]]
---@param entity NoirPlayer The player to check
---@return integer
function Addon.Classes.PlayerZone:GetIDForEntity(entity)
    return entity.ID
end