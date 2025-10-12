
local inv_next_line_offset = moretools.adaptation.player_mod.next_line_offset_inv

table.insert(moretools.knife_actions, {
	action_on_use = function(action, user, pointed_thing)
		local inv = user:get_inventory()
		local item = inv:get_stack("main", user:get_wield_index()+inv_next_line_offset)
		local item_name = item:get_name()
		local item_def = core.registered_items[item_name]
		if core.get_item_group(item_name, "stick")>0 then
			item:take_item()
			inv:set_stack("main", user:get_wield_index()+inv_next_line_offset, item)
			local new_item = ItemStack("trapworks_parts:pole_wood")
			if inv:room_for_item("main", new_item) then
				inv:add_item("main", new_item)
			else
				core.item_drop(new_item, user, user:get_pos())
			end
			return 1.0
		end
		return false
	end,
})