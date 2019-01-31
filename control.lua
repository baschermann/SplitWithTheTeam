function create_gui(player)
	local container = player.gui.center["container"]
	if(container) then container.destroy() end

	player.gui.center.add{ type="frame", name="container",	direction="horizontal" }
	player.gui.center.container.add{ type="table", name="table", direction="horizontal", column_count=3, draw_vertical_lines = true }
	
	create_gui_list(player.gui.center.container.table, global.recipes, "Team 1", false, global.team_names[1], player, 5, 245);
	create_gui_list(player.gui.center.container.table, global.recipes, "Assign", true, "none", player, 2, 125);
	create_gui_list(player.gui.center.container.table, global.recipes, "Team 2", false, global.team_names[2], player, 5, 245);
end

function create_gui_list(element, recipes, caption, is_button, filter_name, player, column_count, width)
	local outer = element.add{ type="table", name="table"..caption, direction="vertical", column_count=1}
	outer.style.align = "center"
	outer.style.left_padding = 8
	outer.style.right_padding = 8
	outer.style.top_padding = 8
	outer.style.bottom_padding = 8
	outer.style.height = 600
	outer.style.width = width
	
	local tableteam = outer.add{ type="table", name="tableteam"..caption, direction="horizontal", column_count=2}
	
	if(player.force.name == filter_name) then
		tableteam.add{ type="label", name="label", caption=caption .. " (your team)"}
	else
		tableteam.add{ type="label", name="label", caption=caption}
	end
	
	if(filter_name ~= "none" and player.force.name == "player") then
		tableteam.add{ type="button", name="button_join_"..filter_name, caption="Join"}
	end
	
	local scrollpane = outer.add{ type="scroll-pane", name="scrollpane"..caption, vertical_scroll_policy="always"}
	local inner = scrollpane.add{ type="table", name="table"..caption.."4", direction="vertical", column_count=column_count }
	
	for key, value in pairs(global.recipes) do
		if(value == filter_name or value == "all") then
			local path = get_sprite_path(key, player);
			if(path ~= nil) then
				if(is_button and path ~= nil ) then
					if(value ~= "all") then
						inner.add{ type="sprite-button", name=key, sprite=path}
					end
				else
					local button = inner.add{ type="sprite-button", name=key, sprite=path, ignored_by_interaction = true}
					if(global.researched_recipes[filter_name][key] == nil) then
						button.style = "red-background-image-style"
					else
						button.style = "transparent-background-image-style"
					end
				end
			end
		end
	end
end

function get_sprite_path(name, player)
	if(player.gui.is_valid_sprite_path("item/"..name)) then
		return "item/"..name
	end
	
	if(player.gui.is_valid_sprite_path("fluid/"..name)) then
		return "fluid/"..name
	end
	
	if(player.gui.is_valid_sprite_path("recipe/"..name)) then
		return "recipe/"..name
	end
	
	player.print("Could not draw: "..name)
	return nil
end

function on_player_create(event)
	local player = game.players[event.player_index]
	local button = player.gui.top.add{ type="button", name="open_split_team_view", caption="ST"}
	toggle_gui(player)

	--for testing
	--local button = player.gui.top.add{ type="button", name="join1", caption="Join T1"}
	--local button = player.gui.top.add{ type="button", name="join2", caption="Join T2"}

	--player.insert{name="electric-mining-drill", count=50}
	--player.insert{name="lab", count=50}
	--player.insert{name="boiler", count=3}
	--player.insert{name="offshore-pump", count=50}
	--player.insert{name="steam-engine", count=6}
	--player.insert{name="science-pack-1", count=600}
	--player.insert{name="science-pack-2", count=600}
	--player.insert{name="medium-electric-pole", count=50}
	--player.insert{name="solid-fuel", count=150}
	--player.insert{name="assembling-machine-3", count=50}
	--player.insert{name="power-armor-mk2", count=1}
	--player.insert{name="fusion-reactor-equipment", count=2}
	--player.insert{name="personal-roboport-mk2-equipment", count=2}
	--player.insert{name="construction-robot", count=50}
	--end testing
end

function on_gui_click(event)
	local player = game.players[event.player_index]

	-- for Testing
	--if(event.element.name == "join1") then
	--	player.force = game.forces[global.team_names[1]]
	--	player.print("Joined T1")
	--end
