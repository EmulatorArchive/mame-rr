print("Street Fighter II hitbox viewer")
print("July 24, 2011")
print("http://code.google.com/p/mame-rr/")
print("Lua hotkey 1: toggle blank screen")
print("Lua hotkey 2: toggle object axis")
print("Lua hotkey 3: toggle hitbox axis")
print("Lua hotkey 4: toggle pushboxes")
print("Lua hotkey 5: toggle throwable boxes")

local boxes = {
	      ["vulnerability"] = {color = 0x7777FF, fill = 0x40, outline = 0xFF},
	             ["attack"] = {color = 0xFF0000, fill = 0x40, outline = 0xFF},
	["proj. vulnerability"] = {color = 0x00FFFF, fill = 0x40, outline = 0xFF},
	       ["proj. attack"] = {color = 0xFF66FF, fill = 0x40, outline = 0xFF},
	               ["push"] = {color = 0x00FF00, fill = 0x20, outline = 0xFF},
	               ["weak"] = {color = 0xFFFF00, fill = 0x40, outline = 0xFF},
	              ["throw"] = {color = 0xFFFF00, fill = 0x40, outline = 0xFF},
	          ["throwable"] = {color = 0xF0F0F0, fill = 0x20, outline = 0xFF},
	      ["air throwable"] = {color = 0x202020, fill = 0x20, outline = 0xFF},
}

local globals = {
	axis_color           = 0xFFFFFFFF,
	blank_color          = 0xFFFFFFFF,
	axis_size            = 12,
	mini_axis_size       = 2,
	blank_screen         = false,
	draw_axis            = true,
	draw_mini_axis       = false,
	draw_pushboxes       = true,
	draw_throwable_boxes = false,
}

--------------------------------------------------------------------------------
-- game-specific modules

