-- internationalization boilerplate
local MP = minetest.get_modpath(minetest.get_current_modname())
local S, NS = dofile(MP.."/intllib.lua")

minetest.register_tool("castle:orb_day", {
	description = S("Orb of Midday"),
	tiles = {"castle_orb_day.png"},
	inventory_image = "castle_orb_day.png",
	wield_image = "castle_orb_day_weild.png",
	stack_max=1,
	on_use = function(itemstack, user)
   minetest.sound_play("castle_orbs", {pos=pos, loop=false})
			minetest.set_timeofday(0.5)
			minetest.sound_play("castle_birds", {pos=pos, loop=false})
			itemstack:add_wear(65535/8)
			return itemstack
	end
})

minetest.register_tool("castle:orb_night",{
 description = S("Orb of Midnight"),
	tiles = {"castle_orb_night.png"},
	inventory_image = "castle_orb_night.png",
	wield_image = "castle_orb_night_weild.png",
	stack_max=1,
	on_use = function(itemstack, user)
   minetest.sound_play("castle_orbs", {pos=pos, loop=false})
			minetest.set_timeofday(0)
			minetest.sound_play("castle_owl", {pos=pos, loop=false})
			itemstack:add_wear(65535/8)
			return itemstack
	end
})


minetest.register_tool("castle:orb_dawn", {
	description = S("Orb of Dawn"),
	tiles = {"castle_orb_day.png"},
	inventory_image = "castle_orb_day.png^[lowpart:50:castle_orb_night.png",
	wield_image = "castle_orb_day_weild.png^[lowpart:75:castle_orb_night_weild.png",
	stack_max=1,
	on_use = function(itemstack, user)
   minetest.sound_play("castle_orbs", {pos=pos, loop=false})
			minetest.set_timeofday(0.2)
			minetest.sound_play("castle_birds", {pos=pos, loop=false})
			itemstack:add_wear(65535/8)
			return itemstack
	end
})

minetest.register_tool("castle:orb_dusk",{
	description = S("Orb of Dusk"),
	tiles = {"castle_orb_night.png"},
	inventory_image = "castle_orb_night.png^[lowpart:50:castle_orb_day.png",
	wield_image = "castle_orb_night_weild.png^[lowpart:75:castle_orb_day_weild.png",
	stack_max=1,
	on_use = function(itemstack, user)
		minetest.sound_play("castle_orbs", {pos=pos, loop=false})
		minetest.set_timeofday(0.8)
		minetest.sound_play("castle_owl", {pos=pos, loop=false})
		itemstack:add_wear(65535/8)
		return itemstack
	end
})

-----------
--Crafting
-----------

minetest.register_craft( {
  output = "castle:orb_day",
  recipe = {
    {"default:diamond", "default:diamond","default:diamond"},
    {"default:diamond", "default:mese_crystal","default:diamond"},
    {"default:diamond", "default:diamond","default:diamond"}
   },
})

minetest.register_craft({
  output = "castle:orb_night",
  recipe = {
   {"default:diamond", "default:diamond","default:diamond"},
   {"default:diamond", "default:obsidian_shard","default:diamond"},
   {"default:diamond", "default:diamond","default:diamond"}
  },
})

minetest.register_craft({
  output = "castle:orb_dawn 2",
  recipe = {
   {"castle:orb_day"},
   {"castle:orb_night"},
  },
})

minetest.register_craft({
  output = "castle:orb_dusk 2",
  recipe = {
   {"castle:orb_night"},
   {"castle:orb_day"},
  },
})

if minetest.get_modpath("loot") then
	loot.register_loot({
		weights = { generic = 10, valuable= 10 },
		payload = {
			stack = ItemStack("castle:orb_day"),
			min_size = 1,
			max_size = 1,
		},
	})

	loot.register_loot({
		weights = { generic = 10, valuable= 10 },
		payload = {
			stack = ItemStack("castle:orb_night"),
			min_size = 1,
			max_size = 1,
		},
	})

	loot.register_loot({
		weights = { generic = 10, valuable= 10 },
		payload = {
			stack = ItemStack("castle:orb_dawn"),
			min_size = 1,
			max_size = 1,
		},
	})

	loot.register_loot({
		weights = { generic = 10, valuable= 10 },
		payload = {
			stack = ItemStack("castle:orb_dusk"),
			min_size = 1,
			max_size = 1,
		},
	})

end