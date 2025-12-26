local rw = require("tiny_gauge:railway")

local this_item_id = item.index("tiny_gauge:rail")

sel = nil

local function make_selection(x, y, z)
    if sel == nil then
        sel = {
            pos = { x = x, y = y, z = z },
            wraps = {},
        }

        -- TODO: set up visuals
        local rail_type = rw.get_rail_type("tiny_gauge:default_rail")
        for _, pattern in pairs(rail_type.pattern_map) do
            local dx, dy, dz = pattern.vec[1], pattern.vec[2], pattern.vec[3]

            local texture
            if _ then
                texture = "wraps/wrap_straight"
            elseif _ then
                texture = "wraps/wrap_split"
            else
                texture = "wraps/wrap_unrelated"
            end

            table.insert(sel.wraps, gfx.blockwraps.wrap({ x + dx, y + dy - 1, z + dz }, texture))
        end
    else
        assert(false, "unreachable")
    end
end

local function clear_selection()
    if sel ~= nil then
        -- TODO: clear visuals
        for _, id in pairs(sel.wraps) do
            gfx.blockwraps.unwrap(id)
        end

        sel = nil
    end
end

function on_use_on_block(x, y, z, player_id, normal)
    if not block.is_replaceable_at(x, y, z) then
        x, y, z = x + normal[1], y + normal[2], z + normal[3]
    end
    if not block.is_replaceable_at(x, y, z) then
        return
    end

    if sel then
        print("make_spline:",
            rw.make_spline(
                x, y, z,
                sel.pos.x, sel.pos.y, sel.pos.z,
                "tiny_gauge:default_rail"
            )
        )
        clear_selection()
    else
        make_selection(x, y, z)
    end
end

function on_use(player_id)
    clear_selection()
end

function on_selected_hotbar_item_change(player_id, inv_id, slot, item_id, count)
    if this_item_id ~= item_id then
        clear_selection()
    end
end

events.on("tiny_gauge:on_selected_hotbar_item_change", on_selected_hotbar_item_change)
