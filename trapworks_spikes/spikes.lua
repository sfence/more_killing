
local S = trapworks_spikes.translator

-- node box {x=0, y=0, z=0}
local node_box = {
	type = "fixed",
	fixed = {
		{-0.375,-0.5,-0.4375,-0.3125,-0.3125,-0.25},
		{0.3125,-0.5,-0.4375,0.375,-0.3125,-0.25},
		{-0.4375,-0.5,-0.375,-0.375,-0.3125,-0.3125},
		{-0.3125,-0.5,-0.375,-0.25,-0.3125,-0.3125},
		{0.25,-0.5,-0.375,0.3125,-0.3125,-0.3125},
		{0.375,-0.5,-0.375,0.4375,-0.3125,-0.3125},
		{-0.375,-0.3125,-0.375,-0.3125,-0.1875,-0.3125},
		{0.3125,-0.3125,-0.375,0.375,-0.1875,-0.3125},
		{0.0,-0.5,-0.3125,0.0625,-0.3125,-0.125},
		{-0.0625,-0.5,-0.25,0.0,-0.3125,-0.1875},
		{0.0625,-0.5,-0.25,0.125,-0.3125,-0.1875},
		{0.0,-0.3125,-0.25,0.0625,-0.1875,-0.1875},
		{-0.3125,-0.5,-0.125,-0.25,-0.3125,0.0625},
		{-0.375,-0.5,-0.0625,-0.3125,-0.3125,0.0},
		{-0.25,-0.5,-0.0625,-0.1875,-0.3125,0.0},
		{0.25,-0.5,-0.0625,0.3125,-0.3125,0.125},
		{-0.3125,-0.3125,-0.0625,-0.25,-0.1875,0.0},
		{-0.0625,-0.5,0.0,0.0,-0.3125,0.1875},
		{0.1875,-0.5,0.0,0.25,-0.3125,0.0625},
		{0.3125,-0.5,0.0,0.375,-0.3125,0.0625},
		{0.25,-0.3125,0.0,0.3125,-0.1875,0.0625},
		{-0.125,-0.5,0.0625,-0.0625,-0.3125,0.125},
		{0.0,-0.5,0.0625,0.0625,-0.3125,0.125},
		{-0.0625,-0.3125,0.0625,0.0,-0.1875,0.125},
		{-0.375,-0.5,0.25,-0.3125,-0.3125,0.4375},
		{0.0,-0.5,0.25,0.0625,-0.3125,0.4375},
		{0.3125,-0.5,0.25,0.375,-0.3125,0.4375},
		{-0.4375,-0.5,0.3125,-0.375,-0.3125,0.375},
		{-0.3125,-0.5,0.3125,-0.25,-0.3125,0.375},
		{-0.0625,-0.5,0.3125,0.0,-0.3125,0.375},
		{0.0625,-0.5,0.3125,0.125,-0.3125,0.375},
		{0.25,-0.5,0.3125,0.3125,-0.3125,0.375},
		{0.375,-0.5,0.3125,0.4375,-0.3125,0.375},
		{-0.375,-0.3125,0.3125,-0.3125,-0.1875,0.375},
		{0.0,-0.3125,0.3125,0.0625,-0.1875,0.375},
		{0.3125,-0.3125,0.3125,0.375,-0.1875,0.375},
	},
}
		
 -- fall_damage_add = 400, -- lovest value when some damage is dan to player if only go and fall one node to spikes without jumping

