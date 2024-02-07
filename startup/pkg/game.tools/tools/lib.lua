local lib = {}

function lib.split(content, delim)
    delim = delim or '\n'
    if string.len(content) <= 0 then 
        return {} 
    end
	local ret = {};
	local pat = "(.-)" .. delim;
	local pos = 0;
	while pos <= string.len(content) do
		local _start, _end, part = string.find(content, pat, pos);
		if not _start then
			table.insert(ret, string.sub(content, pos));
			pos = string.len(content) + 1;
		else
			table.insert(ret, part or "");
			pos = _end + 1;
		end
	end
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

function lib.dump(obj)
    if not obj then return print("nil") end;
        
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
    dumpObj = function(obj, level)
        if type(obj) ~= "table" then
            return wrapVal(obj)
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
    print(dumpObj(obj, 0));
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