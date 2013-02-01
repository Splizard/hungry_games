--This is a modifyed version of hunger mod for the hungry_games

hunger = {}	-- Exported functions

local players_hungry = 			{}		-- Counts the hunger of the player

local steady_hurt_time					-- When the hunger of the player is higher than this he will die very fast

local START_HUNGER_SECONDS = 	230 	-- 3 minutes
local FACTOR_HUNGER_SECONDS = 	2
local MIN_HUNGER_SECONDS = 		1		-- Scheduled damage offsets won't be shorter than this. To prevent infinite calculations.
local HUNGER_DAMAGE = 			1		-- The damage dealt per scheduled offset.
local MIN_TIME_SLICE = 			0.5   	-- Minimum number of seconds that must pass before
										-- the system actually does some expensive calculations.

local HUNGER_TOOLNAME           = "hunger:hunger_meter"
local HUNGER_TOOLDESC           = "Hunger-O-Meter"									  
									  
local timer = 					0

--HUNGRY_GAMES FUNCTION
function hunger.reset(name)
	players_hungry[name] = {count=0}
end

-- Calculating the countertime the player gets hurt. y=x+(x/2^1)+(x/2^2)+(x/2^3)... x=START_HUNGER_SECONDS
-- This table is only generated once at the start of the game.
if hunger_times == nil then
	hunger_times = {}
	local hurt_time = START_HUNGER_SECONDS
	local power = 1
	while ((hurt_time + math.floor(START_HUNGER_SECONDS / math.floor(math.pow(FACTOR_HUNGER_SECONDS, power)))) - hurt_time) >= MIN_HUNGER_SECONDS do
		table.insert (hunger_times, hurt_time)
		hurt_time = hurt_time + math.floor(START_HUNGER_SECONDS / math.floor(math.pow(FACTOR_HUNGER_SECONDS, power)))
		power = power + 1
		steady_hurt_time = hurt_time
	end
end

-- Load and save hungercounter in "hunger_[playername].txt"
local function set_hunger(name, value)
	local output = io.open(minetest.get_worldpath() .. "/hunger_" .. name .. ".txt", "w")
	output:write(value)
	io.close(output)
end

local function get_hunger(name)
	local input = io.open(minetest.get_worldpath() .. "/hunger_" .. name .. ".txt", "r")
	if not input then 
		return nil
	end
	local hunger = input:read("*n")
	io.close(input)
	return hunger
end

minetest.register_on_joinplayer(function(player)
	name = player:get_player_name()
	if not get_hunger(name) then
		set_hunger(name, 0)
	end
	players_hungry[name] = {count=get_hunger(name)}
end)

------------------------------------------------------------------------
-- Find index of player's first "hunger meter" tool the main inventory.
--
local function find_first_hunger_tool_index(player)
	local inventory = player:get_inventory()

	if inventory then
		for i, iref in ipairs(inventory:get_list("main")) do
			if iref:get_name() == HUNGER_TOOLNAME then
				return i
			end
		end
	end
	return nil
end



------------------------------------------------------------------------
-- Display the current drown status in the player's first "hunger meter"
-- tool found in his/her main inventory.
--
local function update_hunger_meter(player)
	local htool = find_first_hunger_tool_index(player)

	if htool then
		local name   = player:get_player_name()
        local hunger = math.min(players_hungry[name].count, steady_hurt_time)
		local wear   = (hunger / steady_hurt_time) * 65535

		if hunger == 0 then
			player:get_inventory():set_stack("main", htool, ItemStack(HUNGER_TOOLNAME))
		else
			player:get_inventory():set_stack("main", htool,
				ItemStack(HUNGER_TOOLNAME.." 1 "..wear))
		end
	end
end

-- hurt player
local function hurt_player(player)
	local name = player:get_player_name()
	if 	player:get_hp() > 0 then
		-- making damage, play sound
		player:set_hp(player:get_hp() - HUNGER_DAMAGE)
		pos = player:getpos()
		pos.y=pos.y+1
		minetest.sound_play({name="hunger_stomach"}, {pos = pos, gain = 1.0, max_hear_distance = 16})
		minetest.chat_send_player(name, "You are hungry.")
	else
		-- so it isn't making sounds when you are dead
		players_hungry[name] = {count=0}
	end
end

-- main function
minetest.register_globalstep(function(dtime)
	timer = timer + dtime
	if timer >= .5 then
		timer = timer - .5
	else
		return
	end
	for _,player in ipairs(minetest.get_connected_players()) do
			local name = player:get_player_name()
			local privs = minetest.get_player_privs(name)
			if privs.interact and not (privs.hg_maker and privs.fly) then
				if players_hungry[name] == nil then
					players_hungry[name] = {count=0}
				end
				players_hungry[name].count = players_hungry[name].count + .5
				if players_hungry[name].count >= steady_hurt_time then
					hurt_player(player)
				else
					for _,hunger_times in ipairs(hunger_times) do
						if players_hungry[name].count == hunger_times then
							hurt_player(player)
						end
					end
				end
		update_hunger_meter(player)
		-- save hungercounter
		set_hunger(name, players_hungry[name].count)
	--	print("hunger "..name.." = "..players_hungry[name].count.."")
			end
	end
end)

-- respawn
minetest.register_on_respawnplayer(function(player)
			local name = player:get_player_name()
			players_hungry[name] = {count=0}
end)

-- eating
--
-- done everytime a player eats something.
-- this overwrites the builtin function.
-- when a player eats something his hunger is reduced by the half.
--
function minetest.item_eat(hp_change, replace_with_item)
    return function(itemstack, user, pointed_thing)  -- closure
        if itemstack:take_item() ~= nil then
            user:set_hp(user:get_hp() + hp_change)
            itemstack:add_item(replace_with_item) -- note: replace_with_item is optional
			players_hungry[user:get_player_name()] = {count=math.floor(players_hungry[name].count/2)}
        end
        return itemstack
    end
end

minetest.register_tool(HUNGER_TOOLNAME, {
	description     = HUNGER_TOOLDESC,
	wield_image     = "wieldhand.png",
	wield_scale     = {x=1,y=1,z=2.5},
	inventory_image = "hunger_meter.png"
})
