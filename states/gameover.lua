local BaseState = require("states.base_state")
local Gameover = BaseState:extend()

local GSM = require("src.gamestate_manager")
local text_score = ""
local text_time = ""
local text = "GAMEOVER!"
local option1 = "RETRY"
local option2 = "QUIT"
local cursor = 1

function Gameover:new()
	Gameover.super.new(self, "Gameover")
end

function Gameover:updateText(score, time)
	text_score = ("SCORE: %i"):format(score or 0)
	if math.floor(time) == 1 then
		text_time = ("TIME: %i second"):format(time or 0)
	else
		text_time = ("TIME: %i seconds"):format(time or 0)
	end
end

function Gameover:setFont(font_big, font_small)
	self.font_big = font_big
	self.font_small = font_small
end

function Gameover:draw()
	love.graphics.setColor(1, 1, 1, 1)
	love.graphics.setFont(self.font_big)
	love.graphics.print(text,
		love.graphics.getWidth()/2 - self.font_big:getWidth(text)/2,
		love.graphics.getHeight()/2 - self.font_big:getHeight(text)/2 - 128)

	love.graphics.setFont(self.font_small)
	love.graphics.print(text_score,
		love.graphics.getWidth()/2 - self.font_small:getWidth(text_score)/2,
		love.graphics.getHeight()/2 - self.font_small:getHeight(text_score)/2 - 64)

	love.graphics.print(text_time,
		love.graphics.getWidth()/2 - self.font_small:getWidth(text_time)/2,
		love.graphics.getHeight()/2 - self.font_small:getHeight(text_time)/2 - 16)

	if cursor == 1 then
		love.graphics.setColor(1, 0, 0, 1)
	else
		love.graphics.setColor(1, 1, 1, 1)
	end
	love.graphics.print(option1,
		love.graphics.getWidth()/2 - self.font_small:getWidth(option1)/2,
		love.graphics.getHeight()/2 + self.font_small:getHeight(option1) + 32)

	if cursor == 2 then
		love.graphics.setColor(1, 0, 0, 1)
	else
		love.graphics.setColor(1, 1, 1, 1)
	end
	love.graphics.print(option2,
		love.graphics.getWidth()/2 - self.font_small:getWidth(option2)/2,
		love.graphics.getHeight()/2 + self.font_small:getHeight(option2) * 2 + 64)
end

function Gameover:keypressed(key)
	if key == "up" or key == "w" or key == "k" then
		cursor = cursor - 1
		if cursor <= 0 then cursor = 2 end
	elseif key == "down" or key == "s" or key == "j" then
		cursor = cursor + 1
		if cursor > 2 then cursor = 1 end
	elseif key == "return" or key == "space" then
		if cursor == 1 then
			GSM:switch( require("states").game() )
		elseif cursor == 2 then
			love.event.quit()
		end
	end
end

return Gameover
