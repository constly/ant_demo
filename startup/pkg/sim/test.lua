
--[[

goap ai 


Action:
	前置条件
		这里也应该是固定配置
		支持tag系统
		map结构，支持bool判断，大于小于判断
	
	优先级
	消耗
		行为执行代价,

	行为内容
		行为支持多个顺序执行
		支持对象系统

	后置影响
		这里是固定配置，不然没法提前计算了

Goal: 行为目标

Memory: 记忆，偏动态， 每个npc都不一样，会参与到行为决策中

Sensor: 感知者，本质和Memroy一样，但是偏动态：监听玩家属性变化，在某些情况下动态更新memory



Demo: 
	场景地点
		矿场
		农田
		商店

	Npc类型
		商人
		矿工
		农民

	世界条件
		是/否有矿场

	Npc条件:


功能实现:
	每个action就是一个component 
	由于只能同时执行一个action, 那么就可以通过不断add_componet 和 remove_component 来实现
	这样只要保证每个component 支持序列化/反序列化的即可 简化问题难度
	不过这样也带来一个问题：每帧最多只会执行一个component (由system执行)，需要在设计时注意


作用域: 
	self 自身
	map 自身所在地图
	global 全局
	family 家庭
	village 村 （一个地图上有多个村庄，村庄之间有利益纠纷）
	faction 门派 （游戏中有很多门派势力）
	company 公司 (地图上一个店铺就是一个公司)
	每个作用域下有一堆属性注册
--]]


local function create_actions()
	-- 注册行为: 优先级, 执行代码, 行为名字, 条件列表, 影响列表
	local function new_action(tags, name, priority, cost, conditons, effects)
		
	end

	do
		-- 挖矿
		-- 条件：身份是矿工
		-- 影响: 矿石+5
		local conditions = {all = {{"self", "identity", "==", "miner"}}}
		local effect = {{"self", "ore", "+", "5"}}
		local action = new_action({}, "挖矿", 1, 1, conditions, effect)
		function action.begin()
		end
		function action.tick(delta_time)
		end
		function action.is_complete()
		end 
	end

	do 
		-- 寻找商店
		-- 条件：地面里商店数量大于1
		-- 影响: 在商店旁边
		local conditions = {all = {{"map", "shop_count", ">", "0"}}}
		local effect = { {"self", "在商店旁边", "=", "1"} }
		local action = new_action({}, "寻找商店", 1, 1, conditions, effect)
		function action.begin()
		end
		function action.tick(delta_time)
		end
		function action.is_complete()
		end 
	end 
		
	do
		-- 卖矿
		-- 条件：有矿石，在商店旁边
		-- 影响: 金钱+50
		local conditions = {all = {{"self", "ore", ">", "0"}, {"self", "在商店旁边", "=", "1"}}}
		local effect = {{"self", "coin", "+", "50"}}
		local action = new_action({}, "卖矿", 1, 1, conditions, effect)
		function action.begin()
		end
		function action.tick(delta_time)
		end
		function action.is_complete()
		end 
	end
	
	do 
		-- 种田
		-- 条件：身份是农民
		-- 影响: 食物+50
		local conditions = {all = {{"self", "identity", "==", "farmer"}}}
		local effect = {{"self", "food", "+", "50"}}
		local action = new_action("种田", 1, 1, conditions, effect)
		function action.begin()
		end
		function action.tick(delta_time)
		end
		function action.is_complete()
		end 
	end

	do
		-- 卖食物
		-- 条件：自身食物数量大于120，在商店旁边
		-- 影响: 金钱+50
		local conditions = {all = {{"self", "food", ">", "0"}, {"self", "在商店旁边", "=", "1"}}}
		local effect = {{"self", "coin", "+", "50"}}
		local action = new_action({}, "卖食物", 1, 1, conditions, effect)
		function action.begin()
		end
		function action.tick(delta_time)
		end
		function action.is_complete()
		end 
	end

	do
		-- 买食物
		-- 条件：在商店旁边，商店有食物
		-- 影响: 食物+50
		local conditions = {all = {{"self", "在商店旁边"}, {"self", "在商店旁边", "=", "1"}}}
		local effect = {{"self", "coin", "+", "50"}}
		local action = new_action({}, "买食物", 1, 1, conditions, effect)
		function action.begin()
		end
		function action.tick(delta_time)
		end
		function action.is_complete()
		end 
	end

	do
		-- 吃饭
		-- 条件：食物大于0，健康小于40
		-- 影响: 健康度+50
		local conditions = {all = {{"self", "food", ">", "0"}, {"self", "health", "<=", "40"}}}
		local effect = {{"self", "health", "+", "10"}}
		local action = new_action({}, "吃饭", 1, 1, conditions, effect)
		function action.begin()
		end
		function action.tick(delta_time)
		end
		function action.is_complete()
		end 
	end

end


local function new_npc()
	---@class test.npc
	local npc = {}

	function npc.tick(delta_time)

	end

	--- 得到npc当前目标
	function npc.get_npc_goal()
	end 

	--- 得到npc当前行为列表
	function npc.get_npc_action()
	
	end 

	--- 得到npc正在执行的行为
	function npc.current_action()
	end

	return npc
end
	



local function new_world()
	local world = {}

	---@type test.npc[]
	world.npcs = {}

	local function init()
		--- tag分类 tag名字 tag描述
		local function register_tag(category, name, desc)

		end
		register_tag("身份标签", "merchant", "商人")
		register_tag("身份标签", "miner", "矿工")
		register_tag("身份标签", "farmer", "农民")

		--- 目标
		--- 饥饿度大于30
		--- 赚钱

		-- 创建商人
		world.create_npc({identity = "merchant"})

		-- 创建矿工
		world.create_npc({identity = "miner"})

		-- 创建农民
		world.create_npc({identity = "farmer"})
	end

	--- 创建npc
	function world.create_npc(params)
		local npc = new_npc()
		npc.id = #world.npc + 1
		npc.params = params  		-- 创建参数
		npc.food = 100				-- 食物 (每秒消耗10)
		table.insert(world.npcs, npc)
	end 

	--- 每帧更新
	function world.tick(delta_time)
		for i, npc in ipairs(world.npcs) do 
			npc.tick(delta_time)
		end 
	end 

	init()
	return world
end 

return {new_world = new_world}