local ecs = ...
local ImGui     = require "imgui"
local mgr = require "data_mgr"
local tools = import_package 'game.tools'
local tbParam = 
{
    ecs             = ecs,
    system_name     = "imgui_03_system",
    category        = mgr.type_imgui,
    name            = "03_各种Flag",
    desc            = "展示控件各种Flag效果",
    file            = "imgui/imgui_03.lua",
    ok              = true
}
local system = mgr.create_system(tbParam)

local all_selected = {}
local selected = {}
local wnd_size = {x = 400, y = 400}
local wnd_pos = {x = 100, y = 100}
local contents = {}
local pages = {"Window", "Child", "InputText", "Table", "TreeNode", "Combo", "TabBar", "TabItem"}
local cur_page = tools.user_data.get('imgui_03_save_key')

local all_flags = {}
local tb_flags = {}

local set_btn_style = function(current)
    if current then 
        ImGui.PushStyleColorImVec4(ImGui.Col.Button, 0, 0.5, 0.8, 1)
        ImGui.PushStyleColorImVec4(ImGui.Col.ButtonHovered, 0, 0.55, 0.7, 1)
        ImGui.PushStyleColorImVec4(ImGui.Col.ButtonActive, 0, 0.55, 0.7, 1)
    else 
        ImGui.PushStyleColorImVec4(ImGui.Col.Button, 0.2, 0.2, 0.25, 1)
        ImGui.PushStyleColorImVec4(ImGui.Col.ButtonHovered, 0.3, 0.3, 0.3, 1)
        ImGui.PushStyleColorImVec4(ImGui.Col.ButtonActive, 0.25, 0.25, 0.25, 1)
    end
end

function system.on_entry()
    wnd_size = {x = 400, y = 400}
    contents = {}
    for i = 1, 5 do 
        table.insert(contents, "我见青山多妩媚，料青山，见我应如是。" )
    end 
end

function system.data_changed()
    local start_x, start_y = mgr.get_content_start()
    wnd_pos = {x = start_x + 50,  y = start_y + 70}

    local start_x, start_y = mgr.get_content_start()
    local content_x, content_y = mgr.get_content_size()
    ImGui.SetNextWindowPos(start_x, start_y)
    ImGui.SetNextWindowSize(content_x, 40)
    if ImGui.Begin("title", nil, ImGui.WindowFlags {"NoResize", "NoMove", "NoTitleBar", "NoScrollbar", "NoBackground"}) then 
        for i, name in ipairs(pages) do 
            local current = name == cur_page
            set_btn_style(current)
            local label = name .. "###btn_title_" .. i
            if ImGui.Button(label, 70 * mgr.get_dpi_scale()) or not cur_page then 
                cur_page = name
                selected = all_selected[i] or {}
                all_selected[i] = selected
                tools.user_data.set('imgui_03_save_key', name, true)
            end
            ImGui.SameLine()
            ImGui.PopStyleColorEx(3)
        end
    end
    ImGui.End()

    tb_flags = all_flags[cur_page]
    local szFlag = system['Draw_' .. cur_page]() or ""

    ImGui.SetNextWindowPos(780, wnd_pos.y)  
    ImGui.SetNextWindowSize(400, 400)
    if ImGui.Begin("wnd_flags", nil, ImGui.WindowFlags {"NoResize", "NoMove", "NoTitleBar"}) then 
        for i, v in ipairs(tb_flags) do 
            local is_table = type(v) == "table"
            local name = is_table and v[1] or v
            if ImGui.RadioButton(name .. "##flag" .. i, selected[i] == true) then 
                selected[i] = not selected[i]
            end
            if is_table then 
                if ImGui.IsItemHovered() and ImGui.BeginTooltip() then 
                    ImGui.PushTextWrapPos(400);
                    ImGui.Text(v[2]);
                    ImGui.PopTextWrapPos()
                    ImGui.EndTooltip();
                end
            end
        end
    end
    ImGui.End()

    ImGui.SetNextWindowPos(225, 550)  
    ImGui.SetNextWindowSize(950, 400)
    if ImGui.Begin("wnd_bottom", nil, ImGui.WindowFlags {"NoResize", "NoMove", "NoTitleBar", "NoScrollbar", "NoBackground"}) then 
        local str = string.format("%s {%s}", szFlag, table.concat(system.get_styles(), ", "))
		ImGui.PushTextWrapPos(650);
        ImGui.Text(str)
		ImGui.PopTextWrapPos()

        set_btn_style(false)
        ImGui.SetCursorPos(720, 10)
		if ImGui.ButtonEx("复 制##btn_copy_flag", 80) then 
			print("copy", str)
		end 
		ImGui.SameLine()
        if ImGui.ButtonEx("清 空##btn_clear_flag", 80) then 
            for i, v in pairs(selected) do 
                selected[i] = nil
            end
        end
        ImGui.PopStyleColorEx(3)
    end
    ImGui.End()
