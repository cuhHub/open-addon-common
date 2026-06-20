--------------------------------------------------------
-- Classes - Data Store Model Instance Migration
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
    A class representing a data store model instance migration.
]]
---@class DataStoreModelInstanceMigration: NoirClass
---@field New fun(self: DataStoreModelInstanceMigration, summary: string, to: integer|nil, callback: fun()): DataStoreModelInstanceMigration
Addon.Classes.DataStoreModelInstanceMigration = Noir.Class("DataStoreModelInstanceMigration")

--[[
    Initialises class instances.
]]
---@param summary string The migration summary for logging
---@param to integer The version this migration migrates to
---@param callback fun() The migration callback
function Addon.Classes.DataStoreModelInstanceMigration:Init(summary, to, callback)
    --[[
        The migration summary for logging.
    ]]
    self.Summary = summary

    --[[
        The version this migration migrates to.
    ]]
    self.TargetVersion = to

    --[[
        The migration callback.
    ]]
    self.Callback = callback
end

--[[
    Returns the migration summary.
]]
---@return string
function Addon.Classes.DataStoreModelInstanceMigration:GetSummary()
    return self.Summary
end

--[[
    Returns the version this migration migrates to.
]]
---@return integer
function Addon.Classes.DataStoreModelInstanceMigration:GetTargetVersion()
    return self.TargetVersion
end

--[[
    Runs the migration.
]]
function Addon.Classes.DataStoreModelInstanceMigration:Run()
    self.Callback()
end