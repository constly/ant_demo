local ecs = ...
local mgr = require "data_mgr"
local tbParam = 
{
    ecs             = ecs,
    system_name     = "imgui_10_system",
    category        = mgr.type_imgui,
    name            = "10_原生节点使用",
    file            = "imgui/imgui_10.lua",
    ok              = true
}
local system = mgr.create_system(tbParam)
local dep = require 'dep'
local ed = dep.ed
local ImGui  = dep.ImGui
local ImGuiExtend = dep.ImGuiExtend
local draw_list = ImGuiExtend.draw_list
local context
local links = {{id = 1, input = 7, output = 12}}
local next_link_id = 1;
local id = 0
local next_id = function()
	id = id + 1
	return id
end
local needNavigateTo = false

function system.on_entry()
	if not context then 
		context = ed.CreateEditorContext()
		context:OnStart()
	end
	needNavigateTo = true
end

function system.data_changed()
	ImGui.SetNextWindowPos(mgr.get_content_start())
    ImGui.SetNextWindowSize(mgr.get_content_size())
    if ImGui.Begin("window_body", nil, ImGui.WindowFlags {"NoResize", "NoMove", "NoScrollbar", "NoScrollWithMouse", "NoCollapse", "NoTitleBar"}) then 
		local size_x, size_y = ImGui.GetContentRegionAvail();
		local io = ImGui.GetIO()
		ImGui.Text(string.format("FPS: %.2f (%.2gms)", io.Framerate, io.Framerate > 0 and 1000 / io.Framerate or 0 ))
		ImGui.SameLineEx(size_x * 0.5 - 150)
		ImGui.Text("原生节点编辑器使用演示")
		ImGui.SetCursorPos(size_x - 100, 5)
		if ImGui.ButtonEx("重置视图") then 
			needNavigateTo = true
		end

		ed.SetCurrentEditor(context)
			ed.Begin("My Editor", 0, 0)
				id = 0
				system.draw_node1();
				system.draw_node2();
				system.draw_node3();
				system.draw_node4();
				system.draw_node5();
				system.draw_links()
			ed.End()

			if needNavigateTo then 
				needNavigateTo = false
				ed.NavigateToContent()
			end
		ed.SetCurrentEditor(nil)
	end 
	ImGui.End()
end

function system.draw_node1()
	local id = next_id()
	if not ed.CheckNodeExist(id) then ed.SetNodePosition(id, 50, 20) end

	ed.BeginNode(id)
		ImGui.Text("Node A")
		ImGui.BeginGroup();
			ed.BeginPin(next_id(), ed.PinKind.Input)
				ImGui.Text("-> In1")
			ed.EndPin()
			ed.BeginPin(next_id(), ed.PinKind.Input)
				ImGui.Text("-> In2")
			ed.EndPin()
		ImGui.EndGroup()
		
		ImGui.SameLine()
		ed.BeginPin(next_id(), ed.PinKind.Output)
			ImGui.Text("Out ->")
		ed.EndPin()
	ed.EndNode()
end

