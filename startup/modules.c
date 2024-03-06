#define linit_c
#define LUA_LIB

#include <stddef.h>
#include "lua.h"
#include "lualib.h"
#include "lauxlib.h"
#include "modules.h"

static const luaL_Reg loadedlibs[] = {
    {LUA_GNAME, luaopen_base},
    {LUA_LOADLIBNAME, luaopen_package},
    {LUA_COLIBNAME, luaopen_coroutine},
    {LUA_TABLIBNAME, luaopen_table},
    {LUA_IOLIBNAME, luaopen_io},
    {LUA_OSLIBNAME, luaopen_os},
    {LUA_STRLIBNAME, luaopen_string},
    {LUA_MATHLIBNAME, luaopen_math},
    {LUA_UTF8LIBNAME, luaopen_utf8},
    {LUA_DBLIBNAME, luaopen_debug},
    {NULL, NULL}
};


int luaopen_ly_imgui_extend(lua_State* L);
int luaopen_ly_sound_impl(lua_State* L);
int luaopen_ly_imgui_node_editor(lua_State* L);
int luaopen_ly_net(lua_State *L);

static void loadmodules(lua_State* L) {
	static const luaL_Reg modules[] = {
		{ "ly.imgui.extend", luaopen_ly_imgui_extend },
		{ "ly.imgui.node_editor", luaopen_ly_imgui_node_editor },
		{ "ly.sound.impl", luaopen_ly_sound_impl},
		{ "ly.net", luaopen_ly_net},

        { NULL, NULL},
	};

	const luaL_Reg *lib;
    luaL_getsubtable(L, LUA_REGISTRYINDEX, LUA_PRELOAD_TABLE);
    for (lib = modules; lib->func; lib++) {
        lua_pushcfunction(L, lib->func);
        lua_setfield(L, -2, lib->name);
    }
    lua_pop(L, 1);
}

LUALIB_API void luaL_openlibs (lua_State *L) {
    const luaL_Reg *lib;
    for (lib = loadedlibs; lib->func; lib++) {
        luaL_requiref(L, lib->name, lib->func, 1);
        lua_pop(L, 1);  /* remove lib */
    }
    ant_loadmodules(L);
    luaL_getsubtable(L, LUA_REGISTRYINDEX, LUA_PRELOAD_TABLE);
    loadmodules(L);
    lua_pop(L, 1);
}
