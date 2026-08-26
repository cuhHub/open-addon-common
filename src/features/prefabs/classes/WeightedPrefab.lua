--------------------------------------------------------
-- Classes - Weighted Prefab
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
    Represents a prefab that has an RNG weight associated with it.
]]
---@class WeightedPrefab: Prefab
---@field New fun(self: WeightedPrefab, name: string, weight: number): WeightedPrefab
Addon.Classes.WeightedPrefab = Noir.Class("WeightedPrefab", Addon.Classes.Prefab)

--[[
    Initializes new `WeightedPrefab` instances.
]]
---@param name string The name of this prefab
---@param weight number The weight for this prefab to be picked with RNG
function Addon.Classes.WeightedPrefab:Init(name, weight)
    self:InitFrom(Addon.Classes.Prefab, name)

    --[[
        The weight for this prefab to be picked with RNG.
    ]]
    self.Weight = weight
end

--[[
    Returns the weight.
]]
---@return number
function Addon.Classes.WeightedPrefab:GetWeight()
    return self.Weight
end