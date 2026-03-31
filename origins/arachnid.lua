local origins = require "origins.origins"

local arachnid = origins.new("arachnid")

arachnid.emissiveBuffer = 100

function arachnid.emissive()
    return world.getLightLevel(player:getPos()) < 10
end

arachnid:init()