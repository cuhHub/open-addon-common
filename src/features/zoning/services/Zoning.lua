--------------------------------------------------------
-- Services - Zoning
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
    A service to handle zones.
]]
---@class Zoning: NoirService
Addon.Zoning = Noir.Services:CreateService(
    "Zoning",
    false,
    "A service to handle zones.",
    "A service to handle zones.",
    {"Cuh4"}
)

--[[
    Called when the service is initialized.
]]
function Addon.Zoning:ServiceInit()
    --[[
        A table of all registered zones, indexed by zone ID.
    ]]
    ---@type table<integer, Zone>
    self.Zones = {}
end

--[[
    Called when the service is started.
]]
function Addon.Zoning:ServiceStart()
    self:ScheduleZonesUpdate()
end

--[[
    Registers a zone.
]]
---@param zone Zone The zone to register
function Addon.Zoning:RegisterZone(zone)
    if self:IsZoneRegistered(zone) then
        error("Addon.Zoning:RegisterZone()", "Zone %s (class name: %s) is already registered", zone:GetID(), zone.ClassName)
    end

    self.Zones[zone:GetID()] = zone
    Addon.Logger:Info("Zoning: Registered zone %s (class name: %s)", zone:GetID(), zone.ClassName)
end

--[[
    Returns all zones.
]]
---@return table<integer, Zone>
function Addon.Zoning:GetZones()
    return self.Zones
end

--[[
    Returns a zone by ID.
]]
---@param zoneID integer The ID of the zone
---@return Zone|nil
function Addon.Zoning:GetZone(zoneID)
    return self:GetZones()[zoneID]
end

--[[
    Returns if a zone is registered or not.
]]
---@param zone Zone The zone to check
---@return boolean
function Addon.Zoning:IsZoneRegistered(zone)
    return self:GetZone(zone:GetID()) ~= nil
end

--[[
    Unregisters a zone.
]]
---@param zone Zone The zone to unregister
function Addon.Zoning:UnregisterZone(zone)
    if not self:IsZoneRegistered(zone) then
        error("Addon.Zoning:UnregisterZone()", "Zone %s (class name: %s) is not registered", zone:GetID(), zone.ClassName)
    end

    self.Zones[zone:GetID()] = nil
    Addon.Logger:Info("Zoning: Unregistered zone %s (class name: %s)", zone:GetID(), zone.ClassName)
end

--[[
    Creates a player zone.
]]
---@param radius integer The radius in meters
---@param position SWMatrix The position of the zone
---@return PlayerZone
function Addon.Zoning:CreatePlayerZone(radius, position)
    local zone = Addon.Classes.PlayerZone:New(
        Addon.ID:GetID(),
        radius,
        position
    )

    self:RegisterZone(zone)
    return zone
end

--[[
    Updates all zones.
]]
function Addon.Zoning:UpdateZones()
    ---@type table<integer, integer>
    local zoneIDs = {}

    for _, zone in pairs(self:GetZones()) do
        table.insert(zoneIDs, zone:GetID())
    end

    if #zoneIDs == 0 then
        self:ScheduleZonesUpdate()
        return
    end

    Noir.Services.TaskService:IterateOverTicks(zoneIDs, Config.Zoning.ZoneUpdateBatchSize, function(_, zoneID, _, completed)
        if completed then
            self:ScheduleZonesUpdate()
        end

        local zone = self:GetZone(zoneID)

        if not zone then
            return
        end

        zone:Update()
    end)
end

--[[
    Schedules the next zones update cycle.
]]
function Addon.Zoning:ScheduleZonesUpdate()
    Noir.Services.TaskService:AddTickTask(function()
        self:UpdateZones()
    end, Config.Zoning.ZoneUpdateTickInterval)
end