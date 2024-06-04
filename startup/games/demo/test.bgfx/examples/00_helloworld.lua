local ecs       = ...
local world     = ecs.world
local bgfx      = require "bgfx"	---@type bgfx
local math3d    = require "math3d"
local layoutmgr = require "layoutmgr"
local sampler   = require "sampler"
local platform  = require "bee.platform"
local OS        = platform.os

local utils		= require 'utils' ---@type test.bfgx.utils
local ROOT<const> = utils.Root
local caps = bgfx.get_caps()
local renderer<const> = caps.rendererType

local is = ecs.system "init_system"

local ImGui 		= require "imgui"

local mesh = {
    ib = {
        handle = bgfx.create_index_buffer(
            bgfx.memory_buffer("w", {0, 1, 2, 2, 3, 0})
            ),
        start = 0,
        num = 6,
    },
    vb = {
        handle = bgfx.create_vertex_buffer(
            bgfx.memory_buffer("fff", {
                -1,-1, 0,
                -1, 1, 0,
                 1, 1, 0,
                 1,-1, 0,
            }), layoutmgr.get "p3".handle, ""
        ),
        start = 0,
        num = 4,
    }
}

local function create_uniform(h, mark)
    local name, type, num = bgfx.get_uniform_info(h)
    if mark[name] then
        return
    end
    mark[name] = true
    return { handle = h, name = name, type = type, num = num }
end

