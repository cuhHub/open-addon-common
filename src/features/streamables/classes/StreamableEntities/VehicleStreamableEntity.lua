--------------------------------------------------------
-- Classes - Vehicle Streamable Entity
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
    A streamable entity for vehicles, spawned via asset.
]]
---@class VehicleStreamableEntity: StreamableEntity<NoirVehicle>
---@field New fun(self: VehicleStreamableEntity, asset: Asset): VehicleStreamableEntity
Addon.Classes.VehicleStreamableEntity = Noir.Class("VehicleStreamableEntity", Addon.Classes.StreamableEntity)

--[[
    Initializes new `VehicleStreamableEntity` instances.
]]
---@param asset Asset The vehicle asset to use
function Addon.Classes.VehicleStreamableEntity:Init(asset)
    self:InitFrom(Addon.Classes.StreamableEntity)

    --[[
        The vehicle asset to use.
    ]]
    self.Asset = asset
end

--[[
    Returns the vehicle asset.
]]
---@return Asset
function Addon.Classes.VehicleStreamableEntity:GetAsset()
    return self.Asset
end

--[[
    Spawns the entity at the provided position.
]]
---@return NoirVehicle
function Addon.Classes.VehicleStreamableEntity:HandleSpawn(position)
    local vehicle = self:GetAsset():SpawnVehicle(position)
    Addon.Janitor:DisposeVehicle(vehicle)

    return vehicle
end

--[[
    Returns the position of the entity.
]]
---@return SWMatrix
function Addon.Classes.VehicleStreamableEntity:HandleGetPosition()
    return self:GetEntity():GetPosition()
end

--[[
    Despawns the entity.
]]
function Addon.Classes.VehicleStreamableEntity:HandleDespawn()
    self:GetEntity():Despawn()
end