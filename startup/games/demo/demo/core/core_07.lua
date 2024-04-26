local ecs = ...
local ImGui     = require "imgui"
local mgr = require "data_mgr"
local tbParam = 
{
    ecs             = ecs,
    system_name     = "core_07_system",
    category        = mgr.type_core,
    name            = "07_ecs",
    file            = "core/core_07.lua",
    ok              = true
}
local system = mgr.create_system(tbParam)
local draw_color_text = require 'utils.draw_color_text'
local dep = require 'dep'
local tb_desc = {}

tb_desc[1] = [[
-----------------------------------------------------------------------------
-- 规则说明
-----------------------------------------------------------------------------
import_feature: 导入其他包内的特性，即依赖
	*用法: 
		import_feature "ant.scene"

pipeline: 定义pipeline 
	*方法1: .stage, 定义策略阶段
	*用法: 
		pipeline "animation" 
			.stage "animation_state"
			.stage "animation_playback"

policy: 定义策略,策略是组件的集合, 用于实例化entity
	*方法1: .component "animation", 表示给策划加组件
	*方法2: .include_policy "ant.scene|scene_object", 表示可以包含子策略
	*用法: 
		policy "animation" 
			.component "animation" 
			.include_policy "ant.scene|scene_object"

component: 定义组件,需要指定组件是c还是lua, 组件有哪些属性, 组件的实现文件
	*说明: 当组件没有属性时, 退化为tag
	*用法:
		component "render_object"
			.type "c"
			.field "worldmat:userdata|math_t"
			.implement "render_system/render_object.lua"

system: 定义系统
	*用法:
		system "animation_system"
			.implement "animation.lua"

feature: 导入本包内其他featire
	*用法: 
		feature "debug_material"
			.import "debug_material.ecs"

-----------------------------------------------------------------------------
-- 以下为完整示例:
-----------------------------------------------------------------------------
-- ant.animation/package.ecs

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

tb_desc[2] =
[[
-- world相关接口
do
	local ecs = import_package "ant.ecs"
	-- 创建ecs world
	local world = ecs.new_world({ ecs = { feature = {} } })

	-- world 大部分接口在 ant.ecs/main.lua

	-- 创建entity 
	-- entiy构建是异步的, 调用create接口后, 只会返回一个id, 但entity还不可用
	-- 可以在entity_init这个stage中 通过 world:select "INIT component_name:update" 筛选出刚刚创建出来的包含component_name的组件, 执行初始化
	-- 此处INIT是一个引擎定义的ecs tag, 只会存在一帧
	-- 当所有entity_init stage执行完后, 才会依次调用on_ready 函数
	world:create_entity()
	world:create_instance()

	-- 销毁entity 
	-- 对于由create_instance创建出来的entity列表, 可以由remove_entiy分批次销毁
	-- entity id唯一, 重复销毁不会出问题
	-- entity销毁是异步的, 在当前帧末尾才真正销毁
	-- 如果要在销毁时做事情, 需要加一个叫 entity_remove 的stage, 在里面通过 world:select "REMOVE component_name:in" 
	-- 筛选出当前帧被删除的组件，并作收尾处理
	-- 此处REMOVE是引擎定义的ecs tag, 所有当前帧被移除的entity 都由这个tag
	-- entity id 是64位的
	world:remove_instance(instance)
	world:remove_entity()

	-- instance里面可以有一组entity
	-- 对使用create_entity()创建出来的entity发送消息
	-- 对使用create_instance()创建出来的instance发送消息
	world:entity_message()
	world:instance_message()

	-- 3个主要 pipeline 接口
	world:pipeline_init()
	world:pipeline_update()
	world:pipeline_exit()

	world:remove_template(filename)
	world:group_enable_tag(tag, id)
	world:group_disable_tag(tag, id)
	world:group_flush(tag)
	world:instance_set_parent()

	-- entity 遍历说明
	-- clear temp component from all entities
	world:clear "temp"

	-- Iterate the entity with visible/value/output components and without readonly component
	-- Create temp component for each.
	for v in w:select "visible readonly:absent value:in output:out temp:new" do
		v.output = v.value + 1
		v.temp = v.value
	end

	-- 形式: component_name[:?]action, actin有以下取值 
	in : read the component
	out : write the component
	update : read / write
	absent : check if the component is not exist
	exist (default) : check if the component is exist
	new : create the component
	? means it's an optional action if the component is not exist

	world:import_feature(name)
	world:enable_system(name)
	world:disable_system(name)

	-- 消息通信接口
	local event_mb = world:sub {"test_event_group", "event_name"}
	world:unsub(event_mb)
	world:dispatch_message { type = "update" }
end 


-- entity相关接口
do 
	-- 扩展entity e, 申请读取keyframe组件
	w:extend(e, "keyframe:in")
	-- 扩展e, 申请读取value, 写入name 权限
	w:extend(e, "value:in name:out")
	-- 扩展e, 如果有value组件就申请写入权限
	w:extend(v, "value?in")

	-- 提交entity的修改
	w:submit(e)
end

]]

tb_desc[3] =
[[
-----------------------------------------------------------------------------
-- 接口说明
-----------------------------------------------------------------------------
激活系统
	world:disable_system("demo|core_07_system")

禁用系统
	world:enable_system("demo|core_07_system")

]]

local tbMenu = {
	"package.ecs文件解读",
	"ecs概述",
	"system使用"
}
local curMenuIndex
local tb_lines

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
    if ImGui.Begin("window_body", nil, ImGui.WindowFlags {"NoResize", "NoMove", "NoScrollbar", "NoScrollWithMouse", "NoCollapse", "NoTitleBar"}) then 
		-- 菜单
		local scale = mgr.get_dpi_scale()
		local btn_len  = 150 * scale
		ImGui.BeginGroup()
		for i, v in ipairs(tbMenu) do 
			set_btn_style(i == curMenuIndex)
			if ImGui.ButtonEx(v, btn_len) or not curMenuIndex then 
				local idx = i
				if not curMenuIndex then
					idx = tonumber(dep.common.user_data.get("core_07_index", i)) or i
				end
				curMenuIndex = idx;
				tb_lines = draw_color_text.convert(tb_desc[idx])
				dep.common.user_data.set("core_07_index", idx, true)
			end	
			ImGui.PopStyleColorEx(4)
			ImGui.PopStyleVar()
		end
		ImGui.EndGroup()
		
		ImGui.SetCursorPos(btn_len + 15, 0)
		local x, y = ImGui.GetContentRegionAvail()
		ImGui.BeginChild("wnd_content", x + 8, y + 13, ImGui.ChildFlags({"Border"}), ImGui.WindowFlags {  })
		draw_color_text.draw(tb_lines)
        ImGui.EndChild()
	end
	ImGui.End()
end