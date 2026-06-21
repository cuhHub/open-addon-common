--------------------------------------------------------
-- Services - Perf
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
    A service for performance-related utilities.
]]
---@class Perf: NoirService
Addon.Perf = Noir.Services:CreateService(
    "Perf",
    false,
    "A service for performance-related utilities.",
    "A service for performance-related utilities.",
    {"Cuh4"}
)

--[[
    Called when this service is initialized.
]]
function Addon.Perf:ServiceInit()
    --[[
        TPS measurement processes.
    ]]
    ---@type table<integer, TPSMeasurementProcess>
    self.TPSMeasurementProcesses = {}
end

--[[
    Called when the service is started.
]]
function Addon.Perf:ServiceStart()
    --[[
        A task to update TPS measurement processes.
    ]]
    self.TPSMeasurementUpdateTask = Noir.Services.TaskService:AddTickTask(function()
        for _, TPSMeasurementProcess in pairs(self:GetTPSMeasurementProcesses()) do
            TPSMeasurementProcess:Tick()
        end
    end, 1, nil, true)
end

--[[
    Measures the average TPS over time, and returns the complete average.
]]
---@param duration number The duration to measure over
---@param callback fun(averageTPS: number) The callback to run when complete
---@return TPSMeasurementProcess
function Addon.Perf:MeasureAverageTPSOver(duration, callback)
    local ID = Addon.ID:GetID()

    local TPSMeasurementProcess = Addon.Classes.TPSMeasurementProcess:New(ID, duration)

    TPSMeasurementProcess.OnComplete:Once(function(...)
        self:RemoveTPSMeasurementProcess(TPSMeasurementProcess)
        callback(...)
    end)

    self.TPSMeasurementProcesses[ID] = TPSMeasurementProcess

    return TPSMeasurementProcess
end

--[[
    Returns the TPS measurement processes.
]]
---@return table<integer, TPSMeasurementProcess>
function Addon.Perf:GetTPSMeasurementProcesses()
    return self.TPSMeasurementProcesses
end

--[[
    Removes a TPS measurement process.
]]
---@param TPSMeasurementProcess TPSMeasurementProcess The TPS measurement process to remove
function Addon.Perf:RemoveTPSMeasurementProcess(TPSMeasurementProcess)
    self.TPSMeasurementProcesses[TPSMeasurementProcess.ID] = nil
end