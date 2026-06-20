--------------------------------------------------------
-- Classes - TPS Measurement Process
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
    A class for measuring TPS over time.
]]
---@class TPSMeasurementProcess: NoirClass
---@field New fun(self: TPSMeasurementProcess, ID: integer, duration: integer): TPSMeasurementProcess
Addon.Classes.TPSMeasurementProcess = Noir.Class("TPSMeasurementProcess")

--[[
    Initializes `TPSMeasurementProcess` class instances.
]]
---@param ID integer The ID of this TPS measurement process
---@param duration integer The duration to measure TPS over (seconds)
function Addon.Classes.TPSMeasurementProcess:Init(ID, duration)
    --[[
        The ID of this TPS measurement process.
    ]]
    self.ID = ID

    --[[
        The duration in seconds.
    ]]
    self.Duration = duration

    --[[
        The time the measurement started.
    ]]
    self.StartedAt = Noir.Services.TaskService:GetTimeSeconds()

    --[[
        The TPS measurements.
    ]]
    ---@type table<integer, integer>
    self.Measurements = {}

    --[[
        The event fired when the measurement is complete.<br>
        Arguments: averageTPS (number)
    ]]
    self.OnComplete = Noir.Libraries.Events:Create()

    --[[
        Whether or not the measurement is complete.
    ]]
    self.IsComplete = false

    --[[
        The max allowed measurements.
    ]]
    self.MAX_MEASUREMENTS = Config.Perf.MaxMeasurementsForTPSMeasurementProcesses
end

--[[
    Inserts a new measurement.
]]
function Addon.Classes.TPSMeasurementProcess:InsertMeasurement()
    table.insert(self.Measurements, Noir.Services.TPSService:GetTPS())
end

--[[
    Pops the first measurement.
]]
function Addon.Classes.TPSMeasurementProcess:PopMeasurement()
    table.remove(self.Measurements, 1)
end

--[[
    Updates the measurement.
]]
function Addon.Classes.TPSMeasurementProcess:Tick()
    if self:IsOver() then
        self:Complete()
        return
    end

    self:InsertMeasurement()

    if #self.Measurements > self.MAX_MEASUREMENTS then
        self:PopMeasurement()
    end
end

--[[
    Returns if we've overstayed our welcome (duration passed).
]]
---@return boolean
function Addon.Classes.TPSMeasurementProcess:IsOver()
    if self.IsComplete then
        return true
    end

    return (Noir.Services.TaskService:GetTimeSeconds() - self.StartedAt) >= self.Duration
end

--[[
    Completes the measurement.
]]
function Addon.Classes.TPSMeasurementProcess:Complete()
    self.IsComplete = true

    local average = Noir.Libraries.Number:Average(self.Measurements)
    self.OnComplete:Fire(average)
end