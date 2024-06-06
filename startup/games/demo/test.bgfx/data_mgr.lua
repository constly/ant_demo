---@class test.bgfx.example 
---@field _name string
---@field on_entry function
---@field on_exit function
---@field update function

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
	if api.Current.on_entry then
		api.Current.on_entry()
	end
	if ins then
		common.user_data.set("test.bgfx.current", ins._name, true)
	end
end

function api.update(delta_time)
	if api.Current then 
		api.Current.update(delta_time)
	end
end

init()
return api