local spikes = {
	wood = {
		desc = S("Wooden"),
		mesh = "trapworks_spikes_spikes_fall.obj",
		tile = "default_tree_top.png",
		fall_damage_add = 400, 
		move_resistance = 2,
		spike = false,
	},
	stone = {
		desc = S("Stone"),
		mesh = "trapworks_spikes_spikes_fall_with_spikes.obj",
		tiles = {"default_tree.png", "default_stone.png"},
		fall_damage_add = 450, 
		move_resistance = 3,
		spike = true,
		body_mat = "group:stone",
	},
	copper = {
		desc = S("Copper"),
		mesh = "trapworks_spikes_spikes_fall_with_spikes.obj",
		tiles = {"default_tree.png", "default_copper_block.png"},
		fall_damage_add = 500, 
		move_resistance = 3,
		spike = true,
		body_mat = "default:copper_ingot",
	},
	bronze = {
		desc = S("Bronze"),
		mesh = "trapworks_spikes_spikes_fall_with_spikes.obj",
		tiles = {"default_tree.png", "default_bronze_block.png"},
		fall_damage_add = 550, 
		move_resistance = 3,
		spike = true,
		body_mat = "default:bronze_ingot",
	},
	steel = {
		desc = S("Steel"),
		mesh = "trapworks_spikes_spikes_fall_with_spikes.obj",
		tiles = {"default_tree.png", "default_steel_block.png"},
		fall_damage_add = 650, 
		move_resistance = 3,
		spike = true,
		body_mat = "default:steel_ingot",
	},
	diamond = {
		desc = S("Diamond"),
		mesh = "trapworks_spikes_spikes_fall_with_spikes.obj",
		tiles = {"default_tree.png", "default_diamond_block.png"},
		fall_damage_add = 700, 
		move_resistance = 3,
		spike = true,
		body_mat = "default:diamond",
	},
	obsidian = {
		desc = S("Obsidian"),
		mesh = "trapworks_spikes_spikes_fall_with_spikes.obj",
		tiles = {"default_tree.png", "default_obsidian.png"},
		fall_damage_add = 700, 
		move_resistance = 3,
		spike = true,
		body_mat = "default:obsidian_shard",
	},
}
if core.get_modpath("pigiron") then
	spikes.iron = {
		desc = S("Iron"),
		mesh = "trapworks_spikes_spikes_fall_with_spikes.obj",
		tiles = {"default_tree.png", "pigiron_iron_block.png"},
		fall_damage_add = 600, 
		move_resistance = 3,
		spike = true,
		body_mat = "pigiron:iron_ingot",
	}
end

local spikes_hammer_build_nodes = {}

for key, data in pairs(spikes) do
	local drop = ""
	if data.spike then
		drop = {
			max_items = 1,
			items = {
				{
					items = {"trapworks_spikes:spike_"..key.." 9"},
					rarity = 1,
				},
			},
		}
	end
	core.register_node("trapworks_spikes:spikes_fall_"..key, {
		description = S("@1 Trap Spikes", data.desc),
		drawtype = "mesh",
		mesh = data.mesh,
		selection_box = node_box,
		collision_box = node_box,
		tiles = data.tiles or {"default_tree.png", data.tile},
		use_texture_alpha = "opaque",
		groups = {choppy = 3, fall_damage_add_percent = data.fall_damage_add},
		paramtype = "light",
		--move_resistance = data.move_resistance,
		liquid_viscosity = data.move_resistance,
		walkable = true,

		node_placement_prediction = "", -- disable prediction
		on_place = function(itemstack, placer, pointed_thing)
			return nil
		end,

		drop = drop,
		node_dig_prediction = spikes and "trapworks_spikes:spikes_fall_poles" or "air", -- when dig with empty hand, show poles
		node_after_dig = function(pos)
			if spikes then
				core.set_node(pos, {name="trapworks_spikes:spikes_fall_poles"})
			else
				core.set_node(pos, {name="air"})
			end
		end,
	})
	if data.spike then
		core.register_craftitem("trapworks_spikes:spike_"..key, {
			description = S("@1 Trap Spike", data.desc),
			inventory_image = "trapworks_spikes_spike_"..key..".png",
		})

		core.register_craft({
			output = "trapworks_spikes:spike_"..key.." 3",
			recipe = {
				{"", data.body_mat, ""},
				{data.body_mat, "", data.body_mat},
			}
		})

		spikes_hammer_build_nodes["trapworks_spikes:spike_"..key] = {
			trap_node = "trapworks_spikes:spikes_fall_"..key,
		}
	end
end

