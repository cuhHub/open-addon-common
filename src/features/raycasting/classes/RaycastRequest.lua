--------------------------------------------------------
-- Classes - Raycast Request
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
    Represents a raycast request.
]]
---@class RaycastRequest: NoirClass
---@field New fun(self: RaycastRequest, position: SWMatrix): RaycastRequest
Addon.Classes.RaycastRequest = Noir.Class("RaycastRequest")

--[[
    Initializes new `RaycastRequest` instances.
]]
---@param position SWMatrix The position to raycast downwards from
function Addon.Classes.RaycastRequest:Init(position)
    --[[
        The position to raycast downwards from.
    ]]
    self.Position = position

    --[[
        The state of the raycast request.
    ]]
    self.State = Addon.Enums.RaycastRequestState.Queued

    --[[
        An event fired when the raycast request is moved.<br>
        Arguments: result (RaycastResult)
    ]]
    self.OnDone = Noir.Libraries.Events:Create()

    --[[
        The tick count when state was set to Moved.
    ]]
    self.MovedTickCount = 0

    --[[
        The ticks to wait before state can be proceeded from Moved.
    ]]
    self.MOVED_PROGRESS_TICK_INTERVAL = 2
end

--[[
    Returns the position to raycast downwards from.
]]
---@return SWMatrix
function Addon.Classes.RaycastRequest:GetPosition()
    return self.Position
end

--[[
    Returns the request state.
]]
---@return RaycastRequestState
function Addon.Classes.RaycastRequest:GetState()
    return self.State
end

--[[
    Sets the state.
]]
---@param state RaycastRequestState The new state
function Addon.Classes.RaycastRequest:SetState(state)
    local currentState = self:GetState()

    if currentState == state then
        error(
            "Addon.Classes.RaycastRequest:SetState()",
            "Attempted to set state to %s when that is already the current state",
            state
        )
    end

    self.State = state

    if state == Addon.Enums.RaycastRequestState.Moved then
        self:UpdateMovedTickCount()
    end
end

--[[
    Updates the moved tick count.
]]
function Addon.Classes.RaycastRequest:UpdateMovedTickCount()
    if self:GetState() ~= Addon.Enums.RaycastRequestState.Moved then
        error("Addon.Classes.RaycastRequest:UpdateMovedTickCount()", "Raycast request state is not `Moved`")
    end

    self.MovedTickCount = Noir.Services.TaskService.Ticks
end

--[[
    Returns if state has been `Moved` for long enough.
]]
---@return boolean
function Addon.Classes.RaycastRequest:HasBeenMovedStatedLongEnough()
    if self:GetState() ~= Addon.Enums.RaycastRequestState.Moved then
        error("Addon.Classes.RaycastRequest:HasBeenMovedStatedLongEnough()", "Raycast request state is not `Moved`")
    end

    return Noir.Services.TaskService.Ticks - self.MovedTickCount >= self.MOVED_PROGRESS_TICK_INTERVAL
end

--[[
    Marks the request as done.
]]
---@param result RaycastResult The raycast result
function Addon.Classes.RaycastRequest:Done(result)
    if self:GetState() == Addon.Enums.RaycastRequestState.Done then
        error("Addon.Classes.RaycastRequest:Done()", "Raycast request is already done")
    end

    self:SetState(Addon.Enums.RaycastRequestState.Done)
    self.OnDone:Fire(result)
end