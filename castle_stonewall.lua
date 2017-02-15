minetest.register_alias("castle:pavement",      "castle:pavement_brick")

minetest.register_node("castle:stonewall", {
	description = "Castle Wall",
	drawtype = "normal",
	tiles = {"castle_stonewall.png"},
	paramtype = "light",
	drop = "castle:stonewall",
	groups = {cracky=3},
	sunlight_propagates = false,
	sounds = default.node_sound_stone_defaults(),
})


minetest.register_node("castle:rubble", {
	description = "Castle Rubble",
	drawtype = "normal",
	tiles = {"castle_rubble.png"},
	paramtype = "light",
	groups = {crumbly=3,falling_node=1},
	sounds = default.node_sound_gravel_defaults(),
})

minetest.register_craft({
	output = "castle:stonewall",
	recipe = {
		{"default:cobble"},
		{"default:desert_stone"},
	}
})

minetest.register_craft({
	output = "castle:rubble",
	recipe = {
		{"castle:stonewall"},
	}
})

minetest.register_craft({
	output = "castle:rubble 2",
	recipe = {
		{"default:gravel"},
		{"default:desert_stone"},
	}
})

minetest.register_node("castle:stonewall_corner", {
	drawtype = "normal",
	paramtype = "light",
	paramtype2 = "facedir",
	description = "Castle Corner",
	tiles = {"castle_corner_stonewall_tb.png^[transformR90",
		 "castle_corner_stonewall_tb.png^[transformR180",
		 "castle_corner_stonewall1.png",
		 "castle_stonewall.png",
		 "castle_stonewall.png",	
		 "castle_corner_stonewall2.png"},
	groups = {cracky=3},
	sounds = default.node_sound_stone_defaults(),
})

minetest.register_craft({
	output = "castle:stonewall_corner",
	recipe = {
		{"", "castle:stonewall"},
		{"castle:stonewall", "default:sandstone"},
	}
})

if minetest.get_modpath("moreblocks") then
	stairsplus:register_all("castle", "stonewall", "castle:stonewall", {
		description = "Stone Wall",
		tiles = {"castle_stonewall.png"},
		groups = {cracky=3, not_in_creative_inventory=1},
		sounds = default.node_sound_stone_defaults(),
		sunlight_propagates = true,
	})

	stairsplus:register_all("castle", "rubble", "castle:rubble", {
		description = "Rubble",
		tiles = {"castle_rubble.png"},
		groups = {cracky=3, not_in_creative_inventory=1},
		sounds = default.node_sound_gravel_defaults(),
		sunlight_propagates = true,
	})

elseif minetest.get_modpath("stairs") then
	stairs.register_stair_and_slab("stonewall", "castle:stonewall",
		{cracky=3},
		{"castle_stonewall.png"},
		"Castle Stonewall Stair",
		"Castle Stonewall Slab",
		default.node_sound_stone_defaults()
	)

	stairs.register_stair_and_slab("rubble", "castle:rubble",
		{cracky=3},
		{"castle_rubble.png"},
		"Castle Rubble Stair",
		"Castle Rubble Slab",
		default.node_sound_stone_defaults()
	)
end


minetest.register_node("castle:dungeon_stone", {
	description = "Dungeon Stone",
	drawtype = "normal",
	tiles = {"castle_dungeon_stone.png"},
	groups = {cracky=2},
	paramtype = "light",
	sounds = default.node_sound_stone_defaults(),
})

minetest.register_craft({
	output = "castle:dungeon_stone",
	recipe = {
		{"default:stonebrick", "default:obsidian"},
	}
})

minetest.register_craft({
	output = "castle:dungeon_stone",
	recipe = {
		{"default:stonebrick"},
		{"default:obsidian"},
	}
})


minetest.register_node("castle:pavement_brick", {
	description = "Paving Stone",
	drawtype = "normal",
	tiles = {"castle_pavement_brick.png"},
	groups = {cracky=2},
	paramtype = "light",
	sounds = default.node_sound_stone_defaults(),
})

minetest.register_craft({
	output = "castle:pavement_brick 4",
	recipe = {
		{"default:stone", "default:cobble"},
		{"default:cobble", "default:stone"},
	}
})


if minetest.get_modpath("moreblocks") then
	stairsplus:register_all("castle", "dungeon_stone", "castle:dungeon_stone", {
		description = "Dungeon Stone",
		tiles = {"castle_dungeon_stone.png"},
		groups = {cracky=2, not_in_creative_inventory=1},
		sounds = default.node_sound_stone_defaults(),
		sunlight_propagates = true,
	})

	stairsplus:register_all("castle", "pavement_brick", "castle:pavement_brick", {
		description = "Pavement Brick",
		tiles = {"castle_pavement_brick.png"},
		groups = {cracky=2, not_in_creative_inventory=1},
		sounds = default.node_sound_stone_defaults(),
		sunlight_propagates = true,
	})

elseif minetest.get_modpath("stairs") then
	stairs.register_stair_and_slab("dungeon_stone", "castle:dungeon_stone",
		{cracky=2},
		{"castle_dungeon_stone.png"},
		"Dungeon Stone Stair",
		"Dungeon Stone Slab",
		default.node_sound_stone_defaults()
	)

	stairs.register_stair_and_slab("pavement_brick", "castle:pavement_brick",
		{cracky=2},
		{"castle_pavement_brick.png"},
		"Castle Pavement Stair",
		"Castle Pavement Slab",
		default.node_sound_stone_defaults()
	)
end