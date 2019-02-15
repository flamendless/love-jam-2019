local Controls = {
	control = 1,
}

local Baton = require("modules.baton.baton")

function Controls:init()
	self:set()
end

function Controls:set(n)
	if self.control == 1 then
		self.left = "a"
		self.right = "d"
		self.up = "w"
		self.down = "s"
		self.shoot = "n"
	elseif self.control == 2 then
		self.left = "left"
		self.right = "right"
		self.up = "up"
		self.down = "down"
		self.shoot = "z"
	elseif self.control == 3 then
		self.left = "h"
		self.right = "l"
		self.up = "k"
		self.down = "j"
		self.shoot = "f"
	end
end

function Controls:setControls()
	local input
	local control = self.control
	if control == 1 then
		input = Baton.new({
				controls = {
					left = {"key:a"},
					right = {"key:d"},
					up = {"key:w"},
					down = {"key:s"},
				},
			})
	elseif control == 2 then
		input = Baton.new({
				controls = {
					left = {"key:left"},
					right = {"key:right"},
					up = {"key:up"},
					down = {"key:down"},
				},
			})
	elseif control == 3 then
		input = Baton.new({
				controls = {
					left = {"key:h"},
					right = {"key:l"},
					up = {"key:k"},
					down = {"key:j"},
				},
			})
	end
	return input
end

function Controls:getMovement()
	return self.left, self.right, self.up, self.down
end

function Controls:getShoot() return self.shoot end

return Controls
