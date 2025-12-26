local rw = require("tiny_gauge:railway")

local prev_slot = nil
local prev_item_id = nil
local prev_count = nil

function on_player_tick(player_id, tps)
    local inv_id, slot = player.get_inventory(player_id)
    local item_id, count = inventory.get(inv_id, slot)

    if slot ~= prev_slot or item_id ~= prev_item_id or count ~= prev_count then
        events.emit("tiny_gauge:on_selected_hotbar_item_change", player_id, inv_id, slot, item_id, count)
    end

    prev_slot = slot
    prev_item_id = item_id
    prev_count = count
end

function on_world_open()
    rw._load()
end

function on_world_save()
    rw._save()
end

local rail_types = {
    { direction = { n = 1, e = 0 }, elevation = 0, rotation = "straight",     model = "rail_spline_tiny_straight" },
    { direction = { n = 1, e = 1 }, elevation = 0, rotation = "diagonal",     model = "rail_spline_tiny_diagonal" },

    { direction = { n = 2, e = 0 }, elevation = 0, rotation = "straight",     model = "rail_spline_short_straight" },
    { direction = { n = 2, e = 1 }, elevation = 0, rotation = "halfdiagonal", model = "rail_spline_short_halfdiagonal" },
    { direction = { n = 2, e = 2 }, elevation = 0, rotation = "diagonal",     model = "rail_spline_short_diagonal" },

    -- { direction = { n = 5, e = 0 }, elevation = 0, rotation = "straight",     model = "rail_spline_long_straight" },
    -- { direction = { n = 5, e = 2 }, elevation = 0, rotation = "halfdiagonal", model = "rail_spline_long_halfdiagonal" },
    -- { direction = { n = 4, e = 4 }, elevation = 0, rotation = "diagonal",     model = "rail_spline_long_diagonal" },
}

rw.reg_rail_type(PACK_ID, "default_rail", rail_types)
