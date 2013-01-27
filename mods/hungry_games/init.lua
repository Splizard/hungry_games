-----------------------------------
--------Arena configuration--------

--Set size of the arena.
glass_arena.set_size(200)

--Set texture of the arena.
glass_arena.set_texture("default_glass.png")

-----------------------------------
--------Chest configuration--------
local chest_item = random_chests.register_item

--Enable chests to spawn in the world when generated.
--Pass false if you want to hide your own chests in the world in creative.
random_chests.enable()

--Set Chest Rarity.
--Rarity is how many chests per chunk.
random_chests.set_rarity(3)

--Set Chest Refill.
--The refill rate should not be set too low to reduce lag
--Uncomment one of the following...

----Can be set as an abm: 
--random_chests.setrefill("abm", 1000)

----or as nodetimers: (refill rate is in seconds)
--random_chests.setrefill("nodetimer", 3600)

--Register a new item that can be spawned in random chests.
--eg chest_item('default:torch', 4, 6) #has a 1 in 4 chance of spawning up to 6 torches.
chest_item('default:apple', 4, 5)
chest_item('default:ladder', 8, 5)
chest_item('default:torch', 4, 6)
chest_item('default:axe_wood', 3, 1)
chest_item('default:axe_stone', 5, 1)
chest_item('default:axe_steel', 10, 1)
chest_item('throwing:arrow', 4, 6)
chest_item('throwing:arrow_fire', 8, 6)
chest_item('throwing:bow_wood', 3, 1)
chest_item('throwing:bow_stone', 5, 1)
chest_item('throwing:bow_steel', 3, 1)
chest_item('bucket:bucket_lava', 20, 1)
chest_item('default:sword_wood', 3, 1)
chest_item('default:sword_stone', 5, 1)
chest_item('default:sword_steel', 10, 1)
chest_item('bread:slice', 3, 1)
chest_item('bread:bun', 5, 1)
chest_item('bread:bread', 10, 1)
