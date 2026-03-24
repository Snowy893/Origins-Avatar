local origins = require "origins.origins"
local squapi = require "lib.thirdparty.SquAPI"

local horse = origins.new("snowy:horse")

local ears = models.model.root.Head.horseEars
local tail = models.model.root.Body.horseTail

horse.modelParts = { ears, tail }

squapi.ear(ears.horseLeftEar, ears.horseRightEar,
    true,
    1000,
    0.1,
    false,
    0.25,
    0.08,
    0.95
)

squapi.tails(tail,
    3.5,
    nil,
    nil,
    nil,
    nil,
    nil,
    nil,
    nil,
    0.006,
    nil,
    80,
    40,
    20
)

horse:init()