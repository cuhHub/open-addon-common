--------------------------------------------------------
-- Classes - Streamable Entity
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
    Base class for anything that is streamable (e.g. vehicle).
]]
---@generic T
---@class StreamableEntity<T>: NoirClass
---@field New fun(self: StreamableEntity): StreamableEntity
---@field Entity T|nil The entity instance (nil if not spawned).
---@field GetEntity fun(self: StreamableEntity): T Returns the entity.
---@field HandleSpawn fun(self: StreamableEntity, position: SWMatrix): T Spawns the entity at the provided position.
Addon.Classes.StreamableEntity = Noir.Class("StreamableEntity")

--[[
    Initializes new `StreamableEntity` instances.
]]
function Addon.Classes.StreamableEntity:Init()
    --[[
        The entity instance (nil if not not spawned).
    ]]
    self.Entity = nil

    --[[
        Event fired on spawn.<br>
        Arguments: entity (T)
    ]]
    self.OnSpawn = Noir.Libraries.Events:Create()

    --[[
        Event fired before despawn.<br>
        Arguments: entity (T)
    ]]
    self.OnBeforeDespawn = Noir.Libraries.Events:Create()

    --[[
        Event fired after despawn.
    ]]
    self.OnAfterDespawn = Noir.Libraries.Events:Create()
end

--[[
    Spawns the entity at the provided position.<br>
    *abstractmethod*
]]
function Addon.Classes.StreamableEntity:HandleSpawn(position)
    error("Addon.Classes.StreamableEntity:Spawn()", "Missing implementation")
end

--[[
    Spawns the entity.
]]
---@param position SWMatrix The position to spawn the entity at
function Addon.Classes.StreamableEntity:Spawn(position)
    if self:IsSpawned() then
        error("Addon.Classes.StreamableEntity:Spawn()", "Entity is already spawned.")
    end

    Addon.Logger:Info("StreamableEntity: Spawning entity (class: %s)", self.ClassName)

    self.Entity = self:HandleSpawn(position)
    self.OnSpawn:Fire(self:GetEntity())
end

--[[
    Returns the entity.
]]
function Addon.Classes.StreamableEntity:GetEntity()
    if not self:IsSpawned() then
        error("Addon.Classes.StreamableEntity:GetEntity()", "Entity is not spawned.")
    end

    return self.Entity
end

--[[
    Returns if the entity is spawned.
]]
---@return boolean
function Addon.Classes.StreamableEntity:IsSpawned()
    return self.Entity ~= nil
end

--[[
    Returns the position of the entity.<br>
    *abstractmethod*
]]
---@return SWMatrix
function Addon.Classes.StreamableEntity:HandleGetPosition()
    error("Addon.Classes.StreamableEntity:GetPosition()", "Missing implementation")
end

--[[
    Returns the position of the entity.
]]
---@return SWMatrix
function Addon.Classes.StreamableEntity:GetPosition()
    if not self:IsSpawned() then
        error("Addon.Classes.StreamableEntity:GetPosition()", "Entity is not spawned.")
    end

    return self:HandleGetPosition()
end

--[[
    Despawns the entity.<br>
    *abstractmethod*
]]
function Addon.Classes.StreamableEntity:HandleDespawn()
    error("Addon.Classes.StreamableEntity:Despawn()", "Missing implementation")
end

--[[
    Despawns the entity.
]]
function Addon.Classes.StreamableEntity:Despawn()
    if not self:IsSpawned() then
        error("Addon.Classes.StreamableEntity:Despawn()", "Entity is not spawned.")
    end

    Addon.Logger:Info("StreamableEntity: Despawning entity (class: %s)", self.ClassName)

    self.OnBeforeDespawn:Fire(self:GetEntity())

    self:HandleDespawn()
    self.Entity = nil

    self.OnAfterDespawn:Fire()
end