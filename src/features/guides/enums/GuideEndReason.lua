--------------------------------------------------------
-- Enums - Guide End Reason
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
    Represents the reason a guide was ended by a player.
]]
Addon.Enums.GuideEndReason = {
    None = 0,
    Cancelled = 1,
    Finished = 2
}

--[[
    Represents the reason a guide was ended by a player.
]]
---@alias GuideEndReason
---| 0 # None
---| 1 # Cancelled
---| 2 # Finished