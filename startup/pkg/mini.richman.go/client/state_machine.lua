-----------------------------------------------------------------------
--- 客户端 游戏流程 状态机
-----------------------------------------------------------------------
local client = require 'client.room.client_room'	---@type mrg.client_room
local msg = require 'core.msg'						---@type mrg.msg

local api = {}									---@class mini.richman.go.view.state_machine
api.state_ready 		= 1
api.state_reconnect 	= 2
api.state_main 			= 3
api.state_end 			= 4

---@class mini.richman.go.view.statemachine
local base = {}
do 
	function base:on_entry() end 
	function base:on_exit() end 
	function base:on_update() end 
end 


local all_states = {}
local cur_state  ---@type mini.richman.go.view.statemachine
---@return mini.richman.go.view.statemachine
local register = function(name) 
	local tb = setmetatable({type = name}, {__index = base})
	all_states[name] = tb
	return tb;
end 

do 
	local s = register(api.state_ready)
	function s:on_entry()
		client.call_rpc(msg.rpc_login)
	end

	function s:on_update()
	end 
end 

do 
	local s = register(api.state_reconnect)
end 

do 
	local s = register(api.state_main)
end 

do 
	local s = register(api.state_end)
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
	if cur_state and cur_state.type == name then return end 
	if cur_state then 
		cur_state:on_exit()
	end
	cur_state = all_states[name]
	if cur_state then 
		cur_state:on_entry()
	end
end

function api.update(deltaTime)
	if cur_state then 
		cur_state:on_update(deltaTime)
	end 
end

return api