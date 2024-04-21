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

---@class ly.game_editor.csv.data.selected 
---@field lineIdx number 选中的行
---@field keyIdx number 选中的列
---@field only_head boolean 是否只选中了头部
---@field shift boolean 是否按下了shift

---@class ly.game_editor.csv.data.cache 
---@field selected  ly.game_editor.csv.data.selected[] 


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

	--------------------------------------------------------
	-- 序列化/反序列化
	--------------------------------------------------------
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
				elseif heads[j] then
					if i == 2 then
						heads[j].type = str 
					elseif i == 3 then
						heads[j].key = str 
					end
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

	--------------------------------------------------------
	-- get / set / delete 
	--------------------------------------------------------
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
				return v, i
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

	---@return ly.game_editor.csv.data.cache 
	function api.get_cache()
		local cache = api.data.cache or {}
		cache.selected = cache.selected or {}
		api.data.cache = cache
		return cache
	end

	---@return ly.game_editor.csv.head 删除列
	function api.delete_colume(key)
		for i, v in ipairs(api.data.heads) do 
			if v.key == key then 
				return table.remove(api.data.heads, i)
			end
		end
	end

	--------------------------------------------------------
	-- insert 
	--------------------------------------------------------
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
	function api.insert_line(pos, count)
		count = count or 1
		local first
		for i = 1, count do 
			---@type ly.game_editor.csv.body
			local line = {}
			line.key = ""
			if pos and pos <= #api.data.bodies then
				table.insert(api.data.bodies, pos, line)
			else 
				table.insert(api.data.bodies, line)
			end 
			first = first or line
		end
		return first
	end

	--------------------------------------------------------
	-- 选中相关
	--------------------------------------------------------
	-- 更新选中状态
	local function update_selected_status()
		local cache = api.get_cache()
		local first = cache.selected[1]
		if not first then return end 
		first.only_head = true				-- 是不是只选择了头部
		for i, v in ipairs(cache.selected) do 
			if v.lineIdx ~= 1 then 
				first.only_head = false
				break
			end
		end
	end
	function api.add_selected(lineIdx, keyIdx)
		local cache = api.get_cache()
		table.insert(cache.selected, {lineIdx = lineIdx, keyIdx = keyIdx})
		cache.selected[1].shift = false
		update_selected_status()
	end 

	function api.add_selected_shift(lineIdx, keyIdx)
		local cache = api.get_cache()
		for i = #cache.selected, 2, -1 do 
			table.remove(cache.selected, i)
		end
		table.insert(cache.selected, {lineIdx = lineIdx, keyIdx = keyIdx})
		cache.selected[1].shift = true
		update_selected_status()
	end 

	function api.set_selected(lineIdx, keyIdx)
		local cache = api.get_cache()
		local first = cache.selected[1]
		if first and first.lineIdx == lineIdx and first.keyIdx == keyIdx and #cache.selected == 1 then 
			return false
		end
		cache.selected = {{lineIdx = lineIdx, keyIdx = keyIdx}}
		update_selected_status()
		return true
	end

	function api.is_selected(lineIdx, keyIdx)
		local cache = api.get_cache()
		local first = cache.selected[1]
		if not first then return end 

		if first.shift then 
			local second = cache.selected[2]
			if not second then return end 
			local minLine = math.min(first.lineIdx, second.lineIdx)
			local maxLine = math.max(first.lineIdx, second.lineIdx)
			local minKey = math.min(first.keyIdx, second.keyIdx)
			local maxKey = math.max(first.keyIdx, second.keyIdx)
			return lineIdx >= minLine and lineIdx <= maxLine and keyIdx >= minKey and keyIdx <= maxKey
		elseif first.only_head then 
			for i, v in ipairs(cache.selected) do 
				if v.keyIdx == keyIdx then 
					return true
				end
			end
		else
			for i, v in ipairs(cache.selected) do 
				if v.lineIdx == lineIdx and v.keyIdx == keyIdx then 
					return true
				end
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

	-- 清空选择
	function api.clear_selected()
		local cache = api.get_cache()
		local first = cache.selected[1]
		if not first then return end 
		
		local cols = api.get_visbile_columns()
		if first.shift then 
			local second = cache.selected[2]
			if not second then return end 
			local minLine = math.min(first.lineIdx, second.lineIdx)
			local maxLine = math.max(first.lineIdx, second.lineIdx)
			local minKey = math.min(first.keyIdx, second.keyIdx)
			local maxKey = math.min(#cols, math.max(first.keyIdx, second.keyIdx))
			for x = minKey, maxKey do 
				local col = cols[x]
				for y = minLine, maxLine do 
					if y <= 3 then 
						if y == 3 then col.explain = "" end
					else 
						local line = api.get_line_by_index(y - 3)
						if line then 
							line[col.key] = nil
						end
					end
				end
			end
		elseif first.only_head then 
			for i, v in ipairs(cache.selected) do 
				local col = cols[v.keyIdx]
				if col then 
					for _, body in ipairs(api.data.bodies) do 
						body[col.key] = nil
					end
				end
			end
		else 
			for i, v in ipairs(cache.selected) do 
				local col = cols[v.keyIdx]
				if col then
					if v.lineIdx <= 3 then 
						if v.lineIdx == 3 then col.explain = "" end
					else 
						local line = api.get_line_by_index(v.lineIdx - 3)
						if line then 
							line[col.key] = nil
						end
					end
				end
			end
		end
		return true;
	end

	function api.delete_selected()
		local cache = api.get_cache()
		local first = cache.selected[1]
		if not first then return end 
		
		local cols = api.get_visbile_columns()
		if first.only_head then 
			local keys = {}
			for i, v in ipairs(cache.selected) do 
				local col = cols[v.keyIdx]
				if col then 
					table.insert(keys, col.key)
				end
			end
			for i, key in ipairs(keys) do 
				api.delete_colume(key)
			end
			return true
		end
	end

	---@return number,number 得到选择起始点
	function api.get_selected_start()
		local cache = api.get_cache()
		if #cache.selected == 0 then return end 

		local minKey, minLine = 99999, 99999
		for i, v in ipairs(cache.selected) do
			minKey = math.min(v.keyIdx, minKey)
			minLine = math.min(v.lineIdx, minLine) 
		end
		return minLine, minKey
	end

	-- 选择内容转换为string
	function api.selected_to_string()
		local cache = api.get_cache()
		local first = cache.selected[1]
		if not first then return end 
		
		local cols = api.get_visbile_columns()
		if first.shift then 
			local second = cache.selected[2]
			if not second then return end 
			local minLine = math.min(first.lineIdx, second.lineIdx)
			local maxLine = math.max(first.lineIdx, second.lineIdx)
			local minKey = math.min(first.keyIdx, second.keyIdx)
			local maxKey = math.min(#cols, math.max(first.keyIdx, second.keyIdx))
			local tb_list = {}
			for y = minLine, maxLine do 
				local one = {}
				for x = minKey, maxKey do 
					local col = cols[x]
					local str = ""
					if y <= 3 then 
						if y == 1 then str = col.key
						elseif y == 2 then str = col.type
						elseif y == 3 then str = col.explain end
					else 
						local line = api.get_line_by_index(y - 3)
						if line then 
							str = line[col.key]
						end
					end
					one[#one + 1] = str
				end
				table.insert(tb_list, table.concat(one, "\t"))
			end
			return table.concat(tb_list, "\n")
		elseif first.only_head then
			local minKey = 999999
			local maxKey = -1 
			local valid = {}
			for i, v in ipairs(cache.selected) do 
				minKey = math.min(minKey, v.keyIdx)
				maxKey = math.max(maxKey, v.keyIdx)
				valid[v.keyIdx] = true
			end
			local tb_list = {}
			local tb1, tb2, tb3 = {}, {}, {}
			for i = minKey, maxKey do 
				if valid[i] then 
					local col = cols[i]
					table.insert(tb1, col.key)
					table.insert(tb2, col.type)
					table.insert(tb3, col.explain)
				end
			end
			table.insert(tb_list, table.concat(tb1, "\t"))
			table.insert(tb_list, table.concat(tb2, "\t"))
			table.insert(tb_list, table.concat(tb3, "\t"))
			for _, body in ipairs(api.data.bodies) do 
				local one = {}
				for i = minKey, maxKey do 
					if valid[i] then 
						local col = cols[i]
						local str = ""
						if col then 
							str = body[col.key]
						end
						one[#one + 1] = str
					end
				end
				table.insert(tb_list, table.concat(one, "\t"))
			end
			return table.concat(tb_list, "\n")
		else
			if #cache.selected > 1 then 
				return false, "只支持复制shift多选"
			end
			local col = cols[first.keyIdx]
			if not col then return end 

			if first.lineIdx <= 3 then 
				if first.lineIdx == 1 then return col.key end 
				if first.lineIdx == 2 then return col.type end 
				if first.lineIdx == 3 then return col.explain end
			else 
				local body = api.get_line_by_index(first.lineIdx - 3)
				if body then 
					return body[col.key]
				end
			end
		end
	end

	-- string粘贴到选择处
	function api.string_to_selected(str)
		local startLine, startKey = api.get_selected_start()
		if not startLine or not startKey then return false end 

		local cols = api.get_visbile_columns()
		local function set_cell_data(x, y, data)
			local col = cols[x]
			if y <= 3 then 
				if y == 1 then col.key = data
				elseif y == 2 then col.type = data
				elseif y == 3 then col.explain = data end 
			else 
				local line = api.get_line_by_index(y - 3)
				line[col.key] = data
			end
		end

		local lines = lib.split(str, "\n")
		local endIdx = startLine + #lines - 1
		while endIdx > (#api.data.bodies + 3) do
			api.insert_line()
		end

		for i = 1, #lines do 
			local line = lib.trim(lines[i], "\r")
			local list = lib.split(line, "\t");

			if i == 1 then 
				local endIdx = startKey + #list - 1
				if endIdx > #cols then
					for idx = #cols + 1, endIdx do 
						local key = api.gen_next_column_key("key")
						api.insert_column(key, "string", nil, "注释")
					end
					cols = api.get_visbile_columns()
				end
			end

			for x = 1, #list do
				set_cell_data(x + startKey - 1, i + startLine - 1, list[x])
			end
		end
		return true
	end

	--------------------------------------------------------
	-- 复制/粘贴 相关
	--------------------------------------------------------
	function api.gen_next_column_key(name)
		local find = {}
		for i, v in ipairs(api.data.heads) do 
			find[v.key] = true
		end

		for i = 1, 9999 do 
			local name = name .. i
			if not find[name] then 
				return name
			end
		end
		return name
	end

	return api
end

return {new = new}
