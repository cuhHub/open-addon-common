--------------------------------------------------------
-- Libraries - Queue
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
    A library for creating queues.
]]
---@class Queue: NoirLibrary
Addon.Libs.Queue = Noir.Libraries:Create(
    "Queue",
    "A library for creating queues.",
    "A library for creating queues.",
    {"Cuh4"}
)

--[[
    Creates a queue.
]]
---@return Queue
function Addon.Libs.Queue:CreateQueue()
    return Addon.Classes.Queue:New()
end