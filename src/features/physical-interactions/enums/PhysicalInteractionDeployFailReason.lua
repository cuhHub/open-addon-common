--------------------------------------------------------
-- Enums - Physical Interaction Deploy Fail Reason
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
    Represents why a physical interaction failed to deploy.
]]
Addon.Enums.PhysicalInteractionDeployFailReason = {
    None = 0,
    TooCloseToVehicle = 1,
    AlreadyDeployed = 2,
    NotSpawned = 3
}

--[[
    Represents why a physical interaction failed to deploy.
]]
---@alias PhysicalInteractionDeployFailReason
---| 0 # None
---| 1 # TooCloseToVehicle
---| 2 # AlreadyDeployed
---| 3 # NotSpawned