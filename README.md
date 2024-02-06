# Ant Game Engine 学习记录
本项目记录我是怎么学习[Ant Game Engine](https://github.com/ejoy/ant)的，以及为后面正式做东西铺路：
* 尽可能给每一个功能点都加上示例代码
* 尽可能覆盖游戏开发的方方面面，比如编辑器，UI，渲染，联机，调试，优化，资源管理，对接Steam等等
* 尽可能多写注释讲明原理
* 尽量封装+模块化，以便需要时直接Ctrl+C, Ctrl+V


**部分界面如下:**
![imgui_02](./img/imgui_02.png)
![imgui_07](./img/imgui_07.png)
![imgui_08](./img/imgui_08.png)
![imgui_09](./img/imgui_09.png)


## 如何运行
```
git clone https://github.com/constly/ant_demo.git
cd ant_demo
git submodule update --init  -- 或者手动建立3rd目录，将ant引擎拷贝进去
compile.bat
run.bat 
```

## 问题
1. 如何将项目转换为vs2022工程, 以便后续调试? (在build目录下执行这个不行: ninja -t msvc)

## 如何注册一个功能示例
```
local ecs = ...
local mgr = require "data_mgr"
local tbParam = 
{
    ecs             = ecs,
    system_name     = "系统名字",           -- 如: imgui_02_system
    category        = "用例所属类别",       -- 如: mgr.type_imgui
    name            = "用例名字",           -- 如: 01_ImGui基础功能展示
    desc            = "用例描述",           -- 如: 展示ImGui常用控件
    file            = "用例文件路径",       -- 如: imgui/imgui_02.lua
    ok              = false,               -- 功能是否已经开发完成
}
local system = mgr.create_system(tbParam)

-- 当进入示例时（可能需要执行一些初始化）
function system.on_entry()
end

-- 当离开示例时（可能需要执行清理操作）
function system.on_leave()
end

-- 每帧更新
function system.data_changed()
    -- 具体示例代码写这里
end
```