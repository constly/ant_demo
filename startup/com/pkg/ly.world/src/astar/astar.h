#pragma once
#include <map>
#include <set>
#include "../define.h"

struct World;

struct Point {
	uint64_t ID = 0;
	int x = 0;
	int y = 0;
	int z = 0;
	
	int G = 0;
	int H = 0;

	Point() {}
	Point(int _x, int _y, int _z) {
		x = _x;
		y = _y;
		z = _z;
		
		// 将坐标转换为 [0, 200万]
		ID = (((int64_t)_x + POS_RANGE) << 42) | (((int64_t)_y + POS_RANGE) << 21) | (_z + POS_RANGE);
	}

    bool operator<(const Point& rhs) const {
        return ID < rhs.ID; 
    }

	bool operator==(const Point& rhs) const {
        return ID == rhs.ID; 
    }

	int GetF() const { return G + H;}
};


// 寻路参数
struct AStarParam {
public:
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
	bool Run();

public:
	World* world = nullptr;
	AStarParam param;

private:
	// 清理缓存数据
	void CleanCache();

	// 得到相邻格子
	std::vector<Point>& GetAroundGrids(const Point& point);

	// 生成最终路径
	void GenerateFinalPath();

	// 是否可以通行
	bool IsWalkable(const Point& point);

	// 邻居是否可以通行
	bool IsNeighborWalkable(const Point& point);

private:
	std::vector<Point> openList;
	std::set<Point> closeList;
	std::map<Point, Point> parentList;
	std::map<Point, bool> cacheWalkable;
	std::map<Point, bool> cacheNeighborWalkable;
	bool open_debug = false;
};