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

-- Material definition:
-- {
--	name=,
--	desc=,
--	tile=,
--	craft_material=,
--	composition_material=, -- Optional, this will override the properties of the product with a specific material if you want to use a group for the craft material
--}

castle_structure.materials = {}
if read_setting("castle_structure_stonewall", true) then
	table.insert(castle_structure.materials, {name="stonewall", desc=S("Stonewall"), tile="castle_stonewall.png", craft_material="castle:stonewall"})
end
if read_setting("castle_structure_cobble", true) then
	table.insert(castle_structure.materials, {name="cobble", desc=S("Cobble"), tile="default_cobble.png", craft_material="default:cobble"})
end
if read_setting("castle_structure_stonebrick", true) then
	table.insert(castle_structure.materials, {name="stonebrick", desc=S("Stonebrick"), tile="default_stone_brick.png", craft_material="default:stonebrick"})
end
if read_setting("castle_structure_sandstonebrick", true) then
	table.insert(castle_structure.materials, {name="sandstonebrick", desc=S("Sandstone Brick"), tile="default_sandstone_brick.png", craft_material="default:sandstonebrick"})
end
if read_setting("castle_structure_desertstonebrick", true) then
	table.insert(castle_structure.materials, {name="desertstonebrick", desc=S("Desert Stone Brick"), tile="default_desert_stone_brick.png", craft_material="default:desert_stonebrick"})
end
if read_setting("castle_structure_stone", true) then
	table.insert(castle_structure.materials, {name="stone", desc=S("Stone"), tile="default_stone.png", craft_material="default:stone"})
end
if read_setting("castle_structure_sandstone", true) then
	table.insert(castle_structure.materials, {name="sandstone", desc=S("Sandstone"), tile="default_sandstone.png", craft_material="default:sandstone"})
end
if read_setting("castle_structure_desertstone", true) then
	table.insert(castle_structure.materials, {name="desertstone", desc=S("Desert Stone"), tile="default_desert_stone.png", craft_material="default:desert_stone"})
end
if read_setting("castle_structure_wood", false) then
	table.insert(castle_structure.materials, {name="wood", desc=S("Wood"), tile="default_wood.png", craft_material="group:wood", composition_material="default:wood"})
end
if read_setting("castle_structure_ice", false) then
	table.insert(castle_structure.materials, {name="ice", desc=S("Ice"), tile="default_ice.png", craft_material="default:ice"})
end
if read_setting("castle_structure_snow", false) then
	table.insert(castle_structure.materials, {name="snow", desc=S("Snow"), tile="default_snow.png", craft_material="default:snow"})
end


castle_structure.get_material_properties = function(material)
	local composition_def
	local burn_time
	if material.composition_material ~= nil then
		composition_def = minetest.registered_nodes[material.composition_material]
		burn_time = minetest.get_craft_result({method="fuel", width=1, items={ItemStack(material.composition_material)}}).time
	else
		composition_def = minetest.registered_nodes[material.craft_material]
		burn_time = minetest.get_craft_result({method="fuel", width=1, items={ItemStack(material.craft_materia)}}).time
	end
	
	local tiles = material.tile
	if tiles == nil then
		tiles = composition_def.tile
	elseif type(tiles) == "string" then
		tiles = {tiles}
	end

	local desc = material.desc
	if desc == nil then
		desc = composition_def.description
	end
	
	return composition_def, burn_time, tiles, desc
end

-------------------------------------------------------------------------------------

