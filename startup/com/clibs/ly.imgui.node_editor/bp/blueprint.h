#pragma once
#include <imgui.h>
#include "../src/imgui_node_editor.h"

namespace ax {
namespace NodeEditor {

enum class PinType
{
    Flow,
    Bool,
    Int,
    Float,
    String,
    Object,
    Function,
    Delegate,
};

enum class NodeType
{
    Blueprint,
    Simple,
    Tree,
    Comment,
    Houdini
};

enum class IconType: ImU32 { Flow, Circle, Square, Grid, RoundSquare, Diamond };

bool Splitter(bool split_vertically, float thickness, float* size1, float* size2, float min_size1, float min_size2, float splitter_long_axis_size = -1.0f);

ImColor GetIconColor(PinType Type);

void DrawPinIcon(PinType pinType, bool connected, int alpha);

void DrawIcon(ImDrawList* drawList, const ImVec2& a, const ImVec2& b, IconType type, bool filled, ImU32 color, ImU32 innerColor);

}
}