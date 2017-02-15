minetest.register_alias("darkage:box",         "castle:crate")

minetest.register_node("castle:crate", {
	description = "Crate",
	drawtype = "normal",
	tiles = {"castle_crate_top.png","castle_crate_top.png","castle_crate.png","castle_crate.png","castle_crate.png","castle_crate.png"},
	groups = {choppy=3},
	sounds = default.node_sound_wood_defaults(),
	paramtype = "light",
	on_construct = function(pos)
		local meta = minetest.get_meta(pos)
		meta:set_string("formspec",
				"size[8,9]"..
				 default.gui_bg ..
				 default.gui_bg_img ..
				 default.gui_slots ..
				"list[current_name;main;0,0;8,5;]"..
				"list[current_player;main;0,5;8,4;]")
		meta:set_string("infotext", "Crate")
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

minetest.register_craft({
	output = "castle:crate",
	recipe = {
		{"default:wood", "default:wood", "default:wood"},
		{"default:wood", "default:steel_ingot", "default:wood"},
	}
})