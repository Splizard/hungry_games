spawning = {}
local registered_spawns = {}
local filepath = minetest.get_worldpath()..'/spawning'

--Load spawns
local input = io.open(filepath..".spawns", "r")
if input then
    while true do
        local nodename = input:read("*l")
        if not nodename then break end
        local parms = {}
        --Catch config.
		i, flags = nodename:match("^(%S*) (.*)")
		repeat
			v, p = flags:match("^(%S*) (.*)")
			if p then
				flags = p
			end
			if v then
				table.insert(parms,v)
			else
				v = flags:match("^(%S*)")
				table.insert(parms,v)
				break
			end
		until false
		registered_spawns[i] = {
			pos={x=parms[1],y=parms[2],z=parms[3]}
		}
	end
	io.close(input)
end

function spawning.save_spawns()
	local output = io.open(filepath..".spawns", "w")
	for i,v in pairs(registered_spawns) do
		output:write(i.." "..v.pos.x.." "..v.pos.y.." "..v.pos.z.."\n")
	end
	io.close(output)
end

function spawning.on_death(mode)
	if mode == "spectate" then
		minetest.register_on_dieplayer(function(player)
		   	local name = player:get_player_name()
		   	local privs = minetest.get_player_privs(name)
			privs.fast = true
			privs.fly = true
			privs.interact = false
			minetest.set_player_privs(name, privs)
			minetest.auth_reload()
			minetest.chat_send_player(name, "You are now spectating")
		end)		
	end
end

function spawning.on_join(mode)
	if mode == "spectate" then
		minetest.register_on_joinplayer(function(player)
		   	local name = player:get_player_name()
		   	local privs = minetest.get_player_privs(name)
			privs.fast = true
			privs.fly = true
			privs.interact = false
			minetest.set_player_privs(name, privs)
			minetest.auth_reload()
			minetest.chat_send_player(name, "You are now spectating")
		end)		
	end
end

--Set spawn pos
function spawning.set_spawn(place, pos)
	local spawn = registered_spawns[place]
	if not spawn then spawning.register_spawn(place, {}) end
	
	registered_spawns[place].pos = pos
	
	--Save spawns.
	spawning.save_spawns()
end

function spawning.is_spawn(place)
	local spawn = registered_spawns[place]
	if not spawn then return false else return true end
end

function spawning.spawn(player, place)
	local spawn = registered_spawns[place]
	if spawn then
		--if spawn.mode == "static" then
		   	local pos = spawn.pos
		   	local env = minetest.env
		   	if pos then
				if env:get_node({x=pos.x,y=pos.y+1,z=pos.z}).name ~= "air" then
					for y=pos.y, pos.y+30 do
						local node = env:get_node({x=pos.x,y=y,z=pos.z})
						if node.name == "ignore" then
							player:setpos({x=pos.x,y=pos.y+y+1,z=pos.z})
							minetest.after(2, spawning.spawn, player, place)
							return true
						end
						if node.name == "air" then
							player:setpos({x=pos.x,y=pos.y+y+1,z=pos.z})
							return true
						elseif node.name == "default:water_source" then
							player:setpos({x=pos.x,y=pos.y+y+1,z=pos.z})
							return true
						end
					end
					player:setpos({x=pos.x,y=pos.y+25,z=pos.z})
				end
				player:setpos(pos)
				return true
			end
		--end
	end
end

function spawning.register_spawn(name, spawndef)
	local pos
	--Save spawnpoint position if it is already assigned.
	if registered_spawns[name] then pos = registered_spawns[name].pos end
	
	-- Apply defaults and add to registered_* table.
	setmetatable(spawndef, {__index = spawning.spawndef_default})
	registered_spawns[name] = spawndef
	
	--Restore position if it was already assigned.
	if pos then registered_spawns[name].pos = pos end
	
	--Save spawns.
	spawning.save_spawns()
end

spawning.spawndef_default = {
	pos = {x=0, y=0, z=0},
	mode = "static",
}
