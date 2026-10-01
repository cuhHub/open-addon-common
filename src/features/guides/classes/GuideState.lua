--------------------------------------------------------
-- Classes - Guide State
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
    Represents a player's state for their current guide (if any).
]]
---@class GuideState: NoirClass
---@field New fun(self: GuideState, player: NoirPlayer): GuideState
Addon.Classes.GuideState = Noir.Class("GuideState")

--[[
    Initializes new `GuideState` instances.
]]
---@param player NoirPlayer The player this is for
function Addon.Classes.GuideState:Init(player)
    --[[
        The player this is for.
    ]]
    self.Player = player

    --[[
        The guide the player is on.
    ]]
    ---@type Guide|nil
    self.Guide = nil

    --[[
        The index of the message in the guide the player is on.
    ]]
    ---@type integer
    self.MessageIndex = 1

    --[[
        The screen popup containing the current guide message/
    ]]
    ---@type NoirScreenPopupWidget
    self.MessagePopup = nil
end

--[[
    Performs setup (UI creation, etc).
]]
function Addon.Classes.GuideState:Setup()
    self.MessagePopup = Noir.Services.UIService:CreateScreenPopup(
        "",
        0,
        0,
        false,
        self:GetPlayer()
    )

    Addon.Janitor:DisposeWidget(self:GetMessagePopup())
end

--[[
    Returns the message popup widget.
]]
---@return NoirScreenPopupWidget
function Addon.Classes.GuideState:GetMessagePopup()
    return self.MessagePopup
end

--[[
    Returns the player this is for.
]]
---@return NoirPlayer
function Addon.Classes.GuideState:GetPlayer()
    return self.Player
end

--[[
    Returns the current message index.
]]
---@return integer
function Addon.Classes.GuideState:GetMessageIndex()
    return self.MessageIndex
end

--[[
    Returns the current guide.
]]
---@return Guide|nil
function Addon.Classes.GuideState:GetGuide()
    return self.Guide
end

--[[
    Returns if a guide is active.
]]
---@return boolean
function Addon.Classes.GuideState:HasGuide()
    return self:GetGuide() ~= nil
end

--[[
    Returns if the player has reached the end of the guide.
]]
---@return boolean
function Addon.Classes.GuideState:HasReachedEndOfGuide()
    if not self:HasGuide() then
        error("Addon.Classes.GuideState:HasReachedEndOfGuide()", "No guide is active.")
    end

    return self.MessageIndex >= #self:GetGuide():GetMessages()
end

--[[
    Returns the current guide message.
]]
---@return GuideMessage
function Addon.Classes.GuideState:GetCurrentMessage()
    if not self:HasGuide() then
        error("Addon.Classes.GuideState:GetCurrentMessage()", "No guide is active.")
    end

    return self:GetGuide():GetMessage(self:GetMessageIndex())
end

--[[
    Sets the current message index.
]]
---@param index integer The index of the message
function Addon.Classes.GuideState:SetMessageIndex(index)
    self.MessageIndex = index
end

--[[
    Starts a guide.
]]
---@param guide Guide The guide to start
function Addon.Classes.GuideState:StartGuide(guide)
    if self:HasGuide() then
        error("Addon.Classes.GuideState:StartGuide()", "A guide is already active.")
    end

    local player = self:GetPlayer()

    if Addon.Prompts:HasPrompt(player) then -- prevent ui conflict
        Addon.Prompts:RemovePrompt(player)
    end

    self.Guide = guide
    self:SetMessageIndex(1)

    self.MessagePopup.Visible = true
    self.MessagePopup:Update()

    self:SendCurrentMessage()

    guide:HandleOnStart(player)
end

--[[
    Ends the current guide.
]]
---@param reason GuideEndReason The reason for ending the guide
function Addon.Classes.GuideState:EndGuide(reason)
    if not self:HasGuide() then
        error("Addon.Classes.GuideState:EndGuide()", "No guide is active.")
    end

    local player = self:GetPlayer()

    self.MessagePopup.Visible = false
    self.MessagePopup:Update()

    self.Guide:HandleOnEnd(player, reason)

    if reason == Addon.Enums.GuideEndReason.Cancelled then
        Addon.Message:Send(
            player,
            "Guide",
            "You have cancelled the guide.",
            Addon.Enums.NotificationType.ERROR
        )
    elseif reason == Addon.Enums.GuideEndReason.Finished then
        Addon.Message:Send(
            player,
            "Guide",
            "You have finished the guide!",
            Addon.Enums.NotificationType.SUCCESS
        )
    end

    self.Guide = nil
    self:SetMessageIndex(1)
end

--[[
    Finishes the current guide.
]]
function Addon.Classes.GuideState:Finish()
    self:EndGuide(Addon.Enums.GuideEndReason.Finished)
end

--[[
    Cancels the current guide.
]]
function Addon.Classes.GuideState:Cancel()
    self:EndGuide(Addon.Enums.GuideEndReason.Cancelled)
end

--[[
    Goes to the next message in the current guide,
    or completes the guide if no next.
]]
function Addon.Classes.GuideState:Next()
    if not self:HasGuide() then
        error("Addon.Classes.GuideState:Next()", "No guide is active.")
    end

    if self:HasReachedEndOfGuide() then
        self:Finish()
        return
    end

    self:SetMessageIndex(self:GetMessageIndex() + 1)
    self:SendCurrentMessage()
end

--[[
    Sends the current message in the current guide.
]]
function Addon.Classes.GuideState:SendCurrentMessage()
    if not self:HasGuide() then
        error("Addon.Classes.GuideState:SendCurrentMessage()", "No guide is active.")
    end

    local message = self:GetCurrentMessage():GetContent()
    local index = self:GetMessageIndex()
    local messageCount = self:GetGuide():GetMessageCount()

    self.MessagePopup.Text = table.concat({
        ("Guide (%s/%s)"):format(index, messageCount),
        "---",
        message,
        "---",
        "Type '?gcancel' to cancel.",
        "Type '?gnext' to continue."
    }, "\n")

    self.MessagePopup:Update()

    Addon.Message:SendNotification(
        self:GetPlayer(),
        ("Guide (%s/%s)"):format(index, messageCount),
        table.concat({
            message,
            "----------------",
            "Type '?gcancel' to cancel the guide.",
            "Type '?gnext' to continue the guide."
        }, "\n"),
        Addon.Enums.NotificationType.INFO
    )
end