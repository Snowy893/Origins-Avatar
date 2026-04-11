local origin = require "origins.origin"
local originsapi = require "lib.thirdparty.OriginsAPI"
local util = require "lib.util"

local blazeborn = origin.new("blazeborn")

blazeborn.sounds.ambient = sounds["minecraft:entity.blaze.burn"]:volume(0.9):pitch(0.9)
blazeborn.sounds.hurt = sounds["minecraft:entity.blaze.hurt"]:volume(0.9):pitch(0.9)

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

local hasStrength

---@param toggle boolean
function pings.hasStrength(toggle)
    hasStrength = toggle
end

if host:isHost() then
    util.tick:register(function()
        if not blazeborn.isOrigin then return end
        for _, effect in ipairs(host:getStatusEffects()) do
            if util.getEffect(effect.name) == "effect.minecraft.strength" then
                pings.hasStrength(true)
            end
            return
        end
        pings.hasStrength(false)
    end, 100)
end

function flame.condition()
    flame.id = hasStrength and "minecraft:soul_fire_flame" or "minecraft:flame"
    flame.rate = player:isWet() and 0.5 or (player:isOnFire() and 4 or 1)
    return blazeborn.isOrigin
end

util.newAmbientParticles(steam)
util.newAmbientParticles(flame)

local strengthSound = sounds["minecraft:entity.blaze.shoot"]

local lastFloat = 0
function blazeborn.tick()
    local float = originsapi.getPowerData(player, "snowy:blaze_float_resource")
    if float == 100 and lastFloat ~= 100 then
        util.playSound(strengthSound)
        util.particleExplosion(flame.id,
            player:getPos():add(0, 1, 0),
            0,
            vec(0.1, 0.1, 0.1),
            20
        )
    end
    lastFloat = float
end

blazeborn:register()