-----------------------------
--Node Registration
-----------------------------

minetest.register_node("castle:anvil",{
	drawtype = "nodebox",
	description = "Anvil",
	tiles = {"castle_steel.png"},
	groups = { cracky = 2, falling_node = 1 },
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

minetest.register_node("castle:crate", {
	description = "Crate",
	tiles = {
     "castle_crate_top.png",
     "castle_crate_top.png",
     "castle_crate.png"
   },
	groups = { choppy = 3 },
	paramtype = "light",
	sounds = default.node_sound_wood_defaults(),
	on_construct = function(pos)
		local meta = minetest.get_meta(pos)
		meta:set_string("formspec",
				"size[9,9]"..
				default.gui_bg..
    default.gui_bg_img..
    default.gui_slots..
				"list[current_name;main;0,0;9,4;]"..
				"list[current_player;main;0.5,5;8,4;]"..
			 "listring[current_name;main]" ..
    "listring[current_player;main]")
		meta:set_string("infotext", "Crate")
		local inv = meta:get_inventory()
		inv:set_size("main", 9*4)
	end,
	can_dig = function(pos,player)
		local meta = minetest.get_meta(pos);
		local inv = meta:get_inventory()
		return inv:is_empty("main")
	end,
	on_metadata_inventory_move = function(pos, from_list, from_index, to_list, to_index, count, player)
		minetest.log("action", player:get_player_name()..
				" moves stuff in crate at "..minetest.pos_to_string(pos))
	end,
    on_metadata_inventory_put = function(pos, listname, index, stack, player)
		minetest.log("action", player:get_player_name()..
				" moves stuff to crate at "..minetest.pos_to_string(pos))
	end,
    on_metadata_inventory_take = function(pos, listname, index, stack, player)
		minetest.log("action", player:get_player_name()..
				" takes stuff from crate at "..minetest.pos_to_string(pos))
	end,
})

doors.register("castle:oak_door", {
		tiles = {{ name = "castle_door_oak.png", backface_culling = true }},
		description = "Oak Door",
		inventory_image = "castle_oak_door_inv.png",
		protected = true,
		groups = { choppy = 2, door = 1 },
		sounds = default.node_sound_wood_defaults(),
		recipe = {
			{"default:tree", "default:tree"},
			{"default:tree", "default:tree"},
			{"default:tree", "default:tree"},
		}
})

doors.register("castle:jail_door", {
		tiles = {{ name = "castle_door_jail.png", backface_culling = true }},
		description = "Jail Door",
		inventory_image = "castle_jail_door_inv.png",
		protected = true,
		groups = { cracky = 2, door = 1},
		sound_open = "doors_steel_door_open",
		sound_close = "doors_steel_door_close",
		recipe = {
			{"xpanes:jailbars", "xpanes:jailbars"},
			{"xpanes:jailbars", "xpanes:jailbars"},
			{"xpanes:jailbars", "xpanes:jailbars"},
		}
})

if minetest.get_modpath("xpanes") then
  xpanes.register_pane("jailbars", {
   description = "Jail Bars",
   tiles = {"castle_jailbars.png"},
   drawtype = "airlike",
   paramtype = "light",
   inventory_image = "castle_jailbars.png",
   wield_image = "castle_jailbars.png",
   textures = {
       "castle_jailbars.png",
       "castle_jailbars.png",
       "xpanes_space.png"
      },
   sounds = default.node_sound_stone_defaults(),
   groups = { cracky = 1, pane = 1 },
   recipe = {
     {"default:steel_ingot","","default:steel_ingot"},
     {"default:steel_ingot","default:steel_ingot","default:steel_ingot"},
     {"default:steel_ingot","","default:steel_ingot"}
    }
  })
end

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
   groups = { snappy = 3, dig_immediate = 1 },
   sounds = default.node_sound_leaves_defaults(),
   selection_box = {
      type = "wallmounted",
    },
})

