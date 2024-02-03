#include "ImTextColorful.h"
#include <stack>

namespace imguilua {
		
	using std::string;
	using std::vector;
	using std::stack;

	ImU32 ImTextColorful::SplitColorDot(string & Colorstring) {
		ImVec4 ColorValue;

		size_t firstDot = 0, secondDot = 0, thirdDot = 0;
		firstDot = Colorstring.find(',', 0);
		if (firstDot != string::npos)
			secondDot = Colorstring.find(',', firstDot + 1);
		if (secondDot != string::npos)
			thirdDot = Colorstring.find(',', secondDot + 1);
		if (thirdDot != string::npos) {
			ColorValue.x = std::stoi(string(Colorstring.begin(), Colorstring.begin() + firstDot)) / 255.0f;
			ColorValue.y = std::stoi(string(Colorstring.begin() + firstDot + 1, Colorstring.begin() + secondDot)) / 255.0f;
			ColorValue.z = std::stoi(string(Colorstring.begin() + secondDot + 1, Colorstring.begin() + thirdDot)) / 255.0f;
			ColorValue.w = std::stoi(string(Colorstring.begin() + thirdDot + 1, Colorstring.end())) / 255.0f;
		}

		return ImGui::ColorConvertFloat4ToU32(ColorValue);
	}

	void ImTextColorful::SplitColorfulString(vector<FColorStruct>& ColorStructArr, string InContent, ImVec4 InDefaultColor) {
		ColorStructArr.clear();
		ImU32 DefaultColor = ImGui::ColorConvertFloat4ToU32(InDefaultColor);

		while(!ColorStack.empty()) ColorStack.pop(); //如果 ColorStack 没有被置空证明输入的Content出错

		if (InContent.length() == 0)
			return;

		size_t startindex = 0;
		startindex = InContent.find("<color=", startindex);
		size_t LeftIdenity_RightBracketindex = InContent.find(">", startindex + 7);
		size_t RightIdenityBracketindex = -1;
		string colorstring = "";
		if (startindex != string::npos && LeftIdenity_RightBracketindex != string::npos) {
			colorstring.assign(InContent.begin() + startindex + 7, InContent.begin() + LeftIdenity_RightBracketindex);
			ColorStack.push(SplitColorDot(colorstring));
		}
		else {
			ColorStructArr.push_back({ DefaultColor,InContent });  // 没有 检测到 HTML 
			return;
		}

		if (startindex != 0) {
			ColorStructArr.push_back({ DefaultColor,string(InContent.begin(),InContent.begin() + startindex) });
		}

		size_t lastindex = LeftIdenity_RightBracketindex + 1;
		string TextValue = "";

		while (!ColorStack.empty() || startindex != string::npos) {

			if (ColorStack.empty()) { //代表 栈为空 中间存在一段不需要染色的 区域
				startindex = InContent.find("<color=", lastindex);
				if (startindex == string::npos) return;
				TextValue.assign(InContent.begin() + lastindex, InContent.begin() + startindex);
				ColorStructArr.push_back({ DefaultColor,TextValue });
				LeftIdenity_RightBracketindex = InContent.find(">", lastindex + 7);
				if (LeftIdenity_RightBracketindex != string::npos) {
					colorstring.assign(InContent.begin() + startindex + 7, InContent.begin() + LeftIdenity_RightBracketindex);
					ColorStack.push(SplitColorDot(colorstring));
					lastindex = LeftIdenity_RightBracketindex + 1;
				}
				else {
					return;
				}
			}
			else {
				ImU32 ColorActive = ColorStack.top();
				RightIdenityBracketindex = InContent.find("</>", lastindex);
				startindex = InContent.find("<color=", lastindex);

				if (RightIdenityBracketindex == string::npos) return; // 不可能找不到 </> 否则无法中止
				if (startindex == string::npos) { // 即只有 RightIdenityBracketindex
					TextValue.assign(InContent.begin() + lastindex, InContent.begin() + RightIdenityBracketindex);
					ColorStructArr.push_back({ ColorActive,TextValue });
					ColorStack.pop(); // 遇到 B 类型结尾必定出栈
					lastindex = RightIdenityBracketindex + 3;
				}

				else if (startindex < RightIdenityBracketindex) { // 如果没有遇到 </> 而是又遇到了一个 <color=
					TextValue.assign(InContent.begin() + lastindex, InContent.begin() + startindex);
					ColorStructArr.push_back({ ColorActive,TextValue });
					LeftIdenity_RightBracketindex = InContent.find(">", startindex + 7);
					if (startindex != string::npos && LeftIdenity_RightBracketindex != string::npos) {
						colorstring.assign(InContent.begin() + startindex + 7, InContent.begin() + LeftIdenity_RightBracketindex);
						ColorStack.push(SplitColorDot(colorstring));
					}
					lastindex = LeftIdenity_RightBracketindex + 1;
				}
				else { // 先遇到了一个 </> 而非 <color= 出栈
					TextValue.assign(InContent.begin() + lastindex, InContent.begin() + RightIdenityBracketindex);
					ColorStructArr.push_back({ ColorActive,TextValue });
					ColorStack.pop();
					lastindex = RightIdenityBracketindex + 3;
				}
			}
		}

		if (lastindex >= InContent.length()) {
			return;
		}
		else {
			TextValue.assign(InContent.begin() + lastindex, InContent.end());  // 插入最后一个元素
			ColorStructArr.push_back({ DefaultColor,TextValue });
		}
	}

	void ImTextColorful::DrawLine(const std::string& InContent, ImVec2 DrawPosition, bool DisableFlag) {
		vector<FColorStruct> ColorStructArr;
		SplitColorfulString(ColorStructArr, InContent, DefaultColor);

		auto DrawList = ImGui::GetWindowDrawList();
		string HasDraw = "";
		ImVec2 stringDrawPosition = DrawPosition;

		for (auto item : ColorStructArr) {
			auto textSize = ImGui::GetFont()->CalcTextSizeA(ImGui::GetFontSize(), FLT_MAX, -1.0f, HasDraw.c_str(), nullptr, nullptr);
			stringDrawPosition.x += textSize.x; //向右边偏移

			auto drawcolor = item.InColor;
			if (DisableFlag) {
				uint32_t alpha = (item.InColor >> IM_COL32_A_SHIFT) / 2 ;
				item.InColor = item.InColor & (0x00FFFFFF) | (alpha << IM_COL32_A_SHIFT) ;
			}
			DrawList->AddText(stringDrawPosition, item.InColor, item.ColorfulString.c_str());
			HasDraw = item.ColorfulString;
		}
	}


}