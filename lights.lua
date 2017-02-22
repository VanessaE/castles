minetest.register_alias("darkage:lamp",        "castle:street_light")

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