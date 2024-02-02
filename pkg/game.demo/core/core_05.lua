local ecs = ...
local ImGui = import_package "ant.imgui"
local ImGuiLegacy = require "imgui.legacy"
local mgr = require "data_mgr"
local tbParam = 
{
    ecs             = ecs,
    system_name     = "core_05_system",
    category        = mgr.type_core,
    name            = "05_ecs",
    file            = "core/core_05.lua",
    ok              = true
}
local system = mgr.create_system(tbParam)

local desc =
[[

local ecs   = ...
local world = ecs.world
local w     = world.w

-- 这个接口啥子意思
w:extend(e, "keyframe:in")

]]

-- ecs 文件说明
local desc2 = 
[[
ant.animation/package.ecs

	-- 表示运行依赖 pkg ant.scene
	import_feature "ant.scene"

	-- 定义pipeline 
	pipeline "animation"
		.stage "animation_state"
		.stage "animation_playback"
		.stage "animation_sample"
	
	-- 定义策略，用于创建entity
	-- 策略是组件的集合
	policy "animation"
		-- 继承的意思
		.include_policy "ant.scene|scene_object"
		-- entity身上挂载的组件
		.component "animation"
	
	-- 定义策略
	policy "skinning"
		.include_policy "ant.scene|scene_object"
		-- 某些组件的初始值可以由构造函数产生，不需要构造 entity 时外部提供
		-- 当构造一个带有 skinning 这个 policy 的 entity 时，就不需要在构造时给出 skinning 组件的初始数据。
		.component_opt "skinning"
	
	-- 定义策略
	policy "slot"
		-- 在 ant.scene|scene_object 的基础上增加了 slot 和 animation 两个组件
		.include_policy "ant.scene|scene_object"
		.component "slot"
		.component "animation"
	
	-- 定义组件，数据类型是lua
	component "animation".type "lua"

	-- 定义组件，由于没有值，会自动变为tag，在代码中，通过设置e.animation_changed = true or e.animation_changed = false 来开启或者关闭tag
	component "animation_changed"
	component "animation_playback"
	
	-- 定义lua组件
	component "slot".type "lua"
	
	-- 定义系统，预定义system名字为animation_system，代码实现在animation.lua中
	system "animation_system"
		.implement "animation.lua"

	-- 定义了一个C++实现的系统
	system "scenespace_system"
		-- : 表示由C++实现
		.implement ":system.scene"

	-- 定义复杂组件, 类型为C, Ant 的编译系统会利用这个定义生成一个 C 的 .h 文件供 C/C++ 代码使用
	-- 生成代码放在 clibs/ecs/ecs/component.hpp 中
	component "render_object"
		.type "c"
		.field "worldmat:userdata|math_t"
	
		--materials
		.field "rm_idx:dword"
	
		--visible
		.field "visible_idx:int"
		.field "cull_idx:int"
	
		--mesh
		.field "vb_start:dword"

		-- 组件会有构造方法等方法
		-- .implement 告诉了引擎，这些方法的实现放在哪个 lua 源文件中
		.implement "render_system/render_object.lua"

	-- 目录下可以定义多个ecs，系统只会默认加载package.ecs，其他的ecs需要通过下面的方式手动引入
	feature "debug_material"
		.import "debug_material.ecs"

	-- 这是注释	
	--system "slot_system"
	--    .implement "slot.lua"
	
]]

local tbMenu = {
	"package.ecs文件解读"
}
local curMenuIndex

local context = {
    text = "",
    flags = ImGui.InputTextFlags{"ReadOnly"},
}

local set_btn_style = function(current)
    if current then 
        ImGui.PushStyleColorImVec4(ImGui.Col.Button, 0.6, 0.6, 0.25, 1)
        ImGui.PushStyleColorImVec4(ImGui.Col.ButtonHovered, 0.5, 0.5, 0.25, 1)
        ImGui.PushStyleColorImVec4(ImGui.Col.ButtonActive, 0.5, 0.5, 0.25, 1) 
        ImGui.PushStyleColorImVec4(ImGui.Col.Text, 0.95, 0.95, 0.95, 1)
    else 
        ImGui.PushStyleColorImVec4(ImGui.Col.Button, 0.2, 0.2, 0.25, 1)
        ImGui.PushStyleColorImVec4(ImGui.Col.ButtonHovered, 0.3, 0.3, 0.3, 1)
        ImGui.PushStyleColorImVec4(ImGui.Col.ButtonActive, 0.25, 0.25, 0.25, 1)
        ImGui.PushStyleColorImVec4(ImGui.Col.Text, 0.95, 0.95, 0.95, 1)
    end
	ImGui.PushStyleVarImVec2(ImGui.StyleVar.ButtonTextAlign, 0, 0.5)
end

function system.data_changed()
	ImGui.SetNextWindowPos(mgr.get_content_start())
    ImGui.SetNextWindowSize(mgr.get_content_size())
    if ImGui.Begin("window_body", nil, ImGui.WindowFlags {"NoResize", "NoMove", "NoScrollbar", "NoCollapse", "NoTitleBar"}) then 
		-- 演示如何创建/删除/遍历entity
		-- 演示system的禁用 和 激活

		-- 菜单
		local scale = mgr.get_dpi_scale()
		local btn_len  = 150 * scale
		ImGui.BeginGroup()
		for i, v in ipairs(tbMenu) do 
			set_btn_style(i == curMenuIndex)
			if ImGui.Button(v, btn_len) or not curMenuIndex then 
				curMenuIndex = i;
				context.text = desc2
			end	
			ImGui.PopStyleColorEx(4)
			ImGui.PopStyleVar()
		end
		ImGui.EndGroup()
		

		ImGui.SetCursorPos(btn_len + 10, 5)
		ImGui.BeginGroup()
		context.width, context.height = ImGui.GetContentRegionAvail()
		ImGuiLegacy.InputTextMultiline("##show_text", context)
		ImGui.EndGroup()
	end
	ImGui.End()
end