local profile = {
	{
		games = {"sf2"},
		status_type = "normal",
		address = {
			player           = 0xFF83C6,
			projectile       = 0xFF938A,
			left_screen_edge = 0xFF8BD8,
		},
		player_space       = 0x300,
		box_parameter_size = 1,
		box_list = {
			{addr_table = 0xA, id_ptr = 0xD, id_space = 0x04, type = "push"},
			{addr_table = 0x0, id_ptr = 0x8, id_space = 0x04, type = "vulnerability"},
			{addr_table = 0x2, id_ptr = 0x9, id_space = 0x04, type = "vulnerability"},
			{addr_table = 0x4, id_ptr = 0xA, id_space = 0x04, type = "vulnerability"},
			{addr_table = 0x6, id_ptr = 0xB, id_space = 0x04, type = "weak"},
			{addr_table = 0x8, id_ptr = 0xC, id_space = 0x0C, type = "attack"},
		},
		throw_box_list = {
			{param_offset = 0x6C, type = "throwable"},
			{param_offset = 0x64, type = "throw"},
		}
	},
	{
		games = {"sf2ce","sf2hf"},
		status_type = "normal",
		address = {
			player           = 0xFF83BE,
			projectile       = 0xFF9376,
			left_screen_edge = 0xFF8BC4,
		},
		player_space       = 0x300,
		box_parameter_size = 1,
		box_list = {
			{addr_table = 0xA, id_ptr = 0xD, id_space = 0x04, type = "push"},
			{addr_table = 0x0, id_ptr = 0x8, id_space = 0x04, type = "vulnerability"},
			{addr_table = 0x2, id_ptr = 0x9, id_space = 0x04, type = "vulnerability"},
			{addr_table = 0x4, id_ptr = 0xA, id_space = 0x04, type = "vulnerability"},
			--{addr_table = 0x6, id_ptr = 0xB, id_space = 0x04, type = "weak"}, --present but nonfunctional
			{addr_table = 0x8, id_ptr = 0xC, id_space = 0x0C, type = "attack"},
		},
		throw_box_list = {
			{param_offset = 0x6C, type = "throwable"},
			{param_offset = 0x64, type = "throw"},
		}
	},
	{
		games = {"ssf2t"},
		status_type = "normal",
		address = {
			player           = 0xFF844E,
			projectile       = 0xFF97A2,
			left_screen_edge = 0xFF8ED4,
			stage            = 0xFFE18A,
		},
		player_space       = 0x400,
		box_parameter_size = 1,
		box_list = {
			{addr_table = 0x8, id_ptr = 0xD, id_space = 0x04, type = "push"},
			{addr_table = 0x0, id_ptr = 0x8, id_space = 0x04, type = "vulnerability"},
			{addr_table = 0x2, id_ptr = 0x9, id_space = 0x04, type = "vulnerability"},
			{addr_table = 0x4, id_ptr = 0xA, id_space = 0x04, type = "vulnerability"},
			{addr_table = 0x6, id_ptr = 0xC, id_space = 0x10, type = "attack"},
		},
		throw_box_list = {
			{param_offset = 0x6C, type = "throwable"},
			{param_offset = 0x64, type = "throw"},
		}
	},
	{
		games = {"ssf2"},
		status_type = "normal",
		address = {
			player           = 0xFF83CE,
			projectile       = 0xFF96A2,
			left_screen_edge = 0xFF8DD4,
			stage            = 0xFFE08A,
		},
		player_space       = 0x400,
		box_parameter_size = 1,
		box_list = {
			{addr_table = 0x8, id_ptr = 0xD, id_space = 0x04, type = "push"},
			{addr_table = 0x0, id_ptr = 0x8, id_space = 0x04, type = "vulnerability"},
			{addr_table = 0x2, id_ptr = 0x9, id_space = 0x04, type = "vulnerability"},
			{addr_table = 0x4, id_ptr = 0xA, id_space = 0x04, type = "vulnerability"},
			{addr_table = 0x6, id_ptr = 0xC, id_space = 0x0C, type = "attack"},
		},
		throw_box_list = {
			{param_offset = 0x6C, type = "throwable"},
			{param_offset = 0x64, type = "throw"},
		}
	},
	{
		games = {"hsf2"},
		status_type = "hsf2",
		address = {
			player           = 0xFF833C,
			projectile       = 0xFF9554,
			left_screen_edge = 0xFF8CC2,
			stage            = 0xFF8B64,
		},
		char_mode          = 0x32A,
		player_space       = 0x400,
		box_parameter_size = 2,
		box_list = {
			{addr_table = 0xA, id_ptr = 0xD, id_space = 0x08, type = "push"},
			{addr_table = 0x0, id_ptr = 0x8, id_space = 0x08, type = "vulnerability"},
			{addr_table = 0x2, id_ptr = 0x9, id_space = 0x08, type = "vulnerability"},
			{addr_table = 0x4, id_ptr = 0xA, id_space = 0x08, type = "vulnerability"},
			{addr_table = 0x6, id_ptr = 0xB, id_space = 0x08, type = "weak"},
			{addr_table = 0x8, id_ptr = 0xC, id_space = 0x14, type = "attack"},
		},
		throw_box_list = {
			{param_offset = 0x6C, type = "throwable"},
			{param_offset = 0x64, type = "throw"},
		}
	},
}

for _,game in ipairs(profile) do
	game.box_number = #game.box_list + #game.throw_box_list
end

for _,box in pairs(boxes) do
	box.fill    = box.color * 0x100 + box.fill
	box.outline = box.color * 0x100 + box.outline
end

local game
local player, projectiles, frame_buffer = {}, {}, {}
local NUMBER_OF_PLAYERS    = 2
local MAX_GAME_PROJECTILES = 8
local MAX_BONUS_OBJECTS    = 16
local DRAW_DELAY           = 1
if fba then
	DRAW_DELAY = DRAW_DELAY + 1
end


--------------------------------------------------------------------------------
-- prepare the hitboxes

local get_status = {
	["normal"] = function()
		return bit.band(memory.readword(0xFF8008), 0x08) > 0
	end,

	["hsf2"] = function()
		return memory.readword(0xFF8004) == 0x08
	end,
}

local function update_globals()
	globals.left_screen_edge = memory.readwordsigned(game.address.left_screen_edge)
	globals.top_screen_edge  = memory.readwordsigned(game.address.left_screen_edge + 0x4)
	globals.match_active     = get_status[game.status_type]()
