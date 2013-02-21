local votes = 0
local ingame = false

local registrants = {}

local end_grace = function()
	if ingame then
		minetest.setting_set("enable_pvp", "true")
		minetest.chat_send_all("Grace peroid over!")
	end
end

local stop_game = function()
	for _,player in ipairs(minetest.get_connected_players()) do
		minetest.after(0.1, function()
			local name = player:get_player_name()
		   	local privs = minetest.get_player_privs(name)
			privs.fast = nil
			privs.fly = nil
			privs.interact = nil
			privs.vote = true
			minetest.set_player_privs(name, privs)
			player:set_hp(20)
			spawning.spawn(player, "lobby")
		end)
	end
	registrants = {}
	ingame = false
end

local check_win = function()
	if ingame then
		local players = minetest.get_connected_players()
		local winner = ""
		local counter = table.getn(players)
		for _,player in ipairs(players) do
			local name = player:get_player_name()
		   	local privs = minetest.get_player_privs(name)
			if not privs.interact then
				counter = counter - 1
			elseif player:get_hp() < 1 then
				counter = counter - 1
			end
		end
		if counter <= 1 then
			for _,player in ipairs(players) do
				local name = player:get_player_name()
			   	local privs = minetest.get_player_privs(name)
				if privs.interact and player:get_hp() > 0 then
					local pos = player:getpos()
					minetest.chat_send_player(name, "You Won!!")
					winner = name
					privs.fast = nil
					privs.fly = nil
					privs.interact = nil
					minetest.set_player_privs(name, privs)
					minetest.chat_send_player(name, "You are now spectating")
					inv = player:get_inventory()
					minetest.env:add_item(pos, player:get_wielded_item())
					if inv then
						inv:set_list("main", {})
					end
				end
			end

			for _,player in ipairs(players) do
				local name = player:get_player_name()
			   	local privs = minetest.get_player_privs(name)
				privs.vote = true
				minetest.set_player_privs(name, privs)
			end
			if winner ~= "" then
				minetest.chat_send_all("The Hungry Games is now over! "..winner.." was the winner!")
			else
				minetest.chat_send_all("The Hungry Games is now over!  No survivors!")
			end

			stop_game()
		end
	end
end

local get_spots = function()
	i = 1
	while true do
		if spawning.is_spawn("player_"..i) then
			i = i + 1
		else
			return i - 1
		end
	end
end

local start_game_now = function(contestants)
	for i,player in ipairs(contestants) do
		local name = player:get_player_name()
		local privs = minetest.get_player_privs(name)
		privs.fast = nil
		privs.fly = nil
		privs.interact = true
		privs.vote = nil
		minetest.set_player_privs(name, privs)
		minetest.after(0.1, function(table)
			player = table[1]
			i = table[2]
			local name = player:get_player_name()
			if spawning.is_spawn("player_"..i) then
				spawning.spawn(player, "player_"..i)
			end
		end, {player, i})
	end
	minetest.chat_send_all("The Hungry Games has begun!")
	minetest.chat_send_all("You have 1min until grace period ends!")
	minetest.setting_set("enable_pvp", "false")
	minetest.after(60, end_grace)
	minetest.sound_play("hungry_games_death")
	votes = 0
	ingame = true
end

