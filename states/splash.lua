local BaseState = require("states.base_state")
local Splash = BaseState:extend()

local GSM = require("src.gamestate_manager")
local Splashes = require("modules.splashes.o-ten-one")
local splash

function Splash:new()
	Splash.super.new(self, "Splash")
end

function Splash:onLoad(previous, ...)
	splash = Splashes()
	splash.onDone = function() print(1) end
end

function Splash:update(dt)
	splash:update(dt)
end

function Splash:draw()
	splash:draw()
end

function Splash:keypressed(key)
end

function Splash:keyreleased(key)
end

function Splash:mousepressed(mx, my, mb)
end

function Splash:mousereleased(mx, my, mb)
end

function Splash:onExit()
end

return Splash
