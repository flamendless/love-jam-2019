local req = function(name)
	return require("objects." .. name)
end

return {
	laser = req("slime_laser"),
}
