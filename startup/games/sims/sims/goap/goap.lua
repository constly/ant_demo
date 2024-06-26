--------------------------------------------------------
-- goap mgr
--------------------------------------------------------
---@type ly.common
local common = import_package 'ly.common'		

---@type goap_mgr
local goap_mgr = common.new_goap_mgr()

do 
	--------------------------------------------------------
	-- 等待一段时间 
	--------------------------------------------------------
	local action_id = "action_wait_time"
	goap_mgr.new_action(action_id, "等待一段时间", "等待一段时间，单位秒")
	.def_param("number", "time", "时间(秒)", 0)
	.set_preview("等待{{time}}秒")
	.set_owner("global")
	.reg_api(function()
		local api = goap_mgr.new_api(action_id)
		local time = 0;
		local max_time = 0;
		function api.on_init(data)
			max_time = tonumber(data.time) or 0
		end
		function api.on_begin()
			time = 0
		end
		function api.on_update(delta_time)
			time = time + delta_time
		end
		function api.is_complete()
			return max_time >= 0 and time >= max_time
		end
		function api.to_string() 
			return string.format("等待中,剩余:%d秒", max_time - time)
		end
		function api.serialize()
			local save = {time = time}
			return save
		end
		function api.deserialize(save)
			time = save.time
		end
		return api
	end)
end 

do 
	--------------------------------------------------------
	-- 等待点击屏幕 
	--------------------------------------------------------
	local action_id = "action_wait_input"
	goap_mgr.new_action(action_id, "等待输入")
	.set_preview("等待输入")
	.set_owner("global")
	.reg_api(function()
		local api = goap_mgr.new_api(action_id)
		local complete = false
		function api.on_update()
			if false then 
				complete = true
			end
		end
		function api.is_complete()
			return complete
		end
		return api
	end)
end 

do 
	--------------------------------------------------------
	-- 输出 
	--------------------------------------------------------
	local action_id = "action_print"
	goap_mgr.new_action(action_id, "打印消息")
	.def_param("string", "msg", "内容", "")
	.set_preview("输出:{{msg}}")
	.set_owner("global")
	.reg_api(function()
		local api = goap_mgr.new_api(action_id)
		local msg 
		function api.on_init(data)
			msg = data.msg
		end
		function api.on_begin()
			print("打印: ", msg)
		end
		function api.is_complete()
			return true
		end
		return api
	end)
end 

do
	--[[
	节点应该有多种类型:
		1. 全局静态节点: 比如wait_time, print
		2. 对象节点: 如npc对象, 队伍对象，社团对象等等
	--]]

	--------------------------------------------------------
	-- 挖矿 
	--------------------------------------------------------
	local action_id = "action_mining"
	goap_mgr.new_action(action_id, "挖矿")
	.def_param("int", "name", "名字", "0")
	.def_param("string", "desc", "描述", "")
	.def_param("number", "speed", "产出", "")
	.set_owner("npc")
	-- 是否还应该有input, output, as, 以及所属对象
	.reg_api(function()
		local api = goap_mgr.new_api(action_id)
		function api.on_begin()
		end 

		function api.on_end()
		end 

		function api.on_update(delta_time)
		end
		
		function api.is_complete()
			return api.complete;
		end

		return api
	end)
end 

return goap_mgr

--[[

道具列表:
	rice 			大米
	iron_sword 		铁剑
	hoe 			锄头
	spade			铁锹
	ore				铁矿石

建筑列表:
	杂货店
	铁匠铺

人物属性:
	金币
	饱食度

世界:
	矿脉数量
	农田数量


农民
	create_npc({name = "农民", items = {{"hoe", 1}}, })

商人
	create_npc({name = "商人", class_name = "shop", items = {{"rice", 10}})

矿工
	create_npc({name = "矿工", items = {{"spade", 1}})

士兵
	create_npc({name = "士兵", items = {{"iron_sword", 1}})

铁匠
	将矿石加工为锄头，铁锹，铁剑
	create_npc({name = "铁匠", class_name = "smithy"})

说明:
	每个人每秒扣除1点饱食度
	每个人都要生存，即 食物 > 0


--]]

