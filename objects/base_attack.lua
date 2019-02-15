local classic = require("modules.classic.classic")
local BaseAttack = classic:extend()

function BaseAttack:new(id, obj_anim, sheet)
	self.id = id
	self.obj_anim = obj_anim
	self.sheet = sheet
	self.sheet:setFilter("nearest", "nearest")
end

function BaseAttack:update(dt)
	self.obj_anim:update(dt)
end

function BaseAttack:draw()
	self.obj_anim:draw(self.sheet, self.pos.x, self.pos.y, self.rotation, self.sx, self.sy, self.ox, self.oy)
end

function BaseAttack:checkHit(other)
end

return BaseAttack
