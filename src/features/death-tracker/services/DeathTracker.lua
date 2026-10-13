--------------------------------------------------------
-- Services - DeathTracker
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
    Stores and tracks player deaths.<br>
    Useful for getting accurate position of death on player respawn.
]]
---@class DeathTracker: NoirService
Addon.DeathTracker = Noir.Services:CreateService(
    "DeathTracker",
    false,
    "Stores and tracks player deaths.",
    "Stores and tracks player deaths.",
    {"Cuh4"}
)

--[[
    Called when the service is initialized.
]]
function Addon.DeathTracker:ServiceInit()
    --[[
        Storres death data, indexed by peer ID.
    ]]
    ---@type table<integer, Death>
    self.Deaths = {}
end

--[[
    Called when the service is started.
]]
function Addon.DeathTracker:ServiceStart()
    --[[
        A connection to `PlayerService`'s `OnDie` event.
    ]]
    ---@param player NoirPlayer
    self.OnPlayerDieConnection = Noir.Services.PlayerService.OnDie:Connect(function(player)
        self:TrackDeath(player)
    end)

    --[[
        A connection to `PlayerService`'s `OnRespawn` event.
    ]]
    ---@param player NoirPlayer
    self.OnPlayerRespawnConnection = Noir.Services.PlayerService.OnRespawn:Connect(function(player)
        Noir.Services.TaskService:AddTickTask(function() -- to let other areas of addon to get track data on respawn
            self:UntrackDeath(player)
        end, 1)
    end)

    --[[
        A connection to `PlayerService`'s `OnLeave` event.
    ]]
    ---@param player NoirPlayer
    self.OnPlayerLeaveConnection = Noir.Services.PlayerService.OnLeave:Connect(function(player)
        self:UntrackDeath(player)
    end)
end

--[[
    Tracks a player's death.
]]
---@param player NoirPlayer The player to track
function Addon.DeathTracker:TrackDeath(player)
    local death = Addon.Classes.Death:New(player)
    death:Setup()

    self.Deaths[player.ID] = death

    Addon.Logger:Info("DeathTracker: Tracked death of %s", Addon.Libs.Player:FormatPlayerName(player))
end

--[[
    Gets a player's death data.
]]
---@param player NoirPlayer The player to get data for
---@return Death|nil
function Addon.DeathTracker:GetDeath(player)
    return self.Deaths[player.ID]
end

--[[
    Untracks a player's death.
]]
---@param player NoirPlayer The player to untrack
function Addon.DeathTracker:UntrackDeath(player)
    self.Deaths[player.ID] = nil
end