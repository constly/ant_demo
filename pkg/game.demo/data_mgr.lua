local utils = import_package 'game.tools'
local all_data = {}
local max_id = 0
local cur_item = nil
local api = {}

function api.create_system(tbParam)
    if type(tbParam) ~= "table" then return end 

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

function api.get_content_start() return {x = 180, y = 100} end

-- 类型排版占位
local tb_def = {
    {"type_imgui",      "ImGui"},
    {"type_res",        "资源管理"},
    {"type_rmlui",      "RmlUI"},
    {"type_scene",      "场景和输入"},
    {"type_ecs",        "Lua ECS"},
    {"type_renderer",   "渲染"},
    {"type_effect",     "特效和声音"},
    {"type_net",        "网络"},
    {"type_debug",      "性能和调试"},
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
temp_create("资源管理", "通过vfs加载", "尚未实现")
temp_create("资源管理", "自定义字节流存取", "尚未实现")
temp_create("资源管理", "自定义字符串存取", "尚未实现")
temp_create("资源管理", "单机存档/读档", "尚未实现")
temp_create("资源管理", "打pack包", "尚未实现")
temp_create("资源管理", "解pack包", "尚未实现")
temp_create("资源管理", "加密/解密", "尚未实现")
temp_create("资源管理", "压缩/解压", "尚未实现")

temp_create("RmlUI", "01_基础控件", "尚未实现")
temp_create("RmlUI", "02_列表和弹框", "尚未实现")
temp_create("RmlUI", "03_UI播放动画", "尚未实现")
temp_create("RmlUI", "04_UI播放特效", "尚未实现")
temp_create("RmlUI", "05_UI中显示RT", "尚未实现")

temp_create("场景和输入", "模型和动画", "尚未实现")
temp_create("场景和输入", "角色操控", "尚未实现")
temp_create("场景和输入", "第三人称摄像机", "尚未实现")
temp_create("场景和输入", "键盘和鼠标", "尚未实现")
temp_create("场景和输入", "多点触屏", "尚未实现")
temp_create("场景和输入", "手柄", "尚未实现")
temp_create("场景和输入", "选中场景物件", "尚未实现")

temp_create("Lua ECS", "创建Entity", "创建和删除Entity")
temp_create("Lua ECS", "System更新", "")

temp_create("渲染", "01_LOD", "尚未实现")
temp_create("渲染", "02_光影/迷雾", "尚未实现")
temp_create("渲染", "03_森林/草原", "尚未实现")
temp_create("渲染", "04_河流/瀑布", "尚未实现")
temp_create("渲染", "05_下雪和脚印", "尚未实现")
temp_create("渲染", "06_下雨和涟漪", "尚未实现")
temp_create("渲染", "07_RenderTexture", "通过RT反向操作物体")
temp_create("渲染", "08_卡通渲染", "尚未实现")
temp_create("渲染", "09_画质设置", "尚未实现")

temp_create("特效和声音", "测试特效", "尚未实现")
temp_create("特效和声音", "2D声音", "包括BGM和音效")
temp_create("特效和声音", "3D声音", "1. 可以指定声音距离摄像机的距离\n2. 有暂停/继续/中止等接口演示")
temp_create("特效和声音", "音量调节", "尚未实现")

temp_create("网络", "WebServer", "尚未实现")
temp_create("网络", "Socket通信", "尚未实现")
temp_create("网络", "简单多人游戏", "尚未实现")

temp_create("性能和调试", "帧率", "尚未实现")
temp_create("性能和调试", "内存情况", "尚未实现")


return api;