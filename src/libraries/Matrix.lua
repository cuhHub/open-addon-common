--------------------------------------------------------
-- Libraries - Matrix
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
    A library for operations relating to matrices.<br>
    `Noir.Libraries.Matrix` provides a lot already, but this adds missing operations like a
    performant distance check.
]]
---@class MatrixLib: NoirLibrary
Addon.Libs.Matrix = Noir.Libraries:Create(
    "Matrix",
    "A library for operations relating to matrices.",
    "A library for operations relating to matrices. This adds missing operations like a performant distance check.",
    {"Cuh4"}
)

--[[
    Formats distance.
]]
---@param distance number The distance to format
---@return string
function Addon.Libs.Matrix:FormatDistance(distance)
    if distance < 1000 then
        return ("%.1fm"):format(distance)
    end

    return ("%.1fkm"):format(distance / 1000)
end

--[[
    Returns the squared distance between two matrices.<br>
    This is more performant than `matrix.distance` as `sqrt` is not used.
]]
---@param matrix1 SWMatrix
---@param matrix2 SWMatrix
---@return number
function Addon.Libs.Matrix:GetSquaredDistance(matrix1, matrix2)
    local x1, y1, z1 = matrix.position(matrix1)
    local x2, y2, z2 = matrix.position(matrix2)

    local dx = x2 - x1
    local dy = y2 - y1
    local dz = z2 - z1

    return (dx * dx) + (dy * dy) + (dz * dz)
end