--
	--if(event.element.name == "join2") then
	--	player.force = game.forces[global.team_names[2]]
	--	player.print("Joined T2")
	--end
	-- end Testing
	
	if(event.element.name == "open_split_team_view") then
		toggle_gui(player)
	end
	
	if(player.force.name ~= "player") then
		if(global.recipes[event.element.name] ~= nil and global.recipes[event.element.name] == "none") then
			assign_technologies(event.element.name, player)
			update_gui_for_all()
		end
	else
		if(event.element.name == "button_join_Team1") then
			join_team(player, global.team_names[1])
			game.print("Player "..player.name.." joined Team 1")
			update_gui(player)
		elseif(event.element.name == "button_join_Team2") then
			join_team(player, global.team_names[2])
			game.print("Player "..player.name.." joined Team 2")
			update_gui(player)
		end
	end
end

function toggle_gui(player)
	if(player.gui.center.container == nil) then
		create_gui(player)
	else
		player.gui.center.container.destroy()
	end
end

function join_team(player, team_name)
	player.force = game.forces[team_name]
	
end

function update_gui_for_all()
	for k, v in pairs(game.players) do
		if(v.gui.center.container ~= nil) then
			create_gui(v)
		end
	end
end

function update_gui(player)
	if(player.gui.center.container ~= nil) then
		create_gui(player)
	end
end

function get_other_force_name(name)
	if(global.team_names[1] == name) then return global.team_names[2] else return global.team_names[1] end
end

function assign_technologies(name, player)
	local other_force_name = get_other_force_name(player.force.name);
	local other_force = game.forces[other_force_name]

	global.recipes[name] = player.force.name
	global.researched_recipes[player.force.name][name] = true; -- kinda hacky
	
	if(player.force.recipes[name] ~= nil) then
		player.force.recipes[name].enabled = true
	end

	if(name == "iron-ore") then
		global.recipes["copper-ore"] = other_force_name
		global.researched_recipes[other_force_name]["copper-ore"] = true;
		add_to(other_force, "iron-plate", true)
		add_to(player.force, "copper-plate", true)
		add_to(player.force, "iron-gear-wheel", true)
		add_to(player.force, "pipe", true)
		add_to(other_force, "pipe-to-ground", true)
	elseif(name == "stone") then
		add_to(other_force, "stone-furnace", true)
		add_to(player.force, "boiler", true)
		add_to(other_force, "steam-engine", true)
		global.recipes["coal"] = other_force_name
		global.researched_recipes[other_force_name]["coal"] = true;
		global.recipes["water"] = player.force.name
		global.researched_recipes[player.force.name]["water"] = true;
		add_to(other_force, "offshore-pump", true)
	elseif(name == "uranium-ore") then

	end

	-- count the number of not assigned technologies
	local free_technologies = 0
	for key, value in pairs(global.recipes) do
		if(value == "none") then free_technologies = free_technologies + 1 end
	end

	--if(free_technologies <= 0) then assign_techs(player.force, other_force, global.start_techs, true, 0, player.force) end
	if(free_technologies <= 0) then assign_techs(global.start_techs, true, 0, player.force) end
end

