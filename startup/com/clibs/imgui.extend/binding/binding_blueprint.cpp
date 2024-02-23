#include "../blueprint/bp_drawing.h"
#include "binding_utils.h"
#include "imgui.h"


static int 
bpDrawPinIcon(lua_State* L) {
	auto pin_type = (imguilua::EPinType)luaL_checkinteger(L, 1);
	bool connected = lua_toboolean(L, 2);
	auto alpha = (int)luaL_checkinteger(L, 3);
	float scale = (float)luaL_checknumber(L, 4);
	imguilua::Blueprint::DrawPinIcon(pin_type, connected, alpha, scale);
	return 0;
}


void init_blueprint(lua_State* L) {
	luaL_Reg api_list[] = {
		{ "DrawPinIcon", bpDrawPinIcon },
		{ NULL, NULL },
	};
	luaL_newlib(L, api_list);
	lua_setfield(L, -2, "blueprint");
}