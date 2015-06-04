local votes = 0
local starting_game = false
local ingame = false
local force_init_warning = false
local grace = false
local countdown = false

local registrants = {}
local currGame = {}

local timer_hudids = {}

local timer = nil
local timer_updated = nil
local timer_mode = nil	-- nil, "vote", "starting", "grace"

local update_timer_hud = function(text)
	local players = minetest.get_connected_players()
	for i=1,#players do
		local player = players[i]
		local name = player:get_player_name()
		if timer_hudids[name] ~= nil then
			player:hud_change(timer_hudids[name], "text", text)
		end
	end
end

local set_timer = function(name, time)
	timer_mode = name
	timer = time
	timer_updated = nil
end

local unset_timer = function()
	timer_mode = nil
	timer_updated = nil
	update_timer_hud("")
end

local end_grace = function()
	if ingame then
		minetest.setting_set("enable_pvp", "true")
		minetest.chat_send_all("Grace peroid over!")
		grace = false
		unset_timer()
		minetest.sound_play("hungry_games_grace_over")
	end
end

local drop_player_items = function(playerName, clear) --If clear != nil, don't drop items, just clear inventory
	if not playerName then
		return
	end

	local player = minetest.get_player_by_name(playerName)
	
	if not player then 
		return
	end
	
	local pos = player:getpos()
	local inv = player:get_inventory()

	if not clear then
		--Drop main and craft inventories
		local inventoryLists = {inv:get_list("main"), inv:get_list("craft")}
		
		for _,inventoryList in pairs(inventoryLists) do
			for i,v in pairs(inventoryList) do
				local obj = minetest.env:add_item({x=math.floor(pos.x)+math.random(), y=pos.y, z=math.floor(pos.z)+math.random()}, v)
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
		end
	end

	inv:set_list("craft", {})
	inv:set_list("main", {})

	--Drop armor inventory
	local armor_inv = minetest.get_inventory({type="detached", name=player:get_player_name().."_armor"})
	local player_inv = player:get_inventory()
	local armorTypes = {"head", "torso", "legs", "feet", "shield"}
	for i,stackName in ipairs(armorTypes) do
		if not clear then
			local stack = inv:get_stack("armor_" .. stackName, 1)
			local x = math.random(0, 6)/3
			local z = math.random(0, 6)/3
			pos.x = pos.x + x
			pos.z = pos.z + z
			minetest.env:add_item(pos, stack)
			pos.x = pos.x - x
			pos.z = pos.z - z
		end
		armor_inv:set_stack("armor_"..stackName, 1, nil)
		player_inv:set_stack("armor_"..stackName, 1, nil)
	end
	armor:set_player_armor(player)
	return
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
	currGame = {}
	ingame = false
	grace = false
	countdown = false
	force_init_warning = false
	unset_timer()
end

local check_win = function()
	if ingame then
		local count = 0
		for _,_ in pairs(currGame) do
			count = count + 1
		end
		if count <= 1 then
			local winnerName
			print(dump(currGame))
			for playerName,_ in pairs(currGame) do
				local winnerPos = minetest.get_player_by_name(playerName):getpos()
				winnerName = playerName
				
				minetest.chat_send_player(winnerName, "You Won!")
				minetest.chat_send_all("The Hungry Games are now over, " .. winnerName .. " was the winner")
				minetest.sound_play("hungry_games_victory")
			end
		
			local players = minetest.get_connected_players()
			for _,player in ipairs(players) do
				local name = player:get_player_name()
				local privs = minetest.get_player_privs(name)
				privs.vote = true
				minetest.set_player_privs(name, privs)
			end
			
			stop_game()
			drop_player_items(winnerName, true)
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

local reset_player_state = function(player)
	local name = player:get_player_name()
	player:set_hp(20)
	survival.reset_player_state(name, "hunger")
	survival.reset_player_state(name, "thirst")
end

minetest.register_globalstep(function(dtime)
	if timer_mode ~= nil then
		timer = timer - dtime
		if timer_updated == nil or timer_updated - timer >= 1 then
			timer_updated = timer
			if timer >= 0 then
				if timer_mode == "grace" then
					update_timer_hud(string.format("Grace period: %ds", math.ceil(timer)))
				elseif timer_mode == "vote" then
					update_timer_hud(string.format("Next round in max. %ds.", math.ceil(timer)))
				elseif timer_mode == "starting" then
					update_timer_hud(string.format("Game starts in %ds.", math.ceil(timer)))
				else
					unset_timer()
				end
			else
				unset_timer()
			end
		end
	end
end)

local start_game_now = function(contestants)
	for i,player in ipairs(contestants) do
		local name = player:get_player_name()
		currGame[name] = true
		local privs = minetest.get_player_privs(name)
		if minetest.get_player_by_name(name) then	
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
	end
	minetest.chat_send_all("The Hungry Games has begun!")
	if hungry_games.grace_period > 0 then
		if hungry_games.grace_period >= 60 then
			minetest.chat_send_all("You have "..(dump(hungry_games.grace_period)/60).."min until grace period ends!")
		else
			minetest.chat_send_all("You have "..dump(hungry_games.grace_period).."s until grace period ends!")
		end
		grace = true
		set_timer("grace", hungry_games.grace_period)
		minetest.setting_set("enable_pvp", "false")
		minetest.after(hungry_games.grace_period, end_grace)
	else
		grace = false
		unset_timer()
	end
	minetest.setting_set("enable_damage", "true")
	votes = 0
	ingame = true
	countdown = false
	starting_game = false
	minetest.sound_play("hungry_games_start")
