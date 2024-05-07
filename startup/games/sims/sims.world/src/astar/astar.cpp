#include "astar.h"
#include "../world/world.h"


void AStar::Run() {
	auto& start = param.start;
	auto& dest = param.dest;

	Region* start_region = world->GetRegionByPos(start.x, start.y, start.z);
	Region* end_region = world->GetRegionByPos(dest.x, dest.y, dest.z);
	EGridType grid_data = end_region->GetGridData(dest.x, dest.y, dest.z);
}