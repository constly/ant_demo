#include <lua.hpp>
#include <bee/lua/binding.h>
#include "src/imgui_node_editor.h"
#include "bp/blueprint.h"

namespace ed = ax::NodeEditor;

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
	lua_pushboolean(L, ed::BeginCreate());
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
	ed::PinId inputPinId, outputPinId;
	if (ed::QueryNewLink(&inputPinId, &outputPinId)) {
		if (inputPinId && outputPinId) {
			lua_pushinteger(L, inputPinId.Get());
			lua_pushinteger(L, outputPinId.Get());
			return 2;
		}
	}
	return 0;
}

static int bAcceptNewItem(lua_State* L) {
	lua_pushboolean(L, ed::AcceptNewItem());
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

#define DEF_ENUM(CLASS, MEMBER)                                      \
    lua_pushinteger(L, static_cast<lua_Integer>(ed::CLASS::MEMBER)); \
    lua_setfield(L, -2, #MEMBER);

extern "C" int luaopen_ly_imgui_node_editor(lua_State *L) {
	luaL_Reg lib[] = {
		{ "CreateEditorContext",bCreateEditorContext },
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
		{ "ShowBackgroundContextMenu", 			bShowBackgroundContextMenu },
		
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

    return 1;
}

namespace bee::lua {
	template <>
	struct udata<imguilua::NodeEditorContext> {
		static inline auto name = "imguilua::NodeEditorContext";
		static inline auto metatable = imguilua::bind::metatable;
	};
}