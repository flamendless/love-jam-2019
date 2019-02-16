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
	self.orig_accel = self.accel
	self.orig_deccel = self.deccel
	self.max_life = 100
	self.life = self.max_life
	self.input = Controls:setControls()
	self.color = {1, 1, 1, 1}
	self.rescued = {}
	self.projectiles = {}
	self.score = 0
	self.isDead = false
end

function Player:gotoIntroPosition(delay, fn)
	self.to_intro = Flux.to(self.pos, 2, { y = love.graphics.getHeight() * 0.75 }):ease("backout"):delay(delay or 0)
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
	if self.life <= 0 then self.isDead = true end
	if self.isDead then
		return
	end
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
		else
			self:shootRescued()
		end
	elseif self.input:pressed("repair") then
		if not (#self.rescued == 0) then
			self:doRepair()
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
	if self.pos.x - self.ox * self.sx < 0 then
		self.pos.x = self.ox * self.sx
	end
	if self.pos.x - self.ox * self.sx + self.width * self.sx > love.graphics.getWidth() then
		self.pos.x = love.graphics.getWidth() - (self.width - self.ox * self.sx)
	end

	self.pos.y = self.pos.y + self.yspeed * self.ydir * dt
	if self.pos.y - self.oy * self.sy < 0 then
		self.pos.y = self.oy * self.sy
	end
	if self.pos.y - self.oy * self.sy + self.height * self.sy > love.graphics.getHeight() then
		self.pos.y = love.graphics.getHeight() - (self.height - self.oy * self.sy)
	end

	for i, v in ipairs(self.rescued) do
		v.obj_anim:update(dt)
	end
	for i, v in ipairs(self.projectiles) do
		v.rotation = v.rotation + 64
		v.obj_anim:update(dt)
	end

	for i = #self.projectiles, 1, -1 do
		local obj = self.projectiles[i]
		if obj.remove then table.remove(self.projectiles, i) end
	end
end

function Player:draw()
	for i, v in ipairs(self.rescued) do
		v.obj_anim:draw(v.sheet, v.pos.x, v.pos.y)
	end
	for i, v in ipairs(self.projectiles) do
		v.obj_anim:draw(v.sheet, v.pos.x, v.pos.y, math.rad(v.rotation), 1, 1, v.ox, v.oy)
	end

	Player.super.draw(self)
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
	if not self.vulnerable then
		return
	end
	Flux.to(self, 5, { life = self.life - damage })
	print("Life: " .. self.life - damage)
	self.vulnerable = false
	self.color = {1, 0, 0, 1}
	Shack:setShake(200)
	Flux.to(self.color, 3, { [1] = 1, [2] = 1, [3] = 1 })
		:oncomplete(function()
			self.vulnerable = true
			self.color = {1, 1, 1, 1}
		end)
	self.snd_damage[math.random(1, #self.snd_damage)]:play()
end

function Player:giveRescued(obj)
	-- table.insert(self.rescued, obj)
	local w, h = obj.obj_anim:getDimensions()
	local _obj = {
		obj_anim = obj.obj_anim,
		sheet = obj.sheet,
		pos = obj.pos:clone(),
		damage = obj.damage,
		ox = w/2,
		oy = h/2,
	}
	table.insert(self.rescued, _obj)
	Flux.to(_obj.pos, 1, {
			x = 16 + (#self.rescued - 1) * 32,
			y = love.graphics.getHeight() - 48,
		}):ease("backin")
	self:increaseScore(love.graphics.getHeight() - obj.pos.y)

	--FRICTION!
	self.accel = self.accel - 8
	self.deccel = self.deccel - 8
end

function Player:shootRescued()
	local obj = self.rescued[#self.rescued]
	local _obj = {
		obj_anim = obj.obj_anim,
		sheet = obj.sheet,
		pos = self.pos:clone(),
		rotation = 0,
		ox = obj.ox, oy = obj.oy,
		remove = false,
	}
	self.sounds_attack[math.random(1, #self.sounds_attack)]:play()
	Flux.to(_obj.pos, 2, {
			x = self.obj_slime.pos.x - self.obj_slime.ox * self.obj_slime.sx + self.obj_slime.width/2 * self.obj_slime.sx,
			y = self.obj_slime.pos.y - self.obj_slime.oy * self.obj_slime.sy + self.obj_slime.height/2 * self.obj_slime.sy
		})
		:oncomplete(function()
			self.obj_slime:doDamage(obj.damage)
			self:increaseScore(obj.damage)
			_obj.remove = true
		end)
	table.insert(self.projectiles, _obj)
	table.remove(self.rescued, #self.rescued)
end

function Player:doRepair()
	self.life = self.life + 25
	if self.life > self.max_life then self.life = self.max_life end
	table.remove(self.rescued, #self.rescued)
	self.sounds_repair[math.random(1, #self.sounds_repair)]:play()
	self.color = {0, 1, 0, 1}
	Flux.to(self.color, 2, { [1] = 1, [2] = 1, [3] = 1 })
		:oncomplete(function() self.color = {1, 1, 1, 1} end)
	self:increaseScore(math.random(1, 3) * 25)
end

function Player:increaseScore(score)
	Flux.to(self, 3, { score = self.score + score })
end

function Player:setSlime(slime) self.obj_slime = slime end
function Player:setAttackSound(t) self.sounds_attack = t end
function Player:setRepair(t) self.sounds_repair = t end

function Player:bounce()
	Flux.to(self.pos, 0.5, { y = love.graphics.getHeight() * 0.8 })
end

return Player
