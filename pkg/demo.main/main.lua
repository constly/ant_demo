local api = {}
local tbData = {}
local max_id = 0
local current_item

--[[
    system = "", 模块对应的ecs system
    category = "模块名",
    data = 
    {
        name = "功能名字",
        desc = "功能描述",
    }
--]]
function api.register(system, category, data)
    local tb = api.find_category(category)
    if not tb then 
        tb = {category = category, items = {}}
        table.insert(tbData, tb)
    end
    max_id = max_id + 1
    data._system = system
    data._id = max_id
    table.insert(tb.items, data)
    return data._id
end

function api.get_data()
    return tbData
end

function api.find_category(category_name)
    for _, v in ipairs(tbData) do 
        if v.category == category_name then 
            return v
        end
    end
end

function api.set_current_item(item)
    local pre = current_item
    if pre == item then 
        return 
    end
    if pre and pre._system and pre._system.on_leave then 
        pre._system.on_leave(pre._system)
    end
    if item and item._system and item._system.on_entry then 
        item._system.on_entry(item._system)
    end
    current_item = item
end

function api.get_current_id()
    return current_item and current_item._id
end


-- 这里是测试
api.register(nil, "ImGui", {name= "各种按钮", desc= "包括普通按钮，图片按钮，尚未实现"})
api.register(nil, "ImGui", {name= "下拉列表", desc= "尚未实现"})
api.register(nil, "ImGui", {name= "Table", desc= "尚未实现"})

api.register(nil, "资源管理", {name= "通过io加载", desc= "通过IO直接加载磁盘上的文件"})
api.register(nil, "资源管理", {name= "通过io保存", desc= "通过IO将数据保存到磁盘上"})
api.register(nil, "资源管理", {name= "通过vfs加载", desc= "尚未实现"})

api.register(nil, "RmlUI", {name= "图片按钮", desc= "图片按钮"})

api.register(nil, "输入", {name= "键盘和鼠标", desc= "尚未实现"})
api.register(nil, "输入", {name= "多点触屏", desc= "尚未实现"})
api.register(nil, "输入", {name= "手柄", desc= "尚未实现"})

api.register(nil, "场景角色", {name= "加载模型", desc= "尚未实现"})
api.register(nil, "场景角色", {name= "角色操控", desc= "尚未实现"})
api.register(nil, "场景角色", {name= "第三人称摄像机", desc= "尚未实现"})
api.register(nil, "场景角色", {name= "键盘和鼠标", desc= "尚未实现"})

api.register(nil, "Lua ECS", {name= "创建Entity", desc= "创建和删除Entity"})
api.register(nil, "Lua ECS", {name= "System更新", desc= ""})

api.register(nil, "渲染", {name= "RenderTexture", desc= "将场景对象渲染到UI上"})

api.register(nil, "网络", {name= "WebServer", desc= "创建WebServer"})
api.register(nil, "网络", {name= "Socket", desc= "socket通信"})

api.register(nil, "调试", {name= "帧率", desc= "尚未实现"})
api.register(nil, "调试", {name= "内存情况", desc= "尚未实现"})

return api;