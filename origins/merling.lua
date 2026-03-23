local origins = require "origins.origins"

local merling = origins:new("origins:merling")

merling.emissive = function() return player:isWet() end

merling:init()