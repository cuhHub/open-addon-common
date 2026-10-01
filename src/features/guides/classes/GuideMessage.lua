--------------------------------------------------------
-- Classes - Guide Message
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
    Represents a message in a guide.
]]
---@class GuideMessage: NoirClass
---@field New fun(self: GuideMessage, content: string): GuideMessage
Addon.Classes.GuideMessage = Noir.Class("GuideMessage")

--[[
    Initializes new `GuideMessage` instances.
]]
---@param content string The content of the message
function Addon.Classes.GuideMessage:Init(content)
    --[[
        The content of the message.
    ]]
    self.Content = content
end

--[[
    Returns the message content.
]]
---@return string
function Addon.Classes.GuideMessage:GetContent()
    return self.Content
end