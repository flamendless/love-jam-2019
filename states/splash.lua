local BaseState = require("states.base_state")
local Splash = BaseState:extend()

local GSM = require("src.gamestate_manager")
local AssetsManager = require("src.assets_manager")
local Splashes = require("modules.splashes.o-ten-one")
local splash
local speed = 1

function Splash:new()
	Splash.super.new(self, "Splash")
end

function Splash:onLoad(previous, ...)
	splash = Splashes()
	splash.onDone = function() end
	AssetsManager:setFinished(true)

	if __DEBUG then
		speed = 2
	end
end

function Splash:update(dt)
	splash:update(dt * speed)
end

function Splash:draw()
	splash:draw()
end

return Splash