function assign_techs(recipes_to_assign, enable, number_of_repeats, force_of_researcher)
	local force1 = game.forces[global.team_names[1]]
	local force2 = game.forces[global.team_names[2]]

	-- Add technologies that have not been set manually that are usually available from the start
	for key, value in pairs(recipes_to_assign) do
		if(global.recipes[value] == nil) then
			global.recipes[value] = "none"
		end
	end

	-- assign them automatically
	local repeat_assigning = false;
	local repeat_techs = {}
	
	for _, item_name in pairs(recipes_to_assign) do
		--game.players[1].print(_..": "..item_name)
		-- item_name is the tech we want to assign
		-- the force who can craft less ingredients gets the recipe
		local f1_nr_of_ingr = 0
		local f2_nr_of_ingr = 0

		local all_ingredients_available = true;
		for _, ingredient in pairs(game.recipe_prototypes[item_name].ingredients) do
			--game.players[1].print("Ingredient: "..ingredient.name)
			local ingredient_available = false;

			if(global.recipes[ingredient.name] == global.team_names[1]) then
				f1_nr_of_ingr = f1_nr_of_ingr + 1
				ingredient_available = true
			end

			if(global.recipes[ingredient.name] == global.team_names[2]) then
				f2_nr_of_ingr = f2_nr_of_ingr + 1
				ingredient_available = true
			end

			if(global.recipes[ingredient.name] == "all") then
				f1_nr_of_ingr = f1_nr_of_ingr + 1
				f2_nr_of_ingr = f2_nr_of_ingr + 1
				ingredient_available = true
			end

			if(ingredient_available == false) then
				if(number_of_repeats < 7) then
					all_ingredients_available = false
				else
					all_ingredients_available = true
				end
			end
		end

		local products = {}
		if(game.recipe_prototypes[item_name] ~= nil) then
			for key, value in pairs(game.recipe_prototypes[item_name].products) do
				global.researched_recipes[force_of_researcher.name][value.name] = true
				if(global.recipes[value.name] == nil) then
					table.insert(products, value.name)
				end
			end
		end

		if(all_ingredients_available) then
			if(f1_nr_of_ingr == f2_nr_of_ingr) then
				-- if both have the same number of ingredients
				-- the force with less recipes gets it
				local f1_nr_of_rec = 0
				local f2_nr_of_rec = 0
				for key, value in pairs(global.recipes) do
					if(value == global.team_names[1]) then
						f1_nr_of_rec = f1_nr_of_rec + 1
					end

					if(value == global.team_names[2]) then
						f2_nr_of_rec = f2_nr_of_rec + 1
					end
				end

				if(f1_nr_of_rec >= f2_nr_of_rec) then
					--game.players[1].print("Nr. of recipes:: "..tostring(f1_nr_of_rec).." (T1) to "..tostring(f2_nr_of_rec).." (T2) for "..item_name.." giving Team 2")
					add_to(force2, item_name, enable)
					add_products_to(force2, products)
				else
					--game.players[1].print("Nr. of recipes:: "..tostring(f1_nr_of_rec).." (T1) to "..tostring(f2_nr_of_rec).." (T2) for "..item_name.." giving Team 2")
					add_to(force1, item_name, enable)
					for key, value in pairs(products) do
						add_to(force1, value, enable)
						add_products_to(force1, products)
					end
				end
			elseif(f1_nr_of_ingr > f2_nr_of_ingr) then
				-- if team 1 has more ingredients for this recipe, give it to team 2
				--game.players[1].print("Nr. of ingredients:: "..tostring(f1_nr_of_ingr).." (T1) to "..tostring(f2_nr_of_ingr).." (T2) for "..item_name.." giving Team 2")
				add_to(force2, item_name, enable)
				for key, value in pairs(products) do
					add_to(force2, value, enable)
					add_products_to(force2, products)
				end
			else
				--game.players[1].print("Nr. of ingredients:: "..tostring(f1_nr_of_ingr).." (T1) to "..tostring(f2_nr_of_ingr).." (T2) for "..item_name.." giving Team 1")
				add_to(force1, item_name, enable)
				for key, value in pairs(products) do
					add_to(force1, value, enable)
					add_products_to(force1, products)
				end
			end
		else
			repeat_assigning = true;
			table.insert(repeat_techs, item_name)
			--game.players[1].print("not all ingredients available for "..item_name)
		end
	end
	
	if(number_of_repeats < 7) then
		if(repeat_assigning) then
			--game.players[1].print("--- repeat")
			assign_techs(repeat_techs, enable, number_of_repeats + 1, force_of_researcher)
		end
	else
		--game.players[1].print("Repeats reached maximum limit")
	end
end

function add_to(force, name, enable)
	global.recipes[name] = force.name
	if(enable) then	force.recipes[name].enabled = true end
end

function add_products_to(force, products, researcher_force)
	for key, value in pairs(products) do
		if(global.recipes[value] == nil) then
			global.recipes[value] = force.name
		end
	end
end

function on_research_finished(event)
	local researched_items = {}

	-- get all techs that are researched
	for key, value in pairs(event.research.effects) do
		if(value.type == "unlock-recipe") then
			if(game.recipe_prototypes[value.recipe].subgroup.name == "fill-barrel" or game.recipe_prototypes[value.recipe].subgroup.name == "empty-barrel") then
				global.recipes[value.recipe] = "all"
			else
				table.insert(researched_items, value.recipe)
			end
			global.researched_recipes[event.research.force.name][value.recipe] = true
		end
	end

	-- assign them to the forces but do not enable them
	assign_techs(researched_items, false, 0, event.research.force)

	-- disable that are not our own since researching enables them automatically
	for key, value in pairs(researched_items) do
		if(global.recipes[value] ~= event.research.force.name) then
			game.forces[event.research.force.name].recipes[value].enabled = false
		end
	end

	update_gui_for_all()
end

function on_research_started(event)
	event.research.researched = true;
end

ores = {}
ores[0] = "iron-ore"
ores[1] = "copper-ore"
ores[2] = "coal"
ores[3] = "stone"
ores[4] = "uranium=ore"
function getAllowedEntitys(force)
	local player_entity = {}
	for key, value in pairs(ores) do
		if(global.recipes[value] == force.name) then 
			player_entity[value] = true
		end 
	end 
	return player_entity
end

