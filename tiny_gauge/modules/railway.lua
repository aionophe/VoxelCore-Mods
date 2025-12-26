local L = {}

-- rail_directions = {
--      1,  --  N   --   0.0  -- +Z
--      2,  -- NNE  --  22.5  --
--      3,  --  NE  --  45.0  --
--      4,  -- ENE  --  67.5  --
--      5,  --  E   --  90.0  -- -X
--      6,  -- ESE  -- 112.5  --
--      7,  --  SE  -- 135.0  --
--      8,  -- SSE  -- 157.5  --
--      9,  --  S   -- 180.0  -- -Z
--     10,  -- SSW  -- 202.5  --
--     11,  --  SW  -- 225.0  --
--     12,  -- WSW  -- 247.5  --
--     13,  --  W   -- 270.0  -- +X
--     14,  -- WNW  -- 292.5  --
--     15,  --  NW  -- 315.0  --
--     16,  -- NNW  -- 337.5  --
-- }

-- rail_types = {
--     ["tiny_gauge:default_rail"] = {
--         pattern_map = {
--             ["0:0:2"] = { direction = 1, model = "tiny_gauge:rail_spline_short_straight" },
--             ["1:0:2"] = { direction = 2, model = "tiny_gauge:rail_spline_short_halfdiagonal" },
--             ...
--         },
--     },
-- }
local rail_types = {}

-- rail_pivots = {
--     ["x:y:z"] = {
--         splines = {
--             [uid1] = 1,
--             [uid2] = 10,
--             ...
--         },
--         directions = {
--             [ 1] = uid1,
--             [10] = uid2,
--             ...
--         },
--     },
--     ...
-- }
local rail_pivots = {}

-- rail_splines = {
--     [uid] = {
--         pivots = { "x1:y1:z1", "x2:y2:z2" },
--     },
--     ...
-- }
local rail_splines = {}

function L.reg_rail_type(pack_id, type_name, defs)
    -- TODO: check input

    local result_table = {}
    result_table.pattern_map = {}

    for _, t in pairs(defs) do
        local start_index
        if t.rotation == "straight" then
            start_index = 1
        elseif t.rotation == "diagonal" then
            start_index = 3
        elseif t.rotation == "halfdiagonal" then
            start_index = 2
        else
            return false, "invalid rotation preset: " .. t.rotation
        end

        result_table.pattern_map[ string.format("%d:%d:%d", -t.direction.e, t.elevation,  t.direction.n ) ] = { vec = {-t.direction.e, t.elevation,  t.direction.n}, direction = start_index, model = t.model }
        result_table.pattern_map[ string.format("%d:%d:%d", -t.direction.n, t.elevation, -t.direction.e ) ] = { vec = {-t.direction.n, t.elevation, -t.direction.e}, direction = start_index + 4, model = t.model }
        result_table.pattern_map[ string.format("%d:%d:%d",  t.direction.e, t.elevation, -t.direction.n ) ] = { vec = { t.direction.e, t.elevation, -t.direction.n}, direction = start_index + 8, model = t.model }
        result_table.pattern_map[ string.format("%d:%d:%d",  t.direction.n, t.elevation,  t.direction.e ) ] = { vec = { t.direction.n, t.elevation,  t.direction.e}, direction = start_index + 12, model = t.model }

        if t.rotation == "halfdiagonal" then
            result_table.pattern_map[ string.format("%d:%d:%d", -t.direction.n, t.elevation,  t.direction.e ) ] = { vec = {-t.direction.n, t.elevation,  t.direction.e}, direction = start_index + 2, model = t.model }
            result_table.pattern_map[ string.format("%d:%d:%d", -t.direction.e, t.elevation, -t.direction.n ) ] = { vec = {-t.direction.e, t.elevation, -t.direction.n}, direction = start_index + 6, model = t.model }
            result_table.pattern_map[ string.format("%d:%d:%d",  t.direction.n, t.elevation, -t.direction.e ) ] = { vec = { t.direction.n, t.elevation, -t.direction.e}, direction = start_index + 10, model = t.model }
            result_table.pattern_map[ string.format("%d:%d:%d",  t.direction.e, t.elevation,  t.direction.n ) ] = { vec = { t.direction.e, t.elevation,  t.direction.n}, direction = start_index + 14, model = t.model }
        end
    end

    local full_name = pack_id .. ":" .. type_name
    rail_types[full_name] = result_table

    return true
end
function L.get_rail_type(type_name)
    return rail_types[type_name]
