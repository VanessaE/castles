minetest.register_alias("castle:pillars_bottom", "castle:pillars_stonewall_bottom")
minetest.register_alias("castle:pillars_top", "castle:pillars_stonewall_top")
minetest.register_alias("castle:pillars_middle", "castle:pillars_stonewall_middle")
minetest.register_alias("castle:arrowslit", "castle:arrowslit_stonewall")
minetest.register_alias("castle:arrowslit_hole", "castle:arrowslit_stonewall_hole")
minetest.register_alias("castle:arrowslit", "castle:arrowslit_stonewall_cross")

-- internationalization boilerplate
local MP = minetest.get_modpath(minetest.get_current_modname())
local S, NS = dofile(MP.."/intllib.lua")

castle_structure = {}

local read_setting = function(name, default)
	local setting = minetest.setting_getbool(name)
	if setting == nil then return default end
	return setting
end

local materials = {}
if read_setting("castle_structure_stonewall", true) then table.insert(materials, {"stonewall", S("Stonewall"), "castle_stonewall", "castle:stonewall"}) end
if read_setting("castle_structure_cobble", true) then table.insert(materials, {"cobble", S("Cobble"), "default_cobble", "default:cobble"}) end
if read_setting("castle_structure_stonebrick", true) then table.insert(materials, {"stonebrick", S("Stonebrick"), "default_stone_brick", "default:stonebrick"}) end
if read_setting("castle_structure_sandstonebrick", true) then table.insert(materials, {"sandstonebrick", S("Sandstone Brick"), "default_sandstone_brick", "default:sandstonebrick"}) end
if read_setting("castle_structure_desertstonebrick", true) then table.insert(materials, {"desertstonebrick", S("Desert Stone Brick"), "default_desert_stone_brick", "default:desert_stonebrick"}) end
if read_setting("castle_structure_stone", true) then table.insert(materials, {"stone", S("Stone"), "default_stone", "default:stone"}) end
if read_setting("castle_structure_sandstone", true) then table.insert(materials, {"sandstone", S("Sandstone"), "default_sandstone", "default:sandstone"}) end
if read_setting("castle_structure_desertstone", true) then table.insert(materials, {"desertstone", S("Desert Stone"), "default_desert_stone", "default:desert_stone"}) end

-------------------------------------------------------------------------------------

castle_structure.register_murderhole = function(name, desc, tile, craft_material)
	-- Node Definition
	minetest.register_node("castle:hole_"..name, {
		drawtype = "nodebox",
		description = S("@1 Murder Hole", desc),
		tiles = {tile..".png"},
		groups = {cracky=3},
		sounds = default.node_sound_stone_defaults(),
		paramtype = "light",
		paramtype2 = "facedir",
	node_box = {
		type = "fixed",
		fixed = {
			{-8/16,-8/16,-8/16,-4/16,8/16,8/16},
			{4/16,-8/16,-8/16,8/16,8/16,8/16},
			{-4/16,-8/16,-8/16,4/16,8/16,-4/16},
			{-4/16,-8/16,8/16,4/16,8/16,4/16},
		},
	},
	})

	if craft_material then
		--Choose craft material
		minetest.register_craft({
			output = "castle:hole_"..name.." 4",
			recipe = {
			{"",craft_material, "" },
			{craft_material,"", craft_material},
			{"",craft_material, ""} },
		})
	end
end

-------------------------------------------------------------------------------------

castle_structure.register_pillar = function(name, desc, tile, craft_material)
	-- Node Definition
	minetest.register_node("castle:pillars_"..name.."_bottom", {
		drawtype = "nodebox",
		description = S("@1 Pillar Base", desc),
		tiles = {tile..".png"},
		groups = {cracky=3,attached_node=1},
		sounds = default.node_sound_stone_defaults(),
		paramtype = "light",
		paramtype2 = "facedir",
		node_box = {
			type = "fixed",
			fixed = {
				{-0.500000,-0.500000,-0.500000,0.500000,-0.375000,0.500000},
				{-0.375000,-0.375000,-0.375000,0.375000,-0.125000,0.375000},
				{-0.250000,-0.125000,-0.250000,0.250000,0.500000,0.250000}, 
			},
		},
	})
	minetest.register_node("castle:pillars_"..name.."_top", {
		drawtype = "nodebox",
		description = S("@1 Pillar Top", desc),
		tiles = {tile..".png"},
		groups = {cracky=3,attached_node=1},
		sounds = default.node_sound_stone_defaults(),
		paramtype = "light",
		paramtype2 = "facedir",
	node_box = {
		type = "fixed",
		fixed = {
			{-0.500000,0.312500,-0.500000,0.500000,0.500000,0.500000}, 
			{-0.375000,0.062500,-0.375000,0.375000,0.312500,0.375000}, 
			{-0.250000,-0.500000,-0.250000,0.250000,0.062500,0.250000},
		},
	},
	})

	minetest.register_node("castle:pillars_"..name.."_middle", {
		drawtype = "nodebox",
		description = S("@1 Pillar Middle", desc),
		tiles = {tile..".png"},
		groups = {cracky=3,attached_node=1},
		sounds = default.node_sound_stone_defaults(),
		paramtype = "light",
		paramtype2 = "facedir",
		node_box = {
			type = "fixed",
			fixed = {
				{-0.250000,-0.500000,-0.250000,0.250000,0.500000,0.250000},
			},
		},
	})

	if craft_material then
		--Choose craft material
		minetest.register_craft({
			output = "castle:pillars_"..name.."_bottom 4",
			recipe = {
				{"",craft_material,""},
				{"",craft_material,""},
				{craft_material,craft_material,craft_material} },
		})
	end

	if craft_material then
		--Choose craft material
		minetest.register_craft({
			output = "castle:pillars_"..name.."_top 4",
			recipe = {
				{craft_material,craft_material,craft_material},
				{"",craft_material,""},
				{"",craft_material,""} },
		})
	end

	if craft_material then
		--Choose craft material
		minetest.register_craft({
			output = "castle:pillars_"..name.."_middle 4",
			recipe = {
				{craft_material,craft_material},
				{craft_material,craft_material},
				{craft_material,craft_material} },
		})
	end