function isBuildAllowed(force, entity, surface)
	local protoype = game.entity_prototypes[entity.name]
	local r = protoype.mining_drill_radius
	local box = {{entity.position.x - r, entity.position.y - r}, {entity.position.x + r, entity.position.y + r}}
	local entites = surface.find_entities_filtered{area = box, type="resource"}
	
    local allowedEntitys = getAllowedEntitys(force)
    for key, value in pairs(entites) do
		if allowedEntitys[value.name] ~= true then
			return true
		end
	end
	return false
end

function on_built_entity(event)
	local entity = event.created_entity
	local player = game.players[event.player_index]
	if(entity.name == "burner-mining-drill") then
		if isBuildAllowed(player.force, entity, player.surface) then
			player.print("You are not allowed to mine this.")
			player.insert{name="burner-mining-drill"}
			entity.destroy()
		end
	elseif(entity.name == "electric-mining-drill") then
		if isBuildAllowed(player.force, entity, player.surface) then
			player.insert{name="electric-mining-drill"}
			player.print("You are not allowed to mine this.")
			entity.destroy()
		end
	elseif(entity.name == "offshore-pump"
		or entity.name == "pumpjack") then
		if(global.recipes[entity.name] ~= player.force.name) then
			destroy_and_give_back(player, entity)
		end
	end
end

function destroy_and_give_back(player, entity)
	player.insert{name=entity.name}
	player.print("You are not allowed to do this.")
	entity.destroy()
end
	
function on_robot_build_entity(event)
	local entity = event.created_entity
	local robot = event.robot
	if(entity.name == "burner-mining-drill"
		or entity.name == "electric-mining-drill") then
		if(isBuildAllowed(robot.force, entity, robot.surface)) then
			destroy_and_leave_on_ground(robot, entity)
		end
	elseif(entity.name == "offshore-pump"
			or entity.name == "pumpjack") then
		if(global.recipes[entity.name] ~= robot.force.name) then
			destroy_and_leave_on_ground(robot, entity)
		end
	end
end

function destroy_and_leave_on_ground(robot, entity)
	local entity_name = entity.name
	entity.destroy()
	local new_entity = robot.surface.create_entity{name = "item-on-ground", position = robot.position, stack={name=entity_name}}
	new_entity.order_deconstruction(robot.force)
	robot.force.print("Your robots are not allowed to do that.")
end
	
function prepare_force(force)
	force.disable_all_prototypes()
	force.enable_all_technologies()
	force.recipes["wooden-chest"].enabled = true
	global.recipes["wooden-chest"] = "all"
	force.recipes["iron-axe"].enabled = true
	global.recipes["iron-axe"] = "all"
	force.recipes["wood"].enabled = true
	global.recipes["wood"] = "all"
	force.recipes["iron-stick"].enabled = true
	global.recipes["iron-stick"] = "all"
end
	
function on_init() 
	global.team_names = {}
	global.team_names[1] = "Team1"
	global.team_names[2] = "Team2"

	global.recipes = {}
	global.start_techs = {}

	global.researched_recipes = {}
	global.researched_recipes[global.team_names[1]] = {}
	global.researched_recipes[global.team_names[2]] = {}

	-- prepare forces
	game.create_force("Team1")
	game.create_force("Team2")
	game.forces['Team1'].set_cease_fire('Team2', true)
	game.forces['Team2'].set_cease_fire('Team1', true)
	prepare_force(game.forces[global.team_names[1]])
	prepare_force(game.forces[global.team_names[2]])

	-- setup first ores that can be selected
	global.recipes["iron-ore"] 		= "none"
	global.recipes["stone"] 		= "none"
	global.recipes["uranium-ore"] 	= "none"
	global.recipes["crude-oil"] 	= "none"

	for key, value in pairs(game.forces.player.recipes) do
		if(value.enabled == true and value.hidden == false) then
			if(key ~= "wooden-chest" and key ~= "iron-axe" and key ~= "wood" and key ~= "iron-stick") then
				table.insert(global.start_techs, key)
			end
			global.researched_recipes[global.team_names[1]][key] = true
			global.researched_recipes[global.team_names[2]][key] = true
		end
	end

	-- disable everything for player force
	game.forces["player"].disable_all_prototypes();
end

script.on_init( on_init )
script.on_event( defines.events.on_gui_click, on_gui_click )
script.on_event( defines.events.on_player_created, on_player_create )
script.on_event( defines.events.on_research_finished, on_research_finished )
--script.on_event( defines.events.on_research_started, on_research_started )
script.on_event( defines.events.on_built_entity, on_built_entity )
script.on_event( defines.events.on_robot_built_entity, on_robot_build_entity )