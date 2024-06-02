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

	CleanCache();
	openList.push_back(start);	
	if (open_debug)
		printf("add to openlist: (%d,%d,%d)\n", start.x, start.y, start.z);
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
				CleanCache();
				return true;
			}
			int32_t delta = (std::abs(around.x - p.x) + std::abs(around.y - p.y) + std::abs(around.z - p.z));
			if (delta == 0)
				continue;

			int32_t G = p.G + (delta * 4) + 6;

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
				if (open_debug)
					printf("add to openlist: (%d,%d,%d)\n", around.x, around.y, around.z);
				openList.push_back(around);
			}
			parentList[around] = p;
		}

		openList.erase(openList.begin());
		std::sort(openList.begin(), openList.end(), [](const Point& a, const Point& b) {return a.GetF() < b.GetF();});
	}
	CleanCache();
	return false;
}

std::vector<Point>& AStar::GetAroundGrids(const Point& point) {
	static std::vector<Point> tempPoints;
	tempPoints.clear();

	int32_t xMin = -1, yMin = -1, zMin = -1;
	int32_t xMax = 1, yMax = 1, zMax = 1;

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

				// 如果不能走，忽略
				if (!IsWalkable(temp))
					continue;

				int delta = std::abs(x) + std::abs(y) + std::abs(z);
				if (delta > 1) {	// 如果是对角格子，判断周围是否有不可以走的
					int temp_min_x = std::min(x, 0);
					int temp_min_y = std::min(y, 0);
					int temp_min_z = std::min(z, 0);
					int temp_max_x = std::max(x, 0);
					int temp_max_y = std::max(y, 0);
					int temp_max_z = std::max(z, 0);
					bool valid = true;
					if (temp_max_y == 1) {	// 如果是向上走，最上面一行不能有格子
						for (int _x = temp_min_x; _x <= temp_max_x; ++_x) {
							for (int _z = temp_min_z; _z <= temp_max_z; ++_z) {
								Point p(_x + point.x, temp_max_y + point.y, _z + point.z);
								if (p.ID == temp.ID)
									continue;
								if (valid && !IsNeighborWalkable(p)) {
									valid = false;
									break;
								}
							}
						}
					} else { // 如果是平着走或者向下走，平着这行不能有格子
						for (int _x = temp_min_x; _x <= temp_max_x; ++_x) {
							for (int _z = temp_min_z; _z <= temp_max_z; ++_z) {
								if (_x == 0 && _z == 0)
									continue;
								Point p(_x + point.x, point.y, _z + point.z);
								if (p.ID == temp.ID)
									continue;

								if (valid && !IsNeighborWalkable(p)) {
									valid = false;
									break;
								}
							}
						}
					} 
					if (valid) {
						tempPoints.push_back(temp);
					}
						
				} else {
					// 如果地形可以走，则加入到开放列表
					tempPoints.push_back(temp);
				}
			}
		}
	}
	return tempPoints;
}

bool AStar::IsWalkable(const Point& point) {
	auto it = cacheWalkable.find(point);
	if (it != cacheWalkable.end())
		return it->second;

	EGridType gridType = world->GetGridData(point.x, point.y, point.z);
	bool value = ((int32_t)gridType & (int32_t)EGridType::Ground) != 0;
	cacheWalkable[point] = value;
	if (open_debug)
		printf("check walkable: (%d,%d,%d) -> %d\n", point.x, point.y, point.z, value ? 1 : 0);
	return value;
}

bool AStar::IsNeighborWalkable(const Point& point) {
	auto it = cacheNeighborWalkable.find(point);
	if (it != cacheNeighborWalkable.end())
		return it->second;

	EGridType gridType = world->GetGridData(point.x, point.y, point.z);
	bool value = true;
	if (gridType != EGridType::None) {
		value = ((int32_t)gridType & (int32_t)EGridType::Ground) != 0;
	}
	cacheNeighborWalkable[point] = value;
	if (open_debug)
		printf("check neighbor walkable: (%d,%d,%d) -> %d\n", point.x, point.y, point.z, value ? 1 : 0);
	return value;
}

void AStar::CleanCache() {
	openList.clear();
	closeList.clear();
	parentList.clear();
	cacheWalkable.clear();
	cacheNeighborWalkable.clear();
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