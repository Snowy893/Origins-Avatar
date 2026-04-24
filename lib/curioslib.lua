-- Figura CuriosLib v1.0.0 by Snowy893
-- Curios API Mod can be found here: https://modrinth.com/mod/curios

---@class CuriosLib
local CuriosLib = {}

---@alias Curios.slotID
---| "head"
---| "necklace"
---| "back"
---| "rings"
---| "hands"
---| "waist"
---| "belt"
---| "talisman"
---| "feet"
---| "charm"

---@alias Curios.Data {
---     Identifier: Curios.slotID,
---     StacksHandler: {
---         Cosmetics: {
---             Items: ItemStack[],
---             Size: integer,
---         },
---         Visible: 0|1, -- Doesn't actually change when visibility is toggled
---         HasCosmetic: 0|1, -- Doesn't actually change when visibility is toggled,
---         Stacks: {
---             Items: ItemStack[],
---             Size: integer,
---         },
---         SavedBaseSize: integer,
---         DropRule: string,
---         RenderToggle: 0|1, -- Doesn't actually change when visibility is toggled,
---         Renders: {
---             Renders: ({
---                 Render: (0|1), -- Actually changes when visibility is toggled,
---                 Slot: integer,
---             }?)[],
---             Size: integer,
---         },
---     },
---}[]

---@alias Curios.Inventory { [Curios.slotID]: {
---     items: ItemStack[]?,
---     visible: boolean,
---}}

---@param playr Player?
---@return Curios.Inventory?
function CuriosLib.getInventory(playr)
    if not client.isModLoaded("curios") then return nil end

    local nbt = (playr or player):getNbt()
    ---@type Curios.Data?
    local curios = nbt.ForgeCaps
        and nbt.ForgeCaps["curios:inventory"]
        and nbt.ForgeCaps["curios:inventory"].Curios

    if not curios then return nil end

    local inv = {}

    for _, v in ipairs(curios) do
        inv[v.Identifier] = {}
        local slot = inv[v.Identifier]

        slot.items = v.StacksHandler.Stacks.Items
        slot.visible = false

        for _, render in ipairs(v.StacksHandler.Renders.Renders) do
            if render.Render == 1 then
                slot.visible = true
                break
            end
        end
    end

    return next(inv) ~= nil and inv or nil
end

---@param slot Curios.slotID? -- Checks for the specified slot if not nil, otherwise checks any curios slot.
---@param playr Player?
---@return boolean -- True if the player is wearing an item in a curios slot and that slot is visible.
function CuriosLib.isWearing(slot, playr)
    if not client.isModLoaded("curios") then return false end

    local nbt = (playr or player):getNbt()
    ---@type Curios.Data?
    local curios = nbt.ForgeCaps
        and nbt.ForgeCaps["curios:inventory"]
        and nbt.ForgeCaps["curios:inventory"].Curios

    if not curios then return false end

    for _, v in ipairs(curios) do
        if not slot or v.Identifier == slot then
            local items = v.StacksHandler.Stacks.Items
            local toggled = false

            for _, render in ipairs(v.StacksHandler.Renders.Renders) do
                if render.Render == 1 then
                    toggled = true
                    break
                end
            end

            local visible = toggled and next(items) ~= nil

            if visible or slot then return visible end
        end
    end

    return false
end

return CuriosLib