local clicked = 0
local check = {true}
local e = 0;
local counter = 0
local str1 = ImGui.StringBuf()
local f0 = {0.5}
local f1 = {0.5}
local f2 = {0.5}
function system.draw_node2()
	local id = next_id()
	if not ed.CheckNodeExist(id) then ed.SetNodePosition(id, 50, 150) end

	ed.BeginNode(id)
		ImGui.Text("Basic Widget Demo");
		ed.BeginPin(next_id(), ed.PinKind.Input);
			ImGui.Text("-> In");
		ed.EndPin();
		ImGui.SameLine();
		ImGui.Dummy(250, 0);  -- Hacky magic number to space out the output pin.
		ImGui.SameLine();
		ed.BeginPin(next_id(), ed.PinKind.Output);
			ImGui.Text("Out ->");
		ed.EndPin();

		-- Normal Button
		if ImGui.Button("Button") then 
			clicked = clicked + 1;
		end
		if clicked % 2 == 1 then
			ImGui.SameLine();
			ImGui.Text("Thanks for clicking me!");
		end

		-- Checkbox
		ImGui.Checkbox("checkbox", check);

		-- Radio buttons
		if ImGui.RadioButton("radio a", e == 0) then e = 0 end  ImGui.SameLine();
		if ImGui.RadioButton("radio b", e == 1) then e = 1 end  ImGui.SameLine();
		if ImGui.RadioButton("radio c", e == 2) then e = 2 end

		-- Color buttons, demonstrate using PushID() to add unique identifier in the ID stack, and changing style.
		for i = 0, 7 do
			if i > 0 then ImGui.SameLine() end
			ImGui.PushID(i);
			ImGui.PushStyleColorImVec4(ImGui.Col.Button, i / 7, 0.6, 0.6, 1);
			ImGui.PushStyleColorImVec4(ImGui.Col.ButtonHovered, i / 7.0, 0.7, 0.7, 1);
			ImGui.PushStyleColorImVec4(ImGui.Col.ButtonActive, i / 7.0, 0.8, 0.8, 1);
			ImGui.Button("Click");
			ImGui.PopStyleColorEx(3);
			ImGui.PopID();
		end

		-- Use AlignTextToFramePadding() to align text baseline to the baseline of framed elements (otherwise a Text+SameLine+Button sequence will have the text a little too high by default)
		ImGui.AlignTextToFramePadding();
		ImGui.Text("Hold to repeat:");
		ImGui.SameLine();

		local spacing = {x = 3, y = 3}
		ImGui.PushButtonRepeat(true);
		if ImGui.ArrowButton("##left", ImGui.Dir.Left) then counter = counter - 1 end
		ImGui.SameLine(0.0, spacing.y);
		if ImGui.ArrowButton("##right", ImGui.Dir.Right) then counter = counter + 1 end
		ImGui.PopButtonRepeat();
		ImGui.SameLine();
		ImGui.Text("%d", counter);

		-- The input widgets also require you to manually disable the editor shortcuts so the view doesn't fly around.
		-- (note that this is a per-frame setting, so it disables it for all text boxes.  I left it here so you could find it!)
		local io = ImGui.GetIO()
		ed.EnableShortcuts(not io.WantTextInput);

		-- The input widgets require some guidance on their widths, or else they're very large. (note matching pop at the end).
		ImGui.PushItemWidth(200);
		ImGui.InputTextWithHint("input text (w/ hint)", "enter text here", str1);
		ImGui.InputFloatEx("input float", f0, 0.05, 1.0, "%.3f");
		ImGui.DragFloatEx("drag float", f1, 0.005);
		ImGui.DragFloatEx("drag small float", f2, 0.0001, 0.0, 0.0, "%.06f ns");
		ImGui.PopItemWidth();
	ed.EndNode()
end

local OP1_Bool = {true}
function system.draw_node3()
	local id = next_id()
	if not ed.CheckNodeExist(id) then ed.SetNodePosition(id, 480, 20) end

	-- Headers and Trees Demo =======================================================================================================
	-- TreeNodes and Headers streatch to the entire remaining work area. To put them in nodes what we need to do is to tell
	-- ImGui out work area is shorter. We can achieve that right now only by using columns API.
	--
	-- Relevent bugs: https://github.com/thedmd/imgui-node-editor/issues/30
	ed.BeginNode(id)
		ImGui.Text("Tree Widget Demo");
		ed.BeginPin(next_id(), ed.PinKind.Input);
			ImGui.Text("-> In");
		ed.EndPin();
		ImGui.SameLine();
		ImGui.Dummy(35, 0); --  magic number - Crude & simple way to nudge over the output pin. Consider using layout and springs
		ImGui.SameLine();
		ed.BeginPin(next_id(), ed.PinKind.Output);
			ImGui.Text("Out ->");
		ed.EndPin();

		local width = 135; -- bad magic numbers. used to define width of tree widget
		ImGui.PushStyleVarImVec2(ImGui.StyleVar.ItemSpacing, 0.0, 0.0);
		ImGui.Dummy(width, 0);
		ImGui.PopStyleVar();

		draw_list.BeginColumns("##TreeColumns", 2)
		draw_list.SetColumnWidth(0, width )
		if ImGui.CollapsingHeader("Open Header") then
			ImGui.Text("Hello There");
			if (ImGui.TreeNode("Open Tree")) then
				ImGui.Text("Checked: %s", OP1_Bool[1] and "true" or "false");
				ImGui.Checkbox("Option 1", OP1_Bool);
				ImGui.TreePop();
			end
		end
		draw_list.EndColumns()
		
	ed.EndNode()
