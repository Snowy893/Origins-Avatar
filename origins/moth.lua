local origins = require "origins.origins"
local util = require "lib.util"

local moth = origins.new("snowy:moth")

local buffer = 100
local timer = 0
local wasEmissive

function moth.emissive()
    local emissive = util.isNight() and world.isOpenSky(player:getPos())

    if wasEmissive ~= emissive then
        timer = timer + 1
        if timer == buffer then
            wasEmissive = emissive
            timer = 0
        end
    end

    return wasEmissive
end

function events.entity_init()
    if not moth.isOrigin then return end
    local emissive = util.isNight() and world.isOpenSky(player:getPos())
    moth.partsEmissive(emissive)
    wasEmissive = emissive
end

moth:init()