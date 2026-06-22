--------------------------------------------------------
-- Services - Items
--------------------------------------------------------

--[[
    Copyright (C) 2026 cuhHub - All Rights Reserved
    - Unauthorized copying of this file, via any medium is strictly prohibited
    - Proprietary and confidential
]]

-------------------------------
-- // Main
-------------------------------

--[[
    A service for providing items to players.
]]
---@class Items: NoirService
Addon.Items = Noir.Services:CreateService(
    "Items",
    false,
    "A service for providing items to players.",
    "A service for providing items to players on spawn.",
    {"Cuh4"}
)

--[[
    Called when this service is initialized.
]]
function Addon.Items:ServiceInit()
    --[[
        A table containing all items in the game.
    ]]
    self.Items = {
        Diving = self:CreateItem("Diving Suit", 1, 0, 0, Addon.Enums.SlotType.Outfit),
        Firefighter = self:CreateItem("Firefighter Suit", 2, 0, 0, Addon.Enums.SlotType.Outfit),
        Scuba = self:CreateItem("Scuba Suit", 3, 0, 0, Addon.Enums.SlotType.Outfit),
        Parachute = self:CreateItem("Parachute", 4, 1, 0, Addon.Enums.SlotType.Outfit),
        Arctic = self:CreateItem("Arctic Suit", 5, 0, 0, Addon.Enums.SlotType.Outfit),
        Binoculars = self:CreateItem("Binoculars", 6, 0, 0, Addon.Enums.SlotType.Small),
        Cable = self:CreateItem("Cable", 7, 0, 0, Addon.Enums.SlotType.Large),
        Compass = self:CreateItem("Compass", 8, 0, 0, Addon.Enums.SlotType.Small),
        Defibrillator = self:CreateItem("Defibrillator", 9, 4, 0, Addon.Enums.SlotType.Large),
        FireExtinguisher = self:CreateItem("Fire Extinguisher", 10, 0, 10, Addon.Enums.SlotType.Large),
        FirstAid = self:CreateItem("First Aid", 11, 4, 0, Addon.Enums.SlotType.Small),
        Flare = self:CreateItem("Flare", 12, 4, 0, Addon.Enums.SlotType.Small),
        Flaregun = self:CreateItem("Flaregun", 13, 1, 0, Addon.Enums.SlotType.Small),
        FlaregunAmmo = self:CreateItem("Flaregun Ammo", 14, 4, 0, Addon.Enums.SlotType.Small),
        Flashlight = self:CreateItem("Flashlight", 15, 0, 100, Addon.Enums.SlotType.Small),
        Hose = self:CreateItem("Hose", 16, 0, 0, Addon.Enums.SlotType.Large),
        NightVisionBinoculars = self:CreateItem("Night Vision Binoculars", 17, 0, 100, Addon.Enums.SlotType.Small),
        OxygenMask = self:CreateItem("Oxygen Mask", 18, 0, 100, Addon.Enums.SlotType.Small),
        Radio = self:CreateItem("Radio", 19, 0, 100, Addon.Enums.SlotType.Small),
        RadioSignalLocator = self:CreateItem("Radio Signal Locator", 20, 0, 100, Addon.Enums.SlotType.Small),
        RemoteControl = self:CreateItem("Remote Control", 21, 0, 100, Addon.Enums.SlotType.Small),
        Rope = self:CreateItem("Rope", 22, 0, 0, Addon.Enums.SlotType.Large),
        StrobeLight = self:CreateItem("Strobe Light", 23, 0, 100, Addon.Enums.SlotType.Small),
        StrobeLightInfrared = self:CreateItem("Strobe Light Infrared", 24, 0, 100, Addon.Enums.SlotType.Small),
        Transponder = self:CreateItem("Transponder", 25, 0, 100, Addon.Enums.SlotType.Small),
        UnderwaterWeldingTorch = self:CreateItem("Underwater Welding Torch", 26, 0, 450, Addon.Enums.SlotType.Large),
        WeldingTorch = self:CreateItem("Welding Torch", 27, 0, 450, Addon.Enums.SlotType.Large),
        Coal = self:CreateItem("Coal", 28, 0, 0, Addon.Enums.SlotType.Small),
        Hazmat = self:CreateItem("Hazmat Suit", 29, 0, 0, Addon.Enums.SlotType.Outfit),
        RadiationDetector = self:CreateItem("Radiation Detector", 30, 0, 100, Addon.Enums.SlotType.Small),
        C4 = self:CreateItem("C4", 31, 1, 0, Addon.Enums.SlotType.Small),
        C4Detonator = self:CreateItem("C4 Detonator", 32, 0, 0, Addon.Enums.SlotType.Small),
        Speargun = self:CreateItem("Speargun", 33, 12, 0, Addon.Enums.SlotType.Large),
        SpeargunAmmo = self:CreateItem("Speargun Ammo", 34, 12, 0, Addon.Enums.SlotType.Small),
        Pistol = self:CreateItem("Pistol", 35, 12, 0, Addon.Enums.SlotType.Small),
        PistolAmmo = self:CreateItem("Pistol Ammo", 36, 12, 0, Addon.Enums.SlotType.Small),
        SMG = self:CreateItem("SMG", 37, 12, 0, Addon.Enums.SlotType.Large),
        SMGAmmo = self:CreateItem("SMG Ammo", 38, 12, 0, Addon.Enums.SlotType.Small),
        Rifle = self:CreateItem("Rifle", 39, 30, 0, Addon.Enums.SlotType.Large),
        RifleAmmo = self:CreateItem("Rifle Ammo", 40, 30, 0, Addon.Enums.SlotType.Small),
        Grenade = self:CreateItem("Grenade", 41, 1, 1, Addon.Enums.SlotType.Small),
        MachineGunAmmoBoxK = self:CreateItem("Machine Gun Ammo Box K", 42, 12, 0, Addon.Enums.SlotType.Large),
        MachineGunAmmoBoxHE = self:CreateItem("Machine Gun Ammo Box HE", 43, 12, 0, Addon.Enums.SlotType.Large),
        MachineGunAmmoBoxHEFrag = self:CreateItem("Machine Gun Ammo Box HE Frag", 44, 12, 0, Addon.Enums.SlotType.Large),
        MachineGunAmmoBoxAP = self:CreateItem("Machine Gun Ammo Box AP", 45, 12, 0, Addon.Enums.SlotType.Large),
        MachineGunAmmoBoxI = self:CreateItem("Machine Gun Ammo Box I", 46, 12, 0, Addon.Enums.SlotType.Large),
        LightAutoAmmoBoxK = self:CreateItem("Light Auto Ammo Box K", 47, 12, 0, Addon.Enums.SlotType.Large),
        LightAutoAmmoBoxHE = self:CreateItem("Light Auto Ammo Box HE", 48, 12, 0, Addon.Enums.SlotType.Large),
        LightAutoAmmoBoxHEFrag = self:CreateItem("Light Auto Ammo Box HE Frag", 49, 12, 0, Addon.Enums.SlotType.Large),
        LightAutoAmmoBoxAP = self:CreateItem("Light Auto Ammo Box AP", 50, 12, 0, Addon.Enums.SlotType.Large),
        LightAutoAmmoBoxI = self:CreateItem("Light Auto Ammo Box I", 51, 12, 0, Addon.Enums.SlotType.Large),
        RotaryAutoAmmoBoxK = self:CreateItem("Rotary Auto Ammo Box K", 52, 12, 0, Addon.Enums.SlotType.Large),
        RotaryAutoAmmoBoxHE = self:CreateItem("Rotary Auto Ammo Box HE", 53, 12, 0, Addon.Enums.SlotType.Large),
        RotaryAutoAmmoBoxHEFrag = self:CreateItem("Rotary Auto Ammo Box HE Frag", 54, 12, 0, Addon.Enums.SlotType.Large),
        RotaryAutoAmmoBoxAP = self:CreateItem("Rotary Auto Ammo Box AP", 55, 12, 0, Addon.Enums.SlotType.Large),
        RotaryAutoAmmoBoxI = self:CreateItem("Rotary Auto Ammo Box I", 56, 12, 0, Addon.Enums.SlotType.Large),
        HeavyAutoAmmoBoxK = self:CreateItem("Heavy Auto Ammo Box K", 57, 12, 0, Addon.Enums.SlotType.Large),
        HeavyAutoAmmoBoxHE = self:CreateItem("Heavy Auto Ammo Box HE", 58, 12, 0, Addon.Enums.SlotType.Large),
        HeavyAutoAmmoBoxHEFrag = self:CreateItem("Heavy Auto Ammo Box HE Frag", 59, 12, 0, Addon.Enums.SlotType.Large),
        HeavyAutoAmmoBoxAP = self:CreateItem("Heavy Auto Ammo Box AP", 60, 12, 0, Addon.Enums.SlotType.Large),
        HeavyAutoAmmoBoxI = self:CreateItem("Heavy Auto Ammo Box I", 61, 12, 0, Addon.Enums.SlotType.Large),
        BattleShellK = self:CreateItem("Battle Shell K", 62, 12, 0, Addon.Enums.SlotType.Large),
        BattleShellHE = self:CreateItem("Battle Shell HE", 63, 12, 0, Addon.Enums.SlotType.Large),
        BattleShellHEFrag = self:CreateItem("Battle Shell HE Frag", 64, 12, 0, Addon.Enums.SlotType.Large),
        BattleShellAP = self:CreateItem("Battle Shell AP", 65, 12, 0, Addon.Enums.SlotType.Large),
        BattleShellI = self:CreateItem("Battle Shell I", 66, 12, 0, Addon.Enums.SlotType.Large),
        ArtilleryShellK = self:CreateItem("Artillery Shell K", 67, 12, 0, Addon.Enums.SlotType.Large),
        ArtilleryShellHE = self:CreateItem("Artillery Shell HE", 68, 12, 0, Addon.Enums.SlotType.Large),
        ArtilleryShellHEFrag = self:CreateItem("Artillery Shell HE Frag", 69, 12, 0, Addon.Enums.SlotType.Large),
        ArtilleryShellAP = self:CreateItem("Artillery Shell AP", 70, 12, 0, Addon.Enums.SlotType.Large),
        ArtilleryShellI = self:CreateItem("Artillery Shell I", 71, 12, 0, Addon.Enums.SlotType.Large),
        Glowstick = self:CreateItem("Glowstick", 72, 1, 1, Addon.Enums.SlotType.Small),
        DogWhistle = self:CreateItem("Dog Whistle", 73, 0, 0, Addon.Enums.SlotType.Small),
        BombDisposal = self:CreateItem("Bomb Disposal Suit", 74, 0, 0, Addon.Enums.SlotType.Outfit),
        ChestRig = self:CreateItem("Chest Rig", 75, 0, 0, Addon.Enums.SlotType.Outfit),
        BlackHawkVest = self:CreateItem("Black Hawk Vest", 76, 0, 0, Addon.Enums.SlotType.Outfit),
        PlateVest = self:CreateItem("Plate Vest", 77, 0, 0, Addon.Enums.SlotType.Outfit),
        ArmorVest = self:CreateItem("Armor Vest", 78, 0, 0, Addon.Enums.SlotType.Outfit),
        SpaceSuit = self:CreateItem("Space Suit", 79, 0, 0, Addon.Enums.SlotType.Outfit),
        ExplorationSpaceSuit = self:CreateItem("Exploration Space Suit", 80, 0, 0, Addon.Enums.SlotType.Outfit),
        FishingRod = self:CreateItem("Fishing Rod", 81, 0, 0, Addon.Enums.SlotType.Large),
        FirefighterSCBA = self:CreateItem("Firefighter SCBA", 149, 0, 0, Addon.Enums.SlotType.Outfit)
    }

    --[[
        A table containing items for players to start with.
    ]]
    ---@type table<SWSlotNumberEnum, Item|fun(player: NoirPlayer): Item>
    self.StarterItems = {}

    for slot, item in pairs(Config.Items.StarterItems) do
        self.StarterItems[slot] = self:GetItem(item)
    end
