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
    ---@field emissiveBuffer (integer|{ on: integer, off: integer })?
    ---@field emissiveModelParts ModelPart[]
    ---@field isOrigin boolean
    local origin = {}
    origin.id = id
    origin.emissiveModelParts = { models.model.root }
    origin.isOrigin = false

    local originmt = {}
    setmetatable(origin, originmt)

    local emissiveFunc
    
    function originmt:__newindex(key, value)
        if key == "emissive" and type(value) == "function" then
            emissiveFunc = value
        end
        rawset(self, key, value)
    end

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
        if origin.emissive == nil then
            origin.emissive = false
        elseif origin.emissiveBuffer then
            local onBuffer
            local offBuffer

            if type(origin.emissiveBuffer) == "table" then
                onBuffer = origin.emissiveBuffer.on
                offBuffer = origin.emissiveBuffer.off
            else
                onBuffer = origin.emissiveBuffer
                offBuffer = onBuffer
            end

            local onTimer = 0
            local offTimer = 0
            local wasEmissive

            function self.emissive()
                local emissive = emissiveFunc()

                if wasEmissive ~= emissive then
                    if emissive then
                        onTimer = onTimer + 1
                        if onTimer == onBuffer then
                            wasEmissive = emissive
                            onTimer = 0
                        end
                        offTimer = 0
                    else
                        offTimer = offTimer + 1
                        if offTimer == offBuffer then
                            wasEmissive = emissive
                            offTimer = 0
                        end
                        onTimer = 0
                    end
                end

                return wasEmissive
            end

            function events.entity_init()
                if not self.isOrigin then return end

                local emissive = emissiveFunc()
                self.partsEmissive(emissive)
                wasEmissive = emissive
            end
        end
        
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
