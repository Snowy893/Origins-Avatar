local origin = require "origins.origin"
local originsapi = require "lib.thirdparty.OriginsAPI"
local util = require "lib.util"

local blazeborn = origin.new("blazeborn")

local rods = models.model.root.blazebornRods
    :setScale(0.7, 0.7, 0.7)
    :setPrimaryRenderType("TRANSLUCENT")
    :setLight(vec(15, 15))

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
    end, 80)
end

function flame.condition()
    flame.id = hasStrength and math.random(4) == 1 and "minecraft:soul_fire_flame" or "minecraft:flame"
    flame.rate = player:isWet() and 0.5 or (player:isOnFire() and 4 or 1)
    return blazeborn.isOrigin
end

util.newAmbientParticles(steam)
util.newAmbientParticles(flame)

local strengthSound = sounds["minecraft:entity.blaze.shoot"]

local lastFloat = 0
local lastOnFire = false
local lastFireTicks = 0
local fireTicks = 0

function rodsInvisible()
    rods:setVisible(false)
end

function blazeborn.tick()
    local float = originsapi.getPowerData(player, "snowy:blaze_float_resource")
    local leftHanded = player:isLeftHanded()
    local modelType = models.model.root.RightArm.wideRightArm:getVisible()
    local typeOffset = modelType and 0 or 0.5
    local handedOffset = leftHanded and (-6 + typeOffset) or (6 - typeOffset)

    lastFireTicks = fireTicks

    if player:isOnFire() then
        fireTicks = math.min(40, fireTicks + 1)
    else
        fireTicks = math.max(0, fireTicks - 1)
    end

    local onFire = fireTicks > 30 or float > 0

    if float == 100 and lastFloat ~= 100 then
        util.playSound(strengthSound)
        util.particleExplosion(flame.id,
            player:getPos():add(0, 1, 0),
            0,
            vec(0.1, 0.1, 0.1),
            20
        )
    end

    if fireTicks > lastFireTicks then
        animations.model.blazeborn_rods_transition:stop()
    end

    rods:setParentType(leftHanded and "LeftArm" or "RightArm")
    rods:setPos(handedOffset)

    rods:setOpacity((float > 0 or hasStrength) and 0.5 or 0.4)
    
    local floatBonus = float > 0 and 0.15 or 0
    local strengthBonus = hasStrength and 0.15 or 0
    local speed = 0.8 + floatBonus + strengthBonus

    animations.model.blazeborn_rods:setPlaying(onFire)
        :setSpeed(leftHanded and -speed or speed)

    if onFire ~= lastOnFire then
        if onFire then
            rods:setVisible(true)
        else
            animations.model.blazeborn_rods_transition:stop()
            animations.model.blazeborn_rods_transition:play()
        end
    end

    lastFloat = float
    lastOnFire = onFire
end

function blazeborn.change(toggle)
    if not toggle then
        rods:setVisible(false)
        animations.model.blazeborn_rods:stop()
        animations.model.blazeborn_rods_transition:stop()
    end
end

blazeborn:register()