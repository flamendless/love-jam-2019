__DEBUG = true
if __DEBUG then
	io.stdout:setvbuf("no")
end

local Flux = require("modules.flux.flux")
local Timer = require("modules.hump.timer")
local Moonshine = require("modules.moonshine")

local GSM = require("src.gamestate_manager")
local AssetsManager = require("src.assets_manager")
local States = require("states")

local effect_crt

function love.load()
	effect_crt = Moonshine(Moonshine.effects.crt)
	math.randomseed(os.time())
	if __DEBUG then
		AssetsManager:init(0.25, 0.25)
	else
		AssetsManager:init()
	end
	if __DEBUG then
		-- GSM:initState(States.title())
		GSM:initState(States.game())
	else
		GSM:initState(States.splash())
	end
end

function love.update(dt)
	Timer.update(dt)
	Flux.update(dt)
	if not AssetsManager:getIsFinished() then
		AssetsManager:update(dt)
	else
		GSM:update(dt)
	end
end

function love.draw()
	if not AssetsManager:getIsFinished() then
		AssetsManager:draw()
	else
		effect_crt(function()
			GSM:draw()
			AssetsManager:drawTransition()
		end)
	end
end

function love.keypressed(key)
	GSM:keypressed(key)
end

function love.keyreleased(key)
	GSM:keyreleased(key)
end

function love.mousepressed(mx, my, mb)
	GSM:mousepressed(mx, my, mb)
end

function love.mousereleased(mx, my, mb)
	GSM:mousereleased(mx, my, mb)
end

function love.quit()
end