end

--[[
    Called when this service is started.
]]
function Addon.Items:ServiceStart()
    --[[
        A connection to `PlayerService`'s `OnJoin` event.
    ]]
    ---@param player NoirPlayer
    self.OnJoinSpawn = Noir.Services.PlayerService.OnJoin:Connect(function(player)
        Addon.Libs.Player:GetCharacterDefinite(player, function() -- wait for character to load first
            self:RemoveGameStarterItems(player)
            self:GiveStarterItems(player)
        end)
    end)

    --[[
        A connection to `PlayerService`'s `OnRespawn` event.
    ]]
    ---@param player NoirPlayer
    self.OnPlayerRespawnConnection = Noir.Services.PlayerService.OnRespawn:Connect(function(player)
        Noir.Services.TaskService:AddTimeTask(function() -- because stormworks. gotta wait a tick or so for the game to give the player default items
            self:RemoveGameStarterItems(player)
            self:GiveStarterItems(player)
        end, 0.5)
    end)

    --[[
        A connection to the game's `onEquipmentDrop` event.
    ]]
    self.OnEquipmentDropConnection = Noir.Callbacks:Connect("onEquipmentDrop", function(characterObjectID, equipmentObjectID, equipmentID)
        local object = Noir.Services.ObjectService:GetObject(characterObjectID)
        local player = Noir.Services.PlayerService:GetPlayerByCharacter(object)

        if not player then
            return
        end

        self:HandleDroppedItem(player, Noir.Services.ObjectService:GetObject(equipmentObjectID))
    end)
