local rw = require("tiny_gauge:railway")

args = SAVED_DATA.args or ARGS

-- TODO: temporary?
if not rw._ensure_spline(entity:get_uid(), args.pivot1, args.pivot2, args.direction) then
    entity.skeleton:set_color({ 1, 0, 0 })
end

-- TODO: may be use static model?
-- set/restore dynamic model
entity.skeleton:set_model(entity.skeleton:index("root"), args.model)

function on_aim_on(player_id)
    local inv_id, slot = player.get_inventory(player_id)
    local item_id, count = inventory.get(inv_id, slot)
    local item_name = item.name(item_id)

    if item_name == "tiny_gauge:rail" then
        entity.skeleton:set_color({ 2, 2, 2 })
    end
end

function on_aim_off(player_id)
    entity.skeleton:set_color({ 1, 1, 1 })
end

function on_attacked(_, player_id)
    if player_id > -1 then
        rw._delete_spline(entity:get_uid())
        entity:despawn()
    end
end

function on_save()
    SAVED_DATA.args = args
end
