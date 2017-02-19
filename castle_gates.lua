-- internationalization boilerplate
local MP = minetest.get_modpath(minetest.get_current_modname())
local S, NS = dofile(MP.."/intllib.lua")

castle_gates = {}

if minetest.get_modpath("doors") then
	doors.register("castle:oak_door", {
		tiles = {{ name = "castle_door_oak.png", backface_culling = true }},
		description = S("Oak Door"),
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
		description = S("Jail Door"),
		inventory_image = "castle_jail_door_inv.png",
		protected = true,
		groups = { cracky = 2, door = 1, flow_through = 1},
		sound_open = "doors_steel_door_open",
		sound_close = "doors_steel_door_close",
		recipe = {
			{"castle:jailbars", "castle:jailbars"},
			{"castle:jailbars", "castle:jailbars"},
			{"castle:jailbars", "castle:jailbars"},
		}
	})
end

if minetest.get_modpath("xpanes") then
	xpanes.register_pane("jailbars", {
		description = S("Jail Bars"),
		tiles = {"castle_jailbars.png"},
		drawtype = "airlike",
		paramtype = "light",
		textures = {"castle_jailbars.png", "castle_jailbars.png", "xpanes_space.png"},
		inventory_image = "castle_jailbars.png",
		wield_image = "castle_jailbars.png",
		sounds = default.node_sound_stone_defaults(),
		groups = {cracky=1, pane=1, flow_through=1},
		recipe = {
			{"default:steel_ingot", "default:steel_ingot", "default:steel_ingot"},
			{"default:steel_ingot", "",                    "default:steel_ingot"},
			{"default:steel_ingot", "default:steel_ingot", "default:steel_ingot"}},
	})
end

for i = 1, 15 do
	minetest.register_alias("castle:jailbars_"..i, "xpanes:jailbars_"..i)
end
minetest.register_alias("castle:jailbars", "xpanes:jailbars")

-- Given a facedir, returns a set of all the corresponding directions
local get_dirs = function(facedir)
	local dirs = {}
	local top = {[0]={x=0, y=1, z=0},
		{x=0, y=0, z=1},
		{x=0, y=0, z=-1},
		{x=1, y=0, z=0},
		{x=-1, y=0, z=0},
		{x=0, y=-1, z=0}}	
	dirs.back = minetest.facedir_to_dir(facedir)
	dirs.top = top[math.floor(facedir/4)]
	dirs.right = {
		x=dirs.top.y*dirs.back.z - dirs.back.y*dirs.top.z,
		y=dirs.top.z*dirs.back.x - dirs.back.z*dirs.top.x,
		z=dirs.top.x*dirs.back.y - dirs.back.x*dirs.top.y
	}
	dirs.front = vector.multiply(dirs.back, -1)
	dirs.bottom = vector.multiply(dirs.top, -1)
	dirs.left = vector.multiply(dirs.right, -1)
	return dirs
end


dofile(minetest.get_modpath("castle").."/class_pointset.lua")

