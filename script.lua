-- Set this to false if you want to use the skin texture in the blockbench model!
local useVanillaSkin = true
---------------------------------------------------------------------------------

vanilla_model.PLAYER:setVisible(false)
models.model.root:setSecondaryRenderType("NONE")

if useVanillaSkin then
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
end

local lastModelType
function events.tick()
    local modelType = player:getModelType() == "DEFAULT"
    if modelType ~= lastModelType then
        models.model.root.LeftArm.wideLeftArm:setVisible(modelType)
        models.model.root.RightArm.wideRightArm:setVisible(modelType)
        models.model.root.LeftArm.slimLeftArm:setVisible(not modelType)
        models.model.root.RightArm.slimRightArm:setVisible(not modelType)
    end
    lastModelType = modelType
end
