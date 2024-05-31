#include "astar.h"
#include "../world/world.h"


void AStar::Run() {
	auto& start = param.start;
	auto& dest = param.dest;

	Region* start_region = world->GetRegionByPos(start.x, start.y, start.z);
	Region* end_region = world->GetRegionByPos(dest.x, dest.y, dest.z);
	EGridType grid_data = end_region->GetGridData(dest.x, dest.y, dest.z);

	

}

const std::vector<Point>& AStar::GetAroundGrids(const Point& point) {
	static std::vector<Point> tempPoints;
	tempPoints.clear();

	int32_t xMin = -1, zMin = -1, yMin = -1;
	int32_t xMax = 1, zMax = 1, yMax = 1;
	for (int x = xMin; x <= xMax; ++x) {
		for (int y = yMin; y <= yMax; ++y) {
			for (int z = zMin; z <= zMax; ++z) {
				if (x == 0 && y == 0 && z == 0)
					continue;
				
				int32_t px = point.x + x;
				int32_t py = point.y + y;
				int32_t pz = point.z + z;
				Region* region = world->GetRegionByPos(point.x + x, point.y + y, point.z + z);
				if (!region)
					continue;
				
				int32_t pos_x = px - region->start_x;
				int32_t pos_y = py - region->start_y;
				int32_t pos_z = pz - region->start_z;
				int index = region->OffsetToIndex(pos_x, pos_y, pos_z);
				EGridType gridType = region->grids[index];
				if (gridType == EGridType::Ground)
					tempPoints.push_back(Point(px, py, pz));
			}
		}
	}
	return tempPoints;
}