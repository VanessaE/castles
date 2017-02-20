castle = {}

dofile(minetest.get_modpath("castle").."/tapestry.lua")
dofile(minetest.get_modpath("castle").."/shields_decor.lua")

dofile(minetest.get_modpath("castle").."/town_item.lua")
dofile(minetest.get_modpath("castle").."/orbs.lua")
dofile(minetest.get_modpath("castle").."/rope.lua")

dofile(minetest.get_modpath("castle").."/crossbow.lua")
dofile(minetest.get_modpath("castle").."/battleaxe.lua")

dofile(minetest.get_modpath("castle").."/ironbound_chest.lua")
dofile(minetest.get_modpath("castle").."/crate.lua")

dofile(minetest.get_modpath("castle").."/workbench.lua")


minetest.register_node("castle:hides", {
	drawtype = "signlike",
	description = "Hides",
	inventory_image = "castle_hide.png",
	paramtype = "light",
	walkable = false,
	tiles = {'castle_hide.png'},
	climbable = true,
	paramtype2 = "wallmounted",
	legacy_wallmounted = true,
	groups = {dig_immediate=2},
	selection_box = {
		type = "wallmounted",
	},
})

minetest.register_craft( {
	type = "shapeless",
	output = "castle:hides 6",
	recipe = { "wool:white" , "bucket:bucket_water" },
	replacements = {
		{ 'bucket:bucket_water', 'bucket:bucket_empty' }
	}
})