end 

local do_tooltip = false
local do_adv_tooltip = false
local popup_text = "Pick one!"
local do_popup = false
function system.draw_node4()
	local id = next_id()
	if not ed.CheckNodeExist(id) then ed.SetNodePosition(id, 600, 300) end

	-- Tool Tip & Pop-up Demo =====================================================================================
	-- Tooltips, combo-boxes, drop-down menus need to use a work-around to place the "overlay window" in the canvas.
	-- To do this, we must defer the popup calls until after we're done drawing the node material.
	-- Relevent bugs:  https://github.com/thedmd/imgui-node-editor/issues/48
	ed.BeginNode(id)
		ImGui.Text("Tool Tip & Pop-up Demo");
		ed.BeginPin(next_id(), ed.PinKind.Input);
			ImGui.Text("-> In");
		ed.EndPin();
		ImGui.SameLine();
		ImGui.Dummy(85, 0); 
		ImGui.SameLine();
		ed.BeginPin(next_id(), ed.PinKind.Output);
			ImGui.Text("Out ->");
		ed.EndPin();

		-- Tooltip example
		ImGui.Text("Hover over me");
		do_tooltip = ImGui.IsItemHovered() 
		ImGui.SameLine();
		ImGui.Text("- or me");
		do_adv_tooltip = ImGui.IsItemHovered()

		-- Use AlignTextToFramePadding() to align text baseline to the baseline of framed elements
		-- (otherwise a Text+SameLine+Button sequence will have the text a little too high by default)
		ImGui.AlignTextToFramePadding();
		ImGui.Text("Option:");
		ImGui.SameLine();
		if (ImGui.Button(popup_text)) then
			do_popup = true;	-- Instead of saying OpenPopup() here, we set this bool, which is used later in the Deferred Pop-up Section
		end
	ed.EndNode()

	-- --------------------------------------------------------------------------------------------------
	-- Deferred Pop-up Section
	
	-- This entire section needs to be bounded by Suspend/Resume!  These calls pop us out of "node canvas coordinates"
	-- and draw the popups in a reasonable screen location.
	ed.Suspend()
	-- There is some stately stuff happening here.  You call "open popup" exactly once, and this
	-- causes it to stick open for many frames until the user makes a selection in the popup, or clicks off to dismiss.
	-- More importantly, this is done inside Suspend(), so it loads the popup with the correct screen coordinates!
	if (do_popup) then
		ImGui.OpenPopup("popup_button"); 	-- Cause openpopup to stick open.
		do_popup = false; 					-- disable bool so that if we click off the popup, it doesn't open the next frame.
	end

	-- This is the actual popup Gui drawing section.
	if ImGui.BeginPopup("popup_button") then
		-- Note: if it weren't for the child window, we would have to PushItemWidth() here to avoid a crash!
		ImGui.TextDisabled("Pick One:");
		ImGui.BeginChild("popup_scroller", 100, 100, ImGui.ChildFlags{}, ImGui.WindowFlags{"AlwaysVerticalScrollbar"});
			if (ImGui.Button("Option 1")) then
				popup_text = "Option 1";
				ImGui.CloseCurrentPopup();  -- These calls revoke the popup open state, which was set by OpenPopup above.
			end
			if (ImGui.Button("Option 2")) then
				popup_text = "Option 2";
				ImGui.CloseCurrentPopup()
			end
			if (ImGui.Button("Option 3")) then
				popup_text = "Option 3";
				ImGui.CloseCurrentPopup();
			end
			if (ImGui.Button("Option 4")) then
				popup_text = "Option 4";
				ImGui.CloseCurrentPopup();
			end
		ImGui.EndChild();
		ImGui.EndPopup(); -- Note this does not do anything to the popup open/close state. It just terminates the content declaration.
	end

	-- Handle the simple tooltip
	if (do_tooltip) then
		ImGui.SetTooltip("I am a tooltip");
	end

	-- Handle the advanced tooltip
	if (do_adv_tooltip) then
		ImGui.BeginTooltip();
		ImGui.Text("I am a fancy tooltip");
		--static float arr[] = { 0.6f, 0.1f, 1.0f, 0.5f, 0.92f, 0.1f, 0.2f };
		--ImGui.PlotLines("Curve", arr, IM_ARRAYSIZE(arr));
		ImGui.EndTooltip();
	end

	ed.Resume()
