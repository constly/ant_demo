---------------------------------------------------------------------------
-- 图绘制
---------------------------------------------------------------------------
local dep = require 'dep'
local ImGui = dep.ImGui
local ed = dep.ed

---@param editor blueprint_graph_main
local create = function(editor)
	---@class blueprint_graph_draw 蓝图绘制
	local draw = {}
	local context 			

	local newNodeLinkPin = nil

	function draw.on_init()
		context = ed.CreateEditorContext()
		context:OnStart()
	end 

	function draw.on_destroy()
		context:OnDestroy()
		context = nil
	end 

	-- 渲染更新
	---@param graph blueprint_graph_data
	function draw.on_render(graph, deltatime)
		ed.SetCurrentEditor(context)
		ed.Begin("My Editor", 0, 0)

		do
			for _, node in ipairs(graph.nodes) do 
				local show_type = node.tpl.show_type 
				
				local id = node.id
				if not ed.CheckNodeExist(id) then 
					ed.SetNodePosition(id, node.pos_x, node.pos_y) 
				end

				ed.BeginNode(id)
					ImGui.Text("Node A")
					ImGui.BeginGroup();
						for _, pin in ipairs(node.input_flows) do 
							ed.BeginPin(pin.id, ed.PinKind.Input)
								ImGui.Text(pin.key)
							ed.EndPin()
						end
					ImGui.EndGroup()
					
					ImGui.SameLine()
					ImGui.BeginGroup();
						for _, pin in ipairs(node.output_flows) do 
							ed.BeginPin(pin.id, ed.PinKind.Output)
								ImGui.Text(pin.key)
							ed.EndPin()
						end
					ImGui.EndGroup();
					
				ed.EndNode()
			end
		end

		local posx, posy = ImGui.GetMousePos();
		ed.Suspend()
		local contextNodeId = ed.ShowNodeContextMenu()
		local contextPinId = ed.ShowPinContextMenu()
		local contextLinkId = ed.ShowLinkContextMenu()
		if contextNodeId then 
			ImGui.OpenPopup("Node Context Menu");
		elseif contextPinId then
			ImGui.OpenPopup("Pin Context Menu");
		elseif contextLinkId then
			ImGui.OpenPopup("Link Context Menu");
		elseif ed.ShowBackgroundContextMenu() then
			ImGui.OpenPopup("Create New Node");
			newNodeLinkPin = nil;
		end
		ed.Resume()

		ed.Suspend();
		ImGui.PushStyleVarImVec2(ImGui.StyleVar.WindowPadding, 8, 8);
		if ImGui.BeginPopup("Node Context Menu") then 
			ImGui.TextUnformatted("Node Context Menu");
			ImGui.EndPopup()
		end

		if ImGui.BeginPopup("Create New Node") then		
    		if ImGui.BeginMenu("创 建") then 
				for i, data in ipairs(editor.args.blueprint_builder.nodes) do 
					if ImGui.MenuItem(data.name) then
						editor.data_hander.create_node(posx, posy, data)
						editor.stack.snapshoot(true)
					end
				end
				ImGui.EndMenu()
			end
			ImGui.EndPopup()
		end
		ImGui.PopStyleVar()
		ed.Resume()

		ed.End()
		ed.SetCurrentEditor(nil)
	end

	return draw
end 


return {create = create}