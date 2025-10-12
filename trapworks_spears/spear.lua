local S = trapworks_spears.translator

local SHORT_TIMER = tonumber(core.settings:get("dedicated_server_step") or "0.09")/2
local LONG_TIMER = tonumber(core.settings:get("trapworks_spears_spear_long_timer") or "2.5")
local CHECK_DISTANCE = tonumber(core.settings:get("trapworks_spears_spear_check_distance") or "10.0")

-- table with key as GUID, ajd table with last
local stored_entities = {}
local last_clear_time = core.get_gametime()
local gtime = 0

core.register_globalstep(function(dtime)
	gtime = gtime + dtime
end)

local function is_damagable_object(obj)
	if obj:is_player() then
		return true
	end
	local ent_data = obj:get_luaentity()
	local entity_name = ent_data and ent_data.name
	if not entity_name then
		return false
	end
	local props = obj:get_properties() or {}
	if props.physical == false then
			return false
	end
	if ent_data.type=="animal" or ent_data.type=="monster" or ent_data.type=="npc" then
		-- mobs are always damagable
		return true
	end
	local armor_groups = obj:get_armor_groups() or {}
	if armor_groups.immortal then
		return false
	end
	return true
end

local tops = {
	[0] = {x=0, y=1, z=0}, -- 0–3: top nahoru
	[1] = {x=0, y=0, z=1}, -- 4–7: top na jih
	[2] = {x=0, y=0, z=-1},-- 8–11: top na sever
	[3] = {x=1, y=0, z=0}, -- 12–15: top na východ
	[4] = {x=-1, y=0, z=0},-- 16–19: top na západ
	[5] = {x=0, y=-1, z=0},-- 20–23: top dolů
}

local function rotate_point(p, facedir)
	local dir = core.facedir_to_dir(facedir)
	local top = tops[math.floor(facedir/4)]

	local right = vector.cross(top, dir)
	return {
		x = p.x * right.x + p.y * top.x + p.z * dir.x,
		y = p.x * right.y + p.y * top.y + p.z * dir.y,
		z = p.x * right.z + p.y * top.z + p.z * dir.z,
	}
end

local function rotate_box(box, facedir)
	local xmin,ymin,zmin,xmax,ymax,zmax = unpack(box)
	local corners = {
		{x=xmin,y=ymin,z=zmin}, {x=xmax,y=ymin,z=zmin},
		{x=xmin,y=ymax,z=zmin}, {x=xmax,y=ymax,z=zmin},
		{x=xmin,y=ymin,z=zmax}, {x=xmax,y=ymin,z=zmax},
		{x=xmin,y=ymax,z=zmax}, {x=xmax,y=ymax,z=zmax},
	}
	local newmin = {x= 1e9,y= 1e9,z= 1e9}
	local newmax = {x=-1e9,y=-1e9,z=-1e9}
	for _,c in ipairs(corners) do
		local r = rotate_point(c, facedir)
		newmin.x = math.min(newmin.x, r.x)
		newmin.y = math.min(newmin.y, r.y)
		newmin.z = math.min(newmin.z, r.z)
		newmax.x = math.max(newmax.x, r.x)
		newmax.y = math.max(newmax.y, r.y)
		newmax.z = math.max(newmax.z, r.z)
	end
	return {newmin.x,newmin.y,newmin.z,newmax.x,newmax.y,newmax.z}
end

local function aabb_collision(pos1, box1, pos2, box2)
	local b1 = {
		xmin = pos1.x + box1[1],
		ymin = pos1.y + box1[2],
		zmin = pos1.z + box1[3],
		xmax = pos1.x + box1[4],
		ymax = pos1.y + box1[5],
		zmax = pos1.z + box1[6],
	}
	local b2 = {
		xmin = pos2.x + box2[1],
		ymin = pos2.y + box2[2],
		zmin = pos2.z + box2[3],
		xmax = pos2.x + box2[4],
		ymax = pos2.y + box2[5],
		zmax = pos2.z + box2[6],
	}

	if b1.xmax < b2.xmin or b1.xmin > b2.xmax then return false end
	if b1.ymax < b2.ymin or b1.ymin > b2.ymax then return false end
	if b1.zmax < b2.zmin or b1.zmin > b2.zmax then return false end

	return true
