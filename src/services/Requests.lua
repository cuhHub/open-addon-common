--------------------------------------------------------
-- Services - Requests
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
    A service for managing player-to-player requests.
]]
---@class Requests: NoirService
Addon.Requests = Noir.Services:CreateService(
    "Requests",
    false,
    "A service for managing player-to-player requests.",
    "A service for managing player-to-player requests.",
    {"Cuh4"}
)

--[[
    Called when the service is initialized.
]]
function Addon.Requests:ServiceInit()
    --[[
        Per-player requests, indexed by recipient peer ID.
    ]]
    ---@type table<integer, Request>
    self.Requests = {}
end

--[[
    Called when the service is started.
]]
function Addon.Requests:ServiceStart()
    --[[
        A connection to `PlayerService`'s `OnLeave` event.
    ]]
    ---@param player NoirPlayer
    self.OnLeaveConnection = Noir.Services.PlayerService.OnLeave:Connect(function(player)
        if not self:HasIncomingRequest(player) then
            return
        end

        self:RemoveIncomingRequest(player)
    end)

    self:CreateCommands()
end

--[[
    Creates a request.
]]
---@param name string The name of the request
---@param query string The query for the request
---@param sender NoirPlayer The sender of the request
---@param recipient NoirPlayer The recipient of the request
---@param callback RequestCallback The callback for the request
---@return Request
function Addon.Requests:CreateRequest(name, query, sender, recipient, callback)
    if Noir.Services.PlayerService:IsSamePlayer(sender, recipient) then
        error("Addon.Requests:CreateRequest()", "Sender and recipient cannot be the same player")
    end

    local request = Addon.Classes.Request:New(name, query, sender, recipient)

    request:Listen(function(response)
        callback(response)
        self:RemoveIncomingRequest(recipient)
    end)

    if self:HasIncomingRequest(recipient) then
        request:CancelDueToBusy()
        return request
    end

    request:Send()

    request.Closet:Add(Noir.Services.TaskService:AddTimeTask(function()
        self:RemoveIncomingRequest(recipient, true)
    end, Config.Requests.Timeout))

    self.Requests[recipient.ID] = request

    return request
end

--[[
    Returns the incoming request for the player, if any.
]]
---@param player NoirPlayer The player to check
---@return Request|nil
function Addon.Requests:GetIncomingRequest(player)
    return self.Requests[player.ID]
end

--[[
    Returns if the player has an incoming request.
]]
---@param player NoirPlayer The player to check
---@return boolean
function Addon.Requests:HasIncomingRequest(player)
    return self:GetIncomingRequest(player) ~= nil
end

--[[
    Removes the incoming request for a player.
]]
---@param player NoirPlayer The player to remove the request for (recipient of request)
---@param withCancel boolean|nil Whether or not to cancel the request before removing it
function Addon.Requests:RemoveIncomingRequest(player, withCancel)
    local request = self:GetIncomingRequest(player)

    if not request then
        error("Addon.Requests:RemoveIncomingRequest()", "Player has no active request")
    end

    if withCancel then
        request:Cancel()
    end

    request:Cleanup()
    self.Requests[player.ID] = nil
end

--[[
    Creates commands.
]]
function Addon.Requests:CreateCommands()
    Noir.Services.CommandService:CreateCommand(
        "accept",
        {"acc"},
        false,
        false,
        false,
        "Accepts any incoming request.",

        function(context)
            if not context.HasPermission then
                return
            end

            local request = self:GetIncomingRequest(context.Player)

            if not request then
                return
            end

            request:Accept()
        end
    )

    Noir.Services.CommandService:CreateCommand(
        "decline",
        {"dec"},
        false,
        false,
        false,
        "Declines any incoming request.",

        function(context)
            if not context.HasPermission then
                return
            end

            local request = self:GetIncomingRequest(context.Player)

            if not request then
                return
            end

            request:Decline()
        end
    )
end