-- node box {x=0, y=0, z=0}
local node_box_poles = {
	type = "fixed",
	fixed = {
		{-0.375,-0.5,-0.4375,-0.3125,-0.125,-0.25},
		{0.3125,-0.5,-0.4375,0.375,-0.125,-0.25},
		{-0.4375,-0.5,-0.375,-0.375,-0.125,-0.3125},
		{-0.3125,-0.5,-0.375,-0.25,-0.125,-0.3125},
		{0.25,-0.5,-0.375,0.3125,-0.125,-0.3125},
		{0.375,-0.5,-0.375,0.4375,-0.125,-0.3125},
		{0.0,-0.5,-0.3125,0.0625,-0.125,-0.125},
		{-0.0625,-0.5,-0.25,0.0,-0.125,-0.1875},
		{0.0625,-0.5,-0.25,0.125,-0.125,-0.1875},
		{-0.3125,-0.5,-0.125,-0.25,-0.125,0.0625},
		{-0.375,-0.5,-0.0625,-0.3125,-0.125,0.0},
		{-0.25,-0.5,-0.0625,-0.1875,-0.125,0.0},
		{0.25,-0.5,-0.0625,0.3125,-0.125,0.125},
		{-0.0625,-0.5,0.0,0.0,-0.125,0.1875},
		{0.1875,-0.5,0.0,0.25,-0.125,0.0625},
		{0.3125,-0.5,0.0,0.375,-0.125,0.0625},
		{-0.125,-0.5,0.0625,-0.0625,-0.125,0.125},
		{0.0,-0.5,0.0625,0.0625,-0.125,0.125},
		{-0.375,-0.5,0.25,-0.3125,-0.125,0.4375},
		{0.0,-0.5,0.25,0.0625,-0.125,0.4375},
		{0.3125,-0.5,0.25,0.375,-0.125,0.4375},
		{-0.4375,-0.5,0.3125,-0.375,-0.125,0.375},
		{-0.3125,-0.5,0.3125,-0.25,-0.125,0.375},
		{-0.0625,-0.5,0.3125,0.0,-0.125,0.375},
		{0.0625,-0.5,0.3125,0.125,-0.125,0.375},
		{0.25,-0.5,0.3125,0.3125,-0.125,0.375},
		{0.375,-0.5,0.3125,0.4375,-0.125,0.375},
	},
}

core.register_node("trapworks_spikes:spikes_fall_poles", {
	description = "Spikes trap poles",
	drawtype = "nodebox",
	node_box = node_box_poles,
	selection_box = node_box_poles,
	collision_box = node_box_poles,
	tiles = {"trapworks_spikes_spikes_fall_poles.png", "default_tree.png"},
	use_texture_alpha = "opaque",
	groups = {choppy = 3, fall_damage_add_percent = 25},
	paramtype = "light",
	move_resistance = 2,
	walkable = true,

	drop = {
		max_items = 1,
		items = {
			{
				items = {"trapworks_parts:pole_wood 9"},
				rarity = 1,
			},
		}
	},

	node_placement_prediction = "", -- disable prediction
	on_place = function(itemstack, placer, pointed_thing)
		return nil
	end,
})

local inv_next_line_offset = moretools.adaptation.player_mod.next_line_offset_inv

table.insert(moretools.hammer_actions, {
	type = "node",
	action_on_use = function(action, user, pointed_thing)
		if core.is_protected(pointed_thing.under, user:get_player_name()) then
			--print("Position is protected")
			return false
		end

		local node_under = core.get_node(pointed_thing.under)
		if node_under.name ~= "trapworks_spikes:spikes_fall_poles" then
			--print("Node is not trapworks_spikes:spikes_fall_poles")
			return false
		end

		local inv = user:get_inventory()
		local item = inv:get_stack("main", user:get_wield_index()+inv_next_line_offset)
		local item_name = item:get_name()
		local item_count = item:get_count()
		--print("Item name: "..item_name)
		local spike_data = spikes_hammer_build_nodes[item_name]
		if spike_data and (item_count >= 9) then
			if core.is_creative_enabled(user:get_player_name()) then
				-- do nothing
			else
				item:take_item(9)
				inv:set_stack("main", user:get_wield_index()+inv_next_line_offset, item)
			end
			core.set_node(pointed_thing.under, {name=spike_data.trap_node})
			return 1.0
		end
		return false
	end,
})
