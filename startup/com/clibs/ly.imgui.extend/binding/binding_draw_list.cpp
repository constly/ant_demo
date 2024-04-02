#include "binding_utils.h"
#include "imgui.h"
#include "imgui_internal.h"

#define INDEX_ID 1
#define INDEX_ARGS 2

static double
read_field_float(lua_State *L, const char * field, double v, int tidx = INDEX_ARGS) {
	if (lua_getfield(L, tidx, field) == LUA_TNUMBER) {
		v = lua_tonumber(L, -1);
	}
	lua_pop(L, 1);
	return v;
}

static float
read_field_checkfloat(lua_State *L, const char * field, int tidx = INDEX_ARGS) {
	float v;
	if (lua_getfield(L, tidx, field) == LUA_TNUMBER) {
		v = (float)lua_tonumber(L, -1);
	} else {
		v = 0;
		luaL_error(L, "no float %s", field);
	}
	lua_pop(L, 1);
	return v;
}

static int
read_field_int(lua_State *L, const char * field, int v, int tidx = INDEX_ARGS) {
	if (lua_getfield(L, tidx, field) == LUA_TNUMBER) {
		if (!lua_isinteger(L, -1)) {
			luaL_error(L, "Not an integer");
		}
		v = (int)lua_tointeger(L, -1);
	}
	lua_pop(L, 1);
	return v;
}

static int
read_field_checkint(lua_State *L, const char * field, int tidx = INDEX_ARGS) {
	int v;
	if (lua_getfield(L, tidx, field) == LUA_TNUMBER) {
		if (!lua_isinteger(L, -1)) {
			luaL_error(L, "Not an integer");
		}
		v = (int)lua_tointeger(L, -1);
	} else {
		v = 0;
		luaL_error(L, "no int %s", field);
	}
	lua_pop(L, 1);
	return v;
}

static const char *
read_field_string(lua_State *L, const char * field, const char *v, int tidx = INDEX_ARGS) {
	if (lua_getfield(L, tidx, field) == LUA_TSTRING) {
		v = lua_tostring(L, -1);
	}
	lua_pop(L, 1);
	return v;
}

static const char *
read_field_checkstring(lua_State *L, const char * field, int tidx = INDEX_ARGS) {
	const char * v = NULL;
	if (lua_getfield(L, tidx, field) == LUA_TSTRING) {
		v = lua_tostring(L, -1);
	}
	else {
		luaL_error(L, "no string %s", field);
	}
	lua_pop(L, 1);
	return v;
}

static const char *
read_index_string(lua_State *L, int index, const char *v, int tidx = INDEX_ARGS) {
	if (lua_geti(L, tidx, index) == LUA_TSTRING) {
		v = lua_tostring(L, -1);
	}
	lua_pop(L, 1);
	return v;
}

static bool
read_field_boolean(lua_State *L, const char *field, bool v, int tidx = INDEX_ARGS) {
	if (lua_getfield(L, tidx, field) == LUA_TBOOLEAN) {
		v = (bool)lua_toboolean(L, -1);
	}
	lua_pop(L, 1);
	return v;
}

//read table { x, y }
static ImVec2
read_field_vec2(lua_State *L, const char *field, ImVec2 def_val, int tidx = INDEX_ARGS) {
	if (lua_getfield(L, tidx, field) == LUA_TTABLE) {
		if (lua_geti(L, -1, 1) == LUA_TNUMBER)
			def_val.x = (float)lua_tonumber(L, -1);
		if (lua_geti(L, -2, 2) == LUA_TNUMBER)
			def_val.y = (float)lua_tonumber(L, -1);
		lua_pop(L, 2);
	}
	lua_pop(L, 1);
	return def_val;
}

