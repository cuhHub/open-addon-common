--------------------------------------------------------
-- Enums - Slot Type
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
    Enum for item slot types.
]]
Addon.Enums.SlotType = {
    Small = 0,  -- Small slot type
    Large = 1,  -- Large slot type
    Outfit = 2  -- Outfit slot type
}

--[[
    Represents an item slot type.
]]
---@alias SlotTypeEnum
---| 0 # Small
---| 1 # Large
---| 2 # Outfit