local get_door_layout = function(pos, facedir, player)
	-- This method does a flood-fill looking for all nodes that meet the following criteria:
	-- belongs to a "castle_gate" group
	-- has the same "back" direction as the initial node
	-- is accessible via up, down, left or right directions unless one of those directions goes through an edge that one of the two nodes has marked as a gate edge
	local door = {}

	door.all = {}
	door.hinges = {}
	door.contains_protected_node = false
	door.directions = get_dirs(facedir)
	door.can_slide = {}
	door.previous_move = minetest.get_meta(pos):get_string("previous_move")

	-- temporary pointsets used while searching
	local to_test = Pointset.create()
	local tested = Pointset.create()
	local can_slide_to = Pointset.create()
	
	to_test:set_pos(pos, true)
	
	local test_pos, _ = to_test:pop()
	while test_pos ~= nil do
		tested:set_pos(test_pos, true) -- track nodes we've looked at
		local test_node = minetest.get_node(test_pos)

		if test_node.name == "ignore" then
			--array is next to unloaded nodes, too dangerous to do anything. Abort.
			return nil
		end
		
		if minetest.is_protected(test_pos, player:get_player_name()) and not minetest.check_player_privs(player, "protection_bypass") then
			door.contains_protected_node = true
		end
		
		local test_node_def = minetest.registered_nodes[test_node.name]
		can_slide_to:set_pos(test_pos, test_node_def.buildable_to == true)
		
		if test_node_def.paramtype2 == "facedir" then
			local test_node_dirs = get_dirs(test_node.param2)
			local coplanar = vector.equals(test_node_dirs.back, door.directions.back)

			if coplanar and (test_node_def.groups.castle_gate or test_node_def.groups.castle_gate_hinge) then
				local entry = {["pos"] = test_pos, ["node"] = test_node}
				table.insert(door.all, entry)
				if test_node_def.groups.castle_gate_hinge then
					table.insert(door.hinges, entry)
				end
				
				can_slide_to:set_pos(test_pos, true) -- since this is part of the door, other parts of the door can slide into it

				local test_directions = {"top", "bottom", "left", "right"}
				for _, dir in pairs(test_directions) do
					local adjacent_pos = vector.add(test_pos, door.directions[dir])
					local adjacent_node = minetest.get_node(adjacent_pos)
					local adjacent_def = minetest.registered_nodes[adjacent_node.name]
					can_slide_to:set_pos(adjacent_pos, adjacent_def.buildable_to == true or adjacent_def.groups.castle_gate)
					
					if test_node_def._gate_edges == nil or not test_node_def._gate_edges[dir] then -- if we ourselves are an edge node, don't look in the direction we're an edge in
						if tested:get_pos(adjacent_pos) == nil then -- don't look at nodes that have already been looked at
							if adjacent_def.paramtype2 == "facedir" then -- all doors are facedir nodes so we can pre-screen some targets
							
								local edge_points_back_at_test_pos = false
								-- Look at the adjacent node's definition. If it's got gate edges, check if they point back at us.
								if adjacent_def._gate_edges ~= nil then
									local adjacent_directions = get_dirs(adjacent_node.param2)
									for dir, val in pairs(adjacent_def._gate_edges) do
										if vector.equals(vector.add(adjacent_pos, adjacent_directions[dir]), test_pos) then
											edge_points_back_at_test_pos = true
											break
										end
									end									
								end
								
								if not edge_points_back_at_test_pos then
									to_test:set_pos(adjacent_pos, true)
								end
							end
						end
					end				
				end
			end
		end
		
		test_pos, _ = to_test:pop()
	end
	
	if table.getn(door.hinges) == 0 then
		--sliding door, evaluate which directions it can go
		door.can_slide = {top=true, bottom=true, left=true, right=true}
		for _,door_node in pairs(door.all) do
			door.can_slide.top = door.can_slide.top and can_slide_to:get_pos(vector.add(door_node.pos, door.directions.top))
			door.can_slide.bottom = door.can_slide.bottom and can_slide_to:get_pos(vector.add(door_node.pos, door.directions.bottom))
			door.can_slide.left = door.can_slide.left and can_slide_to:get_pos(vector.add(door_node.pos, door.directions.left))
			door.can_slide.right = door.can_slide.right and can_slide_to:get_pos(vector.add(door_node.pos, door.directions.right))
			
			minetest.debug("slide tests", dump(door_node), dump({can_slide_to:get_pos(vector.add(door_node.pos, door.directions.top)),
			can_slide_to:get_pos(vector.add(door_node.pos, door.directions.bottom)),
			can_slide_to:get_pos(vector.add(door_node.pos, door.directions.left)),
			can_slide_to:get_pos(vector.add(door_node.pos, door.directions.right))}))
			
		end
	end
	
	return door
end

