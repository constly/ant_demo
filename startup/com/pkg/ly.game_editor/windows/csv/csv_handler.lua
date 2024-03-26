--------------------------------------------------------
-- csv 数据处理
--------------------------------------------------------
---@class ly.game_editor.csv.head
---@field explain string 注释
---@field type string 数据类型
---@field key string 关键字
---@field visible boolean 是否显示
---@field width number 列宽度

---@class ly.game_editor.csv.body
---@field key string 关键字
---@field any any 其他字段

---@class ly.game_editor.csv.data 
---@field heads ly.game_editor.csv.head[]
---@field bodies ly.game_editor.csv.body[]

local function new()
	---@class ly.game_editor.csv.handler
	---@field data ly.game_editor.csv.data
	local api = {
		data = {},
		stack_version = 0,
		isModify = false,
		cache = {},			-- 缓存数据，存档时忽略
	}

	--- 初始化
	function api.init()
		api.data = {heads = {}, bodies = {}}
		for i = 1, 5 do 
			api.insert_column("key" .. i, "string", i);
			api.insert_line(i)
		end
	end

	---@param data ly.game_editor.csv.data 设置数据
	function api.set_data(data)
		if not data or type(data) ~= "table" or not data.heads or not data.contents then 
			api.init()
		else 
			api.data = data
		end
	end

	function api.to_csv_string()

	end 

	function api.from_csv_string()

	end

	---@return ly.game_editor.csv.head[]
	function api.get_heads() return api.data.heads end

	---@return ly.game_editor.csv.body[]
	function api.get_bodies() return api.data.bodies end

	---@return boolean 是否存在列
	function api.has_column(key) return api.get_colume(key) end

	---@return boolean 是否存在行
	function api.has_line(key) return api.get_line(key) end

	---@return ly.game_editor.csv.body 得到行
	function api.get_line(key)
		for i, v in ipairs(api.data.bodies) do 
			if v.key == key then 
				return v
			end
		end
	end

	---@return ly.game_editor.csv.head 得到列
	function api.get_colume(key)
		for i, v in ipairs(api.data.heads) do 
			if v.key == key then 
				return v
			end
		end
	end

	---@param pos number 插入列位置
	function api.insert_column(key, type, pos)
		if api.has_column(key) then return end 
		---@type ly.game_editor.csv.head
		local head = {}
		head.key = key
		head.type = type
		head.width = 100
		head.visible = true 
		if pos and pos <= #api.data.heads then
			table.insert(api.data.heads, pos, head)
		else 
			table.insert(api.data.heads, head)
		end
		return head
	end

	---@param pos number 插入行位置
	function api.insert_line(pos)
		---@type ly.game_editor.csv.body
		local line = {}
		line.key = ""
		if pos and pos <= #api.data.bodies then
			table.insert(api.data.bodies, pos, line)
		else 
			table.insert(api.data.bodies, line)
		end 
		return line
	end

	--- 得到单元格内容
	---@param lineId string 行id
	---@param key string 列id 
	function api.get_cell(lineId, key)
		local line = api.get_line(lineId)
		return line and line[key]
	end

	--- 设置单元格内容
	---@param lineId string 行id
	---@param key string 关键字
	---@param value string 值
	function api.set_cell(lineId, key, value)
		local line = api.get_line(lineId)
		if line and line[key] ~= value then 
			line[key] = value
			return true
		end
	end

	return api
end

return {new = new}