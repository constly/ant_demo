#include <lua.hpp>
#include <bee/lua/binding.h>
#include "bgfx_interface.h"

static int getStats(lua_State* L) {
	BGFX(set_debug)(BGFX_DEBUG_NONE);
	return 0;
}

extern "C" int luaopen_ly_bgfx_impl(lua_State *L) {
	lua_newtable(L);
	lua_pushcfunction(L, getStats);
	lua_setfield(L, -2, "getStats");

	return 1;
}