-----------------------------------------------------------------------
-- 通过tick驱动的timer，效率最高
-----------------------------------------------------------------------

local function new()
	---@class ly.common.tick_timer
	local api = {}; 
	local _tick = 0
	local data = {}

	function api.reset()
		_tick = 0
		data = {}
	end

	function api.update()
		local t = _tick
		local f = data[t]
		if f then
			f()
			data[t] = nil
		end
		_tick = t + 1
	end

	function api.add(tick, func)
		local t = _tick + tick
		local f = data[t]
		data[t] = f and function()
			f()
			func()
		end or func
	end

	function api.interval(tick, func)
		assert(tick > 0)
		local function f()
			func()
			api.add(tick, f)
		end
		api.add(tick, f)
	end

	return api
end 

return {new = new}
