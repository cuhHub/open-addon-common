--------------------------------------------------------
-- Services - Weather
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
    A service for providing custom weather.
]]
---@class Weather: NoirService
Addon.Weather = Noir.Services:CreateService(
    "Weather",
    false,
    "A service for providing custom weather.",
    "A service for providing custom weather, using weather presets, etc.",
    {"Cuh4"}
)

--[[
    Called when this service is initialized.
]]
function Addon.Weather:ServiceInit()
    --[[
        A list of weather presets.
    ]]
    ---@type table<integer, WeatherPreset>
    self.WeatherPresets = {}

    --[[
        A list of active weather presets, one for each type.
    ]]
    ---@type table<WeatherPresetTypeEnum, WeatherPreset>
    self.ActiveWeatherPresets = {}

    --[[
        The current fog.
    ]]
    self.Fog = 0

    --[[
        The current rain.
    ]]
    self.Rain = 0

    --[[
        The current wind.
    ]]
    self.Wind = 0
end

--[[
    Called when this service is started.
]]
function Addon.Weather:ServiceStart()
    self:CreateDefaultPresets()
    self:SetRandomWeather()
    self:RegisterTips()
    self:CreateCommands()

    --[[
        A task for updating weather.
    ]]
    self.UpdateWeatherTask = Noir.Services.TaskService:AddTickTask(function()
        self:UpdateWeather()
    end, Config.Weather.UpdateIntervalTicks, nil, true)

    --[[
        A repeated task for changing weather.
    ]]
    self.WeatherChangeTask = Noir.Services.TaskService:AddTimeTask(function()
        self:SetRandomWeather()
    end, Config.Weather.WeatherChangeInterval, nil, true)
end

--[[
    Returns the time in seconds til the next weather change.
]]
---@return number
function Addon.Weather:GetTimeTilWeatherChange()
    return self.WeatherChangeTask.StopsAt - Noir.Services.TaskService:GetTimeSeconds()
end

--[[
    Updates the weather based on active weather presets.
]]
function Addon.Weather:UpdateWeather()
    local context = Addon.Classes.WeatherHandlerContext:New(
        Noir.Services.TaskService.Ticks
    )

    local active = self:GetActiveWeatherPresets()

    local fogActivePreset = active[Addon.Enums.WeatherPresetType.Fog]
    local rainActivePreset = active[Addon.Enums.WeatherPresetType.Rain]
    local windActivePreset = active[Addon.Enums.WeatherPresetType.Wind]

    local lastFog, lastRain, lastWind = self.Fog, self.Rain, self.Wind
    self.Fog, self.Rain, self.Wind = fogActivePreset:GetValue(context), rainActivePreset:GetValue(context), windActivePreset:GetValue(context)

    if lastFog == self.Fog and lastRain == self.Rain and lastWind == self.Wind then
        return
    end

    self:UpdateGameWeather()
end

--[[
    Updates the game's weather.
]]
function Addon.Weather:UpdateGameWeather()
    server.setWeather(self.Fog, self.Rain, self.Wind)
end

--[[
    Announces the current weather to players.
]]
function Addon.Weather:AnnounceWeather()
    local formattedPresets = self:GetFormattedActiveWeatherPresets()

    Addon.Message:SendNotification(
        nil,
        "Weather",
        "The weather has changed to:\n"..Addon.Libs.String:BulletList(formattedPresets, "-"),
        Addon.Enums.NotificationType.INFO
    )

    if Addon.Libs.Player:IsServerEmpty() then
        return
    end

    Addon.API.Server:SendLiveChat(
        "Weather",
        "The weather has changed to: "..table.concat(formattedPresets, ", ")..".",
        ":cloud:",
        215, 215, 252
    )
end

--[[
    Returns a table of the formatted names of the current active weather presets.
]]
---@return table<integer, string>
function Addon.Weather:GetFormattedActiveWeatherPresets()
    ---@type table<integer, string>
    local formattedPresets = {}

    for _, preset in pairs(self:GetActiveWeatherPresets()) do
        table.insert(formattedPresets, preset:GetFormattedName())
    end

    return formattedPresets
