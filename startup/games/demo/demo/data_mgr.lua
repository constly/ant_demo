local dep = require 'dep'
local ImGui = dep.ImGui
local all_data = {}
local cur_item = nil
---@class data_mgr
local api = {}
local content_start = {200, 100}
local content_size = {1149, 700}

function api.create_system(tbParam)
    local tb = api.find_category(tbParam.category)
    if not tb then 
        tb = {category = tbParam.category, items = {}}
		tb.min_id = #all_data * 1000
        table.insert(all_data, tb)
    end
    if not tbParam.name then return end

    local system = tbParam.ecs and tbParam.ecs.system(tbParam.system_name)
    local data = {}
    data.name = tbParam.name
    data.world = tbParam.ecs and tbParam.ecs.world
    data.desc = tbParam.desc
    data.ok   = tbParam.ok
    data.system = system
    data.system_name = system and ("demo|" .. tbParam.system_name)
    data.id = tb.min_id + #tb.items + 1
	data.file = '/games/demo/demo/' .. tbParam.file;
    table.insert(tb.items, data)
    table.sort(tb.items, function(a, b) return a.name < b.name end)
    return system, data.id
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

function api.reset()
	all_data = {}
	cur_item = nil 

	-- 类型排版占位
	local tb_def = {
		{"type_imgui",      "ImGui"},
		{"type_designer",   "设计工具"},
		{"type_core",       "引擎核心"},
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


	temp_create(api.type_core, "93_性能分析", "帧率，内存使用，cput使用，gpu使用，尚未实现")
	temp_create(api.type_core, "94_PC平台", "当窗口最小化时，当窗口分辨率变化时，修改窗口分辨率，得到窗口分辨率，设置窗口标题")

	temp_create(api.type_core, "81_自定义数据存取", "尚未实现") -- 包括字符串/字节流
	temp_create(api.type_core, "82_单机存档/读档", "尚未实现")
	temp_create(api.type_core, "83_打/解pack包", "尚未实现")
	temp_create(api.type_core, "84_加密/解密", "尚未实现")
	temp_create(api.type_core, "85_压缩/解压", "尚未实现")

	temp_create(api.type_designer, "01_曲线编辑器", "编辑器各种1维2维曲线")
	temp_create(api.type_designer, "02_dotween", "曲线动画")
	temp_create(api.type_designer, "07_技能编辑器", "")
	temp_create(api.type_designer, "08_剧情编辑器", "")
	temp_create(api.type_designer, "09_UI编辑器", "")

	temp_create(api.type_scene, "模型和动画", "尚未实现")
	temp_create(api.type_scene, "海量对象", "尚未实现")
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
end
api.reset()

return api;