//read table { x, y, z, w }
static ImVec4
read_field_vec4(lua_State *L, const char *field, ImVec4 def_val, int tidx = INDEX_ARGS) {
	if (lua_getfield(L, tidx, field) == LUA_TTABLE) {
		if (lua_geti(L, -1, 1) == LUA_TNUMBER)
			def_val.x = (float)lua_tonumber(L, -1);
		if (lua_geti(L, -2, 2) == LUA_TNUMBER)
			def_val.y = (float)lua_tonumber(L, -1);
		if (lua_geti(L, -3, 3) == LUA_TNUMBER)
			def_val.z = (float)lua_tonumber(L, -1);
		if (lua_geti(L, -4, 4) == LUA_TNUMBER)
			def_val.w = (float)lua_tonumber(L, -1);
		lua_pop(L, 4);
	}
	lua_pop(L, 1);
	return def_val;
}


static int 
dlPushClipRect(lua_State* L) {
	float left = (float)luaL_checknumber(L, 1);
	float top = (float)luaL_checknumber(L, 2);
	float right = (float)luaL_checknumber(L, 3);
	float bottom = (float)luaL_checknumber(L, 4);
	bool intersect_with_current_clip_rect = lua_toboolean(L, 5);
	ImDrawList* draw_list = ImGui::GetWindowDrawList();
	if (draw_list) {
		draw_list->PushClipRect(ImVec2(left, top), ImVec2(right, bottom), intersect_with_current_clip_rect);
	}
	return 0;
}

static int 
dlPopClipRect(lua_State* L) {
	ImDrawList* draw_list = ImGui::GetWindowDrawList();
	if (draw_list) {
		draw_list->PopClipRect();
	}
	return 0;
}

static int 
dlGetClipRectMin(lua_State* L) {
	ImDrawList* draw_list = ImGui::GetWindowDrawList();
	if (draw_list) {
		auto min = draw_list->GetClipRectMin();
		lua_pushnumber(L, min.x);
		lua_pushnumber(L, min.y);
		return 2;
	}
	return 0;
}

static int 
dlGetClipRectMax(lua_State* L) {
	ImDrawList* draw_list = ImGui::GetWindowDrawList();
	if (draw_list) {
		auto max = draw_list->GetClipRectMax();
		lua_pushnumber(L, max.x);
		lua_pushnumber(L, max.y);
		return 2;
	}
	return 0;
}

static int
dlAddLine(lua_State* L) {
	ImVec2 p1 = { 0.0f, 0.0f };
	ImVec2 p2 = { 1.0f, 1.0f };
	ImVec4 col = { 1.0f, 1.0f, 1.0f, 1.0f };
	float thickness = 1;
	ImDrawList* draw_list = ImGui::GetWindowDrawList();
	if (lua_type(L, 1) == LUA_TTABLE && draw_list) {
		p1 = read_field_vec2(L, "p1", p1, 1);
		p2 = read_field_vec2(L, "p2", p2, 1);
		col = read_field_vec4(L, "col", col, 1);
		thickness = (float)read_field_float(L, "thickness", thickness, 1);
		draw_list->AddLine(p1, p2, ImGui::ColorConvertFloat4ToU32(col), thickness);
	}
	return 0;
}

static int 
dlAddRect(lua_State* L) {
	ImVec2 min = { 0.0f, 0.0f };
	ImVec2 max = { 1.0f, 1.0f };
	ImVec4 col = { 1.0f, 1.0f, 1.0f, 1.0f };
	float rounding = 0;
	ImDrawFlags flags = 0;
	float thickness = 1;
	ImDrawList* draw_list = ImGui::GetWindowDrawList();
	if (lua_type(L, 1) == LUA_TTABLE && draw_list) {
		min = read_field_vec2(L, "min", min, 1);
		max = read_field_vec2(L, "max", max, 1);
		col = read_field_vec4(L, "col", col, 1);
		rounding = (float)read_field_float(L, "rounding", rounding, 1);
		flags = read_field_int(L, "flags", flags, 1);
		thickness = (float)read_field_float(L, "thickness", thickness, 1);
		draw_list->AddRect(min, max, ImGui::ColorConvertFloat4ToU32(col), rounding, flags, thickness);
	}
	return 0;
}

