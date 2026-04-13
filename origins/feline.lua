local origin = require "origins.origin"
local squapi = require "lib.thirdparty.SquAPI"

local feline = origin.new("feline")

local ears = models.model.root.Head.felineEars
local tail = models.model.root.Body.felineTail
local helmet = 6 ---@type Entity.slot
local earsTexture = "textures.feline.feline_ears_"
local tailTexture = "textures.feline.feline_tail_"

feline.parts = { ears, tail }
feline.partsCoveredByArmor = { [helmet] = { ears } }

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

feline.variants.red = {
    name = "Ginger",
    item = "minecraft:orange_wool",
    textureParts = {
        {
            part = ears,
            texture = textures[earsTexture.."red"],
        },
        {
            part = tail,
            texture = textures[tailTexture.."red"],
        },
    }
}

feline.variants.white = {
    name = "White",
    item = "minecraft:white_wool",
    textureParts = {
        {
            part = ears,
            texture = textures[earsTexture.."white"]
        },
        {
            part = tail,
            texture = textures[tailTexture.."white"]
        },
    },
}

feline.squishy = {
    squapi.ear:new(ears.felineLeftEar, ears.felineRightEar,
        0.1,
        false,
        0.3,
        true,
        1000,
        0.02,
        0.95,
        10
    ),
    squapi.tail:new({ tail, tail.felineTail2 },
        14,
        nil,
        nil,
        nil,
        1.9,
        nil,
        nil,
        nil,
        nil,
        0.8,
        60
    ),
}

feline:register()