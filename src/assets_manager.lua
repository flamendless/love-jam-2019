local AssetsManager = {
	isFinished = false,
	isFadeIn = false,
	images = {},
	sources = {},
	fonts = {},
	alpha = 1,
	in_alpha = 1,
	dur = 1.5,
	delay = 0.9,
	canvas,
}

local Loader = require("modules.love-loader.love-loader")
local Flux = require("modules.flux.flux")
local str
local _pos, _scale, _ox, _oy

function AssetsManager:init(dur, delay)
	self.canvas = love.graphics.newCanvas()
	self.dur = dur or self.dur
	self.delay = delay or self.delay
	self.image = love.graphics.newImage("assets/images/loading.png")
	self.image:setFilter("nearest", "nearest")
	self:random()
end

function AssetsManager:random()
	_pos = {
		x = love.graphics.getWidth()/2,
		y = love.graphics.getHeight() * 0.25
	}
	_scale = math.random(1, 2)
	_ox = self.image:getWidth()/2
	_oy = self.image:getHeight()/2
	Flux.to(_pos, 2, { y = love.graphics.getHeight() * 1.5 })
end

function AssetsManager:addImage(container, images)
	if not self.images[container] then
		self.images[container] = {}
	end
	for i, v in ipairs(images) do
		assert(v.id, "No ID is passed at index .. " .. i)
		assert(v.path, "No path is passed at index .." .. i)
		Loader.newImage(self.images[container], v.id, v.path)
	end
end

function AssetsManager:addFont(fonts)
	for i, v in ipairs(fonts) do
		assert(v.id, "No ID is passed at index .. " .. i)
		assert(v.path, "No path is passed at index .." .. i)
		assert(v.size, "No size is passed at index .." .. i)
		Loader.newFont(self.fonts, v.id, v.path, v.size)
	end
end

function AssetsManager:addSource(container, sources)
	if not self.sources[container] then
		self.sources[container] = {}
	end
	for i, v in ipairs(sources) do
		assert(v.id, "No ID is passed at index .. " .. i)
		assert(v.path, "No path is passed at index .." .. i)
		assert(v.kind, "No kind is passed at index .." .. i)
		Loader.newSource(self.sources[container], v.id, v.path, v.kind)
	end
end

function AssetsManager:onFinish(cb)
	Flux.to(self, self.dur, { alpha = 0 })
		:oncomplete(function()
			self.isFinished = true
			self.isFadeIn = true
			Flux.to(self, self.dur, { in_alpha = 0 })
				:oncomplete(function()
					self.isFadeIn = false
					--reset
					self.alpha = 1
					self.in_alpha = 1
				end)
		end)
		:delay(self.delay)
	if cb then cb() end
end

function AssetsManager:onLoad(kind, holder, key)
	local asset = holder[key]
	if kind == "image" or kind == "font" then
		asset:setFilter("nearest", "nearest")
	elseif kind == "streamSource" then
		asset:setLooping(false)
	end
end

function AssetsManager:start(cb)
	self:random()
	self.isFinished = false
	Loader.start(function()
		self:onFinish(cb)
	end,
	function(kind, holder, key)
		self:onLoad(kind, holder, key)
	end)
end

function AssetsManager:update(dt)
	if not self.isFinished then
		Loader.update()
		local percent = 0
		if Loader.resourceCount ~= 0 then percent = Loader.loadedCount / Loader.resourceCount end
		str = ("Loading..%2d%%"):format(percent * 100)
	end
end

function AssetsManager:draw()
	if not self.isFinished then
		love.graphics.setCanvas(self.canvas)
		love.graphics.clear()
		love.graphics.draw(self.image, _pos.x, _pos.y, 0, _scale, _scale, _ox, _oy)
		love.graphics.setCanvas()

		love.graphics.setColor(1, 1, 1, self.alpha)
		love.graphics.draw(self.canvas)
	end
end

function AssetsManager:drawTransition()
	if self.isFadeIn then
		love.graphics.setColor(0, 0, 0, self.in_alpha)
		love.graphics.rectangle("fill", 0, 0, love.graphics.getWidth(), love.graphics.getHeight())
	end
end

function AssetsManager:getIsFinished() return self.isFinished end

function AssetsManager:getFont(id)
	assert(self.fonts[id], ("Font '%s' does not exist"):format(id))
	return self.fonts[id]
end
function AssetsManager:getImage(container, id)
	assert(self.images[container], ("Container '%s' does not exist"):format(container))
	assert(self.images[container][id], ("Image '%s' does not exist"):format(id))
	return self.images[container][id]
end

function AssetsManager:getAllImages(container)
	assert(self.images[container], ("Container '%s' does not exist"):format(container))
	return self.images[container]
end

function AssetsManager:getSource(container, id)
	assert(self.sources[container], ("Container '%s' does not exist"):format(container))
	assert(self.sources[container][id], ("Source '%s' does not exist"):format(id))
	return self.sources[container][id]
end

function AssetsManager:getAllSources(container)
	assert(self.sources[container], ("Container '%s' does not exist"):format(container))
	return self.sources[container]
end

function AssetsManager:setFinished(bool) self.isFinished = bool end

return AssetsManager
