local origin = require "origins.origin"

local enderian = origin.new("enderian")

enderian.sounds.ambient = sounds["minecraft:entity.enderman.ambient"]:volume(0.6)
enderian.sounds.hurt = sounds["minecraft:entity.enderman.hurt"]:volume(0.6)

---@type Util.AmbientParticle
local portal = {
    id = "minecraft:portal",
    offset = vec(0, 0.5, 0),
    radius = 0.5,
    velocity = 0.01,
}

function portal.condition()
    portal.rate = player:isWet() and 4 or 2
    return world.exists()
end

enderian:newAmbientParticles(portal)

enderian:register()