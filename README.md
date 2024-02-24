# Ant Game Engine 学习记录
## 项目说明
学习使用[Ant Game Engine](https://github.com/ejoy/ant)，指导方针如下：
* 尽可能给每一个功能点都加上示例代码
* 尽可能覆盖游戏开发的方方面面，比如编辑器，UI，渲染，联机，调试，优化，资源管理，对接Steam等等
* 尽量封装+模块化，以便需要时直接Ctrl+C, Ctrl+V


## 如何运行
```
-- clone引擎，注意: 就用默认名字ant
git clone https://github.com/ejoy/ant.git   

-- clone项目, 注意: 需与引擎处在同级目录
git clone https://github.com/constly/ant_demo.git

cd ant_demo
compile.bat
run.bat 

-- 双击 ant_demo.code-workspace 打开vscode
-- 用Visual Studio打开根目录，将bin/msvc/debug/ant_demo.exe设置为启动项, 启动即可调试C++
```

## 内容展示
![imgui_02](./img/imgui_02.png)
![imgui_07](./img/imgui_07.png)
![imgui_08](./img/imgui_08.png)
![imgui_10](./img/imgui_10.png)
![core_10](./img/core_10.png)
![core_11](./img/core_11.png)




## 工具链相关
#### 一. 安装特效编辑器Effekseer  
1. 官方文档 [HowToBuild](https://github.com/effekseer/Effekseer/blob/master/docs/Development/HowToBuild.md)  
2. 另外需要安装python最新版,以及执行: pip install setuptools
3. Effekseer/ResourceData/samples目录下有大量示例

### 二. bgfx学习
1. 如何 [build](https://github.com/bkaradzic/bgfx/blob/master/docs/build.rst)
1. bgfx下有大量使用示例, 网上也有 [学习笔记](https://hinageshi01.github.io/2022/05/30/bgfx/)

## 其他说明
1. 声音使用的 [cute](https://github.com/RandyGaul/cute_headers)
2. 节点编辑器使用的 [imgui-node-editor](https://github.com/thedmd/imgui-node-editor.git)
2. lua语法提示使用的 EmmyLua


## 待解决问题
3. 如何遍历场景中所有entity, 以及他们身上有什么组件, 并且展示出组件属性字段
