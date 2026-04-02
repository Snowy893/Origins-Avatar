local origins = require "origins.origins"

local moth = origins.new("snowy:moth")

local wings = models.model.root.Body.mothWings
local fluff = models.model.root.Head.mothFluff

-- moth.partsToHide = { [5] = { ["minecraft:elytra"] = wings } }

moth:register()