end


local function get_x(x)
	return x - globals.left_screen_edge
end


local function get_y(y)
	return emu.screenheight() - (y - 15) + globals.top_screen_edge
end


local get_box_parameters = {
	[1] = function(box)
		box.hval   = memory.readbytesigned(box.address + 0)
		box.hval2  = memory.readbyte(box.address + 5)
		if box.hval2 >= 0x80 and box.type == "attack" then
			box.hval = -box.hval2
		end
		box.vval   = memory.readbytesigned(box.address + 1)
		box.hrad   = memory.readbyte(box.address + 2)
		box.vrad   = memory.readbyte(box.address + 3)
	end,

	[2] = function(box)
		box.hval   = memory.readwordsigned(box.address + 0)
		box.vval   = memory.readwordsigned(box.address + 2)
		box.hrad   = memory.readword(box.address + 4)
		box.vrad   = memory.readword(box.address + 6)
	end,
}


local process_box_type = {
	["vulnerability"] = function(obj, box)
	end,

	["attack"] = function(obj, box)
		if obj.projectile then
			box.type = "proj. attack"
		elseif memory.readbyte(obj.base + 0x03) == 0 then
			return false
		end
	end,

	["push"] = function(obj, box)
		if obj.projectile then
			box.type = "proj. vulnerability"
		end
	end,

	["weak"] = function(obj, box)
		if (game.char_mode and memory.readbyte(obj.base + game.char_mode) ~= 0x4)
			or memory.readbyte(obj.animation_ptr + 0x15) ~= 2 then
			return false
		end
	end,

	["throw"] = function(obj, box)
		get_box_parameters[2](box)
		if box.hval == 0 and box.vval == 0 and box.hrad == 0 and box.vrad == 0 then
			return false
		end

		for offset = 0,6,2 do
			memory.writeword(box.address + offset, 0) --bad
		end

		box.hval   = obj.pos_x + box.hval * (obj.facing_dir == 1 and -1 or 1)
		box.vval   = obj.pos_y - box.vval
		box.left   = box.hval - box.hrad
		box.right  = box.hval + box.hrad
		box.top    = box.vval - box.vrad
		box.bottom = box.vval + box.vrad
	end,

	["throwable"] = function(obj, box)
		if (memory.readbyte(obj.animation_ptr + 0x8) == 0 and
			memory.readbyte(obj.animation_ptr + 0x9) == 0 and
			memory.readbyte(obj.animation_ptr + 0xA) == 0) or
			memory.readbyte(obj.base + 0x3) == 0x0E or
			memory.readbyte(obj.base + 0x3) == 0x14 or
			memory.readbyte(obj.base + 0x143) > 0 or
			memory.readbyte(obj.base + 0x1BF) > 0 or
			memory.readbyte(obj.base + 0x1A1) > 0 then
			return false
		elseif memory.readbyte(obj.base + 0x181) > 0 then
			box.type = "air throwable"
		end

		box.hrad = memory.readword(box.address + 0)
		box.vrad = memory.readword(box.address + 2)
		box.hval = obj.pos_x
		box.vval = obj.pos_y - box.vrad/2
		box.left   = box.hval - box.hrad
		box.right  = box.hval + box.hrad
		box.top    = obj.pos_y - box.vrad
		box.bottom = obj.pos_y
	end,
}


local function define_box(obj, box_entry)
	local box = {
		type = box_entry.type,
		id = memory.readbyte(obj.animation_ptr + box_entry.id_ptr),
	}

	if box.id == 0 or process_box_type[box.type](obj, box) == false then
		return nil
	end

	local addr_table = obj.hitbox_ptr + memory.readwordsigned(obj.hitbox_ptr + box_entry.addr_table)
	box.address = addr_table + box.id * box_entry.id_space
	get_box_parameters[game.box_parameter_size](box)

	box.hval   = obj.pos_x + box.hval * (obj.facing_dir == 1 and -1 or 1)
	box.vval   = obj.pos_y - box.vval
	box.left   = box.hval - box.hrad
	box.right  = box.hval + box.hrad
	box.top    = box.vval - box.vrad
	box.bottom = box.vval + box.vrad

	return box
