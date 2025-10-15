
core.register_craft({
	output = "trapworks_spears:spear_wood",
	recipe = {
		{"", "", "group:wood"},
		{"", "group:stick", ""},
		{"group:stick", "", ""}
	}
})

core.register_craft({
	output = "trapworks_spears:spear_wood",
	recipe = {
		{"group:wood", "", ""},
		{"", "group:stick", ""},
		{"", "", "group:stick"}
	}
})

local inv_next_line_offset = moretools.adaptation.player_mod.next_line_offset_inv

local twigs_to_support = {
	["trunks:twig_2"] = true,
	["trunks:twig_3"] = true,
	["trunks:twig_10"] = true,
}

table.insert(moretools.knife_actions, {
	type = "node",
	action_on_use = function(action, user, pointed_thing)
		local node = core.get_node(pointed_thing.under)
		local inv = user:get_inventory()
		if twigs_to_support[node.name] then
			local new_item = ItemStack("trapworks_spears:spear_support")
			if inv:room_for_item("main", new_item) then
				inv:add_item("main", new_item)
			else
				core.item_drop(new_item, user, user:get_pos())
			end
			core.remove_node(pointed_thing.under)
			return 1.0
		end
		return false
	end,
})
