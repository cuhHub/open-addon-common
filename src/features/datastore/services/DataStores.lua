--------------------------------------------------------
-- Services - Data Stores
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
    A high-level wrapper around API persistent data service.
]]
---@class DataStores: NoirService
Addon.DataStores = Noir.Services:CreateService(
    "DataStores",
    false,
    "A high level wrapper around API persistent data service.",
    "A high level wrapper around API persistent data service.",
    {"Cuh4"}
)

--[[
    Called when the service is initialized.
]]
function Addon.DataStores:ServiceInit()
    --[[
        Datastore models instances indexed by key.
    ]]
    ---@type table<string, DataStoreModel>
    self.ModelInstances = {}
end

--[[
    Called when the service is started.
]]
function Addon.DataStores:ServiceStart()
    --[[
        A connection to `PlayerService`'s `OnLeave` event.
    ]]
    ---@param player NoirPlayer
    self.OnLeaveConnection = Noir.Services.PlayerService.OnLeave:Connect(function(player)
        for _, model in pairs(self:GetPlayerModelInstances(player)) do
            self:_RemoveModelInstance(model)

            if not model.Settings.SaveOnPlayerLeave then
                goto continue
            end

            model:Save()

            ::continue::
        end
    end)

    --[[
        A connection to `OnDestroy`.
    ]]
    self.OnDestroyConnection = Noir.Callbacks:Connect("onDestroy", function()
        for _, model in pairs(self:GetModelInstances()) do
            self:_RemoveModelInstance(model)

            if not model.Settings.SaveOnDestroy then
                goto continue
            end

            model:Save()

            ::continue::
        end
    end)
end

--[[
    Returns all model instances.
]]
---@return table<string, DataStoreModel>
function Addon.DataStores:GetModelInstances()
    return self.ModelInstances
end

--[[
    Returns a model instance from cache by key.
]]
---@param key string The key in the database
---@return DataStoreModel|nil
function Addon.DataStores:_GetModelInstance(key)
    return self.ModelInstances[key]
end

--[[
    Adds a model instance to cache.
]]
---@param model DataStoreModel The model instance
function Addon.DataStores:_AddModelInstance(model)
    self.ModelInstances[model.Key] = model
end

--[[
    Removes a model instance from cache.
]]
---@param model DataStoreModel The model instance
function Addon.DataStores:_RemoveModelInstance(model)
    self.ModelInstances[model.Key] = nil
end

--[[
    Returns all model instances linked to a player.
]]
---@param player NoirPlayer The player to check for
---@return table<integer, DataStoreModel>
function Addon.DataStores:GetPlayerModelInstances(player)
    ---@type table<integer, DataStoreModel>
    local found = {}

    for _, model in pairs(self.ModelInstances) do
        local modelPlayer = model:GetPlayer()

        if modelPlayer and Noir.Services.PlayerService:IsSamePlayer(modelPlayer, player) then
            table.insert(found, model)
        end
    end

    return found
end

--[[
    Returns a key from a model and a key.
]]
---@param model DataStoreModel The model to use
---@param key string The key in the database
---@return string
function Addon.DataStores:GetKey(model, key)
    return Addon.API.Server.ServerData.ID.."_"..model.ClassName.."_"..key
end

--[[
    Loads data from the provided key and the provided model.
]]
---@param model IDataStoreModel The model to use
---@param key string The key in the database
---@param callback fun(data: DataStoreModel) The callback called when the data is fetched
---@param _player NoirPlayer|nil The player to assign the created model instance to, or nil if unneeded
function Addon.DataStores:LoadData(model, key, callback, _player)
    -- TODO: refactor this horseshit

    key = self:GetKey(model, key)
    Addon.Logger:Info("DataStores: Loading data for key %s", key)

    local cached = self:_GetModelInstance(key)

    if cached then
        Addon.Logger:Debug("DataStores: Got cache hit for key %s, using cached instead", key)
        callback(cached)

        return
    end

    Addon.API.PersistentData:GetData(key, function(data)
        local modelInstance = model:New()
        modelInstance:_SetKey(key)

        if _player then
            modelInstance:_SetPlayer(_player)
        end

        self:_AddModelInstance(modelInstance)

        if not data then
            Addon.Logger:Debug("DataStores: No data found for key %s, using empty model and saving", key)

            modelInstance:Save()
            callback(modelInstance)

            return
        end

        local decoded = Noir.Libraries.JSON:Decode(data.Value)

        if not decoded then
            Addon.Logger:Error("DataStores: Failed to JSON decode persisted data at key %s. Got: %s", key, data)
            return
        end

        Addon.Logger:Info("DataStores: Loaded data for key %s, got: %s", key, data.Value)

        modelInstance:_Load(decoded)
        callback(modelInstance)
        modelInstance:_PostLoad()
    end)
end

--[[
    Loads data from a player and the provided model.
]]
---@param model IDataStoreModel The model to use
---@param player NoirPlayer The player to load data for
---@param callback fun(data: DataStoreModel) The callback called when the data is fetched
function Addon.DataStores:LoadDataPlayer(model, player, callback)
    self:LoadData(model, player.Steam, callback, player)
end

--[[
    Saves the provided model instance.
]]
---@param model DataStoreModel The model to save
function Addon.DataStores:SaveData(model)
    Addon.Logger:Info("DataStores: Saving data for key %s with data: %s", model.Key, model:_GetJSONFields())
    Addon.API.PersistentData:SaveData(model.Key, model:_GetJSONFields())
end

--[[
    Unsaves the provided model instance.
]]
---@param model DataStoreModel The model to unsave
function Addon.DataStores:UnsaveData(model)
    Addon.Logger:Info("DataStores: Unsaving data for key %s", model.Key)
    Addon.API.PersistentData:DeleteData(model.Key)
end