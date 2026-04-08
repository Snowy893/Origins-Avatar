local origins = require "origins.origin"
local util = require "lib.util"

local blazeborn = origins.new("blazeborn")

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
    flame.id = "minecraft:soul_fire_flame" and hasStrength or "minecraft:flame"
    flame.rate = player:isWet() and 0.5 or (hasStrength and 1.5 or 1)
    return blazeborn.isOrigin
end

util.newAmbientParticles(steam)
util.newAmbientParticles(flame)

local strengthSound = sounds["minecraft:entity.blaze.shoot"]

local fireTicks = 0

function blazeborn.change(toggle)
    if not toggle then
        fireTicks = 0
        renderer:setRenderFire(true)
    end
end

function blazeborn.tick()
    local lastTick = fireTicks
    fireTicks = fireTicks + (player:isOnFire() and 1 or 0)
    if fireTicks == lastTick then
        fireTicks = 0
    end

    if fireTicks == 0 then
        renderer:setRenderFire(true)
    elseif fireTicks == 60 then
        renderer:setRenderFire(false)
        util.playSound(strengthSound)
        util.particleExplosion(flame.id,
            player:getPos():add(0, 1, 0),
            0,
            vec(0.1, 0.1, 0.1),
            20
        )
    end
end

blazeborn:register()