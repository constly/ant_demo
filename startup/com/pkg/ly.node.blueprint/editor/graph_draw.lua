---------------------------------------------------------------------------
-- 图绘制
---------------------------------------------------------------------------
local dep = require 'dep' ---@type ly.node.blueprint.dep
local def = require 'def' ---@type ly.node.blueprint.def
local ImGui = dep.ImGui
local ed = dep.ed

---@param editor blueprint_editor
local create = function(editor)
	---@class blueprint_graph_draw 蓝图绘制
	local graph = {}
	local context 			
	local builder
	local newNodeLinkPin = nil
	local img_bg
	local open_menu_x, open_menu_y
	local createNewNode = false
	---@type blueprint_node_pin_data
	local newLinkPin
	local newLinkPinNode
	local has_open_menu = false
	local graph_data ---@type blueprint_graph_data

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
	---@param _graph_data blueprint_graph_data
	---@param _deltatime number 渲染间隔(秒)
	---@param params table<string, any> 扩展参数
	function graph.on_render(_graph_data, _deltatime, params)
		graph_data = _graph_data
		ed.SetCurrentEditor(context)
		ed.Begin("BlueprintGraphDraw", 0, 0)
		if params.needReload then graph.reload(graph_data) end

		local screen_pos_x, screen_pos_y = ImGui.GetCursorScreenPos()
		builder:Init(dep.textureman.texture_get(img_bg.id), 64, 64);

		-- 绘制节点
		for _, node in ipairs(graph_data.nodes) do 
			local node_tpl = editor.data_hander.get_node_tpl(editor.blueprint_builder, node)
			if node_tpl then 
				local show_type = node_tpl.show_type 
				if show_type == def.type_blueprint then 
					graph.draw_blueprint(node, node_tpl)
				elseif show_type == def.type_simple then 
					graph.draw_simple(node, node_tpl)
				elseif show_type == def.type_tree then 
					graph.draw_tree(node, node_tpl)
				elseif show_type == def.type_houdini then 
					graph.draw_houdini(node, node_tpl)
				elseif show_type == def.type_comment then
					graph.draw_comment(node, node_tpl)
				end
			else 
				graph.draw_errornode(node)
			end
		end

		-- 绘制连线
		for _, v in ipairs(graph_data.links) do 
			ed.PinLink(v.id, v.startPin, v.endPin, v.type, 2)
		end

		if not createNewNode then 
			graph.draw_querylink(graph_data);
		end
		ImGui.SetCursorScreenPos(screen_pos_x, screen_pos_y)
		
		graph.draw_menu();
		graph.check_dirty();
		ed.End()

		if params.navigateToContent then ed.NavigateToContent() end
		ed.SetCurrentEditor(nil)
	end

	function graph.reload()
		for _, node in ipairs(graph_data.nodes) do 
			ed.SetNodePosition(node.id, node.pos_x, node.pos_y)
		end
		ed:ClearDirty()
	end

	function graph.can_create_link(pin1, pin2, node1, node2)
		return editor.data_hander.can_create_link(graph_data, pin1, pin2, node1, node2)
	end

	---@param node blueprint_node_data
	---@param node_tpl blueprint_node_tpl_data
	function graph.draw_blueprint(node, node_tpl)
		builder:Begin(node.id)	
			local input_text_max_x = 0;
			for i, pin in ipairs(node.inputs) do 
				input_text_max_x = math.max(input_text_max_x, ImGui.CalcTextSize(pin.key))
			end

			local output_text_max_x = 0;
			for i, pin in ipairs(node.outputs) do 
				output_text_max_x = math.max(output_text_max_x, ImGui.CalcTextSize(pin.key))
			end

			-- draw header
			if node_tpl.header_color then 
				builder:Header(table.unpack(node_tpl.header_color))
			else 
				builder:Header(0.5, 0.5, 0.5, 1)
			end
			local pos1 = ImGui.GetCursorPosX()
			ImGui.Text(node_tpl.name);
			ImGui.SameLine()
			ImGui.Dummy(0, 25)
			if #node.delegates > 0 then 
				ImGui.SameLine();
				local size = ImGui.GetCursorPosX() - pos1
				local data = node.delegates[1] 
				local content_x = input_text_max_x + output_text_max_x + 100;
				local need_x = ImGui.CalcTextSize(data.key) + 30
				if size + need_x < content_x then 
					ImGui.Dummy(content_x - size - need_x, 20);
					ImGui.SameLine()
				end

				local alpha = 1
				if newLinkPin and not graph.can_create_link(newLinkPin, data, newLinkPinNode, node) and newLinkPin ~= data then 
					alpha = alpha * 0.188;
				end

				ed.BeginPin(data.id, ed.PinKind.Output)
				ed.PinPivotAlignment(1.0, 0.5);
				ed.PinPivotSize(0, 0);
				ImGui.BeginGroup()
				ImGui.PushStyleVar(ImGui.StyleVar.Alpha, alpha)
				ImGui.Text(data.key)
				ImGui.PopStyleVar()
				ImGui.SameLine()
				local is_linked = editor.data_hander.is_pin_linked(graph_data, data)
				ed.DrawPinIcon(ed.PinType.Delegate, is_linked, math.ceil(alpha * 255))
				ImGui.EndGroup()
				ed.EndPin()
			end
			builder:EndHeader()
			local head_x = builder:GetHeaderSize()

			if #node.inputs > 0 then
				for i, pin in ipairs(node.inputs) do 
					local alpha = 1
					if newLinkPin and not graph.can_create_link(newLinkPin, pin, newLinkPinNode, node) and pin ~= newLinkPin then 
						alpha = alpha * 0.188
					end
					builder:Input(pin.id)
					ed.DrawPinIcon(pin.type, false, math.ceil(alpha * 255))
					ImGui.SameLine()
					ImGui.PushStyleVar(ImGui.StyleVar.Alpha, alpha)
					ImGui.Text(pin.key or "")
					ImGui.PopStyleVar()
					builder:EndInput()
				end
			elseif #node.outputs > 0 then
				local out_x = output_text_max_x + 35;
				if out_x < head_x then
					ImGui.Dummy(head_x - out_x, 20);
					ImGui.SameLine()
				end
			end

			for i, pin in ipairs(node.outputs) do 
				local alpha = 1
				if newLinkPin and not graph.can_create_link(newLinkPin, pin, newLinkPinNode, node) and pin ~= newLinkPin then 
					alpha = alpha * 0.188
				end
				builder:Output(pin.id)
				local size = ImGui.CalcTextSize(pin.key)
				ImGui.Dummy(35 + output_text_max_x, 20)
				ImGui.SameLineEx(output_text_max_x - size + 1)
				ImGui.PushStyleVar(ImGui.StyleVar.Alpha, alpha)
				ImGui.Text(pin.key)
				ImGui.PopStyleVar()
				ImGui.SameLineEx(output_text_max_x + 10)
				ed.DrawPinIcon(pin.type, false, math.ceil(alpha * 255))
				
				builder:EndOutput()
			end
			
		builder:End()
	end

	---@param node blueprint_node_data
	---@param node_tpl blueprint_node_tpl_data
	function graph.draw_simple(node, node_tpl)
		builder:Begin(node.id)	
			builder:Middle()
			ImGui.Text(node_tpl.name)
			local output_text_max_x = 0;
			for i, pin in ipairs(node.outputs) do 
				output_text_max_x = math.max(output_text_max_x, ImGui.CalcTextSize(pin.key))
			end

			for i, pin in ipairs(node.outputs) do 
				local alpha = 1
				if newLinkPin and not graph.can_create_link(newLinkPin, pin, newLinkPinNode, node) and pin ~= newLinkPin then 
					alpha = alpha * 0.188
				end
				builder:Output(pin.id)
				local size = ImGui.CalcTextSize(pin.key)
				ImGui.Dummy(35 + output_text_max_x, 20)
				ImGui.SameLineEx(output_text_max_x - size + 1)
				ImGui.PushStyleVar(ImGui.StyleVar.Alpha, alpha)
				ImGui.Text(pin.key)
				ImGui.PopStyleVar()
				ImGui.SameLineEx(output_text_max_x + 10)
				ed.DrawPinIcon(pin.type, false, math.ceil(alpha * 255))
				
				builder:EndOutput()
			end
		builder:End()
	end

	---@param node blueprint_node_data
	---@param node_tpl blueprint_node_tpl_data
	function graph.draw_tree(node, node_tpl)

	end

	---@param node blueprint_node_data
	---@param node_tpl blueprint_node_tpl_data
	function graph.draw_houdini(node, node_tpl)

	end

	---@param node blueprint_node_data
	---@param node_tpl blueprint_node_tpl_data
	function graph.draw_comment(node, node_tpl)
		ImGui.PushStyleVar(ImGui.StyleVar.Alpha, 0.75)
		ed.PushStyleColor(ed.StyleColor.NodeBg, 0.3, 0.3, 0.3, 0.7)
		ed.PushStyleColor(ed.StyleColor.NodeBorder, 0.8, 0.8, 0.8, 1)
		ed.BeginNode(node.id)	
		ImGui.PushIDInt(node.id)

		node_tpl.size = node_tpl.size or {}
		local x, y = node_tpl.size.x or 300, node_tpl.size.y or 300
		ImGui.BeginGroup();
		ImGui.AlignTextToFramePadding();
		local size = ImGui.CalcTextSize(node_tpl.name)
		local posx = (x - size) * 0.5 - 10
		if posx > 0 then 
			ImGui.Dummy(posx, 10)
			ImGui.SameLine();
		end
		ImGui.Text(node_tpl.name);
		ImGui.EndGroup();

		ImGui.BeginGroup();
		ed.Group(x, y)
		ImGui.EndGroup();

		ImGui.PopID();
		ed.EndNode()
		ed.PopStyleColor(2);
		ImGui.PopStyleVar()
	end

	---@param node blueprint_node_data
	function graph.draw_errornode(node)
		builder:Begin(node.id)	
		builder:Header(1, 0, 0, 1)
		ImGui.Text(node.tplId .. " missing");
		builder:EndHeader()
		builder:End()
	end

	function graph.draw_querylink()
		if ed.BeginCreate(1, 1, 1, 1, 2) then 
			local showLabel = function(label, color)
				color = {0.1, 0.1, 0.1, 1}
				ImGui.SetCursorPosY(ImGui.GetCursorPosY() - ImGui.GetTextLineHeight());
				local sizex, sizey = ImGui.CalcTextSize(label)
				local padding = {x = 3, y = 3}
				local spacing = {x = 3, y = 3}
				local px, py = ImGui.GetCursorPos()
				ImGui.SetCursorPos(px + spacing.y, py - spacing.y);

				local p1, p2 = ImGui.GetCursorScreenPos()
				local rectMin = {p1 - padding.x,  p2 - padding.y };
				local rectMax = {p1 + sizex + padding.x, p2 + sizey + padding.y};

				local draw_list = dep.ImGuiExtend.draw_list;
				draw_list.AddRectFilled({min = rectMin, max = rectMax, col = color, rounding = 10}); 
				ImGui.Text(label);
			end
			local inputPinId, outputPinId = ed.QueryNewLink()
			if inputPinId and outputPinId then
				local pin1, node1 = editor.data_hander.find_pin(graph_data, inputPinId)
				local pin2, node2 = editor.data_hander.find_pin(graph_data, outputPinId)
				newLinkPin = pin1 and pin1 or pin2;
				if pin1 and pin1.kind == ed.PinKind.Input then 
					pin1, pin2 = pin2, pin1
				end
				if pin1 and pin2 then 
					if pin1 == pin2 then 
						ed.RejectNewItem(255, 0, 0, 255, 2)
					elseif pin2.kind == pin1.kind then 
						showLabel("端口不匹配");
						ed.RejectNewItem(255, 0, 0, 255, 2.0);
					elseif pin2.type ~= pin1.type or not graph.can_create_link(pin1, pin2, node1, node2) then 
						showLabel("端口不匹配");
						ed.RejectNewItem(255, 128, 128, 255, 1)
					else 
						showLabel("+ 创建连线");
						if ed.AcceptNewItem(0.5, 1, 0.5, 4) then
							table.insert(graph_data.links, {id = editor.data_hander.next_id(), startPin = pin1.id, endPin = pin2.id, type = pin1.type})
							dep.common.lib.dump(graph_data.links)
							editor.stack.snapshoot(true)
						end
					end
				end
			end

			local pinId = ed.QueryNewNode()
			if pinId then 
				newLinkPin = editor.data_hander.find_pin(graph_data, pinId)
				if newLinkPin then 
					showLabel("+ 创建节点")
				end
				if ed.AcceptNewItem() then 
					createNewNode = true
					newNodeLinkPin = newLinkPin and newLinkPin.id or 0
					newLinkPin = nil
					ed.Suspend();
					ImGui.OpenPopup("Create New Node");
					has_open_menu = true
					ed.Resume();
				end
			end
		else 
			newLinkPin = nil
		end
		ed.EndCreate();

		if newLinkPin then 
			newLinkPin, newLinkPinNode = editor.data_hander.find_pin(graph_data, newLinkPin.id)
		else 
			newLinkPinNode = nil
		end

		if ed.BeginDelete() then 
			local ok = false
			local deletedLinkId = ed.QueryDeletedLink()
			while deletedLinkId do 
				if ed.AcceptDeletedItem() and editor.data_hander.remove_link(graph_data, deletedLinkId) then 
					ok = true
				end
				deletedLinkId = ed.QueryDeletedLink()
			end
			local deletedNodeId = ed.QueryDeletedNode()
			while deletedNodeId do 
				if ed.AcceptDeletedItem() and editor.data_hander.remove_node(graph_data, deletedNodeId) then 
					ok = true
				end
				deletedNodeId = ed.QueryDeletedNode()
			end
			if ok then editor.stack.snapshoot(true) end
		end 
		ed.EndDelete()
	end

	function graph.draw_menu() 
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
			has_open_menu = true
		end
		ed.Resume()

		if has_open_menu then 
			open_menu_x, open_menu_y = ImGui.GetMousePos(); 
			has_open_menu = false
		end

		ed.Suspend();
		ImGui.PushStyleVarImVec2(ImGui.StyleVar.WindowPadding, 8, 8);
		if ImGui.BeginPopup("Node Context Menu") then 
			ImGui.Text("Node Context Menu");
			ImGui.EndPopup()
		end

		if ImGui.BeginPopup("Pin Context Menu") then 
			ImGui.Text("Pin Context Menu");
			ImGui.EndPopup()
		end

		if ImGui.BeginPopup("Link Context Menu") then 
			ImGui.Text("Link Context Menu");
			ImGui.EndPopup()
		end

		if ImGui.BeginPopup("Create New Node") then		
    		if ImGui.BeginMenu("创 建") then 
				for i, data in ipairs(editor.args.blueprint_builder.nodes) do 
					if ImGui.MenuItem(data.name) then
						createNewNode = false
						editor.data_hander.create_node(open_menu_x, open_menu_y, data)
						editor.stack.snapshoot(true)
					end
				end
				ImGui.EndMenu()
			end
			ImGui.EndPopup()
		else 
			createNewNode = false
		end
		ImGui.PopStyleVar()
		ed.Resume()
	end

	function graph.check_dirty()
		local n = ed.GetDirtyReason();
		if n > 0 then 
			-- add 和 remove 上面已经处理了
			--if (n & def.dirty_AddNode) or (n & def.dirty_RemoveNode) then 
			--	editor.stack.snapshoot(true)
			--else
			if (n & def.dirty_Position) > 0 then
				for _, node in ipairs(graph_data.nodes) do 
					local posx, posy = ed.GetNodePosition(node.id)
					node.pos_x = posx
					node.pos_y = posy
				end
				editor.stack.snapshoot(false)
			end
			ed.ClearDirty()
		end
	end

	return graph
end 


return {create = create}