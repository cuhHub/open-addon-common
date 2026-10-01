--------------------------------------------------------
-- Classes - Guide Message
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