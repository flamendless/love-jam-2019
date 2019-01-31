__DEBUG = true
if __DEBUG then
	io.stdout:setvbuf("no")
end

local GSM = require("src.gamestate_manager")
local States = require("states")

function love.load()
	GSM:initState(States.splash)
end

function love.update(dt)
	GSM:update(dt)
end

function love.draw()
	GSM:draw()
end

function love.keypressed(key)
end

function love.keyreleased(key)
end

function love.mousepressed(mx, my, mb)
end

function love.mousereleased(mx, my, mb)
end

function love.quit()
end
