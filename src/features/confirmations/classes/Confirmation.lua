--------------------------------------------------------
-- Classes - Confirmation
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
    A callback for a confirmation.
]]
---@alias ConfirmationCallback fun(response: ConfirmationResponse)

--[[
    A class representing a confirmation ("do you want to proceed?" type stuff).
]]
---@class Confirmation: NoirClass
---@field New fun(self: Confirmation, name: string, query: string, player: NoirPlayer): Confirmation
Addon.Classes.Confirmation = Noir.Class("Confirmation")

--[[
    Initializes `Confirmation` class instances.
]]
---@param name string The name of the confirmation
---@param query string The query of the confirmation
---@param player NoirPlayer The player the confirmation is for
function Addon.Classes.Confirmation:Init(name, query, player)
    --[[
        The name of this confirmation.
    ]]
    self.Name = name

    --[[
        The query of this confirmation.
    ]]
    self.Query = query

    --[[
        The player this confirmation is for.
    ]]
    self.Player = player

    --[[
        The callback for this confirmation.
    ]]
    ---@type ConfirmationCallback
    self.Callback = nil

    --[[
        The closet for this confirmation.
    ]]
    self.Closet = Addon.Janitor:CreateCloset()
end

--[[
    Triggers the callback.
]]
---@param response ConfirmationResponse The response to the confirmation
function Addon.Classes.Confirmation:Trigger(response)
    if not self.Callback then
        return
    end

    self.Callback(response)
end

--[[
    Confirms the confirmation.
]]
function Addon.Classes.Confirmation:Confirm()
    self:Trigger(Addon.Enums.ConfirmationResponse.Confirmed)
end

--[[
    Denies the confirmation.
]]
function Addon.Classes.Confirmation:Deny()
    self:Trigger(Addon.Enums.ConfirmationResponse.Denied)
end

--[[
    Cancels the confirmation.
]]
function Addon.Classes.Confirmation:Cancel()
    self:Trigger(Addon.Enums.ConfirmationResponse.Cancelled)
end

--[[
    Listens for confirmation.
]]
---@param callback ConfirmationCallback The listener callback
function Addon.Classes.Confirmation:Listen(callback)
    self.Callback = callback
end

--[[
    Sends the confirmation message.
]]
function Addon.Classes.Confirmation:Send()
    Addon.Message:Send(
        self.Player,
        "Confirm: "..self.Name,
        table.concat({
            self.Query,
            "-------------",
            "Type any of the below commands in chat to respond:",
            "'?confirm' to confirm (or '?con')",
            "'?deny' to deny (or '?den')"
        }, "\n"),
        Addon.Enums.NotificationType.INFO
    )
end

--[[
    Cleans up this instance.
]]
function Addon.Classes.Confirmation:Cleanup()
    self.Closet:Cleanup()
end