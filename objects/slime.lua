local classic = require("objects.base")
local Slime = classic:extend()

local Vec2 = require("modules.hump.vector")
local Flux = require("modules.flux.flux")

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
end

function Slime:gotoIntroPosition(delay, fn)
	Flux.to(self.pos, 2, { y = 0 }):ease("backout"):delay(delay or 0)
		:oncomplete(function()
			self.can_move = true
			if fn then fn() end
		end)
end

function Slime:update(dt)
	self.obj_anim:update(dt)
end

function Slime:draw()
	self.obj_anim:draw(self.sheet, self.pos.x, self.pos.y, self.rotation, self.sx, self.sy, self.ox, self.oy)
end

return Slime
