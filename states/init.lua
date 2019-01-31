local req = function(name)
	return require("states." .. name)
end

local States = {
	splash = req("splash")
}

return States