minetest.register_node("castle:ironbound_chest",{
  drawtype = "nodebox",
  description = "Ironbound Chest",
  tiles = {
     "castle_ironbound_chest_top.png",
     "castle_ironbound_chest_top.png",
     "castle_ironbound_chest_side.png",
     "castle_ironbound_chest_side.png",
     "castle_ironbound_chest_back.png",
     "castle_ironbound_chest_front.png"
    },
  paramtype = "light",
  paramtype2 = "facedir",
  groups = { cracky = 3, choppy = 3, snapp = 1 },
  sounds = default.node_sound_wood_defaults(),
  node_box = {
    type = "fixed",
     fixed = {
       {-0.500000,-0.500000,-0.312500,0.500000,-0.062500,0.312500},
       {-0.500000,-0.062500,-0.250000,0.500000,0.000000,0.250000},
       {-0.500000,0.000000,-0.187500,0.500000,0.062500,0.187500},
       {-0.500000,0.062500,-0.062500,0.500000,0.125000,0.062500},
     },
   },
  selection_box = {
    type = "fixed",
     fixed = {
       {-0.5,-0.500000,-0.400000,0.5,0.200000,0.4},
     },
  },
	on_construct = function(pos)
		local meta = minetest.get_meta(pos)
		meta:set_string("formspec",
				"size[8,9]"..
				default.gui_bg..
    default.gui_bg_img..
    default.gui_slots..
				"list[current_name;main;0,0.3;8,4;]"..
				"list[current_player;main;0,5;8,4;]"..
			 "listring[current_name;main]" ..
    "listring[current_player;main]")
		meta:set_string("infotext", "Ironbound Chest")
		local inv = meta:get_inventory()
		inv:set_size("main", 8*4)
	end,
	can_dig = function(pos,player)
		local meta = minetest.get_meta(pos);
		local inv = meta:get_inventory()
		return inv:is_empty("main")
	end,
	on_metadata_inventory_move = function(pos, from_list, from_index, to_list, to_index, count, player)
		minetest.log("action", player:get_player_name()..
				" moves stuff in chest at "..minetest.pos_to_string(pos))
	end,
    on_metadata_inventory_put = function(pos, listname, index, stack, player)
		minetest.log("action", player:get_player_name()..
				" moves stuff to chest at "..minetest.pos_to_string(pos))
	end,
    on_metadata_inventory_take = function(pos, listname, index, stack, player)
		minetest.log("action", player:get_player_name()..
				" takes stuff from chest at "..minetest.pos_to_string(pos))
	end,
})

minetest.register_node("castle:street_light",{
	description = "Street Lantern",
	 inventory_image ="castle_street_light.png",
		tiles = {"castle_street_light.png"},
	sunlight_propagates = true,
	walkable = false,
	groups = { cracky = 3, snappy = 1, choppy = 2 },
	is_ground_content = false,
	paramtype = "light",
	sounds = default.node_sound_glass_defaults(),
 on_construct = function(pos)
		local timer = minetest.env:get_node_timer(pos)
		timer:start(1)
	end,

	on_timer = function(pos, elapsed)
		if minetest.env:get_timeofday() >= 0.75 or minetest.env:get_timeofday() < 0.25 then
			minetest.set_node(pos, {name="castle:street_light_on"})
		else
			local timer = minetest.env:get_node_timer(pos)
			timer:start(30)
			return true
		end
	end,
})

minetest.register_node("castle:street_light_on",{
  description = "Street Lantern",
  tiles = {"castle_street_light_on.png"},
  sunlight_propagates = true,
  walkable = false,
  light_source = default.LIGHT_MAX,
  groups = { cracky = 3, snappy = 1, choppy = 2, not_in_creative_inventory = 1 },
  is_ground_content = false,
  paramtype = "light",
  drop = "castle:street_light",
  sounds = default.node_sound_glass_defaults(),
	on_construct = function(pos)
		local timer = minetest.env:get_node_timer(pos)
		timer:start(1)
	end,

	on_timer = function(pos, elapsed)
		if minetest.env:get_timeofday() >= 0.25 and minetest.env:get_timeofday() < 0.75 then
  minetest.set_node(pos, {name="castle:street_light"})
		else
			local timer = minetest.env:get_node_timer(pos)
			timer:start(30)
		end
		return true
	end,
})

