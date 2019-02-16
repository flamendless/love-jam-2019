local Base = require("objects.base_attack")
local SlimeHoming = Base:extend()

local AssetsManager = require("src.assets_manager")
local GSM = require("src.gamestate_manager")
local Anim8 = require("modules.anim8.anim8")
local Vec2 = require("modules.hump.vector")

local map = function(n, start1, stop1, start2, stop2)
	return ((n - start1)/(stop1 - start1)) * (stop2 - start2) + start2
end

function SlimeHoming:new(parent, target)
	local sheet = AssetsManager:getImage("game", "sheet_slime_scatter")
	local grid = Anim8.newGrid(32, 32, sheet:getWidth(), sheet:getHeight())
	local obj_anim = Anim8.newAnimation(grid('1-4', 1), 0.1)
	SlimeHoming.super.new(self, "homing", obj_anim, sheet)
	self.target = target
	self:setDamage(10)
	self.width = 32
	self.height = 32
	self.hit_frame = 0
	self.pos = Vec2((parent.pos.x - parent.ox * parent.sx) + parent.width/2 * parent.sx - self.width/2, (parent.pos.y - parent.oy * parent.sy) + parent.height * parent.sy - self.height/2)
	self.rotation = 0
	self.sx = 0.5
	self.sy = 0.5
	self.ox = self.width/2
	self.oy = self.height/2
	self.max_speed = 6
	self.velocity = Vec2()
	self.accel = Vec2()
	self.should_seek = true
	self.distance = 200
end

function SlimeHoming:seek()
	local desired = self.target.pos - self.pos
	local d = desired:len()
	desired = desired:normalized()
	if d < self.distance then
		local m = map(d, 0, self.distance, 0, self.max_speed)
		desired = desired * m
		self.should_seek = false
	else
		desired = desired * self.max_speed
	end
	local steer = desired - self.velocity
	steer:trimmed(0.1)
	self.accel = self.accel + steer
end

function SlimeHoming:update(dt)
	SlimeHoming.super.update(self, dt)
	if self.should_seek then
		self:seek()
	end
	self.velocity = self.velocity + self.accel
	self.velocity:trimmed(self.max_speed)
	self.pos = self.pos + self.velocity
	self.accel = self.accel * 0

	if self.pos.y > love.graphics.getHeight() + 32 then
		self.finished = true
	end
	if self.pos.x < -32 or self.pos.x > love.graphics.getWidth() + 32 then
		self.finished = true
	end
end

return SlimeHoming