static int 
dlAddRectFilled(lua_State* L) {
	ImVec2 min = { 0.0f, 0.0f };
	ImVec2 max = { 1.0f, 1.0f };
	ImVec4 col = { 1.0f, 1.0f, 1.0f, 1.0f };
	float rounding = 0;
	ImDrawFlags flags = 0;
	ImDrawList* draw_list = ImGui::GetWindowDrawList();
	if (lua_type(L, 1) == LUA_TTABLE && draw_list) {
		min = read_field_vec2(L, "min", min, 1);
		max = read_field_vec2(L, "max", max, 1);
		col = read_field_vec4(L, "col", col, 1);
		rounding = (float)read_field_float(L, "rounding", rounding, 1);
		flags = read_field_int(L, "flags", flags, 1);
		draw_list->AddRectFilled(min, max, ImGui::ColorConvertFloat4ToU32(col), rounding, flags);
	}
	return 0;
}

static int
dlAddRectFilledMultiColor(lua_State* L) {
	ImVec2 min = { 0.0f, 0.0f };
	ImVec2 max = { 1.0f, 1.0f };
	ImVec4 col_upr_left = { 1.0f, 1.0f, 1.0f, 1.0f };
	ImVec4 col_upr_right = { 1.0f, 1.0f, 1.0f, 1.0f };
	ImVec4 col_bot_right = { 1.0f, 1.0f, 1.0f, 1.0f };
	ImVec4 col_bot_left = { 1.0f, 1.0f, 1.0f, 1.0f };
	ImDrawList* draw_list = ImGui::GetWindowDrawList();
	if (lua_type(L, 1) == LUA_TTABLE && draw_list) {
		min = read_field_vec2(L, "min", min, 1);
		max = read_field_vec2(L, "max", max, 1);
		ImU32 upr_left = ImGui::ColorConvertFloat4ToU32(read_field_vec4(L, "col_upr_left", col_upr_left, 1));
		ImU32 upr_right = ImGui::ColorConvertFloat4ToU32(read_field_vec4(L, "col_upr_right", col_upr_right, 1));
		ImU32 bot_right = ImGui::ColorConvertFloat4ToU32(read_field_vec4(L, "col_bot_right", col_bot_right, 1));
		ImU32 bot_left = ImGui::ColorConvertFloat4ToU32(read_field_vec4(L, "col_bot_left", col_bot_left, 1));
		draw_list->AddRectFilledMultiColor(min, max, upr_left, upr_right, bot_right, bot_left);
	}
	return 0;
}

static int
dlAddQuad(lua_State* L) {
	ImVec2 p1 = { 0.0f, 0.0f };
	ImVec2 p2 = { 0.0f, 0.0f };
	ImVec2 p3 = { 0.0f, 0.0f };
	ImVec2 p4 = { 0.0f, 0.0f };
	ImVec4 col = { 1.0f, 1.0f, 1.0f, 1.0f };
	float thickness = 1;
	ImDrawList* draw_list = ImGui::GetWindowDrawList();
	if (lua_type(L, 1) == LUA_TTABLE && draw_list) {
		p1 = read_field_vec2(L, "p1", p1, 1);
		p2 = read_field_vec2(L, "p2", p2, 1);
		p3 = read_field_vec2(L, "p3", p3, 1);
		p4 = read_field_vec2(L, "p4", p4, 1);
		col = read_field_vec4(L, "col", col, 1);
		thickness = (float)read_field_float(L, "thickness", thickness, 1);
		draw_list->AddQuad(p1, p2, p3, p4, ImGui::ColorConvertFloat4ToU32(col), thickness);
	}
	return 0;
}