----------
--Tools
----------

minetest.register_tool("castle:battleaxe", {
	description = "Battleaxe",
	inventory_image = "castle_tool_battleaxe.png",
	tool_capabilities = {
		full_punch_interval = 2.0,
		max_drop_level=1,
		groupcaps={
			cracky = {times={[1]=1.80, [2]=1.20, [3]=0.60}, uses=30, maxlevel=2},
			choppy={times={[1]=1.20, [2]=0.80, [3]=0.40}, uses=100, maxlevel=3},
		},
		damage_groups = {fleshy=8},
	},
})

minetest.register_tool("castle:broad_sword", {
	description = "Broadsword",
	inventory_image = "castle_tool_sword_broad.png",
	tool_capabilities = {
		full_punch_interval = 2.0,
		max_drop_level=1,
		groupcaps={
			choppy = {times={[1]=1.80, [2]=1.20, [3]=0.60}, uses=30, maxlevel=2},
			snappy={times={[1]=1.20, [2]=0.80, [3]=0.40}, uses=100, maxlevel=3},
		},
		damage_groups = {fleshy=8},
	},
})

-----------
--Crafting
-----------

minetest.register_craft({
	output = "castle:anvil",
	recipe = {
   {"default:steel_ingot","default:steel_ingot","default:steel_ingot"},
   {"","default:steel_ingot", ""},
   {"default:steel_ingot", "default:steel_ingot","default:steel_ingot"},
  }
})

minetest.register_craft({
	output = "castle:battleaxe",
	recipe = {
		{"default:steel_ingot", "default:steel_ingot","default:steel_ingot"},
		{"default:steel_ingot", "group:stick","default:steel_ingot"},
  {"", "group:stick",""},
	}
})

minetest.register_craft({
	output = "castle:battleaxe",
	recipe = {
		{ "default:axe_steel", "", "default:axe_steel"},
	}
})

minetest.register_craft({
	output = 'castle:broad_sword',
	recipe = {
		{"default:steel_ingot", "", "default:steel_ingot"},
	 {"default:steel_ingot", "", "default:steel_ingot"},
		{"group:stick", "", "group:stick"},
	}
})

minetest.register_craft({
	output = 'castle:broad_sword',
	recipe = {
		{"default:sword_steel", "", "default:sword_steel"},
	}
})

minetest.register_craft({
	output = 'castle:crate',
	recipe = {
   { 'group:stick', 'group:wood', 'group:stick' },
			{ 'group:wood', '', 'group:wood' },
			{ 'group:stick', 'group:wood', 'group:stick' },
	}
})

minetest.register_craft( {
 type = "shapeless",
 output = "castle:hides 2",
 recipe = { "wool:white" , "bucket:bucket_water" },
 replacements = {
   { 'bucket:bucket_water', 'bucket:bucket_empty' }
  }
} )

if minetest.get_modpath( "mobs") then
minetest.register_craft({
 type = "shapeless",
	output = "castle:hides 4",
	recipe = { "mobs:leather" , "bucket:bucket_water" },
	replacements = {
   { "bucket:bucket_water", "bucket:bucket_empty" }
  }
} )
end

minetest.register_craft({
	output = 'castle:ironbound_chest',
	recipe = {
   { 'default:steel_ingot', '', 'default:steel_ingot' },
   { '', 'castle:crate', '' },
   { 'default:steel_ingot', '', 'default:steel_ingot' },
	}
})

minetest.register_craft({
	output = 'castle:ironbound_chest',
	recipe = {
   { 'default:steel_ingot', 'group:wood', 'default:steel_ingot' },
			{ 'group:wood', '', 'group:wood' },
			{ 'default:steel_ingot', 'group:wood', 'default:steel_ingot' },
	}
})

minetest.register_craft({
	output = "castle:street_light",
	recipe = {
    {"default:stick", "default:glass", "default:stick"},
    {"default:glass", "default:torch", "default:glass"},
    {"default:stick", "default:glass", "default:stick"},
  }
})