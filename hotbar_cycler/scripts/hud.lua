function on_hud_open(player_id)
    input.add_callback("hotbar_cycler.cycle_hotbar", function()
        local player_inv, _ = player.get_inventory(player_id)
        local temp_inv = inventory.create(10)

        for i = 0, 9 do
            inventory.move(player_inv, i, temp_inv, i)
        end
        for i = 0, 9 do
            inventory.move(player_inv, i + 10, player_inv, i)
        end
        for i = 0, 9 do
            inventory.move(player_inv, i + 20, player_inv, i + 10)
        end
        for i = 0, 9 do
            inventory.move(player_inv, i + 30, player_inv, i + 20)
        end
        for i = 0, 9 do
            inventory.move(temp_inv, i, player_inv, i + 30)
        end

        inventory.remove(temp_inv)
    end)
end
