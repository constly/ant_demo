#include <lua.hpp>
#include <bee/lua/binding.h>
#include "backend/imgui_impl_bgfx.h"
#include <bee/nonstd/unreachable.h>
#include "src/imgui_node_editor.h"
#include "src/imgui_canvas.h"
#include "bp/blueprint.h"
#include "bp/builders.h"

namespace ed = ax::NodeEditor;
namespace util = ax::NodeEditor::Utilities;

namespace imguilua {
	struct NodeEditorContext {	
		~NodeEditorContext() { OnDestroy(); }
		ed::EditorContext* m_Context = nullptr;

		void OnStart() {
			if (!m_Context) {
				ed::Config config;
				config.SettingsFile = nullptr;
				m_Context = ed::CreateEditor(&config);
			}
		}

		void OnDestroy() {
			if (m_Context) {
				ed::DestroyEditor(m_Context);
				m_Context = nullptr;
			}
		}
	};
}


namespace imguilua::bind {

	static int OnStart(lua_State* L) {
		auto& context = bee::lua::checkudata<imguilua::NodeEditorContext>(L, 1);
		context.OnStart();
		return 0;
	}

	static int OnDestroy(lua_State* L) {
		auto& context = bee::lua::checkudata<imguilua::NodeEditorContext>(L, 1);
		context.OnDestroy();
		return 0;
	}

	//----------------------------------------------------------
	// metatable
	//----------------------------------------------------------
	static void metatable(lua_State* L) {
		static luaL_Reg lib[] = {
			{"OnStart", OnStart},
			{"OnDestroy", OnDestroy},

			{nullptr, nullptr},
		};
		luaL_newlib(L, lib);
		lua_setfield(L, -2, "__index");
	}
}
static int bCreateEditorContext(lua_State* L) {
	bee::lua::newudata<imguilua::NodeEditorContext>(L);
	return 1;
}

namespace imguilua::bindutils {

	ImTextureID get_texture_id(lua_State* L, int idx) {
		int lua_handle = (int)luaL_checkinteger(L, idx);
		if (auto id = ImGui_ImplBgfx_GetTextureID(lua_handle)) {
			return *id;
		}
		luaL_error(L, "Invalid handle type TEXTURE");
		std::unreachable();
	}

	static int bInit(lua_State* L) {
		util::BlueprintNodeBuilder& builder = bee::lua::checkudata<util::BlueprintNodeBuilder>(L, 1);
		auto texture_id = get_texture_id(L, 2);
		int textureWidth = (int)luaL_checkinteger(L, 3);
		int textureHeight = (int)luaL_checkinteger(L, 4);
		builder.Init(texture_id, textureWidth, textureHeight);
		return 0;
	}

	static int bBegin(lua_State* L) {
		util::BlueprintNodeBuilder& builder = bee::lua::checkudata<util::BlueprintNodeBuilder>(L, 1);
		int pinId = (int)luaL_checkinteger(L, 2);
		builder.Begin(pinId);
		return 0;
	}

	static int bEnd(lua_State* L) {
		util::BlueprintNodeBuilder& builder = bee::lua::checkudata<util::BlueprintNodeBuilder>(L, 1);
		builder.End();
		return 0;
	}

	static int bHeader(lua_State* L) {
		util::BlueprintNodeBuilder& builder = bee::lua::checkudata<util::BlueprintNodeBuilder>(L, 1);
		float r = (float)luaL_checknumber(L, 2);
		float g = (float)luaL_checknumber(L, 3);
		float b = (float)luaL_checknumber(L, 4);
		float a = (float)luaL_checknumber(L, 5);
		builder.Header(ImVec4(r, g, b, a));
		return 0;
	}

	static int bEndHeader(lua_State* L) {
		util::BlueprintNodeBuilder& builder = bee::lua::checkudata<util::BlueprintNodeBuilder>(L, 1);
		builder.EndHeader();
		return 0;
	}

	static int bInput(lua_State* L) {
		util::BlueprintNodeBuilder& builder = bee::lua::checkudata<util::BlueprintNodeBuilder>(L, 1);
		int pinId = (int)luaL_checkinteger(L, 2);
		builder.Input(pinId);
		return 0;
	}

	static int bEndInput(lua_State* L) {
		util::BlueprintNodeBuilder& builder = bee::lua::checkudata<util::BlueprintNodeBuilder>(L, 1);
		builder.EndInput();
		return 0;
	}

