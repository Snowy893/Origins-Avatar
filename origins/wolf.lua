if true then return end

local origins = require "origins.origins"
local squapi = require "lib.thirdparty.SquAPI"
local util = require "lib.util"

local wolf = origins.new("fishbowl:wolf")

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

wolf:init()

if not host:isHost() then return end

local currentVariant = util.getOrDefault("wolf_variant", "pale")
local variantPage = action_wheel:newPage()

---@param variant Wolf.variant
function pings.setWolfVariant(variant)
    currentVariant = variant
    ears:setPrimaryTexture("CUSTOM", textures["model.wolf_ears_" .. variant])
    tail:setPrimaryTexture("CUSTOM", textures["model.wolf_tail_" .. variant])
end

---@param title string
---@param variant Wolf.variant
---@param item? Minecraft.itemID
local function variantAction(title, variant, item)
    return variantPage:newAction()
        :title(title)
        :item(item)
        :onLeftClick(function()
            if currentVariant == variant then return end
            config:save("wolf_variant", variant)
            pings.setWolfVariant(variant)
        end)
end

variantAction("Pale", "pale",
    "minecraft:player_head[minecraft:lore=['{\"text\":\"Custom Head ID: 86442\",\"color\":\"gray\",\"italic\":false}','{\"text\":\"www.minecraft-heads.com\",\"color\":\"blue\",\"italic\":false}'],profile={id:[I;439224108,1258439645,-2058014510,-1631212001],properties:[{name:\"textures\",value:\"eyJ0ZXh0dXJlcyI6eyJTS0lOIjp7InVybCI6Imh0dHA6Ly90ZXh0dXJlcy5taW5lY3JhZnQubmV0L3RleHR1cmUvYmM4M2YyNmY0MjAwMDRkYmQzZWYxNWFlMDUyMTM2MTg4N2UxZTRkN2ZjYzRmNGJmYjBmZTFmNTRiMTZlNzcxMSJ9fX0=\"}]}]")
variantAction("Ashen", "ashen",
    "minecraft:player_head[minecraft:lore=['{\"text\":\"Custom Head ID: 86442\",\"color\":\"gray\",\"italic\":false}','{\"text\":\"www.minecraft-heads.com\",\"color\":\"blue\",\"italic\":false}'],profile={id:[I;439224108,1258439645,-2058014510,-1631212001],properties:[{name:\"textures\",value:\"eyJ0ZXh0dXJlcyI6eyJTS0lOIjp7InVybCI6Imh0dHA6Ly90ZXh0dXJlcy5taW5lY3JhZnQubmV0L3RleHR1cmUvYmM4M2YyNmY0MjAwMDRkYmQzZWYxNWFlMDUyMTM2MTg4N2UxZTRkN2ZjYzRmNGJmYjBmZTFmNTRiMTZlNzcxMSJ9fX0=\"}]}]")
-- variantAction("Black", "black", "minecraft:black_wool")
-- variantAction("Chestnut", "chestnut", "minecraft:grass_block")
-- variantAction("Rusty", "rusty", "minecraft:weathered_copper")
-- variantAction("Snowy", "snowy", "minecraft:snow_block")
-- variantAction("Spotted", "spotted", "minecraft:orange_wool")
-- variantAction("Striped", "striped", "minecraft:birch_log")
-- variantAction("Woods", "woods", "minecraft:oak_log")

util.switchPageActions(wolf.page, variantPage, "Wolf Variants", "spruce_sapling")

util.tick:register(function()
    if wolf.isOrigin then
        pings.setWolfVariant(currentVariant)
    end
end, 40)
