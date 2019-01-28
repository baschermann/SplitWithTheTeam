function create_gui(player)
	local container = player.gui.center["container"]
	if(container) then container.destroy() end

	player.gui.center.add{ type="frame", name="container",	direction="horizontal" }
	player.gui.center.container.add{ type="table", name="table", direction="horizontal", column_count=3, draw_vertical_lines = true }
	
	create_gui_list(player.gui.center.container.table, global.recipes, "Team 1", false, "Team1", player, 220);
	create_gui_list(player.gui.center.container.table, global.recipes, "Assign", true, "none", player, 245);
	create_gui_list(player.gui.center.container.table, global.recipes, "Team 2", false, "Team2", player, 220);
end

function create_gui_list(element, recipes, caption, is_button, filter_name, player, width)
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
	local inner = scrollpane.add{ type="table", name="table"..caption.."4", direction="vertical", column_count=5 }
	
	for key, value in pairs(global.recipes) do
		if(value == filter_name) then
			local path = get_sprite_path(key, player);
			if(is_button and path ~= nil) then
				inner.add{ type="sprite-button", name=key, sprite=path}
			else
				inner.add{ type="sprite", name=key, sprite=path}
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
	
	player.print(name)
	return nil
end

function on_player_create(event)
	local player = game.players[event.player_index]
	local button = player.gui.top.add{ type="button", name="open_split_team_view", caption="ST"}
end

function on_gui_click(event)
	local player = game.players[event.player_index]
	
	if(event.element.name == "open_split_team_view") then
		if(player.gui.center.container == nil) then
			create_gui(player)
		else
			player.gui.center.container.destroy()
		end
	end
	
	if(player.force.name ~= "player") then
		if(global.recipes[event.element.name] ~= nil) then
			global.recipes[event.element.name] = player.force.name
			update_gui_for_all()
		end
	else
		if(event.element.name == "button_join_Team1") then
			player.force = game.forces["Team1"]
			update_gui(player)
		elseif(event.element.name == "button_join_Team2") then
			player.force = game.forces["Team2"]
			update_gui(player)
		end
	end
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

function prepareTeam(team)
  team.disable_all_prototypes()
  team.enable_all_technologies()
end

function on_player_join(event)
	local player = game.players[event.player_index]
	
	--for key, value in pairs(game.item_prototypes) do
	--	if(string.find(key, "%-ore") ~= nil) then
	--		player.print(key)
	--	end
	--end
end

function on_init() 

	TeamNames = {};
	TeamNames[0] = "Team1"
	TeamNames[1] = "Team2"

	game.create_force("Team1")
	game.create_force("Team2")

	game.forces['Team1'].set_cease_fire('Team2', true)
	game.forces['Team2'].set_cease_fire('Team1', true)
	prepareTeam(game.forces[TeamNames[0]])
	prepareTeam(game.forces[TeamNames[1]])
	
	global.recipes = {}
	global.recipes["iron-ore"] 		= "none"
	global.recipes["copper-ore"] 	= "none"
	global.recipes["coal"] 			= "none"
	global.recipes["stone"] 		= "none"
	global.recipes["uranium-ore"] 	= "none"
	global.recipes["water"] 		= "none"
	
	for key, value in pairs(game.item_prototypes) do
		if(string.find(key, "%-ore") ~= nil) then
			global.recipes[key] = "none"
		end
	end
	
	--for key, value in pairs(game.fluid_prototypes) do
	--	global.recipes[key] = "none"
	--end
	
	--for key, value in pairs(game.forces.player.recipes) do
	--	if(value.hidden == false) then
	--		global.recipes[key] = "none"
	--	end
	--end
end

--function on_player_create(player_index)
--  game.players[player_index.player_index].force = game.forces[TeamNames[0]]
--end

script.on_init( on_init )
script.on_event(defines.events.on_player_joined_game, on_player_join )
script.on_event(defines.events.on_gui_click, on_gui_click )
script.on_event(defines.events.on_player_created, on_player_create)