end

--[[
    Returns a weather preset by name.
]]
---@param name string The name of the preset
---@return WeatherPreset|nil
function Addon.Weather:GetWeatherPresetByName(name)
    for _, preset in pairs(self:GetWeatherPresets()) do
        if preset.Name == name then
            return preset
        end
    end
end

--[[
    Sets random active weather presets.
]]
function Addon.Weather:SetRandomWeather()
    local rainPreset = self:GetRandomWeatherPresetOfType(Addon.Enums.WeatherPresetType.Rain)
    local windPreset = self:GetRandomWeatherPresetOfType(Addon.Enums.WeatherPresetType.Wind)
    local fogPreset = self:GetRandomWeatherPresetOfType(Addon.Enums.WeatherPresetType.Fog)

    if self:GetActiveWeatherPresets()[Addon.Enums.WeatherPresetType.Rain] == rainPreset then
        self:SetRandomWeather()
        return
    end

    if self:GetActiveWeatherPresets()[Addon.Enums.WeatherPresetType.Wind] == windPreset then
        self:SetRandomWeather()
        return
    end

    if self:GetActiveWeatherPresets()[Addon.Enums.WeatherPresetType.Fog] == fogPreset then
        self:SetRandomWeather()
        return
    end

    self:SetActiveWeatherPresets({
        [Addon.Enums.WeatherPresetType.Rain] = self:GetRandomWeatherPresetOfType(Addon.Enums.WeatherPresetType.Rain),
        [Addon.Enums.WeatherPresetType.Wind] = self:GetRandomWeatherPresetOfType(Addon.Enums.WeatherPresetType.Wind),
        [Addon.Enums.WeatherPresetType.Fog] = self:GetRandomWeatherPresetOfType(Addon.Enums.WeatherPresetType.Fog)
    })
end

--[[
    Sets the active weather presets.
]]
---@param weatherPresets table<WeatherPresetTypeEnum, WeatherPreset> The weather presets to set
function Addon.Weather:SetActiveWeatherPresets(weatherPresets)
    self.ActiveWeatherPresets = weatherPresets
    self:AnnounceWeather()
end

--[[
    Creates a weather preset.
]]
---@param name string The name of the preset
---@param presetType WeatherPresetTypeEnum The type of the weather preset
---@param chance number The chance of the preset
---@param handler WeatherPresetHandler The handler for the preset
function Addon.Weather:CreateWeatherPreset(name, presetType, chance, handler)
    local weatherPreset = Addon.Classes.WeatherPreset:New(name, presetType, chance)
    weatherPreset:SetHandler(handler)

    table.insert(self.WeatherPresets, weatherPreset)

    return weatherPreset
end

--[[
    Returns the active weather presets.
]]
---@return table<WeatherPresetTypeEnum, WeatherPreset>
function Addon.Weather:GetActiveWeatherPresets()
    return self.ActiveWeatherPresets
end

--[[
    Returns all weather presets.
]]
---@return table<integer, WeatherPreset>
function Addon.Weather:GetWeatherPresets()
    return self.WeatherPresets
end

--[[
    Returns all weather presets of a type.
]]
---@param presetType WeatherPresetTypeEnum The type of the weather preset
---@return table<integer, WeatherPreset>
function Addon.Weather:GetWeatherPresetsOfType(presetType)
    ---@type table<integer, WeatherPreset>
    local weatherPresets = {}

    for _, weatherPreset in pairs(self:GetWeatherPresets()) do
        if weatherPreset.PresetType ~= presetType then
            goto continue
        end

        table.insert(weatherPresets, weatherPreset)

        ::continue::
    end

    return weatherPresets
end

