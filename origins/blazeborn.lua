local origins = require "origins.origins"

local blazeborn = origins.new("origins:blazeborn")

function blazeborn.emissive()
    return player:isOnFire()
end

blazeborn:init()