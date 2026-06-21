--------------------------------------------------------
-- Classes - Prompt
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
    A class representing a prompt ("Check this out" type stuff).
]]
---@class Prompt: NoirClass
---@field New fun(self: Prompt, name: string, text: string, player: NoirPlayer): Prompt
Addon.Classes.Prompt = Noir.Class("Prompt")

--[[
    Initializes `Prompt` class instances.
]]
---@param name string The name of the prompt
---@param text string The text of the prompt
---@param player NoirPlayer The player the prompt is for
function Addon.Classes.Prompt:Init(name, text, player)
    --[[
        The name of this prompt.
    ]]
    self.Name = name

    --[[
        The text of this prompt.
    ]]
    self.Text = text

    --[[
        The player this prompt is for.
    ]]
    self.Player = player

    --[[
        The prompt screen popup widget.
    ]]
    ---@type NoirScreenPopupWidget
    self.ScreenPopupWidget = nil

    --[[
        The closet for this prompt.
    ]]
    self.Closet = Addon.Janitor:CreateCloset()
end

--[[
    Sets up the prompt.
]]
function Addon.Classes.Prompt:Setup()
    self:Send()
    self:CreateUI()
end

--[[
    Sends the prompt message.
]]
function Addon.Classes.Prompt:Send()
    Addon.Message:Send(
        self.Player,
        self.Name,
        table.concat({
            self.Text,
            "-------------",
            "Type '?dismiss' to dismiss this prompt (or '?dis')"
        }, "\n"),
        Addon.Enums.NotificationType.INFO
    )
end

--[[
    Creates the prompt UI.
]]
function Addon.Classes.Prompt:CreateUI()
    self.ScreenPopupWidget = Noir.Services.UIService:CreateScreenPopup(
        table.concat({
            self.Name,
            "---",
            self.Text,
            "---",
            "Type '?dis' in chat to dismiss"
        }, "\n"),
        0,
        0,
        true,
        self.Player
    )

    Addon.Janitor:DisposeWidget(self.ScreenPopupWidget)
    self.Closet:Add(self.ScreenPopupWidget)
end

--[[
    Dismisses the prompt.
]]
function Addon.Classes.Prompt:Dismiss()
    self:Cleanup()
end

--[[
    Cleans up this instance.
]]
function Addon.Classes.Prompt:Cleanup()
    self.Closet:Cleanup()
end