#pragma once
#include <map>
#include <set>
#include "../define.h"

struct World;

// 寻路参数
struct AStarParam {
	// 寻路起点
	Point start;

	// 寻路终点
	Point dest;

	// 身体大小
	int bodySize = 0;

	// 寻路类型
	EWalkType walkType = EWalkType::Ground;

	// 路线
	std::vector<Point> path;
};


struct AStar {
public:
	void Start(World* world, const AStarParam& param);

	void Run();

public:
	World* world = nullptr;
	AStarParam param;

private:
	const std::vector<Point>& GetAroundGrids(const Point& point);
};