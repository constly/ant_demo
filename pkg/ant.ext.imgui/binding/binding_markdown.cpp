#include "binding_utils.h"
#include "../markdown/imgui_markdown.h"
#include <string>

static int Markdown(lua_State* L) {
	std::string markdown_ = luaL_checkstring(L, 1);

    ImGui::MarkdownConfig mdConfig;
	// mdConfig.linkCallback =         LinkCallback;
    // mdConfig.tooltipCallback =      NULL;
    // mdConfig.imageCallback =        ImageCallback;
    // mdConfig.linkIcon =             ICON_FA_LINK;
    // mdConfig.headingFormats[0] =    { H1, true };
    // mdConfig.headingFormats[1] =    { H2, true };
    // mdConfig.headingFormats[2] =    { H3, false };
    // mdConfig.userData =             NULL;
    // mdConfig.formatCallback =       ExampleMarkdownFormatCallback;
	if (lua_type(L, 2) == LUA_TTABLE) {
		// config参数
	}

    ImGui::Markdown( markdown_.c_str(), markdown_.length(), mdConfig );
	return 0;
}

void init_markdown(lua_State* L) {
	lua_pushcfunction(L, Markdown);
	lua_setfield(L, -2, "Markdown");
}