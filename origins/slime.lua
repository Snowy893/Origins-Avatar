local origins = require "origins.origins"

local slime = origins:new("moborigins:slime")

slime.page = action_wheel:newPage()

local colors = {
    green = { vec(136,179,138) },
    red = { vec(184, 118, 118) },
}

local texture = textures["model.skin"]
local dimensions = texture:getDimensions()

local wobble = origins:wobble(models.model.root)

---@alias Tint
---| "none"
---| "green"
---| "red"

---@param tint Tint
function pings.setColor(tint)
    texture:restore()
    if tint == nil then tint = "green" end
    if tint == "none" then
        texture:update()
        return
    end
    local color = colors[tint]
    texture:applyFunc(0, 0, dimensions.x, dimensions.y,
        function(currentColor, x, y)
            return currentColor:mul(vec(color.x / 255, color.y / 255, color.z / 255, 255 / 255))
        end)
    texture:update()
end

---@param tint Tint
---@param title string
---@param item? Minecraft.itemID
---@return Action
local function colorAction(tint, title, item)
    return action_wheel:newAction()
        :title(title)
        :item(item)
        :onLeftClick(function()
            pings.setColor(tint)
            config:save("slime_tint", tint)
        end)
end

slime.page:setAction(-1, colorAction("none", "Disable Tint", "glass"))
slime.page:setAction(-1, colorAction("green", "Enable Green", "green_wool"))
slime.page:setAction(-1, colorAction("red", "Enable Red", "red_wool"))

slime:init(function (isOrigin)
    wobble:setEnabled(isOrigin)
    if isOrigin then
        pings.setColor(config:load("slime_tint"))
        models.model.root:setOpacity(0.65)
    else
        pings.setColor("none")
        models.model.root:setOpacity(nil)
    end
end)