local origins = require "origins.origins"
local squapi = require "lib.thirdparty.SquAPI"

local feline = origins.new("feline")

local ears = models.model.root.Head.felineEars
local earsTexture = "textures.feline.feline_ears_"

local tail = models.model.root.Body.felineTail
local tailTexture = "textures.feline.feline_tail_"

feline.parts = { ears, tail }

feline.variants.black = {
    name = "Black",
    item = "minecraft:black_wool",
    textureParts = {
        {
            part = ears, 
            texture = textures[earsTexture.."black"],
        },
        {
            part = tail,
            texture = textures[tailTexture.."black"]
        }
    },
}

feline.variants.ginger = {
    name = "Ginger",
    item = "minecraft:orange_wool",
    textureParts = {
        {
            part = ears,
            texture = textures[earsTexture.."ginger"],
        },
        {
            part = tail,
            texture = textures[tailTexture.."ginger"],
        },
    }
}

squapi.ear(ears.felineRightEar, ears.felineLeftEar,
    true,
    1000,
    0.1,
    false,
    0.25,
    0.08,
    0.95
)

squapi.tails({ tail, tail.felineTail2 },
    0.75,
    nil,
    nil,
    nil,
    nil,
    nil,
    0,
    nil,
    nil,
    nil,
    60
)

feline:init()