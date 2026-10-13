--------------------------------------------------------
-- Classes - Death
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
    Represents a player's death info (where they died, etc.).
]]
---@class Death: NoirClass
---@field New fun(self: Death, player: NoirPlayer): Death
Addon.Classes.Death = Noir.Class("Death")

--[[
    Initializes new `Death` instances.
]]
---@param player NoirPlayer The player who died
function Addon.Classes.Death:Init(player)
    --[[
        The player who died.
    ]]
    self.Player = player

    --[[
        The position they died at.
    ]]
    self.Position = matrix.identity()

    --[[
        The time they died at.
    ]]
    self.Time = 0
end

--[[
    Returns the player who died.
]]
---@return NoirPlayer
function Addon.Classes.Death:GetPlayer()
    return self.Player
end

--[[
    Returns the position of death.
]]
---@return SWMatrix
function Addon.Classes.Death:GetPosition()
    return self.Position
end

--[[
    Returns the time of death.
]]
---@return number
function Addon.Classes.Death:GetTimeOfDeath()
    return self.Time
end

--[[
    Sets up the death.
]]
function Addon.Classes.Death:Setup()
    self.Position = self.Player:GetPosition()
    self.Time = Noir.Services.TaskService:GetTimeSeconds()
end