end

function system.get_styles()
    local ret = {}
    for i, v in ipairs(tb_flags) do 
        local is_table = type(v) == "table"
        local name = is_table and v[1] or v
        if selected[i] then 
            table.insert(ret, name)
        end
    end
    return ret
end

----------------------------------------------------------------
--- Window
----------------------------------------------------------------
all_flags["Window"] = {
    "NoTitleBar", 
    "NoResize", 
    "NoMove", 
    "NoScrollbar",
    "NoScrollWithMouse",
    "NoCollapse",
    "AlwaysAutoResize",
    "NoBackground",
    "NoSavedSettings",
    "NoMouseInputs",
    "MenuBar",
    "HorizontalScrollbar",
    "NoFocusOnAppearing",
    "NoBringToFrontOnFocus",
    "NoBringToFrontOnFocus",
    "AlwaysVerticalScrollbar",
    "AlwaysHorizontalScrollbar",
    --"AlwaysUseWindowPadding",  -- 引擎似乎没导出，使用会报错
    "NoNavInputs",
    "NoNavFocus",
    "UnsavedDocument",
    "NoNav",
    "NoDecoration",
    "NoInputs",
}
function system.Draw_Window()
    ImGui.SetNextWindowPos(wnd_pos.x, wnd_pos.y)  
    ImGui.SetNextWindowSize(wnd_size.x, wnd_size.y)
    if ImGui.Begin("ImGui.Begin##window_imgui_03", nil, ImGui.WindowFlags(system.get_styles())) then 
        for i, desc in ipairs(contents) do 
            ImGui.Text(desc)
        end
    end
    wnd_size.x, wnd_size.y = ImGui.GetWindowSize()
    ImGui.End()
    return "ImGui.WindowFlags"
end

----------------------------------------------------------------
--- Child
----------------------------------------------------------------
all_flags["Child"] = {
    "Border",
    "AlwaysUseWindowPadding",
    "ResizeX",
    "ResizeY",
    "AutoResizeX",
    "AutoResizeY",
    "AlwaysAutoResize",
    "FrameStyle",
}
function system.Draw_Child()
    ImGui.SetNextWindowPos(wnd_pos.x, wnd_pos.y)  
    ImGui.SetNextWindowSize(wnd_size.x, wnd_size.y)
    if ImGui.Begin("##window_imgui_03_child", nil, ImGui.WindowFlags{"NoResize", "NoMove", "NoCollapse", "NoTitleBar"}) then 
        ImGui.SetCursorPos(50, 50)
        ImGui.BeginChild("ImGui.BeginChild", 300, 300, ImGui.ChildFlags(system.get_styles()), ImGui.WindowFlags { "HorizontalScrollbar" })
        for i, desc in ipairs(contents) do 
            ImGui.Text(desc)
        end
        ImGui.EndChild()
    end 
    ImGui.End()
    return "ImGui.ChildFlags"
end

