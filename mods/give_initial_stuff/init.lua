minetest.register_on_newplayer(function(player)
	print("on_newplayer")
	if minetest.setting_getbool("give_initial_stuff") then
		print("giving give_initial_stuff to player")
		player:get_inventory():add_item('main', 'default:ladder 10')
		player:get_inventory():add_item('main', 'default:apple 10')
		player:get_inventory():add_item('main', 'throwing:bow_wood')
		player:get_inventory():add_item('main', 'throwing:arrow_teleport')
		player:get_inventory():add_item('main', 'default:axe_wood')
		player:get_inventory():add_item('main', 'snow:snowball 99')
	end
end)