static int
dlAddQuadFilled(lua_State* L) {
	ImVec2 p1 = { 0.0f, 0.0f };
	ImVec2 p2 = { 0.0f, 0.0f };
	ImVec2 p3 = { 0.0f, 0.0f };
	ImVec2 p4 = { 0.0f, 0.0f };
	ImVec4 col = { 1.0f, 1.0f, 1.0f, 1.0f };
	ImDrawList* draw_list = ImGui::GetWindowDrawList();
	if (lua_type(L, 1) == LUA_TTABLE && draw_list) {
		p1 = read_field_vec2(L, "p1", p1, 1);
		p2 = read_field_vec2(L, "p2", p2, 1);
		p3 = read_field_vec2(L, "p3", p3, 1);
		p4 = read_field_vec2(L, "p4", p4, 1);
		col = read_field_vec4(L, "col", col, 1);
		draw_list->AddQuadFilled(p1, p2, p3, p4, ImGui::ColorConvertFloat4ToU32(col));
	}
	return 0;
}

static int
dlAddTriangle(lua_State* L) {
	ImVec2 p1 = { 0.0f, 0.0f };
	ImVec2 p2 = { 0.0f, 0.0f };
	ImVec2 p3 = { 0.0f, 0.0f };
	ImVec4 col = { 1.0f, 1.0f, 1.0f, 1.0f };
	float thickness = 1;
	ImDrawList* draw_list = ImGui::GetWindowDrawList();
	if (lua_type(L, 1) == LUA_TTABLE && draw_list) {
		p1 = read_field_vec2(L, "p1", p1, 1);
		p2 = read_field_vec2(L, "p2", p2, 1);
		p3 = read_field_vec2(L, "p3", p3, 1);
		col = read_field_vec4(L, "col", col, 1);
		thickness = (float)read_field_float(L, "thickness", thickness, 1);
		draw_list->AddTriangle(p1, p2, p3, ImGui::ColorConvertFloat4ToU32(col), thickness);
	}
	return 0;
}

static int
dlAddTriangleFilled(lua_State* L) {
	ImVec2 p1 = { 0.0f, 0.0f };
	ImVec2 p2 = { 0.0f, 0.0f };
	ImVec2 p3 = { 0.0f, 0.0f };
	ImVec4 col = { 1.0f, 1.0f, 1.0f, 1.0f };
	ImDrawList* draw_list = ImGui::GetWindowDrawList();
	if (lua_type(L, 1) == LUA_TTABLE && draw_list) {
		p1 = read_field_vec2(L, "p1", p1, 1);
		p2 = read_field_vec2(L, "p2", p2, 1);
		p3 = read_field_vec2(L, "p3", p3, 1);
		col = read_field_vec4(L, "col", col, 1);
		draw_list->AddTriangleFilled(p1, p2, p3, ImGui::ColorConvertFloat4ToU32(col));
	}
	return 0;
}

static int
dlAddCircle(lua_State* L) {
	ImVec2 center = { 0.0f, 0.0f };
	float radius = 100;
	ImVec4 col = { 1.0f, 1.0f, 1.0f, 1.0f };
	int num_segments = 0;
	float thickness = 1;
	ImDrawList* draw_list = ImGui::GetWindowDrawList();
	if (lua_type(L, 1) == LUA_TTABLE && draw_list) {
		center = read_field_vec2(L, "center", center, 1);
		radius = (float)read_field_float(L, "radius", radius, 1);
		col = read_field_vec4(L, "col", col, 1);
		num_segments = read_field_int(L, "segments", num_segments, 1);
		thickness = (float)read_field_float(L, "thickness", thickness, 1);
		draw_list->AddCircle(center, radius, ImGui::ColorConvertFloat4ToU32(col), num_segments, thickness);
	}
	return 0;
}

