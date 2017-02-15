minetest.register_alias("cottages:straw",      "farming:straw")
minetest.register_alias("castle:straw",        "farming:straw")
minetest.register_alias("darkage:straw",       "farming:straw")
minetest.register_alias("cottages:straw_bale", "castle:bound_straw")
minetest.register_alias("darkage:straw_bale",  "castle:bound_straw")
minetest.register_alias("darkage:lamp",        "castle:street_light")

minetest.register_node("castle:anvil",{
	drawtype = "nodebox",
	description = "Anvil",
	tiles = {"castle_steel.png"},
	groups = {cracky=2,falling_node=1},
	sounds = default.node_sound_stone_defaults(),
	paramtype = "light",
	paramtype2 = "facedir",
	node_box = {
		type = "fixed",
		fixed = {
			{-0.500000,-0.500000,-0.500000,0.500000,-0.250000,0.500000},
			{-0.187500,-0.500000,-0.375000,0.187500,0.312500,0.375000},
			{-0.375000,-0.500000,-0.437500,0.375000,-0.125000,0.437500},
			{-0.500000,0.312500,-0.500000,0.500000,0.500000,0.500000},
			{-0.375000,0.187500,-0.437500,0.375000,0.425000,0.437500},
		},
	},
})

minetest.register_craft({
	output = "castle:anvil",
	recipe = {
		{"default:steel_ingot","default:steel_ingot","default:steel_ingot"},
		{"","default:steel_ingot", ""},
		{"default:steel_ingot", "default:steel_ingot","default:steel_ingot"},
	}
})

minetest.register_node("castle:bound_straw", {
	description = "Bound Straw",
	drawtype = "normal",
	tiles = {"castle_straw_bale.png"},
	groups = {choppy=4, flammable=1, oddly_breakable_by_hand=3},
	sounds = default.node_sound_leaves_defaults(),
	paramtype = "light",
})

minetest.register_craft({
	output = "castle:bound_straw",
	recipe = {
		{"castle:straw", "castle:ropes"},
	}
})

minetest.register_node("castle:light",{
	drawtype = "glasslike",
	description = "Light Block",
	sunlight_propagates = true,
	light_source = 14,
	tiles = {"castle_street_light.png"},
	groups = {cracky=2},
	sounds = default.node_sound_glass_defaults(),
	paramtype = "light",
})

minetest.register_craft({
	output = "castle:light",
	recipe = {
		{"default:stick", "default:glass", "default:stick"},
		{"default:glass", "default:torch", "default:glass"},
		{"default:stick", "default:glass", "default:stick"},
	}
})

minetest.register_node( "castle:chandelier", {
	drawtype = "plantlike",
	description = "Chandelier",
	paramtype = "light",
	wield_image = "castle_chandelier_wield.png",
	inventory_image = "castle_chandelier_wield.png", 
	groups = {cracky=2},
	sounds = default.node_sound_glass_defaults(),
	sunlight_propagates = true,
	light_source = 14,
	tiles = {
			{
			name = "castle_chandelier.png",
			animation = {
				type = "vertical_frames",
				aspect_w = 16,
				aspect_h = 16,
				length = 1.0
			},
		},
	},
	selection_box = {
		type = "fixed",
			fixed = {
				{0.35,-0.375,0.35,-0.35,0.5,-0.35},

		},
	},
})

minetest.register_node( "castle:chandelier_chain", {
	drawtype = "plantlike",
	description = "Chandelier Chain",
	paramtype = "light",
	wield_image = "castle_chandelier_chain.png",
	inventory_image = "castle_chandelier_chain.png", 
	groups = {cracky=2},
	sounds = default.node_sound_glass_defaults(),
	sunlight_propagates = true,
	tiles = {"castle_chandelier_chain.png"},
	selection_box = {
		type = "fixed",
			fixed = {
				{0.1,-0.5,0.1,-0.1,0.5,-0.1},

		},
	},
})

