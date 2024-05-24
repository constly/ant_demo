
---@param api sims.msg
local function new(api)

	api.reg_center_rpc(api.rpc_restart, 
		function(player, tbParam, fd)
			print("save type", tbParam.type, tbParam.save_id)
			if tbParam.type == "only_save" then 			-- 只存档
				return api.center.save_mgr.save()
			elseif tbParam.type == "cover" then				-- 覆盖存档
				return api.center.save_mgr.cover_save(tbParam.save_id)
			end
			api.center.restart_before()
			if tbParam.type == "load" then					-- 读档
				api.center.save_mgr.load_save(tbParam.save_id)	
			elseif tbParam.type == "new_save" then 			-- 新建存档
				api.center.save_mgr.new_save()
			elseif tbParam.type == "save_and_load" then 	-- 存档后马上读档（不写文件）
				api.center.save_mgr.save_and_load()
			elseif tbParam.type == "load_last" then 		-- 读取最近一次存档
				api.center.save_mgr.load_save_last()
			end
			api.center.restart_after()
		end)

end

return {new = new}