local originsapi = require "lib.thirdparty.OriginsAPI"

---@class Origins
---@field ALL { [string]: Origin }
local origins = {}

origins.ALL = {}

---@param id string
---@return Origin
function origins.new(id)
    ---@class Origin
    ---@field page Page
    ---@field modelParts ModelPart[]
    ---@field emissive boolean|function
    ---@field emissiveModelParts ModelPart[]
    ---@field isOrigin boolean
    local origin = {}
    origin.id = id
    origin.emissive = false
    origin.emissiveModelParts = { models.model.root }
    origin.isOrigin = false

    ---@param toggle boolean
    function origin.partsVisible(toggle)
        if not origin.modelParts then return end
        for _, part in ipairs(origin.modelParts) do
            part:setVisible(toggle)
        end
    end

    ---@param toggle boolean
    function origin.partsEmissive(toggle)
        local renderType = toggle and "EYES" or "NONE"
        for _, part in ipairs(origin.emissiveModelParts) do
            part:setSecondaryRenderType(renderType)
        end
    end

    ---@param func fun(isOrigin: boolean)?
    function origin:init(func)
        origin.func = func
        origins.ALL[origin.id] = origin
    end

    return origin
end

function events.tick()
    for _, origin in pairs(origins.ALL) do
        origin.isOrigin = originsapi.hasOrigin(player, origin.id)

        if origin.wasOrigin ~= origin.isOrigin then
            local emissive = origin.isOrigin and origin.emissive and type(origin.emissive) == "boolean"

            origin.partsVisible(origin.isOrigin)
            origin.partsEmissive(emissive)

            if host:isHost() and origin.isOrigin and origin.page then
                action_wheel:setPage(origin.page)
            end
        end

        if origin.isOrigin and type(origin.emissive) == "function" then
            local emissive = origin.emissive()
            if origin.wasEmissive ~= emissive then
                origin.partsEmissive(emissive)
            end
            origin.wasEmissive = emissive
        end

        if origin.func then origin.func(origin.isOrigin) end
        
        origin.wasOrigin = origin.isOrigin
    end
end

return origins
