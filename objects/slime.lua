local classic = require("objects.base")
local Slime = classic:extend()

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
end

function Slime:setPlayer(player) self.player = player end

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
		if not v.finished then
			v:update(dt)
			if v:checkHit(self.player) then
				print("HIT")
			end
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
	self.obj_anim:draw(self.sheet, self.pos.x, self.pos.y, self.rotation, self.sx, self.sy, self.ox, self.oy)
end

return Slime
