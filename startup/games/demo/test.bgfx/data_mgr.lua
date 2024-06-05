---@class test.bgfx.example 
---@field _name string
---@field on_entry function
---@field on_exit function
---@field update function

---@class test.bgfx.data_mgr
local api = {}

--- 所有例子
---@type test.bgfx.example[]
api.tbExamples = {}

--- 当前正在展示的例子
---@type test.bgfx.example 
api.Current = nil

local function init()
	local reg = function(name)
		local data = require ('examples.' .. name)
		data._name = name
		table.insert(api.tbExamples, data)
	end
	reg("00_helloworld")
	reg("01_cubes")

	api.entry(api.tbExamples[1])
end

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
end

function api.update(delta_time)
	if api.Current then 
		api.Current.update(delta_time)
	end
end

init()
return api