static int
dlAddCircleFilled(lua_State* L) {
	ImVec2 center = { 0.0f, 0.0f };
	float radius = 100;
	ImVec4 col = { 1.0f, 1.0f, 1.0f, 1.0f };
	int num_segments = 0;
	ImDrawList* draw_list = ImGui::GetWindowDrawList();
	if (lua_type(L, 1) == LUA_TTABLE && draw_list) {
		center = read_field_vec2(L, "center", center, 1);
		radius = (float)read_field_float(L, "radius", radius, 1);
		col = read_field_vec4(L, "col", col, 1);
		num_segments = read_field_int(L, "segments", num_segments, 1);
		draw_list->AddCircleFilled(center, radius, ImGui::ColorConvertFloat4ToU32(col), num_segments);
	}
	return 0;
}

static int
dlAddNgon(lua_State* L) {
	ImVec2 center = { 0.0f, 0.0f };
	float radius = 100;
	ImVec4 col = { 1.0f, 1.0f, 1.0f, 1.0f };
	int num_segments = 0;
	float thickness = 1;
	ImDrawList* draw_list = ImGui::GetWindowDrawList();
	if (lua_type(L, 1) == LUA_TTABLE && draw_list) {
		center = read_field_vec2(L, "center", center, 1);
		radius = (float)read_field_float(L, "radius", radius, 1);
		col = read_field_vec4(L, "col", col, 1);
		num_segments = read_field_int(L, "segments", num_segments, 1);
		thickness = (float)read_field_float(L, "thickness", thickness, 1);
		draw_list->AddNgon(center, radius, ImGui::ColorConvertFloat4ToU32(col), num_segments, thickness);
	}
	return 0;
}

static int
dlAddNgonFilled(lua_State* L) {
	ImVec2 center = { 0.0f, 0.0f };
	float radius = 100;
	ImVec4 col = { 1.0f, 1.0f, 1.0f, 1.0f };
	int num_segments = 0;
	ImDrawList* draw_list = ImGui::GetWindowDrawList();
	if (lua_type(L, 1) == LUA_TTABLE && draw_list) {
		center = read_field_vec2(L, "center", center, 1);
		radius = (float)read_field_float(L, "radius", radius, 1);
		col = read_field_vec4(L, "col", col, 1);
		num_segments = read_field_int(L, "segments", num_segments, 1);
		draw_list->AddNgonFilled(center, radius, ImGui::ColorConvertFloat4ToU32(col), num_segments);
	}
	return 0;
}

static int
dlAddEllipse(lua_State* L) {
	ImVec2 center = { 0.0f, 0.0f };
	float radius_x = 100;
	float radius_y = 100;
	ImVec4 col = { 1.0f, 1.0f, 1.0f, 1.0f };
	float rot = 0;
	int num_segments = 0;
	float thickness = 1;
	ImDrawList* draw_list = ImGui::GetWindowDrawList();
	if (lua_type(L, 1) == LUA_TTABLE && draw_list) {
		center = read_field_vec2(L, "center", center, 1);
		radius_x = (float)read_field_float(L, "radius_x", radius_x, 1);
		radius_y = (float)read_field_float(L, "radius_y", radius_y, 1);
		col = read_field_vec4(L, "col", col, 1);
		rot = (float)read_field_float(L, "rot", rot, 1);
		num_segments = read_field_int(L, "segments", num_segments, 1);
		thickness = (float)read_field_float(L, "thickness", thickness, 1);
		draw_list->AddEllipse(center, ImVec2(radius_x, radius_y), ImGui::ColorConvertFloat4ToU32(col), rot, num_segments, thickness);
	}
	return 0;
}

