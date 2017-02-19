-- internationalization boilerplate
local MP = minetest.get_modpath(minetest.get_current_modname())
local S, NS = dofile(MP.."/intllib.lua")

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

-- Starting from pos, scans in the dir direction finding portcullis nodes
-- Continues scanning in a loop for each portcullis node, but stops after it encounters
-- a portcullis_edge node. This is useful when making dual sliding gates that meet at a junction.
-- Returns the pos lying one node *past* the end of the portcullis.
local scan_for_portcullis = function(pos, dir)
	local scan_pos = vector.new(pos)
	local done = false
	while not done do
		local node = minetest.get_node(scan_pos)
		if minetest.get_item_group(node.name, "portcullis") > 0 then
			scan_pos = vector.add(scan_pos, dir)
		elseif minetest.get_item_group(node.name, "portcullis_edge") > 0 then
			if not vector.equals(scan_pos, pos) then -- special case, if the edge is starting in the portcullis slot we want to continue scanning
				done = true
			end
			scan_pos = vector.add(scan_pos, dir)
		else
			done = true
		end
	end
	-- scan_pos now points one-past-the-edge	
	return scan_pos
end

-- Similar to the above, starts at pos and scans in the direction dir.
-- Unlike above, this only gets *identical* nodes (using the first one as an example)
-- both in node type and facing. Places a list of positions into the output table.
local scan_for_slot_row = function(pos, dir, output)
	local finished = false
	local node = minetest.get_node(pos)
	local pos_dir = vector.add(pos, dir)
	while not finished do
		local dir_node = minetest.get_node(pos_dir)
		if dir_node.param2 == node.param2 and dir_node.name == node.name then
			table.insert(output, {["pos"]=pos_dir})
			pos_dir = vector.add(pos_dir, dir)
		else
			finished = true
		end
	end
	return output
end

-- Actually slides the columns of portcullis nodes, as defined in the "port" table
-- dir is the axis the portcullis is moving along and up is a boolean that determines which
-- end of the portcullis table's node lists to start from (if up is true it starts moving at the "above" end)
local move_portcullis = function(port, dir, up)
	for _, slot in pairs(port) do
		local start, finish
		if up then
			start = vector.subtract(slot.above, dir)
			finish = slot.below
		else
			start = vector.subtract(slot.below, dir)
			finish = slot.above
		end
		while not vector.equals(start, finish) do
			local node = minetest.get_node(start)
			minetest.remove_node(start)
			minetest.set_node(vector.add(start, dir), node)
			start = vector.subtract(start, dir)
		end
	end
end

