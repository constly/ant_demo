#include <lua.hpp>

extern void init_text_editor(lua_State* L);

extern "C"
int luaopen_imgui_extend(lua_State *L) {
	lua_newtable(L);
	init_text_editor(L);

/*
    luaL_Reg lib[] = {
        // { "Sequencer", wSequencer },
        // { "SimpleSequencer", wSimpleSequencer },
        // { "DirectionalArrow", zDirectionalArrow },
        // { "PropertyLabel", wPropertyLabel },
        { NULL, NULL },
    };
    luaL_newlib(L, lib);
*/
    return 1;
}
