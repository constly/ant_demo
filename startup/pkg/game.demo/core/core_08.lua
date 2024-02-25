local ecs = ...
local ImGui     = require "imgui"
local mgr = require "data_mgr"
local tbParam = 
{
    ecs             = ecs,
    system_name     = "core_08_system",
    category        = mgr.type_core,
    name            = "08_datalist",
    file            = "core/core_08.lua",
    ok              = true
}
local system = mgr.create_system(tbParam)
local dep = require 'dep'
local ImGuiExtend = dep.ImGuiExtend
local datalist = require 'datalist'
local stringify = import_package "ant.serialize".stringify


local desc = 
[[
gltf文件:
	1. GL传输格式的缩写, 是一种开源格式, glTF 支持动画、移动场景和静态模型
	2. glTF基于JSON, 而外部文件保存一些数据, 例如着色器(GLSL)或纹理(JPEG或PNG)
	
glb文件: 
	1. GL Binary, 基于glTF格式
	2. GLB 是 glTF 文件的单个二进制版本, 即将显示模型所需要的所有资产,包括纹理,材质,照明,动画等所有数据打包存储
	
gltf 和 glb 的区别
	1. 一个是二进制文件, 一个是json文本文件
	2. 一个是独立文件, 一个是散列文件


素材网站:
	1. [sketchfab](https://sketchfab.com/3d-models?date=week&features=downloadable&sort_by=-likeCount)里面有免费的，不过得慢慢找


]]

local default_tb = 
[[
{
	a = 1,
	b = 2,
	c = {
		2,3, 4, "123",
		a = 6,
		c = {4,5}
	},
	d = 1
}
]]

local default_text = 
[[
x :
	1 2 3
y :
	dict : "hello world"
z : { foobar }	
]]

local tb_editor
local text_editor



function system.on_entry()
	if not text_editor then 
		text_editor = ImGuiExtend.CreateTextEditor()
		text_editor:SetTabSize(8)
		text_editor:SetShowWhitespaces(false)
		text_editor:SetText(default_text)
	end
	if not tb_editor then 
		tb_editor = ImGuiExtend.CreateTextEditor()
		tb_editor:SetTabSize(8)
		tb_editor:SetShowWhitespaces(false)
		tb_editor:SetText(default_tb)
	end
end

function system.data_changed()
	ImGui.SetNextWindowPos(mgr.get_content_start())
    ImGui.SetNextWindowSize(mgr.get_content_size())
    if ImGui.Begin("window_body", nil, ImGui.WindowFlags {"NoResize", "NoMove", "NoScrollbar", "NoCollapse", "NoTitleBar"}) then 
		local sizeX, sizeY = ImGui.GetContentRegionAvail()
		local height = sizeY * 0.5 - 20
		local length = sizeX * 0.5 - 150
		local halfx = sizeX * 0.5

		tb_editor:Render("##tb_input", length, height, true)
		local str = tb_editor:GetText()
		ImGui.SameLineEx(halfx + 50)
        ImGui.BeginChild("###tb_child_output", length + 50, height, ImGui.ChildFlags({"Border"}))
			xpcall(function()
				local tb = load(tostring("return " .. str))()
				ImGui.Text(stringify(tb))
			end, function(err)
			end)
        ImGui.EndChild()
		
		text_editor:Render("##text_input", length, height, true)
		local str = text_editor:GetText()
		ImGui.SameLineEx(halfx + 50)
        ImGui.BeginChild("###txt_child_output", length + 50, height, ImGui.ChildFlags({"Border"}))
			xpcall( function()
				local tb = datalist.parse(str)
				ImGui.Text(dep.common.lib.table2string(tb))
			end, function()
			end)
        ImGui.EndChild()

		ImGui.SetCursorPos(halfx - 100, 100)
		ImGui.Text("table \n  to \ndatalist")

		ImGui.SetCursorPos(halfx - 100, 100 + height)
		ImGui.Text("datalist \n  to \ntable")

	end 
	ImGui.End()
end