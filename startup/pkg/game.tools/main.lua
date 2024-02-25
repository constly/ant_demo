---@type com.common.main
local common = import_package 'com.common'

local api = {}
api.lib         = common.lib
api.user_data   = common.user_data

api.path        = require 'tools/path'

return api