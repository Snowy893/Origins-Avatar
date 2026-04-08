local origins = require "origins.origin"
local squapi = require "lib.thirdparty.SquAPI"
local util = require "lib.util"

local avian = origins.new("avian")

local wings = models.model.root.Body.avianWings:setScale(0.9, 0.9, 0.9)
local feathers = models.model.root.Head.avianFeathers

avian.parts = { wings, feathers }

avian.squishy = {
    squapi.tail:new({ wings.avianRightWing },
        4.5,
        3.5,
        0.8,
        0.5,
        0.58,
        nil,
        1,
        nil,
        0.006,
        nil,
        0,
        -0.5,
        nil
    ),
    squapi.tail:new({ wings.avianLeftWing },
        4.5,
        3.5,
        0.8,
        0.4,
        0.58,
        nil,
        12,
        nil,
        0.006,
        nil,
        0,
        -0.5,
        nil
    ),
}

util.tick:register(function()
    if not avian.isOrigin or not player:isSneaking() or player:isOnGround() then return end

    local pos = player:getPos()
    local fallSpeed = player:getVelocity().y
    local inAir = world.getBlockState(pos.x, pos.y - 0.01, pos.z):isAir()

    if fallSpeed > 0 then fallSpeed = 0 end

    if inAir then
        animations.model.avian_flap:stop()
        animations.model.avian_flap:play()
        particles:newParticle("cloud",
            pos.x,
            pos.y - 0.4,
            pos.z,
            (math.random() - 0.5) / 5,
            ((math.random() - 0.5) / 5) + fallSpeed,
            (math.random() - 0.5) / 5
        ):scale(0.82)
    end
end, 3)

avian:register()