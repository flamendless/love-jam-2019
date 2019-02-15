local Base = require("objects.base_attack")
local SlimeLaser = Base:extend()

local AssetsManager = require("src.assets_manager")
local GSM = require("src.gamestate_manager")
local Anim8 = require("modules.anim8.anim8")
local Vec2 = require("modules.hump.vector")

function SlimeLaser:new(parent)
	local sheet = AssetsManager:getImage(GSM:getID(), "sheet_slime_laser")

	local grid = Anim8.newGrid(101, 360, sheet:getWidth(), sheet:getHeight())
	local obj_anim = Anim8.newAnimation(grid('1-5', 1), 0.3, function()
		self.finished = true
	end)
	SlimeLaser.super.new(self, "laser", obj_anim, sheet)

	self.width = 101
	self.height = 360
	self.pos = Vec2(parent.pos.x + parent.width/2 - self.width/2, parent.pos.y + parent.height * parent.sy - 64)
	self.rotation = 0
	self.sx = 1
	self.sy = 2
	self.ox = 101/2
	self.oy = 0
end

return SlimeLaser
