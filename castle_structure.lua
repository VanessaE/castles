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

local materials = {}
if read_setting("castle_structure_stonewall", true) then
	table.insert(materials, {name="stonewall", desc=S("Stonewall"), tile="castle_stonewall.png", craft_material="castle:stonewall"})
end
if read_setting("castle_structure_cobble", true) then
	table.insert(materials, {name="cobble", desc=S("Cobble"), tile="default_cobble.png", craft_material="default:cobble"})
end
if read_setting("castle_structure_stonebrick", true) then
	table.insert(materials, {name="stonebrick", desc=S("Stonebrick"), tile="default_stone_brick.png", craft_material="default:stonebrick"})
end
if read_setting("castle_structure_sandstonebrick", true) then
	table.insert(materials, {name="sandstonebrick", desc=S("Sandstone Brick"), tile="default_sandstone_brick.png", craft_material="default:sandstonebrick"})
end
if read_setting("castle_structure_desertstonebrick", true) then
	table.insert(materials, {name="desertstonebrick", desc=S("Desert Stone Brick"), tile="default_desert_stone_brick.png", craft_material="default:desert_stonebrick"})
end
if read_setting("castle_structure_stone", true) then
	table.insert(materials, {name="stone", desc=S("Stone"), tile="default_stone.png", craft_material="default:stone"})
end
if read_setting("castle_structure_sandstone", true) then
	table.insert(materials, {name="sandstone", desc=S("Sandstone"), tile="default_sandstone.png", craft_material="default:sandstone"})
end
if read_setting("castle_structure_desertstone", true) then
	table.insert(materials, {name="desertstone", desc=S("Desert Stone"), tile="default_desert_stone.png", craft_material="default:desert_stone"})
end
if read_setting("castle_structure_wood", true) then
	table.insert(materials, {name="wood", desc=S("Wood"), tile="default_wood.png", craft_material="group:wood", composition_material="default:wood"})
end

local get_material_properties = function(material)
	local composition_def
	local burn_time
	if material.composition_material ~= nil then
		composition_def = minetest.registered_nodes[material.composition_material]
		burn_time = minetest.get_craft_result({method="fuel", width=1, items={ItemStack(material.composition_material)}}).time
	else
		composition_def = minetest.registered_nodes[material.craft_material]
		burn_time = minetest.get_craft_result({method="fuel", width=1, items={ItemStack(material.craft_materia)}}).time
	end
	return composition_def, burn_time
end

-------------------------------------------------------------------------------------

