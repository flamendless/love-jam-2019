local Base = require("objects.base")
local Player = Base:extend()

local Baton = require("modules.baton.baton")
local Vec2 = require("modules.hump.vector")
local Flux = require("modules.flux.flux")

function Player:new(sprite, pos, rotation, sx, sy, ox, oy)
	assert(Vec2.isvector(pos), "pos must be a vector")
	Player.super.new(self, "player", sprite, pos, rotation, sx, sy, ox, oy)
	self.can_move = false
	self.xdir = 0
	self.ydir = 0
	self.max_speed = 512
	self.min_speed = 128
	self.xspeed = self.min_speed
	self.yspeed = self.min_speed
	self.accel = 128
end

function Player:setControls(control)
	if control == 1 then
		self.input = Baton.new({
				controls = {
					left = {"key:a"},
					right = {"key:d"},
					up = {"key:w"},
					down = {"key:s"},
				},
			})
	elseif control == 2 then
		self.input = Baton.new({
				controls = {
					left = {"key:left"},
					right = {"key:right"},
					up = {"key:up"},
					down = {"key:down"},
				},
			})
	elseif control == 3 then
		self.input = Baton.new({
				controls = {
					left = {"key:h"},
					right = {"key:l"},
					up = {"key:k"},
					down = {"key:j"},
				},
			})
	end
end

function Player:gotoIntroPosition(delay, fn)
	Flux.to(self.pos, 2, { y = love.graphics.getHeight() * 0.75 }):ease("backout"):delay(delay or 0)
		:oncomplete(function()
			self.can_move = true
			if fn then fn() end
		end)
end

function Player:update(dt)
	self.input:update()
	self.xdir = 0
	self.ydir = 0
	if not self.can_move then return end
	if self.input:down("left") then
		self.xdir = -1
		self.xspeed = self.xspeed - self.accel * dt
		if self.xspeed < self.min_speed then self.xspeed = self.min_speed end
	elseif self.input:down("right") then
		self.xdir = 1
		self.xspeed = self.xspeed + self.accel * dt
		if self.xspeed > self.max_speed then self.xspeed = self.max_speed end
	end
	if self.input:down("up") then
		self.ydir = -1
		self.yspeed = self.yspeed + self.accel * dt
		if self.yspeed > self.max_speed then self.yspeed = self.max_speed end
	elseif self.input:down("down") then
		self.ydir = 1
		self.xspeed = self.xspeed - self.accel * dt
		if self.xspeed < self.min_speed then self.xspeed = self.min_speed end
	end

	self.pos.x = self.pos.x + self.xspeed * self.xdir * dt
	self.pos.y = self.pos.y + self.yspeed * self.ydir * dt
end

function Player:getXDirection() return self.xdir end
function Player:getYDirection() return self.ydir end

return Player