static int
dlAddEllipseFilled(lua_State* L) {
	ImVec2 center = { 0.0f, 0.0f };
	float radius_x = 100;
	float radius_y = 100;
	ImVec4 col = { 1.0f, 1.0f, 1.0f, 1.0f };
	float rot = 0;
	int num_segments = 0;
	ImDrawList* draw_list = ImGui::GetWindowDrawList();
	if (lua_type(L, 1) == LUA_TTABLE && draw_list) {
		center = read_field_vec2(L, "center", center, 1);
		radius_x = (float)read_field_float(L, "radius_x", radius_x, 1);
		radius_y = (float)read_field_float(L, "radius_y", radius_y, 1);
		col = read_field_vec4(L, "col", col, 1);
		rot = (float)read_field_float(L, "rot", rot, 1);
		num_segments = read_field_int(L, "segments", num_segments, 1);
		draw_list->AddEllipseFilled(center, ImVec2(radius_x, radius_y), ImGui::ColorConvertFloat4ToU32(col), rot, num_segments);
	}
	return 0;
}

static int
dlAddText(lua_State* L) {
	ImVec2 pos = { 0.0f, 0.0f };
	ImVec4 col = { 1.0f, 1.0f, 1.0f, 1.0f };
	if (lua_type(L, 1) == LUA_TTABLE) {
		pos = read_field_vec2(L, "pos", pos, 1);
		col = read_field_vec4(L, "col", col, 1);
		const char *text = read_field_string(L, "text", NULL, 1);
		const char *type = read_field_string(L, "type", NULL, 1);
		ImDrawList* draw_list = ImGui::GetWindowDrawList();
		if (type && std::string(type) == std::string("foreground"))
			draw_list = ImGui::GetForegroundDrawList();
		if (draw_list)
			draw_list->AddText(pos, ImGui::ColorConvertFloat4ToU32(col), text);
	}
	return 0;
}

static int 
dlAddBezierCubic(lua_State* L) {
	ImVec2 p1 = { 0.0f, 0.0f };
	ImVec2 p2 = { 0.0f, 0.0f };
	ImVec2 p3 = { 0.0f, 0.0f };
	ImVec2 p4 = { 0.0f, 0.0f };
	ImVec4 col = { 1.0f, 1.0f, 1.0f, 1.0f };
	int num_segments = 0;
	float thickness = 1;
	ImDrawList* draw_list = ImGui::GetWindowDrawList();
	if (lua_type(L, 1) == LUA_TTABLE && draw_list) {
		p1 = read_field_vec2(L, "p1", p1, 1);
		p2 = read_field_vec2(L, "p2", p2, 1);
		p3 = read_field_vec2(L, "p3", p3, 1);
		p4 = read_field_vec2(L, "p4", p3, 1);
		col = read_field_vec4(L, "col", col, 1);
		num_segments = read_field_int(L, "segments", num_segments, 1);
		thickness = (float)read_field_float(L, "thickness", thickness, 1);
		draw_list->AddBezierCubic(p1, p2, p3, p4, ImGui::ColorConvertFloat4ToU32(col), thickness, num_segments);
	}
	return 0;
}

static int 
dlAddBezierQuadratic(lua_State* L) {
	ImVec2 p1 = { 0.0f, 0.0f };
	ImVec2 p2 = { 0.0f, 0.0f };
	ImVec2 p3 = { 0.0f, 0.0f };
	ImVec4 col = { 1.0f, 1.0f, 1.0f, 1.0f };
	int num_segments = 0;
	float thickness = 1;
	ImDrawList* draw_list = ImGui::GetWindowDrawList();
	if (lua_type(L, 1) == LUA_TTABLE && draw_list) {
		p1 = read_field_vec2(L, "p1", p1, 1);
		p2 = read_field_vec2(L, "p2", p2, 1);
		p3 = read_field_vec2(L, "p3", p3, 1);
		col = read_field_vec4(L, "col", col, 1);
		num_segments = read_field_int(L, "segments", num_segments, 1);
		thickness = (float)read_field_float(L, "thickness", thickness, 1);
		draw_list->AddBezierQuadratic(p1, p2, p3, ImGui::ColorConvertFloat4ToU32(col), thickness, num_segments);
	}
	return 0;
}

static int dlBeginColumns(lua_State* L) {
	const char* label = luaL_checkstring(L, 1);
	int count = (int)luaL_checkinteger(L, 2);
	ImGui::BeginColumns(label, count);
	return 0;
}

