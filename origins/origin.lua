local periodical = require "lib.periodical"
local util = require "lib.util"

---@alias Origin.Sounds.Ambient {
---     sound: Sound,
---     minTicks: integer?,
---     maxTicks: integer?,
---     condition: (fun(): boolean)?,
---     pitch: number,
---}

---@alias Origin.Sounds.Hurt {
---     sound: Sound,
---     pitch: number?,
---}

---@alias Origin.Variant.TexturePart {
---     part: ModelPart,
---     texture: Texture,
---}

---@alias Origin.Variant {
---     textureParts: Origin.Variant.TexturePart[]?,
---     parts: ModelPart[]?,
---     name: string,
---     item: ItemStack|Minecraft.itemID,
---}

---@generic T
---@class Origin
---@field id string
---@field page Page
---@field parts ModelPart[]
---@field partsCoveredByArmor { [Entity.slot]: { [integer|Minecraft.itemID]: ModelPart } }
---@field sounds { ambient: (Origin.Sounds.Ambient|Sound)?, hurt: (Origin.Sounds.Hurt|Sound)? }
---@field tick fun()?
---@field render Event.Render.func?
---@field change fun(toggle: boolean)?
---@field variants { [string]: Origin.Variant }?
---@field squishy SquAPI<T>[]
---@field currentVariant string
---@field ALL { [string]: Origin }
local Origin = {}
Origin.__index = Origin

Origin.ALL = {}
Origin.isOrigin = false
Origin.sounds = {}
Origin.variants = {}
Origin.numberToVariant = {}
Origin.variantToNumber = {}

---@param toggle boolean
function Origin:setEnabled(toggle)
    self.isOrigin = toggle

    if self.parts then
        for _, part in ipairs(self.parts) do
            part:setVisible(toggle)
        end
    end

    if toggle then
        action_wheel:setPage(self.page)
    end

    if self.change then
        self.change(toggle)
    end
end

function Origin:checkArmorParts()
    if not self.partsCoveredByArmor then return end
    for slot, parts in pairs(self.partsCoveredByArmor) do
        local item = player:getItem(slot)
        local isWearing = item.id ~= "minecraft:air"
        for k, part in pairs(parts) do
            part:setVisible(not (type(k) ~= "string" and isWearing or item.id:find(k) ~= nil))
        end
    end
end

function Origin:squishyTick()
    if not self.squishy then return end
    for _, obj in ipairs(self.squishy) do
        if obj.tick then obj:tick() end ---@diagnostic disable-line: undefined-field
    end
end

---@param delta number
---@param context Event.Render.context
function Origin:squishyRender(delta, context)
    if not self.squishy then return end
    for _, obj in ipairs(self.squishy) do
        if obj.render then obj:render(delta, context) end ---@diagnostic disable-line: undefined-field
    end
end

---@overload fun(variant: string): number
---@overload fun(variant: number): string
function Origin:convertVariantID(variant)
    if type(variant) == "number" then
        return self.numberToVariant[variant]
    else
        return self.variantToNumber[variant]
    end
end