end

local spear_dirs = {}
for fd=0,23 do
	local point_from = rotate_point(vector.new(-0.125,-0.5,-0.5), fd)
	local point_to = rotate_point(vector.new(-0.0625,0.125,0.5), fd)
	spear_dirs[fd] = vector.normalize(vector.subtract(point_from, point_to))
end

local function effective_forward_speed(ent_data, facedir, speed)
	local move_dir = vector.normalize(vector.subtract(ent_data.pos, ent_data.ppos))
	local spear_dir = spear_dirs[facedir] -- spear points backwards

	local dot = vector.dot(move_dir, spear_dir)
	dot = math.max(-1, math.min(1, dot)) 
	local angle = math.deg(math.acos(dot))

	--print("Spear angle: "..angle.."° (dot: "..dot..")")

	local weight
	if angle <= 45 then
		-- do 30° bereme čistě dopřednou složku
		weight = dot
	elseif angle < 60 then
		-- mezi 45° a 60° lineárně utlumíme na nulu
		local factor = (60 - angle) / (60 - 45) -- 1 → 0
		weight = dot * factor
	else
		weight = 0
	end

	return speed * math.max(weight, 0)
end

-- node box {x=0, y=0, z=0}
local node_box = {
	type = "fixed",
	fixed = {
		{-0.125,-0.5,-0.5,-0.0625,-0.4375,-0.25},
		{-0.1875,-0.5,-0.4375,-0.125,-0.4375,-0.375},
		{-0.0625,-0.5,-0.4375,0.0,-0.4375,-0.375},
		{-0.125,-0.4375,-0.4375,-0.0625,-0.375,-0.1875},
		{-0.1875,-0.4375,-0.375,-0.125,-0.375,-0.25},
		{-0.0625,-0.4375,-0.375,0.0,-0.375,-0.25},
		{-0.125,-0.375,-0.375,-0.0625,-0.3125,-0.0625},
		{-0.1875,-0.375,-0.25,-0.125,-0.3125,-0.1875},
		{-0.0625,-0.375,-0.25,0.0,-0.3125,-0.1875},
		{-0.125,-0.3125,-0.25,-0.0625,-0.25,0.1875},
		{-0.1875,-0.3125,-0.1875,-0.125,-0.25,-0.0625},
		{-0.0625,-0.3125,-0.1875,0.0,-0.25,-0.0625},
		{-0.125,-0.25,-0.1875,-0.0625,-0.1875,0.125},
		{-0.1875,-0.25,-0.0625,-0.125,-0.1875,0.0},
		{-0.0625,-0.25,-0.0625,0.0,-0.1875,0.0},
		{-0.125,-0.1875,-0.0625,-0.0625,-0.125,0.1875},
		{-0.125,-0.5,0.0,-0.0625,-0.3125,0.1875},
		{-0.1875,-0.1875,0.0,-0.125,-0.125,0.125},
		{-0.0625,-0.1875,0.0,0.0,-0.125,0.125},
		{-0.125,-0.125,0.0,-0.0625,-0.0625,0.3125},
		{-0.1875,-0.5,0.0625,-0.125,-0.1875,0.125},
		{-0.0625,-0.5,0.0625,0.0,-0.1875,0.125},
		{-0.25,-0.25,0.0625,-0.1875,-0.0625,0.125},
		{0.0,-0.25,0.0625,0.0625,-0.0625,0.125},
		{-0.1875,-0.125,0.125,-0.125,-0.0625,0.1875},
		{-0.0625,-0.125,0.125,0.0,-0.0625,0.1875},
		{-0.125,-0.0625,0.125,-0.0625,0.0,0.375},
		{-0.1875,-0.0625,0.1875,-0.125,0.0,0.3125},
		{-0.0625,-0.0625,0.1875,0.0,0.0,0.3125},
		{-0.125,0.0,0.1875,-0.0625,0.0625,0.375},
		{-0.1875,0.0,0.3125,-0.125,0.0625,0.375},
		{-0.0625,0.0,0.3125,0.0,0.0625,0.375},
		{-0.125,0.0625,0.3125,-0.0625,0.125,0.375},
		{-0.125,0.0625,0.375,-0.0625,0.125,0.5},
	},
}

