--------------------------------------------------------
-- Classes - Weather Transition
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
    Stores the starting value and timing of a weather transition.
]]
---@class WeatherTransition: NoirClass
---@field New fun(self: WeatherTransition, startValue: number, startedAt: number, duration: number): WeatherTransition
Addon.Classes.WeatherTransition = Noir.Class("WeatherTransition")

--[[
    Initializes new `WeatherTransition` instances.
]]
---@param startValue number The weather value at the start of the transition
---@param startedAt number The start time in seconds
---@param duration number The transition duration in seconds
function Addon.Classes.WeatherTransition:Init(startValue, startedAt, duration)
    --[[
        The weather value at the start of the transition.
    ]]
    self.StartValue = startValue

    --[[
        The start time in seconds.
    ]]
    self.StartedAt = startedAt

    --[[
        The transition duration in seconds.
    ]]
    self.Duration = duration
end

--[[
    Returns the weather value at the start of the transition.
]]
---@return number
function Addon.Classes.WeatherTransition:GetStartValue()
    return self.StartValue
end

--[[
    Returns the start time in seconds.
]]
---@return number
function Addon.Classes.WeatherTransition:GetStartedAt()
    return self.StartedAt
end

--[[
    Returns the transition duration in seconds.
]]
---@return number
function Addon.Classes.WeatherTransition:GetDuration()
    return self.Duration
end