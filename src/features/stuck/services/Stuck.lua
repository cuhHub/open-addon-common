--------------------------------------------------------
-- Services - Stuck
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
    A service to help players who are physically stuck (e.g. under map).
]]
---@class Stuck: NoirService
Addon.Stuck = Noir.Services:CreateService(
    "Stuck",
    false,
    "A service to help players who are physically stuck (e.g. under map).",
    "A service to help players who are physically stuck (e.g. under map).",
    {"Cuh4"}
)

--[[
    Called when the service is initialized.
]]
function Addon.Stuck:ServiceInit()
    --[[
        How many meters to teleport the player up when trying to unstuck.
    ]]
    self.UNSTUCK_TELEPORT_OFFSET_Y = 10

    --[[
        The unstuck cooldown key.
    ]]
    self.UNSTUCK_COOLDOWN_KEY = "unstuck"

    --[[
        The unstuck cooldown duration.
    ]]
    self.UNSTUCK_COOLDOWN_DURATION = Config.Stuck.UnstuckCooldown
end

--[[
    Called when the service is started.
]]
function Addon.Stuck:ServiceStart()
    self:RegisterTips()
    self:CreateCommansd()
end

--[[
    Unstucks a player by teleporting them up.
]]
---@param player NoirPlayer The player to unstuck
function Addon.Stuck:Unstuck(player)
    local position = player:GetPosition()
    player:Teleport(matrix.multiply(position, matrix.translation(0, self.UNSTUCK_TELEPORT_OFFSET_Y, 0)))

    Addon.Message:Send(
        player,
        "Unstuck",
        "You have been teleported %.0fm up to unstuck you.",
        Addon.Enums.NotificationType.SUCCESS,
        self.UNSTUCK_TELEPORT_OFFSET_Y
    )
end

--[[
    Unstucks a player, but with cooldown logic.
]]
---@param player NoirPlayer The player to unstuck
function Addon.Stuck:TryUnstuck(player)
    if Addon.Cooldowns:HandlePlayerCooldown(player, self.UNSTUCK_COOLDOWN_KEY, self.UNSTUCK_COOLDOWN_DURATION) then
        Addon.Message:Send(
            player,
            "Unstuck",
            "This action is on cooldown. Try again later!",
            Addon.Enums.NotificationType.ERROR
        )

        return
    end

    self:Unstuck(player)
end

--[[
    Registers tips.
]]
function Addon.Stuck:RegisterTips()
    Addon.Tips:RegisterTips({
        "Fallen under the map? Stuck? Use '?stuck' while under low terrain to unstuck yourself."
    })
end

--[[
    Creates commands.
]]
function Addon.Stuck:CreateCommansd()
    Noir.Services.CommandService:CreateCommand(
        "stuck",
        {"st"},
        false,
        false,
        false,
        "Teleports you up to un-stuck yourself.",

        function(context)
            if not context.HasPermission then
                return
            end

            self:TryUnstuck(context.Player)
        end
    )
end