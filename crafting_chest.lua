castle = {}

minetest.register_node("castle:craftchest",{
		description = "Crafting Chest",
		tiles = {"castle_craftchest.png", "castle_craftchest_2.png"},
		paramtype = "light",
		paramtype2 = "facedir",
		sunlight_propagates = true,
		is_ground_content = false,
		groups = {	snappy	=	2,	choppy	=	2,	oddly_breakable_by_hand	=	2	},
	on_construct = function ( pos )
        local meta = minetest.get_meta( pos )
		meta:set_string( "formspec",
				"size[9,9.5]"..
				default.gui_bg..
				default.gui_bg_img..
				default.gui_slots..
				"label[0.7,0.3;Input:]"..
				"list[context;src;0.5,1;2,4;]"..
				"label[3,0.75;Crafting Recipe]"..
				"list[context;rec;3,1.75;3,3;]"..
				"label[6.7,0.3;Output:]"..
				"list[context;dst;6.5,1;2,4;]"..
				"list[current_player;main;0.5,5.5;8,4;]"..
				"listring[current_player;main]" ..
				"listring[context;src]" ..
				"listring[context;rec]" ..
				"listring[current_player;main]" ..
				"listring[context;dst]" ..
				"listring[current_player;main]")
		meta:set_string( "infotext", "Crafting Chest" )
				local inv = meta:get_inventory()
				inv:set_size( "src", 2 * 4 )
				inv:set_size( "rec", 3 * 3 )
				inv:set_size( "dst", 2 * 4 )
    end,
		can_dig = function(pos,player)
				local meta = minetest.get_meta(pos);
				local inv = meta:get_inventory()
				return inv:is_empty("src") and inv:is_empty("rec") and inv:is_empty("dst")
		end,
	on_metadata_inventory_move = function(pos, from_list, from_index, to_list, to_index, count, player)
		minetest.log("action", player:get_player_name()..
				" moves stuff in crafting chest at "..minetest.pos_to_string(pos))
	end,
    on_metadata_inventory_put = function(pos, listname, index, stack, player)
		minetest.log("action", player:get_player_name()..
				" moves stuff to crafting chest at "..minetest.pos_to_string(pos))
	end,
    on_metadata_inventory_take = function(pos, listname, index, stack, player)
		minetest.log("action", player:get_player_name()..
				" takes stuff from crafting chest at "..minetest.pos_to_string(pos))
	end,
})
local get_recipe = function ( inv )
	local result, needed, input
	needed = inv:get_list( "rec" )

	result, input = minetest.get_craft_result( {
		method = "normal",
		width = 3,
		items = needed
	} )

	local totalneed = {}

	if result.item:is_empty() then
		result = nil
	else
		result = result.item
		for _, item in ipairs( needed ) do
			if item ~= nil and not item:is_empty() and not inv:contains_item( "src", item ) then
				result = nil
				break
			end
			if item ~= nil and not item:is_empty() then
				if totalneed[item:get_name()] == nil then
					totalneed[item:get_name()] = 1
				else
					totalneed[item:get_name()] = totalneed[item:get_name()] + 1
				end
			end
		end
		for name, number in pairs( totalneed ) do
			local totallist = inv:get_list( "src" )
			for i, srcitem in pairs( totallist ) do
				if srcitem:get_name() == name then
					local taken = srcitem:take_item( number )
					number = number - taken:get_count()
					totallist[i] = srcitem
				end
				if number <= 0 then
					break
				end
			end
			if number > 0 then
				result = nil
				break
			end
		end
	end

	return needed, input, result
end

minetest.register_abm( {
	nodenames = { "castle:craftchest" },
	interval = 1,
	chance = 1,
	action = function ( pos, node )
		local meta = minetest.get_meta( pos )
		local inv = meta:get_inventory()
		local cresult, newinput, needed
		if not inv:is_empty( "src" ) then
			-- Check for a valid recipe and sufficient resources to craft it
			needed, newinput, result = get_recipe( inv )
			if result ~= nil and inv:room_for_item( "dst", result ) then
				inv:add_item( "dst", result )
				for i, item in pairs( needed ) do
					if item ~= nil and item ~= "" then
						inv:remove_item( "src", ItemStack( item ) )
					end
					if newinput[i] ~= nil and not newinput[i]:is_empty() then
						inv:add_item( "src", newinput[i] )
					end
				end
			end
		end
	end
} )

local function has_locked_chest_privilege(meta, player)
	if player:get_player_name() ~= meta:get_string("owner") then
		return false
	end
	return true
end

minetest.register_craft({
	output = "castle:craftchest",
	recipe = {
		{"default:diamond", "default:mese_crystal", "default:diamond"},
		{"default:obsidian_shard", "default:chest", "default:obsidian_shard"},
		{"default:diamond", "default:mese_crystal", "default:diamond"},
	}
})