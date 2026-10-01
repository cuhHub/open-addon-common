--------------------------------------------------------
-- Services - Guides
--------------------------------------------------------

--[[
    Copyright (C) 2026 cuhHub - All Rights Reserved
    - Unauthorized copying of this file, via any medium is strictly prohibited
    - Proprietary and confidential
]]

-------------------------------
-- // Main
-------------------------------

--[[
    Handles text-based guides for players.
]]
---@class Guides: NoirService
Addon.Guides = Noir.Services:CreateService(
    "Guides",
    false,
    "Handles text-based guides for players.",
    "Handles text-based guides for players.",
    {"Cuh4"}
)

--[[
    Called when the service is initialized.
]]
function Addon.Guides:ServiceInit()
    --[[
        A table of registered guides.
    ]]
    ---@type table<string, Guide>
    self.Guides = {}

    --[[
        A table of player guide states, indexed by peer ID.
    ]]
    ---@type table<integer, GuideState>
    self.GuideStates = {}
end

--[[
    Called when the service is started.
]]
function Addon.Guides:ServiceStart()
    --[[
        A connection to `PlayerService`'s `OnJoin` event.
    ]]
    ---@param player NoirPlayer
    self.OnJoinConnection = Noir.Services.PlayerService.OnJoin:Connect(function(player)
        self:CreateGuideState(player)
    end)

    --[[
        A connection to `PlayerService`'s `OnLeave` event.
    ]]
    ---@param player NoirPlayer
    self.OnLeaveConnection = Noir.Services.PlayerService.OnLeave:Connect(function(player)
        self:RemoveGuideState(player)
    end)

    for _, player in pairs(Noir.Services.PlayerService:GetPlayers(true)) do
        self:CreateGuideState(player)
    end

    self:CreateCommands()
end

--[[
    Creates a guide.
]]
---@param ID string The ID of the guide
---@param name string The name of the guide
---@param command string The command to start the guide
---@param messages table<integer, string> The messages in the guide
---@return Guide
function Addon.Guides:RegisterGuide(ID, name, command, messages)
    local guide = Addon.Classes.Guide:New(
        ID,
        name,
        command,
        Noir.Libraries.Table:Map(messages, function(index, value)
            return Addon.Classes.GuideMessage:New(value)
        end)
    )

    self.Guides[ID] = guide
    Addon.Logger:Info("Guides: Registered guide with ID %s and name %s (cmd: '?%s')", ID, name, command)

    return guide
end

--[[
    Returns all guides.
]]
---@return table<string, Guide>
function Addon.Guides:GetGuides()
    return self.Guides
end

--[[
    Returns a guide by its ID.
]]
---@param ID string The ID of the guide
---@return Guide
function Addon.Guides:GetGuide(ID)
    return self.Guides[ID]
end

--[[
    Creates the guide state for a player.
]]
---@param player NoirPlayer The player
---@return GuideState
function Addon.Guides:CreateGuideState(player)
    local state = Addon.Classes.GuideState:New(player)
    state:Setup()

    self.GuideStates[player.ID] = state

    Addon.Logger:Info("Guides: Created guide state for player %s (%s)", player.Name, player.Steam)

    return state
end

--[[
    Returns all guide states, indexed by peer ID.
]]
---@return table<integer, GuideState>
function Addon.Guides:GetGuideStates()
    return self.GuideStates
end

--[[
    Returns the guide state for a player.
]]
---@param player NoirPlayer The player
---@return GuideState
function Addon.Guides:GetGuideState(player)
    return self:GetGuideStates()[player.ID]
end

--[[
    Removes a guide state for a player.
]]
---@param player NoirPlayer The player
function Addon.Guides:RemoveGuideState(player)
    self.GuideStates[player.ID] = nil
end

--[[
    Creates all commands.
]]
function Addon.Guides:CreateCommands()
    Noir.Services.CommandService:CreateCommand(
        "gnext",
        {"gn"},
        false,
        false,
        false,
        "Continues the current guide.",

        function(context)
            if not context.HasPermission then
                return
            end

            local state = self:GetGuideState(context.Player)

            if not state then
                return -- should never happen
            end

            if not state:HasGuide() then
                Addon.Message:Send(
                    context.Player,
                    "Guide",
                    "You have no guide active.",
                    Addon.Enums.NotificationType.ERROR
                )

                return
            end

            state:Next()
        end
    )

    Noir.Services.CommandService:CreateCommand(
        "gcancel",
        {"gc"},
        false,
        false,
        false,
        "Cancels the current guide.",

        function(context)
            if not context.HasPermission then
                return
            end

            local state = self:GetGuideState(context.Player)

            if not state then
                return -- should never happen
            end

            if not state:HasGuide() then
                Addon.Message:Send(
                    context.Player,
                    "Guide",
                    "You have no guide active.",
                    Addon.Enums.NotificationType.ERROR
                )

                return
            end

            state:Cancel()
        end
    )
end