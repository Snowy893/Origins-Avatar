local origins = require "origins.origins"
local util = require "lib.util"

local moth = origins.new("snowy:moth")

local wings = models.model.root.Body.mothWings
local fluff = models.model.root.Head.mothFluff

-- moth.partsToHide = { [5] = { ["minecraft:elytra"] = wings } }

moth.emissiveBuffer = 100

function moth.emissive()
    return util.isNight() and world.isOpenSky(player:getPos())
end

moth:init()