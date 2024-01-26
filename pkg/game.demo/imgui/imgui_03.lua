local ecs = ...
local ImGui = import_package "ant.imgui"
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
        ImGui.PushStyleColor(ImGui.Enum.Col.Button, 0, 0.5, 0.8, 1)
        ImGui.PushStyleColor(ImGui.Enum.Col.ButtonHovered, 0, 0.55, 0.7, 1)
        ImGui.PushStyleColor(ImGui.Enum.Col.ButtonActive, 0, 0.55, 0.7, 1)
    else 
        ImGui.PushStyleColor(ImGui.Enum.Col.Button, 0.2, 0.2, 0.25, 1)
        ImGui.PushStyleColor(ImGui.Enum.Col.ButtonHovered, 0.3, 0.3, 0.3, 1)
        ImGui.PushStyleColor(ImGui.Enum.Col.ButtonActive, 0.25, 0.25, 0.25, 1)
    end
end

function system.on_entry()
    local start = mgr.get_content_start()
    wnd_pos = {x = start.x + 50,  y = 130}
    wnd_size = {x = 400, y = 400}
    contents = {}
    for i = 1, 5 do 
        table.insert(contents, "我见青山多妩媚，料青山，见我应如是。" )
    end 
end

function system.data_changed()
    ImGui.SetNextWindowPos(250, 60)
    ImGui.SetNextWindowSize(800, 40)
    if ImGui.Begin("title", ImGui.Flags.Window {"NoResize", "NoMove", "NoTitleBar", "NoScrollbar", "NoBackground"}) then 
        for i, name in ipairs(pages) do 
            local current = name == cur_page
            set_btn_style(current)
            local label = name .. "###btn_title_" .. i
            if ImGui.Button(label, 80, 25) or not cur_page then 
                cur_page = name
                selected = all_selected[i] or {}
                all_selected[i] = selected
                tools.user_data.set('imgui_03_save_key', name, true)
            end
            ImGui.SameLine()
            ImGui.PopStyleColor(3)
        end
    end
    ImGui.End()

    tb_flags = all_flags[cur_page]
    local szFlag = system['Draw_' .. cur_page]() or ""

    ImGui.SetNextWindowPos(720, 130)  
    ImGui.SetNextWindowSize(400, 400)
    if ImGui.Begin("wnd_flags", ImGui.Flags.Window {"NoResize", "NoMove", "NoTitleBar"}) then 
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

    ImGui.SetNextWindowPos(225, 540)  
    ImGui.SetNextWindowSize(950, 400)
    if ImGui.Begin("wnd_bottom", ImGui.Flags.Window {"NoResize", "NoMove", "NoTitleBar", "NoScrollbar", "NoBackground"}) then 
        ImGui.PushTextWrapPos(650);
        local str = string.format("%s {%s}", szFlag, table.concat(system.get_styles(), ", "))
        ImGui.InputText("##input_show", {text = str, flags = ImGui.Flags.InputText({"ReadOnly"})})
        ImGui.PopTextWrapPos();

        set_btn_style(false)
        ImGui.SetCursorPos(810, 10)
        if ImGui.Button("清 空##btn_clear_flag", 80, 25) then 
            for i, v in pairs(selected) do 
                selected[i] = nil
            end
        end
        ImGui.PopStyleColor(3)
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
    if ImGui.Begin("ImGui.Begin##window_imgui_03", ImGui.Flags.Window(system.get_styles())) then 
        for i, desc in ipairs(contents) do 
            ImGui.Text(desc)
        end
    end
    wnd_size.x, wnd_size.y = ImGui.GetWindowSize()
    ImGui.End()
    return "ImGui.Flags.Window"
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
    if ImGui.Begin("##window_imgui_03_child", ImGui.Flags.Window {}) then 
        ImGui.SetCursorPos(50, 50)
        ImGui.BeginChild("ImGui.BeginChild", 300, 300, ImGui.Flags.Child(system.get_styles()), ImGui.Flags.Window { "HorizontalScrollbar" })
        for i, desc in ipairs(contents) do 
            ImGui.Text(desc)
        end
        ImGui.EndChild()
    end 
    ImGui.End()
    return "ImGui.Flags.Child"
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
    flags = nil,
    up = function()
    end,
    down = function()
    end,
}
function system.Draw_InputText()
    ImGui.SetNextWindowPos(wnd_pos.x, wnd_pos.y)  
    ImGui.SetNextWindowSize(wnd_size.x, wnd_size.y)
    if ImGui.Begin("##window_imgui_03_input", ImGui.Flags.Window {}) then 
        ImGui.SetCursorPos(50, 100)
        ImGui.Text("InputText: ")
        ImGui.SameLine()
        ImGui.SetNextItemWidth(150)
        input_content.flags = ImGui.Flags.InputText(system.get_styles())
        if ImGui.InputText("##input_test", input_content) then 
            print("input", tostring(input_content.text))
        end
    end 
    ImGui.End()
    return "ImGui.Flags.InputText"
end

----------------------------------------------------------------
--- Table
----------------------------------------------------------------
all_flags["Table"] = {

}
function system.Draw_Table()
end

----------------------------------------------------------------
--- TreeNode
----------------------------------------------------------------
all_flags["TreeNode"] = {

}
function system.Draw_TreeNode()
end

----------------------------------------------------------------
--- Combo
----------------------------------------------------------------
all_flags["Combo"] = {

}
function system.Draw_Combo()
end


----------------------------------------------------------------
--- TabBar
----------------------------------------------------------------
all_flags["TabBar"] = {

}
function system.Draw_TabBar()
end

----------------------------------------------------------------
--- TabBar
----------------------------------------------------------------
all_flags["TabItem"] = {

}
function system.Draw_TabItem()
end
