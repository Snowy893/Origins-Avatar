local origins = require "origins.origins"
local util = require "lib.util"

local moth = origins.new("snowy:moth")

moth.emissiveBuffer = 100

function moth.emissive()
    return util.isNight() and world.isOpenSky(player:getPos())
end

moth:init()