local start_game = function()
	print("filling chests...")
	random_chests.refill()
	local i = 1
	--Find out how many spots there are to spawn
	local spots = get_spots()
	local diff =  spots-table.getn(registrants)
	local contestants = {}
	for _,player in pairs(minetest.get_connected_players() ) do
		if diff > 0 then
			registrants[player:get_player_name()] = true
			diff = diff - 1
		end
		minetest.after(0.1, function(list)
			player = list[1]
			i = list[2]
			local name = player:get_player_name()
			if registrants[name] == true and spawning.is_spawn("player_"..i) then
				player:set_hp(20)
				table.insert(contestants, player)
				spawning.spawn(player, "player_"..i)
				hunger.reset(name)
			else
				minetest.chat_send_player(name, "There are no spots for you to spawn!")
				if privs.hg_admin then
					minetest.chat_send_player(name, "Try setting some with the /hg set player_#")
				end
			end
		end, {player, i})
		if registrants[player:get_player_name()] then i = i + 1 end
	end
	minetest.chat_send_all("Starting in "..dump(10))
	for i=1, 9 do
		minetest.after(i, function(list)
			contestants = list[1]
			i = list[2]
			minetest.chat_send_all("Starting in "..dump(10-i))
			for i,player in ipairs(contestants) do
				minetest.after(0.1, function(table)
					player = table[1]
					i = table[2]
					local name = player:get_player_name()
					if spawning.is_spawn("player_"..i) then
						spawning.spawn(player, "player_"..i)
					end
				end, {player, i})
			end
		end, {contestants,i})
	end
	minetest.after(10, start_game_now, contestants)
end

local check_votes = function()
	if not ingame then
		local players = minetest.get_connected_players()
		local num = table.getn(players)
		if num > 1 and (votes >= num or (num > 5 and votes > num*0.75)) then
			start_game()
		end
	end
end

--Check if theres only one player left and stop hungry games.
minetest.register_on_dieplayer(function(player)
	check_win()
	local name = player:get_player_name()
   	local privs = minetest.get_player_privs(name)
   	if privs.interact then
   		minetest.sound_play("hungry_games_death")
   	end
	privs.fast = true
	privs.fly = true
	privs.interact = nil
	minetest.set_player_privs(name, privs)
	minetest.chat_send_player(name, "You are now spectating")
end)

minetest.register_on_respawnplayer(function(player)
	player:set_hp(1)
end)

minetest.register_on_joinplayer(function(player)
	local name = player:get_player_name()
   	local privs = minetest.get_player_privs(name)
	privs.vote = true
	privs.register = true
	privs.fast = nil
	privs.fly = nil
	privs.interact = nil
	minetest.set_player_privs(name, privs)
	minetest.chat_send_player(name, "You are now spectating")
	spawning.spawn(player, "lobby")
end)

minetest.register_on_newplayer(function(player)
	local name = player:get_player_name()
   	local privs = minetest.get_player_privs(name)
	privs.register = true
	minetest.set_player_privs(name, privs)

end)

minetest.register_on_leaveplayer(function(player)
	local name = player:get_player_name()
   	local privs = minetest.get_player_privs(name)
	if not privs.vote and votes > 0 then
		votes = votes - 1
	end
	if registrants[name] then registrants[name] = nil end
	minetest.after(1, function()
		check_votes()
		check_win()
	end)
end)

minetest.register_privilege("hg_admin", "Hungry Games Admin.")
minetest.register_privilege("hg_maker", "Hungry Games Map Maker.")
minetest.register_privilege("vote", "Privilege to vote.")
minetest.register_privilege("register", "Privilege to register.")

--Hungry Games Chat Commands.
minetest.register_chatcommand("hg", {
	params = "<command>",
	description = "Manage hungry_games",
	privs = {hg_admin=true},
	func = function(name, param)
		--Catch param.
		local parms = {}
		repeat
			v, p = param:match("^(%S*) (.*)")
			if p then
				param = p
			end
			if v then
				table.insert(parms,v)
			else
				v = param:match("^(%S*)")
				table.insert(parms,v)
				break
			end
		until false
		--Restarts/Starts game.
		if parms[1] == "restart" or parms[1] == 'r' or parms[1] == "start" then
			start_game()
		--Stops Game.
		elseif parms[1] == "stop" then
			stop_game()
			minetest.chat_send_all("The Hunger Games has been stopped!")
		elseif parms[1] == "build" then
			if not ingame then
				local privs = minetest.get_player_privs(name)
				privs.interact = true
				privs.fly = true
				privs.fast = true
				minetest.set_player_privs(name, privs)

				minetest.chat_send_player(name, "You now have interact and fly/fast!")
			else
				minetest.chat_send_player(name, "You cant build while in a match!")
				return
			end
		elseif parms[1] == "set" then
			if parms[2] == "spawn" or parms[2] == "lobby" or parms[2]:match("player_%d") then
				local pos = {}
				if parms[3] and parms[4] and parms[5] then
					pos = {x=parms[3],y=parms[4],z=parms[5]}
					spawning.set_spawn(parms[2], pos)
				else
					pos = minetest.env:get_player_by_name(name):getpos()
					spawning.set_spawn(parms[2], pos)
				end
				minetest.chat_send_player(name, parms[2].." has been set to "..pos.x.." "..pos.y.." "..pos.z)
			else
				minetest.chat_send_player(name, "Set what?")
			end
		end
	end,
})

