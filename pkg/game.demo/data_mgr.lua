local utils = import_package 'game.tools'
local ImGui = import_package "ant.imgui"
local all_data = {}
local max_id = 0
local cur_item = nil
local api = {}
local content_start = {200, 100}
local content_size = {1149, 700}

function api.create_system(tbParam)
    local tb = api.find_category(tbParam.category)
    if not tb then 
        tb = {category = tbParam.category, items = {}}
        table.insert(all_data, tb)
    end
    if not tbParam.name then return end

    local system = tbParam.ecs and tbParam.ecs.system(tbParam.system_name)
    max_id = max_id + 1
    local data = {}
    data.name = tbParam.name
    data.world = tbParam.ecs and tbParam.ecs.world
    data.desc = tbParam.desc
    data.ok   = tbParam.ok
    data.system = system
    data.system_name = system and ("game.demo|" .. tbParam.system_name)
    data.id = max_id
    data.file = utils.path.disk_project_root .. 'pkg/game.demo/' .. tbParam.file;
    data.file = data.file:gsub("/","\\")
    table.insert(tb.items, data)
    table.sort(tb.items, function(a, b) return a.name < b.name end)
    return system, max_id
end

function api.find_category(category_name)
    for _, v in ipairs(all_data) do 
        if v.category == category_name then 
            return v
        end
    end
end

function api.find_item(category_name, item_id)
    local tb = api.find_category(category_name) or {items = {}}
    for i, v in ipairs(tb.items) do 
        if v.id == item_id then 
            return v
        end
    end
end

function api.set_current_item(category_name, item_id)
    local item = api.find_item(category_name, item_id)
    local pre = cur_item
    if pre == item then 
        return 
    end
    if pre and pre.system then 
        pre.world:disable_system(pre.system_name)
        if pre.system.on_leave then 
            pre.system.on_leave(pre.system)
        end
    end
    if item and item.system then 
        item.world:enable_system(item.system_name)
        if item.system.on_entry then
            item.system.on_entry(item.system)
        end
    end
    cur_item = item
end

function api.disable_all()
    for _, v in ipairs(all_data) do 
        for _, data in ipairs(v.items) do 
            if data.world then
                data.world:disable_system(data.system_name)
            end
        end
    end
end

function api.get_data() return all_data end

function api.get_current_id() return cur_item and cur_item.id end

function api.get_content_start() return content_start[1],  content_start[2] end
function api.set_content_start(x, y) content_start = {x, y} end

function api.get_content_size() return content_size[1], content_size[2] end
function api.set_content_size(x, y) content_size = {x, y} end

function api.get_dpi_scale() return ImGui.GetMainViewport().DpiScale end

-- 类型排版占位
local tb_def = {
    {"type_imgui",      "ImGui"},
    {"type_core",       "引擎核心"},
    {"type_asset",      "资源管理"},
    {"type_rmlui",      "RmlUI"},
    {"type_scene",      "场景"},
    {"type_renderer",   "渲染"},
    {"type_net",        "网络"},
    {"type_minigame",   "完整示例"},
}
for i, v in ipairs(tb_def) do 
    api[v[1]] = v[2]    
    local tbParam = { category = v[2] }
    api.create_system(tbParam)
end

-- 下面是测试占位
local temp_create = function(category, name, desc)
    local tbParam = { category = category, name = name, desc = desc, file = "data_system.lua" }
    api.create_system(tbParam)
end

temp_create(api.type_core, "04_itask", "尚未实现")
temp_create(api.type_core, "07_输入", "尚未实现")
temp_create(api.type_core, "10_特效", "尚未实现")
temp_create(api.type_core, "11_声音", "1. 2D声音，包括BGM和音效; \n2. 3D声音，可以指定声音距离摄像机的距离，有暂停/继续/中止等接口演示；\n3.音量调节")
temp_create(api.type_core, "12_性能分析", "帧率，内存使用，cput使用，gpu使用，尚未实现")
temp_create(api.type_core, "13_PC平台", "当窗口最小化时，当窗口分辨率变化时，修改窗口分辨率，得到窗口分辨率，设置窗口标题")

temp_create(api.type_asset, "01_通过vfs加载", "尚未实现")
temp_create(api.type_asset, "02_自定义数据存取", "尚未实现") -- 包括字符串/字节流
temp_create(api.type_asset, "03_单机存档/读档", "尚未实现")
temp_create(api.type_asset, "04_打/解pack包", "尚未实现")
temp_create(api.type_asset, "05_加密/解密", "尚未实现")
temp_create(api.type_asset, "06_压缩/解压", "尚未实现")

temp_create(api.type_rmlui, "01_基础控件", "尚未实现")
temp_create(api.type_rmlui, "02_列表和弹框", "尚未实现")
temp_create(api.type_rmlui, "03_UI播放动画", "尚未实现")
temp_create(api.type_rmlui, "04_UI播放特效", "尚未实现")
temp_create(api.type_rmlui, "05_UI中显示RT", "尚未实现")

temp_create(api.type_scene, "模型和动画", "尚未实现")
temp_create(api.type_scene, "角色操控", "尚未实现")
temp_create(api.type_scene, "第三人称摄像机", "尚未实现")
temp_create(api.type_scene, "键盘和鼠标", "尚未实现")
temp_create(api.type_scene, "多点触屏", "尚未实现")
temp_create(api.type_scene, "手柄", "尚未实现")
temp_create(api.type_scene, "选中场景物件", "尚未实现")


temp_create("渲染", "01_LOD", "尚未实现")
temp_create("渲染", "02_光影/迷雾", "尚未实现")
temp_create("渲染", "03_森林/草原", "尚未实现")
temp_create("渲染", "04_河流/瀑布", "尚未实现")
temp_create("渲染", "05_下雪和脚印", "尚未实现")
temp_create("渲染", "06_下雨和涟漪", "尚未实现")
temp_create("渲染", "07_RenderTexture", "通过RT反向操作物体")
temp_create("渲染", "08_卡通渲染", "尚未实现")
temp_create("渲染", "09_画质设置", "尚未实现")

temp_create(api.type_net, "WebServer", "尚未实现")
temp_create(api.type_net, "Socket通信", "尚未实现")
temp_create(api.type_net, "简单多人游戏", "尚未实现")

temp_create(api.type_minigame, "待定", "尚未实现")


return api;