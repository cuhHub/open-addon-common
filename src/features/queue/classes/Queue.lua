--------------------------------------------------------
-- Classes - Queue
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
    First-in first-out queue data structure.
]]
---@generic T
---@class Queue<T>: NoirClass
---@field New fun(self: Queue<T>): Queue<T>
---@field Values table<integer, T> The values in the queue
---@field GetValues fun(self: Queue): table<integer, T> Returns the values in the queue
---@field Get fun(self: Queue): T|nil Returns first value in the queue, or nil if the queue is empty
---@field Add fun(self: Queue, value: T) Adds a value to the queue
Addon.Classes.Queue = Noir.Class("Queue")

--[[
    Initializes new `Queue` instances.
]]
function Addon.Classes.Queue:Init()
    --[[
        The values in the queue.
    ]]
    self.Values = {}
end

--[[
    Returns the values in the queue.
]]
function Addon.Classes.Queue:GetValues()
    return self.Values
end

--[[
    Returns the first value in the queue.
]]
function Addon.Classes.Queue:Get()
    return self.Values[1]
end

--[[
    Adds a value to the queue.
]]
function Addon.Classes.Queue:Add(value)
    table.insert(self.Values, value)
end

--[[
    Returns if the queue is empty.
]]
---@return boolean
function Addon.Classes.Queue:Empty()
    return #self:GetValues() <= 0
end

--[[
    Pops the first value from the queue.
]]
function Addon.Classes.Queue:Pop()
    if self:Empty() then
        error("Addon.Classes.Queue:Pop()", "Queue is empty")
    end

    table.remove(self.Values, 1)
end