castle_structure.register_murderhole = function(material)
	local composition_def, burn_time, tile, desc = castle_structure.get_material_properties(material)
	local mod_name = minetest.get_current_modname()
	
	-- Node Definition
	minetest.register_node(mod_name..":hole_"..material.name, {
		drawtype = "nodebox",
		description = S("@1 Murder Hole", desc),
		tiles = tile,
		groups = composition_def.groups,
		sounds = composition_def.sounds,
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
	
	minetest.register_node(mod_name..":machicolation_"..material.name, {
		drawtype = "nodebox",
		description = S("@1 Machicolation", desc),
		tiles = tile,
		groups = composition_def.groups,
		sounds = composition_def.sounds,
		paramtype = "light",
		paramtype2 = "facedir",
		node_box = {
			type = "fixed",
			fixed = {
				{-0.5, 0, -0.5, 0.5, 0.5, 0},
				{-0.5, -0.5, 0, -0.25, 0.5, 0.5},
				{0.25, -0.5, 0, 0.5, 0.5, 0.5},
			},
		},
	})

	minetest.register_craft({
		output = mod_name..":hole_"..material.name.." 4",
		recipe = {
			{"",material.craft_material, "" },
			{material.craft_material,"", material.craft_material},
			{"",material.craft_material, ""}
		},
	})

	minetest.register_craft({
		output = mod_name..":machicolation_"..material.name,
		type="shapeless",
		recipe = {mod_name..":hole_"..material.name},
	})
	minetest.register_craft({
		output = mod_name..":hole_"..material.name,
		type="shapeless",
		recipe = {mod_name..":machicolation_"..material.name},
	})
	
	if burn_time > 0 then
		minetest.register_craft({
			type = "fuel",
			recipe = mod_name..":hole_"..material.name,
			burntime = burn_time,
		})
		minetest.register_craft({
			type = "fuel",
			recipe = mod_name..":machicolation_"..material.name,
			burntime = burn_time,
		})	
	end
end

-------------------------------------------------------------------------------------

castle_structure.register_pillar = function(material)
	local composition_def, burn_time, tile, desc = castle_structure.get_material_properties(material)
	local crossbrace_connectable_groups = {}
	for group, val in pairs(composition_def.groups) do
		crossbrace_connectable_groups[group] = val
	end	
	crossbrace_connectable_groups.crossbrace_connectable = 1

	local mod_name = minetest.get_current_modname()
	
	-- Node Definition
	minetest.register_node(mod_name..":pillars_"..material.name.."_bottom", {
		drawtype = "nodebox",
		description = S("@1 Pillar Base", desc),
		tiles = tile,
		groups = crossbrace_connectable_groups,
		sounds = composition_def.sounds,
		paramtype = "light",
		paramtype2 = "facedir",
		node_box = {
			type = "fixed",
			fixed = {
				{-0.5,-0.5,-0.5,0.5,-0.375,0.5},
				{-0.375,-0.375,-0.375,0.375,-0.125,0.375},
				{-0.25,-0.125,-0.25,0.25,0.5,0.25}, 
			},
		},
	})

	minetest.register_node(mod_name..":pillars_"..material.name.."_bottom_half", {
		drawtype = "nodebox",
		description = S("@1 Half Pillar Base", desc),
		tiles = tile,
		groups = composition_def.groups,
		sounds = composition_def.sounds,
		paramtype = "light",
		paramtype2 = "facedir",
		node_box = {
			type = "fixed",
			fixed = {
				{-0.5, -0.5, 0, 0.5, -0.375, 0.5},
				{-0.375, -0.375, 0.125, 0.375, -0.125, 0.5},
				{-0.25, -0.125, 0.25, 0.25, 0.5, 0.5},
			},
		},
	})
	
	minetest.register_node(mod_name..":pillars_"..material.name.."_top", {
		drawtype = "nodebox",
		description = S("@1 Pillar Top", desc),
		tiles = tile,
		groups = crossbrace_connectable_groups,
		sounds = composition_def.sounds,
		paramtype = "light",
		paramtype2 = "facedir",
		node_box = {
			type = "fixed",
			fixed = {
				{-0.5,0.3125,-0.5,0.5,0.5,0.5}, 
				{-0.375,0.0625,-0.375,0.375,0.3125,0.375}, 
				{-0.25,-0.5,-0.25,0.25,0.0625,0.25},
			},
		},
	})

	minetest.register_node(mod_name..":pillars_"..material.name.."_top_half", {
		drawtype = "nodebox",
		description = S("@1 Half Pillar Top", desc),
		tiles = tile,
		groups = composition_def.groups,
		sounds = composition_def.sounds,
		paramtype = "light",
		paramtype2 = "facedir",
		node_box = {
			type = "fixed",
			fixed = {
				{-0.5, 0.3125, 0, 0.5, 0.5, 0.5},
				{-0.375, 0.0625, 0.125, 0.375, 0.3125, 0.5},
				{-0.25, -0.5, 0.25, 0.25, 0.0625, 0.5},
			},
		},
	})	

	minetest.register_node(mod_name..":pillars_"..material.name.."_middle", {
		drawtype = "nodebox",
		description = S("@1 Pillar Middle", desc),
		tiles = tile,
		groups = crossbrace_connectable_groups,
		sounds = composition_def.sounds,
		paramtype = "light",
		paramtype2 = "facedir",
		node_box = {
			type = "fixed",
			fixed = {
				{-0.25,-0.5,-0.25,0.25,0.5,0.25},
			},
		},
	})

	minetest.register_node(mod_name..":pillars_"..material.name.."_middle_half", {
		drawtype = "nodebox",
		description = S("@1 Half Pillar Middle", desc),
		tiles = tile,
		groups = composition_def.groups,
		sounds = composition_def.sounds,
		paramtype = "light",
		paramtype2 = "facedir",
		node_box = {
			type = "fixed",
			fixed = {
				{-0.25, -0.5, 0.25, 0.25, 0.5, 0.5},
			},
		},
	})
	
	minetest.register_node(mod_name..":pillars_"..material.name.."_crossbrace",
	{
		drawtype = "nodebox",
		description = S("@1 Crossbrace", desc),
		tiles = tile,
		groups = composition_def.groups,
		sounds = composition_def.sounds,
		paramtype = "light",
		paramtype2 = "facedir",
		node_box = {
			type = "connected",
			fixed = {-0.25,0.25,-0.25,0.25,0.5,0.25},
			connect_front = {-0.25,0.25,-0.75,0.25,0.5,-0.25}, -- -Z
			connect_left = {-0.25,0.25,-0.25,-0.75,0.5,0.25}, -- -X
			connect_back = {-0.25,0.25,0.25,0.25,0.5,0.75}, -- +Z
			connect_right = {0.25,0.25,-0.25,0.75,0.5,0.25}, -- +X
		},
		connects_to = { mod_name..":pillars_"..material.name.."_crossbrace", "group:crossbrace_connectable"},
		connect_sides = { "front", "left", "back", "right" },
	})
	
	minetest.register_craft({
		output = mod_name..":pillars_"..material.name.."_bottom 4",
		recipe = {
			{"",material.craft_material,""},
			{"",material.craft_material,""},
			{material.craft_material,material.craft_material,material.craft_material} },
	})

	minetest.register_craft({
		output = mod_name..":pillars_"..material.name.."_top 4",
		recipe = {
			{material.craft_material,material.craft_material,material.craft_material},
			{"",material.craft_material,""},
			{"",material.craft_material,""} },
	})

	minetest.register_craft({
		output = mod_name..":pillars_"..material.name.."_middle 4",
		recipe = {
			{material.craft_material,material.craft_material},
			{material.craft_material,material.craft_material},
			{material.craft_material,material.craft_material} },
	})
	
	minetest.register_craft({
		output = mod_name..":pillars_"..material.name.."_crossbrace 10",
		recipe = {
			{material.craft_material,"",material.craft_material},
			{"",material.craft_material,""},
			{material.craft_material,"",material.craft_material} },
	})
	
	minetest.register_craft({
		output = mod_name..":pillars_"..material.name.."_middle_half 2",
		type="shapeless",
		recipe = {mod_name..":pillars_"..material.name.."_middle"},
	})
	minetest.register_craft({
		output = mod_name..":pillars_"..material.name.."_middle",
		type="shapeless",
		recipe = {mod_name..":pillars_"..material.name.."_middle_half", mod_name..":pillars_"..material.name.."_middle_half"},
	})

	minetest.register_craft({
		output = mod_name..":pillars_"..material.name.."_top_half 2",
		type="shapeless",
		recipe = {mod_name..":pillars_"..material.name.."_top"},
	})
	minetest.register_craft({
		output = mod_name..":pillars_"..material.name.."_top",
		type="shapeless",
		recipe = {mod_name..":pillars_"..material.name.."_top_half", mod_name..":pillars_"..material.name.."_top_half"},
	})

	minetest.register_craft({
		output = mod_name..":pillars_"..material.name.."_bottom_half 2",
		type="shapeless",
		recipe = {mod_name..":pillars_"..material.name.."_bottom"},
	})
	minetest.register_craft({
		output = mod_name..":pillars_"..material.name.."_bottom",
		type="shapeless",
		recipe = {mod_name..":pillars_"..material.name.."_bottom_half", mod_name..":pillars_"..material.name.."_bottom_half"},
	})
	
	if burn_time > 0 then
		minetest.register_craft({
			type = "fuel",
			recipe = mod_name..":pillars_"..material.name.."_top",
			burntime = burn_time*5/4,
		})	
		minetest.register_craft({
			type = "fuel",
			recipe = mod_name..":pillars_"..material.name.."_top_half",
			burntime = burn_time*5/8,
		})
		minetest.register_craft({
			type = "fuel",
			recipe = mod_name..":pillars_"..material.name.."_bottom",
			burntime = burn_time*5/4,
		})	
		minetest.register_craft({
			type = "fuel",
			recipe = mod_name..":pillars_"..material.name.."_bottom_half",
			burntime = burn_time*5/8,
		})	
		minetest.register_craft({
			type = "fuel",
			recipe = mod_name..":pillars_"..material.name.."_middle",
			burntime = burn_time*6/4,
		})
		minetest.register_craft({
			type = "fuel",
			recipe = mod_name..":pillars_"..material.name.."_middle_half",
			burntime = burn_time*6/8,
		})
		minetest.register_craft({
			type = "fuel",
			recipe = mod_name..":pillars_"..material.name.."_crossbrace",
			burntime = burn_time*5/10,
		})
	end
	
end

-------------------------------------------------------------------------------------

castle_structure.register_arrowslit = function(material)
	local composition_def, burn_time, tile, desc = castle_structure.get_material_properties(material)
	local mod_name = minetest.get_current_modname()

	-- Node Definition
	minetest.register_node(mod_name..":arrowslit_"..material.name, {
		drawtype = "nodebox",
		description = S("@1 Arrowslit", desc),
		tiles = tile,
		groups = composition_def.groups,
		sounds = composition_def.sounds,
		paramtype = "light",
		paramtype2 = "facedir",
	node_box = {
		type = "fixed",
		fixed = {
			{-0.5, -0.375, 0.5, -0.0625, 0.375, 0.3125},
			{0.0625, -0.375, 0.5, 0.5, 0.375, 0.3125},
			{-0.5, 0.375, 0.5, 0.5, 0.5, 0.3125}, 
			{-0.5, -0.5, 0.5, 0.5, -0.375, 0.3125}, 
			{0.25, -0.5, 0.3125, 0.5, 0.5, 0.125},
			{-0.5, -0.5, 0.3125, -0.25, 0.5, 0.125},
		},
	},
	selection_box = {
		type = "fixed",
		fixed = {
			{-0.5,-0.5,0.5,0.5,0.5,0.125},
		},
	},
	})

	minetest.register_node(mod_name..":arrowslit_"..material.name.."_cross", {
		drawtype = "nodebox",
		description = S("@1 Arrowslit with Cross", desc),
		tiles = tile,
		groups = composition_def.groups,
		sounds = composition_def.sounds,
		paramtype = "light",
		paramtype2 = "facedir",
	node_box = {
		type = "fixed",
		fixed = {
			{-0.5, -0.125, 0.5, -0.0625, 0.375, 0.3125},
			{0.0625, -0.125, 0.5, 0.5, 0.375, 0.3125},
			{-0.5, 0.375, 0.5, 0.5, 0.5, 0.3125},
			{-0.5, -0.5, 0.5, 0.5, -0.375, 0.3125},
			{0.0625, -0.375, 0.5, 0.5, -0.25, 0.3125},
			{-0.5, -0.375, 0.5, -0.0625, -0.25, 0.3125},
			{-0.5, -0.25, 0.5, -0.1875, -0.125, 0.3125},
			{0.1875, -0.25, 0.5, 0.5, -0.125, 0.3125},
			{0.25, -0.5, 0.3125, 0.5, 0.5, 0.125},
			{-0.5, -0.5, 0.3125, -0.25, 0.5, 0.125},
		},
	},
	selection_box = {
		type = "fixed",
		fixed = {
			{-0.5, -0.5, 0.5, 0.5, 0.5, 0.125},
		},
	},
	})

	minetest.register_node(mod_name..":arrowslit_"..material.name.."_hole", {
		drawtype = "nodebox",
		description = S("@1 Arrowslit with Hole", desc),
		tiles = tile,
		groups = composition_def.groups,
		sounds = composition_def.sounds,
		paramtype = "light",
		paramtype2 = "facedir",
	node_box = {
		type = "fixed",
		fixed = {
			{-0.5, -0.375, 0.5, -0.125, 0.375, 0.3125},
			{0.125, -0.375, 0.5, 0.5, 0.375, 0.3125},
			{-0.5, -0.5, 0.5, 0.5, -0.375, 0.3125},
			{0.0625, -0.125, 0.5, 0.125, 0.375, 0.3125},
			{-0.125, -0.125, 0.5, -0.0625, 0.375, 0.3125},
			{-0.5, 0.375, 0.5, 0.5, 0.5, 0.3125},
			{0.25, -0.5, 0.3125, 0.5, 0.5, 0.125},
			{-0.5, -0.5, 0.3125, -0.25, 0.5, 0.125},
		},
	},
	selection_box = {
		type = "fixed",
		fixed = {
			{-0.5, -0.5, 0.5, 0.5, 0.5, 0.125},
		},
	},
	})

	minetest.register_node(mod_name..":arrowslit_"..material.name.."_embrasure", {
		drawtype = "nodebox",
		description = S("@1 Embrasure", desc),
		tiles = tile,
		groups = composition_def.groups,
		sounds = composition_def.sounds,
		paramtype = "light",
		paramtype2 = "facedir",
	node_box = {
		type = "fixed",
		fixed = {
			{-0.25, -0.5, 0.375, -0.125, 0.5, 0.5},
			{0.125, -0.5, 0.375, 0.25, 0.5, 0.5},
			{0.25, -0.5, 0.25, 0.5, 0.5, 0.5},
			{0.375, -0.5, 0.125, 0.5, 0.5, 0.25},
			{-0.5, -0.5, 0.25, -0.25, 0.5, 0.5},
			{-0.5, -0.5, 0.125, -0.375, 0.5, 0.25},
		},
	},
	selection_box = {
		type = "fixed",
		fixed = {
			{-0.5,-0.5,0.5,0.5,0.5,0.125},
		},
	},
	})
	
	minetest.register_craft({
		output = mod_name..":arrowslit_"..material.name.." 6",
		recipe = {
		{material.craft_material,"", material.craft_material},
		{material.craft_material,"", material.craft_material},
		{material.craft_material,"", material.craft_material} },
	})

	minetest.register_craft({
		output = mod_name..":arrowslit_"..material.name.."_cross",
		recipe = {
		{mod_name..":arrowslit_"..material.name} },
	})
	minetest.register_craft({
		output = mod_name..":arrowslit_"..material.name.."_hole",
		recipe = {
		{mod_name..":arrowslit_"..material.name.."_cross"} },
	})
	minetest.register_craft({
		output = mod_name..":arrowslit_"..material.name.."_embrasure",
		recipe = {
		{mod_name..":arrowslit_"..material.name.."_hole"} },
	})
	minetest.register_craft({
		output = mod_name..":arrowslit_"..material.name,
		recipe = {
		{mod_name..":arrowslit_"..material.name.."_embrasure"} },
	})
	
	if burn_time > 0 then
		minetest.register_craft({
			type = "fuel",
			recipe = mod_name..":arrowslit_"..material.name,
			burntime = burn_time,
		})	
		minetest.register_craft({
			type = "fuel",
			recipe = mod_name..":arrowslit_"..material.name.."_cross",
			burntime = burn_time,
		})	
		minetest.register_craft({
			type = "fuel",
			recipe = mod_name..":arrowslit_"..material.name.."_hole",
			burntime = burn_time,
		})	
		minetest.register_craft({
			type = "fuel",
			recipe = mod_name..":arrowslit_"..material.name.."_embrasure",
			burntime = burn_time,
		})	
	end

	local lbm_def = {
		name = mod_name..":arrowslit_flip_front_to_back"..material.name,
		nodenames = {
			mod_name..":arrowslit_"..material.name,
			mod_name..":arrowslit_"..material.name.."_cross",
			mod_name..":arrowslit_"..material.name.."_hole",
		},
		action = function(pos, node)
			local flip_front_to_back = {[0]=2, 3, 0, 1, 6, 7, 4, 5, 10, 7, 8, 9, 14, 15, 12, 13, 18, 19, 16, 17, 22, 23, 20, 21}
			node.param2 = flip_front_to_back[node.param2]
			minetest.swap_node(pos, node)
		end
	}
	
	minetest.register_lbm(lbm_def)
end

-------------------------------------------------------------------------------------

if read_setting("castle_structure_pillar", true) then
	for _, material in pairs(castle_structure.materials) do
		castle_structure.register_pillar(material)
	end
end

if read_setting("castle_structure_arrowslit", true) then
	for _, material in pairs(castle_structure.materials) do
		castle_structure.register_arrowslit(material)
	end
end

if read_setting("castle_structure_murderhole", true) then
	for _, material in pairs(castle_structure.materials) do
		castle_structure.register_murderhole(material)
	end
end
