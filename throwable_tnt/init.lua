
local tnt_stick_timeout = 5 -- seconds

local game_time = 0
local last_gametime_sec = core.get_gametime()

local function tnt_stick_boom(pos)
	core.sound_play("tnt_explode", {pos=pos, gain=1.0, max_hear_distance=16,})
	tnt.boom(pos, {damage_radius=2, radius=2, ignore_protection=false,})
end

core.register_globalstep(function(dtime)
	game_time = game_time + dtime
	local new_gametime_sec = core.get_gametime()
	if last_gametime_sec ~= new_gametime_sec then
		for _, player in ipairs(core.get_connected_players()) do
			-- find burning tnt stick in inventory
			-- check timer
			-- remove and explode if timer is up
			local inv = player:get_inventory()
			if inv:contains_item("main", "throwable_tnt:tnt_stick_burning") then
				for i = 1, inv:get_size("main") do
					local item = inv:get_stack("main", i)
					if item:get_name() == "throwable_tnt:tnt_stick_burning" then
						local meta = item:get_meta()
						local gametime = meta:get_float("gametime")
						local timer = tnt_stick_timeout - (new_gametime_sec - gametime)
						if timer <= 0 then
							-- remove item
							inv:set_stack("main", i, nil)
							-- explode
							local pos = player:get_pos()
							pos.y = pos.y + 1.5
							tnt_stick_boom(pos)
						end
					end
				end
			end
		end

		last_gametime_sec = new_gametime_sec
	end
end)

core.register_entity("throwable_tnt:tnt_stick_burning", {
	initial_properties = {
		hp_max = 1,
		physical = true,
		collide_with_objects = true,
		collisionbox = {-0.3, -0.3, -0.3, 0.3, 0.3, 0.3},
		visual = "sprite",
		visual_size = {x = 0.4, y = 0.4},
		--textures = {{name = "throwable_tnt_tnt_stick_burning_animate.png", type = "vertical_frames", aspect_w = 16, aspect_h = 16, length = 0.3}},
		textures = {"throwable_tnt_tnt_stick_burning.png"},
		glow = 10,
	},

	on_activate = function(self, staticdata, dtime_s)
		self.object:set_armor_groups({immortal=1})
		if staticdata then
			self.timer = tonumber(staticdata) or tnt_stick_timeout
		else
			self.timer = tnt_stick_timeout
		end
	end,
	get_staticdata = function(self)
		return tostring(self.timer)
	end,
	
	on_step = function(self, dtime, moveresult)
		local pos = self.object:get_pos()
		local node = core.get_node(pos)
		self.timer = self.timer - dtime
		if self.timer <= 0 then
			self.object:remove()
			tnt_stick_boom(pos)
			return
		end

		if not moveresult then
			return
		end

		local vel = self.object:get_velocity()

		-- apply velocity decrease on reflection
		for _, collision in pairs(moveresult.collisions or {}) do
			vel[collision.axis] = vel[collision.axis] * 0.6
		end

		-- aerodynamic deceleration
		-- calculated from aerodynamic force, based on v^2
		local speed = vector.length(vel)
		print("Speed: "..speed)
		if moveresult.touching_ground or moveresult.standing_on_object then
			speed = math.max(0, speed - 10 * dtime)
		end
		local drag = 0.25 * 0.5 * speed * speed
		speed = math.max(0, speed - drag * dtime)
		vel = vector.normalize(vel)
		vel = vector.multiply(vel, speed)
		self.object:set_velocity(vel)

		print("Timer: "..self.timer.." Speed: "..speed)
		--print("Timer: "..self.timer.." Speed: "..speed.." move_result: "..dump(moveresult))
	end,
})

core.register_craftitem("throwable_tnt:tnt_stick_burning", {
	description = "TNT Burning Stick",
	inventory_image = "throwable_tnt_tnt_stick_burning.png",
	stack_max = 1,

	-- throw TNT burning stick
	on_use = function(itemstack, user, pointed_thing)
		local pos = user:get_pos()
		local dir = user:get_look_dir()
		pos.y = pos.y + 1.5
		vector.add(pos, dir)
		local obj = core.add_entity(pos, "throwable_tnt:tnt_stick_burning")
		if obj then
			local ent = obj:get_luaentity()
			local meta = itemstack:get_meta()
			ent.timer = tnt_stick_timeout - (core.get_gametime() - meta:get_float("gametime"))
			obj:set_velocity({x=dir.x * 15, y=dir.y * 15, z=dir.z * 15})
			obj:set_acceleration({x=dir.x * -2, y=-10, z=dir.z * -2})
			itemstack:take_item()
		end
		return itemstack
	end,
	on_drop = function(itemstack, dropper, pos)
		local dir = dropper:get_look_dir()
		pos.y = pos.y + 1.5
		vector.add(pos, dir)
		local obj = core.add_entity(pos, "throwable_tnt:tnt_stick_burning")
		if obj then
			local ent = obj:get_luaentity()
			local meta = itemstack:get_meta()
			ent.timer = tnt_stick_timeout - (core.get_gametime() - meta:get_float("gametime"))
			obj:set_velocity(vector.new(dir.x * 0.5, dir.y * 0.5, dir.z * 0.5))
			obj:set_acceleration({x=0, y=-10, z=0})
			itemstack:take_item()
		end
		return itemstack
	end,
})

local tnt_stick_flaming_nodes = {
	["default:torch"] = true,
}

core.override_item("tnt:tnt_stick", {
	on_use = function(itemstack, user, pointed_thing)
		--[[
		 if pointed to fire node, remove one tnt stick, 
		 replace all items in stack by burning tnt stick,
		 and move leftover stick to different stack position or drop them,
		 if there is no room in inventory
		]]
		if pointed_thing.type == "node" then
			local node = core.get_node(pointed_thing.under)
			if (core.get_item_group(node.name, "fire") > 0) or tnt_stick_flaming_nodes[node.name] then
				local inv = user:get_inventory()
				local wield_index = user:get_wield_index()
				itemstack:take_item(1)
				local burning_stick = ItemStack("throwable_tnt:tnt_stick_burning")
				local meta = burning_stick:get_meta()
				meta:set_float("gametime", core.get_gametime())
				inv:set_stack("main", wield_index, burning_stick)
				if itemstack:get_count() > 0 then
					if inv:room_for_item("main", itemstack) then
						inv:add_item("main", itemstack)
					else
						local added = inv:add_item("main", itemstack)
						if not added:is_empty() then
							local pos = user:get_pos()
							pos.y = pos.y + 1.5
							core.add_item(pos, added)
						end
					end
				end
				return burning_stick
			end
		end
		return itemstack
	end,
})