	static int bMiddle(lua_State* L) {
		util::BlueprintNodeBuilder& builder = bee::lua::checkudata<util::BlueprintNodeBuilder>(L, 1);
		builder.Middle();
		return 0;
	}

	static int bOutput(lua_State* L) {
		util::BlueprintNodeBuilder& builder = bee::lua::checkudata<util::BlueprintNodeBuilder>(L, 1);
		int pinId = (int)luaL_checkinteger(L, 2);
		builder.Output(pinId);
		return 0;
	}

	static int bEndOutput(lua_State* L) {
		util::BlueprintNodeBuilder& builder = bee::lua::checkudata<util::BlueprintNodeBuilder>(L, 1);
		builder.EndOutput();
		return 0;
	}

	static int bGetHeaderSize(lua_State* L) {
		util::BlueprintNodeBuilder& builder = bee::lua::checkudata<util::BlueprintNodeBuilder>(L, 1);
		lua_pushnumber(L, builder.HeaderMax.x - builder.HeaderMin.x);
		lua_pushnumber(L, builder.HeaderMax.y - builder.HeaderMin.y);
		return 2;
	}

	//----------------------------------------------------------
	// metatable
	//----------------------------------------------------------
	static void metatable(lua_State* L) {
		static luaL_Reg lib[] = {
			{"Init", 		bInit},
			{"Begin", 		bBegin},
			{"End", 		bEnd},
			{"Header", 		bHeader},
			{"EndHeader", 	bEndHeader},
			{"Input", 		bInput},
			{"EndInput", 	bEndInput},
			{"Middle", 		bMiddle},
			{"Output", 		bOutput},
			{"EndOutput", 	bEndOutput},
			{"GetHeaderSize", 	bGetHeaderSize},

			{nullptr, nullptr},
		};
		luaL_newlib(L, lib);
		lua_setfield(L, -2, "__index");
	}
}
static int bCreateBlueprintNodeBuilder(lua_State* L) {
	bee::lua::newudata<util::BlueprintNodeBuilder>(L);
	return 1;
}

//--------------------------------------------------------------------
// canvas 接口绑定
//--------------------------------------------------------------------
namespace imguilua {
	struct CanvasContext {	
		ImGuiEx::Canvas canvas;
	};
}

namespace imguilua::canvasbind {

	static int bBegin(lua_State* L) {
		imguilua::CanvasContext& context = bee::lua::checkudata<imguilua::CanvasContext>(L, 1);
		auto str = luaL_checkstring(L, 2);
		float x = (float)luaL_checknumber(L, 3);
		float y = (float)luaL_checknumber(L, 4);
		if (context.canvas.Begin(str, ImVec2(x, y))) {
			lua_pushboolean(L, true);
			return 1;
		}
		return 0;
	}

	static int bEnd(lua_State* L) {
		imguilua::CanvasContext& context = bee::lua::checkudata<imguilua::CanvasContext>(L, 1);
		context.canvas.End();
		return 0;
	}

	static int bSetView(lua_State* L) {
		imguilua::CanvasContext& context = bee::lua::checkudata<imguilua::CanvasContext>(L, 1);
		float x = (float)luaL_checknumber(L, 2);
		float y = (float)luaL_checknumber(L, 3);
		float scale = (float)luaL_checknumber(L, 4);
		context.canvas.SetView(ImVec2(x, y), scale);
		return 0;
	}

	static int bViewOrigin(lua_State* L) {
		imguilua::CanvasContext& context = bee::lua::checkudata<imguilua::CanvasContext>(L, 1);
		const ImVec2& value = context.canvas.ViewOrigin();
		lua_pushnumber(L, value.x);
		lua_pushnumber(L, value.y);
		return 2;
	}

	static int bViewScale(lua_State* L) {
		imguilua::CanvasContext& context = bee::lua::checkudata<imguilua::CanvasContext>(L, 1);
		float scale = context.canvas.ViewScale();
		lua_pushnumber(L, scale);
		return 1;
	}

	static int bToLocal(lua_State* L) {
		imguilua::CanvasContext& context = bee::lua::checkudata<imguilua::CanvasContext>(L, 1);
		float x = (float)luaL_checknumber(L, 2);
		float y = (float)luaL_checknumber(L, 3);
		ImVec2 value = context.canvas.ToLocal(ImVec2(x, y));
		lua_pushnumber(L, value.x);
		lua_pushnumber(L, value.y);
		return 2;
	}

