--------------------------------------------------------
--- 文件操作相关接口
--------------------------------------------------------
---@type ly.common.lib
local lib = require 'tools.lib'

---@type ly.common.dep
local dep = require 'dep'

---@class ly.common.file
local api = {}

---@class ly.common.datalist
local datalist = require 'tools.datalist'

---@param file_path string 文件磁盘路径
---@return string 文本内容
function api.load_file_from_disk(file_path)
	local f<close> = io.open(file_path, 'r')
	return f and f:read "a"
end

---@param file_path string 文件vsf路径
---@return string 文本内容
function api.load_file_from_vfs(file_path)
	return dep.aio.readall_s(file_path)
end

---@return boolean 是不是vfs路径
function api.is_vfs_path(path)
	if lib.start_with(path, "/pkg/") then 
		return true
	end
	return string.find(path, ":") == nil
end

---@param file_path string 文件路径
---@return string 文本内容
function api.load_file(file_path)
	if not file_path then return "" end 
	local content
	xpcall(function()
		local is_vfs = api.is_vfs_path(file_path)
		content = is_vfs and api.load_file_from_vfs(file_path) or api.load_file_from_disk(file_path)
	end, function(msg)
		log.warn(msg)
	end)
	return content or ""
end

---@param file_path string 文件磁盘路径
---@return table datalist
function api.load_datalist(file_path)
	local content = api.load_file(file_path)
	return dep.datalist.parse(content)
end

---@return table 加载ini文件
function api.load_ini(file_path)
	return api.load_datalist(file_path)
end

---@return table 加载csv文件
function api.load_csv(file_path)
	local content = api.load_file(file_path)
    if not content or content == "" then
        return {}
    end

	content = string.gsub(content, "\r\n", "\n")
    local lines = lib.split(content, "\n")
    local count = #lines
    if count <= 3 then
        return {}
    end

    local keys = lib.split(lines[3], "\t")
    local rets = {}
    for i = 4, count do
        local line = lines[i]
		local vars = lib.split(line, "\t")
		if vars[1] and vars[1] ~= "" then
			local data = {}
			local valid = false
			for col, var in ipairs(vars) do
				local key = keys[col]
				if key and key ~= "" and var and var ~= "" then
					data[key] = var
					valid = true
				end
			end
			if valid then 
				table.insert(rets, data)
			end
		end
    end

    return rets
end 

---@param full_path string 文件磁盘路径
---@param content string 文件内容
function api.save_file(full_path, content)
	local f<close> = assert(io.open(full_path, "w"))
	if f then
		f:write(content)
	end
end

---@param full_path string 文件磁盘路径
---@param data table 数据内容
function api.save_datalist(full_path, data)
	api.save_file(full_path, datalist.serialize(data or {}))
end


return api