local function uniform_info(shader, uniforms, mark)
    local shaderuniforms = bgfx.get_shader_uniforms(shader)
    if shaderuniforms then
        for _, h in ipairs(shaderuniforms) do
            uniforms[#uniforms+1] = create_uniform(h, mark)
        end
    end
end

local function create_render_program(vs, fs)
    local prog = bgfx.create_program(vs, fs, false)
    if prog then
        local uniforms = {}
        local mark = {}
        uniform_info(vs, uniforms, mark)
        if fs then
            uniform_info(fs, uniforms, mark)
        end
        return prog, uniforms
    else
        error(string.format("create program failed, vs:%d, fs:%d", vs, fs))
    end
end

local function read_file(filename)
	print("load file", filename)
    local f<close> = io.open(filename, "rb")
    return assert(f):read "a"
end

local function load_shader(shaderfile)
    local h = bgfx.create_shader(read_file(shaderfile))
    bgfx.set_name(h, shaderfile)
    return h
end


local material = {
    depth = {
        shader = {},
        state = bgfx.make_state {
            ALPHA_REF = 0,
            CULL = "CCW",
            DEPTH_TEST = "LESS",
            MSAA = true,
            WRITE_MASK = "Z",
        }
    },
    mesh = {
        shader = {},
        state = bgfx.make_state {
            ALPHA_REF = 0,
            CULL = "CCW",
            DEPTH_TEST = "EQUAL",
            MSAA = true,
            WRITE_MASK = "RGBA",
        },
        simple_state = bgfx.make_state {
            ALPHA_REF = 0,
            CULL = "CCW",
            DEPTH_TEST = "LEQUAL",
            MSAA = true,
            WRITE_MASK = "RGBAZ",
        },
    },
    fullscreen = {
        shader = {},
        state = bgfx.make_state {
            ALPHA_REF = 0,
            CULL = "CW",
            DEPTH_TEST = "ALWAYS",
            MSAA = true,
            PT = "TRISTRIP",
            WRITE_MASK = "RGBA"
        }
    }
}

local function load_program(shader, vsfile, fsfile)
    local vshandle = load_shader(vsfile)
    local fshandle
    if fsfile then
        fshandle = load_shader(fsfile)
    end
    shader.prog, shader.uniforms = create_render_program(vshandle, fshandle)
end

local function shader_path(name)
    return (ROOT .. "/shaders/bin/%s/%s/%s"):format(OS, renderer:lower(), name)
end

load_program(material.mesh.shader,          shader_path "vs_mesh.bin", shader_path "fs_mesh.bin")
load_program(material.fullscreen.shader,    shader_path "vs_quad.bin", shader_path "fs_quad.bin")
load_program(material.depth.shader,         shader_path "vs_mesh.bin")

local function create_tex2d(filename, flags)
    local f = read_file(filename)
    local h = bgfx.create_texture(f, flags)
    bgfx.set_name(h, filename)
    return h
end

local texhandle = create_tex2d(ROOT .. "/textures/2x2.dds", sampler{
    MIN="LINEAR",
    MAG="LINEAR",
    U="CLAMP",
    V="CLAMP",
    COLOR_SPACE="sRGB",
})


local viewid = 2

function is:init()
	local window = require "window"
    window.set_title("Ant Game Engine 学习记录 - bgfx_01_helloworld")
end

local fb_size = {w=world.args.width, h=world.args.height}

local function create_fb1(rbs, viewid)
    local fbhandle = bgfx.create_frame_buffer(rbs, true)
    bgfx.set_view_frame_buffer(viewid, fbhandle)
    return viewid, {handle = fbhandle, rb_handles=rbs}
end

local function create_fb(rbs, viewid)
    local handles = {}
    for _, rb in ipairs(rbs) do
        handles[#handles+1] = bgfx.create_texture2d(rb.w, rb.h, false, rb.layers, rb.format, rb.flags)
    end

    return create_fb1(handles, viewid)
end
local sampleflag = sampler{
    RT = "RT_ON",
    MIN="LINEAR",
    MAG="LINEAR",
    U="CLAMP",
    V="CLAMP",
}

local depth_viewid, depth_fb = create_fb({
    {
        w = fb_size.w,
        h = fb_size.h,
        format = "D24S8",
        layers = 1,
        flags = sampleflag,
    },
}, 0)

local fb_viewid, fb = create_fb1({
    bgfx.create_texture2d(
        fb_size.w,
        fb_size.h,
        false,
        1,
        "RGBA16F",
        sampleflag), depth_fb.rb_handles[1]}, 1)

local function test_fb(viewmat, projmat)
    bgfx.touch(depth_viewid)
    bgfx.set_view_clear(depth_viewid, "D", 0, 1.0, 0.0)
    bgfx.set_view_transform(depth_viewid, viewmat, projmat)
    bgfx.set_view_rect(depth_viewid, 0, 0, fb_size.w, fb_size.h)
    bgfx.set_state(material.depth.state)
    bgfx.set_vertex_buffer(0, mesh.vb.handle, mesh.vb.start, mesh.vb.num)
    bgfx.set_index_buffer(mesh.ib.handle, mesh.ib.start, mesh.ib.num)
    bgfx.submit(depth_viewid, material.depth.shader.prog, 0)

    bgfx.touch(fb_viewid)
    bgfx.set_view_clear(fb_viewid, "C", 0x000000ff, 1.0, 0.0)
    bgfx.set_view_transform(fb_viewid, viewmat, projmat)
    bgfx.set_view_rect(fb_viewid, 0, 0, fb_size.w, fb_size.h)
    bgfx.set_state(material.mesh.state)
    bgfx.set_vertex_buffer(0, mesh.vb.handle, mesh.vb.start, mesh.vb.num)
    bgfx.set_index_buffer(mesh.ib.handle, mesh.ib.start, mesh.ib.num)
    
    bgfx.submit(fb_viewid, material.mesh.shader.prog, 0)

    bgfx.touch(viewid)
    bgfx.set_view_rect(viewid, 0, 0, fb_size.w, fb_size.h)
    bgfx.set_state(material.fullscreen.state)
    bgfx.set_vertex_buffer(0, mesh.vb.handle, 0, 3)
    bgfx.set_texture(0, material.fullscreen.shader.uniforms[1].handle, fb.rb_handles[1])
    bgfx.submit(viewid, material.fullscreen.shader.prog, 0)
end

local function find_uniform(shader, name)
    for _, u in ipairs(shader.uniforms) do
        if u.name == name then
            return u.handle
        end
    end
end

local function draw_simple_mode(viewmat, projmat)
    --bgfx.touch(viewid)
    bgfx.set_view_clear(viewid, "CD", 0x808080ff, 1.0, 0.0)
    bgfx.set_view_transform(viewid, viewmat, projmat)
    bgfx.set_view_rect(viewid, 0, 0, fb_size.w, fb_size.h)

    bgfx.set_state(material.mesh.simple_state)
    bgfx.set_vertex_buffer(0, mesh.vb.handle, mesh.vb.start, mesh.vb.num)
    bgfx.set_index_buffer(mesh.ib.handle, mesh.ib.start, mesh.ib.num)
    
    bgfx.submit(viewid, material.mesh.shader.prog, 0)
end

local clicked = false;
function is:data_changed()
	ImGui.SetNextWindowPos(50, 200, ImGui.Cond.FirstUseEver)
	ImGui.SetNextWindowSize(300, 200, ImGui.Cond.FirstUseEver);

	local window_flag = ImGui.WindowFlags {"NoScrollbar", "NoScrollWithMouse"}
	if ImGui.Begin("window_body", nil, window_flag) then 
		ImGui.Text("hell world.")
		if ImGui.Button("test button") then 
			clicked = not clicked
		end
		if clicked then 
			ImGui.SameLine()
			ImGui.Text("click me")
		end
	end
	ImGui.End()
end


local s_logo
function is:update()
    bgfx.touch(viewid)	
	bgfx.set_debug("T")
	bgfx.set_view_rect(viewid, 0, 0, fb_size.w, fb_size.h)
	bgfx.set_view_clear(viewid, "CD", 0x0, 1.0, 0.0)

    -- local viewmat = math3d.value_ptr(math3d.lookat(math3d.vector(0, 0, -10), math3d.vector(0, 0, 0), math3d.vector(0, 1, 0)))
    -- local projmat = math3d.value_ptr(math3d.projmat{aspect=fb_size.w/fb_size.h, fov=90, n=0.01, f=100})

    -- local colorhandle = find_uniform(material.mesh.shader, "u_color")
    -- if colorhandle then
    --     bgfx.set_uniform(colorhandle, math3d.value_ptr(math3d.vector(0.5, 0.5, 0.5, 1.0)))
    -- end

    -- local tex = find_uniform(material.mesh.shader, "s_tex")
    -- if tex then
    --     bgfx.set_texture(0, tex, texhandle)
    -- end
    -- draw_simple_mode(viewmat, projmat)
	bgfx.dbg_text_clear()

	local stats = bgfx.get_stats("sd")
	bgfx.dbg_text_image(
		math.max(stats.textWidth // 2, 20) - 20, 	-- // 表示 整除运算符，比如 5//2 输出结果 2
		math.max(stats.textHeight // 2, 6) - 6, 
		40, 
		12, 
		s_logo, 
		160
	)

	bgfx.dbg_text_print(0, 0, 0x0f, "Color can be changed with ANSI \x1b[9;me\x1b[10;ms\x1b[11;mc\x1b[12;ma\x1b[13;mp\x1b[14;me\x1b[0m code too.");
	
	bgfx.dbg_text_print(80, 1, 0x0f, "\x1b[;0m    \x1b[;1m    \x1b[; 2m    \x1b[; 3m    \x1b[; 4m    \x1b[; 5m    \x1b[; 6m    \x1b[; 7m    \x1b[0m")
	bgfx.dbg_text_print(80, 2, 0x0f, "\x1b[;8m    \x1b[;9m    \x1b[;10m    \x1b[;11m    \x1b[;12m    \x1b[;13m    \x1b[;14m    \x1b[;15m    \x1b[0m");

	bgfx.dbg_text_print(0, 1, 0x0f, string.format("Backbuffer %dW x %dH in pixels, debug text %dW x %dH in characters.",
		stats.width, stats.height, stats.textWidth, stats.textHeight));
end

s_logo = "\z
	\xdc\x03\xdc\x03\xdc\x03\xdc\x03\x20\x0f\x20\x0f\x20\x0f\x20\x0f\z
	\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\z
	\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\xdc\x08\z
	\xdc\x03\xdc\x07\xdc\x07\xdc\x08\x20\x0f\x20\x0f\x20\x0f\x20\x0f\z
	\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\z
	\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\z
	\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\z
	\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\z
	\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\z
	\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\z
	\xde\x03\xb0\x3b\xb1\x3b\xb2\x3b\xdb\x3b\x20\x0f\x20\x0f\x20\x0f\z
	\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\z
	\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\xdc\x03\xb1\x3b\xb2\x3b\z
	\xdb\x3b\xdf\x03\xdf\x3b\xb2\x3f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\z
	\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\z
	\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\z
	\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\z
	\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\z
	\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\z
	\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\z
	\x20\x0f\xb1\x3b\xb1\x3b\xb2\x3b\xb2\x3f\x20\x0f\x20\x0f\x20\x0f\z
	\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\z
	\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\xb1\x3b\xb1\x3b\xb2\x3b\z
	\xb2\x3f\x20\x0f\x20\x0f\xdf\x03\x20\x0f\x20\x0f\x20\x0f\x20\x0f\z
	\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\z
	\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\z
	\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\z
	\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\z
	\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\z
	\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\z
	\x20\x0f\xb1\x3b\xb1\x3b\xb1\x3b\xb1\x3f\xdc\x0b\xdc\x03\xdc\x03\z
	\xdc\x03\xdc\x03\x20\x0f\x20\x0f\xdc\x08\xdc\x03\xdc\x03\xdc\x03\z
	\xdc\x03\xdc\x03\xdc\x03\xdc\x08\x20\x0f\xb1\x3b\xb1\x3b\xb1\x3b\z
	\xb1\x3f\xb1\x3f\xb2\x0b\x20\x0f\x20\x0f\xdc\x03\xdc\x03\xdc\x03\z
	\x20\x0f\x20\x0f\xdc\x03\xdc\x03\xdc\x03\x20\x0f\x20\x01\x20\x0f\z
	\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\z
	\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\z
	\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\z
	\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\z
	\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\z
	\x20\x0f\xb2\x3b\xb1\x3b\xb0\x3b\xb0\x3f\x20\x0f\xde\x03\xb0\x3f\z
	\xb1\x3f\xb2\x3f\xdd\x03\xde\x03\xdb\x03\xdb\x03\xb2\x3f\x20\x0f\z
	\x20\x0f\xb0\x3f\xb1\x3f\xb2\x3f\xde\x38\xb2\x3b\xb1\x3b\xb0\x3b\z
	\xb0\x3f\x20\x0f\x20\x0f\x20\x0f\xb0\x3b\xb1\x3b\xb2\x3b\xb2\x3f\z
	\xdd\x03\xde\x03\xb0\x3f\xb1\x3f\xb2\x3f\xdd\x03\x20\x01\x20\x0f\z
	\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\z
	\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\z
	\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\z
	\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\z
	\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\z
	\x20\x0f\xb2\x3b\xb1\x3b\xb0\x3b\xb0\x3f\x20\x0f\x20\x0f\xdb\x03\z
	\xb0\x3f\xb1\x3f\xdd\x03\xb1\x3b\xb0\x3b\xdb\x03\xb1\x3f\x20\x0f\z
	\x20\x0f\x20\x3f\xb0\x3f\xb1\x3f\xb0\x3b\xb2\x3b\xb1\x3b\xb0\x3b\z
	\xb0\x3f\x20\x0f\x20\x0f\x20\x0f\xdc\x08\xdc\x3b\xb1\x3b\xb1\x3f\z
	\xb1\x3b\xb0\x3b\xb2\x3b\xb0\x3f\xdc\x03\x20\x0f\x20\x01\x20\x0f\z
	\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\z
	\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\z
	\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\z
	\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\z
	\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\z
	\x20\x0f\xb2\x3b\xb1\x3b\xb0\x3b\xb0\x3f\xdc\x0b\xdc\x07\xdb\x03\z
	\xdb\x03\xdc\x38\x20\x0f\xdf\x03\xb1\x3b\xb0\x3b\xb0\x3f\xdc\x03\z
	\xdc\x07\xb0\x3f\xb1\x3f\xb2\x3f\xdd\x3b\xb2\x3b\xb1\x3b\xdc\x78\z
	\xdf\x08\x20\x0f\x20\x0f\xde\x08\xb2\x3b\xb1\x3b\xb0\x3b\xb0\x3f\z
	\x20\x0f\xdf\x03\xb1\x3b\xb2\x3b\xdb\x03\xdd\x03\x20\x01\x20\x0f\z
	\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\z
	\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\z
	\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\z
	\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\z
	\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\z
	\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\z
	\x20\x0f\x20\x0f\x20\x0f\x20\x0f\xdc\x08\xdc\x08\xdc\x08\x20\x0f\z
	\x20\x0f\xb0\x3f\xb0\x3f\xb1\x3f\xdd\x3b\xdb\x0b\xdf\x03\x20\x0f\z
	\x20\x0f\x20\x0f\x20\x0f\x20\x0f\xdf\x08\xdf\x03\xdf\x03\xdf\x08\z
	\x20\x0f\x20\x0f\xdf\x08\xdf\x03\xdf\x03\x20\x0f\x20\x01\x20\x0f\z
	\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\z
	\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\z
	\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\z
	\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\z
	\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\z
	\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\z
	\x20\x0f\x20\x0f\x20\x0f\x20\x0f\xdb\x08\xb2\x38\xb1\x38\xdc\x03\z
	\xdc\x07\xb0\x3b\xb1\x3b\xdf\x3b\xdf\x08\x20\x0f\x20\x0f\x20\x0f\z
	\x20\x0b\x20\x0b\x20\x0b\x20\x0b\x20\x0b\x20\x0b\x20\x0b\x20\x0b\z
	\x20\x0b\x20\x0b\x20\x0b\x20\x0b\x20\x0b\x20\x0b\x20\x0b\x20\x0b\z
	\x20\x0b\x20\x0b\x20\x0b\x20\x0b\x20\x0b\x20\x0b\x20\x0b\x20\x0b\z
	\x20\x0b\x20\x0b\x20\x0b\x20\x0b\x20\x0b\x20\x0b\x20\x0b\x20\x0b\z
	\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\z
	\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\z
	\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\z
	\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0b\x20\x0b\x20\x0b\x20\x0b\z
	\x20\x0b\x20\x0b\x20\x0b\x20\x0b\x20\x0b\x20\x0b\x20\x0b\x20\x0b\z
	\x20\x0b\x20\x0b\x20\x0b\x20\x0b\x20\x0b\x20\x0b\x20\x0b\x20\x0b\z
	\x20\x0b\x20\x0b\x20\x0b\x20\x0b\x20\x0b\x20\x0b\x20\x0b\x20\x0b\z
	\x20\x0b\x20\x0b\x20\x0b\x20\x0b\x20\x0f\x20\x0f\x20\x0f\x20\x0f\z
	\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\z
	\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\z
	\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\z
	\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\z
	\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\z
	\x2d\x08\x3d\x08\x20\x0a\x43\x0b\x72\x0b\x6f\x0b\x73\x0b\x73\x0b\z
	\x2d\x0b\x70\x0b\x6c\x0b\x61\x0b\x74\x0b\x66\x0b\x6f\x0b\x72\x0b\z
	\x6d\x0b\x20\x0b\x72\x0b\x65\x0b\x6e\x0b\x64\x0b\x65\x0b\x72\x0b\z
	\x69\x0b\x6e\x0b\x67\x0b\x20\x0b\x6c\x0b\x69\x0b\x62\x0b\x72\x0b\z
	\x61\x0b\x72\x0b\x79\x0b\x20\x0f\x3d\x08\x2d\x08\x20\x01\x20\x0f\z
	\x20\x0a\x20\x0a\x20\x0a\x20\x0a\x20\x0a\x20\x0a\x20\x0a\x20\x0a\z
	\x20\x0a\x20\x0a\x20\x0a\x20\x0a\x20\x0a\x20\x0a\x20\x0a\x20\x0a\z
	\x20\x0a\x20\x0a\x20\x0a\x20\x0a\x20\x0a\x20\x0a\x20\x0a\x20\x0a\z
	\x20\x0a\x20\x0a\x20\x0a\x20\x0a\x20\x0a\x20\x0a\x20\x0a\x20\x0a\z
	\x20\x0a\x20\x0a\x20\x0a\x20\x0a\x20\x0a\x20\x0a\x20\x0a\x20\x0a\z
	\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\z
	\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\z
	\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\z
	\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\z
	\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\z
	\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\z
	\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\z
	\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\z
	\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\z
	\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\z
	\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\z
	\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\z
	\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\z
	\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\z
	\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\z
	\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\z
	\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\z
	\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\z
	\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\z
	\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\z
	\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\z
	\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\z
	\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\z
	\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\z
	\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\z
	\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\z
	\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\z
	\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\z
	\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\z
	\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\z
	\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\z
	\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\z
	\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\z
	\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\z
	\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\z
	\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\z
	\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\z
	\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\z
	\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\z
	\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\z
	\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\z
	\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\z
	\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\z
	\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\z
	\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\z
	\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\z
	\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\z
	\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\z
	\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\z
	\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\z
	\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\z
	\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\z
	\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\z
	\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\z
	\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\z
	\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\z
	\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\z
	\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\z
	\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\z
	\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\z
	\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\z
	\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\z
	\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\z
	\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\z
	\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\z
	\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\z
	\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\z
	\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\z
	\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\z
	\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\z
	\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\z
	\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\z
	\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\z
	\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\z
	\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\z
	\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\z
	\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\z
	\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\z
	\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\z
	\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\z
	\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\z
	\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\z
	\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\z
	\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\z
	\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\z
	\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\z
	\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\z
	\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\z
	\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\z
	\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\z
	\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\z
	\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\z
	\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\z
	\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\z
	\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\z
	\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\z
	\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\z
	\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\z
	\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\z
	\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\z
	\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\z
	\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\z
	\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\z
	\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\z
	\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\z
	\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\z
	\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\z
	\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\z
	\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\z
	\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\z
	\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\z
	\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\z
	\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\z
	\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\z
	\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\z
	\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\z
	\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\z
	\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\z
	\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\z
	\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\z
	\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\z
	\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\z
	\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\z
	\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\z
	\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\z
	\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\z
	\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\z
	\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\z
	\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\z
	\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\z
	\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\z
	\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\z
	\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\z
	\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\z
	\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\z
	\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\z
	\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\z
	\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\z
	\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\z
	\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\x20\x0f\z
"
