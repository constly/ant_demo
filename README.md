# Ant Game Engine 学习记录
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
```

## 工具链相关
### 一. 客户端多开
1. 运行文件服务器: "./bin/msvc/debug/ant_demo.exe" -s
2. 启动运行时版本: "./bin/msvc/debug/ant_demo_rt.exe"
3. 只有运行时版本才可以多开
4. 日志输出在: startup/.app/log/runtime-1.log

### 二. 调试C++
1. 用Visual Studio打开项目根目录
2. 将bin/msvc/debug/ant_demo.exe设置为启动项, 启动即可调试C++
3. 运行时版本 ant_demo_rt.exe 也可以用同样的方式调试

### 三. 关于编译
1. 某些情况下会报奇怪的编译报错，这时可以看文件中是否有中文，改下文件的编码或者把中文删掉试试

### 四. 使用的插件
1. 声音使用的 [cute](https://github.com/RandyGaul/cute_headers)
2. 节点编辑器使用的 [imgui-node-editor](https://github.com/thedmd/imgui-node-editor.git)
2. lua语法提示使用的 [EmmyLua](https://github.com/EmmyLua/IntelliJ-EmmyLua)

### 五. 安装特效编辑器Effekseer  
1. 官方文档 [HowToBuild](https://github.com/effekseer/Effekseer/blob/master/docs/Development/HowToBuild.md)  
2. 另外需要安装python最新版,以及执行: pip install setuptools
3. Effekseer/ResourceData/samples目录下有大量示例

### 六. bgfx学习
1. 如何 [build](https://github.com/bkaradzic/bgfx/blob/master/docs/build.rst)
1. bgfx下有大量使用示例, 网上也有 [学习笔记](https://hinageshi01.github.io/2022/05/30/bgfx/)



## 内容展示
![imgui_02](./img/imgui_02.png)
![imgui_07](./img/imgui_07.png)
![imgui_08](./img/imgui_08.png)
![imgui_11](./img/imgui_11.png)
![designer_06](./img/designer_06.png)
![core_10](./img/core_10.png)
![core_11](./img/core_11.png)



## 待解决问题
1. 如何遍历场景中所有entity, 以及他们身上有什么组件, 并且展示出组件属性字段
2. 建议：引擎相关类定义时能否加上 ---@class 标识， 这样方便代码跳转
3. 自走棋多world如何实现
4. 海量人群渲染，包括各自播放不同的动作 （参考laya的例子）
5. 地图编辑器是否有必要： 某些物件只能放置在某些层级？
6. 在PC平台时，需要捕获窗口关闭事件，以便释放声音资源
7. 拖动PC窗口时，能否不要暂停游戏，这会导致声音出现嘶嘶嘶的问题，也会暂停windows的收发包
8. windows平台希望有接口得到窗口句柄，声音需要
9. 互相require对方时，程序会死循环，无响应，希望能有友好的提示输出

## 开发主目标
Richman
* ~~多视口功能完善，包括视口分隔，tab页拖动，右键菜单~~
* csv编辑器，数据获取中心，变量定义中心
* 文件支持多视口，一部分为RT视口，支持实时编辑/预览数据，数据有版本号，预览界面自己看情况刷新，也可以手动屏蔽/开启自动刷新功能
* 多人移动同步流程走通
* 所有节点，变量共用，有tag系统，支持统一删除某tag的节点或者变量定义

其他
* 简易UI编辑器
* 曲线编辑器
