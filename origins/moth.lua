local origins = require "origins.origins"
local originsapi = require "lib.thirdparty.OriginsAPI"

local moth = origins.new("snowy:moth")

local antennae = models.model.root.Head.mothAntennae:setScale(0.9, 0.9, 0.9)
local fluff = models.model.root.Head.mothFluff
local wings = models.model.root.Body.mothWings

moth.parts = { antennae, wings, fluff }

local lastJumps = 3
function moth.tick()
    local jumps = originsapi.getPowerData(player, "snowy:geppo_jumps")
    if jumps < lastJumps then
        animations.model.moth_flap:stop()
        animations.model.moth_flap:play()
    end
    lastJumps = jumps
end

moth:register()