local head_collision_boxes = {}
for fd=0,23 do
	head_collision_boxes[fd] = rotate_box({-0.125,0.0625,0.375,-0.0625,0.125,0.5}, fd)
end

local spears = {
	wood = {
		desc = S("Wooden Trap Spear"),
		inventory_image = "trapworks_spears_spear_wood.png",
		wield_image = "trapworks_spears_spear_wood.png^[transformR90",
		tile = "default_tree_top.png",
		spear = "trapworks_spears:spear_wood",
		move_resistance = 4,
		forward_speed_damage = 2,
	},
}

if core.get_modpath("spears") then
	spears.stone = {
		desc = S("Stone Trap Spear"),
		tile = "default_stone.png",
		spear = "spears:spear_stone",
		move_resistance = 4,
		forward_speed_damage = 3,
	}
	if core.get_modpath("pigiron") then
		spears.iron = {
			desc = S("Iron Trap Spear"),
			tile = "pigiron_iron_block.png",
			spear = "spears:spear_iron",
			move_resistance = 4,
			forward_speed_damage = 4.1,
		}
	end
	spears.steel = {
		desc = S("Steel Trap Spear"),
		tile = "default_steel_block.png",
		spear = "spears:spear_steel",
		move_resistance = 4,
		forward_speed_damage = 4.5,
	}
	spears.copper = {
		desc = S("Copper Trap Spear"),
		tile = "default_copper_block.png",
		spear = "spears:spear_copper",
		move_resistance = 4,
		forward_speed_damage = 3.5,
	}
	spears.bronze = {
		desc = S("Bronze Trap Spear"),
		tile = "default_bronze_block.png",
		spear = "spears:spear_bronze",
		move_resistance = 4,
		forward_speed_damage = 3.9,
	}
	spears.diamond = {
		desc = S("Diamond Trap Spear"),
		tile = "default_diamond.png",
		spear = "spears:spear_diamond",
		move_resistance = 4,
		forward_speed_damage = 5,
	}
	spears.obsidian = {
		desc = S("Obsidian Trap Spear"),
		tile = "default_obsidian.png",
		spear = "spears:spear_obsidian",
		move_resistance = 4,
		forward_speed_damage = 5,
	}
end

