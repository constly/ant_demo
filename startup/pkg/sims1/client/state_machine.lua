-----------------------------------------------------------------------
--- 客户端 游戏流程 状态机
-----------------------------------------------------------------------
---@class sims1.client.state_machine.state_base 
---@field on_entry function
---@field on_exit function
---@field on_update function


---@param s sims1.client.state_machine
local function create_ready(s)
	local api = {}
	function api.on_entry()
		s.sims1.call_server(s.msg.rpc_login, {code = 0})
	end
	return api
end

---@param s sims1.client.state_machine
local function create_reconnect(s)
	local api = {}
	return api
end

---@param s sims1.client.state_machine
local function create_main(s)
	local api = {}
	return api
end

---@param s sims1.client.state_machine
local function create_end(s)
	local api = {}
	return api
end

---@param sims1 sims1
local function new(sims1)
	---@class sims1.client.state_machine
	local api = {}
	api.state_ready 		= 1
	api.state_reconnect 	= 2
	api.state_main 			= 3
	api.state_end 			= 4

	api.client 		= sims1.room 
	api.msg 		= sims1.msg
	api.sims1 		= sims1

	---@type sims1.client.state_machine.state_base[]
	api.all_states = {}

	---@type sims1.client.state_machine.state_base
	local cur_state

	local function init()
		api.all_states[api.state_ready] = create_ready(api)
		api.all_states[api.state_reconnect] = create_reconnect(api)
		api.all_states[api.state_main] = create_main(api)
		api.all_states[api.state_end] = create_end(api)
	end

	function api.init(is_reconnect, is_listen_player)
		cur_state = nil
		if is_listen_player then 
			--net_client.set_is_local_player(true)
		end 
		if is_reconnect then 
			api.goto_state(api.state_reconnect)
		else 
			api.goto_state(api.state_ready)
		end 
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