local random_items = {}

random_chests = {}
--Regester a new item that can be spawned in random chests.
--eg random_chests.register_item('default:torch', 4, 6) #has a 1 in 4 chance of spawning up to 6 torches.
function random_chests.register_item(item, rarity, max)
	assert(item and rarity and max)
	table.insert(random_items, {item, rarity, max})
end


minetest.register_on_generated(function(minp, maxp, seed)
	for i=0, 3 do
		local pos = {x=math.random(minp.x,maxp.x),z=math.random(minp.z,maxp.z), y=minp.y}
		local env = minetest.env
		 -- Find ground level (0...15)
		local ground = nil
		for y=maxp.y,minp.y+1,-1 do
			if env:get_node({x=pos.x,y=y,z=pos.z}).name ~= "air" and env:get_node({x=pos.x,y=y,z=pos.z}).name ~= "default:water_source" and env:get_node({x=pos.x,y=y,z=pos.z}).name ~= "snow:snow" then
				ground = y
				break
			end
		end
		
		if ground then
			local invcontent = {}
			local pos = {x=pos.x,y=ground+1,z=pos.z}
			--Spawn items in chest
			for i,v in pairs(random_items) do
				if math.random(1, v[2]) == 1 then
					table.insert(invcontent, v[1].." "..tostring(math.random(1,v[3])) )
				end
			end
			env:add_node(pos,{name='default:chest', inv=invcontent})	
			local meta = minetest.env:get_meta(pos)
			local inv = meta:get_inventory()
			for _,itemstring in ipairs(invcontent) do
				inv:add_item('main', itemstring)
			end
			--print("spawn near "..pos.x.." "..pos.z)
		end
	end	
end)