end

--[[
    Handles a dropped item.
]]
---@param player NoirPlayer The player who dropped the item
---@param itemObject NoirObject The dropped item object
function Addon.Items:HandleDroppedItem(player, itemObject)
    local character = player:GetCharacter()

    if not character then
        return
    end

    if character:IsDowned() then -- items dropped due to death, so ignore to prevent notif spam and unneeded exemptions
        return
    end

    Addon.Message:SendNotification(
        player,
        "Item Dropped",
        "You dropped an item. It will be despawned in %s.",
        Addon.Enums.NotificationType.INFO,
        Addon.Libs.Time:FormatTime(Config.Items.DroppedItemDespawnInterval)
    )

    Addon.Cleanup:ExemptObjectFromCleanup(itemObject, Config.Items.DroppedItemDespawnInterval)
end

--[[
    Creates an item class instance.
]]
---@param name string The name of the item
---@param equipmentType SWEquipmentTypeEnum The item type ID
---@param intValue integer The item's int value
---@param floatValue number The item's float value
---@param slotType SlotTypeEnum The slot type
---@return Item
function Addon.Items:CreateItem(name, equipmentType, intValue, floatValue, slotType)
    return Addon.Classes.Item:New(name, equipmentType, intValue, floatValue, slotType)
end

--[[
    Removes base-game starter items.
]]
---@param player NoirPlayer The player to remove the items from
function Addon.Items:RemoveGameStarterItems(player)
    local character = player:GetCharacter()

    if not character then
        error("Addon.Items:RemoveGameStarterItems()", "Player's character is nil")
    end

    character:GiveItem(2, 0)
    character:GiveItem(3, 0)
end

--[[
    Gives starter items to a player.
]]
---@param player NoirPlayer The player to give items to
---@param notify boolean|nil Whether to notify the player, defaults to false
function Addon.Items:GiveStarterItems(player, notify)
    local character = player:GetCharacter()

    if not character then
        error("Addon.Items:GiveStarterItems()", "Player's character is nil")
    end

    local failed = 0

    for slot, item in pairs(self.StarterItems) do
        item = type(item) == "function" and item(player) or item
        item:Give(slot, character)
    end

    if not notify then
        return
    end

    Addon.Message:SendNotification(
        player,
        "Starter Items",
        "You have been given starter items."..(failed > 0 and ("\n%d item(s) failed to be given. Make sure your slots are freed up!"):format(failed) or ""),
        Addon.Enums.NotificationType.SUCCESS
    )
end

--[[
    Returns an item by name.
]]
---@param name string The name of the item
---@return Item
function Addon.Items:GetItem(name)
    return self:GetItems()[name]
end

--[[
    Returns all items.
]]
---@return table<string, Item>
function Addon.Items:GetItems()
    return self.Items
end