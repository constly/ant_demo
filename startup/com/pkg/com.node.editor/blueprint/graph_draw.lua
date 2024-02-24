---------------------------------------------------------------------------
-- 图绘制
---------------------------------------------------------------------------
local ed = require "imgui.node_editor"

---@param graph blueprint_graph_main
local create = function(graph)
	---@class blueprint_graph_draw
	local draw = {}
	local context 			

	function draw.on_init()
		context = ed.CreateEditorContext()
		context:OnStart()
	end 

	function draw.on_destroy()
		context:OnDestroy()
		context = nil
	end 

	-- 渲染更新
	function draw.on_render(deltatime)
		ed.SetCurrentEditor(context)
		ed.Begin("My Editor", 0, 0)
		ed.End()
		ed.SetCurrentEditor(nil)
	end

	return draw
end 


return {create = create}