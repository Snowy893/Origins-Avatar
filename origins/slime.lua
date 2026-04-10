local origin = require "origins.origin"
local wobbleLib = require "lib.thirdparty.CMwubLib"
local options = require "options".SLIME
local originsapi = require "lib.thirdparty.OriginsAPI"

local slime = origin.new("snowy:slime")

slime.sounds.hurt = sounds["minecraft:entity.slime.hurt"]

local wobble = wobbleLib:newWobbleSetup()
local wobbleParts = options.WOBBLE_PARTS
local wobbleVelocity = 0.04
local wobbleCrouchMultiplier = 8
local wasCrouching

local fallSound = "minecraft:entity.slime.squish" ---@type Minecraft.soundID
local landParticleColor = options.LAND_PARTICLE_COLOR / 255
local landParticleRadius = vec(0.3, 0, 0.3)
local lastFalling = 0

local leapSound = "minecraft:entity.slime.jump" ---@type Minecraft.soundID
local wasAirSpeed = false

function slime.tick()
    local falling = player:getNbt().FallDistance
    local pos = player:getPos()

    if falling < lastFalling and lastFalling > 2.5 and player:isOnGround() then
        for _ = 1, 10 do
            particles:newParticle("minecraft:item_slime",
                pos.x + math.lerp(-landParticleRadius.x, landParticleRadius.x, math.random()),
                pos.y + math.lerp(-landParticleRadius.y, landParticleRadius.y, math.random()),
                pos.z + math.lerp(-landParticleRadius.z, landParticleRadius.z, math.random()),
                1, 1, 1
            ):color(landParticleColor)
        end

        if not player:isSneaking() then
            sounds:playSound(fallSound, pos)
        end
    end

    local isAirSpeed = originsapi.getPowerData(player, "snowy:charged_leap_air_speed_toggle") == 1

    if isAirSpeed and not wasAirSpeed then
        sounds:playSound(leapSound, pos)
    end

    lastFalling = falling
    wasAirSpeed = isAirSpeed
end

function slime.render()
    if not player:isLoaded() then return end

    local crouching = player:isCrouching()
    wobble:update(player:getVelocity().y, true)

    for _, part in ipairs(wobbleParts) do
        part:setScale(
            1 + wobble.wobble * wobbleVelocity / 2,
            1 - wobble.wobble * wobbleVelocity,
            1 + wobble.wobble * wobbleVelocity / 2
        )
    end

    if crouching ~= wasCrouching then
        local vel = (crouching and wobbleVelocity or -wobbleVelocity) * wobbleCrouchMultiplier
        wobble:setWobble(vel, vel, vel)
        wasCrouching = crouching
    end
end

function slime.change(toggle)
    if toggle then
        if options.ENABLE_TRANSPARENCY then
            options.TRANSPARENCY = math.clamp(options.TRANSPARENCY, 0.3, 1)
            for _, part in ipairs(options.TRANSPARENT_PARTS) do
                part:setPrimaryRenderType("TRANSLUCENT_CULL")
                part:setOpacity(options.TRANSPARENCY)
            end
        end
    else
        for _, part in ipairs(wobbleParts) do
            part:setScale()
        end
        for _, part in ipairs(options.TRANSPARENT_PARTS) do
            part:setPrimaryRenderType()
            part:setOpacity(1)
        end
    end
end

slime:register()