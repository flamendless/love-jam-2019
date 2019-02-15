local Base = require("objects.base")
local Survivor = Base:extend()

local Flux = require("modules.flux.flux")

function Survivor:new(sprite, pos, rotation, sx, sy, ox, oy)
	Survivor.super.new(self, "island", sprite, pos, rotation, sx, sy, ox, oy)
	self.dir = -1
	self.dur = math.random(1, 2)
	self.proximity = 64
	self.rescued = false
	self.gone = false
	self.timer = math.random(3, 5)
	self.speed = 32
	self.being_rescued = false
	self:float(self.dir)
end

function Survivor:float(dir)
	Flux.to(self, self.dur, { oy = self.oy + 32 * dir })
		:oncomplete(function()
			self.dir = self.dir * -1
			self:float(self.dir)
		end)
end

function Survivor:setSuvivor(sheet, obj_anim)
	self.sheet = sheet
	self.obj_anim = obj_anim
end

function Survivor:setSoundOnRescue(snd)
	self.snd_rescued = snd
end

function Survivor:setSoundHelp(snd)
	self.snd_help = snd
	self.help = true
end

function Survivor:update(dt)
	Survivor.super.update(self, dt)
	self.obj_anim:update(dt)
	if self.rescued == false and self.timer <= 0 then
		self.rescued = true
		self.snd_rescued:play()
	end

	local speed = self.speed
	if self.being_rescued then
		speed = 16
	end
	self.pos.y = self.pos.y + speed * dt

	if self.help and self.pos.y > 64 then
		self.help = false
		self.snd_help:play()
	end

	if self.pos.y > love.graphics.getHeight() * 1.5 then
		self.gone = true
	end
end

local function CheckCircleCollision(x1,y1,w1,h1, x2,y2,radius)
return x1 < x2+radius and
	x2 < x1+w1 and
	y1 < y2+radius and
	y2 < y1+h1
end

function Survivor:checkHit(other)
	return CheckCircleCollision(other.pos.x - other.ox * other.sx, other.pos.y - other.oy * other.sy,
		other.width * other.sx, other.height * other.sy,
		self.pos.x - self.ox * self.sx, self.pos.y - self.oy * self.sy,
		self.proximity)
end

function Survivor:draw()
	Survivor.super.draw(self)
	self.obj_anim:draw(self.sheet,
		(self.pos.x - self.ox * self.sx) + self.width/2 * self.sx,
		(self.pos.y - self.oy * self.sy) + self.height/2 * self.sy,
		self.rotation, self.sx, self.sy, 16, 16)

	if __DEBUG then
		love.graphics.setColor(1, 0, 0, 1)
		love.graphics.circle("line", self.pos.x, self.pos.y, self.proximity)
	end
end

return Survivor
