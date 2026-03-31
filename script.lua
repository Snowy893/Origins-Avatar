local util = require "lib.util"
---------------------------------------------------------------------------------

-- Set this to false if you want to use the skin texture in the blockbench model.
local USE_VANILLA_SKIN = true

-- Set this to false if you want to disable your origin's ambient particles in first person.
util.RENDER_AMBIENT_FIRST_PERSON = true

---------------------------------------------------------------------------------

vanilla_model.PLAYER:setVisible(false)
models.model.root:setSecondaryRenderType("EYES")

if not USE_VANILLA_SKIN then return end

for _, part in ipairs({
    models.model.root.Head.Head,
    models.model.root.Head.Hat,
    models.model.root.Body.Body,
    models.model.root.Body.Jacket,
    models.model.root.LeftArm.wideLeftArm.LeftArm,
    models.model.root.LeftArm.wideLeftArm["Left Sleeve"],
    models.model.root.RightArm.wideRightArm.RightArm,
    models.model.root.RightArm.wideRightArm["Right Sleeve"],
    models.model.root.LeftArm.slimLeftArm.SlimLeftArm,
    models.model.root.LeftArm.slimLeftArm["SlimLeft Sleeve"],
    models.model.root.RightArm.slimRightArm.SlimRightArm,
    models.model.root.RightArm.slimRightArm["SlimRight Sleeve"],
    models.model.root.LeftLeg.LeftLeg,
    models.model.root.LeftLeg["Left Pants"],
    models.model.root.RightLeg.RightLeg,
    models.model.root.RightLeg["Right Pants"],
}) do
    part:setPrimaryTexture("SKIN")
end

function events.entity_init()
    local modelType = player:getModelType() == "DEFAULT"
    models.model.root.LeftArm.wideLeftArm:setVisible(modelType)
    models.model.root.RightArm.wideRightArm:setVisible(modelType)
    models.model.root.LeftArm.slimLeftArm:setVisible(not modelType)
    models.model.root.RightArm.slimRightArm:setVisible(not modelType)
end
