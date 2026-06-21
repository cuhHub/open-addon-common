--------------------------------------------------------
-- Classes - Supporter Perk
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
    A class representing a cuhHub supporter perk specific to the server this addon runs in.
]]
---@class SupporterPerk: NoirClass
---@field New fun(self: SupporterPerk, ID: string, name: string, description: string, supporterTier: APISupporterTierEnum): SupporterPerk
Addon.Classes.SupporterPerk = Noir.Class("SupporterPerk")

--[[
    Initializes new `SupporterPerk` instances.
]]
---@param ID string The ID of this perk
---@param name string The name of this perk
---@param description string The description of this perk
---@param supporterTier APISupporterTierEnum The supporter tier a player needs to access this perk
function Addon.Classes.SupporterPerk:Init(ID, name, description, supporterTier)
    --[[
        The ID of this perk.
    ]]
    self.ID = ID

    --[[
        The name of this perk.
    ]]
    self.Name = name

    --[[
        The description of this perk.
    ]]
    self.Description = description

    --[[
        The supporter tier a player needs to access this perk.
    ]]
    self.RequiredSupporterTier = supporterTier

    --[[
        A list of players who have this perk (peer ID as index).
    ]]
    ---@type table<integer, boolean>
    self._PlayersWithPerk = {}
end

--[[
    Returns if the provided supporter tier is greater than or equal to the required supporter tier.
]]
---@param supporterTier APISupporterTierEnum The supporter tier to check
function Addon.Classes.SupporterPerk:DoesSupporterTierMeetRequirement(supporterTier)
    return supporterTier == self.RequiredSupporterTier
end

--[[
    Returns if a player has this perk.
]]
---@param player NoirPlayer The player to check
---@return boolean
function Addon.Classes.SupporterPerk:DoesPlayerOwn(player)
    if self._PlayersWithPerk[player.ID] == nil then
        return false
    end

    return self._PlayersWithPerk[player.ID]
end

--[[
    Checks if the player has this perk.
]]
---@param player NoirPlayer The player to check
function Addon.Classes.SupporterPerk:CheckOwnership(player)
    Addon.API.Player:GetPlayerData(player, function(data)
        self._PlayersWithPerk[player.ID] = self:DoesSupporterTierMeetRequirement(data.SupporterTier)
    end)
end

--[[
    Removes a player from this perk. To be called on leave.
]]
---@param player NoirPlayer The player to remove
function Addon.Classes.SupporterPerk:_RemoveOwnershipRecognition(player)
    self._PlayersWithPerk[player.ID] = nil
end

--[[
    Formats this perk for text representation.
]]
---@return string
function Addon.Classes.SupporterPerk:Format()
    return ("%s: %s"):format(self.Name, self.Description)
end