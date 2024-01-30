local ecs = ...
local ImGui = import_package "ant.imgui"
local mgr = require "data_mgr"
local tbParam = 
{
    ecs             = ecs,
    system_name     = "core_02_system",
    category        = mgr.type_core,
    name            = "02_引擎源码",
    file            = "core/core_02.lua",
    ok              = true
}
local system = mgr.create_system(tbParam)

local tb_text = 
{
["ant/clibs/"] = 
[[
Lua 用到的若干 C 库

bake: 离线烘培 
	1. 相关API呢？

bee: bee.lua的编译脚本
	说明: 里面没有代码，只有make.lua 

bgfx: bgfx 的 Lua binding
	说明: 相关API 

datalist: 类似 yaml 的结构化数据文件
	说明: 里面的readme.md 和 test.lua 有详细使用方法

ecs: luaecs 的 C++ 封装
	说明: 

fastio: 用于 Lua 的 IO 模块
	说明: fastio.cpp 中定义了各种使用接口

filedialog:	对话框
	说明: 里面定义有save 和 open 函数

firmware: 手机 App 的启动用模块
	说明: 

foundation: C 模块使用的基础设施
	说明: 看起来是一些基础数据结构

image: bimg 的 Lua 封装
	说明: 接口定义在image.cpp里面	

imgui: imgui 的 Lua 封装
	说明: 

imgui-widgets:  封装了一些imgui复杂的控件
	说明: 

ltask: ltask 的编译脚本
	说明:

lua: lua 的编译脚本
	说明:

luabind: Lua binding 用的库
	说明: 对lua与C数据交互接口的封装

noise: 噪声，暂时没研究用在何处
	说明: 里面定义了一个函数 perlin2d

ozz: ozz的编译脚本
	说明：还封装一些接口导出

protocol: fileserver 通讯协议
	说明: 

quadsphere: 立方体球
	说明: 不知道干嘛用的

vfs: VFS (虚拟文件系统) 的 C 部分
	说明: 

zip: 文件目录压缩和解压
	说明: 打包应该需要

]],

["ant/engine/"] = 
[[
引擎中不受包管理的 Lua 代码
	注意: 其他地方无法 require 引擎目录的文件
	因为: require 不支持引用外部包里的子模块，工作环境不能超出当前包

engine/firmware: 游戏客户端的自举部分及基础库
	说明: 

engine/runtime: 运行时调试相关
	说明：如果是调试模式启动游戏，启动后立刻暂停游戏，等待与vscode相连

engine/game: 看起来与vfs有关
	说明: 

engine/service: 引擎内置的服务
	说明: 比如logger, timer
]],

["ant/pkg/"] = 
[[
pkg.audio 
	1. 说明

pkg.asset 
	ant.timer
	ant.timeline 
]],

["ant/test/"] = 
[[

]],

["ant/runtime/"] = 
[[

]],

["ant/tools/"] = 
[[

]],

}


local context = {
    text = "",
    flags = ImGui.Flags.InputText{"ReadOnly"},
}

local tb_dir = 
{
	"ant/clibs/",
	"ant/engine/",
	"ant/pkg/",
	"ant/test/",
	"ant/runtime/",
	"ant/tools/",
}
local cur_dir;

local set_btn_style = function(current)
    if current then 
        ImGui.PushStyleColor(ImGui.Enum.Col.Button, 0.6, 0.6, 0.25, 1)
        ImGui.PushStyleColor(ImGui.Enum.Col.ButtonHovered, 0.5, 0.5, 0.25, 1)
        ImGui.PushStyleColor(ImGui.Enum.Col.ButtonActive, 0.5, 0.5, 0.25, 1) 
        ImGui.PushStyleColor(ImGui.Enum.Col.Text, 0.95, 0.95, 0.95, 1)
    else 
        ImGui.PushStyleColor(ImGui.Enum.Col.Button, 0.2, 0.2, 0.25, 1)
        ImGui.PushStyleColor(ImGui.Enum.Col.ButtonHovered, 0.3, 0.3, 0.3, 1)
        ImGui.PushStyleColor(ImGui.Enum.Col.ButtonActive, 0.25, 0.25, 0.25, 1)
        ImGui.PushStyleColor(ImGui.Enum.Col.Text, 0.95, 0.95, 0.95, 1)
    end
	ImGui.PushStyleVar(ImGui.Enum.StyleVar.ButtonTextAlign, 0, 0.5)
end

function system.data_changed()
	ImGui.SetNextWindowPos(mgr.get_content_start())
    ImGui.SetNextWindowSize(mgr.get_content_size())
	ImGui.PushStyleColor(ImGui.Enum.Col.FrameBg, 0, 0, 0.3, 0)
    if ImGui.Begin("window_body", ImGui.Flags.Window {"NoResize", "NoMove", "NoScrollbar", "NoCollapse", "NoTitleBar"}) then 
		-- 菜单
		ImGui.BeginGroup()
		for i, v in ipairs(tb_dir) do 
			set_btn_style(i == cur_dir)
			if ImGui.Button(v, 130) or not cur_dir then 
				cur_dir = i;
				context.text = tb_text[v]
			end	
			ImGui.PopStyleColor(4)
			ImGui.PopStyleVar()
		end
		ImGui.EndGroup()
		

		ImGui.SetCursorPos(150, 5)
		ImGui.BeginGroup()
		context.width, context.height = ImGui.GetContentRegionAvail()
		ImGui.InputTextMultiline("##show_text", context)
		ImGui.EndGroup()
	end
	ImGui.PopStyleColor()
	ImGui.End()
end