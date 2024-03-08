local player_mgr = {}
player_mgr.list = {}
function player_mgr.on_login(tbParam)
	local p = {}
	table.insert(player_mgr.list, p)
end


local api = {cmds = {}}
function api.register(cmd, cb)
	api.cmds[cmd] = cb
end 
api.register("login", function(tbParam)
	player_mgr.on_login(tbParam)
end)


local function foreach(callback)
	for i, p in ipairs(player_mgr.list) do 
		callback(p)
	end
end

local function send(player, tbData)
	if player.isLocal then 
		local ltask = require "ltask"
		ltask.call(ServiceWindow, "message_handle", tbData)
	else 
		print("这里需要通过网络发送")
	end
end

local function notify(data)
	foreach(function(player)
		send(player, data)
	end)
end