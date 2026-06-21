--------------------------------------------------------
-- Services - Prompts
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
    A service for showing on-screen prompts to the player.
]]
---@class Prompts: NoirService
Addon.Prompts = Noir.Services:CreateService(
    "Prompts",
    false,
    "A service for showing on-screen prompts to the player.",
    "A service for showing on-screen prompts to the player.",
    {"Cuh4"}
)

--[[
    Called when the service is initialized.
]]
function Addon.Prompts:ServiceInit()
    --[[
        Per-player prompts, indexed by peer ID.
    ]]
    ---@type table<integer, Prompt>
    self.Prompts = {}
end

--[[
    Called when the service is started.
]]
function Addon.Prompts:ServiceStart()
    --[[
        A connection to `PlayerService`'s `OnLeave` event.
    ]]
    ---@param player NoirPlayer
    self.OnLeaveConnection = Noir.Services.PlayerService.OnLeave:Connect(function(player)
        if not self:GetPrompt(player) then
            return
        end

        self:RemovePrompt(player)
    end)

    self:CreateCommands()
end

--[[
    Creates a prompt.
]]
---@param name string The name of the prompt
---@param text string The text of the prompt
---@param player NoirPlayer The player the prompt is for
---@return Prompt
function Addon.Prompts:CreatePrompt(name, text, player)
    if self:GetPrompt(player) then
        self:RemovePrompt(player)
    end

    local prompt = Addon.Classes.Prompt:New(name, text, player)
    prompt:Setup()

    self.Prompts[player.ID] = prompt

    return prompt
end

--[[
    Returns the active prompt for the player, if any.
]]
---@param player NoirPlayer The player to check
---@return Prompt|nil
function Addon.Prompts:GetPrompt(player)
    return self.Prompts[player.ID]
end

--[[
    Removes a prompt for a player.
]]
---@param player NoirPlayer The player to remove
function Addon.Prompts:RemovePrompt(player)
    local prompt = self:GetPrompt(player)

    if not prompt then
        error("Addon.Prompts:RemovePrompt()", "Player has no active prompt")
    end

    prompt:Cleanup()
    self.Prompts[player.ID] = nil
end

--[[
    Creates commands.
]]
function Addon.Prompts:CreateCommands()
    Noir.Services.CommandService:CreateCommand(
        "dismiss",
        {"dis"},
        false,
        false,
        false,
        "Dismisses the on-screen prompt, if any.",

        function(context)
            if not context.HasPermission then
                return
            end

            local prompt = self:GetPrompt(context.Player)

            if not prompt then
                return
            end

            prompt:Dismiss()
            self:RemovePrompt(context.Player)
        end
    )
end