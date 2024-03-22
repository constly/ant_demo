---@class ly.common.lib
local lib = {}

function lib.split(content, delim)
	content = content or ""
    delim = delim or '\n'
	local ret = {}
    local pattern = string.format("([^%s]+)", delim)
    content:gsub(pattern, function(substring)
        table.insert(ret, substring)
    end)
    return ret
end
function lib.start_with(str, prefix)
    return str:sub(1, #prefix) == prefix
end

function lib.end_with(str, suffix)
    return suffix == "" or str:sub(-#suffix) == suffix
end

function lib.trim(s, chars)
    chars = chars or "%s" -- 默认为空白字符
    return s:gsub("^["..chars.."]*(.-)["..chars.."]*$", "%1")
end

function lib.map_key_to_array(list)
	local array = {}
	for key, _ in pairs(list) do 
		array[#array + 1] = key
	end
	return array
end

--- 得到文件名，包含扩展名
function lib.get_file_name(path)
	if string.find(path, "/") then 
		local arr = lib.split(path, "/")
		return arr[#arr]
	end 
	return path
end

--- 得到文件名，不包含扩展名
function lib.get_filename_without_ext(path)
	local file = lib.get_file_name(path)
	if string.find(file, "%.") then
		return file:match("^(.*)%.([^.]+)$")
	end 
	return file
end

--- 得到文件扩展名
function lib.get_file_ext(path)
	local file = lib.get_file_name(path)
	return file:match(".*%.([^.]+)$")
end

function lib.table2string(obj)
	if not obj then return "nil" end;
        
    local getIndent, quoteStr, wrapKey, wrapVal, isArray, dumpObj
    getIndent = function(level)
        return string.rep("  ", level)
    end
    quoteStr = function(str)
        str = string.gsub(str, "[%c\\\"]", {
            ["\t"] = "\\t",
            ["\r"] = "\\r",
            ["\n"] = "\\n",
            ["\""] = "\\\"",
            ["\\"] = "\\\\",
        })
        return '"' .. str .. '"'
    end
    wrapKey = function(val)
        if type(val) == "number" then
            return "[" .. val .. "]"
        elseif type(val) == "string" then
            return "[" .. quoteStr(val) .. "]"
        else
            return "[" .. tostring(val) .. "]"
        end
    end
    wrapVal = function(val, level)
        if type(val) == "table" then
            return dumpObj(val, level)
        elseif type(val) == "number" then
            return val
        elseif type(val) == "string" then
            return quoteStr(val)
        else
            return tostring(val)
        end
    end
    local isArray = function(arr)
        local count = 0 
        for k, v in pairs(arr) do
            count = count + 1 
        end 
        for i = 1, count do
            if arr[i] == nil then
                return false
            end 
        end 
        return true, count
    end
	local processed = {}
    dumpObj = function(obj, level)
        if type(obj) ~= "table" then
            return wrapVal(obj)
		else 
			if processed[obj] then 
				return "--Recycle--"
			end 
			processed[obj] = true
        end
        level = level + 1
        local tokens = {}
        tokens[#tokens + 1] = "{"
        local ret, count = isArray(obj)
        if ret then
            for i = 1, count do
                tokens[#tokens + 1] = getIndent(level) .. wrapVal(obj[i], level) .. ","
            end
        else
            for k, v in pairs(obj) do
                tokens[#tokens + 1] = getIndent(level) .. wrapKey(k) .. " = " .. wrapVal(v, level) .. ","
            end
        end
        tokens[#tokens + 1] = getIndent(level - 1) .. "}"
        return table.concat(tokens, "\n")
    end
    return dumpObj(obj, 0);
end

function lib.dump(obj)
    print(lib.table2string(obj))
end

function lib.copy(tb)
	local ret = {};
	if type(tb) ~= "table" then
		return tb;
	end
	for k, v in pairs(tb) do
		if type(v) == "table" then
			ret[k] = lib.copy(v);
		else
			ret[k] = v;
		end
	end
	return ret;
end

return lib