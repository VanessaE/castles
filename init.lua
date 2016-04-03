--dofile(minetest.get_modpath("castle").."/arrow.lua")
--dofile(minetest.get_modpath("castle").."/arrowslit.lua")
dofile(minetest.get_modpath("castle").."/crafting_chest.lua")
--dofile(minetest.get_modpath("castle").."/crossbow.lua")
--dofile(minetest.get_modpath("castle").."/murder_hole.lua")
dofile(minetest.get_modpath("castle").."/orbs.lua")
--dofile(minetest.get_modpath("castle").."/pillars.lua")
dofile(minetest.get_modpath("castle").."/rope.lua")
dofile(minetest.get_modpath("castle").."/shields_decor.lua")
--dofile(minetest.get_modpath("castle").."/tapestry.lua")
dofile(minetest.get_modpath("castle").."/town_item.lua")

----------
--Aliases
----------

minetest.register_alias("castle:light", "castle:street_light")
minetest.register_alias("castle:pavement", "castle:pavement_brick")
minetest.register_alias("castle:straw", "farming:straw")
minetest.register_alias("castle:workbench", "castle:craftchest")
minetest.register_alias("cottages:straw", "farming:straw")
minetest.register_alias("cottages:straw_bale", "castle:bound_straw")
minetest.register_alias("darkage:box", "castle:crate")
minetest.register_alias("darkage:straw", "farming:straw")
minetest.register_alias("darkage:straw_bale", "castle:bound_straw")

----------------------
--Node Registration
----------------------

minetest.register_node("castle:bound_straw", {
  description = "Bound Straw",
  tiles = {"castle_straw_bale.png"},
  paramtype = "light",
  sunlight_propagates = true,
  is_ground_content = false,
  groups = { snappy = 3 , flammable = 3, oddly_breakable_by_hand = 2 },
  sounds = default.node_sound_leaves_defaults(),
})

minetest.register_node("castle:dungeon_stone", {
  description = "Dungeon Stone",
  tiles = {"castle_dungeon_stone.png"},
  paramtype = "light",
  sunlight_propagates = false,
  is_ground_content = false,
  groups = { cracky=1, level = 2 },
  sounds = default.node_sound_stone_defaults(),
})

minetest.register_node("castle:pavement_brick", {
  description = "Paving Stone",
  tiles = {"castle_pavement_brick.png"},
  paramtype = "light",
  sunlight_propagates = true,
  is_ground_content = false,
  groups = { cracky=1 },
  sounds = default.node_sound_stone_defaults(),
})

minetest.register_node("castle:roofslate", {
  drawtype = "raillike",
  description = "Roof Slates",
  inventory_image = "castle_slate.png",
  tiles = {'castle_slate.png'},
  paramtype = "light",
  sunlight_propagates = true,
  is_ground_content = false,
  walkable = false,
  climbable = true,
  selection_box = {
    type = "fixed",
     fixed = {-1/2, -1/2, -1/2, 1/2, -1/2+1/16, 1/2},
    },
  groups = { cracky = 3, attached_node = 1 },
  sounds = default.node_sound_stone_defaults(),
})

minetest.register_node("castle:rubble", {
  description = "Castle Rubble",
  tiles = {"castle_rubble.png"},
  paramtype = "light",
  sunlight_propagates = true,
  is_ground_content = false,
  groups = { crumbly = 2, falling_node = 1 },
  sounds = default.node_sound_leaves_defaults(),
})

minetest.register_node("castle:stonewall", {
  description = "Castle Wall",
  tiles = {"castle_stonewall.png"},
  paramtype = "light",
  sunlight_propagates = true,
  is_ground_content = false,
  groups = { cracky = 2 },
  sounds = default.node_sound_stone_defaults(),
})

minetest.register_node("castle:stonewall_corner", {
  description = "Castle Corner",
  tiles = {
    "castle_stonewall.png",
    "castle_stonewall.png",
    "castle_corner_stonewall1.png",
    "castle_stonewall.png",
    "castle_stonewall.png",
    "castle_corner_stonewall2.png"
   },
  paramtype = "light",
  paramtype2 = "facedir",
  sunlight_propagates = true,
  is_ground_content = false,
  groups = {	cracky	=	2	},
  sounds = default.node_sound_stone_defaults(),
})

--Moreblocks mod support
if minetest.get_modpath("moreblocks") then

stairsplus:register_all("castle", "dungeon_stone", "castle:dungeon_stone", {
  description = "Dungeon Stone",
  tiles = {"castle_dungeon_stone.png"},
  paramtype = "light",
  sunlight_propagates = false,
  is_ground_content = false,
  groups = { cracky=1, level = 2, not_in_creative_inventory = 1 },
  sounds = default.node_sound_stone_defaults(),
})

stairsplus:register_all("castle", "pavement_brick", "castle:pavement_brick", {
  description = "Pavement Brick",
  tiles = {"castle_pavement_brick.png"},
  paramtype = "light",
  sunlight_propagates = true,
  is_ground_content = false,
  groups = { cracky=1, not_in_creative_inventory = 1 },
  sounds = default.node_sound_stone_defaults(),
})

stairsplus:register_all("castle", "stonewall", "castle:stonewall", {
  description = "Stone Wall",
  tiles = {"castle_stonewall.png"},
  paramtype = "light",
  sunlight_propagates = true,
  is_ground_content = false,
  groups = { cracky = 2, not_in_creative_inventory = 1 },
  sounds = default.node_sound_stone_defaults(),
})

