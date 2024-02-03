#include "imgui.h"
#include <string>
#include <vector>
#include <stack>

namespace imguilua {

	struct ImTextColorful {
	public:
		struct FColorStruct {
			ImU32 InColor;
			std::string ColorfulString;
		};
		ImTextColorful() :DefaultColor(ImVec4(1.0f, 1.0f, 1.0f, 1.f)) {}
		ImTextColorful(ImVec4 InColor) :DefaultColor(InColor) {}

		void DrawLine(const std::string& InContent, ImVec2 DrawPosition, bool DisableFlag = false);


	private:
		ImU32 SplitColorDot(std::string& Colorstring);
		void SplitColorfulString(std::vector<FColorStruct>& ColorStructArr, std::string InContent, ImVec4 InDefaultColor);

	private:
		std::stack<ImU32> ColorStack;
		ImVec4 DefaultColor;
	};

}