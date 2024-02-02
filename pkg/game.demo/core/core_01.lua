local ecs = ...
local ImGui = import_package "ant.imgui"
local ImGuiLegacy = require "imgui.legacy"
local mgr = require "data_mgr"
local tbParam = 
{
    ecs             = ecs,
    system_name     = "core_01_system",
    category        = mgr.type_core,
    name            = "01_3rd说明",
    file            = "core/core_01.lua",
    ok              = true
}
local system = mgr.create_system(tbParam)

local text = 
[[
bee.lua:  lua运行时和工具集
	地址: https://github.com/actboy168/bee.lua.git
	1. lua调试支持
	2. 对lua功能的补充

bgfx:	跨平台渲染库
	地址: https://github.com/bkaradzic/bgfx.git
	1. 支持direct3d, opengl, vulkan, webgl
	2. 支持android, ios, linux, windows(7+), wasm

bgfx.luamake 使用luamake编译bgfx
	地址: https://github.com/actboy168/bgfx.luamake

fmod: 声音播放
	地址: https://fmod.com/
	1. 这玩意是付费的

glm: 基于OpenGL规范的C++数学库
	地址: https://github.com/junjie020/glm.git
	1. 此项目不仅限于 GLSL 功能。还扩展了诸如：矩阵变换、四元数、数据打包、随机数、噪声等
	2. 用 C++98 编写的，但在编译器支持时可以利用 C++11
	3. 是一个独立于平台的库，没有依赖性

imgui: 一个用于C++的图形用户界面库
	地址: https://github.com/ocornut/imgui.git
	1. 输出优化的顶点缓冲区, 可以用于任意3D应用程序
	2. Dear ImGui 旨在实现快速迭代，并使程序员能够创建内容创建工具和可视化/调试工具
	3. Dear ImGui 特别适合集成到游戏引擎、实时3D应用程序等程序中

ltask:	Lua任务调度库
	地址: https://github.com/cloudwu/ltask.git
	1. 它实现了一个 n: m 调度程序，以便可以在 N 个操作系统线程上运行 M lua VM
	2. 每个lua服务（一个独立的 lua VM）都在请求/响应模式下工作，它们使用消息通道进行相互通信

luaecs: 一个用于Lua的ECS库
	地址: https://github.com/cloudwu/luaecs.git

math3d: 对glm的lua扩展
	地址: https://github.com/cloudwu/math3d.git

minizip-ng: 一个用C编写，用于操纵zip文件的库
	地址: https://github.com/zlib-ng/minizip-ng
	1. zip 是一种存档文件格式，它可以将多个文件和目录打包到单个文件中
	2. 可选地使用 zlib 或其他压缩算法对这些文件进行压缩
	
ozz-animation: 开源 C++ 3D 骨骼动画库和工具集
	地址: https://github.com/guillaumeblanc/ozz-animation
	1. ozz-animation 提供运行时角色动画播放功能（加载、采样、混合等）
	2. 它提出了一个与渲染器无关且与游戏引擎无关的低级实现，通过面向数据的设计专注于性能和内存约束
	3. 附带工具链，用于从主要的数字内容创建格式(obj, fbx)转换为 ozz 优化的运行时结构

stylecache: CSS style 管理
	地址: https://github.com/cloudwu/stylecache

vulkan: 跨平台3D图形库
	地址: https://www.vulkan.org/
	问题：有了bgfx为啥还要有vulkan？

yoga: 一个可嵌入且高性能的 flexbox 布局引擎
	地址: https://github.com/facebook/yoga.git
	1. 主要用于解决移动应用开发中的 UI 布局计算问题，尤其是针对复杂的、动态变化的界面布局
	2. Yoga 库可以帮助开发人员在不同平台上实现一致的 UI 布局效果

zlib-ng: 适用于下一代系统的 zlib 数据压缩库
	地址: https://github.com/zlib-ng/zlib-ng.git
	1. zlib 是一个用于数据压缩和解压缩的开源库，它通常用于在文件中或通过网络传输数据时进行压缩
]]

local context = {
    text = text,
    flags = ImGui.InputTextFlags{"ReadOnly"},
}


function system.data_changed()
	ImGui.SetNextWindowPos(mgr.get_content_start())
    ImGui.SetNextWindowSize(mgr.get_content_size())
	ImGui.PushStyleColorImVec4(ImGui.Col.FrameBg, 0, 0, 0, 0)
    if ImGui.Begin("window_body", ImGui.WindowFlags {"NoResize", "NoMove", "NoScrollbar", "NoCollapse", "NoTitleBar"}) then 
		context.width, context.height = ImGui.GetContentRegionAvail()
		ImGuiLegacy.InputTextMultiline("##show", context)
	end
	ImGui.PopStyleColor()
	ImGui.End()
end