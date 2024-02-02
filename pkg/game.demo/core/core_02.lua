local ecs = ...
local ImGui = import_package "ant.imgui"
local mgr = require "data_mgr"
local ImGuiLegacy = require "imgui.legacy"
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
ant.anim_ctrl:	动画控制器
ant.animation: 动画播放
ant.asset: 引擎内部资源加载和卸载，主要指材质 和 贴图
ant.audio: 声音相关接口封装
ant.camera: 摄像机控制器 和 摄像机轨迹录制
ant.compile_resource: 资源编译，用在打包等场景，禁止在运行时使用
ant.daynight: 白天和晚上，通过修改光照/材质参数实现
and.debug: 调试, 具体是指调试group、材质、贴图、mipmap
ant.debugger: 调试, 具体是指通过vscode调试游戏
ant.decal: 贴花，具体不知道咋用
ant.ecs: ecs核心系统
ant.efk: 特效播放相关
ant.font: 字体有关 (涉及到bgfx)
ant.general: 没看懂在干嘛，好像是提供了一些公共接口
ant.geometry: 得到常用几何体的顶点、绘制骨骼
ant.grid: 绘制网格
ant.group: 激活/禁用组，过滤组，刷新组 
ant.httpc: http协议实现
ant.hwi: 渲染接口封装
ant.imgui: imgui初始化与渲染更新
ant.inputmgr: 输入管理
ant.io:	对vfs 和 fastio 的封装
ant.json: json decode 和 encode
ant.landform: 地形相关
ant.luaecs: 看起来是把ecs world中所有实体写到文件中，以及从文件中还原
ant.material: 材质相关
ant.math: 一些数学相关的接口，还包括射线创建之类的
ant.modifier: 动画可以直接驱动场景对象，只需要将动画中的骨骼点和场景对象关联在一起。官方wiki里面有详细说明
ant.motion_sampler: 运动插值器:如果想让一个场景对象沿直线运动，更可以只设置起点、终点和运行时间就够了，具体使用需要看官方文档
ant.net: 网络接口封装，比如listen, connect, recv, send 等
ant.objcontroller: 场景对象控制，比如拾取检测
ant.outline: 应该是描边吧
ant.pipeline: 引擎默认pipeline
ant.polyline: 没太看懂，看起来与画线有关
ant.render: 渲染核心，里面很复杂
ant.render.core: 渲染层中被其它包依赖的部分
ant.resource_manager: 资源管理服务
	* pkg/ant.resource_manager/service 资源管理 (ltask) 服务
	* pkg/ant.resource_manager/src 资源管理用到的 C 模块（用于绕过 Lua 层直接用过 C API 获取资源）
	* pkg/ant.resource_manager/thread 资源管理服务用到的 Lua 模块
ant.resources: 引擎中定义的文本资源
	* pkg/ant.resources/materials 材质
	* pkg/ant.resources/settings 材质的配置
	* pkg/ant.resources/shaders 着色器
	* pkg/ant.resources/state_machines （？？？）
	* pkg/ant.resources/textures 默认纹理
ant.resources.binary:  引擎中定义的二进制资源
ant.resources.test: 引擎test需要的资源
ant.rmlui: 游戏用 UI （RMLUI）
ant.scene: 场景组件实现
ant.serialize: 似乎是解析/保存datalist的
ant.settings: 项目全局设置相关
ant.sh: 好像是一些工具接口，没看懂
ant.shadow_bounding: 阴影范围之类的？没看明白
ant.sky: 天空盒
ant.splitviews: 视野分割吗，使用场景是啥呢
ant.starsky: 与天空盒有关，具体没看懂
ant.terrain: 地形，好像还有水
ant.timeline: 时间线，多少时间后干啥事情
ant.timer: 定时器？没太看懂
ant.vfs: 虚拟文件系统
ant.webserver: 简易web服务器实现
ant.widget: 绘制常见几何体，比如sphere, box, capsule, aabb, skeleton
ant.window: 游戏窗体服务， 切换场景时调用其rebot

]],

["ant/test/"] = 
[[
test/features: 展示引擎的各种特性
	说明: 此处最好把所有支持的都列完, 方便后续查询
	1. 有描边, 水, pbr, 光源, 阴影, 特效等等

test/httpc: 下载和上传
	说明: 不知道是不是封装的原生平台内置的下载功能

test/imgui: 测试imgui功能
	说明: 里面功能很简单，可能需要完善下

test/native_bgfx: 
	说明: 没有使用系统定义的pipeline，不知道干嘛用的

test/rmlui: 测试rmlui
	说明: 里面测试例子太简陋了，可能需要完善下

test/simple: 一个最简单的项目示例
	说明: 也很简陋，可以更复杂点

test/vfsmem: 演示在内存中动态创建vfs路径（不会存档）
	说明: 这个启动程序非常简单，没有窗口那一套
	1. 这个执行是瞬间的，写命令行工具程序时，很适合参考这个示例

test/zip: 演示zip的使用
	说明: 包括以下几点功能
	1. 往zip中写入/读取文件
	2. 对字符串 压缩/解压
	3. 这个示例更简单，直接就是执行一个lua文件，vfsmem还要启动一个服务，看来写命令行工具更适合参考这个
]],

["ant/runtime/"] = 
[[
ios/window/posix 平台启动入口
]],

["ant/tools/"] = 
[[
工具库:

tools/editor: 引擎编辑器
	说明: 

tools/fbx2glb: 通过blender将fbx转换为glb
	说明: 

tools/filepack: 打包相关
	说明: 

tools/fileserver: 引擎运行时需要的开发机服务
	说明: 此服务如何部署呢？

tools/material_compile:  材质编译服务
	说明: 什么情况下使用这个工具呢？

tools/prefab_viewer: prefab预览工具？
	说明：运行报错，跑不起来，不知道是啥效果

tools/texture: 没太明白是干嘛用的
	说明: 这个示例启动方向有点奇怪
]],

}


local context = {
    text = "",
    flags = ImGui.InputTextFlags{"ReadOnly"},
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
	ImGui.PushStyleColorImVec4(ImGui.Col.FrameBg, 0, 0, 0.3, 0)
    if ImGui.Begin("window_body", nil, ImGui.WindowFlags {"NoResize", "NoMove", "NoScrollbar", "NoCollapse", "NoTitleBar"}) then 
		-- 菜单
		ImGui.BeginGroup()
		for i, v in ipairs(tb_dir) do 
			set_btn_style(i == cur_dir)
			if ImGui.ButtonEx(v, 130) or not cur_dir then 
				cur_dir = i;
				context.text = tb_text[v]
			end	
			ImGui.PopStyleColorEx(4)
			ImGui.PopStyleVar()
		end
		ImGui.EndGroup()
		

		ImGui.SetCursorPos(150, 5)
		ImGui.BeginGroup()
		context.width, context.height = ImGui.GetContentRegionAvail()
		ImGuiLegacy.InputTextMultiline("##show_text", context)
		ImGui.EndGroup()
	end
	ImGui.PopStyleColorEx()
	ImGui.End()
end