end

-------------------------------------------------------------------------------------

castle_structure.register_arrowslit = function(name, desc, tile, craft_material)
	-- Node Definition
	minetest.register_node("castle:arrowslit_"..name, {
		drawtype = "nodebox",
		description = S("@1 Arrowslit", desc),
		tiles = {tile..".png"},
		groups = {cracky=3},
		sounds = default.node_sound_stone_defaults(),
		paramtype = "light",
		paramtype2 = "facedir",
	node_box = {
		type = "fixed",
		fixed = {
			{-0.500000,-0.375000,-0.500000,-0.062500,0.375000,-0.312500},
			{0.062500,-0.375000,-0.500000,0.500000,0.375000,-0.312500},
			{-0.500000,0.375000,-0.500000,0.500000,0.500000,-0.312500}, 
			{-0.500000,-0.500000,-0.500000,0.500000,-0.375000,-0.312500}, 
		},
	},
	selection_box = {
		type = "fixed",
		fixed = {
			{-0.500000,-0.500000,-0.500000,0.500000,0.500000,-0.312500},
		},
	},
	})
	minetest.register_node("castle:arrowslit_"..name.."_cross", {
		drawtype = "nodebox",
		description = S("@1 Arrowslit with Cross", desc),
		tiles = {tile..".png"},
		groups = {cracky=3},
		sounds = default.node_sound_stone_defaults(),
		paramtype = "light",
		paramtype2 = "facedir",
	node_box = {
		type = "fixed",
		fixed = {
			{-0.500000,-0.125000,-0.500000,-0.062500,0.375000,-0.312500}, 
			{0.062500,-0.125000,-0.500000,0.500000,0.375000,-0.312500},
			{-0.500000,0.375000,-0.500000,0.500000,0.500000,-0.312500}, 
			{-0.500000,-0.500000,-0.500000,0.500000,-0.375000,-0.312500}, 
			{0.062500,-0.375000,-0.500000,0.500000,-0.250000,-0.312500}, 
			{-0.500000,-0.375000,-0.500000,-0.062500,-0.250000,-0.312500},
			{-0.500000,-0.250000,-0.500000,-0.187500,-0.125000,-0.312500}, 
			{0.187500,-0.250000,-0.500000,0.500000,-0.125000,-0.312500}, 
		},
	},
	selection_box = {
		type = "fixed",
		fixed = {
			{-0.500000,-0.500000,-0.500000,0.500000,0.500000,-0.312500},
		},
	},
	})
	minetest.register_node("castle:arrowslit_"..name.."_hole", {
		drawtype = "nodebox",
		description = S("@1 Arrowslit with Hole", desc),
		tiles = {tile..".png"},
		groups = {cracky=3},
		sounds = default.node_sound_stone_defaults(),
		paramtype = "light",
		paramtype2 = "facedir",
	node_box = {
		type = "fixed",
		fixed = {
			{-0.500000,-0.375000,-0.500000,-0.125000,0.375000,-0.312500},
			{0.125000,-0.375000,-0.500000,0.500000,0.375000,-0.312500}, 
			{-0.500000,-0.500000,-0.500000,0.500000,-0.375000,-0.312500}, 
			{0.062500,-0.125000,-0.500000,0.125000,0.375000,-0.312500},
			{-0.125000,-0.125000,-0.500000,-0.062500,0.375000,-0.312500},
			{-0.500000,0.375000,-0.500000,0.500000,0.500000,-0.312500}, 
		},
	},
	selection_box = {
		type = "fixed",
		fixed = {
			{-0.500000,-0.500000,-0.500000,0.500000,0.500000,-0.312500},
		},
	},
	})
	if craft_material then
		--Choose craft material
		minetest.register_craft({
			output = "castle:arrowslit_"..name.." 6",
			recipe = {
			{craft_material,"", craft_material},
			{craft_material,"", craft_material},
			{craft_material,"", craft_material} },
		})
	end
	if craft_material then
		minetest.register_craft({
			output = "castle:arrowslit_"..name.."_cross",
			recipe = {
			{"castle:arrowslit_"..name} },
		})
	end
	if craft_material then
		minetest.register_craft({
			output = "castle:arrowslit_"..name.."_hole",
			recipe = {
			{"castle:arrowslit_"..name.."_cross"} },
		})
	end
	if craft_material then
		minetest.register_craft({
			output = "castle:arrowslit_"..name,
			recipe = {
			{"castle:arrowslit_"..name.."_hole"} },
		})
	end
end

-------------------------------------------------------------------------------------

if read_setting("castle_structure_pillar", true) then
	for _, material in pairs(materials) do
		castle_structure.register_pillar(material[1], material[2], material[3], material[4])
	end
end

if read_setting("castle_structure_arrowslit", true) then
	for _, material in pairs(materials) do
		castle_structure.register_arrowslit(material[1], material[2], material[3], material[4])
	end
end

if read_setting("castle_structure_murderhole", true) then
	for _, material in pairs(materials) do
		castle_structure.register_murderhole(material[1], material[2], material[3], material[4])
	end
end