--sets a node's metadata to "lock" it against outside interaction and also sets a timer
--to remove that lock in 2 seconds (timer will be refreshed if it's locked again before then)
local lock_slot = function(pos)
	local meta = minetest.get_meta(pos)
	meta:set_string("locked", "true")
	local timer = minetest.get_node_timer(pos)
	timer:start(2)
end

-- pos and node are a portcullis slot.
-- direction is either "up" or "down"
local trigger_move = function(pos, node, direction)
	local dirs = get_dirs(node.param2)
	local all_slots = {}
	scan_for_slot_row(pos, dirs.right, all_slots)
	scan_for_slot_row(pos, dirs.left, all_slots)
	for _, slot in pairs(all_slots) do
		lock_slot(slot.pos)			
	end -- lock all of the connected slots other than this one
	
	table.insert(all_slots, {["pos"]=pos}) -- add this one to the table.
	
	local can_move_up = true
	local can_move_down = true
	
	for _, slot in pairs(all_slots) do
		local port_pos = vector.add(slot.pos, dirs.back) -- the position adjacent to this slot that holds the portcullis
		local port_node = minetest.get_node(port_pos)
		
		if minetest.get_item_group(port_node.name, "portcullis") + minetest.get_item_group(port_node.name, "portcullis_edge") == 0 then
			--There's nothing in the slot
			can_move_up = false
			can_move_down = false
		else
			slot.above = scan_for_portcullis(port_pos, dirs.top) -- this gets us the position one above the top portcullis node
			slot.below = scan_for_portcullis(port_pos, dirs.bottom) -- this gets us the position one below the bottom portcullis node
			
			local node_above = minetest.get_node(slot.above).name
			local node_below = minetest.get_node(slot.below).name
							
			can_move_up = can_move_up and
				minetest.registered_nodes[node_above].buildable_to and
				node_above ~= "ignore" and
				not vector.equals(port_pos, vector.add(slot.below, dirs.top))
			can_move_down = can_move_down and
				minetest.registered_nodes[node_below].buildable_to and
				node_below ~= "ignore" and
				not vector.equals(port_pos, vector.add(slot.above, dirs.bottom))
		end		
	end
	
	if direction == "up" then
		if can_move_up then
			move_portcullis(all_slots, dirs.top, true)
			minetest.get_node_timer(pos):start(1)
			minetest.get_meta(pos):set_string("controlling", "true")
		else
			for _, slot in pairs(all_slots) do
				-- movement finished, reset everything and toggle direction
				local slot_meta = minetest.get_meta(slot.pos)
				slot_meta:set_string("controlling", nil) -- only one node should be controlling, but wipe everything to be on the safe side
				slot_meta:set_string("locked", nil)
				slot_meta:set_string("direction",  "down")
			end
		end
	elseif direction == "down" then
		if can_move_down then
			move_portcullis(all_slots, dirs.bottom, false)
			minetest.get_node_timer(pos):start(1)
			minetest.get_meta(pos):set_string("controlling", "true")
		else
			for _, slot in pairs(all_slots) do
				-- movement finished, reset everything and toggle direction
				local slot_meta = minetest.get_meta(slot.pos)
				slot_meta:set_string("controlling", nil) -- only one node should be controlling, but wipe everything to be on the safe side
				slot_meta:set_string("locked", nil)
				slot_meta:set_string("direction",  "up")
			end
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
	
	on_construct = function(pos)
		local meta = minetest.get_meta(pos)
		meta:set_string("direction", "up")
	end,
	
	on_rightclick = function(pos, node, player, itemstack, pointed_thing)
		local meta = minetest.get_meta(pos)
		if meta:get_string("locked") ~= "" or meta:get_string("controlling") ~= "" then
			return
		end
		meta:set_string("controlling", "true")
		minetest.get_node_timer(pos):start(1)
	end,
	
	on_timer = function(pos, elapsed)
		local meta = minetest.get_meta(pos)
		if meta:get_string("locked") ~= "" then
			meta:set_string("locked", nil)
			return
		end
		if meta:get_string("controlling") ~= "" then
			trigger_move(pos, minetest.get_node(pos), meta:get_string("direction"))
		end
	
	end,
})

minetest.register_node("castle:portcullis_bars", {
	drawtype = "nodebox",
	description = S("Portcullis Bars"),
	groups = {portcullis = 1, choppy = 1, flow_through = 1},
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
	}
})