----------------------------------------------------------------
--- InputText
----------------------------------------------------------------
all_flags["InputText"] = {
    {"CharsDecimal", "Allow 0123456789.+-*/"},
    {"CharsHexadecimal", "Allow 0123456789ABCDEFabcdef"},
    {"CharsUppercase", "Turn a..z into A..Z"},
    {"CharsNoBlank", "Filter out spaces, tabs"},
    {"AutoSelectAll", "Select entire text when first taking mouse focus"},
    {"EnterReturnsTrue", "Return 'true' when Enter is pressed (as opposed to every time the value was modified). Consider looking at the IsItemDeactivatedAfterEdit() function."},
    {"CallbackCompletion", "Callback on pressing TAB (for completion handling)"},
    {"CallbackHistory", "Callback on pressing Up/Down arrows (for history handling)"},
 --   {"CallbackAlways", "Callback on each iteration. User code may query cursor position, modify text buffer."},
    {"CallbackCharFilter", "Callback on character inputs to replace or discard them. Modify 'EventChar' to replace or discard, or return 1 in callback to discard."},
    {"AllowTabInput", "Pressing TAB input a '\t' character into the text field"},
    {"CtrlEnterForNewLine", "In multi-line mode, unfocus with Enter, add new line with Ctrl+Enter (default is opposite: unfocus with Ctrl+Enter, add line with Enter)."},
    {"NoHorizontalScroll", "Disable following the cursor horizontally"},
    {"AlwaysOverwrite", "Overwrite mode"},
    {"ReadOnly", "Read-only mode"},
    {"Password", "Password mode, display all characters as '*'"},
    {"NoUndoRedo", "Disable undo/redo. Note that input text owns the text data while active, if you want to provide your own undo/redo stack you need e.g. to call ClearActiveID()."},
    {"CharsScientific", "Allow 0123456789.+-*/eE (Scientific notation input)"},
    {"CallbackResize", "Callback on buffer capacity changes request (beyond 'buf_size' parameter value), allowing the string to grow. Notify when the string wants to be resized (for string types which hold a cache of their Size). You will be provided a new BufSize in the callback and NEED to honor it. (see misc/cpp/imgui_stdlib.h for an example of using this)"},
    {"CallbackEdit", "Callback on any edit (note that InputText() already returns true on edit, the callback is useful mainly to manipulate the underlying buffer while focus is active)"},
    {"EscapeClearsAll", "Escape key clears content if not empty, and deactivate otherwise (contrast to default behavior of Escape to revert)"},
}
local input_content = {
    text = "",
	hint = "请输入",
    flags = nil,
    up = function() end,
    down = function() end,
}
local input_multi_content = {
    text = "文本内容",
    flags = nil,
	width = 180,
	height = 150,
}
function system.Draw_InputText()
    ImGui.SetNextWindowPos(wnd_pos.x, wnd_pos.y)  
    ImGui.SetNextWindowSize(wnd_size.x, wnd_size.y)
    if ImGui.Begin("##window_imgui_03_input", nil, ImGui.WindowFlags {}) then 
        ImGui.SetCursorPos(30, 70)
        ImGui.Text("InputText: ")
        ImGui.SameLine()
        ImGui.SetNextItemWidth(180)
        input_content.flags = ImGui.InputTextFlags(system.get_styles())
        if ImGui.InputText("##input_test", input_content) then 
            print("input", tostring(input_content.text))
        end

		ImGui.SetCursorPos(30, 120)
		ImGui.Text("InputMult: ")
        ImGui.SameLine()
		input_multi_content.flags = ImGui.InputTextFlags(system.get_styles())
		if ImGui.InputTextMultiline("##input_multi_test", input_multi_content) then 
			print("multi_input", tostring(input_multi_content.text))
		end
    end 
    ImGui.End()
    return "ImGui.InputTextFlags"
end

----------------------------------------------------------------
--- Table
----------------------------------------------------------------
all_flags["Table"] = {

}
function system.Draw_Table()
	local i  = 0;
end

----------------------------------------------------------------
--- TreeNode
----------------------------------------------------------------
all_flags["TreeNode"] = {

}
function system.Draw_TreeNode()
	local i  = 0;
end

----------------------------------------------------------------
--- Combo
----------------------------------------------------------------
all_flags["Combo"] = {

}
function system.Draw_Combo()
	local i  = 0;
end


----------------------------------------------------------------
--- TabBar
----------------------------------------------------------------
all_flags["TabBar"] = {

}
function system.Draw_TabBar()
	local i  = 0;
end

----------------------------------------------------------------
--- TabBar
----------------------------------------------------------------
all_flags["TabItem"] = {

}
function system.Draw_TabItem()
	local i  = 0;
end
