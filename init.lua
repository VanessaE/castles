castle = {}

-- use this when you have a "wallmounted" node that should never be oriented
-- to floor or ceiling (e.g. a tapestry)

function castle.fix_rotation_nsew(pos, placer, itemstack, pointed_thing)
	local node = minetest.get_node(pos)
	local yaw = placer:get_look_yaw()
	local dir = minetest.yaw_to_dir(yaw)
	local fdir = minetest.dir_to_wallmounted(dir)
	minetest.swap_node(pos, { name = node.name, param2 = fdir })
end

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

dofile(minetest.get_modpath("castle").."/castle_stonewall.lua")
dofile(minetest.get_modpath("castle").."/castle_structure.lua")

dofile(minetest.get_modpath("castle").."/castle_gates.lua")


minetest.register_node("castle:roofslate", {
	drawtype = "raillike",
	description = "Roof Slates",
	inventory_image = "castle_slate.png",
	paramtype = "light",
	walkable = false,
	tiles = {'castle_slate.png'},
	climbable = true,
	selection_box = {
		type = "fixed",
		fixed = {-1/2, -1/2, -1/2, 1/2, -1/2+1/16, 1/2},
	},
	groups = {cracky=3,attached_node=1},
	sounds = default.node_sound_glass_defaults(),
})

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

local mod_building_blocks = minetest.get_modpath("building_blocks")
local mod_streets = minetest.get_modpath("streets") or minetest.get_modpath("asphalt")

if mod_building_blocks then
	minetest.register_craft({
		output = "castle:roofslate 4",
		recipe = {
			{ "building_blocks:Tar" , "default:gravel" },
			{ "default:gravel",       "building_blocks:Tar" }
		}
	})

	minetest.register_craft( {
		output = "castle:roofslate 4",
		recipe = {
			{ "default:gravel",       "building_blocks:Tar" },
			{ "building_blocks:Tar" , "default:gravel" }
		}
	})
end

if mod_streets then
	minetest.register_craft( {
		output = "castle:roofslate 4",
		recipe = {
			{ "streets:asphalt" , "default:gravel" },
			{ "default:gravel",   "streets:asphalt" }
		}
	})

	minetest.register_craft( {
		output = "castle:roofslate 4",
		recipe = {
			{ "default:gravel",   "streets:asphalt" },
			{ "streets:asphalt" , "default:gravel" }
		}
	})
end

if not (mod_building_blocks or mod_streets) then
	minetest.register_craft({
		type = "cooking",
		output = "castle:roofslate",
		recipe = "default:gravel",
	})

end

