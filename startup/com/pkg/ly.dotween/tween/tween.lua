local impl = require 'ly.impl.dotween'

---@param type ly.dotween.EaseType
local function create(EaseType, startValue, endValue, duration)
	---@class ly.dotween.tween
	local api = {}
	local timescale = 1
	local delay = 0
	local bKilled = false
	local is_start
	local Ended = 0
	local ElapsedTime = 0
	local OnStartCallback
	local OnCompleteCallback 
	local OnUpdateCallback 
	local Repeat = 0
	local bYoyo = false
	local NormalizedTime
	local EaseOvershootOrAmplitude = 1.7
	local EasePeriod = 0
	local bSnapping = false
	local CurValue = startValue

	function api.get_value() return CurValue end 
	function api.is_killed() return bKilled end
 
	function api.set_delay(value) delay = value end
	function api.set_timescale(value) timescale = value end
	function api.set_update(cb) OnUpdateCallback = cb end
	
	local function __update()
		Ended = 0
		if not is_start then 
			if ElapsedTime < delay then return end 
			is_start = true
			if OnStartCallback then OnStartCallback() end 
			if bKilled then return end
		end
		local reversed = false
		local tt = ElapsedTime - delay;
		if Repeat ~= 0 then 
			local round = math.floor(tt / duration);
			tt = tt - duration * round;
			if bYoyo then
				reversed = round % 2 == 1;
			end
			if Repeat > 0 and (Repeat - round < 0) then
				if bYoyo then
					reversed = Repeat % 2 == 1;
				end
				tt = duration;
				Ended = 1;
			end
		elseif (tt >= duration) then 
			tt = duration
			Ended = 1
		end

		-- 返回归一化的时间
		NormalizedTime = impl.Evaluate(EaseType, reversed and (duration - tt) or tt, duration, EaseOvershootOrAmplitude, EasePeriod);
		local v = startValue + (endValue - startValue) * NormalizedTime
		if bSnapping then 
			v = (v % 1 >= 0.5) and math.ceil(v) or math.floor(v)
		end
		CurValue = v
		if OnUpdateCallback then OnUpdateCallback(api) end
	end

	function api.update(dt)
		if Ended ~= 0 then
			if OnCompleteCallback then OnCompleteCallback() end
			bKilled = true
			return 
		end

		if timescale ~= 1 then 
			dt = dt * timescale
		end 
		ElapsedTime = ElapsedTime + dt
		__update();
		if Ended ~= 0 and not bKilled then
			if OnCompleteCallback then OnCompleteCallback() end
			bKilled = true
			return 
		end
	end

	function api.kill()
		if bKilled then return end 
		if Ended == 0 then 
			ElapsedTime = delay + duration * 2
			__update()
		end
		bKilled = true
	end

	return api;
end


local api = {}
api.tweens = {}  ---@type ly.dotween.tween[]

---@return ly.dotween.tween
function api.to(easeType, from, to, duration)
	local tween = create(easeType, from, to, duration)
	api.tweens[#api.tweens + 1] = tween
	return tween
end

function api.vec2_to()
end


return api