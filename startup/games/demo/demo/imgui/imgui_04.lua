local ecs = ...
local ImGui     = require "imgui"
local mgr = require "data_mgr"
local tbParam = 
{
    ecs             = ecs,
    system_name     = "imgui_04_system",
    category        = mgr.type_imgui,
    name            = "04_Table",
    file            = "imgui/imgui_04.lua",
	ok				= true,
}
local system = mgr.create_system(tbParam)

function system.data_changed()
    ImGui.SetNextWindowPos(mgr.get_content_start())
    ImGui.SetNextWindowSize(mgr.get_content_size())
	if ImGui.Begin("window_body", nil, ImGui.WindowFlags {"NoResize", "NoMove", "NoScrollbar", "NoCollapse", "NoTitleBar"}) then 

		local n = 9
		if ImGui.BeginTable("table1", n, ImGui.TableFlags {'BordersInnerH', 'Borders', }) then
			for i = 1, n do 
				ImGui.TableSetupColumnEx("H" .. i, ImGui.TableColumnFlags {'WidthStretch'}, 60);
			end
			ImGui.TableHeadersRow();

			for i = 1, n do 
				ImGui.TableNextRow();
				for j = 1, i  do 
					ImGui.TableNextColumn()
					ImGui.Text(string.format("%d x %d", j, i))
				end 
			end 

			ImGui.TableNextRow();
			ImGui.TableNextColumn()
			ImGui.Text(" ")
			
			do 
				ImGui.TableNextRow();
				ImGui.TableNextColumn()
				ImGui.Text("文字+按钮")
				ImGui.ButtonEx("按钮名", 80)

				ImGui.TableNextColumn()
				ImGui.BeginChild("##show_joints", 100, 100, ImGui.ChildFlags{'Border'})
				ImGui.Text("内嵌子窗口")
				ImGui.EndChild()

				ImGui.TableSetColumnIndex(4);
				ImGui.Text("跳到\n第5列显示")
			end
			
			do 
				ImGui.TableNextRow();
				ImGui.TableNextColumn()
				if ImGui.TreeNode("TreeNode") then 
					ImGui.Text("Tree内容")
					ImGui.TreePop();
				end

				ImGui.TableNextColumn()
				ImGui.Text("内嵌子Table")
				if ImGui.BeginTable("table1", 2) then
					ImGui.TableSetupColumn("列1");
					ImGui.TableSetupColumn("列2");
					ImGui.TableHeadersRow();
					for i = 1, 3 do 
						ImGui.TableNextRow();
						ImGui.TableNextColumn()
						ImGui.Text("v1" .. i)
						ImGui.TableNextColumn()
						ImGui.Text("v2" .. i)
					end
					ImGui.EndTable()
				end
			end
			ImGui.EndTable()
		end
	end 
	ImGui.End()
end