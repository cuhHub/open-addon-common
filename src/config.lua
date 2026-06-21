--------------------------------------------------------
-- Config
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
    A table storing configuration values for use throughout the addon.
]]
Config = {}
Config.Version = "your_addon_version"

--[[
    API service config.
]]
Config.API = {}
Config.API.URL = "https://api.cuhhub.com/"
Config.API.Port = 1500
Config.API.ConversionResponsesFetchInterval = 2.5 -- in seconds
Config.API.ServerEventFetchInterval = 5 -- in seconds
Config.API.ShouldFetchServerEvents = false
Config.API.ShouldFetchConversionRequestResponses = true
Config.API.ConversionRequestTimeout = 15 -- in seconds

--[[
    UI service related config.
]]
Config.UI = {}
Config.UI.UpdateInterval = 0.01 -- seconds

--[[
    Tips service related config.
]]
Config.Tips = {}
Config.Tips.SendInterval = 2 * 60 -- seconds

--[[
    Help service related config.
]]
Config.Help = {}

Config.Help.CommandFormat = table.concat({
    "/== ?$NAME (?$ALIASES)",
    "$DESCRIPTION"
}, "\n")

Config.Help.CommandsPerPage = 3

--[[
    Items service related config.
]]
Config.Items = {}
Config.Items.DroppedItemDespawnInterval = 30 -- seconds

Config.Items.StarterItems = {
    [1] = "WeldingTorch",
    [2] = "Compass",
    [3] = "Flashlight",
    [4] = "Binoculars",
    [5] = "FirstAid",
    [6] = "FirstAid",
    [7] = "Radio",
    [8] = "OxygenMask",
    [10] = "Parachute"
}

--[[
    Cleanup service related config.
]]
Config.Cleanup = {}
Config.Cleanup.OilSpillCleanupInterval = 1 -- seconds
Config.Cleanup.RadiationCleanupInterval = 1 -- seconds
Config.Cleanup.ObjectCleanupInterval = 0.1 -- seconds

Config.Cleanup.ObjectTypeExceptions = {
    [66] = {lifetime = 1200}, -- c4
    [67] = {lifetime = 10}, -- grenade
    [72] = {lifetime = 0}, -- creatures
    [59] = {lifetime = 0}, -- animals
    [1] = {lifetime = 0}, -- characters
    [74] = {lifetime = 0}, -- fishing lure
    [58] = {lifetime = 0}, -- fire
    [68] = {lifetime = 0}, -- chaff flares
    [64] = {lifetime = 5}, -- ammo shell
    [71] = {lifetime = 1200}, -- glowstick
    [73] = {lifetime = 0}, -- drill rod
    [57] = {lifetime = 10}, -- flare (handheld)
    [62] = {lifetime = 10}, -- flare (flare gun projectile)
    [63] = {lifetime = 10}, -- flare (vehicle flare projectile)
}

--[[
    Weather service related config.
]]
Config.Weather = {}
Config.Weather.UpdateIntervalTicks = 20
Config.Weather.WeatherChangeInterval = 5 * 60 -- seconds

--[[
    Confirmation related config
]]
Config.Confirmations = {}
Config.Confirmations.Timeout = 20

--[[
    Requests related config.
]]
Config.Requests = {}
Config.Requests.Timeout = 15

--[[
    Perf service related config.
]]
Config.Perf = {}
Config.Perf.MaxMeasurementsForTPSMeasurementProcesses = 125 -- such good naming