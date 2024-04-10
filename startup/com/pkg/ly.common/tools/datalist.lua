---@class ly.common.datalist
local api = {}

local datalist = require 'datalist'

local out
local conv

local function sortpairs(t)
    local sort = {}
    for k in pairs(t) do
        if type(k) == "string" then
            sort[#sort+1] = k
		elseif type(k) == "number" then 
			error("datalist中key类型不能是number")
        end
    end
    table.sort(sort)
    local n = 1
    return function ()
        local k = sort[n]
        if k == nil then
            return
        end
        n = n + 1
        return k, t[k]
    end
end

local function isArray(v)
	if type(v) == "table" then 
		local n = 0
		for _, _ in pairs(v) do
			n = n + 1
		end 
		return n == #v
	end 
end

local function is_simple_array_recursively(v)
	local function check(v)
		if type(v) == "table" then 
			if not isArray(v) then 
				return false
			end 
			for i, v in ipairs(v) do 
				local ret = check(v)
				if not ret then 
					return false
				end
			end
		end
		return true 
	end
	return check(v)
end

local function indent(n)
    return ("  "):rep(n)
end

local function convertreal(v)
    local g = ('%.16g'):format(v)
    if tonumber(g) == v then
        return g
    end
    return ('%.17g'):format(v)
end

local function stringify_basetype(v)
    local t = type(v)
    if t == 'number' then
        if math.type(v) == "integer" then
            return ('%d'):format(v)
        else
            return convertreal(v)
        end
    elseif t == 'string' then
        if v:match "^%$" then
            return v
        end
        if v == "" or v == "true" or v == "false" or v == "nil" then
            return datalist.quote(v)
        end
        if tonumber(v) then
            return datalist.quote(v)
        end
        if v:match "[\0-\31\x80-\xFF#:$-,%s\"\\{}%[%]]" then
            return datalist.quote(v)
        end
        return v
    elseif t == 'boolean'then
        if v then
            return 'true'
        else
            return 'false'
        end
    elseif t == 'function' then
        return 'null'
    end
    error('invalid type:'..t)
end

local function try_conv(prefix, v)
    if type(v) == "table" or type(v) == "userdata" then
        local class = conv[v]
        if class then
            prefix = prefix.." $"..class.name
            if class.save then
                v = class.save(v)
            end
        end
    end
    return prefix, v
end

local function parse_simple_table(v, depth)
	if type(v) == "table" then 
		local s = {}
		for i, v in ipairs(v) do 
			s[i] = parse_simple_table(v, depth + 1)
		end
		if depth == 0 then 
			return table.concat(s, ", ")
		else 
			return "{" .. table.concat(s, ", ") .. "}"
		end
	else
		return stringify_basetype(v)
	end
end

local stringify_
local stringify_value

local function stringify_array_simple(n, prefix, t)
    local s = {}
    for _, v in ipairs(t) do
        s[#s+1] = stringify_basetype(v)
    end
    out[#out+1] = indent(n)..prefix.."{"..table.concat(s, ", ").."}"
end

local function stringify_array_map(n, t)
    for _, tt in ipairs(t) do
        out[#out+1] = indent(n).."---"
        for k, v in sortpairs(tt) do
            stringify_value(n, k..":", v)
        end
    end
end

local function stringify_array_array(n, t)
    local _, t1 = try_conv('', t[1])
    local first_value = t1[1]
    if type(first_value) ~= "table" then
        for _, tt in ipairs(t) do
            local prefix, tt = try_conv('', tt)
            prefix = prefix == '' and prefix or (prefix:sub(2) .. ' ')
            stringify_array_simple(n, prefix, tt)
        end
        return
    end
    for _, tt in ipairs(t) do
        out[#out+1] = indent(n).."---"
        stringify_(n, tt)
    end
end

local function stringify_array(n, prefix, t)
	if is_simple_array_recursively(t) then 
		out[#out+1] = indent(n)..prefix
		out[#out+1] = indent(n + 1) .. parse_simple_table(t, 0)
	else 
		local first_value = t[1]
		if type(first_value) == "table" then
			out[#out+1] = indent(n)..prefix
			if isArray(first_value) then
				stringify_array_array(n+1, t)
				return
			end
			stringify_array_map(n+1, t)
		elseif type(first_value) == "string" then
			out[#out+1] = indent(n)..prefix
			for _, v in ipairs(t) do
				out[#out+1] = indent(n+1)..stringify_basetype(v)
			end
		else
			stringify_array_simple(n, prefix.." ", t)
		end
	end
end

local function stringify_map(n, prefix, t)
    out[#out+1] = indent(n)..prefix
    n = n + 1
    for k, v in sortpairs(t) do
        stringify_value(n, k..":", v)
    end
end

function stringify_value(n, prefix, v)
    prefix, v = try_conv(prefix, v)
    if type(v) == "table" then
        local first_value = next(v)
        if first_value == nil then
            out[#out+1] = indent(n)..prefix..' {}'
            return
        end
        if type(first_value) == "number" then
            stringify_array(n, prefix, v)
        else
            stringify_map(n, prefix, v)
        end
        return
    end
    out[#out+1] = indent(n)..prefix.." "..stringify_basetype(v)
end

function stringify_(n, data)
    if isArray(data) then
		if is_simple_array_recursively(data) then 
			out[#out+1] = indent(n) .. parse_simple_table(data, 0)
		else 
			local first_value = data[1]
			if type(first_value) ~= "table" then
				stringify_array_simple(n, "", data)
				return
			end
			if isArray(first_value) then
				stringify_array_array(n, data)
				return
			end
			stringify_array_map(n, data)
		end
    else
        for k, v in sortpairs(data) do
            stringify_value(n, k..":", v)
        end
    end
end


--- 序列化
function api.serialize(data)
	out = {}
    conv = {}
    stringify_(0, data)
    return table.concat(out, '\n')
end 

--- 反序列化
function api.deserialize(data)
	return datalist.parse(data)
end 

return api