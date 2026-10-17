--------------------------------------------------------
-- Classes - Streamable
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
    Base class for streamable entities (e.g. vehicles).
]]
---@class Streamable: NoirClass
---@field New fun(self: Streamable, ID: integer, spawnPosition: SWMatrix, streamRadius: number, streamType: StreamType, streamSpawningType: StreamSpawningType, entity: StreamableEntity): Streamable
Addon.Classes.Streamable = Noir.Class("Streamable")

--[[
    Initializes new `Streamable` instances.
]]
---@param ID integer The ID of the streamable
---@param spawnPosition SWMatrix The initial spawn position of the streamable
---@param streamRadius number The radius of the stream zone (meters)
---@param streamType StreamType The type of streaming to use
---@param streamSpawningType StreamSpawningType The spawning type to use
---@param entity StreamableEntity The streamable entity instance
function Addon.Classes.Streamable:Init(ID, spawnPosition, streamRadius, streamType, streamSpawningType, entity)
    --[[
        The ID of the streamable.
    ]]
    self.ID = ID

    --[[
        The initial spawn position of the streamable.
    ]]
    self.SpawnPosition = spawnPosition

    --[[
        The last position of the streamable when streamed in.
    ]]
    self.LastPosition = spawnPosition

    --[[
        The type of streaming in use.
    ]]
    self.StreamType = streamType

    --[[
        The spawning type in use.
    ]]
    self.StreamSpawningType = streamSpawningType

    --[[
        The streamable entity instance.
    ]]
    self.Entity = entity

    --[[
        The trigger zone.
    ]]
    self.TriggerZone = Addon.Zoning:CreatePlayerZone(streamRadius, self.SpawnPosition)

    --[[
        Whether or not the streamable is streamed in.
    ]]
    self.StreamedIn = false

    --[[
        Fired after the streamable is streamed in.
    ]]
    self.OnStreamedIn = Noir.Libraries.Events:Create()

    --[[
        Fired after the streamable is streamed out.
    ]]
    self.OnStreamedOut = Noir.Libraries.Events:Create()
end

--[[
    Sets up the streamable.
]]
function Addon.Classes.Streamable:Setup()
    local zone = self:GetTriggerZone()

    zone.OnEnter:Connect(function()
        self:StreamIn()
    end)

    zone.OnExit:Connect(function()
        if zone:IsAnyIn() then
           return
        end

        self:StreamOut()
    end)
end

--[[
    Updates the streamable.
]]
function Addon.Classes.Streamable:Update()
    local entity = self:GetStreamableEntity()

    if not entity:IsSpawned() then
        return
    end

    self:UpdateLastPosition(entity:GetPosition())
end

--[[
    Streams in.
]]
function Addon.Classes.Streamable:StreamIn()
    if self:IsStreamedIn() then
        return
    end

    Addon.Logger:Info("Streamable: %s - stream in", self:GetID())

    self.StreamedIn = true
    self.Entity:Spawn(self:DetermineSpawnPosition())

    self.OnStreamedIn:Fire()
end

--[[
    Streams out.
]]
function Addon.Classes.Streamable:StreamOut()
    if not self:IsStreamedIn() then
        return
    end

    if self:GetStreamType() == Addon.Enums.StreamType.StreamInOnly then
        return
    end

    Addon.Logger:Info("Streamable: %s - stream out", self:GetID())

    self.StreamedIn = false
    self.Entity:Despawn()

    self.OnStreamedOut:Fire()
end

--[[
    Returns if the streamable is streamed in.
]]
---@return boolean
function Addon.Classes.Streamable:IsStreamedIn()
    return self.StreamedIn
end

--[[
    Updates the last position.
]]
---@param position SWMatrix The new last position
function Addon.Classes.Streamable:UpdateLastPosition(position)
    if self:GetStreamSpawningType() ~= Addon.Enums.StreamSpawningType.UseLastPosition then -- no point in updating the last position if we don't use it
        return
    end

    self.LastPosition = position
    self:GetTriggerZone().Position = position
end

--[[
    Determines the spawn position to use for the entity.
]]
---@return SWMatrix
function Addon.Classes.Streamable:DetermineSpawnPosition()
    local spawningType = self:GetStreamSpawningType()

    if spawningType == Addon.Enums.StreamSpawningType.UseLastPosition then
        return self:GetPosition()
    elseif spawningType == Addon.Enums.StreamSpawningType.UseSpawnPosition then
        return self:GetSpawnPosition()
    else
        error("Addon.Classes.Streamable:DetermineSpawnPosition()", "Invalid stream spawning type (%s).", spawningType)
    end
end

--[[
    Returns the ID of the streamable.
]]
---@return integer
function Addon.Classes.Streamable:GetID()
    return self.ID
end

--[[
    Returns the initial spawn position of the streamable.
]]
---@return SWMatrix
function Addon.Classes.Streamable:GetSpawnPosition()
    return self.SpawnPosition
end

--[[
    Returns the last position of the streamable when streamed in.
]]
---@return SWMatrix
function Addon.Classes.Streamable:GetPosition()
    return self.LastPosition
end

--[[
    Returns the type of streaming in use.
]]
---@return StreamType
function Addon.Classes.Streamable:GetStreamType()
    return self.StreamType
end

--[[
    Returns the spawning type in use.
]]
---@return StreamSpawningType
function Addon.Classes.Streamable:GetStreamSpawningType()
    return self.StreamSpawningType
end

--[[
    Returns the streamable entity instance.
]]
---@return StreamableEntity
function Addon.Classes.Streamable:GetStreamableEntity()
    return self.Entity
end

--[[
    Returns the streamable trigger zone.
]]
---@return PlayerZone
function Addon.Classes.Streamable:GetTriggerZone()
    return self.TriggerZone
end

--[[
    Cleans up the streamable.
]]
function Addon.Classes.Streamable:Cleanup()
    self:GetTriggerZone():Remove()
end

--[[
    Removes this streamable.
]]
function Addon.Classes.Streamable:Remove()
    Addon.Streamables:RemoveStreamable(self)
end