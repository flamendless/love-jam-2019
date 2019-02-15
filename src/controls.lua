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
		self.repair = "m"
	elseif self.control == 2 then
		self.left = "left"
		self.right = "right"
		self.up = "up"
		self.down = "down"
		self.shoot = "z"
		self.repair = "x"
	elseif self.control == 3 then
		self.left = "h"
		self.right = "l"
		self.up = "k"
		self.down = "j"
		self.shoot = "f"
		self.repair = "r"
	end
end

function Controls:setControls()
	local input
	local control = self.control
	input = Baton.new({
			controls = {
				left = {("key:%s"):format(self.left)},
				right = {("key:%s"):format(self.right)},
				up = {("key:%s"):format(self.up)},
				down = {("key:%s"):format(self.down)},
				shoot = {("key:%s"):format(self.shoot)},
				repair = {("key:%s"):format(self.repair)},
			},
		})
	return input
end

function Controls:getMovement()
	return self.left, self.right, self.up, self.down
end

function Controls:getShoot() return self.shoot end
function Controls:getRepair() return self.repair end

return Controls