--[[
    Returns a random weather preset of the provided type.
]]
---@param presetType WeatherPresetTypeEnum The type of the weather preset
---@return WeatherPreset
function Addon.Weather:GetRandomWeatherPresetOfType(presetType)
    local presets = self:GetWeatherPresetsOfType(presetType)
    local totalWeight = 0

    for _, preset in pairs(presets) do
        totalWeight = totalWeight + preset.Chance
    end

    if totalWeight <= 0 then
        error("Weather:GetRandomWeatherPresetOfType()", "No weather presets of type %s could be found.", presetType)
    end

    local roll = math.random() * totalWeight
    local cumulative = 0

    for _, preset in pairs(presets) do
        cumulative = cumulative + preset.Chance

        if roll <= cumulative then
            return preset
        end
    end

    return presets[#presets] -- fallback
end

--[[
    Creates default weather presets.
]]
function Addon.Weather:CreateDefaultPresets()
    -- Fog
    self:CreateWeatherPreset(
        "Clear Skies",
        Addon.Enums.WeatherPresetType.Fog,
        0.9,

        function(context)
            return 0
        end
    )

    self:CreateWeatherPreset(
        "Light Fog",
        Addon.Enums.WeatherPresetType.Fog,
        0.1,

        function(context)
            return 0.2 + (0.1 * math.abs(math.sin(context.Ticks * 0.001)))
        end
    )

    self:CreateWeatherPreset(
        "Medium Fog",
        Addon.Enums.WeatherPresetType.Fog,
        0.09,

        function(context)
            return 0.4 + (0.1 * math.abs(math.sin(context.Ticks * 0.001)))
        end
    )

    self:CreateWeatherPreset(
        "Heavy Fog",
        Addon.Enums.WeatherPresetType.Fog,
        0.05,

        function(context)
            return 0.8 + (0.1 * math.abs(math.sin(context.Ticks * 0.001)))
        end
    )

    -- Rain
    self:CreateWeatherPreset(
        "Sunny",
        Addon.Enums.WeatherPresetType.Rain,
        0.9,

        function(context)
            return 0
        end
    )

    self:CreateWeatherPreset(
        "Light Rain",
        Addon.Enums.WeatherPresetType.Rain,
        0.2,

        function(context)
            return 0.3
        end
    )

    self:CreateWeatherPreset(
        "Medium Rain",
        Addon.Enums.WeatherPresetType.Rain,
        0.1,

        function(context)
            return 0.6
        end
    )

    self:CreateWeatherPreset(
        "Heavy Rain",
        Addon.Enums.WeatherPresetType.Rain,
        0.1,

        function(context)
            return 0.8
        end
    )

    -- Wind
    self:CreateWeatherPreset(
        "No Wind",
        Addon.Enums.WeatherPresetType.Wind,
        0.9,

        function(context)
            return 0
        end
    )

    self:CreateWeatherPreset(
        "Slight Breeze",
        Addon.Enums.WeatherPresetType.Wind,
        0.1,

        function(context)
            return 0.2
        end
    )

    self:CreateWeatherPreset(
        "Strong Wind",
        Addon.Enums.WeatherPresetType.Wind,
        0.03,

        function(context)
            return 0.5
        end
    )

    self:CreateWeatherPreset(
        "Heavy Winds",
        Addon.Enums.WeatherPresetType.Wind,
        0.015,

        function(context)
            return 0.5 + (0.2 * math.abs(math.sin(context.Ticks * 0.001)))
        end
    )
end

--[[
    Registers tips.
]]
function Addon.Weather:RegisterTips()
    Addon.Tips:RegisterTips({
        "Use '?weather' ('?wea') to see the current active weather presets.",
        ("This server uses a custom weather system! Premade weather presets are selected at random every %d minute(s)."):format(math.ceil(Config.Weather.WeatherChangeInterval / 60))
    })
end

--[[
    Creates commands.
]]
function Addon.Weather:CreateCommands()
    Noir.Services.CommandService:CreateCommand(
        "weather",
        {"wea"},
        false,
        false,
        false,
        "Displays the current active weather presets.",

        function(context)
            if not context.HasPermission then
                return
            end

            local formattedPresets = self:GetFormattedActiveWeatherPresets()

            Addon.Message:Send(
                context.Player,
                "Weather",
                "The current active weather presets are:\n"..Addon.Libs.String:BulletList(formattedPresets, "-").."\nNext Weather Change In: "..Addon.Libs.Time:FormatTime(self:GetTimeTilWeatherChange()),
                Addon.Enums.NotificationType.INFO
            )
        end
    )
end