function Origin:register()
    if self.sounds.hurt then
        if type(self.sounds.hurt) == "Sound" then
            self.sounds.hurt = { sound = self.sounds.hurt }
        end
        local hurt = self.sounds.hurt
        hurt.pitch = hurt.pitch or hurt.sound:getPitch()
    end

    if self.sounds.ambient then
        if type(self.sounds.ambient) == "Sound" then
            self.sounds.ambient = { sound = self.sounds.ambient }
        end
        local ambient = self.sounds.ambient
        ambient.minTicks = ambient.minTicks or 1200
        ambient.maxTicks = ambient.maxTicks or 1800
        ambient.condition = ambient.condition or world.exists
        ambient.pitch = ambient.pitch or ambient.sound:getPitch()

        periodical.new(function()
            ---@diagnostic disable-next-line: param-type-mismatch
            util.playSound(ambient.sound, ambient.pitch)
        end):condition(function()
            return self.isOrigin and ambient.condition()
        end):timing(ambient.minTicks, ambient.maxTicks)
            :register()
    end

    if next(self.variants) ~= nil then
        for k, _ in pairs(self.variants) do
            local n = #self.numberToVariant + 1
            self.numberToVariant[n] = k
            self.variantToNumber[k] = n
        end
    end

    if host:isHost() and next(self.variants) ~= nil then
        local variantActionWheel = action_wheel:newPage()
        if not self.page then
            self.page = variantActionWheel
        else
            util.switchPageActions(self.page, variantActionWheel)
        end

        self.currentVariant = config:load(self.id .. "_current_variant")

        if not self.currentVariant then
            for k, _ in pairs(self.variants) do
                self.currentVariant = k
                break
            end
        end

        for k, variant in pairs(self.variants) do
            variantActionWheel:newAction()
                :title(variant.name)
                :item(variant.item)
                :onLeftClick(function()
                    pings.setVariant(self:convertVariantID(k))
                    config:save(self.id .. "_current_variant", k)
                    self.currentVariant = k
                end)
        end

        util.tick:register(function()
            if self.isOrigin then
                pings.setVariant(self:convertVariantID(self.currentVariant))
            end
        end, 120)
    end

    Origin.ALL[self.id] = self
end

---@param id string If no namespace is provided, assumes `"origins:<id>"`
---@return Origin
function Origin.new(id)
    local origin = setmetatable({}, Origin)
    origin.id = not id:find(":", 2) and "origins:" .. id or id
    return origin
end

---@return Origin?
local function getCurrentOrigin()
    local nbt = player:getNbt()
    local layers = nbt.cardinal_components
        and nbt.cardinal_components["origins:origin"]
        and nbt.cardinal_components["origins:origin"].OriginLayers
    local origin
    for _, v in ipairs(layers) do
        if v.Layer == "origins:origin" then
            origin = v.Origin
            break
        end
    end
    return Origin.ALL[origin]
end

---@param variantID number
function pings.setVariant(variantID)
    local origin = Origin.current
    local variant = origin.variants[origin.convertVariantID(variantID)]

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

    origin.lastVariant = origin.convertVariantID(variantID)
end

function events.entity_init()
    for _, origin in pairs(Origin.ALL) do
        origin:setEnabled(false)
    end
end

function util.tick()
    Origin.current = getCurrentOrigin()
    local origin = Origin.current

    if not origin then
        if Origin.last then
            Origin.last:setEnabled(false)
        end
        Origin.last = origin
        return
    end

    if origin ~= Origin.last then
        if Origin.last then
            Origin.last:setEnabled(false)
        end

        origin:setEnabled(true)

        if origin.currentVariant then
            pings.setVariant(origin:convertVariantID(origin.currentVariant))
        end
    end

    origin:checkArmorParts()

    origin:squishyTick()

    if origin.tick then origin.tick() end

    Origin.last = origin
end

-- Thanks `manuel_2867` on the Figura Discord for original snippet!
-- https://discord.com/channels/1129805506354085959/1234218592187453452/1463663512520753227
function events.on_play_sound(id, pos, volume, pitch, loop, category, path)
    if not path then return
    elseif not Origin.current or not Origin.current.sounds.hurt then return
    elseif not player:isLoaded() then return end

    local nearest = math.huge
    local uuid

    for _, playr in pairs(world.getPlayers()) do
        local dist = (playr:getPos() - pos):length()
        if dist < nearest then
            nearest = dist
            uuid = playr:getUUID()
        end
    end

    if uuid ~= player:getUUID() or nearest > 0.8 then return end

    if id:find("player") and id:find("hurt") then
        ---@diagnostic disable-next-line: param-type-mismatch
        util.playSound(Origin.current.sounds.hurt.sound, Origin.current.sounds.hurt.pitch, pos)
    end
end

function events.render(delta, context, matrix)
    if Origin.current then
        if Origin.current.render then
            Origin.current.render(delta, context, matrix)
        end
        Origin.current:squishyRender(delta, context)
    end
end

return Origin
