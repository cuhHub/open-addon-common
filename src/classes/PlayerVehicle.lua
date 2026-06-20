--------------------------------------------------------
-- Classes - Player Vehicle
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
    A class representing a player-spawned vehicle.
]]
---@class PlayerVehicle: NoirHoardable
---@field New fun(self: PlayerVehicle, owner: NoirPlayer, vehicle: NoirVehicle): PlayerVehicle
Addon.Classes.PlayerVehicle = Noir.Class("PlayerVehicle", Noir.Classes.Hoardable)

--[[
    Initializes `PlayerVehicle` class instances.
]]
---@param owner NoirPlayer The owner of this vehicle
---@param vehicle NoirVehicle The vehicle itself
function Addon.Classes.PlayerVehicle:Init(owner, vehicle)
    self:InitFrom(Noir.Classes.Hoardable, vehicle.ID)

    --[[
        The owner of this vehicle.
    ]]
    ---@type NoirPlayer
    self.Owner = owner

    --[[
        The vehicle itself.
    ]]
    ---@type NoirVehicle
    self.Vehicle = vehicle

    --[[
        Represents if the vehicle has had its first load or not.
    ]]
    self.HasHadFirstLoad = false

    --[[
        The total cost of the vehicle.
    ]]
    self.Cost = self.Vehicle.Cost

    --[[
        The spawn position of this vehicle.
    ]]
    self.SpawnPosition = self.Vehicle.SpawnPosition

    --[[
        Represents if refunding on despawn is allowed.
    ]]
    self.RefundAllowed = false
end

--[[
    Called before serialization via HoarderService.
]]
function Addon.Classes.PlayerVehicle:OnPreSerialize()
    ---@type NoirPlayer -- <-- same reason as below
    self.Owner = self.Owner.ID

    ---@type NoirVehicle -- <-- so lua lsp doesn't complain that this can sometimes be a number
    self.Vehicle = self.Vehicle.ID -- cant serialize a cyclic table (bodies inside the vehicle reference the vehicle)
end

--[[
    Called after deserialization via HoarderService.
]]
---@param serialized table The serialized version of this class instance
---@param lookupClasses table<string, NoirClass> The lookup classes used
function Addon.Classes.PlayerVehicle:OnPostDeserialize(serialized, lookupClasses)
    ---@type NoirPlayer
    ---@diagnostic disable-next-line: param-type-mismatch
    self.Owner = Noir.Services.PlayerService:GetPlayer(self.Owner)

    ---@type NoirVehicle
    ---@diagnostic disable-next-line: param-type-mismatch
    self.Vehicle = Noir.Services.VehicleService:GetVehicle(self.Vehicle)

    if not self.Owner or not self.Vehicle then
        return
    end

    self:Update()
end

--[[
    Saves to savedata.
]]
function Addon.Classes.PlayerVehicle:Save()
    self:Hoard(Addon.Vehicles, "PlayerVehicles")
end

--[[
    Unsaves from savedata.
]]
function Addon.Classes.PlayerVehicle:Unsave()
    self:Unhoard(Addon.Vehicles, "PlayerVehicles")
end

--[[
    Updates the vehicle.
]]
function Addon.Classes.PlayerVehicle:Update()
    self:UpdateTooltip()
end

--[[
    Called when the vehicle first fully loads.
]]
function Addon.Classes.PlayerVehicle:OnFirstLoad()
    if self.HasHadFirstLoad then
        return
    end

    self.HasHadFirstLoad = true
end

--[[
    Called when the vehicle is fully spawned.
]]
function Addon.Classes.PlayerVehicle:OnFullySpawned()
    if not self.HasHadFirstLoad then
        error("Addon.Classes.PlayerVehicle:OnFullySpawned()", "Vehicle has not had its first load yet, How could it fully spawn?")
    end

    self:SetRefundAllowed(true)

    self:Pay()
    self:Update()
end

--[[
    Sets if refunding is allowed.
]]
---@param allow boolean Whether refunding is allowed
function Addon.Classes.PlayerVehicle:SetRefundAllowed(allow)
    self.RefundAllowed = allow
    self:Save()
end

