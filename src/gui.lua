local GUI = {}

local text_life = ""
local text_time = ""
local text_score = ""
local text_slime_life = ""
local text_skip = "Press ESCAPE to skip intro"
local text_paused = "PAUSED!"
local text_resume = "Press 'm' to resume"

function GUI:new(font, font_big, font_medium)
	self.font = font
	self.font_big = font_big
	self.font_medium = font_medium
	self.time = 0
	self.timer_start = false
	self.skippable = false
end

function GUI:setObjects(player, slime)
	self.player = player
	self.slime = slime
end

function GUI:update(dt)
	if self.timer_start then
		self.time = self.time + dt
		text_time = ("TIME: %i"):format(self.time)
	end
	text_score = ("SCORE: %i"):format(self.player.score)
	text_life = ("LIFE: %i/100"):format(self.player.life)
	text_slime_life = ("SLIME: %i/%i"):format(self.slime.life, self.slime.max_life)
end

function GUI:draw()
	love.graphics.setColor(1, 1, 0, 1)
	love.graphics.setFont(self.font)
	love.graphics.print(text_life, 16, 16)
	love.graphics.print("RESCUED: " .. #self.player.rescued,
		16, love.graphics.getHeight() - self.font:getHeight("") - 64)
	love.graphics.print(text_score, 16, 16 + self.font:getHeight("") + 8)
	love.graphics.print(text_time, 16, 16 + self.font:getHeight("") * 2 + 16)
	love.graphics.print(text_slime_life, love.graphics.getWidth() * 0.65, 32)

	if self.skippable then
		love.graphics.print(text_skip, love.graphics.getWidth() - self.font:getWidth(text_skip) - 8, love.graphics.getHeight() - self.font:getHeight(text_skip) - 8)
	end
end

function GUI:drawPaused()
	love.graphics.setFont(self.font_big)
	love.graphics.setColor(1, 1, 0, 1)
	love.graphics.print(text_paused, love.graphics.getWidth()/2 - self.font_big:getWidth(text_paused)/2,
		love.graphics.getHeight() * 0.15)
	love.graphics.setFont(self.font_medium)
	love.graphics.print(text_resume, love.graphics.getWidth()/2 - self.font_medium:getWidth(text_resume)/2,
		love.graphics.getHeight() * 0.75)
end

return GUI
