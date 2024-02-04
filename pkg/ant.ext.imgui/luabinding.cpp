#include <lua.hpp>

extern void init_text_editor(lua_State* L);
extern void init_text_color(lua_State* L);
extern void init_draw_list(lua_State* L);

extern "C" int luaopen_imgui_extend(lua_State *L) {
	lua_newtable(L);
	init_text_editor(L);
	init_text_color(L);
	init_draw_list(L);
    return 1;
}
