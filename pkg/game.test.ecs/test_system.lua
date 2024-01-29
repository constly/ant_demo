
local ecs = ...
local system = ecs.system "test_system"

function system.init()
	print("[test_system] init")
end

function system.post_init()
	print("[test_system] post_init")
end

function system.data_changed()
	print("[test_system] data_changed")
end

function system.on_fixedupdate()
	print("[test_system] on_fixedupdate")
end

function system.exit()
	print("[test_system] exit")
end