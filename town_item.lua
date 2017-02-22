minetest.register_alias("cottages:straw",      "farming:straw")
minetest.register_alias("castle:straw",        "farming:straw")
minetest.register_alias("darkage:straw",       "farming:straw")
minetest.register_alias("cottages:straw_bale", "castle:bound_straw")
minetest.register_alias("darkage:straw_bale",  "castle:bound_straw")

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