end


local function define_throw_box(obj, box_entry)
	local box = {
		type = box_entry.type,
		address = obj.base + box_entry.param_offset,
	}

	if process_box_type[box.type](obj, box) == false then
		return nil
	end

	return box
end


local function update_game_object(obj)
	obj.facing_dir    = memory.readbyte(obj.base + 0x12)
	obj.pos_x         = get_x(memory.readwordsigned(obj.base + 0x06))
	obj.pos_y         = get_y(memory.readwordsigned(obj.base + 0x0A))
	obj.animation_ptr = memory.readdword(obj.base + 0x1A)
	obj.hitbox_ptr    = memory.readdword(obj.base + 0x34)

	for entry in ipairs(game.box_list) do
		table.insert(obj, define_box(obj, game.box_list[entry]))
	end
end


local function read_projectiles()
	local current_projectiles = {}

	for i = 1, MAX_GAME_PROJECTILES do
		local obj = {base = game.address.projectile + (i-1) * 0xC0}
		if memory.readword(obj.base) == 0x0101 then
			obj.projectile = true
			update_game_object(obj)
			table.insert(current_projectiles, obj)
		end
	end

	for i = 1, MAX_BONUS_OBJECTS do
		local obj = {base = game.address.projectile + (MAX_GAME_PROJECTILES + i-1) * 0xC0}
		if bit.band(0xFF00, memory.readword(obj.base)) == 0x0100 then
			update_game_object(obj)
			table.insert(current_projectiles, obj)
		end
	end

	return current_projectiles
end


local function adjust_delay(stage_address)
	if not stage_address or not mame then
		return 0
	end
	local stage_lag = {
		[0x0] = 0, --Ryu
		[0x1] = 0, --E.Honda
		[0x2] = 0, --Blanka
		[0x3] = 0, --Guile
		[0x4] = 0, --Ken
		[0x5] = 0, --Chun Li
		[0x6] = 0, --Zangief
		[0x7] = 0, --Dhalsim
		[0x8] = 0, --Dictator
		[0x9] = 0, --Sagat
		[0xA] = 1, --Boxer*
		[0xB] = 0, --Claw
		[0xC] = 1, --Cammy*
		[0xD] = 1, --T.Hawk*
		[0xE] = 0, --Fei Long
		[0xF] = 1, --Dee Jay*
	}
	return stage_lag[bit.band(memory.readword(stage_address), 0xF)]
end


local function update_hitboxes()
	if not game then
		return
	end
	local effective_delay = DRAW_DELAY + adjust_delay(game.address.stage)
	update_globals()

	for f = 1, effective_delay do
		frame_buffer[f].match_active = frame_buffer[f+1].match_active
		for p = 1, NUMBER_OF_PLAYERS do
			frame_buffer[f][player][p] = copytable(frame_buffer[f+1][player][p])
		end
		frame_buffer[f][projectiles] = copytable(frame_buffer[f+1][projectiles])
	end

	frame_buffer[effective_delay+1].match_active = globals.match_active
	for p = 1, NUMBER_OF_PLAYERS do
		player[p] = {base = game.address.player + (p-1) * game.player_space}
		if memory.readword(player[p].base) > 0x0100 then
			update_game_object(player[p])
		end
		frame_buffer[effective_delay+1][player][p] = player[p]

		local prev_frame = frame_buffer[effective_delay][player][p]
		if prev_frame and prev_frame.pos_x then
			for entry in ipairs(game.throw_box_list) do
				table.insert(prev_frame, define_throw_box(prev_frame, game.throw_box_list[entry]))
			end
		end

	end
	frame_buffer[effective_delay+1][projectiles] = read_projectiles()
end

emu.registerafter( function()
	update_hitboxes()
end)


--------------------------------------------------------------------------------
-- draw the hitboxes

