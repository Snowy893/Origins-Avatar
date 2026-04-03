local origins = require "origins.origins"
local squapi = require "lib.thirdparty.SquAPI"

local horse = origins.new("snowy:horse")

local ears = models.model.root.Head.horseEars
local tail = models.model.root.Body.horseTail
local helmet = 6 ---@type Entity.slot

horse.sounds.ambient = {
    sound = sounds["minecraft:entity.horse.ambient"]:volume(0.6),
}

horse.sounds.hurt = sounds["minecraft:entity.horse.hurt"]

horse.parts = { ears, tail }
horse.partsCoveredByArmor = { [helmet] = { ears } }

horse.squishy = {
    squapi.ear:new(ears.horseLeftEar, ears.horseRightEar,
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
        nil,
        nil,
        nil,
        nil,
        nil,
        nil,
        nil,
        nil,
        0.006,
        nil,
        35,
        -0.5,
        nil
    ),
}

horse:register()