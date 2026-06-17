local origin = require "origins.origin"
local options = require "options".STRIDER
local util = require "lib.util"

local strider = origin.new("snowy:strider")

if options.ENABLE_SHIVER then
    local timer = 1
    function strider.tick()
        local temperature = world.getBiome(player:getPos()):getTemperature()
        if not player:isOnFire() and temperature < 0.6 then
            timer = timer + 1
            if timer > 41 then
                timer = 1
            end
            models.model.root:setOffsetRot(0, (math.random() - 0.5) * math.lerp(1, 4, (timer / 100) * 2), 0)
        else
            models.model.root:setOffsetRot()
        end
    end
end

function strider.change(toggle)
    renderer:setRenderFire(not toggle)
    if not toggle then
        models.model.root:setOffsetRot()
    end
end

---@type Util.AmbientParticle
local flame = {
    id = "minecraft:flame",
    rate = 6,
    radius = 0.5,
    offset = vec(0, 1, 0),
    velocity = 0.005,
}

function flame.condition()
    return player:isOnFire()
end

strider:newAmbientParticles(flame)

strider:register()