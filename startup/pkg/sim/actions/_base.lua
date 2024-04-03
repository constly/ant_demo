
local action_def = {}
action_def.action_mining = "挖矿"
action_def.action_mining_sell = "卖矿"

local function reg_action_condition(name, tb)
	
end

local function reg_action_effect(name, tb)
	-- body
end

local function new_action(name)
	
end


local function reg_action(func)
	-- body
end

return {
	reg_action_condition = reg_action_condition,
	reg_action_effect = reg_action_effect,
	action_def = action_def,

	new_action = new_action,
	reg_action = reg_action,
	
}