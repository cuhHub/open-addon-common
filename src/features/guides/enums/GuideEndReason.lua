--------------------------------------------------------
-- Enums - Guide End Reason
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
    Represents the reason a guide was ended by a player.
]]
Addon.Enums.GuideEndReason = {
    None = 0,
    Cancelled = 1,
    Finished = 2
}

--[[
    Represents the reason a guide was ended by a player.
]]
---@alias GuideEndReason
---| 0 # None
---| 1 # Cancelled
---| 2 # Finished