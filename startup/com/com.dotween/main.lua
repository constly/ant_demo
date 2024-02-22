-- 后面参考这里的代码
-- https://github.com/Demigiant/dotween/tree/develop/_DOTween.Assembly
-- 如果换一种写法: 创建一个entity, 把曲线信息都存储在它的组件上，这样遍历效率会不会更高? 不太清楚组件上的数据存储是否有做优化

local _maxId = 0;
local datas = {}
local api = {}

-- 动画类型
api.type_number = 1
api.type_color = 2
api.type_position = 3
api.type_scale = 4

-- 播放
--[[
params = 
{
	type = api.type_number,
	from = 0,
	to = 1,
	time = 1,
	curve = "linear",
	on_update = function(v) end,
	on_complete = function() end,
}
--]]
function api.create(params)
	_maxId = _maxId + 1
	params._Id = _maxId
	table.insert(datas, params)
	return params._Id
end

function api.create_sequence(params)

end

-- 暂停某个动画
function api.pause(animId)

end

-- 继续
function api.resume(animId)

end 

-- 中止
function api.kill(animId)

end

-- 全部中止
function api.kill_all()

end

function api.get_datas()
	return datas
end 

return api;