local Base = require("objects.base")
local Player = Base:extend()

local Shack = require("modules.shack.shack")
local Controls = require("src.controls")
local Vec2 = require("modules.hump.vector")
local Flux = require("modules.flux.flux")

function Player:new(sprite, pos, rotation, sx, sy, ox, oy)
	assert(Vec2.isvector(pos), "pos must be a vector")
	Player.super.new(self, "player", sprite, pos, rotation, sx, sy, ox, oy)
	self.can_move = false
	self.vulnerable = false
	self.xdir = 0
	self.ydir = 0
	self.max_speed = 512
	self.min_speed = 128
	self.xspeed = self.min_speed
	self.yspeed = self.min_speed
	self.accel = 128
	self.deccel = 256
	self.life = 100
	self.input = Controls:setControls()
	self.color = {1, 1, 1, 1}
	self.rescued = {}
	self.score = 0
end

function Player:gotoIntroPosition(delay, fn)
	Flux.to(self.pos, 2, { y = love.graphics.getHeight() * 0.75 }):ease("backout"):delay(delay or 0)
		:oncomplete(function()
			if __DEBUG then
				self.can_move = true
			end
			self.vulnerable = true
			if fn then fn() end
		end)
end

function Player:dodgeToLeft()
	self.can_move = false
	Flux.to(self.pos, 1, { x = 64 })
		:oncomplete(function()
			self.can_move = true
		end)
end

function Player:update(dt)
	self.input:update()
	self.xdir = 0
	self.ydir = 0
	if not self.can_move then return end
	if self.input:down("left") then
		self.xdir = -1
	elseif self.input:down("right") then
		self.xdir = 1
	end
	if self.input:down("up") then
		self.ydir = -1
	elseif self.input:down("down") then
		self.ydir = 1
	end
	if self.input:pressed("shoot") then
		if #self.rescued == 0 then
			self:damage(25)
		end
	end

	if self.xdir == 0 then
		self.xspeed = self.xspeed - self.deccel * dt
		if self.xspeed < self.min_speed then self.xspeed = self.min_speed end
	elseif self.xdir ~= 0 then
		self.xspeed = self.xspeed + self.accel * dt
		if self.xspeed > self.max_speed then self.xspeed = self.max_speed end
	end
	if self.ydir == 0 then
		self.yspeed = self.yspeed - self.deccel * dt
		if self.yspeed < self.min_speed then self.yspeed = self.min_speed end
	elseif self.ydir ~= 0 then
		self.yspeed = self.yspeed + self.accel * dt
		if self.yspeed > self.max_speed then self.yspeed = self.max_speed end
	end

	if self.xdir ~= 0 or self.ydir ~= 0 then
		self:playMoveSound()
	elseif self.xdir == 0 and self.ydir == 0 then
		self.sound_move:stop()
	end

	self.pos.x = self.pos.x + self.xspeed * self.xdir * dt
	self.pos.y = self.pos.y + self.yspeed * self.ydir * dt
end

function Player:playMoveSound()
	if not self.sound_move:isPlaying() then
		self.sound_move:setVolume(1)
		self.sound_move:play()
	end
end

function Player:setDamageSound(audio) self.snd_damage = audio end

function Player:getXDirection() return self.xdir end
function Player:getYDirection() return self.ydir end
function Player:setMoveSound(audio)
	assert(audio:type() == "Source", "audio must be a source")
	self.sound_move = audio
end

function Player:damage(damage)
	self.life = self.life - damage
	print("Life: " .. self.life)
	self.vulnerable = false
	self.color = {1, 0, 0, 1}
	Shack:setShake(200)
	Flux.to(self.color, 2, { [1] = 1, [2] = 1, [3] = 1 })
		:oncomplete(function()
			self.vulnerable = true
			self.color = {1, 1, 1, 1}
		end)
	self.snd_damage[math.random(1, #self.snd_damage)]:play()
end

function Player:giveRescued(obj)
	table.insert(self.rescued, obj)
	self.score = self.score + love.graphics.getHeight() - obj.pos.y
end

return Player
