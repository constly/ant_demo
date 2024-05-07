#pragma once
#include <map>
#include <set>
#include "region.h"
#include "../astar/astar.h"


/*
x,y,z 区域坐标限制: [-100万, 100万]
*/
struct World {
public:
	World();
	~World();

	// 销毁世界数据
	void Destroy();

	// 重置世界
	void Reset();

	// 每帧更新
	void Update();
	
public:
	// 设置区域尺寸
	void SetRegionSize(int region_size_x, int region_size_y, int region_size_z);

	// 设置寻路最大agent的大小
	void SetMaxAgentSize(int size) { max_agent_size = size; }


public:
	// 设置地形数据
	// terrain 为0 时表示清空
	// 清空完后，需要检查是否有空白区域，如果有则删掉
	void SetGridData(int start_x, int start_y, int start_z, int size_x, int size_y, int size_z, EGridType gridType);

	// 清空地形数据
	void ClearGridData(int start_x, int start_y, int start_z, int size_x, int size_y, int size_z);

	// 得到格子数据
	EGridType GetGridData(int pos_x, int pos_y, int pos_z);
	
	// 得到区域id
	int64_t GetRegionId(int pos_x, int pos_y, int pos_z);

	// 得到区域
	Region* GetRegionById(int64_t regionId);
	Region* GetRegionByPos(int pos_x, int pos_y, int pos_z);

	// 得到地面高度
	int GetGroundHeight(int pos_x, int pos_y, int pos_z, int checkRange = 200);

	void DestroyRegion(int64_t regionId);

	// 寻路
	AStar astar;

private:

	void SetGridDataInner(int start_x, int start_y, int start_z, int size_x, int size_y, int size_z, EGridType gridType, bool autoCreateRegion);

	// 得到或者创建区域
	Region* GetOrCreateRegionByPos(int pos_x, int pos_y, int pos_z);

private:
	// 区域大小
	int region_size_x = 20;
	int region_size_y = 10;
	int region_size_z = 20;

	// 
	int max_agent_size = 2;

	// 区域列表
	std::map<int64_t, Region*> Regions;

	// 脏标记
	std::set<Region*> dirtyList;
};