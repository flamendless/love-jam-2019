local classic = require("modules.classic.classic")
local BaseAttack = classic:extend()

function BaseAttack:new(id, obj_anim, sheet)
	self.id = id
	self.obj_anim = obj_anim
	self.sheet = sheet
	self.sheet:setFilter("nearest", "nearest")
	self.current_frame = 0
	self.can_hit = false
end

function BaseAttack:setDamage(damage) self.damage = damage end

function BaseAttack:update(dt)
	self.obj_anim:update(dt)
	self.current_frame = self.current_frame + dt
end

function BaseAttack:draw()
	if self.color then
		love.graphics.setColor(self.color)
	else
		love.graphics.setColor(1, 1, 1, 1)
	end
	self.obj_anim:draw(self.sheet, self.pos.x, self.pos.y, self.rotation, self.sx, self.sy, self.ox, self.oy)

	if self.hit_frame ~= -1 and self.current_frame >= self.hit_frame then
		self.can_hit = true
	else
		self.can_hit = false
	end

	if __DEBUG then
		if self.can_hit then
			love.graphics.setColor(1, 0, 0, 1)
		else
			love.graphics.setColor(0, 0, 1, 1)
		end
		love.graphics.rectangle("line",
			self.pos.x - self.ox * self.sx,
			self.pos.y - self.oy * self.sy,
			(self.hit_width or self.width) * self.sx,
			(self.hit_height or self.height) * self.sy)
	end
end

local function CheckCollision(x1,y1,w1,h1, x2,y2,w2,h2)
return x1 < x2+w2 and
	x2 < x1+w1 and
	y1 < y2+h2 and
	y2 < y1+h1
end

function BaseAttack:checkHit(other)
	return CheckCollision(
		self.pos.x - self.ox * self.sx, self.pos.y - self.oy * self.sy,
		(self.hit_width or self.width) * self.sx,
		(self.hit_height or self.height) * self.sy,
		other.pos.x - other.ox * other.sx, other.pos.y - other.oy * other.sy,
		other.width * other.sx,
		other.height * other.sy)
end

return BaseAttack
