---@type ly.common.lib
local lib = require 'tools.lib'

---@type ly.common.dep
local dep = require 'dep'

---@type ly.common.path_def
local path_def = require "path_def"

local fs = dep.fs 
local file_path = path_def.cache_root .. 'user_data.txt'
local version = "0.0.1"

local function load_string_from_disk(path)
    local f<close> = io.open(path, 'r')
    if f then 
        return f:read "a"
    end 
    return ""
end

local function save_string_to_disk(_path, _content)
	fs.create_directories(path_def.cache_root)
    local f<close> = io.open(_path, 'wb')
    if f then
        f:write(_content)
    end
end

---@class ly.common.user_data
local api = {}
local data = {}

function api.get_number(key, default)
    return tonumber(api.get(key)) or default or 0
end

function api.get_guid()
	local key = "guid"
	local v = api.get(key)
	if not v then 
		v = string.format("id_%s_%s", math.random(1 << 20, 1 << 45), os.time()) 
		api.set(key, v, true)
	end
	return v
end

function api.get(key, default)
    return data[key] or default
end 

function api.set(key, value, auto_save)
    if data[key] == value then 
        return
    end
    data[key] = value
    if auto_save then 
        api.save()
    end
end 

function api.delete(key)
    data[key] = nil
end

function api.save()
    local tb = {}
    for k, v in pairs(data) do
        local str = string.format("%s=%s", k, tostring(v))
        table.insert(tb, str) 
    end
    table.sort(tb)
    save_string_to_disk(file_path, table.concat(tb, "\n"));
end

do
    local content = load_string_from_disk(file_path);
    local lines = lib.split(content, "\n")
    for _, v in ipairs(lines) do 
        local pos = string.find(v, '=')
        if pos then 
            local key = string.sub(v, 1, pos - 1)
            local value = string.sub(v, pos + 1)
            data[key] = value 
        end
    end
	if api.get("_user_data.version") ~= version then 
		data = {}
		api.set("_user_data.version", version)
	end
end

return api