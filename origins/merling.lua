local origins = require "origins.origins"
local squapi = require "lib.thirdparty.SquAPI"

local merling = origins.new("merling")

local headFins = models.model.root.Head.merlingFins
local backFin = models.model.root.Body.merlingBackFin

merling.sounds.hurt = sounds["minecraft:entity.salmon.hurt"]:volume(0.6)

merling.parts = { headFins, backFin }

merling.squishy = {
    squapi.ear:new(headFins.merlingLeftFin, headFins.merlingRightFin,
        0.25,
        true,
        0.1,
        true,
        1200,
        0.1,
        0.8,
        5
    ),
    squapi.tail:new({ backFin },
        4,
        0.0,
        nil,
        0.0,
        0.2,
        nil,
        nil,
        nil,
        0.008,
        0.0,
        0,
        0,
        0
    ),
}

merling:register()