--------------------------------------------------------
-- Classes - Data Store Model
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
    A data store model representing data that can be persisted.
]]
---@class DataStoreModel: NoirClass
---@field New fun(self: DataStoreModel, version: integer, fields: table<integer, string>, settings: DataStoreModelSettings|nil): DataStoreModel
Addon.Classes.DataStoreModel = Noir.Class("DataStoreModel")

---@class IDataStoreModel: DataStoreModel
---@field New fun(self: IDataStoreModel): IDataStoreModel

--[[
    Represents settings for a data store model.
]]
---@class DataStoreModelSettings
---@field SaveOnPlayerLeave boolean|nil Whether to save the model when the player leaves
---@field SaveOnDestroy boolean|nil Whether to save the model when `onDestroy` event is fired

--[[
    Initializes new `DataStoreModel` instances.
]]
---@param version integer The version of the model
---@param fields table<integer, string> The fields that require saving
---@param settings DataStoreModelSettings|nil The settings to use
function Addon.Classes.DataStoreModel:Init(version, fields, settings)
    --[[
        The key of this model instance.
    ]]
    ---@type string
    self.Key = nil

    --[[
        The player behind this model instance.<br>
        Can be nil if this data was not loaded for a player.
    ]]
    ---@type NoirPlayer
    self.Player = nil

    --[[
        The settings for this model instance.
    ]]
    ---@type DataStoreModelSettings
    self.Settings = settings or {}

    --[[
        The fields of this model instance that can be persisted.
    ]]
    ---@type table<integer, string>
    self.Fields = Noir.Libraries.Table:Merge({
        "_Version"
    }, fields)

    --[[
        The version of this data store model instance.<br>
        This gets overwritten with whatever version gets loaded.<br>
        Can be nil in some scenarios (e.g. loaded data without `_Version`), so use `:GetVersion()` instead.
    ]]
    ---@type integer|nil
    self._Version = nil

    --[[
        The latest version of the data store model.
    ]]
    self._LatestVersion = version

    --[[
        Represents if we're in a `:WithSave()` scope.
    ]]
    self._SaveWrap = false

    --[[
        Represents if this instance has never been saved. A fresh start.
    ]]
    self._FirstTime = true

    self:Make()
end

--[[
    Constructs the model instance pre-load/first-time.
    *abstractmethod*
]]
function Addon.Classes.DataStoreModel:Make()
    error("Addon.Classes.DataStoreModel:Make()", "Must be implemented in subclass.")
end

--[[
    Returns if this model instance is freshly created and hasn't been saved before.
]]
---@return boolean
function Addon.Classes.DataStoreModel:IsFirstTime()
    return self._FirstTime
end

--[[
    Called when this model instance is loaded (data received and added to instance).
    This is a good place to handle migrations.
    *abstractmethod*
]]
function Addon.Classes.DataStoreModel:OnLoad() end

--[[
    Called after this model instance is loaded (data loaded, callbacks called, etc).<br>
    When this is called, the version of the model is set to the latest version.
    *abstractmethod*
]]
function Addon.Classes.DataStoreModel:OnPostLoad() end

--[[
    Loads a model instance for the provided player.
    *staticmethod*
]]
---@param player NoirPlayer The player to load the model for
---@param callback fun(data: DataStoreModel) The callback called when the model is fetched
function Addon.Classes.DataStoreModel:LoadPlayer(player, callback)
    return Addon.DataStores:LoadDataPlayer(self, player, callback) ---@diagnostic disable-line: param-type-mismatch
end

--[[
    Loads a model instance from a key.
    *staticmethod*
]]
---@param key string The key to load the model for
---@param callback fun(data: DataStoreModel) The callback called when the model is fetched
function Addon.Classes.DataStoreModel:Load(key, callback)
    return Addon.DataStores:LoadData(self, key, callback) ---@diagnostic disable-line: param-type-mismatch
end

--[[
    Sets the player behind this model instance.
]]
---@param player NoirPlayer The player to set
function Addon.Classes.DataStoreModel:_SetPlayer(player)
    self.Player = player
end

--[[
    Returns the player behind this model instance, if any.
]]
---@return NoirPlayer
function Addon.Classes.DataStoreModel:GetPlayer()
    return self.Player
end

--[[
    Sets the key of this model instance.
]]
---@param key string The key to set
function Addon.Classes.DataStoreModel:_SetKey(key)
    self.Key = key