local slide_gate = function(door, direction)
	for _, door_node in pairs(door.all) do
		door_node.pos = vector.add(door_node.pos, door.directions[direction])
	end
	door.previous_move = direction
end

castle_gates.trigger_gate = function(pos, node, player)
	local door = get_door_layout(pos, node.param2, player)
	
	--minetest.debug(dump(door))
	
	if door ~= nil then
		for _, door_node in pairs(door.all) do
			minetest.set_node(door_node.pos, {name="air"})
		end
		
		local door_moved = false
		if table.getn(door.hinges) == 0 then -- this is a sliding door
			if door.previous_move == "top" and door.can_slide.top then
				slide_gate(door, "top")
				door_moved = true
			elseif door.previous_move == "bottom" and door.can_slide.bottom then
				slide_gate(door, "bottom")
				door_moved = true
			elseif door.previous_move == "left" and door.can_slide.left then
				slide_gate(door, "left")
				door_moved = true
			elseif door.previous_move == "right" and door.can_slide.right then
				slide_gate(door, "right")
				door_moved = true
			end
			
			if not door_moved then -- reverse door's direction for next time
				if door.previous_move == "top" and door.can_slide.bottom then
					door.previous_move = "bottom"
				elseif door.previous_move == "bottom" and door.can_slide.top then
					door.previous_move = "top"
				elseif door.previous_move == "left" and door.can_slide.right then
					door.previous_move = "right"
				elseif door.previous_move == "right" and door.can_slide.left then
					door.previous_move = "left"
				else
					-- find any open direction
					for slide_dir, enabled in pairs(door.can_slide) do
						if enabled then
							door.previous_move = slide_dir
							break
						end
					end
				end
			end
		end

		for _, door_node in pairs(door.all) do
			minetest.set_node(door_node.pos, door_node.node)
			minetest.get_meta(door_node.pos):set_string("previous_move", door.previous_move)
		end
		
		if door_moved then
			minetest.after(1, function()
				castle_gates.trigger_gate(door.all[1].pos, door.all[1].node, player)
				end)
		end
		
	end	
end

minetest.register_node("castle:portcullis_slot", {
	drawtype = "nodebox",
	description = S("Portcullis Slot"), 
	--  top, bottom, right, left, back, front. 
	tiles = {"default_wood.png", "default_stone_brick.png", "default_stone_brick.png", "default_stone_brick.png", "default_stone_brick.png", "default_stone_brick.png"},
	paramtype = "light",
	paramtype2 = "facedir",
	groups = {oddly_breakable_by_hand=1},
	
	node_box = {
		type = "fixed",
		fixed = {
			{-0.5, -0.5, -0.5, 0.5, 0.5, 0.75}, -- body
			{-0.5, -0.5, 1.25, 0.5, 0.5, 1.5}, -- far piece
			{-0.25, -0.25, 1.15, 0.25, 0.25, 1.25}, -- gripper
			{-0.25, -0.25, 0.75, 0.25, 0.25, 0.85}, -- gripper
			
			{-0.125, -0.5+1, -0.125, 0.125, -0.4375+1, 0.125}, -- axle
			{-0.3125, -0.4375+1, -0.3125, 0.3125, -0.3125+1, 0.3125}, -- wheel
			{-0.25, -0.3125+1, 0.125, -0.125, -0.1875+1, 0.25}, -- handle
			{0.125, -0.3125+1, -0.25, 0.25, -0.1875+1, -0.125}, -- handle
		}
	},
	
	collision_box = {
		type = "fixed",
		fixed = {-0.5, -0.5, -0.5, 0.5, 0.5, 1.5}, -- body
	},
})

