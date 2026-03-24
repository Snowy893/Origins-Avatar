local origins = require "origins.origins"

local merling = origins.new("origins:merling")

function merling.emissive()
    return player:isWet()
end

merling:init()