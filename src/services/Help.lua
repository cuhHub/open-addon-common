--------------------------------------------------------
-- Services - Help
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
    A service for helping players, providing a help command, etc.
]]
---@class Help: NoirService
Addon.Help = Noir.Services:CreateService(
    "Help",
    false,
    "A service for helping players, providing a help command, etc.",
    "A service for helping players, providing a help command which shows all commands, etc.",
    {"Cuh4"}
)

Addon.Help.StartPriority = 1000 -- ensure this service starts last so all commands are registered before the help command is created

--[[
    Called when this service is started.
]]
function Addon.Help:ServiceStart()
    --[[
        A table containing commands and their descriptions.
    ]]
    ---@type table<integer, string>
    self.Commands = self:GetCommandList()

    -- Create commands
    self:CreateCommands()

    -- Create UI
    self:CreateUI()

    Addon.Tips:RegisterTips({
        "Type '?help' in chat to see a list of commands, as well as server information.",
        ("Confused? Check out the website at cuhhub.com for any tutorials and FAQs, or join the Discord at %s and ask for help!"):format(Addon.API.cuhHubData.DiscordInviteURL)
    })
end

--[[
    Loads all commands and formats them for display.
]]
---@return table<integer, string>
function Addon.Help:GetCommandList()
    local commands = {}

    for _, command in pairs(Noir.Services.CommandService:GetCommands()) do
        if not command.RequiresAdmin then
            local formatted = Config.Help.CommandFormat:gsub("$NAME", command.Name)
            formatted = formatted:gsub("$ALIASES", table.concat(command.Aliases, ", ?"))
            formatted = formatted:gsub("$DESCRIPTION", command.Description)

            table.insert(commands, formatted)
        end
    end

    return commands
end

--[[
    Creates UI.
]]
function Addon.Help:CreateUI()
    Addon.UI.GlobalUIHook:Connect(function()
        ---@type NoirScreenPopupWidget
        local widget = Addon.UI:WrapWidget("Help", Noir.Services.UIService:CreateScreenPopup(
            "Use \"?help\" for a list of commands.",
            -0.9,
            0,
            true
        ))

        widget:Update()
    end)
end

--[[
    Creates all commands.
]]
function Addon.Help:CreateCommands()
    Noir.Services.CommandService:CreateCommand(
        "help",
        {"h"},
        false,
        false,
        false,
        "Shows a list of commands.",

        function(context)
            if not context.HasPermission then
                return
            end

            Addon.Libs.Commands:HandlePaginateList(context, "Commands", self.Commands, Config.Help.CommandsPerPage, nil, function(message)
                return ("Server Description:\n%s\n\n%s"):format(
                    Addon.API.Server.ServerData.Description,
                    message
                )
            end)
        end
    )
end