stairsplus:register_all("castle", "rubble", "castle:rubble", {
  description = "Rubble",
  tiles = {"castle_rubble.png"},
  paramtype = "light",
  sunlight_propagates = true,
  is_ground_content = false,
  groups = { crumbly = 2, falling_node = 1, not_in_creative_inventory = 1 },
  sounds = default.node_sound_stone_defaults(),
})
end

--Stairs mod support
stairs.register_stair_and_slab("dungeon_stone", "castle:dungeon_stone",
  {	cracky	=	1, level = 2	},
  {"castle_dungeon_stone.png"},
  "Dungeon Stone Stair",
  "Dungeon Stone Slab",
  default.node_sound_stone_defaults())

stairs.register_stair_and_slab("castle_pavement_brick", "castle:pavement_brick",
  {	cracky	=	1	},
  {"castle_pavement_brick.png"},
  "Bricked Pavement Stair",
  "Bricked Pavement Slab",
  default.node_sound_stone_defaults())

stairs.register_stair_and_slab("stonewall", "castle:stonewall",
  {	cracky	=	2	},
  {"castle_stonewall.png"},
  "Castle Stone Stair",
  "Castle Stone Slab",
  default.node_sound_stone_defaults())

-----------
--Crafting
-----------

local mod_building_blocks = minetest.get_modpath("building_blocks")
local mod_streets = minetest.get_modpath("streets") or minetest.get_modpath("asphalt")

if mod_building_blocks then
minetest.register_craft( {
  output = "castle:roofslate 4",
  recipe = {
    { "building_blocks:Tar" , "default:gravel" },
    { "default:gravel", "building_blocks:Tar" }
  }
})

minetest.register_craft( {
  output = "castle:roofslate 4",
  recipe = {
    { "default:gravel", "building_blocks:Tar" },
    { "building_blocks:Tar" , "default:gravel" }
  }
})
end

if mod_streets then
minetest.register_craft( {
  output = "castle:roofslate 4",
  recipe = {
    { "streets:asphalt" , "default:gravel" },
    { "default:gravel", "streets:asphalt" }
   }
})

minetest.register_craft( {
  output = "castle:roofslate 4",
  recipe = {
    { "default:gravel", "streets:asphalt" },
    { "streets:asphalt" , "default:gravel" }
  }
})
end

if not (mod_building_blocks or mod_streets) then
minetest.register_craft({
  type = "cooking",
  output = "castle:roofslate",
  recipe = "default:gravel",
})

end

minetest.register_craft({
  output = "castle:bound_straw",
  recipe = {
    {"castle:straw", "castle:ropes"},
  }
})

minetest.register_craft({
  output = "castle:dungeon_stone",
  recipe = {
    {"default:stonebrick", "default:obsidian"},
  }
})

minetest.register_craft({
  output = "castle:dungeon_stone",
  recipe = {
    {"default:stonebrick"},
    {"default:obsidian"},
  }
})

minetest.register_craft({
  output = "castle:pavement 4",
  recipe = {
    {"default:stone", "default:cobble"},
    {"default:cobble", "default:stone"},
  }
})

minetest.register_craft({
  output = "castle:rubble",
  recipe = {
    {"castle:stonewall"},
  }
})

minetest.register_craft({
  output = "castle:rubble 2",
  recipe = {
    {"default:gravel"},
    {"default:desert_stone"},
  }
})

minetest.register_craft({
  output = "castle:stonewall",
  recipe = {
    {"default:cobble"},
    {"default:desert_stone"},
  }
})

minetest.register_craft({
  output = "castle:stonewall_corner",
  recipe = {
    {"", "castle:stonewall"},
    {"castle:stonewall", "default:sandstone"},
  }
})

--stairs crafting
minetest.register_craft({
  output = "castle:stairs 4",
  recipe = {
    {"castle:stonewall","",""},
    {"castle:stonewall","castle:stonewall",""},
    {"castle:stonewall","castle:stonewall","castle:stonewall"},
  }
})

minetest.register_craft({
  output = "stairs:stair_stonewall 4",
  recipe = {
    {"","","castle:stonewall"},
    {"","castle:stonewall","castle:stonewall"},
    {"castle:stonewall","castle:stonewall","castle:stonewall"},
  }
})

minetest.register_craft({
  output = "stairs:slab_stonewall 6",
  recipe = {
    {"castle:stonewall","castle:stonewall","castle:stonewall"},
  }
})

minetest.register_craft({
  output = "stairs:slab_dungeon_stone 6",
  recipe = {
    {"castle:dungeon_stone","castle:dungeon_stone","castle:dungeon_stone"},
  }
})

minetest.register_craft({
  output = "stairs:slab_pavement_brick 6",
  recipe = {
    {"castle:pavement_brick","castle:pavement_brick","castle:pavement_brick"},
  }
})

minetest.register_craft({
  output = "stairs:stair_dungeon_stone 4",
  recipe = {
    {"","","castle:dungeon_stone"},
    {"","castle:dungeon_stone","castle:dungeon_stone"},
    {"castle:dungeon_stone","castle:dungeon_stone","castle:dungeon_stone"},
  }
})

minetest.register_craft({
  output = "stairs:stair_pavement_brick 4",
  recipe = {
    {"","","castle:pavement_brick"},
    {"","castle:pavement_brick","castle:pavement_brick"},
    {"castle:pavement_brick","castle:pavement_brick","castle:pavement_brick"},
  }
})
