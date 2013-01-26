drowning = {}	-- Exported functions

-- counter
local players_under_water = {}

local steady_hurt_time = 0
local saved_value = 0

local START_DROWNING_SECONDS = 32
local FACTOR_DROWNING_SECONDS = 2
local MIN_DROWNING_SECONDS = 1
local DROWNING_DAMAGE = 1

--calculating the countertime the player gets hurt. x+(x/2)+(x/4)+(x/8)...
if drowning_times == nil then
	drowning_times = {}
	local hurt_time = START_DROWNING_SECONDS
	local power = 1
	while ((hurt_time + math.floor(START_DROWNING_SECONDS / math.floor(math.pow(FACTOR_DROWNING_SECONDS, power)))) - hurt_time) >= MIN_DROWNING_SECONDS do
		table.insert (drowning_times, hurt_time)
		hurt_time = hurt_time + math.floor(START_DROWNING_SECONDS / math.floor(math.pow(FACTOR_DROWNING_SECONDS, power)))
		power = power + 1
		steady_hurt_time = hurt_time
	end
end

local timer = 0
if minetest.setting_getbool("enable_damage") == true then

-- load drowningcounter
local function set_drowning(name, value)
	local output = io.open(minetest.get_worldpath() .. "/drowning_" .. name .. ".txt", "w")
	output:write(value)
	io.close(output)
end

local function get_drowning(name)
	local input = io.open(minetest.get_worldpath() .. "/drowning_" .. name .. ".txt", "r")
	if not input then 
		return nil
	end
	drowning = input:read("*n")
	io.close(input)
	return drowning
end

minetest.register_on_joinplayer(function(player)
	name = player:get_player_name()
	if not get_drowning(name) then
		set_drowning(name, 0)
	end
	players_under_water[name] = {count=get_drowning(name)}
end)

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
			if players_under_water[name] == nil then
				players_under_water[name] = {count=0}
			end
			if PlayerNotInLiquid(player) == false then
				players_under_water[name].count = players_under_water[name].count + .5
				for _,drowning_times in ipairs(drowning_times) do
					if players_under_water[name].count == drowning_times or players_under_water[name].count >= steady_hurt_time then
						if player:get_hp() > 0 then
							-- making damage, play sound
							player:set_hp(player:get_hp() - DROWNING_DAMAGE)
							pos = player:getpos()
							pos.y=pos.y+1
							minetest.sound_play({name="drowning_gurp"}, {pos = pos, gain = 1.0, max_hear_distance = 16})
							minetest.chat_send_player(name, "You are drowning.")
						else
							players_under_water[name] = {count=0}
						end
					end
				end
			elseif players_under_water[name].count > 0 then
				pos = player:getpos()
				pos.y=pos.y+1
				minetest.sound_play({name="drowning_gasp"}, {pos = pos, gain = 1.0, max_hear_distance = 32})
				players_under_water[name] = {count=0}
			end
		-- save drowningcounter
		set_drowning(name, players_under_water[name].count)
--		print("drowning "..name.." = "..players_under_water[name].count.."")
	end
end)

minetest.register_on_respawnplayer(function(player)
			local name = player:get_player_name()
			players_under_water[name] = {count=0}
end)

end

function PlayerNotInLiquid(player)
	local pos = player:getpos()
	pos.x = math.floor(pos.x+0.5)
	pos.y = math.floor(pos.y+2.0)
	pos.z = math.floor(pos.z+0.5)
	
	-- getting nodename at players head
	n_head = minetest.env:get_node(pos).name
	-- checking if node is liquid (0=not 2=lava 3=water) then player is underwater
	-- this includes flowing water and flowing lava
	if minetest.get_item_group(n_head, "liquid") ~= 0 then
		return false
	end
	return true
end