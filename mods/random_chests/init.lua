local random_items = {}
local chest_rarity = 3
local chests_spawn = true
local chests_abm = false
local chests_nodetimer = false
local chests_interval = nil


--Spawn items in chest
local fill_chest = function(pos)
	local invcontent = {}
	for i,v in pairs(random_items) do
		if math.random(1, v[2]) == 1 then
			table.insert(invcontent, v[1].." "..tostring(math.random(1,v[3])) )
		end
	end
	minetest.env:add_node(pos,{name='default:chest', inv=invcontent})	
	local meta = minetest.env:get_meta(pos)
	local inv = meta:get_inventory()
	for _,itemstring in ipairs(invcontent) do
		inv:add_item('main', itemstring)
	end
	--Restart nodetimer
	if chests_nodetimer then
		local timer = minetest.env:get_node_timer(pos)
		timer:start(chests_interval)
	end
end

--API defintions
random_chests = {}

--Register a new item that can be spawned in random chests.
--eg random_chests.register_item('default:torch', 4, 6) #has a 1 in 4 chance of spawning up to 6 torches.
function random_chests.register_item(item, rarity, max)
	assert(item and rarity and max)
	table.insert(random_items, {item, rarity, max})
end

--Set rarity of the chests. (n = How many per chunk).
function random_chests.set_rarity(n)
	chest_rarity = tonumber(n) or 3
end

--Enable/Disable chests to spawn.
--Disable this if you want to hide your own chests in the world.
function random_chests.enable(b)
	if b == nil then b = true end
	chests_spawn = b
end

--Refill chests
function random_chests.setrefill(mode, interval)
	if interval < 100 then
		print("random_chests: WARNING! You have made the chest refill rate very high!")
	end
	if mode == "abm" then
		minetest.register_abm({
			nodenames = {"default:chest"},
			interval = interval,
			chance = 1,
			action = fill_chest,
		})
	elseif mode == "nodetimer" then
		--Add nodetimer to chests.
		chests_interval = interval
		local chest = {}
		for k,v in pairs(minetest.registered_nodes["default:chest"]) do
			chest[k] = v
		end
		chest.on_timer = fill_chest
		chest.on_construct = function(pos)
			local timer = minetest.env:get_node_timer(pos)
			timer:start(interval)
			local meta = minetest.env:get_meta(pos)
			meta:set_string("formspec",
					"size[8,9]"..
					"list[current_name;main;0,0;8,4;]"..
					"list[current_player;main;0,5;8,4;]")
			meta:set_string("infotext", "Chest")
			local inv = meta:get_inventory()
			inv:set_size("main", 8*4)
		end
		minetest.register_node(":default:chest", chest)
	end
end

--Spawning function.
minetest.register_on_generated(function(minp, maxp, seed)
	if chests_spawn then
		for i=1, chest_rarity do
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
				fill_chest({x=pos.x,y=ground+1,z=pos.z})
				--print("spawn near "..pos.x.." "..pos.z)
			end
		end	
	end
end)
