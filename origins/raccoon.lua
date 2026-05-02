local origin = require "origins.origin"
local originsapi = require "lib.thirdparty.OriginsAPI"
local squapi = require "lib.thirdparty.SquAPI"

local raccoon = origin.new("snowy:raccoon")

local ears = models.model.root.Head.raccoonEars
local tail = models.model.root.Body.raccoonTail
local helmet = 6 ---@type Entity.slot
local earsTexture = "textures.raccoon.raccoon_ears"
local tailTexture = "textures.raccoon.raccoon_tail"

raccoon.parts = { ears, tail }
raccoon.partsCoveredByArmor = { [helmet] = { ears } }

raccoon:addVariant({
    name = "Tanuki",
    item = "minecraft:brown_dye",
    parts = {
        {
            part = ears,
            texture = textures[earsTexture],
        },
        {
            part = tail,
            texture = textures[tailTexture],
        },
    },
})

raccoon:addVariant({
    name = "Raccoon",
    item = "minecraft:gray_dye",
    parts = {
        {
            part = ears,
            texture = textures[earsTexture.."_alternate"],
        },
        {
            part = tail,
            texture = textures[tailTexture.."_alternate"],
        },
    },
})

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

local lastUseTime
function raccoon.tick()
    local spit = originsapi.getPowerData(player, "snowy:spit")
    local useTime
    if spit then
        useTime = spit.LastUseTime
    end
    if lastUseTime and useTime and useTime - lastUseTime > 30 then
        animations.model.spit:play()
    end
    lastUseTime = useTime
end

raccoon:register()