end

--[[
    Handles migrations in the correct order.
]]
---@param migrations table<integer, DataStoreModelInstanceMigration> The migrations to run, keyed by version
function Addon.Classes.DataStoreModel:RunMigrations(migrations)
    ---@type table<integer, DataStoreModelInstanceMigration>
    local ordered = Noir.Libraries.Table:Copy(migrations)

    table.sort(ordered, function(a, b)
        return a:GetTargetVersion() < b:GetTargetVersion()
    end)

    for _, migration in ipairs(ordered) do
        self:RunMigration(migration)
    end
end

--[[
    Calls the callback function if the version is the same as provided, then sets the
    version to the one provided.
]]
---@param migration DataStoreModelInstanceMigration The migration to run
function Addon.Classes.DataStoreModel:RunMigration(migration)
    local currentVersion = self:GetVersion()
    local targetVersion = migration:GetTargetVersion()
    local migrationSummary = migration:GetSummary()

    if targetVersion <= currentVersion then -- already up-to-date
        return
    end

    if targetVersion > self._LatestVersion then
        error("Addon.Classes.DataStore:RunMigration()", "Bad migration, target version is higher than latest version. Migration: %s (key: %s)", migrationSummary, self.Key)
    end

    if targetVersion ~= currentVersion + 1 then -- ensure migrations are sequential
        error("Addon.Classes.DataStore:RunMigration()", "Bad migration, a version has been skipped. Migration: %s (key: %s)", migrationSummary, self.Key)
    end

    Addon.Logger:Info("DataStoreModel: Running migration for %s (migrating %s --> %s): %s", self.Key, currentVersion, targetVersion, migrationSummary)
    migration:Run()

    self:_SetVersion(targetVersion)
end

--[[
    Sets the version of this model instance.
]]
---@param version integer The version to set
function Addon.Classes.DataStoreModel:_SetVersion(version)
    self:WithSave(function()
        self._Version = version
    end)
end

--[[
    Returns the version of this model instance.
]]
---@return integer
function Addon.Classes.DataStoreModel:GetVersion()
    return self._Version or 1
end

--[[
    Returns the latest version of this model instance.
]]
---@return integer
function Addon.Classes.DataStoreModel:GetLatestVersion()
    return self._LatestVersion
end

--[[
    Saves this model instance.
]]
function Addon.Classes.DataStoreModel:Save()
    Addon.DataStores:SaveData(self)
end

--[[
    Unsaves this model instance.
]]
function Addon.Classes.DataStoreModel:Unsave()
    Addon.DataStores:UnsaveData(self)
end

--[[
    Saves the model instance after calling the callback.<br>
    Syntax sugar.
]]
---@param callback fun() The callback to call
function Addon.Classes.DataStoreModel:WithSave(callback)
    if self._SaveWrap then
        callback()
        return
    end

    self._SaveWrap = true

    callback()
    self:Save()

    self._SaveWrap = false
end

--[[
    Loads the model from saved data.
]]
---@param data table<string, any> The saved data
function Addon.Classes.DataStoreModel:_Load(data)
    for key, value in pairs(data) do -- `_Version` may not be provided if data is from before versioning was added
        if not Noir.Libraries.Table:Find(self.Fields, key) then
            Addon.Logger:Warning("Addon.Classes.DataStoreModel:InitFields(): Field '%s' is not apart of model %s. Adding anyway for potential migrations to handle.", key, self.ClassName)
        end

        self[key] = value
    end

    self._FirstTime = false
    self:OnLoad()
end

--[[
    Handles post load.
]]
function Addon.Classes.DataStoreModel:_PostLoad()
    self:_SetVersion(self:GetLatestVersion())
    self:OnPostLoad()
end

--[[
    Returns the fields for this model instance.
]]
---@return table<string, any>
function Addon.Classes.DataStoreModel:_GetFields()
    ---@type table<string, any>
    local fields = {}

    for _, field in pairs(self.Fields) do
        fields[field] = self[field]
    end

    return fields
end

--[[
    Converts the model to JSON.
]]
---@return string
function Addon.Classes.DataStoreModel:_GetJSONFields()
    return Noir.Libraries.JSON:Encode(self:_GetFields())
end

--[[
    Resets the model, using default values for the fields again.
]]
function Addon.Classes.DataStoreModel:Reset()
    self:WithSave(function()
        self:Make()
    end)
end