---@class ly.common.lib
local lib = {}

---@return string[]
function lib.split(sData, sDelim)
	if type(sData) ~= "string" or #sData <= 0 then
        return {}
    end
    local tRet = {}
    local sPat = "(.-)" .. sDelim
    local nPos = 0
    local nLen = string.len(sData)

    while nPos <= nLen do
        local nStart, nEnd, sGet = string.find(sData, sPat, nPos)
        if not nStart then
            table.insert(tRet, string.sub(sData, nPos))
            break
        else
            table.insert(tRet, sGet)
            nPos = nEnd + 1
        end
    end
    return tRet
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

--- 将小数格式化为字符串，去除多余的0
---@param f number 小数指
---@param precision number 保留小数点后几位
function lib.float_format(f, precision)
	if not f or not precision or precision <= 0 then return f end 

	local p = 1
	while precision > 0 do
		p = p * 10
		precision = precision - 1 
	end
	local n = math.floor(f * p + 0.5)
	n = tostring(n / p)
	for i = #n, 1, -1 do 
		local c = string.sub(n, i, i)
		if c == '.' then 
			return string.sub(n, 1, i - 1)
		end
		if c ~= '0' then 
			return string.sub(n, 1, i)
		end
	end
	return 0
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

--- 得到文件路径名 (去除文件名)
function lib.get_file_root(file)
	local arr = lib.split(file, "/")
	return table.concat(arr, "/", 1, #arr - 1)
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
	if not tb then return end 
	
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

---运行代码. string to value
---@param s string Lua代码
---@return any 代码的返回
function lib.eval(s)
    return assert(load("return " .. (s or "")))()
end

function lib.string_to_vec2(str)
	local tb = lib.eval(str)
	if not tb then return {x = 0, y = 0} end 
	return {x = tb[1] or 0, y = tb[2] or 0}
end

function lib.string_to_color_array(str)
	str = str or ""
	str = #str >= 2 and str.sub(str, 2, -2) or str
	local arr = lib.split(str, ",")
	local x = tonumber(arr[1]) or 1
	local y = tonumber(arr[2]) or 1
	local z = tonumber(arr[3]) or 1
	local w = tonumber(arr[4]) or 1
	return {x, y, z, w}
end

function lib.color_array_to_string(array, precision)
	local get = function(idx)
		return lib.float_format(array[idx] or 1, precision)
	end
	return string.format("{%s,%s,%s,%s}", get(1), get(2), get(3), get(4))
end

---@return number 得到table的深度
function lib.get_table_depth(data)
	local function get_depth(tb, depth)
		if type(tb) == "table" then 
			local max = 1
			for i, v in pairs(tb) do 
				max = math.max(max, get_depth(v, depth + 1))
			end 
			return max
		else 
			return depth
		end
	end 
	return get_depth(data, 0)
end

return lib