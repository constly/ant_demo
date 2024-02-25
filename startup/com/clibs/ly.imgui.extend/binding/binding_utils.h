#include <lua.hpp>
#include <bee/lua/binding.h>
#include <vector>
#include <string>

namespace imguilua::bind {

	struct utils {
		static std::vector<float> read_field_array_float(lua_State *L, int tidx, const char *field);
		static std::vector<int> read_field_array_int(lua_State *L, int tidx, const char *field);
		static std::vector<std::string> read_field_array_string(lua_State *L, int tidx, const char *field);
		static std::string read_field_string(lua_State *L, int tidx, const char *field, std::string def = "");
		static bool read_field_bool(lua_State *L, int tidx, const char *field, bool def = false);
	};
}