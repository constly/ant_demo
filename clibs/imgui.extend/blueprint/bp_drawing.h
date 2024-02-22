# pragma once
#include "imgui.h"


namespace imguilua {

	enum class EPinType {
		Flow,
		Bool,
		Int,
		Float,
		String,
		Object,
		Function,
		Delegate,
	};

	enum class EPinKind {
		Output,
		Input,
	};

	enum class ENodeType {
		Blueprint,
		Simple,
		Tree,
		Comment,
		Houdini,
	};

	enum class IconType : ImU32 { Flow, Circle, Square, Grid, RoundSquare, Diamond };

	struct Blueprint {
	public:
		static void DrawPinIcon(EPinType pin_type, bool connected, int alpha, float scale);

	private:
		static void DrawIcon(ImDrawList* drawList, const ImVec2& a, const ImVec2& b, IconType type, bool filled, ImU32 color, ImU32 innerColor);
		static ImColor GetIconColor(EPinType InType);
		static void Icon(const ImVec2& size, IconType type, bool filled, const ImVec4& color = ImVec4(1, 1, 1, 1), const ImVec4& innerColor = ImVec4(0, 0, 0, 0));
	};

	
} 
