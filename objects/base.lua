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
	self:setDimensions(sprite:getWidth(), sprite:getHeight())
end

function Base:update(dt) end

function Base:draw()
	if self.color then love.graphics.setColor(self.color) end
	love.graphics.draw(self.sprite,
		self.pos.x, self.pos.y,
		self.rotation, self.sx, self.sy,
		self.ox, self.oy)

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

function Base:setDimensions(w, h)
	self.width = w
	self.height = h
end

return Base
