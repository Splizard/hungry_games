--[[
	This is the config mod for the hungry_games game.
	You should edit this BEFORE generation of hungry_games worlds.
	Feilds Marked with [SAFE] are safe to edit if you already have worlds generated.
]]--
dofile(minetest.get_modpath("hungry_games").."/engine.lua")
-----------------------------------
--------Arena configuration--------

--Set size of the arena.
glass_arena.set_size(200)

--Set texture of the arena. [SAFE]
glass_arena.set_texture("default_glass.png") 

-----------------------------------
--------Spawn configuration--------

--Set spawn points. [SAFE]
--NOTE: is overiden by hg_admin commands and save file.
spawning.register_spawn("spawn",{
	mode = "static", 
	pos = {x=0,y=0,z=0},
})
spawning.register_spawn("lobby",{
	mode = "static", 
	pos = {x=0,y=0,z=0},
})

-----------------------------------
--------Chest configuration--------
local chest_item = random_chests.register_item

--Enable chests to spawn in the world when generated.
--Pass false if you want to hide your own chests in the world in creative.
random_chests.enable()

--Set the boundary where chests are spawned
--Should be set to the same or smaller then the arena.
--Defaults to whole map.
random_chests.set_boundary(200)

--Set Chest Rarity.
--Rarity is how many chests per chunk.
random_chests.set_rarity(3)

--Set Chest Refill.
--The refill rate should not be set too low to reduce lag
--Uncomment one of the following...

----Can be set as a database:
----This will refill chests when a match is started, it processes 5 chests per second (so will take a while to fill on a large map)
random_chests.setrefill("database", 5)

----or set as an abm: [SAFE]
--random_chests.setrefill("abm", 12000)

----or as nodetimers: (refill rate is in seconds)
--random_chests.setrefill("nodetimer", 3600)

--Register a new item that can be spawned in random chests. [SAFE]
--eg chest_item('default:torch', 4, 6) #has a 1 in 4 chance of spawning up to 6 torches.
--items
chest_item('default:apple', 4, 5)
chest_item('default:ladder', 8, 5)
chest_item('default:torch', 4, 6)
chest_item('default:axe_wood', 10, 1)
chest_item('default:axe_stone', 15, 1)
chest_item('default:axe_steel', 20, 1)
chest_item('throwing:arrow', 4, 10)
chest_item('throwing:arrow_fire', 12, 6)
chest_item('throwing:bow_wood', 5, 1)
chest_item('throwing:bow_stone', 10, 1)
chest_item('throwing:bow_steel', 15, 1)
chest_item('bucket:bucket_lava', 20, 1)
chest_item('default:sword_wood', 10, 1)
chest_item('default:sword_stone', 15, 1)
chest_item('default:sword_steel', 20, 1)
chest_item('food:bread_slice', 3, 1)
chest_item('food:bun', 5, 1)
chest_item('food:bread', 10, 1)
chest_item('snow:snowball', 10, 99)
--crafting items
chest_item('default:stick', 8, 10)
chest_item('default:steel_ingot', 15, 3)
chest_item('farming:string', 7, 3)
chest_item('hungry_games:stones', 6, 3)
chest_item('hungry_games:planks', 5, 3)
