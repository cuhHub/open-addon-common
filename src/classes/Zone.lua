--------------------------------------------------------
-- Classes - Zone
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
    A class representing a base zone.
]]
---@class Zone: NoirClass
---@field New fun(self: Zone, position: SWMatrix, radius: number): Zone
Addon.Classes.Zone = Noir.Class("Zone")

--[[
    Initializes new `Zone` instances.
]]
---@param position SWMatrix The position of the zone
---@param radius number The radius (meters) of the zone
function Addon.Classes.Zone:Init(position, radius)
    --[[
        The position this zone is located at.
    ]]
    self.Position = position

    --[[
        The radius of this zone.
    ]]
    self.Radius = radius
end

--[[
    Returns if a position is in the zone.
]]
---@param position SWMatrix The position to check
---@return boolean
function Addon.Classes.Zone:IsPositionInThisZone(position)
    return Addon.Libs.Matrix:GetSquaredDistance(position, self.Position) <= self.Radius * self.Radius -- squared radius since squared distance
end

--[[
    Returns if a vehicle is in the zone.
]]
---@param vehicle NoirVehicle The vehicle to check
---@return boolean
function Addon.Classes.Zone:IsVehicleInThisZone(vehicle)
    return self:IsPositionInThisZone(vehicle:GetPosition())
end

--[[
    Returns if a body is in the zone.
]]
---@param body NoirBody The body to check
---@return boolean
function Addon.Classes.Zone:IsBodyInThisZone(body)
    return self:IsPositionInThisZone(body:GetPosition())
end

--[[
    Returns if a player is in the zone.
]]
---@param player NoirPlayer The player to check
---@return boolean
function Addon.Classes.Zone:IsPlayerInThisZone(player)
    return self:IsPositionInThisZone(player:GetPosition())
end

--[[
    Returns all players in this zone.
]]
---@return table<integer, NoirPlayer>
function Addon.Classes.Zone:GetPlayersInThisZone()
    local players = {} ---@type table<integer, NoirPlayer>

    for _, player in pairs(Noir.Services.PlayerService:GetPlayers(true)) do
        if self:IsPlayerInThisZone(player) then
            table.insert(players, player)
        end
    end

    return players
end

--[[
    Returns a random position in the zone.
]]
---@return SWMatrix
function Addon.Classes.Zone:GetRandomPosition()
    return Noir.Libraries.Matrix:RandomOffset(
        self.Position,
        self.Radius,
        0,
        self.Radius
    )
end