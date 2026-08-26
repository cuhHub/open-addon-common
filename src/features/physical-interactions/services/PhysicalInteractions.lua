--------------------------------------------------------
-- Services - Physical Interactions
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
    A service that manages physical interactions for players.
]]
---@class PhysicalInteractions: NoirService
Addon.PhysicalInteractions = Noir.Services:CreateService(
    "PhysicalInteractions",
    false,
    "A service that manages physical interactions for players.",
    "A service that manages physical interactions for players.",
    {"Cuh4"}
)

Addon.PhysicalInteractions.StartPriority = 999 -- start after all other features have registered their prefabs

--[[
    Called when this service is initialized.
]]
function Addon.PhysicalInteractions:ServiceInit()
    --[[
        A table of registered physical interaction prefabs, indexed by name.
    ]]
    ---@type table<string, PhysicalInteractionPrefab>
    self.PhysicalInteractionPrefabs = {}

    --[[
        A table of player physical interactions, indexed by player ID then prefab name.
    ]]
    ---@type table<integer, table<string, PhysicalInteraction>>
    self.PlayerPhysicalInteractions = {}
end

--[[
    Called when this service is started.
]]
function Addon.PhysicalInteractions:ServiceStart()
    --[[
        A connection to `PlayerService`'s `OnJoin` event.
    ]]
    ---@param player NoirPlayer
    self.OnPlayerJoinConnection = Noir.Services.PlayerService.OnJoin:Connect(function(player)
        self:CreatePlayerPhysicalInteractions(player)
    end)

    --[[
        A connection to `PlayerService`'s `OnLeave` event.
    ]]
    ---@param player NoirPlayer
    self.OnPlayerLeaveConnection = Noir.Services.PlayerService.OnLeave:Connect(function(player)
        self:RemovePlayerPhysicalInteractions(player)
    end)

    --[[
        A connection to `PlayerService`'s `OnDie` event.
    ]]
    ---@param player NoirPlayer
    self.OnPlayerDieConnection = Noir.Services.PlayerService.OnDie:Connect(function(player)
        local interaction = self:GetPlayerDeployedInteraction(player)

        if not interaction then
            return
        end

        interaction:Retract(Addon.Enums.PhysicalInteractionRetractReason.None, true)
    end)

    for _, player in pairs(Noir.Services.PlayerService:GetPlayers()) do
        self:CreatePlayerPhysicalInteractions(player)
    end

    --[[
        The repeated physical interaction update task.
    ]]
    self.PhysicalInteractionUpdateTask = Noir.Services.TaskService:AddTickTask(function()
        self:UpdateAllPhysicalInteractions()
    end, Config.PhysicalInteractions.UpdateTickInterval, nil, true)
end

--[[
    Updates all physical interactions.
]]
function Addon.PhysicalInteractions:UpdateAllPhysicalInteractions()
    for _, interactions in pairs(self:GetPlayerPhysicalInteractions()) do
        for _, interaction in pairs(interactions) do
            interaction:Update()
        end
    end
end

--[[
    Registers a physical interaction prefab.
]]
---@param prefab PhysicalInteractionPrefab The prefab to register
function Addon.PhysicalInteractions:RegisterPhysicalInteractionPrefab(prefab)
    self.PhysicalInteractionPrefabs[prefab:GetName()] = prefab
    Addon.Logger:Debug("PhysicalInteractions: Registered physical interaction prefab '%s'", prefab:GetName())
end

--[[
    Returns all registered physical interaction prefabs.
]]
---@return table<string, PhysicalInteractionPrefab>
function Addon.PhysicalInteractions:GetPhysicalInteractionPrefabs()
    return self.PhysicalInteractionPrefabs
end

--[[
    Returns a physical interaction prefab by name.
]]
---@param name string The name of the prefab
---@return PhysicalInteractionPrefab|nil
function Addon.PhysicalInteractions:GetPhysicalInteractionPrefab(name)
    return self:GetPhysicalInteractionPrefabs()[name]
end

