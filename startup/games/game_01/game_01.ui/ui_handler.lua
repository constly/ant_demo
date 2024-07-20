
local function new(window, ...)	
	local model = window.createModel(...)

	function model.open_ui(fileName, ...)
		window.open('/pkg/game_01.res/ui/' .. fileName .. ".html", ...);
	end

	return model
end

return {new = new}