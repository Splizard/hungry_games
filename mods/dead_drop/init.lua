--Drop the item the player was holding
minetest.register_on_dieplayer(function(player)
		local pos = player:getpos()
		inv = player:get_inventory()
		minetest.env:add_item(pos, player:get_wielded_item())
       	inv:set_list("main", {})
        return
end)
