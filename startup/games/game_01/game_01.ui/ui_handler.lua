
local function new(window, ...)	
	local model = window.createModel(...)

	function model.open(filepath)
		window.open(filepath)
	end

	return model
end

return {new = new}