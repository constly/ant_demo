#pragma once
#include <vector>
#include <assert.h> 

enum class EGridType : uint8_t {
	None = 0,		// 空中

	Under_Ground	= 1,		// 地形中
	Under_Water 	= 2,		// 水中
	Under_Object 	= 3,		// 不可以站立物件内部 （比如场景的某个格子是个花瓶）
	Under_StandableObject = 4,	// 可站立物件内部（比如场景地块，或者场景中有个可以站立的箱子）

	Need_Refresh 	= 7,			// 标记为需要刷新，且以下类型为动态生成
	Ground		= 1 << 3,			// 地表面 （Under_StandableObject || Under_Ground 上面格子）
	Water		= 1 << 4,			// 水表面
	Wall 		= 1 << 5,			// 墙表面 （Under_StandableObject || Under_Ground 前后左右格子）
	Ceiling 	= 1 << 6,			// 天花板 （Under_Object || Under_StandableObject || Under_Ground 下面格子）
};

struct Point {
	int x = 0;
	int y = 0;
	int z = 0;
};

// 寻路类型
enum class EWalkType : int8_t {
	Ground = 1, 	// 可以在地表面走
	Sky = 2,		// 可以在空中走
	Water = 4,		// 可以在水表面走
	Wall = 8,		// 可以在墙表面走
};

// 无效数值
#define INVALID_NUM -1000000000