end

local start_game = function()
	if starting_game then
		return
	end
	starting_game = true
	grace = false
	countdown = true
	
	if hungry_games.countdown > 8.336 then
		minetest.after(hungry_games.countdown-8.336, function()
			minetest.sound_play("hungry_games_prestart")
		end)
	end
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
		drop_player_items(player:get_player_name(), true)
		minetest.after(0.1, function(list)
			player = list[1]
			i = list[2]
			local name = player:get_player_name()
			if registrants[name] == true and spawning.is_spawn("player_"..i) then
				table.insert(contestants, player)
				spawning.spawn(player, "player_"..i)
				reset_player_state(player)
				minetest.chat_send_player(name, "Get ready to fight!")
			else
				minetest.chat_send_player(name, "There are no spots for you to spawn!")
			end
		end, {player, i})
		if registrants[player:get_player_name()] then i = i + 1 end
	end
	minetest.setting_set("enable_damage", "false")
	if hungry_games.countdown > 0 then
		set_timer("starting", hungry_games.countdown)
		for i=1, (hungry_games.countdown-1) do
			minetest.after(i, function(list)
				contestants = list[1]
				i = list[2]
				local time_left = hungry_games.countdown-i
				if time_left%4==0 and time_left >= 16 then
					minetest.sound_play("hungry_games_starting_drum")
				end
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
		minetest.after(hungry_games.countdown, start_game_now, contestants)
	else
		start_game_now(contestants)
	end
end

local check_votes = function()
	if not ingame then
		local players = minetest.get_connected_players()
		local num = table.getn(players)
		if num > 1 and (votes >= num or (num > hungry_games.vote_unanimous and votes > num*hungry_games.vote_percent)) then
			start_game()
			return true
		end
	end
	return false
end

--Check if theres only one player left and stop hungry games.
minetest.register_on_dieplayer(function(player)
	local playerName = player:get_player_name()	
	local pos = player:getpos()
	
	local count = 0
	for _,_ in pairs(currGame) do
		count = count + 1
	end
	count = count - 1
	
	if ingame and currGame[playerName] and count ~= 1 then
		minetest.chat_send_all(playerName .. " has died! Players left: " .. tostring(count))		
	end	

	drop_player_items(playerName)
	currGame[playerName] = nil
	check_win()

   	local privs = minetest.get_player_privs(playerName)
	if privs.interact then
		minetest.sound_play("hungry_games_death", {pos = pos})
	end
	if privs.interact or privs.fly then
   		if privs.interact and (hungry_games.death_mode == "spectate") then 
		   	privs.fast = true
			privs.fly = true
			privs.interact = nil
			minetest.set_player_privs(playerName, privs)
			minetest.chat_send_player(playerName, "You are now spectating")
		end
   	end
end)

minetest.register_on_respawnplayer(function(player)
	player:set_hp(1)
	local name = player:get_player_name()
   	local privs = minetest.get_player_privs(name)
   	if (privs.interact or privs.fly) and (hungry_games.death_mode == "spectate") then
		spawning.spawn(player, "spawn")
	elseif (hungry_games.death_mode == "lobby") then
		spawning.spawn(player, "lobby")
	end
	return true
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
	timer_hudids[name] = player:hud_add({
		hud_elem_type = "text",
		position = { x=0.5, y=0 },
		offset = { x=0, y=20 },
		direction = 0,
		text = "",
		number = 0xFFFFFF,
		alignment = {x=0,y=0},
		size = {x=100,y=24},
	})
end)

minetest.register_on_newplayer(function(player)
	local name = player:get_player_name()
   	local privs = minetest.get_player_privs(name)
	privs.register = true
	minetest.set_player_privs(name, privs)

end)

minetest.register_on_leaveplayer(function(player)
	local name = player:get_player_name()
	drop_player_items(player:get_player_name())
	currGame[name] = nil
	timer_hudids[name] = nil
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
	params = "start | stop | build | set player_<n> | lobby | spawn",
	description = "Manage Hungry Games. start: Start/restart Hungry Games; stop: Abort current game; build: Building mode to set up lobby, arena, etc.; set player_<n>: Set spawn position of player <n> (starting by 1); set lobby: Set spawn position in lobby; set spawn: Set initial spawn position for new players.",
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
			if parms[2] ~= nil and (parms[2] == "spawn" or parms[2] == "lobby" or parms[2]:match("player_%d")) then
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
		else
			minetest.chat_send_player(name, "Unknown subcommand! Use /help hg for a list of available subcommands.")
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
			minetest.chat_send_all(name.. " has have voted to begin! Votes so far: "..votes.."; Votes needed: "..((num > hungry_games.vote_unanimous and num*hungry_games.vote_percent) or num) )

			local cv = check_votes()
			if votes > 1 and force_init_warning == false and cv == false then
				minetest.chat_send_all("The match will automatically be initiated in 5min.")
				force_init_warning = true
				set_timer("vote", 60*5)
				minetest.after((60*5), function () 
					if not (starting_game or ingame) then
						start_game()
					end
				end)
			end
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
