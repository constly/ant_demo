local base = require 'actions._base'
local d = base.action_def

do
	-- 挖矿
	-- 条件：身份是矿工
	-- 影响: 矿石+5
	local name = d.action_mining
	local conditions = {all = {{"self", "identity", "==", "miner"}}}
	local effect = {{"self", "ore", "+", "5"}}
	base.reg_action_condition(name, conditions)
	base.reg_action_effect(name, effect)
	base.reg_action(name, function()
		local api = base.new_action(name)
		function api.begin()

		end
		function api.tick(delta_time)

		end
		function api.is_complete()

		end 
		return api
	end)
end


do 
	-- 卖矿
	-- 条件：有矿石，在商店旁边
	-- 影响: 金钱+50
	local name = d.action_mining_sell
	local conditions = {all = {{"self", "ore", ">", "0"}, {"self", "在商店旁边", "=", "1"}}}
	local effect = {{"self", "coin", "+", "50"}}
	base.reg_action_condition(name, conditions)
	base.reg_action_effect(name, effect)
	base.reg_action(name, function()
		local api = base.new_action(name)
		function api.begin()

		end
		function api.tick(delta_time)

		end
		function api.is_complete()

		end 
		return api
	end)
end