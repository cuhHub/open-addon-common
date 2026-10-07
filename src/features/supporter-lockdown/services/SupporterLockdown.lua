--------------------------------------------------------
-- Services - Supporter Lockdown
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
    A service to restrict the server to supporters only.<br>
    TODO: implement backend server flag for this, then let API feature handle this in Bridge addon (responsibility toggleable in config.lua)
]]
---@class SupporterLockdown: NoirService
Addon.SupporterLockdown = Noir.Services:CreateService(
    "SupporterLockdown",
    false,
    "A service to restrict the server to supporters only.",
    "A service to restrict the server to supporters only.",
    {"Cuh4"}
)

--[[
    Called when the service is started.
]]
function Addon.SupporterLockdown:ServiceStart()
    --[[
        A connection to `PlayerService`'s `OnJoin` event.
    ]]
    ---@param player NoirPlayer
    self.OnJoinConnection = Noir.Services.PlayerService.OnJoin:Connect(function(player)
        self:CanPlayerJoin(player, function(allowed)
            if allowed then
                return
            end

            local formattedPlayerName = Addon.Libs.Player:FormatPlayerName(player)

            player:Kick()

            Addon.Message:Send(
                nil,
                "Supporters Only",
                "%s was kicked as the server is locked to supporters only.",
                Addon.Enums.NotificationType.ERROR,
                formattedPlayerName
            )

            Addon.API.Server:SendLiveChat(
                "Supporters Only",
                ("%s was kicked as the server is locked to supporters only."):format(formattedPlayerName),
                ":closed_lock_with_key:",
                255,
                0,
                0
            )
        end)
    end)
end

--[[
    Whether or not the server is locked to supporters only.
]]
---@return boolean
function Addon.SupporterLockdown:IsLocked()
    return Config.SupporterLockdown.Enabled
end

--[[
    Returns if the tier is allowed.
]]
---@param tier APISupporterTierEnum The tier to check
---@return boolean
function Addon.SupporterLockdown:IsTierAllowed(tier)
    return Noir.Libraries.Table:Find(Config.SupporterLockdown.WhitelistedTiers, tier) ~= nil
end

--[[
    Checks if a player is allowed to join.
]]
---@param player NoirPlayer The player to check
---@param callback fun(allowed: boolean) The callback called when the check is complete
function Addon.SupporterLockdown:CanPlayerJoin(player, callback)
    if not self:IsLocked() then
        callback(true)
        return
    end

    Addon.API.Player:GetPlayerData(player, function(data)
        callback(self:IsTierAllowed(data.SupporterTier))
    end)
end