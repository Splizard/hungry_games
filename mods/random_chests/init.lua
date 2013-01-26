--local random_seed = math.random(0,1000)

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
			--local rand = PseudoRandom(seed+random_seed)
			local rand = {}
			function rand:next(x,y) return math.random(x,y) end
			if rand:next(1,4) == 1 then
				table.insert(invcontent, 'default:apple '..tostring(rand:next(1,5)))
			end
			if rand:next(1,8) == 1 then
				table.insert(invcontent, 'default:ladder '..tostring(rand:next(1,5)))
			end
			if rand:next(1,4) == 1 then
				table.insert(invcontent, 'default:torch '..tostring(rand:next(1,6)))
			end
			if rand:next(1,3) == 1 then
				table.insert(invcontent, 'default:sword_wood 1')
			end
			if rand:next(1,3) == 1 then
				table.insert(invcontent, 'default:axe_wood 1')
			end
			if rand:next(1,5) == 1 then
				table.insert(invcontent, 'default:axe_stone 1')
			end
			if rand:next(1,10) == 1 then
				table.insert(invcontent, 'default:axe_steel 1')
			end
			if rand:next(1,3) == 1 then
				table.insert(invcontent, 'throwing:bow_wood 1')
			end
			if rand:next(1,20) == 1 then
				table.insert(invcontent, 'bucket:bucket_lava 1')
			end
			if rand:next(1,5) == 1 then
				table.insert(invcontent, 'default:sword_stone 1')
			end
			if rand:next(1,5) == 1 then
				table.insert(invcontent, 'throwing:bow_stone 1')
			end
			if rand:next(1,10) == 1 then
				table.insert(invcontent, 'default:sword_steel 1')
			end
			if rand:next(1,10) == 1 then
				table.insert(invcontent, 'throwing:bow_steel 1')
			end
			if rand:next(1,10) == 1 then
				table.insert(invcontent, 'bread:bread 1')
			end
			if rand:next(1,5) == 1 then
				table.insert(invcontent, 'bread:bun 1')
			end
			if rand:next(1,3) == 1 then
				table.insert(invcontent, 'bread:slice 1')
			end
			if rand:next(1,4) == 1 then
				table.insert(invcontent, 'throwing:arrow '..tostring(rand:next(1,6)))
			end
			if rand:next(1,6) == 1 then
				table.insert(invcontent, 'throwing:arrow_fire '..tostring(rand:next(1,6)))
			end
			if rand:next(1,20) == 1 then
				table.insert(invcontent, 'throwing:arrow_teleport '..tostring(rand:next(1,6)))
			end
			env:add_node(pos,{name='default:chest', inv=invcontent})	
			local meta = minetest.env:get_meta(pos)
			local inv = meta:get_inventory()
			for _,itemstring in ipairs(invcontent) do
				inv:add_item('main', itemstring)
			end
			print("spawn near "..pos.x.." "..pos.z)
		end
	end	
end)
