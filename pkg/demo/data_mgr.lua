local all_data = {}
local max_id = 0
local cur_item = nil
local api = {}

function api.register(system, category, name, desc)
    local tb = api.find_category(category)
    if not tb then 
        tb = {category = category, items = {}}
        table.insert(all_data, tb)
    end
    if not name then return end

    max_id = max_id + 1
    local data = {}
    data.name = name
    data.desc = desc
    data.system = system
    data.id = max_id
    table.insert(tb.items, data)
    table.sort(tb.items, function(a, b) return a.name < b.name end)
    return max_id
end

function api.find_category(category_name)
    for _, v in ipairs(all_data) do 
        if v.category == category_name then 
            return v
        end
    end
end

function api.set_current_item(item)
    local pre = cur_item
    if pre == item then 
        return 
    end
    if pre and pre.system and pre.system.on_leave then 
        pre.system.on_leave(pre.system)
    end
    if item and item.system and item.system.on_entry then 
        item.system.on_entry(item.system)
    end
    cur_item = item
end

function api.get_data() return all_data end

function api.get_current_id() return cur_item and cur_item.id end

-- 固定类型排版
local tb_def = {
    {"type_imgui",      "ImGui"},
    {"type_res",        "资源管理"},
    {"type_rmlui",      "RmlUI"},
    {"type_input",      "输入"},
    {"type_scene",      "场景角色"},
    {"type_ecs",        "Lua ECS"},
    {"type_renderer",   "渲染"},
    {"type_effect",     "特效"},
    {"type_net",        "网络"},
    {"type_debug",      "调试"},
}
for i, v in ipairs(tb_def) do 
    api[v[1]] = v[2]    
    api.register(nil, v[2])
end



-- 下面是测试占位
local mgr = api
mgr.register(nil, "资源管理", "通过io加载", "通过IO直接加载磁盘上的文件")
mgr.register(nil, "资源管理", "通过io保存", "通过IO将数据保存到磁盘上")
mgr.register(nil, "资源管理", "通过vfs加载", "尚未实现")

mgr.register(nil, "RmlUI", "图片按钮", "图片按钮")

mgr.register(nil, "输入", "键盘和鼠标", "尚未实现")
mgr.register(nil, "输入", "多点触屏", "尚未实现")
mgr.register(nil, "输入", "手柄", "尚未实现")

mgr.register(nil, "场景角色", "模型和动画", "尚未实现")
mgr.register(nil, "场景角色", "角色操控", "尚未实现")
mgr.register(nil, "场景角色", "第三人称摄像机", "尚未实现")
mgr.register(nil, "场景角色", "键盘和鼠标", "尚未实现")

mgr.register(nil, "Lua ECS", "创建Entity", "创建和删除Entity")
mgr.register(nil, "Lua ECS", "System更新", "")

mgr.register(nil, "渲染", "RenderTexture", "将场景对象渲染到UI上")
mgr.register(nil, "渲染", "光影", "尚未实现")
mgr.register(nil, "渲染", "河流", "尚未实现")
mgr.register(nil, "渲染", "瀑布", "尚未实现")
mgr.register(nil, "渲染", "卡通渲染", "尚未实现")
mgr.register(nil, "渲染", "低多边形", "尚未实现")

mgr.register(nil, "特效", "测试", "尚未实现")

mgr.register(nil, "网络", "WebServer", "创建WebServer")
mgr.register(nil, "网络", "Socket", "socket通信")

mgr.register(nil, "调试", "帧率", "尚未实现")
mgr.register(nil, "调试", "内存情况", "尚未实现")


return api;