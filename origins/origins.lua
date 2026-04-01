local originsapi = require "lib.thirdparty.OriginsAPI"
local periodical = require "lib.periodical"
local util = require "lib.util"

---@class Origins
---@field ALL { [string]: Origin }
local origins = {}

origins.ALL = {}

---@return Origin?
local function getCurrentOrigin()
    local nbt = player:getNbt()
    local layers = nbt.cardinal_components
        and nbt.cardinal_components["origins:origin"]
        and nbt.cardinal_components["origins:origin"].OriginLayers
    local origin = layers[1].Origin
    return origins.ALL[origin]
end

---@alias Origins.AmbientSound {
---     sound: Sound,
---     minTicks: integer?,
---     maxTicks: integer?,
---     condition: (fun(): boolean)?,
---}

---@alias Origins.Variant.TexturePart {
---     part: ModelPart,
---     texture: Texture,
---}

---@alias Origins.Variant {
---     textureParts: Origins.Variant.TexturePart[]?,
---     parts: ModelPart[]?,
---     name: string,
---     item: ItemStack|Minecraft.itemID,
---}

---@param variantID string
function pings.setVariant(variantID)
    local origin = origins.current
    local variant = origin.variants[variantID]

    if origin.lastVariant then
        local last = origin.variants[origin.lastVariant]
        if last.parts then
            for _, part in ipairs(last.parts) do
                part:setVisible(false)
            end
        end
        if last.textureParts then
            for _, obj in ipairs(last.textureParts) do
                obj.part:setVisible(false)
            end
        end
    end
    
    if variant.parts then
        for _, part in ipairs(variant.parts) do
            part:setVisible(true)
        end
    end

    if variant.textureParts then
        for _, obj in ipairs(variant.textureParts) do
            obj.part:setVisible(true)
            obj.part:setPrimaryTexture("CUSTOM", obj.texture)
        end
    end

    origin.lastVariant = variantID
end

---@param id string If no namespace is provided, assumes `"origins:<id>"`
---@return Origin
function origins.new(id)
    ---@generic T
    ---@class Origin
    ---@field page Page
    ---@field parts ModelPart[]
    ---@field partsCoveredByArmor { [Entity.slot]: { [integer|Minecraft.itemID]: ModelPart } }
    ---@field sounds { ambient: Origins.AmbientSound?, hurt: Sound? }
    ---@field tick fun()?
    ---@field change fun(toggle: boolean)?
    ---@field variants { [string]: Origins.Variant }?
    ---@field squishy SquAPI<T>[]
    local origin = {}
    origin.id = not id:find(":", 2) and "origins:" .. id or id
    origin.isOrigin = false
    origin.sounds = {}
    origin.variants = {}

    ---@param toggle boolean
    function origin.setPartsVisible(toggle)
        if not origin.parts then return end
        for _, part in ipairs(origin.parts) do
            part:setVisible(toggle)
        end
    end

    function origin.checkArmorParts()
        if not origin.partsCoveredByArmor then return end
        for slot, parts in pairs(origin.partsCoveredByArmor) do
            local item = player:getItem(slot)
            local isWearing = item.id ~= "minecraft:air"
            for k, part in pairs(parts) do
                part:setVisible(not (type(k) ~= "string" and isWearing or item.id:find(k) ~= nil))
            end
        end
    end

    function origin.squishyTick()
        if not origin.squishy then return end
        for _, obj in ipairs(origin.squishy) do
            if obj.tick then obj:tick() end ---@diagnostic disable-line: undefined-field
        end
    end

    ---@param delta number
    ---@param context Event.Render.context
    function origin.squishyRender(delta, context)
        if not origin.squishy then return end
        for _, obj in ipairs(origin.squishy) do
            if obj.render then obj:render(delta, context) end ---@diagnostic disable-line: undefined-field
        end
    end

    local function ambientSoundsInit()
        local ambient = origin.sounds.ambient
        ambient.minTicks = ambient.minTicks or 600
        ambient.maxTicks = ambient.maxTicks or 1200
        ambient.condition = ambient.condition or world.exists

        periodical.new(function()
            util.playSound(ambient.sound)
        end):condition(function()
            return origin.isOrigin and ambient.condition()
        end):timing(ambient.minTicks, ambient.maxTicks)
            :register()
    end

    local function variantActionsInit()
        local variantActionWheel = action_wheel:newPage()
        if not origin.page then
            origin.page = variantActionWheel
        else
            util.switchPageActions(origin.page, variantActionWheel)
        end

        origin.currentVariant = config:load(origin.id.."_current_variant")

        if not origin.currentVariant then
            for k, _ in pairs(origin.variants) do
                origin.currentVariant = k
                break
            end
        end

        for k, variant in pairs(origin.variants) do
            variantActionWheel:newAction()
                :title(variant.name)
                :item(variant.item)
                :onLeftClick(function()
                    pings.setVariant(k)
                    config:save(origin.id.."_current_variant", k)
                    origin.currentVariant = k
                end)
        end

        util.tick:register(function()
            if origin.isOrigin then
                pings.setVariant(origin.currentVariant)
            end
        end, 120)
    end

    function origin:init()
        if origin.sounds.ambient then
            ambientSoundsInit()
        end

        if host:isHost() and next(origin.variants) ~= nil then
            variantActionsInit()
        end
        
        origins.ALL[origin.id] = origin
    end

    return origin
end

local lastHealth = 20

function events.entity_init()
    for _, origin in pairs(origins.ALL) do
        origin.setPartsVisible(false)
    end
end

function util.tick()
    origins.current = getCurrentOrigin()
    local origin = origins.current

    if not origin then
        if origins.last then
            origins.last.setPartsVisible(false)
            if origins.last.change then
                origins.last.change(false)
            end
        end
        origins.last = origin
        return
    end

    local health = player:getHealth()
    local wasHurt = lastHealth > health

    if origin ~= origins.last then
        if origins.last then
            origins.last.isOrigin = false
            origins.last.setPartsVisible(false)
            if origins.last.change then
                origins.last.change(false)
            end
        end

        origin.isOrigin = true

        if origin.currentVariant then
            pings.setVariant(origin.currentVariant)
        end

        wasHurt = false

        origin.setPartsVisible(true)

        action_wheel:setPage(origin.page)

        if origin.change then
            origin.change(true)
        end
    end

    origin.checkArmorParts()

    if wasHurt and origin.sounds.hurt then
        util.playSound(origin.sounds.hurt)
    end

    origin.squishyTick()

    if origin.tick then origin.tick() end

    lastHealth = health
    origins.last = origin
end

function events.render(delta, context)
    if origins.current then
        origins.current.squishyRender(delta, context)
    end
end

return origins
