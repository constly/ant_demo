local ecs = ...
local ImGui = import_package "ant.imgui"
local mgr = require "data_mgr"
local tbParam = 
{
    ecs             = ecs,
    system_name     = "imgui_06_system",
    category        = mgr.type_imgui,
    name            = "06_菜单&弹框",
    file            = "imgui/imgui_06.lua",
	ok 				= true
}
local system = mgr.create_system(tbParam)

local set_item_tooltip = function(tip)
	if ImGui.IsItemHovered() and ImGui.BeginTooltip() then
		ImGui.Text(tip)
		ImGui.EndTooltip()
	end
end

local menu_options = function()
	if ImGui.BeginMenu("选项") then 
		ImGui.MenuItem("帮助");
		ImGui.MenuItem("文档");
		ImGui.MenuItem("作者");
		ImGui.Separator();
		ImGui.Text("测试滚动区域")
		ImGui.BeginChild("child", 200, 50, ImGui.ChildFlags({"Border"}));
		for i = 1, 5 do 
			ImGui.Text("滚动区域 " .. i);
		end
		ImGui.EndChild();
		ImGui.Text("可以渲染任意控件")
		ImGui.EndMenu();
	end
end

local my_popup = function(name)
	if ImGui.BeginPopupContextItemEx(name) then 
		menu_options()
		if ImGui.MenuItem("打开弹窗") then 
			ImGui.OpenPopup("my popup", ImGui.PopupFlags { "None" });
		end
		set_item_tooltip("点击我")
		ImGui.Separator()
		if ImGui.MenuItem("Close") then 
			ImGui.CloseCurrentPopup();
		end
		ImGui.EndPopup();
	end
end

function system.data_changed()
	ImGui.SetNextWindowPos(mgr.get_content_start())
    ImGui.SetNextWindowSize(mgr.get_content_size())

	if ImGui.Begin("window_body", ImGui.WindowFlags {"NoResize", "NoMove", "NoScrollbar", "MenuBar"}) then 
		
		if ImGui.BeginMenuBar() then
			if ImGui.BeginMenu("菜单") then 
				if ImGui.MenuItem("打开") then  end
				if ImGui.MenuItem("保存") then  end
				
				ImGui.Separator();
				if ImGui.BeginMenu("打包") then 
					ImGui.MenuItem("Android");
					ImGui.MenuItem("Windows");
					ImGui.MenuItem("IOS");
					ImGui.EndMenu();
				end
				ImGui.EndMenu();
			end
			menu_options()
			ImGui.EndMenuBar();
		end

		ImGui.SetCursorPos(50, 100)
		ImGui.BeginChild("##child_1", 500, 500, ImGui.ChildFlags({"Border"}))
			ImGui.SameLine(150)
			ImGui.Text("测试菜单") 
			
			ImGui.NewLine()
			ImGui.Text("1. 右键以下任意一个都可以打开菜单");
			ImGui.NewLine()
			ImGui.SameLine(30)
			ImGui.BeginGroup()
			ImGui.Text("我们是一组的")
			ImGui.Button("组员1")
			ImGui.Text("组员2")
			ImGui.Text("右键任意一个都可以打开菜单")
			ImGui.Text("使用的: ImGui.BeginGroup() / ImGui.EndGroup()")
			ImGui.EndGroup()
			set_item_tooltip("快，使用右键点击我")
			my_popup("popup_menu")
			ImGui.NewLine()

			ImGui.Text("2. 右键点击我，可以打开菜单");
			ImGui.OpenPopupOnItemClick("popup_menu", 1);
		
			ImGui.NewLine()
			if ImGui.Button("3. 左键点击我，也可以打开菜单") then 
				ImGui.OpenPopup("popup_menu", ImGui.PopupFlags { "None" });
			end
		ImGui.EndChild()

		ImGui.SetCursorPos(600, 100)
		if ImGui.BeginChild("##child_2", 500, 500, ImGui.ChildFlags({"Border"})) then
			ImGui.SameLine(150)
			ImGui.Text("测试弹框") 
			ImGui.NewLine()

			local cfg = 
			{
				[1] = "AlwaysAutoResize + NoClosed 弹框",
				[2] = "固定位置和大小 弹框",
				[3] = "可改变位置和大小 弹框",
			}
			for i, name in ipairs(cfg) do 
				local label = string.format("%d. %s  ##btn_child2_%d", i, name, i)
				if ImGui.Button(label) then 
					ImGui.OpenPopup("popup_modal" .. i, ImGui.PopupFlags { "None" })
					ImGui.SetNextWindowPos(500, 200) 
					ImGui.SetNextWindowSize(300, 200)
				end
				system["wnd_popup_modal" .. i]()
			end
        end
		ImGui.EndChild()

	end
	ImGui.End()
end

function system.wnd_popup_modal1()
	if ImGui.BeginPopupModal("popup_modal1", nil, ImGui.WindowFlags{"AlwaysAutoResize"} ) then
		ImGui.Text("弹框内容1")
		ImGui.Text("弹框内容2")
		ImGui.Separator();
		ImGui.Selectable("点击我可以关闭弹框", false)	
		if ImGui.Button("点击我也可以关闭弹框") then 
			ImGui.CloseCurrentPopup()
		end
		ImGui.EndPopup();
	end
end

function system.wnd_popup_modal2()
	
	if ImGui.BeginPopupModal("popup_modal2", nil, ImGui.WindowFlags{"NoResize", "NoMove"} ) then
		local sizex, sizey = ImGui.GetContentRegionAvail()
		ImGui.SetCursorPos(sizex * 0.5 - 100, sizey * 0.5 - 10)
		ImGui.BeginGroup()
		ImGui.Text("右键点我打开菜单")
		ImGui.Text("固定位置和大小")
		ImGui.EndGroup()
		ImGui.OpenPopupOnItemClick("popup_item_modal2", 1);
		my_popup("popup_item_modal2")
		ImGui.EndPopup();
	end
end

function system.wnd_popup_modal3()
	if ImGui.BeginPopupModal("popup_modal3", nil, ImGui.WindowFlags{} ) then
		local sizex, sizey = ImGui.GetContentRegionAvail()
		ImGui.SetCursorPos(sizex * 0.5 - 100, sizey * 0.5 - 10)
		ImGui.BeginGroup()
		ImGui.Text("右键点我打开菜单")
		ImGui.Text("可改变位置和大小")
		ImGui.EndGroup()
		ImGui.OpenPopupOnItemClick("popup_item_modal3", 1);
		my_popup("popup_item_modal3")
		ImGui.EndPopup();
	end
end