	static int bCenterView(lua_State* L) {
		imguilua::CanvasContext& context = bee::lua::checkudata<imguilua::CanvasContext>(L, 1);
		float x = (float)luaL_checknumber(L, 2);
		float y = (float)luaL_checknumber(L, 3);
		context.canvas.CenterView(ImVec2(x, y));
		return 0;
	}

	static int bRect(lua_State* L) {
		imguilua::CanvasContext& context = bee::lua::checkudata<imguilua::CanvasContext>(L, 1);
		ImRect rect = context.canvas.Rect();
		lua_pushnumber(L, rect.Min.x);
		lua_pushnumber(L, rect.Min.y);
		lua_pushnumber(L, rect.Max.x);
		lua_pushnumber(L, rect.Max.y);
		return 4;
	}

	static int bSuspend(lua_State* L) {
		imguilua::CanvasContext& context = bee::lua::checkudata<imguilua::CanvasContext>(L, 1);
		context.canvas.Suspend();
		return 0;
	}
	
	static int bResume(lua_State* L) {
		imguilua::CanvasContext& context = bee::lua::checkudata<imguilua::CanvasContext>(L, 1);
		context.canvas.Resume();
		return 0;
	}

	//----------------------------------------------------------
	// metatable
	//----------------------------------------------------------
	static void metatable(lua_State* L) {
		static luaL_Reg lib[] = {
			{"Begin", bBegin},
			{"End", bEnd},
			{"SetView", bSetView},
			{"ViewOrigin", bViewOrigin},
			{"ViewScale", bViewScale},
			{"ToLocal", bToLocal},
			{"CenterView", bCenterView},
			{"Rect", bRect},
			{"Resume", bResume},
			{"Suspend", bSuspend},

			{nullptr, nullptr},
		};
		luaL_newlib(L, lib);
		lua_setfield(L, -2, "__index");
	}
}
static int bCreateCanvasContext(lua_State* L) {
	bee::lua::newudata<imguilua::CanvasContext>(L);
	return 1;
}

//------------------------------------------------------------------------
// ed 接口绑定
//------------------------------------------------------------------------
static int bSetCurrentEditor(lua_State* L) {
	if (lua_isuserdata(L, 1)) {
		imguilua::NodeEditorContext& context = bee::lua::checkudata<imguilua::NodeEditorContext>(L, 1);
		ed::SetCurrentEditor(context.m_Context);
	} else {
		ed::SetCurrentEditor(nullptr);
	}
	return 0;
}

static int bBegin(lua_State* L) {
	auto id = luaL_checkstring(L, 1);
	float size_x = (float)luaL_checknumber(L, 2);
	float size_y = (float)luaL_checknumber(L, 3);
	ed::Begin(id, ImVec2(size_x, size_y));
	return 0;
}

static int bEnd(lua_State* L) {
	ed::End();
	return 0;
}

static int bBeginNode(lua_State* L) {
	int node_id = (int)luaL_checkinteger(L, 1);
	ed::BeginNode(node_id);
	return 0;
}

static int bEndNode(lua_State* L) {
	ed::EndNode();
	return 0;
}

static int bBeginPin(lua_State* L) {
	int pin_id = (int)luaL_checkinteger(L, 1);
	ed::PinKind type = (ed::PinKind)luaL_checkinteger(L, 2);
	ed::BeginPin(pin_id, type);
	return 0;
}

static int bEndPin(lua_State* L) {
	ed::EndPin();
	return 0;
}

static int bBeginDelete(lua_State* L) {
	lua_pushboolean(L, ed::BeginDelete());
	return 1;
}

static int bEndDelete(lua_State* L) {
	ed::EndDelete();
	return 0;
}

static int bBeginCreate(lua_State* L) {
	float r = (float)luaL_optnumber(L, 1, 1);
	float g = (float)luaL_optnumber(L, 2, 1);
	float b = (float)luaL_optnumber(L, 3, 1);
	float a = (float)luaL_optnumber(L, 4, 1);
	float thickness = (float)luaL_optnumber(L, 5, 1);
	lua_pushboolean(L, ed::BeginCreate(ImVec4(r, g, b, a), thickness));
	return 1;
}

static int bEndCreate(lua_State* L) {
	ed::EndCreate();
	return 0;
}

