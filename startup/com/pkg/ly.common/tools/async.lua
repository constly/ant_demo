-- aync.lua 用于创建一个 aync_instance 过程
-- 原版 coroutine 不能直接在 ltask 中时候，需要导入 ant.coroutine ，用法一致。
local coroutine = import_package "ant.coroutine"

local function new(world)
	---@class ly.common.async
	local async = {}; 
	async.__index = async

	local function check_ready(self)
		local r = self._ready
		if r >= self._wait then
			self._wait = 0
			self._ready = 1
			assert(coroutine.resume(self._co))
		else
			self._ready = r + 1
		end
	end
	
	local function async_create_instance(self, arg)
		function arg.on_ready(inst)
			check_ready(self)
		end
		self._wait = self._wait + 1
		return world:create_instance(arg)
	end
	
	local function async_create_entity(self, arg)
		function arg.data.on_ready(inst)
			check_ready(self)
		end
		self._wait = self._wait + 1
		return world:create_entity(arg)
	end

	function async:create_instance(arg)
		local inst = async_create_instance(self, arg)
		coroutine.yield()
		return inst
	end

	function async:create_entity(arg)
		local enity = async_create_entity(self, arg)
		coroutine.yield()
		return enity
	end
	
	async.async_instance = async_create_instance
	async.async_entity = async_create_entity
	async.wait = coroutine.yield

	return function (main_func)
		local co = coroutine.create(main_func)
		local async_inst = setmetatable( { _co = co, _wait = 0, _ready = 1 }, async )
		assert(coroutine.resume(co, async_inst))
	end
end

return {new = new}