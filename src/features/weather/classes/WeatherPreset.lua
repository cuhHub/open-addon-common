--------------------------------------------------------
-- Classes - Weather Preset
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
    A class representing a weather preset.
]]
---@class WeatherPreset: NoirClass
---@field New fun(self: WeatherPreset, name: string, presetType: WeatherPresetTypeEnum, chance: number): WeatherPreset
Addon.Classes.WeatherPreset = Noir.Class("WeatherPreset")

--[[
    Initializes new `WeatherPreset` instances.
]]
---@param name string The name of the weather preset
---@param presetType WeatherPresetTypeEnum The type of the weather preset
---@param chance number The chance of the preset
function Addon.Classes.WeatherPreset:Init(name, presetType, chance)
    --[[
        The name of the preset.
    ]]
    self.Name = name

    --[[
        The type of weather preset.
    ]]
    self.PresetType = presetType

    --[[
        The chance of the preset.
    ]]
    self.Chance = chance

    --[[
        The preset handler function.
    ]]
    ---@type WeatherPresetHandler
    self.Handler = nil
end

--[[
    Returns the formatted name for this preset.
]]
---@return string
function Addon.Classes.WeatherPreset:GetFormattedName()
    return ("%s (%s) (%s chance)"):format(
        self.Name,
        Noir.Libraries.Table:Find(Addon.Enums.WeatherPresetType, self.PresetType),
        Addon.Libs.String:FormatPercentage(self.Chance)
    )
end

--[[
    Sets the handler for the preset.
]]
---@param handler WeatherPresetHandler The handler function for the preset
function Addon.Classes.WeatherPreset:SetHandler(handler)
    self.Handler = handler
end

--[[
    Returns the current weather preset value by executing the handler.
]]
---@param context WeatherHandlerContext The context to pass to the handler
---@return number
function Addon.Classes.WeatherPreset:GetValue(context)
    if not self.Handler then
        error("WeatherPreset:GetValue()", "No handler has been set for this weather preset (%s).", self.Name)
    end

    return self.Handler(context)
end

--[[
    Tests the chance of the preset, determining if it should be active.
]]
---@return boolean
function Addon.Classes.WeatherPreset:TestChance()
    math.randomseed(Noir.Services.TaskService.Ticks)
    return math.random() <= self.Chance
end

---@alias WeatherPresetHandler fun(context: WeatherHandlerContext): number