static int bSetNodePosition(lua_State* L) {
	int id = (int)luaL_checkinteger(L, 1);
	float pos_x = (float)luaL_checknumber(L, 2);
	float pos_y = (float)luaL_checknumber(L, 3);
	ed::SetNodePosition(id, ImVec2(pos_x, pos_y));
	return 0;
}

static int bGetNodePosition(lua_State* L) {
	int id = (int)luaL_checkinteger(L, 1);
	ImVec2 pos = ed::GetNodePosition(id);
	lua_pushnumber(L, pos.x);
	lua_pushnumber(L, pos.y);
	return 2;
}

static int bCheckNodeExist(lua_State* L) {
	int id = (int)luaL_checkinteger(L, 1);
	lua_pushboolean(L, ed::CheckNodeExist(id));
	return 1;
}

static int bEnableShortcuts(lua_State* L) {
	bool v = lua_toboolean(L, 1);
	ed::EnableShortcuts(v);
	return 0;
}

static int bSuspend(lua_State* L) {
	ed::Suspend();
	return 0;
}

static int bResume(lua_State* L) {
	ed::Resume();
	return 0;
}

static int bLink(lua_State* L) {
	int id = (int)luaL_checkinteger(L, 1);
	int inputId = (int)luaL_checkinteger(L, 2);
	int outputId = (int)luaL_checkinteger(L, 3);
	float tickness = (float)luaL_optnumber(L, 5, 1);

	ImVec4 color(1, 1, 1, 1);
	if (lua_type(L, 4) == LUA_TTABLE) {
		if (lua_geti(L, 4, 1) == LUA_TNUMBER)
			color.x = (float)lua_tonumber(L, -1);
		if (lua_geti(L, 4, 2) == LUA_TNUMBER)
			color.y = (float)lua_tonumber(L, -1);
		if (lua_geti(L, 4, 3) == LUA_TNUMBER)
			color.z = (float)lua_tonumber(L, -1);
		if (lua_geti(L, 4, 4) == LUA_TNUMBER)
			color.w = (float)lua_tonumber(L, -1);
		lua_pop(L, 4);
	}
	ed::Link(id, inputId, outputId, color, tickness);
	return 0;
}

static int bPinLink(lua_State* L) {
	int id = (int)luaL_checkinteger(L, 1);
	int inputId = (int)luaL_checkinteger(L, 2);
	int outputId = (int)luaL_checkinteger(L, 3);
	ed::PinType type = (ed::PinType)luaL_checkinteger(L, 4);
	float tickness = (float)luaL_optnumber(L, 5, 1);
	
	ImColor color = ed::GetIconColor(type);
	ed::Link(id, inputId, outputId, color, tickness);
	return 0;
}

static int bQueryNewLink(lua_State* L) {
	ed::PinId inputPinId = 0;
	ed::PinId outputPinId = 0;
	if (ed::QueryNewLink(&inputPinId, &outputPinId)) {
		lua_pushinteger(L, inputPinId.Get());
		lua_pushinteger(L, outputPinId.Get());
		return 2;
	}
	return 0;
}

static int bQueryNewNode(lua_State* L) {
	ed::PinId pinId = 0;
	if (ed::QueryNewNode(&pinId)) {
		lua_pushinteger(L, pinId.Get());
		return 1;
	}
	return 0;
}

static int bAcceptNewItem(lua_State* L) {
	if (lua_tonumber(L, 1)) {
		float r = (float)luaL_checknumber(L, 1);
		float g = (float)luaL_checknumber(L, 2);
		float b = (float)luaL_checknumber(L, 3);
		float a = (float)luaL_checknumber(L, 4);
		float thickness = (float)luaL_optnumber(L, 5, 1);
		lua_pushboolean(L, ed::AcceptNewItem(ImVec4(r, g, b, a), thickness));
	} else {
		lua_pushboolean(L, ed::AcceptNewItem());
	}
	return 1;
}

static int bQueryDeletedLink(lua_State* L) {
	ed::LinkId deletedLinkId = 0;
	if (ed::QueryDeletedLink(&deletedLinkId)) {
		lua_pushinteger(L, deletedLinkId.Get());
		return 1;
	}
	return 0;
}

static int bQueryDeletedNode(lua_State* L) {
	ed::NodeId nodeId = 0;
	if (ed::QueryDeletedNode(&nodeId)) {
		lua_pushinteger(L, nodeId.Get());
		return 1;
	}
	return 0;
}

static int bAcceptDeletedItem(lua_State* L) {
	lua_pushboolean(L, ed::AcceptDeletedItem());
	return 1;
}

