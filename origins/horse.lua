local origins = require "origins.origins"
local originsapi = require "lib.thirdparty.OriginsAPI"
local squapi = require "lib.thirdparty.SquAPI"
local util = require "lib.util"

local horse = origins.new("snowy:horse")

local ears = models.model.root.Head.horseEars
local tail = models.model.root.Body.horseTail
local helmet = 6 ---@type Entity.slot

local sprintParticle = "minecraft:flame" ---@type Minecraft.particleID
local sprintParticleSwiftness = "minecraft:soul_fire_flame" ---@type Minecraft.particleID

horse.sounds.ambient = sounds["minecraft:entity.horse.ambient"]:volume(0.7):pitch(0.9)
horse.sounds.hurt = sounds["minecraft:entity.horse.hurt"]:volume(0.7):pitch(0.9)

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
        25,
        -0.5,
        nil
    ),
}

util.tick:register(function()
    if not horse.isOrigin then return end
    
    local speed = originsapi.getPowerData(player, "snowy:great_sprint_speed_resource")

    local velocity = player:getVelocity().xz:length()

    local hasSwiftness = velocity >= 0.49

    if speed == 130 and velocity >= 0.3 and player:isOnGround() then
        particles:newParticle(
            hasSwiftness and sprintParticleSwiftness or sprintParticle,
            player:getPos(util.delta),
            (math.random() - 0.5) / 5, 0, (math.random() - 0.5) / 5
        ):scale(hasSwiftness and 1.3 or 0.96)
    end
end, 1)

horse:register()