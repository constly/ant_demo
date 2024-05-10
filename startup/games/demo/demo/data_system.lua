local ecs = ...
local world = ecs.world
local system = ecs.system "data_system"
local window = require "window"
local dep = require 'dep'				---@type demo.dep
local ImGui = dep.ImGui
local data_mgr  = require "data_mgr" 	---@type data_mgr
local auto_test = ecs.require 'utils.auto_test'
local sound = dep.sound
local category = nil
local selected = {}
local showHover = true

local set_btn_style = function(current, ok)
    if current then 
        ImGui.PushStyleColorImVec4(ImGui.Col.Button, 0.6, 0.6, 0.25, 1)
        ImGui.PushStyleColorImVec4(ImGui.Col.ButtonHovered, 0.5, 0.5, 0.25, 1)
        ImGui.PushStyleColorImVec4(ImGui.Col.ButtonActive, 0.5, 0.5, 0.25, 1)
        if ok then 
            ImGui.PushStyleColorImVec4(ImGui.Col.Text, 0.95, 0.95, 0.95, 1)
        else 
            ImGui.PushStyleColorImVec4(ImGui.Col.Text, 0.8, 0.8, 0.8, 1)
        end
    else 
        ImGui.PushStyleColorImVec4(ImGui.Col.Button, 0.2, 0.2, 0.25, 1)
        ImGui.PushStyleColorImVec4(ImGui.Col.ButtonHovered, 0.3, 0.3, 0.3, 1)
        ImGui.PushStyleColorImVec4(ImGui.Col.ButtonActive, 0.25, 0.25, 0.25, 1)
        if ok then 
            ImGui.PushStyleColorImVec4(ImGui.Col.Text, 0.95, 0.95, 0.95, 1)
        else 
            ImGui.PushStyleColorImVec4(ImGui.Col.Text, 0.7, 0.7, 0.7, 1)
        end
    end
end

function system.preinit()
	-- 设置项目根目录
	if world.args.ecs.project_root then
		dep.common.path_def.project_root = world.args.ecs.project_root
	end
end 


function system.init_world()
    data_mgr.disable_all()
    window.set_title("Ant Game Engine 学习记录")
    category = dep.common.user_data.get("last_category", "")
    if category ~= "" then 
        selected[category] = dep.common.user_data.get_number('last_category_' .. category)
        data_mgr.set_current_item(category, selected[category])    
    end
    -- 设置全局文本默认颜色
    ImGui.PushStyleColorImVec4(ImGui.Col.Text, 0.9, 0.9, 0.9, 1)

	sound.play_music("/pkg/demo.res/sound/bgm.wav")
	sound.set_music_volume(0.3)
end

function system.exit()
	sound.exit()
	data_mgr.reset()
end

function system.data_changed()
    local viewport = ImGui.GetMainViewport();
    local size_x, size_y = viewport.WorkSize.x, viewport.WorkSize.y

    local dpiScale = data_mgr.get_dpi_scale()
    local top_y = 35 * dpiScale
    local top_size_x = size_x
    -- 顶部菜单
    ImGui.SetNextWindowPos(0, 0)
    ImGui.SetNextWindowSize(size_x, top_y)
    if ImGui.Begin("demo_main_title", nil, ImGui.WindowFlags {"AlwaysAutoResize", "NoMove", "NoTitleBar", "NoScrollbar"}) then 
		ImGui.SetCursorPosX(200)
        for i, v in ipairs(data_mgr.get_data()) do 
            local current = v.category == category
            set_btn_style(current, true)
            local label = v.category .. "###main_category_i_" .. i
            if ImGui.ButtonEx(label, 50 + 30 * dpiScale, 25 * dpiScale) or category == "" then 
                category = v.category
                dep.common.user_data.set('last_category', category, true)
                if not selected[category] then 
                    selected[category] = dep.common.user_data.get_number('last_category_' .. category)
                end
                if selected[category] > 0 then 
                    data_mgr.set_current_item(category, selected[category])    
                end
				sound.play_sound("/pkg/demo.res/sound/click.wav")
            end
            ImGui.SameLine()
            ImGui.PopStyleColorEx(4)
        end
		ImGui.SetCursorPosX(size_x - 120)
		if ImGui.Button(" Auto Test ") then 
			auto_test.begin(system)
		end

		ImGui.SameLine()
		ImGui.SetCursorPosX(30)
		if ImGui.ButtonEx(" 主 页 ##btn_return", 80) then 
			dep.common.map.load({feature = {"entry"}, pre = "demo"})
		end
    end
    ImGui.End()

    local tbList = data_mgr.find_category(category) or {items = {}}
    local item
    
    -- 左边菜单
    local begin_y = top_y
    local left_body_y = size_y - begin_y;
    data_mgr.set_content_start(200, begin_y)
    data_mgr.set_content_size(top_size_x - 200, left_body_y)
    ImGui.SetNextWindowPos(0, begin_y)
    ImGui.SetNextWindowSize(200, left_body_y)
    ImGui.PushStyleVarImVec2(ImGui.StyleVar.ButtonTextAlign, 0, 0.5)
    if ImGui.Begin("demo_main_body_left", nil, ImGui.WindowFlags {"AlwaysAutoResize", "NoMove", "NoTitleBar", "NoScrollbar"}) then 
        for i, v in ipairs(tbList.items) do 
            local label = v.name .. "###main_body_left_" .. i
            local current = v.id == selected[category]
            if current then 
                item = v
            end
            set_btn_style(current, v.ok)
            local click = false
            if ImGui.ButtonEx(label, 185) or not selected[category] or (selected[category] == 0) then 
                click = true
				sound.play_sound("/pkg/demo.res/sound/click.wav")
            end
            ImGui.PopStyleColorEx(4)
			local root = dep.common.path_def.project_root
			if root and v.file then
				local id = string.format("btn_left_pop_id_%d", i)
				if ImGui.BeginPopupContextItem(id) then 
					click = true
					showHover = false
					local file = root .. v.file
					file = file:gsub("/","\\")
					if ImGui.MenuItem("打开文件") then 
						os.execute("code "..file)
					end
					if ImGui.MenuItem("选中文件") then 
						os.execute("c:\\windows\\explorer.exe /select,".. file)
					end
					ImGui.EndPopup()
				else 
					if showHover and ImGui.IsItemHovered() then
						if ImGui.BeginTooltip() then
							ImGui.Text("右键可选中/打开所在文件")
							ImGui.EndTooltip()
						end
					end
				end
			end

            if click and selected[category] ~= v.id then 
                selected[category] = v.id
                data_mgr.set_current_item(category, v.id)
                dep.common.user_data.set('last_category_' .. category, v.id, true) 
            end
        end
    end
    ImGui.End()
    ImGui.PopStyleVar()
end

function system.set_current_item(_category, _item_id)
	category = _category
	selected[_category] = _item_id
	data_mgr.set_current_item(_category, _item_id)
	sound.play_sound("/pkg/demo.res/sound/click.wav")
end

function system.init()
	local fonts = {}
	fonts[#fonts+1] = {
		FontPath = "/pkg/demo.res/font/Alibaba-PuHuiTi-Regular.ttf",
		SizePixels = 18,
		GlyphRanges = { 0x0020, 0xFFFF }
	}
	local ImGuiAnt      = import_package "ant.imgui"
	ImGuiAnt.FontAtlasBuild(fonts)
end