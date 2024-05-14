﻿#include <lua.hpp>
#include <bee/lua/binding.h>
#include "world/world.h"

namespace luabind {

	// 每帧更新
	static int Update(lua_State* L) {
		World& world = bee::lua::checkudata<World>(L, 1);
		world.Update();
		return 0;
	}

	// 重置世界
	static int Reset(lua_State* L) {
		World& world = bee::lua::checkudata<World>(L, 1);
		world.Reset();
		return 0;
	}

	// 销毁世界数据
	static int Destroy(lua_State* L) {
		World& world = bee::lua::checkudata<World>(L, 1);
		world.Destroy();
		return 0;
	}

	// 设置世界中的区域大小
	static int SetRegionSize(lua_State* L) {
		World& world = bee::lua::checkudata<World>(L, 1);
		int size_x = (int)luaL_checkinteger(L, 2);  	
		int size_y = (int)luaL_checkinteger(L, 3);  	
		int size_z = (int)luaL_checkinteger(L, 4);  	
		world.SetRegionSize(size_x, size_y, size_z);
		return 0;
	}

	// 设置最大agent大小
	static int SetMaxAgentSize(lua_State* L) {
		World& world = bee::lua::checkudata<World>(L, 1);
		int size = (int)luaL_checkinteger(L, 2);  	
		world.SetMaxAgentSize(size);
		return 0;
	}

	// 得到地面高度
	static int GetGroundHeight(lua_State* L) {
		World& world = bee::lua::checkudata<World>(L, 1);
		int pos_x = (int)luaL_checkinteger(L, 2);  	
		int pos_y = (int)luaL_checkinteger(L, 3);  	
		int pos_z = (int)luaL_checkinteger(L, 4);  	
		int checkRange = (int)luaL_optinteger(L, 5, 200);
		int height = world.GetGroundHeight(pos_x, pos_y, pos_z, checkRange);
		lua_pushinteger(L, height);
		return 1;
	}

	// 设置格子数据
	static int SetGridData(lua_State* L) {
		World& world = bee::lua::checkudata<World>(L, 1);
		int start_x = (int)luaL_checkinteger(L, 2);  	
		int start_y = (int)luaL_checkinteger(L, 3);  	
		int start_z = (int)luaL_checkinteger(L, 4);  	
		int size_x = (int)luaL_checkinteger(L, 5);  	
		int size_y = (int)luaL_checkinteger(L, 6);  	
		int size_z = (int)luaL_checkinteger(L, 7);  	
		EGridType gridType = (EGridType)luaL_checkinteger(L, 8);  	
		world.SetGridData(start_x, start_y, start_z, size_x, size_y, size_z, gridType);
		return 0;
	}

	// 清空格子数据
	static int ClearGridData(lua_State* L) {
		World& world = bee::lua::checkudata<World>(L, 1);
		int start_x = (int)luaL_checkinteger(L, 2);
		int start_y = (int)luaL_checkinteger(L, 3);
		int start_z = (int)luaL_checkinteger(L, 4);
		int size_x = (int)luaL_checkinteger(L, 5);
		int size_y = (int)luaL_checkinteger(L, 6);
		int size_z = (int)luaL_checkinteger(L, 7);
		world.ClearGridData(start_x, start_y, start_z, size_x, size_y, size_z);
		return 0;
	}

	// 寻路
	static int FindPath(lua_State* L) {
		World& world = bee::lua::checkudata<World>(L, 1);
		AStarParam param;
		param.start.x = (int)luaL_checkinteger(L, 2);  	
		param.start.y = (int)luaL_checkinteger(L, 3);  	
		param.start.z = (int)luaL_checkinteger(L, 4);  	
		param.dest.x = (int)luaL_checkinteger(L, 5);  	
		param.dest.y = (int)luaL_checkinteger(L, 6);  	
		param.dest.z = (int)luaL_checkinteger(L, 7);  
		param.bodySize = (int)luaL_checkinteger(L, 8);  
		param.walkType = (EWalkType)luaL_checkinteger(L, 9);  
		param.path.clear();

		world.astar.Run();
		return 0;
	}

	static void metatable(lua_State* L) {
		static luaL_Reg lib[] = {
			{"Update", Update},
			{"Reset", Reset},
			{"Destroy", Destroy},
			
			{"SetRegionSize", SetRegionSize},
			{"SetMaxAgentSize", SetMaxAgentSize},

			{"GetGroundHeight", GetGroundHeight},
			{"SetGridData", SetGridData},
			{"ClearGridData", ClearGridData},
			{"FindPath", FindPath},

			{nullptr, nullptr},
		};
		luaL_newlib(L, lib);
		lua_setfield(L, -2, "__index");
	}
}

static int bCreateWorld(lua_State* L) {
	bee::lua::newudata<World>(L);
	return 1;
}

#define DEF_ENUM(CLASS, MEMBER)                                      \
    lua_pushinteger(L, static_cast<lua_Integer>(CLASS::MEMBER)); \
    lua_setfield(L, -2, #MEMBER);

extern "C" int luaopen_sims_world_impl(lua_State *L) {
	lua_newtable(L);
	lua_pushcfunction(L, bCreateWorld);
	lua_setfield(L, -2, "CreateWorld");

	lua_pushinteger(L, INVALID_NUM);
	lua_setfield(L, -2, "InValidNum");	// 无效数值

	lua_newtable(L);
	DEF_ENUM(EWalkType, Ground);
	DEF_ENUM(EWalkType, Sky);
	DEF_ENUM(EWalkType, Water);
	DEF_ENUM(EWalkType, Wall);
	lua_setfield(L, -2, "WalkType");

	lua_newtable(L);
	DEF_ENUM(EGridType, None);
	DEF_ENUM(EGridType, Under_Ground);
	DEF_ENUM(EGridType, Under_Water);
	DEF_ENUM(EGridType, Under_Object);
	DEF_ENUM(EGridType, Under_StandableObject);

	DEF_ENUM(EGridType, Ground);
	DEF_ENUM(EGridType, Wall);
	DEF_ENUM(EGridType, Water);
	DEF_ENUM(EGridType, Ceiling);
	lua_setfield(L, -2, "GridType");

	return 1;
}

namespace bee::lua {
	template <>
	struct udata<World> {
		static inline auto name = "astar::world";
		static inline auto metatable = luabind::metatable;
	};
}