end

local function pos_ser(x, y, z)
    return x .. ":" .. y .. ":" .. z
end

function L.make_spline(x1, y1, z1, x2, y2, z2, rail_type_name)
    local pivot1, pivot2 = pos_ser(x1, y1, z1), pos_ser(x2, y2, z2)
    print(pivot1, pivot2)
    local dx, dy, dz = x2 - x1, y2 - y1, z2 - z1

    local rail_type = rail_types[rail_type_name]
    if rail_type == nil then
        return false, "invalid rail type"
    end

    local pattern_str = dx .. ":" .. dy .. ":" .. dz
    local pattern = rail_type.pattern_map[pattern_str]
    if pattern == nil then
        return false, "no corresponding pattern found: " .. pattern_str
    end

    local rail_pos = {
        (x1 + x2) / 2 + 0.5,
        (y1 + y2) / 2 + 0.05,
        (z1 + z2) / 2 + 0.5,
    }

    local entity = entities.spawn("tiny_gauge:rail_spline", rail_pos, {
        tiny_gauge__rail_spline = { model = pattern.model, pivot1 = pivot1, pivot2 = pivot2, direction = pattern.direction }
    })

    if entity then
        local spline_id = entity:get_uid()

        rail_splines[spline_id] = { pivots = { pivot1, pivot2 } }

        rail_pivots[pivot1] = rail_pivots[pivot1] or {splines = {}, directions = {}}
        rail_pivots[pivot2] = rail_pivots[pivot2] or {splines = {}, directions = {}}

        local direction2 = (pattern.direction - 1 + 8) % 16 + 1

        rail_pivots[pivot1].splines[spline_id] = pattern.direction
        rail_pivots[pivot2].splines[spline_id] = direction2

        rail_pivots[pivot1].directions[pattern.direction] = spline_id
        rail_pivots[pivot2].directions[direction2] = spline_id

        print(pivot1, pattern.direction)
        print(pivot2, direction2)

        entity.transform:set_rot(mat4.look_at({ 0, 0, 0 }, { -dx, dy, dz }, { 0, 1, 0 }))
    else
        return false, "error creating spline entity"
    end

    return true, nil
end

function L.get_connected_splines(x, y, z)
    return rail_pivots[pos_ser(x, y, z)]
end

function L._delete_spline(uid)
    local pivot1 = rail_splines[uid].pivots[1]
    local pivot2 = rail_splines[uid].pivots[2]

    rail_pivots[pivot1].directions[rail_pivots[pivot1].splines[uid]] = nil
    rail_pivots[pivot1].splines[uid] = nil
    if table.count_pairs(rail_pivots[pivot1].splines) < 1 then
        rail_pivots[pivot1] = nil
        print("deleted pivot", pivot1)
    end

    rail_pivots[pivot2].directions[rail_pivots[pivot2].splines[uid]] = nil
    rail_pivots[pivot2].splines[uid] = nil
    if table.count_pairs(rail_pivots[pivot2].splines) < 1 then
        rail_pivots[pivot2] = nil
        print("deleted pivot", pivot2)
    end

    rail_splines[uid] = nil
    print("deleted spline", pivot1, pivot2)
end

function L._ensure_spline(uid, pivot1, pivot2, direction)
    if rail_splines[uid] == nil then
        if pivot1 == nil then
            print("unable to restore rail spline, id: " .. uid)
            return false
        end

        rail_splines[uid] = { pivots = { pivot1, pivot2 } }

        rail_pivots[pivot1] = rail_pivots[pivot1] or {splines = {}, directions = {}}
        rail_pivots[pivot2] = rail_pivots[pivot2] or {splines = {}, directions = {}}

        local direction2 = (direction - 1 + 8) % 16 + 1

        rail_pivots[pivot1].splines[uid] = direction
        rail_pivots[pivot2].splines[uid] = direction2

        rail_pivots[pivot1].directions[direction] = uid
        rail_pivots[pivot2].directions[direction2] = uid

        print("restored rail spline, id: " .. uid)
    else
        print("rail spline ensured successfully, id: " .. uid)
    end
    return true
end

function L._load()
    print(PACK_ID, "load")

    for uid, spline in pairs(rail_splines) do
        if not entities.exists(uid) then
            print("ERROD: not found spline entity, id: " .. uid)

            print("ABOBA AYAYA")

            L._delete_spline(uid)
        end
    end
end

function L._save()
    print(PACK_ID, "save")
end

return L
