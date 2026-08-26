--------------------------------------------------------
-- Classes - Physical Interaction
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
    Represents a deployable physical interaction (e.g. inventory, call-in).<br>
    This is meant to be extended.
]]
---@class PhysicalInteraction: PrefabInstance
---@field New fun(self: PhysicalInteraction, player: NoirPlayer, prefab: PhysicalInteractionPrefab): PhysicalInteraction
---@field Prefab PhysicalInteractionPrefab
---@field GetPrefab fun(self: PhysicalInteraction): PhysicalInteractionPrefab
Addon.Classes.PhysicalInteraction = Noir.Class("PhysicalInteraction", Addon.Classes.PrefabInstance)

--[[
    Initializes new `PhysicalInteraction` instances.
]]
---@param player NoirPlayer The player this interaction belongs to
---@param prefab PhysicalInteractionPrefab The prefab for this interaction
function Addon.Classes.PhysicalInteraction:Init(player, prefab)
    self:InitFrom(Addon.Classes.PrefabInstance, prefab)

    --[[
        The player this interaction belongs to.
    ]]
    self.Player = player

    --[[
        The spawned vehicle for this interaction.
    ]]
    ---@type NoirVehicle
    self.Vehicle = nil

    --[[
        The popup widget for this interaction.
    ]]
    ---@type NoirPopupWidget|nil
    self.PopupWidget = nil

    --[[
        Whether or not the interaction is currently deployed.
    ]]
    self.Deployed = false

    --[[
        The offset between the interaction and the player, determined every deployment.
    ]]
    self.DeployedOffset = matrix.identity()

    --[[
        The interaction pitch rotation.
    ]]
    self.PITCH_ROTATION = Config.PhysicalInteractions.PitchRotation

    --[[
        The interaction offset from the player when deployed.
    ]]
    self.POSITION_OFFSET = Config.PhysicalInteractions.PositionOffset

    --[[
        The interaction battery name.
    ]]
    self.BATTERY_NAME = Config.PhysicalInteractions.BatteryName

    --[[
        The retract button name.
    ]]
    self.RETRACT_BUTTON_NAME = Config.PhysicalInteractions.RetractButtonName

    --[[
        The auto-retract task, if it exists.
    ]]
    ---@type NoirTask|nil
    self.AutoRetractTask = nil

    --[[
        A table of button press connections, indexed by button name.
    ]]
    ---@type table<string, NoirConnection>
    self.ButtonPressConnections = {}
end

--[[
    Listens for a button press on the interaction vehicle.
]]
---@param buttonName string The name of the button to listen for
---@param callback fun(player: NoirPlayer) The callback to fire when the button is pressed
function Addon.Classes.PhysicalInteraction:ListenForButtonPress(buttonName, callback)
    if not self:IsSpawned() then
        error("Addon.Classes.PhysicalInteraction:ListenForButton()", "Interaction is not spawned.")
    end

    ---@param player NoirPlayer|nil
    ---@param _buttonName string
    ---@param isPressed boolean
    local connection = self.Vehicle.PrimaryBody.OnButtonPress:Connect(function(player, _buttonName, isPressed)
        if _buttonName ~= buttonName then
            return
        end

        if not isPressed then
            return
        end

        if not player then
            return
        end

        if not Noir.Services.PlayerService:IsSamePlayer(player, self.Player) then
            return
        end

        callback(player)
    end)

    self.ButtonPressConnections[buttonName] = connection
end

--[[
    Returns if the interaction is spawned or not.
]]
---@return boolean
function Addon.Classes.PhysicalInteraction:IsSpawned()
    return self.Vehicle ~= nil
end

--[[
    Returns if the interaction is deployed or not.
]]
---@return boolean
function Addon.Classes.PhysicalInteraction:IsDeployed()
    return self.Deployed
end

--[[
    Returns the current position of the interaction.
]]
---@return SWMatrix
function Addon.Classes.PhysicalInteraction:GetPosition()
    return self.Vehicle:GetPosition()
