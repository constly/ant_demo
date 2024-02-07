#include "binding_utils.h"


namespace imguilua::bind {

	//read table { 1.5, 2.5, 3.5, .. }
	std::vector<float> utils::read_field_array_float(lua_State *L, int tidx, const char *field) {
		std::vector<float> values;
		auto fieldType = lua_getfield(L, tidx, field);
		if (fieldType == LUA_TTABLE) {
			lua_len(L, -1);
			int n = (int)lua_tointeger(L, -1);
			lua_pop(L, 1);

			for (int i = 0; i < n; ++i) {
				if (lua_geti(L, i * -1 - 1, i + 1) != LUA_TNUMBER) {
					luaL_error(L, "read_field_array_float should be a number");
				}
				values.push_back((float)lua_tonumber(L, -1));
			}
			lua_pop(L, n);
		} else if (fieldType != LUA_TNIL) {
			luaL_error(L, "read_field_array_float should be a table, field = %s", field);
		}
		lua_pop(L, 1);
		return values;
	}


	//read table { 1, 2, 3, .. }
	std::vector<int> utils::read_field_array_int(lua_State *L, int tidx, const char *field) {
		std::vector<int> values;
		auto fieldType = lua_getfield(L, tidx, field);
		if (fieldType == LUA_TTABLE) {
			lua_len(L, -1);
			int n = (int)lua_tointeger(L, -1);
			lua_pop(L, 1);

			for (int i = 0; i < n; ++i) {
				if (lua_geti(L, i * -1 - 1, i + 1) != LUA_TNUMBER) {
					luaL_error(L, "read_field_array_int should be a number");
				}
				values.push_back((int)lua_tointeger(L, -1));
			}
			lua_pop(L, n);
		} else if (fieldType != LUA_TNIL) {
			luaL_error(L, "read_field_array_int should be a table, field = %s", field);
		}
		lua_pop(L, 1);
		return values;
	}
	
	//read table { "hello", "world", "nihao", .. }
	std::vector<std::string> utils::read_field_array_string(lua_State *L, int tidx, const char *field) {
		std::vector<std::string> values;
		auto fieldType = lua_getfield(L, tidx, field);
		if (fieldType == LUA_TTABLE) {
			lua_len(L, -1);
			int n = (int)lua_tointeger(L, -1);
			lua_pop(L, 1);

			for (int i = 0; i < n; ++i) {
				if (lua_geti(L, i * -1 - 1, i + 1) != LUA_TSTRING) {
					luaL_error(L, "read_field_array_string should be a string");
				}
				values.push_back(lua_tostring(L, -1));
			}
			lua_pop(L, n);
		} else if (fieldType != LUA_TNIL) {
			luaL_error(L, "read_field_array_string should be a table, field = %s", field);
		}
		lua_pop(L, 1);
		return values;
	}

	std::string utils::read_field_string(lua_State *L, int tidx, const char *field, std::string def) {
		if (lua_getfield(L, tidx, field) == LUA_TSTRING) {
			def = (bool)lua_tostring(L, -1);
		}
		lua_pop(L, 1);
		return def;
	}

	bool utils::read_field_bool(lua_State *L, int tidx, const char *field, bool def) {
		if (lua_getfield(L, tidx, field) == LUA_TBOOLEAN) {
			def = (bool)lua_toboolean(L, -1);
		}
		lua_pop(L, 1);
		return def;
	}
}