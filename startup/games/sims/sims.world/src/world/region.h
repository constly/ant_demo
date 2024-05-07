#pragma once
#include "../define.h"

struct World;

struct Region {

public:
	// 设置大小
	void SetSize(int size_x, int size_y, int size_z);

	// 设置区域起点
	void SetStart(int x, int y, int z);

	// 设置地形数据
	void SetGridData(int pos_x, int pos_y, int pos_z, EGridType gridData);

	// 得到地形数据
	EGridType GetGridData(int pos_x, int pos_y, int pos_z);

	void CleanDirty() { isDirty = false; }

	// 刷新格子状态
	void Refresh();

	// 是不是空区域
	bool IsEmpty();

	// 将偏移转换为index
	int OffsetToIndex(int offset_x, int offset_y, int offset_z);

private:
	// 刷新某个具体的格子
	void RefreshGrid(int offset_x, int offset_y, int offset_z, int index);

public:
	// 所属world
	World* world = nullptr;

	// 格子数据
	std::vector<EGridType> grids;

	// 区域id
	int64_t regionId = 0;

	// 区域起始点
	int start_x = 0;
	int start_y = 0;
	int start_z = 0;

	// 区域长宽高
	int size_x = 0;
	int size_y = 0;
	int size_z = 0;

	bool isDirty = false;

private:
	bool isEmpty = false;

};