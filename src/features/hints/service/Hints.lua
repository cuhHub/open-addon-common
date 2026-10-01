--------------------------------------------------------
-- Services - Hints
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
    Provides an easy way of giving players hints during gameplay.
]]
---@class Hints: NoirService
Addon.Hints = Noir.Services:CreateService(
    "Hints",
    false,
    "Provides an easy way of giving players hints during gameplay.",
    "Provides an easy way of giving players hints during gameplay.",
    {"Cuh4"}
)

--[[
    Called when the service is initialized.
]]
function Addon.Hints:ServiceInit()
    --[[
        The hint cooldown key.
    ]]
    self.HINT_COOLDOWN_KEY_PREFIX = "hint_"
end

--[[
    Returns the cooldown key for a hint.
]]
---@param hintID string The hint ID to get the cooldown key for
---@return string
function Addon.Hints:GetHintCooldownKey(hintID)
    return self.HINT_COOLDOWN_KEY_PREFIX..hintID
end

--[[
    Returns if the hint is on cooldown for the palyer.
]]
---@param player NoirPlayer The player to check
---@param hintID string The hint ID to check
---@return boolean
function Addon.Hints:IsHintOnCooldown(player, hintID)
    return Addon.Cooldowns:GetPlayerCooldown(
        player,
        self:GetHintCooldownKey(hintID)
    ) ~= nil
end

--[[
    Places a hint on cooldown for a player.
]]
---@param player NoirPlayer The player to place the hint on cooldown for
---@param hintID string The hint ID to place on cooldown
function Addon.Hints:PlaceHintOnCooldown(player, hintID)
    Addon.Cooldowns:CreatePlayerCooldown(
        player,
        self:GetHintCooldownKey(hintID),
        Config.Hints.HintCooldown
    )
end

--[[
    Sends an hint to the player.
]]
---@param player NoirPlayer The player to send the hint to
---@param title string The title of the hint
---@param content string The content of the hint
function Addon.Hints:_SendHint(player, title, content)
    Addon.Message:Send(
        player,
        ("%s [Hint]"):format(title),
        content,
        Addon.Enums.NotificationType.INFO
    )
end

--[[
    Sends an hint to the player if it's not on cooldown.
]]
---@param player NoirPlayer The player to send the hint to
---@param hintID string The hint ID to send
---@param title string The title of the hint
---@param content string The content of the hint
function Addon.Hints:TrySendHint(player, hintID, title, content)
    if self:IsHintOnCooldown(player, hintID) then
        return
    end

    self:_SendHint(player, title, content)
    self:PlaceHintOnCooldown(player, hintID)

    Addon.Logger:Info("Hints: Sending hint '%s' to player %s (%s)", hintID, player.Name, player.Steam)
end