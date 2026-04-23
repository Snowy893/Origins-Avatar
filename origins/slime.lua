local origin = require "origins.origin"
local util = require "lib.util"

local options = require "options".SLIME
local originsapi = require "lib.thirdparty.OriginsAPI"

local slime = origin.new("snowy:slime")

slime.sounds.hurt = sounds["minecraft:entity.slime.hurt"]

local fallSound = "minecraft:entity.slime.squish" ---@type Minecraft.soundID
local landParticleColor = options.PARTICLE_COLOR / 255
local landParticleRadius = vec(0.3, 0, 0.3)
local lastFalling = 0

local leapSound = "minecraft:entity.slime.jump" ---@type Minecraft.soundID
local wasAirSpeed = false

local charge

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

    charge = originsapi.getPowerData(player, "snowy:charged_leap_charge") or 0

    lastFalling = falling
    wasAirSpeed = isAirSpeed
end

if options.ENABLE_WOBBLE then
    local wobbleLib = require "lib.thirdparty.CMwubLib"
    local wobble = wobbleLib:newWobbleSetup()
    local anyArmorPivotDisabled = false
    local wobbleVelocity = 0.04
    local wobbleCrouchMultiplier = 8
    local wasCrouching
    local verticalSquish = 0.9
    local horizontalSquish = 1.035
    local squishDelta = 0

    function util.tick()
        anyArmorPivotDisabled = next(util.getArmorPivotsDisabled()) ~= nil
    end

    function slime.render(_, context)
        if not player:isLoaded() then return end
        local isFirstPerson = context == "FIRST_PERSON"
        local _velocity = anyArmorPivotDisabled and not isFirstPerson and wobbleVelocity / 8 or wobbleVelocity
        local velocity = isFirstPerson and -_velocity * 0.75 or _velocity

        if charge > 2 and player:isSneaking() then
            if squishDelta < 30 then
                squishDelta = math.expDecay(squishDelta, charge, 0.32, math.dt)
            end
            local vertical = math.expDecay(
                1,
                anyArmorPivotDisabled and verticalSquish + 0.08 or verticalSquish,
                0.32,
                squishDelta
            )
            local horizontal = math.expDecay(
                1,
                anyArmorPivotDisabled and horizontalSquish - 0.025 or horizontalSquish,
                0.32,
                squishDelta
            )
            for _, part in ipairs(options.WOBBLE_PARTS) do
                part:setScale(horizontal, vertical, horizontal)
            end
            if isFirstPerson then
                util.getDominantArm():setPos(0, math.expDecay(0, 2, 0.32, squishDelta))
            else
                models.model.root.RightArm:setPos()
                models.model.root.LeftArm:setPos()
            end
            return
        end

        squishDelta = 0
        models.model.root.RightArm:setPos()
        models.model.root.LeftArm:setPos()
        
        wobble:update(player:getVelocity().y, true)

        for _, part in ipairs(options.WOBBLE_PARTS) do
            part:setScale(
                1 + wobble.wobble * velocity / 2,
                1 - wobble.wobble * velocity,
                1 + wobble.wobble * velocity / 2
            )
        end

        local crouching = player:isCrouching()

        if crouching ~= wasCrouching then
            local crouchVelocity = (crouching and velocity or -velocity) * wobbleCrouchMultiplier
            wobble:setWobble(crouchVelocity, crouchVelocity, crouchVelocity)
            wasCrouching = crouching
        end
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
        if options.ENABLE_WOBBLE then
            for _, part in ipairs(options.WOBBLE_PARTS) do
                part:setScale()
            end
        end
        if options.ENABLE_TRANSPARENCY then
            for _, part in ipairs(options.TRANSPARENT_PARTS) do
                part:setPrimaryRenderType()
                part:setOpacity(1)
            end
        end
    end
end

slime:register()