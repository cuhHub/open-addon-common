--------------------------------------------------------
-- Services - Confirmations
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
    A service for managing the typical "Are you sure you want to do this?".
]]
---@class Confirmations: NoirService
Addon.Confirmations = Noir.Services:CreateService(
    "Confirmations",
    false,
    "A service for managing the typical \"Are you sure you want to do this?\".",
    "A service for managing the typical \"Are you sure you want to do this?\".",
    {"Cuh4"}
)

--[[
    Called when the service is initialized.
]]
function Addon.Confirmations:ServiceInit()
    --[[
        Per-player confirmations, indexed by peer ID.
    ]]
    ---@type table<integer, Confirmation>
    self.Confirmations = {}
end

--[[
    Called when the service is started.
]]
function Addon.Confirmations:ServiceStart()
    --[[
        A connection to `PlayerService`'s `OnLeave` event.
    ]]
    ---@param player NoirPlayer
    self.OnLeaveConnection = Noir.Services.PlayerService.OnLeave:Connect(function(player)
        if not self:GetActiveConfirmation(player) then
            return
        end

        self:RemoveConfirmation(player)
    end)

    self:CreateCommands()
end

--[[
    Creates a confirmation.
]]
---@param name string The name of the confirmation
---@param query string What to ask the player
---@param player NoirPlayer The player the confirmation is for
---@param callback ConfirmationCallback The callback for the confirmation
---@return Confirmation
function Addon.Confirmations:CreateConfirmation(name, query, player, callback)
    if self:GetActiveConfirmation(player) then
        self:RemoveConfirmation(player, true)
    end

    local confirmation = Addon.Classes.Confirmation:New(name, query, player)

    confirmation:Listen(function(response)
        callback(response)
        self:RemoveConfirmation(player)
    end)

    confirmation:Send()

    confirmation.Closet:Add(Noir.Services.TaskService:AddTimeTask(function()
        self:RemoveConfirmation(player, true)
    end, Config.Confirmations.Timeout))

    self.Confirmations[player.ID] = confirmation

    return confirmation
end

--[[
    Returns the active confirmation for the player, if any.
]]
---@param player NoirPlayer The player to check
---@return Confirmation|nil
function Addon.Confirmations:GetActiveConfirmation(player)
    return self.Confirmations[player.ID]
end

--[[
    Removes a confirmation for a player.
]]
---@param player NoirPlayer The player to remove
---@param withCancel boolean|nil Whether or not to cancel the confirmation
function Addon.Confirmations:RemoveConfirmation(player, withCancel)
    local confirmation = self:GetActiveConfirmation(player)

    if not confirmation then
        error("Addon.Confirmations:RemoveConfirmation()", "Player has no active confirmation")
    end

    if withCancel then
        confirmation:Cancel()
    end

    confirmation:Cleanup()
    self.Confirmations[player.ID] = nil
end

--[[
    Creates commands.
]]
function Addon.Confirmations:CreateCommands()
    Noir.Services.CommandService:CreateCommand(
        "confirm",
        {"con"},
        false,
        false,
        false,
        "Confirms the active confirmation.",

        function(context)
            if not context.HasPermission then
                return
            end

            local confirmation = self:GetActiveConfirmation(context.Player)

            if not confirmation then
                return
            end

            confirmation:Confirm()
        end
    )

    Noir.Services.CommandService:CreateCommand(
        "deny",
        {"den"},
        false,
        false,
        false,
        "Denies the active confirmation.",

        function(context)
            if not context.HasPermission then
                return
            end

            local confirmation = self:GetActiveConfirmation(context.Player)

            if not confirmation then
                return
            end

            confirmation:Deny()
        end
    )
end