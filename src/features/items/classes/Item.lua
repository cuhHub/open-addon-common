--------------------------------------------------------
-- Classes - Item
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
    A class representing an item.
]]
---@class Item: NoirClass
---@field New fun(self: Item, name: string, equipmentType: SWEquipmentTypeEnum, int: integer, float: number, slotType: SlotTypeEnum): Item
Addon.Classes.Item = Noir.Class("Item")

--[[
    Initializes `Item` class instances.
]]
---@param name string The name of the item
---@param equipmentType SWEquipmentTypeEnum The item type
---@param int integer The item's int value
---@param float number The item's float value
---@param slotType SlotTypeEnum The slot type this item is for
function Addon.Classes.Item:Init(name, equipmentType, int, float, slotType)
    --[[
        The name of this item.
    ]]
    self.Name = name

    --[[
        The type of this item.
    ]]
    self.EquipmentType = equipmentType

    --[[
        The integer value of this item.
    ]]
    self.Int = int

    --[[
        The float value of this item.
    ]]
    self.Float = float

    --[[
        The slot type this item is for.
    ]]
    self.SlotType = slotType
end

--[[
    Returns a user-friendly string representation of this item.
]]
---@return string
function Addon.Classes.Item:ToString()
    return ("%s (#%s)"):format(self.Name, self.EquipmentType)
end

--[[
    Spawns this item in the world.
]]
---@param position SWMatrix The position to spawn the item at
---@return NoirObject
function Addon.Classes.Item:Spawn(position)
    return Noir.Services.ObjectService:SpawnEquipment(self.EquipmentType, position, self.Int, self.Float)
end

--[[
    Gives this item to a player.
]]
---@param slot number The slot to insert the item into
---@param character NoirObject The character to give the item to
---@param overrideInt integer|nil A custom int to provide, or nil for default
---@param overrideFloat number|nil A custom float to provide, or nil for default
---@param isActive boolean|nil Whether the item should be active
function Addon.Classes.Item:Give(slot, character, overrideInt, overrideFloat, isActive)
    character:GiveItem(slot, self.EquipmentType, isActive or false, overrideInt or self.Int, overrideFloat or self.Float)
end

--[[
    Returns a free slot for this item, or nil if none is available.
]]
---@param character NoirObject The character to check for a free slot
---@return number|nil
function Addon.Classes.Item:GetFreeSlot(character)
    if self.SlotType == Addon.Enums.SlotType.Outfit then
        return self:_GetFreeOutfitSlot(character)
    elseif self.SlotType == Addon.Enums.SlotType.Large then
        return self:_GetFreeLargeSlot(character)
    elseif self.SlotType == Addon.Enums.SlotType.Small then
        return self:_GetFreeSmallSlot(character)
    end
end

--[[
    Returns a free outfit slot for this item, or nil if none is available.
]]
---@param character NoirObject The character to check for a free slot
---@return number|nil
function Addon.Classes.Item:_GetFreeOutfitSlot(character)
    return character:GetItem(10) == 0 and 10 or nil
end

--[[
    Returns a free large slot for this item, or nil if none is available.
]]
---@param character NoirObject The character to check for a free slot
---@return number|nil
function Addon.Classes.Item:_GetFreeLargeSlot(character)
    return character:GetItem(1) == 0 and 1 or nil
end

--[[
    Returns a free small slot for this item, or nil if none is available.
]]
---@param character NoirObject The character to check for a free slot
---@return number|nil
function Addon.Classes.Item:_GetFreeSmallSlot(character)
    for i = 2, 9 do
        if character:GetItem(i) == 0 then
            return i
        end
    end
end