castle_structure.register_murderhole = function(material)
	local composition_def, burn_time = get_material_properties(material)
	
	-- Node Definition
	minetest.register_node("castle:hole_"..material.name, {
		drawtype = "nodebox",
		description = S("@1 Murder Hole", material.desc),
		tiles = {material.tile},
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

	minetest.register_craft({
		output = "castle:hole_"..material.name.." 4",
		recipe = {
		{"",material.craft_material, "" },
		{material.craft_material,"", material.craft_material},
		{"",material.craft_material, ""} },
	})
	
	if burn_time > 0 then
		minetest.register_craft({
			type = "fuel",
			recipe = "castle:hole_"..material.name,
			burntime = burn_time,
		})	
	end
end

-------------------------------------------------------------------------------------

castle_structure.register_pillar = function(material)
	local composition_def, burn_time = get_material_properties(material)
		
	-- Node Definition
	minetest.register_node("castle:pillars_"..material.name.."_bottom", {
		drawtype = "nodebox",
		description = S("@1 Pillar Base", material.desc),
		tiles = {material.tile},
		groups = composition_def.groups,
		sounds = composition_def.sounds,
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
	
	minetest.register_node("castle:pillars_"..material.name.."_top", {
		drawtype = "nodebox",
		description = S("@1 Pillar Top", material.desc),
		tiles = {material.tile},
		groups = composition_def.groups,
		sounds = composition_def.sounds,
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

	minetest.register_node("castle:pillars_"..material.name.."_middle", {
		drawtype = "nodebox",
		description = S("@1 Pillar Middle", material.desc),
		tiles = {material.tile},
		groups = composition_def.groups,
		sounds = composition_def.sounds,
		paramtype = "light",
		paramtype2 = "facedir",
		node_box = {
			type = "fixed",
			fixed = {
				{-0.250000,-0.500000,-0.250000,0.250000,0.500000,0.250000},
			},
		},
	})

	minetest.register_craft({
		output = "castle:pillars_"..material.name.."_bottom 4",
		recipe = {
			{"",material.craft_material,""},
			{"",material.craft_material,""},
			{material.craft_material,material.craft_material,material.craft_material} },
	})

	minetest.register_craft({
		output = "castle:pillars_"..material.name.."_top 4",
		recipe = {
			{material.craft_material,material.craft_material,material.craft_material},
			{"",material.craft_material,""},
			{"",material.craft_material,""} },
	})

	minetest.register_craft({
		output = "castle:pillars_"..material.name.."_middle 4",
		recipe = {
			{material.craft_material,material.craft_material},
			{material.craft_material,material.craft_material},
			{material.craft_material,material.craft_material} },
	})
	
	if burn_time > 0 then
		minetest.register_craft({
			type = "fuel",
			recipe = "castle:pillars_"..material.name.."_top",
			burntime = burn_time*5/4,
		})	
		minetest.register_craft({
			type = "fuel",
			recipe = "castle:pillars_"..material.name.."_bottom",
			burntime = burn_time*5/4,
		})	
		minetest.register_craft({
			type = "fuel",
			recipe = "castle:pillars_"..material.name.."_middle",
			burntime = burn_time*6/4,
		})	
	end
	
end

-------------------------------------------------------------------------------------

castle_structure.register_arrowslit = function(material)
	local composition_def, burn_time = get_material_properties(material)

	-- Node Definition
	minetest.register_node("castle:arrowslit_"..material.name, {
		drawtype = "nodebox",
		description = S("@1 Arrowslit", material.desc),
		tiles = {material.tile},
		groups = composition_def.groups,
		sounds = composition_def.sounds,
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

	minetest.register_node("castle:arrowslit_"..material.name.."_cross", {
		drawtype = "nodebox",
		description = S("@1 Arrowslit with Cross", material.desc),
		tiles = {material.tile},
		groups = composition_def.groups,
		sounds = composition_def.sounds,
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

	minetest.register_node("castle:arrowslit_"..material.name.."_hole", {
		drawtype = "nodebox",
		description = S("@1 Arrowslit with Hole", material.desc),
		tiles = {material.tile},
		groups = composition_def.groups,
		sounds = composition_def.sounds,
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
	
	minetest.register_craft({
		output = "castle:arrowslit_"..material.name.." 6",
		recipe = {
		{material.craft_material,"", material.craft_material},
		{material.craft_material,"", material.craft_material},
		{material.craft_material,"", material.craft_material} },
	})

	minetest.register_craft({
		output = "castle:arrowslit_"..material.name.."_cross",
		recipe = {
		{"castle:arrowslit_"..material.name} },
	})

	minetest.register_craft({
		output = "castle:arrowslit_"..material.name.."_hole",
		recipe = {
		{"castle:arrowslit_"..material.name.."_cross"} },
	})

	minetest.register_craft({
		output = "castle:arrowslit_"..material.name,
		recipe = {
		{"castle:arrowslit_"..material.name.."_hole"} },
	})
	
	if burn_time > 0 then
		minetest.register_craft({
			type = "fuel",
			recipe = "castle:arrowslit_"..material.name,
			burntime = burn_time,
		})	
		minetest.register_craft({
			type = "fuel",
			recipe = "castle:arrowslit_"..material.name.."_cross",
			burntime = burn_time,
		})	
		minetest.register_craft({
			type = "fuel",
			recipe = "castle:arrowslit_"..material.name.."_hole",
			burntime = burn_time,
		})	
	end
end

-------------------------------------------------------------------------------------

if read_setting("castle_structure_pillar", true) then
	for _, material in pairs(materials) do
		castle_structure.register_pillar(material)
	end
end

if read_setting("castle_structure_arrowslit", true) then
	for _, material in pairs(materials) do
		castle_structure.register_arrowslit(material)
	end
end

if read_setting("castle_structure_murderhole", true) then
	for _, material in pairs(materials) do
		castle_structure.register_murderhole(material)
	end
end



