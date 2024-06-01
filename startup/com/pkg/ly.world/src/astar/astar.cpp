#include "astar.h"
#include "../world/world.h"
#include <algorithm>

bool AStar::Run() {
	auto& start = param.start;
	auto& dest = param.dest;

	if (start == dest) 
		return true;
	
	//Region* start_region = world->GetRegionByPos(start.x, start.y, start.z);
	//Region* end_region = world->GetRegionByPos(dest.x, dest.y, dest.z);
	//EGridType grid_data = end_region->GetGridData(dest.x, dest.y, dest.z);

	openList.clear();
	closeList.clear();
	openList.push_back(start);	
	while (openList.size() > 0) {
		Point p = openList[0];
		closeList.insert(p);

		auto& arounds = GetAroundGrids(p); 
		for (auto& around : arounds) {
			// 检查是否在开启列表中
			Point* find = nullptr;
			for(auto& o : openList) {
				if (o.ID == around.ID) {
					find = &o;
					break;
				}
			}

			// 如果找到了终点
			if (around.ID == dest.ID) {
				GenerateFinalPath();
				CleanData();
				return true;
			}
			int32_t delta = (std::abs(around.x - p.x) + std::abs(around.y - p.y) + std::abs(around.z - p.z));
			if (delta == 0)
				continue;

			int32_t G = (delta == 1 ? 10 : 14) + p.G;

			// 如果已经在开启列表，且之前的寻路代价更低，则忽略
			if (find && find->G < G) 
				continue;
			
			if (find) {
				// 更新最新G值
				find->G = G;
			} else {
				// 加入到开启列表
				around.G = G;
				around.H = (std::abs(around.x - dest.x) + std::abs(around.y - dest.y) + std::abs(around.z - dest.z)) * 10;
				openList.push_back(around);
			}
			parentList[around] = p;
		}

		openList.erase(openList.begin());
		std::sort(openList.begin(), openList.end(), [](const Point& a, const Point& b) {return a.GetF() < b.GetF();});
	}
	CleanData();
	return false;
}

std::vector<Point>& AStar::GetAroundGrids(const Point& point) {
	static std::vector<Point> tempPoints;
	tempPoints.clear();

	int32_t xMin = -1, zMin = -1, yMin = -1;
	int32_t xMax = 1, zMax = 1, yMax = 1;
	for (int x = xMin; x <= xMax; ++x) {
		for (int y = yMin; y <= yMax; ++y) {
			for (int z = zMin; z <= zMax; ++z) {
				if (x == 0 && y == 0 && z == 0)
					continue;
				
				Point temp(point.x + x, point.y + y, point.z + z);

				// 忽略在 关闭列表中的
				if (closeList.find(temp) != closeList.end())
					continue;

				Region* region = world->GetRegionByPos(temp.x, temp.y, temp.z);
				if (!region)
					continue;
				
				int32_t pos_x = temp.x - region->start_x;
				int32_t pos_y = temp.y - region->start_y;
				int32_t pos_z = temp.z - region->start_z;
				int index = region->OffsetToIndex(pos_x, pos_y, pos_z);
				EGridType gridType = region->grids[index];

				// 如果地形可以走，则加入到开放列表
				if (((int32_t)gridType & (int32_t)EGridType::Ground) != 0) {
					tempPoints.push_back(temp);
				}
			}
		}
	}
	return tempPoints;
}

void AStar::CleanData() {
	openList.clear();
	closeList.clear();
	parentList.clear();
}

void AStar::GenerateFinalPath() {
	param.path.clear();
	param.path.push_back(param.dest);
	if (openList.size() > 0) {
		auto first = openList[0];
		param.path.push_back(first);
		while(true) {
			auto it = parentList.find(first);
			if (it != parentList.end()) {
				first = it->second;
				if (first.ID == param.start.ID)
					break;
				param.path.push_back(first);
			} else {
				break;
			}
		}
	}
	param.path.push_back(param.start);
}