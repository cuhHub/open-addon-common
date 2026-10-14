--------------------------------------------------------
-- Services - EnvMods
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
    A service for spawning tagged assets on startup.
]]
---@class EnvMods: NoirService
Addon.EnvMods = Noir.Services:CreateService(
    "EnvMods",
    false,
    "A service for spawning tagged assets on startup.",
    "A service for spawning tagged assets on startup.",
    {"Cuh4"}
)

--[[
    Called when this service is initialized.
]]
function Addon.EnvMods:ServiceInit()
    --[[
        The environment mod asset tag.
    ]]
    self.ENV_MOD_ASSET_TAG = "env_mod"
end

--[[
    Called when this service is started.
]]
function Addon.EnvMods:ServiceStart()
    self:SpawnEnvModAssets()
end

--[[
    Spawns an env mod asset.
]]
---@param asset Asset The env mod asset
function Addon.EnvMods:SpawnEnvModAsset(asset)
    Addon.Streamables:CreateStreamable(
        asset:GetPosition(true),
        Config.EnvMods.StreamRadius,
        Addon.Enums.StreamType.StreamInStreamOut,
        Addon.Enums.StreamSpawningType.UseSpawnPosition,
        Addon.Streamables:CreateVehicleStreamableEntity(asset)
    )

    Addon.Logger:Info("EnvMods: Spawned %s as streamable", asset:Format())
end

--[[
    Spawns all env mod assets.
]]
function Addon.EnvMods:SpawnEnvModAssets()
    for _, asset in pairs(Addon.Assets:Find({self.ENV_MOD_ASSET_TAG})) do
        self:SpawnEnvModAsset(asset)
    end
end