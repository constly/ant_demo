local bgfx    = require "bgfx"	---@type bgfx
local ImGui 	= require "imgui"
local viewid = 2

local math3d    = require "math3d"
local utils		= require 'utils' ---@type test.bfgx.utils

local api 		= {}
local ctx = {}
local time = 0;

local s_ptNames = {
	"Triangle List",
	"Triangle Strip",
	"Lines",
	"Line Strip",
	"Points",
}
local cur_combo = s_ptNames[1]

function api.on_entry()
	ctx.prog = utils.load_program("vs_cubes.bin", "fs_cubes.bin")

	ctx.state = bgfx.make_state({ PT = "TRISTRIP" } , nil)	-- from BGFX_STATE_DEFAULT
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
	ctx.ib = bgfx.create_index_buffer{
		0, 1, 2, 3, 7, 1, 5, 0, 4, 2, 6, 7, 4, 5,
	}
end

function api.on_exit()
	
end

function api.update(delta_time)
	local width = 150
	ImGui.SetNextWindowPos(Screen_Width - width, 0)
	ImGui.SetNextWindowSize(width, 300);

	local window_flag = ImGui.WindowFlags {"NoScrollbar", "NoScrollWithMouse", "NoTitleBar", "NoResize"}
	if ImGui.Begin("menu", nil, window_flag) then 
		ImGui.Text("11111111111111")
		ImGui.SetNextItemWidth(width)
        if ImGui.BeginCombo("##combo_4", cur_combo) then
            for i, name in ipairs(s_ptNames) do
                if ImGui.Selectable(name, name == cur_combo) then
                    cur_combo = name
                end
            end
            ImGui.EndCombo()
        end
	end
	ImGui.End()
	
	bgfx.set_debug("")
	bgfx.set_view_clear(viewid, "CD", 0x303030ff, 1, 0)

	local w, h = ContentSizeX, ContentSizeY
	bgfx.set_view_rect(viewid, ContentStartX, ContentStartY, w, h)
	bgfx.reset(w, h, "vmx")
	bgfx.dbg_text_clear()
	
	local eyepos, at = math3d.vector(0,0,-35), math3d.vector(0, 0, 0)
	local viewmat = math3d.lookat(eyepos, at)
	local projmat = math3d.projmat { fov = 60, aspect = w/h , n = 0.1, f = 100 }
	bgfx.set_view_transform(viewid, viewmat, projmat)

	bgfx.touch(viewid)
	time = time + delta_time
	for yy = 0, 10 do
		for xx = 0, 10 do
			bgfx.set_transform { r = { time + xx*0.21, time + yy*0.37, 0 }, t = { -15.0 + xx * 3, -15.0 + yy * 3, 0 } }
			bgfx.set_vertex_buffer(ctx.vb)
			bgfx.set_index_buffer(ctx.ib)
			bgfx.set_state(ctx.state)
			bgfx.submit(viewid, ctx.prog)
		end
	end
end

return api