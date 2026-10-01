--------------------------------------------------------
-- Classes - Guide
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
    A class representing a text-based guide.
]]
---@class Guide: NoirClass
---@field New fun(self: Guide, ID: string, name: string, command: string, messages: table<integer, GuideMessage>): Guide
Addon.Classes.Guide = Noir.Class("Guide")

--[[
    Initializes new `Guide` instances.
]]
---@param ID string The ID of the guide
---@param name string The name of the guide
---@param command string The command to start this guide
---@param messages table<integer, GuideMessage> The messages in the guide
function Addon.Classes.Guide:Init(ID, name, command, messages)
    --[[
        The ID of the guide.
    ]]
    self.ID = ID

    --[[
        The name of the guide.
    ]]
    self.Name = name

    --[[
        The command string to start this guide.
    ]]
    self.Command = command

    --[[
        The messages in the guide.
    ]]
    self.Messages = messages

    --[[
        An event fired when a player starts this guide.<br>
        Arguments: player (NoirPlayer)
    ]]
    self.OnStart = Noir.Libraries.Events:Create()

    --[[
        An event fired when a player ends this guide.<br>
        Arguments: player (NoirPlayer), reason (GuideEndReason)
    ]]
    self.OnEnd = Noir.Libraries.Events:Create()
end

--[[
    Sets up the guide (creates commands, registers tips, etc.).
]]
function Addon.Classes.Guide:Setup()
    local command = self:GetCommand()
    local name = self:GetName()

    Noir.Services.CommandService:CreateCommand(
        command,
        {},
        false,
        false,
        false,
        ("Starts the '%s' guide."):format(name),

        function(context)
            if not context.HasPermission then
                return
            end

            local state = Addon.Guides:GetGuideState(context.Player)

            if state:HasGuide() then
                Addon.Message:Send(
                    context.Player,
                    "Guide",
                    "You already have a guide active.",
                    Addon.Enums.NotificationType.ERROR
                )

                return
            end

            state:StartGuide(self)
        end
    )

    Addon.Tips:RegisterTips({
        ("Type '?%s' to start the '%s' guide."):format(command, name),
    })
end

--[[
    Returns the ID of the guide.
]]
---@return string
function Addon.Classes.Guide:GetID()
    return self.ID
end

--[[
    Returns the name of the guide.
]]
---@return string
function Addon.Classes.Guide:GetName()
    return self.Name
end

--[[
    Returns the command string to start the guide.
]]
---@return string
function Addon.Classes.Guide:GetCommand()
    return self.Command
end

--[[
    Returns the messages in the guide.
]]
---@return table<integer, GuideMessage>
function Addon.Classes.Guide:GetMessages()
    return self.Messages
end

--[[
    Returns the message at the provided index.
]]
---@param index integer The index of the message
---@return GuideMessage
function Addon.Classes.Guide:GetMessage(index)
    local message = self:GetMessages()[index]

    if not message then
        error("Addon.Classes.Guide:GetMessage()", "No message at index %s", index)
    end

    return message
end

--[[
    Returns if the provided message index is the last message in the guide.
]]
---@param index integer The index of the message
---@return boolean
function Addon.Classes.Guide:IsLastMessage(index)
    return index >= self:GetMessageCount()
end

--[[
    Returns the message count.
]]
---@return integer
function Addon.Classes.Guide:GetMessageCount()
    return #self:GetMessages()
end

--[[
    Performs logic for when a player starts this guide.
]]
---@param player NoirPlayer The player starting the guide
function Addon.Classes.Guide:HandleOnStart(player)
    self.OnStart:Fire(player)
end

--[[
    Performs logic for when a player ends this guide.
]]
---@param player NoirPlayer The player ending the guide
---@param reason GuideEndReason The reason the guide was ended
function Addon.Classes.Guide:HandleOnEnd(player, reason)
    self.OnEnd:Fire(player, reason)
end