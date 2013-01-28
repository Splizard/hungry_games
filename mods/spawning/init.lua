spawning = {}
spawning.point = {x=0,y=0,z=0}

function spawning.on_death(mode)
	if mode == "spectate" then
		minetest.register_on_dieplayer(function(player)
		   	local name = player:get_player_name()
		   	local privs = minetest.get_player_privs(name)
			if privs.privs or privs.server then
				minetest.chat_send_player(name, "You are now spectating")
			else
				privs.fast = true
				privs.fly = true
				privs.interact = false
				minetest.set_player_privs(name, privs)
				minetest.auth_reload()
				minetest.chat_send_player(name, "You are now spectating")
			end
		end)		
	end
end

function spawning.on_join(mode)
	if mode == "spectate" then
		minetest.register_on_joinplayer(function(player)
		   	local name = player:get_player_name()
		   	local privs = minetest.get_player_privs(name)
			if privs.privs or privs.server then
				minetest.chat_send_player(name, "You are now spectating")
			else
				privs.fast = true
				privs.fly = true
				privs.interact = false
				minetest.set_player_privs(name, privs)
				minetest.auth_reload()
				minetest.chat_send_player(name, "You are now spectating")
			end
		end)		
	end
end

function spawning.set_spawn(mode, param)
	if mode == "static" then
		spawning.point = {x=param[1],y=param[2],z=param[3]}
		function spawning.spawn(player)
		   	local pos = spawning.point
		   	local env = minetest.env
		   	if pos then
				if env:get_node({x=pos.x,y=pos.y+1,z=pos.z}).name ~= "air" then
					for y=pos.y, pos.y+25 do
						local node = env:get_node({x=pos.x,y=y,z=pos.z})
						if node.name == "ignore" then
							player:setpos({x=pos.x,y=pos.y+y+1,z=pos.z})
							minetest.after(2, spawning.spawn, player)
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
		end	
		minetest.register_on_respawnplayer(spawning.spawn)
		minetest.register_on_joinplayer(spawning.spawn)
	elseif mode == "dynamic" then
		minetest.register_on_respawnplayer(glass_arena.teleport)
		minetest.register_on_joinplayer(glass_arena.teleport)
		spawning.spawn = glass_arena.teleport
	end
end
