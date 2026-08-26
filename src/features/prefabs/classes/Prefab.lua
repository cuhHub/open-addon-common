--------------------------------------------------------
-- Classes - Prefab
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
    Represents a prefab.
]]
---@class Prefab: NoirClass
---@field New fun(self: Prefab, name: string): Prefab
Addon.Classes.Prefab = Noir.Class("Prefab")

--[[
    Initializes new `Prefab` instances.
]]
---@param name string The name of this prefab
function Addon.Classes.Prefab:Init(name)
    --[[
        The name of this prefab.
    ]]
    self.Name = name
end

--[[
    Returns the name.
]]
---@return string
function Addon.Classes.Prefab:GetName()
    return self.Name
end

--[[
    Creates an instance of the prefab.<br>
    This method is abstract and must be overridden (should return a class instance that inherits from `PrefabInstance`).
]]
---@return PrefabInstance
function Addon.Classes.Prefab:Create()
    error("Addon.Classes.Prefab:CreateInstance()", "This method is abstract and must be overridden.")
end

---@alias AnyPrefab
---| WeightedPrefab
---| Prefab