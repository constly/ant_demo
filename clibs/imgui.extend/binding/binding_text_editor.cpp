#include "../text_editor/ImTextEditor.h"
#include "binding_utils.h"

namespace imguilua::bind::TextEditor {
	using PaletteIndex = imguilua::TextEditor::PaletteIndex;

	// 这个还是定义在C++中，只提供选择接口比较好
	static int SetLanguageDefinition(lua_State* L) {
		auto& editor = bee::lua::checkudata<imguilua::TextEditor>(L, 1);
		if (lua_type(L, 2) == LUA_TTABLE) {
			imguilua::TextEditor::LanguageDefinition langDef;
			std::vector<std::string> keywords = utils::read_field_array_string(L, 2, "keywords");
			for(auto& one : keywords)
				langDef.mKeywords.insert(one);

			auto identifiers = utils::read_field_array_string(L, 2, "identifiers");
			for (auto& k : identifiers) {
				imguilua::TextEditor::Identifier id;
				id.mDeclaration = "Built-in function";
				langDef.mIdentifiers.insert(std::make_pair(std::string(k), id));
			}

			langDef.mCommentStart = utils::read_field_string(L, 2, "commentStart", "--[[");
			langDef.mCommentEnd = utils::read_field_string(L, 2, "commentEnd", "]]");
			langDef.mSingleLineComment = utils::read_field_string(L, 2, "singleLineComment", "--");

			langDef.mCaseSensitive = utils::read_field_bool(L, 2, "caseSensitive", true);
			langDef.mAutoIndentation = utils::read_field_bool(L, 2, "autoIndentation", true);

			langDef.mTokenRegexStrings.push_back(std::make_pair<std::string, PaletteIndex>("[ \\t]*#[ \\t]*[a-zA-Z_]+", PaletteIndex::Preprocessor));
			langDef.mTokenRegexStrings.push_back(std::make_pair<std::string, PaletteIndex>("L?\\\"(\\\\.|[^\\\"])*\\\"", PaletteIndex::String));
			langDef.mTokenRegexStrings.push_back(std::make_pair<std::string, PaletteIndex>("\\'\\\\?[^\\']\\'", PaletteIndex::CharLiteral));
			langDef.mTokenRegexStrings.push_back(std::make_pair<std::string, PaletteIndex>("[+-]?([0-9]+([.][0-9]*)?|[.][0-9]+)([eE][+-]?[0-9]+)?[fF]?", PaletteIndex::Number));
			langDef.mTokenRegexStrings.push_back(std::make_pair<std::string, PaletteIndex>("[+-]?[0-9]+[Uu]?[lL]?[lL]?", PaletteIndex::Number));
			langDef.mTokenRegexStrings.push_back(std::make_pair<std::string, PaletteIndex>("0[0-7]+[Uu]?[lL]?[lL]?", PaletteIndex::Number));
			langDef.mTokenRegexStrings.push_back(std::make_pair<std::string, PaletteIndex>("0[xX][0-9a-fA-F]+[uU]?[lL]?[lL]?", PaletteIndex::Number));
			langDef.mTokenRegexStrings.push_back(std::make_pair<std::string, PaletteIndex>("[a-zA-Z_][a-zA-Z0-9_]*", PaletteIndex::Identifier));
			langDef.mTokenRegexStrings.push_back(std::make_pair<std::string, PaletteIndex>("[\\[\\]\\{\\}\\!\\%\\^\\&\\*\\(\\)\\-\\+\\=\\~\\|\\<\\>\\?\\/\\;\\,\\.]", PaletteIndex::Punctuation));

			langDef.mName = utils::read_field_string(L, 2, "name", "none");

			printf("keywords is: %zd - %s \n", keywords.size(), langDef.mCommentStart.data());
			
			//lang.mKeywords = read_field_
			editor.SetLanguageDefinition(langDef);
		}
		return 0;
	}

	static int SetText(lua_State* L) {
		auto& editor = bee::lua::checkudata<imguilua::TextEditor>(L, 1);
		auto value = luaL_checkstring(L, 2);
		editor.SetText(value);
		return 0;
	}

