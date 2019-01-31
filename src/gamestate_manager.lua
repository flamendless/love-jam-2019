local GSM = {
	previous_state,
	current_state,
}

local BaseState = require("states.base_state")

function GSM:initState(state)
	assert(state:is(BaseState), "Passed state must extend from base state")
	self.current_state = state
	self:init()
end

function GSM:init()
	if self.current_state.preload and not self.current_state:hasPreloaded() then
		self.current_state:preload()
		self.current_state:setPreload(true)
	else
		self.current_state:init()
	end
end

function GSM:switch(state)
	assert(state:is(BaseState), "Passed state must extend from base state")
	self.current_state:onExit()
	self.previous_state = self.current_state
	self.current_state = state
	self:init()
end

function GSM:switchToPrevious()
	if self.previous_state then
		self:switch(self.previous_state)
	else
		return nil
	end
end

function GSM:update(dt)
	self.current_state:update(dt)
end

function GSM:draw()
	self.current_state:draw()
end

function GSM:keypressed(key)
	self.current_state:keypressed(key)
end

function GSM:keyreleased(key)
	self.current_state:keyreleased(key)
end

function GSM:mousepressed(mx, my, mb)
	self.current_state:mousepressed(mx, my, mb)
end

function GSM:mousereleased(mx, my, mb)
	self.current_state:mousereleased(mx, my, mb)
end

return GSM
