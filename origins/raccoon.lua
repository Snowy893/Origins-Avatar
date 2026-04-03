local origins = require "origins.origins"
local squapi = require "lib.thirdparty.SquAPI"

local raccoon = origins.new("snowy:raccoon")

local ears = models.model.root.Head.raccoonEars
local tail = models.model.root.Body.raccoonTail
local helmet = 6 ---@type Entity.slot

raccoon.sounds.hurt = sounds["minecraft:entity.bat.hurt"]:pitch(0.6)

raccoon.parts = { ears, tail }
raccoon.partsCoveredByArmor = { [helmet] = { ears } }

raccoon.squishy = {
    squapi.ear:new(ears.raccoonLeftEar, ears.raccoonRightEar,
        0.1,
        false,
        0.25,
        true,
        1000,
        0.02,
        0.95,
        10
    ),
    squapi.tail:new({ tail },
        13,
        nil,
        nil,
        nil,
        nil,
        nil,
        nil,
        nil,
        nil,
        0.8,
        60
    ),
}

raccoon:register()
