local bgfx      = require "bgfx"		---@type bgfx
local bf 		= require "bee.filesystem"
print("current_path is:", bf.current_path())

--- 需要做一个桥接工作
--- https://github.com/ejoy/ant/discussions/167
local mathpkg 	= import_package "ant.math"

local platform  = require "bee.platform"
local OS        = platform.os
local caps 		= bgfx.get_caps()
local renderer<const> = caps.rendererType

---@class test.bfgx.utils
local api = {}

api.Root = "../ant_demo/startup/games/demo/test.bgfx"


function api.load_program(vsfile, fsfile)
	local function shader_path(name)
		return (api.Root .. "/shaders/bin/%s/%s/%s"):format(OS, renderer:lower(), name)
	end
	vsfile = shader_path(vsfile)
	fsfile = shader_path(fsfile)

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

    local vshandle = load_shader(vsfile)
    local fshandle
    if fsfile then
        fshandle = load_shader(fsfile)
    end
    return create_render_program(vshandle, fshandle)
end
return api