local origins = require "origins.origins"
local util = require "lib.util"

local moth = origins.new("snowy:moth")

local wings = models.model.root.Body.MothWings

moth.armorParts = { [5] = { ["minecraft:elytra"] = wings } }

moth.emissiveBuffer = 100

function moth.emissive()
    return util.isNight() and world.isOpenSky(player:getPos())
end

moth:init()