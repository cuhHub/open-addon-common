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
    A base class for zones.
]]
---@generic T
---@class Zone<T>: NoirClass
---@field New fun(self: Zone, ID: integer, radius: number, position: SWMatrix): Zone<T>
---@field Entities table<integer, T>
---@field GetEntitiesWithin fun(self: Zone): table<integer, T>
---@field FindAllEntities fun(self: Zone): table<integer, T>
---@field GetEntityPosition fun(self: Zone, entity: T): SWMatrix
---@field CheckIsEntityValid fun(self: Zone, entity: T): boolean
---@field GetIDForEntity fun(self: Zone, entity: T): integer
---@field CheckIsEntityIn fun(self: Zone, entity: T): boolean
---@field HandleEnter fun(self: Zone, entity: T)
---@field HandleExit fun(self: Zone, entity: T)
---@field IsIn fun(self: Zone, entity: T): boolean
---@field IsOut fun(self: Zone, entity: T): boolean
Addon.Classes.Zone = Noir.Class("Zone")

--[[
    Initializes new `Zone` instances.
]]
---@param ID integer The ID of the zone
---@param radius number The radius of the zone
---@param position SWMatrix The position of the zone
function Addon.Classes.Zone:Init(ID, radius, position)
    --[[
        The ID of the zone.
    ]]
    self.ID = ID

    --[[
        The radius of the zone (meters).
    ]]
    self.Radius = radius

    --[[
        The radius of the zone squared (meters).
    ]]
    self.RadiusSquared = radius * radius

    --[[
        The position of the zone.
    ]]
    self.Position = position

    --[[
        The entities in the zone.
    ]]
    self.Entities = {}

    --[[
        An event fired when an entity enters the zone.<br>
        Arguments: entity (T)
    ]]
    self.OnEnter = Noir.Libraries.Events:Create()

    --[[
        An event fired when an entity exits the zone.<br>
        Arguments: entity (T)
    ]]
    self.OnExit = Noir.Libraries.Events:Create()
end

--[[
    Returns the zone's ID.
]]
---@return integer
function Addon.Classes.Zone:GetID()
    return self.ID
end

--[[
    Returns the zone's radius (meters).
]]
---@return number
function Addon.Classes.Zone:GetRadius()
    return self.Radius
end

--[[
    Returns the zone's radius squared (meters).
]]
---@return number
function Addon.Classes.Zone:GetRadiusSquared()
    return self.RadiusSquared
end

--[[
    Returns the zone's position.
]]
---@return SWMatrix
function Addon.Classes.Zone:GetPosition()
    return self.Position
end

--[[
    Returns the entities in the zone.
]]
function Addon.Classes.Zone:GetEntitiesWithin()
    return self.Entities
end

--[[
    Updates the zone.
]]
function Addon.Classes.Zone:Update()
    local allEntities = self:FindAllEntities()

    -- detect enters
    for _, entity in pairs(allEntities) do
        if self:CheckIsEntityIn(entity) and self:IsOut(entity) then
            self:HandleEnter(entity)
        end
    end

    -- detect exits
    for _, entity in pairs(self:GetEntitiesWithin()) do
        if not self:CheckIsEntityIn(entity) then
            self:HandleExit(entity)
        end
    end
end

--[[
    Returns all possible entities that can be in the zone.<br>
    *abstractmethod*
]]
function Addon.Classes.Zone:FindAllEntities()
    error("Addon.Classes.Zone:FindAllEntities()", "Method not implemented in subclass.")
end

--[[
    Returns the position of the given entity.<br>
    *abstractmethod*
]]
function Addon.Classes.Zone:GetEntityPosition(entity)
    error("Addon.Classes.Zone:GetEntityPosition()", "Method not implemented in subclass.")
end

--[[
    Returns if the given entity is still valid.<br>
    *abstractmethod*
]]
function Addon.Classes.Zone:CheckIsEntityValid(entity)
    error("Addon.Classes.Zone:CheckIsEntityValid()", "Method not implemented in subclass.")
end

--[[
    Returns the ID for the given entity.<br>
    *abstractmethod*
]]
function Addon.Classes.Zone:GetIDForEntity(entity)
    error("Addon.Classes.Zone:GetIDForEntity()", "Method not implemented in subclass.")
end

--[[
    Checks if the given entity is in the zone.
]]
function Addon.Classes.Zone:CheckIsEntityIn(entity)
    if not self:CheckIsEntityValid(entity) then
        return false
    end

    return self:IsPositionIn(self:GetEntityPosition(entity))
end

--[[
    Returns if a position is in the zone.
]]
---@param position SWMatrix The position to check
---@return boolean
function Addon.Classes.Zone:IsPositionIn(position)
    return Addon.Libs.Matrix:GetSquaredDistance(
        position,
        self:GetPosition()
    ) <= self:GetRadiusSquared()
end

--[[
    Handles when an entity enters the zone.
]]
function Addon.Classes.Zone:HandleEnter(entity)
    local entityID = self:GetIDForEntity(entity)

    if self.Entities[entityID] then
        error("Addon.Classes.Zone:HandleEnter()", "Entity is already in the zone.")
    end

    self.Entities[entityID] = entity
    self.OnEnter:Fire(entity)
end

--[[
    Handles when an entity exits the zone.
]]
function Addon.Classes.Zone:HandleExit(entity)
    local entityID = self:GetIDForEntity(entity)

    if not self.Entities[entityID] then
        error("Addon.Classes.Zone:HandleExit()", "Entity is already not in the zone.")
    end

    self.Entities[entityID] = nil
    self.OnExit:Fire(entity)
end

--[[
    Returns if the given entity is in the zone.
]]
function Addon.Classes.Zone:IsIn(entity)
    return self:GetEntitiesWithin()[self:GetIDForEntity(entity)] ~= nil
end

--[[
    Returns if the given entity is out of the zone.
]]
function Addon.Classes.Zone:IsOut(entity)
    return not self:IsIn(entity)
end

--[[
    Returns if any entity is in the zone.
]]
---@return boolean
function Addon.Classes.Zone:IsAnyIn()
    return next(self:GetEntitiesWithin()) ~= nil
end

--[[
    Removes this zone.
]]
function Addon.Classes.Zone:Remove()
    Addon.Zoning:UnregisterZone(self)
end