--------------------------------------------------------
-- Services - Streamables
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
    A service to handle dynamically-streamed entities, like vehicles.
]]
---@class Streamables: NoirService
Addon.Streamables = Noir.Services:CreateService(
    "Streamables",
    false,
    "A service to handle dynamically-streamed entities, like vehicles.",
    "A service to handle dynamically-streamed entities, like vehicles.",
    {"Cuh4"}
)

--[[
    Called when the service is initialized.
]]
function Addon.Streamables:ServiceInit()
    ---@type table<integer, Streamable>
    self.Streamables = {}
end

--[[
    Called when the service is started.
]]
function Addon.Streamables:ServiceStart()
    self:RegisterFlags()
    self:ScheduleUpdate()
end

--[[
    Schedules an update for all streamables.
]]
function Addon.Streamables:ScheduleUpdate()
    Noir.Services.TaskService:AddTickTask(function()
        self:Update()
    end, Config.Streamables.UpdateTickInterval)
end

--[[
    Updates all streamables.
]]
function Addon.Streamables:Update()
    if not Addon.Flags:IsEnabled("Streamables.Update") then
        self:ScheduleUpdate()
        return
    end

    local streamableIDs = {}

    for _, streamable in pairs(self:GetStreamables()) do
        table.insert(streamableIDs, streamable:GetID())
    end

    if #streamableIDs <= 0 then
        self:ScheduleUpdate()
        return
    end

    Noir.Services.TaskService:IterateOverTicks(
        streamableIDs,
        Config.Streamables.StreamablesPerTickIteration,
        function(_, streamableID, _, completed)
            if completed then
                self:ScheduleUpdate()
            end

            local streamable = self:GetStreamable(streamableID)

            if not streamable then
                return
            end

            streamable:Update()
        end
    )
end

--[[
    Creates a vehicle streamable entity.
]]
---@param vehicleAsset Asset The vehicle asset to use
---@return VehicleStreamableEntity
function Addon.Streamables:CreateVehicleStreamableEntity(vehicleAsset)
    return Addon.Classes.VehicleStreamableEntity:New(vehicleAsset)
end

--[[
    Creates a streamable.
]]
---@param spawnPosition SWMatrix The spawn position of the streamable
---@param streamRadius number The radius of the streamable
---@param streamType StreamType The type of streaming to use
---@param streamSpawningType StreamSpawningType The spawning type to use
---@param entity StreamableEntity The streamable entity instance
---@return Streamable
function Addon.Streamables:CreateStreamable(spawnPosition, streamRadius, streamType, streamSpawningType, entity)
    local streamable = Addon.Classes.Streamable:New(
        Addon.ID:GetID(), spawnPosition, streamRadius,
        streamType, streamSpawningType, entity
    )

    streamable:Setup()

    self.Streamables[streamable.ID] = streamable

    Addon.Logger:Info(
        "Streamables: Created streamable %s with entity %s at %s",
        streamable:GetID(), streamable:GetStreamableEntity().ClassName,
        Noir.Libraries.Matrix:ToString(streamable:GetSpawnPosition())
    )

    return streamable
end

--[[
    Returns all streamables.
]]
---@return table<integer, Streamable>
function Addon.Streamables:GetStreamables()
    return self.Streamables
end

--[[
    Returns a streamable by ID.
]]
---@param ID integer The ID of the streamable
---@return Streamable|nil
function Addon.Streamables:GetStreamable(ID)
    return self:GetStreamables()[ID]
end

--[[
    Returns if a streamable is registered or not.
]]
---@param streamable Streamable The streamable to check
---@return boolean
function Addon.Streamables:HasStreamable(streamable)
    return self:GetStreamable(streamable.ID) ~= nil
end

--[[
    Removes a streamable.
]]
---@param streamable Streamable The streamable to remove
function Addon.Streamables:RemoveStreamable(streamable)
    if not self:HasStreamable(streamable) then
        error("Addon.Streamables:RemoveStreamable()", "Streamable %s is not registered", streamable.ID)
    end

    Addon.Logger:Info("Streamables: Removing streamable %s", streamable:GetID())

    streamable:Cleanup()
    self.Streamables[streamable.ID] = nil
end

--[[
    Registers flags.
]]
function Addon.Streamables:RegisterFlags()
    Addon.Flags:RegisterFlag(
        "Streamables.Update",
        true
    )
end