--[[
    Returns the cost of the vehicle.
]]
---@return integer
function Addon.Classes.PlayerVehicle:GetCost()
    local cost = self.Cost

    if cost <= 0 then
        return 1
    end

    return self.Cost
end

--[[
    Returns if the player can afford this vehicle.
]]
---@return boolean
function Addon.Classes.PlayerVehicle:CanAfford()
    local wallet = Addon.Money:GetWallet(self.Owner)

    if not wallet then
        return false
    end

    return wallet:HasEnough(self:GetCost())
end

--[[
    Pays for the vehicle.
]]
function Addon.Classes.PlayerVehicle:Pay()
    if not self:CanAfford() then
        return
    end

    local wallet = Addon.Money:GetWallet(self.Owner)

    if not wallet then
        return
    end

    local payment = self:GetCost()
    wallet:TakeFunds(payment, "vehicle purchase")
    wallet:AddToRefund(payment)
end

--[[
    Returns the refund amount for the vehicle.
]]
---@return number
function Addon.Classes.PlayerVehicle:GetRefundAmount()
    return self:GetCost() * Config.Vehicles.RefundMultiplier
end

--[[
    Refunds the owner for the vehicle.
]]
function Addon.Classes.PlayerVehicle:Refund()
    if not self.RefundAllowed then
        return
    end

    local wallet = Addon.Money:GetWallet(self.Owner)

    if not wallet then
        return
    end

    local refundAmount = self:GetRefundAmount()
    wallet:AddFunds(refundAmount, ("vehicle refund (%s refund)"):format(Addon.Libs.String:FormatPercentage(Config.Vehicles.RefundMultiplier)))
    wallet:TakeFromRefund(self:GetCost())
end

--[[
    Omits despawn messages for this vehicle.
]]
function Addon.Classes.PlayerVehicle:OmitDespawnMessage()
    self.HideDespawnMessage = true
    self:Save()
end

--[[
    Returns if the vehicle still exists.
]]
---@return boolean
function Addon.Classes.PlayerVehicle:Exists()
    return Noir.Services.VehicleService:GetVehicle(self.Vehicle.ID) ~= nil
end

--[[
    Returns if the vehicle is owned by the provided player.
]]
---@param player NoirPlayer The player to check
---@return boolean
function Addon.Classes.PlayerVehicle:IsOwnedBy(player)
    return Noir.Services.PlayerService:IsSamePlayer(player, self.Owner)
end

--[[
    Returns the vehicle's bodies.
]]
---@return table<integer, NoirBody>
function Addon.Classes.PlayerVehicle:GetBodies()
    return self.Vehicle.Bodies
end

--[[
    Returns the vehicle's body count (ha).
]]
---@return integer
function Addon.Classes.PlayerVehicle:GetBodyCount()
    return Noir.Libraries.Table:Length(self:GetBodies())
end

--[[
    Returns a table of formatted commands for the vehicle.<br>
    To be used in tooltip.
]]
---@return table<integer, string>
function Addon.Classes.PlayerVehicle:_GetFormattedVehicleCommands()
    return {
        ("Use '?c %d' to despawn."):format(self.Vehicle.ID)
    }
end

--[[
    Updates the vehicle's tooltip.
]]
function Addon.Classes.PlayerVehicle:UpdateTooltip()
    for _, body in pairs(self:GetBodies()) do
        local tooltip = table.concat({
            ("%s (of %s)"):format(Addon.Libs.Vehicle:FormatBodyName(body), Addon.Libs.Vehicle:FormatVehicleName(body.ParentVehicle)),
            "Owned by: "..Addon.Libs.Player:FormatPlayerName(body.Owner),
            Addon.Libs.Money:FormatMoney(self:GetCost()),
            "",
            "Chat Commands:",
            table.concat(self:_GetFormattedVehicleCommands(), "\n")
        }, "\n")

        body:SetTooltip(tooltip)
    end
end

--[[
    Returns the vehicle's position.
]]
---@return SWMatrix
function Addon.Classes.PlayerVehicle:GetPosition()
    return self.Vehicle:GetPosition()
end