for key, data in pairs(spears) do
	core.register_node("trapworks_spears:spear_"..key, {
			description = data.desc,
			inventory_image = data.inventory_image,
			wield_image = data.wield_image,
			drawtype = "mesh",
			mesh = "trapworks_spears_spear_spear.obj",
			selection_box = node_box,
			collision_box = node_box,
			tiles = data.tiles or {"default_tree.png", data.tile, "default_tree.png"},
			use_texture_alpha = "opaque",
			groups = {choppy = 3},
			paramtype = "light",
			paramtype2 = "facedir",
			liquid_viscosity = data.move_resistance,
			walkable = false,

			node_placement_prediction = "", -- disable prediction
			on_place = function(itemstack, placer, pointed_thing)
				return nil
			end,
			drop = "",
			node_dig_prediction = "trapworks_spears:spear_support",
			after_dig_node = function(pos, oldnode, oldmetadata, digger)
				core.set_node(pos, {name="trapworks_spears:spear_support"})
				local spear_item = ItemStack(data.spear)
				if oldmetadata and oldmetadata.fields and oldmetadata.fields.spear_wear then
					local wear = tonumber(oldmetadata.fields.spear_wear)
					if wear > 0 then
						spear_item:set_wear(wear)
					end
				end
				local inv = digger:get_inventory()
				if inv:room_for_item("main", spear_item) then
					inv:add_item("main", spear_item)
				else
					core.add_item(pos, spear_item)
				end
			end,

			on_rotate = false,
			on_construct = function(pos)
				local timer = core.get_node_timer(pos)
				timer:start(SHORT_TIMER)
			end,
			on_timer = function(pos, elapsed)
				local objs = core.get_objects_inside_radius(pos, CHECK_DISTANCE)
				local use_short_timer = false
				local node = core.get_node(pos)
				local facedir = node.param2 % 24

				--print("gtime: "..gtime)

				for _, obj in ipairs(objs) do
					if is_damagable_object(obj) then
						use_short_timer = true

						local guid = obj:get_guid()
						local epos = obj:get_pos()

						if stored_entities[guid] == nil then
							stored_entities[guid] = {
								pos = epos,
								time = gtime,
							}
							--print("storing new entity "..guid)
						else
							if stored_entities[guid].time < gtime then
								stored_entities[guid] = {
									ppos = stored_entities[guid].pos,
									pos = epos,
									dt = gtime - stored_entities[guid].time,
									time = gtime,
								}
								--print("updating entity "..guid)
							end

							-- check collision
							--print("checking collision for "..guid)

							if aabb_collision(pos, head_collision_boxes[facedir], epos, obj:get_properties().collisionbox) then
								-- handle collision
								local ent_data = stored_entities[guid]
								--print("ent_data.ppos: "..core.pos_to_string(ent_data.ppos).." ent_data.pos: "..core.pos_to_string(ent_data.pos).." ent_data.dt: "..tostring(ent_data.dt))
								local speed = vector.distance(ent_data.ppos, ent_data.pos) / ent_data.dt

								local forward_speed = effective_forward_speed(ent_data, facedir, speed)

								local damage = forward_speed * data.forward_speed_damage
								--print("Spear hit: "..guid.." at "..core.pos_to_string(epos).." with forward speed "..forward_speed.." (speed "..speed..") dealing damage "..damage)

								if damage > 0.5 then
									obj:punch(obj, 1.0, {
										full_punch_interval=1.0,
										damage_groups = {fleshy=math.round(damage)},
									}, vector.normalize(ent_data.ppos - ent_data.pos))
								end
							end

						end
					end
				end
				local timer = core.get_node_timer(pos)
				if use_short_timer then
					timer:start(SHORT_TIMER)
				else
					timer:start(LONG_TIMER)
				end
				return false -- timer is restarted manually
			end,
		})
end

-- node box {x=0, y=0, z=0}
local node_box_support = {
	type = "fixed",
	fixed = {
		{-0.125,-0.5,0.0,-0.0625,-0.25,0.1875},
		{-0.1875,-0.5,0.0625,-0.125,-0.1875,0.125},
		{-0.0625,-0.5,0.0625,0.0,-0.1875,0.125},
		{-0.25,-0.25,0.0625,-0.1875,-0.0625,0.125},
		{0.0,-0.25,0.0625,0.0625,-0.0625,0.125},
	},
}

core.register_node("trapworks_spears:spear_support", {
	description = S("Trap Spear Support"),
	drawtype = "mesh",
	mesh = "trapworks_spears_spear_support.obj",
	selection_box = node_box_support,
	collision_box = node_box_support,
	tiles = {"default_tree.png"},
	use_texture_alpha = "opaque",
	groups = {choppy = 3},
	paramtype = "light",
	paramtype2 = "facedir",
	walkable = false,

	on_rotate = false,

	on_punch = function(pos, node, puncher, pointed_thing)
		local itemstack = puncher:get_wielded_item()
		local name = itemstack:get_name()
		print("Trying to place spear trap with item: "..name)
		for key, data in pairs(spears) do
			if data.spear == name then
				node.name = "trapworks_spears:spear_"..key
				core.set_node(pos, node)
				if itemstack:get_wear() > 0 then
					local meta = core.get_meta(pos)
					meta:set_string("spear_wear", itemstack:get_wear())
				end
				print("Placed spear trap: "..node.name)
				if not core.is_creative_enabled(puncher:get_player_name()) then
					itemstack:take_item()
					puncher:set_wielded_item(itemstack)
				end
				return
			end
		end
	end,
})