minetest.register_chatcommand("vote", {
	description = "Vote to start the Hungry Games",
	privs = {vote=true},
	func = function(name, param)
		local players = minetest.get_connected_players()
		local num = table.getn(players)
		if num == 1 then
			minetest.chat_send_player(name, "Need more players!")
			return
		end
		if not ingame then
			local privs = minetest.get_player_privs(name)
			privs.vote = nil
			minetest.set_player_privs(name, privs)

			votes = votes + 1
			minetest.chat_send_all(name.. " has have voted to begin! votes so far: "..votes.." votes needed: "..((num > 5 and num*0.75) or num) )
			check_votes()
		else
			minetest.chat_send_player(name, "Already ingame!")
			return
		end
	end,
})

minetest.register_chatcommand("register", {
	description = "Register to take part in the Hungry Games",
	privs = {register=true},
	func = function(name, param)
		--Catch param.
		local parms = {}
		repeat
			v, p = param:match("^(%S*) (.*)")
			if p then
				param = p
			end
			if v then
				table.insert(parms,v)
			else
				v = param:match("^(%S*)")
				table.insert(parms,v)
				break
			end
		until false
		if table.getn(registrants) < get_spots() then
			registrants[name] = true
			minetest.chat_send_player(name, "You have registered!")
		else
			minetest.chat_send_player(name, "Sorry! no spots left!")
		end
	end,
})

minetest.register_chatcommand("build", {
	description = "Give yourself interact",
	privs = {hg_maker=true},
	func = function(name, param)
		if not ingame then
				local privs = minetest.get_player_privs(name)
				privs.interact = true
				privs.fly = true
				privs.fast = true
				minetest.set_player_privs(name, privs)

				minetest.chat_send_player(name, "You now have interact and fly/fast!")
		else
			minetest.chat_send_player(name, "You cant build while in a match!")
			return
		end
	end,
})

minetest.register_tool(":default:admin_pick", {
	description = "Admin Pickaxe",
	inventory_image = "default_tool_mesepick.png",
	tool_capabilities = {
		full_punch_interval = 0.65,
		max_drop_level=3,
		groupcaps={
			crumbly = {times={[1]=0.5, [2]=0.5, [3]=0.5}, uses=0, maxlevel=3},
			cracky = {times={[1]=0.5, [2]=0.5, [3]=0.5}, uses=0, maxlevel=3},
			snappy = {times={[1]=0.5, [2]=0.5, [3]=0.5}, uses=0, maxlevel=3},
			choppy = {times={[1]=0.5, [2]=0.5, [3]=0.5}, uses=0, maxlevel=3},
			oddly_breakable_by_hand = {times={[1]=0.5, [2]=0.5, [3]=0.5}, uses=0, maxlevel=3},
		}
	},
})

minetest.register_craftitem("hungry_games:planks", {
	description = "Planks",
	inventory_image = "default_wood.png",
	groups = {wood=1},
})

minetest.register_craftitem("hungry_games:stones", {
	description = "Stones",
	inventory_image = "default_cobble.png",
	groups = {stone=1},
})