minetest.register_node("castle:portcullis_bars_bottom", {
	drawtype = "nodebox",
	description = S("Portcullis Bottom"),
	groups = {portcullis_edge = 1, choppy = 1, flow_through = 1},
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
	}
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

dofile(minetest.get_modpath("castle").."/class_pointset.lua")

local get_door_layout = function(pos, facedir, player)
	-- This method does a flood-fill looking for all nodes that meet the following criteria:
	-- belongs to a "big_door" group
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
	
	to_test:set_pos(pos, true)
	
	local test_pos, _ = to_test:pop()
	while test_pos ~= nil do
		local test_node = minetest.get_node(test_pos)

		if test_node.name == "ignore" then
			--array is next to unloaded nodes, too dangerous to do anything. Abort.
			return nil
		end
		
		if minetest.is_protected(test_pos, player:get_player_name()) and not minetest.check_player_privs(player, "protection_bypass") then
			door.contains_protected_node = true
		end
		
		local test_node_def = minetest.registered_nodes[test_node.name]
		tested:set_pos(test_pos, test_node_def.buildable_to == true) -- track nodes we've looked at, and note if the door can slide into this node while we're at it
		
		if test_node_def.paramtype2 == "facedir" then
			local test_node_dirs = get_dirs(test_node.param2)
			local coplanar = vector.equals(test_node_dirs.back, door.directions.back)

			if coplanar and (test_node_def.groups.big_door or test_node_def.groups.big_door_hinge) then
				local entry = {["pos"] = test_pos, ["node"] = test_node}
				table.insert(door.all, entry)
				if test_node_def.groups.big_door_hinge then
					table.insert(door.hinges, entry)
				end
				
				tested:set_pos(test_pos, true) -- since this is part of the door, other parts of the door can slide into it

				local test_directions = {"top", "bottom", "left", "right"}
				for _, dir in pairs(test_directions) do
					if test_node_def._gate_edges == nil or not test_node_def._gate_edges[dir] then
						local adjacent_pos = vector.add(test_pos, door.directions[dir])
						if tested:get_pos(adjacent_pos) == nil then
							local adjacent_node = minetest.get_node(adjacent_pos)
							local adjacent_def = minetest.registered_nodes[adjacent_node.name]
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
		door.can_slide = {up=true, down=true, left=true, right=true}
		for _,door_node in pairs(door.all) do
			minetest.debug(dump(door.can_slide))
			minetest.debug(dump(vector.add(door_node.pos, door.directions.top)))
			door.can_slide.up = door.can_slide.up and tested:get_pos(vector.add(door_node.pos, door.directions.top))
			door.can_slide.down = door.can_slide.down and tested:get_pos(vector.add(door_node.pos, door.directions.bottom))
			door.can_slide.left = door.can_slide.left and tested:get_pos(vector.add(door_node.pos, door.directions.left))
			door.can_slide.right = door.can_slide.right and tested:get_pos(vector.add(door_node.pos, door.directions.right))
		end
	end
	
	return door
end


local trigger_gate = function(pos, node, player, itemstack, pointed_thing)
	local door = get_door_layout(pos, node.param2, player)
	
	minetest.debug(dump(door))
	
	if door ~= nil then
		for _, door_node in pairs(door.all) do
			minetest.set_node(door_node.pos, {name="air"})
		end
		
		if table.getn(door.hinges) == 0 then
		
			if door.previous_move == "up" then
				
				
			elseif door.previous_move == "down" then
			elseif door.previous_move == "left" then
			elseif door.previous_move == "right" then
			end
			
		end

		for _, door_node in pairs(door.all) do
			minetest.set_node(door_node.pos, door_node.node)
			minetest.get_meta(door_node.pos):set_string("previous_move", nil) -- TODO: set this
		end
		
	end	
end


minetest.register_node("castle:gate_hinge", {
	drawtype = "nodebox",
	description = S("Gate Door With Hinge"),
	groups = {choppy = 1, big_door_hinge = 1},
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
	on_rightclick = trigger_gate,
})

minetest.register_node("castle:gate_panel", {
	drawtype = "nodebox",
	description = S("Gate Door"),
	groups = {choppy = 1, big_door = 1},
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
	on_rightclick = trigger_gate,
})

minetest.register_node("castle:gate_edge", {
	drawtype = "nodebox",
	description = S("Gate Door Edge"),
	groups = {choppy = 1, big_door = 1},
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
	on_rightclick = trigger_gate,
})

minetest.register_node("castle:gate_edge_handle", {
	drawtype = "nodebox",
	description = S("Gate Door With Handle"),
	groups = {choppy = 1, big_door = 1},
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
	on_rightclick = trigger_gate,
})
