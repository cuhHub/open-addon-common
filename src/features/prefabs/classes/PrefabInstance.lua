--------------------------------------------------------
-- Classes - Prefab Instance
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
    Represents an instance created from a prefab.
]]
---@generic T: Prefab
---@class PrefabInstance<T>: NoirClass
---@field New fun(self: PrefabInstance<T>, prefab: T): PrefabInstance<T>
---@field Prefab T
---@field GetPrefab fun(self: PrefabInstance<T>): T
Addon.Classes.PrefabInstance = Noir.Class("PrefabInstance")

--[[
    Initializes new `PrefabInstance` instances.
]]
function Addon.Classes.PrefabInstance:Init(prefab)
    --[[
        The prefab this instance was created from.
    ]]
    self.Prefab = prefab
end

--[[
    Returns the prefab this instance was created from.
]]
function Addon.Classes.PrefabInstance:GetPrefab()
    return self.Prefab
end