local function draw_hitbox(obj, entry)
	local hb = obj[entry]
	if (not globals.draw_pushboxes and hb.type == "push") or
		(not globals.draw_throwable_boxes and hb.type == "throwable") then
		return
	end

	if globals.draw_mini_axis then
		gui.drawline(hb.hval, hb.vval-globals.mini_axis_size, hb.hval, hb.vval+globals.mini_axis_size, boxes[hb.type].outline)
		gui.drawline(hb.hval-globals.mini_axis_size, hb.vval, hb.hval+globals.mini_axis_size, hb.vval, boxes[hb.type].outline)
	end

	gui.box(hb.left, hb.top, hb.right, hb.bottom, boxes[hb.type].fill, boxes[hb.type].outline)
end


local function draw_axis(obj)
	if not obj or not obj.pos_x then
		return
	end
	
	gui.drawline(obj.pos_x, obj.pos_y-globals.axis_size, obj.pos_x, obj.pos_y+globals.axis_size, globals.axis_color)
	gui.drawline(obj.pos_x-globals.axis_size, obj.pos_y, obj.pos_x+globals.axis_size, obj.pos_y, globals.axis_color)
	--gui.text(obj.pos_x, obj.pos_y, string.format("%06X",obj.base)) --debug
end


local function render_hitboxes()
	gui.clearuncommitted()
	if not game or not frame_buffer[1].match_active then
		return
	end

	if globals.blank_screen then
		gui.box(0, 0, emu.screenwidth(), emu.screenheight(), globals.blank_color)
	end

	for entry = 1, game.box_number do
		for p = 1, #frame_buffer[1][projectiles] do
			local obj = frame_buffer[1][projectiles][p]
			if obj[entry] then
				draw_hitbox(obj, entry)
			end
		end

		for p = 1, NUMBER_OF_PLAYERS do
			local obj = frame_buffer[1][player][p]
			if obj and obj[entry] then
				draw_hitbox(obj, entry)
			end
		end
	end

	if globals.draw_axis then
		for p  = 1, #frame_buffer[1][projectiles] do
			draw_axis(frame_buffer[1][projectiles][p])
		end

		for p = 1, NUMBER_OF_PLAYERS do
			draw_axis(frame_buffer[1][player][p])
		end
	end
end


gui.register( function()
	render_hitboxes()
end)


--------------------------------------------------------------------------------
-- hotkey functions

input.registerhotkey(1, function()
	globals.blank_screen = not globals.blank_screen
	render_hitboxes()
	print((globals.blank_screen and "activated" or "deactivated") .. " blank screen mode")
end)


input.registerhotkey(2, function()
	globals.draw_axis = not globals.draw_axis
	render_hitboxes()
	print((globals.draw_axis and "showing" or "hiding") .. " object axis")
end)


input.registerhotkey(3, function()
	globals.draw_mini_axis = not globals.draw_mini_axis
	render_hitboxes()
	print((globals.draw_mini_axis and "showing" or "hiding") .. " hitbox axis")
end)


input.registerhotkey(4, function()
	globals.draw_pushboxes = not globals.draw_pushboxes
	render_hitboxes()
	print((globals.draw_pushboxes and "showing" or "hiding") .. " pushboxes")
end)


input.registerhotkey(5, function()
	globals.draw_throwable_boxes = not globals.draw_throwable_boxes
	render_hitboxes()
	print((globals.draw_throwable_boxes and "showing" or "hiding") .. " throwable boxes")
end)


--------------------------------------------------------------------------------
-- initialize on game startup

local function initialize()
	globals.left_screen_edge = 0
	globals.top_screen_edge  = 0
	for p = 1, NUMBER_OF_PLAYERS do
		player[p] = {}
	end
	for f = 1, DRAW_DELAY + 2 do
		frame_buffer[f] = {}
		frame_buffer[f][player] = {}
		frame_buffer[f][projectiles] = {}
	end
end


local function whatgame()
	print()
	game = nil
	for _, module in ipairs(profile) do
		for _, shortname in ipairs(module.games) do
			if emu.romname() == shortname or emu.parentname() == shortname then
				print("drawing " .. emu.romname() .. " hitboxes")
				game = module
				initialize()
				return
			end
		end
	end
	print("not prepared for " .. emu.romname() .. " hitboxes")
end


savestate.registerload(function()
	initialize()
end)


emu.registerstart( function()
	whatgame()
end)