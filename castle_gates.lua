-- internationalization boilerplate
local MP = minetest.get_modpath(minetest.get_current_modname())
local S, NS = dofile(MP.."/intllib.lua")

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
	groups = { cracky = 2, door = 1},
	sound_open = "doors_steel_door_open",
	sound_close = "doors_steel_door_close",
	recipe = {
		{"castle:jailbars", "castle:jailbars"},
		{"castle:jailbars", "castle:jailbars"},
		{"castle:jailbars", "castle:jailbars"},
	}
})

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
		groups = {cracky=1, pane=1},
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


local get_directions = function(facedir)
	local directions = {}
	local top = {[0]={x=0, y=1, z=0},
		{x=0, y=0, z=1},
		{x=0, y=0, z=-1},
		{x=1, y=0, z=0},
		{x=-1, y=0, z=0},
		{x=0, y=-1, z=0}}
	
	directions.back = minetest.facedir_to_dir(facedir)
	directions.top = top[math.floor(facedir/4)]
	directions.right = {
		x=directions.top.y*directions.back.z - directions.back.y*directions.top.z,
		y=directions.top.z*directions.back.x - directions.back.z*directions.top.x,
		z=directions.top.x*directions.back.y - directions.back.x*directions.top.y
	}
	directions.front = vector.multiply(directions.back, -1)
	directions.bottom = vector.multiply(directions.top, -1)
	directions.left = vector.multiply(directions.right, -1)
	return directions
end

local scan_for_portcullis = function(pos, dir)
	local scan_pos = vector.new(pos)

	local done = false
	local contains_protected = false -- TODO: check for this and return it
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

local get_row = function(pos, dir, output)
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


local move_portcullis = function(port, dir, up)
	minetest.debug("")
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

local lock_slot = function(pos)
	local meta = minetest.get_meta(pos)
	meta:set_string("locked", "true")
	local timer = minetest.get_node_timer(pos)
	timer:start(2)
end

local trigger_move = function(pos, node, direction)
	local directions = get_directions(node.param2)
	local all_slots = {}
	get_row(pos, directions.right, all_slots)
	get_row(pos, directions.left, all_slots)
	for _, slot in pairs(all_slots) do
		lock_slot(slot.pos)			
	end -- lock all of the connected slots other than this one
	
	table.insert(all_slots, {["pos"]=pos}) -- add this one to the table.
	
	local can_move_up = true
	local can_move_down = true
	
	for _, slot in pairs(all_slots) do
		local port_pos = vector.add(slot.pos, directions.back) -- the position adjacent to this slot that holds the portcullis
		local port_node = minetest.get_node(port_pos)
		
		if minetest.get_item_group(port_node.name, "portcullis") + minetest.get_item_group(port_node.name, "portcullis_edge") == 0 then
			--There's nothing in the slot
			can_move_up = false
			can_move_down = false
		else
			slot.above = scan_for_portcullis(port_pos, directions.top) -- this gets us the position one above the top portcullis node
			slot.below = scan_for_portcullis(port_pos, directions.bottom) -- this gets us the position one below the bottom portcullis node
			
			local node_above = minetest.get_node(slot.above).name
			local node_below = minetest.get_node(slot.below).name
							
			can_move_up = can_move_up and
				minetest.registered_nodes[node_above].buildable_to and
				node_above ~= "ignore" and
				not vector.equals(port_pos, vector.add(slot.below, directions.top))
			can_move_down = can_move_down and
				minetest.registered_nodes[node_below].buildable_to and
				node_below ~= "ignore" and
				not vector.equals(port_pos, vector.add(slot.above, directions.bottom))
		end		
	end
	
	if direction == "up" then
		if can_move_up then
			move_portcullis(all_slots, directions.top, true)
			minetest.get_node_timer(pos):start(1)
		else
			minetest.get_meta(pos):set_string("direction",  "down")
		end
	elseif direction == "down" then
		if can_move_down then
			move_portcullis(all_slots, directions.bottom, false)
			minetest.get_node_timer(pos):start(1)
		else
			minetest.get_meta(pos):set_string("direction", "up")
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
		if meta:get_string("locked") ~= "" then
			return
		end

		trigger_move(pos, node, meta:get_string("direction"))
	end,
	
	on_timer = function(pos, elapsed)
		local meta = minetest.get_meta(pos)
		if meta:get_string("locked") ~= "" then
			meta:set_string("locked", nil)
			return
		end
		
		trigger_move(pos, minetest.get_node(pos), meta:get_string("direction"))
	
	end,
})

minetest.register_node("castle:portcullis_bars", {
	drawtype = "nodebox",
	description = S("Portcullis Bars"),
	groups = {portcullis = 1, oddly_breakable_by_hand=1},
	tiles = {"default_steel_block.png"},
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

minetest.register_node("castle:portcullis_bar_bottom", {
	drawtype = "nodebox",
	description = S("Portcullis Bottom"),
	groups = {portcullis_edge = 1, oddly_breakable_by_hand=1},
	tiles = {"default_steel_block.png"},
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