end

--[[
    Returns the deployed offset.
]]
---@return SWMatrix
function Addon.Classes.PhysicalInteraction:GetDeployedOffset()
    return self.DeployedOffset
end

--[[
    Sets the deployed offset.
]]
---@param offset SWMatrix The new deployed offset
function Addon.Classes.PhysicalInteraction:SetDeployedOffset(offset)
    self.DeployedOffset = offset
end

--[[
    Cancels auto-retract task (if possible).
]]
function Addon.Classes.PhysicalInteraction:CancelAutoRetract()
    if self.AutoRetractTask then
        self.AutoRetractTask:Remove()
        self.AutoRetractTask = nil
    end
end

--[[
    Teleports the interaction to the given position.
]]
---@param position SWMatrix The position to teleport the interaction to
---@param instant boolean|nil If the teleport should be instant
function Addon.Classes.PhysicalInteraction:Teleport(position, instant)
    if not self:IsSpawned() then
        error("Addon.Classes.PhysicalInteraction:Teleport()", "Interaction is not spawned.")
    end

    if instant then
        self.Vehicle:Move(position)
        return
    end

    self.Vehicle:Teleport(position)
end

--[[
    Attempts to deploy the interaction, returning a fail reason if it cannot.
]]
---@return boolean, PhysicalInteractionDeployFailReason
function Addon.Classes.PhysicalInteraction:TryDeploy()
    if not self:IsSpawned() then
        return false, Addon.Enums.PhysicalInteractionDeployFailReason.NotSpawned
    end

    if self:IsDeployed() then
        return false, Addon.Enums.PhysicalInteractionDeployFailReason.AlreadyDeployed
    end

    if Addon.PhysicalInteractions:IsPositionTooCloseToVehicle(self:GetDeployedPosition()) then
        return false, Addon.Enums.PhysicalInteractionDeployFailReason.TooCloseToVehicle
    end

    self:Deploy()
    return true, Addon.Enums.PhysicalInteractionDeployFailReason.None
end

--[[
    Deploys the interaction.
]]
function Addon.Classes.PhysicalInteraction:Deploy()
    if not self:IsSpawned() then
        error("Addon.Classes.PhysicalInteraction:Deploy()", "Interaction is not spawned.")
    end

    if self:IsDeployed() then
        error("Addon.Classes.PhysicalInteraction:Deploy()", "Interaction is already deployed.")
    end

    local deployedInteraction = Addon.PhysicalInteractions:GetPlayerDeployedInteraction(self.Player)

    if deployedInteraction and deployedInteraction ~= self then
        deployedInteraction:Retract(Addon.Enums.PhysicalInteractionRetractReason.None, true)
    end

    local targetPosition, offset = self:GetDeployedPosition()

    if Addon.PhysicalInteractions:IsPositionTooCloseToVehicle(targetPosition) then
        error("Addon.Classes.PhysicalInteraction:Deploy()", "Interaction target position is too close to a vehicle.")
    end

    self:SetDeployedOffset(offset)
    self:Teleport(targetPosition)
    Addon.Effects:SpawnFlashEffect(targetPosition)

    self.Deployed = true

    Addon.Logger:Debug("PhysicalInteraction: '%s' deployed for %s (%s)",
        self:GetPrefab():GetName(),
        self.Player.Name,
        self.Player.Steam
    )

    self:OnDeploy()

    self.AutoRetractTask = Noir.Services.TaskService:AddTimeTask(function()
        if not self:IsDeployed() then
            return
        end

        self:Retract(Addon.Enums.PhysicalInteractionRetractReason.AutoRetract, true)
    end, self:GetPrefab():GetLifetime())
end

