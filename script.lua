local options = require "options"

vanilla_model.PLAYER:setVisible(false)
models.model.root.Cape:setVisible(options.ENABLE_CAPE)

if options.USE_VANILLA_SKIN then
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
end

if options.USE_VANILLA_CAPE_TEXTURE then
    function events.entity_init()
        if player:hasCape() then
            models.model.root.Cape:setPrimaryTexture("CAPE")
            models.model.root.Elytra:setPrimaryTexture("CAPE")
        else
            models.model.root.Elytra:setPrimaryTexture("ELYTRA")
        end
    end
end

if options.name == "NAME HERE" then options.name = "${name}" end
nameplate.ALL:setText(toJson {
    text = options.name,
    color = "#"..vectors.rgbToHex(options.rgb / 255),
})
