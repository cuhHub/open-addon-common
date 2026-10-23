--------------------------------------------------------
-- Classes - Raycast Sensor Vehicle
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
    A class representing a sensor vehicle to provide raycast results.
]]
---@class RaycastSensorVehicle: NoirClass
---@field New fun(self: RaycastSensorVehicle, asset: Asset): RaycastSensorVehicle
Addon.Classes.RaycastSensorVehicle = Noir.Class("RaycastSensorVehicle")

--[[
    Initializes new `RaycastSensorVehicle` instances.
]]
---@param asset Asset The vehicle asset to use
function Addon.Classes.RaycastSensorVehicle:Init(asset)
    --[[
        The vehicle asset.
    ]]
    self.Asset = asset

    --[[
        The spawned raycast vehicle.
    ]]
    ---@type NoirVehicle
    self.Vehicle = nil

    --[[
        Whether or not the sensor vehicle is at resting position.
    ]]
    self.Resting = false

    --[[
        The sensor reading dial name.
    ]]
    self.SENSOR_READING_DIAL_NAME = "Distance"

    --[[
        The sensor position sign.
    ]]
    self.SENSOR_POSITION_SIGN = "SensorPos"

    --[[
        The sensor max distance.
    ]]
    self.SENSOR_MAX_DISTANCE = 3000
end

--[[
    Sets up the vehicle.
]]
function Addon.Classes.RaycastSensorVehicle:Setup()
    self:Spawn()
end

--[[
    Spawns the vehicle.
]]
function Addon.Classes.RaycastSensorVehicle:Spawn()
    if self:IsSpawned() then
        error("Addon.Classes.RaycastSensorVehicle:Spawn()", "Raycast vehicle is already spawned.")
    end

    self.Vehicle = self:GetAsset():SpawnVehicle(matrix.identity())
    Addon.Janitor:DisposeVehicle(self.Vehicle)
end

--[[
    Returns the asset.
]]
---@return Asset
function Addon.Classes.RaycastSensorVehicle:GetAsset()
    return self.Asset
end

--[[
    Returns if the vehicle is at resting position.
]]
---@return boolean
function Addon.Classes.RaycastSensorVehicle:IsResting()
    return self.Resting
end

--[[
    Returns if the vehicle is spawned or not.
]]
---@return boolean
function Addon.Classes.RaycastSensorVehicle:IsSpawned()
    return self.Vehicle ~= nil
end

--[[
    Returns the vehicle.
]]
---@return NoirVehicle
function Addon.Classes.RaycastSensorVehicle:GetVehicle()
    if not self:IsSpawned() then
        error("Addon.Classes.RaycastSensorVehicle:GetVehicle()", "Raycast vehicle is not spawned.")
    end

    return self.Vehicle
end

--[[
    Returns the primary body.
]]
---@return NoirBody
function Addon.Classes.RaycastSensorVehicle:GetPrimaryBody()
    if not self:IsSpawned() then
        error("Addon.Classes.RaycastSensorVehicle:GetPrimaryBody()", "Raycast vehicle is not spawned.")
    end

    return self:GetVehicle().PrimaryBody
end

--[[
    Returns if the vehicle is ready for sensor readings.
]]
---@return boolean
function Addon.Classes.RaycastSensorVehicle:IsReady()
    if not self:IsSpawned() then
        return false
    end

    local primaryBody = self:GetPrimaryBody()

    if not primaryBody:IsSimulating() then
        return false
    end

    return true
end

--[[
    Moves the vehicle to the provided position.
]]
---@param position SWMatrix The position to move to
function Addon.Classes.RaycastSensorVehicle:_Move(position)
    if not self:IsSpawned() then
        error("Addon.Classes.RaycastSensorVehicle:_Move()", "Raycast vehicle is not spawned.")
    end

    self:GetVehicle():Move(position)
end

--[[
    Moves the vehicle to the provided position.
]]
---@param position SWMatrix The position to move to
function Addon.Classes.RaycastSensorVehicle:MoveTo(position)
    if not self:IsSpawned() then
        error("Addon.Classes.RaycastSensorVehicle:MoveTo()", "Raycast vehicle is not spawned.")
    end

    self:_Move(matrix.translation(position[13], self.SENSOR_MAX_DISTANCE, position[15]))
    self.Resting = false
end

--[[
    Resets the vehicle.
]]
function Addon.Classes.RaycastSensorVehicle:TryReset()
    if not self:IsSpawned() then
        error("Addon.Classes.RaycastSensorVehicle:TryReset()", "Raycast vehicle is not spawned.")
    end

    if self:IsResting() then
        return
    end

    self:_Move(matrix.identity())
    self.Resting = true
end

--[[
    Returns the sensor position.
]]
---@return SWMatrix
function Addon.Classes.RaycastSensorVehicle:GetSensorPosition()
    if not self:IsReady() then
        error("Addon.Classes.RaycastSensorVehicle:GetSensorPosition()", "Raycast vehicle is not ready.")
    end

    local sign = self:GetPrimaryBody():GetSign(self.SENSOR_POSITION_SIGN)

    if not sign then
        error("Addon.Classes.RaycastSensorVehicle:GetSensorPosition()", "Raycast vehicle does not have a sign.")
    end

    return self:GetVehicle():GetPosition(sign.pos.x, sign.pos.y, sign.pos.z)
end

--[[
    Returns the distance reading.
]]
---@return RaycastResult
function Addon.Classes.RaycastSensorVehicle:GetRaycastResult()
    if not self:IsReady() then
        error("Addon.Classes.RaycastSensorVehicle:GetRaycastResult()", "Raycast vehicle is not ready.")
    end

    local dial = self:GetPrimaryBody():GetDial(self.SENSOR_READING_DIAL_NAME)

    if not dial then
        error("Addon.Classes.RaycastSensorVehicle:GetRaycastResult()", "Raycast vehicle does not have a dial.")
    end

    return Addon.Classes.RaycastResult:New(self:GetSensorPosition(), dial.value)
end