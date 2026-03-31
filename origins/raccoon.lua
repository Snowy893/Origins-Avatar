local origins = require "origins.origins"
local squapi = require "lib.thirdparty.SquAPI"

local raccoon = origins.new("snowy:raccoon")

local ears = models.model.root.Head.raccoonEars
local tail = models.model.root.Body.raccoonTail
local helmet = 6 ---@type Entity.slot

raccoon.parts = { ears, tail }
raccoon.partsCoveredByArmor = { [helmet] = { ears } }

raccoon.squishy = {
    squapi.ear:new(ears.raccoonLeftEar, ears.raccoonRightEar,
        0.1,
        false,
        0.25,
        true,
        1000,
        0.08,
        0.95
    ),
    squapi.tail:new({ tail },
        nil,
        nil,
        nil,
        nil,
        nil,
        nil,
        25,
        nil,
        0.006,
        nil,
        60
    ),
}

raccoon:init()
