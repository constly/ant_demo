#include <lua.hpp>
#include "text_editor/ImTextEditor.h"

extern "C"
int luaopen_imgui_extend(lua_State *L) {
    luaL_Reg lib[] = {
        // { "Sequencer", wSequencer },
        // { "SimpleSequencer", wSimpleSequencer },
        // { "DirectionalArrow", zDirectionalArrow },
        // { "PropertyLabel", wPropertyLabel },
        { NULL, NULL },
    };
    luaL_newlib(L, lib);
    return 1;
}
