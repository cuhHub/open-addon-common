--------------------------------------------------------
-- Services - Supporter Perks
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
    A service for handling cuhHub supporter perks.
]]
---@class SupporterPerks: NoirService
Addon.SupporterPerks = Noir.Services:CreateService(
    "SupporterPerks",
    false,
    "A service for handling cuhHub supporter perks.",
    "A service for handling cuhHub supporter perks.",
    {"Cuh4"}
)

--[[
    Called when this service is initialized.
]]
function Addon.SupporterPerks:ServiceInit()
    --[[
        A table of all created perks in this addon.
    ]]
    ---@type table<string, SupporterPerk>
    self.Perks = {}

    --[[
        How long to wait (in seconds) before presenting perks.<br>
        This is in place because the Bridge addon takes a bit to send an introduction message<br>
        due to HTTP requests being performed beforehand.
    ]]
    self.PERK_PRESENTATION_DELAY = 5
end

--[[
    Called when this service is started.
]]
function Addon.SupporterPerks:ServiceStart()
    --[[
        Connection to `PlayerService`'s `OnJoin` event
    ]]
    ---@param player NoirPlayer
    self._OnJoinConnection = Noir.Services.PlayerService.OnJoin:Connect(function(player)
        self:CheckPerksOwnership(player)

        Noir.Services.TaskService:AddTimeTask(function()
            self:PresentPerks(player)
        end, self.PERK_PRESENTATION_DELAY)
    end)

    Addon.API:RunWhenReady(function()
        for _, player in pairs(Noir.Services.PlayerService:GetPlayers(true)) do
            self:CheckPerksOwnership(player)
        end
    end)

    --[[
        Connection to `PlayerService`'s `OnLeave` event
    ]]
    ---@param player NoirPlayer
    self._OnLeaveConnection = Noir.Services.PlayerService.OnLeave:Connect(function(player)
        self:_RemovePerkOwnershipRecognition(player)
    end)
end

--[[
    Creates a perk.
]]
---@param ID string The ID of this perk
---@param name string The name of this perk
---@param description string The description of this perk
---@param supporterTier APISupporterTierEnum The supporter tier a player needs to access this perk
---@return SupporterPerk
function Addon.SupporterPerks:CreatePerk(ID, name, description, supporterTier)
    local perk = Addon.Classes.SupporterPerk:New(ID, name, description, supporterTier)
    self.Perks[ID] = perk

    return perk
end

--[[
    Returns the perk with the provided ID.
]]
---@param ID string The ID of the perk to get
---@return SupporterPerk
function Addon.SupporterPerks:GetPerk(ID)
    return self:GetPerks()[ID]
end

--[[
    Returns all perks.
]]
---@return table<string, SupporterPerk>
function Addon.SupporterPerks:GetPerks()
    return self.Perks
end

--[[
    Returns all perks in sequential order rather than a dictionary-like table.
]]
---@return table<integer, SupporterPerk>
function Addon.SupporterPerks:GetPerksInOrder()
    ---@type table<integer, SupporterPerk>
    return Noir.Libraries.Table:Values(self:GetPerks())
end

--[[
    Checks for ownership of all perks.
]]
---@param player NoirPlayer The player to check
function Addon.SupporterPerks:CheckPerksOwnership(player)
    for _, perk in pairs(self:GetPerks()) do
        perk:CheckOwnership(player)
    end
end

--[[
    Removes perk ownership recognition.
]]
---@param player NoirPlayer The player to check
function Addon.SupporterPerks:_RemovePerkOwnershipRecognition(player)
    for _, perk in pairs(self:GetPerks()) do
        perk:_RemoveOwnershipRecognition(player)
    end
end

--[[
    Returns all perks a player has.
]]
---@param player NoirPlayer The player to get perks for
---@return table<integer, SupporterPerk>
function Addon.SupporterPerks:GetPerksForPlayer(player)
    ---@type table<integer, SupporterPerk>
    local perks = {}

    for _, perk in pairs(self:GetPerks()) do
        if perk:DoesPlayerOwn(player) then
            table.insert(perks, perk)
        end
    end

    return perks
end

--[[
    Presents the perks a player has. Should be called a bit after joining.<br>
    If they have no perks, no message is sent.
]]
---@param player NoirPlayer The player to present their perks to
function Addon.SupporterPerks:PresentPerks(player)
    local perks = self:GetPerksForPlayer(player)

    if #perks <= 0 then
        return
    end

    local formattedPerks = {}

    for _, perk in pairs(perks) do
        table.insert(formattedPerks, perk:Format())
    end

    Addon.Message:Send(
        player,
        "Supporter Perks",
        "Thanks for supporting cuhHub! Thanks to your support, you now have access to the following perks:\n"..Addon.Libs.String:BulletList(formattedPerks, "*"),
        Addon.Enums.NotificationType.INFO
    )
end