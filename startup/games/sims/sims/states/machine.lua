-----------------------------------------------------------------------
--- 客户端 游戏流程 状态机
-----------------------------------------------------------------------
---@class sims.client.state_machine.state_base 
---@field on_entry function
---@field on_exit function
---@field on_update function
---@field on_destroy function

---@param client sims.client
local function new(client)
	---@class sims.client.state_machine
	local api = {}
	api.state_entry 		= 1
	api.state_create_room 	= 2
	api.state_join_room 	= 3
	api.state_room_end 		= 4
	api.state_room_running  = 5

	api.client 		= client.room 
	api.msg 		= client.msg

	---@type sims.client.state_machine.state_base[]
	api.all_states = {}

	---@type sims.client.state_machine.state_base
	local cur_state

	local function init()
		api.all_states[api.state_entry] 		= require 'states.state_entry'.new(api, client) 
		api.all_states[api.state_create_room] 	= require 'states.state_create_room'.new(api, client) 
		api.all_states[api.state_join_room] 	= require 'states.state_join_room'.new(api, client) 
		api.all_states[api.state_room_end] 		= require 'states.state_room_end'.new(api, client) 
		api.all_states[api.state_room_running] 	= require 'states.state_room_running'.new(api, client) 
	end

	function api.init()
		cur_state = nil
		api.goto_state(api.state_entry)
	end 

	function api.shutdown()
		for i, v in pairs(api.all_states) do 
			if v.on_destroy then 
				v.on_destroy()
			end
		end
		api.reset()
	end

	function api.reset()
		cur_state = nil
	end 

	function api.goto_state(name)
		local state = api.all_states[name]
		if state == cur_state then 
			return 
		end 
		if state and state.on_exit then 
			state.on_exit()
		end
		cur_state = state
		if cur_state and cur_state.on_entry then 
			cur_state.on_entry()
		end
	end

	function api.update(deltaTime)
		if cur_state and cur_state.on_update then 
			cur_state.on_update(deltaTime)
		end 
	end

	init()
	return api
end

return {new = new}