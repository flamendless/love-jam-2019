local req = function(name)
	return require("states." .. name)
end

local States = {
	splash = req("splash"),
	title = req("title"),
	game = req("game"),
	gameover = req("gameover"),
}

return States