	static int GetText(lua_State* L) {
		auto& editor = bee::lua::checkudata<imguilua::TextEditor>(L, 1);
		std::string text = editor.GetText();
		lua_pushfstring(L, text.data());
		return 1;
	}

	static int Render(lua_State* L) {
		auto& editor = bee::lua::checkudata<imguilua::TextEditor>(L, 1);
		auto title = luaL_checkstring(L, 2);
		auto sizeX = (float)luaL_checknumber(L, 3);
		auto sizeY = (float)luaL_checknumber(L, 4);
		auto border = (bool)!!lua_toboolean(L, 5);
		editor.Render(title, ImVec2(sizeX, sizeY), border);
		return 0;
	}

	static int SetReadOnly(lua_State* L) {
		auto& editor = bee::lua::checkudata<imguilua::TextEditor>(L, 1);
		auto value = (bool)!!lua_toboolean(L, 2);
		editor.SetReadOnly(value);
		return 0;
	}

	static int IsReadOnly(lua_State* L) {
		auto& editor = bee::lua::checkudata<imguilua::TextEditor>(L, 1);
		lua_pushboolean(L, editor.IsReadOnly());
		return 1;
	}

	static int SetTabSize(lua_State* L) {
		auto& editor = bee::lua::checkudata<imguilua::TextEditor>(L, 1);
		auto size = (int32_t)luaL_checkinteger(L, 2);
		editor.SetTabSize(size);
		return 0;
	}

	static int GetTabSize(lua_State* L) {
		auto& editor = bee::lua::checkudata<imguilua::TextEditor>(L, 1);
		lua_pushinteger(L, editor.GetTabSize());
		return 1;
	}

	static int IsColorizerEnabled(lua_State* L) {
		auto& editor = bee::lua::checkudata<imguilua::TextEditor>(L, 1);
		lua_pushboolean(L, editor.IsColorizerEnabled());
		return 1;
	}

	static int SetColorizerEnable(lua_State* L) {
		auto& editor = bee::lua::checkudata<imguilua::TextEditor>(L, 1);
		auto value = (bool)!!lua_toboolean(L, 2);
		editor.SetColorizerEnable(value);
		return 0;
	}

	static int IsShowingWhitespaces(lua_State* L) {
		auto& editor = bee::lua::checkudata<imguilua::TextEditor>(L, 1);
		lua_pushboolean(L, editor.IsShowingWhitespaces());
		return 1;
	}

	static int SetShowWhitespaces(lua_State* L) {
		auto& editor = bee::lua::checkudata<imguilua::TextEditor>(L, 1);
		auto value = (bool)!!lua_toboolean(L, 2);
		editor.SetShowWhitespaces(value);
		return 0;
	}
	
	

	static void metatable(lua_State* L) {
		static luaL_Reg lib[] = {
			{"SetLanguageDefinition", SetLanguageDefinition},
			{"SetText", SetText},
			{"GetText", GetText},
			{"SetReadOnly", SetReadOnly},
			{"IsReadOnly", IsReadOnly},
			{"SetTabSize", SetTabSize},
			{"GetTabSize", GetTabSize},
			{"IsColorizerEnabled", IsColorizerEnabled},
			{"SetColorizerEnable", SetColorizerEnable},
			{"IsShowingWhitespaces", IsShowingWhitespaces},
			{"SetShowWhitespaces", SetShowWhitespaces},
			{"Render", Render},

			{nullptr, nullptr},
		};
		luaL_newlib(L, lib);
		lua_setfield(L, -2, "__index");
	}

	static int getmetatable(lua_State* L) {
		bee::lua::getmetatable<imguilua::TextEditor>(L);
        return 1;
	}

	static int create(lua_State* L) {
		bee::lua::newudata<imguilua::TextEditor>(L);
		return 1;
	}
}

static int create_texteditor(lua_State* L) {
	return imguilua::bind::TextEditor::create(L);
}

void init_text_editor(lua_State* L) {
	lua_pushcfunction(L, create_texteditor);
	lua_setfield(L, -2, "CreateTextEditor");
}

namespace bee::lua {
	template <>
	struct udata<imguilua::TextEditor> {
		static inline auto name = "imguilua::TextEditor";
		static inline auto metatable = imguilua::bind::TextEditor::metatable;
	};
}