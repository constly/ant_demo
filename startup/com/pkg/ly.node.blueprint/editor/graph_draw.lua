---------------------------------------------------------------------------
-- 图绘制
---------------------------------------------------------------------------
local dep = require 'dep' ---@type ly.node.blueprint.dep
local ImGui = dep.ImGui
local ed = dep.ed

---@param editor blueprint_graph_main
local create = function(editor)
	---@class blueprint_graph_draw 蓝图绘制
	local graph = {}
	local context 			
	local builder
	local newNodeLinkPin = nil
	local img_bg
	local open_menu_x, open_menu_y

	function graph.on_init()
		context = ed.CreateEditorContext()
		builder = ed.CreateBlueprintNodeBuilder()
		img_bg = dep.assetmgr.resource("/pkg/ly.node.blueprint/assets/imgs/BlueprintBackground.texture", { compile = true })
		context:OnStart()
	end 

	function graph.on_destroy()
		context:OnDestroy()
		context = nil
		builder = nil
	end 

	-- 渲染更新
	---@param graph_data blueprint_graph_data
	function graph.on_render(graph_data, deltatime)
		ed.SetCurrentEditor(context)
		ed.Begin("BlueprintGraphDraw", 0, 0)
		builder:Init(dep.textureman.texture_get(img_bg.id), 64, 64);

		-- 绘制节点
		local builder = editor.args.blueprint_builder
		for _, node in ipairs(graph_data.nodes) do 
			local id = node.id
			if not ed.CheckNodeExist(id) then 
				ed.SetNodePosition(id, node.pos_x, node.pos_y) 
			end

			local show_type = node.tpl.show_type 
			if show_type == builder.type_blueprint then 
				graph.draw_blueprint(node)
			elseif show_type == builder.type_simple then 
				graph.draw_simple(node)
			end
		end
		
		graph.draw_menu();
		ed.End()
		ed.SetCurrentEditor(nil)
	end

	---@param node blueprint_node_data
	function graph.draw_blueprint(node)
		builder:Begin(node.id)	
			-- draw header
			builder:Header(0.5, 0.5, 0.5, 1)
			ImGui.Text(node.tpl.name);
			ImGui.SameLine()
			ImGui.Dummy(0, 28)
			if #node.delegates > 0 then 
				ImGui.SameLine();
				local data = node.delegates[1] 
				ed.BeginPin(data.id, ed.PinKind.Output)
				ed.PinPivotAlignment(1.0, 0.5);
				ed.PinPivotSize(0, 0);
				
				ImGui.BeginGroup()
				ImGui.Text(data.key)
				ImGui.SameLine()
				ed.DrawPinIcon(ed.PinType.Delegate, false, 255)
				ImGui.EndGroup()
				ed.EndPin()
			end
			builder:EndHeader()
			
		builder:End()
	end

	function graph.draw_simple(node)
		
	end

	function graph.draw_menu() 
		ed.Suspend()
		local has_open = false
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
			has_open = true
		end
		ed.Resume()

		if has_open then open_menu_x, open_menu_y = ImGui.GetMousePos(); end

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
						editor.data_hander.create_node(open_menu_x, open_menu_y, data)
						editor.stack.snapshoot(true)
					end
				end
				ImGui.EndMenu()
			end
			ImGui.EndPopup()
		end
		ImGui.PopStyleVar()
		ed.Resume()
	end

	return graph
end 


return {create = create}