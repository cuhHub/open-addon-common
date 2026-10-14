--------------------------------------------------------
-- Enums - Stream Type
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
    Represents the type of streaming for a streamable.
]]
Addon.Enums.StreamType = {
    StreamInOnly = 0,
    StreamInStreamOut = 1
}

--[[
    Represents the type of streaming for a streamable.
]]
---@alias StreamType
---| 0 # StreamInOnly
---| 1 # StreamInStreamOut