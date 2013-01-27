spawning = {}


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
