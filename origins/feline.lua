local origins = require "origins.origins"
local squapi = require "lib.thirdparty.SquAPI"

local feline = origins.new("feline")

local ears = models.model.root.Head.felineEars
local earsTexture = "textures.feline.feline_ears_"

local tail = models.model.root.Body.felineTail
local tailTexture = "textures.feline.feline_tail_"

feline.sounds.ambient = {
    sound = sounds["minecraft:entity.cat.ambient"]:volume(0.6),
}

feline.sounds.hurt = sounds["minecraft:entity.cat.hurt"]:volume(0.6)

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