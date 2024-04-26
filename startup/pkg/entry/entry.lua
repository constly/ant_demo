local ecs = ...
local world = ecs.world
local m = ecs.system "entry_system"
local ImGui = require "imgui"
local window = require "window"

---@type ly.common
local common = import_package 'ly.common'

---@class entry.game
---@field name string 名字
---@field feature table 
---@field desc string 

---@type entry.game[]
local games = {
	{name = "demo", feature = {"demo|gameplay"}, desc = "some usage examples of the ant"},
	{name = "sims", feature = {"sims"}, desc = "sample project 1"},
}

local selected = tonumber(common.user_data.get("entry.las")) or 1

function m.init_world()
	window.set_title("Ant Game Engine 学习记录")
	-- 设置项目根目录
	if world.args.ecs.project_root then
		common.path_def.project_root = world.args.ecs.project_root
	end

	local tbParam = common.map.tbParam or {}
	for i, game in ipairs(games) do 
		if game.name == tbParam.pre then 
			selected = i
		end
	end
end

function m.data_changed()
	local viewport = ImGui.GetMainViewport();
    local size_x, size_y = viewport.WorkSize.x, viewport.WorkSize.y
	local width, height = 500, 400
	ImGui.SetNextWindowPos((size_x - width) * 0.5, (size_y - height) * 0.5 - 50)
    ImGui.SetNextWindowSize(width, height)
    if ImGui.Begin("main", nil, ImGui.WindowFlags {"NoMove", "NoTitleBar", "NoResize", "NoScrollbar"}) then 
		local game = games[selected]
		if game then 
			ImGui.Dummy(10, 30)
			common.imgui_utils.draw_text_center(game.desc)
		end
		ImGui.Dummy(10, 30)
		local y = ImGui.GetCursorPosY()
		ImGui.SetCursorPos(150, y)
		ImGui.BeginGroup()
		for i, game in ipairs(games) do 
			if common.imgui_utils.draw_btn(game.name, selected == i, {size_x = 200, size_y = 35}) then 
				selected = i
				common.user_data.set("entry.las", selected, true)
			end
		end
		ImGui.EndGroup()

		if game then
			ImGui.Dummy(10, 50)
			local y = ImGui.GetCursorPosY()
			ImGui.SetCursorPos(width * 0.5 - 50, y)
			if common.imgui_utils.draw_btn("GO", true, {size_x = 100, size_y = 30}) then 
				common.map.load({feature = game.feature})
			end
		end
	end
	ImGui.End()
end