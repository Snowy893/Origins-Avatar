local origins = require "origins.origins"
local squapi = require "lib.thirdparty.SquAPI"
local util = require "lib.util"

local wolf = origins:new("fishbowl:wolf")

---@alias Wolf.variant
---| "pale"
---| "ashen"
---| "black"
---| "chestnut"
---| "rusty"
---| "snowy"
---| "spotted"
---| "striped"
---| "woods"

local ears = models.model.root.upperBody.Head.WolfEars
local tail = models.model.root.upperBody.Body.WolfTail

wolf.page = action_wheel:newPage()
wolf.modelParts = { ears, tail }

local variantPage = action_wheel:newPage()

---@param variant Wolf.variant
function pings.setWolfVariant(variant)
    if variant == nil then variant = "pale" end
    ears:setPrimaryTexture("CUSTOM", textures["model.wolf_ears_" .. variant])
    tail:setPrimaryTexture("CUSTOM", textures["model.wolf_tail_" .. variant])
end

---@param title string
---@param variant Wolf.variant
---@param item? Minecraft.itemID
local function variantAction(title, variant, item)
    return action_wheel:newAction()
        :title(title)
        :item(item)
        :onLeftClick(function()
            config:save("wolf_variant", variant)
            pings.setWolfVariant(variant)
        end)
end

variantPage:setAction(-1, variantAction("Pale", "pale",
    "minecraft:player_head[minecraft:lore=['{\"text\":\"Custom Head ID: 86442\",\"color\":\"gray\",\"italic\":false}','{\"text\":\"www.minecraft-heads.com\",\"color\":\"blue\",\"italic\":false}'],profile={id:[I;439224108,1258439645,-2058014510,-1631212001],properties:[{name:\"textures\",value:\"eyJ0ZXh0dXJlcyI6eyJTS0lOIjp7InVybCI6Imh0dHA6Ly90ZXh0dXJlcy5taW5lY3JhZnQubmV0L3RleHR1cmUvYmM4M2YyNmY0MjAwMDRkYmQzZWYxNWFlMDUyMTM2MTg4N2UxZTRkN2ZjYzRmNGJmYjBmZTFmNTRiMTZlNzcxMSJ9fX0=\"}]}]"))

variantPage:setAction(-1, variantAction("Ashen", "ashen",
    "minecraft:player_head[minecraft:lore=['{\"text\":\"Custom Head ID: 86442\",\"color\":\"gray\",\"italic\":false}','{\"text\":\"www.minecraft-heads.com\",\"color\":\"blue\",\"italic\":false}'],profile={id:[I;439224108,1258439645,-2058014510,-1631212001],properties:[{name:\"textures\",value:\"eyJ0ZXh0dXJlcyI6eyJTS0lOIjp7InVybCI6Imh0dHA6Ly90ZXh0dXJlcy5taW5lY3JhZnQubmV0L3RleHR1cmUvYmM4M2YyNmY0MjAwMDRkYmQzZWYxNWFlMDUyMTM2MTg4N2UxZTRkN2ZjYzRmNGJmYjBmZTFmNTRiMTZlNzcxMSJ9fX0=\"}]}]"))

-- local blackAction = mainPage:newAction()
--   :title("Black Variant")
--   :item("minecraft:black_wool")
--   :setOnLeftClick(pings.setVariant("black"))

-- local chestnutAction = mainPage:newAction()
--   :title("Chestnut Variant")
--   :item("minecraft:grass_block")
--   :setOnLeftClick(pings.setVariant("chestnut"))

-- local rustyAction = mainPage:newAction()
--   :title("Rusty Variant")
--   :item("minecraft:copper_block")
--   :setOnLeftClick(pings.setVariant("rusty"))

-- local snowyAction = mainPage:newAction()
--   :title("Snowy Variant")
--   :item("minecraft:white_wool")
--   :setOnLeftClick(pings.setVariant("snowy"))

-- local spottedAction = mainPage:newAction()
--   :title("Spotted Variant")
--   :item("minecraft:orange_wool")
--   :setOnLeftClick(pings.setVariant("spotted"))

-- local stripedAction = mainPage:newAction()
--   :title("Striped Variant")
--   :item("minecraft:birch_wood")
--   :setOnLeftClick(pings.setVariant("striped"))

-- local woodsAction = mainPage:newAction()
--   :title("Woods Variant")
--   :item("minecraft:oak_wood")
--   :setOnLeftClick(pings.setVariant("woods"))

wolf.page:setAction(-1, util.switchPageActions(wolf.page, variantPage, "Wolf Variants", "spruce_sapling"))

squapi.ear(ears.WolfLeftEar, ears.WolfRightEar,
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

wolf:init(function ()
    pings.setWolfVariant(config:load("wolf_variant"))
end)