local origins = require "origins.origin"
local wobbleLib = require "lib.thirdparty.CMWubLib"

local slime = origins.new("snowy:slime")

local wobble = wobbleLib:newWobbleSetup()
local wobblePart = models.model.root
local wasCrouching
local velocity = 0.4

function slime.render()
    if not player:isLoaded() then return end

    local crouching = player:isCrouching()
    wobble:update(player:getVelocity().y, true)

    wobblePart:setScale(
        1 + wobble.wobble * velocity / 2,
        1 - wobble.wobble * velocity,
        1 + wobble.wobble * velocity / 2
    )

    if crouching ~= wasCrouching then
        local vel = crouching and velocity or -velocity
        wobble:setWobble(vel, vel, vel)
        wasCrouching = crouching
    end
end

function slime.change(toggle)
    if not toggle then wobblePart:setScale() end
end

slime:register()