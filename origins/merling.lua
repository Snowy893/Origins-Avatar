local origins = require "origins.origins"
local util = require "lib.util"

local merling = origins.new("origins:merling")

function merling.emissive()
    return player:isInRain() or player:isInWater() and world.getBlockState(util.eyePos(player)).id == "minecraft:water"
end

merling:init()