
local function begin_tag(category, desc)
	-- body
end

local function reg_tag(name, desc)
end 


local function reg_region(type, attrs)
	
end

local function reg_condition_opt()
end

local function reg_effect_opt()
	-- body
end


local function init()
	begin_tag("identity", "身份类");
	reg_tag("merchant", 	"商人")
	reg_tag("miner", 		"矿工")
	reg_tag("farmer", 		"农民")

	--- 注册npc属性
	reg_region("npc", {
		{"number",		"coin", 		"金币"},
		{"number",		"health", 		"健康"},

		{"number",		"food", 		"食物"},
		{"tag",			"identity", 	"身份", 	{category = "identity"}},

		{"number",		"ore",	 		"铁矿"},	

		{"bool", 		"beside_shop", "商店前面"},
	})

	--- 注册地图属性
	reg_region("map", {
		{"number",		"shop_count", 	"商店数量"},
	})

	--- 注册全局属性
	reg_region("global", {
		{"number",		"test", 		"测试"},
	})

	--- 注册条件判断类型
	reg_condition_opt("==",	"等于")
	reg_condition_opt(">", 	"大于")
	reg_condition_opt(">=", 	"大于等于")
	reg_condition_opt("<", 	"小于")
	reg_condition_opt("<=", 	"小于等于")

	--- 注册效果运行
	reg_effect_opt("+")
	reg_effect_opt("+=")
	reg_effect_opt("-")
	reg_effect_opt("-=")
	reg_effect_opt("=")
end