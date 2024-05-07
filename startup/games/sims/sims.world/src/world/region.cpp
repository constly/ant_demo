#include "region.h"
#include "world.h"

void Region::SetSize(int size_x, int size_y, int size_z) {
	assert(grids.size() == 0);
	this->size_x = size_x;
	this->size_y = size_y;
	this->size_z = size_z;
	int size = size_x * size_y * size_z;
	grids.resize(size, EGridType::None);
}

void Region::SetStart(int x, int y, int z) {
	this->start_x = x;
	this->start_y = y;
	this->start_z = z;
}

void Region::SetGridData(int pos_x, int pos_y, int pos_z, EGridType gridData) {
	isDirty = true;
	pos_x = pos_x - start_x;
	pos_y = pos_y - start_y;
	pos_z = pos_z - start_z;
	int index = OffsetToIndex(pos_x, pos_y, pos_z);
	assert(index < grids.size());
	grids[index] = gridData;
}

EGridType Region::GetGridData(int pos_x, int pos_y, int pos_z) {
	pos_x = pos_x - start_x;
	pos_y = pos_y - start_y;
	pos_z = pos_z - start_z;
	int index = OffsetToIndex(pos_x, pos_y, pos_z);
	assert(index < grids.size());
	return grids[index];
}

bool Region::IsEmpty() {
	return isEmpty;
}

void Region::Refresh() {
	int validGrid = 0;
	for (int y = 0; y < size_y; ++y) {
		for (int x = 0; x < size_x; ++x) {
			for (int z = 0; z < size_z; ++z) {
				int index = OffsetToIndex(x, y, z);
				EGridType type = grids[index];
				// 如果格子类型是动态生成的，此时需要重新刷新
				if (type >= EGridType::Need_Refresh) {		
					RefreshGrid(x, y, z, index);
				}
				if (type != EGridType::None)
					++validGrid;
			}
		}
	}
	isEmpty = validGrid == 0;
}

void Region::RefreshGrid(int offset_x, int offset_y, int offset_z, int index) {
	// 上下 左右 前后 6个方向
	const int8_t offset[] = {
		0, 1, 0, 
		0, -1, 0,
		0, 0, 1,
		0, 0, -1,
		1, 0, 0,
		-1, 0, 0,
	};
	int data = (int)grids[index];
	for (int i = 0; i < 18; i += 3) {
		int x = offset[i], y = offset[i + 1], z = offset[i + 2];
		int p_x = offset_x + x;
		int p_y = offset_y + y;
		int p_z = offset_z + z;
		EGridType gridType = EGridType::None;
		if (p_x >= 0 && p_y >= 0 && p_z >= 0 && p_x < size_x && p_y < size_y && p_z < size_z) {
			gridType = grids[OffsetToIndex(p_x, p_y, p_z)];
		} else {
			gridType = world->GetGridData(p_x + start_x, p_y + start_y, p_z + start_z);
		}
		switch (gridType) {
			case EGridType::Under_Object: 
				if (y == 1)
					data |= (int)EGridType::Ceiling;
				break;
			case EGridType::Under_Ground:
			case EGridType::Under_StandableObject: 
				if (y == -1)
					data |= (int)EGridType::Ground;
				else if (y == 1)
					data |= (int)EGridType::Ceiling;
				else 
					data |= (int)EGridType::Wall;
				break;
			case EGridType::Under_Water:
				if (y == -1)
					data |= (int)EGridType::Water;
				break;
			default: break;
		}
	}
	data &= (~(int)EGridType::Need_Refresh);
	grids[index] = (EGridType)data;
}

int Region::OffsetToIndex(int offset_x, int offset_y, int offset_z) {
	return size_x * size_z * offset_y + offset_x * size_z + offset_z;
}