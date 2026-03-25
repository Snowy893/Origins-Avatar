local origins = require "origins.origins"
local util = require "lib.util"

local moth = origins.new("snowy:moth")

function moth.emissive()
    return util.isNight() and world.isOpenSky(player:getPos())
end

moth:init()