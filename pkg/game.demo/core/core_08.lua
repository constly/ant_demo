local ecs = ...
local ImGui = import_package "ant.imgui"
local mgr = require "data_mgr"
local tbParam = 
{
    ecs             = ecs,
    system_name     = "core_08_system",
    category        = mgr.type_core,
    name            = "08_DataList",
    file            = "core/core_08.lua",
    ok              = false
}
local system = mgr.create_system(tbParam)

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

function system.data_changed()
	ImGui.SetNextWindowPos(mgr.get_content_start())
    ImGui.SetNextWindowSize(mgr.get_content_size())
    if ImGui.Begin("window_body", nil, ImGui.WindowFlags {"NoResize", "NoMove", "NoScrollbar", "NoCollapse", "NoTitleBar"}) then 
		ImGui.Text("待定")
	end 
	ImGui.End()
end