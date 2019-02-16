local classic = require("objects.base")
local Slime = classic:extend()

local Shack = require("modules.shack.shack")
local Timer = require("modules.hump.timer")
local Vec2 = require("modules.hump.vector")
local Flux = require("modules.flux.flux")
local Lume = require("modules.lume.lume")
local SlimeAttacks = require("objects.slime_attacks")

local bar_pad = 16
local bar_y = bar_pad
local bar_w = 192
local bar_h = 16
local bar_percent = 0

function Slime:new(obj_anim, sheet, pos, rotation, sx, sy, ox, oy)
	assert(Vec2.isvector(pos), "pos must be a vector")
	self.obj_anim = obj_anim
	self.sheet = sheet
	self.pos = pos
	self.rotation = rotation
	self.sx = sx
	self.sy = sy
	self.ox = ox
	self.oy = oy
	self.can_move = false
	self.projectiles = {}
	self.max_life = 1000000
	self.life = self.max_life
	self.show_hp = false
	self.color = {1, 1, 1, 1}
	self.damage = 40
end

function Slime:setPlayer(player) self.player = player end
function Slime:setDimensions(w, h) self.width = w; self.height = h end

function Slime:gotoIntroPosition(delay, fn)
	self.to_intro = Flux.to(self.pos, 2, { y = 0 }):ease("backout"):delay(delay or 0)
		:oncomplete(function()
			self.can_move = true
			self.show_hp = true
			if fn then fn() end
		end)
end

function Slime:attack(kind)
	if kind == "laser" then
		local attack = SlimeAttacks[kind](self)
		table.insert(self.projectiles, attack)
	elseif kind == "scatter" then
		local n = math.random(7, 15)
		print("scatter count: " .. n)
		Timer.every(1.25, function()
			local c = SlimeAttacks[kind](self, 0, 1, 0, 128)
			local l = SlimeAttacks[kind](self, -1, 1, 64, 128)
			local l2 = SlimeAttacks[kind](self, -1, 1, 128, 64)
			local r = SlimeAttacks[kind](self, 1, 1, 64, 128)
			local r2 = SlimeAttacks[kind](self, 1, 1, 128, 64)
			local w = SlimeAttacks[kind](self, -1, 1, 512, 0)
			local e = SlimeAttacks[kind](self, 1, 1, 512, 0)
			local nw = SlimeAttacks[kind](self, -1, -1, 256, 128)
			local nw2 = SlimeAttacks[kind](self, -1, -1, 256, 256)
			local ne = SlimeAttacks[kind](self, 1, -1, 256, 128)
			local ne2 = SlimeAttacks[kind](self, 1, -1, 256, 256)
			table.insert(self.projectiles, c)
			table.insert(self.projectiles, l)
			table.insert(self.projectiles, l2)
			table.insert(self.projectiles, r)
			table.insert(self.projectiles, r2)
			table.insert(self.projectiles, w)
			table.insert(self.projectiles, e)
			table.insert(self.projectiles, nw)
			table.insert(self.projectiles, nw2)
			table.insert(self.projectiles, ne)
			table.insert(self.projectiles, ne2)
		end, n)

	elseif kind == "bomb" then
		local n = math.random(5, 10)
		print("bomb count: " .. n)
		Timer.every(2, function()
			local pos = Vec2(
					math.random(0, love.graphics.getWidth()),
					math.random(0, love.graphics.getHeight())
				)
			local timer = math.random(2, 4)
			local b = SlimeAttacks[kind](self, pos, timer)
			table.insert(self.projectiles, b)
		end, n)

	elseif kind == "homing" then
		local n = math.random(10, 15)
		print("homing count: " .. n)
		Timer.every(1.5, function()
			local a = SlimeAttacks[kind](self, self.player)
			table.insert(self.projectiles, a)
		end)
	end
end

function Slime:move()
	local choice = Lume.randomchoice({"left", "right", "center"})
	print("slime direction: " .. choice)
	if self.prev and self.prev == choice then
		self:move()
	else
		if choice == "left" then
			self.orig_pos = self.pos:clone()
			Flux.to(self.pos, 5, { x = 128 })
		elseif choice == "right" then
			self.orig_pos = self.pos:clone()
			Flux.to(self.pos, 5, { x = love.graphics.getWidth() * 0.75 })
		elseif choice == "center" then
			if self.orig_pos then
				Flux.to(self.pos, 5, { x = self.orig_pos.x })
			end
		end
		self.prev = choice
	end
end

function Slime:update(dt)
	bar_percent = self.life/self.max_life * bar_w
	self.obj_anim:update(dt)
	if self:checkHit(self.player) then
		self.player:damage(self.damage)
		self.player:bounce()
	end
	for i, v in ipairs(self.projectiles) do
		v:update(dt)
		if v:checkHit(self.player) and self.player.vulnerable and v.can_hit then
			self.player:damage(v.damage)
			v.finished = true
		end
	end

	--safely remove
	for i = #self.projectiles, 1, -1 do
		local obj = self.projectiles[i]
		if obj.finished then table.remove(self.projectiles, i) end
	end
end

function Slime:draw()
	love.graphics.setColor(1, 1, 1, 1)
	for i, v in ipairs(self.projectiles) do
		v:draw()
	end

	love.graphics.setColor(self.color)
	self.obj_anim:draw(self.sheet, self.pos.x, self.pos.y, self.rotation, self.sx, self.sy, self.ox, self.oy)

	--HP Bar
	if self.show_hp then
		love.graphics.setColor(1, 0, 0, 1)
		love.graphics.rectangle("fill", love.graphics.getWidth() - bar_w - bar_pad, bar_y, bar_w, bar_h)
		love.graphics.setColor(0, 1, 1, 1)
		love.graphics.rectangle("fill", love.graphics.getWidth() - bar_w - bar_pad, bar_y, bar_percent, bar_h)
		love.graphics.setColor(1, 1, 1, 1)
	end

	if __DEBUG then
		love.graphics.setColor(1, 0, 0, 1)
		love.graphics.rectangle("line",
			self.pos.x - self.ox * self.sx,
			self.pos.y - self.oy * self.sy,
			self.width * self.sx,
			self.height * self.sy)
		love.graphics.setColor(0, 1, 0, 1)
		love.graphics.rectangle("line",
			self.pos.x - self.width/2, self.pos.y + self.height/2,
			self.width, self.height)
		love.graphics.setColor(1, 1, 1, 1)
	end
end

function Slime:setHitSound(t) self.sounds_hit = t end
function Slime:doDamage(damage)
	local r = math.random(1, 3)
	Flux.to(self, 5, { life = self.life - damage * r })
	print("Slime hp: " .. self.life - damage * r)
	self.color = {1, 0, 0, 1}
	Flux.to(self.color, 2, { [1] = 1, [2] = 1, [3] = 1 })
		:oncomplete(function() self.color = {1, 1, 1, 1} end)
	self.sounds_hit[math.random(1, #self.sounds_hit)]:play()
	Shack:setShake(200)
end

local function CheckCollision(x1,y1,w1,h1, x2,y2,w2,h2)
return x1 < x2+w2 and
	x2 < x1+w1 and
	y1 < y2+h2 and
	y2 < y1+h1
end

function Slime:checkHit(other)
	return CheckCollision(
		self.pos.x - self.width/2,
		self.pos.y + self.height/2,
		self.width, self.height,
		other.pos.x - other.ox * other.sx, other.pos.y - other.oy * other.sy,
		other.width * other.sx,
		other.height * other.sy)
end

return Slime