--[[
    Retracts the interaction.
]]
---@param reason PhysicalInteractionRetractReason The reason for retraction
---@param hideNotification boolean|nil Whether or not to hide the notification
function Addon.Classes.PhysicalInteraction:Retract(reason, hideNotification)
    if not self:IsSpawned() then
        error("Addon.Classes.PhysicalInteraction:Retract()", "Interaction is not spawned.")
    end

    if not self:IsDeployed() then
        error("Addon.Classes.PhysicalInteraction:Retract()", "Interaction is not deployed.")
    end

    Addon.Effects:SpawnFlashEffect(self:GetPosition())

    self.Deployed = false
    self:CancelAutoRetract()
    self:Teleport(matrix.identity())

    Addon.Logger:Debug("PhysicalInteraction: '%s' retracted for %s (%s) - Reason: %s",
        self:GetPrefab():GetName(),
        self.Player.Name,
        self.Player.Steam,
        reason
    )

    self:OnRetract(reason)
end

--[[
    Creates UI for the interaction.
]]
function Addon.Classes.PhysicalInteraction:CreateUI()
    if not self:IsSpawned() then
        error("Addon.Classes.PhysicalInteraction:CreateUI()", "Interaction is not spawned.")
    end

    self.PopupWidget = Noir.Services.UIService:CreatePopup(
        self:GetPrefab():GetName(),
        matrix.identity(),
        Config.PhysicalInteractions.PopupRenderDistance,
        true,
        self.Player
    )

    self.PopupWidget.AttachmentOffset = matrix.translation(0, Config.PhysicalInteractions.PopupYOffset, 0)
    self.PopupWidget:AttachToBody(self.Vehicle.PrimaryBody)

    Addon.Janitor:DisposeWidget(self.PopupWidget)
end

--[[
    Spawns the interaction.
]]
---@return NoirVehicle
function Addon.Classes.PhysicalInteraction:Spawn()
    if self:IsSpawned() then
        error("Addon.Classes.PhysicalInteraction:Spawn()", "Interaction is already spawned.")
    end

    local asset = self:GetPrefab():GetAsset()
    self.Vehicle = asset:SpawnVehicle(matrix.identity())

    Addon.Janitor:DisposeVehicle(self.Vehicle)

    self:CreateUI()

    self:ListenForButtonPress(self.RETRACT_BUTTON_NAME, function(player)
        if self:IsDeployed() then
            self:Retract(Addon.Enums.PhysicalInteractionRetractReason.None)
        end
    end)

    Addon.Logger:Debug("PhysicalInteraction: '%s' spawned for %s (%s)",
        self:GetPrefab():GetName(),
        self.Player.Name,
        self.Player.Steam
    )

    self:OnSpawn()

    return self.Vehicle
end

--[[
    Teleports the interaction to be offset from the player. Call every update.
]]
function Addon.Classes.PhysicalInteraction:Follow()
    if not self:IsSpawned() then
        error("Addon.Classes.PhysicalInteraction:Follow()", "Interaction is not spawned.")
    end

    if not self:IsDeployed() then
        error("Addon.Classes.PhysicalInteraction:Follow()", "Interaction is not deployed.")
    end

    self:Teleport(matrix.multiply(self.Player:GetPosition(), self:GetDeployedOffset()), true)
end

--[[
    Replenishes the interaction vehicle (recharge, etc.).
]]
function Addon.Classes.PhysicalInteraction:Replenish()
    if not self:IsSpawned() then
        error("Addon.Classes.PhysicalInteraction:Replenish()", "Interaction is not spawned.")
    end

    self.Vehicle.PrimaryBody:SetBattery(self.BATTERY_NAME, 1)
end

--[[
    Returns the position the interaction should be at when deployed, and returns the position offset matrix.
]]
---@return SWMatrix, SWMatrix
function Addon.Classes.PhysicalInteraction:GetDeployedPosition()
    if not self:IsSpawned() then
        error("Addon.Classes.PhysicalInteraction:GetDeployedPosition()", "Interaction is not spawned.")
    end

    -- cheers LittleGroove: https://discord.com/channels/357480372084408322/905791966904729611/1169353889104023572 (stormworks official discord)
    local playerPosition = self.Player:GetPosition()
    local lookX, _, lookZ = self.Player:GetLook()
    local offset = matrix.translation(lookX * self.POSITION_OFFSET, 0, lookZ * self.POSITION_OFFSET)

    playerPosition = matrix.multiply(playerPosition, offset)
    playerPosition = matrix.multiply(playerPosition, matrix.rotationToFaceXZ(-lookX, -lookZ))

    return matrix.multiply(playerPosition, matrix.rotationX(self.PITCH_ROTATION)), offset
