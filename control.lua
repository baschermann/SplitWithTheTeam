function create_gui(player)
	local container = player.gui.center["container"]
	if(container) then container.destroy() end

	player.gui.center.add{ type="frame", name="container",	direction="horizontal" }
	player.gui.center.container.add{ type="table", name="table", direction="horizontal", column_count=3, draw_vertical_lines = true }
	
	create_gui_list(player.gui.center.container.table, global.recipes, "Team 1", false, "Team1", player, 200);
	create_gui_list(player.gui.center.container.table, global.recipes, "Assign", true, "none", player, 250);
	create_gui_list(player.gui.center.container.table, global.recipes, "Team 2", false, "Team2", player, 200);
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
	
	outer.add{ type="label", name="label", caption=caption}
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

function on_player_join(event)
	local player = game.players[event.player_index];
	
	if(global.first_join) then
		for key, value in pairs(player.force.recipes) do
			if(value.enabled and value.hidden == false) then
				global.recipes[key] = "none"
			end
		end
		
		global.first_join = false;
	end
	create_gui(player)
end

function on_gui_click(event)
	local player = game.players[event.player_index]
	if(player.force.name ~= "player") then
		global.recipes[event.element.name] = player.force.name
		for k, v in pairs(game.players) do
			create_gui(v)
		end
	else
		player.print("Join a Team first!")
	end
end

function on_init() 
	game.create_force("Team1")
	game.create_force("Team2")
    game.forces['Team1'].set_cease_fire('Team2', true)
    game.forces['Team2'].set_cease_fire('Team1', true)
	
	global.recipes = {};
	global.first_join = true;
end


script.on_init( on_init )
script.on_event(defines.events.on_player_joined_game, on_player_join )
script.on_event(defines.events.on_gui_click, on_gui_click )