static int bNavigateToContent(lua_State* L) {
	ed::NavigateToContent();
	return 0;
}

static int bSplitter(lua_State* L) {
	bool split_vertically = lua_toboolean(L, 1);
	float thickness = (float)luaL_checknumber(L, 2);
	float size1 = (float)luaL_checknumber(L, 3); 
	float size2 = (float)luaL_checknumber(L, 4);
	float min_size1 = (float)luaL_checknumber(L, 5);
	float min_size2 = (float)luaL_checknumber(L, 6);
	float splitter_long_axis_size = (float)luaL_optnumber(L, 7, -1);
	if (ed::Splitter(split_vertically, thickness, &size1, &size2, min_size1, min_size2, splitter_long_axis_size)) {
		lua_pushnumber(L, size1);
		lua_pushnumber(L, size2);
		return 2;
	} 
	return 0;
}

static int bShowNodeContextMenu(lua_State* L) {
	ed::NodeId id;
	if (ed::ShowNodeContextMenu(&id)) {
		lua_pushinteger(L, id.Get());
		return 1;
	}
	return 0;
}

static int bShowPinContextMenu(lua_State* L) {
	ed::PinId id = 0;
	if (ed::ShowPinContextMenu(&id)) {
		lua_pushinteger(L, id.Get());
		return 1;
	}
	return 0;
}

static int bShowLinkContextMenu(lua_State* L) {
	ed::LinkId id = 0;
	if (ed::ShowLinkContextMenu(&id)) {
		lua_pushinteger(L, id.Get());
		return 1;
	}
	return 0;
}

static int bShowBackgroundContextMenu(lua_State* L) {
	if (ed::ShowBackgroundContextMenu()) {
		lua_pushboolean(L, true);
		return 1;
	}
	return 0;
}

static int bPinPivotAlignment(lua_State* L) {
	float x = (float)luaL_checknumber(L, 1);
	float y = (float)luaL_checknumber(L, 2);
	ed::PinPivotAlignment(ImVec2(x, y));
	return 0;
}

static int bPinPivotSize(lua_State* L) {
	float x = (float)luaL_checknumber(L, 1);
	float y = (float)luaL_checknumber(L, 2);
	ed::PinPivotSize(ImVec2(0, 0));
	return 0;
}

static int bDrawPinIcon(lua_State* L) {
	ed::PinType type = (ed::PinType)luaL_checkinteger(L, 1);
	bool connected = !!lua_toboolean(L, 2);
	int alpha = (int)luaL_checkinteger(L, 3);
	ed::DrawPinIcon(type, connected, alpha);
	return 0;
}

static int bRejectNewItem(lua_State* L) {
	int r = (int)luaL_checkinteger(L, 1);
	int g = (int)luaL_checkinteger(L, 2);
	int b = (int)luaL_checkinteger(L, 3);
	int a = (int)luaL_checkinteger(L, 4);
	float thickness = (float)luaL_optnumber(L, 5, 1);
	ed::RejectNewItem(ImColor(r, g, b, a), thickness);
	return 0;
}

using SaveReasonFlags = ed::SaveReasonFlags;
static int bGetDirtyReason(lua_State* L) {
	auto flag = ed::GetSaveReasonFlags();
	lua_pushinteger(L, (int)flag);
	return 1;
}

static int bClearDirty(lua_State* L) {
	ed::ClearDirty();
	return 0;
}

static int bGroup(lua_State* L) {
	float x = (float)luaL_checknumber(L, 1);
	float y = (float)luaL_checknumber(L, 2);
	ed::Group(ImVec2(x, y));
	return 0;
}

static int bBeginGroupHint(lua_State* L) {
	ed::NodeId id = (int)luaL_checkinteger(L, 1);
	if (ed::BeginGroupHint(id)) {
		lua_pushboolean(L, true);
		return 1;
	}
	return 0;
}

static int bEndGroupHint(lua_State* L) {
	ed::EndGroupHint();
	return 0;
}

static int bGetGroupMin(lua_State* L) {
	auto min = ed::GetGroupMin();
	lua_pushnumber(L, min.x);
	lua_pushnumber(L, min.y);
	return 2;
}

