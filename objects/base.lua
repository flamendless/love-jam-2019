local classic = require("modules.classic.classic")
local Base = classic:extend()

function Base:new(id, sprite, pos, rotation, sx, sy, ox, oy)
	self.id = id
	self.sprite = sprite
	self.pos = pos
	self.rotation = rotation or 0
	self.sx = sx or 1
	self.sy = sy or 1
	self.ox = ox or 0
	self.oy = oy or 0
end

function Base:update(dt) end

function Base:draw()
	love.graphics.draw(self.sprite,
		self.pos.x, self.pos.y,
		self.rotation, self.sx, self.sy,
		self.ox, self.oy)
end

return Base
