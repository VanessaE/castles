
----------------------
--Node Registration
----------------------

minetest.register_node("castle:ropes",{
		description = "Rope",
		inventory_image = "castle_ropes.png",
		tiles = {"castle_ropes.png"},
		drawtype = "nodebox",
		paramtype = "light",
		paramtype2 = "facedir",
		sunlight_propagates = true,
		is_ground_content = false,
		walkable = false,
		climbable = true,
		groups = { snappy = 3, oddly_breakable_by_hand = 2, flammable	= 3 },
		sounds = default.node_sound_leaves_defaults(),
	node_box = {
		type = "fixed",
		fixed = {
			{-1/16, -8/16, -1/16, 1/16, 8/16, 1/16},
		},
	},
	selection_box = {
		type = "fixed",
		fixed = {
			{-1/16, -8/16, -1/16, 1/16, 8/16, 1/16},
		},
	},
})

minetest.register_node("castle:box_rope", {
		description = "Rope from Ropebox",
		tiles = {"castle_ropes.png"},
		drawtype = "nodebox",
		paramtype = "light",
		paramtype2 = "facedir",
		sunlight_propagates = true,
		is_ground_content = false,
		walkable = false,
		climbable = true,
		groups = { snappy = 3, oddly_breakable_by_hand = 2, flammable	= 3, not_in_creative_inventory =	1 },
		sounds = default.node_sound_leaves_defaults(),
	node_box = {
		type = "fixed",
		fixed = {
			{-1/16, -8/16, -1/16, 1/16, 8/16, 1/16},
		},
	},
	selection_box = {
		type = "fixed",
		fixed = {
			{-1/16, -8/16, -1/16, 1/16, 8/16, 1/16},
		},
	},
    after_destruct = function(pos,oldnode)
        local node = minetest.get_node({x=pos.x,y=pos.y-1,z=pos.z})
        if node.name == "castle:box_rope" then
            minetest.remove_node({x=pos.x,y=pos.y-1,z=pos.z})
        end
    end,
})

minetest.register_node("castle:ropebox", {
  description = "Ropebox",
  tiles = {
    "castle_ropebox_top.png",
    "castle_ropebox_top.png",
    "castle_ropebox_side_1.png",
    "castle_ropebox_side_1.png",
    "castle_ropebox_side_2.png",
    "castle_ropebox_side_2.png"
   },
		drawtype = "nodebox",
		paramtype = "light",
		paramtype2 = "facedir",
		sunlight_propagates = true,
		is_ground_content = false,
		walkable = false,
		climbable = true,
		groups = {cracky = 3, choppy = 2, snappy = 1	},
		sounds = default.node_sound_wood_defaults(),
	node_box = {
		type = "fixed",
		fixed = {
			{-2/16, -2/16, -4/16, 2/16, 2/16, 4/16},
			{-2/16, -4/16, -2/16, 2/16, 4/16, 2/16},
			{-2/16, -3/16, -3/16, 2/16, 3/16, 3/16},
			{-3/16, -2/16, -2/16, -2/16, 8/16, 2/16},
			{2/16, -2/16, -2/16, 3/16, 8/16, 2/16},
			{-1/16, -8/16, -1/16, 1/16, -4/16, 1/16},
		},
	},
    after_destruct = function(pos,oldnode)
        local node = minetest.get_node({x=pos.x,y=pos.y-1,z=pos.z})
        if node.name == "castle:box_rope" then
            minetest.remove_node({x=pos.x,y=pos.y-1,z=pos.z})
        end
    end,
})

minetest.register_abm({
	nodenames = {"castle:ropebox"},
	interval = 1,
	chance = 1,
	action = function(pos, node)
	if minetest.get_node({x=pos.x,y=pos.y-1,z=pos.z}).name ~= 'air'  then return end
	        minetest.add_node({x=pos.x,y=pos.y-1,z=pos.z}, {name="castle:box_rope"})
	end
})

minetest.register_abm({
	nodenames = {"castle:box_rope"},
	interval = 1,
	chance = 1,
	action = function(pos, node)
  if minetest.get_node({x=pos.x,y=pos.y-1,z=pos.z}).name ~= 'air'  then return end
	 minetest.add_node({x=pos.x,y=pos.y-1,z=pos.z}, {name="castle:box_rope"})
	end
})

-----------
--Crafting
-----------

minetest.register_craft({
	output = "castle:ropes 4",
	recipe = {
			{"castle:hides"},
			{"castle:hides"},
			{"castle:hides"},
		}
})

minetest.register_craft({
	output = "castle:ropes",
	recipe = {
			{"farming:string"},
			{"farming:string"},
			{"farming:string"},
		}
})

minetest.register_craft({
	output = "castle:ropebox",
	recipe = {
			{"castle:ropes", "default:steel_ingot", "castle:ropes"},
			{"castle:ropes", "castle:ropes", "castle:ropes"},
			{"castle:ropes", "castle:ropes", "castle:ropes"},
		}
})
