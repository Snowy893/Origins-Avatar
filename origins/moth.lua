local origin = require "origins.origin"
local originsapi = require "lib.thirdparty.OriginsAPI"

local moth = origin.new("snowy:moth")

local antennae = models.model.root.Head.mothAntennae:setScale(0.9, 0.9, 0.9)
local fluff = models.model.root.Head.mothFluff
local wings = models.model.root.Body.mothWings
local helmet = 6 ---@type Entity.slot

moth.sounds.hurt = sounds["minecraft:entity.bat.hurt"]:setPitch(0.4):volume(0.4)

moth.parts = { antennae, wings, fluff }
moth.partsCoveredByArmor = { [helmet] = { antennae } }

local lastJumps = 3
function moth.tick()
    local jumps = originsapi.getPowerData(player, "snowy:geppo_jumps") --[[@as integer?]]
    if jumps then
        if jumps < lastJumps then
            animations.model.moth_flap:stop()
            animations.model.moth_flap:play()
        end
        lastJumps = jumps
    end
end

moth:register()
