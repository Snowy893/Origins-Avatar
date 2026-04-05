local origins = require "origins.origins"
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
        0.48,
        0.4,
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
        0.48,
        nil,
        9,
        nil,
        0.006,
        nil,
        0,
        -0.5,
        nil
    ),
}

util.tick:register(function()
    if not player:isSneaking() or player:isOnGround() then return end

    local pos = player:getPos()
    local block = world.getBlockState(vec(pos.x, pos.y - 0.01, pos.z))
    local inAir = block.id == "minecraft:air" or block.id == "minecraft:cave_air" or block.id == "minecraft:void_air"

    if inAir then
        animations.model.avian_flap:stop()
        animations.model.avian_flap:play()
        particles:newParticle("cloud", pos, vec(
            (math.random() - 0.5) / 6,
            (math.random() - 0.5) / 6,
            (math.random() - 0.5) / 6
        ))
    end
end, 3)

avian:register()