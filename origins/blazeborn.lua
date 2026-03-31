local origins = require "origins.origins"
local util = require "lib.util"

local blazeborn = origins.new("blazeborn")

blazeborn.sounds.ambient = {
    sound = sounds["minecraft:entity.blaze.burn"],
}

blazeborn.sounds.hurt = sounds["minecraft:entity.blaze.hurt"]

function blazeborn.emissive()
    return player:isOnFire()
end

---@type Util.AmbientParticle
local steam = {
    id = client.isModLoaded("farmersdelight")
        and "farmersdelight:steam"
        or "minecraft:campfire_cosy_smoke",
    offset = vec(0, 0.5, 0),
    radius = 0.5,
    velocity = 0.01,
}

function steam.condition()
    steam.rate = player:isInWater() and 5 or 2.5
    return blazeborn.isOrigin and player:isWet()
end

---@type Util.AmbientParticle
local flame = {
    id = "minecraft:flame",
    offset = vec(0, 1, 0),
    radius = 0.5,
    velocity = 0.005,
}

function flame.condition()
    flame.rate = player:isWet() and 0.5 or 1
    return blazeborn.isOrigin
end

util.newAmbientParticles(steam)
util.newAmbientParticles(flame)

blazeborn:init()