local classic = require("objects.base")
local Slime = classic:extend()

local Shack = require("modules.shack.shack")
local Vec2 = require("modules.hump.vector")
local Flux = require("modules.flux.flux")
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
	local attack = SlimeAttacks[kind](self)
	table.insert(self.projectiles, attack)
end

function Slime:update(dt)
	bar_percent = self.life/self.max_life * bar_w
	self.obj_anim:update(dt)
	for i, v in ipairs(self.projectiles) do
		v:update(dt)
		if v:checkHit(self.player) and self.player.vulnerable and v.can_hit then
			self.player:damage(v.damage)
		end
	end

	--safely remove
	for i = #self.projectiles, 1, -1 do
		local obj = self.projectiles[i]
		if obj.finished then table.remove(self.projectiles, i) end
	end
end

function Slime:draw()
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
		love.graphics.setColor(1, 1, 1, 1)
	end
end

function Slime:setHitSound(t) self.sounds_hit = t end
function Slime:damage(damage)
	local r = math.random(1, 3)
	Flux.to(self, 5, { life = self.life - damage * r })
	print("Slime hp: " .. self.life - damage * r)
	self.color = {1, 0, 0, 1}
	Flux.to(self.color, 2, { [1] = 1, [2] = 1, [3] = 1 })
		:oncomplete(function() self.color = {1, 1, 1, 1} end)
	self.sounds_hit[math.random(1, #self.sounds_hit)]:play()
	Shack:setShake(200)
end

return Slime