--[[
    Creates all physical interactions for a player.
]]
---@param player NoirPlayer The player to create interactions for
function Addon.PhysicalInteractions:CreatePlayerPhysicalInteractions(player)
    if self.PlayerPhysicalInteractions[player.ID] then
        Addon.Logger:Warning("PhysicalInteractions: Player %s (%s) joined but already has physical interactions.", player.Name, player.Steam)
        return
    end

    self.PlayerPhysicalInteractions[player.ID] = {}

    for _, prefab in pairs(self:GetPhysicalInteractionPrefabs()) do
        local interaction = prefab:Create(player)
        interaction:Spawn()

        self.PlayerPhysicalInteractions[player.ID][prefab:GetName()] = interaction

        Addon.Logger:Debug("PhysicalInteractions: Created '%s' interaction for %s (%s)", prefab:GetName(), player.Name, player.Steam)
    end
end

--[[
    Removes all physical interactions for a player.
]]
---@param player NoirPlayer The player to remove interactions from
function Addon.PhysicalInteractions:RemovePlayerPhysicalInteractions(player)
    local interactions = self:GetPlayerPhysicalInteractions()[player.ID]

    if not interactions then
        Addon.Logger:Warning("PhysicalInteractions: Player %s (%s) left but does not have physical interactions.", player.Name, player.Steam)
        return
    end

    for _, interaction in pairs(interactions) do
        if interaction:IsDeployed() then
            interaction:Retract(Addon.Enums.PhysicalInteractionRetractReason.None, true)
        end

        interaction:Despawn()
    end

    self.PlayerPhysicalInteractions[player.ID] = nil

    Addon.Logger:Debug("PhysicalInteractions: Removed all interactions for %s (%s)", player.Name, player.Steam)
end

--[[
    Returns all player physical interactions.
]]
---@return table<integer, table<string, PhysicalInteraction>>
function Addon.PhysicalInteractions:GetPlayerPhysicalInteractions()
    return self.PlayerPhysicalInteractions
end

--[[
    Returns a player's physical interaction by prefab.
]]
---@param player NoirPlayer The player
---@param prefab PhysicalInteractionPrefab The prefab to get the interaction for
---@return PhysicalInteraction|nil
function Addon.PhysicalInteractions:GetPhysicalInteraction(player, prefab)
    local interactions = self.PlayerPhysicalInteractions[player.ID]

    if not interactions then
        return nil
    end

    return interactions[prefab:GetName()]
end

--[[
    Returns if a player has a physical interaction for the given prefab.
]]
---@param player NoirPlayer The player
---@param prefab PhysicalInteractionPrefab The prefab to check
---@return boolean
function Addon.PhysicalInteractions:HasPhysicalInteraction(player, prefab)
    return self:GetPhysicalInteraction(player, prefab) ~= nil
end

--[[
    Returns if a position is too close to any player vehicle.
]]
---@param position SWMatrix The position to check
---@return boolean
function Addon.PhysicalInteractions:IsPositionTooCloseToVehicle(position)
    local prohibitedDistanceSquared = Config.PhysicalInteractions.ProhibitedDistanceToVehicle * Config.PhysicalInteractions.ProhibitedDistanceToVehicle

    for _, body in pairs(Noir.Services.VehicleService:GetBodies()) do
        local data = body:GetData()

        if data and data.static then
            goto continue
        end

        if Addon.Libs.Matrix:GetSquaredDistance(body:GetPosition(), position) <= prohibitedDistanceSquared then
            return true
        end

        ::continue::
    end

    return false
end

--[[
    Returns a player's currently deployed physical interaction, if any.
]]
---@param player NoirPlayer The player to check
---@return PhysicalInteraction|nil
function Addon.PhysicalInteractions:GetPlayerDeployedInteraction(player)
    local interactions = self:GetPlayerPhysicalInteractions()[player.ID]

    if not interactions then
        return nil
    end

    for _, interaction in pairs(interactions) do
        if interaction:IsDeployed() then
            return interaction
        end
    end

    return nil
end