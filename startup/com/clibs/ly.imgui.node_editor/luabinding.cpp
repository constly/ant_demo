#include <lua.hpp>
#include <bee/lua/binding.h>
#include "backend/imgui_impl_bgfx.h"
#include <bee/nonstd/unreachable.h>
#include "src/imgui_node_editor.h"
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
	// 颜色
	// tickness
	ed::Link(id, inputId, outputId);
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
	ed::LinkId deletedLinkId;
	if (ed::QueryDeletedLink(&deletedLinkId)) {
		lua_pushinteger(L, deletedLinkId.Get());
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
	ed::PinId id;
	if (ed::ShowPinContextMenu(&id)) {
		lua_pushinteger(L, id.Get());
		return 1;
	}
	return 0;
}

static int bShowLinkContextMenu(lua_State* L) {
	ed::LinkId id;
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

#define DEF_ENUM(CLASS, MEMBER)                                      \
    lua_pushinteger(L, static_cast<lua_Integer>(ed::CLASS::MEMBER)); \
    lua_setfield(L, -2, #MEMBER);

extern "C" int luaopen_ly_imgui_node_editor(lua_State *L) {
	luaL_Reg lib[] = {
		{ "CreateEditorContext", bCreateEditorContext },
		{ "CreateBlueprintNodeBuilder", bCreateBlueprintNodeBuilder },
	
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
		{ "CheckNodeExist", 	bCheckNodeExist },
		{ "EnableShortcuts", 	bEnableShortcuts },
		{ "Suspend", 			bSuspend },
		{ "Resume", 			bResume },
		{ "Link", 				bLink },
		{ "QueryNewLink", 		bQueryNewLink },
		{ "AcceptNewItem", 		bAcceptNewItem },
		{ "QueryDeletedLink", 	bQueryDeletedLink },
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
}