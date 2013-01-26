--Bread
minetest.register_craftitem("bread:bread",{
	description = "Bread",
	inventory_image = "bread_bread.png",
	on_use = minetest.item_eat(16),
})

minetest.register_craftitem("bread:bun",{
	description = "Bread Bun",
	inventory_image = "bread_bun.png",
	on_use = minetest.item_eat(8),
})

minetest.register_craftitem("bread:slice",{
	description = "Bread Slice",
	inventory_image = "bread_slice.png",
	on_use = minetest.item_eat(4),
})
