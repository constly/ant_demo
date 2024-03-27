--------------------------------------------------------
-- csv 数据处理
--------------------------------------------------------
---@type ly.game_editor.dep
local dep = require 'dep'
local lib = dep.common.lib

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
			api.insert_column(i == 1 and "id" or ("key" .. (i - 1)), "string", i, i == 1 and "唯一标识" or "注释说明");
			api.insert_line(i)
		end
	end

	---@param data ly.game_editor.csv.data 设置数据
	function api.set_data(data)
		if type(data) == "string" then 
			data = api.from_string(data)
		end
		if not data or type(data) ~= "table" or not data.heads or not data.bodies then 
			api.init()
		else 
			api.data = data
		end
	end

	function api.to_string()
		local list = {}
		local line1, line2, line3 = {}, {}, {}
		for i, head in ipairs(api.data.heads) do 
			table.insert(line1, string.format("%s;%s;%s", math.floor(head.width), head.visible and 1 or 0, head.explain or ""))
			table.insert(line2, head.type)
			table.insert(line3, head.key)
		end
		table.insert(list, table.concat(line1, "\t"))
		table.insert(list, table.concat(line2, "\t"))
		table.insert(list, table.concat(line3, "\t"))

		for i, body in ipairs(api.data.bodies) do 
			local tb = {}
			for _, col in ipairs(api.data.heads) do 
				table.insert(tb, body[col.key] or "")
			end
			table.insert(list, table.concat(tb, "\t"))
		end
		return table.concat(list, "\n")
	end 

	function api.from_string(str)
		local lines = lib.split(str, "\n")
		if #lines < 3 then return end 

		local heads = {}	---@type ly.game_editor.csv.head[]
		for i = 1, 3 do 
			local line = lib.trim(lines[i], "\r")
			local list = lib.split(line, "\t");
			for j = 1, #list do 
				local str = list[j]
				if i == 1 then 
					local arr = lib.split(str, ";")
					local data = {} ---@type ly.game_editor.csv.head
					data.width = tonumber(arr[1]) or 20
					data.visible = arr[2] == "1"
					data.explain = arr[3]
					heads[j] = data
				elseif i == 2 then
					heads[j].type = str 
				elseif i == 3 then
					heads[j].key = str 
				end
			end
		end

		local bodies = {}
		for i = 4, #lines do 
			local line = lib.trim(lines[i], "\r")
			local list = lib.split(line, "\t");
			local data = {}
			for j, value in ipairs(list) do 
				local head = heads[j]
				if head then 
					data[head.key] = value
				end
			end
			table.insert(bodies, data)
		end
		return {heads = heads, bodies = bodies}
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

	---@return ly.game_editor.csv.body 得到行
	function api.get_line_by_index(index)
		return api.data.bodies[index]
	end


	---@return ly.game_editor.csv.head 得到列
	function api.get_colume(key)
		for i, v in ipairs(api.data.heads) do 
			if v.key == key then 
				return v
			end
		end
	end

	---@return ly.game_editor.csv.head[] 得到所有可见的列
	function api.get_visbile_columns()
		local tbCols = {}
		for i, v in ipairs(api.data.heads) do 
			if v.visible then 
				table.insert(tbCols, v)
			end
		end
		return tbCols
	end

	---@param pos number 插入列位置
	function api.insert_column(key, type, pos, explain)
		if api.has_column(key) then return end 
		---@type ly.game_editor.csv.head
		local head = {}
		head.key = key
		head.type = type
		head.width = 80
		head.explain = explain
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

	function api.get_cache()
		local cache = api.data.cache or {}
		cache.selected = cache.selected or {}
		api.data.cache = cache
		return cache
	end

	function api.add_selected(lineIdx, keyIdx)
		local cache = api.get_cache()
		table.insert(cache.selected, {lineIdx = lineIdx, keyIdx = keyIdx})
	end 

	function api.add_selected_shift(lineIdx, keyIdx)
		local cache = api.get_cache()
		table.insert(cache.selected, {lineIdx = lineIdx, keyIdx = keyIdx})
		for i = #cache.selected, 2, -1 do 
			table.remove(cache.selected, i)
		end
	end 

	function api.set_selected(lineIdx, keyIdx)
		local cache = api.get_cache()
		cache.selected = {{lineIdx = lineIdx, keyIdx = keyIdx}}
	end

	function api.is_selected(lineIdx, keyIdx)
		local cache = api.get_cache()
		for i, v in ipairs(cache.selected) do 
			if v.lineIdx == lineIdx and v.keyIdx == keyIdx then 
				return true
			end
		end
	end

	function api.get_selected_count()
		local cache = api.get_cache()
		return #cache.selected
	end

	function api.get_first_selected()
		local cache = api.get_cache()
		local one = cache.selected[1]
		if one then 
			return one.lineIdx, one.keyIdx
		end
	end

	return api
end

return {new = new}
