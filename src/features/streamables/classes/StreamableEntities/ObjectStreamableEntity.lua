--------------------------------------------------------
-- Classes - Object Streamable Entity
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
    A callback for spawning an object for object streamable entity.
]]
---@alias ObjectStreamableEntitySpawnCallback fun(position: SWMatrix): NoirObject

--[[
    A streamable entity for objects, spawned via passed callback.
]]
---@class ObjectStreamableEntity: StreamableEntity<NoirObject>
---@field New fun(self: ObjectStreamableEntity, spawnCallback: ObjectStreamableEntitySpawnCallback): ObjectStreamableEntity
Addon.Classes.ObjectStreamableEntity = Noir.Class("ObjectStreamableEntity", Addon.Classes.StreamableEntity)

--[[
    Initializes new `ObjectStreamableEntity` instances.
]]
---@param spawnCallback ObjectStreamableEntitySpawnCallback
function Addon.Classes.ObjectStreamableEntity:Init(spawnCallback)
    self:InitFrom(Addon.Classes.StreamableEntity)

    --[[
        The spawn callback to use.
    ]]
    self.SpawnCallback = spawnCallback
end

--[[
    Returns the sapwn callback.
]]
---@return ObjectStreamableEntitySpawnCallback
function Addon.Classes.ObjectStreamableEntity:GetSpawnCallback()
    return self.SpawnCallback
end

--[[
    Spawns the entity at the provided position.
]]
---@return NoirObject
function Addon.Classes.ObjectStreamableEntity:HandleSpawn(position)
    local object = self:GetSpawnCallback()(position)
    Addon.Janitor:DisposeObject(object)

    return object
end

--[[
    Returns the position of the entity.
]]
---@return SWMatrix
function Addon.Classes.ObjectStreamableEntity:HandleGetPosition()
    return self:GetEntity():GetPosition()
end

--[[
    Despawns the entity.
]]
function Addon.Classes.ObjectStreamableEntity:HandleDespawn()
    self:GetEntity():Despawn()
end