local origins = require "origins.origins"

local merling = origins.new("merling")

merling.emissiveBuffer = 60

function merling.emissive()
    return player:isWet()
end

merling:init()