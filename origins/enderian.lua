local origins = require "origins.origins"
local util = require "lib.util"

local enderian = origins.new("enderian")

enderian.sounds.ambient = {
    sound = sounds["minecraft:entity.enderman.ambient"],
}

enderian.sounds.hurt = sounds["minecraft:entity.enderman.hurt"]

---@type Util.AmbientParticle
local portal = {
    id = "minecraft:portal",
    offset = vec(0, 0.5, 0),
    radius = 0.5,
    velocity = 0.01,
}

function portal.condition()
    portal.rate = player:isWet() and 4 or 2
    return enderian.isOrigin
end

util.newAmbientParticles(portal)

enderian:register()