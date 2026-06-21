--------------------------------------------------------
-- Classes - Request
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
    A callback for a request.
]]
---@alias RequestCallback fun(response: RequestResponse)

--[[
    A class representing a request from one player to another.
]]
---@class Request: NoirClass
---@field New fun(self: Request, name: string, query: string, sender: NoirPlayer, recipient: NoirPlayer): Request
Addon.Classes.Request = Noir.Class("Request")

--[[
    Initializes `Request` class instances.
]]
---@param name string The name of the request
---@param query string The query for the request
---@param sender NoirPlayer The sender of the request
---@param recipient NoirPlayer The recipient of the request
function Addon.Classes.Request:Init(name, query, sender, recipient)
    --[[
        The name of this request.
    ]]
    self.Name = name

    --[[
        The query of this request.
    ]]
    self.Query = query

    --[[
        The player who sent the request.
    ]]
    self.Sender = sender

    --[[
        The player who received the request.
    ]]
    self.Recipient = recipient

    --[[
        The event for this request.<br>
        Arguments: response (RequestResponse)
    ]]
    self.OnTrigger = Noir.Libraries.Events:Create()

    --[[
        The closet for this confirmation.
    ]]
    self.Closet = Addon.Janitor:CreateCloset()
end

--[[
    Triggers the event for this request.
]]
---@param response RequestResponse The response to the request
function Addon.Classes.Request:Trigger(response)
    if response == Addon.Enums.RequestResponse.Accepted then
        -- to recipient
        Addon.Message:Send(
            self.Recipient,
            "Request: "..self.Name,
            "You have accepted %s's request.",
            Addon.Enums.NotificationType.INFO,
            Addon.Libs.Player:FormatPlayerName(self.Sender)
        )

        -- to sender
        Addon.Message:Send(
            self.Sender,
            "Request: "..self.Name,
            "%s has accepted your request.",
            Addon.Enums.NotificationType.INFO,
            Addon.Libs.Player:FormatPlayerName(self.Recipient)
        )
    elseif response == Addon.Enums.RequestResponse.Declined then
        -- to recipient
        Addon.Message:Send(
            self.Recipient,
            "Request: "..self.Name,
            "You have declined %s's request.",
            Addon.Enums.NotificationType.INFO,
            Addon.Libs.Player:FormatPlayerName(self.Sender)
        )

        -- to sender
        Addon.Message:Send(
            self.Sender,
            "Request: "..self.Name,
            "%s has declined your request.",
            Addon.Enums.NotificationType.INFO,
            Addon.Libs.Player:FormatPlayerName(self.Recipient)
        )
    elseif response == Addon.Enums.RequestResponse.Cancelled then
        -- to sender
        Addon.Message:Send(
            self.Sender,
            "Request: "..self.Name,
            "Your request has been cancelled.",
            Addon.Enums.NotificationType.INFO
        )
    elseif response == Addon.Enums.RequestResponse.Busy then
        -- to sender
        Addon.Message:Send(
            self.Sender,
            "Request: "..self.Name,
            "%s already has an incoming request. Try again later.",
            Addon.Enums.NotificationType.INFO,
            Addon.Libs.Player:FormatPlayerName(self.Recipient)
        )
    end

    self.OnTrigger:Fire(response)
end

--[[
    Cancels the request due to business.
]]
function Addon.Classes.Request:CancelDueToBusy()
    self:Trigger(Addon.Enums.RequestResponse.Busy)
end

--[[
    Accepts the request.
]]
function Addon.Classes.Request:Accept()
    self:Trigger(Addon.Enums.RequestResponse.Accepted)
end

--[[
    Declines the request.
]]
function Addon.Classes.Request:Decline()
    self:Trigger(Addon.Enums.RequestResponse.Declined)
end

--[[
    Cancels the request.
]]
function Addon.Classes.Request:Cancel()
    self:Trigger(Addon.Enums.RequestResponse.Cancelled)
end

--[[
    Listens for request.
]]
---@param callback RequestCallback The trigger callback
function Addon.Classes.Request:Listen(callback)
    self.OnTrigger:Connect(callback)
end

--[[
    Sends the request message.
]]
function Addon.Classes.Request:Send()
    Addon.Message:Send(
        self.Sender,
        "Request: "..self.Name,
        "A request has been sent to %s.",
        Addon.Enums.NotificationType.INFO,
        Addon.Libs.Player:FormatPlayerName(self.Recipient)
    )

    Addon.Message:Send(
        self.Recipient,
        "Request: "..self.Name,
        table.concat({
            self.Query,
            ("From: %s"):format(Addon.Libs.Player:FormatPlayerName(self.Sender)),
            "-------------",
            "Type any of the below commands in chat to respond:",
            "'?accept' to accept (or '?acc')",
            "'?decline' to decline (or '?dec')"
        }, "\n"),
        Addon.Enums.NotificationType.INFO
    )
end

--[[
    Cleans up the request after finish.
]]
function Addon.Classes.Request:Cleanup()
    self.Closet:Cleanup()
end