--------------------------------------------------------
-- Classes - Physical Interaction Prefab
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
    A prefab for a physical interaction (e.g. inventory, call-in).<br>
    This is meant to be extended.
]]
---@class PhysicalInteractionPrefab: Prefab
---@field New fun(self: PhysicalInteractionPrefab, name: string, lifetime: number): PhysicalInteractionPrefab
Addon.Classes.PhysicalInteractionPrefab = Noir.Class("PhysicalInteractionPrefab", Addon.Classes.Prefab)

--[[
    Initializes new `PhysicalInteractionPrefab` instances.
]]
---@param name string The name of this physical interaction (e.g. "Inventory", "Call-In")
---@param lifetime number The lifetime in seconds until auto-retract
function Addon.Classes.PhysicalInteractionPrefab:Init(name, lifetime)
    self:InitFrom(
        Addon.Classes.Prefab,
        name
    )

    --[[
        The lifetime in seconds until auto-retract.
    ]]
    self.Lifetime = lifetime
end

--[[
    Returns the lifetime in seconds until auto-retract.
]]
---@return number
function Addon.Classes.PhysicalInteractionPrefab:GetLifetime()
    return self.Lifetime
end

--[[
    Returns the vehicle asset for this physical interaction.<br>
    *abstractmethod*
]]
---@return Asset
function Addon.Classes.PhysicalInteractionPrefab:GetAsset()
    error("Addon.Classes.PhysicalInteractionPrefab:GetAsset()", "Missing implementation.")
end

--[[
    Creates the physical interaction instance for a player.<br>
    *abstractmethod*
]]
---@param player NoirPlayer The player this interaction belongs to
---@return PhysicalInteraction
function Addon.Classes.PhysicalInteractionPrefab:Create(player)
    error("Addon.Classes.PhysicalInteractionPrefab:Create()", "Missing implementation.")
end