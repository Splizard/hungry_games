local votes = 0
local ingame = false

local end_grace = function()
	minetest.setting_set("enable_pvp", "true")
	minetest.chat_send_all("Grace peroid over!")
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
				if privs.privs or privs.server then
					local pos = player:getpos()
					minetest.chat_send_player(name, "You Won!!")
					winner = name
					privs.fast = true
					privs.fly = true
					privs.interact = true
					minetest.set_player_privs(name, privs)
					minetest.chat_send_player(name, "You are now spectating")
					inv = player:get_inventory()
					minetest.env:add_item(pos, player:get_wielded_item())
				elseif privs.interact and player:get_hp() > 0 then
					local pos = player:getpos()
					minetest.chat_send_player(name, "You Won!!")
					winner = name
					privs.fast = true
					privs.fly = true
					privs.interact = false
					minetest.set_player_privs(name, privs)
					minetest.chat_send_player(name, "You are now spectating")
					inv = player:get_inventory()
					minetest.env:add_item(pos, player:get_wielded_item())
					if inv then
						inv:set_list("main", {})
					end
				end
			end
			minetest.auth_reload()
			for _,player in ipairs(players) do
				local name = player:get_player_name()
			   	local privs = minetest.get_player_privs(name)
				privs.vote = true
				minetest.set_player_privs(name, privs)
			end
			minetest.chat_send_all("The Hungry Games is now over! "..winner.." was the winner!")
			minetest.auth_reload()
			ingame = false
		end
	end
end

local start_game = function()
	for _,player in  pairs(minetest.get_connected_players() ) do
		minetest.after(0.1, function(player)
			local name = player:get_player_name()
		   	local privs = minetest.get_player_privs(name)
			if privs.privs or privs.server then
				privs.fast = false
				privs.fly = false
				privs.give = false
			else
				privs.fast = false
				privs.fly = false
				privs.interact = true
				privs.vote = false
				minetest.set_player_privs(name, privs)
				minetest.auth_reload()
			end
			player:set_hp(20)
			spawning.spawn(player)
		end, player)
	end
	minetest.chat_send_all("The Hunger Games has begun!")
	minetest.chat_send_all("You have 1min until grace period ends!")
	minetest.setting_set("enable_pvp", "false")
	minetest.after(60, end_grace)
	minetest.auth_reload()
	votes = 0
	ingame = true
end

local check_votes = function()
	local players = minetest.get_connected_players()
	local num = table.getn(players)
	if votes >= num or (num > 5 and votes > num*0.75) then
		start_game()
	end
end

--Check if theres only one player left and stop hungry games.
minetest.register_on_dieplayer(function(player)
	check_win()
end)

minetest.register_on_joinplayer(function(player)
	local name = player:get_player_name()
   	local privs = minetest.get_player_privs(name)
	privs.vote = true
	minetest.set_player_privs(name, privs)
	minetest.auth_reload()
end)

minetest.register_on_leaveplayer(function(player)
	local name = player:get_player_name()
   	local privs = minetest.get_player_privs(name)
	if not privs.vote and votes > 0 then
		votes = votes - 1
	end
	minetest.after(1, function()
		check_votes()
		check_win()
	end)
end)

minetest.register_privilege("hg_admin", "Hungry Games Admin..")
minetest.register_privilege("vote", "Privilege to vote.")

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
			for _,player in ipairs(minetest.get_connected_players()) do
				local name = player:get_player_name()
			   	local privs = minetest.get_player_privs(name)
				if privs.privs or privs.server then
				else
					privs.fast = true
					privs.fly = true
					privs.interact = false
					privs.vote = true
					minetest.set_player_privs(name, privs)	
				end
				minetest.auth_reload()
				player:set_hp(20)
				spawning.spawn(player)
			end
			minetest.chat_send_all("The Hunger Games has been stopped!")
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
		local privs = minetest.get_player_privs(name)
		privs.vote = false
		minetest.set_player_privs(name, privs)
		minetest.auth_reload()
		votes = votes + 1
		minetest.chat_send_all(name.. " has have voted to begin! votes so far: "..votes.." votes needed: "..((num > 5 and num*0.75) or num) )
		check_votes()
	end,
})
