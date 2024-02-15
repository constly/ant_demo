
local ImGui = require "imgui"
local ImGuiExtend = require "imgui.extend"
local tools = import_package "game.tools"

local api = {}
local label = "World Dump##popup_world_dump"
local cur_key 
local text_editor
local keys = {
	"args",
	"_group_tags",
	"_clibs_loaded",
	"_templates",
	"_cpu_stat",
	"_envs",
	"_components",
	"_systems",
	"_initsystems",
	"_exitsystems",
	"_updatesystems",
	"_system_step",
	"_decl.pipeline",
	"_decl.component",
	"_decl.feature",
	"_decl.system",
	"_decl.policy",
}

local set_btn_style = function(current)
    if current then 
        ImGui.PushStyleColorImVec4(ImGui.Col.Button, 0.6, 0.6, 0.25, 1)
        ImGui.PushStyleColorImVec4(ImGui.Col.ButtonHovered, 0.5, 0.5, 0.25, 1)
        ImGui.PushStyleColorImVec4(ImGui.Col.ButtonActive, 0.5, 0.5, 0.25, 1) 
        ImGui.PushStyleColorImVec4(ImGui.Col.Text, 0.95, 0.95, 0.95, 1)
    else 
        ImGui.PushStyleColorImVec4(ImGui.Col.Button, 0.2, 0.2, 0.25, 1)
        ImGui.PushStyleColorImVec4(ImGui.Col.ButtonHovered, 0.3, 0.3, 0.3, 1)
        ImGui.PushStyleColorImVec4(ImGui.Col.ButtonActive, 0.25, 0.25, 0.25, 1)
        ImGui.PushStyleColorImVec4(ImGui.Col.Text, 0.95, 0.95, 0.95, 1)
    end
	ImGui.PushStyleVarImVec2(ImGui.StyleVar.ButtonTextAlign, 0, 0.5)
end


function api.open()
	ImGui.OpenPopup(label, ImGui.PopupFlags { "None" });
	if not text_editor then 
		text_editor = ImGuiExtend.CreateTextEditor()
		text_editor:SetTabSize(8)
		text_editor:SetShowWhitespaces(false)
		text_editor:SetReadOnly(true)
	end
end


function api.draw(world)
	local viewport = ImGui.GetMainViewport();
    local size_x, size_y = viewport.WorkSize.x, viewport.WorkSize.y
	local wnd_x, wnd_y = size_x - 200, size_y - 100
	ImGui.SetNextWindowPos((size_x - wnd_x) * 0.5, (size_y - wnd_y) * 0.5) 
	ImGui.SetNextWindowSize(wnd_x, wnd_y)

	if ImGui.BeginPopupModal(label, true, ImGui.WindowFlags{"NoResize", "NoMove"}) then 
		local height = wnd_y - 50
		if ImGui.BeginChild("##child_1", 220, height, ImGui.ChildFlags({"Border"})) then
			for i, name in ipairs(keys) do 
				set_btn_style(cur_key == i)
				if ImGui.ButtonEx(name, 200) or not cur_key then 
					cur_key = i
					local arr = tools.lib.split(name, ".")
					local data = world
					local idx = 1
					while idx <= #arr and data do
						data = data[arr[idx]]
						idx = idx + 1
					end
					text_editor:SetText( tools.lib.table2string(data) )
				end
				ImGui.PopStyleColorEx(4)
				ImGui.PopStyleVar()
			end
			ImGui.EndChild()
		end
		ImGui.SameLine()
		text_editor:Render("##text_show", wnd_x - 250, height, true)

		ImGui.EndPopup();
	end
end

return api;