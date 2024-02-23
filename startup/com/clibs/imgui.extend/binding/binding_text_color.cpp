#include "../text_color/ImTextColorful.h"
#include "binding_utils.h"

namespace imguilua::bind::TextColor {

	static int Render(lua_State* L) {
		auto& text = bee::lua::checkudata<imguilua::ImTextColorful>(L, 1);
		auto content = luaL_checkstring(L, 2);
		auto posX = (float)luaL_checknumber(L, 3);
		auto posY = (float)luaL_checknumber(L, 4);
		auto disable = false;
		if (lua_isboolean(L, 5)) 
			disable = lua_toboolean(L, 5);

		text.DrawLine(content, ImVec2(posX, posY), disable);
		return 0;
	}

	static void metatable(lua_State* L) {
		static luaL_Reg lib[] = {
			{"Render", Render},
			{nullptr, nullptr},
		};
		luaL_newlib(L, lib);
		lua_setfield(L, -2, "__index");
	}

	static int getmetatable(lua_State* L) {
		bee::lua::getmetatable<imguilua::ImTextColorful>(L);
        return 1;
	}

	static int create(lua_State* L) {
		bee::lua::newudata<imguilua::ImTextColorful>(L);
		return 1;
	}
}


static int create_textcolor(lua_State* L) {
	return imguilua::bind::TextColor::create(L);
}

void init_text_color(lua_State* L) {
	lua_pushcfunction(L, create_textcolor);
	lua_setfield(L, -2, "CreateTextColor");
}

namespace bee::lua {
	template <>
	struct udata<imguilua::ImTextColorful> {
		static inline auto name = "imguilua::TextColor";
		static inline auto metatable = imguilua::bind::TextColor::metatable;
	};
}