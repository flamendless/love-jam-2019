local Base = require("objects.base_attack")
local SlimeBomb = Base:extend()

local AssetsManager = require("src.assets_manager")
local GSM = require("src.gamestate_manager")
local Anim8 = require("modules.anim8.anim8")
local Vec2 = require("modules.hump.vector")
local Timer = require("modules.hump.timer")
local Flux = require("modules.flux.flux")

function SlimeBomb:new(parent, pos, timer)
	assert(Vec2.isvector(pos), "pos must be a vector")
	local sheet = AssetsManager:getImage(GSM:getID(), "sheet_slime_bomb")
	local grid = Anim8.newGrid(32, 36, sheet:getWidth(), sheet:getHeight())
	self.sound = AssetsManager:getSource(GSM:getID(), "explosion")
	self.explode = false
	self.hit = Anim8.newAnimation(grid('4-7', 1), 0.05, function()
		self.finished = true
	end)
	local obj_anim = Anim8.newAnimation(grid('1-3', 1), 0.3, function()
		if self.explode then
			self.obj_anim = self.hit
			self.sound:play()
			self.color = {1, 1, 1, 1}
		end
	end)
	SlimeBomb.super.new(self, "bomb", obj_anim, sheet)
	self.width = 32
	self.height = 36
	self.hit_frame = -1
	self:setDamage(25)

	self.pos = pos
	self.rotation = 0
	self.sx = 2
	self.sy = 2
	self.ox = self.width/2
	self.oy = self.height/2
	self.timer = timer
	self.color = {0, 0, 0, 1}

	Timer.after(self.timer, function()
		self.explode = true
		self.hit_frame = 0
	end)

	Flux.to(self.color, self.timer, { [1] = 1 })
end

return SlimeBomb
