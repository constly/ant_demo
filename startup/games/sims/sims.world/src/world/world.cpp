#include "world.h"

World::World() {
	astar.world = this;
}

World::~World() { 
	Destroy(); 
}

void World::Destroy() {
	Reset();
}

void World::Reset() {
	for(auto& one : Regions) {
		delete one.second;
	}
	Regions.clear();
	dirtyList.clear();
}

void World::SetRegionSize(int region_size_x, int region_size_y, int region_size_z) {
	this->region_size_x = region_size_x;
	this->region_size_y = region_size_y;
	this->region_size_z = region_size_z;
}

void World::Update() {
	for(auto& region : dirtyList) {
		region->CleanDirty();
		region->Refresh();
		if (region->IsEmpty()) {
			DestroyRegion(region->regionId);
		}
	}
	dirtyList.clear();
}

void World::SetGridDataInner(int start_x, int start_y, int start_z, int size_x, int size_y, int size_z, EGridType gridType, bool autoCreateRegion) {
	Region* last_region = nullptr;
	for (int y = -1; y <= size_y; ++y) {
		int pos_y = y + start_y;
		for (int x = -1; x <= size_x; ++x) {
			int pos_x = x + start_x;
			for (int z = -1; z <= size_z; ++z) {
				int pos_z = z + start_z;
				bool isEdge = x == -1 || z == -1 || y == -1 || x == size_x || z == size_z || y == size_y;
				Region* region = autoCreateRegion ? GetOrCreateRegionByPos(pos_x, pos_y, pos_z) : GetRegionByPos(pos_x, pos_y, pos_z);
				if (!region)
					continue;

				if (isEdge) {
					// 保证生成八方向边缘格子，边缘格子默认无数据
					auto type = region->GetGridData(pos_x, pos_y, pos_z);
					if (type == EGridType::None || type > EGridType::Need_Refresh)
						region->SetGridData(pos_x, pos_y, pos_z, EGridType::Need_Refresh);
				} else {
					region->SetGridData(pos_x, pos_y, pos_z, gridType);
				}
				if (last_region != region) {
					last_region = region;
					dirtyList.insert(region);
				}
			}
		}
	}
}

void World::SetGridData(int start_x, int start_y, int start_z, int size_x, int size_y, int size_z, EGridType gridType) {
	SetGridDataInner(start_x, start_y, start_z, size_x, size_y, size_z, gridType, true);
}

void World::ClearGridData(int start_x, int start_y, int start_z, int size_x, int size_y, int size_z) {
	SetGridDataInner(start_x, start_y, start_z, size_x, size_y, size_z, EGridType::None, false);
}

EGridType World::GetGridData(int pos_x, int pos_y, int pos_z) {
	Region* region = GetRegionByPos(pos_x, pos_y, pos_z);
	return region ? region->GetGridData(pos_x, pos_y, pos_z) : EGridType::None;
}

int64_t World::GetRegionId(int pos_x, int pos_y, int pos_z) { 
	// 区域坐标限制
	#define REGION_LIMIT 1000000
	size_t x = (int)floor((float)pos_x / region_size_x) + REGION_LIMIT;		// 转换为正数 [0,200万]
	size_t y = (int)floor((float)pos_y / region_size_y) + REGION_LIMIT;
	size_t z = (int)floor((float)pos_z / region_size_z) + REGION_LIMIT;
	return (x << 42) | (y << 21) | z;
}

Region* World::GetRegionById(int64_t regionId) {
	auto it = Regions.find(regionId);
	return it != Regions.end() ? it->second : nullptr;
}

Region* World::GetRegionByPos(int pos_x, int pos_y, int pos_z) {
	int64_t id = GetRegionId(pos_x, pos_y, pos_z);
	return GetRegionById(id);
}

int World::GetGroundHeight(int pos_x, int pos_y, int pos_z, int checkRange) {
	EGridType Type = GetGridData(pos_x, pos_y, pos_z);
	if (Type == EGridType::Ground || Type == EGridType::Water)
		return pos_z;

	if ((Type < EGridType::Need_Refresh) && (Type != EGridType::None)) {
		for (int i = 1; i <= checkRange; ++i) {
			EGridType Type = GetGridData(pos_x, pos_y + i, pos_z);
			if (Type == EGridType::Ground || Type == EGridType::Water)
				return pos_y + i;
		}
	} else {
		for (int i = 1; i <= checkRange; ++i) {
			int Type = (int)GetGridData(pos_x, pos_y - i, pos_z);
			if ((Type > (int)EGridType::None) && (Type < (int)EGridType::Need_Refresh))
				return pos_y - i;
			if ((Type & (int)EGridType::Ground) || (Type & (int)EGridType::Water))
				return pos_y - i;
		}
	}
	return INVALID_NUM;
}

Region* World::GetOrCreateRegionByPos(int pos_x, int pos_y, int pos_z) {
	int64_t id = GetRegionId(pos_x, pos_y, pos_z);
	Region* region = GetRegionById(id);
	if (region) 
		return region;

	int x = (int)floor((float)pos_x / region_size_x) * region_size_x;
	int y = (int)floor((float)pos_y / region_size_y) * region_size_y;
	int z = (int)floor((float)pos_z / region_size_z) * region_size_z;
	region = new Region();
	region->regionId = id;
	region->world = this;
	region->SetStart(x, y, z);
	region->SetSize(region_size_x, region_size_y, region_size_z);
	Regions.insert(std::make_pair(region->regionId, region));
	return region;
}

void World::DestroyRegion(int64_t regionId) {
	auto it = Regions.find(regionId);
	if (it != Regions.end()) {
		delete it->second;
		Regions.erase(it);
	}
}