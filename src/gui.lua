local GUI = {}

local text_time = ""
local text_score = ""

function GUI:new(font)
	self.font = font
	self.time = 0
	-- self.timer_start = false
	self.timer_start = true
end

function GUI:setObjects(player)
	self.player = player
end

function GUI:update(dt)
	if self.timer_start then
		self.time = self.time + dt
		text_time = ("TIME: %i"):format(self.time)
	end
	text_score = ("SCORE: %i"):format(self.player.score)
end

function GUI:draw()
	love.graphics.setColor(1, 1, 0, 1)
	love.graphics.setFont(self.font)
	if self.player then
		love.graphics.print("LIFE: " .. self.player.life .. "/100", 16, 16)
		love.graphics.print("RESCUED: " .. #self.player.rescued,
			16, love.graphics.getHeight() - self.font:getHeight("") - 8)
		love.graphics.print(text_score, 16, 16 + self.font:getHeight("") + 8)
		love.graphics.print(text_time, 16, 16 + self.font:getHeight("") * 2 + 16)
	end
end

return GUI