end

local progress, progress_dir = 0, 1.0;
function system.draw_node5()
	local id = next_id()
	if not ed.CheckNodeExist(id) then ed.SetNodePosition(id, 650, 530) end

	ed.BeginNode(id)
		ImGui.Text("Plot Demo");
		ed.BeginPin(next_id(), ed.PinKind.Input);
			ImGui.Text("-> In");
		ed.EndPin();
		ImGui.SameLine();
		ImGui.Dummy(250, 0); -- Hacky magic number to space out the output pin.
		ImGui.SameLine();
		ed.BeginPin(next_id(), ed.PinKind.Output);
			ImGui.Text("Out ->");
		ed.EndPin();
		
		ImGui.PushItemWidth(300);

		-- Animate a simple progress bar
		progress = progress + progress_dir * 0.4 * ImGui.GetIO().DeltaTime;
		if progress >= 1.1 then 
			progress = 1.1; 
			progress_dir = progress_dir * -1; 
		end

		if progress <= -0.1 then  
			progress = -0.1; 
			progress_dir = progress_dir * -1.0; 
		end

		-- Typically we would use ImVec2(-1.0f,0.0f) or ImVec2(-FLT_MIN,0.0f) to use all available width,
		-- or ImVec2(width,0.0f) for a specified width. ImVec2(0.0f,0.0f) uses ItemWidth.
		ImGui.ProgressBar(progress, 0, 0);
		ImGui.SameLineEx(0.0, 3);
		ImGui.Text("Progress Bar");

		local progress_saturated = (progress < 0.0) and 0.0 or (progress > 1.0) and 1.0 or progress;
		local buf = string.format("%d/%d", math.floor(progress_saturated * 1753), 1753)
		ImGui.ProgressBar(progress, 0, 0, buf);

		ImGui.PopItemWidth();
	ed.EndNode()

end

function system.draw_links()
	for i, v in ipairs(links) do 
		ed.Link(v.id, v.input, v.output)
	end

	if ed.BeginCreate() then 
		local inputPinId, outputPinId = ed.QueryNewLink()
		if inputPinId and outputPinId then 
			if ed.AcceptNewItem() then 
				next_link_id = next_link_id + 1
				local data = {id = next_link_id, input = inputPinId, output = outputPinId}
				table.insert(links, data)
				ed.Link(data.id, data.input, data.output)
			end
		end
	end
	ed.EndCreate()

	if ed.BeginDelete() then 
		local deletedLinkId = ed.QueryDeletedLink()
		while deletedLinkId do 
			if ed.AcceptDeletedItem() then 
				for i, data in ipairs(links) do 
					if data.id == deletedLinkId then 
						table.remove(links, i)
						break
					end
				end
			end
			deletedLinkId = ed.QueryDeletedLink()
		end
	end
	ed.EndDelete()
end