minetest.register_node("castle:portcullis_bars", {
	drawtype = "nodebox",
	description = S("Portcullis Bars"),
	groups = {castle_gate = 1, choppy = 1, flow_through = 1},
	tiles = {
		"default_steel_block.png^(default_wood.png^[transformR90^[mask:castle_portcullis_mask.png)",
		"default_steel_block.png^(default_wood.png^[transformR90^[mask:castle_portcullis_mask.png)",
		"default_wood.png^[transformR90",
		"default_wood.png^[transformR90",
		"default_steel_block.png^(default_wood.png^[transformR90^[mask:castle_portcullis_mask.png)",
		"default_steel_block.png^(default_wood.png^[transformR90^[mask:castle_portcullis_mask.png)",
		},
	paramtype = "light",
	paramtype2 = "facedir",
	node_box = {
		type = "fixed",
		fixed = {
			{-0.125, -0.5, -0.125, 0.125, 0.5, 0.125}, -- middle bar
			{-0.5, -0.5, -0.125, -0.375, 0.5, 0.125}, -- side bar
			{0.375, -0.5, -0.125, 0.5, 0.5, 0.125}, -- side bar
			{-0.375, 0.1875, -0.0625, 0.375, 0.3125, 0.0625}, -- crosspiece
			{-0.375, -0.3125, -0.0625, 0.375, -0.1875, 0.0625}, -- crosspiece
		}
	},
	on_rightclick = castle_gates.trigger_gate,
})

minetest.register_node("castle:portcullis_bars_bottom", {
	drawtype = "nodebox",
	description = S("Portcullis Bottom"),
	groups = {castle_gate = 1, choppy = 1, flow_through = 1},
	tiles = {
		"default_steel_block.png^(default_wood.png^[transformR90^[mask:castle_portcullis_mask.png)",
		"default_steel_block.png^(default_wood.png^[transformR90^[mask:castle_portcullis_mask.png)",
		"default_wood.png^[transformR90",
		"default_wood.png^[transformR90",
		"default_steel_block.png^(default_wood.png^[transformR90^[mask:castle_portcullis_mask.png)",
		"default_steel_block.png^(default_wood.png^[transformR90^[mask:castle_portcullis_mask.png)",
		},
	paramtype = "light",
	paramtype2 = "facedir",
		node_box = {
		type = "fixed",
		fixed = {
			{-0.125, -0.5, -0.125, 0.125, 0.5, 0.125}, -- middle bar
			{-0.5, -0.5, -0.125, -0.375, 0.5, 0.125}, -- side bar
			{0.375, -0.5, -0.125, 0.5, 0.5, 0.125}, -- side bar
			{-0.375, 0.1875, -0.0625, 0.375, 0.3125, 0.0625}, -- crosspiece
			{-0.375, -0.3125, -0.0625, 0.375, -0.1875, 0.0625}, -- crosspiece
			{-0.0625, -0.5, -0.0625, 0.0625, -0.625, 0.0625}, -- peg
			{0.4375, -0.5, -0.0625, 0.5, -0.625, 0.0625}, -- peg
			{-0.5, -0.5, -0.0625, -0.4375, -0.625, 0.0625}, -- peg
		}
	},
	_gate_edges = {bottom=true},
	on_rightclick = castle_gates.trigger_gate,
})

minetest.register_craft({
	output = "castle:portcullis_slot",
	recipe = {
		{"group:wood","","group:wood" },
		{"default:steel_ingot","","default:steel_ingot"},
		{"group:wood","","group:wood" },
	},
})
	
minetest.register_craft({
	output = "castle:portcullis_bars",
	recipe = {
		{"group:wood","default:steel_ingot","group:wood" },
		{"group:wood","default:steel_ingot","group:wood" },
		{"group:wood","default:steel_ingot","group:wood" },
	},
})

minetest.register_craft({
	output = "castle:portcullis_bars",
	recipe = {
		{"castle:portcullis_bars_bottom"}
	},
})

minetest.register_craft({
	output = "castle:portcullis_bars_bottom",
	recipe = {
		{"castle:portcullis_bars"}
	},
})

--------------------------------------------------------------------------------------------------------------


