
local inv_next_line_offset = moretools.adaptation.player_mod.next_line_offset_inv

table.insert(moretools.hammer_actions, {
	type = "node",
	action_on_use = function(action, user, pointed_thing)
		if core.is_protected(pointed_thing.under, user:get_player_name()) then
			--print("Position is protected")
			return false
		end

		local node_under = core.get_node(pointed_thing.under)

		if (node_under.name == "trapworks_strings:poles_l2") then
			core.set_node(pointed_thing.under, {name="trapworks_strings:poles_l1"})
			return 1.0
		end
		if (node_under.name == "trapworks_strings:poles_l1") then
			core.set_node(pointed_thing.under, {name="trapworks_strings:poles_ground"})
			return 1.0
		end
		return false
	end,
})

print("Add string trap poles hammer action")
table.insert(moretools.hammer_actions, {
	type = "node",
	action_on_use = function(action, user, pointed_thing)
		print("try place string trap poles")
		local node_under = core.get_node(pointed_thing.under)
		local crumbly = core.get_item_group(node_under.name, "crumbly")
		if crumbly == 0 then
			--print("Node is not crumbly")
			return false
		end
		local node_above = core.get_node(pointed_thing.above)
		local def_above = core.registered_nodes[node_above.name]
		if not def_above or not def_above.buildable_to then
			--print("Node above is not buildable_to")
			return false
		end

		if core.is_protected(pointed_thing.above, user:get_player_name()) then
			--print("Position is protected")
			return false
		end

		local inv = user:get_inventory()
		local item = inv:get_stack("main", user:get_wield_index()+inv_next_line_offset)
		local item_name = item:get_name()
		local item_count = item:get_count()
		--print("Item name: "..item_name)
		if (item_name == "trapworks_parts:pole_wood") and (item_count >= 4) then
			if core.is_creative_enabled(user:get_player_name()) then
				-- do nothing
			else
				item:take_item(4)
				inv:set_stack("main", user:get_wield_index()+inv_next_line_offset, item)
			end
			if core.get_item_group(node_under.name, "sand") > 0 then
				core.set_node(pointed_thing.above, {name="trapworks_strings:poles_l1"})
			else
				core.set_node(pointed_thing.above, {name="trapworks_strings:poles_l2"})
			end
			return 1.0
		end
		return false
	end,
})