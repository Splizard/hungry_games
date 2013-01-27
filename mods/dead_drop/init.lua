minetest.register_on_dieplayer(function(player)
		local pos = player:getpos()
		inv = player:get_inventory()
		inventorylist = inv:get_list("main")
		--Drop all players items
		for i,v in pairs(inventorylist) do
            obj = minetest.env:add_item({x=math.floor(pos.x)+math.random(), y=pos.y, z=math.floor(pos.z)+math.random()}, v)
            if obj ~= nil then
				obj:get_luaentity().collect = true
				local x = math.random(1, 5)
				if math.random(1,2) == 1 then
					x = -x
				end
				local z = math.random(1, 5)
				if math.random(1,2) == 1 then
					z = -z
				end
				obj:setvelocity({x=1/x, y=obj:getvelocity().y, z=1/z})
			end
        end
       	inv:set_list("main", {})
        return
end)
