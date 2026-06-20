--------------------------------------------------------
-- Libraries - Cache
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
    A library for caching function call results for faster access.
]]
---@class CacheLib: NoirLibrary
Addon.Libs.Cache = Noir.Libraries:Create(
    "Cache",
    "A library for caching function call results for faster access.",
    "A library for caching function call results for faster access.",
    {"Cuh4"}
)

--[[
    Returns a cache index for the given arguments.
]]
---@param ... any The arguments to get the cache index for
---@return string
function Addon.Libs.Cache:GetCacheIndex(...)
    local n = select("#", ...)

    ---@type table<integer, string>
    local stringSafe = {}

    for index = 1, n do
        local value = select(index, ...)
        stringSafe[index] = tostring(value)..type(value)
    end

    return table.concat(stringSafe, ",").."|"..n
end

--[[
    Caches a function call result.
]]
---@generic targetFunction: function The function to cache
---@param func targetFunction The function to cache
---@return targetFunction
function Addon.Libs.Cache:CacheFunction(func)
    ---@type table<string, table<integer, any>>
    local cache = {}

    return function(...)
        local cacheIndex = self:GetCacheIndex(...)
        local cachedResults = cache[cacheIndex]

        if cachedResults then
            return table.unpack(cachedResults, 1, cachedResults.n) ---@diagnostic disable-line: undefined-field
        end

        local results = table.pack(func(...))
        cache[cacheIndex] = results

        return table.unpack(results, 1, results.n)
    end
end