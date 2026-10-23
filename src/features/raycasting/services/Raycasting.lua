--------------------------------------------------------
-- Services - Raycasting
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
    A service to handle raycasting (only downwards for now).
]]
---@class Raycasting: NoirService
Addon.Raycasting = Noir.Services:CreateService(
    "Raycasting",
    false,
    "A service to handle raycasting.",
    "A service to handle raycasting (only downwards for now).",
    {"Cuh4"}
)

--[[
    Called when the service is initialized.
]]
function Addon.Raycasting:ServiceInit()
    --[[
        The raycast request queue.
    ]]
    ---@type Queue<RaycastRequest>
    self.RaycastRequests = Addon.Libs.Queue:CreateQueue()

    --[[
        The raycast vehicle asset tag.
    ]]
    self.RAYCAST_VEHICLE_ASSET_TAG = "raycast_vehicle"

    --[[
        The raycast vehicle asset.
    ]]
    ---@type Asset
    self.RaycastVehicleAsset = nil

    --[[
        The raycast sensor vehicle.
    ]]
    ---@type RaycastSensorVehicle
    self.RaycastVehicle = nil
end

--[[
    Called when the service is started.
]]
function Addon.Raycasting:ServiceStart()
    self:FindRaycastVehicleAsset()
    self:CreateRaycastVehicle()

    --[[
        A connection to `onTick`.
    ]]
    self.OnTickConnection = Noir.Callbacks:Connect("onTick", function()
        self:HandleNextRaycastRequest()
    end)
end

--[[
    Handles the next raycast request.
]]
function Addon.Raycasting:HandleNextRaycastRequest()
   local request = self:GetRaycastRequests():Get()

    if not request then
        return
    end

    local vehicle = self:GetRaycastVehicle()

    if not vehicle:IsReady() then
        return
    end

    local state = request:GetState()

    if state == Addon.Enums.RaycastRequestState.Queued then -- move to raycast position
        Addon.Logger:Info("Raycasting: Handling queued raycast request")

        vehicle:MoveTo(request:GetPosition())
        request:SetState(Addon.Enums.RaycastRequestState.Moved)
    elseif state == Addon.Enums.RaycastRequestState.Moved and request:HasBeenMovedStatedLongEnough() then -- been moved, so get raycast result (sensor would show value now)
        local result = vehicle:GetRaycastResult()

        Addon.Logger:Info(
            "Raycasting: Raycast request done, dist: %s, underwater: %s",
            result:GetDistance(), tostring(result:IsHitUnderwater())
        )

        request:Done(result)
        self:GetRaycastRequests():Pop()
    end
end

--[[
    Finds the raycast vehicle asset.
]]
function Addon.Raycasting:FindRaycastVehicleAsset()
    local asset = Addon.Assets:Find({self.RAYCAST_VEHICLE_ASSET_TAG})[1]

    if not asset then
        error("Addon.Raycasting:ServiceStart()", "Raycast vehicle asset not found.")
    end

    self.RaycastVehicleAsset = asset
end

--[[
    Returns the raycast vehicle asset.
]]
---@return Asset
function Addon.Raycasting:GetRaycastVehicleAsset()
    return self.RaycastVehicleAsset
end

--[[
    Creates the raycast vehicle.
]]
function Addon.Raycasting:CreateRaycastVehicle()
    self.RaycastVehicle = Addon.Classes.RaycastSensorVehicle:New(self:GetRaycastVehicleAsset())
    self:GetRaycastVehicle():Setup()
end

--[[
    Returns the raycast vehicle.
]]
---@return RaycastSensorVehicle
function Addon.Raycasting:GetRaycastVehicle()
    return self.RaycastVehicle
end

--[[
    Creates a raycast request.
]]
---@param position SWMatrix The position to raycast downwards from
---@param callback fun(result: RaycastResult)
---@return RaycastRequest
function Addon.Raycasting:CreateRaycastRequest(position, callback)
    local request = Addon.Classes.RaycastRequest:New(position)
    request.OnDone:Connect(callback)

    self:GetRaycastRequests():Add(request)

    Addon.Logger:Info("Raycasting: Creating downwards raycast request at %s", Noir.Libraries.Matrix:ToString(position))

    return request
end

--[[
    Returns all raycast requests.
]]
---@return Queue<RaycastRequest>
function Addon.Raycasting:GetRaycastRequests()
    return self.RaycastRequests
end