-----------------------------------------------------------------------
-- 通过真实time驱动的timer
-----------------------------------------------------------------------

local function new()
	---@class sims.common.time_timer
	local api = {}
	local list = {}
	local next_id = 0;

	function api.reset()
		list = {}
		next_id = 0
	end

	function api.update(delta_time)
		for timerId, v in pairs(list) do 
			v.delay = v.delay - delta_time
			if v.delay <= 0 then 
				v.cb()
				if v.interval then 
					v.delay = v.interval
				else 
					api.remove_timer(timerId)
				end
			end
		end
	end

	function api.add_timer(delay, cb)
		next_id = next_id + 1
		list[next_id] = {id = next_id, delay = delay, cb = cb}
		return next_id
	end

	function api.add_loop_timer(delay, interval, cb)
		next_id = next_id + 1
		list[next_id] = {id = next_id, delay = delay, interval = interval, cb = cb}
		return next_id
	end

	function api.remove_timer(timerId)
		list[timerId] = nil
	end

	return api
end

return {new = new}