minetest.register_node("castle:gate_hinge", {
	drawtype = "nodebox",
	description = S("Gate Door With Hinge"),
	groups = {choppy = 1, castle_gate_hinge = 1},
	tiles = {
		"default_wood.png^[transformR90",
		},
	paramtype = "light",
	paramtype2 = "facedir",
		node_box = {
		type = "fixed",
		fixed = {
			{-0.5, -0.5, -0.5, 0.5, 0.5, -0.25},
			{-10/16, -4/16, -10/16, -6/16, 4/16, -6/16},
		}
	},
	on_rightclick = castle_gates.trigger_gate,
})

minetest.register_node("castle:gate_panel", {
	drawtype = "nodebox",
	description = S("Gate Door"),
	groups = {choppy = 1, castle_gate = 1},
	tiles = {
		"default_wood.png^[transformR90",
		"default_wood.png^[transformR90",
		"default_wood.png^[transformR90",
		"default_wood.png^[transformR90",
		"default_wood.png^[transformR90",
		"default_wood.png^[transformR90",
		},
	paramtype = "light",
	paramtype2 = "facedir",
		node_box = {
		type = "fixed",
		fixed = {
			{-0.5, -0.5, -0.5, 0.5, 0.5, -0.25},
		}
	},
	on_rightclick = castle_gates.trigger_gate,
})

minetest.register_node("castle:gate_edge", {
	drawtype = "nodebox",
	description = S("Gate Door Edge"),
	groups = {choppy = 1, castle_gate = 1},
	tiles = {
		"default_wood.png^[transformR90",
		"default_wood.png^[transformR90",
		"default_wood.png^[transformR90",
		"default_wood.png^[transformR90",
		"default_wood.png^[transformR90^(default_coal_block.png^[mask:castle_door_edge_mask.png^[transformFX)",
		"default_wood.png^[transformR90^(default_coal_block.png^[mask:castle_door_edge_mask.png)",
		},
	paramtype = "light",
	paramtype2 = "facedir",
		node_box = {
		type = "fixed",
		fixed = {
			{-0.5, -0.5, -0.5, 0.5, 0.5, -0.25},
		}
	},
	_gate_edges = {right=true},
	on_rightclick = castle_gates.trigger_gate,
})

minetest.register_node("castle:gate_edge_handle", {
	drawtype = "nodebox",
	description = S("Gate Door With Handle"),
	groups = {choppy = 1, castle_gate = 1},
	tiles = {
		"default_steel_block.png^(default_wood.png^[mask:castle_door_side_mask.png^[transformR90)",
		"default_steel_block.png^(default_wood.png^[mask:castle_door_side_mask.png^[transformR90)",
		"default_steel_block.png^(default_wood.png^[transformR90^[mask:castle_door_side_mask.png)",
		"default_steel_block.png^(default_wood.png^[transformR90^[mask:(castle_door_side_mask.png^[transformFX))",
		"default_wood.png^[transformR90^(default_coal_block.png^[mask:castle_door_edge_mask.png^[transformFX)^(default_steel_block.png^[mask:castle_door_handle_mask.png^[transformFX)",
		"default_wood.png^[transformR90^(default_coal_block.png^[mask:castle_door_edge_mask.png)^(default_steel_block.png^[mask:castle_door_handle_mask.png)",
		},
	paramtype = "light",
	paramtype2 = "facedir",
		node_box = {
		type = "fixed",
		fixed = {
			{-0.5, -0.5, -0.5, 0.5, 0.5, -0.25},
			{4/16, -4/16, -2/16, 6/16, 4/16, -3/16},
			{4/16, -4/16, -9/16, 6/16, 4/16, -10/16},
			{4/16, -4/16, -9/16, 6/16, -3/16, -3/16},
			{4/16, 4/16, -9/16, 6/16, 3/16, -3/16},
		}
	},
	_gate_edges = {right=true},
	on_rightclick = castle_gates.trigger_gate,
})
