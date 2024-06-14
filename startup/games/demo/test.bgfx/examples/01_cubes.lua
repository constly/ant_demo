local bgfx    = require "bgfx"	---@type bgfx
local ImGui 	= require "imgui"
local viewid = 2

local math3d    = require "math3d"
local utils		= require 'utils' ---@type test.bfgx.utils

---@type test.bgfx.example 
local api 		= {}
local ctx = {}
local time = 0;

local s_ptNames = {
	{"Triangle List", 	nil},
	{"Triangle Strip", 	"TRISTRIP"},
	{"Lines", 			"LINES"},
	{"Line Strip", 		"LINESTRIP"},
	{"Points",			"POINTS"},
}
local cur_combo = 1
local check_r = {true}
local check_g = {true}
local check_b = {true}
local check_a = {true}

function api.on_entry()
	ctx.prog = utils.load_program("vs_cubes.bin", "fs_cubes.bin")
	ctx.vdecl = bgfx.vertex_layout {
		{ "POSITION", 3, "FLOAT" },
		{ "COLOR0", 4, "UINT8", true },
	}
	local buf = bgfx.memory_buffer( 16 * 8)
	buf[1]    = string.pack("fffL", -1.0,  1.0,  1.0, 0xff000000)
	buf[16+1] = string.pack("fffL", 1.0,  1.0,  1.0, 0xff0000ff)
	buf[32+1] = string.pack("fffL", -1.0, -1.0,  1.0, 0xff00ff00)
	buf[48+1] = string.pack("fffL", 1.0, -1.0,  1.0, 0xff00ffff)
	buf[64+1] = string.pack("fffL", -1.0,  1.0, -1.0, 0xffff0000)
	buf[80+1] = string.pack("fffL", 1.0,  1.0, -1.0, 0xffff00ff)
	buf[96+1] = string.pack("fffL", -1.0, -1.0, -1.0, 0xffffff00)
	buf[112+1] = string.pack("fffL", 1.0, -1.0, -1.0, 0xffffffff)

	ctx.vb = bgfx.create_vertex_buffer(buf, ctx.vdecl)
	ctx.ib = {}

	-- cube triangle list
	ctx.ib[1] = bgfx.create_index_buffer {
		0, 1, 2, -- 0
		1, 3, 2,
		4, 6, 5, -- 2
		5, 6, 7,
		0, 2, 4, -- 4
		4, 2, 6,
		1, 5, 3, -- 6
		5, 7, 3,
		0, 4, 1, -- 8
		4, 5, 1,
		2, 3, 6, -- 10
		6, 3, 7,
	}

	-- cube triangle strip
	ctx.ib[2] = bgfx.create_index_buffer{
		0, 1, 2, 
		3, 7, 1, 5, 0, 4, 2, 6, 7, 4, 5,
	}

	-- cube line list
	ctx.ib[3] = bgfx.create_index_buffer {
		0, 1,
		0, 2,
		0, 4,
		1, 3,
		1, 5,
		2, 3,
		2, 6,
		3, 7,
		4, 5,
		4, 6,
		5, 7,
		6, 7,
	}

	-- cube line strip
	ctx.ib[4] = bgfx.create_index_buffer {
		0, 2, 3, 1, 5, 7, 6, 4,
		0, 2, 6, 4, 5, 7, 3, 1,
		0,
	}

	-- cube points
	ctx.ib[5] = bgfx.create_index_buffer {
		0, 1, 2, 3, 4, 5, 6, 7
	}

	bgfx.set_debug("PT")
	bgfx.dbg_text_clear()
end

function api.on_exit()
	bgfx.destroy(ctx.prog)
	for i, v in pairs(ctx.ib) do 
		bgfx.destroy(v)
	end
	bgfx.destroy(ctx.vb)
end

function api.on_resize()
	print("on_resize")
	local w, h = ContentSizeX, ContentSizeY
	bgfx.set_view_rect(viewid, ContentStartX, ContentStartY, w, h)
	bgfx.set_view_clear(viewid, "CD", 0x303030ff, 1, 0)
	
	local eyepos, at = math3d.vector(0,0,-35), math3d.vector(0, 0, 0)
	local viewmat = math3d.lookat(eyepos, at)
	local projmat = math3d.projmat { fov = 60, aspect = w/h , n = 0.1, f = 100 }
	bgfx.set_view_transform(viewid, viewmat, projmat)
end

function api.update(delta_time)
	local width = 180
	ImGui.SetNextWindowPos(Screen_Width - width, 0)
	ImGui.SetNextWindowSize(width, 250);
	local window_flag = ImGui.WindowFlags {"NoScrollbar", "NoScrollWithMouse", "NoTitleBar", "NoResize"}
	if ImGui.Begin("menu", nil, window_flag) then 
		ImGui.Checkbox("Write R##checkbox_r", check_r)
		ImGui.Checkbox("Write G##checkbox_g", check_g)
		ImGui.Checkbox("Write B##checkbox_b", check_b)
		ImGui.Checkbox("Write A##checkbox_a", check_a)

		ImGui.Text("Primitive topology:");
		ImGui.SetNextItemWidth(width - 10)
        if ImGui.BeginCombo("##combo_4", s_ptNames[cur_combo][1]) then
            for i, v in ipairs(s_ptNames) do
				local name = v[1]
                if ImGui.Selectable(name, name == cur_combo) then
                    cur_combo = i
                end
            end
            ImGui.EndCombo()
        end
	end
	ImGui.End()
	
	local mask = "Z"
	if check_r[1] then mask = mask .. "R" end
	if check_g[1] then mask = mask .. "G" end
	if check_b[1] then mask = mask .. "B" end
	if check_a[1] then mask = mask .. "A" end

	local state = bgfx.make_state({ 
		PT = s_ptNames[cur_combo][2], 
		MSAA = true, 
		CULL = "CW",
		DEPTH_TEST = "LESS",
		WRITE_MASK = mask,
	})	

	bgfx.touch(viewid)
	time = time + delta_time
	for yy = 0, 10 do
		for xx = 0, 10 do
			bgfx.set_transform { r = { time + xx*0.21, time + yy*0.37, 0 }, t = { -15.0 + xx * 3, -15.0 + yy * 3, 0 } }
			bgfx.set_vertex_buffer(ctx.vb)
			bgfx.set_index_buffer(ctx.ib[cur_combo])
			bgfx.set_state(state)
			bgfx.submit(viewid, ctx.prog)
		end
	end
end

return api