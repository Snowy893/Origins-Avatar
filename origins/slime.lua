local origins = require "origins.origin"
local wobbleLib = require "lib.thirdparty.CMwubLib"
local options = require "options"

local slime = origins.new("snowy:slime")

local wobble = wobbleLib:newWobbleSetup()
local wobblePart = options.WOBBLE_PART
local wasCrouching
local wobbleVelocity = 0.12
local wobbleCrouchMultiplier = 2

local fallSound = "minecraft:entity.slime.jump" ---@type Minecraft.soundID
local landParticleRadius = vec(0.3, 0, 0.3)
local wasOnGround = false
local lastFalling = 0

if options.ENABLE_SLIME_TRANSPARENCY then
    options.TRANSPARENT_PART:setPrimaryRenderType("TRANSLUCENT_CULL")
    options.SLIME_TRANSPARENCY = math.clamp(options.SLIME_TRANSPARENCY, 0.3, 1)
    options.TRANSPARENT_PART:setOpacity(options.SLIME_TRANSPARENCY)
end

function slime.tick()
    local grounded = player:isOnGround()

    if grounded and not wasOnGround and lastFalling < -0.5 then
        local pos = player:getPos()

        for _ = 1, 10 do
            particles:newParticle("minecraft:item_slime",
                pos.x + math.lerp(-landParticleRadius.x, landParticleRadius.x, math.random()),
                pos.y + math.lerp(-landParticleRadius.y, landParticleRadius.y, math.random()),
                pos.z + math.lerp(-landParticleRadius.z, landParticleRadius.z, math.random()),
                1, 1, 1
            )
        end

        if not player:isSneaking() then
            sounds:playSound(fallSound, pos)
        end
    end

    wasOnGround = grounded
    lastFalling = player:getVelocity().y
end

function slime.render()
    if not player:isLoaded() then return end

    local crouching = player:isCrouching()
    wobble:update(player:getVelocity().y, true)

    wobblePart:setScale(
        1 + wobble.wobble * wobbleVelocity / 2,
        1 - wobble.wobble * wobbleVelocity,
        1 + wobble.wobble * wobbleVelocity / 2
    )

    if crouching ~= wasCrouching then
        local vel = (crouching and wobbleVelocity or -wobbleVelocity) * wobbleCrouchMultiplier
        wobble:setWobble(vel, vel, vel)
        wasCrouching = crouching
    end
end

function slime.change(toggle)
    if not toggle then wobblePart:setScale() end
end

slime:register()