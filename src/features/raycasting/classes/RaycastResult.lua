--------------------------------------------------------
-- Classes - Raycast Result
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
    A class representing the result of a downwards raycast.
]]
---@class RaycastResult: NoirClass
---@field New fun(self: RaycastResult, sensorPosition: SWMatrix, distance: number): RaycastResult
Addon.Classes.RaycastResult = Noir.Class("RaycastResult")

--[[
    Initializes new `RaycastResult` instances.
]]
---@param sensorPosition SWMatrix The position of the sensor
---@param distance number The distance to the target
function Addon.Classes.RaycastResult:Init(sensorPosition, distance)
    --[[
        The position of the sensor at the time of raycast.
    ]]
    self.SensorPosition = sensorPosition

    --[[
        The distance to the target.
    ]]
    self.Distance = distance

    --[[
        The terrain height.
    ]]
    self.TerrainHeight = sensorPosition[14] - distance

    --[[
        The hit position.
    ]]
    self.HitPosition = matrix.translation(sensorPosition[13], self:GetTerrainHeight(), sensorPosition[15])
end

--[[
    Returns the sensor position at the time of raycast.
]]
---@return SWMatrix
function Addon.Classes.RaycastResult:GetSensorPosition()
    return self.SensorPosition
end

--[[
    Returns the distance to the target.
]]
---@return number
function Addon.Classes.RaycastResult:GetDistance()
    return self.Distance
end

--[[
    Returns the terrain height.
]]
---@return number
function Addon.Classes.RaycastResult:GetTerrainHeight()
    return self.TerrainHeight
end

--[[
    Returns the hit position.
]]
---@return SWMatrix
function Addon.Classes.RaycastResult:GetHitPosition()
    return self.HitPosition
end

--[[
    Returns if the hit position is underwater.
]]
---@return boolean
function Addon.Classes.RaycastResult:IsHitUnderwater()
    return self:GetHitPosition()[14] < 0
end