--[[
    Returns the vehicle's primary body.
]]
---@return NoirBody
function Addon.Classes.PlayerVehicle:GetPrimaryBody()
    return self.Vehicle.PrimaryBody or error("Addon.Classes.PlayerVehicle:GetPrimaryBody()", "Primary body is nil")
end

--[[
    Returns the primary body's components.
]]
---@return SWLoadedVehicleData|nil
function Addon.Classes.PlayerVehicle:GetPrimaryBodyComponents()
    return self:GetPrimaryBody():GetComponents()
end

--[[
    Returns if a random seat on the primary body, if any.
]]
---@return SWVehicleSeatData|nil
function Addon.Classes.PlayerVehicle:GetRandomSeat()
    local components = self:GetPrimaryBodyComponents()

    if not components then
        return
    end

    local seats = Addon.Libs.Table:Shuffle(components.components.seats)
    local foundSeat

    for _, seat in ipairs(seats) do
        if Addon.Libs.Vehicle:IsSeatOccupied(seat) then
            goto continue
        end

        foundSeat = seat

        ::continue::
    end

    return foundSeat
end

--[[
    Returns if any seats are available.
]]
---@return boolean
function Addon.Classes.PlayerVehicle:HasAvailableSeats()
    local components = self:GetPrimaryBodyComponents()

    if not components then
        return false
    end

    return #components.components.seats > 0
end

--[[
    Places the owner within a random seat on the vehicle.
]]
function Addon.Classes.PlayerVehicle:PlaceOwnerInRandomSeat()
    local seat = self:GetRandomSeat()

    if not seat then
        Addon.Message:SendNotification(
            self.Owner,
            "Vehicles",
            "There are no available seats on %s.",
            Addon.Enums.NotificationType.ERROR,
            self:FormatName()
        )

        return
    end

    local character = self.Owner:GetCharacter()

    if not character then
        Addon.Message:SendNotification(
            self.Owner,
            "Vehicles",
            table.concat({
                "You do not have a character... somehow. You should never see this message, and yet you did. I'm sorry you have to see this. This shouldn't have happened. And since it did, ",
                "then there's a fundamental flaw in my code and I am sorry I let that happen. Please forgive me, %s."
            }, ""),
            Addon.Enums.NotificationType.ERROR,
            Addon.Libs.Player:FormatPlayerName(self.Owner)
        )

        return
    end

    character:Seat(self:GetPrimaryBody(), nil, seat.pos.x, seat.pos.y, seat.pos.z)

    Addon.Message:SendNotification(
        self.Owner,
        "Vehicles",
        "You have been placed into a random seat on %s.",
        Addon.Enums.NotificationType.INFO,
        self:FormatName()
    )
end

--[[
    Formats the name of the vehicle.
]]
---@return string
function Addon.Classes.PlayerVehicle:FormatName()
    return Addon.Libs.Vehicle:FormatVehicleName(self.Vehicle)
end

--[[
    Sends the vehicle despawn message.
]]
---@param player NoirPlayer|nil Player to show the message for, or nil for everyone
function Addon.Classes.PlayerVehicle:_SendDespawnMessage(player)
    Addon.Message:SendNotification(
        player,
        "Vehicles",
        "%s's %s has been despawned.",
        Addon.Enums.NotificationType.INFO,
        Addon.Libs.Player:FormatPlayerName(self.Owner),
        self:FormatName()
    )
end

--[[
    To be called whenever the vehicle despawns.
]]
function Addon.Classes.PlayerVehicle:OnDespawn()
    self:Refund()

    if self.HideDespawnMessage then
        for _, player in pairs(Noir.Services.PlayerService:GetPlayers()) do
            if Noir.Services.PlayerService:IsSamePlayer(player, self.Owner) then
                goto continue
            end

            self:_SendDespawnMessage(player)
            ::continue::
        end
    else
        self:_SendDespawnMessage()
    end
end

--[[
    Despawns the vehicle.
]]
---@param omitDespawnMessage boolean|nil Whether or not to omit the despawn message
function Addon.Classes.PlayerVehicle:Despawn(omitDespawnMessage)
    if omitDespawnMessage then
        self:OmitDespawnMessage()
    end

    self.Vehicle:Despawn()
end