static int bPushStyleColor(lua_State* L) {
	ed::StyleColor index = (ed::StyleColor)luaL_checkinteger(L, 1);
	float r = (float)luaL_checknumber(L, 2);
	float g = (float)luaL_checknumber(L, 3);
	float b = (float)luaL_checknumber(L, 4);
	float a = (float)luaL_checknumber(L, 5);
	ed::PushStyleColor(index, ImColor(r, g, b, a));
	return 0;
}

static int bPopStyleColor(lua_State* L) {
	int count = (int)luaL_optinteger(L, 1, 1);
	ed::PopStyleColor(count);
	return 0;
}

static int bPushStyleVar(lua_State* L) {
	ed::StyleVar index = (ed::StyleVar)luaL_checkinteger(L, 1);
	float x = (float)luaL_checknumber(L, 2);
	float y = (float)luaL_checknumber(L, 3);
	ed::PushStyleVar(index, ImVec2(x, y));
	return 0;
}

static int bPopStyleVar(lua_State* L) {
	int count = (int)luaL_optinteger(L, 1, 1);
	ed::PopStyleVar(count);
	return 0;
}

#define DEF_ENUM(CLASS, MEMBER)                                      \
    lua_pushinteger(L, static_cast<lua_Integer>(ed::CLASS::MEMBER)); \
    lua_setfield(L, -2, #MEMBER);

#define DEF_ENUM2(CLASS, MEMBER, NAME)                                      \
    lua_pushinteger(L, static_cast<lua_Integer>(ed::CLASS::MEMBER)); \
    lua_setfield(L, -2, #NAME);

extern "C" int luaopen_ly_imgui_node_editor(lua_State *L) {
	luaL_Reg lib[] = {
		{ "CreateEditorContext", bCreateEditorContext },
		{ "CreateBlueprintNodeBuilder", bCreateBlueprintNodeBuilder },
		{ "CreateCanvasContext", bCreateCanvasContext },
		
		{ "SetCurrentEditor", 	bSetCurrentEditor },
		{ "Begin", 				bBegin },
		{ "End", 				bEnd },
		{ "BeginNode", 			bBeginNode },
		{ "EndNode", 			bEndNode },
		{ "BeginPin", 			bBeginPin },
		{ "EndPin", 			bEndPin },
		{ "BeginDelete", 		bBeginDelete },
		{ "EndDelete", 			bEndDelete },
		{ "BeginCreate", 		bBeginCreate },
		{ "EndCreate", 			bEndCreate },
		{ "SetNodePosition", 	bSetNodePosition },
		{ "GetNodePosition", 	bGetNodePosition },
		{ "CheckNodeExist", 	bCheckNodeExist },
		{ "EnableShortcuts", 	bEnableShortcuts },
		{ "Suspend", 			bSuspend },
		{ "Resume", 			bResume },
		{ "Link", 				bLink },
		{ "PinLink", 			bPinLink },
		{ "QueryNewLink", 		bQueryNewLink },
		{ "QueryNewNode", 		bQueryNewNode },
		{ "AcceptNewItem", 		bAcceptNewItem },
		{ "QueryDeletedLink", 	bQueryDeletedLink },
		{ "QueryDeletedNode", 	bQueryDeletedNode },
		{ "AcceptDeletedItem", 	bAcceptDeletedItem },
		{ "NavigateToContent", 	bNavigateToContent },
		{ "Splitter", 			bSplitter },
		{ "ShowNodeContextMenu", 			bShowNodeContextMenu },	
		{ "ShowPinContextMenu", 			bShowPinContextMenu },
		{ "ShowLinkContextMenu", 			bShowLinkContextMenu },
		{ "ShowBackgroundContextMenu", 		bShowBackgroundContextMenu },
		{ "PinPivotAlignment", 				bPinPivotAlignment },
		{ "PinPivotSize", 					bPinPivotSize },
		{ "DrawPinIcon", 					bDrawPinIcon },
		{ "RejectNewItem", 					bRejectNewItem },
		{ "GetDirtyReason", 				bGetDirtyReason },
		{ "ClearDirty", 					bClearDirty },
		{ "Group", 							bGroup },
		{ "BeginGroupHint", 				bBeginGroupHint },
		{ "EndGroupHint", 					bEndGroupHint },
		{ "GetGroupMin", 					bGetGroupMin },
		{ "PushStyleColor", 				bPushStyleColor },
		{ "PopStyleColor", 					bPopStyleColor },
		{ "PushStyleVar", 					bPushStyleVar },
		{ "PopStyleVar", 					bPopStyleVar },
		
		{ NULL, NULL },
	};
	luaL_newlibtable(L, lib);
    luaL_setfuncs(L, lib, 0);

	lua_newtable(L);
	DEF_ENUM(PinKind, Input);
	DEF_ENUM(PinKind, Output);
	lua_setfield(L, -2, "PinKind");

	lua_newtable(L);
	DEF_ENUM(FlowDirection, Forward);
	DEF_ENUM(FlowDirection, Backward);
	lua_setfield(L, -2, "FlowDirection");

	lua_newtable(L);
	DEF_ENUM(PinType, Flow);
	DEF_ENUM(PinType, Bool);
	DEF_ENUM(PinType, Int);
	DEF_ENUM(PinType, Float);
	DEF_ENUM(PinType, String);
	DEF_ENUM(PinType, Object);
	DEF_ENUM(PinType, Function);
	DEF_ENUM(PinType, Delegate);
	lua_setfield(L, -2, "PinType");

	lua_newtable(L);
	DEF_ENUM2(StyleColor, StyleColor_Bg, Bg);
	DEF_ENUM2(StyleColor, StyleColor_Grid, Grid);
	DEF_ENUM2(StyleColor, StyleColor_NodeBg, NodeBg);
	DEF_ENUM2(StyleColor, StyleColor_NodeBorder, NodeBorder);
	DEF_ENUM2(StyleColor, StyleColor_HovNodeBorder, HovNodeBorder);
	DEF_ENUM2(StyleColor, StyleColor_SelNodeBorder, SelNodeBorder);
	DEF_ENUM2(StyleColor, StyleColor_NodeSelRect, NodeSelRect);
	DEF_ENUM2(StyleColor, StyleColor_NodeSelRectBorder, NodeSelRectBorder);
	DEF_ENUM2(StyleColor, StyleColor_HovLinkBorder, HovLinkBorder);
	DEF_ENUM2(StyleColor, StyleColor_SelLinkBorder, SelLinkBorder);
	DEF_ENUM2(StyleColor, StyleColor_HighlightLinkBorder, HighlightLinkBorder);
	DEF_ENUM2(StyleColor, StyleColor_LinkSelRect, LinkSelRect);
	DEF_ENUM2(StyleColor, StyleColor_LinkSelRectBorder, LinkSelRectBorder);
	DEF_ENUM2(StyleColor, StyleColor_PinRect, PinRect);
	DEF_ENUM2(StyleColor, StyleColor_PinRectBorder, PinRectBorder);
	DEF_ENUM2(StyleColor, StyleColor_Flow, Flow);
	DEF_ENUM2(StyleColor, StyleColor_FlowMarker, FlowMarker);
	DEF_ENUM2(StyleColor, StyleColor_GroupBg, GroupBg);
	DEF_ENUM2(StyleColor, StyleColor_GroupBorder, GroupBorder);
	lua_setfield(L, -2, "StyleColor");

	lua_newtable(L);
	DEF_ENUM2(StyleVar, StyleVar_NodePadding, NodePadding);
	DEF_ENUM2(StyleVar, StyleVar_NodeRounding, NodeRounding);
	DEF_ENUM2(StyleVar, StyleVar_NodeBorderWidth, NodeBorderWidth);
	DEF_ENUM2(StyleVar, StyleVar_SourceDirection, NodeBorderWidth);
	DEF_ENUM2(StyleVar, StyleVar_TargetDirection, NodeBorderWidth);
	DEF_ENUM2(StyleVar, StyleVar_LinkStrength, NodeBorderWidth);
	DEF_ENUM2(StyleVar, StyleVar_PinBorderWidth, NodeBorderWidth);
	DEF_ENUM2(StyleVar, StyleVar_PinRadius, NodeBorderWidth);
	lua_setfield(L, -2, "StyleVar");

    return 1;
}

namespace bee::lua {
	template <>
	struct udata<imguilua::NodeEditorContext> {
		static inline auto name = "imguilua::NodeEditorContext";
		static inline auto metatable = imguilua::bind::metatable;
	};

	template <>
	struct udata<util::BlueprintNodeBuilder> {
		static inline auto name = "util::BlueprintNodeBuilder";
		static inline auto metatable = imguilua::bindutils::metatable;
	};

	template <>
	struct udata<imguilua::CanvasContext> {
		static inline auto name = "imguilua::CanvasContext";
		static inline auto metatable = imguilua::canvasbind::metatable;
	};
}