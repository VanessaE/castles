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