---@class test.bgfx.example 
---@field _name string
---@field on_entry function 当进入时
---@field on_exit function	当离开时
---@field on_resize function 当窗口大小改变时
---@field update function 每帧更新

---@class test.bgfx.data_mgr
local api = {}

---@type ly.common
local common = import_package 'ly.common'

--- 所有例子
---@type test.bgfx.example[]
api.tbExamples = {}

--- 当前正在展示的例子
---@type test.bgfx.example 
api.Current = nil

local function init()
	local last = common.user_data.get("test.bgfx.current")
	local reg = function(name)
		local data = require ('examples.' .. name)
		data._name = name
		table.insert(api.tbExamples, data)

		if name == last then 
			api.entry(data)
		end
	end
	reg("00_helloworld")
	reg("01_cubes")
	reg("02_metaballs")

	if not api.Current then
		api.entry(api.tbExamples[1])
	end
end

---@param ins test.bgfx.example 
function api.entry(ins)
	if ins == api.Current then 
		return
	end
	if api.Current and api.Current.on_exit then 
		api.Current.on_exit()
	end
	api.Current = ins
	if ins.on_entry then
		ins.on_entry()
	end
	if ins.on_resize then
		ins.on_resize()
	end
	if ins then
		common.user_data.set("test.bgfx.current", ins._name, true)
	end
end

function api.on_resize()
	if api.Current and api.Current.on_resize then 
		api.Current.on_resize()
	end
end

function api.update(delta_time)
	if api.Current then 
		api.Current.update(delta_time)
	end
end

init()
return api