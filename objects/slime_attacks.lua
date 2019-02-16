local req = function(name)
	return require("objects." .. name)
end

return {
	laser = req("slime_laser"),
	scatter = req("slime_scatter"),
	bomb = req("slime_bomb"),
	homing = req("slime_homing"),
}