end

--[[
    Returns if the interaction is too close to a vehicle.
]]
---@return boolean
function Addon.Classes.PhysicalInteraction:IsTooCloseToVehicle()
    if not self:IsSpawned() then
        error("Addon.Classes.PhysicalInteraction:IsTooCloseToVehicle()", "Interaction is not spawned.")
    end

    if not self:IsDeployed() then
        return false
    end

    return Addon.PhysicalInteractions:IsPositionTooCloseToVehicle(self:GetPosition())
end

--[[
    Checks if the interaction is too close to a vehicle, and retracts it and returns true if so.<br>
    Call every update.
]]
function Addon.Classes.PhysicalInteraction:CheckTooCloseToVehicle()
    if not self:IsSpawned() then
        error("Addon.Classes.PhysicalInteraction:CheckTooCloseToVehicle()", "Interaction is not spawned.")
    end

    if not self:IsDeployed() then
        error("Addon.Classes.PhysicalInteraction:CheckTooCloseToVehicle()", "Interaction is not deployed.")
    end

    if self:IsTooCloseToVehicle() then
        self:Retract(Addon.Enums.PhysicalInteractionRetractReason.TooCloseToVehicle, true)
    end
end

--[[
    Updates the interaction.
]]
function Addon.Classes.PhysicalInteraction:Update()
    if not self:IsSpawned() then
        return
    end

    if not self:IsDeployed() then
        return
    end

    self:Replenish()
    self:Follow()
    self:CheckTooCloseToVehicle()
    self:OnUpdate()
end

--[[
    Cleans up the interaction (internally).
]]
function Addon.Classes.PhysicalInteraction:Cleanup()
    self:CancelAutoRetract()

    for _, connection in pairs(self.ButtonPressConnections) do
        connection:Disconnect()
    end

    self.ButtonPressConnections = {}

    if self.PopupWidget then
        self.PopupWidget:Destroy()
        self.PopupWidget = nil
    end

    self:OnCleanup()
end

--[[
    Despawns the interaction.
]]
function Addon.Classes.PhysicalInteraction:Despawn()
    if not self:IsSpawned() then
        error("Addon.Classes.PhysicalInteraction:Despawn()", "Interaction is not spawned.")
    end

    self.Vehicle:Despawn()
    self.Vehicle = nil

    self:Cleanup()

    Addon.Logger:Debug("PhysicalInteraction: '%s' despawned for %s (%s)",
        self:GetPrefab():GetName(),
        self.Player.Name,
        self.Player.Steam
    )

    self:OnDespawn()
end

--[[
    Called on deploy.<br>
    *abstractmethod*
]]
function Addon.Classes.PhysicalInteraction:OnDeploy() end

--[[
    Called on retract.<br>
    *abstractmethod*
]]
---@param reason PhysicalInteractionRetractReason The reason for retraction
function Addon.Classes.PhysicalInteraction:OnRetract(reason) end

--[[
    Called on spawn.<br>
    *abstractmethod*
]]
function Addon.Classes.PhysicalInteraction:OnSpawn() end

--[[
    Called on despawn.<br>
    *abstractmethod*
]]
function Addon.Classes.PhysicalInteraction:OnDespawn() end

--[[
    Called on cleanup.<br>
    *abstractmethod*
]]
function Addon.Classes.PhysicalInteraction:OnCleanup() end

--[[
    Called on update.<br>
    *abstractmethod*
]]
function Addon.Classes.PhysicalInteraction:OnUpdate() end
