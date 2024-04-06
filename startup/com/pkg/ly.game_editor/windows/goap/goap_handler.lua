--------------------------------------------------------
-- goap 数据处理
--------------------------------------------------------
local dep = require 'dep'
local lib = dep.common.lib

---@class ly.game_editor.goap.condition 条件
---@field region string 作用域
---@field id string id 
---@field opt string 操作类型
---@field value any 操作值


---@class ly.game_editor.goap.effect 影响
---@field region string 作用域
---@field id string id 
---@field opt string 操作类型
---@field value any 操作值


---@class ly.game_editor.goap.node.body.line 
---@field actionId string 
---@field params map<string, any> 参数列表
---@field disable boolean 是否禁用


---@class ly.game_editor.goap.node.body.section 子段落
---@field lines ly.game_editor.goap.node.body.line[]


---@class ly.game_editor.goap.node.body 身体
---@field sections ly.game_editor.goap.node.body.section[] 段落列表


---@class ly.game_editor.goap.node 节点
---@field tags string[] tag列表
---@field conditions ly.game_editor.goap.condition[]
---@field effects ly.game_editor.goap.effect[]
---@field body ly.game_editor.goap.node.body


---@class ly.game_editor.goap.data
---@field nodes ly.game_editor.goap.node[] 节点列表


local function new()
	---@class ly.game_editor.goap.handler
	---@field data ly.game_editor.goap.data
	local api = {
		data = {},
		stack_version = 0,
		isModify = false,
		cache = {},			-- 缓存数据，存档时忽略
	}

	---@param data ly.game_editor.tag.data
	function api.set_data(data)
		if not data or type(data) ~= "table" or not data.children then 
			data = {}
			data.name = "root"
			data.desc = ""
			data.children = {}
		end 
		api.data = data
		api.cache = api.cache or {}
	end


	return api
end

return {new = new}