static int dlSetColumnWidth(lua_State* L) {
	int index = (int)luaL_checkinteger(L, 1);
	float width = (float)luaL_checknumber(L, 2);
	ImGui::SetColumnWidth(index, width);
	return 0;
}

static int dlEndColumns(lua_State* L) {
	ImGui::EndColumns();
	return 0;
}

static int dlGetTableColumnWidth(lua_State* L) {
	int column_n = (int)luaL_checkinteger(L, 1);
	ImGuiContext* g = ImGui::GetCurrentContext();
	if (!g) return 0;
	ImGuiTable* table = g->CurrentTable;
	if (!table) return 0;
    IM_ASSERT(column_n >= 0 && column_n < table->ColumnsCount);
	ImGuiTableColumn* column_0 = &table->Columns[column_n];
	lua_pushnumber(L, column_0->WidthRequest);
	return 1;
}

static int dlSetTableColumnWidth(lua_State* L) {
	int column_n = (int)luaL_checkinteger(L, 1);
	float width = (float)luaL_checknumber(L, 2);
	ImGui::TableSetColumnWidth(column_n, width);
	return 0;
}

static int dlTableSetColumnWidthAutoSingle(lua_State* L) {
	int column_n = (int)luaL_checkinteger(L, 1);
	ImGuiContext* g = ImGui::GetCurrentContext();
	if (g && g->CurrentTable) {
		IM_ASSERT(column_n >= 0 && column_n < g->CurrentTable->ColumnsCount);
		ImGui::TableSetColumnWidthAutoSingle(g->CurrentTable, column_n);
	}
	return 0;
}

static int dlTableSetColumnWidthAutoAll(lua_State* L) {
	ImGuiContext* g = ImGui::GetCurrentContext();
	if (g && g->CurrentTable) 
		ImGui::TableSetColumnWidthAutoAll(g->CurrentTable);
	return 0;
}

void init_draw_list(lua_State* L) {
	luaL_Reg draw_list[] = {
		{ "PushClipRect", dlPushClipRect },
		{ "PopClipRect", dlPopClipRect },
		{ "GetClipRectMin", dlGetClipRectMin },
		{ "GetClipRectMax", dlGetClipRectMax },
		{ "AddLine", dlAddLine },
		{ "AddRect", dlAddRect },
		{ "AddRectFilled", dlAddRectFilled },
		{ "AddRectFilledMultiColor", dlAddRectFilledMultiColor },
		{ "AddQuad", dlAddQuad },
		{ "AddQuadFilled", dlAddQuadFilled },
		{ "AddTriangle", dlAddTriangle },
		{ "AddTriangleFilled", dlAddTriangleFilled },
		{ "AddCircle", dlAddCircle },
		{ "AddCircleFilled", dlAddCircleFilled },
		{ "AddNgon", dlAddNgon },
		{ "AddNgonFilled", dlAddNgonFilled },
		{ "AddEllipse", dlAddEllipse },
		{ "AddEllipseFilled", dlAddEllipseFilled },
		{ "AddText", dlAddText },
		{ "AddBezierCubic", dlAddBezierCubic },
		{ "AddBezierQuadratic", dlAddBezierQuadratic },
		{ "BeginColumns", dlBeginColumns },
		{ "SetColumnWidth", dlSetColumnWidth },
		{ "EndColumns", dlEndColumns },
		{ "GetTableColumnWidth", dlGetTableColumnWidth },
		{ "SetTableColumnWidth", dlSetTableColumnWidth },
		{ "TableSetColumnWidthAutoSingle", dlTableSetColumnWidthAutoSingle },
		{ "TableSetColumnWidthAutoAll", dlTableSetColumnWidthAutoAll },
		{ NULL, NULL },
	};
	luaL_newlib(L, draw_list);
	lua_setfield(L, -2, "draw_list");
}