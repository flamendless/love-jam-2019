local Base = require("objects.base_attack")
local SlimeScatter = Base:extend()

local AssetsManager = require("src.assets_manager")
local GSM = require("src.gamestate_manager")
local Anim8 = require("modules.anim8.anim8")
local Vec2 = require("modules.hump.vector")

function SlimeScatter:new(parent, xdir, ydir, xspeed, yspeed)
	local sheet = AssetsManager:getImage(GSM:getID(), "sheet_slime_scatter")
	local grid = Anim8.newGrid(32, 32, sheet:getWidth(), sheet:getHeight())
	local obj_anim = Anim8.newAnimation(grid('1-4', 1), 0.1)
	SlimeScatter.super.new(self, "scatter", obj_anim, sheet)
	self:setDamage(10)
	self.width = 32
	self.height = 32
	self.hit_frame = 0
	self.pos = Vec2(
		(parent.pos.x - parent.ox * parent.sx) + parent.width/2 * parent.sx - self.width/2,
		(parent.pos.y - parent.oy * parent.sy) + parent.height * parent.sy - self.height/2)
	self.rotation = 0
	self.sx = 1
	self.sy = 1
	self.ox = self.width/2
	self.oy = 0
	self.xspeed = xspeed
	self.yspeed = yspeed
	self.xdir = xdir
	self.ydir = ydir
end

function SlimeScatter:update(dt)
	SlimeScatter.super.update(self, dt)

	self.pos.x = self.pos.x + self.xspeed * self.xdir * dt
	self.pos.y = self.pos.y + self.yspeed * self.ydir * dt

	if self.pos.y > love.graphics.getHeight() + 32 then
		self.finished = true
	end
	if self.pos.x < -32 or self.pos.x > love.graphics.getWidth() + 32 then
		self.finished = true
	end
end

return SlimeScatter
