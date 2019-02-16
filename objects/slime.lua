local classic = require("objects.base")
local Slime = classic:extend()

local Shack = require("modules.shack.shack")
local Vec2 = require("modules.hump.vector")
local Flux = require("modules.flux.flux")
local SlimeAttacks = require("objects.slime_attacks")

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
	self.life = 1000000
	self.color = {1, 1, 1, 1}
end

function Slime:setPlayer(player) self.player = player end
function Slime:setDimensions(w, h) self.width = w; self.height = h end

function Slime:gotoIntroPosition(delay, fn)
	Flux.to(self.pos, 2, { y = 0 }):ease("backout"):delay(delay or 0)
		:oncomplete(function()
			self.can_move = true
			if fn then fn() end
		end)
end

function Slime:attack(kind)
	local attack = SlimeAttacks[kind](self)
	table.insert(self.projectiles, attack)
end

function Slime:update(dt)
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
	self.life = self.life - damage * math.random(1, 3)
	self.color = {1, 0, 0, 1}
	Flux.to(self.color, 2, { [1] = 1, [2] = 1, [3] = 1 })
		:oncomplete(function() self.color = {1, 1, 1, 1} end)
	self.sounds_hit[math.random(1, #self.sounds_hit)]:play()
	Shack:setShake(200)
	print("Slime hp: " .. self.life)
end

return Slime
