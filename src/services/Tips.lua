--------------------------------------------------------
-- Services - Tips
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
    A service that sends helpful tips periodically.
]]
---@class Tips: NoirService
Addon.Tips = Noir.Services:CreateService(
    "Tips",
    false,
    "A service that sends helpful tips periodically.",
    "A service that sends helpful tips periodically.",
    {"Cuh4"}
)

--[[
    Called when this service is initialized.
]]
function Addon.Tips:ServiceInit()
    --[[
        A table containing tips to randomly send periodically.
    ]]
    ---@type table<integer, string>
    self.Tips = {}

    --[[
        The last tip used to prevent repeats.
    ]]
    ---@type string
    self.LastTip = ""
end

--[[
    Called when this service is started.
]]
function Addon.Tips:ServiceStart()
    --[[
        A repeated task for sending tips.
    ]]
    self.TipSendTask = Noir.Services.TaskService:AddTimeTask(function()
        self:SendRandomTip()
    end, Config.Tips.SendInterval, nil, true)

    -- Create default tips
    self:RegisterTips({
        "The rules for cuhHub can be found @ "..Addon.API.cuhHubData.DiscordInviteURL..". Please read and follow them!",
        "Any player breaking the rules? Report them in the Discord @ "..Addon.API.cuhHubData.DiscordInviteURL.."!"
    })

    -- Create commands
    self:CreateCommands()
end

--[[
    Returns a random tip.
]]
---@return string
function Addon.Tips:GetRandomTip()
    local tip = Noir.Libraries.Table:Random(self.Tips) ---@type string

    if not tip then
        error("Addon.Tips:GetRandomTip()", "No tips registered")
    end

    if tip == self.LastTip then
        return self:GetRandomTip()
    end

    self.LastTip = tip
    return tip
end

--[[
    Sends a random tip
]]
---@param player NoirPlayer|nil The player to send it to, or nil for everyone
function Addon.Tips:SendRandomTip(player)
    if not player and Addon.Libs.Player:IsServerEmpty() then
        return
    end

    local tip = self:GetRandomTip()

    Addon.Message:SendNotification(
        player,
        "Tip",
        (player ~= nil and "[For You] " or "")..tip,
        Addon.Enums.NotificationType.INFO
    )

    if not player then
        Addon.API.Server:SendLiveChat(
            "Tip",
            tip,
            ":bulb:",
            227, 227, 111
        )
    end
end

--[[
    Registers the provided tips internally
]]
---@param tips table<integer, string> The tips to register
function Addon.Tips:RegisterTips(tips)
    self.Tips = Noir.Libraries.Table:Merge(self.Tips, tips)
end

--[[
    Creates all commands.
]]
function Addon.Tips:CreateCommands()
    Noir.Services.CommandService:CreateCommand(
        "tip",
        {"t"},
        false,
        false,
        false,
        "Sends a random helpful tip.",

        function(context)
            if not context.HasPermission then
                return
            end

            self:SendRandomTip(context.Player)
        end
    )
end